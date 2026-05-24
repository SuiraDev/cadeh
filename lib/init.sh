# shellcheck shell=bash
# Inicialização do CADEH em um projeto de trabalho

_init_seed_state() {
  local target="$1"
  local state="${target}/.cadeh/state.yml"
  local project
  project="$(_init_project_name "$target")"
  local date
  date="$(date '+%Y-%m-%d %H:%M')"

  [[ -f "$state" ]] || return 0

  if grep -q '^updated_at: ""' "$state" 2>/dev/null; then
    sed -i "s/^updated_at:.*/updated_at: \"${date}\"/" "$state" 2>/dev/null || \
      sed -i '' "s/^updated_at:.*/updated_at: \"${date}\"/" "$state" 2>/dev/null || true
  fi

  if ! grep -q "init do CADEH" "$state" 2>/dev/null; then
    {
      echo ""
      echo "# init ${date} — projeto: ${project}"
    } >> "$state"
  fi
}

_init_project_name() {
  basename "$(cd "$1" && pwd)"
}

_init_print_next_steps() {
  local target="$1"
  local with_global="$2"
  local cg_ok="false"

  codegraph_project_ready "$target" && cg_ok="true"

  echo ""
  log "CADEH pronto em: ${target}"
  echo ""
  echo "Próximos passos:"
  echo "  1. Abra o projeto no Cursor e reinicie/recarregue (MCP CodeGraph)"
  if [[ "$cg_ok" == "true" ]]; then
    echo "  2. Memória de código: CodeGraph (.codegraph/) — use ferramentas MCP"
  else
    echo "  2. Instale CodeGraph: cadeh codegraph install"
  fi
  if [[ "$with_global" != "true" ]]; then
    echo "  3. (Opcional) Regra global: cadeh global"
    echo "  4. Nova feature: cadeh new feature <nome>"
    echo "  5. Chat: /cadeh-continue → /cadeh-spec (TLC) · fim: /cadeh-memory"
  else
    echo "  3. Nova feature: cadeh new feature <nome>  # cria branch feature/<slug>"
    echo "  4. Chat: /cadeh-continue → /cadeh-spec (TLC) · fim: /cadeh-memory"
  fi
  echo ""
  echo "TLC: docs/cadeh/tlc-integration.md · Estado: .cadeh/state.yml"
}

cmd_init() {
  local force="false"
  local with_global="false"
  local skip_global="false"
  local skip_codegraph="false"
  local skip_tlc="false"
  local agent=""
  local target="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force="true"; shift ;;
      --global) with_global="true"; shift ;;
      --no-global) skip_global="true"; shift ;;
      --skip-codegraph) skip_codegraph="true"; shift ;;
      --skip-tlc) skip_tlc="true"; export CADEH_SKIP_TLC=1; shift ;;
      --agent)
        [[ $# -ge 2 ]] || { err "--agent requer nome do agente"; exit 1; }
        agent="$2"
        if ! resolve_agent "$agent" >/dev/null; then exit 1; fi
        shift 2
        ;;
      -h|--help) help_command init; return ;;
      -*) err "Opção desconhecida: $1"; exit 1 ;;
      *) target="$1"; shift ;;
    esac
  done

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  # Prompt for agent selection if not specified and interactive
  if [[ -z "$agent" ]] && [[ -t 0 ]]; then
    agent="$(prompt_agent_selection)"
  elif [[ -z "$agent" ]]; then
    agent="cursor"
  fi

  if cadeh_project_installed "$target" && [[ "$force" != "true" ]]; then
    warn "CADEH já instalado em: $target"
    log "Use: cadeh update $target --agent $agent  ou  cadeh init $target -f --agent $agent"
    exit 1
  fi

  log "Inicializando CADEH em: ${target}"
  log "Agente: $(agent_label "$agent")"
  install_project "$target" "$force" "$CADEH_ROOT" "$agent"
  _init_seed_state "$target"

  if [[ "$skip_codegraph" != "true" ]]; then
    install_codegraph_project "$target" "false" "$agent" || warn "CodeGraph falhou — rode: cadeh codegraph install"
  fi

  if [[ "$skip_global" != "true" ]]; then
    local global_path
    global_path="$(agent_global_path "$agent")"
    if [[ "$with_global" == "true" ]] || [[ ! -f "$global_path" ]]; then
      install_global "$CADEH_ROOT" "$agent"
      with_global="true"
    else
      log "Regra global já existe em $global_path (use --global para sobrescrever)"
    fi
  fi

  echo ""
  doctor_check "$target" "$agent" || true
  _init_print_next_steps "$target" "$with_global"
}
