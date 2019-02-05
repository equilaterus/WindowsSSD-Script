Set-Location -Path $PSScriptRoot
Import-Module ./FolderLinks

$OriginPath = '.\TEMP\origin\'
$DestinationPath = '.\TEMP\destination\'

function AssertSymbolicLink {
    # Create link
    Assert-MockCalled -ModuleName FolderLinks New-Item -ParameterFilter { $Path -eq $OriginPath -and $Value -eq $DestinationPath } -Exactly 1

    # Move origin data
    Assert-MockCalled -ModuleName FolderLinks Move-Item -ParameterFilter { $Path -eq $($OriginPath + '*') -and $Destination -eq $DestinationPath } -Exactly 1
    Assert-MockCalled -ModuleName FolderLinks Remove-Item -ParameterFilter { $Path -eq $OriginPath } -Exactly 1
}

Describe 'FolderLinks.LinkFolder Unit Tests' {
    Context 'When DestinationPath does not exist' {
        # Prepare
        Mock -ModuleName FolderLinks Test-Path { return $Path -eq $OriginPath }
        Mock -ModuleName FolderLinks Move-Item { } -Verifiable
        Mock -ModuleName FolderLinks Remove-Item { } -Verifiable
        Mock -ModuleName FolderLinks New-Item { } -Verifiable -ParameterFilter { $Path -eq $DestinationPath -or $Path -eq $OriginPath }

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'makes calls correctly' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName FolderLinks New-Item -Exactly 2
            Assert-MockCalled -ModuleName FolderLinks New-Item -ParameterFilter {$Path -eq $DestinationPath } -Exactly 1

            AssertSymbolicLink
        }
    }

    Context 'When DestinationPath exists' {
        # Prepare
        Mock -ModuleName FolderLinks Test-Path { return $true }

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        It 'returns false' {
            $result | Should Be $false
        }
    }

    Context 'When DestinationPath exists but IgnoreExtraFiles is true' {
        # Prepare
        Mock -ModuleName FolderLinks Test-Path { return $true }
        Mock -ModuleName FolderLinks Move-Item { }  -Verifiable
        Mock -ModuleName FolderLinks Remove-Item { }  -Verifiable
        Mock -ModuleName FolderLinks New-Item { } -Verifiable -ParameterFilter{ $Path -eq $DestinationPath -or $Path -eq $OriginPath}

        # Execute
        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }

        It 'makes calls correctly' {
            Assert-MockCalled -ModuleName FolderLinks New-Item -Exactly 1

            AssertSymbolicLink
        }
    }
}

Describe 'FolderLinks.IsLinked Unit Tests' {
    Context 'When normal file' {
        # Prepare
        Mock -ModuleName FolderLinks Get-Item { }

        # Execute
        $result = IsLinked -Path $OriginPath

        # Validate
        It 'returns false' {
            $result | Should Be $false
        }
    }
}