-- ==============================================================================
-- SCRIPT: 02_funcao_autenticacao.sql
-- OBJETIVO: Criar função de login customizada para o APEX e validar massa de dados
-- ==============================================================================

-- 1. Criação da Função de Autenticação Customizada
CREATE OR REPLACE FUNCTION clinica_medica.valida_login_simples (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
) RETURN BOOLEAN 
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM clinica_medica.usuarios_sistema
    WHERE UPPER(login) = UPPER(p_username)
    AND senha_hash = p_password; 

    IF v_count = 1 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/

-- 2. Bloco Anônimo de Validação (Health Check)
SET SERVEROUTPUT ON;
DECLARE
    v_qtd_admin NUMBER;
    v_qtd_recep NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- INICIANDO VALIDAÇÃO DE SEGURANÇA ---');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    
    -- Valida Admin
    SELECT COUNT(*) INTO v_qtd_admin FROM clinica_medica.usuarios_sistema WHERE UPPER(login) = 'ADMIN_APEX';
    IF v_qtd_admin > 0 THEN
        DBMS_OUTPUT.PUT_LINE('[OK] Usuário desenvolvedor ADMIN_APEX encontrado e destrancado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERRO] ADMIN_APEX não encontrado. Menus do App Builder ficarão ocultos!');
    END IF;

    -- Valida Recepcionista
    SELECT COUNT(*) INTO v_qtd_recep FROM clinica_medica.usuarios_sistema WHERE UPPER(login) = 'RECEPCAO01';
    IF v_qtd_recep > 0 THEN
        DBMS_OUTPUT.PUT_LINE('[OK] Usuário de teste RECEPCAO01 encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERRO] RECEPCAO01 não encontrado. Falha de Login no APEX.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
END;
/
EXIT;
