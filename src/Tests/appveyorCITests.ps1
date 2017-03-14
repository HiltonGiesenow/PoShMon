#based on code from https://github.com/RamblingCookieMonster/PSDiskPart/
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
Set-Location $ProjectRoot

#$path = (Split-Path -Parent $MyInvocation.MyCommand.Path)

Import-Module Pester

Invoke-Pester -Path "$ProjectRoot\src\Tests\CI" -CodeCoverage "$ProjectRoot\src\Functions\*\*.ps1" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\RawTestResults.xml" -PassThru | `
            Export-Clixml -Path "$ProjectRoot\PesterTestResults.xml"

#Invoke-Pester -Path "$ProjectRoot\src\Tests\Integration" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\RawIntegrationTestResults.xml" -PassThru | `
#            Export-Clixml -Path "$ProjectRoot\PesterIntegrationTestResults.xml"

#Show status...
$AllFiles = Get-ChildItem -Path $ProjectRoot\*Results.xml | Select -ExpandProperty FullName
"`n`tSTATUS: Finalizing results`n"
"COLLATING FILES:`n$($AllFiles | Out-String)"

#Upload results for test page
Get-ChildItem -Path $ProjectRoot\Raw*TestResults.xml | Foreach-Object {
    $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    $Source = $_.FullName

    "UPLOADING FILES: $Address $Source"

    (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
}

#What failed?
$Results = @( Get-ChildItem -Path "$ProjectRoot\Pester*TestResults.xml" | Import-Clixml )
            
$FailedCount = $Results |
    Select -ExpandProperty FailedCount |
    Measure-Object -Sum |
    Select -ExpandProperty Sum
    
if ($FailedCount -gt 0) {

    $FailedItems = $Results |
        Select -ExpandProperty TestResult |
        Where {$_.Passed -notlike $True}

    "FAILED TESTS SUMMARY:`n"
    $FailedItems | ForEach-Object {
        $Test = $_
        [pscustomobject]@{
            Describe = $Test.Describe
            Context = $Test.Context
            Name = "It $($Test.Name)"
            Result = $Test.Result
        }
    } |
        Sort Describe, Context, Name, Result |
        Format-List

    throw "$FailedCount tests failed."
}