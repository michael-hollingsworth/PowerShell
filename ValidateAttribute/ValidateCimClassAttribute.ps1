<#
.SYNOPSIS
    Validates that a CIM instance is of the desired CIM class.
.EXAMPLE
    ```PowerShell
    function Test-Cim {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateCimClass(ClassName = 'Win32_UserProfile')]
            $CimInstance
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-Cim -CimInstance (Get-CimInstance -ClassName Win32_UserProfile)
    ```

    Fail:
    ```PowerShell
    Test-Cim -CimInstance (Get-CimInstance -ClassName Win32_ComputerSystem)
    ```
.NOTES
    This attribute can be defined as either `[ValidateCimClass('<CLASS_NAME>')]` or `[ValidateCimClass(ClassName = '<CLASS_NAME>')]`.
.NOTES
    Author: Michael Hollingsworth
#>
class ValidateCimClassAttribute : System.Management.Automation.ValidateArgumentsAttribute {
    [ValidateNotNullOrEmpty()]
    [String]$ClassName

    ValidateCimClassAttribute() {
    }

    ValidateCimClassAttribute([String]$ClassName) {
        if ([String]::IsNullOrWhiteSpace($ClassName)) {
            throw [System.Management.Automation.ErrorRecord]::new(
                [System.ArgumentNullException]::new('ClassName'),
                'ArgumentIsNullOrWhiteSpace',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $ClassName
            )
        }

        $this.ClassName = $ClassName
    }

    [Void] Validate([Object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics) {
        if ($arguments.CimClass.CimClassName -eq $this.ClassName) {
            return
        }

        throw [System.Management.Automation.ValidationMetadataException]::new(
            "CIM instance must be of the class '$($this.ClassName)'.",
            [System.Management.Automation.PSArgumentException]::new("CIM instance must be of the class '$($this.ClassName)'.")
        )
    }

    [String] ToString() {
        return "[ValidateCimClassAttribute($($this.ClassName))]"
    }
}

class ValidateCimClassAttribute2 : System.Management.Automation.ValidateEnumeratedArgumentsAttribute {
    [ValidateNotNullOrEmpty()]
    [String]$ClassName

    ValidateCimClassAttribute2([String]$ClassName) {
        if ([String]::IsNullOrWhiteSpace($ClassName)) {
            throw [System.Management.Automation.ErrorRecord]::new(
                [System.ArgumentNullException]::new('ClassName'),
                'ArgumentIsNullOrWhiteSpace',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $ClassName
            )
        }

        $this.ClassName = $ClassName
    }

    [Void] ValidateElement([Object]$element) {
        if ($element.CimClass.CimClassName -eq $this.ClassName) {
            return
        }

        throw [System.Management.Automation.ValidationMetadataException]::new(
            "CIM instance must be of the class '$($this.ClassName)'.",
            [System.Management.Automation.PSArgumentException]::new("CIM instance must be of the class '$($this.ClassName)'.")
        )
    }

    [String] ToString() {
        return "[ValidateCimClassAttribute($($this.ClassName))]"
    }
}