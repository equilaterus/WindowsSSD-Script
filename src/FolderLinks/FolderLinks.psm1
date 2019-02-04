function LinkFolder {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath,
        [bool] $IgnoreExtraFiles = $false
    )

    # Create destination folder
    $DestinationPathExists = Test-Path -Path $DestinationPath
    if (!$DestinationPathExists) {
        New-Item -ItemType Directory -Path $DestinationPath
    } elseif (!$IgnoreExtraFiles) {
        return $false
    }

    # Move origin
    $OriginPathExists = Test-Path -Path $OriginPath
    if (!$OriginPathExists) {
        # Ensure subpath is created 
        # (later on it removes last folder in the path)
        New-Item -ItemType Directory -Path $OriginPath
    } else {
        Move-Item -Path $($OriginPath + '*') -Destination $DestinationPath -ErrorVariable +err -ErrorAction 0
        if ($err) {
            return $false
        }        
    }

    # Remove empty folder
    Remove-Item -Path $OriginPath -Force

    # Create link
    New-Item -Path $OriginPath -ItemType SymbolicLink -Value $DestinationPath
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