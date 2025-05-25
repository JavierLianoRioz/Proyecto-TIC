# Mide el tiempo de ejecución de docker-compose up -d
$startTime = Get-Date

# Inicia los servicios definidos en docker-compose.yml en modo desatendido
docker-compose up -d

$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Tiempo transcurrido: $($duration.TotalSeconds) segundos"

# Traquea el uso de CPU del sistema y RAM durante 1 minuto (60 segundos)
Write-Host "Monitoreando uso de CPU y RAM durante 1 minuto..."
$cpuSamples = @()
$ramSamples = @()

for ($i = 0; $i -lt 60; $i++) {
    try {
        $cpuLoad = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
        $os = Get-WmiObject Win32_OperatingSystem
        if ($cpuLoad -ne $null -and $os -ne $null) {
            $cpuSamples += $cpuLoad
            $totalMemory = $os.TotalVisibleMemorySize
            $freeMemory = $os.FreePhysicalMemory
            $usedMemoryPercent = [math]::Round((($totalMemory - $freeMemory) / $totalMemory) * 100, 2)
            $ramSamples += $usedMemoryPercent
        } else {
            Write-Host "Error: no se pudo obtener la carga de CPU o la memoria RAM."
            break
        }
    } catch {
        Write-Host "Error al obtener la carga de CPU o la memoria RAM: $_"
        break
    }
    Start-Sleep -Seconds 1
}

if ($cpuSamples.Count -gt 0) {
    $avgCpu = [math]::Round(($cpuSamples | Measure-Object -Average).Average, 2)
    Write-Host "Promedio de uso de CPU en 1 minuto: $avgCpu %"
} else {
    Write-Host "No se pudo monitorear el uso de CPU debido a errores en la obtención."
}

if ($ramSamples.Count -gt 0) {
    $avgRam = [math]::Round(($ramSamples | Measure-Object -Average).Average, 2)
    Write-Host "Promedio de uso de RAM en 1 minuto: $avgRam %"
} else {
    Write-Host "No se pudo monitorear el uso de RAM debido a errores en la obtención."
}

# Detiene los servicios de Docker
docker-compose down