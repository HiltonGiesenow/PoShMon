Function New-PushbulletExceptionBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception
    )

    $messageBody = ''
    $messageBody += "An exception occurred while trying to monitor the environment.`r`n"
    $messageBody += "Details: $($Exception.ToString())"

    return $messageBody
}