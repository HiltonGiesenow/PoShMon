Function New-EmailExceptionBody
{
    [CmdletBinding()]
    Param(
        [System.Exception]$Exception
    )

    $emailBody = ""
    $emailBody += "An exception occurred while trying to monitor the environment.`r`n"
    $emailBody += "Details: $($Exception.ToString())"
    
    return $emailBody
}