# SmartDB Clínica Médica

Sistema de clínica desenvolvido integralmente com Oracle APEX e Oracle Database 23ai. O projeto foca em arquitetura de dados relacional, governança de acessos e automação de infraestrutura via Docker.

## Arquitetura do Projeto

O ecossistema é composto por 13 tabelas físicas e 2 views de negócio, orquestradas através de contêineres Docker para garantir a reprodutibilidade do ambiente de banco de dados.

Principais entregas técnicas:
* Modelagem de Dados: Estruturação completa com chaves primárias, estrangeiras e restrições de integridade.
* Segurança e Governança (RBAC): Implementação de Controle de Acesso Baseado em Funções com autenticação PL/SQL customizada.
* Isolamento de Visão: Segregação estrita de interface no Oracle APEX garantindo que perfis distintos (Administrador, Médico e Recepcionista) acessem apenas seus respectivos domínios.
* Infraestrutura como Código (IaC): Scripts de inicialização (`orquestrador.sh`) e DDL/DML versionados para carga automatizada do ambiente.

## Stack Tecnológico

* Oracle Database 23ai (Docker Free Edition)
* Oracle APEX
* PL/SQL
* Shell Script / Bash
* Python (Scripts auxiliares)

## Estrutura de Diretórios

* `backend/dicionario_de_dados/`: Documentação de requisitos, modelagem, roteiros de telas e matriz de segurança.
* `backend/scripts_banco/`: Scripts DDL para criação de tabelas, views e automação de login customizado.
* `orquestrador.sh`: Script principal de automação de build e deploy do ambiente Docker.

## Autor
Desenvolvido por Arley Ribeiro - Database Administrator.
