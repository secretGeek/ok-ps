. (Join-Path $PSScriptRoot "Get-TokenColor.ps1")

function Show-OKToken {
	Param(
		[Parameter(Mandatory,
			ValueFromPipeline = $true,
			HelpMessage = 'Tokens to be highlighted',
			Position = 0)]
		[System.Management.Automation.Language.Token[]]$Tokens,

		$charNumX,

		[bool]$debugMode = $false,
		[int]$CommentOffset,
		[int]$MaxKeyLength

	)
	Begin {
		$commentShown = $false;
		$charNum = $host.UI.RawUI.CursorPosition.X;

		if ($null -ne $charNumX) {
			$charNum = $charNumX;
		}
		else {
			if ($charNum -eq 0) { $charNum = 1; }
		}
		$lineNum = 1;

		if ($null -ne $Tokens -and $Tokens[0].Extent.StartLineNumber -gt 1) {
			$lineNum = $Tokens[0].Extent.StartLineNumber;
		}
	}
	Process {
		ForEach ($token in $tokens) {
			$tokenColor = (Get-TokenColor $token.Kind $token.TokenFlags $debugMode);

			if ($token.Extent.StartLineNumber -gt $lineNum) {
				$charNum = 1;
			}

			# if ($token.Extent.StartColumnNumber -gt $charNum) {
			# 	$numSpaces = ($token.Extent.StartColumnNumber - $charNum);

			# 	#Write-Host (" " * $numSpaces) -NoNewline;
			# 	Write-Host ("_" * $numSpaces) -NoNewline -f blue;
			# 	$charNum += $numSpaces;
			# }

			if ($commentShown -eq $false -and $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
				$numSpaces = ($CommentOffset - $charNum);
				$commentShown = $true;
				if ($numSpaces -gt 0) {
					#Write-Host ("_" * $numSpaces) -NoNewline -f red;
					Write-Host (" " * $numSpaces) -NoNewline;
				}
			}
			else {
				if ($token.Extent.StartColumnNumber -gt $charNum -and $token.Kind -ne [System.Management.Automation.Language.TokenKind]::EndOfInput	) {
					$numSpaces = ($token.Extent.StartColumnNumber - $charNum);

					Write-Host (" " * $numSpaces) -NoNewline;
					#Write-Host ("_" * $numSpaces) -NoNewline -f blue;
					$charNum += $numSpaces;
				}
			}

			if ($null -ne $token.NestedTokens) {

				# NESTED TOKENS ARE FUN
				# Strings (and here-strings) can contain nested tokens (as do nested expressions)
				#
				# write-host "This is my name $myName and yours is $yourName I believe!"
				#            |-----------------outer token ----------------------------| <-- $token
				# write-host "This is my name $myName and yours is $yourName I believe!"
				#                             |--t1-|              |---t2--|             <-- $token.NestedTokens
				# write-host "This is my name $myName and yours is $yourName I believe!"
				#            |----between1----|     |---between2---|                     <-- between Nested tokens
				# write-host "This is my name $myName and yours is $yourName I believe!"
				#                                                           |---after--| <-- after Nested tokens
				#
				# Observations:
				# - there are as many 'betweens' as there are nested tokens.
				# - there is exactly 1 'after'.
				# - the quotes (which differ from string, to herestring etc.) are part of between1 and after.

				$tokenStartOffset = $token.Extent.StartOffset;
				$upTo = $tokenStartOffset;
				ForEach ($innerToken in $token.NestedTokens) {
					if ($innerToken.Extent.StartOffset -gt $upTo) {
						# write the part of the 'outer token' that comes before the first nested token, or:
						# write the between:
						if ($token.Text.length -ge ($innerToken.Extent.StartOffset - $tokenStartOffset)) {
							Write-Host ($token.Text.Substring($upTo - $tokenStartOffset, $innerToken.Extent.StartOffset - $upTo)) -f $tokenColor -n;
						}
						else {
							#Write-Host "XX" -f red -n; (wonder if this is end of input?)
						}
					}

					Show-OKToken $innerToken -charNumX:$innerToken.Extent.StartColumnNumber -debugMode:$debugMode -CommentOffset $CommentOffset -MaxKeyLength $MaxKeyLength;
					$upTo = $innerToken.Extent.EndOffset;
				}

				if ($upTo -lt ($token.Text.Length + $tokenStartOffset)) {
					# Write the 'after' (see section above)
					Write-Host $token.Text.Substring($upTo - $tokenStartOffset) -f $tokenColor -n;
				}
			}
			else {
				if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
					Write-Host ($token.Text.TrimStart()) -ForegroundColor $tokenColor -NoNewline
				}
				else {
					Write-Host ($token.Text) -ForegroundColor $tokenColor -NoNewline
				}
			}

			$lineNum = $token.Extent.EndLineNumber;
			$charNum = $token.Extent.EndColumnNumber;
		};
	}
	End {
	}
}
