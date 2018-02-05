Function New-ShortExceptionMessageBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception,
        [string]$Action = "monitor"
    )

    $messageBody = ''
    $messageBody += "An exception occurred while trying to $Action the environment.`r`n"
    $messageBody += "Details: $($Exception.ToString())"

    return $messageBody
}