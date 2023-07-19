$user_profile_path = Join-Path -Path $PSScriptRoot -ChildPath 'user_profile.ps1'
. $user_profile_path

Invoke-Expression (&starship init powershell)

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
Set-Alias flutter ".fvm/flutter_sdk/bin/flutter"

# Shell Integration between Powershell + Starship with Terminal Emulator to communicate cwd
# https://wezfurlong.org/wezterm/shell-integration.html#osc-7-on-windows-with-powershell-with-starship
$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

# Move to user_profile in Windows
# Set-Alias ll ls
# Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Utilities
function vn {
	$notes_dir = $env:NOTES_DIR
	if (!$notes_dir) {
		$notes_dir = "~/Dropbox/notes" # to not break windows PC after pull
	}
	Set-Location $notes_dir; nvim (Get-ChildItem | Sort-Object LastWriteTime -Descending | Select-Object Name -ExpandProperty Name | fzf --reverse --print-query | select-object -Last 1)
}

function vbuser {
  vim "$PSScriptRoot/user_profile.ps1"
}

function rmd($path) {
  Remove-Item -Path $path -Force -Recurse
}

# wezterm tab title
function tt($title) {
  $t = ''
  if ($title) {
	$t = $title
  }
  wezterm cli set-tab-title $t
}

function lg {
  tt("LazyGit")
  lazygit
}
