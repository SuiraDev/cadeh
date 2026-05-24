#!/usr/bin/env bash
# Ciclo completo de testes do CLI CADEH
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
export CADEH_SKIP_CODEGRAPH=1
export CADEH_SKIP_TLC=1
CADEH_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="/tmp/cadeh-full-cycle-$$"
GLOBAL_RULE="${HOME}/.cursor/rules/cadeh.mdc"
GLOBAL_BACKUP="/tmp/cadeh-global-backup-$$.mdc"

mkdir -p "$TEST_ROOT"
[[ -f "$GLOBAL_RULE" ]] && cp -a "$GLOBAL_RULE" "$GLOBAL_BACKUP" || true

pass=0
fail=0

run() {
  local name="$1"
  shift
  printf '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
  printf 'TEST: %s\n  %s\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n' "$name" "$*"
  if "$@"; then
    printf '✓ PASS: %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '✗ FAIL: %s (exit %s)\n' "$name" "$?"
    fail=$((fail + 1))
  fi
}

run_fail() {
  local name="$1"
  shift
  printf '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
  printf 'TEST (expect fail): %s\n  %s\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n' "$name" "$*"
  if "$@" 2>/dev/null; then
    printf '✗ FAIL: %s (deveria falhar)\n' "$name"
    fail=$((fail + 1))
  else
    printf '✓ PASS: %s\n' "$name"
    pass=$((pass + 1))
  fi
}

cd "$CADEH_REPO"

# --- Info / help ---
run "version" cadeh version
run "help" cadeh help
run "help install" cadeh help install
run "help uninstall" cadeh help uninstall
run "help new" cadeh help new
run "help status" cadeh help status
run "commands" cadeh commands
run "path" cadeh path
run "setup" cadeh setup
run "install --help" cadeh install --help
run "uninstall --help" cadeh uninstall --help
run "atalho h" cadeh h
run "atalho h install" cadeh h install

# --- Install / docs ---
run "init" cadeh init "$TEST_ROOT" --no-global --skip-codegraph --skip-tlc
run_fail "init duplicado" cadeh init "$TEST_ROOT"
run "init -f reinit" cadeh init "$TEST_ROOT" -f --no-global --skip-codegraph --skip-tlc
run "help init" cadeh help init
run "status" cadeh status "$TEST_ROOT"
run "doctor" cadeh doctor "$TEST_ROOT"
run "check (alias doctor)" cadeh check "$TEST_ROOT"
run "list vazio" cadeh list "$TEST_ROOT"

run "new sdd auth-login" cadeh new sdd auth-login -C "$TEST_ROOT"
run "new sdd slugify" cadeh new sdd "Minha Feature" -C "$TEST_ROOT"
run "new plan auth-login" cadeh new plan auth-login -C "$TEST_ROOT"
run "new tasks auth-login" cadeh new tasks auth-login -C "$TEST_ROOT"
run "new feature full-cycle" cadeh new feature full-cycle -C "$TEST_ROOT"
run "list com docs" cadeh list "$TEST_ROOT"
run "state.yml existe" test -f "${TEST_ROOT}/.cadeh/state.yml"
run "codegraph.md existe" test -f "${TEST_ROOT}/docs/cadeh/codegraph.md"
run "help codegraph" cadeh help codegraph

run_fail "new sdd duplicado" cadeh new sdd auth-login -C "$TEST_ROOT"
run_fail "new sem nome" cadeh new sdd -C "$TEST_ROOT"
run_fail "new tipo inválido" cadeh new foo bar -C "$TEST_ROOT"

run "update" cadeh update "$TEST_ROOT"
run "doctor pós-update" cadeh doctor "$TEST_ROOT"

# --- Atalhos ---
run "atalho i" cadeh i "$TEST_ROOT"
run "atalho u" cadeh u "$TEST_ROOT"
run "atalho g" cadeh g
run "atalho st" cadeh st "$TEST_ROOT"
run "atalho ls" cadeh ls "$TEST_ROOT"
run "atalho d" cadeh d "$TEST_ROOT"
run "atalho n sdd" cadeh n sdd via-atalho -C "$TEST_ROOT"

