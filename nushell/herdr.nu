# HERDR auto-start
if ($env | get -o HERDR_ENV | is-empty) and ($env | get -o TMUX | is-empty) and ($env | get -o ZELLIJ | is-empty) {
    if (which herdr | is-not-empty) {
        exec herdr
    }
}
