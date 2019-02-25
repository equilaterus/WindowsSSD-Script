Set-Location -Path $PSScriptRoot
Import-Module ./FolderLinks

# Paths including subpaths for harder test cases
$OriginPath = 'TestDrive:\origin\origin\'
$DestinationPath = 'TestDrive:\destination\destination\'
$DestinationEnding = '\destination\destination\'

$DestinationPathTwo = 'TestDrive:\destinationtwo\destination\'
$DestinationEndingTwo = '\destinationtwo\destination\'

$OriginFiles = @('file1.txt', 'folder\file2.txt', 'folder\folder\file3.txt')
$DestinationFiles = @('dest1.txt', 'dest\dest2.txt', 'dest\dest\dest3.txt')
$FileContent = 'Nevermind'

function CreateFiles {
    Param(
        [string] $Path=$false,
        [string[]] $Files
    )

    foreach ($file in $Files) {
        $FullPath = $($Path + $file)
        $PathExists = Test-Path -Path $FullPath
        if (!$PathExists) {
             New-Item -Path $FullPath -Force
        }
        Set-Content -Path $FullPath -Value $FileContent
    }
}

function SeedData {
    param(
        [bool] $CreateOrigin=$false,
        [bool] $CreateDestination=$false,
        [bool] $RepeatFiles=$false
    )

    if ($CreateOrigin) {
        CreateFiles -Path $OriginPath -Files $OriginFiles
    }
    if ($CreateDestination) {
        if ($RepeatFiles) {
            CreateFiles -Path $DestinationPath -Files $OriginFiles
        } else {
            CreateFiles -Path $DestinationPath -Files $DestinationFiles
        }
    }
}

function ValidateFile {
    param (
        [string] $Path
    )
    $data = Get-Content -Path $Path
    return $data -eq $FileContent
}

function ValidateResultingFiles {
    param(
        [bool] $CreateOrigin=$false,
        [bool] $CreateDestination=$false,
        [bool] $RepeatFiles=$false
    )

    $TotalFiles = 0
    if ($CreateOrigin) {
        $TotalFiles += $OriginFiles.Count
    }
    if ($CreateDestination -and !$RepeatFiles) {
        $TotalFiles += $DestinationFiles.Count
    }
    $ResultingFiles = @(Get-ChildItem $DestinationPath -Recurse -Attributes !Directory)
    $ResultingFiles.Count | Should Be $TotalFiles

    foreach ($path in $ResultingFiles) {
        $FileValidation = ValidateFile -Path $path.FullName
        $FileValidation | Should Be $true
    }
}

function PreRequisites {
    if (Test-Path $OriginPath) {
        throw 'OriginPath path was not deleted'
    }

    if (Test-Path $DestinationPath) {
        throw 'Destination path was not deleted'
    }
}

function ValidateSymlink {
    param (
        [string] $Path,
        [string] $EndingPath
    )

    IsLinked -Path $OriginPath | Should Be $true
    $result = GetLinkFor -Path $OriginPath 
    $result.endsWith($EndingPath) | Should be $true
}

# This must be executed before Pester Test
# tears down to avoid errors on CI build
function ClearLink {
    (Get-Item $OriginPath).Delete()
}

Describe 'FolderLinks\LinkFolder - Functional Tests' {
    Context 'When no OriginPath or DestinationPath exist' {
        # Prepare
        PreRequisites

        $CreateOrigin = $false
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produce valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding
            ClearLink          
        }        
    }

    Context 'When OriginPath does not exist' {
        # Prepare
        PreRequisites

        $CreateOrigin = $false
        $CreateDestination = $true
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produces valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding
            ClearLink     
        }        
    }

    Context 'When DestinationPath does not exist' {
        # Prepare
        PreRequisites
        
        $CreateOrigin = $true
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produces valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding
            ClearLink       
        }        
    }

    Context 'When DestinationPath exists but no IgnoreExtraFiles flag was sent' {
        # Prepare
        PreRequisites

        $CreateOrigin = $true
        $CreateDestination = $true
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        
        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns false' {
            $result.Error | Should Be $true
            $result.CanRetry | Should Be $true
        }       
    }

    Context 'When DestinationPath exists with no collision files or folders' {
        # Prepare
        PreRequisites

        $CreateOrigin = $true
        $CreateDestination = $true
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        
        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produces valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }
        
        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding  
            ClearLink       
        }        
    }

    Context 'When DestinationPath exists with collision files and/or folders' {
        # Prepare
        PreRequisites

        $CreateOrigin = $true
        $CreateDestination = $true
        $RepeatFiles = $true
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns false' {
            $result.Error | Should Be $true
            $result.CanRetry | Should Be $false
        }

        It 'keeps all files' {
            $ResultingFiles = @(Get-ChildItem $OriginPath -Recurse -Attributes !Directory)
            $ResultingFiles.Count | Should Be $OriginFiles.Count

            $ResultingFiles = @(Get-ChildItem $DestinationPath -Recurse -Attributes !Directory)
            $ResultingFiles.Count | Should Be $DestinationFiles.Count
        }
        
        It 'does not create a symlink' {
            IsLinked -Path $OriginPath | Should Be $false
        }
    }
}

Describe 'FolderLinks\ReLinkFolder - Functional Tests' {
    Context 'When Link exists and It contains files' {
        # Prepare
        PreRequisites
        
        $CreateOrigin = $true
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Create a symlink to DestinationPathTwo
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPathTwo
        ValidateSymlink -Path $OriginPath -EndingPath $DestinationEndingTwo

        # Execute
        ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produces valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding
            ClearLink    
        }        
    }

    Context 'When Link exists but is is empty' {
        # Prepare
        PreRequisites
        
        $CreateOrigin = $false
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Create a symlink to DestinationPathTwo
        LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPathTwo
        ValidateSymlink -Path $OriginPath -EndingPath $DestinationEndingTwo

        # Execute
        $result = ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result.Error | Should Be $false
        }

        It 'produces valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            ValidateSymlink -Path $OriginPath -EndingPath $DestinationEnding
            ClearLink    
        }        
    }

    Context 'When Link does not exist' {
        # Prepare
        PreRequisites
        
        $CreateOrigin = $false
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles       

        # Execute
        $result = ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns false' {
            $result.Error | Should Be $true
            $result.CanRetry | Should Be $false
        }
        
        It 'does not create a symlink' {
            IsLinked -Path $OriginPath | Should Be $false
        }
    }
}