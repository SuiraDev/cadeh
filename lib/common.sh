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

# Diretório relativo da skill TLC no projeto (sem SKILL.md)
tlc_skill_dest_dir() {
  case "$1" in
    cursor) echo ".cursor/skills/tlc-spec-driven" ;;
    claude) echo ".claude/skills/tlc-spec-driven" ;;
    codex) echo ".codex/skills/tlc-spec-driven" ;;
    antigravity) echo ".agent/skills/tlc-spec-driven" ;;
    pi) echo ".pi/skills/tlc-spec-driven" ;;
    *) echo ".cursor/skills/tlc-spec-driven" ;;
  esac
}

# Caminho relativo do SKILL.md por agente
tlc_skill_rel_path() {
  case "$1" in
    cursor) echo ".cursor/skills/tlc-spec-driven/SKILL.md" ;;
    claude) echo ".claude/skills/tlc-spec-driven/SKILL.md" ;;
    codex) echo ".codex/skills/tlc-spec-driven/SKILL.md" ;;
    antigravity) echo ".agent/skills/tlc-spec-driven/SKILL.md" ;;
    pi) echo ".pi/skills/tlc-spec-driven/SKILL.md" ;;
    *) echo ".cursor/skills/tlc-spec-driven/SKILL.md" ;;
  esac
}

tlc_skill_installed() {
  local target="$1"
  local agent="${2:-cursor}"
  local rel
  rel="$(tlc_skill_rel_path "$agent")"
  [[ -f "${target}/${rel}" ]]
}

# Dica: abrir IDE / recarregar MCP após init
agent_open_project_hint() {
  case "$1" in
    cursor) echo "Abra o projeto no Cursor e reinicie/recarregue a janela (MCP CodeGraph)" ;;
    claude) echo "Abra o projeto no Claude Code; recarregue se alterou MCP (.claude/mcp.json)" ;;
    codex) echo "Abra o projeto no Codex; MCP em .codex/config.toml" ;;
    antigravity) echo "Abra o projeto no Antigravity/VS Code; MCP em .cursor/mcp.json" ;;
    pi) echo "Abra o projeto no Pi Agent; MCP em .mcp.json (pi-mcp-adapter)" ;;
    *) echo "Abra o projeto no seu agente de IA" ;;
  esac
}

# Dica: memória de código via MCP
agent_codegraph_usage_hint() {
  case "$1" in
    cursor) echo "Memória de código: CodeGraph (.codegraph/) — ferramentas MCP no Cursor" ;;
    claude) echo "Memória de código: CodeGraph (.codegraph/) — ferramentas MCP no Claude Code" ;;
    codex) echo "Memória de código: CodeGraph (.codegraph/) — ferramentas MCP no Codex" ;;
    antigravity) echo "Memória de código: CodeGraph (.codegraph/) — ferramentas MCP" ;;
    pi) echo "Memória de código: CodeGraph (.codegraph/) — ferramentas MCP no Pi Agent" ;;
    *) echo "Memória de código: CodeGraph (.codegraph/) — use ferramentas MCP" ;;
  esac
}

# Dica: entrar no fluxo CADEH no chat do agente
agent_chat_flow_hint() {
  case "$1" in
    pi) echo "Chat: prompt cadeh-continue → cadeh-spec (TLC) · fim: cadeh-memory (.pi/prompts/)" ;;
    claude|cursor|codex|antigravity)
      echo "Chat: /cadeh-continue → /cadeh-spec (TLC) · fim: /cadeh-memory" ;;
    *)
      echo "Chat: /cadeh-continue → /cadeh-spec (TLC) · fim: /cadeh-memory" ;;
  esac
}

# Comando inicial quando não há feature ativa
agent_spec_entry_hint() {
  case "$1" in
    pi) echo "Pi: prompt cadeh-spec (.pi/prompts/)" ;;
    *) echo "/cadeh-spec" ;;
  esac
}

# Pergunta s/n (default: n). Retorna 0 = sim.
prompt_yes_no() {
  local prompt="${1:-Continuar?}"
  local default_no="${2:-true}"
  local answer

  if [[ ! -t 0 ]]; then
    return 1
  fi

  if [[ "$default_no" == "true" ]]; then
    read -r -p "  ${prompt} [s/N]: " answer
    [[ "${answer,,}" == "s" || "${answer,,}" == "sim" || "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
  else
    read -r -p "  ${prompt} [S/n]: " answer
    [[ -z "$answer" || "${answer,,}" == "s" || "${answer,,}" == "sim" || "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
  fi
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
