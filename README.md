# PoShMon
PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an "agent-less" monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run or schedule the script from a regular workstation and have it monitor a single server or group of servers, using PowerShell remoting. PoShMon is also able to monitor "farm"-based products like SharePoint, in which multiple servers work together to provide a single platform. For details on why I built PoShMon, see the bottom of this page.

## Key Features
Some of the key features / benefits of PoShMon are:
* Agent-less Monitoring - nothing needs to be installed on the remote servers
* Core operating system and web-site monitoring
* Specialized SharePoint monitoring
* Supports frequent/critical as well as comprehensive daily monitoring
* Email, Pushbullet (mobile) and Office 365 Teams ("Chat-ops") notifications
* Provides a framework for a ['self-healing'](https://github.com/HiltonGiesenow/PoShMon/wiki/Creating-a-Self-Healing-System-Using-PoShMon) system

## Installation Instructions
PoShMon is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PoShMon) so you can either download it from this GitHub page or even install it directly from the gallery onto your local workstation using

`PS> Install-Module -Name PoShMon`

## Prerequisites
While PoShMon is indeed "agent-less", it **does need to execute remote PowerShell commands** against the servers in question. As a result, you need to ensure that PowerShell remoting is correctly configured and also that you are running PoShMon under an account that has the correct rights to connect to the server remotely and execute the requisite commands. You also need to make sure you're not going to encounter the classic 'Double Hop' issue. If you're already remotely administering your environment you're probably fine, but have a look at the quick [Prerequisite Guide](https://github.com/HiltonGiesenow/PoShMon/wiki/Prerequisites) to confirm / set up what you need.

