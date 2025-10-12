function New-ADComputerReport {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    param (
        #TODO: Add the rest of the parameters to reach feature parody with Get-ADComputer
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Identity')]
        #TODO: figure out what kinda black magic Microsoft uses to get the Identity parameter to work
        ## While you're at it, see if it is possible to do all of this inside the native ADComputer object
        [Management[]]$Identity,
        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [String]$Filter,
        [Parameter(ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [String]$SearchBase,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Property')]
        [String[]]$Properties
    )

    [Microsoft.ActiveDirectory.Management.ADComputer[]]$computers = if ($PSCmdlet.ParameterSetName -eq 'Filter') {
        [HashTable]$gadcSplat = @{
            Filter = $Filter
            ErrorAction = [System.Management.Automation.ActionPreference]::Stop
        }

        if (-not [String]::IsNullOrWhiteSpace($SearchBase)) {
            $gadcSplat.Add('SearchBase', $SearchBase)
        }

        Get-ADComputer @gadcSplat
    } else {
        foreach ($id in $Identity) {
            Get-ADComputer -Identity $id -Properties $searchProperties -ErrorAction Continue
        }
    }
}