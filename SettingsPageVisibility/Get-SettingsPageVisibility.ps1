<#
.DESCRIPTION
    Gets the current configuration of the SettingsPageVisibility registry key.
.PARAMETER Scope
    Defines whether to retrieve the computer or current user configuration for the SettingsPageVisibility registry key.
    The default value for this parameter is `Computer`.
.EXAMPLE
    Get-SettingsPageVisibility
.EXAMPLE
    Get-SettingsPageVisibility -Scope CurrentUser
.NOTES
    Author: Michael Hollingsworth
#>
function Get-SettingsPageVisibility {
    [CmdletBinding()]
    [OutputType([SettingsPageVisibility])]
    param (
        [Parameter(Position = 0)]
        [PSDefaultValue(Help = 'Computer')]
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer
    )

    return [SettingsPageVisibility]::Get($Scope)
}
