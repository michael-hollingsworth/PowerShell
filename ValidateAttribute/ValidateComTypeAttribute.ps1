<#
.SYNOPSIS
    Validates that a COM object is of a specific type.
.EXAMPLE
    ```PowerShell
    function Test-Com {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateComType(Type = ('IUpdateSession', 'IUpdateSession2', 'IUpdateSession3'))]
            $ComObject
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-Com -ComObject (New-Object -ComObject Microsoft.Update.Session)
    ```

    Fail:
    ```PowerShell
    Test-Com -ComObject (New-Object -ComObject Microsoft.Update.Searcher)
    ```
.NOTES
    This attribute can be defined as either `[ValidateComType('<CLASS_NAME>')]` or `[ValidateCimClass(Type = ('<TYPE_NAME_1>', '<TYPE_NAME_2>', ...))]`.
.NOTES
    Author: Michael Hollingsworth
#>
Add-Type -AssemblyName Microsoft.VisualBasic

class ValidateComTypeAttribute : System.Management.Automation.ValidateArgumentsAttribute {
    [ValidateNotNullOrEmpty()]
    [String[]]$Type

    ValidateComTypeAttribute() {
    }

    ValidateComTypeAttribute([String]$Type) {
        if ([String]::IsNullOrWhiteSpace($Type)) {
            throw [System.Management.Automation.ErrorRecord]::new(
                [System.ArgumentNullException]::new('Type'),
                'ArgumentIsNullOrWhiteSpace',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $Type
            )
        }

        $this.Type = @(, $Type)
    }

    ValidateComTypeAttribute([String[]]$Type) {
        foreach ($string in $Type) {
            if ([String]::IsNullOrWhiteSpace($string)) {
                throw [System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentNullException]::new('Type'),
                    'ArgumentIsNullOrWhiteSpace',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $string
                )
            }
        }

        $this.Type = $Type
    }

    [Void] Validate([Object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics) {
        [String]$argumentType = [Microsoft.VisualBasic.Information]::TypeName($arguments)

        if (($this.Type.Count -eq 1) -and ($argumentType -eq $this.Type)) {
            return
        } elseif ($argumentType -in $this.Type) {
            return
        }

        throw [System.Management.Automation.ValidationMetadataException]::new(
            "Argument '$arguments' must be a valid '$($this.Type)' COM object.",
            [System.Management.Automation.PSArgumentException]::new("Argument '$arguments' must be a valid '$($this.Type)' COM object.")
        )
    }

    [String] ToString() {
        if ($this.Type.Count -eq 1) {
            return "[ValidateComTypeAttribute(Type = '$($this.Type)')]"
        }

        return "[ValidateComTypeAttribute(Type = ('$($this.Type -join "', '")'))]"
    }
}