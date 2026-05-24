# Project Context — DNA do Projeto

> **Papel:** conhecimento estrutural do projeto — stack, padrões, convenções, arquitetura.  
> **Uso:** leitura obrigatória para qualquer agente antes de implementar.  
> **Manutenção:** atualizar quando stack, padrões ou arquitetura mudarem.  
> **Comando:** `/cadeh-context` (cria/atualiza este documento)

**Projeto:** `[nome]`  
**Última atualização:** `[data]`  
**Versão do documento:** `1.0`

---

## 1. Tech Stack

### Linguagens & Runtimes

| Tecnologia | Versão | Uso |
|-----------|--------|-----|
| `[ex: TypeScript]` | `[5.x]` | Linguagem principal |
| `[ex: Node.js]` | `[20 LTS]` | Runtime |
| | | |

### Frameworks

| Framework | Versão | Responsabilidade |
|-----------|--------|-----------------|
| `[ex: Next.js]` | `[14 App Router]` | Frontend + API |
| `[ex: Fastify]` | `[4.x]` | Backend HTTP |
| | | |

### Banco de dados & ORM

| Tecnologia | Versão | Notas |
|-----------|--------|-------|
| `[ex: PostgreSQL]` | `[16]` | Banco principal |
| `[ex: Prisma]` | `[5.x]` | ORM + migrations |
| | | |

### Infra & Deploy

| Ferramenta | Uso |
|-----------|-----|
| `[ex: Docker Compose]` | Ambiente local |
| `[ex: Vercel]` | Deploy frontend |
| | |

### Dependências-chave

| Pacote | Propósito |
|--------|----------|
| `[ex: zod]` | Validação de schemas |
| `[ex: next-auth]` | Autenticação |
| | |

---

## 2. Estrutura de diretórios

```
[preencher com a árvore real do projeto, destacando módulos]
src/
├── app/            # [ex: Next.js App Router — páginas e API routes]
│   ├── api/        # [ex: Route handlers]
│   └── (routes)/   # [ex: Páginas]
├── components/     # [ex: Componentes React compartilhados]
│   ├── ui/         # [ex: shadcn/ui — design system]
│   └── features/   # [ex: Componentes específicos de features]
├── lib/            # [ex: Utilitários, config, clients]
├── hooks/          # [ex: Custom hooks React]
├── services/       # [ex: Lógica de negócio, Server Actions]
├── db/             # [ex: Schema Prisma, migrations, seeds]
└── types/          # [ex: Tipos TypeScript globais]
```

---

## 3. Arquitetura

### Padrão arquitetural

`[ex: Feature-first com Server Components + Server Actions. Cada feature tem sua própria pasta com componentes, actions e tipos colocalizados.]`

### Camadas

| Camada | Onde | Responsabilidade |
|--------|------|-----------------|
| **UI** | `components/`, `app/` | Renderização, interação |
| **API** | `app/api/` | Endpoints REST |
| **Serviço** | `services/`, `lib/` | Lógica de negócio |
| **Dados** | `db/`, Prisma | Persistência, queries |
| **Tipos** | `types/`, `*.d.ts` | Contratos TypeScript |

### Fluxo de dados típico

```
UI (client component) → Server Action → Service → Prisma → DB
UI (server component) → query direta → Prisma → DB
API route → Service → Prisma → DB → JSON response
```

### Decisões arquiteturais (ADR)

| Decisão | Motivo | Data |
|---------|--------|------|
| `[ex: Server Actions em vez de API routes para mutations]` | `[menos boilerplate, typesafe]` | |
| `[ex: Zod para validação em todas as camadas]` | `[contrato único shared]` | |
| | | |

---

## 4. Padrões de código

### Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|----------|---------|
| Arquivos | `[kebab-case.ts]` | `user-service.ts` |
| Componentes | `[PascalCase.tsx]` | `UserProfile.tsx` |
| Funções | `[camelCase]` | `getUserById()` |
| Tipos/Interfaces | `[PascalCase, prefixo I opcional]` | `User`, `CreateUserInput` |
| Constantes | `[UPPER_SNAKE_CASE]` | `MAX_RETRY_COUNT` |
| Branches Git | `[feature/<slug>]` | `feature/user-auth` |
| Commits | `[conventional commits]` | `feat(auth): add login flow` |

### Estrutura de arquivos

```
[descrever o padrão de organização interna]
feature/
├── components/       # Componentes React da feature
├── actions.ts        # Server Actions
├── schema.ts         # Schemas Zod (validação + tipos)
├── queries.ts        # Queries (server-only)
└── types.ts          # Tipos específicos da feature
```

### Padrões de componente

- `[ex: Server Components por padrão; Client Components só quando necessário]`
- `[ex: Props interface exportada junto ao componente]`
- `[ex: Estados: loading, error, empty, success — sempre tratados]`

