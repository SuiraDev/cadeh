# shellcheck shell=bash
# Instalação em projeto e regra global por agente

_prune_empty_dir() {
  local d="$1"
  [[ -d "$d" ]] || return 0
  if [[ -z "$(find "$d" -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]]; then
    rmdir "$d" 2>/dev/null || true
  fi
}

# Remove artefatos CADEH em .cursor/ quando o agente alvo não é Cursor (ex.: pi, claude, codex)
_cleanup_cursor_for_non_cursor_agent() {
  local target="$1"
  local agent="$2"
  local removed="false"

  case "$agent" in
    cursor|antigravity) return 0 ;;
  esac

  if [[ -d "${target}/.cursor/skills/tlc-spec-driven" ]]; then
    rm -rf "${target}/.cursor/skills/tlc-spec-driven"
    removed="true"
  fi

  rm -f "${target}/.cursor/rules/cadeh"*.mdc \
        "${target}/.cursor/rules/harness"*.mdc \
        "${target}/.cursor/rules/cadeh-codegraph.mdc" \
        "${target}/.cursor/rules/codegraph.mdc" 2>/dev/null || true

  rm -f "${target}/.cursor/commands/cadeh-"*.md \
        "${target}/.cursor/commands/harness-"*.md 2>/dev/null || true

  # Pi/Claude/Codex usam MCP próprio — não deixar .cursor/mcp.json legado do CodeGraph
  if [[ -f "${target}/.cursor/mcp.json" ]] && grep -q '"codegraph"' "${target}/.cursor/mcp.json" 2>/dev/null; then
    case "$agent" in
      pi)
        [[ -f "${target}/.mcp.json" ]] && rm -f "${target}/.cursor/mcp.json" && removed="true"
        ;;
      claude)
        [[ -f "${target}/.claude/mcp.json" ]] && rm -f "${target}/.cursor/mcp.json" && removed="true"
        ;;
      codex)
        grep -q "codegraph" "${target}/.codex/config.toml" 2>/dev/null && rm -f "${target}/.cursor/mcp.json" && removed="true"
        ;;
    esac
  fi

  _prune_empty_dir "${target}/.cursor/commands"
  _prune_empty_dir "${target}/.cursor/rules"
  _prune_empty_dir "${target}/.cursor/skills"
  _prune_empty_dir "${target}/.cursor"

  if [[ "$removed" == "true" ]]; then
    log "Removido legado em .cursor/ (agente: $(agent_label "$agent"))"
  fi
}

_cadeh_merge_gitignore() {
  local target="$1"
  local gitignore="${target}/.gitignore"
  local snippet="${CADEH_ROOT}/templates/.gitignore.cadeh"

  [[ -f "$snippet" ]] || return 0

  if [[ -f "$gitignore" ]] && grep -qE '^\.codegraph/?$' "$gitignore" 2>/dev/null; then
    return 0
  fi

  {
    echo ""
    echo "# CADEH / CodeGraph"
    grep -v '^#' "$snippet" | grep -v '^$' || true
  } >> "$gitignore"
  log ".gitignore: .codegraph/"
}

_install_cadeh_state() {
  local target="$1"
  local force="${2:-false}"
  mkdir -p "${target}/.cadeh"
  if [[ -f "${target}/.cadeh/state.yml" && "$force" != "true" ]]; then
    return 0
  fi
  if [[ -f "${target}/.cadeh/state.yml" && "$force" == "true" ]]; then
    warn "state.yml mantido (use cadeh update sem --force no state ou edite manualmente)"
    return 0
  fi
  cp -f "${CADEH_ROOT}/templates/.cadeh/state.yml" "${target}/.cadeh/state.yml"
  log "Estado: .cadeh/state.yml"
}

