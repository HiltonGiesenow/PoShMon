function Trim-Date {
 
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [DateTime]$Date,
 
        [ValidateSet('Tick','Millisecond','Second','Minute','Hour','Day')]
        [String]$Precision = 'Second'
    )
 
    process {
 
        if ($Precision -eq 'Tick')
        {
            return $Date
        }
 
        $TickCount = Switch ($Precision)
        {
            'Millisecond' { 10000; break }
            'Second' { ( New-TimeSpan -Seconds 1 ).ticks; break }
            'Minute' { ( New-TimeSpan -Minutes 1 ).ticks; break }
            'Hour' { ( New-TimeSpan -Hours 1 ).ticks; break }
            'Day' { ( New-TimeSpan -Days 1 ).ticks; break }
        }
 
        $Result = $Date.Ticks - ( $Date.Ticks % $TickCount )
        [DateTime]$Result
    }
}