$path = (Split-Path -Parent $MyInvocation.MyCommand.Path)

$scriptFiles = @( Get-ChildItem -Path "$path\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )

$testResultSettings = @{ }

Foreach($import in $scriptFiles)
{
    Invoke-Pester -Script $import # -PassThru $testResultSettings
}

# $testResultSettings