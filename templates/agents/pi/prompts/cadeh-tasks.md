---
description: Quebrar plano em tarefas T-xx atômicas e verificáveis
---
# CADEH — Criar Tasks

Quebra o plano de implementação em tarefas atômicas (T-xx). Não implemente código.

## Precauções

1. `.cadeh/state.yml` — confirme `feature`, `phase: tasks`
2. Leia `docs/plans/<feature>.md` (seção 6: arquivos impactados)
3. **CodeGraph:** confirme paths da seção 6

## Estrutura das tasks

Preencha `docs/tasks/<feature>.md`:

- Cada T-xx: escopo único, verificável, independente quando possível
- Ordem: fundação → lógica → interface → integração
- Critério de verificação por tarefa (como validar que está pronta)

## Boas práticas

- T-01 a T-05 para features pequenas, T-01 a T-15+ para médias/grandes
- Cada T-xx = um commit atômico
- Tasks de fundação primeiro (tipos, schemas, contratos)

## Ao encerrar

- Tasks aprovadas → `phase: implement`, `task: T-01`
- `/cadeh-memory`
- Sugira: **`/cadeh-implement`**
