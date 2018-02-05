Function New-HtmlExceptionBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception,
        [string]$Action = "monitor"
    )

    $emailBody = ""
    $emailBody += "An exception occurred while trying to $Action the environment.`r`n"
    $emailBody += "Details: $($Exception.ToString())"
    
    return $emailBody
}