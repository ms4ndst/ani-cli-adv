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

function Convert-ToMsysPath([string] $p) {
  # Convert e.g. C:\Users\me\path -> /c/Users/me/path
  $p = [System.IO.Path]::GetFullPath($p)
  $drive = $p.Substring(0,1).ToLowerInvariant()
  $rest = $p.Substring(2) -replace '\\','/'
  return "/$drive/$rest"
}

$bash = Get-BashPath
$herePosix = ($PSScriptRoot -replace '\\','/')

# Build a list of extra PATH segments for Git Bash (ensures Scoop-installed tools are visible)
$extraPaths = New-Object System.Collections.Generic.List[string]

# Scoop (per-user)
$scoopUser = Join-Path $Env:USERPROFILE 'scoop\shims'
if (Test-Path $scoopUser) { $extraPaths.Add($scoopUser) }

# Scoop (system-wide)
if ($Env:SCOOP) {
  $scoopGlobal = Join-Path $Env:SCOOP 'shims'
  if (Test-Path $scoopGlobal) { $extraPaths.Add($scoopGlobal) }
}
$progDataScoop = Join-Path $Env:ProgramData 'scoop\shims'
if (Test-Path $progDataScoop) { $extraPaths.Add($progDataScoop) }

# Git for Windows unix tools (grep/sed/cut), just in case
$gitUsrBin = Join-Path $Env:ProgramFiles 'Git\usr\bin'
if (Test-Path $gitUsrBin) { $extraPaths.Add($gitUsrBin) }

# Also include locations of tools as seen by PowerShell (robust across managers)
$toolNames = @('fzf','mpv','ffmpeg','yt-dlp','aria2c')
foreach ($name in $toolNames) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) {
    try {
      $dir = Split-Path -Parent $cmd.Source
      if ($dir -and (Test-Path $dir)) { $extraPaths.Add($dir) }
    } catch {}
  }
}

# Deduplicate while preserving order
$extraPaths = [System.Collections.ArrayList](@($extraPaths | Select-Object -Unique))

# Convert to MSYS style and join for in-bash export
$msysExtra = $extraPaths | ForEach-Object { Convert-ToMsysPath $_ }
$prepend = ($msysExtra -join ':')
# Also prepare Windows-style PATH prefix for the process env (more reliable for MSYS PATH conversion)
$winExtra = ($extraPaths -join ';')

# Quote each argument for bash safely
$argStr = ''
if ($Arguments -and $Arguments.Count -gt 0) {
  $argStr = ($Arguments | ForEach-Object { Quote-ForBash $_ }) -join ' '
}

$pre = ''
if ($prepend) { $pre = "export PATH=\"$prepend:\$PATH\"; hash -r; " }
$cmd = ("{0}cd \"{1}\" && ./ani-cli {2}" -f $pre, $herePosix, $argStr)

# Inherit current environment; run login shell to load bash defaults
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $bash
$psi.ArgumentList.Add('-lc')
$psi.ArgumentList.Add($cmd)
$psi.RedirectStandardInput = $false
$psi.RedirectStandardOutput = $false
$psi.RedirectStandardError = $false
$psi.UseShellExecute = $false
# Prepend shims to the PATH seen by bash (Windows-style; MSYS will convert)
if ($winExtra) {
  $psi.EnvironmentVariables['PATH'] = ($winExtra + ';' + [System.Environment]::GetEnvironmentVariable('PATH','Process'))
}

if ($Env:ANI_CLI_PS_VERBOSE -eq '1') {
  Write-Host "Launching bash: $($psi.FileName)" -ForegroundColor Cyan
  Write-Host "Command: $($psi.ArgumentList -join ' ')" -ForegroundColor DarkCyan
  Write-Host "Prepended PATH (process env): $winExtra" -ForegroundColor DarkGray
}
$p = [System.Diagnostics.Process]::Start($psi)
$p.WaitForExit()
exit $p.ExitCode
