$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

class UpsServiceInstanceMock {
    [object]$Server

    UpsServiceInstanceMock ([string]$NewServerDisplayName) {
        $this.Server = [pscustomobject]@{DisplayName=$NewServerDisplayName};
    }
}

class FimRunHistoryItemMock {
    [string]$RunStatus
    [string]$RunStatusReturnValue
    [datetime]$EndTime
    [string]$ServerName
    [string]$WebApplicationName
    [string]$ErrorMessage

    FimRunHistoryItemMock ([string]$NewRunStatus, [datetime]$NewEndTime, [string]$NewServerName, [string]$NewWebApplicationName, [string]$NewErrorMessage) {
        $this.RunStatus = $NewRunStatus;
        $this.EndTime = $NewEndTime;
        $this.ServerName = $NewServerName;
        $this.WebApplicationName = $NewWebApplicationName;
        $this.ErrorMessage = $NewErrorMessage;
    }

    [object] RunDetails() {
        return [PSCustomObject]@{ "ReturnValue" = $RunStatusReturnValue }
    }
}

Describe "Test-UserProfileSync" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
            return @(
                [UpsServiceInstanceMock]::new("Server1")
            )
        }

        Mock -CommandName Get-WmiObject -MockWith {
            return [DiskMock]::new('C:', 3, "", [UInt64]50GB, [UInt64]5GB, "MyCDrive")
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
            }   

        $actual = Test-UserProfileSync $poShMonConfiguration

        $headerKeyCount = 5

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be $headerKeyCount
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be $headerKeyCount
        $values1.ContainsKey("JobDefinitionTitle") | Should Be $true
        $values1.ContainsKey("EndTime") | Should Be $true
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("WebApplicationName") | Should Be $true
        $values1.ContainsKey("ErrorMessage") | Should Be $true
        #$values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should not warn on no failed Jobs" {

        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            return @(
            )
        }

        $poShMonConfiguration = New-PoShMonConfiguration {}

        $actual = Test-UserProfileSync $poShMonConfiguration
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $true
    }

    It "Should warn on any failed Jobs" {

        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            return @(
                [SPJobHealthMock]::new('Job 123', (get-date).AddMinutes(-145), "Server1", "Web App1", "Something went wrong...")
            )
        }

        $poShMonConfiguration = New-PoShMonConfiguration {}

        $actual = Test-UserProfileSync $poShMonConfiguration
        
        Assert-VerifiableMocks

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

        $actual = Test-UserProfileSync $poShMonConfiguration
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Count | Should Be 2
        $actual.OutputValues[0].JobDefinitionTitle | Should Be 'Job 123'
        $actual.OutputValues[1].JobDefinitionTitle | Should Be 'Job 456'
    }

}