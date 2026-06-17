#!/usr/bin/env pwsh
# Build the three resume PDFs (one US Letter page each) from resume.md.
# Regenerates dist/*.html, then prints each theme to dist/*.pdf with headless
# Chrome or Edge. No LaTeX. Run from anywhere:  ./build-pdf.ps1
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# Ensure dependencies, then rebuild the HTML from the Markdown source.
if (-not (Test-Path "node_modules")) { npm install }
node build.mjs

# Find a Chromium-based browser.
$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $browser) {
  throw "No Chrome or Edge found. Open dist/*.html in a browser and use Ctrl+P -> Save as PDF."
}

# Wait until $path exists with a stable, non-zero size. Headless Chrome on Windows
# returns before its child process finishes writing the PDF, so a plain check races.
function Wait-StableFile([string]$path, [int]$timeoutSec = 30) {
  $deadline = (Get-Date).AddSeconds($timeoutSec)
  $last = -1
  while ((Get-Date) -lt $deadline) {
    if (Test-Path $path) {
      $len = (Get-Item $path).Length
      if ($len -gt 0 -and $len -eq $last) { return $true }
      $last = $len
    }
    Start-Sleep -Milliseconds 250
  }
  return ((Test-Path $path) -and ((Get-Item $path).Length -gt 0))
}

# Print each theme to a one-page PDF. A throwaway --user-data-dir forces a fresh
# headless instance; without it a running Chrome can swallow --print-to-pdf.
# (If a future Chrome drops --headless=old, change it to --headless.)
foreach ($theme in "minimal", "modern", "classic") {
  $html = "file:///" + ((Join-Path $PSScriptRoot "dist\$theme.html") -replace '\\', '/')
  $pdf  = Join-Path $PSScriptRoot "dist\$theme.pdf"
  if (Test-Path $pdf) { Remove-Item $pdf -Force }
  $profileDir = Join-Path $env:TEMP ("resume-pdf-" + [System.Guid]::NewGuid())
  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
  try {
    & $browser --headless=old --disable-gpu --no-first-run --no-pdf-header-footer `
        --user-data-dir="$profileDir" "--print-to-pdf=$pdf" $html 2>$null
    if (-not (Wait-StableFile $pdf)) { throw "Failed to write $pdf" }
  } finally {
    Remove-Item -Recurse -Force $profileDir -ErrorAction SilentlyContinue
  }
  Write-Host "wrote dist/$theme.pdf"
}
Write-Host "Done. PDFs are in dist/."
