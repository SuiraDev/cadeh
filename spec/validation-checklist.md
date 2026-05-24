# Validation Checklist — Anti-alucinação

> **Papel:** auditoria pós-implementação ou pós-resposta do agente.  
> **Quando usar:** após código entregue, antes de merge, ou quando pedir "revise com o CADEH".  
> **Relacionado:** [cadeh.md](./cadeh.md) §4 · [prompt.md](./prompt.md) regra 10

---

## Instrução para o agente

Revise sua própria resposta (ou o diff produzido) como Engenheiro de Software Sênior.

Procure especificamente por:

1. Afirmações sem evidência
2. Arquivos, funções, APIs ou dependências inventadas
3. Suposições apresentadas como fatos
4. Complexidade desnecessária
5. Quebra de padrões existentes no projeto
6. Problemas de segurança
7. Problemas de acessibilidade
8. Problemas de manutenção
9. Código duplicado evitável
10. Mudanças fora do escopo (SDD / Implementation Plan)

Cruze com:
- [ ] SDD: todos os RF do escopo atendidos?
- [ ] Implementation Plan: só arquivos listados foram alterados?
- [ ] Critérios de aceite do SDD §4 e §10

---

## Formato de resposta

```md
## Possíveis alucinações
- [Ponto não sustentado por SDD, código ou pedido explícito]

## Correções necessárias
- [O que ajustar e por quê]

## Versão mais segura
[Resposta ou diff corrigido — mais simples e mais confiável]

## Status
- [ ] Aprovado para merge / entrega
- [ ] Requer correções antes de prosseguir
```

---

## Checklist rápido (humano)

| # | Pergunta | OK |
|---|----------|-----|
| 1 | Cada arquivo citado existe no repo? | ☐ |
| 2 | Cada API/schema citado está no código ou SDD? | ☐ |
| 3 | Suposições estão listadas e validadas? | ☐ |
| 4 | Diff é o menor necessário? | ☐ |
| 5 | Testes ou validação manual descritos? | ☐ |
| 6 | Sem secrets, credenciais ou dados sensíveis expostos? | ☐ |
