# Arquitetura de Controle de Acesso Baseado em Papeis (RBAC) - Oracle APEX

## 1. Visao Geral da Arquitetura de Seguranca
A aplicacao Oracle APEX para a Clinica Medica implementa o modelo de Controle de Acesso Baseado em Papeis (Role-Based Access Control - RBAC). O objetivo e segregar estritamente as capacidades administrativas daquelas de nivel operacional, garantindo aderencia ao Principio do Privilegio Minimo e aos preceitos de protecao de dados pessoais da LGPD.

---

## 2. Definicao dos Perfis de Acesso

### 2.1. Perfil: ADMIN (Administrador do Sistema)
* **Descricao:** Perfil de gestao tecnica e corporativa da clinica.
* **Privilegios e Escopo:**
  * Acesso irrestrito a todos os modulos da aplicacao.
  * Painel de administracao e cadastro mestre de especialidades e medicos.
  * Gestao de credenciais e contas de usuarios (`USUARIOS_SISTEMA`).
  * Visualizacao de dados cadastrais integrais sem mascara (acesso desmascarado autorizado aos dados de pacientes).
  * Consulta e exportacao de relatorios e logs de auditoria da LGPD (`AUDITORIA_LGPD`).

### 2.2. Perfil: FUNCIONARIO (Recepcao / Operacional)
* **Descricao:** Perfil destinado aos atendentes e operadores da recepcao da clinica.
* **Privilegios e Escopo:**
  * Rotinas operacionais de agendamento, confirmacao e cancelamento de consultas.
  * Cadastro inicial e atualizacao cadastral de pacientes.
  * Consulta a grade de disponibilidade dos medicos.
  * Visualizacao protegida: campos identificadores como `CPF`, telefone e e-mail sofrem mascaramento dinamico via politicas do Oracle Data Redaction.
  * Bloqueio total a telas de configuracao do sistema, historicos clinicos de prontuarios e relatorios de auditoria.

---

## 3. Matriz de Acesso RBAC

| Funcionalidade / Recurso | ADMIN | FUNCIONARIO (Recepcao) | Regra de Seguranca Aplicada |
| :--- | :--- | :--- | :--- |
| **Painel Administrativo** | Total (C,R,U,D) | Sem Acesso | Bloqueio de Pagina no APEX |
| **Gestao de Medicos e Especialidades** | Total (C,R,U,D) | Somente Leitura (R) | Desabilitacao de Controles de Escrita |
| **Agendamento de Consultas** | Total (C,R,U,D) | Total (C,R,U,D) | Operacao Padrao de Atendimento |
| **Cadastro de Pacientes** | Total (C,R,U,D) | Criacao e Edicao (C,R,U) | Acesso Operacional |
| **Visualizacao de CPF do Paciente** | Valor Integral | Mascarado (ex: `***.456.789-**`) | Politica Oracle Data Redaction |
| **Visualizacao de Prontuarios** | Apenas Auditoria | Sem Acesso | Segregacao de Dado Sensivel (Art. 11 LGPD) |
| **Auditoria e Logs LGPD** | Leitura Total (R) | Sem Acesso | Restricao por Esquema de Autorizacao |
| **Gestao de Usuarios e Perfis** | Total (C,R,U,D) | Sem Acesso | Restricao Administrativa Estrita |

---

## 4. Mecanismo de Integracao no Oracle APEX

### 4.1. Resolucao de Contexto de Sessao
No momento da autenticacao no Oracle APEX, o identificador do usuario e capturado atraves da variavel reservada `:APP_USER`. A funcao interna de autenticacao valida as credenciais contra a tabela `USUARIOS_SISTEMA` e armazena o `ID_PERFIL` em um item de aplicacao de escopo global (ex: `F_ID_PERFIL` / `F_NOME_PERFIL`).

### 4.2. Authorization Schemes (Esquemas de Autorizacao)
O Oracle APEX avalia as permissoes de componentes (paginas, botoes, colunas e regioes) utilizando Esquemas de Autorizacao declarativos no Shared Components:

1. **`AUTH_ADMIN_ONLY`:**
   * **Tipo:** Exists (SQL Query) ou PL/SQL Function Returning Boolean.
   * **Logica:** Valida se o usuario da sessao (`:APP_USER`) possui perfil ativo associado a `ADMIN`.
   * **Aplicacao:** Associado as paginas de gestao de usuarios, dashboards executivos e relatorio de auditoria LGPD.

2. **`AUTH_OPERACIONAL`:**
   * **Tipo:** PL/SQL Function Returning Boolean.
   * **Logica:** Valida se o usuario possui perfil `ADMIN` ou `FUNCIONARIO`.
   * **Aplicacao:** Associado as rotinas de agendamento de consultas e busca de pacientes.

### 4.3. Vinculo com Oracle Data Redaction e VPD
O Oracle Database 23ai utiliza a sessao estabelecida pelo APEX via `DBMS_SESSION.SET_IDENTIFIER` para que as politicas de banco de dados identifiquem dinamicamente o perfil do operador. Caso o usuario pertenca ao perfil `FUNCIONARIO`, a engine do banco aplica o mascaramento dos dados sensiveis diretamente na camada SQL, antes de entregar os dados a aplicacao low-code.
