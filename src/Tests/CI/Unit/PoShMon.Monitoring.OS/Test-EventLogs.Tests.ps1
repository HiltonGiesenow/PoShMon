$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-EventLogs" {
    InModuleScope PoShMon {

        class EventLogItemMock {
            [int]$EventCode
            [string]$SourceName
            [string]$User
            [datetime]$TimeGenerated
            [string]$Message

            EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [datetime]$NewTimeGenerated, [String]$NewMessage) {
                $this.EventCode = $NewEventCode;
                $this.SourceName = $NewSourceName;
                $this.User = $NewUser;
                $this.TimeGenerated = $NewTimeGenerated;
                $this.Message = $NewMessage;
            }

            [string] ConvertToDateTime([datetime]$something) {
                return $something.ToString()
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", ([datetime]::new(2017, 1, 1, 10, 15, 0)), "Sample Message")
                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'localhost'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("GroupBy") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 6
            $actual.OutputValues[0].ServerName | Should Be 'localhost'
            $actual.OutputValues[0].EventID | Should Be '123'
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[0].Source | Should Be "Test App"
            $actual.OutputValues[0].User | Should Be "domain\user1"
            $actual.OutputValues[0].Timestamp | Should Be ([datetime]::new(2017, 1, 1, 10, 15, 0)).ToString()
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            #$valuesGroup1 = $actual.OutputValues[0]
            #$valuesGroup1.Keys.Count | Should Be 2
            #$values1 = $valuesGroup1.GroupOutputValues
            #$values1.Keys.Count | Should Be 6
            #$values1.ContainsKey("EventID") | Should Be $true
            #$values1.ContainsKey("InstanceCount") | Should Be $true
            #$values1.ContainsKey("Source") | Should Be $true
            #$values1.ContainsKey("User") | Should Be $true
            #$values1.ContainsKey("Timestamp") | Should Be $true
            #$values1.ContainsKey("Message") | Should Be $true
        }

        It "Should write the expected Verbose output - No Failing Servers" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -Verbose
            $output = $($actual = Test-EventLogs $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Initiating 'Critical Event Log Issues' Test..."
            $output[1].ToString() | Should Be "`tServer1"
            $output[2].ToString() | Should Be "`t`tNo Entries Found In Time Specified"
            $output[3].ToString() | Should Be "Complete 'Critical Event Log Issues' Test, Issues Found: No"
        }

        It "Should write the expected Warning output - Single Failing Server" {
    
            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                $date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15

                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, "Sample Message")
                $eventsCollection += [EventLogItemMock]::new(456, "Test App2", "domain\user2", $date.AddSeconds(1), "Another Message")
                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration
            $output = $($actual = Test-EventLogs $poShMonConfiguration) 3>&1

            $date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15
        
            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`t`t123 : 1 : Test App : domain\user1 : $($date.ToString()) - Sample Message"
            $output[1].ToString() | Should Be "`t`t456 : 1 : Test App2 : domain\user2 : $($date.AddSeconds(1).ToString()) - Another Message"
        }

        It "Should alert on items found" {
        
            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", (Get-Date), "Sample Message")
                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false
        }

        It "Should group per server" -Skip { #no longer valid
        
            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                $date = Get-Date

                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, "Sample Message")
                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-1), "Sample Message")
                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-2), "Another Sample Message")
                $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", $date.AddMinutes(-3), "Different Event Code")

                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1', 'Server2'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 6
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 2
            $actual.OutputValues[1].Message | Should Be "Another Sample Message"
            $actual.OutputValues[1].InstanceCount | Should Be 1
        }

        It "Should group on EventID and Message" {

            Mock -CommandName Get-WmiObject -MockWith {
                $eventsCollection = @()

                $date = Get-Date

                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, "Sample Message")
                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-1), "Sample Message")
                $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-2), "Another Sample Message")
                $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", $date.AddMinutes(-3), "Different Event Code")

                return $eventsCollection
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1', 'Server2'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 6
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 2
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "Another Sample Message"
            $actual.OutputValues[1].InstanceCount | Should Be 1

            $actual.OutputValues[3].ServerName | Should Be "Server2"
            $actual.OutputValues[3].Message | Should Be "Sample Message"
            $actual.OutputValues[3].InstanceCount | Should Be 2
            $actual.OutputValues[4].ServerName | Should Be "Server2"
            $actual.OutputValues[4].Message | Should Be "Another Sample Message"
            $actual.OutputValues[4].InstanceCount | Should Be 1
		}
	}
}
Describe "Test-EventLogs-NewScope" {
	InModuleScope PoShMon {

        class EventLogItemMock {
            [int]$EventCode
            [string]$SourceName
            [string]$User
            [datetime]$TimeGenerated
            [string]$Message

            EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [datetime]$NewTimeGenerated, [String]$NewMessage) {
                $this.EventCode = $NewEventCode;
                $this.SourceName = $NewSourceName;
                $this.User = $NewUser;
                $this.TimeGenerated = $NewTimeGenerated;
                $this.Message = $NewMessage;
            }

            [string] ConvertToDateTime([datetime]$something) {
                return $something.ToString()
            }
		}
		
		Mock -CommandName Get-WmiObject -MockWith {
			$eventsCollection = @()

			if ($ComputerName -eq 'Server2')
			{
				$date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15

				$eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, "Sample Message")
				$eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-1), "Sample Message")
				$eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date.AddMinutes(-2), "Another Sample Message")
			}

			return $eventsCollection
		}

        It "Should List a Result for All Servers Specified" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1', 'Server2', 'Server3'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 4
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be $null
            $actual.OutputValues[0].InstanceCount | Should Be $null

            $actual.OutputValues[1].ServerName | Should Be "Server2"
            $actual.OutputValues[1].Message | Should Be "Sample Message"
            $actual.OutputValues[1].InstanceCount | Should Be 2
            $actual.OutputValues[2].ServerName | Should Be "Server2"
            $actual.OutputValues[2].Message | Should Be "Another Sample Message"
			$actual.OutputValues[2].InstanceCount | Should Be 1

			$actual.OutputValues[3].ServerName | Should Be "Server3"
            $actual.OutputValues[3].Message | Should Be $null
            $actual.OutputValues[3].InstanceCount | Should Be $null
        }
        
        It "Should write the expected Warning output - Failing Server in Group" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1', 'Server2', 'Server3'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration
            $output = $($actual = Test-EventLogs $poShMonConfiguration) 3>&1

            $date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15
        
            $output.Count | Should Be 2
            $output[0].ToString() | Should Be "`t`t123 : 2 : Test App : domain\user1 : $($date.ToString()) - Sample Message"
            $output[1].ToString() | Should Be "`t`t123 : 1 : Test App : domain\user1 : $($date.AddMinutes(-2).ToString()) - Another Sample Message"
        }
        
        It "Should write the expected Verbose output - Failing Server in Group" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1', 'Server2', 'Server3'
                            OperatingSystem
                        }

			$actual = Test-EventLogs $poShMonConfiguration -Verbose
			$output = $($actual = Test-EventLogs $poShMonConfiguration -Verbose) 4>&1

			$output.Count | Should Be 7
			$output[0].ToString() | Should Be "Initiating 'Critical Event Log Issues' Test..."
			$output[1].ToString() | Should Be "`tServer1"
			$output[2].ToString() | Should Be "`t`tNo Entries Found In Time Specified"
			$output[3].ToString() | Should Be "`tServer2"
			$output[4].ToString() | Should Be "`tServer3"
			$output[5].ToString() | Should Be "`t`tNo Entries Found In Time Specified"
			$output[6].ToString() | Should Be "Complete 'Critical Event Log Issues' Test, Issues Found: Yes"
        }
    }
}

