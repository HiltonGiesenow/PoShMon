$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPJobHealth" {
    InModuleScope PoShMon {

        class SPJobHealthMock {
            [string]$JobDefinitionTitle
            [string]$EndTime
            [string]$ServerName
            [string]$WebApplicationName
            [string]$ErrorMessage

            SPJobHealthMock ([string]$NewJobDefinitionTitle, [string]$NewEndTime, [string]$NewServerName, [string]$NewWebApplicationName, [string]$NewErrorMessage) {
                $this.JobDefinitionTitle = $NewJobDefinitionTitle;
                $this.EndTime = $NewEndTime;
                $this.ServerName = $NewServerName;
                $this.WebApplicationName = $NewWebApplicationName;
                $this.ErrorMessage = $NewErrorMessage;
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [SPJobHealthMock]::new('Job 123', [datetime]::new(2017, 1, 1, 10, 15, 0).ToString(), "Server1", "Web App1", "Something went wrong...")
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                }   

            $actual = Test-SPJobHealth $poShMonConfiguration

            $headerKeyCount = 4

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("HeaderUrl") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[0].JobDefinitionTitle | Should Be 'Job 123'
            $actual.OutputValues[0].EndTime | Should Be ([datetime]::new(2017, 1, 1, 10, 15, 0)).ToString()
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            #$actual.OutputValues[0].WebApplicationName | Should Be "Web App1"
            $actual.OutputValues[0].ErrorMessage | Should Be "Something went wrong..."
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be $headerKeyCount
            #$values1.ContainsKey("JobDefinitionTitle") | Should Be $true
            #$values1.ContainsKey("EndTime") | Should Be $true
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("WebApplicationName") | Should Be $true
            #$values1.ContainsKey("ErrorMessage") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration { }

            $actual = Test-SPJobHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPJobHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "Initiating 'Failing Timer Jobs' Test..."
            $output[1].ToString() | Should Be "Complete 'Failing Timer Jobs' Test, Issues Found: No"
        }

        It "Should not warn on no failed Jobs" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPJobHealth $poShMonConfiguration
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $true
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {

                $date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15

                return @(
                    [SPJobHealthMock]::new('Job 123', $date, "Server1", "Web App1", "Something went wrong..."),
                    [SPJobHealthMock]::new('Job 456', $date.AddMinutes(-1), "Server1", "Web App1", "Something went wrong...")
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPJobHealth $poShMonConfiguration
            $output = $($actual = Test-SPJobHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`tJob 123 at 01/01/2017 09:30:15 on Server1 for Web App1 : Something went wrong..."
            $output[1].ToString() | Should Be "`tJob 456 at 01/01/2017 09:29:15 on Server1 for Web App1 : Something went wrong..."
        }

        It "Should warn on any failed Jobs" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPJobHealthMock]::new('Job 123', (get-date).AddMinutes(-145), "Server1", "Web App1", "Something went wrong...")
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPJobHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 1
        }

        It "Should return all failed Jobs" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPJobHealthMock]::new('Job 123', (get-date).AddMinutes(-145), "Server1", "Web App1", "Something went wrong..."),
                    [SPJobHealthMock]::new('Job 456', (get-date).AddMinutes(-145), "Server1", "Web App1", "Something went wrong...")
                )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPJobHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
            $actual.OutputValues[0].JobDefinitionTitle | Should Be 'Job 123'
            $actual.OutputValues[1].JobDefinitionTitle | Should Be 'Job 456'
        }
    }
}