-- ==============================================================================
-- SCRIPT: 03_fix_autenticacao.sql
-- OBJETIVO: Sanitizar dados, aplicar grants e blindar a função de login
-- ==============================================================================

-- 1. Garante que qualquer esquema do APEX possa executar a função
GRANT EXECUTE ON clinica_medica.valida_login_simples TO PUBLIC;

-- 2. Sanitiza os dados (remove espaços acidentais no início ou fim)
UPDATE clinica_medica.usuarios_sistema 
SET login = TRIM(login), senha_hash = TRIM(senha_hash);
COMMIT;

-- 3. Recria a função blindada contra espaços e case sensitivity do username
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
    WHERE TRIM(UPPER(login)) = TRIM(UPPER(p_username))
    AND TRIM(senha_hash) = TRIM(p_password); 

    IF v_count >= 1 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/

-- 4. Simulação direta de Login via PL/SQL (O mesmo que o APEX faz)
SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TESTE DE LOGIN ---');
    IF clinica_medica.valida_login_simples('recepcao01', 'Teste@123') THEN
        DBMS_OUTPUT.PUT_LINE('[SUCESSO] A função retornou TRUE para recepcao01. Banco OK!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERRO] A função retornou FALSE. Dados ainda divergem.');
    END IF;
END;
/
EXIT;
