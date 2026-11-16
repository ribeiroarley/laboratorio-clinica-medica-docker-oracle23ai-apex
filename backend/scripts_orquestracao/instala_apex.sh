#!/bin/bash
echo "======================================================"
echo " INSTALANDO ORACLE APEX NO ORACLE 23ai (FREEPDB1) "
echo "======================================================"
cd /tmp
if [ ! -f apex-latest.zip ]; then
    echo ">>> 1. Baixando o Oracle APEX mais recente..."
    curl -s -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip
fi
echo ">>> 2. Extraindo arquivos..."
unzip -qo apex-latest.zip
cd /tmp/apex
sed -i 's/elsif l_final_version >= 23 and l_final_version < 23.010 then/elsif 1=2 then/' /tmp/apex/core/scripts/apxprereq.sql

echo ">>> 3. Instalando o APEX no banco (AGUARDE, PODE LEVAR CERCA DE 10 MINUTOS)..."
sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apexins.sql SYSAUX SYSAUX TEMP /i/

echo ">>> 4. Configurando senha do Administrador (ADMIN)..."
echo -e "ADMIN\nadmin@clinica.com\nClinica_2026_Admin!" | sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apxchpwd.sql

echo ">>> 5. Configurando usuarios REST (APEX_LISTENER e APEX_REST_PUBLIC_USER)..."
echo -e "Clinica_2026_Admin!\nClinica_2026_Admin!" | sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apex_rest_config.sql

echo ">>> 6. Desbloqueando conta APEX_PUBLIC_USER..."
sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba <<EOF
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "Clinica_2026_Admin!";
EXIT;
EOF
echo "======================================================"
echo " INSTALACAO DO APEX CONCLUIDA COM SUCESSO! "
echo "======================================================"
