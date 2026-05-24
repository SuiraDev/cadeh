# Integração CADEH + TLC Spec-Driven

O CADEH usa a skill **[tlc-spec-driven](https://github.com/tech-leads-club/agent-skills)** (Tech Leads Club) como **base do processo** de especificação. Os artefatos ficam nos caminhos do CADEH para compatibilidade com CodeGraph, Git e memória.

## Instalação

```bash
cadeh init              # instala skill para o agente escolhido
cadeh tlc               # menu interativo (instalar / status / reinstalar)
cadeh tlc install       # reinstalar ou após --skip-tlc
cadeh tlc install --agent pi
cadeh tlc status
```

Alias: `cadeh tcl` → `cadeh tlc` (typo comum).

Comando direto (equivalente):

```bash
npx @tech-leads-club/agent-skills install --skill tlc-spec-driven
```

Skill no projeto (por agente):

| Agente | Path |
|--------|------|
| Cursor | `.cursor/skills/tlc-spec-driven/SKILL.md` |
| Claude Code | `.claude/skills/tlc-spec-driven/SKILL.md` |
| Codex | `.codex/skills/tlc-spec-driven/SKILL.md` |
| Antigravity | `.agent/skills/tlc-spec-driven/SKILL.md` |
| Pi Agent | `.pi/skills/tlc-spec-driven/SKILL.md` (espelhada após install) |

## Mapeamento de fases

| Fase CADEH | `state.yml` | Skill TLC | Referência | Artefato CADEH |
|--------------|-------------|-----------|------------|------------------|
| Especificar | `sdd` | **Specify** | `references/specify.md` | `docs/sdd/<slug>.md` |
| Planejar | `plan` | **Design** | `references/design.md` | `docs/plans/<slug>.md` |
| Tasks | `tasks` | **Tasks** | `references/tasks.md` | `docs/tasks/<slug>.md` |
| Implementar | `implement` | **Execute** | `references/implement.md` | código + T-xx |
| Validar | `validate` | **Validate** | `references/validate.md` | checklist CADEH |

Espelho opcional TLC (agente pode criar para ferramentas TLC):

```
.specs/features/<slug>/
├── spec.md      # cópia ou fonte sincronizada com docs/sdd/<slug>.md
├── design.md    # ↔ docs/plans/<slug>.md
└── tasks.md     # ↔ docs/tasks/<slug>.md
```

**Canônico para o CADEH:** sempre `docs/sdd|plans|tasks/` + `.cadeh/state.yml`.

## Git (obrigatório em feature nova)

`cadeh new feature <slug>`:

1. Cria docs + memória + estado
2. Se repositório Git: `git checkout -b feature/<slug>` e grava `branch` no `state.yml`
3. Personaliza `docs/tasks/<slug>.md` com pré-requisitos (branch marcada se criada)

## Comandos do agente

| Comando | Skill TLC |
|---------|-----------|
| `/cadeh-spec` | Specify (+ discuss se ambíguo) |
| `/cadeh-plan` | Design |
| `/cadeh-tasks` | Tasks (granular, critérios de verificação) |
| `/cadeh-implement` | Execute (commits atômicos por T-xx) |

## Complementos CADEH (não substituídos pela TLC)

- **CodeGraph** — memória de código (`.codegraph/`)
- **`.cadeh/state.yml`** — fase e T-xx ativa
- **`docs/memory/<slug>.md`** — decisões e log entre chats
- **`/cadeh-continue`** · **`/cadeh-memory`**

## Auto-sizing (TLC)

A skill adapta profundidade (Quick / Medium / Large / Complex). O agente deve declarar o escopo detectado no início do `/cadeh-spec` e seguir a profundidade adequada — sem pular Specify nem Execute.
