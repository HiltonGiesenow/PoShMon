$path = (Split-Path -Parent $MyInvocation.MyCommand.Path)

$scriptFiles = @( Get-ChildItem -Path "$path\Integration\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )
#$scriptFiles = @( Get-ChildItem -Path "$path\Unit\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )
#$scriptFiles = @( Get-ChildItem -Path "$path\*\*.ps1" -Recurse -ErrorAction SilentlyContinue )

$testResultSettings = @{ }

Foreach($import in $scriptFiles)
{
    #Invoke-Pester -Script $import # -PassThru $testResultSettings
    #$import
    . $import
}

# $testResultSettings