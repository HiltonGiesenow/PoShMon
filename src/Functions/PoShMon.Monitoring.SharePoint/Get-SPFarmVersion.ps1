Function Get-SPFarmVersion
{
    [CmdletBinding()]
    param (
        [hashtable]$PoShMonConfiguration
    )

    Write-Verbose "Checking SharePoint farm version..."

    $farmVersion = Invoke-RemoteCommand -PoShMonConfiguration $PoShMonConfiguration -ScriptBlock {
                            return (Get-SPFarm).BuildVersion
                        }

    return $farmVersion
}