Describe "Test-EventLogs-IgnoreListScope" {
	InModuleScope PoShMon {

        class EventLogItemMock {
            [int]$EventCode
            [string]$SourceName
            [string]$User
            [datetime]$TimeGenerated
            [string]$Message

            EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [datetime]$NewTimeGenerated, [String]$NewMessage) {
                $this.EventCode = $NewEventCode;
                $this.SourceName = $NewSourceName;
                $this.User = $NewUser;
                $this.TimeGenerated = $NewTimeGenerated;
                $this.Message = $NewMessage;
            }

            [string] ConvertToDateTime([datetime]$something) {
                return $something.ToString()
            }
		}
		
		Mock -CommandName Get-WmiObject -MockWith {
			$eventsCollection = @()

			if ($ComputerName -eq 'Server1')
			{
				$date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15

				$eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, "Sample Message")
				$eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", $date.AddMinutes(-1), "Another Sample Message")
				$eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", $date.AddMinutes(-2), "Another Sample Message")
				$eventsCollection += [EventLogItemMock]::new(789, "Test App", "domain\user1", $date.AddMinutes(-2), "3rd Sample Message")
			}

			return $eventsCollection
		}

        It "Should Show All Items for No Ignore" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 3
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "Another Sample Message"
			$actual.OutputValues[1].InstanceCount | Should Be 2
            $actual.OutputValues[2].ServerName | Should Be "Server1"
            $actual.OutputValues[2].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[2].InstanceCount | Should Be 1
		}

		It "Should NOT show items marked for Ignore (using deprecated EventIDIgnoreList)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventIDIgnoreList @{ "456" = "foo"}
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[1].InstanceCount | Should Be 1
        }
        
        It "Should Ignore items within count (using deprecated EventIDIgnoreList)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventIDIgnoreList @{ "456" = "foo"}
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[1].InstanceCount | Should Be 1
        }
        
        It "Should write the expected Warning output for deprecated EventIDIgnoreList" {

            $actual = New-PoShMonConfiguration {
                        General -ServerNames 'Server1'
                        OperatingSystem -EventIDIgnoreList @{ "456" = "foo"}
                    }
            $output = $($actual = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1'
                                    OperatingSystem -EventIDIgnoreList @{ "456" = "foo"}
                                }) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "The 'EventIDIgnoreList' setting has been deprecated, please use 'EventLogIgnore' instances, for example New-PoShMonConfiguration { OperatingSystem { EventLogIgnore 123, EventLogIgnore 456 }}"
        }

        It "Should NOT show items marked for Ignore (single item)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventLogIgnores { 
                                            EventLogIgnore -EventID 456
                                        }
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[1].InstanceCount | Should Be 1
        }

        It "Should NOT show items marked for Ignore (multiple ignores)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventLogIgnores { 
                                            EventLogIgnore -EventID 123
                                            EventLogIgnore -EventID 456
                                        }
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 1
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[0].InstanceCount | Should Be 1
        }
        
        It "Should NOT show items marked for Ignore (other config parameters)" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -CPULoadThresholdPercent 50 -EventLogIgnores { 
                                            EventLogIgnore -EventID 123
                                            EventLogIgnore -EventID 456
                                        } -DriveSpaceThreshold 55
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 1
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[0].InstanceCount | Should Be 1
        }
        
        It "Should Ignore items within count" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventLogIgnores { 
                                            EventLogIgnore -EventID 456 -IgnoreIfLessThan 3
                                        }
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[1].InstanceCount | Should Be 1
        }

        It "Should flag items outside count" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        General -ServerNames 'Server1'
                                        OperatingSystem -EventLogIgnores { 
                                            EventLogIgnore -EventID 456 -IgnoreIfLessThan 1
                                            EventLogIgnore -EventID 999
                                        }
                                    }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 3
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "Sample Message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
            $actual.OutputValues[1].ServerName | Should Be "Server1"
            $actual.OutputValues[1].Message | Should Be "Another Sample Message"
            $actual.OutputValues[1].InstanceCount | Should Be 2
            $actual.OutputValues[2].ServerName | Should Be "Server1"
            $actual.OutputValues[2].Message | Should Be "3rd Sample Message"
			$actual.OutputValues[2].InstanceCount | Should Be 1
        }
    }
}

