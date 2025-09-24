function Get-ADComputerLastLogon {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Identity')]
        [String[]]$Identity,
        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [String]$Filter,
        [Parameter(ParameterSetName = 'Filter')]
        [String]$SearchBase
    )

    foreach ($id in $Identity) {
        Get-ADComputer -Identity $id -Properties @('LastLogon', 'LastLogonDate') -ErrorAction Continue
    }
}