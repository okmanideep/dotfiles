oh-my-posh init pwsh --config ~/Documents/code/personal/dotfiles/powershell/okmanideep.omp.json | Invoke-Expression

Import-Module git-aliases -DisableNameChecking
Import-Module posh-git

#Icons
Import-Module -Name Terminal-Icons

# PSReadline
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionSource History

# Fzf
Import-Module PSFzf
Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias Commands
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Utilities
function vnotes {
  cd ~/Dropbox/notes; vim .
}

function fmain {
  cd ~/Documents/code/hotstar/hotstar-android-mobile;
}

function firetv {
  cd ~/Documents/code/hotstar/hotstar-android-livingroom;
}

function frocky {
  cd ~/Documents/code/hotstar/android;
}

function which($command) {
  $obj = Get-Command -Name $command

  if ($obj.CommandType -eq "Application") {
    Write-Output $obj.Path
  } elseif ($obj.CommandType -eq "Function") {
    Write-Output $obj.definition
  }
}
