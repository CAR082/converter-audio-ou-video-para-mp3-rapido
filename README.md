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
