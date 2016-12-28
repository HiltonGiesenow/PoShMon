$version = "0.4.0"
$manifestPath = "C:\Dev\GitHub\PoShMon\src\$version\PoShMon.psd1"
Remove-Item -Path $manifestPath -ErrorAction SilentlyContinue

New-ModuleManifest -Path $manifestPath -ModuleVersion $version -RootModule "PoShMon.psm1" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport '*' -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -Description "A PowerShell-based server and farm monitoring solution" -Tags 'Monitoring','Server','Farm','SharePoint' -Verbose

$t = Test-ModuleManifest -Path $manifestPath

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon