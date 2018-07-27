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
        [Parameter(Mandatory=$true)][string] $Title,
        [Parameter(Mandatory=$true)][string] $Caption,
        [Parameter(Mandatory=$true)][string] $Message
    )

    Write-Host $('  - ' + $Title + ' -  ') -ForegroundColor white -BackgroundColor blue
    $Options = YesNo
    $Answer = Prompt -Caption $Caption -Message $Message -Options $options
    return $Answer -eq 1
}

Export-ModuleMember -Function AskYesNo