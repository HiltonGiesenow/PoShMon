Function Merge-WinOSTests
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration,
        [System.Collections.ArrayList]$TestOutputValues
    )

    $mergableOutputValues = $TestOutputValues | Where SectionHeader -In "Server CPU Load Review", "Memory Review", "Server Clock Review"

    if ($mergableOutputValues.SectionHeader.Count -gt 1) #make sure there's enough to merge by counting the headers
    {
        $newOutput = Get-InitialOutput -SectionHeader "Server Overview" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server Name' })

        foreach ($outputItem in $mergableOutputValues[0].OutputValues)
        {
            $newOutput.OutputValues += [pscustomobject]@{
                                    'ServerName' = $outputItem.ServerName
                                    'Highlight' = @()
                                }
        }

        $cpuOutput = $mergableOutputValues | Where SectionHeader -eq "Server CPU Load Review"
        if ($cpuOutput -ne $null)
        {
            $newOutput.OutputHeaders.Add('CPULoad', 'CPU Load (%)')

            foreach ($currentCpuItem in $cpuOutput.OutputValues)
            {
                $cpuValue = $currentCpuItem.CPULoad

                foreach ($outputValue in $newOutput.OutputValues)
                {
                    if ($outputValue.ServerName -eq $currentCpuItem.ServerName)
                    {
                        $outputValue | Add-Member -MemberType NoteProperty -Name 'CPULoad' -Value $cpuValue

                        foreach ($highlight in $currentCpuItem.Highlight)
                        {
                            $outputValue.Highlight += $highlight
                        }
                    }
                }
            }

            if ($cpuOutput.NoIssuesFound -eq $false) { $newOutput.NoIssuesFound = $false}
            $newOutput.ElapsedTime += $cpuOutput.ElapsedTime

            $TestOutputValues.Remove($cpuOutput)
        }

        $memoryOutput = $mergableOutputValues | Where SectionHeader -eq "Memory Review"
        if ($memoryOutput -ne $null)
        {
            $newOutput.OutputHeaders.Add('Memory', 'Memory (GB)')

            foreach ($currentMemoryItem in $memoryOutput.OutputValues)
            {
                $totalMemoryValue = $currentMemoryItem.TotalMemory
                $freeMemoryValue = $currentMemoryItem.FreeMemory
                $freeMemoryPerc = $freeMemoryValue.Substring($freeMemoryValue.IndexOf(" ") + 1)
                $freeMemoryValue = $freeMemoryValue.Substring(0, $freeMemoryValue.IndexOf(" "))
                $finalMemory = "$freeMemoryValue / $totalMemoryValue $freeMemoryPerc"

                foreach ($outputValue in $newOutput.OutputValues)
                {
                    if ($outputValue.ServerName -eq $currentMemoryItem.ServerName)
                    {
                        $outputValue | Add-Member -MemberType NoteProperty -Name 'Memory' -Value $finalMemory

                        if ($currentMemoryItem.Highlight.Contains("FreeMemory"))
                        {
                            $outputValue.Highlight += 'Memory'
                        }
                    }
                }
            }

            if ($memoryOutput.NoIssuesFound -eq $false) { $newOutput.NoIssuesFound = $false}
            $newOutput.ElapsedTime += $memoryOutput.ElapsedTime

            $TestOutputValues.Remove($memoryOutput)
        }

        $timeOutput = $mergableOutputValues | Where SectionHeader -eq "Server Clock Review"
        if ($timeOutput -ne $null)
        {
            $newOutput.OutputHeaders.Add('CurrentTime', 'Current Time')
            $newOutput.OutputHeaders.Add('LastBootUptime', 'Last Boot Time')

            foreach ($currentItem in $timeOutput.OutputValues)
            {
                foreach ($outputValue in $newOutput.OutputValues)
                {
                    if ($outputValue.ServerName -eq $currentItem.ServerName)
                    {
                        $outputValue | Add-Member -MemberType NoteProperty -Name 'CurrentTime' -Value $currentItem.CurrentTime
                        $outputValue | Add-Member -MemberType NoteProperty -Name 'LastBootUptime' -Value $currentItem.LastBootUptime

                        if ($currentItem.Highlight.Contains("CurrentTime"))
                            { $outputValue.Highlight += 'CurrentTime' }
                        if ($currentItem.Highlight.Contains("LastBootUptime"))
                            { $outputValue.Highlight += 'LastBootUptime' }
                    }
                }
            }

            if ($timeOutput.NoIssuesFound -eq $false) { $newOutput.NoIssuesFound = $false}
            $newOutput.ElapsedTime += $timeOutput.ElapsedTime

            $TestOutputValues.Remove($timeOutput)
        }

        $TestOutputValues.Insert(0, $newOutput)
    }

    return $TestOutputValues
}