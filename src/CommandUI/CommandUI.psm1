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
    $null = Write-Host $('  Link already exists ') -ForegroundColor white -BackgroundColor green
    $null = Write-Host $('  ' + $OriginPath + ' -> ' + $DestinationPath)
    $null = Write-Host $('  ')
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
        [Parameter(Mandatory=$true)][string] $Message
    )
    $null = Write-Host $('  ')
    $null = Write-Host $('  ')
    $null = Write-Host $('  Task                          ') -ForegroundColor black -BackgroundColor white
    $null = Write-Host $('  ' + $Message)
    $null = Write-Host $('  ')
}

function SayStep {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    $null = Write-Host $('  - Attemping to ' + $Message)
}

function SayAlert {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    $null = Write-Host $('  - Alert: ' + $Message) -ForegroundColor yellow
    $null = Write-Host $('  - Trying to continue... ') -ForegroundColor yellow
    $null = Write-Host $('  ')
}

function SaySuccess {
    $null = Write-Host '  - Success'
    $null = Write-Host $('  ')
}

Export-ModuleMember -Function AskYesNo, AskCreateLink, SayStartTask, SaySuccess, SayLinkAlreadyExists, SayTaskDescription, SayStep, SayAlert