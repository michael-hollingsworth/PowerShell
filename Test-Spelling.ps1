<#
.LINK
    https://learn.microsoft.com/en-us/office/vba/api/word.application.checkspelling
#>
function Test-Spelling {
    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$InputObject
    )

    begin {
        [__ComObject]$wordApp = New-Object -ComObject Word.Application -ErrorAction Stop
    } process {
        return $wordApp.CheckSpelling($InputObject)
    } end {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wordApp)
        $wordApp = $null
    }
}