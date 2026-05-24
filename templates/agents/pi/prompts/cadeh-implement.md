---
description: Implementar uma tarefa T-xx — menor diff, commit atômico, TLC Execute
---
# CADEH — Implementar tarefa (TLC Execute)

Implemente **uma** T-xx com menor diff. Fase **Execute** da TLC: commits atômicos.

## Antes de codar

1. `.cadeh/state.yml` — `task` (T-xx), `feature`, `branch`
2. Confirme checkout em `feature/<slug>` (`cadeh git status`)
3. `docs/tasks/<slug>.md` — só a T-xx atual
4. **CodeGraph:** `codegraph_impact` nos símbolos a alterar

## Execute (TLC)

1. Leia `references/implement.md` da skill tlc-spec-driven
2. Liste passos atômicos se Tasks foi pulada (safety valve TLC)
3. Implemente só a T-xx; teste critério de verificação da tarefa
4. Commit atômico:
   ```bash
   cadeh git add <arquivos>
   cadeh git commit -m "feat(<slug>): T-xx descrição"
   ```

## Ao concluir T-xx

- Marque tarefa `concluída` em `docs/tasks/<slug>.md`
- Atualize `task:` para próxima T-xx ou `phase: validate`
- `/cadeh-memory` se encerrar sessão

## Proibido

- Expandir escopo além do SDD
- Trabalhar em `master`/`main` se `branch` definida para a feature
- Ignorar CodeGraph
