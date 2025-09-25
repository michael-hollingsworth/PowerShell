function Clear-SettingsPageVisibility {
    [CmdletBinding()]
    param (
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer,
        [Switch]$Force
    )

    [String]$regKey = if ($Scope -eq [SettingsPageVisibilityScope]::Computer) {
        "HKLM:$([SettingsPageVisibility]::spvKeyPath)"
    } else {
        "HKCU:$([SettingsPageVisibility]::spvKeyPath)"
    }

    Remove-ItemProperty -LiteralPath $regKey -Name 'SettingsPageVisibility' -Force:(!!$Force) -ErrorAction Ignore
}