function Get-OKToken {
	Param(
		[Parameter(Mandatory,
			ValueFromPipeline = $true,
			HelpMessage = "Code to be tokenized",
			Position = 0)]
		[string]$code,

		[Parameter(Mandatory = $false)]
		[ref]$errors

	)
	$ParserTokens = $null;
	$result = [System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$ParserTokens, [ref]$null) | Out-Null;
	# Result is of type AST, parserTokens is an array.
	return $ParserTokens;
}
