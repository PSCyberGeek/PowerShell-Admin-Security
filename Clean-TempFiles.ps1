# Clean-TempFiles.ps1
# Purpose: Deletes temporary files from common Windows locations, with preview, retry, and CSV logging options.
# Category: Admin
# Author: PSCyberGeek
# Creation Date: February 20, 2025
# Version: 1.0
# Usage: Run in PowerShell with .\Clean-TempFiles.ps1 (Admin privileges recommended).
# Requirements: Run as Administrator for full access to all temp directories.

# Clear the console
Clear-Host

# Write a header
Write-Host "=== Temporary File Cleanup ===" -ForegroundColor Cyan
Write-Host "Started on: $(Get-Date)" -ForegroundColor Cyan
Write-Host "Script Version: 1.3" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Define temp directories and log file
$tempDirs = @(
    $env:TEMP,                            # Current user's temp folder
    "$env:windir\Temp"                    # System temp folder
)
$logFile = "$PSScriptRoot\skipped_files_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# Initialize counters and collections
$totalFilesDeleted = 0
$totalSpaceFreed = 0
$filesToDelete = @()
$skippedFiles = @()

# Preview mode: Collect files first
Write-Host "Scanning temp directories for files..." -ForegroundColor Green
foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        $files = Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $filesToDelete += [PSCustomObject]@{
                Path = $file.FullName
                SizeKB = [math]::Round($file.Length / 1KB, 2)
            }
        }
    } else {
        Write-Host "Directory not found: $dir" -ForegroundColor Red
    }
}

# Show preview and get confirmation
Write-Host ""
Write-Host "Files found: $($filesToDelete.Count)" -ForegroundColor Yellow
Write-Host "Sample of files to delete (first 10):" -ForegroundColor Yellow
$filesToDelete | Select-Object -First 10 | ForEach-Object {
    Write-Host "  $($_.Path) ($($_.SizeKB) KB)"
}
Write-Host ""
$confirm = Read-Host "Proceed with deletion? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cleanup aborted by user." -ForegroundColor Red
    exit
}

# Deletion process with retry and CSV logging
foreach ($file in $filesToDelete) {
    Write-Host "Attempting: $($file.Path)" -ForegroundColor Green
    try {
        Remove-Item -Path $file.Path -Force -ErrorAction Stop
        $totalFilesDeleted++
        $totalSpaceFreed += $file.SizeKB
        Write-Host "  Deleted: $($file.Path) ($($file.SizeKB) KB)" -ForegroundColor Yellow
    } catch {
        Write-Host "  Error: $($file.Path) - $_" -ForegroundColor Red
        $retry = Read-Host "  Retry deletion? (Y/N)"
        if ($retry -eq "Y" -or $retry -eq "y") {
            try {
                Remove-Item -Path $file.Path -Force -ErrorAction Stop
                $totalFilesDeleted++
                $totalSpaceFreed += $file.SizeKB
                Write-Host "  Deleted on retry: $($file.Path) ($($file.SizeKB) KB)" -ForegroundColor Yellow
            } catch {
                Write-Host "  Failed again: $($file.Path) - $_" -ForegroundColor Red
                $skippedFiles += [PSCustomObject]@{
                    Path = $file.Path
                    SizeKB = $file.SizeKB
                    Reason = $_.Exception.Message
                }
            }
        } else {
            $skippedFiles += [PSCustomObject]@{
                Path = $file.Path
                SizeKB = $file.SizeKB
                Reason = "Skipped by user"
            }
        }
    }
}

# Log skipped files as CSV if any
if ($skippedFiles.Count -gt 0) {
    Write-Host "Logging $($skippedFiles.Count) skipped files to $logFile" -ForegroundColor Yellow
    $skippedFiles | Export-Csv -Path $logFile -NoTypeInformation
}

# Summary
Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "Cleanup complete." -ForegroundColor Cyan
Write-Host "Files deleted: $totalFilesDeleted" -ForegroundColor Cyan
Write-Host "Space freed: $([math]::Round($totalSpaceFreed / 1024, 2)) MB" -ForegroundColor Cyan
if ($skippedFiles.Count -gt 0) {
    Write-Host "Skipped files logged: $($skippedFiles.Count) (see $logFile)" -ForegroundColor Cyan
}
