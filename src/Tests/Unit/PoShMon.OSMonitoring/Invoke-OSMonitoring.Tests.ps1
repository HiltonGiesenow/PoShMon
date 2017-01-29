$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Invoke-OSMonitoring" {
    It "Should work with a minimal configuration" {

        $poShMonConfiguration = New-PoShMonConfiguration {}
        
        Mock -CommandName Invoke-Tests -ModuleName PoShMon -Verifiable -MockWith {
            Begin
            {
                $outputValues = @()
            }

            Process
            {
                foreach ($test in $TestToRuns)
                {
                    $outputValues += @{
                                    "SectionHeader" = "Mock Test: $test"
                                    "OutputHeaders" = @{ 'Item1' = 'Item 1'; }
                                    "NoIssuesFound" = $false
                                    "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                                    "OutputValues" = @(
                                                        @{
                                                            "Item1" = 123
                                                            "State" = "State 1"
                                                        }
                                                    )
                                }
                }
            }
    
            End
            {
                return $outputValues
            }
        }
        Mock -CommandName Initialize-Notifications -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose "Tests Run:"
            $TestOutputValues | % { Write-Verbose "`t$($_.SectionHeader)" }
            return
        }
        
        $actual = Invoke-OSMonitoring $poShMonConfiguration -Verbose

        Assert-VerifiableMocks
    }
}
