enum SettingsPageVisibilityModifier {
    Hide = 1
    ShowOnly = 2
}

enum SettingsPageVisibilityScope {
    Computer = 1
    CurrentUser = 2
}

class SettingsPageVisibility {
    hidden [System.Nullable[SettingsPageVisibilityModifier]]$_modifier
    hidden [String[]]$_hiddenSettings
    hidden [String[]]$_shownSettings
    hidden [String]$_value

    SettingsPageVisibility() {
        $this._modifier = $null
        $this._hiddensettings = @()
        $this._shownsettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings
        $this._value = ''
    }

    SettingsPageVisibility([String]$Value) {
        $this.ParseValue($Value)
    }

    hidden [Void] ParseValue([String]$Value) {
        if ([String]::IsNullOrWhiteSpace($Value)) {
            $this.Clear()
            return
        }

        [System.Text.RegularExpressions.Group]$spvMatches = ([SettingsPageVisibility]::spvPattern).Match($Value)

        if ($spvMatches.Success -ne $true) {
            throw [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.ParameterBindingException]::new("Cannot validate the argument on parameter [Value]. The argument [$Value] does not match the pattern [$(([SettingsPageVisibility]::spvPattern).ToString())]."),
                'ParameterArgumentValidationError',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $Value
            )
        }

        [String[]]$values = $spvMatches.Groups[2].Value.Split(';')

