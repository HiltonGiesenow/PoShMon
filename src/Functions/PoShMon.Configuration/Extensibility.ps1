Function New-ExtensibilityConfig
{
    [CmdletBinding()]
    param(
        [string[]]$ExtraTestFilesToInclude = @(),
        [string[]]$ExtraResolverFilesToInclude = @(),
        [string[]]$ExtraMergerFilesToInclude = @()
    )

    return @{
            TypeName = "PoShMon.ConfigurationItems.Extensibility"
            ExtraTestFilesToInclude = $ExtraTestFilesToInclude
            ExtraResolverFilesToInclude = $ExtraResolverFilesToInclude
            ExtraMergerFilesToInclude = $ExtraMergerFilesToInclude
        }
}