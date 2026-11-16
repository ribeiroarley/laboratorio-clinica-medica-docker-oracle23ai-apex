# Dicionario de Dados - Modulo de Back-Office (Financeiro e Recursos Humanos)

## 1. Visao Geral
Este documento define os metadados das 5 tabelas integrantes do modulo de Back-Office da Clinica Medica. A estrutura abrange a gestao de colaboradores (RH), parceiros comerciais (Fornecedores) e o controle financeiro (Faturamento, Contas a Pagar e Contas a Receber).

---

## 2. Especificacao das Tabelas

### 2.1. Tabela: FUNCIONARIOS
* **Descricao de Negocio:** Registra o quadro de colaboradores da clinica, integrando dados cadastrais, cargo, remuneracao e vinculo de acesso ao sistema.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_FUNCIONARIO` | NUMBER(10) | PK, NOT NULL | Identificador unico do funcionario na instituicao (Identity). |
| `ID_USUARIO` | NUMBER(10) | FK, UNIQUE, NOT NULL | Vinculo direto com a conta de login (`USUARIOS_SISTEMA.ID_USUARIO`). A constraint UNIQUE garante a relacao 1:1. |
| `NOME` | VARCHAR2(150) | NOT NULL | Nome completo do colaborador. |
| `CPF` | VARCHAR2(14) | NOT NULL, UNIQUE | Cadastro de Pessoa Fisica. Dado Pessoal Identificador sob protecao da LGPD e sujeito a Oracle Data Redaction. |
| `CARGO` | VARCHAR2(80) | NOT NULL | Funcao ou cargo exercido pelo colaborador (ex: Atendente, Recepcionista, Gerente Administrativo). |
| `SALARIO` | NUMBER(12,2) | NOT NULL | Remuneracao salarial contratual. Dado confidencial com visualizacao restrita ao perfil ADMIN via Data Redaction. |
| `DATA_CONTRATACAO` | DATE | NOT NULL | Data de admissao oficial do colaborador na instituicao. |

---

### 2.2. Tabela: FORNECEDORES
* **Descricao de Negocio:** Cadastra prestadores de servicos, distribuidoras de medicamentos, locadoras e fornecedores de insumos hospitalares.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_FORNECEDOR` | NUMBER(10) | PK, NOT NULL | Identificador unico da empresa fornecedora (Identity). |
| `RAZAO_SOCIAL` | VARCHAR2(150) | NOT NULL | Razao social ou denominacao comercial do fornecedor. |
| `CNPJ` | VARCHAR2(18) | NOT NULL, UNIQUE | Cadastro Nacional da Pessoa Juridica do parceiro comercial. |
| `TIPO_SERVICO` | VARCHAR2(100) | NOT NULL | Categoria do servico prestado ou produto fornecido (ex: 'Equipamentos Medicos', 'Limpeza e Sanitizacao', 'Locacao de Imovel'). |

---

### 2.3. Tabela: FATURAMENTO
* **Descricao de Negocio:** Consolida o fechamento financeiro de consultas e procedimentos medicos agendados.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_FATURAMENTO` | NUMBER(10) | PK, NOT NULL | Identificador unico da cobranca emitida (Identity). |
| `ID_AGENDAMENTO` | NUMBER(10) | FK, UNIQUE, NOT NULL | Vinculo direto com a consulta realizada (`AGENDAMENTOS.ID_AGENDAMENTO`). A constraint UNIQUE garante a relacao 1:1. |
| `VALOR_TOTAL` | NUMBER(12,2) | NOT NULL | Valor bruto total faturado pelo atendimento. |
| `METODO_PAGAMENTO` | VARCHAR2(50) | NOT NULL | Forma pactuada de pagamento (ex: 'DINHEIRO', 'PIX', 'CARTAO_CREDITO', 'CONVENIO_SAUDE'). |
| `STATUS` | VARCHAR2(20) | NOT NULL, CHECK in ('PENDENTE','FATURADO','CANCELADO') | Situacao atual do processamento da fatura no sistema. |

---

### 2.4. Tabela: CONTAS_PAGAR
* **Descricao de Negocio:** Gerencia os titulos, boletos e obrigacoes financeiras assumidas pela clinica junto a fornecedores e prestadores.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_CONTA_PAGAR` | NUMBER(10) | PK, NOT NULL | Identificador unico do lancamento a pagar (Identity). |
| `ID_FORNECEDOR` | NUMBER(10) | FK, NOT NULL | Referencia ao credor do titulo (`FORNECEDORES.ID_FORNECEDOR`). |
| `VALOR` | NUMBER(12,2) | NOT NULL | Valor monetario devido do compromisso financeiro. |
| `DATA_VENCIMENTO` | DATE | NOT NULL | Data limite para quitacao do titulo sem cobranca de encargos. |
| `STATUS_PAGAMENTO` | VARCHAR2(20) | NOT NULL, CHECK in ('ABERTO','PAGO','VENCIDO','CANCELADO') | Estado operacional da obrigacao financeira. |

---

### 2.5. Tabela: CONTAS_RECEBER
* **Descricao de Negocio:** Controla o cronograma e fluxo de recebimento de valores decorrentes das faturas de consultas, cobradas de particulares ou repassadas por convenios.
* **Tablespace:** `TS_CLINICA_APP`

| Nome da Coluna | Tipo de Dado | Constraints | Descricao de Negocio |
| :--- | :--- | :--- | :--- |
| `ID_CONTA_RECEBER` | NUMBER(10) | PK, NOT NULL | Identificador unico do titulo a receber (Identity). |
| `ID_FATURAMENTO` | NUMBER(10) | FK, NOT NULL | Referencia a fatura geradora do recebivel (`FATURAMENTO.ID_FATURAMENTO`). |
| `VALOR` | NUMBER(12,2) | NOT NULL | Valor monetario atribuido a parcela ou repasse. |
| `DATA_VENCIMENTO` | DATE | NOT NULL | Data limite estipulada para a entrada dos recursos em caixa. |
| `STATUS_RECEBIMENTO` | VARCHAR2(20) | NOT NULL, CHECK in ('PENDENTE','RECEBIDO','VENCIDO','GLOSADO','CANCELADO') | Situacao da liquidacao do titulo financeiro. |
