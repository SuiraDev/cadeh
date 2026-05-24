# CADEH — Planejar (Design) com TLC Spec-Driven

Derive o plano do SDD aprovado usando fase **Design** da skill TLC. Não implemente código nesta sessão.

## Skill TLC

1. `.cursor/skills/tlc-spec-driven/SKILL.md`
2. Siga **`references/design.md`** (pule só se escopo Small/Medium e SKILL permitir design inline)
3. Leia `docs/sdd/<slug>.md` antes de desenhar

## Contexto

1. `.cadeh/state.yml` — `phase: plan`
2. **CodeGraph** — seção 6 do plano = arquivos **reais** (`codegraph_search`, `codegraph_context`)
3. `docs/plans/<slug>.md`
4. Confirme `branch` em `state.yml` (deve ser `feature/<slug>`)

## Gravar

| Destino | Conteúdo |
|---------|----------|
| **`docs/plans/<slug>.md`** | Canônico — arquitetura, componentes, reutilização, arquivos impactados |
| `.specs/features/<slug>/design.md` | Espelho TLC (opcional) |

## Ao encerrar

Plano aprovado → `phase: tasks` · `/cadeh-memory` · sugira **`/cadeh-tasks`**