# Instala os arquivos especificos do agente no projeto
_install_agent_files() {
  local target="$1"
  local agent="$2"
  local templates="$3"
  local force="${4:-false}"

  local agent_dir="${templates}/agents/${agent}"
  [[ -d "$agent_dir" ]] || { warn "Adapter nao encontrado: ${agent_dir}"; return 1; }

  local IFS='|'
  local paths
  paths=($(agent_project_paths "$agent"))
  local rules_dir="${paths[0]}"
  local commands_dir="${paths[1]}"

  # Rules
  if [[ -n "$rules_dir" ]] && [[ -d "${agent_dir}/rules" ]]; then
    mkdir -p "${target}/${rules_dir}"
    cp -f "${agent_dir}/rules/"* "${target}/${rules_dir}/" 2>/dev/null || true
    log "Rules: ${rules_dir}/"
  fi

  # Commands / prompts
  if [[ -n "$commands_dir" ]] && [[ -d "${agent_dir}/commands" ]]; then
    mkdir -p "${target}/${commands_dir}"
    cp -f "${agent_dir}/commands/"*.md "${target}/${commands_dir}/" 2>/dev/null || true
    mkdir -p "${target}/docs/cadeh/commands"
    cp -f "${agent_dir}/commands/"*.md "${target}/docs/cadeh/commands/" 2>/dev/null || true
    log "Commands: ${commands_dir}/"
  fi

  # Prompts (Pi Agent)
  if [[ -d "${agent_dir}/prompts" ]]; then
    mkdir -p "${target}/.pi/prompts"
    cp -f "${agent_dir}/prompts/"*.md "${target}/.pi/prompts/" 2>/dev/null || true
    mkdir -p "${target}/docs/cadeh/commands"
    cp -f "${agent_dir}/prompts/"*.md "${target}/docs/cadeh/commands/" 2>/dev/null || true
    log "Prompts: .pi/prompts/"
  fi

  # CLAUDE.md (Claude Code)
  if [[ -f "${agent_dir}/CLAUDE.md" ]]; then
    if [[ -f "${target}/CLAUDE.md" && "$force" != "true" ]]; then
      warn "CLAUDE.md já existe — mantido (use --force)"
    else
      cp -f "${agent_dir}/CLAUDE.md" "${target}/CLAUDE.md"
      log "CLAUDE.md"
    fi
  fi

  # Pi-specific files
  if [[ -f "${agent_dir}/APPEND_SYSTEM.md" ]]; then
    mkdir -p "${target}/.pi"
    cp -f "${agent_dir}/APPEND_SYSTEM.md" "${target}/.pi/APPEND_SYSTEM.md"
    log ".pi/APPEND_SYSTEM.md"
  fi

  if [[ -f "${agent_dir}/settings.json" ]]; then
    mkdir -p "${target}/.pi"
    if [[ -f "${target}/.pi/settings.json" && "$force" != "true" ]]; then
      warn ".pi/settings.json já existe — mantido (use --force)"
    else
      cp -f "${agent_dir}/settings.json" "${target}/.pi/settings.json"
      log ".pi/settings.json"
    fi
  fi

  # Copilot instructions (Antigravity)
  if [[ -d "${agent_dir}/.github" ]]; then
    mkdir -p "${target}/.github"
    cp -f "${agent_dir}/.github/"* "${target}/.github/" 2>/dev/null || true
    log ".github/copilot-instructions.md"
  fi

  return 0
}

