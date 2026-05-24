# CADEH — Controlled AI Development Environment Harness

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

**CADEH** é um CLI e conjunto de artefatos para desenvolvimento assistido por IA com baixo risco de alucinação, escopo claro e rastreabilidade de decisões. Funciona com **Cursor, Claude Code, OpenAI Codex, Antigravity e Pi Agent**.

```bash
npx ai-suiradev-cadeh init               # instala no projeto (seleção interativa do agente)
npx ai-suiradev-cadeh init --agent pi    # ou direto: cursor | claude | codex | antigravity | pi
```

---

## O que é o CADEH

O CADEH resolve o problema de agentes de IA que alucinam código, inventam APIs e tomam decisões frágeis. Ele fornece:

- **Workflow spec-driven** — SDD → Plano → Tasks → Implementar → Validar, com orquestração por fase
- **Cérebro integrado** — 5 camadas de memória que persistem entre chats (Conhecimento, Código, Fluxo, Spec, Narrativa)
- **Multi-agente** — mesmo conjunto de regras e artefatos, adaptado para cada agente (Cursor, Claude Code, Codex, Antigravity, Pi)
- **Anti-alucinação** — classificação obrigatória de contexto (confirmado, inferido, suposição, desconhecido)
- **CodeGraph** — grafo de código com MCP para navegação precisa de símbolos e impacto
- **Auditoria** — 70+ itens de LGPD + OWASP com evidências do código
- **Contexto de projeto** — documentação automática do DNA do projeto (stack, padrões, arquitetura)

---

## Instalação

### Requisitos

- **Node.js 18+** (para `npx` e CodeGraph)
- **Bash** (Linux, macOS, WSL)

### Opção A — npx (recomendado)

```bash
cd /caminho/do/seu-app
npx ai-suiradev-cadeh init
```

O CLI pergunta qual agente você usa (1-5). Depois instala tudo automaticamente.

```bash
# Primeira feature
npx ai-suiradev-cadeh new feature minha-feature
```

### Opção B — clone + setup

```bash
git clone https://github.com/SuiraDev/cadeh.git
cd cadeh
./bin/cadeh setup
```

Adicione ao `~/.bashrc` ou `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Confirme:

```bash
cadeh version   # → cadeh 1.7.0
cadeh init      # instala no projeto atual
```

---

## Uso rápido

```bash
# Iniciar em um projeto (seleciona o agente)
cadeh init

# Ou direto com o agente desejado
cadeh init --agent pi        # Pi Agent
cadeh init --agent cursor    # Cursor IDE
cadeh init --agent claude    # Claude Code

# Criar uma feature
cadeh new feature login-social

# Ver estado atual
cadeh continue

# Trocar de agente a qualquer momento (preserva tudo)
cadeh switch --agent pi

# Diagnóstico
cadeh doctor

