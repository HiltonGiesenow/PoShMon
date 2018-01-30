$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

#. (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")
#. (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")

Describe "Repair-Environment" {
    It "Should send notifications of repairs" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'Core' `
                            -PrimaryServerName 'Svr1'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $monitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "AMonitoringTest"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "Component" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "Component" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $RepairScripts = @(
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")        
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon] Core Repair Results (1 Repairs(s) Performed)"
            $Body | Should Be '<head><title>Core Repairs Report</title></head><body><h1>Core Repairs Report</h1><p><h1>Mock Repair</h1><table border="1"><tbody><tr><td>Some repair message</td></tr></tbody></table></body>'

            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Mock Repair : Repair performed`r`n"

            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Mock Repair : Repair performed`r`n"

            return
        }

        $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

        Assert-VerifiableMocks
    }

    It "Should send notifications of exceptions in repairs" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'Core' `
                            -PrimaryServerName 'Svr1'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $monitoringOutput = [System.Collections.ArrayList]@(
            @{
                "SectionHeader" = "AMonitoringTest"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "Component" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "Component" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $RepairScripts = @(
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Failing-Repair.ps1")        
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon] Core Repair Results (1 Repairs(s) Performed)"
            $Body | Should Be '<head><title>Core Repairs Report</title></head><body><h1>Core Repairs Report</h1><p><h1>Failing-Repair</h1><table border="1"><tbody><tr><td>An Exception Occurred</td></tr><tr><td>System.Management.Automation.RuntimeException: Something</td></tr></tbody></table></body>'

            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Failing-Repair : (Exception occurred)`r`n"

            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Failing-Repair : (Exception occurred)`r`n"

            return
        }

        $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

        Assert-VerifiableMocks
    }

    It "Should send notifications of each repair performed" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'Core' `
                            -PrimaryServerName 'Svr1'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $monitoringOutput = @(
            @{
                "SectionHeader" = "AMonitoringTest"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "Component" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "Component" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $RepairScripts = @(
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair.ps1")        
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")        
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon] Core Repair Results (2 Repairs(s) Performed)"
            $Body | Should Be '<head><title>Core Repairs Report</title></head><body><h1>Core Repairs Report</h1><p><h1>Mock Repair</h1><table border="1"><tbody><tr><td>Some repair message</td></tr></tbody></table><p><h1>Another Mock Repair</h1><table border="1"><tbody><tr><td>Another repair message</td></tr></tbody></table></body>'

            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Mock Repair : Repair performed`r`nAnother Mock Repair : Repair performed`r`n"

            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Mock Repair : Repair performed`r`nAnother Mock Repair : Repair performed`r`n"

            return
        }

        $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

        Assert-VerifiableMocks
    }

    It "Should send notifications of exceptions in repairs as well as successful repairs" {

        $poShMonConfiguration = New-PoShMonConfiguration {
                        General `
                            -EnvironmentName 'Core' `
                            -PrimaryServerName 'Svr1'
                        Notifications -When All {
                            Email -ToAddress "someone@email.com" -FromAddress "all@jones.com" -SmtpServer "smtp.company.com"
                            Pushbullet -AccessToken "TestAccessToken" -DeviceId "TestDeviceID"
                            O365Teams -TeamsWebHookUrl "http://teams.office.com/theapi"
                        }               
                    }

        $monitoringOutput = @(
            @{
                "SectionHeader" = "AMonitoringTest"
                "OutputHeaders" = @{ 'ComponentName' = 'Component'; 'State' = 'State' }
                "NoIssuesFound" = $false
                "ElapsedTime" = (Get-Date).Subtract((Get-Date).AddMinutes(-1))
                "OutputValues" = @(
                                    @{
                                        "Component" = 123
                                        "State" = "State 1"
                                    },
                                    @{
                                        "Component" = 456
                                        "State" = "State 2"
                                    }
                                )
            }
        )

        $RepairScripts = @(
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Failing-Repair.ps1")        
                            (Join-Path $rootPath -ChildPath "Tests\CI\Integration\PoShMon.SelfHealing.Core\Dummy-Repair2.ps1")        
        )

        Mock -CommandName Send-PoShMonEmail -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon] Core Repair Results (2 Repairs(s) Performed)"
            $Body | Should Be '<head><title>Core Repairs Report</title></head><body><h1>Core Repairs Report</h1><p><h1>Failing-Repair</h1><table border="1"><tbody><tr><td>An Exception Occurred</td></tr><tr><td>System.Management.Automation.RuntimeException: something</td></tr></tbody></table><p><h1>Another Mock Repair</h1><table border="1"><tbody><tr><td>Another repair message</td></tr></tbody></table></body>'

            return
        }
        Mock -CommandName Send-PushbulletMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Failing-Repair : (Exception occurred)`r`nAnother Mock Repair : Repair performed`r`n"

            return
        }
        Mock -CommandName Send-O365TeamsMessage -ModuleName PoShMon -Verifiable -MockWith {
            Write-Verbose $Subject
            Write-Verbose $Body

            $Subject | Should Be "[PoshMon Core Repair Results]`r`n"
            $Body | Should Be "Failing-Repair : (Exception occurred)`r`nAnother Mock Repair : Repair performed`r`n"

            return
        }

        $actual = Repair-Environment $poShMonConfiguration $monitoringOutput $RepairScripts -Verbose

        Assert-VerifiableMocks
    }
}
