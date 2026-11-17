# Guia de Execução Local (IaC)

Este projeto utiliza Infraestrutura como Código para garantir a reprodutibilidade do ecossistema de banco de dados Oracle 23ai e Oracle APEX. Caso você tenha limpado o seu ambiente Docker ou esteja baixando o projeto pela primeira vez, siga os passos abaixo para recriar a arquitetura completa.

## Pré-requisitos
- **Git** instalado.
- **Docker Desktop** (ou Docker Engine) instalado e em execução.
- Terminal com suporte a Bash (Git Bash, WSL ou Linux) ou PowerShell.

## Passo a Passo para Recriação do Ambiente

### 1. Clonar o Repositório
Abra o seu terminal e clone o projeto do GitHub para a sua máquina local:
```bash
git clone https://github.com/ribeiroarley/NOME_DO_SEU_REPOSITORIO.git
cd NOME_DO_SEU_REPOSITORIO
```

### 2. Inicializar os Contêineres Docker
Na raiz do diretório do projeto, execute o Docker Compose em segundo plano:
```bash
docker compose up -d
```
Esse comando iniciará dois contêineres na rede `clinica_network`:
- `laboratorio-clinica-medica-docker-oracle23ai-apex`: Instância do Oracle Database 23ai Free (portas 1521 e 8080).
- `laboratorio-clinica-medica-ords`: Servidor Oracle REST Data Services (porta 8181).

### 3. Acompanhar a Inicialização do Banco de Dados
Aguarde até que o Oracle Database finalize a criação e abertura do banco:
```bash
docker logs -f laboratorio-clinica-medica-docker-oracle23ai-apex
```
Aguarde até visualizar a mensagem:
`DATABASE IS READY TO USE!`
Após a confirmação, pressione `Ctrl + C` para sair dos logs.

### 4. Orquestração do Backend (DDL, DML, RBAC e Views)
Envie a pasta de scripts do backend para o contêiner de banco e execute o orquestrador automatizado:

```bash
# 1. Copiar a pasta backend para o diretorio temporario do conteiner
docker cp backend laboratorio-clinica-medica-docker-oracle23ai-apex:/tmp/backend

# 2. Executar o script bash de orquestracao
docker exec -it laboratorio-clinica-medica-docker-oracle23ai-apex bash -c "chmod +x /tmp/backend/scripts_orquestracao/orquestrador.sh && /tmp/backend/scripts_orquestracao/orquestrador.sh"
```
Esse processo compilará as 13 tabelas físicas, roles RBAC, views analíticas, package PL/SQL, triggers LGPD e jobs de manutenção no PDB `FREEPDB1`.

### 5. Instalação do Oracle APEX e Configuração do ORDS
Caso a imagem base do Oracle Database não possua o APEX pré-instalado:

1. **Instalar o APEX no Banco:**
```bash
docker exec -it laboratorio-clinica-medica-docker-oracle23ai-apex bash -c "chmod +x /tmp/backend/scripts_orquestracao/instala_apex.sh && /tmp/backend/scripts_orquestracao/instala_apex.sh"
```

2. **Copiar e Rotear os Arquivos Estáticos (`/i/`) para o ORDS:**
```bash
# Copiar pasta images do banco para a maquina host
docker cp laboratorio-clinica-medica-docker-oracle23ai-apex:/tmp/apex/images ./apex_images

# Injetar os arquivos estaticos no conteiner do ORDS
docker cp ./apex_images laboratorio-clinica-medica-ords:/opt/oracle/apex_images

# Remover pasta temporaria local (PowerShell: Remove-Item -Recurse -Force ./apex_images)
rm -rf ./apex_images

# Configurar roteamento de estaticos e modo proxied no ORDS
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex_images
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set standalone.static.context.path /i
docker exec laboratorio-clinica-medica-ords /opt/oracle/ords/bin/ords --config /etc/ords/config config set plsql.gateway.mode proxied

# Reiniciar o servidor ORDS
docker restart laboratorio-clinica-medica-ords
```

### 6. Carga de Autenticação e Usuários RBAC
Para habilitar o login customizado com a função blindada `valida_login_simples`:

```bash
docker exec -i laboratorio-clinica-medica-docker-oracle23ai-apex bash -c "sqlplus -s sys/Clinica_2026_Admin\!@localhost:1521/FREEPDB1 as sysdba" <<EOF
@/tmp/backend/scripts_banco/02_funcao_autenticacao.sql
@/tmp/backend/scripts_banco/03_fix_autenticacao.sql
EXIT;
EOF
```

### 7. Acesso ao Sistema e Credenciais

* **URL do Oracle APEX:** http://localhost:8181/ords/
* **Workspace de Desenvolvimento:** `WS_CLINICA_MEDICA`
* **Schema do Banco:** `CLINICA_MEDICA`

#### Credenciais de Teste Homologadas (RBAC)
| Usuário | Senha | Perfil | Módulos e Menus Acessíveis |
| :--- | :--- | :--- | :--- |
| `admin_apex` | `Teste@123` | Administrador | Acesso total: Tabelas centrais, financeiro, RH, auditoria LGPD e views |
| `recepcao01` | `Teste@123` | Recepcionista | Fluxo de atendimento: Especialidades, Pacientes, Médicos e Agendamentos |
| `medico01` | `Teste@123` | Médico | Área clínica: Prontuários Eletrônicos e Agenda Médica Consolidada |

---

## Comandos Operacionais de Ciclo de Vida

- **Parar os serviços preservando os dados:**
  ```bash
  docker compose stop
  ```

- **Retomar os serviços já existentes:**
  ```bash
  docker compose start
  ```

- **Encerrar e desinstalar todo o ambiente (liberar armazenamento):**
  ```bash
  docker compose down -v
  ```
