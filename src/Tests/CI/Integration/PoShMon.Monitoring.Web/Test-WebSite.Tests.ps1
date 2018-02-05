$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

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
<#
Describe "Test-Website" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Invoke-WebRequest -MockWith {
            return [WebRequestMock]::new(200, "OK", $testContent)
        }
        Mock -CommandName Invoke-RemoteWebRequest -MockWith {
            return [RemoteWebRequestMock]::new(200, "OK", $testContent, $serverName)
        }

        $actual = Test-WebSite -SiteUrl 'abc' -TextToLocate $testContent -ServerNames $serverName

        Assert-VerifiableMock

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 3
        $headers.ContainsKey("ServerName") | Should Be $true
        $headers.ContainsKey("StatusCode") | Should Be $true
        $headers.ContainsKey("Outcome") | Should Be $true
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be 4
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("StatusCode") | Should Be $true
        $values1.ContainsKey("Outcome") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }
    
    It "Should test directly and on each server" {

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', 'OK', '<html>Test Content</html>')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -MockWith {
            return [RemoteWebRequestMock]::new('200', 'OK', '<html>Test Content</html>', $ServerName) 
        }

        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test content' -ServerNames 'Server1','Server2'

        Assert-VerifiableMock

        $actual.NoIssuesFound | Should Be $true
        $actual.OutputValues.Count | Should Be 3
        $actual.OutputValues[0].ServerName | Should Be '(Direct)'
        $actual.OutputValues[1].ServerName | Should Be 'Server1'
        $actual.OutputValues[2].ServerName | Should Be 'Server2'
    }

    It "Should fail on server 1" {

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -MockWith {
            if ($ServerName -ne "Server1")
                { return [RemoteWebRequestMock]::new('200', 'OK', '<html>Test Content</html>', $ServerName) }
            else
                { return [RemoteWebRequestMock]::new('500', 'Server Error', '<html><title>Server Error</title></html>', $ServerName) }
        }

        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test content' -ServerNames 'Server1','Server2'

        Assert-VerifiableMock

        $actual.NoIssuesFound | Should Be $false
        $actual.OutputValues[1].Highlight | Should Be 'Outcome'
        $actual.OutputValues[1].Outcome | Should Be 'Server Error'
    }
    
    It "Should find matching text" {

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', 'OK', '<html>Test Content</html>')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -MockWith {
            if ($ServerName -eq "Server1")
                { return [RemoteWebRequestMock]::new('200', 'OK', '<html>Test Content</html>', $ServerName) }
            else
                { return [RemoteWebRequestMock]::new('200', 'OK', '<html>other stuff</html>', $ServerName) }
        }

        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test Content' -ServerNames 'Server1','Server2'

        Assert-VerifiableMock

        $actual.NoIssuesFound | Should Be $true
        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[0].Outcome | Should Be 'Specified Page Content Found'
        $actual.OutputValues[1].Highlight.Count | Should Be 0
        $actual.OutputValues[1].Outcome | Should Be 'Specified Page Content Found'
        $actual.OutputValues[2].Highlight | Should Be 'Outcome'
        $actual.OutputValues[2].Outcome | Should Be 'Specified Page Content Not Found'
    }
}
#>