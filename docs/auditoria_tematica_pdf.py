import os
import sys
from pathlib import Path
import fitz
from dotenv import load_dotenv
from google import genai
from google.genai.errors import APIError

def encontrar_arquivo_pdf(diretorio: Path) -> Path:
    arquivos_pdf = list(diretorio.glob("*.pdf"))
    if not arquivos_pdf:
        raise FileNotFoundError("Nenhum arquivo PDF encontrado no diretorio atual.")
    return arquivos_pdf[0]

def extrair_texto_pdf(caminho_pdf: Path) -> tuple[str, int]:
    doc = fitz.open(str(caminho_pdf))
    total_paginas = len(doc)
    partes_texto = []

    for indice, pagina in enumerate(doc):
        numero_pagina = indice + 1
        texto_pagina = pagina.get_text()
        partes_texto.append(f"--- Pagina {numero_pagina} ---\n{texto_pagina}\n")

    doc.close()
    texto_consolidado = "".join(partes_texto)
    return texto_consolidado, total_paginas

def executar_auditoria():
    diretorio_atual = Path(".")
    caminho_env = diretorio_atual / ".env"

    if caminho_env.exists():
        load_dotenv(dotenv_path=caminho_env)
    else:
        load_dotenv()

    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("[ERRO] Variavel GEMINI_API_KEY nao encontrada no arquivo .env.")
        print("[INSTRUCAO] Insira sua chave de API no arquivo .env com: GEMINI_API_KEY=sua_chave")
        sys.exit(1)

    caminho_pdf = encontrar_arquivo_pdf(diretorio_atual)
    print(f"[RECONHECIMENTO] Arquivo PDF detectado: {caminho_pdf.name}")

    print("[PROCESSAMENTO] Extraindo texto das paginas...")
    texto_pdf, total_paginas = extrair_texto_pdf(caminho_pdf)
    print(f"[PROCESSAMENTO] Leitura concluida com sucesso. Total de paginas lidas: {total_paginas}")

    cliente = genai.Client(api_key=api_key)

    modelo_alvo = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
    print(f"[IA] Configurando cliente Google Gemini apontando para o modelo: {modelo_alvo}")

    prompt_instrucao = (
        "Atue como Arquiteto de Software. Analise o documento fornecido sobre Oracle APEX e LGPD. "
        "O objetivo e realizar uma auditoria tematica. "
        "Retorne um relatorio em Markdown contendo os grandes temas abordados (capitulos ou blocos logicos). "
        "Para cada tema, forneca: 1) Titulo do Tema; 2) Resumo tecnico conciso; 3) Intervalo de paginas aproximado onde o tema esta localizado. "
        "Nao invente informacoes. "
        "Regra mandatoria: Nao utilize emojis sob nenhuma circunstancia no texto retornado."
    )

    conteudo_requisicao = f"{prompt_instrucao}\n\nDocumento:\n{texto_pdf}"

    print("[IA] Enviando requisicao para geracao do relatorio de auditoria...")

    resposta = None
    try:
        resposta = cliente.models.generate_content(
            model=modelo_alvo,
            contents=conteudo_requisicao,
        )
    except APIError as erro:
        if "404" in str(erro) or "not found" in str(erro).lower() or "no longer available" in str(erro).lower():
            modelo_fallback = "gemini-3.5-flash"
            print(f"[AVISO] O modelo {modelo_alvo} nao esta disponivel no endpoint da API (404/descontinuado).")
            print(f"[REDIRECIONAMENTO] Utilizando modelo compativel ativo: {modelo_fallback}")
            resposta = cliente.models.generate_content(
                model=modelo_fallback,
                contents=conteudo_requisicao,
            )
        else:
            raise erro

    if not resposta or not resposta.text:
        print("[ERRO] Nao foi possivel obter resposta valida da IA.")
        sys.exit(1)

    caminho_saida = diretorio_atual / "relatorio_auditoria_apex_lgpd.md"
    conteudo_saida = resposta.text

    with open(caminho_saida, "w", encoding="utf-8") as f:
        f.write(conteudo_saida)

    print(f"[CONCLUSAO] Relatorio salvo com sucesso em: {caminho_saida.name}")
    print(f"[RESUMO] Total de paginas auditadas: {total_paginas}")
    print(f"[RESUMO] Arquivo gerado: {caminho_saida.name}")

if __name__ == "__main__":
    executar_auditoria()
