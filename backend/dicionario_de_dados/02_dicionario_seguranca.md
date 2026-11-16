# Dicionario de Dados - Modulo de Seguranca, RBAC e Auditoria LGPD

## 1. Visao Geral
Este documento especifica os metadados das tabelas de infraestrutura de seguranca da informacao, responsaveis pelo Controle de Acesso Baseado em Papeis (RBAC), autenticacao de operadores e rastreabilidade auditavel em conformidade com a LGPD.

---

## 2. Especificacao das Tabelas

### 2.1. Tabela: PERFIS_ACESSO
* **Descricao de Negocio:** Armazena os papeis institucionais (roles) que definem os privilegios e politicas de autorizacao no Oracle APEX e no banco de dados.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_PERFIL` | NUMBER(10) | PK, NOT NULL | Identificador unico do perfil de acesso (gerado por Identity). |
| `NOME_PERFIL` | VARCHAR2(50) | NOT NULL, UNIQUE | Nome padronizado do perfil no sistema (ex: 'ADMIN', 'FUNCIONARIO'). |
| `DESCRICAO` | VARCHAR2(250) | NOT NULL | Detalhamento sobre o escopo operacional e permissoes atribuidas ao perfil. |

---

### 2.2. Tabela: USUARIOS_SISTEMA
* **Descricao de Negocio:** Cadastra as contas de acesso dos colaboradores autorizados a operar a aplicacao da clinica.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_USUARIO` | NUMBER(10) | PK, NOT NULL | Identificador unico do usuario no sistema. |
| `LOGIN` | VARCHAR2(50) | NOT NULL, UNIQUE | Credencial unica de identificacao do operador no login. |
| `SENHA_HASH` | VARCHAR2(256) | NOT NULL | Resumo criptografico unidirecional (hash) da senha do operador. |
| `ID_PERFIL` | NUMBER(10) | FK, NOT NULL | Referencia ao perfil de acesso associado (`PERFIS_ACESSO.ID_PERFIL`). |
| `DATA_CRIACAO` | TIMESTAMP | NOT NULL | Data e hora em que a conta foi criada no banco de dados. |
| `STATUS_ATIVO` | VARCHAR2(1) | NOT NULL, CHECK in ('S','N') | Flag que define se o usuario esta ativo para autenticacao ('S' ou 'N'). |

---

### 2.3. Tabela: AUDITORIA_LGPD
* **Descricao de Negocio:** Registra trilhas imutaveis de auditoria relativas ao tratamento, insercao, alteracao ou consulta de dados cadastrais e clinicos sensiveis.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_LOG` | NUMBER(19) | PK, NOT NULL | Identificador sequencial unico do registro de auditoria (Identity). |
| `NOME_TABELA` | VARCHAR2(50) | NOT NULL | Nome da entidade alvo da operacao auditada (ex: 'PACIENTES', 'PRONTUARIOS'). |
| `ACAO` | VARCHAR2(20) | NOT NULL, CHECK in ('INSERT','UPDATE','DELETE','SELECT_SENSIVEL') | Tipo de acao realizada sobre os dados sob governanca LGPD. |
| `USUARIO_BANCO` | VARCHAR2(128) | NOT NULL | Usuario de sessao do Oracle Database (`SESSION_USER`). |
| `USUARIO_APEX` | VARCHAR2(100) | NULL | Identificador do usuario autenticado na camada APEX (`:APP_USER`). |
| `DATA_ACAO` | TIMESTAMP | NOT NULL | Carimbo de data e hora de alta precisao (`SYSTIMESTAMP`) em que a acao ocorreu. |
