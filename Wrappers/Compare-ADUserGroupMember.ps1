function Compare-ADUserGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        $ReferenceObject,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        $DifferenceObject,
        [Switch]$ExcludeDifferent,
        [Switch]$IncludeEqual
    )

    begin {
        if (-not (($ReferenceObject -is [String]) -or ($ReferenceObject -is [ADUser]))) {
            throw
        }

        if (-not (($DifferenceObject -is [String]) -or ($DifferenceObject -is [ADUser]))) {
            throw
        }

        if (-not $ReferenceObject.PSObject.Properties.ContainsKey('MemberOf')) {
            $ReferenceObject = Get-ADUser -Identity $ReferenceObject -Property MemberOf
        }
        if (-not $DifferenceObject.PSObject.Properties.ContainsKey('MemberOf')) {
            $DifferenceObject = Get-ADUser -Identity $DifferenceObject -Property MemberOf
        }
    } process {
        Compare-Object -RefferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property MemberOf -IncludeEqual:(!!$IncludeEqual) -ExcludeDifferent:(!!$ExcludeDifferent)
    }
}