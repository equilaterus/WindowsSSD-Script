Import-Module ./../src/FolderLinks

$OriginPath = 'TestDrive:\origin\'
$DestinationPath = 'TestDrive:\destination\'

$OriginFiles = @('file1.txt', 'folder\file2.txt', 'folder\folder\file3.txt')
$DestinationFiles = @('dest1.txt', 'folder\dest2.txt', 'folder\folder\dest3.txt')
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

    $TotalFiles = $OriginFiles.Count
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
    (Get-Item 'TestDrive:\origin').Delete()
}

Describe "FolderLinks Functional Tests" {
    Context "When DestionationPath does not exist" {
        # Prepare
        $CreateOrigin = $true
        $CreateDestination = $false
        $RepeatFiles = $false
        SeedData -CreateOrigin $CreateOrigin -CreateDestination $CreateDestination -RepeatFiles $RepeatFiles

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It "returns true" {
            $result | Should Be $true
        }

        It "produce valid files" {
            ValidateResultingFiles
        }

        It "creates a symlink" {
            IsLinked -Path $OriginPath
        }

        ClearSymlink
    }
}