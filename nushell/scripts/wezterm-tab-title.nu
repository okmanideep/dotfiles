export def tt [title: string = '', command?: closure] {
	wezterm cli set-tab-title $title
	# if there is a command passed, then the title should be temporary
	if $command != null {
		do $command
		wezterm cli set-tab-title '' # unset after the closure
	}
}
