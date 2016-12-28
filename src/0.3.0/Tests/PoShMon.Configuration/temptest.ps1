

Remove-Module PoShMon

Import-Module C:\Development\GitHub\PoShMon\PoShMon\src\0.3.0\PoShMon.psd1 -Verbose

#Test-ModuleManifest C:\Development\GitHub\PoShMon\PoShMon\src\0.3.0\PoShMon.psd1

#Get-Command -Module PoShMon

$options = New-PoShMonConfiguration {
                General `
                    -TestsToSkip 'ABC' `
                    -ServerNames 'svr1','svr2'
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


