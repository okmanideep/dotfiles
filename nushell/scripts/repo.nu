def repo_list [] {
    cd
    cd Documents
    cd code

    ls | where type == dir | get name | each { |f| ls $f | where type == dir | get name } | flatten
}

export def --env repo [pth: string@repo_list] {
    cd (
        if ($nu.os-info.name == windows ) {
            ($env.USERPROFILE)
        } else {
            ($env.HOME)
        } | path join Documents code $pth
    )
}
