function Compare-ADUserGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.ActiveDirectory.Management.ADUser]$ReferenceUser,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.ActiveDirectory.Management.ADUser]$DifferenceUser,
        [Switch]$ExcludeDifferent,
        [Switch]$IncludeEqual
    )

    begin {
        if (-not $ReferenceUser.PSObject.Properties.Name.Contains('MemberOf')) {
            $ReferenceUser = Get-ADUser -Identity $ReferenceUser -Property MemberOf
        }
    } process {
        if (-not $DifferenceUser.PSObject.Properties.Name.Contains('MemberOf')) {
            $DifferenceUser = Get-ADUser -Identity $DifferenceUser -Property MemberOf
        }

        return (Compare-Object -RefferenceObject $ReferenceUser -DifferenceObject $DifferenceUser -Property MemberOf -IncludeEqual:(!!$IncludeEqual) -ExcludeDifferent:(!!$ExcludeDifferent))
    }
}