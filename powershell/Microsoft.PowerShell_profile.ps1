oh-my-posh init pwsh --config ~/Documents/code/personal/dotfiles/powershell/okmanideep.omp.json | Invoke-Expression

Import-Module git-aliases -DisableNameChecking

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
function which($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function vnotes {
  cd ~/Dropbox/notes; vim .
}

# Start Notes Preview Server
Start-Job -Name NotesPreview -ScriptBlock {
  cd ~/Documents/code/personal/notes-preview
  npm start
}
