# shellcheck shell=bash
# Comandos auxiliares: status, list, path

cmd_status() {
  local target="${1:-.}"
  local agent="${2:-}"
  target="$(cd "$target" 2>/dev/null && pwd)" || { err "Diretório inválido: $1"; exit 1; }

  # Detect agent
  if [[ -z "$agent" ]]; then
    agent="$(_detect_project_agent "$target")" 2>/dev/null || true
    [[ -z "$agent" ]] && agent="cursor"
  fi

  echo "CADEH v${CADEH_VERSION}"
  echo ""

  # CLI
  if command -v cadeh >/dev/null 2>&1; then
    ok "CLI: $(command -v cadeh)"
  else
    warn "CLI não está no PATH — rode: cadeh setup"
  fi
  log "Repo: ${CADEH_ROOT}"
  echo ""

  # Global
  echo "Global ($(agent_label "$agent"))"
  local global_path
  global_path="$(agent_global_path "$agent")"
  if [[ -n "$global_path" ]] && [[ -f "$global_path" ]]; then
    ok "$global_path"
  else
    warn "Regra global ausente — cadeh global --agent $agent"
  fi
  echo ""

  # Projeto
  echo "Projeto: $target"
  if cadeh_project_installed "$target"; then
    ok "CADEH instalado (agente: $(agent_label "$agent"))"
    local sdd_count plan_count tasks_count
    sdd_count="$(list_cadeh_docs "$target" sdd | wc -l | tr -d ' ')"
    plan_count="$(list_cadeh_docs "$target" plan | wc -l | tr -d ' ')"
    tasks_count="$(list_cadeh_docs "$target" tasks | wc -l | tr -d ' ')"
    log "SDDs: ${sdd_count} · Planos: ${plan_count} · Tasks: ${tasks_count}"
    if codegraph_project_ready "$target"; then
      ok "CodeGraph: .codegraph/"
    else
      warn "CodeGraph ausente — cadeh codegraph install"
    fi
    if [[ -f "${target}/.cadeh/state.yml" ]]; then
      log "Estado: .cadeh/state.yml"
    fi
    if command -v git >/dev/null 2>&1 && git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
      local branch
      branch="$(git -C "$target" branch --show-current 2>/dev/null || echo "?")"
      log "Git: branch ${branch}"
    fi
  else
    warn "CADEH não instalado — cadeh init"
  fi
}

_cadeh_docs_dir() {
  case "$1" in
    sdd) echo "sdd" ;;
    plan) echo "plans" ;;
    tasks) echo "tasks" ;;
    *) echo "$1" ;;
  esac
}

list_cadeh_docs() {
  local target="$1"
  local kind="$2"   # sdd | plan | tasks
  local subdir
  subdir="$(_cadeh_docs_dir "$kind")"
  local dir="${target}/docs/${subdir}"

  [[ -d "$dir" ]] || return 0

  find "$dir" -maxdepth 1 -name '*.md' ! -name '_template.md' ! -name 'README.md' -printf '%f\n' 2>/dev/null \
    | sed 's/\.md$//' \
    | sort
}

cmd_list() {
  local target="${1:-.}"
  target="$(cd "$target" 2>/dev/null && pwd)" || { err "Diretório inválido: $1"; exit 1; }

  if ! cadeh_project_installed "$target"; then
    err "CADEH não instalado em: $target"
    exit 1
  fi

  echo "Projeto: $target"
  echo ""

  echo "SDDs (docs/sdd/):"
  local sdds
  sdds="$(list_cadeh_docs "$target" sdd)"
  if [[ -n "$sdds" ]]; then
    while IFS= read -r name; do
      echo "  · $name  →  docs/sdd/${name}.md"
    done <<< "$sdds"
  else
    echo "  (nenhum — cadeh new sdd <nome>)"
  fi

  echo ""
  echo "Planos (docs/plans/):"
  local plans
  plans="$(list_cadeh_docs "$target" plan)"
  if [[ -n "$plans" ]]; then
    while IFS= read -r name; do
      echo "  · $name  →  docs/plans/${name}.md"
    done <<< "$plans"
  else
    echo "  (nenhum — cadeh new plan <nome>)"
  fi

  echo ""
  echo "Tasks (docs/tasks/):"
  local tasks
  tasks="$(list_cadeh_docs "$target" tasks)"
  if [[ -n "$tasks" ]]; then
    while IFS= read -r name; do
      echo "  · $name  →  docs/tasks/${name}.md"
    done <<< "$tasks"
  else
    echo "  (nenhum — cadeh new tasks <nome>)"
  fi

}