Describe "Test-EventLogs-NoMessageScope" {
	InModuleScope PoShMon {

        class EventLogItemMock {
            [int]$EventCode
            [string]$SourceName
            [string]$User
            [datetime]$TimeGenerated
            [string]$Message
            [string[]]$InsertionStrings

            EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [datetime]$NewTimeGenerated, [String]$NewMessage, [String[]]$InsertionStrings) {
                $this.EventCode = $NewEventCode;
                $this.SourceName = $NewSourceName;
                $this.User = $NewUser;
                $this.TimeGenerated = $NewTimeGenerated;
                $this.Message = $NewMessage;
                $this.InsertionStrings = $InsertionStrings
            }

            [string] ConvertToDateTime([datetime]$something) {
                return $something.ToString()
            }
		}
		
		Mock -CommandName Get-WmiObject -MockWith {
			$eventsCollection = @()

            $date = Get-Date -Year 2017 -Month 1 -Day 1 -Hour 9 -Minute 30 -Second 15

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", $date, $null, @("This", "is", "the message"))

			return $eventsCollection
		}

        It "Should use InsertionStrings for empty Message" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General -ServerNames 'Server1'
                            OperatingSystem
                        }

            $actual = Test-EventLogs $poShMonConfiguration -WarningAction SilentlyContinue
        
            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 1
            $actual.OutputValues[0].ServerName | Should Be "Server1"
            $actual.OutputValues[0].Message | Should Be "This, is, the message"
            $actual.OutputValues[0].InstanceCount | Should Be 1
        }
    }
}