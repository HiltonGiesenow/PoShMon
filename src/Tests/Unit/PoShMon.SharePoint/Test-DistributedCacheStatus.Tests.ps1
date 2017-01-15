$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

class SPDistributedCacheMock {
    [object]$Server
    [object]$Status

    SPDistributedCacheMock ([string]$NewServerDisplayName, [string]$NewStatusValue) {
        $this.Server = [pscustomobject]@{DisplayName=$NewServerDisplayName};
        $this.Status = [pscustomobject]@{Value=$NewStatusValue};
    }
}

Describe "Test-DistributedCacheStatus" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
            return @(
                [SPDistributedCacheMock]::new('Server1', 'Online')
            )
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
            }   

        $actual = Test-DistributedCacheStatus $poShMonConfiguration

        $headerKeyCount = 2

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be $headerKeyCount
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be ($headerKeyCount+1)
        $values1.ContainsKey("Server") | Should Be $true
        $values1.ContainsKey("Status") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should not warn on all server are online" {

        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            return @(
                [SPDistributedCacheMock]::new('Server1', 'Online')
            )
        }

        $poShMonConfiguration = New-PoShMonConfiguration {}

        $actual = Test-DistributedCacheStatus $poShMonConfiguration
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $true

        $actual.OutputValues.Highlight.Count | Should Be 0
    }

    It "Should warn on servers being offline" {

        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -Verifiable -MockWith {
            return @(
                [SPDistributedCacheMock]::new('Server1', 'Online'),
                [SPDistributedCacheMock]::new('Server2', 'Offline')
            )
        }

        $poShMonConfiguration = New-PoShMonConfiguration {}

        $actual = Test-DistributedCacheStatus $poShMonConfiguration
        
        Assert-VerifiableMocks

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[1].Highlight.Count | Should Be 1
        $actual.OutputValues[1].Highlight[0] | Should Be 'Status'
    }

}