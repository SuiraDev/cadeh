# shellcheck shell=bash
# Biblioteca compartilhada do CLI CADEH

cadeh_resolve_root() {
  local script="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  local bin_dir
  bin_dir="$(cd "$(dirname "$script")" && pwd)"
  # bin/cadeh -> repo root; lib/*.sh -> repo root
  if [[ "$(basename "$bin_dir")" == "bin" ]]; then
    cd "$(dirname "$bin_dir")" && pwd
  elif [[ "$(basename "$bin_dir")" == "lib" ]]; then
    cd "$(dirname "$bin_dir")" && pwd
  else
    echo "$bin_dir"
  fi
}

CADEH_VERSION="1.7.0"

log() { printf '\033[36m→\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
err() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[32m✓\033[0m %s\n' "$*"; }

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g'
}

require_dir() {
  if [[ ! -d "$1" ]]; then
    err "Diretório não existe: $1"
    exit 1
  fi
}

require_cadeh_project() {
  local target="$1"
  if [[ ! -f "${target}/docs/sdd/_template.md" ]] || [[ ! -f "${target}/.cadeh/state.yml" ]]; then
    err "CADEH não instalado em: $target"
    err "Rode: cadeh init ${target}"
    exit 1
  fi
}

cadeh_project_installed() {
  [[ -f "${1}/docs/sdd/_template.md" && -f "${1}/.cadeh/state.yml" ]]
}

# ============================================================
# Agent adapters — paths e configurações por agente
# ============================================================

# Lista de agentes suportados
CADEH_AGENTS=("cursor" "claude" "codex" "antigravity" "pi")

# Resolve o agente (valida ou retorna default)
resolve_agent() {
  local agent="${1:-}"
  if [[ -z "$agent" ]]; then
    echo ""
    return 0
  fi
  for a in "${CADEH_AGENTS[@]}"; do
    if [[ "$a" == "$agent" ]]; then
      echo "$agent"
      return 0
    fi
  done
  err "Agente desconhecido: $agent"
  err "Agentes suportados: ${CADEH_AGENTS[*]}"
  return 1
}

# Retorna os paths de projeto para um agente (rules_dir commands_dir rules_format)
agent_project_paths() {
  local agent="$1"
  case "$agent" in
    cursor)
      echo ".cursor/rules|.cursor/commands|.mdc" ;;
    claude)
      echo ".claude/rules|.claude/commands|.md" ;;
    codex)
      echo ".codex/rules||.rules" ;;
    antigravity)
      echo ".github||.md" ;;
    pi)
      echo ".pi/prompts||.md" ;;
    *)
      echo "||" ;;
  esac
}

# Retorna o path global de regras para um agente
agent_global_path() {
  local agent="$1"
  case "$agent" in
    cursor)
      echo "${HOME}/.cursor/rules/cadeh.mdc" ;;
    claude)
      echo "${HOME}/.claude/CLAUDE.md" ;;
    codex)
      echo "${HOME}/.codex/AGENTS.md" ;;
    antigravity)
      echo "${HOME}/AGENTS.md" ;;
    pi)
      echo "${HOME}/.pi/agent/AGENTS.md" ;;
    *)
      echo "" ;;
  esac
}

# Retorna o nome amigável do agente
agent_label() {
  local agent="$1"
  case "$agent" in
    cursor) echo "Cursor IDE" ;;
    claude) echo "Claude Code" ;;
    codex) echo "OpenAI Codex" ;;
    antigravity) echo "Antigravity" ;;
    pi) echo "Pi Agent" ;;
    *) echo "$agent" ;;
  esac
}

# Retorna se o agente suporta global install
agent_has_global() {
  local agent="$1"
  case "$agent" in
    cursor|claude|codex|antigravity|pi) return 0 ;;
    *) return 1 ;;
  esac
}

# Retorna se o agente suporta commands (slash commands ou prompt templates)
agent_has_commands() {
  local agent="$1"
  case "$agent" in
    cursor|claude|pi) return 0 ;;
    *) return 1 ;;
  esac
}

# Prompt interativo para selecionar agente
prompt_agent_selection() {
  echo ""
  log "Selecione o agente de IA que você usa:"
  echo ""
  echo "  1) Cursor IDE        (.cursor/rules/ + commands)"
  echo "  2) Claude Code       (CLAUDE.md + .claude/commands/)"
  echo "  3) OpenAI Codex      (AGENTS.md + .codex/rules/)"
  echo "  4) Antigravity       (AGENTS.md + copilot-instructions)"
  echo "  5) Pi Agent          (AGENTS.md + .pi/prompts/)"
  echo ""
  
  local choice
  if [[ -t 0 ]]; then
    read -r -p "  Escolha (1-5): " choice
  fi
  
  case "${choice:-}" in
    1) echo "cursor" ;;
    2) echo "claude" ;;
    3) echo "codex" ;;
    4) echo "antigravity" ;;
    5) echo "pi" ;;
    *)
      warn "Escolha inválida — usando Cursor (default)"
      echo "cursor"
      ;;
  esac
}
