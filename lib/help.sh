# shellcheck shell=bash
# Ajuda do CLI

usage_main() {
  cat <<EOF
cadeh — CADEH — Controlled AI Development Environment Harness v${CADEH_VERSION}

Uso: cadeh <comando> [opções]
     cadeh help <comando>

Instalação
  setup                 Instala CLI em ~/.local/bin
  init [path]           Inicia CADEH + CodeGraph no projeto
  install [path]        Instala CADEH no projeto (padrão: .)
  uninstall [path]      Remove CADEH do projeto
  switch [path]         Troca de agente (cursor↔claude↔codex↔antigravity↔pi)
  global                Regra global (todos os projetos)
  update [path]         Atualiza arquivos (igual install)

Agentes
  agents                Lista agentes suportados
  --agent <nome>        Seleciona agente (cursor|claude|codex|antigravity|pi)

Documentação
  new sdd <nome>        Cria docs/sdd/<nome>.md
  new plan <nome>       Cria docs/plans/<nome>.md
  new tasks <nome>      Cria docs/tasks/<nome>.md
  new feature <nome>    Cria sdd + plan + tasks + memory + state
  continue [path]       Resumo do fluxo e comando sugerido
  tlc [install|status]  Skill tlc-spec-driven (menu interativo sem args)
  tlc install [path]    Instala skill para o agente do projeto
  tlc status [path]       Verifica skill TLC

CodeGraph (memória de código)
  codegraph install     Configura MCP + index no projeto
  codegraph status      Estatísticas do índice
  codegraph index       Reindexar

Git (no diretório do projeto)
  git status [path]     git status
  git branch <nome>     Cria e faz checkout da branch
  git checkout <nome>   Troca de branch
  git diff [args]       git diff (args extras permitidos)
  git add [paths]       Stage (sem paths: git add -A)
  git commit -m "msg"   Commit com mensagem
  git log [-n N]        Histórico oneline
  git stash [push|pop|list]

Auxiliares
  status [path]         Resumo da instalação (global + projeto)
  list [path]           Lista SDDs e planos no projeto
  path                  Caminhos do CLI e do repositório
  doctor [path]         Diagnóstico detalhado (check)
  version               Versão e root do CADEH
  commands              Lista comandos (uma linha cada)
  help [comando]        Esta ajuda ou ajuda de um comando

Opções comuns
  --agent <nome>        init|install|global|uninstall: agente alvo
  -f, --force           install/uninstall: força arquivos
  -g, --global          uninstall: remove regra global
  --purge               uninstall: apaga docs/ inteira
  --codegraph           uninstall: remove CodeGraph do projeto
  -C, --path <dir>      new: projeto alvo

Atalhos: i install · u update · g global · d doctor · n new · h help · st status · ls list

Exemplos:
  npx cadeh init
  cadeh init --agent pi
  cadeh init --agent cursor
  cadeh agents
  cadeh new feature auth
  cadeh git branch feature/auth

Mais: README.md · STRUCTURE.md · spec/workflow.md

EOF
}

help_command() {
  local cmd="${1:-}"
  case "$cmd" in
    setup)
      cat <<'EOF'
cadeh setup

  Instala o executável em ~/.local/bin/cadeh (symlink para este repo).
  Verifica se ~/.local/bin está no PATH.

Exemplo:
  cadeh setup
EOF
      ;;
    init)
      cat <<'EOF'
cadeh init [path] [--agent <nome>] [--global] [--no-global] [-f]

  Comando principal para usar o CADEH em um projeto seu.
  Faz: install + CodeGraph (init -i) + doctor + regra global (se ausente).

  path              Diretório do projeto (padrão: .)
  --agent <nome>    Agente alvo: cursor|claude|codex|antigravity|pi
                    Se omitido, abre seleção interativa
  --global          Força instalação da regra global
  --no-global       Não instala regra global
  --skip-codegraph  Não roda CodeGraph (testes/CI)
  --skip-tlc        Não instala skill tlc-spec-driven (testes/CI)
  -f, --force       Reinstala scaffold

