#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $projectRoot 'scripts/iniciar.ps1'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw 'Contrato do kit: scripts/iniciar.ps1 deve ser o ponto de entrada.'
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('asx-teste-' + [guid]::NewGuid().ToString('N'))
$scriptDir = Join-Path $tempRoot 'scripts'
$logDir = Join-Path $tempRoot 'logs'
$entry = Join-Path $scriptDir 'iniciar.ps1'

# Respostas controladas dos provedores do Windows para testar dados sensíveis.
function Get-PnpDevice {
    [CmdletBinding()]
    param([switch]$PresentOnly)
    if ($providerFailure) { throw 'ERRO_PRIVADO_USB' }
    [pscustomobject]@{ InstanceId = 'USB\VID_AB12&PID_CD34\SERIAL_PRIVADO'; FriendlyName = 'NOME_PRIVADO_USB' }
    [pscustomobject]@{ InstanceId = 'USB\VID_AB12&PID_CD34&MI_00\OUTRO_SERIAL'; FriendlyName = 'NOME_PRIVADO_USB' }
    [pscustomobject]@{ InstanceId = 'USB\ROOT_HUB30\OUTRO_SERIAL'; FriendlyName = 'NOME_PRIVADO_USB' }
    [pscustomobject]@{ InstanceId = 'PCI\VID_ABCD&PID_EF00\OUTRO_SERIAL'; FriendlyName = 'NOME_PRIVADO_USB' }
}
function Get-NetAdapter {
    [CmdletBinding()]
    param([switch]$Physical)
    if ($providerFailure) { throw 'ERRO_PRIVADO_REDE' }
    [pscustomobject]@{ Status = 'Up'; Name = 'NOME_PRIVADO_REDE'; MacAddress = '00-12-34-56-78-9A' }
    [pscustomobject]@{ Status = 'Disconnected'; Name = 'OUTRA_REDE'; MacAddress = '00-12-34-56-78-9B' }
}
function Get-CimInstance {
    [CmdletBinding()]
    param([string]$ClassName, [string[]]$Property)
    if ($providerFailure) { throw 'ERRO_PRIVADO_WINDOWS' }
    [pscustomobject]@{ Caption = 'Windows de teste'; Version = '10.0.12345'; BuildNumber = '12345'; CSName = 'NOME_PRIVADO_PC' }
}

try {
    [IO.Directory]::CreateDirectory($scriptDir) | Out-Null
    Copy-Item -LiteralPath $source -Destination $entry

    $providerFailure = $false
    & $entry -WhatIf
    if (Test-Path -LiteralPath $logDir) { throw 'O modo WhatIf criou a pasta de logs.' }

    & $entry
    $files = @(Get-ChildItem -LiteralPath $logDir -File)
    if ($files.Count -ne 1) { throw 'A primeira execução deve gerar um arquivo.' }
    $report = [IO.File]::ReadAllText($files[0].FullName)
    if ($report -notmatch '\| AB12 \| CD34 \| 2 \|' -or $report -match '\bEF00\b') {
        throw 'O relatório deve agrupar interfaces USB por VID/PID e excluir dispositivos PCI.'
    }
    if ($report -notmatch '\| Adaptadores físicos \| 2 \|' -or $report -notmatch '\| Adaptadores físicos ativos \| 1 \|') {
        throw 'O relatório deve conter somente contagens de adaptadores.'
    }
    if ($report -notmatch 'Windows de teste' -or $report -notmatch '10\.0\.12345' -or $report -notmatch '\| adb \|') {
        throw 'Inventário do ambiente incompleto.'
    }
    if ($report -match 'PRIVAD[OA]|OUTRO_SERIAL|OUTRA_REDE|00-12-34-56-78-9[AB]') {
        throw 'O relatório gravou um identificador privado.'
    }

    $providerFailure = $true
    & $entry
    $newFiles = @(Get-ChildItem -LiteralPath $logDir -File | Where-Object { $_.Name -ne $files[0].Name })
    if ($newFiles.Count -ne 1) { throw 'Uma falha de provedor deve permitir um novo relatório.' }
    $incomplete = [IO.File]::ReadAllText($newFiles[0].FullName)
    if ($incomplete -notmatch 'Inventário USB indisponível' -or
        $incomplete -notmatch 'Inventário de rede indisponível' -or
        $incomplete -notmatch 'Versão do Windows indisponível' -or
        $incomplete -match 'ERRO_PRIVADO') {
        throw 'Falhas de provedores devem aparecer sem expor a exceção bruta.'
    }

    Write-Host 'Passou: simulação, inventário, privacidade e falhas parciais.'
}
finally {
    if (Test-Path -LiteralPath $logDir) {
        Get-ChildItem -LiteralPath $logDir -Filter 'inventario-*.md' -File |
            Remove-Item -ErrorAction Stop
        [IO.Directory]::Delete($logDir)
    }
    if ([IO.File]::Exists($entry)) { [IO.File]::Delete($entry) }
    if ([IO.Directory]::Exists($scriptDir)) { [IO.Directory]::Delete($scriptDir) }
    if ([IO.Directory]::Exists($tempRoot)) { [IO.Directory]::Delete($tempRoot) }
}
