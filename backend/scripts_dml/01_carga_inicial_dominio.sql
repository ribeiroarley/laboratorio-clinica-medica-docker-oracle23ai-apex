-- =============================================================================
-- Script: 01_carga_inicial_dominio.sql
-- Objetivo: Carga Inicial de Dados Mestres e Amostrais (DML)
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE GOVERNANCA E DML:
-- 1. Todas as declaracoes de INSERT utilizam explicitamente o owner CLINICA_MEDICA.;
-- 2. Colunas de auto-incremento (GENERATED ALWAYS AS IDENTITY) sao omitidas
--    da lista de colunas para garantir atribuicao automatica pelo SGBD;
-- 3. Chaves estrangeiras sao resolvidas via subqueries para evitar dependencias
--    rigidas de identificadores numericos hardcoded;
-- 4. O script finaliza com a instrucao formal de COMMIT para persistencia.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Carga de Especialidades Medicas
-- -----------------------------------------------------------------------------
INSERT INTO CLINICA_MEDICA.ESPECIALIDADES (NOME_ESPECIALIDADE, DESCRICAO, STATUS_ATIVO)
VALUES ('Cardiologia', 'Diagnostico e tratamento de doencas do coracao e do sistema circulatorio.', 'S');

INSERT INTO CLINICA_MEDICA.ESPECIALIDADES (NOME_ESPECIALIDADE, DESCRICAO, STATUS_ATIVO)
VALUES ('Ortopedia', 'Tratamento de lesoes e patologias do aparelho locomotor e osteoarticular.', 'S');

INSERT INTO CLINICA_MEDICA.ESPECIALIDADES (NOME_ESPECIALIDADE, DESCRICAO, STATUS_ATIVO)
VALUES ('Pediatria', 'Assistencia integral a saude de criancas e adolescentes.', 'S');

INSERT INTO CLINICA_MEDICA.ESPECIALIDADES (NOME_ESPECIALIDADE, DESCRICAO, STATUS_ATIVO)
VALUES ('Oftalmologia', 'Preservacao visual, diagnostico de disturbios oculares e cirurgias da visao.', 'S');

INSERT INTO CLINICA_MEDICA.ESPECIALIDADES (NOME_ESPECIALIDADE, DESCRICAO, STATUS_ATIVO)
VALUES ('Dermatologia', 'Prevencao, diagnostico e tratamento de afeccoes da pele, cabelos e unhas.', 'S');

-- -----------------------------------------------------------------------------
-- 2. Carga de Perfis de Acesso (RBAC)
-- -----------------------------------------------------------------------------
INSERT INTO CLINICA_MEDICA.PERFIS_ACESSO (NOME_PERFIL, DESCRICAO)
VALUES ('ADMIN', 'Acesso total de administracao, configuracao, gestao de usuarios e auditoria LGPD.');

INSERT INTO CLINICA_MEDICA.PERFIS_ACESSO (NOME_PERFIL, DESCRICAO)
VALUES ('FUNCIONARIO', 'Acesso operacional da recepcao para agendamento de consultas e cadastro de pacientes.');

-- -----------------------------------------------------------------------------
-- 3. Carga de Usuarios do Sistema
-- -----------------------------------------------------------------------------
INSERT INTO CLINICA_MEDICA.USUARIOS_SISTEMA (LOGIN, SENHA_HASH, ID_PERFIL, DATA_CRIACAO, STATUS_ATIVO)
VALUES (
    'admin.clinica',
    '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    (SELECT ID_PERFIL FROM CLINICA_MEDICA.PERFIS_ACESSO WHERE NOME_PERFIL = 'ADMIN'),
    SYSTIMESTAMP,
    'S'
);

-- -----------------------------------------------------------------------------
-- 4. Carga de Medicos
-- -----------------------------------------------------------------------------
INSERT INTO CLINICA_MEDICA.MEDICOS (ID_ESPECIALIDADE, NOME_MEDICO, CRM, UF_CRM, EMAIL, TELEFONE, STATUS_ATIVO)
VALUES (
    (SELECT ID_ESPECIALIDADE FROM CLINICA_MEDICA.ESPECIALIDADES WHERE NOME_ESPECIALIDADE = 'Cardiologia'),
    'Dr. Carlos Eduardo Silva',
    '123456',
    'SP',
    'carlos.silva@clinicamedica.com.br',
    '(11) 98765-1001',
    'S'
);

