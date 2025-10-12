function Suspend-ADComputer {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.ActiveDirectory.Management.ADComputer[]]$Identity,
        [ValidateNotNullOrEmpty()]
        [String]$Reason = "",
        [String]$NewOU,
        [Switch]$PassThru,
        [Switch]$Force
    )

    begin {
        if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
            $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
        }

        if (-not [String]::IsNullOrWhiteSpace($NewOU)) {
            try {
                [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]$targetOU = Get-ADOrganizationalUnit -Identity $newOU -ErrorAction Stop
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    } process {
        foreach ($comp in $Identity) {
            try {
                [Microsoft.ActiveDirectory.Management.ADComputer]$computer = Get-ADComputer -Identity $comp -Property @('Description', 'Info') -ErrorAction Stop
            } catch {
                $PSCmdlet.WriteError($_)
                continue
            }

            if (-not $PSCmdlet.ShouldProcess($computer.Name)) {
                continue
            }

            if (-not $computer.Enabled) {
                if ([String]::IsNullOrWhiteSpace($computer.Description)) {
                    [String]$description = "^Disabled $([DateTime]::Now.ToString()) - $Reason"
                } else {
                    #TODO:
                    if ($computer.Description -match 'Disabled <DATE> - <REASON>') {

                    }
                    [String]$description = $computer.Description
                }

                if ($description.Length -gt 4096) {
                    $PSCmdlet.WriteVerbose("The description [$description] is [$(description.Length) characters long. Trimming it down to [4096] characters.")
                    [String]$description = "$($description.SubString(0, 4092))..."
                }

                Set-ADComputer -Identity $computer -Enabled:$false -Description $description -ErrorAction Continue
            }

            if (-not ($null -eq $targetIU) -and ($computer.DistinguishedName -notmatch "^CN=$($computer.Name),$($targetOU.DistinguishedName)$")) {
                [String]$info = $computer.DistinguishedName

                if ([String]::IsNullOrWhiteSpace($computer.Info)) {
                    $info += "; $($computer.Info)"
                }

                #TODO:
                if ($info.Length -gt 4096) {
                    $PSCmdlet.WriteVerbose("")
                    [String]$info = "$($info.SubString(0, 4092))..."
                }

                try {
                    Move-ADObject -Identity $computer -TargetPath $targetOU
                    Set-ADComputer -Identity $computer -Replace @{ Info = $info }
                } catch {
                    $PSCmdlet.WriteError($_)
                }
            }

            if ($PassThru) {
                $PSCmdlet.WriteObject((Get-ADComputer -Identity $computer -Property @('Description', 'Info')))
            }
        }
    }
}