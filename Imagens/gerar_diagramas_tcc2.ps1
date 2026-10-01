# Regera os diagramas da monografia sem dependências externas.
# Executar no PowerShell: .\Imagens\gerar_diagramas_tcc2.ps1
Add-Type -AssemblyName System.Drawing

function Cor([string] $hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Iniciar([int] $largura, [int] $altura) {
    $script:bitmap = [System.Drawing.Bitmap]::new($largura, $altura)
    $script:g = [System.Drawing.Graphics]::FromImage($script:bitmap)
    $script:g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $script:g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $script:g.Clear((Cor '#ffffff'))
    $script:fonteTitulo = [System.Drawing.Font]::new('Segoe UI', 37, [System.Drawing.FontStyle]::Bold)
    $script:fonteCaixa = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
    $script:fonteTexto = [System.Drawing.Font]::new('Segoe UI', 24)
    $script:fonteNota = [System.Drawing.Font]::new('Segoe UI', 25)
    $script:pincelEscuro = [System.Drawing.SolidBrush]::new((Cor '#233449'))
    $script:pincelCinza = [System.Drawing.SolidBrush]::new((Cor '#526579'))
    $script:alinhamento = [System.Drawing.StringFormat]::new()
    $script:alinhamento.Alignment = [System.Drawing.StringAlignment]::Center
    $script:alinhamento.LineAlignment = [System.Drawing.StringAlignment]::Center
}

function Texto([string] $texto, [int] $x, [int] $y, [int] $w, [int] $h, [System.Drawing.Font] $fonte, [System.Drawing.Brush] $pincel, [bool] $centralizado) {
    $retangulo = [System.Drawing.RectangleF]::new($x, $y, $w, $h)
    if ($centralizado) {
        $script:g.DrawString($texto, $fonte, $pincel, $retangulo, $script:alinhamento)
    } else {
        $script:g.DrawString($texto, $fonte, $pincel, $retangulo)
    }
}

function Caixa([int] $x, [int] $y, [int] $w, [int] $h, [string] $titulo, [string] $corFundo, [string] $subtitulo) {
    $fundo = [System.Drawing.SolidBrush]::new((Cor $corFundo))
    $cabecalho = [System.Drawing.SolidBrush]::new((Cor '#203955'))
    $borda = [System.Drawing.Pen]::new((Cor '#203955'), 4)
    $script:g.FillRectangle($fundo, $x, $y, $w, $h)
    $script:g.FillRectangle($cabecalho, $x, $y, $w, 70)
    $script:g.DrawRectangle($borda, $x, $y, $w, $h)
    $branco = [System.Drawing.SolidBrush]::new((Cor '#ffffff'))
    Texto $titulo ($x + 12) ($y + 5) ($w - 24) 60 $script:fonteCaixa $branco $true
    if ($subtitulo) {
        Texto $subtitulo ($x + 20) ($y + 86) ($w - 40) ($h - 100) $script:fonteTexto $script:pincelEscuro $true
    }
    $branco.Dispose(); $borda.Dispose(); $cabecalho.Dispose(); $fundo.Dispose()
}

function Seta([int[]] $coords, [string] $rotulo, [int] $lx, [int] $ly, [int] $lw) {
    $pontos = @()
    for ($i = 0; $i -lt $coords.Length; $i += 2) {
        $pontos += [System.Drawing.Point]::new($coords[$i], $coords[$i + 1])
    }
    $caneta = [System.Drawing.Pen]::new((Cor '#315b78'), 5)
    $script:g.DrawLines($caneta, [System.Drawing.Point[]] $pontos)
    $fim = $pontos[-1]
    $anterior = $pontos[-2]
    $dx = $fim.X - $anterior.X
    $dy = $fim.Y - $anterior.Y
    $tamanho = [Math]::Sqrt($dx * $dx + $dy * $dy)
    $ux = $dx / $tamanho
    $uy = $dy / $tamanho
    $px = -$uy
    $py = $ux
    $a = [System.Drawing.Point]::new($fim.X, $fim.Y)
    $b = [System.Drawing.Point]::new([int]($fim.X - 22 * $ux + 12 * $px), [int]($fim.Y - 22 * $uy + 12 * $py))
    $c = [System.Drawing.Point]::new([int]($fim.X - 22 * $ux - 12 * $px), [int]($fim.Y - 22 * $uy - 12 * $py))
    $triangulo = [System.Drawing.SolidBrush]::new((Cor '#315b78'))
    $script:g.FillPolygon($triangulo, [System.Drawing.Point[]] @($a, $b, $c))
    if ($rotulo) { Texto $rotulo $lx $ly $lw 44 $script:fonteNota $script:pincelCinza $true }
    $triangulo.Dispose(); $caneta.Dispose()
}

function Encerrar([string] $nome) {
    $destino = Join-Path $PSScriptRoot $nome
    $script:bitmap.Save($destino, [System.Drawing.Imaging.ImageFormat]::Png)
    $script:g.Dispose()
    $script:bitmap.Dispose()
    $script:fonteTitulo.Dispose(); $script:fonteCaixa.Dispose()
    $script:fonteTexto.Dispose(); $script:fonteNota.Dispose()
    $script:pincelEscuro.Dispose(); $script:pincelCinza.Dispose()
    $script:alinhamento.Dispose()
    Write-Output $destino
}

# Arquitetura: linhas antes das caixas, para não cruzarem o texto.
Iniciar 2200 1220
Texto 'Componentes e fluxos da implementação' 70 15 2060 70 $script:fonteTitulo $script:pincelEscuro $true
$grupo = [System.Drawing.Pen]::new((Cor '#b5c6d2'), 4)
$grupo.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$script:g.DrawRectangle($grupo, 790, 345, 1350, 805)
$grupo.Dispose()
Texto 'Serviços definidos no Docker Compose' 835 355 920 52 $script:fonteNota $script:pincelCinza $false
Seta @(305,290,405,290) '' 0 0 0
Seta @(765,270,840,270,840,200) '' 0 0 0
Seta @(765,340,795,340,795,540,850,540) 'Chamadas HTTP + JWT' 390 435 390
Seta @(1045,230,1045,410) 'Validação do token' 1055 275 390
Seta @(1260,555,1605,555) 'Prisma' 1360 502 140
Seta @(1260,625,1450,625,1450,780,1605,780) 'URL assinada' 1310 690 220
Seta @(580,390,580,920,1605,920,1605,825) 'Envio direto do arquivo' 740 858 425
Caixa 60 205 245 170 'Usuário' '#eef5f9' 'Navegador'
Caixa 405 180 360 210 'Frontend' '#e8f5f3' 'React + Next.js'
Caixa 840 75 410 195 'Clerk' '#fff4da' 'Sessões e organizações'
Caixa 850 415 410 270 'API' '#e8f5f3' 'NestJS / Express' 
Caixa 1605 465 490 180 'PostgreSQL' '#edf2fa' 'Dados relacionais via Prisma'
Caixa 1605 695 490 180 'MinIO' '#edf2fa' 'Objetos e arquivos'
Caixa 1605 935 490 175 'Redis' '#f4f4f4' 'Provisionado; cache não demonstrado'
Encerrar 'diagramaArquiteturaTCC2.png'

# Modelo de dados: vínculos centrais; os atributos apresentados são os relevantes.
Iniciar 2400 1550
Texto 'Entidades e relações principais do esquema Prisma' 60 15 2280 70 $script:fonteTitulo $script:pincelEscuro $true
Seta @(270,265,420,265) '1:N' 310 215 100
Seta @(625,370,625,460,1070,460,1070,525) '1:N' 800 405 100
Seta @(955,370,955,490,1170,490,1170,525) '1:N' 990 440 100
Seta @(1320,370,1320,525) '1:N' 1335 430 100
Seta @(1700,370,1700,465,1450,465,1450,525) '1:N' 1500 405 100
Seta @(1540,715,1660,715) '1:N' 1555 655 100
Seta @(1790,1130,1790,925) '1:N' 1805 1010 100
Seta @(2130,1130,2130,925) '1:N' 2140 1010 100
Seta @(1080,875,1080,1040,920,1040) '0:N' 950 970 120
Seta @(1810,925,1810,1010,920,1010,920,1060) '0:N' 1390 950 120
Seta @(560,1170,390,1170) '1:N' 435 1110 100
Caixa 70 125 230 280 'Cidade' '#fff4da' "id (PK)`nCódigo IBGE`nCidade / UF"
Caixa 420 125 290 280 'Produtor' '#eef5f9' "id (PK)`norgId`ncidadeId (FK)"
Caixa 800 125 310 280 'Ponto de coleta' '#eef5f9' "id (PK)`norgId / cidadeId`nlat. / long."
Caixa 1180 125 280 280 'Abelha' '#eef5f9' "id (PK)`nNome científico"
Caixa 1540 125 320 280 'Tipo de amostra' '#eef5f9' "id (PK)`nNome"
Caixa 1020 525 520 350 'Amostra' '#e8f5f3' "id (PK) / orgId`nprodutorId / pontoColetaId`nabelhaId / tipoAmostraId`ndataColeta"
Caixa 1660 535 560 390 'Análise' '#e8f5f3' "id (PK) / orgId`namostraId / tipoAnaliseId`nresponsavelId`nstatus"
Caixa 1370 1130 335 230 'Responsável' '#eef5f9' "id (PK) / orgId`ncidadeId (FK)"
Caixa 1970 1130 350 230 'Tipo de análise' '#eef5f9' "id (PK)`nNome"
Caixa 560 1040 360 240 'Grupo de arquivos' '#fff4da' "id (PK) / orgId`namostraId? / analiseId?"
Caixa 70 1050 320 230 'Arquivo' '#fff4da' "id (PK)`nfileGroupId / url`ntipo"
Texto 'Cidade IBGE também é referência para ponto de coleta e responsável.' 500 1370 1450 48 $script:fonteNota $script:pincelCinza $true
Texto 'PK: chave primária    FK: chave estrangeira    ?: associação opcional' 500 1420 1450 48 $script:fonteNota $script:pincelCinza $true
Encerrar 'diagramaDadosTCC2.png'

# Casos de uso: atores e associações derivados das páginas e guardas da API.
function Ligacao([int] $x1, [int] $y1, [int] $x2, [int] $y2) {
    $linha = [System.Drawing.Pen]::new((Cor '#536b80'), 5)
    $script:g.DrawLine($linha, $x1, $y1, $x2, $y2)
    $linha.Dispose()
}

function Ator([int] $x, [int] $y, [string] $nome) {
    $linha = [System.Drawing.Pen]::new((Cor '#203955'), 7)
    $script:g.DrawEllipse($linha, ($x - 30), $y, 60, 60)
    $script:g.DrawLine($linha, $x, ($y + 60), $x, ($y + 137))
    $script:g.DrawLine($linha, ($x - 57), ($y + 90), ($x + 57), ($y + 90))
    $script:g.DrawLine($linha, $x, ($y + 137), ($x - 52), ($y + 200))
    $script:g.DrawLine($linha, $x, ($y + 137), ($x + 52), ($y + 200))
    Texto $nome ($x - 155) ($y + 210) 310 55 $script:fonteCaixa $script:pincelEscuro $true
    $linha.Dispose()
}

function Caso([int] $y, [string] $rotulo, [string] $fundoHex) {
    $fundo = [System.Drawing.SolidBrush]::new((Cor $fundoHex))
    $linha = [System.Drawing.Pen]::new((Cor '#203955'), 5)
    $script:g.FillEllipse($fundo, 620, $y, 1000, 108)
    $script:g.DrawEllipse($linha, 620, $y, 1000, 108)
    Texto $rotulo 675 ($y + 10) 890 88 $script:fonteCaso $script:pincelEscuro $true
    $linha.Dispose(); $fundo.Dispose()
}

Iniciar 2100 2300
$script:fonteCaso = [System.Drawing.Font]::new('Segoe UI', 32)
Texto 'Casos de uso da plataforma' 90 15 1920 78 $script:fonteTitulo $script:pincelEscuro $true
$limite = [System.Drawing.Pen]::new((Cor '#9fb1c1'), 5)
$script:g.DrawRectangle($limite, 480, 130, 1280, 2090)
$limite.Dispose()
Texto 'Plataforma NAPI Abelhas' 700 150 840 60 $script:fonteCaixa $script:pincelEscuro $true

# Associações sem seta: o ator inicia ou participa do caso de uso.
Ligacao 325 305 620 294
Ligacao 1815 305 1620 294
Ligacao 325 760 620 569
Ligacao 325 760 620 729
Ligacao 325 760 620 889
Ligacao 325 1540 620 1144
Ligacao 325 1540 620 1304
Ligacao 325 1540 620 1464
Ligacao 325 1540 620 1624
Ligacao 325 1540 620 1784
Ligacao 325 1540 620 1944

# Generalização: o administrador também possui as consultas do membro.
$heranca = [System.Drawing.Pen]::new((Cor '#536b80'), 5)
$script:g.DrawLines($heranca, [System.Drawing.Point[]] @(
    [System.Drawing.Point]::new(150, 1540),
    [System.Drawing.Point]::new(92, 1540),
    [System.Drawing.Point]::new(92, 760),
    [System.Drawing.Point]::new(132, 760)
))
$triangulo = [System.Drawing.Point[]] @(
    [System.Drawing.Point]::new(157, 760),
    [System.Drawing.Point]::new(132, 746),
    [System.Drawing.Point]::new(132, 774)
)
$branco = [System.Drawing.SolidBrush]::new((Cor '#ffffff'))
$script:g.FillPolygon($branco, $triangulo)
$script:g.DrawPolygon($heranca, $triangulo)
$branco.Dispose(); $heranca.Dispose()

Caso 240 'Autenticar-se na plataforma' '#eeeaf8'
Caso 515 'Consultar amostras' '#e8f5f3'
Caso 675 'Consultar análises e arquivos' '#e8f5f3'
Caso 835 'Consultar produtores' '#e8f5f3'
Caso 1090 'Cadastrar ou editar produtores' '#fff4da'
Caso 1250 'Cadastrar ou editar pontos de coleta' '#fff4da'
Caso 1410 'Cadastrar ou editar amostras' '#fff4da'
Caso 1570 'Registrar ou atualizar análises' '#fff4da'
Caso 1730 'Anexar arquivo a uma análise' '#fff4da'
Caso 1890 'Manter cadastros de apoio' '#fff4da'

Ator 245 210 'Visitante'
Ator 245 665 'Membro'
Ator 245 1450 'Administrador'
Ator 1900 210 'Clerk'
Texto 'O administrador herda as consultas do membro.' 655 2075 930 62 $script:fonteNota $script:pincelCinza $true
$script:fonteCaso.Dispose()
Encerrar 'diagramaCasosUsoTCC2.png'
