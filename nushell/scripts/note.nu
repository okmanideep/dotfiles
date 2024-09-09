def os_home [] {
  if ($nu.os-info.name == windows ) {
    ($env.USERPROFILE)
  } else {
    ($env.HOME)
  }
}

def notes_dir [] {
	if ('NOTES_DIR' in $env) {
		$env.NOTES_DIR
	} else {
		(os_home) | path join 'Documents' 'notes'
	}
}

def notes [] {
	notes_dir | ls $in | get name | path basename
}

export def --env note [
	name: string@notes
] {
	let pth = notes_dir
	let file = $pth | path join $name

	cd $pth
	wezterm cli set-tab-title 'notes'
	nvim $name
}
