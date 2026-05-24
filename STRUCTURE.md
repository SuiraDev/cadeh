# Estrutura do repositório

```
cadeh/
├── package.json           # npm / npx (ai-suiradev-cadeh)
├── bin/cadeh.js           # Entry point npm
├── README.md
├── LICENSE
├── .gitignore
├── STRUCTURE.md
├── install.sh
│
├── bin/cadeh              # CLI Bash
├── lib/
│   ├── common.sh          # Utilidades, logging, agent adapters
│   ├── install.sh         # Instalação no projeto
│   ├── uninstall.sh       # Remoção
│   ├── help.sh            # Ajuda
│   ├── status.sh          # Status, list, path, switch
│   ├── git.sh             # Wrappers Git
│   ├── init.sh            # cadeh init
│   ├── codegraph.sh       # Integração CodeGraph + MCP por agente
│   ├── tlc.sh             # TLC Spec-Driven
│   └── state.sh           # Estado (.cadeh/state.yml) + continue + memory
│
├── spec/                  # Fontes Markdown (canônicas)
│   ├── harness.md         # Contrato normativo da IA
│   ├── persona.md         # Persona resumida
│   ├── persona.user-rule.md
│   ├── workflow.md        # Fluxo SDD guiado por IA
│   ├── sdd.md             # Template de especificação
│   ├── implementation-plan.md
│   ├── tasks.md
│   ├── prompt.md          # Prompt mestre
│   ├── validation-checklist.md
│   ├── audit.md           # Auditoria LGPD + OWASP (70+ itens)
│   ├── context.md         # Template de DNA do projeto
│   ├── brain.md           # Cérebro integrado (5 camadas)
│   ├── memory.md          # Template de memória narrativa
│   ├── codegraph.md       # Integração CodeGraph
│   ├── tlc-integration.md # Integração TLC Spec-Driven
│   ├── state.yml          # Template de estado
│   └── README.md
│
├── templates/
│   ├── AGENTS.md           # Universal — entry point para todos os agentes
│   ├── .cadeh/state.yml    # Template de estado
│   ├── .gitignore.cadeh    # Snippet para .gitignore
│   ├── docs/               # READMEs e templates de documentação
│   │   ├── README.md
│   │   ├── sdd/README.md
│   │   ├── plans/README.md
│   │   ├── tasks/README.md
│   │   └── memory/README.md
│   └── agents/             # Adapters por agente
│       ├── cursor/
│       │   ├── rules/      # cadeh.mdc, cadeh-codegraph.mdc, cadeh-feature-docs.mdc
│       │   └── commands/   # /cadeh-* (9 comandos)
│       ├── claude/
│       │   ├── CLAUDE.md
│       │   └── commands/   # /cadeh-* (9 comandos)
│       ├── codex/
│       │   └── rules/      # cadeh.rules
│       ├── antigravity/
│       │   └── .github/    # copilot-instructions.md
│       └── pi/
│           ├── prompts/    # /cadeh-* (9 prompt templates)
│           ├── APPEND_SYSTEM.md
│           └── settings.json
│
└── scripts/
    └── test-all.sh         # Testes do CLI (66 testes)
```

## Papéis

| Pasta | O quê |
|-------|--------|
| `spec/` | Fontes canônicas → copiadas para `docs/cadeh/` no projeto |
| `templates/AGENTS.md` | Entry point universal — todo agente lê |
| `templates/agents/<nome>/` | Arquivos específicos de cada agente (rules, commands, prompts) |
| `templates/docs/` | Templates de documentação (SDD, planos, tasks, memory) |
| `lib/` | Biblioteca do CLI Bash (modularizada por responsabilidade) |

## Fluxo v1.7

```
/cadeh-context → /cadeh-continue → /cadeh-spec → /cadeh-plan → /cadeh-tasks → /cadeh-implement → /cadeh-memory
                                                                                     ↓
                                                                               /cadeh-audit
```

**Cérebro (5 camadas):** Conhecimento → Código → Fluxo → Spec → Narrativa

Multi-agente: mesma lógica, paths de regras/comandos adaptados por agente.

## Agentes suportados

| Agente | Rules | Commands | Global |
|--------|-------|----------|--------|
| Cursor | `.cursor/rules/*.mdc` | `.cursor/commands/` | `~/.cursor/rules/cadeh.mdc` |
| Claude Code | `CLAUDE.md` | `.claude/commands/` | `~/.claude/CLAUDE.md` |
| Codex | `AGENTS.md` + `.codex/rules/` | — | `~/.codex/AGENTS.md` |
| Antigravity | `AGENTS.md` + `.github/copilot-instructions.md` | — | `~/AGENTS.md` |
| Pi Agent | `AGENTS.md` + `.pi/APPEND_SYSTEM.md` | `.pi/prompts/` | `~/.pi/agent/AGENTS.md` |

## Editar o CADEH

1. Altere `spec/` ou `templates/`.
2. `cadeh update <path>` nos projetos.
3. `cadeh global --agent <nome>` para regra global.

## Remover

```bash
cadeh uninstall .
cadeh uninstall . --global
cadeh uninstall . --purge
```
