# Roteiro de Configuração de Segurança (RBAC) - APEX
**Objetivo:** Substituir a autenticação padrão pelas tabelas `USUARIOS_SISTEMA` e `PERFIS_ACESSO`, isolando a visão da Recepcionista, Médico e Administrador.

## Passo 1: Autenticação Customizada (Login)
1. Acesse o App Builder e clique em **Shared Components**.
2. Em *Security*, clique em **Authentication Schemes**.
3. Clique em **Create** > *Based on a pre-configured scheme from the gallery* > **Next**.
4. Configure:
   - **Name:** Autenticacao_SmartDB
   - **Scheme Type:** Custom
   - **Authentication Function Name:** `brio.pkg_gestao_atendimento.valida_login`
5. Clique em **Create Authentication Scheme**. 

## Passo 2: Criação dos Esquemas de Autorização (Perfis)
Em **Shared Components**, sob *Security*, clique em **Authorization Schemes**. Repita o fluxo (**Create** > *From Scratch* > **Next**) para criar os 3 perfis abaixo:

### 2.1 Perfil Administrador
- **Name:** Perfil_Administrador
- **Scheme Type:** Exists SQL Query
- **SQL Query:** 
  ```sql
  SELECT 1 
  FROM clinica_medica.usuarios_sistema u
  JOIN clinica_medica.perfis_acesso p ON u.id_perfil = p.id_perfil
  WHERE UPPER(u.login) = UPPER(:APP_USER) 
  AND UPPER(p.nome_perfil) = 'ADMINISTRADOR';
  ```
- **Error Message:** Acesso restrito a Administradores.

### 2.2 Perfil Recepcionista
- **Name:** Perfil_Recepcionista
- **Scheme Type:** Exists SQL Query
- **SQL Query:** 
  ```sql
  SELECT 1 
  FROM clinica_medica.usuarios_sistema u
  JOIN clinica_medica.perfis_acesso p ON u.id_perfil = p.id_perfil
  WHERE UPPER(u.login) = UPPER(:APP_USER) 
  AND UPPER(p.nome_perfil) = 'RECEPCIONISTA';
  ```
- **Error Message:** Acesso restrito a Recepcionistas.

### 2.3 Perfil Médico
- **Name:** Perfil_Medico
- **Scheme Type:** Exists SQL Query
- **SQL Query:** 
  ```sql
  SELECT 1 
  FROM clinica_medica.usuarios_sistema u
  JOIN clinica_medica.perfis_acesso p ON u.id_perfil = p.id_perfil
  WHERE UPPER(u.login) = UPPER(:APP_USER) 
  AND UPPER(p.nome_perfil) = 'MEDICO';
  ```
- **Error Message:** Acesso restrito a Médicos.

## Passo 3: Aplicação das Regras de Negócio nas Telas (Menus)
Nesta etapa, vamos definir quem pode ver quais links no menu lateral do sistema. O APEX oculta os menus automaticamente se o usuário logado não tiver o perfil exigido.

1. Acesse **Shared Components** > *Navigation and Search* > **Lists**.
2. Clique na lista chamada **Desktop Navigation Menu**. Você verá a tela "List Details" com todos os itens do seu menu.
3. Na seção *List Entries*, clique no ícone do lápis amarelo (**Edit List Entry**) à direita do item que deseja proteger (Ex: `Faturamento`).
4. A tela de edição do item (List Entry) será aberta. Role a tela para baixo até encontrar a aba/seção chamada **Authorization**.
5. No campo **Authorization Scheme**, abra a caixa de seleção. O APEX listará os três perfis que você criou no Passo 2.
6. Selecione o perfil que tem permissão para acessar esta tela (Ex: `Perfil_Administrador`).
7. Clique no botão azul **Apply Changes** (canto superior direito).
8. Repita os passos 3 a 7 para os demais itens, aplicando a matriz de acesso abaixo:

### Matriz de Acesso Sugerida
* **Apenas Administrador (Perfil_Administrador):**
  - Perfis de Acesso
  - Funcionários
  - Cadastro de Funcionário
  - Fornecedores
  - Faturamento
  - Contas a Receber
  - Contas a Pagar
  - Usuários do Sistema
  - Relatório de Auditoria LGPD
  - Resumo de Faturamento (View)

* **Médico (Perfil_Medico):**
  *O Médico deve ver as telas abaixo. (Você pode criar um Scheme agrupado ou deixar sem restrição caso o Médico e a Recepcionista compartilhem a mesma visão básica, protegendo apenas o que é exclusivo do Admin)*
  - Prontuários Eletrônicos
  - Agenda Médica Consolidada (View)

* **Recepcionista (Perfil_Recepcionista):**
  - Pacientes
  - Agendamentos
  - Médicos
  - Especialidades Médicas
