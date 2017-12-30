$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

$twilioConfigPath = [Environment]::GetFolderPath("MyDocuments") + "\twilioConfig.json"

<#
Sample contents of file:
{
    "SID": "[your SID]",
    "Token": "[your Token]",
	"FromAddress": "[your Twilio Number]",
	"ToAddress": "[your Mobile Phone Number]"
}
#>

if (Test-Path $twilioConfigPath) # only run this test if there's a config to send notifications
{
    Describe "Send-TwilioMessage" {
        It "Should send a Twilio message" {

            $twilioConfig = Get-Content -Raw -Path $twilioConfigPath | ConvertFrom-Json

            $poShMonConfiguration = New-PoShMonConfiguration {
                            General `
                                -EnvironmentName 'SharePoint' `
                                -MinutesToScanHistory 60 `
                                -PrimaryServerName 'ZAMGNTSPAPP1' `
                                -ConfigurationName SpFarmPosh `
                                -TestsToSkip 'SPServerStatus','WindowsServiceState','SPFailingTimerJobs','SPDatabaseHealth','SPSearchHealth','SPDistributedCacheHealth','WebTests'
                            Notifications -When All {
								Twilio `
									-SID $twilioConfig.SID `
									-Token $twilioConfig.Token `
									-FromAddress $twilioConfig.FromAddress `
									-ToAddress $twilioConfig.ToAddress
                            }               
                        }

            $actual = Send-TwilioMessage $poShMonConfiguration $poShMonConfiguration.Notifications.Sinks "Test Subject" "Test Body" $false -verbose

        }

    }
}