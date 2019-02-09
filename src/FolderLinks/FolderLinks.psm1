function LinkFolder {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath,
        [bool] $IgnoreExtraFiles = $false
    )

    if (!(Test-Path -Path $DestinationPath)) {
        # Create destination folder
        $null = New-Item -ItemType Directory -Path $DestinationPath
    } elseif (!$IgnoreExtraFiles) {
        # If exists -> ensure IgnoreExtraFiles is true
        return $false;
    }

    if (!(Test-Path -Path $OriginPath)) {
        # Ensure subpath is created 
        # (later on, it removes last folder in the path and it will crash if it is not found)
        $null = New-Item -ItemType Directory -Path $OriginPath
    } else {
        
        # Move origin
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

function ReLinkFolder {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath
    )

    if (!(IsLinked -Path $OriginPath)) {
        return $false
    }

    # Create destination path if necessary
    if (!(Test-Path -Path $DestinationPath)) {
        $null = New-Item -ItemType Directory -Path $DestinationPath
    }
    # Move current folder
    $currentFolder = GetLinkFor -Path $OriginPath
    $null = Move-Item -Path $($currentFolder + '*') -Destination $DestinationPath -ErrorVariable +err -ErrorAction 0
    if ($err) {       
        return $false
    }   

    # Re-create link
    $null = (Get-Item $OriginPath).Delete()
    return LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true
}

function GetLinkFor {
    param(    
        [Parameter(Mandatory=$true)][string] $Path
    )
    return Get-Item $Path | Select-Object -ExpandProperty Target
}

Export-ModuleMember -Function LinkFolder, ReLinkFolder, IsLinked, GetLinkFor