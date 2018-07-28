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
        Write-Host $('  - ' + $Title + ' -  ') -ForegroundColor white -BackgroundColor blue
    }
    $Options = YesNo
    $Answer = Prompt -Caption $Caption -Message $Message -Options $options
    return $Answer -eq 1
}

function GetLinkDescription {
    param(
        [Parameter(Mandatory=$true)][string] $OriginPath,
        [Parameter(Mandatory=$true)][string] $DestinationPath
    )

    return $OriginPath + ' -> ' + $DestinationPath
}

function AskToCreateLink {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )

    return AskYesNo -Title $Message -Caption 'Would you like to create a symbolic link?' -Message $Message    
}

function StartTaskMessage {
    Write-Output 'Attemping to execute requested task'
}

function SuccessMessage {
    Write-Output 'Done'
}

Export-ModuleMember -Function AskYesNo, GetLinkDescription, AskToCreateLink, StartTaskMessage, SuccessMessage