$files = Get-ChildItem .\..\src -File -Recurse -Include *

Invoke-Pester .\..\test -CodeCoverage $files