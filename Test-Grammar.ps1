<#
.LINK
    https://learn.microsoft.com/en-us/office/vba/api/word.application.checkgrammar
#>
function Test-Grammar {
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
        return $wordApp.CheckGrammar($InputObject)
    } end {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wordApp)
        $wordApp = $null
    }
}