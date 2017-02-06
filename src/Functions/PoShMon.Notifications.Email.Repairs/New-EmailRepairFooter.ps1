Function New-EmailRepairFooter
{
    [CmdletBinding()]
    param(
    )

    $emailSection = ''

    $emailSection += '</body>'

    return $emailSection;
}