Set-Location -Path $PSScriptRoot

$files = Get-ChildItem .\..\src -File -Recurse -Include * -Exclude *.Tests.*

Invoke-Pester .\..\src -CodeCoverage $files