_clean_agent_files() {
  local target="$1"
  local agent="$2"

  case "$agent" in
    cursor)
      if [[ -d "${target}/.cursor" ]]; then
        rm -rf "${target}/.cursor"
        log "Limpo: .cursor/ (completo)"
      fi
      ;;
    claude)
      rm -f "${target}/CLAUDE.md"
      if [[ -d "${target}/.claude" ]]; then
        rm -rf "${target}/.claude"
        log "Limpo: CLAUDE.md e .claude/"
      else
        log "Limpo: CLAUDE.md"
      fi
      ;;
    codex)
      if [[ -d "${target}/.codex" ]]; then
        rm -rf "${target}/.codex"
        log "Limpo: .codex/ (completo)"
      fi
      ;;
    antigravity)
      if [[ -d "${target}/.github" ]]; then
        rm -rf "${target}/.github"
        log "Limpo: .github/ (completo)"
      fi
      ;;
    pi)
      if [[ -d "${target}/.pi" ]]; then
        rm -rf "${target}/.pi"
        log "Limpo: .pi/ (completo)"
      fi
      ;;
  esac
}

cmd_switch() {
  local target="."
  local new_agent=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        [[ $# -ge 2 ]] || { err "--agent requer nome do agente"; exit 1; }
        new_agent="$2"
        if ! resolve_agent "$new_agent" >/dev/null; then exit 1; fi
        shift 2
        ;;
      -h|--help) help_command switch; return ;;
      *) target="$1"; shift ;;
    esac
  done

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  if ! cadeh_project_installed "$target"; then
    err "CADEH não instalado em: $target"
    err "Rode: cadeh init $target"
    exit 1
  fi

  local current_agent
  current_agent="$(_detect_project_agent "$target")"

  # Prompt if no agent specified
  if [[ -z "$new_agent" ]]; then
    echo ""
    log "Agente atual: $(agent_label "$current_agent")"
    echo ""
    log "Selecione o novo agente:"
    echo ""
    local i=1
    for a in "${CADEH_AGENTS[@]}"; do
      if [[ "$a" == "$current_agent" ]]; then
        echo "  $i) $(agent_label "$a") ← atual"
      else
        echo "  $i) $(agent_label "$a")"
      fi
      ((i++))
    done
    echo ""

    local choice
    if [[ -t 0 ]]; then
      read -r -p "  Escolha (1-${#CADEH_AGENTS[@]}): " choice
    fi

    case "${choice:-}" in
      1) new_agent="cursor" ;;
      2) new_agent="claude" ;;
      3) new_agent="codex" ;;
      4) new_agent="antigravity" ;;
      5) new_agent="pi" ;;
      *) err "Escolha inválida"; exit 1 ;;
    esac
  fi

  if [[ "$new_agent" == "$current_agent" ]]; then
    warn "Projeto já está usando $(agent_label "$new_agent")"
    log "Nada a fazer. Use: cadeh update $target para atualizar os arquivos"
    exit 0
  fi

  echo ""
  log "Trocando: $(agent_label "$current_agent") → $(agent_label "$new_agent")"

  # 1. Remove current agent files
  _clean_agent_files "$target" "$current_agent"

  # 2. Install new agent files
  local templates="${CADEH_ROOT}/templates"
  _install_agent_files "$target" "$new_agent" "$templates" "true"

  # 3. Re-copy docs/cadeh/commands (for the new agent's command copies)
  rm -f "${target}/docs/cadeh/commands"/cadeh-*.md 2>/dev/null || true
  local agent_dir="${templates}/agents/${new_agent}"
  if [[ -d "${agent_dir}/commands" ]]; then
    cp -f "${agent_dir}/commands/"*.md "${target}/docs/cadeh/commands/" 2>/dev/null || true
  elif [[ -d "${agent_dir}/prompts" ]]; then
    cp -f "${agent_dir}/prompts/"*.md "${target}/docs/cadeh/commands/" 2>/dev/null || true
  fi

  # 4. Reconfigurar CodeGraph MCP para o novo agente (sem reindexar)
  reinstall_codegraph_mcp "$target" "$new_agent"

  if [[ -f "${target}/.cadeh/state.yml" ]]; then
    _cadeh_state_set_field "${target}/.cadeh/state.yml" agent "$new_agent"
  fi
  _cleanup_cursor_for_non_cursor_agent "$target" "$new_agent"

  echo ""
  ok "Agente trocado: $(agent_label "$current_agent") → $(agent_label "$new_agent")"
  log "Docs, estado e memória preservados"
  echo ""
  _offer_tlc_install_if_missing "$target" "$new_agent" || true
  doctor_check "$target" "$new_agent" || true
}

cmd_path() {
  echo "version:  ${CADEH_VERSION}"
  echo "bin:      $(readlink -f "${CADEH_ROOT}/bin/cadeh")"
  echo "root:     ${CADEH_ROOT}"
  echo "spec:     ${CADEH_ROOT}/spec"
  echo "templates:${CADEH_ROOT}/templates"
  echo "agents:   ${CADEH_ROOT}/templates/agents/"
  if [[ -L "${HOME}/.local/bin/cadeh" ]]; then
    echo "link:     ${HOME}/.local/bin/cadeh → $(readlink -f "${HOME}/.local/bin/cadeh" 2>/dev/null || readlink "${HOME}/.local/bin/cadeh")"
  fi
  echo ""
  echo "Global rules:"
  for agent in "${CADEH_AGENTS[@]}"; do
    local gp
    gp="$(agent_global_path "$agent")"
    if [[ -f "$gp" ]]; then
      echo "  $(agent_label "$agent"): $gp"
    fi
  done
}
