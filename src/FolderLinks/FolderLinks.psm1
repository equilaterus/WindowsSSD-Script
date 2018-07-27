function LinkFolder {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath,
        [bool] $IgnoreExtraFiles = $false
    )

    $PathExists = Test-Path -Path $DestinationPath
    if (!$PathExists) {
        New-Item -ItemType Directory -Force -Path $DestinationPath
    } elseif (!$IgnoreExtraFiles) {
        return $false
    }

    Move-Item -Path $($OriginPath + '*') -Destination $DestinationPath
    Remove-Item -Path $OriginPath -Force
    New-Item -Path $OriginPath  -ItemType SymbolicLink -Value $($DestinationPath)
    return $true
}

function IsLinked {
    param(
        [Parameter(Mandatory=$true)][string] $Path
    )

    $File = Get-Item $Path -Force -ea SilentlyContinue
    return [bool]($File.Attributes -band [IO.FileAttributes]::ReparsePoint)
  }

Export-ModuleMember -Function LinkFolder, IsLinked