Exemplos:
  npx cadeh init
  cadeh init --agent pi
  cadeh init --agent claude
  cadeh init ~/workspace/legacy-app --no-global --agent codex
EOF
      ;;
    install|i)
      cat <<'EOF'
cadeh install [path] [--agent <nome>] [-f]

  Copia rules, commands, AGENTS.md e docs/ (sdd, plans, tasks, cadeh).
  Fontes: spec/ e templates/agents/<nome>/ deste repositório.

  path             Diretório do projeto (padrão: .)
  --agent <nome>   Agente alvo: cursor|claude|codex|antigravity|pi (padrão: cursor)
  -f               Sobrescreve AGENTS.md se já existir

Exemplos:
  cadeh install --agent pi
  cadeh install ~/workspace/meu-app --agent claude
  cadeh install . -f
EOF
      ;;
    uninstall|remove|rm|u)
      cat <<'EOF'
cadeh uninstall [path] [--agent <nome>] [-g] [--purge] [--codegraph] [-f]

  Remove scaffold do CADEH. Por padrão mantém SDDs/planos que você criou.

  --agent <nome>   Agente alvo (detecta automaticamente se omitido)
  -g, --global     Remove também regra global
  --purge          Remove docs/ inteira (inclui suas features)
  --codegraph      Remove também CodeGraph (.codegraph/ + MCP)
  -f, --force      Remove AGENTS.md mesmo se editado

Exemplos:
  cadeh uninstall .
  cadeh uninstall . --agent pi
  cadeh uninstall . --codegraph
  cadeh uninstall ~/app --global --codegraph
  cadeh uninstall . --purge -f
EOF
      ;;
    global|g)
      cat <<'EOF'
cadeh global [--agent <nome>]

  Instala regra global do CADEH para o agente escolhido.
  
  --agent <nome>   cursor: ~/.cursor/rules/cadeh.mdc
                   claude: ~/.claude/CLAUDE.md
                   codex:  ~/.codex/AGENTS.md
                   antigravity: ~/AGENTS.md
                   pi:     ~/.pi/agent/AGENTS.md

  Combinar com: cadeh install <projeto>  (docs + rules locais)

Exemplos:
  cadeh global --agent pi
  cadeh global --agent claude
  cadeh global
EOF
      ;;
    update|u)
      cat <<'EOF'
cadeh update [path] [--agent <nome>] [-f]

  Sincroniza projeto com spec/ e templates/ atuais (mesmo que install).

Exemplo:
  cadeh update ~/workspace/meu-app --agent pi
EOF
      ;;
    new|n)
      cat <<'EOF'
cadeh new sdd|plan|tasks|feature <nome> [path|-C path]

  Cria documento(s) de feature a partir de _template.md.
  feature = sdd + plan + tasks com o mesmo slug (+ atualiza .cadeh/state.yml)

  -C, --path   Projeto (padrão: diretório atual)

Exemplos:
  cadeh new feature auth-login
  cadeh new tasks auth-login -C ~/workspace/app
EOF
      ;;
    git)
      cat <<'EOF'
cadeh git <subcomando> [args] [-C path]

  Wrappers Git no projeto (requer repositório git init/clone).

  status [path]              git status
  branch <nome> [path]       checkout -b (ou checkout se existe)
  checkout <nome> [path]
  diff [git-args...] [path]
  add [paths...] [path]      sem paths: git add -A
  commit -m "msg" [path]
  log [-n 10] [path]
  stash [push|pop|list|drop] [path]

Exemplos:
  cadeh git status .
  cadeh git branch feature/auth-login
  cadeh git commit -m "feat(auth): T-01 schema"
EOF
      ;;
    "git status"|"git branch"|"git checkout"|"git diff"|"git add"|"git commit"|"git log"|"git stash")
      help_command git
      ;;
    doctor|d|check)
      cat <<'EOF'
cadeh doctor [path] [--agent <nome>]

  Verifica regra global, rules do projeto, templates e docs/cadeh.
  Alias: cadeh check

  --agent <nome>   Agente alvo (detecta automaticamente se omitido)

