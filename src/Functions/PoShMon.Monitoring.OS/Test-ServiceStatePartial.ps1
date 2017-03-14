Function Test-ServiceStatePartial
{
    [CmdletBinding()]
    param (
        [string]$ServerName,
        [string[]]$Services,
        [string]$ServiceState = "Running"
    )

    $NoIssuesFound = $true

    $serviceFoundOnServer = Get-Service -ComputerName $ServerName

    $itemOutputValues = @()

    foreach ($service in $Services)
    {
        Write-Verbose "`t`t Checking '$service'..."

        $serviceFound = $serviceFoundOnServer | Where Name -eq $service

        $highlight = ""

        if ($serviceFound -eq $null)
        {
            $NoIssuesFound = $false
            $highlight += "Status"

            Write-Host "Service '$service' on $serverName Not Found!" -ForegroundColor Red

            $outputItem = @{
                'DisplayName' = "[Not Found]";
                'Name' = $service;
                'Status' = "[Not Found]";
                'Highlight' = $highlight
            }
        } else {
            if ($ServiceState -ne $serviceFound.Status)
            {
                $NoIssuesFound = $false
                $highlight += "Status"

                Write-Host "'$service' on $serverName state incorrect - expected $ServiceState" -ForegroundColor Red
            } else {
                Write-Verbose "`t`t'$service' found and in correct state"
            }

            $outputItem = [pscustomobject]@{
                'ServerName' = $ServerName;
                'DisplayName' = $serviceFound.DisplayName;
                'Name' = $serviceFound.Name;
                'Status' = $serviceFound.Status;
                'Highlight' = $highlight
            }
        }

        $itemOutputValues += $outputItem
    }

    $groupedoutputItem = @{
            #'GroupName' = $serverName
            'GroupOutputValues' = $itemOutputValues
            'NoIssuesFound' = $NoIssuesFound
        }

    return $groupedoutputItem
}