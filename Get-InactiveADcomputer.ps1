function Get-InactiveADcomputer {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$SearchBase,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Filter,
        [Parameter(ParameterSetName = 'Days')]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$MinDaysSinceLastLogon = 45,
        [Parameter(Mandatory = $true, ParameterSetName = 'CutoffDate')]
        [DateTime]$CutoffDate,
        [Parameter(Mandatory = $true, ParameterSetName = 'CutoffTimeSpan')]
        [DateTime]$CutoffTimeSpan,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Property')]
        [String[]]$Properties
    )

    [HashTable]$gadcllSplat = $PSBoundParameters

    if ($PSCmdlet.ParameterSetName -eq 'Days') {
        [DateTime]$CutoffDate = [DateTime]::Now.AddDays(-$MinDaysSinceLastLogon)
        $gadcllSplat.Remove('MinDaysSinceLastLogon')
    } elseif ($PSCmdlet.ParameterSetName -eq 'CutoffTimeSpan') {
        [DateTime]$CutoffDate = [DateTime]::Now.Add(-$CutoffTimeSpan)
        $gadcllSplat.Remove('CutoffTimeSpan')
    } else {
        $gadcllSplat.Remove('CutoffDate')
    }

    $computers = Get-ADComputerLastLogon @gadcllSplat

    foreach ($computer in $computers) {
        if (($computer.LastLogon -gt $CutoffDate) -or ($computer.LastLogonTimestamp -gt $CutoffDate)) {
            continue
        }

        $PSCmdlet.WriteObject($computer)
    }
}