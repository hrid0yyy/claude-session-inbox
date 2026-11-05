<#
  wake-session.ps1 - resume a Claude Code session and send it a prompt.

  Usage:
    .\wake-session.ps1 -SessionId <id> -Prompt "your prompt here"
    .\wake-session.ps1 -SessionId <id> -Prompt "your prompt" -Dir "C:\path\to\project"
    .\wake-session.ps1 -SessionId <id> -Prompt "your prompt" -Delay 10m   # wait first (s/m/h)

  Notes:
    - Uses `claude --resume <id> -p`, which appends the prompt and Claude's reply
      to that session's transcript.
    - Run it from the same folder the session was started in (or pass -Dir),
      because sessions are stored per project folder.
#>
param(
  [Parameter(Mandatory = $true)][string]$Prompt,
  [Parameter(Mandatory = $true)][string]$SessionId,
  [string]$Dir = (Get-Location).Path,
  [string]$Delay = ""
)

if ($Delay -match '^(\d+)([smh])$') {
  $n = [int]$Matches[1]
  $secs = switch ($Matches[2]) { 's' { $n } 'm' { $n * 60 } 'h' { $n * 3600 } }
  Write-Host "Waiting $Delay before waking session..."
  Start-Sleep -Seconds $secs
}

Set-Location $Dir
claude --resume $SessionId -p $Prompt
