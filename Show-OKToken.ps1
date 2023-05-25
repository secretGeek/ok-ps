. (Join-Path $PSScriptRoot "Get-OKTokenColor.ps1")
. (Join-Path $PSScriptRoot "Show-OKName.ps1")

# Write a scrap of text, that is part of a token (may be the entire token)
function Write-OKScrap ( $scrap , $token, $debugMode) {
	$tokenColor = (Get-OKTokenColor $token.Kind $token.TokenFlags $debugMode);
	$quoteColor = "Cyan";

	# Controversial! Write '$' and '#' (at start of Variable and Comment respectively)
	#  in a different color to the rest of the variable/comment.
	if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -and
		$scrap -like '$*') {
		$dollarColor = "Cyan";
		Write-Host '$' -ForegroundColor $dollarColor -NoNewline
		$secondTokenColor = "DarkCyan";

		Show-Name ($scrap.Substring(1)) -ForegroundColor $tokenColor -SecondForeGroundColor $secondTokenColor -NoNewline
	}
	elseif ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
		$scrap -like '#*') {
		Write-Host '#' -ForegroundColor Green -NoNewline
		Write-Host ($scrap.Substring(1)) -ForegroundColor $tokenColor -NoNewline
	}
	elseif (
		($token.Kind -eq [System.Management.Automation.Language.TokenKind]::StringExpandable -or
		$token.Kind -eq [System.Management.Automation.Language.TokenKind]::StringLiteral -or
		$token.Kind -eq [System.Management.Automation.Language.TokenKind]::HereStringExpandable) -and
		($scrap -like '"*' -or $scrap -like '*"' -or $scrap -like '''*' -or $scrap -like '*''')) {
		if ($scrap -like '"*' -or $scrap -like '''*') {
			Write-Host ($scrap.Substring(0, 1)) -ForegroundColor $quoteColor -NoNewline
		}
		else {
			Write-Host ($scrap.Substring(0, 1)) -ForegroundColor $tokenColor -NoNewline
		}
		if ($scrap -like '*"' -or $scrap -like '*''' -and $scrap.length -gt 1) {
			Write-Host ($scrap.Substring(1, $scrap.Length - 2)) -ForegroundColor $tokenColor -NoNewline
			Write-Host ($scrap.Substring($scrap.Length - 1)) -ForegroundColor $quoteColor -NoNewline
		}
		elseif ($scrap.length -gt 1) {
			Write-Host ($scrap.Substring(1)) -ForegroundColor $tokenColor -NoNewline
		}
	}
	else {
		Write-Host ($scrap) -ForegroundColor $tokenColor -NoNewline
	}
}


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
			#$tokenColor = (Get-TokenColor $token.Kind $token.TokenFlags $debugMode);

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
				if ($CommentOffset -ge 0) {
					$numSpaces = ($CommentOffset - $charNum);
				}
				else {
					# the value -1 (for example) means '1 actual space' (not the X offset from left of screen)
					$numSpaces = $CommentOffset * -1;
				}
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
							#Write-Host ($token.Text.Substring($upTo - $tokenStartOffset, $innerToken.Extent.StartOffset - $upTo)) -f $tokenColor -n;
							Write-OKScrap ($token.Text.Substring($upTo - $tokenStartOffset, $innerToken.Extent.StartOffset - $upTo)) $token $debugMode;
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
					#Write-Host $token.Text.Substring($upTo - $tokenStartOffset) -f $tokenColor -n;
					Write-OKScrap $token.Text.Substring($upTo - $tokenStartOffset) $token $debugMode;
				}
			}
			else {
				if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
					#Write-Host ($token.Text.TrimStart()) -ForegroundColor $tokenColor -NoNewline
					Write-OKScrap ($token.Text.TrimStart()) $token $debugMode;
				}
				else {
					Write-OKScrap ($token.Text.TrimStart()) $token $debugMode;
					#Write-Host ($token.Text) -ForegroundColor $tokenColor -NoNewline
				}
			}

			$lineNum = $token.Extent.EndLineNumber;
			$charNum = $token.Extent.EndColumnNumber;
		};
	}
	End {
	}
}
