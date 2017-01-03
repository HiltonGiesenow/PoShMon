Function Test-WebSites
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    $allTestsOutput = @()

    foreach ($websiteDetailKey in $PoShMonConfiguration.WebSite.WebsiteDetails.Keys)
    {
        $siteUrl = $websiteDetailKey
        $textToLocate = $PoShMonConfiguration.WebSite.WebsiteDetails[$websiteDetailKey]

        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
   
        $sectionHeader = "Web Test - " + $siteUrl
        $NoIssuesFound = $true
        $outputHeaders = @{ 'ServerName' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
        $outputValues = @()

        For ($i = -1; $i -lt $PoShMonConfiguration.General.ServerNames.Count; $i++) {
        
            $serverName = '(Direct)'
            $highlight = @()

            if ($i -eq -1) # Direct Call
            {
                Write-Verbose ("Scanning Site $siteUrl (Direct)")

                $webRequest = Invoke-WebRequest $siteUrl -UseDefaultCredentials
            } else {
                $serverName = $PoShMonConfiguration.General.ServerNames[$i]
            
                Write-Verbose ("Scanning Site $siteUrl on $serverName")
            
                $webRequest = Invoke-RemoteWebRequest -siteUrl $siteUrl -ServerName $serverName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
            }

            Write-Verbose ("StatusCode - " + $webRequest.StatusCode)

            if ($webRequest.StatusCode -ne 200)
            {
                $NoIssuesFound = $false
                $highlight += 'Outcome'
                $outcome = $webRequest.StatusDescription
            } else {
                if ($webRequest.Content.ToLower().Contains($textToLocate.ToLower())) { 
                    $outcome = "Specified Page Content Found"
                } else {
                    $highlight += 'Outcome'
                    $NoIssuesFound = $false
                    $outcome = "Specified Page Content Not Found"
                }
            }

            $outputItem = @{
                'ServerName' = $serverName;
                'StatusCode' = $webRequest.StatusCode;
                'Outcome' = $outcome
                'Highlight' = $highlight
            }

            $outputValues += $outputItem
        }

        $stopWatch.Stop()

        $allTestsOutput += @{
            "SectionHeader" = $sectionHeader;
            "NoIssuesFound" = $NoIssuesFound;
            "OutputHeaders" = $outputHeaders;
            "OutputValues" = $outputValues;
            "ElapsedTime" = $stopWatch.Elapsed
            }
    }

    return $allTestsOutput
}