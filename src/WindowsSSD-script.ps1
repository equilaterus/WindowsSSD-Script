
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [char]$destinationUnitLetter='d'
)

$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', ''
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', ''
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
function AskYesNo($title) {
    Write-Host $('  - ' + $title + ' -  ') -ForegroundColor white -BackgroundColor blue
    return $host.ui.PromptForChoice('Symbolic link', $('Would you like to create a link for ' + $title), $options, 0) -eq 0
}

function AskCreateLink ($OriginPath, $DestinationPath) {
    $msg = $originPath + " -> " + $destinationPath
    if (!(AskYesNo $msg)) {
        return
    }

    Write-Output $('Attemping to create a Symbolic link from ' + $msg)
    If(!(Test-Path -Path $destinationPath)) {
        New-Item -ItemType Directory -Force -Path $destinationPath
    }
    Move-Item -Path $($originPath + '*') -Destination $destinationPath
    Remove-Item -Path $originPath -Force
    New-Item -Path $originPath  -ItemType SymbolicLink -Value $($destinationPath)
    Write-Output 'Done!'
}

$errorActionPreference = 'Stop'
$sysDestPath = $destinationUnitLetter + ':\System\'

Stop-Service -Name 'wuauserv'
AskCreateLink -originPath $($Env:SystemRoot + '\SoftwareDistribution\') -DestinationPath $($sysDestPath + 'Windows\SoftwareDistribution')
AskCreateLink -originPath $($Env:USERPROFILE + '\AppData\Local\Google\') -DestinationPath $($sysDestPath + 'Google')
