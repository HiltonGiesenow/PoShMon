Import-Module "C:\Development\GitHub\PoShMon\PoShMon\src\PoShMon.psd1" -Verbose -Force #This is only necessary if you haven't installed the module into your Modules folder, e.g. via PowerShellGallery / Install-Module

#Alternatively, use the lines below
#If (!(Get-module PoShMon))
#    { Import-Module PoShMon }

$VerbosePreference = 'Continue'

$poShMonConfiguration = New-PoShMonConfiguration {
                New-GeneralConfig `
                    -EnvironmentName 'SharePoint' `
                    -MinutesToScanHistory 1440 `
                    -PrimaryServerName 'SPAPPSVR01' `
                    -ConfigurationName SpFarmPosh `
                    -TestsToSkip ""
                New-OSConfig `
                    -EventLogCodes "Error","Warning"
                New-WebSiteConfig `
                    -WebsiteDetails @{ 
                                        "http://intranet" = "Read our terms"
                                        "http://extranet.company.com" = "Read our terms"
                                     }
                New-NotificationsConfig -When OnlyOnFailure {
                    New-EmailConfig `
                        -ToAddress "SharePointTeam@Company.com" `
                        -FromAddress "Monitoring@company.com" `
                        -SmtpServer "EXCHANGE.COMPANY.COM" `
                }
                
            }

$monitoringOutput = Invoke-SPMonitoring -PoShMonConfiguration $poShMonConfiguration

$poShMonConfiguration.General.PrimaryServerName = ''
$poShMonConfiguration.General.ServerNames = 'OWASVR01'
$poShMonConfiguration.General.EnvironmentName = 'Office Web Apps'
$poShMonConfiguration.General.ConfigurationName = $null
$poShMonConfiguration.WebSite = $null

$monitoringOutput = Invoke-OSMonitoring -PoShMonConfiguration $poShMonConfiguration

#Remove-Module PoShMon