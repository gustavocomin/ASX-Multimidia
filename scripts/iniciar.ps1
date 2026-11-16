#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$logDirectory = Join-Path $projectRoot 'logs'
$now = [DateTimeOffset]::UtcNow
$stamp = $now.ToString('yyyyMMdd-HHmmssZ')
$runId = [guid]::NewGuid().ToString('N').Substring(0, 10)
$reportPath = Join-Path $logDirectory "inventario-$stamp-$runId.md"

if (-not $PSCmdlet.ShouldProcess($reportPath, 'Inventariar o Windows e gravar relatório local')) {
    return
}

$lines = @(
    '# Inventário local — ASX Multimídia'
    ''
    ('Data (UTC) · {0}' -f $now.ToString('u'))
    ''
    'O inventário descreve o computador que executou o script. A conectividade com a central depende de verificação própria.'
    ''
    '## Ambiente'
    ''
)
try {
    $windows = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption, Version, BuildNumber
    $lines += '- Windows · {0}, versão {1}, compilação {2}' -f $windows.Caption, $windows.Version, $windows.BuildNumber
}
catch {
    $lines += '- Versão do Windows indisponível.'
}
$lines += @(
    ('- PowerShell · {0} ({1})' -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition)
    ''
    '| Ferramenta | Encontrada no PATH |'
    '| --- | --- |'
)
foreach ($name in 'codex', 'claude', 'git', 'python', 'adb', 'pwsh', 'netsh') {
    $command = Get-Command -Name $name -CommandType Application, ExternalScript -ErrorAction SilentlyContinue
    $status = if ($command) { 'Sim' } else { 'Não' }
    $lines += "| $name | $status |"
}

$lines += @('', '## Dispositivos USB presentes no Windows', '')
try {
    $usbCodes = foreach ($device in (Get-PnpDevice -PresentOnly)) {
        $usbId = [regex]::Match(
            $device.InstanceId,
            '^USB\\VID_([0-9A-F]{4})&PID_([0-9A-F]{4})(?:[&\\]|$)',
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
        if ($usbId.Success) {
            '{0} | {1}' -f $usbId.Groups[1].Value.ToUpperInvariant(), $usbId.Groups[2].Value.ToUpperInvariant()
        }
    }

    if ($usbCodes) {
        $lines += '| VID | PID | Entradas PnP |', '| --- | --- | ---: |'
        foreach ($group in ($usbCodes | Group-Object | Sort-Object Name)) {
            $lines += '| {0} | {1} |' -f $group.Name, $group.Count
        }
        $lines += '', 'Um dispositivo pode gerar mais de uma entrada PnP.'
    }
    else {
        $lines += 'Nenhuma entrada USB com VID/PID disponível.'
    }
}
catch {
    $lines += 'Inventário USB indisponível.'
}

$lines += @('', '## Adaptadores de rede', '')
try {
    $adapters = @(Get-NetAdapter -Physical)
    $active = @($adapters | Where-Object Status -eq 'Up').Count
    $lines += @(
        '| Estado | Contagem |'
        '| --- | ---: |'
        "| Adaptadores físicos | $($adapters.Count) |"
        "| Adaptadores físicos ativos | $active |"
    )
}
catch {
    $lines += 'Inventário de rede indisponível.'
}

$lines += @(
    ''
    '## Central multimídia'
    ''
    'Interface de diagnóstico da ZCD9200-6956-MIPI-5G ainda sem comprovação. O acesso à central depende de documentação da revisão e identificação da interface.'
)

[IO.Directory]::CreateDirectory($logDirectory) | Out-Null
[IO.File]::WriteAllLines($reportPath, $lines, [Text.UTF8Encoding]::new($true))
Write-Host "Inventário salvo em $reportPath"
