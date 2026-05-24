# Audit — LGPD Compliance & Security Vulnerability

> **Papel:** checklist sistemático de auditoria de conformidade (LGPD) e segurança.  
> **Uso:** o agente percorre cada item, analisa o código e reporta status, evidências e recomendações.  
> **Comando:** `/cadeh-audit`

**Projeto:** `[nome]`  
**Data da auditoria:** `[data]`  
**Escopo:** `[módulos/features auditados]`  
**Resultado:** ✅ Conforme | ⚠️ Parcial | ❌ Não conforme | N/A

---

## PARTE 1 — LGPD (Lei 13.709/2018)

### 1.1 Mapeamento de dados pessoais

| Item | Status | Evidência |
|------|--------|-----------|
| **1.1.1** Quais dados pessoais são coletados? (nome, email, CPF, IP, geolocalização, etc.) | | |
| **1.1.2** Onde esses dados são armazenados? (banco, logs, cache, localStorage, cookies) | | |
| **1.1.3** Há coleta de dados sensíveis? (saúde, biometria, religião, política — Art. 5º, II) | | |
| **1.1.4** Há coleta de dados de crianças/adolescentes? (Art. 14) | | |
| **1.1.5** O fluxo de dados está documentado? (entrada → processamento → armazenamento → descarte) | | |

### 1.2 Base legal (Art. 7º)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.2.1** Qual a base legal para cada finalidade de tratamento? (consentimento, obrigação legal, execução de contrato, legítimo interesse, etc.) | | |
| **1.2.2** A base legal está documentada e justificada? | | |
| **1.2.3** Para dados sensíveis, a base legal é consentimento explícito ou hipóteses do Art. 11? | | |

### 1.3 Consentimento (Art. 8º)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.3.1** O consentimento é obtido de forma livre, informada e inequívoca? | | |
| **1.3.2** Há registro de consentimento (timestamp, IP, termo aceito)? | | |
| **1.3.3** O consentimento é granular (finalidades separadas)? | | |
| **1.3.4** O usuário pode revogar o consentimento facilmente? | | |
| **1.3.5** A revogação interrompe o tratamento? | | |

### 1.4 Direitos do titular (Art. 18)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.4.1** Confirmação da existência de tratamento — endpoint/funcionalidade existe? | | |
| **1.4.2** Acesso aos dados — o usuário pode consultar seus dados? | | |
| **1.4.3** Correção de dados incompletos/inexatos — endpoint/funcionalidade existe? | | |
| **1.4.4** Anonimização, bloqueio ou eliminação — implementado? | | |
| **1.4.5** Portabilidade dos dados — formato estruturado e interoperável? | | |
| **1.4.6** Exclusão de dados tratados com consentimento — implementado? | | |
| **1.4.7** Informação sobre compartilhamento com terceiros — disponível? | | |
| **1.4.8** Oposição a tratamento baseado em legítimo interesse — previsto? | | |

### 1.5 Transparência (Art. 9º)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.5.1** Política de Privacidade publicada e acessível? | | |
| **1.5.2** A política descreve: finalidade, duração, compartilhamento, responsável, direitos? | | |
| **1.5.3** Linguagem clara e acessível (não apenas juridiquês)? | | |
| **1.5.4** Avisos de privacidade nos pontos de coleta (formulários, cadastro)? | | |

### 1.6 Minimização e finalidade (Art. 6º, III)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.6.1** Apenas dados estritamente necessários são coletados? (minimização) | | |
| **1.6.2** Os dados são usados apenas para a finalidade informada? (limitação de finalidade) | | |
| **1.6.3** Há reutilização de dados para finalidade diferente sem nova base legal? | | |

### 1.7 Retenção e descarte (Art. 15, 16)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.7.1** Há política de retenção definida (quanto tempo cada dado é mantido)? | | |
| **1.7.2** Dados são descartados/anonymizados ao fim da finalidade ou do prazo legal? | | |
| **1.7.3** O descarte é seguro (não apenas soft-delete)? | | |

### 1.8 Segurança da informação (Art. 46)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.8.1** Dados pessoais são criptografados em trânsito? (TLS ≥ 1.2) | | |
| **1.8.2** Dados pessoais são criptografados em repouso? | | |
| **1.8.3** Controle de acesso: mínimo privilégio, segregação de funções? | | |
| **1.8.4** Logs de acesso a dados pessoais são mantidos? | | |
| **1.8.5** Há política de senhas fortes e/ou MFA? | | |

