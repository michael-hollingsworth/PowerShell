function Get-ADComputerLastLogon {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    param (
        #TODO: Add the rest of the parameters to reach feature parody with Get-ADComputer
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Identity')]
        #TODO: figure out what kinda black magic Microsoft uses to get the Identity parameter to work
        ## While you're at it, see if it is possible to do all of this inside the native ADComputer object
        [ValidateNotNullOrEmpty()]
        [Microsoft.ActiveDirectory.Management.ADComputer[]]$Identity,
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
        #TODO: Add the remaining default properties
        #TODO: See if the modifications can be made to the original class without modifying the original object to the point that it breaks things when passing it to Set-ADComputer
        [String[]]$gadcProperties = @('LastLogon', 'LastLogonTimestamp')
        $soProperties = @(
            'Name',
            'Enabled',
            @{
                Name = 'LastLogon'
                Expression = { [DateTime]::FromFileTime($_.LastLogon) }
            },
            @{
                Name = 'LastLogonTimestamp'
                Expression = { [DateTime]::FromFileTime($_.LastLogonTimestamp) }
            },
            'DistinguishedName',
            'Sid',
            'GUID'
        )

        if ($Properties) {
            $gadcProperties += $Properties
            $soProperties += $Properties
        }
    } process {
        [Microsoft.ActiveDirectory.Management.ADComputer[]]$computers = if ($PSCmdlet.ParameterSetName -eq 'Filter') {
            [HashTable]$gadcSplat = @{
                Filter = $Filter
                Properties = $gadcProperties
                ErrorAction = [System.Management.Automation.ActionPreference]::Stop
            }

            if (-not [String]::IsNullOrWhiteSpace($SearchBase)) {
                $gadcSplat.Add('SearchBase', $SearchBase)
            }

            Get-ADComputer @gadcSplat
        } else {
            foreach ($id in $Identity) {
                Get-ADComputer -Identity $id -Properties $gadcProperties -ErrorAction Continue
            }
        }

        foreach ($comp in $computers) {
            $PSCmdlet.WriteObject((Select-Object -InputObject $comp -Property $soProperties -ErrorAction Continue))
        }
    }
}