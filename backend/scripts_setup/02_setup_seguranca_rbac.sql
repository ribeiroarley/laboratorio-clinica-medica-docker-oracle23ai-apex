-- =============================================================================
-- Script: 02_setup_seguranca_rbac.sql
-- Objetivo: Criacao de Tabelas de Controle de Acesso (RBAC) e Auditoria LGPD
-- SGBD: Oracle Database 23ai
-- Schema: CLINICA_MEDICA
--
-- NOTA DE ARQUITETURA E SEGURANCA:
-- Este modelo de seguranca fornece as entidades de controle que serao consumidas
-- diretamente pelas politicas de Oracle Data Redaction (para mascaramento dinamico
-- de dados identificadores dos pacientes) e Virtual Private Database - VPD (para
-- isolamento de contexto de dados finos no nivel de linha).
-- Os Esquemas de Autorizacao do Oracle APEX consumirao o ID_PERFIL do usuario logado
-- atraves da variavel de sessao :APP_USER para segregar as interfaces ADMIN e FUNCIONARIO.
-- =============================================================================

-- 1. Tabela de Perfis de Acesso (Roles)
CREATE TABLE CLINICA_MEDICA.PERFIS_ACESSO (
    ID_PERFIL   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    NOME_PERFIL VARCHAR2(50) NOT NULL,
    DESCRICAO   VARCHAR2(250) NOT NULL,
    CONSTRAINT PK_PERFIS_ACESSO PRIMARY KEY (ID_PERFIL),
    CONSTRAINT UK_PERFIS_NOME UNIQUE (NOME_PERFIL)
);

-- 2. Tabela de Usuarios do Sistema
CREATE TABLE CLINICA_MEDICA.USUARIOS_SISTEMA (
    ID_USUARIO   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    LOGIN        VARCHAR2(50) NOT NULL,
    SENHA_HASH   VARCHAR2(256) NOT NULL,
    ID_PERFIL    NUMBER(10) NOT NULL,
    DATA_CRIACAO TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    STATUS_ATIVO VARCHAR2(1) DEFAULT 'S' NOT NULL,
    CONSTRAINT PK_USUARIOS_SISTEMA PRIMARY KEY (ID_USUARIO),
    CONSTRAINT UK_USUARIOS_LOGIN UNIQUE (LOGIN),
    CONSTRAINT FK_USUARIOS_PERFIL FOREIGN KEY (ID_PERFIL) 
        REFERENCES CLINICA_MEDICA.PERFIS_ACESSO (ID_PERFIL),
    CONSTRAINT CK_USUARIOS_STATUS CHECK (STATUS_ATIVO IN ('S', 'N'))
);

-- 3. Tabela de Auditoria e Trilhas de Conformidade LGPD
CREATE TABLE CLINICA_MEDICA.AUDITORIA_LGPD (
    ID_LOG        NUMBER(19) GENERATED ALWAYS AS IDENTITY,
    NOME_TABELA   VARCHAR2(50) NOT NULL,
    ACAO          VARCHAR2(20) NOT NULL,
    USUARIO_BANCO VARCHAR2(128) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL,
    USUARIO_APEX  VARCHAR2(100),
    DATA_ACAO     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_AUDITORIA_LGPD PRIMARY KEY (ID_LOG),
    CONSTRAINT CK_AUDITORIA_ACAO CHECK (ACAO IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT_SENSIVEL'))
);
