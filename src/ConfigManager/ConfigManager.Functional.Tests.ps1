Set-Location -Path $PSScriptRoot
Import-Module ./ConfigManager

$DestinationPath = '../../config/folder-links.json'

Describe 'ConfigManager.LoadTasksFromFile Functional tests' {
    Context 'When Path Exists' {
        # Execute
        $result = LoadTasksFromFile -Path $DestinationPath

        # Validate
        It 'returns 2 tasks' {
            $result.Length | Should Be 2            
        }
    }

    Context 'When Path does not exist' {
        # Execute
        $result = LoadTasksFromFile -Path '../../nullpath/unexistingfile.json'

        # Validate
        It 'returns false' {
            $result | Should Be $false            
        }
    }

    Context 'When Wrong File Contents' {
        # Execute
        $result = LoadTasksFromFile -Path '../../LICENSE'

        # Validate
        It 'returns false' {
            $result | Should Be $false            
        }
    }
}
