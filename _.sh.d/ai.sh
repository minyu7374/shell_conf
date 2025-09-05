#!/bin/bash

llm-env-setup() {
    # 参数为0, 维持懒加载逻辑；参数为1, 强制更新
    [[ -n "$_LLM_ENV_SETUP" && "$1" = 0 ]] && return

    GEMINI_API_KEY="$(pass gemini/token)"

    MINYUCHAT_API_HOST="chat.wminyu.top:433"
    DEEPSEEK_WEB_API_KEY="$(pass deepseek/web-token)"
    DEEPSEEK_API_BASE="https://$MINYUCHAT_API_HOST/v1"
    DEEPSEEK_API_KEY="$DEEPSEEK_WEB_API_KEY"

    CHATANYWHERE_API_HOST="api.chatanywhere.tech"
    CHATANYWHERE_API_KEY="$(pass chatanywhere/token)"
    OPENAI_API_BASE="https://$CHATANYWHERE_API_HOST"
    OPENAI_API_KEY="$CHATANYWHERE_API_KEY"

    export GEMINI_API_KEY
    export DEEPSEEK_API_BASE DEEPSEEK_API_KEY
    export OPENAI_API_BASE OPENAI_API_KEY

    # 标记环境变量已设置，并清除alias
    if [[ -z "$_LLM_ENV_SETUP" ]]; then
        export _LLM_ENV_SETUP=1
        unalias aider gemini 2>/dev/null
    fi
}

# 懒加载AI配置环境变量
alias aider='llm-env-setup 0; aider'
alias gemini='llm-env-setup 0; gemini'

AIDER_AUTO_COMMITS=False
AIDER_MODEL=gemini/gemini-2.5-flash

export AIDER_AUTO_COMMITS AIDER_MODEL
