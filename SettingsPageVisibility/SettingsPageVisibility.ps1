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
        [System.Text.RegularExpressions.Group]$spvMatches = ([SettingsPageVisibility]::spvPattern).Match($Value)

        if ($spvMatches.Success -ne $true) {
            #TODO: should we throw?
            Write-Error -Category InvalidData -TargetObject $Value -Message "The SettingsPageVisbility value [$Value] does not match the expected pattern [$(([SettingsPageVisibility]::spvPattern).ToString())]."
        }

        if ([String]::IsNullOrWhiteSpace($Value)) {
            $this.Clear()
            return
        }

        if ($spvMatches.Groups[1].Value -eq 'hide') {
            #TODO: Replace all of this with a custom Enumeration class that supports 200+ flags and support for a secondary property that contains the 
            [String[]]$hiddenVals = $spvMatches.Groups[2].Value.Split(';')
            $this._shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $hiddenVals }
            $this._hiddenSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $this._shownSettings }
            $this._modifier = [SettingsPageVisibilityModifier]::Hide
        } elseif ($spvMatches.Groups[1].Value -eq 'showonly') {
            [String[]]$shownVals = $spvMatches.Groups[2].Value.Split(';')
            $this._shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -in $shownVals }
            $this._hiddenSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $this._shownSettings }
            $this._modifier = [SettingsPageVisibilityModifier]::ShowOnly
        } else {
            throw 'An unknown error occured. Fix the regex'
        }

        $this._value = $Value
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
            Remove-ItemProperty -LiteralPath $keyPath -Name 'SettingsPageVisibility' -Force
            return
        }

        Set-ItemProperty -LiteralPath $keyPath -Name 'SettingsPageVisibility' -Value $this.Value -Force
    }

    [String] ToString() {
        return $this._value
    }

    static [SettingsPageVisibility] Get() {
        return [SettingsPageVisibility]::Get([SettingsPageVisibilityScope]::Computer)
    }

    static [SettingsPageVisibility] Get([SettingsPageVisibilityScope]$Scope) {
        $explorer = if ($Scope -eq [SettingsPageVisibilityScope]::Computer) {
            Get-ItemProperty -LiteralPath "HKLM:$([SettingsPageVisibility]::spvKeyPath)" -ErrorAction Ignore
        } else {
            Get-ItemProperty -LiteralPath "HKCU:$([SettingsPageVisibility]::spvKeyPath)" -ErrorAction Ignore
        }

        if (($explorer.PSObject.Properties.Name -contains 'SettingsPageVisibility') -and (-not [String]::IsNullOrWhiteSpace($explorer.SettingsPageVisibility))) {
            return [SettingsPageVisibility]::new($explorer.SettingsPageVisibility)
        } else {
            return [SettingsPageVisibility]::new()
        }
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
Update-TypeData -TypeName SettingsPageVisibility -MemberName HiddenSettings -MemberType ScriptProperty -Value { return $this._hiddenSettings } -SecondValue {
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
        [String]$string = (($this._modifier).ToString() + ':' + ([String]::Join(';', $HiddenSettings))).ToLower()
    } else {
        [String[]]$shownSettings = [SettingsPageVisibility]::SettingsPageVisibilitySettings | Where-Object { $_ -notin $HiddenSettings }
        [String]$string = (($this._modifier).ToString() + ':' + ([String]::Join(';', $shownSettings))).ToLower()
    }

    $this.ParseValue($string)
    return
}
Update-TypeData -TypeName SettingsPageVisibility -MemberName ShownSettings -MemberType ScriptProperty -Value { return $this._shownSettings } -SecondValue {
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
        [String]$string = (($this._modifier).ToString() + ':' + ([String]::Join(';', $hiddenSettings))).ToLower()
    } else {
        [String]$string = (($this._modifier).ToString() + ':' + ([String]::Join(';', $ShownSettings))).ToLower()
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