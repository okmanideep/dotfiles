if (which asdf | length) > 0 {
    source $"($nu.home-dir)/.asdf/completions/nushell.nu"
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($nu.home-dir)/.asdf/shims")
}
