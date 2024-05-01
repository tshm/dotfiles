# The prompt to send to the API
LLM_MODEL=${LLM_MODEL:-"llama3-70b-8192"}
LLM_CONTEXT_SIZE=${LLM_CONTEXT_SIZE:-50}
LLM_API_URL=${LLM_API_URL:-"https://api.groq.com/openai/v1/chat/completions"}

LLM_SYSTEM_PROMPT=$(cat <<-EOS
Act as very good zsh/bash shell auto completion engine.
Your job is to come up with suggestions by guessing most probable next characters that follows based on given command execution history.
- I use zsh/bash in linux.
- the history buffer includes prompt such as '>' and may be accompanied with folder path or hostname.
- You'll be provided with buffer of the terminal console, so that inputs and outputs of the previous commands can be used to come up with suggestions.
- from the command execution history given in the buffer, deduce what user is trying to do next.
- 'last line' may include what user already typed, if it ends with whitespace then try to suggest words come after, e.g. additional command line options or file names.  if 'last line' does not end with whitespace, then treat it as only partial word and your suggestion should try to complete the unfinished word and any arguments that may follow.
- respond only the completions.  No explanation nor reasoning are needed.
- console buffer may include my intention as a comment prefixed by ##.
EOS
)

# The function that will generate suggestions
_complete_with_llm() {
  [ -z "$LLM_API_KEY" ] && echo 'Please set $LLM_API_KEY' && return
  # Get the current buffer and cursor position
  local buffer="${BUFFER}"
  local cursor=$CURSOR

  # Trim the buffer to the current cursor position
  local prefix=${buffer:0:$cursor}
  local console=$(tmux capture-pane -pS - | sed '/^$/d' | sed '$d' | tail -${LLM_CONTEXT_SIZE})

  # get tmux buffer (excluding the last line)
  LLM_PROMPT=$(cat <<-EOF
  buffer of the terminal console:
  \`\`\`
  $console
  \`\`\`

  last line: ${prefix}
EOF
  )
  local userprompt=$(jq -Rs . <<<"$LLM_PROMPT")
  echo $userprompt > /tmp/in.json
  # return;

  # Construct the API request
  local headers=(-H "Authorization: Bearer $LLM_API_KEY" -H "Content-Type: application/json")
  # local data='{"messages": "'"${LLMPROMPT}${prefix}"'"}'
  local data='{"messages": [{"role": "system", "content": "'"$LLM_SYSTEM_PROMPT"'"}, {"role": "user", "content": '${userprompt}'}], "model": "'"$LLM_MODEL"'"}'

  # Make the API request
  local response=$(curl -s -X POST $LLM_API_URL "${headers[@]}" -d "$data")

  [ -n "$LLM_DEBUG" ] && echo $data && return
  echo $response > /tmp/out.json

  # Extract the suggestions from the json response
  local choice=$(echo $response | jq -r '.choices[0].message.content')
  local suggestions=(${(f)${choice##*: }})
  suggestions=(${suggestions#*, })

  if [ ${#suggestions} -gt 0 ]
  then
    BUFFER="${buffer}${suggestions[1]}"
    CURSOR=${#BUFFER}
  fi
}

zle -N _complete_with_llm
bindkey '^g' _complete_with_llm
