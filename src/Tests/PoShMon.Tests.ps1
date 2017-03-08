Import-Module Pester

$path = (Split-Path -Parent $MyInvocation.MyCommand.Path)

$testsPath = "$path\CI"

Invoke-Pester -Path $testsPath #-CodeCoverage "$sutPath\*\*.ps1"

#$scriptFiles = @( Get-ChildItem -Path "$path\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )
#$scriptFiles = @( Get-ChildItem -Path "$path\CI\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )
#$scriptFiles = @( Get-ChildItem -Path "$path\CI\Integration\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )
#$scriptFiles = @( Get-ChildItem -Path "$path\CI\Unit\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )

#$testResultSettings = @{ }

#$testsPath = "$path\CI"
#$testsPath = "$path\CI\Integration"

<#
$filesToTest = @()
$sutPath = Join-Path (Split-Path -Parent $path) -ChildPath ('\Functions') -Resolve

Foreach($import in $scriptFiles)
{
    $sutFileName = (Split-Path -Leaf $import).Replace(".Tests", "")
    if (!$filesToTest.Contains($sutFileName))
    {
        $fileToTest = Get-ChildItem -Path "$sutPath\*\$sutFileName" -Recurse

        $filesToTest += $fileToTest.FullName
    }

    #Invoke-Pester -Script $import # -PassThru $testResultSettings
    #. $import
}
#>

# $testResultSettings