param(
  [string] $Filter = 'smoke-*'
)

function Get-BashPath {
  if ($Env:GIT_INSTALL_ROOT) {
    $p = Join-Path $Env:GIT_INSTALL_ROOT 'bin/bash.exe'
    if (Test-Path $p) { return $p }
  }
  $candidates = @(
    "$Env:ProgramFiles\Git\bin\bash.exe",
    "$Env:ProgramFiles(x86)\Git\bin\bash.exe"
  )
  foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
  $which = (Get-Command bash -ErrorAction SilentlyContinue)?.Source
  if ($which) { return $which }
  throw "bash.exe not found. Install Git for Windows or add bash to PATH."
}

$bash = Get-BashPath
$tests = Get-ChildItem -File -Path $PSScriptRoot -Filter $Filter | Where-Object { $_.Extension -eq '.sh' }
if (-not $tests) { Write-Error "No tests matched '$Filter'"; exit 1 }

foreach ($t in $tests) {
Write-Host "Running: $($t.FullName)" -ForegroundColor Cyan
  $rootPosix = ($PSScriptRoot -replace '\\','/')
  $cmd = ('cd "{0}" && sh "./{1}"' -f $rootPosix, $t.Name)
  & $bash -lc $cmd
  if ($LASTEXITCODE -ne 0) { throw "Test failed: $($t.Name)" }
}

Write-Host 'All tests passed' -ForegroundColor Green
