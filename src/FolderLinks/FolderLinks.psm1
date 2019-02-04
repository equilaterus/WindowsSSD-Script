function LinkFolder {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath,
        [bool] $IgnoreExtraFiles = $false
    )

    # Create destination folder
    $DestinationPathExists = Test-Path -Path $DestinationPath
    if (!$DestinationPathExists) {
        $null = New-Item -ItemType Directory -Path $DestinationPath
    } elseif (!$IgnoreExtraFiles) {
        return $false
    }

    # Move origin
    $OriginPathExists = Test-Path -Path $OriginPath
    if (!$OriginPathExists) {
        # Ensure subpath is created 
        # (later on, it removes last folder in the path and it will crash if it is not found)
        $null = New-Item -ItemType Directory -Path $OriginPath
    } else {
        $null = Move-Item -Path $($OriginPath + '*') -Destination $DestinationPath -ErrorVariable +err -ErrorAction 0
        if ($err) {
            return $false
        }        
    }

    # Remove empty folder
    $null = Remove-Item -Path $OriginPath -Force

    # Create link
    $null = New-Item -Path $OriginPath -ItemType SymbolicLink -Value $DestinationPath -ErrorVariable +err -ErrorAction 0
    if ($err) {
        return $false
    }      
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