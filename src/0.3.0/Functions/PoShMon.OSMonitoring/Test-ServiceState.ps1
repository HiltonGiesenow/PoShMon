Function Test-ServiceState
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames,
        [string[]]$Services,
        [string]$ServiceState = "Running"
    )

    $sectionHeader = "Windows Service State"
    $NoIssuesFound = $true
    $outputHeaders = @{ 'DisplayName' = 'Display Name'; 'Name' = 'Name'; 'Status' = 'Status' }
    $outputValues = @()

    Write-Verbose "Getting Windows Service State..."

    $servicesFound = Get-Service -ComputerName $ServerNames

    foreach ($serverName in $ServerNames) # should we be reporting by server name or by service?
    {
        Write-Verbose "`t Checking $serverName..."
        
        $serviceFoundOnServer = $servicesFound | Where MachineName -eq $serverName

        foreach ($service in $Services)
        {
            Write-Verbose "`t`t Checking '$service'..."

            $itemOutputValues = @()

            $serviceFound = $serviceFoundOnServer | Where Name -eq $service

            if ($serviceFound -eq $null)
            {
                $NoIssuesFound = $false
                $highlight += "Status"

                Write-Host "Service '$service' on $serverName Not Found!" -ForegroundColor Red

                $outputItem = @{
                    'DisplayName' = $service;
                    'Name' = "[Not Found]";
                    'State' = "[Not Found]";
                }
            } else {
                if ($ServiceState -ne $serviceFound.Status)
                {
                    $NoIssuesFound = $false
                    $highlight += "Status"

                    Write-Host "$service' on $serverName state incorrect - expected $ServiceState" -ForegroundColor Red
                } else {
                    Write-Verbose "`t`t'$service' found and in correct state"
                }

                $outputItem = @{
                    'DisplayName' = $service;
                    'Name' = $serviceFound.Name;
                    'State' = $serviceFound.State;
                }
            }

            $itemOutputValues += $outputItem
        }

        $groupedoutputItem = @{
                'GroupName' = $serverName
                'GroupOutputValues' = $itemOutputValues
            }

        $outputValues += $groupedoutputItem
    }

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}