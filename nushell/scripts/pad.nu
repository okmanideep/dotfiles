def os_home [] {
    if ($nu.os-info.name == windows ) {
        ($env.USERPROFILE)
    } else {
        ($env.HOME)
    }
}

def pads_dir [] {
    if ('PADS_DIR' in $env) {
        $env.PADS_DIR
    } else {
        (os_home) | path join 'Documents' 'pads'
    }
}

def pads [] {
    pads_dir | ls $in | get name | path basename
}

export def --env pad [
    name: string@pads
] {
    let cur_pwd = $env.PWD
    let pth = pads_dir
    let file = $pth | path join $name

    cd $pth
    wezterm cli set-tab-title ' scratchpad'
    nvim $name
    wezterm cli set-tab-title ''
    cd $cur_pwd
}