### Tratamento de erros

```
[descrever o padrão]
- Erros esperados: retorno tipado (result type)
- Erros inesperados: throw + error boundary
- API: status HTTP + corpo { error: string, code: string }
- Validação: Zod na borda (entrada do usuário)
```

---

## 5. Autenticação & Autorização

| Aspecto | Implementação |
|---------|--------------|
| **Método** | `[ex: next-auth v5 com credenciais + OAuth (Google, GitHub)]` |
| **Sessão** | `[ex: JWT em cookie httpOnly]` |
| **Papéis** | `[ex: USER, ADMIN, MODERATOR]` |
| **Middleware** | `[ex: middleware.ts — proteção de rotas]` |
| **Helpers** | `[ex: getCurrentUser(), requireAdmin() em services/]` |

---

## 6. Testes

| Tipo | Framework | Localização | Comando |
|------|----------|------------|---------|
| Unit | `[ex: Vitest]` | `[ex: *.test.ts colocalizado]` | `npm test` |
| Integration | `[ex: Vitest + testcontainers]` | `__tests__/` | `npm run test:integration` |
| E2E | `[ex: Playwright]` | `e2e/` | `npm run test:e2e` |
| Type check | `tsc --noEmit` | — | `npm run typecheck` |
| Lint | `[ex: ESLint + Prettier]` | — | `npm run lint` |

### Convenções de teste

- `[ex: AAA pattern: Arrange, Act, Assert]`
- `[ex: Mock apenas I/O externo; lógica de negócio testada sem mock]`
- `[ex: Cada RF do SDD tem pelo menos um teste]`

---

## 7. Git workflow

| Aspecto | Convenção |
|---------|----------|
| **Branch default** | `[main]` |
| **Feature branch** | `feature/<slug>` |
| **Commit** | `[conventional commits: feat, fix, refactor, docs, test, chore]` |
| **PR** | `[title = conventional commit, body = descrição + screenshots]` |
| **Merge** | `[squash merge]` |
| **CI** | `[GitHub Actions: lint → typecheck → test → build]` |

---

## 8. API & Contratos

### Padrão de API

| Rota | Método | Autenticação | Descrição |
|------|--------|-------------|-----------|
| `/api/[resource]` | GET | `[pública]` | Listar |
| `/api/[resource]` | POST | `[auth]` | Criar |
| `/api/[resource]/[id]` | GET | `[pública]` | Detalhe |
| `/api/[resource]/[id]` | PATCH | `[auth + owner]` | Atualizar |
| `/api/[resource]/[id]` | DELETE | `[admin]` | Remover |
| | | | |

### Formato de resposta

```json
// Sucesso
{ "data": { ... } }

// Lista paginada
{ "data": [...], "total": 100, "page": 1, "pageSize": 20 }

// Erro
{ "error": "Mensagem amigável", "code": "RESOURCE_NOT_FOUND" }
```

---

## 9. Design System & UI

| Aspecto | Implementação |
|---------|--------------|
| **Framework** | `[ex: Tailwind CSS + shadcn/ui]` |
| **Tokens** | `[ex: tailwind.config.ts — cores, spacing, typography]` |
| **Ícones** | `[ex: lucide-react]` |
| **Modo escuro** | `[ex: next-themes — class strategy]` |
| **Responsivo** | `[ex: mobile-first, breakpoints: sm(640) md(768) lg(1024) xl(1280)]` |
| **Acessibilidade** | `[ex: WCAG 2.1 AA — roles, labels, focus, contraste]` |
| **Formulários** | `[ex: react-hook-form + zod resolver]` |

---

## 10. Glossário do domínio

| Termo | Significado | Contexto |
|-------|------------|----------|
| `[Termo 1]` | `[Definição no contexto do negócio]` | `[ex: entidade User]` |
| `[Termo 2]` | `[Definição]` | |
| | | |

---

## 11. Restrições e regras

- `[ex: Nunca usar any — sempre tipar explicitamente]`
- `[ex: Não importar de 'react' em Server Components]`
- `[ex: Senhas: bcrypt/argon2, nunca plain text]`
- `[ex: API keys e secrets: variáveis de ambiente, nunca no código]`
- `[ex: Images: next/image, nunca <img>]`
- `[ex: Rotas: usar Link do next/navigation, nunca <a href>]`
- 

---

## 12. Scripts úteis

| Comando | Descrição |
|---------|----------|
| `npm run dev` | Inicia ambiente de desenvolvimento |
| `npm run build` | Build de produção |
| `npm run lint` | ESLint + Prettier check |
| `npm run typecheck` | Verificação de tipos |
| `npm test` | Testes unitários |
| `npm run db:migrate` | Roda migrations Prisma |
| `npm run db:studio` | Abre Prisma Studio |
| | |
