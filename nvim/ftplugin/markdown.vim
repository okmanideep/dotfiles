highlight htmlItalic cterm=italic gui=italic

" Hide and format markdown elements like **bold**
" See: `syn-conceal`
setlocal conceallevel=2

" Remove color column
setlocal colorcolumn=0

" Remove line number
setlocal nonu
setlocal nornu

" Turn on spell check
setlocal spell

" Turn off showing traling space etc
setlocal nolist

" Turn on wrap
setlocal wrap
nmap <buffer> j gj
nmap <buffer> k gk

if exists("b:undo_ftplugin")
    let b:undo_ftplugin .= "| setlocal conceallevel<"
else
    let b:undo_ftplugin = "setlocal conceallevel<"
endif

let b:undo_ftplugin .= "| setlocal colorcolumn<"
let b:undo_ftplugin .= "| setlocal nonu<"
let b:undo_ftplugin .= "| setlocal nornu<"
let b:undo_ftplugin .= "| setlocal spell<"
let b:undo_ftplugin .= "| setlocal nolist<"
let b:undo_ftplugin .= "| setlocal wrap<"
let b:undo_ftplugin .= "| nunmap <buffer> j"
let b:undo_ftplugin .= "| nunmap <buffer> k"
