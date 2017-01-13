$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

<#
failing for now
Describe "Test-SearchHealth" {
    It "Should " {

        Mock -CommandName Connect-PSSession -MockWith {
            return
        }
    
        Mock -CommandName Invoke-Command -MockWith {
            return
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                General -ServerNames 'localhost'
                OperatingSystem
            }

        $actual = Test-SearchHealth 
    }

}
#>