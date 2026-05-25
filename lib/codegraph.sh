# shellcheck shell=bash
# Integração CodeGraph — memória estrutural do código (local, MCP)

CODEGRAPH_NPM_PKG="${CODEGRAPH_NPM_PKG:-@colbymchenry/codegraph}"

_codegraph_cmd() {
  if command -v codegraph >/dev/null 2>&1; then
    echo "codegraph"
  elif command -v npx >/dev/null 2>&1; then
    echo "npx --yes ${CODEGRAPH_NPM_PKG}"
  else
    return 1
  fi
}

require_codegraph_runner() {
  if ! _codegraph_cmd >/dev/null; then
    err "CodeGraph requer Node.js (npx) ou 'codegraph' no PATH"
    err "Instale: npm i -g ${CODEGRAPH_NPM_PKG}"
    err "Docs: https://github.com/colbymchenry/codegraph"
    return 1
  fi
}

_run_codegraph() {
  local runner
  runner="$(_codegraph_cmd)" || return 1
  # shellcheck disable=SC2086
  $runner "$@"
}

codegraph_project_ready() {
  [[ -d "${1}/.codegraph" ]]
}

# Configura CodeGraph MCP para um agente específico
_setup_codegraph_mcp() {
  local target="$1"
  local agent="$2"

  case "$agent" in
    cursor|antigravity)
      log "CodeGraph: configurando MCP para $(agent_label "$agent")..."
      if (cd "$target" && _run_codegraph install --target=cursor --location=local --yes 2>/dev/null); then
        ok "CodeGraph: MCP configurado"
      else
        warn "CodeGraph MCP: codegraph install falhou — configure manualmente"
        return 1
      fi
      ;;
    claude)
      log "CodeGraph: configurando MCP para Claude Code..."
      local mcp_config="${target}/.claude/mcp.json"
      mkdir -p "$(dirname "$mcp_config")"
      if [[ ! -f "$mcp_config" ]]; then
        cat > "$mcp_config" <<'MCPEOF'
{
  "mcpServers": {
    "codegraph": {
      "command": "npx",
      "args": ["-y", "@colbymchenry/codegraph", "serve"],
      "cwd": "PROJECT_DIR"
    }
  }
}
MCPEOF
        # Substitui PROJECT_DIR pelo path real do projeto
        sed -i "s|PROJECT_DIR|${target}|g" "$mcp_config" 2>/dev/null || \
          sed -i '' "s|PROJECT_DIR|${target}|g" "$mcp_config" 2>/dev/null || true
        ok "CodeGraph: .claude/mcp.json criado"
      else
        log "CodeGraph: .claude/mcp.json já existe — mantido"
      fi
      ;;
    codex)
      log "CodeGraph: configurando MCP para Codex..."
      local cfg="${target}/.codex/config.toml"
      mkdir -p "$(dirname "$cfg")"
      if [[ ! -f "$cfg" ]] || ! grep -q "codegraph" "$cfg" 2>/dev/null; then
        cat >> "$cfg" <<'MCPEOF'

[mcp_servers.codegraph]
command = "npx"
args = ["-y", "@colbymchenry/codegraph", "serve"]
MCPEOF
        ok "CodeGraph: .codex/config.toml atualizado"
      else
        log "CodeGraph: codegraph já configurado no config.toml"
      fi
      ;;
    pi)
      log "CodeGraph: configurando MCP para Pi Agent (via pi-mcp-adapter)..."
      local mcp_config="${target}/.mcp.json"
      if [[ -f "$mcp_config" ]]; then
        if grep -q "codegraph" "$mcp_config" 2>/dev/null; then
          log "CodeGraph: já configurado no .mcp.json"
        else
          warn "CodeGraph: .mcp.json existe sem codegraph — adicione manualmente ou rode: /mcp setup no Pi"
        fi
      else
        cat > "$mcp_config" <<MCPEOF
{
  "mcpServers": {
    "codegraph": {
      "command": "npx",
      "args": ["-y", "@colbymchenry/codegraph", "serve"],
      "cwd": "${target}"
    }
  }
}
MCPEOF
        ok "CodeGraph: .mcp.json criado (pi-mcp-adapter detectará automaticamente)"
      fi
      ;;
  esac
  return 0
}

install_codegraph_project() {
  local target="$1"
  local skip_index="${2:-false}"
  local agent="${3:-cursor}"

  if [[ "${CADEH_SKIP_CODEGRAPH:-}" == "1" ]]; then
    warn "CodeGraph ignorado (CADEH_SKIP_CODEGRAPH=1)"
    return 0
  fi

  require_codegraph_runner || return 1

  # MCP setup per agent
  _setup_codegraph_mcp "$target" "$agent"

  # Index (agent-agnostic — .codegraph/ files)
  log "CodeGraph: inicializando em ${target}..."
  if [[ "$skip_index" == "true" ]]; then
    _run_codegraph init "$target" || return 1
  else
    _run_codegraph init "$target" -i || return 1
  fi
  ok "CodeGraph: .codegraph/ pronto"

  # CodeGraph rule (only for Cursor — other agents get instructions via AGENTS.md)
  if [[ "$agent" == "cursor" ]] && [[ -f "${CADEH_ROOT}/templates/agents/cursor/rules/cadeh-codegraph.mdc" ]]; then
    mkdir -p "${target}/.cursor/rules"
    cp -f "${CADEH_ROOT}/templates/agents/cursor/rules/cadeh-codegraph.mdc" \
      "${target}/.cursor/rules/cadeh-codegraph.mdc"
    log "Rule: .cursor/rules/cadeh-codegraph.mdc"
  fi

  _cleanup_cursor_for_non_cursor_agent "$target" "$agent"

  return 0
}

