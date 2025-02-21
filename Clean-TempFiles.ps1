# Clean-TempFiles.ps1
# Purpose: Deletes temporary files from common Windows locations to free up disk space.
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
Write-Host "Script Version: 1.0" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Define temp directories
$tempDirs = @(
    $env:TEMP,                            # Current user's temp folder
    "$env:windir\Temp"                    # System temp folder
)

# Initialize counters
$totalFilesDeleted = 0
$totalSpaceFreed = 0

# Loop through each directory
foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        Write-Host "Cleaning: $dir" -ForegroundColor Green
        $files = Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            try {
                $fileSize = $file.Length / 1KB  # Size in KB
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                $totalFilesDeleted++
                $totalSpaceFreed += $fileSize
                Write-Host "  Deleted: $($file.Name) ($([math]::Round($fileSize, 2)) KB)" -ForegroundColor Yellow
            } catch {
                Write-Host "  Error deleting $($file.Name): $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Directory not found: $dir" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "Cleanup complete." -ForegroundColor Cyan
Write-Host "Files deleted: $totalFilesDeleted" -ForegroundColor Cyan
Write-Host "Space freed: $([math]::Round($totalSpaceFreed / 1024, 2)) MB" -ForegroundColor Cyan