$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPSearchHealth" {
    InModuleScope PoShMon {

        class SearchItemsMock {
            [object[]]$SearchComponentStates
            [object[]]$ComponentTopology

            SearchItemsMock () {
            }

            AddComponentWithState([string]$name, [string]$serverName, [string]$state) {
                $this.SearchComponentStates += [PSCustomObject]@{ Name = $name; State = $state }
                $this.ComponentTopology += [PSCustomObject]@{ Name = $name; ServerName = $serverName}

            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "Active")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPSearchHealth $poShMonConfiguration

            $headerKeyCount = 3

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("HeaderUrl") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[1].ServerName | Should Be 'Server1'
            $actual.OutputValues[1].ComponentName | Should Be 'Component2'
            $actual.OutputValues[1].State | Should Be 'Active'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be ($headerKeyCount + 1)
            #$values1.ContainsKey("ComponentName") | Should Be $true
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("State") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "Active")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPSearchHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPSearchHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 5
            $output[0].ToString() | Should Be "Getting Search Service App..."
            $output[1].ToString() | Should Be "Initiating 'Search Status' Test..."
            $output[2].ToString() | Should Be "`tComponent1 is in the following state: Active"
            $output[3].ToString() | Should Be "`tComponent2 is in the following state: Active"
            $output[4].ToString() | Should Be "Complete 'Search Status' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "InActive")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $actual = Test-SPSearchHealth $poShMonConfiguration
            $output = $($actual = Test-SPSearchHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString() | Should Be "`tComponent2 is not listed as 'Active'. State: InActive"
        }

        It "Should return an output for each component" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component3", "Server2", "Active")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPSearchHealth $poShMonConfiguration

            $actual.OutputValues.Count | Should Be 3
        }

        It "Should not warn on all Active components" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "Active")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPSearchHealth $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true

            $actual.OutputValues.Highlight.Count | Should Be 0
        }

        It "Should warn on at least one InActive components" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                $searchItemsMock = [SearchItemsMock]::new()
            
                $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
                $searchItemsMock.AddComponentWithState("Component2", "Server1", "InActive")

                return $searchItemsMock
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPSearchHealth $poShMonConfiguration -WarningAction SilentlyContinue

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight.Count | Should Be 1
            $actual.OutputValues[1].Highlight[0] | Should Be 'State'

        }
    }
}