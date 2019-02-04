Set-Location -Path $PSScriptRoot
Import-Module ./FolderLinks

# Paths including subpaths for harder test cases
$OriginPath = 'TestDrive:\origin\origin\'
$DestinationPath = 'TestDrive:\destination\destination\'

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

function ClearSymlink {
    (Get-Item $OriginPath).Delete()
}

Describe 'FolderLinks Functional Tests' {
    Context 'When no OriginPath or DestinationPath exist' {
        # Prepare
        $CreateOrigin = $false
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'produce valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            IsLinked -Path $OriginPath | Should Be $true
            ClearSymlink
        }        
    }

    Context 'When OriginPath does not exist' {
        # Prepare
        $CreateOrigin = $false
        $CreateDestination = $true
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'produce valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            IsLinked -Path $OriginPath | Should Be $true
            ClearSymlink
        }        
    }

    Context 'When DestinationPath does not exist' {
        # Prepare
        $CreateOrigin = $true
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'produce valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }

        It 'creates a symlink' {
            IsLinked -Path $OriginPath | Should Be $true
            ClearSymlink
        }        
    }

    Context 'When DestinationPath exist with no collision files or folders' {
        # Prepare
        $CreateOrigin = $true
        $CreateDestination = $true
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        
        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'produce valid files' {
            ValidateResultingFiles -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles
        }
        
        It 'creates a symlink' {
            IsLinked -Path $OriginPath | Should Be $true
            ClearSymlink
        }        
    }

    Context 'When DestinationPath exist with collision files and/or folders' {
        # Prepare
        $CreateOrigin = $true
        $CreateDestination = $true
        $RepeatFiles = $true
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns false' {
            $result | Should Be $false
        }

        It 'keeps all files' {
            $ResultingFiles = @(Get-ChildItem $OriginPath -Recurse -Attributes !Directory)
            $ResultingFiles.Count | Should Be $OriginFiles.Count

            $ResultingFiles = @(Get-ChildItem $DestinationPath -Recurse -Attributes !Directory)
            $ResultingFiles.Count | Should Be $DestinationFiles.Count
        }
        
        It 'does not creates a symlink' {
            IsLinked -Path $OriginPath | Should Be $false
        }
    }
}