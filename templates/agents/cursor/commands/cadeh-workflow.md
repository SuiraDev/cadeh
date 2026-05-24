# CADEH — Workflow completo

Brief → SDD → Plano → Tasks → Implementar → Validar, com **CodeGraph** + `.cadeh/state.yml`.

## Cérebro (camadas integradas)

| O quê | Onde |
|-------|------|
| Código | CodeGraph (`.codegraph/`, MCP) |
| Fluxo SDD | `.cadeh/state.yml` |
| Spec | `docs/sdd/`, `docs/plans/`, `docs/tasks/` |
| Narrativa | `docs/memory/<feature>.md` |

Detalhes: `docs/cadeh/brain.md`

## Novo projeto / feature

```bash
cadeh init                    # CADEH + CodeGraph + TLC skill
cadeh new feature <slug>      # docs + branch feature/<slug> + tasks com pré-requisitos
```

Chat: `/cadeh-continue` → `/cadeh-spec` (TLC Specify)

## Se `.codegraph/` não existir

`cadeh codegraph install` ou `cadeh init`

## Mapa de fases

| Estado | Comando |
|--------|---------|
| Retomar | `/cadeh-continue` |
| Salvar sessão | `/cadeh-memory` |
| SDD | `/cadeh-spec` |
| Plano | `/cadeh-plan` |
| Tasks | `/cadeh-tasks` |
| Código | `/cadeh-implement` |
