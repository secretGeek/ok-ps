. (Join-Path $PSScriptRoot "Get-Token.ps1")
. (Join-Path $PSScriptRoot "Get-CommandLength.ps1")
. (Join-Path $PSScriptRoot "Show-HighlightedCode.ps1")

Enum OKCommandType {
    Comment = 1
    Numbered = 2
    Named = 3
}

Class OKCommandInfo {
    [int]$physicalLineNum # 1-based
    [OKCommandType]$type # what type of line is this? A comment, numbered or named
    [string]$commandText # everything other than the command name (if there is one)
    [string]$key # either ("" + $number) or $commandName
    [System.Management.Automation.PSToken[]]$tokens
    [int]$commentOffset # how many chars from the start of the command to the first comment token (useful to know this for aligning comments)
}

Class OKFileInfo {
    [string]$fileName; # fileName
    [Hashtable]$commands; # hashtable of OKCommandInfo
    [OKCommandInfo[]]$lines; # Commands, in the order they are found in the file
    [int]$maxKeyWidth; # what is the widest command name
    [int]$commentOffset;
}

function Get-OKCommand($file) {

    # TODO: parameter validation
    $commands = @{ };

    $lines = New-Object System.Collections.ArrayList
    [regex]$rx = "^[ `t]*(?<commandName>[A-Za-z_][A-Za-z0-9-_]*)[ `t]*\:(?<commandText>.*)$";

    $num = 0;
    $physicalLineNum = 0;

    Get-Content $file | ForEach-Object {
        $line = $_.trim();
        $physicalLineNum = $physicalLineNum + 1;
        if ($null -eq $line -or $line -eq "") {
            # blank line
        }
        else {
            $commandInfo = new-object OKCommandInfo
            $commandInfo.physicalLineNum = $physicalLineNum;

            if ($line.indexOf('#') -eq 0) {
                $commandInfo.type = [OKCommandType]::Comment
                $commandInfo.commandText = $line;
            }
            else {
                $groups = $rx.Matches($line).Groups;
                if ($null -ne $groups) {
                    $commandInfo.type = [OKCommandType]::Named
                    $commandInfo.commandText = $groups[0].Groups["commandText"].Value.Trim();

                    $key = $groups[0].Groups["commandName"].Value.Trim();
                    if ($null -ne $commands[$key]) {
                        $num = $num + 1;
                        <#
                        write-host "ok: duplicate commandname '" -f Red -no;
                        write-host "$key" -f white -no;
                        write-host "' mapped to " -f Red -no;
                        write-host "$num" -f white;
                        #>
                        $key = ("" + $num);
                        $commandInfo.type = [OKCommandType]::Numbered
                    }
                    $commandInfo.key = $key;
                }
                else {
                    $num = $num + 1;
                    $commandInfo.type = [OKCommandType]::Numbered
                    $commandInfo.commandText = $line
                    $commandInfo.key = ("" + $num);
                }
                $maxKeyWidth = [math]::max( $maxKeyWidth , $commandInfo.key.length );
                $commandInfo.Tokens = (Get-Token $commandInfo.commandText);
                $commands.Add($commandInfo.key, $commandInfo) | out-null;
            }
            $lines.Add($commandInfo) | out-null;
        }
    }

    #TODO: this will be configurable
    $alignComments = $true;
    if ($alignComments) {
        $maxCommandLength = ($commands.Values | ForEach-Object {
                [OKCommandInfo]$c = $_;
                # Only consider commands where the total width < console width
                if (($maxKeyLength + 2 + $c.CommandText.Length) -lt $Host.UI.RawUI.WindowSize.Width) {
                    Get-CommandLength ($c.tokens);
                } else {
                    0;
                }
            } | Measure-Object -Maximum | ForEach-Object Maximum);

        $maxCommentLength = ($commands.Values | ForEach-Object {
                [OKCommandInfo]$c = $_;
                ($c.key.length + 2) + ($c.CommandText.Length) - (Get-CommandLength ($c.tokens));
            } | Measure-Object -Maximum | ForEach-Object Maximum);
        # the "- 2" is the width of the ": " after each command.
        $commentOffset = [Math]::Min(
            $Host.UI.RawUI.WindowSize.Width - 2 - $maxCommentLength - $maxKeyLength, 
            $maxCommandLength + 2 + $maxKeyLength)
        #Write-Host "commentOffset:$commentOffset" -f Magenta;
    }
    else {
        $commentOffset = 0;
    }

    $fileInfo = New-Object OKFileInfo;
    $fileInfo.fileName = $file;
    $fileInfo.commands = $commands;
    $fileInfo.lines = $lines;
    $fileInfo.maxKeyWidth = $maxKeyWidth;
    $fileInfo.commentOffset = $commentOffset;
    return $fileInfo;
}


