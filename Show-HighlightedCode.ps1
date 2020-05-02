. (Join-Path $PSScriptRoot "Get-Token.ps1")
. (Join-Path $PSScriptRoot "Show-HighlightedToken.ps1")

function Show-HighlightedCode
{
  [CmdletBinding()]
  param (
      [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [string]
      $code
  )

  Get-Token $code | Show-HighlightedToken 
}

function Show-HighlightedOKCode
{
[CmdletBinding()]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $code,
    [Parameter(Mandatory, ValueFromPipeline=$false)]
    [int]$CommentOffset
)

  Get-Token $code | Show-HighlightedOKToken -CommentOffset $CommentOffset

}