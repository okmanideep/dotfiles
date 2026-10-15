export def --env hdr [...args] {
    wezterm cli set-tab-title 'herdr'
    ^herdr ...$args
    wezterm cli set-tab-title ''
}
