<#
.DESCRIPTION
    
.LINK
    https://learn.microsoft.com/en-us/windows/apps/develop/launch/launch-settings-app#ms-settings-uri-scheme-reference
#>

# All settings from the link above. This includes duplicates and some settings that has search strings
$settings = @(
    'Workplace',
    'EmailAndAccounts',
    'OtherUsers',
    'Provisioning',  # only available on mobile and if the enterprise has deployed a provisioning package
    'Workplace-Provisioning',  # only available if enterprise has deployed a provisioning package
    'Workplace-RepairToken',
    'AssignedAccess',
    'SignInOptions',
    'SignInOptions-DynamicLock',
    'Sync',
    'Backup',  # Backup page deprecated in Windows 11
    'WindowsAnywhere',  # device must be Windows Anywhere-capable
    'SignInOptions-LaunchFaceEnrollment',
    'SignInOptions-LaunchFingerprintEnrollment',
    'YourInfo',
    'AppsFeatures',
    #'AppsFeatures-App?<PACKAGE_FAMILY_NAME>'
    'AppsForWebsites',
    'DefaultApps',  # Behavior introduced in Windows 11, version 21H2 (with 2023-04 Cumulative Update) or 22H2 (with 2023-04 Cumulative Update), or later.
    #https://learn.microsoft.com/en-us/windows/apps/develop/launch/launch-default-apps-settings
    #'defaultapps?registredAppMachine=<'
    #'defaultapps?registredAppUser=<'
    #'defaultapps?registredAUMID=<APPLICATION_USER_MODEL_ID>'
    'DefaultBrowserSettings',  # Deprecated in Windows 11
    'OptionalFeatures',
    'Maps',
    'Maps-DownloadMaps',
    'StartupApps',
    'VideoPlayback',
    'ControlCenter',
    'Cortana-Notifications',
    'Cortana-MoreDetails',
    'Cortana-Permissions',
    'Cortana-WindowsSearch',
    'Cortana-Language',
    'Cortana',
    'Cortana-TalkToCortana',
    'AutoPlay',
    'Bluetooth',
    'ConnectedDevices',
    'Camera',  # Behavior deprecated in Windows 10, version 1809 and later
    #https://learn.microsoft.com/en-us/windows/apps/develop/camera/launch-camera-settings
    #'camera?cameraId=<CAMERA_ID>'
    'MouseTouchPad',  # touchpad settings only available on devices that have a touchpad
    'Pen',
    'Printers',
    'Devices-Touch',
    'Devices-TouchPad',  # only available if touchpad hardware is present
    'DevicesTyping-HWKBTextSuggestions',
    'Typing',
    'USB',
    'Wheel',  # only available if a Surface Dial device is paired
    'Mobile-Devices',
    'EaseOfAccess-Audio',
    'EaseOfAccess-ClosedCaptioning',
    'EaseOfAccess-ColorFilter',
    'EaseOfAccess-ColorFilter-AdaptiveColorLink',
    'EaseOfAccess-BlueLightLink',
    'EaseOfAccess-Display',
    'EaseOfAccess-EyeControl',
    'EaseOfAccess-HearingAids',  # Added in Windows 11, Version 24H2
    'EaseOfAccess-HighContrast',
    'EaseOfAccess-Keyboard',
    'EaseOfAccess-Magnifier',
    'EaseOfAccess-Mouse',
    'EaseOfAccess-MousePointer',
    'EaseOfAccess-Narrator',
    'EaseOfAccess-Narrator-IsAutoStartEnabled',
    'EaseOfAccess-SpeechRecognition',
    'EaseOfAccess-Cursor',
    'EaseOfAccess-VisualEffects',
    'Extras',  # only available if "settings apps" have been installed, for example, by a 3rd party
    'Family-Group',
    'Gaming-GameBar',
    'Gaming-GameDVR',
    'Gaming-GameMode',
    'QuietMomentsGame',
    'Gaming-TruePlay',  # As of Windows 10 version 1809 (10.0; Build 17763), this feature is removed from Windows
    'Holographic-Audio',
    'Privacy-Holographic-Environment',
    'Holographic-Headset',
    'Holographic-Management',
    'Holographic-StartupAndDesktop',
    'Network-Status',
    'Network-AdvancedSettings',
    'Network-AirplaneMode',
    'Proximity',
    'Network-Cellular',
    'Network-DialUp',
    'Network-DirectAccess',  # only available if DirectAccess is enabled
    'Network-Ethernet',
    'Network-WiFiSettings',
    'Network-MobileHotspot',
    'Network-Proxy',
    'Network-VPN',
    'Network-WiFi'  # only available if the device has a wifi adapter
    'WiFi-Provisioning',
    'Personalization-Background',
    'Personalization-Start-Places',
    'Personalization-Colors',
    'Colors',
    'Personalization-TextInput-Copilor-HardwareKey',
    'Personalization-Lighting',
    'Fonts',
    'Personalization-Glance',  # Deprecated in Windows 10, version 1809 and later
    'LockScreen',
    'Personalization-NavBar',  # Deprecated in Windows 10, version 1809 and later
    'Personalization',
    'Personalization-Start',
    'Taskbar',
    'Personalization-TextInput',
    'Personalization-TouchKeyboard',
    'Themes',
    'Mobile-Devices',
    'Mobile-Devices-AddPhone',
    'Mobile-Devices-AddPhone-Direct',  # Opens Your Phone app
    'DeviceUsage',
    'Privacy-AccessoryApps',  # Deprecated in Windows 10, 1809 and later
    'Privacy-AccountInfo',
    'Privacy-AccountHistory',
    'Privacy-AdvertisingID',  # Deprecated in Windows 10, version 1809 and later
    'Privacy-AppDiagnostics',
    'Privacy-AutomaticFileDownloads',
    'Privacy-BackgroundApps',  # Deprecated in Windows 11, 21H2 and later
    'Privacy-BackgroundSpatialPerception',
    'Privacy-Calendar'
    'Privacy-CallHistory'
    'Privacy-Camera'
    'Privacy-Webcam'
    'Privacy-Contacts'
    'Privacy-Documents'
    'Privacy-DownloadsFolder'
    'Privacy-Email'
    'Privacy-EyeTracker',  # requires eyetracker hardware
    'Privacy-Feedback',
    'Privacy-BroadFileSystemAccess',
    'Privacy',
    'Privacy-General',
    'Privacy-GraphicsCaptureProgrammatic',
    'Privacy-GraphicsCaptureWithoutBorder',
    'Privacy-SpeechTyping',
    'Privacy-Location',
    'Privacy-Messaging',
    'Privacy-Microphone',
    'Privacy-Motion',
    'Privacy-MusicLibrary',
    'Privacy-Notifications',
    'Privacy-CustomDevices',
    'Privacy-PhoneCalls',
    'Privacy-Pictures',
    'Privacy-Radios',
    'Privacy-Speech',
    'Privacy-Tasks',
    'Privacy-Videos',
    'Privacy-VoiceActivation',
    'Search',
    'Search-MoreDetails',
    'Search-Permissions',
    'Apps-Volume',
    'Sound',
    'Sound-Devices',
    'Sound-DefaultInputProperties',
    'Sound-DefaultOutputProperties',
    #'Sound-Properties?endpointId=<ENDPOINT_ID>,
    #'Sound-Properties?interfaceId=<INTERFACE_ID>,
    'SurfaceHub-Accounts',
    'SurfaceHub-SessionCleanup',
    'SurfaceHub-Calling',
    'SurfaceHub-DeviceManagement',
    'SurfaceHub-Welcome',
    'About',
    'Display-Advanced',
    'BatterySaver',
    'BatterySaver-Settings',
    'BatterySaver-UsageDetails',
    'Clipboard',
    'SaveLocations',
    'Display',
    'ScreenRotation',
    'QuietMomentsPresentation',
    'QuietMomentsScheduled',
    'DeviceEncryption',
    'EnergyRecommendations',  # Available in February Moment update for Windows 11, Version 22H2, Build 22624 or later
    'QuietHours',
    'Display-AdvancedGraphics',  # only available on devices that support advanced graphics options
    'Display-AdvancedGraphics-Default',
    'Multitasking',
    'Multitasking-SGUpdate',
    'NightLight',
    'Project',
    'CrossDevice',
    'TabletMode',  # Removed in Windows 11
    'Taskbar',
    'Notifications',
    'RemoteDesktop',
    'Phone',  # Deprecated in Windows 10, version 1809 and later
    'PowerSleep'
    'Presence',  # Added in May Moment update for Windows 11, Version 22H2, Build 22624
    'StorageSense',
    'StoragePolicies',
    'StorageRecommendations',
    'DiskAndVolumes',
    'DateAndTime',
    'RegionLanguage-JpnIME',  # available if the Microsoft Japan input method editor is installed
    'RegionFormatting',
    'Keyboard',
    'Keyboard-Advanced',
    'RegionLanguage',
    'RegionLanguage-BpmfIME',
    'RegionLanguage-CangjieIME',
    'RegionLanguage-ChsIME-Wubi-Udp',
    'RegionLanguage-Quicktime',
    'RegionLanguage-KorIME',
    'RegionLanguage-ChsIME-Pinyin',  # available if the Microsoft Pinyin input method editor is installed
    'RegionLanguage-ChsIME-Pinyin-DomainLexicon',
    'RegionLanguage-ChsIME-Pinyin-KeyConfig',
    'RegionLanguage-ChsIME-Pinyin-Udp',
    'Speech',
    'RegionLanguage-ChsIME-Wubi',  # available if the Microsoft Wubi input method editor is installed
    'Activation',
    'Backup',
    'Delivery-Optimization',
    'Delivery-Optimization-Activity',
    'Delivery-Optimization-Advanced',
    'FindMyDevice',
    'Developeres',
    'Recovery',
    'SignInOptions-LaunchSecurityKeyEnrollment',
    'Troubleshoot',
    'WindowsDefender',
    'WindowsInsider',  # only present if user is enrolled in WIP
    'WindowsInsider-OptiIn',
    'WindowsUpdate',
    'WindowsUpdate-Action',
    'WindowsUpdate-ActiveHours',
    'WindowsUpdate-Options',
    'WindowsUpdate-OptionalUpdates',
    'WindowsUpdate-RestartOptions',
    'WindowsUpdate-SeekerOnDemand',
    'WindowsUpdate-History'
)

# This retruns only the unique settings and sorts them alphabetically
$settings | Sort-Object | Select-Object -Unique