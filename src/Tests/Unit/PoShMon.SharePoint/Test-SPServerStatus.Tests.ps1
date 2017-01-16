$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

class SPServerMock {
    [string]$DisplayName
    [string]$Status
    [bool]$NeedsUpgrade
    [string]$Role

    SPServerMock ([string]$NewDisplayName, [string]$NewStatus, [bool]$NewNeedsUpgrade, [string]$NewRole) {
        $this.DisplayName = $NewDisplayName
        $this.Status = $NewStatus
        $this.NeedsUpgrade = $NewNeedsUpgrade
        $this.Role = $NewRole
    }
}

Describe "Test-SPServerStatus" {
    It "Should return a matching output structure" {

        Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {
            return [SPServerMock]::new($ServerName, 'Online', $false, 'Application')
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1','Server2'
                                }   

        $actual = Test-SPServerStatus $poShMonConfiguration

        $headerKeyCount = 4

        $actual.Keys.Count | Should Be 5
        $actual.ContainsKey("NoIssuesFound") | Should Be $true
        $actual.ContainsKey("OutputHeaders") | Should Be $true
        $actual.ContainsKey("OutputValues") | Should Be $true
        $actual.ContainsKey("SectionHeader") | Should Be $true
        $actual.ContainsKey("ElapsedTime") | Should Be $true
        $headers = $actual.OutputHeaders
        $headers.Keys.Count | Should Be $headerKeyCount
        $values1 = $actual.OutputValues[0]
        $values1.Keys.Count | Should Be ($headerKeyCount + 1)
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("Role") | Should Be $true
        $values1.ContainsKey("NeedsUpgrade") | Should Be $true
        $values1.ContainsKey("Status") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
    }

    It "Should return an output for each Server" {
    
        Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {
            return [SPServerMock]::new($ServerName, 'Online', $false, 'Application')
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1','Server2'
                                }   

        $actual = Test-SPServerStatus $poShMonConfiguration

        $actual.OutputValues.Count | Should Be 2
    }

    It "Should not warn on any component needing upgrade" {
    
        Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

            $needsUpgrade = if ($ServerName -eq 'Server1') { $false } else { $true }
            
            return [SPServerMock]::new($ServerName, 'Online', $needsUpgrade, 'Application')
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1','Server2'
                                }

        $actual = Test-SPServerStatus $poShMonConfiguration

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[1].Highlight.Count | Should Be 1
        $actual.OutputValues[1].Highlight[0] | Should Be 'NeedsUpgrade'
    }

   It "Should not warn on any component not being Online" {
    
        Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

            $status = if ($ServerName -eq 'Server1') { 'Online' } else { 'Something Else' }
            
            return [SPServerMock]::new($ServerName, $status, $false, 'TheRole')
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1','Server2'
                                }

        $actual = Test-SPServerStatus $poShMonConfiguration

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[1].Highlight.Count | Should Be 1
        $actual.OutputValues[1].Highlight[0] | Should Be 'Status'
    }

   It "Should not warn on any component not being Online and needing upgrade" {
    
        Mock -CommandName Get-SPServerForRemoteServer -ModuleName PoShMon -MockWith {

            $status = if ($ServerName -eq 'Server1') { 'Online' } else { 'Something Else' }
            $needsUpgrade = if ($ServerName -eq 'Server1') { $false } else { $true }
            
            return [SPServerMock]::new($ServerName, $status, $needsUpgrade, 'TheRole')
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                                    General -ServerNames 'Server1','Server2'
                                }

        $actual = Test-SPServerStatus $poShMonConfiguration

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 2
        $actual.OutputValues[0].Highlight.Count | Should Be 0
        $actual.OutputValues[1].Highlight.Count | Should Be 2
        $actual.OutputValues[1].Highlight[0] | Should Be 'NeedsUpgrade'
        $actual.OutputValues[1].Highlight[1] | Should Be 'Status'
    }
}