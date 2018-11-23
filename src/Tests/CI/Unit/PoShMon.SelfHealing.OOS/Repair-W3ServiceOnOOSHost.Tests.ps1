$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Repair-W3ServiceOnOOSHost" {

    InModuleScope "PoShMon" {

        It "Should invoke the repair" {

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $monitoringOutput = @()

            Mock -CommandName Start-ServicesOnServers -ModuleName PoShMon -Verifiable -MockWith {
                return @{
                    "SectionHeader" = "Mock SectionHeader"
                    "RepairResult" = "Mock RepairResult"
                }
            }

            try { throw "There was no endpoint listening at something/farmstatemanager/FarmStateManager.svc that could accept the message" } catch {}

            $actual = Repair-W3ServiceOnOOSHost $poShMonConfiguration $monitoringOutput -Verbose

            $actual.Keys.Count | Should Be 2
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("RepairResult") | Should Be $true
            $actual.SectionHeader | Should Be "Mock SectionHeader"
            $actual.RepairResult | Should Be "Mock RepairResult"

            Assert-VerifiableMock
        }
    }
}

Describe "Repair-W3ServiceOnOOSHost-Scope2" {

    InModuleScope "PoShMon" {

        It "Should NOT invoke the repair for the wrong exception" {

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $monitoringOutput = @()

            Mock -CommandName Start-ServicesOnServers -ModuleName PoShMon -Verifiable -MockWith {
                return @{
                    "SectionHeader" = "Mock SectionHeader"
                    "RepairResult" = "Mock RepairResult"
                }
            }

            try { throw "Something else" } catch {}

            $actual = Repair-W3ServiceOnOOSHost $poShMonConfiguration $monitoringOutput -Verbose

            $actual.Keys.Count | Should Be 0

            Assert-MockCalled -CommandName Start-ServicesOnServers -ModuleName PoShMon -Times 0
        }
    }
}
