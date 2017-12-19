$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-EmailFooter" {
    InModuleScope PoShMon {

        class ModuleMock {
            [string]$Version
        
            ModuleMock ([string]$NewVersion) {
                $this.Version = $NewVersion;
            }
        }

        It "Should Show the Skipped Tests" {

            Mock -CommandName Get-Module -MockWith {
                return [ModuleMock]::new("1.2.3")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        New-GeneralConfig `
                                            -ServerNames 'Foo' `
                                            -SkipVersionUpdateCheck `
                                            -TestsToSkip 'ABC','DEF'
                                    }

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            $actual = New-EmailFooter $poShMonConfiguration $totalElapsedTime

            $actual.IndexOf("<b>Skipped Tests:</b> ABC, DEF") -gt 0 | Should Be $true
        }

        It "Should Show 'None' for non-skipped tests" {

            Mock -CommandName Get-Module -MockWith {
                return [ModuleMock]::new("1.2.3")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        New-GeneralConfig `
                                            -ServerNames 'Foo' `
                                            -SkipVersionUpdateCheck
                                    }

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            $actual = New-EmailFooter $poShMonConfiguration $totalElapsedTime

            #Write-Host $actual

            $actual.IndexOf("<b>Skipped Tests:</b> None") -gt 0 | Should Be $true
        }

        It "Should Show 'None' for non-skipped tests as empty array" {

            Mock -CommandName Get-Module -MockWith {
                return [ModuleMock]::new("1.2.3")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        New-GeneralConfig `
                                            -ServerNames 'Foo' `
                                            -SkipVersionUpdateCheck `
                                            -TestsToSkip @()
                                    }

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            $actual = New-EmailFooter $poShMonConfiguration $totalElapsedTime

            $actual.IndexOf("<b>Skipped Tests:</b> None") -gt 0 | Should Be $true
        }

        It "Should Show 'None' for non-skipped tests as empty item" -Skip { #this is now handled higher up in the stack

            Mock -CommandName Get-Module -MockWith {
                return [ModuleMock]::new("1.2.3")
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                                        New-GeneralConfig `
                                            -ServerNames 'Foo' `
                                            -SkipVersionUpdateCheck `
                                            -TestsToSkip ''
                                    }

            $totalElapsedTime = (Get-Date).Subtract((Get-Date).AddMinutes(-3))

            $actual = New-EmailFooter $poShMonConfiguration $totalElapsedTime

            $actual.IndexOf("<b>Skipped Tests:</b> None") -gt 0 | Should Be $true
        }
    }
}