## Getting Started
(Below is a quick overview - for more, please visit the more complete [Getting Started Guide](https://github.com/HiltonGiesenow/PoShMon/wiki/Getting-Started-With-PoShMon))
Once you've installed PoShMon, you can have a look at the [Samples](https://github.com/HiltonGiesenow/PoShMon/tree/master/src/0.4.0/Samples) folder to get an idea how to use it. As an example, to monitor a farm of web servers you can use

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
* To make the config a little more readable, I've put each parameter on a new line (note the '`' PowerShell line-continuation character). This is not required, or course, so your configuration could be shorter.

Here's another example, to monitor a SharePoint farm

```
$poShMonConfiguration = New-PoShMonConfiguration {
                General -EnvironmentName 'SharePoint' -MinutesToScanHistory 1440 -PrimaryServerName 'SPAPPSVR01' -ConfigurationName SpFarmPosh -TestsToSkip "SPDatabaseHealth"
                OperatingSystem -EventLogCodes 'Error','Warning'
                WebSite -WebsiteDetails @{ 
                                        "http://intranet" = "Read our terms"
                                        "http://extranet.company.com" = "Read our terms"
                                     }
                Notifications -When All {
                    Email -ToAddress "SharePointTeam@Company.com" -FromAddress "Monitoring@company.com" -SmtpServer "EXCHANGE.COMPANY.COM"
                }
            }

$monitoringOutput = Invoke-SPMonitoring -PoShMonConfiguration $poShMonConfiguration
```

* Note the use of `PrimaryServerName` instead of `ServerNames`. Instead of a list of servers, you need only to supply PoShMon with details of a "primary" server (you can choose any of the SharePoint servers, but typically this is an "application" or "batch" server, on which the main monitoring work will occur) and it will use SharePoint's API to determine the remaining servers.
* Note also the use of [`Invoke-SPMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.SharePoint/Invoke-SPMonitoring.ps1) instead of [`Invoke-OSMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.OSMonitoring/Invoke-OSMonitoring.ps1). "EnvironmentName", which appears in notifications (emails etc.) is also changed to something more suitable.
* 'MinutesToScanHistory' is 1440 instead of 15, so this is more of a daily monitoring example. We've also got `Notifications -When All` instead of `Notifications -When OnlyOnFailure` because we want notifications (emails or similar) in all cases for daily monitoring, unlike for Critical monitoring where we only want to be alerted of major issues. This is also why the EventLogCodes have been changed.
* An important note for monitoring tests where direct access to the servers is required, like in SharePoint where certain commands need to be run remotely: In this case, remote PowerShell sessions are used and, to improve security, PowerShell sessions have been configured to run under appropriate user accounts. You can find out more about the related 'double-hop' issue [here](https://blogs.technet.microsoft.com/ashleymcglone/2016/08/30/powershell-remoting-kerberos-double-hop-solved-securely/) and learn about how to configure remote sessions in this way (instead of using Kerberos or CredSSP) by visiting [this link](https://blogs.msdn.microsoft.com/sergey_babkins_blog/2015/03/18/another-solution-to-multi-hop-powershell-remoting/).
* Storing the output of the monitoring (`$monitoringOutput`) is not required, of course, but it's helpful if you want to do anything with it, like try [automatically correct regular issues in your environment](https://github.com/HiltonGiesenow/PoShMon/wiki/Creating-a-Self-Healing-System-Using-PoShMon).

After that, simply run the script and it will perform an on-demand monitoring of the servers or environments. Of course, you might like to schedule these monitoring tests to run automatically, so see the next section for how to do this.

## Scheduled Monitoring
Ad-hoc monitoring can be useful to troubleshoot specific issues, but mostly we want our monitoring to be automated and scheduled. Because PoShMon simply consists of PowerShell scripts, to have then be scheduled we can rely on simple Windows Task Scheduler, and just set the Tasks to run on a reasonable basis. Here are some [example Task Scheduler](https://github.com/HiltonGiesenow/PoShMon/tree/master/src/0.4.0/Samples/Scheduled%20Task%20Definitions) definitions that can be imported. The first runs "Critical" level monitoring, so it runs every 15 minutes, skips some of the longer-running and less essential tests and notifies only on failure, whereas the latter runs the full barrage of tests on a nightly basis and send a detailed breakdown.

## That's It!
That's all there is to it! Hopefully PoShMon is of use to you and of course feel free to [contribute](https://github.com/HiltonGiesenow/PoShMon/issues) to the project, there's tons more that can be done!

---

## A Note on Why I built PoShMon
Of course there are loads of monitoring systems and tools out there, both paid and free / open source ones. However, there are two main reasons I initially built PoShMon:

1. I wanted to grow my PowerShell knowledge and there didn't seem to be anything purely PowerShell based that could offer what I wanted

2. Many of the tools don't have a lot of product depth. For instance, many Windows monitoring tools can do basic disk / memory / event log monitoring for SharePoint servers but few can actually give me SharePoint-specific metrics, like how healthy the Search service is, what Timer jobs have failed,  or whether any of the servers need to be upgraded (note that many of these tests can be greatly improved). I'm hoping that PoShMon becomes the home for powerful, specialised monitoring of many other products and platforms, like Exchange, SQL Server, CRM and more.

---

## Release Notes
0.13.0
* Implement hyperlinks in output
* Implemented CI server
* Created a Merger framework (to merge multiple outputs)
* Create a Merger for OS output
* Removed ApplicationName from SharePoint Job Health Test
* Add 'Last Reboot Time' test  

0.12.0
* Added Office Web Apps / Office Online Server monitoring
* Added some style to Email output
* Changed display to Hard Drive and Memory output
* Fixed bug in email footer for skipped tests

0.11.0
* Created 'Self-Healing' Framework into which custom scripts can be injected
* Added ability to skip auto-discovered Windows services
* Fixed bug where Pushbullet and Office 365 Teams were not showing Environment name
* Fixed bug in harddrive space percent test
* Fixed bug in cpu test for standalone 'minimal config test

0.10.1
* Added Proxy settings to enable PushBullet and 0365 Teams connectivity
* Introduced a 'minimum configuration' for local machine monitoring
* Fixed bug in SharePoint UPS Sync monitor
* Added Resolver for High CPU usage while SharePoint Search Index is running
* Improved Verbose output logging
* Added option for harddrive space to track by percent
* Add a check for any invalid TestsToSkip
* Fixed bug in Update-PoShMon

0.9.2
* Fixed bug in email output
* Fixed bug with not terminating Remote sessions correctly

0.9.1
* Fixed a bug crossing hour and day boundaries for Server Time test
* Fixed a bug with Services on server testing in non-SharePoint environments

0.9.0
* Added a Server Time test for servers drifting apart
* Add an 'update' notification for new versions of PoShMon
* Add an 'Update' command to make updating PoShMon easier
* Add Try..Catch error handling to each Test method
* Switched to dynamically invoking test methods by name
* Created a shared 'Core' monitoring function

See [here](https://github.com/HiltonGiesenow/PoShMon/wiki/Changelog) for full Changelog