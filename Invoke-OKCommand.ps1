#. (Join-Path $PSScriptRoot "Get-Token.ps1")
. (Join-Path $PSScriptRoot "Get-Token.ps1")
#. (Join-Path $PSScriptRoot "Get-CommandLength.ps1")
. (Join-Path $PSScriptRoot "Get-CommandLength.ps1")
#. (Join-Path $PSScriptRoot "Show-HighlightedCode.ps1")
. (Join-Path $PSScriptRoot "Show-OKCode.ps1")

Enum OKCommandType {
    Comment = 1
    Numbered = 2
    Named = 3
}

#$ReservedWords = @("reset","prompt","prompt_default","auto_show","comment_align","verbose","quiet","list","list-once","list-prompt","h","help","h");

Class OKCommandInfo {
    [int]$physicalLineNum # 1-based
    [OKCommandType]$type # what type of line is this? A comment, numbered or named
    [string]$commandText # everything other than the command name (if there is one)
    [int]$num # number of the command (if it is a name or number command only)
    [string]$key # either ("" + $number) or $commandName, i.e. "5" or "build"
    [System.Management.Automation.Language.Token[]]$tokens
    #[System.Management.Automation.PSToken[]]$tokens
    [int]$commentOffset # how many chars from the start of the command to the first comment token (useful to know this for aligning comments)
}

Class OKFileInfo {
    [string]$fileName; # fileName
    [System.Collections.Specialized.OrderedDictionary]$commands; # order dictionary of OKCommandInfo
    [OKCommandInfo[]]$lines; # Commands, in the order they are found in the file
    [int]$maxKeyWidth; # what is the widest command name
    [int]$commentOffset;
}

