$user_profile_path = Join-Path -Path $PSScriptRoot -ChildPath 'user_profile.ps1'
. $user_profile_path

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
Set-Alias ll Get-ChildItem

# Move to user_profile in Windows
# Set-Alias ll ls
# Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Utilities
function vn {
  Set-Location ~/Dropbox/notes; nvim (Get-ChildItem | Sort-Object LastWriteTime -Descending | Select-Object Name -ExpandProperty Name | fzf --reverse --print-query | select-object -Last 1)
}

function vbuser {
  vim "$PSScriptRoot/user_profile.ps1"
}

function rmd($path) {
  Remove-Item -Path $path -Force -Recurse
}

function which($command) {
  $obj = Get-Command -Name $command

  if ($obj.CommandType -eq "Application") {
    Write-Output $obj.Path
  } elseif ($obj.CommandType -eq "Function") {
    Write-Output $obj.definition
  }
}
