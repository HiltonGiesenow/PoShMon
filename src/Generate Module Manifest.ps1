$version = "1.3.0"
$manifestPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "\PoShMon.psd1"

Remove-Item -Path $manifestPath -ErrorAction SilentlyContinue

$description = "PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an 'agent-less' monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run or schedule the script from a regular workstation and have it monitor a single server or group of servers, using PowerShell remoting. PoShMon is also able to monitor 'farm'-based products like SharePoint, in which multiple servers work together to provide a single platform.

Key Features
Some of the key features / benefits of PoShMon are:
- Agent-less Monitoring - nothing needs to be installed on the remote servers
- Core operating system and web-site monitoring
- Specialized SharePoint monitoring
- Specialized Office Online Server monitoring
- Supports frequent/critical as well as comprehensive daily monitoring
- Email, Pushbullet (mobile), Office 365 Teams ('Chat-ops') and Twilio (SMS) notifications
- Provides a framework for 'self-healing' systems
- Support for Operation Validation Framework (OVF)

For more information, documentation etc. visit https://github.com/HiltonGiesenow/PoShMon as well as the Samples folder within the module itself."

$releaseNotes = "
1.3.0
* Added storing of exceptions for later resolution, where possible (Exception might be environmental, and repairable)
* Fixed bug in Windows Event Log monitoring returning empty details
* Added platform build number to email notifications (SharePoint and OOS)
* Added ability to set SMTP authentication separately from other Internet access

1.2.0
* Improved ability to ignore event log entries (based on a minimum count)
* Added a repair for Office Online Server (previously 'Office Web Apps') to repair the W3C service if stopped
* Improved discovery of other servers in a 'farm' product (e.g. SharePoint, Office Online Server)
* Improved some Verbose output
* Improved formatting for Exception and Repair emails
* Other minor bug fixes

1.1.1
* Various bug fixes in Web tests
* Renamed html ad hoc report function
* Various bug fixes in html ad hoc report function

1.1.0
* Added ability to create ad-hoc html report
* For Drive Space test, added Volume Name to output
* Added html formatting to Exception emails

1.0.0
* Official 1.0.0 release
* Added SMS notification via Twilio
* Improved SharePoint Distributed Cache health test
* Fixed some unit tests
* Fixed Unsupported Verbs warning
* Notification refactor
* Fixed failing Websites test for cookie prompt
* Fixed CPU test failing on local machine
* Fixed CPU test bug for group of servers
* Fixed EventLog test bug
* Improved failure message for Windows Service tests

0.15.1
* Adding capability to run without any config (to scan local machine)
* Minor wording change

0.15.0
* Bug fixes for Pushbullet and Microsoft Teams message posting
* Added sample for self-healing
* Minor code cleanups

0.14.0
* Integration with Operation Validation Framework (OVF)

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
"

New-ModuleManifest -Path $manifestPath -ModuleVersion $version -RootModule "PoShMon.psm1" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport '*' -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -LicenseUri "https://github.com/HiltonGiesenow/PoShMon/blob/master/LICENSE" -Description $description -Tags 'Monitoring','Server','Farm','SharePoint' -ReleaseNotes $releaseNotes -Verbose

$t = Test-ModuleManifest -Path $manifestPath

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon