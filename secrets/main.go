package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"
)

const cacheTTL = 24 * time.Hour

type request struct {
	Reference string `json:"reference"`
}

type response struct {
	Value    string `json:"value,omitempty"`
	Error    string `json:"error,omitempty"`
	ExitCode int    `json:"exit_code,omitempty"`
	Stderr   []byte `json:"stderr,omitempty"`
}

type commandFailure struct {
	code   int
	stderr []byte
}

func (failure *commandFailure) Error() string {
	return "op read failed"
}

type secretCache struct {
	mu      sync.Mutex
	values  map[string]string
	expires map[string]time.Time
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		var failure *commandFailure
		if errors.As(err, &failure) {
			_, _ = os.Stderr.Write(failure.stderr)
			os.Exit(failure.code)
		}
		fmt.Fprintln(os.Stderr, "secrets:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 1 && args[0] == "serve" {
		return serve()
	}
	if len(args) == 2 && args[0] == "read" {
		value, err := read(args[1])
		if err != nil {
			return err
		}
		fmt.Print(value)
		return nil
	}
	return errors.New("usage: secrets read <op-reference> | secrets serve")
}

func socketPath() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".cache", "dotfiles", "secrets", "secrets.sock"), nil
}

func read(reference string) (string, error) {
	if !strings.HasPrefix(reference, "op://") {
		return "", errors.New("reference must start with op://")
	}
	path, err := socketPath()
	if err != nil {
		return "", err
	}
	if err := ensureServer(path); err != nil {
		return "", err
	}
	conn, err := net.DialTimeout("unix", path, 2*time.Second)
	if err != nil {
		return "", fmt.Errorf("connect to secrets helper: %w", err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(30 * time.Second))
	if err := json.NewEncoder(conn).Encode(request{Reference: reference}); err != nil {
		return "", fmt.Errorf("send secret request: %w", err)
	}
	var result response
	if err := json.NewDecoder(bufio.NewReader(conn)).Decode(&result); err != nil {
		return "", fmt.Errorf("read secret response: %w", err)
	}
	if result.Error != "" {
		if result.ExitCode != 0 {
			return "", &commandFailure{code: result.ExitCode, stderr: result.Stderr}
		}
		return "", errors.New(result.Error)
	}
	return result.Value, nil
}

func ensureServer(path string) error {
	if conn, err := net.DialTimeout("unix", path, 200*time.Millisecond); err == nil {
		_ = conn.Close()
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return fmt.Errorf("create helper directory: %w", err)
	}
	if err := os.Chmod(filepath.Dir(path), 0700); err != nil {
		return fmt.Errorf("secure helper directory: %w", err)
	}
	cmd := exec.Command(os.Args[0], "serve")
	cmd.Stdin = nil
	cmd.Stdout = nil
	cmd.Stderr = nil
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("start secrets helper: %w", err)
	}
	if err := cmd.Process.Release(); err != nil {
		return fmt.Errorf("release secrets helper process: %w", err)
	}
	for range 50 {
		if conn, err := net.DialTimeout("unix", path, 200*time.Millisecond); err == nil {
			_ = conn.Close()
			return nil
		}
		time.Sleep(100 * time.Millisecond)
	}
	return errors.New("secrets helper did not start")
}

func serve() error {
	path, err := socketPath()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return fmt.Errorf("create helper directory: %w", err)
	}
	if err := os.Chmod(filepath.Dir(path), 0700); err != nil {
		return fmt.Errorf("secure helper directory: %w", err)
	}
	if conn, err := net.DialTimeout("unix", path, 100*time.Millisecond); err == nil {
		_ = conn.Close()
		return errors.New("secrets helper is already running")
	}
	_ = os.Remove(path)
	listener, err := net.Listen("unix", path)
	if err != nil {
		return fmt.Errorf("listen on helper socket: %w", err)
	}
	defer func() {
		_ = listener.Close()
		_ = os.Remove(path)
	}()
	if err := os.Chmod(path, 0600); err != nil {
		return fmt.Errorf("secure helper socket: %w", err)
	}

	cache := secretCache{values: map[string]string{}, expires: map[string]time.Time{}}
	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-signals
		_ = listener.Close()
	}()

	for {
		conn, err := listener.Accept()
		if err != nil {
			if errors.Is(err, net.ErrClosed) {
				return nil
			}
			return fmt.Errorf("accept helper connection: %w", err)
		}
		go handleConnection(conn, &cache)
	}
}

func handleConnection(conn net.Conn, cache *secretCache) {
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(30 * time.Second))
	var req request
	result := response{}
	if err := json.NewDecoder(bufio.NewReader(conn)).Decode(&req); err != nil {
		result.Error = "invalid request"
	} else {
		result.Value, err = cache.get(req.Reference)
		if err != nil {
			result.Error = err.Error()
			var failure *commandFailure
			if errors.As(err, &failure) {
				result.ExitCode = failure.code
				result.Stderr = failure.stderr
			}
		}
	}
	_ = json.NewEncoder(conn).Encode(result)
}

func (cache *secretCache) get(reference string) (string, error) {
	if !strings.HasPrefix(reference, "op://") {
		return "", errors.New("reference must start with op://")
	}
	cache.mu.Lock()
	defer cache.mu.Unlock()
	if value, ok := cache.values[reference]; ok && time.Now().Before(cache.expires[reference]) {
		return value, nil
	}
	cmd := exec.Command("op", "read", reference)
	var stderr strings.Builder
	cmd.Stderr = &stderr
	output, err := cmd.Output()
	if err != nil {
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			return "", &commandFailure{code: exitErr.ExitCode(), stderr: []byte(stderr.String())}
		}
		return "", fmt.Errorf("op read failed: %w", err)
	}
	value := string(output)
	if strings.TrimSpace(value) == "" {
		return "", errors.New("op read returned an empty secret")
	}
	cache.values[reference] = value
	cache.expires[reference] = time.Now().Add(cacheTTL)
	return value, nil
}
