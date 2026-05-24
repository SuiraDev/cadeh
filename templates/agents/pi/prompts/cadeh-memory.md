---
description: Salvar memória — persiste contexto entre chats (state.yml + memory)
---
# CADEH — Salvar memória (fim de sessão)

Persiste contexto entre chats. Use após trabalho relevante ou antes de fechar o chat.

## 1. Ler estado atual

`.cadeh/state.yml` — `feature`, `phase`, `task`, `branch`, `notes`

## 2. Atualizar fluxo (obrigatório)

Edite `.cadeh/state.yml`:

- `phase` — fase real agora (`brief` | `sdd` | `plan` | `tasks` | `implement` | `validate`)
- `task` — T-xx em andamento ou concluída
- `branch` — se mudou
- `updated_at` — data/hora atual
- `notes` — **uma linha** com o próximo passo concreto

## 3. Memória narrativa (se `feature` definida)

Arquivo: `docs/memory/<feature>.md` (crie com `cadeh new feature` se não existir)

Append na seção **Log de sessões**:

```md
### YYYY-MM-DD

- **Feito:** …
- **Decisões:** …
- **Bloqueios:** …
- **Próximo:** …
```

Atualize também **Decisões** e **Bloqueios** se houver mudança.

## 4. Não duplicar CodeGraph

Paths, símbolos e impacto ficam no **CodeGraph** — não copie listas de arquivos na memória narrativa.

## 5. Confirmar ao usuário

Resuma em 3–5 linhas o que foi salvo e sugira o comando do próximo chat: `/cadeh-continue` + fase (`/cadeh-spec`, `/cadeh-plan`, …).
