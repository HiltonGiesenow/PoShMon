$version = "0.8.2"
$manifestPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "\PoShMon.psd1"

Remove-Item -Path $manifestPath -ErrorAction SilentlyContinue

$description = "PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an 'agent-less' monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run the script from a regular workstation and have it monitor a single server or group of servers (e.g. a web farm). PoShMon is also able to monitor 'farm'-based products like SharePoint, in which multiple servers work together to provide a single platform. In this case, instead of a list of servers, you need only to supply PoShMon with details of a 'primary' server against which you want to monitor the platform and it will use, in this case, SharePoint's API to determine the remaining servers. For more information, documentation etc. see the Project Site as well as the Samples folder within the module."

$releaseNotes = "
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

0.6.1
* Improved global exception handler (try/catch) to handle initial exceptions.
* Added more tests
* Refactored internal Notification code

0.6.0
Adding Office 365 Teams notification output

0.5.1
Fixing Pushbullet notification output

0.5.0
* Added Pushbullet support and some additional unit tests
* Improved description in module itself
* Added basic help tutorial to readme on GitHub project page 
"

New-ModuleManifest -Path $manifestPath -ModuleVersion $version -RootModule "PoShMon.psm1" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport '*' -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -LicenseUri "https://github.com/HiltonGiesenow/PoShMon/blob/master/LICENSE" -Description $description -Tags 'Monitoring','Server','Farm','SharePoint' -ReleaseNotes $releaseNotes -Verbose

$t = Test-ModuleManifest -Path $manifestPath

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon