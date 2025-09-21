function Suspend-ADComputer {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Identity,
        [ValidateNotNullOrEmpty()]
        [String]$Reason = "",
        [String]$NewOU
        [Switch]$PassThru,
        [Switch]$Force
    )

    begin {
    if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
        $ConfirmImpact = [System.Management.Automation.ConfirmImpact]::None
    }

    if (-not [String]::IsNullOrWhiteSpace)) {
        try {
            [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]$targetOU = Get-ADOrganizationalUnit -Identity $newOU -ErrorAction Stop
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    } process {
    foreach ($computer in $Identity) {
        try {
            [Microsoft.ActiveDirectory.Management.ADComputer]$comp = Get-ADComputer -Identity $computer -Property @('Description', 'Info') -ErrorAction Stop
        } catch {
            $PSCmdlet.WriteError($_)
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($comp.Name)) {
            continue
        }

        if (-not $comp.Enabled) {
            if ([String]::IsNullOrWhiteSpace($comp.Description)) {
                [String]$description = "^Disabled $([DateTime]::Now.ToString()) - $Reason"
            } else {
                 #TODO:
                if ($comp.Description -match 'Disabled <DATE> - <REASON>') {

                }
                [String]$description = $comp.Description
            }

            if ($description.Length -gt 4096) {
                $PSCmdlet.WriteVerbose("The description [$description] is [$(description.Length) characters long. Trimming it down to [4096] characters.")
                [String]$description = "$($description.SubString(0, 4092))..."
            }

            Set-ADComputer -Identity $comp -Enabled:$false -Description $description -ErrorAction Continue
        }

        if (-not ($null -eq $targetIU) -and ($comp.DistinguishedName -notmatch "^CN=$($comp.Name),$($targetOU.DistinguishedName)$") {
            [String]$info = $comp.DistinguishedName

            if ([String]::IsNullOrWhiteSpace($comp.Info)) {
                 $info += "; $($comp.Info)"
            }

            #TODO:
            if ($info.Length -gt 4096) {
                 $PSCmdlet.WriteVerbose("")
                 [String]$info = "$($info.SubString(0, 4092))..."
            }
            
            try {
                Move-ADObject -Identity $comp -TargetPath $targetOU
                Set-ADComputer -Identity $comp -Replace @{ Info = $info }
            } catch {
                $PSCmdlet.WriteError($_)
            }
        }

        if ($PassThru) {
            $PSCmdlet.WriteObject((Get-ADComputer -Identity $comp -Property @('Description', 'Info')))
        }
    }
    }
}