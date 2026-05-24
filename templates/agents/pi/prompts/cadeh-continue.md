---
description: Retomar sessão — reconstrói contexto entre chats usando o cérebro integrado (state.yml + docs + CodeGraph + memory)
---
# CADEH — Continuar sessão (cérebro integrado)

Reconstrói contexto entre chats. **Não confie** no histórico deste chat.

## Orquestração (ordem obrigatória)

1. **Fluxo** — `.cadeh/state.yml` (`feature`, `phase`, `task`, `notes`)
2. **Spec** — se `feature` preenchida:
   - `docs/sdd/<feature>.md`
   - `docs/plans/<feature>.md`
   - `docs/tasks/<feature>.md`
   - `docs/memory/<feature>.md` (se existir)
3. **Código** — CodeGraph (se `.codegraph/` existir):

| Tool | Quando |
|------|--------|
| `codegraph_status` | Confirmar índice |
| `codegraph_context` | Contexto da feature/tarefa |
| `codegraph_search` | Achar símbolos |
| `codegraph_impact` | Antes de editar |

Se `.codegraph/` ausente: peça `cadeh codegraph install`.

## Escolher modo automaticamente

| `phase` | Ação nesta sessão | Se usuário confirmar escopo |
|---------|-------------------|-----------------------------|
| vazio / `brief` | Preparar SDD | `/cadeh-spec` |
| `sdd` | Entrevista SDD ou revisar | `/cadeh-spec` → depois `/cadeh-plan` |
| `plan` | Derivar plano (CodeGraph na seção 6) | `/cadeh-plan` → `/cadeh-tasks` |
| `tasks` | Quebrar T-xx | `/cadeh-tasks` → `/cadeh-implement` |
| `implement` | Uma T-xx | `/cadeh-implement` |
| `validate` | Checklist | `docs/cadeh/validation-checklist.md` |

## Resumir (máx. 10 linhas)

- Feature, fase, T-xx, notas
- O que SDD/plan/tasks dizem (1 linha cada)
- O que CodeGraph mostra (símbolos/arquivos relevantes)
- Próximo comando `/cadeh-*` sugerido

Pergunte: *"Continuamos nesta fase ou mudou o escopo?"*

## Ao encerrar a sessão

Peça ou execute `/cadeh-memory` para persistir.
