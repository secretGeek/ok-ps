function Get-CommandLength {
    Param(
        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            HelpMessage = 'Tokens to be measured',
            Position = 0)]
        [System.Management.Automation.Language.Token[]]$Tokens
    )
    Process {
        $upto = 0;
        ForEach ($token in $Tokens) {
            if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -or
                $token.Kind -eq [System.Management.Automation.Language.TokenKind]::EndOfInput) {
                return $upto;
            }
            else {
                $upto = $token.Extent.EndColumnNumber;
            }
        }
        return $upto;
    }
}