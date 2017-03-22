Function Dummy-TestWithException
{
    [CmdletBinding()]
    Param(
        [hashtable]$PoShMonConfiguration
    )

    throw "something"
}