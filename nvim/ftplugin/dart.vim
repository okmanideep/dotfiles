setlocal shiftwidth=2
setlocal tabstop=2
setlocal expandtab

if exists("b:undo_ftplugin")
  let b:undo_ftplugin .= "| setlocal shiftwidth<"
else
  let b:undo_ftplugin = "setlocal shiftwidth<"
endif

let b:undo_ftplugin .= "| setlocal tabstop<"
let b:undo_ftplugin .= "| setlocal expandtab<"
