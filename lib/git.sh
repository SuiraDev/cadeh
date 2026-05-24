# shellcheck shell=bash
# Wrappers Git para projetos com CADEH

_git_target() {
  local target="${1:-.}"
  require_dir "$target"
  cd "$target" && pwd
}

require_git_repo() {
  local target
  target="$(_git_target "$1")"
  if ! git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
    err "Não é um repositório Git: $target"
    exit 1
  fi
  echo "$target"
}

_git_run() {
  local target="$1"
  shift
  git -C "$target" "$@"
}

cmd_git() {
  local sub="${1:-}"
  shift || true

  case "$sub" in
    status|st)
      cmd_git_status "$@"
      ;;
    branch|br)
      cmd_git_branch "$@"
      ;;
    checkout|co)
      cmd_git_checkout "$@"
      ;;
    diff)
      cmd_git_diff "$@"
      ;;
    add)
      cmd_git_add "$@"
      ;;
    commit)
      cmd_git_commit "$@"
      ;;
    log)
      cmd_git_log "$@"
      ;;
    stash)
      cmd_git_stash "$@"
      ;;
    -h|--help|help|"")
      help_command git
      ;;
    *)
      err "Subcomando git desconhecido: $sub"
      echo ""
      log "Use: cadeh git help"
      exit 1
      ;;
  esac
}

cmd_git_status() {
  local target="."
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -h|--help) help_command "git status"; return ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done
  target="$(require_git_repo "$target")"
  log "Git status: $target"
  _git_run "$target" status
}

cmd_git_branch() {
  local target="."
  local name=""
  local create_only="false"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -c|--create-only) create_only="true"; shift ;;
      -h|--help) help_command "git branch"; return ;;
      -*)
        err "Opção desconhecida: $1"
        exit 1
        ;;
      *)
        if [[ -z "$name" ]]; then
          name="$1"
        else
          target="$1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$name" ]]; then
    target="$(require_git_repo "$target")"
    _git_run "$target" branch -a
    return
  fi

  target="$(require_git_repo "$target")"
  if _git_run "$target" show-ref --verify --quiet "refs/heads/${name}"; then
    warn "Branch já existe: $name"
    if [[ "$create_only" != "true" ]]; then
      _git_run "$target" checkout "$name"
      ok "Checkout: $name"
    fi
    return
  fi

  _git_run "$target" checkout -b "$name"
  ok "Branch criada: $name"
}

# Cria/checkout feature/<slug> sem abortar o CLI se não for repo Git
cadeh_git_try_feature_branch() {
  local target="$1"
  local slug="$2"
  local name="feature/${slug}"

  target="$(_git_target "$target")"
  if ! git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
    return 1
  fi

  if _git_run "$target" show-ref --verify --quiet "refs/heads/${name}"; then
    _git_run "$target" checkout "$name" >/dev/null 2>&1 || return 1
    log "Branch: checkout ${name}"
  else
    _git_run "$target" checkout -b "$name" >/dev/null 2>&1 || return 1
    ok "Branch criada: ${name}"
  fi
  return 0
}

cmd_git_checkout() {
  local target="."
  local name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -h|--help) help_command "git checkout"; return ;;
      -*)
        err "Opção desconhecida: $1"
        exit 1
        ;;
      *)
        if [[ -z "$name" ]]; then
          name="$1"
        else
          target="$1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$name" ]]; then
    err "Informe o nome da branch. Ex: cadeh git checkout feature/auth"
    exit 1
  fi

  target="$(require_git_repo "$target")"
  _git_run "$target" checkout "$name"
  ok "Checkout: $name"
}

cmd_git_diff() {
  local target="."
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -h|--help) help_command "git diff"; return ;;
      --)
        shift
        args+=("$@")
        break
        ;;
      -*)
        args+=("$1")
        shift
        ;;
      *)
        if [[ -d "$1" ]] && [[ ${#args[@]} -eq 0 ]]; then
          target="$1"
        else
          args+=("$1")
        fi
        shift
        ;;
    esac
  done

  target="$(require_git_repo "$target")"
  _git_run "$target" diff "${args[@]}"
}

cmd_git_add() {
  local target="."
  local paths=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -h|--help) help_command "git add"; return ;;
      -*)
        paths+=("$1")
        shift
        ;;
      *)
        paths+=("$1")
        shift
        ;;
    esac
  done

  target="$(require_git_repo "$target")"
  if [[ ${#paths[@]} -eq 0 ]]; then
    _git_run "$target" add -A
    ok "git add -A"
  else
    _git_run "$target" add "${paths[@]}"
    ok "git add ${paths[*]}"
  fi
}

cmd_git_commit() {
  local target="."
  local message=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -m)
        [[ $# -ge 2 ]] || { err "-m requer mensagem"; exit 1; }
        message="$2"
        shift 2
        ;;
      -h|--help) help_command "git commit"; return ;;
      *)
        if [[ -z "$message" ]]; then
          message="$1"
        elif [[ -d "$1" ]]; then
          target="$1"
        else
          err "Argumento inesperado: $1"
          exit 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$message" ]]; then
    err "Informe a mensagem: cadeh git commit -m \"sua mensagem\""
    exit 1
  fi

  target="$(require_git_repo "$target")"
  _git_run "$target" commit -m "$message"
  ok "Commit criado"
}

cmd_git_log() {
  local target="."
  local n=10

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      -n)
        [[ $# -ge 2 ]] || { err "-n requer número"; exit 1; }
        n="$2"
        shift 2
        ;;
      -h|--help) help_command "git log"; return ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  target="$(require_git_repo "$target")"
  _git_run "$target" log --oneline -n "$n"
}

cmd_git_stash() {
  local target="."
  local action="list"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -C|--path)
        [[ $# -ge 2 ]] || { err "Opção $1 requer caminho"; exit 1; }
        target="$2"
        shift 2
        ;;
      push|pop|list|drop)
        action="$1"
        shift
        ;;
      -h|--help) help_command "git stash"; return ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  target="$(require_git_repo "$target")"
  case "$action" in
    push) _git_run "$target" stash push -u ;;
    pop) _git_run "$target" stash pop ;;
    drop) _git_run "$target" stash drop ;;
    list) _git_run "$target" stash list ;;
  esac
}
