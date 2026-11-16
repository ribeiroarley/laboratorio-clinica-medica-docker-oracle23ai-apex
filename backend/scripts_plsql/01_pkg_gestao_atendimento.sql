-- =============================================================================
-- Script: 01_pkg_gestao_atendimento.sql
-- Objetivo: Package Corporativa de Regras de Negocio de Atendimento e Agenda
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE GOVERNANCA E PADRONIZACAO:
-- 1. Package Specification e Body sao criados sob o owner CLINICA_MEDICA.;
-- 2. Todas as tabelas e objetos referenciados utilizam qualificacao explicita;
-- 3. A procedure PRC_AGENDAR_CONSULTA encapsula a validacao de integridade temporal
--    impedindo a duplicidade ou sobreposicao de agenda de um profissional medico.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Package Specification
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE CLINICA_MEDICA.PKG_GESTAO_ATENDIMENTO AS

    -- Procedure para realizacao de novo agendamento com validacao de conflito
    PROCEDURE PRC_AGENDAR_CONSULTA (
        p_id_paciente IN CLINICA_MEDICA.PACIENTES.ID_PACIENTE%TYPE,
        p_id_medico   IN CLINICA_MEDICA.MEDICOS.ID_MEDICO%TYPE,
        p_data_hora   IN CLINICA_MEDICA.AGENDAMENTOS.DATA_HORA_AGENDAMENTO%TYPE
    );

END PKG_GESTAO_ATENDIMENTO;
/
SHOW ERRORS PACKAGE CLINICA_MEDICA.PKG_GESTAO_ATENDIMENTO;

-- -----------------------------------------------------------------------------
-- Package Body
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY CLINICA_MEDICA.PKG_GESTAO_ATENDIMENTO AS

    PROCEDURE PRC_AGENDAR_CONSULTA (
        p_id_paciente IN CLINICA_MEDICA.PACIENTES.ID_PACIENTE%TYPE,
        p_id_medico   IN CLINICA_MEDICA.MEDICOS.ID_MEDICO%TYPE,
        p_data_hora   IN CLINICA_MEDICA.AGENDAMENTOS.DATA_HORA_AGENDAMENTO%TYPE
    ) IS
        v_conflito_horario NUMBER := 0;
    BEGIN
        -- 1. Verificacao de Conflito de Horario: Medico com consulta ativa no mesmo horario
        SELECT COUNT(*)
          INTO v_conflito_horario
          FROM CLINICA_MEDICA.AGENDAMENTOS a
         WHERE a.ID_MEDICO = p_id_medico
           AND a.DATA_HORA_AGENDAMENTO = p_data_hora
           AND a.STATUS_AGENDAMENTO NOT IN ('CANCELADO');

        IF v_conflito_horario > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Conflito de Agenda: O medico selecionado ja possui consulta agendada para esta data e horario.'
            );
        END IF;

        -- 2. Insercao do Agendamento na Tabela de Dominio
        INSERT INTO CLINICA_MEDICA.AGENDAMENTOS (
            ID_PACIENTE,
            ID_MEDICO,
            DATA_HORA_AGENDAMENTO,
            STATUS_AGENDAMENTO,
            DATA_CRIACAO
        ) VALUES (
            p_id_paciente,
            p_id_medico,
            p_data_hora,
            'AGENDADO',
            SYSTIMESTAMP
        );

    END PRC_AGENDAR_CONSULTA;

END PKG_GESTAO_ATENDIMENTO;
/
SHOW ERRORS PACKAGE BODY CLINICA_MEDICA.PKG_GESTAO_ATENDIMENTO;
