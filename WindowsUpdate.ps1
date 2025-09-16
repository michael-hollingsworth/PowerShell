class WindowsUpdate {
    hidden [__ComObject]$_updateObject

    WindowsUpdate([__ComObject]$Update) {
         $this._UpdateObject = $Update
    }

    [Void] AcceptEula() {
        if ($null -eq $this._updateObject) {
            return
        }

        if ($this._updateObject.EulaAccepted) {
            return
        }

        $this._updateObject.AcceptEula()
        return
    }

    [Void] Download() {
        if ($null -eq $this._updateObject) {
            return
        }

        if ($this._updateObject.IsDownloaded) {
            Write-Verbose -Message "this update is already downloaded"
            return
        }

       try {
            [__ComObject]$updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateColl = New-Object -ComObject Microsoft.Update.UpdateColl
            [__ComObject]$updateDownloader = $updateSession.CreateUpdateDownloader()

            $null = $updateColl.Add($this._updateObject)

            $updateDownloader.Updates = $updateColl
            [__ComObject]$downloadResults = $updateDownloader.Download()
        } finally {
            if ($null -ne $updateSession) {
                #release com object
            }
            if ($null -ne $updateColl) {
                #release com object
            }
            if ($null -ne $updateDownloader) {
                #release com object
            }
            if ($null -ne $downloadResults) {
                #release com object
            }
        }

        return
    }

    [Void] Install() {
        if () {
            #throw if the object isnt an IUpdate object
        }
        $this.Install($false)
    }

    [Void] Install([Boolean]$Force) {
        if ($null -eq $this._updateObject) {
            return
        }

        if ($this._updateObject.IsInstalled) {
            Write-Verbose -Message "this update is already installed"
            return
        }

        if ((-not $this._updateObject.EulaAccepted) -and (-not $Force)) {
            throw "this could be problematic. Typically, only Feature updates require the EULA to be accepted" 
        }

        if (-not $this._updateObject.IsDownloaded) {
            Write-Verbose -Message "The update is not already downloaded. Downloading now"
            $this.Download()
        }

        try {
            [__ComObject]$updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateColl = New-Object -ComObject Microsoft.Update.UpdateColl
            [__ComObject]$updateInstaller = $updateSession.CreateUpdateInstaller()

            $null = $updateColl.Add($this._updateObject)

            $updateInstaller.Updates = $updateColl
            [__ComObject]$installResults = $updateInstaller.Install()
        } finally {
            if ($null -ne $updateSession) {
                #release com object
            }
            if ($null -ne $updateColl) {
                #release com object
            }
            if ($null -ne $updateInstaller) {
                #release com object
            }
            if ($null -ne $installResults) {
                #release com object
            }
        }

        return
    }

    static [WindowsUpdate[]] GetUpdates() {
        [WindowsUpdate]::Search('IsInstalled = 0')
    }

    static [WindowsUpdate[]] GetInstalledUpdates() {
        #TODO: Look into the other ways of searching for installed updates
        [WindowsUpdate]::Search('Installed = 1')
    }

    static [WindowsUpdate[]] Search([String]$SearchQuery) {
        try {
            [__ComObject]$updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateSearcher = $updateSession.CreateUpdateSearcher()

            [__ComObject]$searchResults = $updateSearcher.Search($SearchQuery)

            foreach ($update in $searchResults.Updates) {
                [WindowsUpdate]::new($update)
            }
        } finally {
            if ($null -ne $updateSession) {
                #release com object
            }
            if ($null -ne $updateSearcher) {
                #release com object
            }
            if ($null -ne $searchResults) {
                #release com object
            }
        }
    }
}

Update-TypeData -TypeName WindowsUpdate -MemberName Title MemberType ScriptProperty -Value { return ($this._updateObject.Title) }
Update-TypeData -TypeName WindowsUpdate -MemberName Description MemberType ScriptProperty -Value { return ($this._updateObject.Description) }
Update-TypeData -TypeName WindowsUpdate -MemberName Category MemberType ScriptProperty -Value { return (Select-Object -InputObject $this._updateObject -Property Categories) }
Update-TypeData -TypeName WindowsUpdate -MemberName Type MemberType ScriptProperty -Value { return (Select-Object -InputObject $this._updateObject -Property Type) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsDownloaded MemberType ScriptProperty -Value { return ($this._updateObject.IsDownloaded) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsInstalled MemberType ScriptProperty -Value { return ($this._updateObject.IsInstalled) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsEulaAccepted MemberType ScriptProperty -Value { return ($this._updateObject.EulaAccepted) }
Update-TypeData -TypeName WindowsUpdate -MemberName EulaText MemberType ScriptProperty -Value { return ($this._updateObject.EulaText) }