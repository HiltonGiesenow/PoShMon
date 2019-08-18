Import-Module "C:\Development\GitHub\PoShMon\PoShMon\src\PoShMon.psd1" -Verbose -Force #This is only necessary if you haven't installed the module into your Modules folder, e.g. via PowerShellGallery / Install-Module

#Alternatively, use the lines below
#If (!(Get-module PoShMon))
#    { Import-Module PoShMon }

$VerbosePreference = 'Continue'

$poShMonConfiguration = New-PoShMonConfiguration {
                General `
                    -EnvironmentName 'SharePoint' `
                    -MinutesToScanHistory 1440 `
                    -PrimaryServerName 'SPAPPSVR01' `
                    -ConfigurationName SpFarmPosh `
                    -TestsToSkip ""
                OperatingSystem `
                    -EventLogCodes "Error","Warning"
                WebSite `
                    -WebsiteDetails @{ 
                                        "http://intranet" = "Read our terms"
                                        "http://extranet.company.com" = "Read our terms"
                                     }
                Notifications -When OnlyOnFailure {
                    Email `
                        -ToAddress "SharePointTeam@Company.com" `
                        -FromAddress "Monitoring@company.com" `
                        -SmtpServer "EXCHANGE.COMPANY.COM" `
                }
                
            }

$monitoringOutput = Invoke-SPMonitoring -PoShMonConfiguration $poShMonConfiguration

$poShMonConfiguration.General.PrimaryServerName = 'OWASVR01'
$poShMonConfiguration.General.ServerNames = $null # this needs to be reset
$poShMonConfiguration.General.EnvironmentName = 'Office Web Apps'
$poShMonConfiguration.General.ConfigurationName = $null
$poShMonConfiguration.WebSite = $null

$monitoringOutput = Invoke-OOSMonitoring -PoShMonConfiguration $poShMonConfiguration

#Remove-Module PoShMon