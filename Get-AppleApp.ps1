<#
.DESCRIPTION
    This function is used to lookup information about an application on the iTunes/Apple store by its app ID or Bundle ID.
    This is particularly useful for MDM/MAM/UEM tools such as IBM MaaS360 which don't provide much information about installed applications, other than the bundle ID.
.LINK
    https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html#//apple_ref/doc/uid/TP40017632-CH5-SW1
    https://performance-partners.apple.com/search-api
.NOTES
    Author: Michael Hollingsworth
#>
function Get-AppleApp {
    [CmdletBinding(DefaultParameterSetName = 'BundleId')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'AppId')]
        [ValidateNotNullOrEmpty()]
        [String[]]$AppId,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'BundleId')]
        [ValidateNotNullOrEmpty()]
        [String[]]$BundleId,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Country = 'us',
        [Parameter(ParameterSetName = 'Name')]
        [ValidateRange(1, 200)]
        [Int32]$SearchLimit = 50,
        [Parameter(ParameterSetName = 'Name')]
        [ValidateSet('en_us', 'ja_jp')]
        [String]$Language = 'en_us',
        [Parameter(ParameterSetName = 'Name')]
        [ValidateRange(1, 2)]
        [Int32]$ApiVersion = 2
    )

    begin {
        [HashTable]$params = @{
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
            Body = @{
                Country = $Country
            }
        }

        switch ($PSCmdlet.ParameterSetName) {
            'AppId' { $params.Add('Uri', 'https://itunes.apple.com/lookup'); $ids = $AppId; $searchTerm = 'id'; break }
            'BundleId' { $params.Add('Uri', 'https://itunes.apple.com/lookup'); $ids = $BundleId; $searchTerm = 'bundleId'; break }
            'Name' {
                $params.Add('Uri', 'https://itunes.apple.com/search')
                $params.Body.Add('limit', $SearchLimit)
                $params.Body.Add('media', 'software')
                $params.Body.Add('lang', $Language)
                $params.Body.Add('version', $ApiVersion)
                $ids = $Name;
                $searchTerm = 'term'
            }
        }
    } process {
        foreach ($id in $ids) {
            #TODO: Properly encode the search term:
            ## URL encoding replaces spaces with the plus (+) character and all characters except the following are encoded: letters, numbers, periods (.), dashes (-), underscores (_), and asterisks (*).
            $params.Body.$searchTerm = $id -replace ' ', '+'
            (Invoke-RestMethod @params).results
        }
    }
}
