$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$harnessScript = (Join-Path $rootPath -ChildPath "Tests\Resources\Invoke-OperationValidationFrameworkScan.TestHarness.ps1")

Describe "Invoke-OperationValidationFrameworkTests" {
    InModuleScope PoShMon {

        It "Should pass if no PoShMon failures" {
            
            $testOutput = Invoke-Pester -Script $harnessScript -TestName "Invoke-OperationValidationFrameworkScan-Clear" -PassThru -Show None            

            $testOutput.PassedCount | Should Be 11

            ($testOutput.TestResult | Where Describe -eq "Grouped Test" | Where Result -eq "Passed").Count | Should Be 5
            ($testOutput.TestResult | Where Describe -eq "Ungrouped Test" | Where Result -eq "Passed").Count | Should Be 5

        }

        It "Should fail any PoShMon failures" {

            $testOutput = Invoke-Pester -Script $harnessScript -TestName "Invoke-OperationValidationFrameworkScan-FailureSet" -PassThru -Show None            

            $testOutput.PassedCount | Should Be 7
            $testOutput.FailedCount | Should Be 3

            ($testOutput.TestResult | Where Describe -eq "Grouped Test" | Where Result -eq "Passed").Count | Should Be 5
            ($testOutput.TestResult | Where Describe -eq "Ungrouped Test" | Where Result -eq "Failed").Count | Should Be 3

        }
    }
}