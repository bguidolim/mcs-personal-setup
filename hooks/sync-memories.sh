#!/bin/bash

set -euo pipefail
trap 'exit 0' ERR

# Check if jq is available
command -v jq >/dev/null 2>&1 || exit 0

# Read and validate JSON input
input_data=$(cat) || exit 0
echo "$input_data" | jq '.' >/dev/null 2>&1 || exit 0

context=""

# === OLLAMA STATUS ===
ollama_running=false
if curl -s --max-time 2 http://localhost:11434/api/tags >/dev/null 2>&1; then
    ollama_running=true
fi

# If project has a memories directory, ensure docs-mcp-server library is synced
if [ -d ".claude/memories" ]; then
    if [ "$ollama_running" = true ]; then
        repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "")
        if [ -n "$repo_name" ]; then
            memories_path="$(git rev-parse --show-toplevel 2>/dev/null)/.claude/memories"

            # Background: ensure library exists and is up to date.
            # Redirect subshell stdout/stderr to /dev/null so the hook's
            # output pipe closes immediately (Claude Code waits for the
            # pipe to close, not just the parent process).
            # A watchdog kills the subshell after 120s to prevent hangs.
            (
                trap 'kill 0 2>/dev/null' TERM
                export OPENAI_API_KEY=ollama
                export OPENAI_API_BASE=http://localhost:11434/v1

                embedding_model="openai:nomic-embed-text"

                if npx -y @arabold/docs-mcp-server list --silent 2>/dev/null | grep -q "$repo_name"; then
                    npx -y @arabold/docs-mcp-server refresh "$repo_name" \
                        --embedding-model "$embedding_model" \
                        --silent >/dev/null 2>&1
                else
                    npx -y @arabold/docs-mcp-server scrape "$repo_name" \
                        "file://$memories_path" \
                        --embedding-model "$embedding_model" \
                        --silent >/dev/null 2>&1
                fi
            ) >/dev/null 2>&1 &
            sync_pid=$!
            ( sleep 120 && kill "$sync_pid" 2>/dev/null ) >/dev/null 2>&1 &
        fi
    else
        context+="⚠️ Ollama not running — docs-mcp semantic search will fail"
    fi
fi

# Output only if we have something to report
if [ -n "$context" ]; then
    jq -n --arg ctx "$context" '{
        hookSpecificOutput: {
            hookEventName: "SessionStart",
            additionalContext: $ctx
        }
    }'
fi
