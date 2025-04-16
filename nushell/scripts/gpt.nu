def gpt [query?: string] {
    let q = if ($query == null) {
        input '> '
    } else {
        $query
    }

    let api_key = $env.OPEN_AI_API_KEY
    let model = "gpt-4.1-mini"
    let body = { "model": $model, "messages": [
        { "role": "developer", "content": "You are helpful assistant. The user is trying to get something done in his terminal. Be as brief as possible. Provide markdown output with fenced code blocks for syntax highlighting." },
        { "role": "user", "content": $q },
    ] } | to json
    http post https://api.openai.com/v1/chat/completions --headers [
        "Authorization" $"Bearer ($api_key)"
        "Content-Type" "application/json"
    ] $body | get choices.0.message.content | glow -s dark
}
