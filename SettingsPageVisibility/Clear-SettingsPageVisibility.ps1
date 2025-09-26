<#
.DESCRIPTION
    Clears the SettingsPageVisibility configuration.
.PARAMETER Scope
    Configures the SettingsPageVisibility registry property in the HKEY_CURRENT_USER registry hive or the HKEY_LOCAL_MACHINE hive.
.PARAMETER PassThru
    Passes an object that represents the item to the pipeline. By default, this function does not generate any output.
.PARAMETER Force
    Forces the command to run without asking for user confirmation.
.EXAMPLE
    Clear-SettingsPageVisibility -Force
#>
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