# Reconfigura só o MCP (sem reindexar) — usado pelo switch
reinstall_codegraph_mcp() {
  local target="$1"
  local agent="$2"

  if [[ "${CADEH_SKIP_CODEGRAPH:-}" == "1" ]]; then
    return 0
  fi

  if ! codegraph_project_ready "$target"; then
    warn "CodeGraph: .codegraph/ não existe — rode: cadeh codegraph install"
    return 0
  fi

  require_codegraph_runner 2>/dev/null || { warn "CodeGraph: npx ausente — MCP não configurado"; return 0; }
  _setup_codegraph_mcp "$target" "$agent"
}

codegraph_doctor_check() {
  local target="$1"
  local agent="${2:-cursor}"
  if [[ "${CADEH_SKIP_CODEGRAPH:-}" == "1" ]]; then
    warn "CodeGraph: ignorado (CADEH_SKIP_CODEGRAPH)"
    return 0
  fi
  if codegraph_project_ready "$target"; then
    ok "CodeGraph index (.codegraph/)"
    # Check MCP config for this agent
    case "$agent" in
      cursor|antigravity)
        [[ -f "${target}/.cursor/mcp.json" ]] && ok "CodeGraph MCP (.cursor/mcp.json)" || warn "CodeGraph MCP ausente — cadeh codegraph install" ;;
      claude)
        [[ -f "${target}/.claude/mcp.json" ]] && ok "CodeGraph MCP (.claude/mcp.json)" || warn "CodeGraph MCP ausente — cadeh codegraph install" ;;
      codex)
        grep -q "codegraph" "${target}/.codex/config.toml" 2>/dev/null && ok "CodeGraph MCP (.codex/config.toml)" || warn "CodeGraph MCP ausente — cadeh codegraph install" ;;
      pi)
        if [[ -f "${target}/.mcp.json" ]] && grep -q "codegraph" "${target}/.mcp.json" 2>/dev/null; then
          ok "CodeGraph MCP (.mcp.json)"
        else
          warn "CodeGraph MCP ausente (.mcp.json) — cadeh codegraph install"
        fi ;;
    esac
    if command -v codegraph >/dev/null 2>&1 || command -v npx >/dev/null 2>&1; then
      _run_codegraph status "$target" 2>/dev/null | head -5 || true
    fi
    return 0
  fi
  warn "CodeGraph não inicializado — rode: cadeh codegraph install"
  return 1
}

uninstall_codegraph_project() {
  local target="$1"
  local remove_mcp="${2:-true}"

  if [[ "${CADEH_SKIP_CODEGRAPH:-}" == "1" ]]; then
    return 0
  fi

  if ! codegraph_project_ready "$target" && [[ "$remove_mcp" != "true" ]]; then
    return 0
  fi

  log "CodeGraph: removendo do projeto..."

  if codegraph_project_ready "$target"; then
    if require_codegraph_runner 2>/dev/null; then
      _run_codegraph uninit "$target" --force 2>/dev/null || \
        warn "codegraph uninit falhou — apague manualmente: ${target}/.codegraph/"
    else
      warn "codegraph não no PATH — remova manualmente: ${target}/.codegraph/"
    fi
    if [[ -d "${target}/.codegraph" ]]; then
      rm -rf "${target}/.codegraph"
      log "Removido: .codegraph/"
    fi
  fi

  if [[ "$remove_mcp" == "true" ]] && require_codegraph_runner 2>/dev/null; then
    if (cd "$target" && _run_codegraph uninstall --target=cursor --location=local --yes 2>/dev/null); then
      ok "CodeGraph: MCP Cursor (local) removido"
    else
      warn "codegraph uninstall falhou — verifique .cursor/ manualmente"
    fi
  fi

  # Regra que o CodeGraph pode ter criado além da nossa cópia
  rm -f "${target}/.cursor/rules/codegraph.mdc" 2>/dev/null || true

  return 0
}

cmd_codegraph() {
  local sub="${1:-}"
  shift || true
  local target="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -h|--help) help_command codegraph; return ;;
      -*)
        err "Opção desconhecida: $1"
        exit 1
        ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  target="$(cd "$target" && pwd)"

  local agent
  agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"

  case "$sub" in
    install|init)
      install_codegraph_project "$target" "false" "$agent" || exit 1
      ;;
    index)
      require_codegraph_runner || exit 1
      _run_codegraph index "$target" -f || exit 1
      ;;
    status|st)
      require_codegraph_runner || exit 1
      _run_codegraph status "$target"
      ;;
    sync)
      require_codegraph_runner || exit 1
      _run_codegraph sync "$target"
      ;;
    -h|--help|help|"")
      help_command codegraph
      ;;
    *)
      err "Subcomando: cadeh codegraph install|index|status|sync"
      exit 1
      ;;
  esac
}
