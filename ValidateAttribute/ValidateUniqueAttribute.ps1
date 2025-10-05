<#
.DESCRIPTION
    This class/attribute validator validates that all elements of a parameter/property are unique.
.EXAMPLE
    ```PowerShell
    function Test-Unique {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateUnique()]
            $UniqueParameter
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-Unique -UniqueParameter 1, 2, 3
    ```

    Pass:
    ```PowerShell
    Test-Unique -UniqueParameter 1, 2, 3
    Test-Unique -UniqueParameter 1, 2, 3
    ```

    Fail:
    ```PowerShell
    Test-Unique -UniqueParameter 1, 2, 3, 2
    ```
.EXAMPLE
    ```PowerShell
    function Test-Unique {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateUnique('Year')]
            $UniqueParameter
        )
    }
    ```

    Pass:
    ```PowerShell
    Test-Unique -UniqueParameter @(
        [DateTime]::new(1, 1, 1),
        [DateTime]::new(2, 1, 1)
    )
    ```

    Fail:
    ```PowerShell
    Test-Unique -UniqueParameter @(
        [DateTime]::new(1, 1, 1),
        [DateTime]::new(1, 2, 2)
    )
    ```
.NOTES
    Author: Michael Hollingsworth
#>
class ValidateUniqueAttribute : System.Management.Automation.ValidateArgumentsAttribute {
    [String]$Property
    [System.Collections.Generic.HashSet[Object]]$ExistingElements = [System.Collections.Generic.HashSet[Object]]::new()

    ValidateUniqueAttribute() {
    }

    ValidateUniqueAttribute([String]$Property) {
        $this.Property = $Property
    }

    [Void] Validate([Object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics) {
        <#
        When the PowerShell engine defines a function/cmdlet that has parameters with additional attributes,
        those attribute class objects are created when the function is defined.
        This means that every time the function is called and thus the parameter is validated, it is using the same instance/object of the class.
        Because of that, we have to clear the HashSet each time the Validate method is called otherwise,
        calling the function twice with the same parameters will result in the parameter value already existing in the HashSet, throwing an error.

        eg. If we didn't clear the HashSet every time the Validate() method was called, running the following commands would throw an error,
        due to the value '1' already existing in the HashSet from the first time the command was run:
        Test-Unique -UniqueParameter 1, 2, 3
        Test-Unique -UniqueParameter 1, 2, 3
        #>
        $this.ExistingElements.Clear()

        foreach ($element in $arguments) {
            $elementToValidate = if ([String]::IsNullOrWhiteSpace($this.Property)) {
                $element
            } else {
                $element.$($this.Property)
            }

            if ($this.ExistingElements.Add($elementToValidate)) {
                continue
            }

            throw [System.Management.Automation.ValidationMetadataException]::new(
                "The argument '$elementToValidate' is a duplicate value.",
                [System.Management.Automation.PSArgumentException]::new("The argument '$elementToValidate' is a duplicate value.")
            )
        }
    }

    [String] ToString() {
        return "[ValidateUniqueAttribute($($this.Property))]"
    }
}