# Memória de código
cadeh codegraph install
```

---

## Agentes suportados

| Agente | Regras | Comandos/Prompts | Regra global |
|--------|--------|-----------------|-------------|
| **Cursor** | `.cursor/rules/*.mdc` | `.cursor/commands/` | `~/.cursor/rules/cadeh.mdc` |
| **Claude Code** | `CLAUDE.md` | `.claude/commands/` | `~/.claude/CLAUDE.md` |
| **Codex** | `AGENTS.md` + `.codex/rules/` | — | `~/.codex/AGENTS.md` |
| **Antigravity** | `AGENTS.md` + `.github/copilot-instructions.md` | — | `~/AGENTS.md` |
| **Pi Agent** | `AGENTS.md` + `.pi/APPEND_SYSTEM.md` | `.pi/prompts/` | `~/.pi/agent/AGENTS.md` |

Todos os agentes leem `AGENTS.md` na raiz do projeto — o denominador comum universal.

### Trocar de agente

```bash
cadeh switch              # menu interativo (mostra o atual)
cadeh switch --agent pi   # troca direta
```

Preserva docs, estado, memória e índice CodeGraph. Remove arquivos do agente anterior, instala os do novo.

---

## Comandos do agente

No chat do seu agente, use os comandos `/cadeh-*` para orquestrar o fluxo:

| Comando | O que faz |
|---------|----------|
| `/cadeh-context` | Documenta o DNA do projeto (stack, padrões, arquitetura) |
| `/cadeh-continue` | Reconstrói contexto entre chats (cérebro integrado) |
| `/cadeh-spec` | Especifica feature — SDD em modo entrevista |
| `/cadeh-plan` | Deriva plano de implementação |
| `/cadeh-tasks` | Quebra plano em tarefas T-xx atômicas |
| `/cadeh-implement` | Implementa uma T-xx (menor diff, commit atômico) |
| `/cadeh-memory` | Salva contexto ao encerrar sessão |
| `/cadeh-workflow` | Mapa completo do fluxo |
| `/cadeh-audit` | Auditoria LGPD + segurança (70+ itens) |

### Fluxo de trabalho

```
/cadeh-context → /cadeh-continue → /cadeh-spec → /cadeh-plan → /cadeh-tasks → /cadeh-implement → /cadeh-memory
                                                                                        ↓
                                                                                  /cadeh-audit
```

---

## Cérebro integrado (5 camadas)

| Camada | Onde | Pergunta |
|--------|------|----------|
| **Conhecimento** | `docs/CONTEXT.md` | Qual stack, padrões, arquitetura? |
| **Código** | `.codegraph/` + MCP | Onde está? Quem chama? Impacto? |
| **Fluxo** | `.cadeh/state.yml` | Em qual feature/fase/T-xx estamos? |
| **Spec** | `docs/sdd/`, `docs/plans/`, `docs/tasks/` | O quê / como / checklist? |
| **Narrativa** | `docs/memory/<feature>.md` | Que decisões foram tomadas? |

**Novo chat:** leia `.cadeh/state.yml` → docs da feature → CodeGraph → `docs/CONTEXT.md` → `docs/memory/`  
**Fim de sessão:** atualize `state.yml` e faça append em `docs/memory/`

---

## Hierarquia de verdade

Em caso de conflito, a ordem de precedência é:

1. Requisito explícito do usuário na conversa atual
2. SDD da feature (`docs/sdd/`)
3. Código existente (CodeGraph + leitura pontual)
4. Implementation Plan (`docs/plans/`)
5. CADEH / Persona (processo e qualidade)
6. Recomendações da IA (sempre rotuladas como hipótese)

---

## O que o projeto recebe

```
seu-projeto/
├── AGENTS.md                       # Universal — todo agente lê
├── .cadeh/
│   └── state.yml                   # Estado do fluxo (feature, fase, T-xx)
├── docs/
│   ├── CONTEXT.md                  # DNA do projeto (gerado pelo /cadeh-context)
│   ├── sdd/                        # Templates + suas specs
│   ├── plans/                      # Templates + seus planos
│   ├── tasks/                      # Templates + suas tasks
│   ├── memory/                     # Memória narrativa por feature
│   └── cadeh/                      # Contrato, workflow, auditoria, referências
└── [arquivos do agente escolhido]  # .cursor/ | .pi/ | .claude/ | .codex/ | .github/
```

---

## CLI completo

| Comando | Descrição |
|---------|-----------|
| `cadeh init [path]` | Inicia CADEH + CodeGraph no projeto |
| `cadeh install [path]` | Scaffold no projeto |
| `cadeh uninstall [path]` | Remove scaffold |
| `cadeh switch [path]` | Troca de agente (cursor↔pi↔claude↔codex↔antigravity) |
| `cadeh global` | Instala regra global |
| `cadeh update [path]` | Atualiza arquivos do CADEH |
| `cadeh agents` | Lista agentes suportados |
| `cadeh new feature <nome>` | SDD + plano + tasks + branch + memória |
| `cadeh new sdd <nome>` | Cria `docs/sdd/<nome>.md` |
| `cadeh new plan <nome>` | Cria `docs/plans/<nome>.md` |
| `cadeh new tasks <nome>` | Cria `docs/tasks/<nome>.md` |
| `cadeh continue` | Resumo do fluxo atual |
| `cadeh doctor` | Diagnóstico detalhado |
| `cadeh status` | Resumo da instalação |
| `cadeh list` | Lista SDDs, planos e tasks |
| `cadeh path` | Caminhos do CLI e regras globais |
| `cadeh codegraph install` | CodeGraph MCP + index |
| `cadeh codegraph status` | Estatísticas do índice |
| `cadeh tlc install` | Skill tlc-spec-driven |
| `cadeh git status` | git status |
| `cadeh git branch <nome>` | Cria e faz checkout |
| `cadeh git commit -m "msg"` | Commit com mensagem |
| `cadeh git diff/log/add/stash` | Demais wrappers Git |
| `cadeh setup` | Instala symlink em `~/.local/bin` |
| `cadeh version` | Versão do CLI |
| `cadeh help` | Ajuda geral |

Opções comuns: `--agent <nome>` | `-f` | `--purge` | `--codegraph` | `--skip-codegraph` | `--skip-tlc`

---

## CodeGraph — memória de código

O CodeGraph cria um grafo local (`.codegraph/`) com todos os símbolos do projeto. O agente usa MCP para navegar sem grep cego.

```bash
cadeh codegraph install    # configura MCP + indexa
cadeh codegraph status     # estatísticas do índice
```

**MCP por agente:**

| Agente | Setup |
|--------|-------|
| Cursor | `.cursor/mcp.json` — automático |
| Claude Code | `.claude/mcp.json` — automático |
| Codex | `.codex/config.toml` — automático |
| Pi Agent | `.mcp.json` — detectado pelo `pi-mcp-adapter` |
| Antigravity | `.cursor/mcp.json` — automático |

---

## Auditoria LGPD + Segurança

```bash
# No agente:
/cadeh-audit
```

70+ itens cobrindo:
- **LGPD** — 13 seções (Art. 6º ao 48º): mapeamento, consentimento, direitos do titular, segurança, DPO, DPIA
- **OWASP** — 10 seções: autenticação, autorização, injeção, XSS, CSRF, dependências, logging
- Relatório salvo em `docs/audits/<data>-audit.md`
- Top 5 ações prioritárias com paths e sugestões de código

---

## Estrutura do repositório

```
cadeh/
├── bin/cadeh              # CLI Bash
├── bin/cadeh.js           # Entry point npm
├── lib/                   # Biblioteca (install, git, state, codegraph, etc.)
├── spec/                  # Fontes canônicas Markdown
├── templates/             # Scaffold copiado para projetos
│   ├── AGENTS.md          # Universal
│   ├── agents/            # Adapters por agente
│   └── docs/              # Templates de documentação
└── scripts/test-all.sh    # Testes do CLI
```

Mais detalhes: [STRUCTURE.md](./STRUCTURE.md)

---

## Licença

[MIT](./LICENSE) — uso, cópia, modificação e distribuição livres.
