# with no parameter: looks in the current folder for a ".ok" file, and lists its commands numbered
# with a number parameter, runs the relevant command from the .ok file, e.g. "ok 1" runs first line of ".ok" file
function ok([parameter(mandatory=$false, position=0)]$number,
	[parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$Remaining
) {

  # this is a private function used by ok
  # given a filename (full of commands) and a number (possibly null) and some remaining parameters: 
  # invoke the numbered command (if a number was given) or list the commands in the file (with numbers)
  function ok_file($file, $number, $Remaining) {
    $commands = @{};
    $num = 0;
    cat $file | % {
      $line = $_.trim();
      if ($line -ne "" -and $line -ne $null) { 
        $num = $num + 1;
        $commands.Add(("" + $num), $line);
      }
    }
    if ($number -ne $null -and $num -ge 1 -and $number -le $num) {
      # INVOKE the command...
      write-host -NoNewline "> " -foregroundcolor "green" # impersonate prompt...
      write-host $commands[("" + $number)] -foregroundcolor "white"
      #invoke-expression  ($commands[('' + $number)] + " $Remaining")
	  invoke-expression  $commands[("" + $number)] 
    } else {
      # LIST the commands
      $commands.GetEnumerator() | sort Name | % { 
        write-host -NoNewline ($_.Name + ". ") -foregroundcolor "white"
        $line = $_.Value
        if ($line.indexOf('#') -gt 0) {
        
          # write things before the # in one color and things after in green
          write-host -NoNewline (($line -split '#')[0])
          write-host $line.substring($line.indexOf('#')) -foregroundcolor "green"
          # write-host -NoNewline ($_.Name + ". ") -foregroundcolor "white"
        } else {
          write-host $_.Value
        }
        #$_.Name + ". " + $_.Value
      }
    }
  }
  
  if (test-path ".\.ok") { ok_file ".\.ok" $number $Remaining}
}

# Remove the 'cd' alias, so our function can take over...
if (test-path alias:cd) {	
	Remove-Item alias:cd -Force
}

# We create our `cd` function as a wrapper around set-location that calls 'ok'
function cd ([parameter(ValueFromRemainingArguments = $true)][string]$Passthrough) {
  Set-Location $Passthrough
  ok # Call 'ok'
  if ((get-date).DayOfWeek -eq "Friday") { 
	check-timesheet;  
  }
}
# consider: do the same for pushd and popd...?
