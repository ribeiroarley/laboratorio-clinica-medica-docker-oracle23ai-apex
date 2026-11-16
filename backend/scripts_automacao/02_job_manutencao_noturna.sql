-- =============================================================================
-- Script: 02_job_manutencao_noturna.sql
-- Objetivo: Agendamento de Rotina Automatica de Manutencao Financeira Noturna
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE AUTOMACAO:
-- Este script configura um Job do Oracle Scheduler (DBMS_SCHEDULER) programado
-- para execucao de segunda a sexta-feira, as 03:00 da manha.
-- A rotina varre a tabela CLINICA_MEDICA.CONTAS_RECEBER e atualiza para 'VENCIDO'
-- todos os titulos pendentes cuja DATA_VENCIMENTO seja anterior a data corrente.
-- =============================================================================

BEGIN
    -- Remove o Job previamente caso ja exista para garantir idempotencia
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(
            job_name => 'CLINICA_MEDICA.JOB_ATUALIZA_STATUS_FINANCEIRO',
            force    => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Ignora erro caso o job ainda nao exista
    END;

    -- Criacao do Job de Manutencao Financeira Noturna
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'CLINICA_MEDICA.JOB_ATUALIZA_STATUS_FINANCEIRO',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                UPDATE CLINICA_MEDICA.CONTAS_RECEBER
                                   SET STATUS_RECEBIMENTO = ''VENCIDO''
                                 WHERE DATA_VENCIMENTO < TRUNC(SYSDATE)
                                   AND STATUS_RECEBIMENTO = ''PENDENTE'';
                                COMMIT;
                            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Job noturno de atualizacao automatica de titulos a receber vencidos (Seg-Sex as 03:00).'
    );
END;
/
