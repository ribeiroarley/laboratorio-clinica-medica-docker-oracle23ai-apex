# Roteiro de Carga de Usuários e Teste RBAC
**Objetivo:** Documentar a inserção dos usuários iniciais para validação do Controle de Acesso Baseado em Funções (RBAC) e destravamento do usuário desenvolvedor.

## 1. Carga Inicial via SQL Commands
Após ativar os esquemas de autorização, o usuário de desenvolvimento perde acesso ao menu caso não conste na tabela `USUARIOS_SISTEMA`. Para resolver isso e gerar a massa de dados de teste:
1. No Oracle APEX, acesse **SQL Workshop** > **SQL Commands**.
2. Execute o bloco PL/SQL abaixo para relacionar automaticamente a tabela de usuários à tabela de perfis:

```sql
BEGIN
    -- 1. Destrancando o usuário desenvolvedor (Admin)
    INSERT INTO clinica_medica.usuarios_sistema (login, senha_hash, id_perfil)
    SELECT 'admin_apex', 'Teste@123', id_perfil 
    FROM clinica_medica.perfis_acesso 
    WHERE UPPER(nome_perfil) = 'ADMINISTRADOR';

    -- 2. Cadastrando a Recepcionista
    INSERT INTO clinica_medica.usuarios_sistema (login, senha_hash, id_perfil)
    SELECT 'recepcao01', 'Teste@123', id_perfil 
    FROM clinica_medica.perfis_acesso 
    WHERE UPPER(nome_perfil) = 'RECEPCIONISTA';

    -- 3. Cadastrando o Médico
    INSERT INTO clinica_medica.usuarios_sistema (login, senha_hash, id_perfil)
    SELECT 'medico01', 'Teste@123', id_perfil 
    FROM clinica_medica.perfis_acesso 
    WHERE UPPER(nome_perfil) = 'MEDICO';

    COMMIT;
END;
/
```

## 2. Validação de Acesso (Teste de Navegação)
Os testes de isolamento de sessão e restrição de menus foram executados com sucesso no App Builder, validando a eficácia da autenticação customizada (`valida_login_simples`) atrelada aos Authorization Schemes.

### Matriz de Visão Validada
- **Usuário:** `admin_apex` (Perfil: Administrador)
  - **Resultado:** Acesso total aos módulos executivos, incluindo Perfis de Acesso, Funcionários, Fornecedores, Faturamento, Contas a Receber/Pagar, Usuários do Sistema, Relatório de Auditoria LGPD e Resumo de Faturamento.
- **Usuário:** `recepcao01` (Perfil: Recepcionista)
  - **Resultado:** Ocultação de módulos financeiros e administrativos. Acesso restrito às tabelas de fluxo de atendimento: Especialidades Médicas, Pacientes, Médicos e Agendamentos.
- **Usuário:** `medico01` (Perfil: Médico)
  - **Resultado:** Foco operacional na área clínica. Acesso restrito a Prontuários Eletrônicos e Agenda Médica Consolidada (View).

**Status do RBAC:** Homologado e funcional no ambiente de desenvolvimento APEX.