function Get-OKCommand($file) {
    # TODO: parameter validation
    $commands = [ordered]@{ };

    $lines = New-Object System.Collections.ArrayList
    [regex]$rx = "^[ `t]*(?<commandName>[A-Za-z_][A-Za-z0-9-_.]*)[ `t]*\:(?<commandText>.*)$";

    $num = 0;
    $physicalLineNum = 0;

    Get-Content $file | ForEach-Object {
        $line = $_.trim();
        $physicalLineNum = $physicalLineNum + 1;
        if ($null -eq $line -or $line -eq "") {
            # skip blank line
        }
        else {
            $commandInfo = New-Object OKCommandInfo
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
                    $num = $num + 1;
                    if ($null -ne $commands[$key]) {
                        # Name has already been used.
                        # (verbose: show warning)
                        <#
                        write-host "ok: duplicate commandname '" -f Red -no;
                        write-host "$key" -f white -no;
                        write-host "' mapped to " -f Red -no;
                        write-host "$num" -f white;
                        #>
                        # suggest
                        $commandInfo.type = [OKCommandType]::Numbered
                        $key = ("" + $num);
                    }
                    $commandInfo.num = $num;
                    $commandInfo.key = $key;
                }
                else {
                    $num = $num + 1;
                    $commandInfo.commandText = $line
                    $commandInfo.type = [OKCommandType]::Numbered
                    $commandInfo.key = ("" + $num);
                    $commandInfo.num = $num;
                }

                $maxKeyWidth = [math]::max( $maxKeyWidth , $commandInfo.key.Length);
                $commandInfo.Tokens = (Get-Token $commandInfo.commandText);
                $commands.Add($commandInfo.key, $commandInfo) | Out-Null;
            }
            $lines.Add($commandInfo) | Out-Null;
        }
    }

    # Suggestion: this could be much more configurable
    $alignComments = $true;
    if ($alignComments) {
        $maxCommandLength = ($commands.Values | ForEach-Object {
                [OKCommandInfo]$c = $_;
                # Only consider commands where the total width < console width

                if (($maxKeyLength + 2 + $c.CommandText.Length) -lt $Host.UI.RawUI.WindowSize.Width) {
                    $commandLength = (Get-CommandLength ($c.tokens));
                    $commentLength = ($c.CommandText.Length) - $commandLength;
                    if ($commentLength -gt 0) {
                        #write-host "commandLength $commandLength $($c.CommandText)" -f blue;
                        #write-host "commentLength $commentLength $($c.CommandText)" -f darkblue;
                        $commandLength;
                    }
                    else {
                        #write-host "commandLength $commandLength $($c.CommandText)" -f magenta;
                        0;
                    }
                }
                else {
                    0;
                }
            } | Measure-Object -Maximum | ForEach-Object Maximum);

        $maxCommentLength = ($commands.Values | ForEach-Object {
                [OKCommandInfo]$c = $_;
                $commandLength = (Get-CommandLength ($c.tokens));
                #$commandLength = (Get-CommandLength ($c.tokens));
                if ($commandLength -gt 0) {
                    # return the length of the comment.. (only counts if there *is* a command)
                    #write-host "commandLength $commandLength $($c.CommandText)" -f red;
                    ($c.key.length + 2) + ($c.CommandText.Length) - $commandLength;
                }
                else {
                    #write-host "No command... $($c.CommandText)" -f green;
                    0;
                }

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
    $okFileInfo.lines | ForEach-Object {
        [OKCommandInfo]$c = $_;
        if ($c.Type -eq [OKCommandType]::Comment) {
            Write-Host ("#" * ($maxKeyWidth)) -NoNewline -f DarkGray;
            Write-Host ": " -NoNewline -f Cyan;
            Write-Host $c.commandText.TrimStart().TrimStart('#').TrimStart() -f Green
        }
        else {
            Write-Host (" " * ($maxKeyWidth - $c.key.length)) -NoNewline
            if ($c.Type -eq [OKCommandType]::Numbered) {
                Write-Host $c.key -f DarkCyan -NoNewline
            }
            else {
                # writing a command.
                Write-Host $c.key -f Cyan -NoNewline
                <#
                $commandColor = [ConsoleColor]::Cyan;
                if ($c.key -eq "now") {
                    $commandColor = [ConsoleColor]::White;
                }
                elseif ($c.key -eq "today" -or $c.key -eq "todo" -or $c.key -eq "ttd") {
                    $commandColor = [ConsoleColor]::Yellow;
                }
                elseif ($c.key -eq "due" -or $c.key -eq "bug" -or $c.key -eq "error"  -or $c.key -eq "bugs" -or $c.key -eq "errors") {
                    $commandColor = [ConsoleColor]::Red;
                }
                elseif ($c.key -eq "search" -or $c.key -eq "find") {
                        $commandColor = [ConsoleColor]::Magenta;
                }
                elseif ($c.key -eq "build") {
                    $commandColor = [ConsoleColor]::DarkBlue;
                }
                elseif ($c.key -eq "publish" -or $c.key -eq "pub") {
                    $commandColor = [ConsoleColor]::Green;
                }
                elseif ($c.key -eq "plan" -or $c.key -eq "idea") {
                    $commandColor = [ConsoleColor]::Blue;
                }
                write-host $c.key -f $commandColor -NoNewline
                #>
            }
            Write-Host ": " -f Cyan -NoNewline
            Show-OKCode -code $c.commandText -CommentOffset $okFileInfo.commentOffset -MaxKeyLength $okFileInfo.MaxKeyWidth;
            Write-Host "";
        }
    }
}

function Invoke-OKCommand {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    param (
        [parameter(mandatory = $false, position = 0)][OKFileInfo]$okFileInfo,
        [parameter(mandatory = $false, position = 1)][string]$commandName,
        [parameter(
            mandatory = $false,
            position = 1,
            ValueFromRemainingArguments = $true
        )]$arg
    )

    #TODO: what if it's not a valid command?
    # see if it's "close" to valid... get candidates. If exactly 1 -- run it.
    # If more than 1 -- say "did you mean" and show those.
    # If it's less than 1 -- error... show file.
    if ($commandName -match "^[0-9]+$") {
        # it is a number.
        $commandIndex = ($commandName -as "int") - 1;
        $numCommands = (($okFileInfo.commands).Keys).Count;
        if ($commandIndex -ge 0 -and $commandIndex -lt ($numCommands)) { 
            $command = $okFileInfo.commands[$commandIndex];
        }
        else {
            $command = $null;
        }
    }
    else {
        $command = $okFileInfo.commands[("" + $commandName)];
    }
    if ($null -eq $command) {
        $candidates = New-Object System.Collections.ArrayList

        $okFileInfo.commands.keys |
            Where-Object { $_ -like ($commandName + "*") } |
            ForEach-Object {
                $candidates.Add($_) | Out-Null;
            }
        if ($null -eq $candidates -or $candidates.Count -eq 0) {
            Write-Host "ok: unknown command " -f Red -no
            Write-Host "'" -no;
            Write-Host "$commandName" -f yellow -no;
            Write-Host "'";
            Write-Host "(use 'ok' for a list of local commands, or 'ok help' for general commands)"
            return;
        }
        if ($candidates.Count -gt 1) {
            Write-Host "ok: command '$commandName' is ambiguous, did you mean:`n`t" -no

            $candidates | ForEach-Object {
                Write-Host "$($_) " -no -f yellow
            }
            return;
        }
        #TODO: check verbose
        Write-Host "ok: No such command! " -f Yellow -NoNewline
        Write-Host "Assume you meant: " -f gray -NoNewline
        Write-Host "'$($candidates[0])'" -f White -NoNewline
        Write-Host "..." -f gray
        $command = $okFileInfo.commands[("" + $candidates[0])];
    }

    #TODO: check verbose
    Write-Host "> " -f Magenta -NoNewline;
    #Show-HighlightedOKCode -code $command.commandText -CommentOffset 0 -MaxKeyLength 0;
    Show-OKCode -code $command.commandText -CommentOffset 0 -MaxKeyLength 0;
    Write-Host "";
    # Write command to history (but in comment form), so you can scroll up and see it there/edit it.
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory("# " + $command.commandText)
    # note arg is a list of object, and can be used in the commandText
    Invoke-Expression $command.commandText;
}

<#
.SYNOPSIS
Inspect or run commands from your ok-file

.DESCRIPTION
"Invoke-OK" (and the entire OK module) rely on first finding a file in the current folder called ".ok" (or ".ok-ps"), full of useful powershell one-liners you like to use in that folder.

 ("Invoke-OK" is usually called by its suggested alias, `ok`. That alias is used in the examples below.)

Call "ok" with **no parameters** and the ok-file will be `pretty printed`, with a number before each powershell one-liner.

Call "ok {number}" to run the line of code that corresponds to that number.

You can also have "named" commands. Just prefix the one-liner with a name and a colon, e.g. your ok file could contain:

    deploy: robocopy *.ps1 c:\launchplace /MIR

...then you would use `ok deploy` to run that robocopy command.

These one liners can accept parameters, for example, if your one-liner said:

    push: git add *; git commit . -m "$arg"; git push;

Then you could call: "ok push minor changes" to make a git commit with the message "minor changes"


.PARAMETER commandName
This optional command can specify the name or number of a user-command.

If specified, Invoke-OK will call Invoke-OKCommand and pass it the name of the command file and the commandName.

.PARAMETER arg

.NOTES

.EXAMPLE
ok
(Assuming you have the ALIAS "ok" for "Invoke-OK" ... because it's super useful!)

#>
function Invoke-OK {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    param (
        [parameter(mandatory = $false, position = 0)][string]$commandName,
        [parameter(
            mandatory = $false,
            position = 1,
            ValueFromRemainingArguments = $true
        )]$arg
    )

    if ($commandName -match "^(/|--|-|\\|)(h|\?|help)$") {
        Get-Help invoke-ok;
        return;
    }
    $file = (Get-OKFileLocation);

    if ($null -ne $file) {
        $okFileInfo = (Get-OKCommand $file);
        if ($null -eq $commandName -or $commandName -eq "") {
            Show-OKFile $okFileInfo;
        }
        else {
            Invoke-OKCommand -okFileInfo $okFileInfo -commandName $commandName -arg $arg;
        }
    }
    else {
        if ($null -ne $commandName -and '' -ne $commandName) {
            Write-Host "ok: No .ok or .ok-ps file in which to find this " -ForegroundColor red -NoNewline ;
            Write-Host "'" -ForegroundColor white -NoNewline ;
            Write-Host $commandName -ForegroundColor yellow -NoNewline ;
            Write-Host "'" -ForegroundColor white;
        }
    }
}

# all knowledge about how to probe for and determine the location of the ok-file is encapsulated in this function.
function Get-OKFileLocation () {
    if (Test-Path ".\.ok-ps") {
        return ".\.ok-ps"
    }

    elseif (Test-Path ".\.ok") {
        return ".\.ok"
    }

    return $null;
}

# TODO: export alias from module;
Set-Alias ok Invoke-OK;

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
