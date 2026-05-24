# Fluxo CADEH — SDD guiado por IA

> Fluxo com **cérebro integrado**: CodeGraph + estado + spec + memória narrativa.  
> Arquitetura: [brain.md](./brain.md)

## Fases

```text
CodeGraph ⇄ Estado (.cadeh) ⇄ Spec (docs) ⇄ Memória (docs/memory)
                ↑                    ↑      ↑       ↑         ↑
         /cadeh-continue    /cadeh-spec  /cadeh-plan  /cadeh-tasks  /cadeh-implement
                ↑
         /cadeh-memory (fim de sessão)
```

| Camada | Artefato | Função |
|--------|----------|--------|
| Código | `.codegraph/` + MCP | Grafo, símbolos, impacto |
| Fluxo | `.cadeh/state.yml` | Feature, fase, T-xx |
| Spec | `docs/sdd|plans|tasks/` | O quê / como / checklist |
| Narrativa | `docs/memory/<feature>.md` | Decisões e log entre chats |

## Início rápido

```bash
cd /seu/projeto
cadeh init
cadeh new feature minha-feature
cadeh continue
```

No agente: `/cadeh-continue` → `/cadeh-spec`

`cadeh init` instala CADEH **e** CodeGraph.

## Troca de chat (nunca perder contexto)

1. Novo chat → `/cadeh-continue`
2. Agente lê `state.yml` + docs da feature + `docs/memory/` + **CodeGraph**
3. Ao encerrar → `/cadeh-memory`

O histórico do chat **não** é fonte de verdade.

## Comandos

| Terminal | Agente IA |
|----------|----------|
| `cadeh continue` | `/cadeh-continue` |
| `cadeh new feature <slug>` | `/cadeh-spec` … |
| `cadeh codegraph index` | MCP `codegraph_*` |

## Modo entrevista (agente)

Spec / plan / tasks: perguntas focadas, gravar Markdown, **não codar** até `/cadeh-implement`.

Código existente: sempre **CodeGraph**, não grep em massa.

## Orquestração automática

O agente lê `phase` em `state.yml` e sugere o próximo `/cadeh-*` ao concluir cada etapa.
