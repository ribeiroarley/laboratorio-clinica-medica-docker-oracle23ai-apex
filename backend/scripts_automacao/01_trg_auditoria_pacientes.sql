-- =============================================================================
-- Script: 01_trg_auditoria_pacientes.sql
-- Objetivo: Trigger de Auditoria para Conformidade com a LGPD
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE AUDITORIA E LGPD:
-- Esta trigger intercepta operacoes de atualizacao cadastral na tabela
-- CLINICA_MEDICA.PACIENTES e registra uma trilha auditavel na tabela
-- CLINICA_MEDICA.AUDITORIA_LGPD sempre que dados sensiveis ou identificadores
-- (NOME_COMPLETO, CPF ou EMAIL) forem modificados.
-- Grava o usuario de banco (USER), o usuario da sessao APEX (:APP_USER) e a data.
-- =============================================================================

CREATE OR REPLACE TRIGGER CLINICA_MEDICA.TRG_AUDITA_PACIENTES
AFTER UPDATE ON CLINICA_MEDICA.PACIENTES
FOR EACH ROW
BEGIN
    -- Dispara a gravacao da trilha de auditoria se houver alteracao em dados sensiveis
    IF (:OLD.NOME_COMPLETO != :NEW.NOME_COMPLETO)
       OR (:OLD.CPF != :NEW.CPF)
       OR (NVL(:OLD.EMAIL, 'X') != NVL(:NEW.EMAIL, 'X')) THEN

        INSERT INTO CLINICA_MEDICA.AUDITORIA_LGPD (
            NOME_TABELA,
            ACAO,
            USUARIO_BANCO,
            USUARIO_APEX,
            DATA_ACAO
        ) VALUES (
            'PACIENTES',
            'UPDATE',
            USER,
            SYS_CONTEXT('APEX$SESSION', 'APP_USER'),
            SYSTIMESTAMP
        );

    END IF;
END TRG_AUDITA_PACIENTES;
/
SHOW ERRORS TRIGGER CLINICA_MEDICA.TRG_AUDITA_PACIENTES;
