$manifestPath = "C:\Dev\GitHub\PoShMon\src\0.2.0\PoShMon.psd1"
Remove-Item -Path $manifestPath -ErrorAction SilentlyContinue

$NestedModules = @(
    'PoShMon.Shared\SharedMonitoringModule.psm1'
    'PoShMon.OSMonitoring\OSMonitoringModule.psm1'
    'PoShMon.SharePoint\SPMonitoringModule.psm1'
    'PoShMon.Web\WebMonitoringModule.psm1'
)

New-ModuleManifest -Path $manifestPath -ModuleVersion "0.2.0" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport "'Invoke-OSMonitoring','Invoke-SPMonitoring'" -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -Description "A PowerShell-based server and farm monitoring solution"

$t = Test-ModuleManifest -Path $manifestPath

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon