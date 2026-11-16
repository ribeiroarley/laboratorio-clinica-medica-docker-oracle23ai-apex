-- =============================================================================
-- Script: 01_views_negocio.sql
-- Objetivo: Criacao das Views de Negocio para Consumo no Oracle APEX
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE GOVERNANCA E MODELAGEM:
-- 1. Todas as Views sao criadas com o prefixo obrigatorio CLINICA_MEDICA.;
-- 2. Todas as tabelas nos blocos FROM e JOIN sao qualificadas com CLINICA_MEDICA.;
-- 3. A view VW_AGENDA_MEDICA fornece a projecao legivel e amigavel para as telas
--    de recepcao e atendimento no Oracle APEX;
-- 4. A view VW_DASHBOARD_FINANCEIRO consolida os totais de receitas previstas,
--    receitas liquidadas e despesas operacionais para alimentacao de cards e graficos.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. View Operacional: Agenda Medica da Recepcao
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CLINICA_MEDICA.VW_AGENDA_MEDICA AS
SELECT 
    a.ID_AGENDAMENTO,
    a.DATA_HORA_AGENDAMENTO,
    p.ID_PACIENTE,
    p.NOME_COMPLETO AS NOME_PACIENTE,
    p.CPF AS CPF_PACIENTE,
    p.TELEFONE AS TELEFONE_PACIENTE,
    m.ID_MEDICO,
    m.NOME_MEDICO,
    m.CRM || '/' || m.UF_CRM AS CRM_MEDICO,
    e.ID_ESPECIALIDADE,
    e.NOME_ESPECIALIDADE,
    a.STATUS_AGENDAMENTO,
    a.MOTIVO_CANCELAMENTO,
    a.DATA_CRIACAO AS DATA_SOLICITACAO
FROM CLINICA_MEDICA.AGENDAMENTOS a
JOIN CLINICA_MEDICA.PACIENTES p 
    ON a.ID_PACIENTE = p.ID_PACIENTE
JOIN CLINICA_MEDICA.MEDICOS m 
    ON a.ID_MEDICO = m.ID_MEDICO
JOIN CLINICA_MEDICA.ESPECIALIDADES e 
    ON m.ID_ESPECIALIDADE = e.ID_ESPECIALIDADE;

-- -----------------------------------------------------------------------------
-- 2. View Analitica: Consolidado para Dashboards Financeiros
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW CLINICA_MEDICA.VW_DASHBOARD_FINANCEIRO AS
SELECT 
    'RECEITAS_PREVISTAS' AS CODIGO_INDICADOR,
    'Receitas Previstas (A Receber)' AS DESCRICAO_INDICADOR,
    'ENTRADA' AS NATUREZA_OPERACAO,
    NVL(SUM(cr.VALOR), 0) AS VALOR_CONSOLIDADO,
    COUNT(cr.ID_CONTA_RECEBER) AS QUANTIDADE_LANCAMENTOS
FROM CLINICA_MEDICA.CONTAS_RECEBER cr
WHERE cr.STATUS_RECEBIMENTO = 'PENDENTE'
UNION ALL
SELECT 
    'RECEITAS_RECEBIDAS' AS CODIGO_INDICADOR,
    'Receitas Liquidadas (Recebidas)' AS DESCRICAO_INDICADOR,
    'ENTRADA' AS NATUREZA_OPERACAO,
    NVL(SUM(cr.VALOR), 0) AS VALOR_CONSOLIDADO,
    COUNT(cr.ID_CONTA_RECEBER) AS QUANTIDADE_LANCAMENTOS
FROM CLINICA_MEDICA.CONTAS_RECEBER cr
WHERE cr.STATUS_RECEBIMENTO = 'RECEBIDO'
UNION ALL
SELECT 
    'DESPESAS_A_PAGAR' AS CODIGO_INDICADOR,
    'Despesas Operacionais a Pagar' AS DESCRICAO_INDICADOR,
    'SAIDA' AS NATUREZA_OPERACAO,
    NVL(SUM(cp.VALOR), 0) AS VALOR_CONSOLIDADO,
    COUNT(cp.ID_CONTA_PAGAR) AS QUANTIDADE_LANCAMENTOS
FROM CLINICA_MEDICA.CONTAS_PAGAR cp
WHERE cp.STATUS_PAGAMENTO IN ('ABERTO', 'VENCIDO')
UNION ALL
SELECT 
    'DESPESAS_PAGAS' AS CODIGO_INDICADOR,
    'Despesas Operacionais Liquidadas' AS DESCRICAO_INDICADOR,
    'SAIDA' AS NATUREZA_OPERACAO,
    NVL(SUM(cp.VALOR), 0) AS VALOR_CONSOLIDADO,
    COUNT(cp.ID_CONTA_PAGAR) AS QUANTIDADE_LANCAMENTOS
FROM CLINICA_MEDICA.CONTAS_PAGAR cp
WHERE cp.STATUS_PAGAMENTO = 'PAGO';
