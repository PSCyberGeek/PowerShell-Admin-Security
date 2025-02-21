# Get-SystemInfo.ps1
# Purpose: Retrieves basic system information including OS, CPU, and memory usage.
# Category: Admin
# Author: PSCyberGeek
# Creation Date: February 20, 2025
# Version: 1.0
# Usage: Run in PowerShell with .\Get-SystemInfo.ps1
# Requirements: Run with sufficient permissions to access system details (Admin recommended).

# Clear the console for a clean output
Clear-Host

# Write a header
Write-Host "=== System Information Report ===" -ForegroundColor Cyan
Write-Host "Generated on: $(Get-Date)" -ForegroundColor Cyan
Write-Host "Script Version: 1.0" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Get Operating System details
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "Operating System:" -ForegroundColor Green
Write-Host "  Name: $($os.Caption)"
Write-Host "  Version: $($os.Version)"
Write-Host "  Build: $($os.BuildNumber)"
Write-Host ""

# Get CPU details
$cpu = Get-CimInstance -ClassName Win32_Processor
Write-Host "Processor:" -ForegroundColor Green
Write-Host "  Name: $($cpu.Name)"
Write-Host "  Cores: $($cpu.NumberOfCores)"
Write-Host "  Load: $($cpu.LoadPercentage)%"
Write-Host ""

# Get Memory details
$memory = Get-CimInstance -ClassName Win32_OperatingSystem
$totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
$freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
$usedMemory = $totalMemory - $freeMemory
Write-Host "Memory:" -ForegroundColor Green
Write-Host "  Total: $totalMemory GB"
Write-Host "  Free: $freeMemory GB"
Write-Host "  Used: $usedMemory GB"

# Footer
Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Report complete." -ForegroundColor Cyan