### 1.9 Transferência internacional (Art. 33)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.9.1** Dados são transferidos para fora do Brasil? | | |
| **1.9.2** Se sim, há salvaguardas adequadas? (cláusulas contratuais, país adequado, certificações) | | |
| **1.9.3** O titular é informado sobre a transferência? | | |

### 1.10 Operadores e terceiros (Art. 39, 42)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.10.1** Lista de terceiros que acessam/processam dados (APIs, provedores cloud, analytics)? | | |
| **1.10.2** Contratos de processamento (DPA) com todos os operadores? | | |
| **1.10.3** Os operadores têm medidas de segurança compatíveis? | | |

### 1.11 Encarregado / DPO (Art. 41)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.11.1** Há um Encarregado de Proteção de Dados nomeado? | | |
| **1.11.2** Canais de contato do DPO publicados e acessíveis? | | |

### 1.12 Relatório de Impacto / DPIA (Art. 38)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.12.1** Foi feito Relatório de Impacto à Proteção de Dados (DPIA)? | | |
| **1.12.2** O DPIA cobre todos os tratamentos de alto risco? | | |

### 1.13 Resposta a incidentes (Art. 48)

| Item | Status | Evidência |
|------|--------|-----------|
| **1.13.1** Há plano de resposta a incidentes de segurança? | | |
| **1.13.2** Há procedimento para comunicar a ANPD e os titulares em caso de incidente? | | |
| **1.13.3** Há prazo definido para notificação (recomendado: imediata, máx. 3 dias úteis)? | | |

---

## PARTE 2 — Vulnerabilidades de Segurança

### 2.1 Autenticação

| Item | Status | Evidência |
|------|--------|-----------|
| **2.1.1** Senhas são armazenadas com hash seguro (bcrypt, argon2)? | | |
| **2.1.2** Há política de força de senha (mín. 8 caracteres, complexidade)? | | |
| **2.1.3** MFA/2FA disponível para usuários (especialmente admins)? | | |
| **2.1.4** Há proteção contra brute force (rate limiting, lockout)? | | |
| **2.1.5** Tokens JWT têm expiração curta e refresh tokens implementados? | | |
| **2.1.6** Recuperação de senha usa tokens únicos e temporários? | | |
| **2.1.7** Sessões podem ser revogadas (logout invalida token)? | | |

### 2.2 Autorização

| Item | Status | Evidência |
|------|--------|-----------|
| **2.2.1** Controle de acesso baseado em papéis (RBAC) implementado? | | |
| **2.2.2** Autorização é verificada em todas as rotas/endpoints? | | |
| **2.2.3** Recursos de um usuário não são acessíveis por outro (IDOR prevention)? | | |
| **2.2.4** Admins podem escalar privilégios inadequadamente? | | |
| **2.2.5** Middleware de autorização é aplicado consistentemente? | | |

### 2.3 Injeção

| Item | Status | Evidência |
|------|--------|-----------|
| **2.3.1** SQL Injection: usa parâmetros preparados ou ORM? (nunca concatenação) | | |
| **2.3.2** NoSQL Injection: validação de input contra operadores ($where, $gt)? | | |
| **2.3.3** Command Injection: input do usuário não é passado para exec()/spawn() diretamente? | | |
| **2.3.4** LDAP/XML/XXE Injection: parsing seguro configurado? | | |

### 2.4 Cross-Site Scripting (XSS)

| Item | Status | Evidência |
|------|--------|-----------|
| **2.4.1** Output encoding: dados do usuário são sanitizados ao renderizar? | | |
| **2.4.2** Content Security Policy (CSP) configurada? | | |
| **2.4.3** HttpOnly e Secure flags em cookies? | | |
| **2.4.4** Frameworks modernos (React, Vue, etc.) com escaping automático? | | |
| **2.4.5** innerHTML/dangerouslySetInnerHTML — uso controlado e sanitizado (DOMPurify)? | | |

### 2.5 CSRF (Cross-Site Request Forgery)

| Item | Status | Evidência |
|------|--------|-----------|
| **2.5.1** Tokens CSRF implementados em formulários e APIs state-changing? | | |
| **2.5.2** SameSite cookies configurados (Strict ou Lax)? | | |
| **2.5.3** Origem das requisições é verificada (Origin/Referer)? | | |

