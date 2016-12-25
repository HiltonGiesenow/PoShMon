Function Format-Gigs
{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]$freeSpaceRaw
    )

    $gigsValue = ($freeSpaceRaw/1MB)
   
    return ("{0:F0}" -f $gigsValue) 
    #$([Math]::Round($disk.Size/1GB,2))
}