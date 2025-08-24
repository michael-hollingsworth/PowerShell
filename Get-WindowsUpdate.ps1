function Install-WindowsUpdate {
    [CmdletBinding()]
    [OutputType([WindowsUpdate[]])]
    param (
        [Switch]$AcceptEula
        [Switch]$PassThru
    )

    begin {
        [String]$query = 'IsInstalled = 0'
    } process {
        [__ComObject]$session = New-Object -ComObject Microsoft.Update.Session
        [__ComObject]$searcher = $session.CreateUpdateSearcher()

        [__ComObject]$searchResults = $searcher.Search($query)

        Write-Verbose -Message "[$($searchResults.Updates.Count)] updates are available."

        if ($searchResults.Updates.Count -lt 1) {
            return
        }

        [__ComObject]$updateColl = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($update in $searchResults.Updates) {
            if ((-not $update.EulaAccepted) {
                if (-not $AcceptEula) {
                    Write-Warning -Message "The update [$($update.Title)] requires the EULA to be accpeted to install it. To accept the EULA use the [-AcceptEula] parameter.
                    continue
                }
                Write-Verbose -Message "Accepting the EULA for the update [$($update.Title)] with the following terms and conditions: rn$($update.EulaText)"
                $update.AcceptEula()
            }
            $null = $updsteColl.Add($update)
        }

        Write-Verbose -Message "[$($updateColl.Updates.Count)] updates were found that matched the specified search criteria."
        if ($updateColl.Updates.Count -lt 1) {
            return
        }

        [__ComObject]$downloader = $session.CreateUpdateDownloader()
        $downloader.Updates = $updateColl.Updates
        Write-Verbose -Message "Downloading [$($updateColl.Updates.Count)] updates."
        [__ComObject]$downloadResults = $downloader.Download()

        [__ComObject]$installer = $session.CreateUpdateInstaller()
        $installer.Updates = $updateColl.Updates
        Write-Verbose -Message "Installing [$($updateColl.Updates.Count)] updates."
        [__ComObject]$installResults = $installer.Install()
    } end {
        if ($session -is [__ComObject]) {
            
        }

        if ($downloader -is [__ComObject]) {
            
        }

        if ($installer -is [__ComObject]) {
            
        }
    }
}