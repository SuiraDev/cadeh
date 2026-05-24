# Implementation Plan

> **Papel:** plano do *como* — entre SDD e código.  
> **Entrada:** [sdd.md](./sdd.md) preenchido e aprovado.  
> **Regras:** [cadeh.md](./cadeh.md) · [cadeh.md](./cadeh.md)  
> **Saída:** diff guiado + validação via [validation-checklist.md](./validation-checklist.md)

**Feature / ID:** `[mesmo ID do SDD]`  
**SDD:** `[link ou path para docs/sdd/...]`  
**Status:** Rascunho | Pronto para implementar | Concluído

---

## 1. Objetivo da implementação

Resumo em 2–3 frases: o que será entregue, alinhado ao SDD, sem expandir escopo.

---

## 2. Contexto confirmado

Apenas fatos comprovados (SDD, código lido, docs, pedido explícito).

| Item | Fonte | ID SDD (se houver) |
|------|-------|-------------------|
| [Ex: RF-01 exige listagem paginada] | SDD | RF-01 |
| [Ex: componente `DataTable` existe] | Código | — |

---

## 3. Inferências e suposições controladas

### Inferências

| Inferência | Base | Confiança |
|------------|------|-----------|
| [Ex: endpoint usa mesmo padrão de auth] | Código em `middleware.ts` | Alta / Média / Baixa |

### Suposições (exigem validação antes de virar decisão)

| Suposição | Risco | Como validar |
|-----------|-------|--------------|
| [Ex: tabela X já tem índice em `user_id`] | Alto | `EXPLAIN` ou schema Prisma |
| | Baixo/Médio/Alto | |

**Regra:** suposição de risco Alto bloqueia implementação até validação.

---

## 4. Escopo técnico

### Dentro do escopo
- [ ] [Comportamento / RF vinculado]
- [ ] [Arquivo ou módulo]

### Fora do escopo
- [ ] [Explicitar o que não será tocado]

---

## 5. Estratégia de implementação

1. Entender padrão existente no código.
2. Identificar menor ponto de alteração.
3. Implementar menor mudança suficiente.
4. Preservar consistência visual e arquitetural.
5. Validar comportamento (testes / manual conforme SDD §10).
6. Revisar com [validation-checklist.md](./validation-checklist.md).

---

## 6. Arquivos impactados

| Arquivo | Mudança | Justificativa | RF |
|---------|---------|---------------|-----|
| `path/to/file` | Criar / Alterar / Remover | [Motivo] | RF-01 |

**Regra:** não alterar arquivos fora desta lista sem atualizar o plano e informar o usuário.

---

## 7. Passo a passo

### Etapa 1 — Análise
- [ ] Ler SDD completo
- [ ] Mapear RF → componentes
- [ ] Ler arquivos da seção 6
- [ ] Confirmar padrões (naming, erros, testes)

**Saída:**

```md
## Diagnóstico técnico
[Resumo]

## Riscos identificados
- [Risco]

## Decisões necessárias
- [ ] [Decisão pendente do usuário]
```

### Etapa 2 — Fundação
- [ ] Tipos, schemas, contratos
- [ ] Testes de contrato (se aplicável)

### Etapa 3 — Lógica de negócio
- [ ] Serviços / Server Actions / handlers
- [ ] Tratamento de erros alinhado ao projeto

### Etapa 4 — Interface
- [ ] Componentes e estados (loading, erro, vazio)
- [ ] Acessibilidade e responsividade

### Etapa 5 — Integração e validação
- [ ] Wire end-to-end
- [ ] Executar critérios de aceite do SDD
- [ ] Checklist de validação

---

## 8. Tratamento de erros e edge cases

| Cenário | Comportamento esperado | Onde implementar |
|---------|------------------------|------------------|
| [Ex: input inválido] | 400 + mensagem | `schema.ts` |
| [Ex: não autorizado] | 403 | middleware |

---

## 9. Plano de testes (mínimo)

| Caso | Tipo | Arquivo / comando |
|------|------|-------------------|
| RF-01 happy path | Unit / integration | |
| RF-01 edge case | | |

---

## 10. Rollback e flags

- Feature flag: `[sim/não — nome]`
- Rollback: `[como reverter com segurança]`

---

## 11. Definition of Done

- [ ] Todos os RF do escopo atendidos
- [ ] Arquivos da seção 6 implementados
- [ ] Sem suposições de risco Alto pendentes
- [ ] [validation-checklist.md](./validation-checklist.md) aplicado
- [ ] SDD atualizado se houve desvio acordado
