

Remove-Module PoShMon

Import-Module C:\Dev\GitHub\PoShMon\src\0.3.0\PoShMon.psd1 -Verbose

#Test-ModuleManifest C:\Development\GitHub\PoShMon\PoShMon\src\0.3.0\PoShMon.psd1

#Get-Command -Module PoShMon

$poShMonConfiguration = New-PoShMonConfiguration {
                General `
                    -EnvironmentName 'SharePoint' `
                    -MinutesToScanHistory 15 `
                    -TestsToSkip 'ABC' `
                    -ServerNames 'svr1','svr2'
                OperatingSystem `
                    -EventLogCodes 'Critical' `
                    -WindowsServices 'Foo'
                WebSite `
                    -WebsiteDetails @{ 
                                        "http://mgportal" = "Read our terms"
                                        "http://clientportal.maitlandgroup.com" = "Read our terms"
                                     }
                Notifications -When All {
                    Email -ToAddress "hilton@giesenow.com" -FromAddress "bob@jones.com" -SmtpServer "smtp.company.com"
                }
                Notifications -When OnlyOnFailure {
                    Email `
                        -ToAddress "hilton@giesenow.com" `
                        -FromAddress "bob@jones.com" `
                        -SmtpServer "smtp.company.com" `
                        -Port 27
                }
                
            }
