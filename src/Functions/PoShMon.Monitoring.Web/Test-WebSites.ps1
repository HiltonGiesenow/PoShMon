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

        $allServersExceptLocal = $PoShMonConfiguration.General.ServerNames | Where-Object { $_ -ne $env:COMPUTERNAME }

		if ($allServersExceptLocal -ne $null -and $allServersExceptLocal.GetType().Name -eq "String") { $allServersExceptLocal = ,$allServersExceptLocal } #convert to proper array

        For ($i = -1; $i -lt $allServersExceptLocal.Count; $i++) {
        
            $serverName = '(Direct)'
			$highlight = @()
			$skip = $false

            if ($i -eq -1) # Direct Call
            {
                Write-Verbose ("`tScanning Site $siteUrl (Direct)")

                $webRequest = Invoke-WebRequest $siteUrl -UseDefaultCredentials -UseBasicParsing
            } else {
                $serverName = $allServersExceptLocal[$i]
			
				if ($serverName -ne $env:COMPUTERNAME)
				{
                	Write-Verbose ("`tScanning Site $siteUrl on $serverName")
            
                	$webRequest = Invoke-RemoteWebRequest -siteUrl $siteUrl -ServerName $serverName -ConfigurationName $PoShMonConfiguration.General.ConfigurationName
				}
				else
					{ $skip = $true }
			}

			if ($skip -eq $false)
			{
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
        }

        $allTestsOutput += (Complete-TimedOutput $mainOutput)
    }

    return $allTestsOutput
}