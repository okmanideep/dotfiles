export def copy [
    --allow-errors (-e)
] {
    if (which xclip | is-empty) == false {
        $in | xclip -selection clipboard
    } else if (which pbcopy | is-empty) == false {
        $in | pbcopy
    } else {
        let msg = "Clipboard program not found"
        if $allow_errors {
            error make -u {msg: $msg}
        } else {
            echo $msg
        }
    }
}

export def pasta [
    --allow-errors (-e)
] {
    if (which xclip | is-empty) == false {
        xclip -selection clipboard -o
    } else if (which pbpaste | is-empty) == false {
        pbpaste
    } else {
        let msg = "Clipboard program not found"
        if $allow_errors {
            error make -u {msg: $msg}
        } else {
            echo $msg
        }
    }
}
