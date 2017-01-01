Function New-O365TeamsExceptionBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception
    )

    $messageBody += "An exception occurred while trying to monitor the environment.`r`n"
    $messageBody += "Details: $($Exception.ToString())"
}