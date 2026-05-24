# CADEH — Gerar Tasks com TLC Spec-Driven

Quebre o plano em T-xx **atômicas** com critérios de verificação (TLC Tasks). Não implemente código nesta sessão.

## Skill TLC

1. `.cursor/skills/tlc-spec-driven/SKILL.md`
2. Siga **`references/tasks.md`** — uma tarefa = um componente / função / endpoint / arquivo
3. Leia `docs/plans/<slug>.md` e `docs/sdd/<slug>.md`

## Contexto

1. `.cadeh/state.yml` — `phase: tasks`
2. **CodeGraph** — `codegraph_impact` nos símbolos principais
3. `docs/tasks/<slug>.md`

## Estrutura obrigatória do arquivo

**Não remova** estas seções do template CADEH:

1. **Resumo** (objetivo, branch `feature/<slug>`)
2. **Pré-requisitos** — todos marcados `[x]` antes de implementar:
   - SDD aprovado
   - Plano com seção 6
   - Branch `feature/<slug>` criada
3. **Tarefas** — tabela T-xx com: verificação TLC, arquivos, dependências, status
4. **Ordem de execução**
5. **Definition of Done**

Mescle granularidade TLC na tabela T-xx (critério de verificação por tarefa).

## Ao encerrar

`phase: implement` · `task: T-01` · `/cadeh-memory` · sugira **`/cadeh-implement`**
