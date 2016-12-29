$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\') -Resolve
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1") -Verbose
$sutFileName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sutFilePath = Join-Path $rootPath -ChildPath "Functions\PoShMon.Notifications.Email\$sutFileName" 
. $sutFilePath
