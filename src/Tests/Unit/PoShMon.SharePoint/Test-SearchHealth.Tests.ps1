$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

class SPFarmMock {
    [string]$Name
    [string]$BuildVersion
    [string]$Status
    [bool]$NeedsUpgrade

    SPFarmMock ([string]$NewName, [string]$NewBuildVersion, [string]$NewStatus, [bool]$NewNeedsUpgrade) {
        $this.Name = $NewName;
        $this.BuildVersion = $NewBuildVersion;
        $this.Status = $NewStatus;
        $this.NeedsUpgrade = $NewNeedsUpgrade;
    }
}

Describe "Test-SearchHealth" {
    It "Should " {
    
        Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
            return
        }

        $poShMonConfiguration = New-PoShMonConfiguration {
                General -ServerNames 'localhost'
                OperatingSystem
            }

        $actual = Test-SearchHealth $poShMonConfiguration
    }

}