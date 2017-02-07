Function New-O365TeamsExceptionBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception,
        [string]$Action = "monitor"
    )

    $messageBody += "An exception occurred while trying to $Action the environment.`r`n"
    $messageBody += "Details: $($Exception.ToString())"
}