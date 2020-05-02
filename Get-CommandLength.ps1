function Get-CommandLength {
    Param(
      [Parameter(Mandatory,
          ValueFromPipeline=$false,
          HelpMessage='Tokens to be highlighted',
          Position=0)]
      [System.Management.Automation.PSToken[]]$Tokens
    )
    Process{
        $upto = 0;
        ForEach($token in $tokens){ #Pipeline input
            if ($token.Type -eq [System.Management.Automation.PSTokenType]::Comment){
                return $upto;        
            } else {
                $upto = ($token.Start + $token.Length);
            }
        }
        return $upto;
    }
}