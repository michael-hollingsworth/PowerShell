<#
.DESCRIPTION
    Unhides a hidden settings page in the settings application.
.PARAMETER SettingsPage
    Defines the settings page(s) that will be unhidden in the settings application.
.PARAMETER Scope
    Configures the SettingsPageVisibility registry property in the HKEY_CURRENT_USER registry hive or the HKEY_LOCAL_MACHINE hive.
.PARAMETER PassThru
    Passes an object that represents the item to the pipeline. By default, this function does not generate any output.
.PARAMETER Force
    Forces the command to run without asking for user confirmation.
.EXAMPLE
    Show-SettingsPage -SettingsPage WindowsUpdate
.NOTES
    Author: Michael Hollingsworth
#>
function Show-SettingsPage {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [ValidateNotNullOrEmpty()]
        [String[]]$SettingsPage,
        [PSDefaultValue(Help = 'Computer')]
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibilityScope]::Computer,
        [Switch]$PassThru,
        [Switch]$Force
    )

    if ($Force -and (-not $PSBoundParameters.ContainsKey('Confirm'))) {
        $ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None
    }

    [SettingsPageVisibility]$spv = [SettingsPageVisibility]::Get($Scope)
    $spv.ShownSettings += $SettingsPage

    if ($PSCmdlet.ShouldProcess($SettingsPage)) {
        $spv.Set($Scope)

        if ($PassThru) {
            return $spv
        }
    }
}