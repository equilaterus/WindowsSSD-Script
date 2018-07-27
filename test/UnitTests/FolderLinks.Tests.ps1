Import-Module ./../src/FolderLinks

$OriginPath = '$env:TEMP\origin'
$DestinationPath = '$env:TEMP\destination'

Describe "FolderLinks.LinkFolder Unit Tests" {
    Context "When Path does not exist" {
        Mock -ModuleName FolderLinks Test-Path { return $true }
        Mock -ModuleName FolderLinks Move-Item { }
        Mock -ModuleName FolderLinks Remove-Item { }
        Mock -ModuleName FolderLinks New-Item { } -Verifiable -ParameterFilter{ $Path -eq $DestinationPath -or $Path -eq $OriginPath}

        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        It "returns true" {
            $result | Should Be $true
        }
    }

    Context "When Path exists" {
        Mock -ModuleName FolderLinks Test-Path { return $true }

        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath

        It "returns false" {
            $result | Should Be $false
        }
    }

    Context "When Path exists but IgnoreExtraFiles is true" {
        Mock -ModuleName FolderLinks Test-Path { return $false }
        Mock -ModuleName FolderLinks Move-Item { }
        Mock -ModuleName FolderLinks Remove-Item { }
        Mock -ModuleName FolderLinks New-Item { } -Verifiable -ParameterFilter{ $Path -eq $DestinationPath -or $Path -eq $OriginPath}

        $result = LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath -IgnoreExtraFiles $true

        It "returns true" {
            $result | Should Be $true
        }
    }
}

Describe "FolderLinks.IsLinked Unit Tests" {
    Context "When normal file" {
        Mock -ModuleName FolderLinks Get-Item { }

        $result = IsLinked -Path $OriginPath

        It "returns false" {
            $result | Should Be $false
        }
    }
}