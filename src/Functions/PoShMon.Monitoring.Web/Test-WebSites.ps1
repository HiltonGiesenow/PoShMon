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
   
        $mainOutput = Get-InitialOutputWithTimer -SectionHeader "Web Test - $siteUrl" -OutputHeaders ([ordered]@{ 'ServerName' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' })

        For ($i = -1; $i -lt $PoShMonConfiguration.General.ServerNames.Count; $i++) {
        
            $serverName = '(Direct)'
            $highlight = @()

            if ($i -eq -1) # Direct Call
            {
                Write-Verbose ("`tScanning Site $siteUrl (Direct)")

                $webRequest = Invoke-WebRequest $siteUrl -UseDefaultCredentials
            } else {
                $serverName = $PoShMonConfiguration.General.ServerNames[$i]
            
                Write-Verbose ("`tScanning Site $siteUrl on $serverName")
            
                $webRequest = Invoke-RemoteWebRequest -siteUrl $siteUrl -ServerName $serverName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
            }

            if ($webRequest.StatusCode -ne 200)
            {
                $mainOutput.NoIssuesFound = $false
                $highlight += 'Outcome'
                $outcome = $webRequest.StatusDescription
            } else {
                if ($webRequest.Content.ToLower().Contains($textToLocate.ToLower())) { 
                    $outcome = "Specified Page Content Found"
                } else {
                    $highlight += 'Outcome'
                    $mainOutput.NoIssuesFound = $false
                    $outcome = "Specified Page Content Not Found"
                }
            }

            Write-Verbose "`t`t$serverName : $($webRequest.StatusCode) : $outcome"

            $mainOutput.OutputValues += [pscustomobject]@{
                'ServerName' = $serverName;
                'StatusCode' = $webRequest.StatusCode;
                'Outcome' = $outcome
                'Highlight' = $highlight
            }
        }

        $allTestsOutput += (Complete-TimedOutput $mainOutput)
    }

    return $allTestsOutput
}