$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Repair-OOSFarm" {

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

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
            }

            try { throw "There was no endpoint listening at something/farmstatemanager/FarmStateManager.svc that could accept the message" } catch {}

            $actual = Repair-OOSFarm $poShMonConfiguration $monitoringOutput -Verbose

            $actual.Keys.Count | Should Be 2
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("RepairResult") | Should Be $true
            $actual.SectionHeader | Should Be "Mock SectionHeader"
            $actual.RepairResult | Should Be "Mock RepairResult"

            Assert-VerifiableMock
        }
    }
}

Describe "Repair-OOSFarm-Scope2" {

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

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
            }

            try { throw "Something else" } catch {}

            $actual = Repair-OOSFarm $poShMonConfiguration $monitoringOutput -Verbose

            $actual.Keys.Count | Should Be 0

            Assert-MockCalled -CommandName Start-ServicesOnServers -ModuleName PoShMon -Times 0
        }
    }
}

Describe "Repair-OOSFarm-Scope3" {

    InModuleScope "PoShMon" {
        It "Should NOT invoke the repair for the no exceptions having occurred" {

            $poShMonConfiguration = New-PoShMonConfiguration {}

            $monitoringOutput = @()

            Mock -CommandName Start-ServicesOnServers -ModuleName PoShMon -Verifiable -MockWith {
                return @{
                    "SectionHeader" = "Mock SectionHeader"
                    "RepairResult" = "Mock RepairResult"
                }
            }

            Mock -CommandName Initialize-RepairNotifications -ModuleName PoShMon -Verifiable -MockWith {
            }

            $actual = Repair-OOSFarm $poShMonConfiguration $monitoringOutput -Verbose

            $actual.Keys.Count | Should Be 0

            Assert-MockCalled -CommandName Start-ServicesOnServers -ModuleName PoShMon -Times 0
        }
    }
}
