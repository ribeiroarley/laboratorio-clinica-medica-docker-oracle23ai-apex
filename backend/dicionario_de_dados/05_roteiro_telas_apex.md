# Roteiro Completo de Geração de Telas (Oracle APEX)
**Aplicação:** SmartDB Clínica Médica | **Workspace:** WS_CLINICA_MEDICA | **Schema:** CLINICA_MEDICA

## Padrão de Criação de Páginas (Passo a Passo)
Para cada tabela do escopo, repita exatamente o fluxo abaixo:

### Tela 1: Component
1. No painel da aplicação, clique em **Create Page**.
2. Clique no ícone **Interactive Report**.

### Tela 2: Page Definition & Data Source
1. **Page Number:** Deixe o número que o APEX sugerir (ex: 3).
2. **Name:** Digite o nome do Relatório (veja a lista abaixo).
3. **Include Form Page:** Ative esta chave.
4. **Form Page Number:** Deixe o número sugerido, mas **GARANTA QUE SEJA DIFERENTE DO PAGE NUMBER** (ex: se a página for 3, o form deve ser 4).
5. **Form Page Name:** Digite o nome do Cadastro (veja a lista abaixo).
6. **Form Page Mode:** Selecione **Modal Dialog**.
7. **Table / View Owner:** `CLINICA_MEDICA`.
8. **Table / View Name:** Selecione a tabela exata do módulo.
9. **Navigation:** Ative "Use Navigation" e em Preference escolha "Create a new entry".
10. Clique em **Next**.

### Tela 3: Primary Key
Como nosso banco de dados tem a modelagem física correta, o APEX detectará a Primary Key (PK) automaticamente.
1. **Primary Key Type:** Selecione `Select Primary Key Column(s)`.
2. **Primary Key Column 1:** O APEX já trará a coluna correta selecionada (ex: `ID_ESPECIALIDADE`, `ID_PACIENTE`). Apenas confirme.
3. Clique em **Create Page**.
4. Ao abrir o Page Designer, clique no botão de "Play" (Save and Run Page) no canto superior direito.

---

## Mapeamento de Tabelas para Páginas

### 1. Módulo de Cadastros Base
* **Tabela:** `ESPECIALIDADES`
  * Relatório (Name): Especialidades Médicas
  * Formulário (Form Page Name): Cadastro de Especialidade
* **Tabela:** `PERFIS_ACESSO`
  * Relatório (Name): Perfis de Acesso
  * Formulário (Form Page Name): Cadastro de Perfil

### 2. Módulo de Pessoas
* **Tabela:** `PACIENTES`
  * Relatório (Name): Pacientes
  * Formulário (Form Page Name): Cadastro de Paciente
* **Tabela:** `MEDICOS`
  * Relatório (Name): Médicos
  * Formulário (Form Page Name): Cadastro de Médico
* **Tabela:** `FUNCIONARIOS`
  * Relatório (Name): Funcionários
  * Formulário (Form Page Name): Cadastro de Funcionário

### 3. Módulo de Atendimento
* **Tabela:** `AGENDAMENTOS`
  * Relatório (Name): Agendamentos
  * Formulário (Form Page Name): Novo Agendamento
* **Tabela:** `PRONTUARIOS`
  * Relatório (Name): Prontuários Eletrônicos
  * Formulário (Form Page Name): Registro de Prontuário

### 4. Módulo Back-Office
* **Tabela:** `FORNECEDORES`
  * Relatório (Name): Fornecedores
  * Formulário (Form Page Name): Cadastro de Fornecedor
* **Tabela:** `FATURAMENTO`
  * Relatório (Name): Faturamento
  * Formulário (Form Page Name): Registro de Faturamento
* **Tabela:** `CONTAS_RECEBER`
  * Relatório (Name): Contas a Receber
  * Formulário (Form Page Name): Lançamento de Receita
* **Tabela:** `CONTAS_PAGAR`
  * Relatório (Name): Contas a Pagar
  * Formulário (Form Page Name): Lançamento de Despesa

### 5. Módulo de Segurança e Auditoria
* **Tabela:** `USUARIOS_SISTEMA`
  * Relatório (Name): Usuários do Sistema
  * Formulário (Form Page Name): Cadastro de Usuário
* **Tabela:** `AUDITORIA_LGPD`
  * Relatório (Name): Relatório de Auditoria LGPD
  * **Atenção:** Para esta tabela, NÃO ative a chave "Include Form Page". Crie apenas o relatório.

### 6. Módulo de Relatórios Gerenciais (Views)
* **View:** `VW_AGENDA_MEDICA_COMPLETA` (no banco: `VW_AGENDA_MEDICA`)
  * Relatório (Name): Agenda Médica Consolidada
  * Formulário: **NÃO INCLUIR**
  * *Nota de criação:* Crie apenas como "Interactive Report" e deixe a chave "Include Form Page" DESATIVADA.
* **View:** `VW_DASHBOARD_FINANCEIRO`
  * Relatório (Name): Resumo de Faturamento
  * Formulário: **NÃO INCLUIR**
  * *Nota de criação:* Crie apenas como "Interactive Report" e deixe a chave "Include Form Page" DESATIVADA.
