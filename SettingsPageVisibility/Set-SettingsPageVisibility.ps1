<#
.SYNOPSIS
    Configures the SettingsPageVisibility registry key.
.PARAMETER Hide
    Hides the specified settings pages. If settings pages are already hidden, the ones specified will be added to the list of hidden pages. If the SettingsPageVisibility setting is configured in ShowOnly mode, the specified settings pages will be removed from the list of explicitly shown pages.
.PARAMETER HideOnly
    Overwrites the SettingsPageVisibility registry property to hide only the specified pages. 
.PARAMETER Show
    Removes the specified settings pages from the list of hidden settings pages. Alternatively, if the SettingsPageVisibility setting is configured in ShowOnly mode, the specified settings pages are added to the list of pages that are explicitly shown.
.PARAMETER ShowOnly
    Specifies which settings pages should be visible. Any pages not included will be hidden.
.PARAMETER InputObject
    Configures the SettingsPageVisibility registry property based on the configurations inside a `[SettingsPageVisibility]` object.
.PARAMETER Clear
    Clears the SettingsPageVisibility registry property.
.PARAMETER Scope
    Configures the SettingsPageVisibility registry property in the HKEY_CURRENT_USER registry hive instead of the HKEY_LOCAL_MACHINE hive.
.PARAMETER PassThru
    Outputs the configured settings page visbility after applying the changes.
.INPUTS
    InputObject: SettingsPageVisibility
    A SettingsPageVisibility object can be piped into this function. When a SettingsPageVisibility object is piped into this function, the SettingsPageVisibility settings are configured to reflect those set in the object.
.OUTPUTS
    SettingsPageVisibility
    When the `-PassThru` parameter is used, a SettingsPageVisibility object is returned containing the current configuration.
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
        [SettingsPageVisibilityModifier]$Modifier,
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer,
        [Switch]$PassThru,
        [Switch]$Force
    )

    if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
        $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
    }

    if ($PSCmdlet.ParameterSetName -ne 'InputObject') {
        [SettingsPageVisibility]$InputObject = [SettingsPageVisibility]::Get()

        if ($PSCmdlet.ParameterSetName -eq 'HiddenSettings') {
            $InputObject.HiddenSettings = $HiddenSettings
        } elseif ($PSCmdlet.ParameterSetName -eq 'ShownSettings') {
            $InputObject.ShownSettings = $ShownSettings
        }

        if ($PSBoundParameters.Containskey('Modifier')) {
            $InputObject.Modifier = $Modifier
        }

        if ($Clear) {
            $InputObject.Clear()
        }
    }

    if ($PSCmdlet.ShouldProcess($InputObject.Value)) {
        $InputObject.Set($Scope)

        if ($PassThru) {
            $PSCmdlet.WriteObject($InputObject)
        }
    }
}