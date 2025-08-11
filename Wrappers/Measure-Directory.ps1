<#
.NOTES
    Author: Michael Hollingsworth
#>
function Measure-Directory {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Path,
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath', 'LP')]
        [String[]]$LiteralPath,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()]
        [IO.DirectoryInfo[]]$InputObject
    )

    if ($Path) {
        [String[]]$LiteralPath = foreach ($p in $Path) {
            try {
                (Get-Item -Path $p -Force -ErrorAction Stop).FullName
            } catch {
                Write-Error $_
            }
        }
    }

    if ($null -eq $LiteralPath) {
        return
    }

    foreach ($lp in $LiteralPath) {
        if (-not (Test-Path -LiteralPath $lp -ErrorAction Stop)) {
            continue
        }

        [Microsoft.PowerShell.Commands.GenericMeasureInfo]$tmp = Get-ChildItem -LiteralPath $lp -Recurse -File -Force -ErrorAction Ignore | Measure-Object -Property Length -Sum
        [PSCustomObject]@{
            PSTypeName = 'DirectorySizeInfo'
            DirectoryPath = $lp
            DirectorySize = $tmp.Sum
            FileCount = $tmp.Count
        }
    }
}