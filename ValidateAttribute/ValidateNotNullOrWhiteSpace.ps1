<#
.SYNOPSIS
    Windows PowerShell compatible ValidateNotNullOrWhiteSpace attribute.
.EXAMPLE
    ```PowerShell
    function Test-NullOrWhiteSpace {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateNotNullOrWhiteSpace()]
            $String
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-NullOrWhiteSpace -String 'test'
    ```

    Fail:
    ```PowerShell
    Test-NullOrWhiteSpace -String ' '
    ```

    Fail:
    ```PowerShell
    Test-NullOrWhiteSpace -String "`n"
    ```

    Fail:
    ```PowerShell
    Test-NullOrWhiteSpace -String $null
    ```
.NOTES
    Author: Michael Hollingsworth
#>
class ValidateNotNullOrWhiteSpaceAttribute : System.Management.Automation.ValidateArgumentsAttribute {
    [Void] Validate([Object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics) {
        if (-not [String]::IsNullOrWhiteSpace($arguments)) {
            return
        }

        throw [System.Management.Automation.ValidationMetadataException]::new(
            "Argument cannot be null or whitespace.",
            [System.Management.Automation.PSArgumentNullException]::new()
        )
    }

    [String] ToString() {
        return '[ValidatenotNullOrWhiteSpaceAttribute()]'
    }
}