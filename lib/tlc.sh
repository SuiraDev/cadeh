# shellcheck shell=bash
# Tech Leads Club — tlc-spec-driven (instalação no projeto)

_tlc_mirror_for_pi() {
  local target="$1"
  local force="${2:-false}"
  local src="${target}/.cursor/skills/tlc-spec-driven"
  local dest="${target}/.pi/skills/tlc-spec-driven"

  [[ -d "$src" ]] || return 1

  if [[ -d "$dest" ]] && [[ "$force" != "true" ]]; then
    return 0
  fi

  mkdir -p "${target}/.pi/skills"
  rm -rf "$dest"
  cp -a "$src" "$dest"
  ok "TLC skill (Pi): .pi/skills/tlc-spec-driven/"
  return 0
}

_tlc_post_install() {
  local target="$1"
  local agent="$2"
  local force="${3:-false}"

  if [[ "$agent" == "pi" ]]; then
    _tlc_mirror_for_pi "$target" "$force" || warn "Espelho Pi ausente — reinstale: cadeh tlc install --agent pi -f"
  fi
}

install_tlc_skill() {
  local target="$1"
  local force="${2:-false}"
  local agent="${3:-}"

  if [[ "${CADEH_SKIP_TLC:-}" == "1" ]]; then
    log "TLC skill: ignorado (CADEH_SKIP_TLC=1)"
    return 0
  fi

  target="$(cd "$target" && pwd)"

  if [[ -z "$agent" ]]; then
    agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"
  fi

  if tlc_skill_installed "$target" "$agent" && [[ "$force" != "true" ]]; then
    log "TLC skill já instalada: $(tlc_skill_rel_path "$agent")"
    if [[ "$agent" == "pi" ]] && [[ ! -f "${target}/.pi/skills/tlc-spec-driven/SKILL.md" ]]; then
      _tlc_mirror_for_pi "$target" "true"
    fi
    return 0
  fi

  if ! command -v npx >/dev/null 2>&1; then
    warn "npx ausente — TLC skill não instalada"
    warn "Requer Node.js 18+ — depois: cadeh tlc install"
    return 1
  fi

  local tlc_cli
  tlc_cli="$(tlc_agent_skills_cli "$agent")"

  log "Instalando tlc-spec-driven para $(agent_label "$agent")..."
  if (cd "$target" && npx -y @tech-leads-club/agent-skills install -s tlc-spec-driven -a "$tlc_cli" ${force:+-f}); then
    ok "TLC skill: $(tlc_skill_rel_path "$agent" | sed 's|/SKILL.md||')"
    _tlc_post_install "$target" "$agent" "$force"
    return 0
  fi

  warn "Falha ao instalar tlc-spec-driven (agente: $tlc_cli)"
  return 1
}

_offer_tlc_install_if_missing() {
  local target="$1"
  local agent="$2"
  local force="${3:-false}"

  if [[ "${CADEH_SKIP_TLC:-}" == "1" ]]; then
    return 0
  fi

  if tlc_skill_installed "$target" "$agent"; then
    return 0
  fi

  echo ""
  warn "Skill tlc-spec-driven ausente para $(agent_label "$agent")"
  echo ""
  echo "  1) Instalar agora"
  echo "  2) Pular (instalar depois com: cadeh tlc)"
  echo ""

  if [[ ! -t 0 ]]; then
    log "Rode: cadeh tlc install --agent $agent"
    return 1
  fi

  local choice
  read -r -p "  Escolha (1-2): " choice
  case "${choice:-}" in
    1)
      install_tlc_skill "$target" "$force" "$agent"
      ;;
    *)
      log "Pulado — quando quiser: cadeh tlc"
      return 1
      ;;
  esac
}

_cmd_tlc_interactive() {
  local target="."
  local force="false"
  local agent

  if [[ -d "${1:-.}" ]]; then
    target="$1"
    shift || true
  fi

  require_dir "$target"
  target="$(cd "$target" && pwd)"
  agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"

  echo ""
  log "TLC Spec-Driven — projeto: ${target}"
  log "Agente detectado: $(agent_label "$agent")"
  echo ""
  echo "  1) Instalar skill tlc-spec-driven"
  echo "  2) Verificar status"
  echo "  3) Reinstalar (forçar download)"
  echo "  4) Trocar agente alvo"
  echo "  5) Sair"
  echo ""

  local choice
  read -r -p "  Escolha (1-5): " choice

  case "${choice:-}" in
    1)
      install_tlc_skill "$target" "$force" "$agent" || exit 1
      ;;
    2)
      if tlc_skill_installed "$target" "$agent"; then
        ok "tlc-spec-driven instalada: $(tlc_skill_rel_path "$agent")"
      else
        warn "tlc-spec-driven ausente para $(agent_label "$agent")"
        _offer_tlc_install_if_missing "$target" "$agent" || exit 1
      fi
      ;;
    3)
      install_tlc_skill "$target" "true" "$agent" || exit 1
      ;;
    4)
      agent="$(prompt_agent_selection)"
      echo ""
      log "Agente: $(agent_label "$agent")"
      install_tlc_skill "$target" "$force" "$agent" || exit 1
      ;;
    5|q|Q)
      return 0
      ;;
    *)
      err "Escolha inválida"
      exit 1
      ;;
  esac
}

cmd_tlc() {
  # Alias amigável: cadeh tlc (sem subcomando) abre menu
  if [[ $# -eq 0 ]]; then
    if [[ -t 0 ]]; then
      _cmd_tlc_interactive
      return
    fi
    help_command tlc
    return
  fi

  local sub="${1:-}"
  shift || true
  local force="false"
  local target="."
  local agent=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force="true"; shift ;;
      --agent)
        [[ $# -ge 2 ]] || { err "--agent requer nome do agente"; exit 1; }
        agent="$2"
        if ! resolve_agent "$agent" >/dev/null; then exit 1; fi
        shift 2
        ;;
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      install)
        sub="install"
        shift
        ;;
      status)
        sub="status"
        shift
        ;;
      -h|--help|help)
        help_command tlc
        return
        ;;
      *)
        if [[ -d "$1" ]]; then
          target="$1"
        else
          err "Opção desconhecida: $1"
          exit 1
        fi
        shift
        ;;
    esac
  done

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  if [[ -z "$agent" ]]; then
    agent="$(_detect_project_agent "$target" 2>/dev/null || echo "cursor")"
  fi

  case "$sub" in
    install)
      install_tlc_skill "$target" "$force" "$agent" || exit 1
      ;;
    status)
      if tlc_skill_installed "$target" "$agent"; then
        ok "tlc-spec-driven instalada ($(agent_label "$agent"))"
        log "Path: $(tlc_skill_rel_path "$agent")"
      else
        warn "tlc-spec-driven ausente para $(agent_label "$agent")"
        if [[ -t 0 ]]; then
          _offer_tlc_install_if_missing "$target" "$agent" "$force" || exit 1
        else
          err "Rode: cadeh tlc install --agent $agent"
          exit 1
        fi
      fi
      ;;
    *)
      if [[ -t 0 ]]; then
        _cmd_tlc_interactive "$target"
      else
        help_command tlc
      fi
      ;;
  esac
}
