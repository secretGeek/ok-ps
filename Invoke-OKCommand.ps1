
. (Join-Path $PSScriptRoot "Show-HighlightedCode.ps1")
. (Join-Path $PSScriptRoot "Get-CommandLength.ps1")

# with no parameter: looks in the current folder for a ".ok" file, and lists its commands numbered
# with a number parameter, runs the relevant command from the .ok file, e.g. "ok 1" runs first line of ".ok" file

function ok { 
	Invoke-OKCommand $args
}

function Invoke-OKCommand {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
  param (
      [parameter(mandatory=$false, position=0)]$number,
      [parameter(
          mandatory=$false,
          position=1,
          ValueFromRemainingArguments=$true
       )]$arg
  )

  # this is a private function used by ok
  # given a filename (a file full of commands) and a number (possibly null) and some remaining parameters:
  #   invoke the numbered command (if a number was given) or display a numbered list of the commands
  function ok_file($file, $number, $arg) {
    $commands = @{};
    $num = 0;
    Get-Content $file | ForEach-Object {
      $line = $_.trim();
      if ($line -ne "" -and $null -ne $line) {
        if ($line.indexOf('#') -ne 0) {
          $num = $num + 1;
          $commands.Add(("" + $num), $line);
        }
      }
    }
    if ($null -ne $number -and $num -ge 1) {
      if ($number -le $num) {
        # INVOKE the command (after pretty-printing it)
        $expression = $commands[("" + $number)];
        ok_prettyPrint $expression
        invoke-expression $expression;
      } else {
        write-host "'$number' needs to be <= $num" -foregroundcolor "red"
        ok_file $file
      }
    } else {
      # Get length of longest command/comment
      # todo: find actual longest command by parsing.
<#
      $maxCommentLength = 0;
      $maxCommandLength = 0;
      ($commands.Values | ForEach-Object {  
        $code = $_; 
        $tokens = (Get-Token $code);
        $this_commandLength = (Get-CommandLength $tokens);
        $this_commentLength = $code.Length - $this_commandLength;
        New-Object psobject -property  @{commandLength = $this_commandLength; commentLength = $this_commentLength}
      } Measure-Object 
#>


      $maxCommandLength = (($commands.Values | ForEach-Object { ($_ -split '#')[0] } | ForEach-Object { $_.Length }) | Measure-Object -Maximum ).Maximum
      $maxCommentLength = (($commands.Values | ForEach-Object { ($_ -split '#')[1] } | ForEach-Object { $_.Length }) | Measure-Object -Maximum ).Maximum
      $maxCommandLength = [Math]::Min($Host.UI.RawUI.WindowSize.Width -  $maxCommentLength - 5, $maxCommandLength)
      # LIST the commands
      $num = 0;
      Get-Content $file | ForEach-Object {
        $num += 1
      if (ok_prettyPrint $_ $num) {
      } else {
        $num -= 1
      }

        #$command, $comment = $_.trim() -split '#' | ForEach-Object { $_.trim() }
        #ok_prettyPrint $_ $num
        #if ($command) {
        #  $num = $num + 1
        #  Write-Host -NoNewLine "$num. " -foregroundcolor "yellow"

        #  Write-Host -NoNewLine $command.PadRight($maxCommandLength + 1, " ") -foregroundcolor "white"
        #  if ($comment) { Write-Host "# $comment" -foregroundcolor "green" }
        #  else { Write-Host "" }
        #} else {
        #  if ($comment) { Write-Host "# $comment" -foregroundcolor "green" }
        #  else { Write-Host "" }
        #}
      }
    }
  }

  if (test-path ".\.ok") {
    ok_file -file ".\.ok" -number $number -arg $arg
    #$file, $number, $arg
  }
}


# this is a resuable function, currently used only by `ok_file`, returns true if the expression contains code.
function ok_prettyPrint {
  [OutputType([bool])]
  param($expression, $number)

  if ($null -eq $number) {
    write-host -NoNewline "> " -foregroundcolor "magenta" # impersonate prompt...
    #Write-Host -NoNewLine "$number`: " -foregroundcolor "yellow"
  } else {
    Write-Host -NoNewLine "$number`: " -foregroundcolor "yellow"
  }

  if ($expression.indexOf('#') -ge 0) {
    write-host -NoNewline (($expression -split '#')[0]) -foregroundcolor "white"
    write-host $expression.substring($expression.indexOf('#')) -foregroundcolor "green"
    return $true;
  } else {
    write-host $expression -foregroundcolor "white"
    return $false;
  }
}





#function Get-Token($code, [ref]$errors) {



# Get-Tokens "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | ft
# Get-Tokens "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | Show-HighlightedToken
# Get-Tokens "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | % { Show-HighlightedToken $_ }
# "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | % { Get-Tokens $_ } | % { Show-HighlightedToken $_ }
# "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | Get-Token | % { Show-HighlightedToken $_ }
# "dir | % {`n `@`"`nhi`n`n`nthere`n`"`@`n}" | Get-Token | Show-HighlightedToken
# "dir | % {`n`@`"`nhi`n`n`nthere`n`"`@`n } #  etc" | Get-Token |Show-HighlightedToken
# "dir | % {`n`@`"`nhi`n`n`nthere`n`"`@`n } #  etc" | Get-Token | % { Show-HighlightedToken $_ }


# "dir | % {`necho   `@`"`nhi`n`n`nthere`n`"`@`n } #  etc" | clipp; echo "now paste it..."
# "dir | % {`necho   `@`"`nhi`n`n`nthere`n`"`@`n } #  etc" | Get-Token | Show-HighlightedToken
# "dir | % {`necho   `@`"`nhi`n`n`nthere`n`"`@`n } #  etc" | Get-Token | % { Show-HighlightedToken $_ }
