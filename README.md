# PoShMon
PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an "agent-less" monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run the script from a regular workstation and have it monitor a single server or group of servers. PoShMon is also able to monitor "farm"-based products like SharePoint, in which multiple servers work together to provide a single platform. For details on why I built PoShMon, see the bottom of this page.

## Key Features
Some of the key features / benefits of PoShMon are:
* Agent-less Monitoring - nothing needs to be installed on the remote servers
* Core operating system and web-site monitoring
* Specialized SharePoint monitoring
* Supports frequent/critical as well as comprehensive daily monitoring
* Email, Pushbullet and Office 365 Teams notifications

## Installation Instructions
PoShMon is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PoShMon) so you can either download it from this GitHub page or even install it directly from the gallery onto your local workstation using

`PS> Install-Module -Name PoShMon`

or via [Azure Automation](https://www.powershellgallery.com/packages/PoShMon).

## Prerequisites
1. While PoShMon is indeed "agent-less", it **does need to execute remote PowerShell commands** against the servers in question. As a result, you need to ensure that PowerShell remoting is correctly configured and also that you are running PoShMon under an account that has the correct rights to connect to the server remotely and execute the requisite commands.
2. In addition to ensuring PowerShell remoting itself is working correctly, you also need to ensure that commands that access other environments further down the line (most commonly SQL Server) have a **means to pass on credentials** effectively and securely. Essentially, this relates to the age-old "Double Hop" issue - we're trying to connect remotely to, say, a SharePoint environment and we in turn need access to SQL Server. This issue is described more fully in a PowerShell context [here](https://blogs.technet.microsoft.com/ashleymcglone/2016/08/30/powershell-remoting-kerberos-double-hop-solved-securely/) and [this link](https://blogs.msdn.microsoft.com/sergey_babkins_blog/2015/03/18/another-solution-to-multi-hop-powershell-remoting/) provides a means for creating more secure connections instead of using CredSSP. More on this appears below in the SharePoint example further down. You can test with SharePoint, for example, by creating a session from a remote machine (say your workstation) and executing `Get-SPFarm` - if that works successfully, you're probably good to go with PoShMon.

## Getting Started
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

* Note the use of `PrimaryServerName` instead of `ServerNames` as well as the use of [`Invoke-SPMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.SharePoint/Invoke-SPMonitoring.ps1) instead of [`Invoke-OSMonitoring`](https://github.com/HiltonGiesenow/PoShMon/blob/master/src/0.4.0/Functions/PoShMon.OSMonitoring/Invoke-OSMonitoring.ps1). "EnvironmentName", which appears in notifications (emails etc.) is also changed to something more suitable.
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
0.8.3
* Reduced duplication in Test code for Stopwatch
* Fixed naming for 'Free Percent' column in Memory Test
* For 'Critical' (i.e. NotifyOnFailure) runs, set Email Priority to High if failure occurs
* For Exception notifications,  set Email Priority to High
* Convert all Tests that used a PSSession parameter to using PoShMonConfiguration - improves testability
* Added Unit Tests for every main Test-* function

0.8.2
* Added date to UserProfileSync output
* Added a function to initialise output for all Test methods
* Added PoShMon version to email output
* Added Farm Health Test (SharePoint) - not active

0.8.1
* Fixing a bug in the SharePoint UPS sync query for datetime

0.8.0
* Added User Profile Sync monitoring for SharePoint 2010/2013 FIM service
* Added CPU monitoring
* Added html encoding for Email notification
* Some unit test bug fixes and coverage work

0.7.0
* Added monitoring for server memory (free + total)
* Removed Credential for Pushbullet, using Header directly instead

0.6.2
* Fixed ordering of output columns (in email etc.)
* Removed hard-coded hard drive space threshold
* Refactored tests to take in 'PoShMonConfiguration' instead of individual parameters
* Removed an unnecessary function
* Sorting database output by size (Desc)

See [here](https://github.com/HiltonGiesenow/PoShMon/wiki/Changelog) for full Changelog