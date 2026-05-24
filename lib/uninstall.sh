# shellcheck shell=bash
# Remoção do CADEH (projeto e global)

uninstall_global() {
  local agent="${1:-cursor}"
  local path

  case "$agent" in
    cursor)
      rm -f "${HOME}/.cursor/rules/harness.mdc" 2>/dev/null || true
      path="${HOME}/.cursor/rules/cadeh.mdc"
      ;;
    claude)
      path="${HOME}/.claude/CLAUDE.md"
      ;;
    codex)
      path="${HOME}/.codex/AGENTS.md"
      ;;
    antigravity)
      path="${HOME}/AGENTS.md"
      ;;
    pi)
      path="${HOME}/.pi/agent/AGENTS.md"
      ;;
    *)
      warn "Agente desconhecido: $agent"
      return 1
      ;;
  esac

  if [[ -f "$path" ]]; then
    rm -f "$path"
    ok "Regra global removida: $path"
  else
    warn "Regra global não encontrada: $path"
  fi
}

# Remove AGENTS.md só se for cópia idêntica do template ou --force
uninstall_agents() {
  local target="$1"
  local root="$2"
  local force="${3:-false}"
  local agents="${target}/AGENTS.md"
  local template="${root}/templates/AGENTS.md"

  [[ -f "$agents" ]] || return 0

  if [[ "$force" == "true" ]]; then
    rm -f "$agents"
    log "AGENTS.md removido (--force)"
    return 0
  fi

  if cmp -s "$template" "$agents" 2>/dev/null; then
    rm -f "$agents"
    log "AGENTS.md removido (igual ao template)"
  else
    warn "AGENTS.md mantido (editado — use --force para remover)"
  fi
}

uninstall_project() {
  local target="$1"
  local root="$2"
  local force="${3:-false}"
  local purge="${4:-false}"
  local with_codegraph="${5:-false}"
  local agent="${6:-cursor}"

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  # try to detect agent
  if [[ -z "$agent" ]] || [[ "$agent" == "cursor" ]]; then
    agent="$(_detect_project_agent "$target")" 2>/dev/null || true
    [[ -z "$agent" ]] && agent="cursor"
  fi

  log "Removendo CADEH de: $target"
  log "Agente: $(agent_label "$agent")"

  # Agent-specific cleanup
  case "$agent" in
    cursor)
      rm -f "${target}/.cursor/rules/cadeh.mdc"
      rm -f "${target}/.cursor/rules/cadeh-feature-docs.mdc"
      rm -f "${target}/.cursor/rules/cadeh-codegraph.mdc"
      rm -f "${target}/.cursor/rules/harness.mdc"
      rm -f "${target}/.cursor/rules/harness-feature-docs.mdc"
      rm -f "${target}/.cursor/rules/harness-codegraph.mdc"
      rm -f "${target}/.cursor/rules/codegraph.mdc" 2>/dev/null || true
      rm -f "${target}/.cursor/commands"/cadeh-*.md 2>/dev/null || true
      rm -f "${target}/.cursor/commands"/harness-*.md 2>/dev/null || true
      log "Rules e commands Cursor removidos"
      # Cleanup empty dirs
      for d in "${target}/.cursor/commands" "${target}/.cursor/rules" "${target}/.cursor"; do
        if [[ -d "$d" ]] && [[ -z "$(ls -A "$d" 2>/dev/null)" ]]; then
          rmdir "$d" 2>/dev/null || true
        fi
      done
      ;;
    claude)
      if [[ "$force" == "true" ]]; then
        rm -f "${target}/CLAUDE.md"
        log "CLAUDE.md removido (--force)"
      else
        warn "CLAUDE.md mantido — use --force para remover"
      fi
      rm -f "${target}/.claude/commands"/cadeh-*.md 2>/dev/null || true
      rm -f "${target}/.claude/commands"/harness-*.md 2>/dev/null || true
      ;;
    codex)
      rm -f "${target}/.codex/rules/cadeh.rules"
      rm -f "${target}/.codex/rules/harness.rules"
      log "Rules Codex removidas"
      ;;
    antigravity)
      rm -f "${target}/.github/copilot-instructions.md"
      log "Copilot instructions removidas"
      ;;
    pi)
      rm -f "${target}/.pi/prompts"/cadeh-*.md 2>/dev/null || true
      rm -f "${target}/.pi/prompts"/harness-*.md 2>/dev/null || true
      rm -f "${target}/.pi/APPEND_SYSTEM.md" 2>/dev/null || true
      if [[ "$force" == "true" ]]; then
        rm -f "${target}/.pi/settings.json" 2>/dev/null || true
      fi
      log "Pi prompts e config removidos"
      ;;
  esac

  # AGENTS.md (universal)
  uninstall_agents "$target" "$root" "$force"

  # Docs
  if [[ "$purge" == "true" ]]; then
    if [[ -d "${target}/docs" ]]; then
      rm -rf "${target}/docs"
      log "docs/ removida inteira (--purge)"
    fi
  else
    rm -rf "${target}/docs/cadeh"
    log "docs/cadeh/ removida"

    rm -f "${target}/docs/sdd/_template.md"
    rm -f "${target}/docs/plans/_template.md"
    rm -f "${target}/docs/tasks/_template.md"
    rm -f "${target}/docs/sdd/README.md"
    rm -f "${target}/docs/plans/README.md"
    rm -f "${target}/docs/tasks/README.md"
    rm -f "${target}/docs/README.md"
    rm -f "${target}/.cadeh/state.yml"
    log "Templates e READMEs do CADEH removidos"

    for sub in sdd plans tasks; do
      if [[ -d "${target}/docs/${sub}" ]] && [[ -z "$(ls -A "${target}/docs/${sub}" 2>/dev/null)" ]]; then
        rmdir "${target}/docs/${sub}" 2>/dev/null && log "docs/${sub}/ removida (vazia)" || true
      fi
    done
    if [[ -d "${target}/docs" ]] && [[ -z "$(ls -A "${target}/docs" 2>/dev/null)" ]]; then
      rmdir "${target}/docs" 2>/dev/null && log "docs/ removida (vazia)" || true
    fi
  fi

  if [[ "$with_codegraph" == "true" ]]; then
    uninstall_codegraph_project "$target" "true" || true
  else
    log "CodeGraph mantido (.codegraph/ e MCP) — use --codegraph para remover"
  fi

  ok "CADEH removido de $target"
}
