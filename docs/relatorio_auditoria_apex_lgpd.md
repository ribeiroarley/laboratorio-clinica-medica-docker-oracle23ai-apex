# Relatório de Auditoria Técnica de Arquitetura de Software

**Documento Analisado:** Da Análise de Requisitos ao Oracle APEX – Como uma boa modelagem de dados transforma sistemas low-code em soluções profissionais  
**Autor:** Marcelino Saraiva Mota  
**Contexto:** Oracle APEX Tour Latinoamérica (LAOUC 2026) / Arquitetura de Dados, IA e LGPD no Oracle Database 26ai  

---

## Tema 1: Engenharia de Requisitos e Fundamentos da Modelagem para Low-Code (Oracle APEX)

* **Resumo Técnico:**  
  Avaliação crítica sobre os erros comuns na adoção do low-code, em especial a "ilusão da velocidade", onde o desenvolvimento de aplicações no Oracle APEX se inicia diretamente pela interface gráfica sem uma análise rigorosa de requisitos e modelagem de dados. Trata do antipadrão de criar tabelas a partir de telas/mockups, o que resulta em baixa escalabilidade, redundância, regras de negócio espalhadas na camada client-side/APEX e alto custo de alteração tardia. Apresenta o ciclo metodológico correto (Entender -> Requisitos -> Processos -> Entidades), a curva de evolução do custo de manutenção, checklists práticos pré-desenvolvimento e as lições aprendidas sobre a centralização da integridade no banco de dados através de constraints.

* **Intervalo de Páginas:**  
  Páginas 1 a 6, Páginas 18 a 20 e Página 74.

---

## Tema 2: Ciclo de Vida da Modelagem de Dados: Conceitual, Lógica, Física e Dimensional

* **Resumo Técnico:**  
  Mapeamento estruturado das etapas de engenharia de dados aplicadas a projetos Oracle APEX. Cobre a transição do Modelo Conceitual (validação com usuário via DFD) para o Modelo Lógico (Diagrama Entidade-Relacionamento - DER com definição de cardinalidades e integridade referencial). Detalha a aplicação das Formas Normais (1FN, 2FN e 3FN) para eliminação de redundâncias e a construção do Modelo Físico no Oracle Database (uso de datatypes nativos como VARCHAR2, DATE, NUMBER, Primary Keys com Identity Columns, Foreign Keys, Check Constraints e colunas de auditoria). Adicionalmente, introduz o Modelo Dimensional (Esquema Estrela com tabelas fato e dimensão) otimizado para a criação de Interactive Reports e dashboards gerenciais em APEX sem necessidade de gambiarras em SQL.

* **Intervalo de Páginas:**  
  Páginas 9 a 17.

---

## Tema 3: Framework de Especificação de Requisitos Orientado a IA e Oracle 26ai

* **Resumo Técnico:**  
  Apresentação de uma metodologia de especificação funcional e técnica composta por 13 blocos complementares. O modelo reflete a nova realidade em que a especificação de requisitos orienta não apenas desenvolvedores humanos, mas também LLMs, assistentes de IA generativa, busca vetorial e algoritmos de machine learning dentro do ecossistema Oracle Database 26ai. Detalha os blocos fundamentais: Identificação da Funcionalidade (Bloco 1), Processo de Negócio (Bloco 2), Entidades Identificadas (Bloco 3), Atributos e Domínios (Bloco 4), Relacionamentos (Bloco 5), Regras de Negócio (Bloco 6), Requisitos para APEX (Bloco 7), Governança/Segurança (Bloco 12) e Critérios de Aceite baseados em BDD (Dado/Quando/Então - Bloco 13).

* **Intervalo de Páginas:**  
  Páginas 7, 21 a 30 e Páginas 70 a 73.

---

## Tema 4: Governança de LLM, Normalização Semântica e Proteção de Dados (LGPD)

