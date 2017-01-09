$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose

class EventLogItemMock {
    [int]$EventCode
    [string]$SourceName
    [string]$User
    [string]$TimeGenerated
    [string]$Message

    EventLogItemMock ([int]$NewEventCode, [String]$NewSourceName, [String]$NewUser, [String]$NewTimeGenerated, [String]$NewMessage) {
        $this.EventCode = $NewEventCode;
        $this.SourceName = $NewSourceName;
        $this.User = $NewUser;
        $this.TimeGenerated = $NewTimeGenerated;
        $this.Message = $NewMessage;
    }

    [string] ConvertToDateTime([string]$something) {
        return (Get-Date).ToString()
    }
}

Describe "Test-EventLogs" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            return $eventsCollection
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-EventLogs $poShMonConfiguration

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 6
        $valuesGroup1 = $actual.OutputValues[0]
        $valuesGroup1.Keys.Count | Should Be 2
        $values1 = $valuesGroup1.GroupOutputValues
        $values1.Keys.Count | Should Be 6
        $values1.ContainsKey("EventID") | Should Be $true
        $values1.ContainsKey("InstanceCount") | Should Be $true
        $values1.ContainsKey("Source") | Should Be $true
        $values1.ContainsKey("User") | Should Be $true
        $values1.ContainsKey("Timestamp") | Should Be $true
        $values1.ContainsKey("Message") | Should Be $true
    }

    It "Should alert on items found" {
        
        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            return $eventsCollection
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'Server1'
                        OperatingSystem
                    }

        $actual = Test-EventLogs $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false
    }
    It "Should group per server" {
        
        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Another Sample Message")
            $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", "123", "Different Event Code")

            return $eventsCollection
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'Server1', 'Server2'
                        OperatingSystem
                    }

        $actual = Test-EventLogs $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Count  | Should Be 2
        $actual.OutputValues[0].GroupName  | Should Be 'Server1'
        $actual.OutputValues[1].GroupName  | Should Be 'Server2'
    }
    It "Should group on EventID and Message" {

        Mock -CommandName Get-WmiObject -MockWith {
            $eventsCollection = @()

            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Sample Message")
            $eventsCollection += [EventLogItemMock]::new(123, "Test App", "domain\user1", "123", "Another Sample Message")
            $eventsCollection += [EventLogItemMock]::new(456, "Test App", "domain\user1", "123", "Different Event Code")

            return $eventsCollection
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'Server1'
                        OperatingSystem
                    }

        $actual = Test-EventLogs $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues[0].GroupOutputValues.Count | Should Be 3
        $actual.OutputValues[0].GroupOutputValues[0].InstanceCount | Should Be 2
        $actual.OutputValues[0].GroupOutputValues[1].InstanceCount | Should Be 1
        $actual.OutputValues[0].GroupOutputValues[2].InstanceCount | Should Be 1
    }
}
