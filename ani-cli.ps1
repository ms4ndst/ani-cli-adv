<#
ani-cli.ps1 — PowerShell wrapper for ani-cli (shell script)
Usage examples (PowerShell):
  .\ani-cli.ps1
  .\ani-cli.ps1 --dub "one piece" -q 1080p
Environment variables (set in PowerShell, inherited by bash):
  $Env:ANI_CLI_STARTUP_MENU = 0
  $Env:ANI_CLI_PLAYER = 'vlc'
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $Arguments
)

function Get-BashPath {
  # Prefer Git for Windows bash
  if ($Env:GIT_INSTALL_ROOT) {
    $p = Join-Path $Env:GIT_INSTALL_ROOT 'bin/bash.exe'
    if (Test-Path $p) { return $p }
  }
  $candidates = @(
    "$Env:ProgramFiles\Git\bin\bash.exe",
    "$Env:ProgramFiles(x86)\Git\bin\bash.exe"
  )
  foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
  # Fallback to PATH
  $which = (Get-Command bash -ErrorAction SilentlyContinue)?.Source
  if ($which) { return $which }
  throw "bash.exe not found. Install Git for Windows or add bash to PATH."
}

function Quote-ForBash([string] $s) {
  # Return a safely single-quoted bash string, replacing ' with '\''
  $sq = [char]39
  $s2 = $s -replace $sq, ($sq + '"' + $sq + '"' + $sq)
  return $sq + $s2 + $sq
}

$bash = Get-BashPath
$herePosix = ($PSScriptRoot -replace '\\','/')

# Quote each argument for bash safely
$argStr = ''
if ($Arguments -and $Arguments.Count -gt 0) {
  $argStr = ($Arguments | ForEach-Object { Quote-ForBash $_ }) -join ' '
}

$cmd = ('cd "{0}" && ./ani-cli {1}' -f $herePosix, $argStr)

# Inherit current environment; run login shell to load bash defaults
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $bash
$psi.ArgumentList.Add('-lc')
$psi.ArgumentList.Add($cmd)
$psi.RedirectStandardInput = $false
$psi.RedirectStandardOutput = $false
$psi.RedirectStandardError = $false
$psi.UseShellExecute = $false

$p = [System.Diagnostics.Process]::Start($psi)
$p.WaitForExit()
exit $p.ExitCode
