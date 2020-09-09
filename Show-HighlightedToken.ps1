. (Join-Path $PSScriptRoot "Get-TokenTypeColor.ps1")

function Show-HighlightedToken {
    Param(
      [Parameter(Mandatory,
          ValueFromPipeline=$true,
          HelpMessage='Tokens to be highlighted',
          Position=0)]
      [System.Management.Automation.PSToken[]]$Tokens
    )
    Begin{
      $charNum = $host.UI.RawUI.CursorPosition.X;#+1;
      if ($charNum -eq 0) { $charNum = 1; }
      $lineNum = 1;
      if ($null -ne $Tokens -and $Tokens[0].Content -eq "|") {
        $here = $true;$env:here = $here;
      }
      if ($null -ne $Tokens -and $Tokens[0].StartLine -gt 1) {
        $lineNum = $Tokens[0].StartLine;
      }
    }
    Process{
      ForEach($token in $tokens){ #Pipeline input
        $hereString = $false;
        $tokenColor = (Get-TokenTypeColor $token.Type);
        if ($token.StartLine -gt $lineNum) { $charNum = 1;}
        if ($token.StartColumn -gt $charNum) {
          $numSpaces = ($token.StartColumn - $charNum)
          write-host (" " * $numSpaces) -NoNewline
          $charNum += $numSpaces;
        }

				if ($token.Type -eq [System.Management.Automation.PSTokenType]::String) {
					if ($token.StartLine -ne $token.Endline) {
						$hereString = $true;
						Write-Host "`@`"`n" -ForegroundColor $tokenColor -NoNewLine;
					} else {
					  # BUG: unable to determine when to use " versus ' ?
					  Write-Host "`"" -ForegroundColor $tokenColor -NoNewLine;
						#$token | Select *;
					}
				}

				if ($token.Type -eq [System.Management.Automation.PSTokenType]::Variable) {
					# Give me my $ back
					#$tokenColor = (Get-TokenTypeColor $token.Type);
					#$token | Select *;
					Write-Host "`$`$" -ForegroundColor $tokenColor -NoNewLine;
				}
				
        Write-Host ($token.Content) -ForegroundColor $tokenColor -NoNewLine
				
				if ($token.Type -eq [System.Management.Automation.PSTokenType]::String) {
					if ($hereString) {
						Write-Host "`n`"`@" -ForegroundColor $tokenColor -NoNewLine;
					} else {
						Write-Host "`"" -ForegroundColor $tokenColor -NoNewLine;
					}
				}
        $lineNum = $token.EndLine;
        $charNum = $token.EndColumn;
      };
    }
    End{
    }
  }
  function Show-HighlightedOKToken {
    Param(
      [Parameter(Mandatory,
          ValueFromPipeline=$true,
          HelpMessage='Tokens to be highlighted',
          Position=0)]
      [System.Management.Automation.PSToken[]]$Tokens,
      [int]$CommentOffset,
      [int]$maxKeyLength
    )
    Begin{
      $commentShown = $false;
      $charNum = 1;
    }
    Process{
      ForEach($token in $tokens){
        $tokenColor = (Get-TokenTypeColor $token.Type);
        if ($token.StartColumn -gt $charNum) {
          $numSpaces = ($token.StartColumn - $charNum);
          write-host (" " * $numSpaces) -NoNewline;
          $charNum += $numSpaces;
        }
        if ($commentShown -eq $false -and $token.Type -eq [System.Management.Automation.PSTokenType]::Comment) {
          $commentShown = $true;
          if ($charnum -lt $CommentOffset) {
            $numSpaces = ($CommentOffset - $charNum);
            write-host (" " * $numSpaces) -NoNewline;
            $charNum += $numSpaces;
          } elseif ($CommentOffset -gt 0 -and $charnum -gt $CommentOffset) {
            $numSpaces = ($Host.UI.RawUI.WindowSize.Width - $token.Content.Length);
            $numSpaces = [Math]::Min($numSpaces, $CommentOffset);
            write-host ""; # take a new line;
            write-host (" " * ($numSpaces + $maxKeyLength + 1)) -NoNewline;
            $charNum = $numSpaces;
          }
        }
        $content = $token.Content;
        # de-literalize any `n items!
        if ($token.Type -eq [System.Management.Automation.PSTokenType]::String) {
          if ($content -like "*`n*" -or $content -like "*`r*") {
            $content = $content.Replace("`n","``n").Replace("`r","``r");
          }
          $content = $content -replace "`"", "```""
          $content = "`"" + $content +  "`""
        }
        # give me my $ back
        if ($token.Type -eq [System.Management.Automation.PSTokenType]::Variable) {
          $content = ("`$" + $content);
        }
        Write-Host ($content) -ForegroundColor $tokenColor -NoNewLine
        $charNum = $token.EndColumn;
      };
    }
    End{
    }
  }
