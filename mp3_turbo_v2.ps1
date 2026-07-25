# Conversão rápida para mp3 by CARO versão 2.0

# como usar o script
# coloque ele numa pasta que tenha algum arquivo de audio ou video de preferencia LONGO de horas , que tu queria converter para mp3
# ai basta abrir o terminal powershell do windows nesta lugar com o arquivo e o script no mesmo lugar e executar estes comandos
# powershell -ExecutionPolicy Bypass -File .\mp3_turbo_v1.ps1 "MUCALOL + 4NALOG + MYLON - Flow #626.aac" | Tee-Object log.txt 
# o comando acima vai converter o arquivo para mp3 128kbps , se não for dito a ele qual bitrate o comando abaixo é especificando o bitrate
# powershell -ExecutionPolicy Bypass -File .\mp3_turbo_v1.ps1 "MUCALOL + 4NALOG + MYLON - Flow #626.aac" 96k | Tee-Object log.txt
# agora neste comando acima, eu especifiquei o bitrate para 96kbps de qualidade do mp3 final.
# este script foi desenvolvido, porque o mp3 se for longo, vai demorar demais para converter se tu converter ele direto, sem dividir em várias partes e converter ele de forma separada,
# pois o processamento do mp3 se não for divido, quando é arquivo longos tipo 10 horas , ele demora algo em torno de 50minutos num xeon 2650 V2 para converter, e deste modo, demora tipo 5min agora

# ===== INÍCIO DO TIMER =====
$START_TIME = Get-Date

# ===== CAMINHO DO FFMPEG =====
$FFMPEG = "C:\ffmpeg-6.1.1-full_build\bin\ffmpeg.exe"
$FFPROBE = "C:\ffmpeg-6.1.1-full_build\bin\ffprobe.exe"

# fallback
if (!(Test-Path $FFMPEG)) { $FFMPEG = "ffmpeg" }
if (!(Test-Path $FFPROBE)) { $FFPROBE = "ffprobe" }

# ===== CONFIG =====
$BITRATE = "128k"
$THREADS = [Environment]::ProcessorCount

$INPUT = $args[0]
$BITRATE_USER = $args[1]

if (-not $INPUT) { exit }

if (!(Test-Path $INPUT)) {
    Write-Host "Arquivo não encontrado"
    exit
}

if ($BITRATE_USER) { $BITRATE = $BITRATE_USER }

$NOME = [System.IO.Path]::GetFileNameWithoutExtension($INPUT)

# ===== DURAÇÃO =====
$DURACAO = & $FFPROBE -v error -show_entries format=duration `
-of default=noprint_wrappers=1:nokey=1 "$INPUT"

$DURACAO = [int][double]$DURACAO

$TEMPO_POR_PARTE = [int]($DURACAO / $THREADS)
if ($TEMPO_POR_PARTE -lt 1) { $TEMPO_POR_PARTE = 1 }

# ===== PASTAS =====
mkdir partes_wav -Force | Out-Null
mkdir partes_mp3 -Force | Out-Null

Write-Host "Dividindo..."

# ===== DIVIDIR =====
& $FFMPEG -y -i "$INPUT" -f segment -segment_time $TEMPO_POR_PARTE `
-c:a pcm_s16le "partes_wav/parte_%03d.wav"

Write-Host "Convertendo paralelo REAL..."

# ===== PROCESSOS =====
$processes = @()

Get-ChildItem partes_wav -Filter *.wav | ForEach-Object {

    $in = $_.FullName
    $out = "partes_mp3\$($_.BaseName).mp3"

    $p = Start-Process $FFMPEG -ArgumentList @(
        "-y","-i","`"$in`"","-vn",
        "-c:a","libmp3lame","-b:a",$BITRATE,
        "`"$out`""
    ) -NoNewWindow -PassThru

    $processes += $p
}

# ===== ESPERAR =====
$processes | ForEach-Object { $_.WaitForExit() }

# ===== VERIFICAR =====
$files = Get-ChildItem partes_mp3 -Filter *.mp3 | Sort-Object Name

if ($files.Count -eq 0) {
    Write-Host "ERRO: nenhum MP3 gerado"
    exit
}

Write-Host "Juntando..."

# ===== LISTA =====
$lista = @()
foreach ($f in $files) {
    $path = $f.FullName -replace '\\','/'
    $lista += "file '$path'"
}

$lista | Out-File -Encoding ASCII lista.txt

# ===== CONCAT =====
& $FFMPEG -y -f concat -safe 0 -i lista.txt -c copy "$NOME.mp3"

# ===== LIMPEZA =====
Remove-Item partes_wav, partes_mp3 -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item lista.txt -ErrorAction SilentlyContinue

# ===== TIMER =====
$TOTAL = (Get-Date) - $START_TIME

Write-Host "Finalizado: $NOME.mp3"
Write-Host ("Tempo total: {0:hh\:mm\:ss}" -f $TOTAL)