        if ($spvMatches.Groups[1].Value -eq 'hide') {
            $this._shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $values }
            $this._hiddenSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $this._shownSettings }
            $this._modifier = [SettingsPageVisibilityModifier]::Hide
            $this._value = (([SettingsPageVisibilityModifier]::Hide).ToString() + ':' + ([String]::Join(';', $this._hiddenSettings))).ToLower()
        } elseif ($spvMatches.Groups[1].Value -eq 'showonly') {
            $this._shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -in $values }
            $this._hiddenSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $this._shownSettings }
            $this._modifier = [SettingsPageVisibilityModifier]::ShowOnly
            $this._value = (([SettingsPageVisibilityModifier]::ShowOnly).ToString() + ':' + ([String]::Join(';', $this._shownSettings))).ToLower()
        }
    }

    [Void] Clear() {
        $this._modifier = $null
        $this._hiddenSettings = @()
        $this._shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings
        $this._value = ''
    }

    [Void] Set() {
        $this.Set([SettingsPageVisibilityScope]::Computer)
    }

    [Void] Set([SettingsPageVisibilityScope]$Scope) {
        [String]$keyPath = if ($Scope -eq [SettingsPageVisibilityScope]::Computer) {
            "HKLM:$([SettingsPageVisibility]::spvKeyPath)"
        } elseif ($Scope -eq [SettingsPageVisibilityModifier]::CurrentUser) {
            "HKCU:$([SettingsPageVisibility]::spvKeyPath)"
        }

        if ($null -eq $this._modifier) {
            Remove-ItemProperty -LiteralPath $keyPath -Name 'SettingsPageVisibility' -Force -ErrorAction Stop
            return
        }

        Set-ItemProperty -LiteralPath $keyPath -Name 'SettingsPageVisibility' -Value $this.Value -Force -ErrorAction Stop
    }

    [String] ToString() {
        return $this._value
    }

    static [SettingsPageVisibility] Get() {
        return [SettingsPageVisibility]::Get([SettingsPageVisibilityScope]::Computer)
    }

    static [SettingsPageVisibility] Get([SettingsPageVisibilityScope]$Scope) {
        [String]$regKeyPath = if ($Scope -eq [SettingsPageVisibilityScope]::Computer) {
            "HKLM:$([SettingsPageVisibility]::spvKeyPath)"
        } else {
            "HKCU:$([SettingsPageVisibility]::spvKeyPath)"
        }

        if (($regKey = Get-Item -LiteralPath $regKeyPath -ErrorAction Stop) -and ($regKey.GetValueNames().Contains('SettingsPageVisibility'))) {
            [SettingsPageVisibility]$spv = [SettingsPageVisibility]::new($regKey.SettingsPageVisibility)
            # Manually set the Value property to the exact value in the registry key.
            ## Calling the new($Value) constructor includes logic to ensure that each settings page only appears once and that invalid settings page values are removed.
            $spv._value = $regKey.SettingsPageVisibility
            return $spv
        }

        return [SettingsPageVisibility]::new()
    }

    static [SettingsPageVisibility] FromHiddenSettings([String[]]$HiddenSettings) {
        return [SettingsPageVisibility]::FromShownSettings($HiddenSettings, [SettingsPageVisibilityModifier]::Hide)
    }

    static [SettingsPageVisibility] FromHiddenSettings([String[]]$HiddenSettings, [SettingsPageVisibilityModifier]$Modifier) {
        [SettingsPageVisibility]$spv = [SettingsPageVisibility]::new()
        $spv.Modifier = $Modifier
        $spv.HiddenSettings = $HiddenSettings
        return $spv
    }

    static [SettingsPageVisibility] FromShownSettings([String[]]$ShownSettings) {
        return [SettingsPageVisibility]::FromShownSettings($ShownSettings, [SettingsPageVisibilityModifier]::Hide)
    }

    static [SettingsPageVisibility] FromShownSettings([String[]]$ShownSettings, [SettingsPageVisibilityModifier]$Modifier) {
        [SettingsPageVisibility]$spv = [SettingsPageVisibility]::new()
        $spv.Modifier = $Modifier
        $spv.ShownSettings = $ShownSettings
        return $spv
    }

    hidden static [String]$spvKeyPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    hidden static [System.Text.RegularExpressions.Regex]$spvPattern = [System.Text.RegularExpressions.Regex]::new('^(hide|showonly):(|([\w\-]+(?:;[\w\-]+)*))$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    static [String[]]$SettingsPageVisibilitySettings = @(
        'About',
        'Activation',
        'AppsFeatures',
        'AppsForWebsites',
        'Apps-Volume',
        'AssignedAccess',
        'AutoPlay',
        'Backup',
        'BatterySaver',
        'BatterySaver-Settings',
        'BatterySaver-UsageDetails',
        'Bluetooth',
        'Camera',
        'Clipboard',
        'Colors',
        'ConnectedDevices',
        'ControlCenter',
        'Cortana',
        'Cortana-Language',
        'Cortana-MoreDetails',
        'Cortana-Notifications',
        'Cortana-Permissions',
        'Cortana-TalkToCortana',
        'Cortana-WindowsSearch',
        'CrossDevice',
        'DateAndTime',
        'DefaultApps',
        'DefaultBrowserSettings',
        'Delivery-Optimization',
        'Delivery-Optimization-Activity',
        'Delivery-Optimization-Advanced',
        'Developeres',
        'DeviceEncryption',
        'Devices-Touch',
        'Devices-TouchPad',
        'DevicesTyping-HWKBTextSuggestions',
        'DeviceUsage',
        'DiskAndVolumes',
        'Display',
        'Display-Advanced',
        'Display-AdvancedGraphics',
        'Display-AdvancedGraphics-Default',
        'EaseOfAccess-Audio',
        'EaseOfAccess-BlueLightLink',
        'EaseOfAccess-ClosedCaptioning',
        'EaseOfAccess-ColorFilter',
        'EaseOfAccess-ColorFilter-AdaptiveColorLink',
        'EaseOfAccess-Cursor',
        'EaseOfAccess-Display',
        'EaseOfAccess-EyeControl',
        'EaseOfAccess-HearingAids',
        'EaseOfAccess-HighContrast',
        'EaseOfAccess-Keyboard',
        'EaseOfAccess-Magnifier',
        'EaseOfAccess-Mouse',
        'EaseOfAccess-MousePointer',
        'EaseOfAccess-Narrator',
        'EaseOfAccess-Narrator-IsAutoStartEnabled',
        'EaseOfAccess-SpeechRecognition',
        'EaseOfAccess-VisualEffects',
        'EmailAndAccounts',
        'EnergyRecommendations',
        'Extras',
        'Family-Group',
        'FindMyDevice',
        'Fonts',
        'Gaming-GameBar',
        'Gaming-GameDVR',
        'Gaming-GameMode',
        'Gaming-TruePlay',
        'Holographic-Audio',
        'Holographic-Headset',
        'Holographic-Management',
        'Holographic-StartupAndDesktop',
        'Keyboard',
        'Keyboard-Advanced',
        'LockScreen',
        'Maps',
        'Maps-DownloadMaps',
        'Mobile-Devices',
        'Mobile-Devices-AddPhone',
        'Mobile-Devices-AddPhone-Direct',
        'MouseTouchPad',
        'Multitasking',
        'Multitasking-SGUpdate',
        'Network-AdvancedSettings',
        'Network-AirplaneMode',
        'Network-Cellular',
        'Network-DialUp',
        'Network-DirectAccess',
        'Network-Ethernet',
        'Network-MobileHotspot',
        'Network-Proxy',
        'Network-Status',
        'Network-VPN',
        'Network-WiFi',
        'Network-WiFiSettings',
        'NightLight',
        'Notifications',
        'OptionalFeatures',
        'OtherUsers',
        'Pen',
        'Personalization',
        'Personalization-Background',
        'Personalization-Colors',
        'Personalization-Glance',
        'Personalization-Lighting',
        'Personalization-NavBar',
        'Personalization-Start',
        'Personalization-Start-Places',
        'Personalization-TextInput',
        'Personalization-TextInput-Copilor-HardwareKey',
        'Personalization-TouchKeyboard',
        'Phone',
        'PowerSleep',
        'Presence',
        'Printers',
        'Privacy',
        'Privacy-AccessoryApps',
        'Privacy-AccountHistory',
        'Privacy-AccountInfo',
        'Privacy-AdvertisingID',
        'Privacy-AppDiagnostics',
        'Privacy-AutomaticFileDownloads',
        'Privacy-BackgroundApps',
        'Privacy-BackgroundSpatialPerception',
        'Privacy-BroadFileSystemAccess',
        'Privacy-Calendar',
        'Privacy-CallHistory',
        'Privacy-Camera',
        'Privacy-Contacts',
        'Privacy-CustomDevices',
        'Privacy-Documents',
        'Privacy-DownloadsFolder',
        'Privacy-Email',
        'Privacy-EyeTracker',
        'Privacy-Feedback',
        'Privacy-General',
        'Privacy-GraphicsCaptureProgrammatic',
        'Privacy-GraphicsCaptureWithoutBorder',
        'Privacy-Holographic-Environment',
        'Privacy-Location',
        'Privacy-Messaging',
        'Privacy-Microphone',
        'Privacy-Motion',
        'Privacy-MusicLibrary',
        'Privacy-Notifications',
        'Privacy-PhoneCalls',
        'Privacy-Pictures',
        'Privacy-Radios',
        'Privacy-Speech',
        'Privacy-SpeechTyping',
        'Privacy-Tasks',
        'Privacy-Videos',
        'Privacy-VoiceActivation',
        'Privacy-Webcam',
        'Project',
        'Provisioning',
        'Proximity',
        'QuietHours',
        'QuietMomentsGame',
        'QuietMomentsPresentation',
        'QuietMomentsScheduled',
        'Recovery',
        'RegionFormatting',
        'RegionLanguage',
        'RegionLanguage-BpmfIME',
        'RegionLanguage-CangjieIME',
        'RegionLanguage-ChsIME-Pinyin',
        'RegionLanguage-ChsIME-Pinyin-DomainLexicon',
        'RegionLanguage-ChsIME-Pinyin-KeyConfig',
        'RegionLanguage-ChsIME-Pinyin-Udp',
        'RegionLanguage-ChsIME-Wubi',
        'RegionLanguage-ChsIME-Wubi-Udp',
        'RegionLanguage-JpnIME',
        'RegionLanguage-KorIME',
        'RegionLanguage-Quicktime',
        'RemoteDesktop',
        'SaveLocations',
        'ScreenRotation',
        'Search',
        'Search-MoreDetails',
        'Search-Permissions',
        'SignInOptions',
        'SignInOptions-DynamicLock',
        'SignInOptions-LaunchFaceEnrollment',
        'SignInOptions-LaunchFingerprintEnrollment',
        'SignInOptions-LaunchSecurityKeyEnrollment',
        'Sound',
        'Sound-DefaultInputProperties',
        'Sound-DefaultOutputProperties',
        'Sound-Devices',
        'Speech',
        'StartupApps',
        'StoragePolicies',
        'StorageRecommendations',
        'StorageSense',
        'SurfaceHub-Accounts',
        'SurfaceHub-Calling',
        'SurfaceHub-DeviceManagement',
        'SurfaceHub-SessionCleanup',
        'SurfaceHub-Welcome',
        'Sync',
        'TabletMode',
        'Taskbar',
        'Themes',
        'Troubleshoot',
        'Typing',
        'USB',
        'VideoPlayback',
        'Wheel',
        'WiFi-Provisioning',
        'WindowsAnywhere',
        'WindowsDefender',
        'WindowsInsider',
        'WindowsInsider-OptiIn',
        'WindowsUpdate',
        'WindowsUpdate-Action',
        'WindowsUpdate-ActiveHours',
        'WindowsUpdate-History',
        'WindowsUpdate-OptionalUpdates',
        'WindowsUpdate-Options',
        'WindowsUpdate-RestartOptions',
        'WindowsUpdate-SeekerOnDemand',
        'Workplace',
        'Workplace-Provisioning',
        'Workplace-RepairToken',
        'YourInfo'
    )
}

