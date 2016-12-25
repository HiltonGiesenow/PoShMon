$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleFolderPath = Join-Path $here -ChildPath ('..\Modules\') -Resolve
#$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")
#$sut = Join-Path $sutFolderPath, $sutFileName
#. "$sut"
Import-Module (Join-Path $moduleFolderPath -ChildPath "PoShMon.Shared\SharedMonitoringModule.psm1")
Import-Module (Join-Path $moduleFolderPath -ChildPath "PoShMon.Web\WebMonitoringModule.psm1")

class WebRequestMock {
    [int]$StatusCode
    [string]$Content
    [string]$StatusDescription

    WebRequestMock ([int]$NewStatusCode, [String]$NewContent, [String]$NewStatusDescription) {
        $this.StatusCode = $NewStatusCode;
        $this.Content = $NewContent;
        $this.StatusDescription = $NewStatusDescription;
    }
}

Describe "Test-Website" {
    It "Should test directly and on each server" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "OutputHeaders" = @{ 'Server' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        #Mock -CommandName Format-Gigs -MockWith {
        #    return '123'
        #}

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -ModuleName WebMonitoringModule -MockWith {
            Write-Host "Mocking $ServerName..."

            return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK') 
        }

        #Invoke-Command -Session 'foo' -ScriptBlock { Out-Host 'foo' }
        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test content' -ServerNames 'Server1','Server2' -ConfigurationName SPFarmAccConn

        #$actual = Test-WebSite -SiteUrl 'https://www.google.com' -ServerNames 'Server1','Server2','Server3'
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $true
        $actual.OutputValues.Count | Should Be 3
        $actual.OutputValues[0].ServerName | Should Be '(Direct)'
        $actual.OutputValues[1].ServerName | Should Be 'Server1'
        $actual.OutputValues[2].ServerName | Should Be 'Server2'
        #$actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
    }
    It "Should fail on server 1" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "OutputHeaders" = @{ 'Server' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        #Mock -CommandName Format-Gigs -MockWith {
        #    return '123'
        #}

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -ModuleName WebMonitoringModule -MockWith {
            Write-Host "Mocking $ServerName..."

            if ($ServerName -ne "Server1")
                { return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK') }
            else
                { return [WebRequestMock]::new('500', '<html><title>Server Error</title></html>', 'Server Error') }
        }

        #Invoke-Command -Session 'foo' -ScriptBlock { Out-Host 'foo' }
        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test content' -ServerNames 'Server1','Server2' -ConfigurationName SPFarmAccConn

        #$actual = Test-WebSite -SiteUrl 'https://www.google.com' -ServerNames 'Server1','Server2','Server3'
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $false
        $actual.OutputValues[1].Highlight | Should Be 'Outcome'
        $actual.OutputValues[1].Outcome | Should Be 'Server Error'
    }
    It "Should find matching text" {
        
        $expected = @{
            "NoIssuesFound" = $true;
            "OutputHeaders" = @{ 'Server' = 'Server'; 'StatusCode' = 'Status Code'; 'Outcome' = 'Outcome' }
            "OutputValues" = @()
            }

        $expected["OutputValues"] += @{
                        'DriveLetter' = 'C:';
                        'TotalSpace' = 243631;
                        'FreeSpace' = 58313;
                        'Highlight' = ''
                    }

        #Mock -CommandName Format-Gigs -MockWith {
        #    return '123'
        #}

        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK')
        }

        Mock -CommandName Invoke-RemoteWebRequest -Verifiable -ModuleName WebMonitoringModule -MockWith {
            Write-Host "Mocking $ServerName..."

            if ($ServerName -ne "Server1")
                { return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK') }
            else
                { return [WebRequestMock]::new('200', '<html>other stuff</html>', 'OK') }
        }

        #Invoke-Command -Session 'foo' -ScriptBlock { Out-Host 'foo' }
        $actual = Test-WebSite -SiteUrl 'https://www.mywebsite.test' -TextToLocate 'Test content' -ServerNames 'Server1','Server2' -ConfigurationName SPFarmAccConn

        #$actual = Test-WebSite -SiteUrl 'https://www.google.com' -ServerNames 'Server1','Server2','Server3'
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $true
        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[0].Outcome | Should Be 'Specified Page Content Found'
        $actual.OutputValues[2].Highlight.Count | Should Be 0
        $actual.OutputValues[2].Outcome | Should Be 'Specified Page Content Found'
        $actual.OutputValues[1].Highlight | Should Be 'Outcome'
        $actual.OutputValues[1].Outcome | Should Be 'Specified Page Content Not Found'
    }
}