### 2.6 Exposição de dados sensíveis

| Item | Status | Evidência |
|------|--------|-----------|
| **2.6.1** Segredos (API keys, senhas, tokens) NÃO estão no código-fonte ou .env versionado? | | |
| **2.6.2** `.env` e `.env.*` estão no `.gitignore`? | | |
| **2.6.3** Mensagens de erro não expõem stack traces nem dados internos? | | |
| **2.6.4** Headers de segurança configurados? (X-Content-Type-Options, X-Frame-Options, HSTS) | | |
| **2.6.5** Dados sensíveis são mascarados em logs? | | |
| **2.6.6** HTTPS forçado em produção? (redirecionamento 301) | | |

### 2.7 Dependências e supply chain

| Item | Status | Evidência |
|------|--------|-----------|
| **2.7.1** Dependências atualizadas e sem vulnerabilidades conhecidas? (npm audit, pip audit, cargo audit) | | |
| **2.7.2** Dependências são revisadas antes de adicionar? (popularidade, manutenção, licença) | | |
| **2.7.3** Lockfiles versionados (package-lock.json, yarn.lock)? | | |
| **2.7.4** Dependências de build vs runtime separadas? | | |

### 2.8 Configuração e infraestrutura

| Item | Status | Evidência |
|------|--------|-----------|
| **2.8.1** Portas e serviços desnecessários estão fechados? | | |
| **2.8.2** CORS configurado restritivamente (origens específicas, não wildcard)? | | |
| **2.8.3** Rate limiting implementado em endpoints sensíveis (login, API)? | | |
| **2.8.4** Upload de arquivos: validação de tipo, tamanho máximo, sanitização? | | |
| **2.8.5** Diretórios sensíveis não são servidos estaticamente (.git, node_modules)? | | |

### 2.9 Logging e monitoramento

| Item | Status | Evidência |
|------|--------|-----------|
| **2.9.1** Logs de autenticação (login, logout, falha)? | | |
| **2.9.2** Logs de ações administrativas (audit trail)? | | |
| **2.9.3** Logs não contêm dados pessoais ou tokens em texto plano? | | |
| **2.9.4** Sistema de alertas para eventos críticos (múltiplas falhas de login, alterações de privilégio)? | | |
| **2.9.5** Logs são protegidos contra adulteração e acessos não autorizados? | | |

### 2.10 API e comunicação

| Item | Status | Evidência |
|------|--------|-----------|
| **2.10.1** APIs usam autenticação robusta (OAuth 2.0, API Keys com escopo)? | | |
| **2.10.2** API Keys não são expostas no client-side? | | |
| **2.10.3** Rate limiting por IP, token ou usuário? | | |
| **2.10.4** GraphQL: proteção contra queries recursivas e introspection em produção? | | |
| **2.10.5** Webhooks: validação de assinatura HMAC? | | |

---

## PARTE 3 — Resumo executivo

### Conformidade LGPD

| Seção | Conformes | Parciais | Não conformes | N/A |
|-------|-----------|----------|---------------|-----|
| 1.1 Mapeamento | | | | |
| 1.2 Base legal | | | | |
| 1.3 Consentimento | | | | |
| 1.4 Direitos do titular | | | | |
| 1.5 Transparência | | | | |
| 1.6 Minimização | | | | |
| 1.7 Retenção | | | | |
| 1.8 Segurança (LGPD) | | | | |
| 1.9 Transferência intl. | | | | |
| 1.10 Operadores | | | | |
| 1.11 DPO | | | | |
| 1.12 DPIA | | | | |
| 1.13 Incidentes | | | | |

### Vulnerabilidades

| Seção | Conformes | Parciais | Não conformes | N/A |
|-------|-----------|----------|---------------|-----|
| 2.1 Autenticação | | | | |
| 2.2 Autorização | | | | |
| 2.3 Injeção | | | | |
| 2.4 XSS | | | | |
| 2.5 CSRF | | | | |
| 2.6 Dados sensíveis | | | | |
| 2.7 Dependências | | | | |
| 2.8 Configuração | | | | |
| 2.9 Logging | | | | |
| 2.10 API | | | | |

### Top 5 ações prioritárias

1. 
2. 
3. 
4. 
5. 

### Notas do auditor

`[observações, contexto adicional, decisões pendentes]`
