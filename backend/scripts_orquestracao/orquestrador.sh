#!/bin/bash
echo "======================================================"
echo " ORQUESTRACAO SMARTDB - CLINICA MEDICA (ORACLE 23ai)"
echo "======================================================"
cd /tmp/backend

sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba <<EOF
SET ECHO ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

PROMPT >>> 1. INFRAESTRUTURA E SCHEMAS
@scripts_setup/01_setup_infra_banco.sql
PROMPT >>> 2. TABELAS CLINICAS CENTRAIS
@scripts_setup/01_setup_tabelas_clinica.sql
PROMPT >>> 3. SEGURANCA E RBAC
@scripts_setup/02_setup_seguranca_rbac.sql
PROMPT >>> 4. BACK-OFFICE (FINANCEIRO E RH)
@scripts_setup/03_setup_financeiro_rh.sql
PROMPT >>> 5. CARGA INICIAL DE DADOS (DML)
@scripts_dml/01_carga_inicial_dominio.sql
PROMPT >>> 6. VIEWS DE NEGOCIO
@scripts_views/01_views_negocio.sql
PROMPT >>> 7. PACKAGE PL/SQL
@scripts_plsql/01_pkg_gestao_atendimento.sql
PROMPT >>> 8. AUTOMACAO - TRIGGER LGPD
@scripts_automacao/01_trg_auditoria_pacientes.sql
PROMPT >>> 9. AUTOMACAO - JOB NOTURNO
@scripts_automacao/02_job_manutencao_noturna.sql

PROMPT >>> ORQUESTRACAO CONCLUIDA COM SUCESSO!
EXIT;
EOF
