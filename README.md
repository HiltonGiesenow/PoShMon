# PoShMon
PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an "agent-less" monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run the script from a regular workstation and have it monitor a single server or group of servers. PoShMon is also able to monitor "farm"-based products like SharePoint, in which multiple servers work together to provide a single platform. In this case, instead of a list of servers, you need only to supply PoShMon with details of a "primary" server against which you want to monitor the platform and it will use, in this case, SharePoint's API to determine the remaining servers.

## Installation Instructions
PoShMon is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PoShMon) so you can either download it from this GitHub page or even install it directly from the gallery onto your local workstation using

`PS> Install-Module -Name PoShMon`

or via [Azure Automation](https://www.powershellgallery.com/packages/PoShMon)

## Getting Started
Once you've installed PoShMon, you can have a look at the [Samples](https://github.com/HiltonGiesenow/PoShMon/tree/master/src/0.4.0/Samples) folder to get an idea how to use it. As an example, to monitor a SharePoint farm you can use

```
$poShMonConfiguration = New-PoShMonConfiguration {
                General `
                    -EnvironmentName 'Intranet Farm' `
                    -MinutesToScanHistory 15 `
                    -ServerNames 'WebServer1','WebServer2' `
                OperatingSystem `
                    -EventLogCodes 'Critical'
                WebSite `
                    -WebsiteDetails @{ 
                                        "http://intranet" = "Read our terms"
                                     }
                Notifications -When OnlyOnFailure {
                    Email `
                        -ToAddress "IntranetTeam@Company.com" `
                        -FromAddress "Monitoring@company.com" `
                        -SmtpServer "EXCHANGE.COMPANY.COM" `
                }
                
            }

$monitoringOutput = Invoke-OSMonitoring -PoShMonConfiguration $poShMonConfiguration
```

Some things to note on the above:

* The actual "monitoring" takes place on the last line with [`Invoke-OSMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.OSMonitoring/Invoke-OSMonitoring.ps1). The lines above are just setting up your specific configuration.
* To make the config a little more readable, I've put each parameter on a new line (note the '`' PowerShell line-continuation character). This is not required, or course, so your configuration could be shorter

```

Here's another example, to monitor a SharePoint farm

$poShMonConfiguration = New-PoShMonConfiguration {
                General `
                    -EnvironmentName 'SharePoint' `
                    -MinutesToScanHistory 1440 `
                    -PrimaryServerName 'SPAPPSVR01' `
                    -ConfigurationName SpFarmPosh `
                    -TestsToSkip "SPDatabaseHealth"
                OperatingSystem `
                    -EventLogCodes 'Error','Warning'
                WebSite `
                    -WebsiteDetails @{ 
                                        "http://intranet" = "Read our terms"
                                        "http://extranet.company.com" = "Read our terms"
                                     }
                Notifications -When All {
                    Email `
                        -ToAddress "SharePointTeam@Company.com" `
                        -FromAddress "Monitoring@company.com" `
                        -SmtpServer "EXCHANGE.COMPANY.COM" `
                }
                
            }

$monitoringOutput = Invoke-SPMonitoring -PoShMonConfiguration $poShMonConfiguration
```

* Note the use of 'PrimaryServerName' instead of 'ServerNames' as well as the use of [`Invoke-SPMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.SharePoint/Invoke-SPMonitoring.ps1) instead of [`Invoke-OSMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.OSMonitoring/Invoke-OSMonitoring.ps1). "EnvironmentName" is also changed to something more suitable for things like notifications (emails etc.)
* We've also changed 'MinutesToScanHistory' to 1440 instead of 15, so this is more of a daily monitoring example. We've also got `Notifications -When All` instead of `Notifications -When OnlyOnFailure` because we want notifications (emails or similar) in all cases for daily monitoring, unlike for Critical monitoring where we only want to be alerted of major issues. This is also why the EventLogCodes have been changed
* storing the output of the monitoring ($monitoringOutput) is not required, of course, but it's helpful if you want to do anything with it, like try automatically correct regular issues in your environment...