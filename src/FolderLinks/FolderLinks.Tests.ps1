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

function GetItemMocked {
    Mock -ModuleName FolderLinks Get-Item { 
        $currentDirectory = [PSCustomObject]@{
            Value = 'LinkedPath'
        }
        $scriptBlock = {
            return $true;
        }
        $memberParam = @{
            MemberType = "ScriptMethod"
            InputObject = $currentDirectory
            Name = "Delete"
            Value = $scriptBlock
        }
        $null = Add-Member @memberParam
        return $currentDirectory 
    } -Verifiable -ParameterFilter { $Path -eq $OriginPath }    
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
        It 'returns success' {
            $result.Error | Should Be $false
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

        It 'returns DestinationFolderExists error' {
            $result.Error | Should Be $true
            $result.CanRetry | Should Be $true
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
        It 'returns Success' {
            $result.Error | Should Be $false
        }

        It 'makes calls correctly' {
            Assert-MockCalled -ModuleName FolderLinks New-Item -Exactly 1

            AssertSymbolicLink
        }
    }
}

Describe 'FolderLinks.ReLinkFolder Unit Tests' {
    Context 'When DestinationPath does not exist' {
        # Prepare
        Mock -ModuleName FolderLinks IsLinked { return $true } -Verifiable -ParameterFilter { $Path -eq $OriginPath }
        Mock -ModuleName FolderLinks Test-Path { return $false } -Verifiable -ParameterFilter { $Path -eq $DestinationPath}
        Mock -ModuleName FolderLinks New-Item { } -Verifiable -ParameterFilter { $Path -eq $DestinationPath }
        Mock -ModuleName FolderLinks GetLinkFor { return 'LinkedPath\' } -Verifiable
        Mock -ModuleName FolderLinks Move-Item { } -Verifiable -ParameterFilter { $Path -eq 'LinkedPath\*' -and $Destination -eq  $DestinationPath }
        GetItemMocked
        Mock -ModuleName FolderLinks LinkFolder { return [PsCustomObject]@{ Error = $false; } } -Verifiable -ParameterFilter { $OriginPath -eq $OriginPath -and $DestinationPath -eq $DestinationPath }

        # Execute
        $result = ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns Success' {
            $result.Error | Should Be $false
        }

        It 'makes calls correctly' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName FolderLinks IsLinked -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Test-Path -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks New-Item -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks GetLinkFor -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Move-Item -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Get-Item -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks LinkFolder -Exactly 1            
        }
    }

    Context 'When DestinationPath exists' {
        # Prepare
        Mock -ModuleName FolderLinks IsLinked { return $true } -Verifiable -ParameterFilter { $Path -eq $OriginPath }
        Mock -ModuleName FolderLinks Test-Path { return $true } -Verifiable -ParameterFilter { $Path -eq $DestinationPath}
        Mock -ModuleName FolderLinks GetLinkFor { return 'LinkedPath\' } -Verifiable
        Mock -ModuleName FolderLinks Move-Item { } -Verifiable -ParameterFilter { $Path -eq 'LinkedPath\*' -and $Destination -eq  $DestinationPath }
        GetItemMocked
        Mock -ModuleName FolderLinks LinkFolder { return [PsCustomObject]@{ Error = $false; } } -Verifiable -ParameterFilter { $OriginPath -eq $OriginPath -and $DestinationPath -eq $DestinationPath }

        # Execute
        $result = ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns Success' {
            $result.Error | Should Be $false
        }

        It 'makes calls correctly' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName FolderLinks IsLinked -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Test-Path -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks GetLinkFor -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Move-Item -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks Get-Item -Exactly 1
            Assert-MockCalled -ModuleName FolderLinks LinkFolder -Exactly 1            
        }
    }

    Context 'When Not IsLinked' {
        # Prepare
        Mock -ModuleName FolderLinks IsLinked { return $false } -Verifiable -ParameterFilter { $Path -eq $OriginPath }
        
        # Execute
        $result = ReLinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        # Validate
        It 'returns NoSymlink error' {
            $result.Error | Should Be $true
            $result.CanRetry | Should Be $false
        }

        It 'makes calls correctly' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName FolderLinks IsLinked -Exactly 1
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