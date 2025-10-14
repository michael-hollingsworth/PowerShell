<#
.DESCRIPTION
    Escapes the specified characters in a string
.PARAMETER String
    Input string(s) to escape.
.PARAMETER MetaCharacter
    Character(s) to be escaped.
.PARAMETER EscapeCharacter
    The character that will be used to escape the metacharacter(s).
.EXAMPLE
    Escape-String -String 'test' -MetaCharacters 't'

    'test' --> '\tes\t'
.EXAMPLE
    $strings | Escape-String -MetaCharacters ':', ','
.NOTES
    This function is based on the logic used for the `[Regex]::Escape` method: https://github.com/dotnet/runtime/blob/9d5a6a9aa463d6d10b0b0ba6d5982cc82f363dc3/src/libraries/System.Text.RegularExpressions/src/System/Text/RegularExpressions/RegexParser.cs#L151
.NOTES
    Author: Michael Hollingsworth
#>
function Escape-String {
    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]]$String,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Char[]]$MetaCharacter,
        [Parameter(Position = 2)]
        [PSDefaultValue(Help = '\')]
        [ValidateNotNullOrEmpty()]
        [Char]$EscapeCharacter = '\'
    )

    begin {
        [System.Text.StringBuilder]$stringBuilder = [System.Text.StringBuilder]::new()
    } process {
        foreach ($str in $String) {
            [Int32]$indexOfMetaCharacter = $str.IndexOfAny($MetaCharacter)

            if ($indexOfMetaCharacter -lt 0) {
                $PSCmdlet.WriteObject($str)
                continue
            }

            $null = $stringBuilder.Clear()

            # Sadly, this has to rely on a string instead of a ReadOnlySpan like is used in the [Regex]::Escape method.
            ## The ReadOnlySpan class is not included in the .NET Framework and requires an additional package.
            [String]$inputString = $str

            while ($true) {
                $null = $stringBuilder.Append($inputString.SubString(0, $indexOfMetaCharacter))
                [String]$inputString = $inputString.SubString($indexOfMetaCharacter)
                if ($inputString.Length -lt 1) {
                    break
                }

                $null = $stringBuilder.Append("${EscapeCharacter}$($inputString.SubString(0, 1))")

                [String]$inputString = $inputString.SubString(1)

                [Int32]$indexOfMetaCharacter = $inputString.IndexOfAny($MetaCharacter)

                if ($indexOfMetaCharacter -lt 0) {
                    [Int32]$indexOfMetaCharacter = $inputString.Length
                }
            }

            $PSCmdlet.WriteObject($stringBuilder.ToString())
        }
    }
}