# --- install -f (AGENTS editado) ---
echo "linha-custom-test" >> "${TEST_ROOT}/AGENTS.md"
run "install sem force (sucesso)" cadeh install "$TEST_ROOT"
if grep -q "linha-custom-test" "${TEST_ROOT}/AGENTS.md"; then
  run "AGENTS mantido sem -f" true
else
  run "AGENTS mantido sem -f" false
fi
run "install -f sobrescreve AGENTS" cadeh install "$TEST_ROOT" -f
if grep -q "linha-custom-test" "${TEST_ROOT}/AGENTS.md" 2>/dev/null; then
  run "AGENTS sobrescrito com -f" false
else
  run "AGENTS sobrescrito com -f" true
fi

# --- uninstall parcial ---
run "uninstall parcial" cadeh uninstall "$TEST_ROOT"
run_fail "list após uninstall" cadeh list "$TEST_ROOT"
test -f "${TEST_ROOT}/docs/sdd/auth-login.md" && run "sdd mantido após uninstall" true || { echo "sdd deveria existir"; false; }

# --- reinstall + purge ---
run "reinstall" cadeh install "$TEST_ROOT"
cadeh new sdd purge-me -C "$TEST_ROOT" >/dev/null
run "uninstall --purge" cadeh uninstall "$TEST_ROOT" --purge
if [[ ! -d "${TEST_ROOT}/docs" ]]; then
  printf '✓ PASS: docs/ removida\n'
  pass=$((pass + 1))
else
  printf '✗ FAIL: docs/ ainda existe\n'
  fail=$((fail + 1))
fi

# --- global uninstall ---
rm -f "$GLOBAL_RULE"
run "uninstall --global" cadeh uninstall "$TEST_ROOT" --global
test ! -f "$GLOBAL_RULE" && run "global removida" true || false
run "global restore" cadeh global

# --- Legado / erros ---
run "install.sh" "$CADEH_REPO/install.sh" version
run_fail "comando inválido" cadeh foo
run_fail "help inválido" cadeh help foo
run_fail "install dir inexistente" cadeh install /tmp/nao-existe-harness-xyz

# --- git (repo temporário) ---
GIT_TEST="${TEST_ROOT}/git-test"
mkdir -p "$GIT_TEST"
git -C "$GIT_TEST" init -q
git -C "$GIT_TEST" config user.email "cadeh@test.local"
git -C "$GIT_TEST" config user.name "CADEH Test"
echo "init" > "${GIT_TEST}/README.md"
git -C "$GIT_TEST" add README.md
git -C "$GIT_TEST" commit -q -m "init"
cadeh install "$GIT_TEST" >/dev/null

run "git status" cadeh git status -C "$GIT_TEST"
run "git branch feature/x" cadeh git branch feature/x -C "$GIT_TEST"
run "new feature cria branch" cadeh new feature auto-branch -C "$GIT_TEST"
run "state branch preenchido" grep -q 'branch: "feature/auto-branch"' "${GIT_TEST}/.cadeh/state.yml"
run "tasks branch marcada" grep -q '\[x\] Branch criada' "${GIT_TEST}/docs/tasks/auto-branch.md"
run "git log" cadeh git log -n 3 -C "$GIT_TEST"
run "help git" cadeh help git

# restore
[[ -f "$GLOBAL_BACKUP" ]] && cp -a "$GLOBAL_BACKUP" "$GLOBAL_RULE" && rm -f "$GLOBAL_BACKUP"
rm -rf "$TEST_ROOT"

printf '\n════════════════════════════════════════\n'
printf 'RESULTADO: %s passed, %s failed (%s)\n' "$pass" "$fail" "$(cadeh version | head -1)"
printf '════════════════════════════════════════\n'
exit "$fail"
