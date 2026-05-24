# CADEH — Controlled AI Development Environment CADEH — Antigravity / VS Code

Este arquivo complementa o `AGENTS.md` para agentes AI que leem copilot-instructions (GitHub Copilot, Antigravity).

## Comportamento

Siga rigorosamente as instruções do `AGENTS.md` na raiz do projeto.

## Workflow SDD

O fluxo de engenharia de software é:

```
brief → sdd → plan → tasks → implement → validate
```

- **Especificar:** preencher `docs/sdd/<feature>.md`
- **Planejar:** derivar `docs/plans/<feature>.md`
- **Tasks:** quebrar em `docs/tasks/<feature>.md`
- **Implementar:** uma T-xx por vez, menor diff, commit atômico
- **Validar:** checklist em `docs/cadeh/validation-checklist.md`

## Memória entre chats

- **Início:** ler `.cadeh/state.yml` → docs da feature → CodeGraph → `docs/memory/`
- **Fim:** atualizar `state.yml` e append em `docs/memory/<feature>.md`

## Código

Use CodeGraph (`.codegraph/` MCP) para navegar símbolos, impacto e fluxo. Não faça grep em massa.

## CLI

```bash
cadeh new feature <slug>
cadeh continue
cadeh codegraph status
```

## Referência

- `docs/cadeh/cadeh.md` — contrato completo
- `docs/cadeh/workflow.md` — fluxo detalhado
- `docs/cadeh/codegraph.md` — CodeGraph MCP
