Function Start-ServicesOnServers
{
    [CmdletBinding()]
    Param(
        [string[]]$ServerNames,
        [string[]]$ServiceNames
    )

    $repairOutput = @()

    if ($ServerNames.GetType().BaseType.Name -ne "Array")
        { $ServerNames = ,$ServerNames }

    foreach ($server in $ServerNames)
    {
        $params = @{
            ScriptBlock = {
                param($ServiceNames)
    
                Write-Verbose "Starting $serviceNames on $serverName"
                $serviceNames | Start-Service
                $serviceNames | Set-Service -StartupType Automatic #Presumably if it's meant to be running, it should be set to auto start...
            }
            ArgumentList = $serviceNames
        }

        if ($server -ne $Env:COMPUTERNAME)
            { $params.Add("ComputerName", $server) }
            
        Invoke-Command @params
 
        $repairOutput += @{
                "SectionHeader" = "Windows Service State on $server"
                "RepairResult" = "The following sevice(s) were re-started: $serviceNames"
            }
    }

    return $repairOutput
}