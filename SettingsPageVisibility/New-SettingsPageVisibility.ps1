<#
.DESCRIPTION
    Creates a new SettingsPageVisibility object
.PARAMETER HiddenSettings
    Defines the settings pages that will be in the HiddenSettings property of the SettingsPageVisibility object.
    All other settings will be in the ShownSettings property.
.PARAMETER ShownSettings
    Defines the settings pages that will be in the ShownSettings property of the SettingsPageVisibility object.
    All other settings will be in the HiddenSettings property.
.PARAMETER Modifier
    The default value of this parameter is `Hide`.
.EXAMPLE
    New-SettingsPageVisibility
        Creates a new SettingsPageVisibility object without any settings defined.
.EXAMPLE
    New-SettingsPageVisibility -HiddenSettings WindowsUpdate
        Creates a SettingsPageVisibility object where the WindowsUpdate settings page is hidden and all other pages are allowed.
.EXAMPLE
    New-SettingsPageVisibility -ShownSettings About -Modifier ShowOnly | Set-SettingsPageVisibility -Force
        Creates a SettingsPageVisibility object where the About settings page is the only page allowed and applies the configuration.
.NOTES
    Author: Michael Hollingsworth
#>
function New-SettingsPageVisibility {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([SettingsPageVisibility])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'HiddenSettings')]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [String[]]$HiddenSettings,
        [Parameter(Mandatory = $true, ParameterSetName = 'ShownSettings')]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [String[]]$ShownSettings,
        [Parameter(Position = 1, ParameterSetName = 'HiddenSettings')]
        [Parameter(Position = 1, ParameterSetName = 'ShownSettings')]
        [PSDefaultValue(Help = 'Hide')]
        [SettingsPageVisibilityModifier]$Modifier = [SettingsPageVisibilityModifier]::Hide
    )

    if ($PSCmdlet.ParameterSetName -eq 'HiddenSettings') {
        return [SettingsPageVisibility]::FromHiddenSettings($HiddenSettings, $Modifier)
    } elseif ($PSCmdlet.ParameterSetName -eq 'ShownSettings') {
        return [SettingsPageVisibility]::FromShownSettings($ShownSettings, $Modifier)
    } else {
        return [SettingsPageVisibility]::new()
    }
}
