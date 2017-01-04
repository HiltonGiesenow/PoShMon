$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose
<#$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.OSMonitoring\$sutFileName" 
. $sutFilePath
#>

class ServerMemoryMock {
    [string]$ServerName
    [UInt64]$TotalMemory
    [UInt64]$FreeMemory

    DiskMock ([string]$NewServerName, [UInt64]$NewTotalMemory, [UInt64]$NewFreeMemory) {
        $this.ServerName = $NewServerName;
        $this.TotalMemory = $NewTotalMemory;
        $this.FreeMemory = $NewFreeMemory;
    }
}

Describe "Test-Memory" {
    It "Should throw an exception if no OperatingSystem configuration is set" {
    
        $poShMonConfiguration = New-PoShMonConfiguration { }

        { Test-Memory $poShMonConfiguration } | Should throw
    }

    It "Should return a matching output structure" {
    
        Mock -CommandName Get-WmiObject -MockWith {
            return [ServerMemoryMock]::new('Server1', 8312456, 2837196)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-Memory $poShMonConfiguration

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 4
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be 5
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("TotalMemory") | Should Be $true
        $values1.ContainsKey("FreeMemory") | Should Be $true
        $values1.ContainsKey("FreeSpacePerc") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should not warn on space above threshold" {

        Mock -CommandName Get-WmiObject -MockWith {
            return [ServerMemoryMock]::new('Server1', 8312456, 2837196)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-Memory $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $true

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
    }

    It "Should warn on space below threshold" {
        
        Mock -CommandName Get-WmiObject -MockWith {
            return [ServerMemoryMock]::new('Server1', 8312456, 2837196)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem -FreeMemoryThreshold 99
                    }

        $actual = Test-Memory $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues.Highlight | Should Be 'FreeMemory'
    }
}