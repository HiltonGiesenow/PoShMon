Function New-HtmlRepairFooter
{
    [CmdletBinding()]
    param(
    )

    $emailSection = ''

    $emailSection += '</body>'

    return $emailSection;
}