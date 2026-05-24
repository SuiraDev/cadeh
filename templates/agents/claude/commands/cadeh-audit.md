---
description: Auditoria completa de conformidade LGPD e vulnerabilidades de segurança — sistemática, item por item, com evidências do código
---
# CADEH — Auditoria LGPD + Segurança

Execute uma auditoria sistemática de **conformidade com a LGPD** (Lei 13.709/2018) e **vulnerabilidades de segurança** no código do projeto.

## Instruções gerais

1. Leia o template completo em `docs.cadeh/audit.md` (ou `spec/audit.md` na fonte do harness).
2. Crie uma cópia em `docs/audits/<data>-audit.md` para registrar os resultados.
3. Percorra **cada item** das Partes 1 (LGPD), 2 (Vulnerabilidades) e 3 (Resumo).
4. Para cada item, classifique como: ✅ **Conforme** | ⚠️ **Parcial** | ❌ **Não conforme** | N/A.
5. Inclua **evidências concretas** do código (paths, arquivos, configurações).
6. Para itens ❌ ou ⚠️, sugira correções específicas com paths e código de exemplo.

## Fluxo de trabalho

### Fase 1 — Coleta de evidências

Use **CodeGraph** para mapear a estrutura do projeto. Depois, leia pontualmente:

- Arquivos de configuração (`.env`, `docker-compose.yml`, `package.json`, `next.config.*`, etc.)
- Código de autenticação/autorização (middleware, guards, decorators)
- Models/schemas de banco de dados (identificar dados pessoais armazenados)
- Endpoints de API (identificar rotas que manipulam dados pessoais)
- Arquivos de políticas (privacy policy, termos de uso)
- Configuração de segurança (CSP, CORS, rate limiting, helmet)
- Dependências (`npm audit`, `pip audit`, `cargo audit`)

### Fase 2 — Preenchimento do checklist

Percorra cada tabela do template, preenchendo coluna por coluna:

```
| **1.1.1** Quais dados pessoais são coletados? | ⚠️ Parcial | `models/User.ts`: name, email, cpf; `analytics.ts`: IP e geolocalização |
```

**Regras:**
- Não pule itens. Se for N/A, justifique em uma frase.
- Para ✅, aponte o arquivo/linha que comprova.
- Para ❌, forneça o risco e sugestão de correção.
- Use CodeGraph para encontrar símbolos relevantes, não faça grep cego.

### Fase 3 — Resumo executivo

Preencha as tabelas de consolidação e liste o **Top 5 ações prioritárias** ordenadas por:
1. Risco de sanção LGPD (multa de até 2% do faturamento, máx. R$50M)
2. Risco de incidente de segurança (vazamento, exposição)
3. Facilidade de correção (quick wins primeiro)

### Fase 4 — Relatório final

Salve o relatório em `docs/audits/<YYYY-MM-DD>-audit.md` e apresente:

1. **Total de itens:** conformes / parciais / não conformes
2. **Top 5 ações** com paths e sugestão de código
3. **Riscos críticos** que exigem ação imediata

## Proibido

- Inventar dados pessoais que o projeto não coleta
- Afirmar conformidade sem evidência no código
- Ignorar itens — se não há informação suficiente, marcar como ⚠️ e sugerir investigação
- Fazer mudanças no código durante a auditoria (apenas relatar)
