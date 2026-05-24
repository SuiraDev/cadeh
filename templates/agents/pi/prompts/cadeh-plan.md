---
description: Planejar implementação — deriva plano de implementação a partir do SDD
---
# CADEH — Planejar (Implementation Plan)

Deriva o plano de implementação a partir do SDD. Não implemente código.

## Precauções

1. `.cadeh/state.yml` — confirme `feature`, `phase: plan`
2. Leia `docs/sdd/<feature>.md` completo
3. **CodeGraph:** `codegraph_context` / `codegraph_search` nos módulos afetados

## Derivação do plano

Preencha `docs/plans/<feature>.md`:

1. **Objetivo** — 2-3 frases alinhadas ao SDD
2. **Contexto confirmado** — fatos do SDD + código lido via CodeGraph
3. **Inferências e suposições** — classifique confiança (Alta/Média/Baixa); risco Alto bloqueia
4. **Escopo técnico** — dentro/fora, vinculado a RFs
5. **Estratégia** — menor ponto de alteração, padrão existente
6. **Arquivos impactados** — tabela (arquivo, mudança, justificativa, RF)

## Proibido

- Inventar arquivos sem confirmar com CodeGraph
- Listar suposições como fatos
- Implementar código

## Ao encerrar

- Plano aprovado → `phase: tasks`
- `/cadeh-memory`
- Sugira: **`/cadeh-tasks`**
