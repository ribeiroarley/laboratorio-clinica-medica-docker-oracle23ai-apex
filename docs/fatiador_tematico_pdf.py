import os
import sys
from pathlib import Path
import fitz

TEMAS_CONFIG = [
    {
        "arquivo": "01_eng_requisitos_low_code.pdf",
        "tema": "Tema 1: Engenharia de Requisitos e Fundamentos da Modelagem para Low-Code",
        "paginas_referencia": "1 a 6, 18 a 20 e 74",
        "intervalos": [(1, 6), (18, 20), (74, 74)],
    },
    {
        "arquivo": "02_ciclo_vida_modelagem.pdf",
        "tema": "Tema 2: Ciclo de Vida da Modelagem de Dados: Conceitual, Logica, Fisica e Dimensional",
        "paginas_referencia": "9 a 17",
        "intervalos": [(9, 17)],
    },
    {
        "arquivo": "03_framework_requisitos_ia.pdf",
        "tema": "Tema 3: Framework de Especificacao de Requisitos Orientado a IA e Oracle 26ai",
        "paginas_referencia": "7, 21 a 30 e 70 a 73",
        "intervalos": [(7, 7), (21, 30), (70, 73)],
    },
    {
        "arquivo": "04_governanca_llm_lgpd.pdf",
        "tema": "Tema 4: Governanca de LLM, Normalizacao Semantica e Protecao de Dados (LGPD)",
        "paginas_referencia": "31 a 39",
        "intervalos": [(31, 39)],
    },
    {
        "arquivo": "05_arquitetura_rag_clinico.pdf",
        "tema": "Tema 5: Arquitetura RAG Clinico e Governanca Regulatoria",
        "paginas_referencia": "40 a 49",
        "intervalos": [(40, 49)],
    },
    {
        "arquivo": "06_vector_search_hibrido.pdf",
        "tema": "Tema 6: AI Vector Search e Busca Semantica Hibrida in-Database",
        "paginas_referencia": "50 a 59",
        "intervalos": [(50, 59)],
    },
    {
        "arquivo": "07_machine_learning_apex.pdf",
        "tema": "Tema 7: Machine Learning In-Database (Oracle OML) e Integracao Operacional no APEX",
        "paginas_referencia": "60 a 69",
        "intervalos": [(60, 69)],
    },
]

def processar_fatiamento():
    diretorio_raiz = Path(".")
    diretorio_docs = diretorio_raiz / "docs"
    diretorio_docs.mkdir(parents=True, exist_ok=True)

    arquivo_pdf_origem = diretorio_raiz / "Da-Analise-de-Requisitos-ao-Oracle-APEX_Consolidada.pdf"

    if not arquivo_pdf_origem.exists():
        print(f"[ERRO] Arquivo de origem nao encontrado: {arquivo_pdf_origem.name}")
        sys.exit(1)

    print(f"[INICIO] Abrindo documento de origem: {arquivo_pdf_origem.name}")
    doc_origem = fitz.open(str(arquivo_pdf_origem))
    total_paginas_origem = len(doc_origem)
    print(f"[INFO] Documento carregado. Total de paginas disponiveis: {total_paginas_origem}")
    print(f"[INFO] Diretorio de destino dos arquivos: {diretorio_docs.resolve()}")
    print("-" * 80)

    relatorio_geracao = []

    for item in TEMAS_CONFIG:
        nome_arquivo = item["arquivo"]
        tema_titulo = item["tema"]
        paginas_ref = item["paginas_referencia"]
        intervalos = item["intervalos"]

        caminho_saida = diretorio_docs / nome_arquivo
        doc_novo = fitz.open()

        for inicio, fim in intervalos:
            if inicio < 1 or fim > total_paginas_origem:
                print(f"[ALERTA] Intervalo ({inicio}, {fim}) fora dos limites (1 a {total_paginas_origem}).")
                continue

            # Ajuste de indice 0-based: pagina 1 = indice 0
            indice_inicio = inicio - 1
            indice_fim = fim - 1

            doc_novo.insert_pdf(
                doc_origem,
                from_page=indice_inicio,
                to_page=indice_fim
            )

        total_paginas_extraidas = len(doc_novo)
        doc_novo.save(str(caminho_saida))
        doc_novo.close()

        relatorio_geracao.append({
            "arquivo": nome_arquivo,
            "paginas": total_paginas_extraidas,
            "intervalo_origem": paginas_ref,
            "tema": tema_titulo
        })

        print(f"[GERADO] {nome_arquivo} | Paginas extraidas: {total_paginas_extraidas} | Origem: {paginas_ref}")

    doc_origem.close()

    print("-" * 80)
    print("[RELATORIO FINAL DE FATIAMENTO TEMATICO]")
    print(f"{'Arquivo':<35} | {'Paginas':<8} | {'Intervalo no Original':<22}")
    print("-" * 80)
    for r in relatorio_geracao:
        print(f"{r['arquivo']:<35} | {r['paginas']:<8} | {r['intervalo_origem']:<22}")
    print("-" * 80)
    print(f"[SUCESSO] Total de arquivos gerados no diretorio 'docs/': {len(relatorio_geracao)}")

if __name__ == "__main__":
    processar_fatiamento()
