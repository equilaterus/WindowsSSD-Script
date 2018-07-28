Import-Module ./../src/CommandUI

Describe "CommandUI.AskYesNo Unit tests" {
    Context "When answers Yes" {
        # Prepare
        Mock -ModuleName CommandUI Write-Host {}
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It "returns true" {
            $result | Should Be $true
        }
    }

    Context "When answers No" {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 0 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It "returns false" {
            $result | Should Be $false
        }
    }

    Context "When answers Anything" {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 0451 }

        # Execute
        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        # Validate
        It "returns false" {
            $result | Should Be $false
        }
    }

    Context "When does not have a title" {
        # Prepare
        Mock -ModuleName CommandUI Write-Host { }
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Caption 'A Caption' -Message 'A Message'

        # Validate
        It "write host it is not called" {
            Assert-MockCalled -ModuleName CommandUI Write-Host -Exactly 0
        }

        It "returns true" {
            $result | Should Be $true
        }
    }

    Context "When it has a title" {
        # Prepare
        $Title = 'The Title'
        Mock -ModuleName CommandUI Write-Host { } -Verifiable
        Mock -ModuleName CommandUI Prompt { return 1 }

        # Execute
        $result = AskYesNo -Title $Title -Caption 'A Caption' -Message 'A Message'

        # Validate
        It "write host it's called" {
            Assert-VerifiableMocks
            Assert-MockCalled -ModuleName CommandUI Write-Host -Exactly 1
        }

        It "returns true" {
            $result | Should Be $true
        }
    }
}