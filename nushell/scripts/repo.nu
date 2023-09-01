def repo_list [] {
	cd
	cd Documents
	cd code

	ls personal | append (ls praja) | get name
}

export def-env repo [pth: string@repo_list] {
	cd (if ($nu.os-info.name == windows ) {
		($env.USERPROFILE)
	} else {
		($env.HOME)
	} | path join Documents code $pth)
}
