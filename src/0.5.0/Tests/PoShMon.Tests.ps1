$scriptFiles  = @( Get-ChildItem -Path $PSScriptRoot\*\*.ps1 -ErrorAction SilentlyContinue )

$testResultSettings = @{ }

Foreach($import in $scriptFiles)
{
    Invoke-Pester -Script $import # -PassThru $testResultSettings
}

# $testResultSettings