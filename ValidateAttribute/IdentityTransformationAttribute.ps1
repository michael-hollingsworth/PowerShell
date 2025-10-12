<#
.SYNOPSIS
    Validates that a parameter value is a valid `[NTAccount]`, `[SecurityIdentifier]`, or `[WindowsIdentity]` and attempts to convert the value to a `[SecurityIdentifier]`.
.EXAMPLE
    ```PowerShell
    function Test-Identity {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [IdentityTransformation()]
            [System.Security.Principal.IdentityReference[]]$Identity
        )

        return $Identity
    }
    ```

    Pass:
    ```PowerShell
    Test-Identity -Identity 'S-1-5-18'
    Test-Identity -Identity ([System.Security.Principal.SecurityIdentifier]::new('S-1-5-18'))
    Test-Identity -Identity 'NT AUTHORITY\SYSTEM'
    Test-Identity -Identity ([System.Security.Principal.NTAccount]::new('NT AUTHORITY\SYSTEM'))

    # This only works when the Identity parameter isn't strictly typed or is typed to accept the [Object]/[Object[]] type.
    ## If the parameter is strongly typed to only allow [System.Security.Principal.IdentityReference[]] this will fail since the [WindowsIdentity] class doesn't inherit from the [IdentityReference] class
    Test-Identity -Identity ([System.Security.Principal.WindowsIdentity]::GetCurrent())
    ```

    Fail:
    ```PowerShell
    Test-Identity -Identity "user that doesn't exist"  # This user doesn't exist so it won't be able to convert the NTAccount to a SID.
    Test-Identity -Identity 'S-1-5-18-12-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2'  # This is an invalid SID format.
    ```
.NOTES
    This attribute transformer relies on the ConvertTo-Sid function and its accompanying [GroupPolicyAccountInfo] class.
.NOTES
    Author: Michael Hollingsworth
#>
class IdentityTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [Object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [Object]$object) {
        if (($object -is [System.Security.Principal.SecurityIdentifier]) -or ($object -is [System.Security.Principal.SecurityIdentifier[]])) {
            return $object
        }

        if (($object -is [System.Security.Principal.NTAccount]) -or ($object -is [System.Security.Principal.NTAccount[]])) {
            return (ConvertTo-Sid -NTAccount $object)
        }

        if (($object -is [System.Security.Principal.WindowsIdentity]) -or ($object -is [System.Security.Principal.WindowsIdentity[]])) {
            return ($object.User)
        }

        if (($object -is [String]) -or ($object -is [String[]])) {
            [System.Security.Principal.SecurityIdentifier[]]$sids = foreach ($string in $object) {
                try {
                    [System.Security.Principal.SecurityIdentifier]::new($string)
                } catch {
                    ConvertTo-Sid -NTAccount $string
                }
            }

            return $sids
        }

        throw ([System.ArgumentException]::new("Failed to convert '$($object.ToString())' to a valid SID."))
    }

    [String] ToString() {
        return '[IdentityTransformationAttribute()]'
    }
}