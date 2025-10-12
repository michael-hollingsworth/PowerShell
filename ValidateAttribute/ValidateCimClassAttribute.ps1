<#
.SYNOPSIS
    Validates that a CIM instance is of the desired CIM class.
.EXAMPLE
    ```PowerShell
    function Test-CimClass {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateCimClass(ClassName = 'Win32_UserProfile')]
            [CimInstance]$CimInstance
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-CimClass -CimInstance (Get-CimInstance -ClassName Win32_UserProfile)
    ```

    Fail:
    ```PowerShell
    Test-CimClass -CimInstance (Get-CimInstance -ClassName Win32_ComputerSystem)
    ```
.NOTES
    This attribute can be defined as either `[ValidateCimClass('<CLASS_NAME>')]` or `[ValidateCimClass(ClassName = '<CLASS_NAME>')]`.
.NOTES
    This attribute validator is only _required_ for validating the CIM class of a property in a custom class. When attempting to validate the CIM class for a parameter in a function, the `[PSTypeName()]` attribute can be a simpler and more efficient way of doing so:
    ```PowerShell
    function Test-CimClass {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [PSTypeName('Microsoft.Management.Infrastructure#root/cimv2/Win32_UserProfile')]
            [CimInstance]$CimInstance
        )
    }
    ```

    For more information, see [PSTypeNameAttribute Class](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pstypenameattribute#remarks).
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
                [System.Management.Automation.PSArgumentNullException]::new('ClassName'),
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
        return "[ValidateCimClassAttribute('$($this.ClassName)')]"
    }
}

class ValidateCimClassAttribute2 : System.Management.Automation.ValidateEnumeratedArgumentsAttribute {
    [ValidateNotNullOrEmpty()]
    [String]$ClassName

    ValidateCimClassAttribute2([String]$ClassName) {
        if ([String]::IsNullOrWhiteSpace($ClassName)) {
            throw [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.PSArgumentNullException]::new('ClassName'),
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
        return "[ValidateCimClassAttribute('$($this.ClassName)')]"
    }
}