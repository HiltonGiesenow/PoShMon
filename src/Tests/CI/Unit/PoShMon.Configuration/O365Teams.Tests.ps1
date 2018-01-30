$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "O365TeamsConfiguration" {
    It "Should return a matching configuration to what was supplied" {

        $testWebhookUrl = "https://outlook.office.com/webhook/"

        $actual = New-PoShMonConfiguration {
                Notifications -When OnlyOnFailure {
                    Email `
                        -ToAddress "someone@email.com" `
                        -FromAddress "bob@jones.com" `
                        -SmtpServer "smtp.company.com" `
                        -Port 27
                    O365Teams -TeamsWebHookUrl $testWebhookUrl
                }
            }

        $actual.Notifications.Sinks.Count | Should Be 2
        $actual.Notifications.Sinks[1].TypeName | Should Be 'PoShMon.ConfigurationItems.Notifications.O365Teams'
        $actual.Notifications.Sinks[1].TeamsWebHookUrl | Should Be $testWebhookUrl
    }
}