* **Resumo Técnico:**  
  Definição do padrão de arquitetura para o uso de LLMs na conversão de linguagem natural em SQL seguro (Bloco 8). Aborda a necessidade da camada de normalização semântica (dicionário de sinônimos mapeando a fala coloquial do usuário para entidades e atributos canônicos do banco), a formalização de regras de integridade operacional no prompt estruturado e o estabelecimento de limites éticos/operacionais rígidos (recusa automática de diagnósticos, prescrições e bloqueio a alterações transacionais diretas via SQL). Sob a ótica de governança e LGPD, exige que conexões de IA utilizem privilégios de somente leitura (SELECT Only) e aplica recursos nativos de segurança do Oracle Database, como mascaramento dinâmico (Oracle Data Redaction) e controle de acesso por perfil/linha (Virtual Private Database - VPD).

* **Intervalo de Páginas:**  
  Páginas 31 a 39.

---

## Tema 5: Arquitetura RAG (Retrieval-Augmented Generation) Clínico e Governança Regulatória

* **Resumo Técnico:**  
  Especificação técnica para implementação de RAG (Retrieval-Augmented Generation) in-database utilizando o Oracle Database 26ai (Bloco 10). Detalha a ingestão e fragmentação (chunking semântico em janelas de 500 tokens com overlap de 10%) de documentos clínicos e contratuais via `DBMS_VECTOR_CHAIN`. Estabelece mecânicas de governança preventiva para ambientes regulados (ANS/LGPD): controle de versão estrito, desativação automática de documentos expirados por meio de filtros condicionais SQL (`valid_until >= SYSDATE`), threshold de corte por similaridade cosseno (> 0,78) para mitigar alucinações, obrigatoriedade de citação da fonte (chunk ID e versão) em cada resposta e logging completo para auditoria.

* **Intervalo de Páginas:**  
  Páginas 40 a 49.

---

## Tema 6: AI Vector Search e Busca Semântica Híbrida in-Database

* **Resumo Técnico:**  
  Arquitetura e implementação do Oracle AI Vector Search (Bloco 9) para resolução do desafio semântico em dados não estruturados (ex.: convergência entre linguagem informal do paciente e terminologia médica). Especifica a estrutura de tabelas relacionais contendo colunas do tipo `VECTOR(1024)` para armazenamento de embeddings gerados in-database via pacote `DBMS_VECTOR` utilizando modelos ONNX (como Multilingual-e5 ou BiomedBERT). Demonstra a execução de busca híbrida (combinação de predicados SQL relacionais e distância vetorial com `VECTOR_DISTANCE` e distância cosseno) e o uso de índices HNSW/IVF. Destaca a conformidade com a LGPD obtida ao manter todo o processamento, vetorização e criptografia (TDE) dentro do perímetro de segurança do banco, sem exportação de dados a APIs de terceiros.

* **Intervalo de Páginas:**  
  Páginas 50 a 59.

---

## Tema 7: Machine Learning In-Database (Oracle OML) e Integração Operacional no APEX

* **Resumo Técnico:**  
  Projeto e implementação de modelos preditivos in-database para resolução de problemas operacionais como o absenteísmo médico (No-Show) (Bloco 11). Detalha a engenharia de atributos preditores em bases históricas anonimizadas, a utilização dos algoritmos Random Forest e GLM Logístico via pacote nativo `DBMS_DATA_MINING`, e os critérios de avaliação de desempenho (limiar mínimo de AUC-ROC de 0,82 com priorização de Recall). Especifica o pipeline de retreinamento automatizado via jobs do `DBMS_SCHEDULER` e a inferência em tempo real via SQL nativo (`PREDICTION_PROBABILITY`). Descreve o consumo dos resultados na camada APEX através de painéis visuais com alertas coloridos por nível de risco, automação de confirmações (SMS/WhatsApp) e liberação estratégica de vagas na agenda, ressaltando as vantagens de compliance com a LGPD e baixíssima latência frente a soluções SaaS ou Python externas.

* **Intervalo de Páginas:**  
  Páginas 60 a 69.