install_project() {
  local target="$1"
  local force="${2:-false}"
  local root="$3"
  local agent="${4:-cursor}"
  local templates="${root}/templates"
  local spec="${root}/spec"

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  log "Instalando CADEH em: $target"
  log "Agente: $(agent_label "$agent")"

  # Docs (universal)
  mkdir -p "${target}/docs/sdd" "${target}/docs/plans" "${target}/docs/tasks" "${target}/docs/memory" "${target}/docs/cadeh/commands"

  # AGENTS.md (universal — todos os agentes leem)
  if [[ -f "${target}/AGENTS.md" && "$force" != "true" ]]; then
    warn "AGENTS.md já existe — mantido (use --force)"
  else
    cp -f "${templates}/AGENTS.md" "${target}/AGENTS.md"
    log "AGENTS.md"
  fi

  # Agent-specific files
  _install_agent_files "$target" "$agent" "$templates" "$force"

  # Docs templates (universal)
  cp -f "${templates}/docs/README.md" "${target}/docs/README.md"
  cp -f "${templates}/docs/sdd/README.md" "${target}/docs/sdd/README.md"
  cp -f "${templates}/docs/plans/README.md" "${target}/docs/plans/README.md"
  cp -f "${templates}/docs/tasks/README.md" "${target}/docs/tasks/README.md"
  if [[ -f "${templates}/docs/memory/README.md" ]]; then
    cp -f "${templates}/docs/memory/README.md" "${target}/docs/memory/README.md"
  fi

  _install_cadeh_state "$target" "$force"
  _cadeh_merge_gitignore "$target"

  cp -f "${spec}/cadeh.md" "${target}/docs/cadeh/cadeh.md"
  cp -f "${spec}/prompt.md" "${target}/docs/cadeh/prompt.md"
  cp -f "${spec}/validation-checklist.md" "${target}/docs/cadeh/validation-checklist.md"
  cp -f "${spec}/audit.md" "${target}/docs/cadeh/audit.md"
  cp -f "${spec}/context.md" "${target}/docs/cadeh/context.md"
  cp -f "${spec}/workflow.md" "${target}/docs/cadeh/workflow.md"
  cp -f "${spec}/codegraph.md" "${target}/docs/cadeh/codegraph.md"
  cp -f "${spec}/brain.md" "${target}/docs/cadeh/brain.md"
  cp -f "${spec}/tlc-integration.md" "${target}/docs/cadeh/tlc-integration.md"
  cp -f "${spec}/sdd.md" "${target}/docs/sdd/_template.md"
  cp -f "${spec}/implementation-plan.md" "${target}/docs/plans/_template.md"
  cp -f "${spec}/tasks.md" "${target}/docs/tasks/_template.md"

  install_tlc_skill "$target" "$force" "$agent" || warn "TLC skill não instalada — rode: cadeh tlc"

  if [[ -f "${target}/.cadeh/state.yml" ]]; then
    _cadeh_state_set_field "${target}/.cadeh/state.yml" agent "$agent"
  fi

  _cleanup_cursor_for_non_cursor_agent "$target" "$agent"

  ok "CADEH instalado em $target"
}

install_global() {
  local root="$1"
  local agent="${2:-cursor}"

  case "$agent" in
    cursor)
      local rules_dir="${HOME}/.cursor/rules"
      mkdir -p "$rules_dir"
      cp -f "${root}/templates/agents/cursor/rules/cadeh.mdc" "${rules_dir}/cadeh.mdc"
      ok "Regra global: ${rules_dir}/cadeh.mdc"
      log "Vale em todos os projetos abertos no Cursor (alwaysApply: true)"
      ;;
    claude)
      local dest="${HOME}/.claude/CLAUDE.md"
      mkdir -p "$(dirname "$dest")"
      if [[ -f "$dest" ]]; then
        cat "${root}/templates/agents/claude/CLAUDE.md" >> "$dest"
        ok "CLAUDE.md global atualizado: $dest"
      else
        cp -f "${root}/templates/AGENTS.md" "$dest"
        echo "" >> "$dest"
        cat "${root}/templates/agents/claude/CLAUDE.md" >> "$dest"
        ok "CLAUDE.md global criado: $dest"
      fi
      ;;
    codex)
      local dest="${HOME}/.codex/AGENTS.md"
      mkdir -p "$(dirname "$dest")"
      cp -f "${root}/templates/AGENTS.md" "$dest"
      ok "AGENTS.md global: $dest"
      ;;
    antigravity)
      local dest="${HOME}/AGENTS.md"
      cp -f "${root}/templates/AGENTS.md" "$dest"
      ok "AGENTS.md global: $dest"
      ;;
    pi)
      local dest="${HOME}/.pi/agent/AGENTS.md"
      mkdir -p "$(dirname "$dest")"
      cp -f "${root}/templates/AGENTS.md" "$dest"
      ok "AGENTS.md global: $dest"
      log "Vale em todos os projetos abertos no Pi Agent"
      ;;
  esac
}

