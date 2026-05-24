# Agent instructions

Este projeto usa o **CADEH — Controlled AI Development Environment Harness** com **cérebro integrado**: CodeGraph + estado SDD + especificação + memória narrativa.

## Comportamento obrigatório

- **Novo chat/sessão:** reconstrua contexto lendo `.cadeh/state.yml` + docs da feature + CodeGraph + `docs/CONTEXT.md` — não confie no histórico anterior.
- **Código:** use CodeGraph (`.codegraph/` + MCP) para navegar símbolos — não faça grep em massa nem invente paths.
- **Padrões do projeto:** siga `docs/CONTEXT.md` — stack, convenções, arquitetura, nomenclatura.
- **SDD:** orquestre fases; sugira o próximo passo ao concluir cada etapa.

## Cérebro (camadas que se complementam)

| Camada | Onde | Função |
|--------|------|--------|
| **Conhecimento** | `docs/CONTEXT.md` | Stack, padrões, convenções, arquitetura |
| Código | `.codegraph/` + MCP | Grafo, símbolos, impacto |
| Fluxo | `.cadeh/state.yml` | Feature, fase, T-xx |
| Spec | `docs/sdd/`, `docs/plans/`, `docs/tasks/` | O quê / como / T-xx |
| Narrativa | `docs/memory/<feature>.md` | Decisões e log entre sessões |

**Antes de qualquer código, leia `docs/CONTEXT.md`.** Para criar/atualizar: `/cadeh-context`.

Detalhes: `docs.cadeh/brain.md`

## Workflow (fases)

```
brief → sdd → plan → tasks → implement → validate
```

- **Especificar** — preencher SDD em `docs/sdd/<feature>.md` (entrevista, sem código)
- **Planejar** — derivar plano em `docs/plans/<feature>.md` (arquivos, passos)
- **Tasks** — quebrar em T-xx atômicas em `docs/tasks/<feature>.md`
- **Implementar** — uma T-xx por vez, menor diff, commit atômico
- **Validar** — checklist em `docs.cadeh/validation-checklist.md`

## Verdade e contexto

- Nunca invente arquivos, APIs, schemas, regras de negócio, libs ou arquitetura.
- Classifique: **confirmada** | **inferida** | **suposição** | **desconhecida**.
- Sem evidência, diga: "Não há contexto suficiente" e proponha o próximo passo.

## Hierarquia (em caso de conflito)

1. Pedido explícito do usuário nesta conversa
2. SDD em `docs/sdd/`
3. Código (CodeGraph + leitura pontual)
4. Plano em `docs/plans/`
5. O CADEH
6. Recomendações da IA (sempre rotuladas como hipótese)

## Implementação

- Menor diff suficiente; preserve padrões do projeto
- Sem dependências novas sem justificativa
- Respeite escopo do SDD e lista de arquivos do plano (seção 6)
- UI: hierarquia, acessibilidade, estados (loading, erro, vazio, sucesso)

## Memória entre sessões

- **Início:** leia `.cadeh/state.yml` → docs da feature → CodeGraph → `docs/memory/`
- **Fim:** atualize `state.yml` (phase, task, updated_at) e faça append em `docs/memory/<feature>.md`

## CLI

```bash
cadeh new feature <slug>    # sdd + plan + tasks + branch + memory
cadeh continue              # estado atual
cadeh codegraph status      # memória de código
cadeh doctor                # diagnóstico
```

## Auditoria (LGPD + Segurança)

Execute `/cadeh-audit` para uma auditoria completa de conformidade LGPD e vulnerabilidades. O agente percorrerá sistematicamente 70+ itens de verificação com evidências do código.

Template: `docs.cadeh/audit.md`

## Referência

- `docs.cadeh/harness.md` — contrato completo
- `docs.cadeh/brain.md` — arquitetura da memória
- `docs.cadeh/workflow.md` — fluxo SDD
- `docs.cadeh/codegraph.md` — CodeGraph MCP
- `docs.cadeh/validation-checklist.md` — validação pós-implementação
- `docs.cadeh/audit.md` — auditoria LGPD + segurança
