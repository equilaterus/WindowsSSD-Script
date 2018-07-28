[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)][char] $DestinationUnitLetter='d',
    [Parameter(Position=2)][bool] $CommandUI=$true
)

Import-Module .\CommandUI
Import-Module .\FolderLinks

function AskCreateLink ($OriginPath, $DestinationPath) {
    $msg = $originPath + " -> " + $destinationPath
    if (!(AskYesNo -Title $msg -Caption 'Would you like to create a symbolic link?' -Message $msg)) {
        return
    }

    Write-Output $('Attemping to create a Symbolic link from ' + $msg)
    LinkFolder -OriginPath $OriginPath -DestinationPath $DestinationPath
    Write-Output 'Done!'
}

$errorActionPreference = 'Stop'
$sysDestPath = $destinationUnitLetter + ':\System\'

Stop-Service -Name 'wuauserv'
AskCreateLink -originPath $($Env:SystemRoot + '\SoftwareDistribution\') -DestinationPath $($sysDestPath + 'Windows\SoftwareDistribution')
AskCreateLink -originPath $($Env:USERPROFILE + '\AppData\Local\Google\') -DestinationPath $($sysDestPath + 'Google')
