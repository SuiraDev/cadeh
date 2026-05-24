---
description: Documentar o DNA do projeto — stack, padrões, convenções, arquitetura. Leitura obrigatória para qualquer agente antes de implementar
---
# CADEH — Contexto do Projeto (DNA)

Cria ou atualiza o documento `docs/CONTEXT.md` com o conhecimento estrutural do projeto. Este documento é a **fonte da verdade** sobre padrões, convenções e arquitetura que **todos os agentes** devem seguir.

## Objetivo

Garantir que qualquer agente de IA (Cursor, Claude, Codex, Pi, Antigravity) trabalhe de forma **consistente e precisa**, seguindo exatamente os mesmos padrões do projeto.

## Fluxo de trabalho

### 1. Coleta de informações

Use **CodeGraph** para mapear a estrutura. Depois leia:

- **Config raiz:** `package.json`, `tsconfig.json`, `next.config.*`, `vite.config.*`, `docker-compose.yml`
- **ORM/Schema:** `prisma/schema.prisma`, `drizzle.config.ts`, `schema.rb`
- **Autenticação:** `auth.ts`, `middleware.ts`, providers config
- **Testes:** `vitest.config.ts`, `jest.config.*`, `playwright.config.*`
- **Lint/Format:** `.eslintrc.*`, `.prettierrc.*`
- **CI/CD:** `.github/workflows/`, `.gitlab-ci.yml`
- **Design system:** `tailwind.config.*`, `theme.ts`, tokens
- **Estrutura:** diretórios de `src/` ou `app/`

### 2. Análise de padrões

Identifique **padrões recorrentes** no código:

- Como os arquivos são nomeados? (kebab-case, PascalCase, camelCase)
- Como os componentes são estruturados? (props, exports, estados)
- Como erros são tratados? (try/catch, result types, error boundaries)
- Como a API é organizada? (REST, GraphQL, RPC, Server Actions)
- Como os tipos são definidos? (interfaces, types, Zod, classes)
- Como as dependências são injetadas? (DI container, imports diretos, context)

### 3. Preenchimento do template

Preencha `docs/CONTEXT.md` usando o template `docs.cadeh/context.md`.

**Regras:**
- Preencha **todas** as seções aplicáveis
- Use exemplos reais do código (paths, trechos)
- Para seções que não se aplicam, escreva "N/A" com justificativa
- Seções incertas: marque com `[CONFIRMAR]` para revisão humana
- Substitua placeholders `[ex: ...]` por valores reais

### 4. Atualização do AGENTS.md

Após criar `docs/CONTEXT.md`, **adicione** esta linha ao `AGENTS.md`:

```markdown
## Conhecimento do projeto

Antes de qualquer implementação, leia `docs/CONTEXT.md` — contém stack, padrões, convenções e arquitetura do projeto.
```

### 5. Atualização contínua

Quando stack, padrões ou arquitetura mudarem, execute `/cadeh-context` novamente para atualizar.

## Seções do documento

| Seção | Conteúdo |
|--------|---------|
| 1. Tech Stack | Linguagens, frameworks, banco, infra, deps-chave |
| 2. Estrutura | Árvore de diretórios com propósito de cada pasta |
| 3. Arquitetura | Padrão arquitetural, camadas, fluxo de dados, ADRs |
| 4. Padrões | Nomenclatura, estrutura de arquivos, componentes, erros |
| 5. Auth | Método, sessão, papéis, middleware, helpers |
| 6. Testes | Frameworks, comandos, convenções |
| 7. Git | Branches, commits, PRs, CI |
| 8. API | Contratos, formato de resposta, paginação, erros |
| 9. Design System | Tokens, breakpoints, acessibilidade, formulários |
| 10. Glossário | Termos do domínio, entidades, jargão do negócio |
| 11. Restrições | Regras absolutas que nunca devem ser violadas |
| 12. Scripts | Comandos úteis do dia a dia |

## Proibido

- Inventar tecnologias que não estão no `package.json`
- Assumir padrões sem confirmar no código existente
- Deixar seções com placeholder — ou preenche ou marca N/A
- Ignorar contradições — se o código viola o padrão documentado, anote como `[INCONSISTENTE]`
