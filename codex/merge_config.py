#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["tomlkit>=0.13,<1"]
# ///
"""Merge shared dotfiles settings into the writable local Codex config."""

from __future__ import annotations

import ast
import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from tomlkit import dumps, parse
from tomlkit.exceptions import TOMLKitError
from tomlkit.items import Table


def load_local(local_path: Path) -> Table:
    if not local_path.exists():
        return parse("")
    text = local_path.read_text()
    try:
        return parse(text)
    except TOMLKitError:
        pass
    # The local config may have been corrupted by an earlier script revision
    # that wrote ``str(dict)`` instead of TOML. Try to recover the Python
    # literal so machine-specific settings are not lost.
    try:
        recovered = ast.literal_eval(text.strip())
    except (SyntaxError, ValueError):
        recovered = None
    if isinstance(recovered, dict):
        print("recovered local config from Python repr", file=sys.stderr)
        return parse(dumps(recovered))
    backup = local_path.with_name(f"{local_path.name}.corrupted.{int(time.time())}.bak")
    backup.write_text(text)
    print(f"unparsable local config backed up to {backup}; starting fresh", file=sys.stderr)
    return parse("")


def merge_tables(target: Table, source: Table) -> None:
    for key, value in source.items():
        current = target.get(key)
        if isinstance(value, dict) and isinstance(current, dict):
            merge_tables(current, value)
        else:
            target[key] = copy.deepcopy(value)


def validate_with_doctor(candidate_toml: str) -> None:
    """Gate the candidate config on `codex doctor` before touching the live file.

    Points Codex at an isolated CODEX_HOME containing only the candidate
    config.toml, then requires the `config.load` check to pass. Raises
    SystemExit without modifying anything on failure.
    """
    codex_bin = shutil.which("codex")
    if codex_bin is None:
        print("codex binary not found; skipping `codex doctor` validation", file=sys.stderr)
        return
    with tempfile.TemporaryDirectory(prefix="codex-config-validate-") as tmpdir:
        Path(tmpdir, "config.toml").write_text(candidate_toml)
        env = dict(os.environ)
        env["CODEX_HOME"] = tmpdir
        try:
            proc = subprocess.run(
                [codex_bin, "doctor", "--json"],
                capture_output=True,
                text=True,
                timeout=120,
                env=env,
            )
        except subprocess.TimeoutExpired:
            raise SystemExit("codex doctor timed out; not updating local config")
        try:
            report = json.loads(proc.stdout)
        except json.JSONDecodeError:
            raise SystemExit(
                "codex doctor returned non-JSON output; not updating local config\n"
                f"{proc.stderr.strip()}"
            )
        # NOTE: ignore overallStatus (auth and other host checks fail in odd
        # environments); only the config.load check judges the candidate file.
        config_check = (report.get("checks") or {}).get("config.load", {})
        if config_check.get("status") != "ok":
            summary = config_check.get("summary", "unknown error")
            raise SystemExit(f"codex doctor rejected candidate config ({summary}); not updating local config")
        print("codex doctor accepted candidate config", file=sys.stderr)


def main() -> None:
    skip_validation = "--skip-validation" in sys.argv[1:]
    positional = [arg for arg in sys.argv[1:] if not arg.startswith("--")]
    if len(positional) != 2:
        raise SystemExit("usage: merge_config.py SHARED_CONFIG LOCAL_CONFIG [--skip-validation]")

    shared_path = Path(positional[0])
    local_path = Path(positional[1])
    shared = parse(shared_path.read_text())
    local = load_local(local_path)
    merge_tables(local, shared)

    # NOTE: do not use str(local) here. Since tomlkit 0.15,
    # str(TOMLDocument) returns a Python dict repr, not TOML
    # (that is what corrupted this file before). dumps() is stable.
    candidate_toml = dumps(local)
    # Internal round-trip check: never write what we cannot parse back.
    parse(candidate_toml)
    # Fast no-op path: `make install` runs often, and `codex doctor`
    # takes seconds. If the merge produces byte-identical output, skip
    # validation and the write entirely (also preserves the file mtime).
    if local_path.exists() and local_path.read_text() == candidate_toml:
        print("codex config already up to date; nothing to do", file=sys.stderr)
        return
    if not skip_validation:
        validate_with_doctor(candidate_toml)

    local_path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{local_path.name}.", dir=local_path.parent
    )
    try:
        with os.fdopen(descriptor, "w") as temporary_file:
            temporary_file.write(candidate_toml)
        os.chmod(temporary_name, 0o600)
        os.replace(temporary_name, local_path)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)


if __name__ == "__main__":
    main()
