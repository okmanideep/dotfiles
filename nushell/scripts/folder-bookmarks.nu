# simple bookmark module

# Prints general information about bm.
export def main [] {
  print -n (help bm)

  print (
  [
    $"(ansi green)Environment(ansi reset):"
    $"    (ansi cyan)BM_PATH(ansi reset) - path to save bookmarks to with ('fadd' | nu-highlight). Alternatively searches for  (ansi cyan)XDG_DATA_HOME(ansi reset) or (ansi cyan)~/.local/share/(ansi reset)"
  ] |
  str join "\n" |
  nu-highlight
  )
}

# List all bookmarked paths
export def flist [] {
  let bm_path = (get_path)

  if (not ($bm_path | path exists))  {
    [] | save $bm_path
  }
    open ($bm_path)
}

def os_home [] {
  if ($nu.os-info.name == "windows" ) {
    ($env.USERPROFILE)
  } else {
    ($env.HOME)
  }
}

def get_path [] {
  $env.BM_PATH? |
  default (
    $env.XDG_DATA_HOME? |
    default (
      if $nu.os-info.name == windows {
        ($env.USERPROFILE? | path join "bm")
      } else {
        ($env.HOME? | path join ".local" "share")
      }
    )
  ) |
  if (not ($in | path exists)) {
    mkdir $in
    $in
  } else {
    $in
  }|
  path join "bookmarks.nuon"
}

def save_path [] {
  $in |
  update path { str replace (os_home) '~' } |
  save -f (get_path)
}

# Reset the bookmarks
export def freset [] {
  flist |
  where name == "prev" |
  save -f (get_path)
}

# Add a new bookmark with an optional name
export def fadd [
  pth: path       # Path to bookmark to.
  name?: string   # Optional name to give to it
                    ] {
  if (($pth | path type) == "dir") and ($pth | path exists) {
    flist | 
    append {name: ($name), path: ($pth)} |
    save_path
  }
}

# remove one or more bookmarks
export def fremove [] {
  let rm_these = (
    flist | 
    where name != "prev" |
    input list -m
  )

  flist | where {|it|
    not $it in $rm_these
  } |
  print
  
}

def marks [] {
  flist | each {|it| 
    {
    value: $it.name,
    description: $it.path
    }
  }
}

# Goto your bookmark
export def-env fgo [
  name: string@marks # Name of Path to "go to"
  ] {
  let prev = $env.PWD
  let pth = (flist | where name == $name | get path).0
  cd $pth
  change_prev $prev
}

def change_prev [new_path: path] {
    ( flist | 
      where name != "prev" 
    ) |
    append {name: prev, path: $new_path} |
    save_path
}
