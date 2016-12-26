$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\') -Resolve
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Web\$sutFileName" 
. $sutFilePath
$depFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Web\Invoke-RemoteWebRequest.ps1"
. $depFilePath

class WebRequestMock {
    [int]$StatusCode
    [string]$StatusDescription
    [string]$Content

    WebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent) {
        $this.StatusCode = $NewStatusCode;
        $this.StatusDescription = $NewStatusDescription;
        $this.Content = $NewContent;
    }
}

class RemoteWebRequestMock {
    [int]$StatusCode
    [string]$StatusDescription
    [string]$Content
    [string]$ServerName

    RemoteWebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent, [String]$NewServerName) {
        $this.StatusCode = $NewStatusCode;
        $this.StatusDescription = $NewStatusDescription;
        $this.Content = $NewContent;
        $this.ServerName = $NewServerName;
    }
}

Describe "Test-Website" {
    It "Should return a direct result and a result from the server(s) specified" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "outputHeaders" = @{ 'ServerName' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
            "OutputValues" = @()
            }

        $testContent = "Content to return"
        $serverName = "SVR123"

        $expected["OutputValues"] += @{
                        'ServerName' = '(Direct)';
                        'StatusCode' = 200;
                        'Outcome' = "Specified Page Content Found";
                        'Highlight' = ''
                    }
        $expected["OutputValues"] += @{
                        'ServerName' = '$serverName';
                        'StatusCode' = 200;
                        'Outcome' = "Specified Page Content Found";
                        'Highlight' = ''
                    }

        Mock -CommandName Invoke-WebRequest -MockWith {
            return [WebRequestMock]::new(200, "OK", $testContent)
        }
        Mock -CommandName Invoke-RemoteWebRequest -MockWith {
            return [RemoteWebRequestMock]::new(200, "OK", $testContent, $serverName)
        }

        $actual = Test-WebSite -SiteUrl 'abc' -TextToLocate $testContent -ServerNames $serverName

        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $true
    }
}