# CodeGraph no CADEH

O CADEH usa [CodeGraph](https://github.com/colbymchenry/codegraph) como **memória estrutural do código** — grafo local em `.codegraph/`, exposto via MCP no agente de IA.

## Por projeto

`cadeh init` executa automaticamente:

1. `codegraph install --target=cursor --location=local --yes`
2. `codegraph init -i` (index inicial)

## Ferramentas MCP

| Tool | Uso no CADEH |
|------|----------------|
| `codegraph_search` | Achar símbolos antes de editar |
| `codegraph_context` | Contexto para tarefa / SDD |
| `codegraph_callers` / `codegraph_callees` | Impacto e fluxo |
| `codegraph_impact` | Antes de mudanças em RF |
| `codegraph_explore` | Exploração ampla (subagente) |

## Estado do fluxo (não confundir)

| Artefato | Conteúdo |
|----------|----------|
| `.cadeh/state.yml` | Feature ativa, fase SDD, T-xx |
| `.codegraph/` | Código, símbolos, chamadas |
| `docs/sdd|plans|tasks/` | Especificação humana |
| `docs/memory/<feature>.md` | Decisões e log (não duplicar código aqui) |

Ver [brain.md](./brain.md) para o modelo integrado.

## Comandos CLI

```bash
cadeh codegraph status .
cadeh codegraph index .
cadeh codegraph install .
```

## Reindexar

```bash
cadeh codegraph sync .
# ou
cadeh codegraph index .
```

## Desinstalar

```bash
# Só CADEH (mantém .codegraph/)
cadeh uninstall .

# CADEH + CodeGraph (índice + MCP local)
cadeh uninstall . --codegraph
```