function Show-OKFile($okFileInfo) {
    $maxKeyWidth = $okFileInfo.maxKeyWidth;
    $okFileInfo.lines | Foreach-Object {
        [OKCommandInfo]$c = $_;
        if ($c.Type -eq [OKCommandType]::Comment) {
            write-host (("-" * ($maxKeyWidth))+"  ") -NoNewline -f Cyan;
            write-host $c.commandText.TrimStart().TrimStart('#').TrimStart() -f Cyan
        }
        else {
            write-host (" " * ($maxKeyWidth - $c.key.length)) -f cyan -NoNewline
            write-host $c.key -f cyan -NoNewline
            write-host ": " -f gray -NoNewline
            Show-HighlightedOKCode -code $c.commandText -CommentOffset $okFileInfo.commentOffset -MaxKeyLength $okFileInfo.MaxKeyWidth;
            write-host "";
        }
    }
}

function Invoke-OKCommand { 
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
  param (
      [parameter(mandatory=$false, position=0)][OKFileInfo]$okFileInfo,
      [parameter(mandatory=$false, position=1)][string]$commandName,
      [parameter(
          mandatory=$false,
          position=1,
          ValueFromRemainingArguments=$true
       )]$arg
  )

    #TODO: what if it's not a valid command?
    # see if it's close to valid... get candidates if exactly 1 -- run it.
    # if more than 1 -- say "did you mean" and show those.
    # if it's less than 1 -- error... show file.
    $command = $okFileInfo.commands[("" + $commandName)];
    if ($null -eq $command) {
        $candidates = New-Object System.Collections.ArrayList

        $okFileInfo.commands.keys |
        Where-Object { $_ -like ($commandName + "*") } |
        Foreach-Object {
            $candidates.Add($_) | out-null;
        }
        if ($null -eq $candidates -or $candidates.Count -eq 0) {
            Write-host "ok: unknown command " -f Red -no
            write-host "'" -no;
            write-host "$commandName" -f yellow -no;
            write-host "'";
            Write-host "(use 'ok' for a list of local commands, or 'ok help' for general commands)"
            return;
        }
        if ($candidates.Count -gt 1) {
            Write-host "ok: command '$commandName' is ambiguous, did you mean:`n`t" -no
            #$candidates;
            $candidates | ForEach-Object {
                write-host "$($_) " -no -f yellow
            }
            return;
        }
        write-host "ok: No such command! " -f Yellow -NoNewLine
        write-host "Assume you meant: " -f gray -NoNewline
        write-host "'$($candidates[0])'" -f White -NoNewLine
        write-host "..." -f gray
        $command = $okFileInfo.commands[("" + $candidates[0])];
    }
    write-host "> " -f Magenta -NoNewline;
    Show-HighlightedOKCode -code $command.commandText -CommentOffset 0 -MaxKeyLength 0;
    write-host "";

    invoke-expression $command.commandText;
}

function Invoke-OK 
{
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
  param (
      [parameter(mandatory=$false, position=0)][string]$commandName,
      [parameter(
          mandatory=$false,
          position=1,
          ValueFromRemainingArguments=$true
       )]$arg
  )

    if (test-path ".\.ok-ps") {
        $file = ".\.ok-ps"

    } elseif (test-path ".\.ok") {
        $file = ".\.ok"
    } else {
        $file = $null;
    }
    if ($null -ne $file) {
        $okFileInfo = (Get-OKCommand $file);
        if ($null -eq $commandName -or $commandName -eq "") {
            Show-OKFile $okFileInfo;
        }
        else {
            Invoke-OKCommand -okfileinfo $okFileInfo -commandName $commandName -arg $arg;
        }
    }
}


# TODO: export alias from module;
Set-alias ok Invoke-OK;

# TODO: export from module:
# Invoke-OK
# Get-OKCommand
# Show-OKFile
# Invoke-OK

# Don't export
# Get-Token
# Get-CommandLength -- nah way too specific to deserve sharing
# Show-HighlightedOKCode -code $c.commandText -CommentOffset $commandInfo.commentOffset; -- too specific?
# Show-HighlightedCode
# Show-HighlightedToken
# Show-HighlightedOKToken
