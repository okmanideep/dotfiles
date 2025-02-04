# a nushell command that is expected to be used
# after a pipe, like `expensive command | ding` and triggers a sound after
# the previous command is done
export def --env ding [] {
	if (sys host | get name) =~ "windows" {
		beep
	} else {
		run-external "tput" "bel"
	}
}