# Detecta qual agente está instalado no projeto
_detect_project_agent() {
  local target="$1"
  local state="${target}/.cadeh/state.yml"
  local from_state

  if [[ -f "$state" ]]; then
    from_state="$(_cadeh_state_get "$state" agent)"
    if [[ -n "$from_state" ]] && resolve_agent "$from_state" >/dev/null 2>&1; then
      echo "$from_state"
      return 0
    fi
  fi

  if [[ -f "${target}/.cursor/rules/cadeh.mdc" ]] || [[ -f "${target}/.cursor/rules/harness.mdc" ]]; then echo "cursor"; return 0; fi
  if [[ -f "${target}/CLAUDE.md" ]]; then echo "claude"; return 0; fi
  if [[ -f "${target}/.codex/rules/cadeh.rules" ]] || [[ -f "${target}/.codex/rules/harness.rules" ]]; then echo "codex"; return 0; fi
  if [[ -f "${target}/.github/copilot-instructions.md" ]]; then echo "antigravity"; return 0; fi
  if [[ -f "${target}/.pi/prompts/cadeh-continue.md" ]] || [[ -f "${target}/.pi/prompts/harness-continue.md" ]]; then echo "pi"; return 0; fi
  echo "cursor"  # default
}

doctor_check() {
  local target="${1:-.}"
  local agent="${2:-}"
  local issues=0

  target="$(cd "$target" 2>/dev/null && pwd)" || { err "Diretório inválido"; return 1; }

  # Detect agent if not specified
  if [[ -z "$agent" ]]; then
    agent="$(_detect_project_agent "$target")"
  fi

  echo "Projeto: $target"
  echo "Agente: $(agent_label "$agent")"
  echo ""

  # Global rule check
  local global_path
  global_path="$(agent_global_path "$agent")"
  if [[ -n "$global_path" ]] && [[ -f "$global_path" ]]; then
    ok "Regra global (${agent})"
  else
    warn "Regra global ausente — rode: cadeh global --agent ${agent}"
    ((issues++)) || true
  fi

  # Agent-specific rules check
  local IFS='|'
  local paths
  paths=($(agent_project_paths "$agent"))
  local rules_dir="${paths[0]}"
  local commands_dir="${paths[1]}"

  if [[ -n "$rules_dir" ]]; then
    case "$agent" in
      cursor)
        if [[ -f "${target}/.cursor/rules/cadeh.mdc" ]]; then
          ok "Rules do projeto (.cursor/rules/)"
        else
          warn "Rules ausentes — rode: cadeh install"
          ((issues++)) || true
        fi
        ;;
      claude)
        if [[ -f "${target}/CLAUDE.md" ]]; then
          ok "CLAUDE.md"
        else
          warn "CLAUDE.md ausente"
          ((issues++)) || true
        fi
        ;;
      codex)
        if [[ -f "${target}/.codex/rules/cadeh.rules" ]]; then
          ok "Rules Codex (.codex/rules/)"
        else
          warn "Rules Codex ausentes"
          ((issues++)) || true
        fi
        ;;
      antigravity)
        if [[ -f "${target}/.github/copilot-instructions.md" ]]; then
          ok "Copilot instructions"
        else
          warn ".github/copilot-instructions.md ausente"
          ((issues++)) || true
        fi
        ;;
      pi)
        if [[ -f "${target}/.pi/APPEND_SYSTEM.md" ]]; then
          ok ".pi/APPEND_SYSTEM.md"
        else
          warn ".pi/ APPEND_SYSTEM.md ausente"
          ((issues++)) || true
        fi
        ;;
    esac
  fi

  # Commands/prompts check
  if agent_has_commands "$agent"; then
    local cmd_path
    case "$agent" in
      cursor) cmd_path="${target}/.cursor/commands" ;;
      claude) cmd_path="${target}/.claude/commands" ;;
      pi) cmd_path="${target}/.pi/prompts" ;;
      *) cmd_path="" ;;
    esac
    if [[ -n "$cmd_path" ]] && [[ -d "$cmd_path" ]] && [[ -n "$(find "$cmd_path" -maxdepth 1 -name 'cadeh-*.md' 2>/dev/null | head -1)" ]]; then
      ok "Comandos/Prompts ($cmd_path)"
    else
      warn "Comandos/Prompts ausentes"
      ((issues++)) || true
    fi
  fi

  if [[ -f "${target}/docs/sdd/_template.md" ]]; then
    ok "Template SDD"
  else
    warn "docs/sdd/_template.md ausente"
    ((issues++)) || true
  fi

  if [[ -f "${target}/docs/plans/_template.md" ]]; then
    ok "Template plano"
  else
    warn "docs/plans/_template.md ausente"
    ((issues++)) || true
  fi

  if [[ -f "${target}/docs/tasks/_template.md" ]]; then
    ok "Template tasks"
  else
    warn "docs/tasks/_template.md ausente"
    ((issues++)) || true
  fi

  if [[ -f "${target}/.cadeh/state.yml" ]]; then
    ok "Estado do fluxo (.cadeh/state.yml)"
  else
    warn ".cadeh/state.yml ausente"
    ((issues++)) || true
  fi

  if [[ -d "${target}/docs/cadeh/commands" ]] && [[ -n "$(find "${target}/docs/cadeh/commands" -maxdepth 1 -name 'cadeh-*.md' 2>/dev/null | head -1)" ]]; then
    ok "Comandos docs/cadeh/commands/"
  else
    warn "docs/cadeh/commands/ ausente — rode: cadeh update"
    ((issues++)) || true
  fi

  if [[ "${CADEH_SKIP_TLC:-}" != "1" ]]; then
    if tlc_skill_installed "$target" "$agent"; then
      ok "TLC skill (tlc-spec-driven) — $(tlc_skill_rel_path "$agent")"
    else
      warn "tlc-spec-driven ausente para $(agent_label "$agent") — rode: cadeh tlc"
      ((issues++)) || true
    fi
  fi

  if [[ -f "${target}/docs/cadeh/prompt.md" ]]; then
    ok "docs/cadeh/prompt.md"
  else
    warn "docs/cadeh/ incompleto"
    ((issues++)) || true
  fi

  codegraph_doctor_check "$target" "$agent" || ((issues++)) || true

  echo ""
  if [[ $issues -eq 0 ]]; then
    ok "Tudo certo"
    return 0
  fi
  warn "$issues problema(s) encontrado(s)"
  return 1
}

