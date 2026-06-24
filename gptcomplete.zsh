#!/bin/zsh

_gptcomplete_log() {
  emulate -L zsh
  local log_file="$1"
  shift

  [[ -z "$log_file" ]] && return 0

  local timestamp
  timestamp=${(%):-%D{%Y-%m-%dT%H:%M:%S}}
  print -r -- "[$timestamp] $*" >> "$log_file" 2>/dev/null
}

_gptcomplete_fast_model_for_api_url() {
  emulate -L zsh
  setopt local_options no_aliases

  local api_url="${(L)1}"
  case "$api_url" in
    (*://bifrost.hq.empathy.co.jp/*|bifrost.hq.empathy.co.jp/*) print -r -- "codex/gpt-5.4-mini" ;;
    (*://api.openai.com/*|api.openai.com/*) print -r -- "gpt-5-nano" ;;
    (*://api.groq.com/*|api.groq.com/*) print -r -- "openai/gpt-oss-20b" ;;
  esac
}

_complete_with_llm() {
  emulate -L zsh
  setopt local_options no_aliases

  local log_file="${GPTCOMPLETE_LOG_FILE:-${LLM_LOG_FILE-}}"
  case "$log_file" in
    (1|true|yes|on) log_file="${TMPDIR:-/tmp}/gptcomplete.log" ;;
  esac
  if [[ -n "$log_file" ]] && ! : >> "$log_file" 2>/dev/null; then
    zle -M "Cannot write GPTCOMPLETE_LOG_FILE: $log_file"
    log_file=""
  fi

  local log_prompts="${GPTCOMPLETE_LOG_PROMPTS:-${LLM_LOG_PROMPTS:-0}}"

  local api_url="${GPTCOMPLETE_API_URL:-${LLM_API_URL:-https://api.groq.com/openai/v1/chat/completions}}"
  local model=""
  if [[ -n ${GPTCOMPLETE_MODEL-} ]]; then
    model="$GPTCOMPLETE_MODEL"
  elif [[ -z ${GPTCOMPLETE_API_URL-} ]]; then
    model="${LLM_MODEL:-}"
  fi
  local context_size="${GPTCOMPLETE_CONTEXT_SIZE:-${LLM_CONTEXT_SIZE:-50}}"
  local api_format="${GPTCOMPLETE_API_FORMAT:-${LLM_API_FORMAT:-auto}}"
  local api_key="${GPTCOMPLETE_API_KEY:-${LLM_API_KEY-}}"
  local connect_timeout="${GPTCOMPLETE_CONNECT_TIMEOUT:-${LLM_CONNECT_TIMEOUT:-5}}"
  local request_timeout="${GPTCOMPLETE_TIMEOUT:-${LLM_TIMEOUT:-20}}"
  local codex_compat="${GPTCOMPLETE_CODEX_COMPAT:-${LLM_CODEX_COMPAT:-auto}}"
  local api_url_log="${api_url%%\?*}"
  [[ "$api_url" == *\?* ]] && api_url_log="${api_url_log}?<redacted>"
  _gptcomplete_log "$log_file" "start pid=$$ model=$model api_url=$api_url_log api_format=$api_format context_size=$context_size connect_timeout=$connect_timeout request_timeout=$request_timeout codex_compat=$codex_compat tmux=${TMUX:+1}"

  if [[ -z "$api_key" ]]; then
    _gptcomplete_log "$log_file" "missing_api_key"
    zle -M "Please set GPTCOMPLETE_API_KEY"
    return 1
  fi

  local command_name
  for command_name in curl jq; do
    if (( ! $+commands[$command_name] )); then
      _gptcomplete_log "$log_file" "missing_command command=$command_name"
      zle -M "Missing required command: $command_name"
      return 1
    fi
  done

  case "$context_size" in
    (''|*[!0-9]*) context_size=50 ;;
  esac
  (( context_size < 1 )) && context_size=1

  case "$api_format" in
    (responses|response) api_format=responses ;;
    (chat|chat-completions|chat_completions) api_format=chat ;;
    (*) api_format=auto ;;
  esac

  api_url="${api_url%/}"
  case "$api_url" in
    (*/responses) api_format=responses ;;
    (*/chat/completions) api_format=chat ;;
    (*/v1)
      [[ "$api_format" == responses ]] && api_url="$api_url/responses" || api_url="$api_url/chat/completions"
      ;;
    (*/openai)
      [[ "$api_format" == responses ]] && api_url="$api_url/v1/responses" || api_url="$api_url/v1/chat/completions"
      ;;
    (*)
      [[ "$api_format" == responses ]] && api_url="$api_url/responses" || api_url="$api_url/chat/completions"
      ;;
  esac
  [[ "$api_format" == auto ]] && api_format=chat

  api_url_log="${api_url%%\?*}"
  [[ "$api_url" == *\?* ]] && api_url_log="${api_url_log}?<redacted>"

  if [[ -z "$model" ]]; then
    model="$(_gptcomplete_fast_model_for_api_url "$api_url")"
    [[ -z "$model" ]] && model="llama3-70b-8192"
  elif [[ "${(L)model}" == auto || "${(L)model}" == fastest ]]; then
    model="$(_gptcomplete_fast_model_for_api_url "$api_url")"
    if [[ -z "$model" ]]; then
      _gptcomplete_log "$log_file" "fast_model_unavailable api_url=$api_url_log"
      zle -M "No fastest model is configured for this provider; set GPTCOMPLETE_MODEL"
      return 1
    fi
  fi

  if [[ "$codex_compat" == auto ]]; then
    [[ "$model" == codex/* ]] && codex_compat=1 || codex_compat=0
  fi

  _gptcomplete_log "$log_file" "config model=$model api_url=$api_url_log api_format=$api_format context_size=$context_size codex_compat=$codex_compat"
  local buffer="$BUFFER"
  local cursor="$CURSOR"
  local prefix="${buffer[1,$cursor]}"
  local suffix="${buffer[$(( cursor + 1 )),-1]}"

  local console=""
  local tmux_context_status="not-in-tmux"
  local pane_line_count=0
  local filtered_line_count=0
  local context_line_count=0
  if (( $+commands[tmux] )) && [[ -n ${TMUX-} ]]; then
    local pane
    tmux_context_status="capture-failed"
    if pane="$(tmux capture-pane -pS -)"; then
      local -a lines filtered
      local line

      lines=("${(@f)pane}")
      pane_line_count=${#lines}
      for line in "${lines[@]}"; do
        [[ -n ${line//[[:space:]]/} ]] && filtered+=("$line")
      done

      (( ${#filtered} > 0 )) && filtered[-1]=()
      filtered_line_count=${#filtered}
      tmux_context_status="captured"
      if (( ${#filtered} > 0 )); then
        local start=$(( ${#filtered} - context_size + 1 ))
        (( start < 1 )) && start=1
        context_line_count=$(( ${#filtered} - start + 1 ))
        console="${(F)filtered[$start,-1]}"
      fi
    fi
  fi

  _gptcomplete_log "$log_file" "context status=$tmux_context_status pane_lines=$pane_line_count filtered_lines=$filtered_line_count context_lines=$context_line_count prefix_chars=${#prefix} suffix_chars=${#suffix}"
  if [[ "$log_prompts" == 1 || "$log_prompts" == true || "$log_prompts" == yes || "$log_prompts" == on ]]; then
    _gptcomplete_log "$log_file" "console<<'GPTCOMPLETE_CONSOLE'
$console
GPTCOMPLETE_CONSOLE"
    _gptcomplete_log "$log_file" "prefix<<'GPTCOMPLETE_PREFIX'
$prefix
GPTCOMPLETE_PREFIX"
    _gptcomplete_log "$log_file" "suffix<<'GPTCOMPLETE_SUFFIX'
$suffix
GPTCOMPLETE_SUFFIX"
  fi

  local system_prompt='You are a zsh/bash shell completion engine.

Return exactly one completion string: the text that should be inserted at the cursor.
Do not return explanations, markdown, code fences, labels, quotes, or alternatives.
Do not repeat text that already appears before the cursor.
Do not modify text after the cursor; only complete what belongs at the cursor.
Preserve necessary leading or trailing spaces in the insertion.
If no useful completion is likely, return an empty string.

Use the terminal buffer as context for likely next commands, options, paths, and arguments.
The buffer may include prompts, hostnames, directories, command output, and comments prefixed with ## that describe user intent.

Completion rules:
- If text before the cursor ends with whitespace, suggest the next word or argument.
- If text before the cursor ends inside a word, complete that unfinished word and any obvious following argument.
- Prefer shell-valid zsh/bash syntax.
- Prefer paths, command names, flags, and arguments that are consistent with the visible context.'

  local user_prompt="terminal buffer:
'''
$console
'''

current ZLE buffer before cursor:
'''
$prefix
'''

current ZLE buffer after cursor:
'''
$suffix
'''"

  local data
  if [[ "$api_format" == responses ]]; then
    local request_id
    request_id="gptcomplete-${$}-${RANDOM}-${RANDOM}"

    if ! data="$(
      jq -n \
        --arg system "$system_prompt" \
        --arg user "$user_prompt" \
        --arg model "$model" \
        --arg request_id "$request_id" \
        --arg codex_compat "$codex_compat" \
        '{
          model: $model,
          instructions: $system,
          input: [
            {
              type: "message",
              role: "user",
              content: [{type: "input_text", text: $user}]
            }
          ],
          tools: [],
          tool_choice: "auto",
          parallel_tool_calls: true,
          reasoning: {effort: "low"},
          store: false,
          stream: true,
          include: ["reasoning.encrypted_content"],
          text: {verbosity: "low"}
        } + if $codex_compat == "1" then {
          client_metadata: {
            session_id: $request_id,
            thread_id: $request_id,
            turn_id: $request_id,
            "x-codex-window-id": ($request_id + ":0")
          }
        } else {} end' 2>/dev/null
    )"; then
      _gptcomplete_log "$log_file" "request_build_failed format=responses"
      zle -M "Failed to build LLM request"
      return 1
    fi
  else
    if ! data="$(
      jq -n \
        --arg system "$system_prompt" \
        --arg user "$user_prompt" \
        --arg model "$model" \
        '{
          messages: [
            {role: "system", content: $system},
            {role: "user", content: $user}
          ],
          model: $model,
          temperature: 0,
          max_tokens: 64,
          n: 1
        }' 2>/dev/null
    )"; then
      _gptcomplete_log "$log_file" "request_build_failed format=chat"
      zle -M "Failed to build LLM request"
      return 1
    fi
  fi

  local -a headers=(
    -H "Authorization: Bearer $api_key"
    -H "Content-Type: application/json"
  )

  if [[ "$api_format" == responses ]]; then
    headers+=(-H "Accept: text/event-stream")
    if [[ "$codex_compat" == 1 ]]; then
      headers+=(
        -H "x-codex-beta-features: terminal_resize_reflow,remote_compaction_v2"
        -H "x-codex-window-id: ${request_id}:0"
        -H "x-client-request-id: $request_id"
        -H "session-id: $request_id"
        -H "thread-id: $request_id"
      )
    fi
  fi

  _gptcomplete_log "$log_file" "request_send format=$api_format url=$api_url_log request_chars=${#data}"
  local response curl_status http_status error_message
  response="$(
    curl -s --fail-with-body \
      --connect-timeout "$connect_timeout" \
      --max-time "$request_timeout" \
      -w $'\n%{http_code}' \
      -X POST "$api_url" \
      "${headers[@]}" \
      --data-binary "$data"
  )"
  curl_status=$?
  http_status="${response##*$'\n'}"
  response="${response%$'\n'*}"
  _gptcomplete_log "$log_file" "response_received curl_status=$curl_status http_status=$http_status response_chars=${#response}"

  if (( curl_status != 0 )); then
    if [[ -n "$response" ]]; then
      error_message="$(jq -r '.error.message // .error.error // .message // .error // empty' <<< "$response" 2>/dev/null)"
      [[ -z "$error_message" ]] && error_message="${response[1,180]}"
    fi
    _gptcomplete_log "$log_file" "request_failed curl_status=$curl_status http_status=${http_status:-none} error=${error_message:-connection error}"
    zle -M "LLM request failed (${http_status:-curl $curl_status}): ${error_message:-connection error}"
    return 1
  fi

  if [[ -n ${GPTCOMPLETE_DEBUG:-${LLM_DEBUG-}} ]]; then
    local debug_dir="${TMPDIR:-/tmp}"
    print -r -- "$data" > "$debug_dir/gptcomplete.in.json"
    print -r -- "$response" > "$debug_dir/gptcomplete.out.json"
    zle -M "Wrote debug JSON to $debug_dir/gptcomplete.*.json"
    _gptcomplete_log "$log_file" "debug_json_written dir=$debug_dir"
  fi

  local choice
  if [[ "$api_format" == responses ]]; then
    if ! choice="$(jq -Rsr '
      split("\n")
      | map(
          select(startswith("data: "))
          | .[6:]
          | select(. != "[DONE]")
          | fromjson?
        )
      | [
          .[]
          | if .type == "response.output_text.delta" then
              .delta
            elif .type == "response.completed" then
              (.response.output_text // ([.response.output[]?.content[]? | select(.type == "output_text") | .text] | join("")) // empty)
            else
              empty
            end
        ]
      | join("")
    ' <<< "$response" 2>/dev/null)"; then
      _gptcomplete_log "$log_file" "response_parse_failed format=responses response_chars=${#response}"
      zle -M "Failed to parse LLM response"
      return 1
    fi

    if [[ -z "$choice" ]]; then
      if ! choice="$(jq -r '.output_text // ([.output[]?.content[]? | select(.type == "output_text") | .text] | join("")) // empty' <<< "$response" 2>/dev/null)"; then
        choice=""
      fi
    fi
  else
    if ! choice="$(jq -r '.choices[0].message.content // empty' <<< "$response" 2>/dev/null)"; then
      _gptcomplete_log "$log_file" "response_parse_failed format=chat response_chars=${#response}"
      zle -M "Failed to parse LLM response"
      return 1
    fi
  fi

  choice="${choice//$'\r'/$'\n'}"

  local suggestion=""
  local -a choices
  choices=("${(@f)choice}")
  local candidate
  for candidate in "${choices[@]}"; do
    [[ -z ${candidate//[[:space:]]/} || "$candidate" == '```'* ]] && continue
    [[ "$candidate" == '- '* || "$candidate" == '* '* ]] && candidate="${candidate[3,-1]}"
    suggestion="$candidate"
    break
  done

  if [[ -z "$suggestion" ]]; then
    _gptcomplete_log "$log_file" "no_suggestion choice_chars=${#choice}"
    return 0
  fi

  if (( cursor > 0 )) && [[ "${suggestion[1,$cursor]}" == "$prefix" ]]; then
    suggestion="${suggestion[$(( cursor + 1 )),-1]}"
  fi

  if [[ -z "$suggestion" ]]; then
    _gptcomplete_log "$log_file" "no_suggestion_after_prefix_strip choice_chars=${#choice}"
    return 0
  fi

  BUFFER="${prefix}${suggestion}${suffix}"
  CURSOR=$(( cursor + ${#suggestion} ))
  _gptcomplete_log "$log_file" "inserted suggestion_chars=${#suggestion} cursor_before=$cursor cursor_after=$CURSOR suggestion=${(qqq)suggestion}"
}

zle -N _complete_with_llm
bindkey '^g' _complete_with_llm
