function LoadTasksFromFile {
    param(
        [Parameter(Mandatory=$true)][string] $Path
    )

    $result = Get-Content -Raw -Path $Path -ErrorVariable +err -ErrorAction 0
    if ($err) {
        return $false
    } 

    # ErrorAction doesn't work consistently for ConvertFrom-Json
    try {
        $json = ConvertFrom-Json -InputObject $result
        return $json
    } catch {
        return $false
    }
}

Export-ModuleMember -Function LoadTasksFromFile