function Prompt {
    param(
        [Parameter(Mandatory=$true)][string] $Caption,
        [Parameter(Mandatory=$true)][string] $Message,
        [Parameter(Mandatory=$true)][System.Management.Automation.Host.ChoiceDescription[]] $Options
    )
    return $host.ui.PromptForChoice($Caption, $Message, $options, 0)
}

function YesNo {
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', ''
    $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', ''
    return [System.Management.Automation.Host.ChoiceDescription[]]($No, $Yes)
}

function AskYesNo {
    param(
        [Parameter(Mandatory=$true)][string] $Caption,
        [Parameter(Mandatory=$true)][string] $Message,
        [string] $Title = ''
    )

    if ($Title -ne '') {
        $null = Write-Host $('  - ' + $Title + ' -  ') -ForegroundColor white -BackgroundColor blue
    }
    $Options = YesNo
    $Answer = Prompt -Caption $Caption -Message $Message -Options $options
    return $Answer -eq 1
}

function SayLinkAlreadyExists {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath
    )
    Write-Host $('  Link already exists ') -ForegroundColor white -BackgroundColor green
    Write-Host $('  ' + $OriginPath + ' -> ' + $DestinationPath)
    Write-Host $('  ')
}

function AskCreateLink {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath
    )
    $Message = $('  ' + $OriginPath + ' ->' + $DestinationPath)
    return AskYesNo -Caption '  Would you like to create a symbolic link? ' -Message $Message     
}

function SayTaskDescription {
    param(
        [Parameter(Mandatory=$true)][string] $Message,
        [bool] $DeleteOriginFiles
    )
    Write-Host $('  ')
    Write-Host $('  ')
    Write-Host $('  Task                          ') -ForegroundColor black -BackgroundColor white
    Write-Host $('  ' + $Message)
    Write-Host $('  ')

    if ($DeleteOriginFiles) {
        Write-Host $(' This task deletes source files.') -ForegroundColor yellow -BackgroundColor black
        Write-Host $(' Windows Update Files can be deleted safely.') -ForegroundColor yellow -BackgroundColor black
    }
}

function SayStep {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    Write-Host $('  - Attemping to ' + $Message)
}

function SayAlert {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    Write-Host $('  - Alert: ' + $Message) -ForegroundColor yellow
    Write-Host $('  - Trying to continue... ') -ForegroundColor yellow
    Write-Host $('  ')
}

function SaySuccess {
    Write-Host '  - Success'
    Write-Host $('  ')
}

function Print {
    param(
        [Parameter(Mandatory=$true)][string] $Format,
        [Parameter(Mandatory=$false)][array] $Values,
        [Parameter(Mandatory=$false)][string] $ForegroundColor,
        [Parameter(Mandatory=$false)][string] $BackgroundColor
    )
    $outputString = ''
    $formatArray = $Format.ToCharArray();
    $j = 0    
    for ($i=0; $i -lt $Format.length; $i++){
        if ($formatArray[$i] -eq '`') {
            $outputString = $($outputString+$Values[$j++])
        }
        else {
            $outputString = $($outputString+$formatArray[$i])
        }
    }
    Write-Host $($outputString) -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
}

Export-ModuleMember -Function AskYesNo, AskCreateLink, SayStartTask, SaySuccess, SayLinkAlreadyExists, SayTaskDescription, SayStep, SayAlert, Print