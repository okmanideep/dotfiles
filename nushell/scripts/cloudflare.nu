export def upload [pth: path] {
    let file_ext = ($pth | path parse | get extension | into string)

    let file_name = random uuid
    let aws_result = (aws s3api put-object --bucket static --key $"($file_name).($file_ext)" --body $pth --profile r2 --endpoint-url "https://d3d36e7acd613b05b0e319edc410b62d.r2.cloudflarestorage.com" | to json)
    let file_url = $"https://s.okmanideep.me/($file_name).($file_ext)"
    $file_url | copy
    echo $"URL copied to clipboard: ($file_url)"

    $file_url
}

export def "upload clip" [] {
    let bytes = _read-clipboard-image
    let file_ext = _read-clipboard-extension

    let opt_bytes = if file_ext == "png" and (which pngquant | is-empty) == false {
        $bytes | pngquant - | into binary
    } else {
        $bytes
    }

    let file_name = random uuid

    let tmp = (mktemp --suffix $".($file_ext)")
    $opt_bytes | save -f $tmp
    try {
        let aws_result = (aws s3api put-object --bucket static --key $"($file_name).($file_ext)" --body $tmp --profile r2 --endpoint-url "https://d3d36e7acd613b05b0e319edc410b62d.r2.cloudflarestorage.com" | to json)
        rm $tmp
    } catch {
        rm $tmp
    }
    let file_url = $"https://s.okmanideep.me/($file_name).($file_ext)"
    $file_url | copy
    echo $"URL copied to clipboard: ($file_url)"

    $file_url
}

# Handle xclip (Linux) and pbpaste (macOS). Returns image bytes.
def _read-clipboard-image [] {
  # --- Linux/X11 via xclip ---------------------------------------------------
  if (which xclip | is-empty) == false {
    # 1) Try raw image bytes first
    let mimes = ["image/png" "image/jpeg" "image/webp"]
    for m in $mimes {
      let bytes = (try { ^xclip -selection clipboard -t $m -o } catch { null })
      if $bytes != null and ($bytes | is-empty) == false {
        return ($bytes | into binary)
      }
    }

    error make -u {msg: "Clipboard has no image bytes or image file path (xclip)."}
  }

  # --- macOS via pbpaste -----------------------------------------------------
  if (which pbpaste | is-empty) == false {
    # 1) Try raw image bytes via UTIs
    let utis = ["public.png" "public.jpeg" "public.tiff" "public.webp"]
    for u in $utis {
      let bytes = (try { ^pbpaste -Prefer $u } catch { null })
      if $bytes != null and ($bytes | is-empty) == false {
        return ($bytes | into binary)
      }
    }

    error make -u {msg: "Clipboard has no image bytes or image file path (pbpaste)."}
  }

  error make -u {msg: "No supported clipboard tool found. Use xclip (Linux) or pbpaste (macOS), or pass --pth."}
}

def _read-clipboard-extension [] {
    # --- Linux/X11 via xclip ---------------------------------------------------
    if (which xclip | is-empty) == false {
        let mime = (try { ^xclip -selection clipboard -t image/png -o } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "png"
        }
        let mime = (try { ^xclip -selection clipboard -t image/jpeg -o } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "jpeg"
        }
        let mime = (try { ^xclip -selection clipboard -t image/webp -o } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "webp"
        }
        let mime = (try { ^xclip -selection clipboard -t image/tiff -o } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "tiff"
        }
    }

    # --- macOS via pbpaste -----------------------------------------------------
    if (which pbpaste | is-empty) == false {
        let mime = (try { ^pbpaste -Prefer public.png } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "png"
        }
        let mime = (try { ^pbpaste -Prefer public.jpeg } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "jpeg"
        }
        let mime = (try { ^pbpaste -Prefer public.webp } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "webp"
        }
        let mime = (try { ^pbpaste -Prefer public.tiff } catch { null })
        if $mime != null and ($mime | is-empty) == false {
        return "tiff"
        }
    }

    error make -u {msg: "No supported clipboard tool found. Use xclip (Linux) or pbpaste (macOS)."}
}
