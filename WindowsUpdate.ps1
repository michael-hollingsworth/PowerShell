class WindowsUpdate {
    #[ValidateScript({throw if the object isnt an IUpdate object})]
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
            [__ComObject]$private:updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateColl = New-Object -ComObject Microsoft.Update.UpdateColl
            [__ComObject]$updateDownloader = $updateSession.CreateUpdateDownloader()

            $null = $updateColl.Add($this._updateObject)

            $updateDownloader.Updates = $updateColl
            [__ComObject]$downloadResults = $updateDownloader.Download()
        } finally {
            if ($null -ne $updateSession) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateSession)
            }
            if ($null -ne $updateColl) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateColl)
            }
            if ($null -ne $updateDownloader) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateDownloader)
            }
            if ($null -ne $downloadResults) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($downloadResults)
            }
        }

        return
    }

    [Void] Install() {
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

        if (-not $this._updateObject.EulaAccepted) {
            if (-not $Force)) {
                throw "this could be problematic. Typically, only Feature updates require the EULA to be accepted" 
            }

            $this.AcceptEula()
        }

        if (-not $this._updateObject.IsDownloaded) {
            Write-Verbose -Message "The update is not already downloaded. Downloading now"
            $this.Download()
        }

        try {
            [__ComObject]$private:updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateColl = New-Object -ComObject Microsoft.Update.UpdateColl
            [__ComObject]$updateInstaller = $updateSession.CreateUpdateInstaller()

            $null = $updateColl.Add($this._updateObject)

            $updateInstaller.Updates = $updateColl
            [__ComObject]$installResults = $updateInstaller.Install()
        } finally {
            if ($null -ne $updateSession) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateSession)
            }
            if ($null -ne $updateColl) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateColl)
            }
            if ($null -ne $updateInstaller) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateInstaller)
            }
            if ($null -ne $installResults) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($installResults)
            }
        }

        return
    }

    static [WindowsUpdate[]] GetUpdates() {
        return ([WindowsUpdate]::Search('IsInstalled = 0'))
    }

    static [WindowsUpdate[]] GetInstalledUpdates() {
        #TODO: Look into the other ways of searching for installed updates
        return ([WindowsUpdate]::Search('Installed = 1'))
    }

    static [WindowsUpdate[]] Search([String]$SearchQuery) {
        try {
            [__ComObject]$private:updateSession = New-Object -ComObject Microsoft.Update.Session
            [__ComObject]$updateSearcher = $updateSession.CreateUpdateSearcher()

            [__ComObject]$searchResults = $updateSearcher.Search($SearchQuery)

            return $(foreach ($update in $searchResults.Updates) {
                [WindowsUpdate]::new($update)
            })
        } finally {
            if ($null -ne $updateSession) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateSession)
            }
            if ($null -ne $updateSearcher) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($updateSearcher)
            }
            if ($null -ne $searchResults) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($searchResults)
            }
        }
    }
}

Update-TypeData -TypeName WindowsUpdate -MemberName Title -MemberType ScriptProperty -Value { return ($this._updateObject.Title) }
Update-TypeData -TypeName WindowsUpdate -MemberName Description -MemberType ScriptProperty -Value { return ($this._updateObject.Description) }
Update-TypeData -TypeName WindowsUpdate -MemberName Category -MemberType ScriptProperty -Value { return (Select-Object -InputObject $this._updateObject -Property Categories) }
Update-TypeData -TypeName WindowsUpdate -MemberName Type -MemberType ScriptProperty -Value { return (Select-Object -InputObject $this._updateObject -Property Type) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsDownloaded -MemberType ScriptProperty -Value { return ($this._updateObject.IsDownloaded) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsInstalled -MemberType ScriptProperty -Value { return ($this._updateObject.IsInstalled) }
Update-TypeData -TypeName WindowsUpdate -MemberName IsEulaAccepted -MemberType ScriptProperty -Value { return ($this._updateObject.EulaAccepted) }
Update-TypeData -TypeName WindowsUpdate -MemberName EulaText -MemberType ScriptProperty -Value { return ($this._updateObject.EulaText) }