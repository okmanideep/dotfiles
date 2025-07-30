if (which asdf | length) > 0 {
    let shims_dir = $env.HOME | path join ".asdf" | path join "shims"
    $env.PATH = ($env.PATH | split row (char esep) | where {|p| $p != $shims_dir } | prepend $shims_dir)

    let asdf_completions_file = $env.HOME | path join ".asdf" | path join "completions" | path join "nushell.nu"
    if ($asdf_completions_file | path exists) {
        source $"($nu.home-path)/.asdf/completions/nushell.nu"
    } else {
        mkdir $"($env.HOME)/.asdf/completions"
        asdf completions nushell | save $asdf_completions_file
        source $"($nu.home-path)/.asdf/completions/nushell.nu"
    }
}