_new_doc_single() {
  local kind="$1"
  local slug="$2"
  local target="$3"
  local template dest subdir

  case "$kind" in
    sdd) subdir="sdd" ;;
    plan) subdir="plans" ;;
    tasks) subdir="tasks" ;;
    *)
      err "Tipo interno inválido: $kind"
      return 1
      ;;
  esac

  template="${target}/docs/${subdir}/_template.md"
  dest="${target}/docs/${subdir}/${slug}.md"

  if [[ ! -f "$template" ]]; then
    err "Template ausente: $template"
    return 1
  fi

  if [[ -f "$dest" ]]; then
    if [[ "${4:-}" == "skip_existing" ]]; then
      warn "Já existe (ignorado): $dest"
      return 0
    fi
    err "Já existe: $dest"
    return 1
  fi

  cp "$template" "$dest"
  ok "Criado: $dest"
}

_set_feature_state() {
  local target="$1"
  local slug="$2"
  local phase="${3:-sdd}"
  local branch="${4:-}"
  local state="${target}/.cadeh/state.yml"
  local date
  date="$(date '+%Y-%m-%d %H:%M')"

  [[ -f "$state" ]] || return 0

  _cadeh_state_set_field "$state" feature "$slug"
  _cadeh_state_set_field "$state" phase "$phase"
  _cadeh_state_set_field "$state" updated_at "$date"
  if [[ -n "$branch" ]]; then
    _cadeh_state_set_field "$state" branch "$branch"
  fi
}

