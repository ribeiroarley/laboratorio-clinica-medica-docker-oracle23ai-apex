# Dicionario de Dados - Sistema Clinica Medica

## 1. Visao Geral
Este documento define o dicionario de dados tecnico do schema `CLINICA_MEDICA`, cobrindo as 5 tabelas centrais de operacao clinica e agendamento. As tipagens seguem os padroes nativos do Oracle Database 23ai, incorporando diretrizes de protecao de dados conforme a LGPD.

---

## 2. Tabelas do Sistema

### 2.1. Tabela: ESPECIALIDADES
* **Descricao de Negocio:** Armazena o catalogo das especialidades medicas oferecidas pela clinica.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_ESPECIALIDADE` | NUMBER(10) | PK, NOT NULL | Identificador unico sequencial da especialidade medica. |
| `NOME_ESPECIALIDADE` | VARCHAR2(100) | NOT NULL, UNIQUE | Nome oficial da especialidade (ex: Cardiologia, Pediatria). |
| `DESCRICAO` | VARCHAR2(500) | NULL | Detalhamento sobre os tipos de procedimentos e escopo da especialidade. |
| `STATUS_ATIVO` | VARCHAR2(1) | NOT NULL, CHECK in ('S','N') | Indicador se a especialidade esta ativa para novos agendamentos ('S' ou 'N'). |

---

### 2.2. Tabela: MEDICOS
* **Descricao de Negocio:** Cadastra os profissionais medicos habilitados a realizar atendimentos.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_MEDICO` | NUMBER(10) | PK, NOT NULL | Identificador unico do medico na instituicao. |
| `ID_ESPECIALIDADE` | NUMBER(10) | FK, NOT NULL | Referencia a tabela ESPECIALIDADES (`ID_ESPECIALIDADE`). |
| `NOME_MEDICO` | VARCHAR2(150) | NOT NULL | Nome completo do profissional medico. |
| `CRM` | VARCHAR2(20) | NOT NULL, UNIQUE | Numero do registro profissional no Conselho Regional de Medicina. |
| `UF_CRM` | VARCHAR2(2) | NOT NULL | Unidade Federativa emissora do registro CRM (ex: SP, RJ). |
| `EMAIL` | VARCHAR2(100) | NOT NULL | Endereco de e-mail institucional do profissional. |
| `TELEFONE` | VARCHAR2(20) | NULL | Telefone de contato profissional para comunicados internos. |
| `STATUS_ATIVO` | VARCHAR2(1) | NOT NULL, CHECK in ('S','N') | Status operacional do medico no corpo clinico ('S' ou 'N'). |

---

### 2.3. Tabela: PACIENTES
* **Descricao de Negocio:** Registra os dados cadastrais dos pacientes titulares, contendo atributos essenciais de auditoria e protecao a privacidade (LGPD).
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_PACIENTE` | NUMBER(10) | PK, NOT NULL | Identificador unico do paciente no sistema clinico. |
| `NOME_COMPLETO` | VARCHAR2(150) | NOT NULL | Nome civil completo do paciente. |
| `CPF` | VARCHAR2(14) | NOT NULL, UNIQUE | Cadastro de Pessoa Fisica. Dado Pessoal Identificador marcado para politica de mascaramento dinamico (Oracle Data Redaction). |
| `DATA_NASCIMENTO` | DATE | NOT NULL | Data de nascimento para controle etario e historico clinico. |
| `SEXO_BIOLOGICO` | VARCHAR2(1) | NOT NULL, CHECK in ('M','F','O') | Sexo biologico do paciente para orientacao de dosagens e exames. |
| `EMAIL` | VARCHAR2(100) | NULL | E-mail para contato e envio de notificacoes de agendamento. |
| `TELEFONE` | VARCHAR2(20) | NOT NULL | Telefone principal de contato para envio de lembretes e confirmacao. |
| `TERMO_ACEITE_LGPD` | VARCHAR2(1) | NOT NULL, CHECK in ('Y','N') | Indicador formal de consentimento do titular para tratamento de dados pessoais conforme a LGPD ('Y' ou 'N'). |
| `DATA_CONSENTIMENTO` | TIMESTAMP | NOT NULL | Carimbo temporal auditavel com a data e hora exatas da manifestacao do aceite LGPD. |
| `STATUS_CADASTRO` | VARCHAR2(20) | NOT NULL | Situacao operacional do registro cadastral (ex: ATIVO, INATIVO). |

---

### 2.4. Tabela: AGENDAMENTOS
* **Descricao de Negocio:** Controla a agenda de consultas, associando paciente, medico e horario.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_AGENDAMENTO` | NUMBER(10) | PK, NOT NULL | Identificador unico da marcacao de consulta. |
| `ID_PACIENTE` | NUMBER(10) | FK, NOT NULL | Referencia ao paciente titular agendado (`PACIENTES.ID_PACIENTE`). |
| `ID_MEDICO` | NUMBER(10) | FK, NOT NULL | Referencia ao medico responsavel pela consulta (`MEDICOS.ID_MEDICO`). |
| `DATA_HORA_AGENDAMENTO` | TIMESTAMP | NOT NULL | Data e horario previstos para a realizacao do atendimento clinico. |
| `STATUS_AGENDAMENTO` | VARCHAR2(20) | NOT NULL, CHECK in ('AGENDADO','CONFIRMADO','CANCELADO','CONCLUIDO','NO_SHOW') | Estado atual do agendamento dentro do fluxo da clinica. |
| `MOTIVO_CANCELAMENTO` | VARCHAR2(300) | NULL | Justificativa textual em caso de cancelamento da consulta. |
| `DATA_CRIACAO` | TIMESTAMP | NOT NULL | Registro de auditoria do momento em que a reserva foi inserida no sistema. |

---

### 2.5. Tabela: PRONTUARIOS
* **Descricao de Negocio:** Guarda o historico de atendimento e dados clinicos sensiveis de cada agendamento executado.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_PRONTUARIO` | NUMBER(10) | PK, NOT NULL | Identificador unico do prontuario medico. |
| `ID_AGENDAMENTO` | NUMBER(10) | FK, UNIQUE, NOT NULL | Referencia ao agendamento de origem (`AGENDAMENTOS.ID_AGENDAMENTO`). A constraint UNIQUE assegura a relacao 1:1. |
| `EVOLUCAO_MEDICA` | CLOB | NOT NULL | Anamnese, historico clinico, queixa principal, diagnostico e evolucao do atendimento. Campo textual de grande extensao classificado como Dado Pessoal Sensivel (Art. 5, II da LGPD). |
| `PRESCRICAO` | CLOB | NULL | Detalhamento de medicamentos, posologias e encaminhamentos terapeuticos emitidos durante a consulta. |
| `DATA_ATENDIMENTO` | TIMESTAMP | NOT NULL | Carimbo temporal do encerramento oficial do atendimento medico. |
| `STATUS_PRONTUARIO` | VARCHAR2(20) | NOT NULL, CHECK in ('FINALIZADO','RETIFICADO') | Estado de conclusao e imutabilidade juridica do prontuario clinico. |
