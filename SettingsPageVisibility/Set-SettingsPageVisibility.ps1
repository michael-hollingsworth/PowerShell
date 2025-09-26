<#
.SYNOPSIS
    Configures the SettingsPageVisibility registry key.
.PARAMETER HiddenSettings
    Overwrites the SettingsPageVisibility registry property to hide only the specified pages. 
.PARAMETER ShownSettings
    Specifies which settings pages should be visible. Any pages not included will be hidden.
.PARAMETER InputObject
    Configures the SettingsPageVisibility registry property based on the configurations inside a `[SettingsPageVisibility]` object.
.PARAMETER Clear
    Clears the SettingsPageVisibility registry property.
.PARAMETER Modifier
    Defines whether to use the Hide or ShowOnly modifier.
    The Hide modifier only hides settings that are explicitly defined as being hidden.
    The ShowOnly modifier hides all settings that aren't explicitly defined as being shown.
.PARAMETER Scope
    Configures the SettingsPageVisibility registry property in the HKEY_CURRENT_USER registry hive or the HKEY_LOCAL_MACHINE hive.
.PARAMETER PassThru
    Passes an object that represents the item to the pipeline. By default, this function does not generate any output.
.PARAMETER Force
    Forces the command to run without asking for user confirmation.
.INPUTS
    InputObject: SettingsPageVisibility
    A SettingsPageVisibility object can be piped into this function. When a SettingsPageVisibility object is piped into this function, the SettingsPageVisibility settings are configured to reflect those set in the object.
.OUTPUTS
    SettingsPageVisibility
    When the `-PassThru` parameter is used, a SettingsPageVisibility object is returned containing the current configuration.
.NOTES
    Author: Michael Hollingsworth
.LINK
    https://learn.microsoft.com/en-us/windows/configuration/settings/page-visibility
    https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/customize/page-visibility
    https://learn.microsoft.com/en-us/windows/apps/develop/launch/launch-settings-app#ms-settings-uri-scheme-reference
#>
function Set-SettingsPageVisibility {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High, DefaultParameterSetName = 'HiddenSettings')]
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()]
        [Alias('SettingsPageVisibility')]
        [SettingsPageVisibility]$InputObject,
        [Parameter(Mandatory = $true, ParameterSetName = 'Clear')]
        [Switch]$Clear,
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'HiddenSettings')]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ShownSettings')]
        [PSDefaultValue(Help = 'Hide')]
        [SettingsPageVisibilityModifier]$Modifier = [SettingsPageVisibilityModifier]::Hide,
        [PSDefaultValue(Help = 'Computer')]
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer,
        [Switch]$PassThru,
        [Switch]$Force
    )

    if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
        $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
    }

    if ($Clear) {
        Clear-SettingsPageVisibility -PassThru:(!!$PassThru) -Force:(!!$Force)
    }

    if ($PSCmdlet.ParameterSetName -ne 'InputObject') {
        [SettingsPageVisibility]$InputObject = [SettingsPageVisibility]::Get()

        if ($PSCmdlet.ParameterSetName -eq 'HiddenSettings') {
            $InputObject.HiddenSettings = $HiddenSettings
        } elseif ($PSCmdlet.ParameterSetName -eq 'ShownSettings') {
            $InputObject.ShownSettings = $ShownSettings
        }

        $InputObject.Modifier = $Modifier
    }

    if ($PSCmdlet.ShouldProcess($InputObject.Value)) {
        $InputObject.Set($Scope)

        if ($PassThru) {
            $PSCmdlet.WriteObject($InputObject)
        }
    }
}