_personalize_tasks_file() {
  local target="$1"
  local slug="$2"
  local branch_ok="${3:-false}"
  local dest="${target}/docs/tasks/${slug}.md"

  [[ -f "$dest" ]] || return 0

  sed -i "s/\[mesmo ID do SDD\]/${slug}/g" "$dest" 2>/dev/null || \
    sed -i '' "s/\[mesmo ID do SDD\]/${slug}/g" "$dest" 2>/dev/null || true
  sed -i "s/feature\/<slug>/feature\/${slug}/g" "$dest" 2>/dev/null || \
    sed -i '' "s/feature\/<slug>/feature\/${slug}/g" "$dest" 2>/dev/null || true
  sed -i "s/feat(<slug>)/feat(${slug})/g" "$dest" 2>/dev/null || \
    sed -i '' "s/feat(<slug>)/feat(${slug})/g" "$dest" 2>/dev/null || true

  if [[ "$branch_ok" == "true" ]]; then
    sed -i 's/- \[ \] Branch criada:/- [x] Branch criada:/' "$dest" 2>/dev/null || \
      sed -i '' 's/- \[ \] Branch criada:/- [x] Branch criada:/' "$dest" 2>/dev/null || true
  fi
}

_cadeh_feature_git_branch() {
  local target="$1"
  local slug="$2"
  local branch="feature/${slug}"

  if cadeh_git_try_feature_branch "$target" "$slug"; then
    _set_feature_state "$target" "$slug" "sdd" "$branch"
    echo "$branch"
    return 0
  fi
  warn "Git ausente ou branch não criada — crie: cadeh git branch ${branch}"
  return 1
}

new_doc() {
  local kind="$1"
  local name="$2"
  local target="$3"
  local slug

  slug="$(slugify "$name")"
  if [[ -z "$slug" ]]; then
    err "Nome inválido: $name"
    exit 1
  fi

  require_cadeh_project "$target"

  case "$kind" in
    sdd|plan|tasks)
      if ! _new_doc_single "$kind" "$slug" "$target"; then
        exit 1
      fi
      ;;
    feature)
      log "Criando feature: $slug"
      _new_doc_single sdd "$slug" "$target" skip_existing || exit 1
      _new_doc_single plan "$slug" "$target" skip_existing || exit 1
      _new_doc_single tasks "$slug" "$target" skip_existing || exit 1
      _new_feature_memory "$target" "$slug"
      mkdir -p "${target}/.specs/features/${slug}"
      local branch_ok="false"
      if _cadeh_feature_git_branch "$target" "$slug" >/dev/null; then
        branch_ok="true"
        ok "Git: feature/${slug}"
      else
        _set_feature_state "$target" "$slug" "sdd"
      fi
      _personalize_tasks_file "$target" "$slug" "$branch_ok"
      local feat_agent
      feat_agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"
      log "Próximo: cadeh continue · $(agent_label "$feat_agent"): $(_cadeh_continue_entry "$feat_agent") → $(_cadeh_suggest_slash "sdd" "$feat_agent")"
      ;;
    *)
      err "Tipo inválido: $kind"
      exit 1
      ;;
  esac
}
