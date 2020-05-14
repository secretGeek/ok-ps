function Get-Token {
    Param(
            [Parameter(Mandatory,
                ValueFromPipeline=$true,
                HelpMessage='Code to be tokenized',
                Position=0)]
            [string]$code,

            [Parameter(Mandatory=$false)]
            [ref]$errors
        )

      return [System.Management.Automation.PSParser]::Tokenize($code, [ref]$errors);
    }
