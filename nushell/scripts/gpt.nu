def gpt [query?: string] {
    let api_key = $env.OPEN_AI_API_KEY
    let model = "gpt-5.6-luna"
    let os_name = match (sys host).name {
        "Darwin" => "macOS"
        $other => $other
    }

    let instructions = $"
You are a terminal helper running on ($os_name). Tailor your searches and responses for command line in ($os_name). Prefer Nushell, otherwise bash. Search the web when needed. Return short guidance and an optional runnable script."
    let response_format = {
        type: "json_schema"
        name: "terminal_helper"
        strict: true
        schema: {
            type: "object"
            properties: {
                message: { type: "string" }
                script: { type: "string" }
            }
            required: [message script]
            additionalProperties: false
        }
    }

    let initial_q = if ($query == null) { input '> ' } else { $query }
    mut current_input = $initial_q
    mut previous_response_id = ""

    loop {
        # The Responses API supersedes Chat Completions and provides the web search tool.
        let request = {
            model: $model
            instructions: $instructions
            input: $current_input
            tools: [{ type: "web_search" }]
            text: { format: $response_format }
        }
        let body = if ($previous_response_id | is-empty) {
            $request
        } else {
            $request | insert previous_response_id $previous_response_id
        } | to json

        let response = (http post https://api.openai.com/v1/responses --headers [
            "Authorization" $"Bearer ($api_key)"
            "Content-Type" "application/json"
        ] $body)
        $previous_response_id = $response.id
        let raw_content = ($response.output
            | where type == "message"
            | get content
            | flatten
            | where type == "output_text"
            | get text
            | str join "\n")

        # Clean potential code fences
        let cleaned = ($raw_content
            | str trim
            | str replace -a '```json' ''
            | str replace -a '```nu' ''
            | str replace -a '```' ''
            | str trim)

        let parsed = (try { $cleaned | from json } catch { { message: $cleaned, script: "" } })

        mut parts = []
        if ($parsed.message | is-not-empty) {
            $parts = ($parts | append $parsed.message)
        }
        if (($parsed.message | is-not-empty) and ($parsed.script | is-not-empty)) {
            $parts = ($parts | append ["", "---"])
        }
        if ($parsed.script | is-not-empty) {
            $parts = ($parts | append ["Proposed script:", "", "```nu", $parsed.script, "```"])
        }
        if ($parts | is-not-empty) {
            $parts | flatten | str join "\n" | glow -s dark
        }

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
                let code = ($ev.code | str lowercase)
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
            $current_input = (input "> ")
            continue
        } else if $choice == "q" {
            break
        }
    }
}
