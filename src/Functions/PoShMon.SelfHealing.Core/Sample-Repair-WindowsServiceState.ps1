<#

#>
Function Repair-WindowsServiceState
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$PoShMonOutputValues
    )

    $stoppedServices = $PoShMonOutputValues | Where { $_.SectionHeader -EQ "Windows Service State" -and $_.NoIssuesFound -eq $false }
 
    $repairOutput = @()

    foreach ($groupOutputValue in $stoppedServices.OutputValues)
    {
        $serverName = $groupOutputValue.GroupName
        $services = $groupOutputValue.GroupOutputValues | Where { $_.Highlight.Count -gt 0 }

        $serviceNames = @()
        foreach ($service in $services)
            { $serviceNames += $service.Name }

        Invoke-Command -ComputerName $serverName -ScriptBlock {
            param($serviceNames)
            $serviceNames | Start-Service
            $serviceNames | Set-Service -StartupType Automatic #Presumably if it's meant to be running, it should be set to auto start...
        } -ArgumentList $serviceNames
 
        $repairOutput += @{
                 "SectionHeader" = "Windows Service State on $serverName"
                "RepairResult" = "The following sevices were re-started: $serviceNames"
            }
    }

    return $repairOutput
}