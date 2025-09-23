function Get-SettingsPageVisibility {
    [CmdletBinding()]
    [OutputType([SettingsPageVisibility])]
    param (
        [Parameter(Position = 0)]
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer
    )

    return [SettingsPageVisibility]::Get($Scope)
}