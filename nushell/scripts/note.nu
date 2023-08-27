def os_home [] {
  if ($nu.os-info.name == windows ) {
    ($env.USERPROFILE)
  } else {
    ($env.HOME)
  }
}

def notes_dir [] {
	(os_home) | path join 'Dropbox' 'notes'
}

def notes [] {
	notes_dir | ls $in | get name | path basename
}

export def-env note [
	name: string@notes
] {
	let pth = notes_dir
	let file = $pth | path join $name

	cd $pth
	nvim $name
}
