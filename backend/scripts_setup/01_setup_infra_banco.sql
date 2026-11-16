-- =============================================================================
-- Script: 01_setup_infra_banco.sql
-- Objetivo: Criacao de Tablespaces e Schema da Aplicacao Clinica Medica
-- SGBD: Oracle Database 23ai
-- Conexao requerida: SYSDBA no PDB de destino
-- =============================================================================

-- 1. Criacao da Tablespace de Aplicacao (Dados e Indices de Negocio)
CREATE TABLESPACE TS_CLINICA_APP DATAFILE 'clinica_app_01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M;

-- 2. Criacao da Tablespace de Usuarios/Comuns
CREATE TABLESPACE TS_CLINICA_USERS DATAFILE 'clinica_users_01.dbf' SIZE 50M AUTOEXTEND ON NEXT 50M;

-- 3. Criacao do Usuario da Aplicacao apontando para as Tablespaces
CREATE USER CLINICA_MEDICA IDENTIFIED BY "Clinica_2026_#" DEFAULT TABLESPACE TS_CLINICA_APP QUOTA UNLIMITED ON TS_CLINICA_APP QUOTA UNLIMITED ON TS_CLINICA_USERS;

-- 4. Concessao de Privilegios de Sistema para o Schema
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER TO CLINICA_MEDICA;
