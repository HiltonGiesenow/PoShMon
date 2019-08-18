$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Get-SPTestsToAutoIgnore-OldVersion" {
    InModuleScope PoShMon {

        Mock -CommandName Get-SPFarmMajorVersion -ModuleName PoShMon -Verifiable -MockWith {
            return 15 #2013
        }

        It "Should NOT ignore SPUPSSyncHealth for older (<=2013) Versions" {

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $poShMonConfiguration.General.TestsToSkip = @()

            $actual = Get-SPTestsToAutoIgnore $poShMonConfiguration
        
            Assert-VerifiableMock

            $poShMonConfiguration.General.TestsToSkip.Count | Should Be 0
        }
    }
}

Describe "Get-SPTestsToAutoIgnore-NewVersion" {
    InModuleScope PoShMon {

        Mock -CommandName Get-SPFarmMajorVersion -ModuleName PoShMon -Verifiable -MockWith {
            return 16 #2016
        }
        
        It "Should ignore SPUPSSyncHealth for newer (>2013) Versions" {

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $poShMonConfiguration.General.TestsToSkip = @()

            $actual = Get-SPTestsToAutoIgnore $poShMonConfiguration
        
            Assert-VerifiableMock

            $poShMonConfiguration.General.TestsToSkip.Count | Should Be 1
            $poShMonConfiguration.General.TestsToSkip[0] | Should Be "SPUPSSyncHealth"
        }
    }
}
