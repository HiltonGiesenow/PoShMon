Remove-Item -Path "C:\Development\GitHub\PoShMon\PoShMon\src\0.1.0\Modules\PoShMon.psd1"

$NestedModules = @(
    'PoShMon.Shared\SharedMonitoringModule.psm1'
    'PoShMon.OSMonitoring\OSMonitoringModule.psm1'
    'PoShMon.SharePoint\SPMonitoringModule.psm1'
    'PoShMon.Web\WebMonitoringModule.psm1'
)

New-ModuleManifest -Path "C:\Development\GitHub\PoShMon\PoShMon\src\0.1.0\Modules\PoShMon.psd1" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport "*" -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -Description "A PowerShell-based server and farm monitoring solution" -ModuleVersion "0.1.0" -NestedModules $NestedModules

$t = Test-ModuleManifest -Path "C:\Development\GitHub\PoShMon\PoShMon\src\0.1.0\Modules\PoShMon.psd1"

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon