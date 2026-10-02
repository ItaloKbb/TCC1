#!/usr/bin/env bash
set -euo pipefail

raiz="$(cd "$(dirname "$0")" && pwd)"
cd "$raiz"

for nome in pdflatex bibtex; do
    if ! command -v "$nome" >/dev/null 2>&1; then
        echo "$nome não encontrado. Instale o TeX Live e execute este script novamente." >&2
        exit 1
    fi
done

for passagem in 1 2 3; do
    echo "pdfLaTeX: passagem $passagem/3"
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error ModeloTCC.tex

    if [[ "$passagem" -eq 1 ]]; then
        echo "BibTeX: referências"
        bibtex ModeloTCC
    fi
done

echo "PDF gerado: $raiz/ModeloTCC.pdf"
