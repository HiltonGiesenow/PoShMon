$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

class SPFarmMock {
    [string]$Name
    [string]$BuildVersion
    [string]$Status
    [bool]$NeedsUpgrade

    SPFarmMock ([string]$NewName, [string]$NewBuildVersion, [string]$NewStatus, [bool]$NewNeedsUpgrade) {
        $this.Name = $NewName;
        $this.BuildVersion = $NewBuildVersion;
        $this.Status = $NewStatus;
        $this.NeedsUpgrade = $NewNeedsUpgrade;
    }
}
<#
Can't get these to run on my workstation - PoSh Remoting issues on this machine that I don't want to deal with now
Describe "Test-FarmHealth" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Invoke-Command -MockWith {
            return [SPFarmMock]::new("SP_Config", "1.2.3", "Online", $false)
        }

        $actual = Test-FarmHealth $null

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be 2
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be 3
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("CPULoad") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should not warn on CPU below threshold" {

        Mock -CommandName Get-Counter -MockWith {
            $sample1 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 12.345)
            $sample2 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 56.789)
            $samples = @($sample1, $sample2)
            $timestamp = Get-Date
            return [CounterResultsMock]::new($timestamp, $samples)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-CPULoad $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $true

        $actual.OutputValues.GroupOutputValues.Highlight.Count | Should Be 0
    }

    It "Should warn on CPU above threshold" {
        
        Mock -CommandName Get-Counter -MockWith {
            $sample1 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 12.345)
            $sample2 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 97.789)
            $samples = @($sample1, $sample2)
            $timestamp = Get-Date
            return [CounterResultsMock]::new($timestamp, $samples)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem
                    }

        $actual = Test-CPULoad $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues.Highlight | Should Be 'CPULoad'
    }
    It "Should use the configuration threshold properly" {
        
        Mock -CommandName Get-Counter -MockWith {
            $sample1 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 12.345)
            $sample2 = [CounterSampleMock]::new("\\Server1\\processor(_total)\% processor time", 57.789)
            $samples = @($sample1, $sample2)
            $timestamp = Get-Date
            return [CounterResultsMock]::new($timestamp, $samples)
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General -ServerNames 'localhost'
                        OperatingSystem -CPULoadThresholdPercent 50
                    }

        $actual = Test-CPULoad $poShMonConfiguration
        
        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues.Highlight | Should Be 'CPULoad'
    }
}
#>