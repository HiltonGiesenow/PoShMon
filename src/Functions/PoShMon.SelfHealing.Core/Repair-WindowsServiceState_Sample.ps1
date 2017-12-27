<#
    
#>
Function Repair-WindowsServiceState_Sample
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$PoShMonOutputValues
    )

    $stoppedServices = $PoShMonOutputValues | Where { $_.SectionHeader -EQ "Windows Service State" -and $_.NoIssuesFound -eq $false }
 
    $repairOutput = @()

    $groups = $stoppedServices.OutputValues | Group $stoppedServices["GroupBy"]

    foreach ($group in $groups)
    {
        $serverName = $group.Name
        $services = $group.Group | Where { $_.Highlight.Count -gt 0 }

        $serviceNames = @()
        foreach ($service in $services)
            { $serviceNames += $service.Name }

        $params = @{
            ScriptBlock = {
                param($serviceNames)
    
                Write-Verbose "Starting $serviceNames on $serverName"
                $serviceNames | Start-Service
                $serviceNames | Set-Service -StartupType Automatic #Presumably if it's meant to be running, it should be set to auto start...
            }
            ArgumentList = $serviceNames
        }

        if ($serverName -ne $Env:COMPUTERNAME)
            { $params.Add("ComputerName", $serverName) }
            
        Invoke-Command @params
 
        $repairOutput += @{
                 "SectionHeader" = "Windows Service State on $serverName"
                "RepairResult" = "The following sevices were re-started: $serviceNames"
            }
    }

    return $repairOutput
}