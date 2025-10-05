function Suspend-InactiveADComputer {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
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

    if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
        $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
    }

    $computers = Get-InactiveADComputer @PSBoundParameters

    foreach ($computer in $computers) {
        if (-not $PSCmdlet.ShouldProcess($computer.Name)) {
            continue
        }

        #TODO: make this work
        Suspend-ADComputer -Identity $computer -Force
    }
}