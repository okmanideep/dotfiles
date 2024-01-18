setlocal expandtab
setlocal shiftwidth=2
setlocal tabstop=2

if (exists("b:undo_ftplugin"))
    let b:undo_ftplugin .= "| setlocal expandtab<"
else
    let b:undo_ftplugin = "setlocal expandtab<"
endif

let b:undo_ftplugin .= "| setlocal shiftwidth<"
let b:undo_ftplugin .= "| setlocal tabstop<"
