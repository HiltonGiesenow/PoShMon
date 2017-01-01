Function New-EmailExceptionBody
{
    [CmdletBinding()]
    Param(
        [string]$ExceptionMessage
    )

    $emailBody = ""
    $emailBody += "'An exception occurred while trying to monitor the environment.`r`n"
    $emailBody += "Details: $ExceptionMessage"
    
    return $emailBody
}