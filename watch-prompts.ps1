<#
  watch-prompts.ps1 - watch a folder; each new .txt file is sent as a prompt
  to the session via wake-session.ps1, then moved to a "sent" subfolder.

  Usage:
    .\watch-prompts.ps1 -SessionId <id>                    # watches .\inbox
    .\watch-prompts.ps1 -SessionId <id> -Inbox C:\prompts
    .\watch-prompts.ps1 -SessionId <id> -DryRun            # only print, don't send

  To send a prompt: drop a file into the inbox, e.g.
    "who is messi" | Set-Content .\inbox\q1.txt
  Stop with Ctrl+C.
#>
param(
  [string]$Inbox = (Join-Path $PSScriptRoot "inbox"),
  [Parameter(Mandatory = $true)][string]$SessionId,
  [string]$Dir = $PSScriptRoot,
  [switch]$DryRun
)

$sent = Join-Path $Inbox "sent"
New-Item -ItemType Directory -Force $Inbox, $sent | Out-Null
$wake = Join-Path $PSScriptRoot "wake-session.ps1"
Write-Host "Watching $Inbox (Ctrl+C to stop)..."

while ($true) {
  Get-ChildItem $Inbox -Filter *.txt -File | Sort-Object LastWriteTime | ForEach-Object {
    Start-Sleep -Milliseconds 300   # let the writer finish
    $prompt = (Get-Content $_.FullName -Raw).Trim()
    if ($prompt) {
      Write-Host "[$(Get-Date -f HH:mm:ss)] $($_.Name): $prompt"
      if (-not $DryRun) {
        & $wake -Prompt $prompt -SessionId $SessionId -Dir $Dir
      }
    }
    Move-Item $_.FullName (Join-Path $sent "$(Get-Date -f yyyyMMdd-HHmmss)-$($_.Name)") -Force
  }
  Start-Sleep -Seconds 2
}
