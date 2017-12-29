$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPWindowsServiceState" {
    InModuleScope PoShMon {

        class SPServiceInstanceMock {
            [object]$Status
            [object]$Service
            [object]$Server

            SPServiceInstanceMock ([string]$NewServerDisplayName, [string]$NewServiceName, [string]$NewStatusValue) {
                $this.Server = [pscustomobject]@{DisplayName=$NewServerDisplayName};
                $this.Service = [pscustomobject]@{Name=$NewServiceName};
                $this.Status = [pscustomobject]@{Value=$NewStatusValue};
            }
        }

        It "Should return a matching output structure" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPServiceInstanceMock]::new('Server1', 'TheService', 'Online')
                )
            }

            Mock -CommandName Test-ServiceStatePartial -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                            @{
                                'NoIssuesFound' = $true
                                'GroupOutputValues' = @(
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 1 DisplayName';
                                                            'Name' = 'Svc1';
                                                            'Status' = "Running";
                                                            'Highlight' = @()
                                                        },
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 2 DisplayName';
                                                            'Name' = 'Svc2';
                                                            'Status' = "Running";
                                                            'Highlight' = @()
                                                        }
                                                       )
                            }
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        OperatingSystem
                                    }   

            $actual = Test-SPWindowsServiceState $poShMonConfiguration

            $headerKeyCount = 3

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("GroupBy") | Should Be $true
            $actual.OutputValues[1].ServerName | Should Be 'Server1'
            $actual.OutputValues[1].DisplayName | Should Be 'Service 2 DisplayName'
            $actual.OutputValues[1].Name | Should Be 'Svc2'
            $actual.OutputValues[1].Status | Should Be 'Running'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            #$values1 = $valuesGroup1.GroupOutputValues[0]
            #$values1.Keys.Count | Should Be ($headerKeyCount + 1)
            #$values1.ContainsKey("DisplayName") | Should Be $true
            #$values1.ContainsKey("Name") | Should Be $true
            #$values1.ContainsKey("Status") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPServiceInstanceMock]::new('Server1', 'TheService', 'Online')
                )
            }

            Mock -CommandName Test-ServiceStatePartial -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                            @{
                                'NoIssuesFound' = $true
                                'GroupOutputValues' = @(
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 1 DisplayName';
                                                            'Name' = 'Svc1';
                                                            'Status' = "Running";
                                                            'Highlight' = @()
                                                        },
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 2 DisplayName';
                                                            'Name' = 'Svc2';
                                                            'Status' = "Running";
                                                            'Highlight' = @()
                                                        }
                                                       )
                            }
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        OperatingSystem
                                    }   

            $actual = Test-SPWindowsServiceState $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPWindowsServiceState $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Windows Service State' Test..."
            $output[1].ToString() | Should Be "`tGetting SharePoint service list..."
            $output[2].ToString() | Should Be "`tGetting state of services per server..."
            $output[3].ToString() | Should Be "Complete 'Windows Service State' Test, Issues Found: No"
        }

        It "Should fail for any service in the wrong state" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPServiceInstanceMock]::new('Server1', 'TheService', 'Online')
                )
            }

            Mock -CommandName Test-ServiceStatePartial -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                            @{
                                'NoIssuesFound' = $false
                                'GroupOutputValues' = @(
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 2 DisplayName';
                                                            'Name' = 'Svc2';
                                                            'Status' = "Stopped";
                                                            'Highlight' = @('Status')
                                                        }
                                                       )
                            }
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        OperatingSystem
                                    }   

            $actual = Test-SPWindowsServiceState $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $false

            Assert-VerifiableMock
        }

        It "Should test for services discovered" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPServiceInstanceMock]::new('Server1', 'TheService', 'Online')
                )
            }

            Mock -CommandName Test-ServiceStatePartial -ModuleName PoShMon -Verifiable -MockWith {

                if (!$Services.Contains('TheService')) { throw "Service Not Found" }

                return @(
                            @{
                                'NoIssuesFound' = $false
                                'GroupOutputValues' = @(
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 2 DisplayName';
                                                            'Name' = 'Svc2';
                                                            'Status' = "Stopped";
                                                            'Highlight' = @('Status')
                                                        }
                                                       )
                            }
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        OperatingSystem
                                    }   

            $actual = Test-SPWindowsServiceState $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $false

            Assert-VerifiableMock
        }

        It "Should skip any service specified discovered" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
                return @(
                    [SPServiceInstanceMock]::new('Server1', 'TheService', 'Online')
                )
            }

            Mock -CommandName Test-ServiceStatePartial -ModuleName PoShMon -Verifiable -MockWith {
        
                if (!$Services.Contains('TheService')) { throw "Service Not Found" }
                if ($Services.Contains('SPWriterV4')) { throw "SPWriterV4 Should be skipped!" }
            
                return @(
                            @{
                                'NoIssuesFound' = $false
                                'GroupOutputValues' = @(
                                                        [pscustomobject]@{
                                                            'ServerName' = 'Server1'
                                                            'DisplayName' = 'Service 2 DisplayName';
                                                            'Name' = 'Svc2';
                                                            'Status' = "Stopped";
                                                            'Highlight' = @('Status')
                                                        }
                                                       )
                            }
                        )
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        OperatingSystem -WindowsServicesToSkip 'SPWriterV4'
                                    }   

            $actual = Test-SPWindowsServiceState $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $false

            Assert-VerifiableMock
        }

    }
}