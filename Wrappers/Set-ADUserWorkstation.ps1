<#
.DESCRIPTION
    This function is used to define what computers an AD user can sign in to by configuring the "User-Workstations" attribute.
.NOTES
    I'm an idiot, you can just use `Set-ADUser -Identity $id -LogonWorkstations $workstations`.
    For more information on this, see the links below:
    - https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-aduser#-logonworkstations
    - https://learn.microsoft.com/en-us/answers/questions/597823/logonworkstions-userworkstation-attribute-is-empty
    - https://woshub.com/restrict-workstation-logon-ad-users/

    In the future, I might make a wrapper for that. For now, this function will be left in its current state where it is psuedocode that hasn't been validated.
.LINK
    https://learn.microsoft.com/en-us/windows/win32/adschema/a-userworkstations
    https://learn.microsoft.com/en-us/windows/win32/adschema/a-logonworkstation
#>
function Set-ADUserWorkstation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Identity,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Workstation')]
        [Alias('LogOnTo', 'NetBIOS', 'DNSName')]
        [String[]]$Workstation,
        [Parameter(ParameterSetName = 'Reset')]
        [Switch]$Reset,
        [Parameter(ParameterSetName = 'Workstation')]
        [Switch]$ValidateWorkstation
    )

    if ($ValidateWorkstation) {
        foreach ($computer in $Workstation) {
            Get-ADComputer -Identity $computer
        }
    }

    foreach ($user in $Identity) {
        # This hasn't been validated to work yet.
        $user = Get-ADUser -Identity $user -Property 'UserWorkstations'
        $user.UserWorkstations = $Workstation -join ','
        Set-ADUser -Instance $user
    }
}

New-Alias -Name 'Set-ADUserLogOnTo' -Value 'Set-ADUserWorkstation'