[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)][char] $DestinationUnitLetter = 'd',
    [Parameter(Position=2)][string] $ConfigPath = '../config/',
    [Parameter(Position=2)][bool] $CommandUI = $true
)

# Default settings
Set-Location -Path $PSScriptRoot
$errorActionPreference = 'Stop'

# Imports
Import-Module ./CommandUI
Import-Module ./FolderLinks
Import-Module ./ConfigManager

# Main function
$sysDestPath = $($DestinationUnitLetter + ':\')
$tasks = LoadTasksFromFile -Path '../config/folder-links.json'
if ($task -eq $false) {
    Throw 'Bad or missing configuration file'
}

foreach ($task in $tasks) {
    SayTaskDescription -Message $task.Description -DeleteOriginFiles $task.DeleteOriginFiles

    foreach($service in $task.StopServices) {
        SayStep -Message $('stop ' + $service)
        Stop-Service -Name $service -Force -ErrorAction 0 -ErrorVariable +err
        if ($err) {
            SayAlert -Message $err
        } else {
            SaySuccess
        }
    }

    foreach($process in $task.StopProcesses) {
        SayStep -Message $('stop ' + $process)
        Stop-Process -Name $process -Force -ErrorAction 0 -ErrorVariable +err
        if ($err) {
            SayAlert -Message 'We cannot stop the process'
        } else {
            SaySuccess
        }
    }

    $originPath = [Environment]::ExpandEnvironmentVariables($task.OriginPath)    
    if (IsLinked -Path $originPath) {
        $destinationPath = GetLinkFor -Path $originPath
        SayLinkAlreadyExists -OriginPath $originPath -DestinationPath $destinationPath
    } else {
        $destinationPath = $($sysDestPath + [Environment]::ExpandEnvironmentVariables($task.DestinationPath))
        if(AskCreateLink -OriginPath $originPath -DestinationPath $destinationPath) {
            $result = LinkFolder -OriginPath $originPath -DestinationPath $destinationPath -DeleteOriginFiles $task.DeleteOriginFiles
            if(!$result.Error) {
                SaySuccess
            } else {
                Write-Error '  - Error creating the folder. Check that the detination folder is empty.'
            }
        }
    }
}