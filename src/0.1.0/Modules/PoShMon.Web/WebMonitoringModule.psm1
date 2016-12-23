Function Invoke-RemoteWebRequest
{
    [CmdletBinding()]
    param (
        [string]$SiteUrl,
        [string]$ServerName,
        [string]$ConfigurationName
    )

    Write-Verbose "Connecting to $ServerName..."

    try {
        $remoteSession = Connect-RemoteSession -ServerName $ServerName -ConfigurationName $ConfigurationName

        $webResponse = Invoke-Command -Session $remoteSession -ScriptBlock {
                                    param($SiteUrl)
                                    Invoke-WebRequest $SiteUrl -UseDefaultCredentials
                                } -ArgumentList $SiteUrl
    } finally {
        Disconnect-RemoteSession $remoteSession
    }

    return $webResponse
}
        

Function Test-WebSite
{
    [CmdletBinding()]
    param (
        [string]$SiteUrl,
        [string]$TextToLocate,
        [string[]]$ServerNames = @(),
        [string]$ConfigurationName
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
   
    $sectionHeader = "Web Test - " + $SiteUrl
    $NoIssuesFound = $true
    $outputHeaders = @{ 'ServerName' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
    $outputValues = @()

    For ($i = -1; $i -lt $ServerNames.Count; $i++) {
        
        $serverName = '(Direct)'
        $highlight = @()

        if ($i -eq -1) # Direct Call
        {
            Write-Verbose ("Scanning Site $SiteUrl (Direct)")

            $webRequest = Invoke-WebRequest $SiteUrl -UseDefaultCredentials
        } else {
            $serverName = $ServerNames[$i]
            
            Write-Verbose ("Scanning Site $SiteUrl on $serverName")
            
            $webRequest = Invoke-RemoteWebRequest -SiteUrl $SiteUrl -ServerName $serverName -ConfigurationName $ConfigurationName
        }

        Write-Verbose ("StatusCode - " + $webRequest.StatusCode)

        if ($webRequest.StatusCode -ne 200)
        {
            $NoIssuesFound = $false
            $highlight += 'Outcome'
            $outcome = $webRequest.StatusDescription
        } else {
            if ($webRequest.Content.ToLower().Contains($TextToLocate.ToLower())) { 
                $outcome = "Specified Page Content Found"
            } else {
                $highlight += 'Outcome'
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

    return @{
        "SectionHeader" = $sectionHeader;
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues;
        "ElapsedTime" = $stopWatch.Elapsed;
        }
}


