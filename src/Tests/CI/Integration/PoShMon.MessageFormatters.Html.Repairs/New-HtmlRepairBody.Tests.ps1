$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "New-HtmlRepairBody" {
    InModuleScope PoShMon {

    Mock -CommandName Get-Module -Verifiable -MockWith {
        return @(
                    [pscustomobject]@{
                        Version = "1.2.3"
                    }
                )
    }

    Mock -CommandName Get-PlatformVersion -ModuleName PoShMon -Verifiable -MockWith {
        return @(
                    [pscustomobject]@{
                        Major = "16"
                        Minor = "0"
                        Build = "1234"
                        Revision = "1000"
                    }
        )
    }

    It "Should return a the correct html for given repair output" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'Office Web Apps' `
                                -PrimaryServerName 'Server1' `
                                -SkipVersionUpdateCheck `
                        }

            $repairOutputValues = @{
                                    "SectionHeader" = "Mock SectionHeader"
                                    "RepairResult" = "Mock RepairResult"
                                }


            $currentVersion = (Get-Module PoShmon).Version.ToString()
            $expected = '<head><title></title></head><body style="font-family: verdana; font-size: 12px;"><table width="100%" style="border-collapse: collapse; "><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; Padding: 20px;"><h1>PoShMon Repairs Report</h1></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 10px; padding-left: 20px">Office Web Apps Environment</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: lightgray; padding-top: 20px;"><div style="width:100%; background-color: #FFFFFF;"><table style="border-collapse: collapse; min-width: 500px; " cellpadding="3"><thead><tr><th align=left style="border: 1px solid CCCCCC; background-color: #1D6097;"><h2 style="font-size: 16px; color: #FFFFFF">Mock SectionHeader</h2></th></tr></thead><tbody><tr><td>Mock RepairResult</td></tr></tbody></table></div><br/></td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #000000; color: #FFFFFF; padding: 20px"><b>Skipped Tests:</b> None</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td style="background-color: lightgray">&nbsp;</td><td style="background-color: #1D6097; color: #FFFFFF; padding: 20px" align="center">PoShMon Version ' + $currentVersion + ' (version check skipped)</td><td style="background-color: lightgray">&nbsp;</td></tr><tr><td colspan="3" style="background-color: lightgray">&nbsp;</td></tr></table><br/></body>'

            $actual = New-HtmlRepairBody $poShMonConfiguration $repairOutputValues

            $actual | Should Be $expected
        }
    }
}