Update-TypeData -TypeName SettingsPageVisibility -MemberName Modifier -MemberType ScriptProperty -Value { return $this._modifier } -SecondValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [SettingsPageVisibilityModifier]$Modifier
    )

    if ($this._modifier -eq $Modifier) {
        return
    }

    $this._modifier = $Modifier
    $this._value = if ($Modifier -eq [SettingsPageVisibilityModifier]::Hide) {
        ([SettingsPageVisibilityModifier]::Hide.ToString() + ':' + ([String]::Join(';', $this._hiddenSettings))).ToLower()
    } else {
        ([SettingsPageVisibilityModifier]::ShowOnly.ToString() + ':' + ([String]::Join(';', $this._shownSettings))).ToLower()
    }
}
Update-TypeData -TypeName SettingsPageVisibility -MemberName HiddenSettings -MemberType ScriptProperty -Value { if ($this._hiddenSettings.Count -eq 1) { return @(, $this._hiddenSettings) } else { return $this._hiddenSettings } } -SecondValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [String[]]$HiddenSettings
    )

    if ($null -eq $this._modifier) {
        $this._modifier = [SettingsPageVisibilityModifier]::Hide
    }

    #TODO: ensure that parsing methods can parse empty arrays (eg. hide:none or showonly:none)
    if ($this._modifier -eq [SettingsPageVisibilityModifier]::Hide) {
        [String]$string = (([SettingsPageVisibilityModifier]::Hide).ToString() + ':' + ([String]::Join(';', $HiddenSettings))).ToLower()
    } else {
        [String[]]$shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $HiddenSettings }
        [String]$string = (([SettingsPageVisibilityModifier]::ShowOnly).ToString() + ':' + ([String]::Join(';', $shownSettings))).ToLower()
    }

    $this.ParseValue($string)
    return
}
Update-TypeData -TypeName SettingsPageVisibility -MemberName ShownSettings -MemberType ScriptProperty -Value { if ($this._shownSettings.Count -eq 1) { return @(, $this._shownSettings) } else { return $this._shownSettings } } -SecondValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ArgumentCompleter({
            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        })]
        [String[]]$ShownSettings
    )

    if ($null -eq $this._modifier) {
        $this._modifier = [SettingsPageVisibilityModifier]::Hide
    }

    if ($this._modifier -eq [SettingsPageVisibilityModifier]::Hide) {
        [String[]]$hiddenSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $ShownSettings }
        [String]$string = (([SettingsPageVisibilityModifier]::Hide).ToString() + ':' + ([String]::Join(';', $hiddenSettings))).ToLower()
    } else {
        [String]$string = (([SettingsPageVisibilityModifier]::ShowOnly).ToString() + ':' + ([String]::Join(';', $ShownSettings))).ToLower()
    }

    $this.ParseValue($string)
    return
}
Update-TypeData -TypeName SettingsPageVisibility -MemberName Value -MemberType ScriptProperty -Value { return $this._value } -SecondValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Value
    )

    $this.ParseValue($Value)
}

# This class can be used for validating parameters on PowerShell 6+
## https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters#dynamic-validateset-values-using-classes
## https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_argument_completion#dynamic-validateset-values-using-classes
### [ValidateSet([SettingsPageValidateSet])]
<# class SettingsPageValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [SettingsPageVisibility]::SettingsPageVisibilitySettings
    }
} #>
