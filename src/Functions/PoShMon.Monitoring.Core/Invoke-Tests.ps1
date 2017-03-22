Function Invoke-Tests
{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$TestToRuns,
        [hashtable]$PoShMonConfiguration
    )

    Begin
    {
        $outputValues = New-Object System.Collections.ArrayList #@();
    }

    Process
    {
        foreach ($test in $TestToRuns)
        {
            try {
                $outputValues += & ("Test-" + $test) $PoShMonConfiguration
            } catch {
                $outputValues += @{
                    "SectionHeader" = $test;
                    "NoIssuesFound" = $false;
                    "Exception" = $_.Exception
                }
            }
        }

        # now include any extra supplied tests, not part of the PoShMon project itself
        foreach ($extraTestFile in $PoShMonConfiguration.Extensibility.ExtraTestFilesToInclude)
        {
            if (Test-Path $extraTestFile)
            {
                . $extraTestFile # Load the script

                $testName = $extraTestFile | Get-Item | Select -ExpandProperty BaseName

                try {
                    #$testName = (Split-Path $extraTestFile -Leaf).Replace(".ps1", "")
                    $outputValues += & $testName $PoShMonConfiguration
                } catch {
                    $outputValues += @{
                        "SectionHeader" = $testName;
                        "NoIssuesFound" = $false;
                        "Exception" = $_.Exception
                    }
                }

            } else {
                Write-Warning "Test file not found, will be skipped: $extraTestFile"
            }
        }     
    }
    
    End
    {
        return $outputValues
    }
}