$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

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

Describe "Test-SearchHealth" {
    It "Should return a matching output structure" {
    
        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
            $searchItemsMock = [SearchItemsMock]::new()
            
            $searchItemsMock.AddComponentWithState("Component1", "Server1", "Active")
            $searchItemsMock.AddComponentWithState("Component2", "Server1", "Active")

            return $searchItemsMock
        }

        $poShMonConfiguration = New-PoShMonConfiguration {}   

        $actual = Test-SearchHealth $poShMonConfiguration

        $headerKeyCount = 3

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
        $values1.ContainsKey("ComponentName") | Should Be $true
        $values1.ContainsKey("ServerName") | Should Be $true
        $values1.ContainsKey("State") | Should Be $true
        $values1.ContainsKey("Highlight") | Should Be $true
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

        $actual = Test-SearchHealth $poShMonConfiguration

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

        $actual = Test-SearchHealth $poShMonConfiguration

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

        $actual = Test-SearchHealth $poShMonConfiguration

        $actual.NoIssuesFound | Should Be $false

        $actual.OutputValues.Highlight.Count | Should Be 1
        $actual.OutputValues[1].Highlight.Count | Should Be 1
        $actual.OutputValues[1].Highlight[0] | Should Be 'State'

    }
}