Exemplo:
  cadeh doctor .
  cadeh doctor . --agent pi
EOF
      ;;
    agents|agent-list)
      cat <<'EOF'
cadeh agents

  Lista todos os agentes suportados com seus paths e formatos.

Exemplo:
  cadeh agents
EOF
      ;;
    switch|sw)
      cat <<'EOF'
cadeh switch [path] [--agent <nome>]

  Troca o agente de IA do projeto preservando docs, estado e memória.
  Remove arquivos do agente atual e instala os do novo agente.

  path             Diretório do projeto (padrão: .)
  --agent <nome>   Novo agente: cursor|claude|codex|antigravity|pi
                   Se omitido, abre seleção interativa mostrando o atual

Exemplos:
  cadeh switch --agent pi
  cadeh switch . --agent claude
  cadeh switch                  # seleção interativa
EOF
      ;;
    status|st)
      cat <<'EOF'
cadeh status [path]

  Resumo rápido: CLI, global, projeto, contagem de SDDs/planos.

Exemplo:
  cadeh status .
EOF
      ;;
    list|ls)
      cat <<'EOF'
cadeh list [path]

  Lista arquivos em docs/sdd/ e docs/plans/ (exceto _template e README).

Exemplo:
  cadeh list .
EOF
      ;;
    path|paths|root)
      cat <<'EOF'
cadeh path

  Exibe caminho do binário, repositório CADEH (spec/, templates/) e regra global.

Exemplo:
  cadeh path
EOF
      ;;
    version|v)
      cat <<'EOF'
cadeh version

  Versão do CLI e diretório raiz do repositório CADEH.

Exemplo:
  cadeh version
EOF
      ;;
    tlc)
      cat <<'EOF'
cadeh tlc [install|status] [path] [--agent <nome>] [-f]

  Skill Tech Leads Club: tlc-spec-driven (Specify → Design → Tasks → Execute).
  Sem subcomando: menu interativo (TTY).

  install [path]   Instala para o agente do projeto (ou --agent)
  status [path]    Verifica SKILL.md; oferece instalar se ausente
  -f, --force      Reinstala (cópia forçada do vendor/)

  Origem: vendor/tlc-spec-driven/ no pacote CADEH (sem npx)

  Paths por agente:
    cursor      .cursor/skills/tlc-spec-driven/
    claude      .claude/skills/tlc-spec-driven/
    codex       .codex/skills/tlc-spec-driven/
    antigravity .agent/skills/tlc-spec-driven/
    pi          .pi/skills/tlc-spec-driven/

  Também em: cadeh init · após cadeh switch (menu se faltar)
  Alias: cadeh tcl → tlc

Exemplos:
  cadeh tlc
  cadeh tlc install --agent pi
  cadeh tlc status .
EOF
      ;;
    codegraph|cg)
      cat <<'EOF'
cadeh codegraph <install|status|index|sync> [path]

  Integração CodeGraph — grafo local do código (.codegraph/).

  install [path]   MCP Cursor (local) + codegraph init -i
  status [path]    Estatísticas do índice
  index [path]     Reindexar (--force no codegraph)
  sync [path]      Sincronização incremental

  Requer: Node/npx ou codegraph no PATH
  Pacote: @colbymchenry/codegraph

Exemplo:
  cadeh codegraph install .
  cadeh codegraph status
EOF
      ;;
    commands|cmds)
      cmd_commands_list
      ;;
    help|h)
      usage_main
      ;;
    *)
      err "Comando desconhecido: $cmd"
      echo ""
      log "Comandos disponíveis:"
      cmd_commands_list
      exit 1
      ;;
  esac
}

cmd_commands_list() {
  cat <<EOF
setup init install uninstall global update switch continue tlc agents
new sdd | new plan | new tasks | new feature
codegraph install | status | index | sync
git status | branch | checkout | diff | add | commit | log | stash
status list path doctor version commands help
EOF
}
