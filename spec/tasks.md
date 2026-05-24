# Tasks — checklist executável

> **Papel:** quebrar o plano em tarefas rastreáveis para o agente implementar em sessões.  
> **Entrada:** [implementation-plan.md](./implementation-plan.md) aprovado.  
> **Próximo passo:** implementar tarefa a tarefa com `docs/cadeh/prompt.md` ou comando `/cadeh-implement`.

**Feature / ID:** `[mesmo ID do SDD]`  
**SDD:** `docs/sdd/<feature>.md`  
**Plano:** `docs/plans/<feature>.md`  
**Status:** Rascunho | Pronto | Em progresso | Concluído

---

## 1. Resumo

| Campo | Valor |
|-------|--------|
| Objetivo | [1 frase alinhada ao SDD] |
| Branch Git sugerida | `feature/<slug>` |
| Estimativa | [opcional: S/M/L ou horas] |

---

## 2. Pré-requisitos

- [ ] SDD revisado e aprovado
- [ ] Plano revisado (seção 6 — arquivos impactados)
- [ ] Suposições de risco **Alto** validadas ou removidas
- [ ] Branch criada: `cadeh git branch feature/<slug>`

---

## 3. Tarefas

Formato: cada tarefa deve ser **independente o suficiente** para uma sessão do agente.

| ID | Tarefa | Etapa plano | Arquivos | Depende de | Status |
|----|--------|-------------|----------|------------|--------|
| T-01 | [Ex: criar schema e migration] | Etapa 2 | `prisma/schema.prisma` | — | pendente |
| T-02 | [Ex: API route GET /items] | Etapa 3 | `app/api/...` | T-01 | pendente |
| T-03 | [Ex: UI lista + estados] | Etapa 4 | `components/...` | T-02 | pendente |
| T-04 | [Ex: testes RF-01] | Etapa 5 | `*.test.ts` | T-02, T-03 | pendente |

**Status:** `pendente` · `em progresso` · `concluída` · `bloqueada`

---

## 4. Ordem sugerida de execução

1. T-01
2. T-02
3. T-03
4. T-04

---

## 5. Comandos Git por tarefa (referência)

```bash
cadeh git status
cadeh git diff
cadeh git add <arquivos>
cadeh git commit -m "feat(<slug>): T-01 descrição curta"
```

---

## 6. Definition of Done (feature)

- [ ] Todas as tarefas T-xx em `concluída`
- [ ] Critérios de aceite do SDD atendidos
- [ ] [validation-checklist.md](./validation-checklist.md) aplicado
- [ ] Commits com mensagens claras (Conventional Commits se o projeto usar)

---

## 7. Notas da sessão

| Data | Tarefa | Notas / bloqueios |
|------|--------|-------------------|
| | | |
