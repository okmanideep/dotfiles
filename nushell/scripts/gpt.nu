def gpt [query: string] {
  let api_key = $env.OPEN_AI_API_KEY
  let model = "gpt-4o-mini"
  let body = { "model": $model, "messages": [
  { "role": "developer", "content": "You are helpful assistant. Be as brief as possible. Simple text output suitable for a terminal" },
  { "role": "user", "content": $query },
  ] } | to json
  http post https://api.openai.com/v1/chat/completions --headers [
    "Authorization" $"Bearer ($api_key)"
    "Content-Type" "application/json"
  ] $body | get choices.0.message.content
}
