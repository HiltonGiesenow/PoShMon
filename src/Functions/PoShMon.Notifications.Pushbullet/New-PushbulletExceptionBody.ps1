Function New-PushbulletExceptionBody
{
    [CmdletBinding()]
    Param(
        [string]$ExceptionMessage
    )

    $messageBody = ''
    $messageBody += "'An exception occurred while trying to monitor the environment.`r`n"
    $messageBody += "Details: $ExceptionMessage"

    return $messageBody
}