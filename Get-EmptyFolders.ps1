<#
.SYNOPSIS
    Gets folders that don't contain any files or folders.
.EXAMPLE
    Get-EmptyFolders -Path C:\Windows\Temp
.NOTES
    Author: Michael Hollingsworth
#>
function Get-EmptyFolders {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([IO.DirectoryInfo])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Path')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath', 'LP')]
        [String]$LiteralPath,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()]
        [IO.DirectoryInfo]$InputObject
    )

    [IO.DirectoryInfo]$parent = if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
        $InputObject
    } else {
        Get-Item @PSBoundParameters -Force -ErrorAction Stop
    }

    [Boolean]$noChildDirs = $false

    if ($childDirectories = $parent.GetDirectories()) {
        foreach ($directory in $childDirectories) {
            & $MyInvocation.MyCommand.Name -InputObject $directory
        }
    } else {
        $noChildDirs = $true
    }

    if ($noChildDirs -and (-not $parent.GetFiles().Count)) {
        return $parent
    }
}

New-Alias -Name 'Get-EmptyDirectories' -Value 'Get-EmptyFolders'