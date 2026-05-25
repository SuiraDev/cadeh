# shellcheck shell=bash
# Estado do fluxo (.cadeh/state.yml) e cadeh continue

_cadeh_state_get() {
  local state="$1"
  local key="$2"
  [[ -f "$state" ]] || return 1
  grep -E "^${key}:" "$state" 2>/dev/null | head -1 | sed -E 's/[[:space:]]#.*$//; s/^[^:]*:[[:space:]]*"?//; s/"?[[:space:]]*$//; s/^"|"$//g'
}

_cadeh_cmd_prefix() {
  local agent="${1:-cursor}"
  if [[ "$agent" == "pi" ]]; then
    echo "cadeh"
  else
    echo "/cadeh"
  fi
}

_cadeh_continue_entry() {
  local agent="${1:-cursor}"
  local p
  p="$(_cadeh_cmd_prefix "$agent")"
  if [[ "$agent" == "pi" ]]; then
    echo "prompt ${p}-continue"
  else
    echo "${p}-continue"
  fi
}

_cadeh_suggest_slash() {
  local phase="${1:-}"
  local agent="${2:-cursor}"
  local p
  p="$(_cadeh_cmd_prefix "$agent")"
  case "$phase" in
    ""|brief) echo "${p}-spec" ;;
    sdd) echo "${p}-spec (ou ${p}-plan se SDD aprovado)" ;;
    plan) echo "${p}-plan (ou ${p}-tasks se plano aprovado)" ;;
    tasks) echo "${p}-implement" ;;
    implement) echo "${p}-implement" ;;
    validate) echo "docs/cadeh/validation-checklist.md" ;;
    *) echo "${p}-continue" ;;
  esac
}

_cadeh_state_set_field() {
  local state="$1"
  local key="$2"
  local value="$3"

  [[ -f "$state" ]] || return 0
  if grep -qE "^${key}:" "$state" 2>/dev/null; then
    # Delimitador | — valores podem conter / (ex.: feature/slug)
    sed -i "s|^${key}:.*|${key}: \"${value}\"|" "$state" 2>/dev/null || \
      sed -i '' "s|^${key}:.*|${key}: \"${value}\"|" "$state" 2>/dev/null || true
  fi
}

_new_feature_memory() {
  local target="$1"
  local slug="$2"
  local template="${CADEH_ROOT}/spec/memory.md"
  local dest="${target}/docs/memory/${slug}.md"

  mkdir -p "${target}/docs/memory"
  [[ -f "$template" ]] || return 0
  if [[ -f "$dest" ]]; then
    warn "Memória já existe: $dest"
    return 0
  fi
  sed "s/<feature>/${slug}/g" "$template" > "$dest"
  ok "Memória: $dest"
}

cmd_continue() {
  local target="${1:-.}"
  local agent
  target="$(cd "$target" 2>/dev/null && pwd)" || { err "Diretório inválido: $1"; exit 1; }

  if ! cadeh_project_installed "$target"; then
    err "CADEH não instalado — cadeh init $target"
    exit 1
  fi

  agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"

  local state="${target}/.cadeh/state.yml"
  local feature phase task branch notes updated
  feature="$(_cadeh_state_get "$state" feature)"
  phase="$(_cadeh_state_get "$state" phase)"
  task="$(_cadeh_state_get "$state" task)"
  branch="$(_cadeh_state_get "$state" branch)"
  notes="$(_cadeh_state_get "$state" notes)"
  updated="$(_cadeh_state_get "$state" updated_at)"

  echo "CADEH — continuar trabalho"
  echo "Projeto: $target"
  echo ""

  if [[ -z "$feature" ]]; then
    warn "Nenhuma feature ativa em .cadeh/state.yml"
    echo ""
    echo "  cadeh new feature <nome>"
    echo "  $(agent_label "$agent"): $(agent_spec_entry_hint "$agent")"
    exit 0
  fi

  log "Feature:  ${feature}"
  log "Fase:     ${phase:-(não definida)}"
  [[ -n "$task" ]] && log "Tarefa:   ${task}"
  [[ -n "$branch" ]] && log "Branch:   ${branch}"
  [[ -n "$updated" ]] && log "Atualizado: ${updated}"
  [[ -n "$notes" ]] && log "Notas:    ${notes}"
  echo ""

  local doc
  for doc in "docs/sdd/${feature}.md" "docs/plans/${feature}.md" "docs/tasks/${feature}.md" "docs/memory/${feature}.md"; do
    if [[ -f "${target}/${doc}" ]]; then
      ok "$doc"
    else
      warn "Ausente: $doc"
    fi
  done

  if codegraph_project_ready "$target"; then
    ok "CodeGraph: .codegraph/ ($(agent_label "$agent") — MCP)"
  else
    warn "CodeGraph ausente — cadeh codegraph install --agent ${agent}"
  fi

  echo ""
  log "No $(agent_label "$agent") (novo chat): $(_cadeh_continue_entry "$agent")"
  log "Comando sugerido: $(_cadeh_suggest_slash "$phase" "$agent")"
  echo ""
}
