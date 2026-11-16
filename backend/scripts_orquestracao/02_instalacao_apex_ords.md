# Roteiro de Instalação e Configuração: Oracle APEX + ORDS

Este documento regista os passos operacionais executados para instalar o Oracle APEX na imagem `gvenzl/oracle-free:23.3-full` e configurar o roteamento de ficheiros estáticos no contentor do ORDS.

## 1. Instalação do Oracle APEX no Banco de Dados
Para instalar o APEX dentro do PDB `FREEPDB1`, execute o seguinte script bash dentro do contentor `db_clinica` (salvo previamente como `instala_apex.sh`):

```bash
cd /tmp
curl -s -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip -qo apex-latest.zip
cd /tmp/apex
sed -i 's/elsif l_final_version >= 23 and l_final_version < 23.010 then/elsif 1=2 then/' /tmp/apex/core/scripts/apxprereq.sql

# Instalacao do APEX no tablespace SYSAUX
sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apexins.sql SYSAUX SYSAUX TEMP /i/

# Definicao de senha do Administrador (ADMIN)
echo -e "ADMIN\nadmin@clinica.com\nClinica_2026_Admin!" | sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apxchpwd.sql

# Configuracao das contas REST (APEX_LISTENER e APEX_REST_PUBLIC_USER)
echo -e "Clinica_2026_Admin!\nClinica_2026_Admin!" | sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba @apex_rest_config.sql

# Desbloqueio e configuracao do APEX_PUBLIC_USER
sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba <<EOF
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "Clinica_2026_Admin!";
EXIT;
EOF
```

## 2. Configuração dos Arquivos Estáticos no ORDS
Para que o APEX renderize as folhas de estilo (CSS), imagens e scripts JavaScript via `/i/`, os arquivos da pasta `/images` do instalador devem ser copiados para o contentor do ORDS:

```bash
# 1. Copiar os ficheiros estaticos do contentor de banco de dados para a maquina local
docker cp laboratorio-clinica-medica-docker-oracle23ai-apex:/tmp/apex/images ./apex_images

# 2. Injetar a pasta de imagens dentro do contentor ORDS
docker cp ./apex_images laboratorio-clinica-medica-ords:/opt/oracle/apex_images

# 3. Limpar a pasta temporaria local (PowerShell)
Remove-Item -Recurse -Force ./apex_images
```

## 3. Parametrização e Reinício do Serviço ORDS
Configure o roteamento estático e habilite o gateway PL/SQL no ORDS:

```bash
# Definir caminho fisico dos ficheiros estaticos
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex_images

# Definir contexto web padrao para /i
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set standalone.static.context.path /i

# Habilitar o gateway PL/SQL em modo proxied
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set plsql.gateway.mode proxied

# Reiniciar o contentor ORDS para aplicar as configuracoes
docker restart laboratorio-clinica-medica-ords
```

## 4. Validação do Ambiente e Acesso
Verifique a conectividade e integridade dos endpoints HTTP:

```bash
# Validacao da versao dos arquivos estaticos (esperado: HTTP 200)
curl -i http://localhost:8181/i/apex_version.txt

# Validacao do endpoint do Oracle APEX (esperado: HTTP 200)
curl -i http://localhost:8181/ords/apex
```

### URLs e Credenciais Iniciais de Administrador
* **URL de Acesso ao Administrador APEX:** `http://localhost:8181/ords/apex` (ou `http://localhost:8181/ords/apex_admin`)
* **Workspace Interno:** `INTERNAL`
* **Usuário:** `ADMIN`
* **Senha:** `Clinica_2026_Admin!`

### Workspace de Desenvolvimento Criado
* **URL de Desenvolvimento:** `http://localhost:8181/ords/`
* **Workspace:** `WS_CLINICA_MEDICA`
* **Schema Associado:** `CLINICA_MEDICA`
* **Usuário Desenvolvedor:** `admin_apex`
* **Senha:** `Clinica_2026_Admin!`
