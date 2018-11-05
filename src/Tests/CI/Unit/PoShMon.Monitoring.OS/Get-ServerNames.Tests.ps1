$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Get-ServerNames" {
    InModuleScope PoShMon {
        It "Should return the servers" {

            Function Get-ServersMock() {
                return @("Server1", "Server2")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $FarmDiscoveryFunctionName = "Get-ServersMock"

            $actual = Get-ServerNames $poShMonConfiguration $FarmDiscoveryFunctionName -Verbose

            $actual.Count | Should Be 2
            $actual[0]  | Should Be "Server1"
            $actual[1]  | Should Be "Server2"
        }

        It "Should return a single server correctly" {

            Function Get-ServersMock() {
                return @("Server1")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $FarmDiscoveryFunctionName = "Get-ServersMock"

            $actual = Get-ServerNames $poShMonConfiguration $FarmDiscoveryFunctionName -Verbose

            $actual.Count | Should Be 1
            $actual  | Should Be "Server1"
        }

        It "Should return a single server correctly (no array)" {

            Function Get-ServersMock() {
                return "Server1"
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $FarmDiscoveryFunctionName = "Get-ServersMock"

            $actual = Get-ServerNames $poShMonConfiguration $FarmDiscoveryFunctionName -Verbose

            $actual.Count | Should Be 1
            $actual  | Should Be "Server1"
        }

        It "Should write the expected Verbose output" {
            Function Get-ServersMock() {
                return @("Server1", "Server2")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}
            $FarmDiscoveryFunctionName = "Get-ServersMock"

            $actual = Get-ServerNames $poShMonConfiguration $FarmDiscoveryFunctionName -Verbose

            $output = $(Get-ServerNames $poShMonConfiguration $FarmDiscoveryFunctionName -Verbose) 4>&1

            $output.Count | Should Be 3
            $output[0].ToString() | Should Be "Found the following server(s): Server1, Server2"
            $output[1].ToString() | Should Be "Server1"
            $output[2].ToString() | Should Be "Server2"
        }
    }
}
