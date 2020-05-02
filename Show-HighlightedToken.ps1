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
      #Write-Output "x:$charNum";
      if ($charNum -eq 0) { $charNum = 1; }
      $lineNum = 1;
      if ($null -ne $Tokens -and $Tokens[0].Content -eq "|") {
        $here = $true;$env:here = $here;#TODO: remove this condition
      }
      if ($null -ne $Tokens -and $Tokens[0].StartLine -gt 1) {
        $lineNum = $Tokens[0].StartLine;
      }
    }
    Process{
      ForEach($token in $tokens){ #Pipeline input
        #Write-Output "t:$($token.Content)";
        $hereString = $false;
        $tokenColor = (Get-TokenTypeColor $token.Type);
        if ($token.StartLine -gt $lineNum) { $charNum = 1;}
        if ($token.StartColumn -gt $charNum) {
          $numSpaces = ($token.StartColumn - $charNum)
          write-host (" " * $numSpaces) -NoNewline
          $charNum += $numSpaces;
        }
        if ($token.StartLine -ne $token.Endline -and $token.Type -eq [System.Management.Automation.PSTokenType]::String) {
          $hereString = $true;
          Write-Host "`@`"`n" -ForegroundColor $tokenColor -NoNewLine;
        }
        Write-Host ($token.Content) -ForegroundColor $tokenColor -NoNewLine
        if ($hereString) {
          Write-Host "`n`"`@" -ForegroundColor $tokenColor -NoNewLine;
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
      [int]$CommentOffset
    )
    Begin{
      $commentShown = $false;
      #$charNum = $host.UI.RawUI.CursorPosition.X;
      $charNum = 1;
      #if ($charNum -eq 0) { $charNum = 1; }
      #$lineNum = 1;
      #if ($null -ne $Tokens -and $Tokens[0].Content -eq "|") {
      ##  $here = $true;$env:here = $here;#TODO: remove this condition
      #}
      #if ($null -ne $Tokens -and $Tokens[0].StartLine -gt 1) {
      #  $lineNum = $Tokens[0].StartLine;
      #}
    }
    Process{
      ForEach($token in $tokens){
        $tokenColor = (Get-TokenTypeColor $token.Type);
        #if ($token.StartLine -gt $lineNum) { $charNum = 1;}
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
          } elseif ($charnum -gt $CommentOffset) {
            #write-host "HE HAD A HAT!" -f red -no
          }
        }
        $content = $token.Content;
        # de-literalize any `n items.
        if ($token.Type -eq [System.Management.Automation.PSTokenType]::String) {
          if ($content -like "*`n*" -or $content -like "*`r*") {
            $content = $content.Replace("`n","``n").Replace("`r","``r");
          }
          $content = $content -replace "`"", "```""
          $content = "`"" + $content +  "`""
        }
        Write-Host ($content) -ForegroundColor $tokenColor -NoNewLine
        
        #$lineNum = $token.EndLine;
        $charNum = $token.EndColumn;
      };
    }
    End{
    }
  }
  