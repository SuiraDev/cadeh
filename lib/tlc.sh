# shellcheck shell=bash
# Tech Leads Club — tlc-spec-driven (instalação no projeto)

tlc_skill_installed() {
  local target="$1"
  [[ -f "${target}/.cursor/skills/tlc-spec-driven/SKILL.md" ]]
}

install_tlc_skill() {
  local target="$1"
  local force="${2:-false}"

  if [[ "${CADEH_SKIP_TLC:-}" == "1" ]]; then
    log "TLC skill: ignorado (CADEH_SKIP_TLC=1)"
    return 0
  fi

  target="$(cd "$target" && pwd)"

  if tlc_skill_installed "$target" && [[ "$force" != "true" ]]; then
    log "TLC skill já instalada: .cursor/skills/tlc-spec-driven/"
    return 0
  fi

  if ! command -v npx >/dev/null 2>&1; then
    warn "npx ausente — TLC skill não instalada"
    warn "Rode: cadeh tlc install (requer Node 18+)"
    return 1
  fi

  log "Instalando skill tlc-spec-driven (Cursor)..."
  if (cd "$target" && npx -y @tech-leads-club/agent-skills install -s tlc-spec-driven -a cursor ${force:+-f}); then
    ok "TLC skill: .cursor/skills/tlc-spec-driven/"
    return 0
  fi

  warn "Falha ao instalar tlc-spec-driven"
  return 1
}

cmd_tlc() {
  local sub="${1:-install}"
  shift || true
  local force="false"
  local target="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force="true"; shift ;;
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      install|-h|--help|help)
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          help_command tlc
          return
        fi
        [[ "$1" == "install" ]] && shift
        ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  require_dir "$target"
  target="$(cd "$target" && pwd)"

  case "$sub" in
    install)
      install_tlc_skill "$target" "$force" || exit 1
      ;;
    status)
      if tlc_skill_installed "$target"; then
        ok "tlc-spec-driven instalada"
      else
        warn "tlc-spec-driven ausente — cadeh tlc install"
        exit 1
      fi
      ;;
    *)
      help_command tlc
      ;;
  esac
}
