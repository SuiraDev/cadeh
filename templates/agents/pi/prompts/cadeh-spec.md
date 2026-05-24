---
description: Especificar feature — elabora SDD usando TLC Spec-Driven (entrevista, sem código)
---
# CADEH — Especificar (SDD) com TLC Spec-Driven

Elaboração do SDD usando a skill **tlc-spec-driven**. Não implemente código nesta sessão.

## 0. Skill TLC (obrigatório)

1. Confirme `.cursor/skills/tlc-spec-driven/SKILL.md` ou `.pi/skills/tlc-spec-driven/SKILL.md` — se ausente: `cadeh tlc install`
2. Leia **SKILL.md** e siga **`references/specify.md`** (processo Specify)
3. Escopo ambíguo → **`references/discuss.md`** antes de fechar o spec

## 1. Precauções iniciais (antes de editar spec)

1. `.cadeh/state.yml` — `feature: <slug>`, `phase: sdd`
2. **Branch Git** — se `branch` vazio e repo Git:
   ```bash
   cadeh git branch feature/<slug>
   ```
   Atualize `branch:` no `state.yml`
3. **CodeGraph** — `codegraph_context` / `codegraph_search` no domínio do pedido
4. `docs/memory/<slug>.md` — bloqueios e decisões anteriores

## 2. Modo Specify (TLC)

- Declare escopo TLC: Small | Medium | Large | Complex (ver SKILL.md)
- Entrevista conversacional; desafie vagueza; critérios **WHEN/THEN/SHALL**
- User stories P1 (MVP) / P2 / P3, cada uma independentemente testável

## 3. Artefatos (gravar)

| Destino | Conteúdo |
|---------|----------|
| **`docs/sdd/<slug>.md`** | **Canônico CADEH** — Problem Statement, Goals, Out of Scope, User Stories, RF/RNF, critérios de aceite |
| `.specs/features/<slug>/spec.md` | Espelho TLC (opcional, mesmo conteúdo adaptado ao template TLC) |

Use o template em `docs/sdd/_template.md` como índice; corpo segue **specify.md** da TLC.

## 4. Proibido nesta fase

- Implementar código ou refatorar fora do spec
- Inventar requisitos sem confirmação
- Pular branch Git em feature nova

## 5. Ao encerrar

- SDD aprovado pelo usuário → `phase: plan`
- `/cadeh-memory`
- Sugira: **`/cadeh-plan`**

Referência: `docs.cadeh/tlc-integration.md`
