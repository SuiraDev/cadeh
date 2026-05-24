# Documentação do projeto

| Pasta | Conteúdo |
|-------|----------|
| `sdd/` | O quê construir |
| `plans/` | Como implementar |
| `tasks/` | T-xx por sessão |
| .cadeh/` | Contrato, workflow, CodeGraph |

## Cérebro integrado

| Camada | Onde |
|--------|------|
| Código | CodeGraph `.codegraph/` |
| Fluxo | `.cadeh/state.yml` |
| Spec | `sdd/`, `plans/`, `tasks/` |
| Narrativa | `memory/<feature>.md` |

Detalhes: .cadeh/brain.md`

## Nova feature

```bash
cadeh new feature minha-feature
cadeh continue
```

Consulte o `AGENTS.md` na raiz do projeto para instruções do agente.