INSERT INTO CLINICA_MEDICA.MEDICOS (ID_ESPECIALIDADE, NOME_MEDICO, CRM, UF_CRM, EMAIL, TELEFONE, STATUS_ATIVO)
VALUES (
    (SELECT ID_ESPECIALIDADE FROM CLINICA_MEDICA.ESPECIALIDADES WHERE NOME_ESPECIALIDADE = 'Ortopedia'),
    'Dra. Mariana Costa Santos',
    '234567',
    'SP',
    'mariana.costa@clinicamedica.com.br',
    '(11) 98765-1002',
    'S'
);

INSERT INTO CLINICA_MEDICA.MEDICOS (ID_ESPECIALIDADE, NOME_MEDICO, CRM, UF_CRM, EMAIL, TELEFONE, STATUS_ATIVO)
VALUES (
    (SELECT ID_ESPECIALIDADE FROM CLINICA_MEDICA.ESPECIALIDADES WHERE NOME_ESPECIALIDADE = 'Pediatria'),
    'Dr. Roberto Alencar Lima',
    '345678',
    'SP',
    'roberto.lima@clinicamedica.com.br',
    '(11) 98765-1003',
    'S'
);

-- -----------------------------------------------------------------------------
-- 5. Carga de Pacientes (com flags LGPD)
-- -----------------------------------------------------------------------------
INSERT INTO CLINICA_MEDICA.PACIENTES (
    NOME_COMPLETO, CPF, DATA_NASCIMENTO, SEXO_BIOLOGICO, 
    EMAIL, TELEFONE, TERMO_ACEITE_LGPD, DATA_CONSENTIMENTO, STATUS_CADASTRO
)
VALUES (
    'Ana Beatriz Ferreira',
    '123.456.789-01',
    TO_DATE('1988-04-15', 'YYYY-MM-DD'),
    'F',
    'ana.ferreira@email.com',
    '(11) 97123-4567',
    'Y',
    SYSTIMESTAMP,
    'ATIVO'
);

INSERT INTO CLINICA_MEDICA.PACIENTES (
    NOME_COMPLETO, CPF, DATA_NASCIMENTO, SEXO_BIOLOGICO, 
    EMAIL, TELEFONE, TERMO_ACEITE_LGPD, DATA_CONSENTIMENTO, STATUS_CADASTRO
)
VALUES (
    'Bruno Henrique Rocha',
    '234.567.890-12',
    TO_DATE('1975-09-22', 'YYYY-MM-DD'),
    'M',
    'bruno.rocha@email.com',
    '(11) 97234-5678',
    'Y',
    SYSTIMESTAMP,
    'ATIVO'
);

INSERT INTO CLINICA_MEDICA.PACIENTES (
    NOME_COMPLETO, CPF, DATA_NASCIMENTO, SEXO_BIOLOGICO, 
    EMAIL, TELEFONE, TERMO_ACEITE_LGPD, DATA_CONSENTIMENTO, STATUS_CADASTRO
)
VALUES (
    'Camila de Souza Dias',
    '345.678.901-23',
    TO_DATE('1995-12-03', 'YYYY-MM-DD'),
    'F',
    'camila.dias@email.com',
    '(11) 97345-6789',
    'Y',
    SYSTIMESTAMP,
    'ATIVO'
);

INSERT INTO CLINICA_MEDICA.PACIENTES (
    NOME_COMPLETO, CPF, DATA_NASCIMENTO, SEXO_BIOLOGICO, 
    EMAIL, TELEFONE, TERMO_ACEITE_LGPD, DATA_CONSENTIMENTO, STATUS_CADASTRO
)
VALUES (
    'Daniel Moreira Prado',
    '456.789.012-34',
    TO_DATE('1982-07-19', 'YYYY-MM-DD'),
    'M',
    'daniel.prado@email.com',
    '(11) 97456-7890',
    'Y',
    SYSTIMESTAMP,
    'ATIVO'
);

INSERT INTO CLINICA_MEDICA.PACIENTES (
    NOME_COMPLETO, CPF, DATA_NASCIMENTO, SEXO_BIOLOGICO, 
    EMAIL, TELEFONE, TERMO_ACEITE_LGPD, DATA_CONSENTIMENTO, STATUS_CADASTRO
)
VALUES (
    'Elena Martins Ramos',
    '567.890.123-45',
    TO_DATE('2001-01-30', 'YYYY-MM-DD'),
    'F',
    'elena.ramos@email.com',
    '(11) 97567-8901',
    'Y',
    SYSTIMESTAMP,
    'ATIVO'
);

-- -----------------------------------------------------------------------------
-- 6. Confirmacao da Transacao
-- -----------------------------------------------------------------------------
COMMIT;
