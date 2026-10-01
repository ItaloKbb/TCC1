$ErrorActionPreference = 'Stop'

$raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$binMiKTeX = Join-Path $env:LOCALAPPDATA 'Programs\MiKTeX\miktex\bin\x64'

function Encontrar-Compilador([string]$nome) {
    $comando = Get-Command $nome -ErrorAction SilentlyContinue
    if ($comando) { return $comando.Source }

    $instalado = Join-Path $binMiKTeX "$nome.exe"
    if (Test-Path $instalado) { return $instalado }

    throw "$nome não encontrado. Instale o MiKTeX e execute este script novamente."
}

$pdflatex = Encontrar-Compilador 'pdflatex'
$bibtex = Encontrar-Compilador 'bibtex'

Push-Location $raiz
try {
    for ($passagem = 1; $passagem -le 3; $passagem++) {
        Write-Host "pdfLaTeX: passagem $passagem/3"
        & $pdflatex --enable-installer -interaction=nonstopmode -halt-on-error -file-line-error ModeloTCC.tex
        if ($LASTEXITCODE -ne 0) { throw "pdfLaTeX falhou na passagem $passagem. Consulte ModeloTCC.log." }

        if ($passagem -eq 1) {
            Write-Host 'BibTeX: referências'
            & $bibtex ModeloTCC
            if ($LASTEXITCODE -ne 0) { throw 'BibTeX falhou. Consulte ModeloTCC.blg.' }
        }
    }

    Write-Host "PDF gerado: $(Join-Path $raiz 'ModeloTCC.pdf')"
}
finally {
    Pop-Location
}
