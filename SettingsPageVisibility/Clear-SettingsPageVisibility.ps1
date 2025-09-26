function Clear-SettingsPageVisibility {
    [CmdletBinding()]
    param (
        [PSDefaultValue(Help = 'Computer')]
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer,
        [Switch]$PassThru,
        [Switch]$Force
    )

    [String]$regKeyPath = if ($Scope -eq [SettingsPageVisibilityScope]::Computer) {
        "HKLM:$([SettingsPageVisibility]::spvKeyPath)"
    } else {
        "HKCU:$([SettingsPageVisibility]::spvKeyPath)"
    }

    if (-not (($regKey = Get-Item -LiteralPath $regKeyPath -ErrorAction Stop) -and ($regKey.GetValueNames().Contains('SettingsPageVisibility')))) {
        return
    }

    Remove-ItemProperty -LiteralPath $regKeyPath -Name 'SettingsPageVisibility' -Force:(!!$Force) -ErrorAction Stop

    if ($PassThru) {
        return [SettingsPageVisbility]::Get($Scope)
    }
}
