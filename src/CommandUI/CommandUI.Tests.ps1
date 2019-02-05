Set-Location -Path $PSScriptRoot
Import-Module ./CommandUI

Describe 'CommandUI.AskYesNo Unit tests' {
    Context 'When answers Yes' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host {}
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It 'returns true' {
            $result | Should Be $true
        }
    }

    Context 'When answers No' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 0 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It 'returns false' {
            $result | Should Be $false
        }
    }

    Context 'When answers Anything' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 0451 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It 'returns false' {
            $result | Should Be $false
        }
    }

    Context 'When does not have a title' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Caption 'A Caption' -Message 'A Message'

        # Validate
        It 'write host it is not called' {
            Assert-MockCalled -ModuleName CommandUI Write-Host -Exactly 0
        }

        It 'returns true' {
            $result | Should Be $true
        }
    }

    Context 'When it has a title' {
        # Prepare
        $Title = 'The Title'
        Mock -ModuleName CommandUI Write-Host { } -Verifiable
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Title $Title -Caption 'A Caption' -Message 'A Message'

        # Validate
        It 'write host is called' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName CommandUI Write-Host -Exactly 1
        }

        It 'returns true' {
            $result | Should Be $true
        }
    }
}

Describe 'CommandUI.Messages Unit tests' {   

    Context 'When asks to create a link' {
        # Prepare
        Mock -ModuleName CommandUI AskYesNo { return 404 } -Verifiable

        # Execute
        $result = AskCreateLink -OriginPath 'Origin' -DestinationPath 'Destination'

        # Validate
        It 'AskYesNo is called' {
            Assert-VerifiableMock
            Assert-MockCalled -ModuleName CommandUI AskYesNo -Exactly 1
        }

        It 'returns same as AskYesNo' {
            $result | Should Be 404
        }
    }

    Context 'When SayTaskDescription' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SayTaskDescription -Message 'A message'

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }

    Context 'When SaySuccess' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SaySuccess

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }

    Context 'When SayLinkAlreadyExists' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SayLinkAlreadyExists -OriginPath 'Any' -DestinationPath 'AnyDestination'

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }

    Context 'When SayTaskDescription' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SayTaskDescription -Message 'Any'

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }

    Context 'When SayStep' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SayStep -Message 'Any'

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }

    Context 'When SayAlert' {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { } -Verifiable

        # Execute
        SayAlert -Message 'Any'

        # Validate
        It 'write host called' {
            Assert-VerifiableMock
        }
    }
}