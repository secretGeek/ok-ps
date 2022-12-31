. (Join-Path $PSScriptRoot "Get-Token.ps1")
. (Join-Path $PSScriptRoot "Show-OKToken.ps1")

function Show-OKCode {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$code,
		$debugMode = $false,
		[Parameter(Mandatory, ValueFromPipeline = $false)]
		[int]$CommentOffset,
		[int]$MaxKeyLength

	)

	Get-Token $code | Show-OKToken -debugMode:$debugMode -CommentOffset $CommentOffset -MaxKeyLength $MaxKeyLength;
}
