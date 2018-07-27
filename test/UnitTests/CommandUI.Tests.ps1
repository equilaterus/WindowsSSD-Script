Import-Module ./../src/CommandUI

Describe "CommandUI.AskYesNo Unit tests" {
    Context "When answers Yes" {
        Mock -ModuleName CommandUI Write-Host {}
        Mock -ModuleName CommandUI Prompt { return 1 }

        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        It "returns true" {
            $result | Should Be $true
        }
    }

    Context "When answers No" {
        Mock -ModuleName CommandUI Write-Host {}
        Mock -ModuleName CommandUI Prompt { return 0 }

        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        It "returns false" {
            $result | Should Be $false
        }
    }

    Context "When answers Anything" {
        Mock -ModuleName CommandUI Write-Host {}
        Mock -ModuleName CommandUI Prompt { return 0451 }

        $result = AskYesNo -Title 'A Title' -Caption 'A Caption' -Message 'A Message'

        It "returns false" {
            $result | Should Be $false
        }
    }
}