# CADEH — Controlled AI Development Environment CADEH — Claude Code

Siga o `AGENTS.md` do projeto. Este arquivo complementa com instruções específicas do Claude Code.

## Comandos slash

Use os comandos abaixo para orquestrar o fluxo SDD:

| Comando | Fase |
|---------|------|
| `/cadeh-continue` | Retomar contexto entre chats |
| `/cadeh-spec` | Especificar (SDD via TLC) |
| `/cadeh-plan` | Planejar implementação |
| `/cadeh-tasks` | Quebrar em tarefas T-xx |
| `/cadeh-implement` | Implementar uma T-xx |
| `/cadeh-memory` | Salvar contexto ao encerrar |
| `/cadeh-workflow` | Mapa completo do fluxo |

## CodeGraph

Use as ferramentas MCP do CodeGraph (`.codegraph/`) para navegar no código:
- `codegraph_search` — achar símbolos
- `codegraph_context` — contexto da feature
- `codegraph_impact` — antes de editar

Se `.codegraph/` não existir: `cadeh codegraph install`

## Git

```bash
cadeh git status
cadeh git branch feature/<slug>
cadeh git commit -m "feat(<slug>): T-xx descrição"
```
