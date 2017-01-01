Function New-O365TeamsExceptionBody
{
    [CmdletBinding()]
    Param(
        [string]$ExceptionMessage
    )

    $messageBody += "'An exception occurred while trying to monitor the environment.`r`n"
    $messageBody += "Details: $ExceptionMessage"
}