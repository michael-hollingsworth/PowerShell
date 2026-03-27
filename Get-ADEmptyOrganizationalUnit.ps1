function Get-ADEmptyOrganizationalUnit {
    [CmdletBinding()]
    [OutputType([Microsoft.ActiveDirectory.Management.ADOrganizationalUnit])]
    param (
    )

    [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit[]]$ous = Get-ADOrganizationalUnit -Filter *

    foreach ($ou in $ous) {
        if (-not (Get-ADObject -SearchBase $ou.DistinguishedName -Filter * -SearchScope OneLevel | & { process { if ($_.DistinguishedName -ne $ou.DistinguishedName) { return $_ } } } | Select-Object -First 1)) {
            $PSCmdlet.WriteObject($ou)
        }
    }
}

Set-Alias -Name Get-ADEmptyOU -Value Get-ADEmptyOrganizationalUnit
