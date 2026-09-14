def workspace_list [] {
    let workspace_dir = [$env.HOME Documents workspace] | path join

    ls $workspace_dir | where type == dir | get name | path basename
}

export def --env ws [pth: string@workspace_list] {
    let workspace_path = [$env.HOME Documents workspace $pth] | path join

    mkdir $workspace_path
    cd $workspace_path
}
