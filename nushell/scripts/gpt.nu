def gpt [query?: string] {
    let api_key = $env.OPEN_AI_API_KEY
    let model = "gpt-5-search-api"

    mut messages = [
        {
            role: "developer"
            content: '
You are a terminal helper. Look up online if necessary and respond with ONLY a single JSON object and nothing else:
{\"message\":\"<short guidance>\", \"script\":\"<Nushell script or empty string>\"}
- message: brief human-readable guidance in markdown (1–5 short lines)
- script: Nushell (or bash) script to run (may be multi-line); empty string if none'
        }
    ]

    let initial_q = if ($query == null) { input '> ' } else { $query }
    $messages = ($messages | append { role: "user", content: $initial_q })

    loop {
        let body = { model: $model, messages: $messages } | to json

        let raw_content = (
            http post https://api.openai.com/v1/chat/completions --headers [
                "Authorization" $"Bearer ($api_key)"
                "Content-Type" "application/json"
            ] $body
            | get choices.0.message.content
        )

        # Clean potential code fences
        let cleaned = ($raw_content
            | str trim
            | str replace -a '```json' ''
            | str replace -a '```nu' ''
            | str replace -a '```' ''
            | str trim)

        let parsed = (try { $cleaned | from json } catch { { message: $cleaned, script: "" } })

        if (($parsed.message | str length) > 0) {
            $parsed.message | glow -s dark
        }
        if (($parsed.script | str length) > 0) {
            let md = (["Proposed script:", "", "```nu", $parsed.script, "```"] | str join "\n")
            $md | glow -s dark
        }

        # Keep assistant turn as the exact JSON for better context
        $messages = ($messages | append { role: "assistant", content: $cleaned })

        # Single-keystroke menu via input listen
        let has_script = (($parsed.script | str length) > 0)
        if $has_script {
            print "\n[e]xecute (nu), [b]ash execute, [a]sk follow-up, [q]uit"
        } else {
            print "\n[a]sk follow-up, [q]uit"
        }
        mut choice = ""
        loop {
            let ev = (input listen --types [key])
            if ($ev.type == "key") and ($ev.key_type == "char") and (($ev.modifiers | length) == 0) {
                let code = ($ev.code | str downcase)
                if ((($has_script and ($code == "e")) or ($has_script and ($code == "b"))) or ($code == "a") or ($code == "q")) {
                    $choice = $code
                    break
                }
            }
        }

        if $choice == "e" {
            print "\nExecuting with nu..."
            ^nu -c $parsed.script
            break
        } else if $choice == "b" {
            print "\nExecuting with bash..."
            ^bash -lc $parsed.script
            break
        } else if $choice == "a" {
            let follow = (input "> ")
            $messages = ($messages | append { role: "user", content: $follow })
            continue
        } else if $choice == "q" {
            break
        }
    }
}
