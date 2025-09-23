function Show-SettingsPage {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = [System.Management.Automation.ConfirmImpact]::High)]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'HiddenSettings')]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [String[]]$SettingsPage,
        [SettingsPageVisibilityScope]$Scope = [SettingsPageVisibility]::Computer,
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