<#
.NOTES
    Latest release: https://update.code.visualstudio.com/api/update/win32-x64/stable/latest
    Stable releases: https://update.code.visualstudio.com/api/releases/stable
    Download: https://update.code.visualstudio.com/$Version/win32-x64/$Branch
.NOTES
    Author: Michael Hollingsworth
#>
function Get-VisualStudioCodeRelease {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        # This isn't hooked up. From what I can tell, there isn't a way to pull back information about a particular release. You can only get a dl url.
        [Version]$Version,
        [Parameter(Position = 1)]
        [ValidateSet('win32-x64', 'win32-x64-user', 'win32-arm64', 'win32-arm64-user')]
        [String]$Platform = 'win32-x64',
        [Parameter(Position = 2)]
        [ValidateSet('Stable', 'Insider')]
        [String]$Branch = 'Stable'
    )

    begin {
        [String]$uri = 'https://update.code.visualstudio.com'
        $uri += if ($null -eq $Version) { '/api/update' } else { $Version }
        $uri += "/$Platform"
        $uri += "/$($Branch.ToLower())"
        if ($null -eq $Version) { $uri += '/latest' }
    } process {
        $releases = Invoke-RestMethod -Uri $uri -Method Get

        foreach ($release in $releases) {
            $release.timestamp = [System.DateTimeOffset]::FromUnixTimeMilliseconds($release.timestamp).DateTime
            Add-Member -InputObject $release -MemberType NoteProperty -Name branch -Value $Branch
            $PSCmdlet.WriteObject($release)
        }
    }
}

New-Alias -Name 'Get-VSCodeRelease' -Value 'Get-VisualStudioCodeRelease'