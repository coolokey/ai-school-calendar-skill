param(
  [Parameter(Mandatory = $true)]
  [string]$TargetDir,

  [string]$SchoolFullName = "桃園市立大溪國民中學",
  [string]$SchoolShortName = "大溪國中",
  [string]$GasWebappUrl = "https://script.google.com/macros/s/REPLACE_WITH_YOUR_DEPLOYMENT_ID/exec"
)

$ErrorActionPreference = "Stop"
$TemplateDir = Join-Path $PSScriptRoot "..\resources\template"

if (-not (Test-Path $TemplateDir)) {
  throw "找不到範本目錄：$TemplateDir"
}

New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "tests") | Out-Null
Copy-Item (Join-Path $TemplateDir "gas_code.gs") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "index.html") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "appsscript.json") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir ".claspignore") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "tests\safety.test.cjs") (Join-Path $TargetDir "tests") -Force

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 1. 更新 gas_code.gs
$codePath = Join-Path $TargetDir "gas_code.gs"
$code = [System.IO.File]::ReadAllText($codePath, [System.Text.Encoding]::UTF8)
$code = $code.Replace("桃園市立大溪國民中學", $SchoolFullName)
$code = $code.Replace("大溪國中", $SchoolShortName)
[System.IO.File]::WriteAllText($codePath, $code, $Utf8NoBom)

# 2. 更新 index.html
$htmlPath = Join-Path $TargetDir "index.html"
$html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
$html = $html.Replace("桃園市立大溪國民中學", $SchoolFullName)
$html = $html.Replace("大溪國中", $SchoolShortName)
if ($GasWebappUrl -and $GasWebappUrl -ne "https://script.google.com/macros/s/REPLACE_WITH_YOUR_DEPLOYMENT_ID/exec") {
  $html = [regex]::Replace($html, "const DEFAULT_GAS_URL = 'https://script\.google\.com/macros/s/[^']+/exec';", "const DEFAULT_GAS_URL = '$GasWebappUrl';")
}
[System.IO.File]::WriteAllText($htmlPath, $html, $Utf8NoBom)

# 3. 同步更新測試腳本中的學校名稱斷言
$testPath = Join-Path $TargetDir "tests\safety.test.cjs"
$testJs = [System.IO.File]::ReadAllText($testPath, [System.Text.Encoding]::UTF8)
$testJs = $testJs.Replace("桃園市立大溪國民中學", $SchoolFullName)
$testJs = $testJs.Replace("大溪國民中學", $SchoolFullName)
$testJs = $testJs.Replace("大溪國中", $SchoolShortName)
[System.IO.File]::WriteAllText($testPath, $testJs, $Utf8NoBom)

Write-Output "SCAFFOLD_OK: $TargetDir ($SchoolFullName / $SchoolShortName)"
