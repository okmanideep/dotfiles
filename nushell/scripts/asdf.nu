if (which asdf | length) > 0 {
    source $"($nu.home-path)/.asdf/completions/nushell.nu"
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.asdf/shims")
}
