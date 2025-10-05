function Resume-ADComputer {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [String[]]$Identity,
        [Switch]$PassThru,
        [Switch]$Force
    )

    if ($Force -and (-not $PSBoundParameters.ContainsKey('Continue'))) {
        $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
    }

    foreach ($id in $Identity) {
        try {
            [Microsoft.ActiveDirectory.Management.ADComputer]$computer = Get-ADComputer -Identity $id -ErrorAction Stop
        } catch {
            $PSCmdlet.WriteError($_)
            continue
        }

        #TODO: Validate that the description and Info fields were set through Suspend-ADComputer

        if ($computer.Enabled -eq $true) {
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($computer.Name)) {
            continue
        }

        # Enable the computer
        Set-ADComputer -Identity $computer -Enabled:$true -Force

        #TODO: Move the computer to its old OU
        Move-ADObject -Identity $computer

        #TODO: Reset the "Description" and "Info" fields
        Set-ADComputer -Identity $computer -Description $description -Replace { Info = $info }

        if ($PassThru) {
            $PSCmdlet.WriteObject((Get-ADComputer -Identity $computer))
        }
    }
}