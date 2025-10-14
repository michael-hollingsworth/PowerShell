function New-ADComputerReport {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    param (
        #TODO: Add the rest of the parameters to reach feature parody with Get-ADComputer
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Identity')]
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

    begin {
        $baseProperties = @()
    } process {
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
}