# Todo items

**TOC**

- [Done for next release (and or, unpublicised)]
- Inbox (unclassified)
- [Highest Priority]
- [DONE] (somewhere after line 207)

# Done for next release (and or, unpublicised)


# Inbox (unclassified)


- If there's a .ok-icon file -- we show that apparently.
- If there's a .ok-showsummary -- we apply a show summary script (not currently editable but open source.)
	- if should be pretty easy to understand.
	- First it applies a rule... if we've just jumped into a folder, is there a file called ".ok-showSummary" present? Then we run the built in script, ok-showSummary -- and it does the following.
	
	- We run the locally sourced script - ok-showsummary.
	
	- Here's it's content.
	
	- parse the .ok file. If it's less than 15 rows, show at most the first 7 rows. Probably clear the screen first -- or write it in a part of the screen that doesn't seem to be in USE.
		- If there's a currently running panel that has publicly registered an interest in subscribing to messages from a panel provider - and has been booked out by an accepted subscription request -- or has other licensing arrangements that let it run the panel on the current screen -- then it would broadcast to and it would be received and processed and displayed.
		
	- BEST format to speak to the dashboard:
	
	
		- Customers - Projects - Tasks - Apps - SLOs
			- OKAY the SLOS should be visually indicative of how many things we have booked in -- and how long until each of tehm expire.
			- Next thing to expire is shown on first half of the panel square's background... A "brightness" indicator for how long until it expires.
			- Everything should have varying brightness based on intensity -- even if it is successful. i.e. Whether green or red or an icon or a hyperlink -- what is the likelihood that you want to click on this?
				- THAT is the calculation for brightness.
				- How extraordinary is the current value?
					- Caluclate that (by each component also looking at and rating their sub components AND OR rating itself by askig its parent what it's rating is.)
				
					
			
		

- [ ] Look at all the lines that are longer than screen -
	- find common substrings between any lines
		- the removal of which would help the total numbers of
		"rows wider than the screen in width" would be reduced to zero.
	- draw those separately in two other colors like this:

		[[SHORTNAME]] dkcsjncscjsijcnsnclksnclksnclksnclkjsnclkjsnljknscklsc
		^^ MAGENTA    ^^ "BRIGHT" YELLOW



[ ] `ok *` or `ok f*` should

	1. search for any command that broadly matches the description

		::- list them, with new numbering.

		::- note that this would only happen if the first parameter contains a wildcard, e.g. `* or ?` (consider: a regex delimited with slashes, such as `/.*/` 's)

		::- handle `ok pattern number` for running the thing with that new number.

		e.g.   we type `ok f*` and see:

		1. find $args
		2. file-new $args
		3. format C: --force --override --accept-all-defaults

And if you then type:

		ok f* 2

...by pressing up, typing " 2" and enter...

... then it will run that `file-new $args` command -- taking any other remaining arguments for the command,

.e.g. `ok f* 2 README.md` would call that command `file-new` and pass it the argument `README.md`.

(The listed command could be anything. `file-new` for example is not a standard name and may indicate anything at all -- it could be a script that will format C:.)






[ ] 'help ok' calls 'help okwrapper' on my system...
	it should have a remark that tells you to try 'help invoke-ok'
	for detailed help on the ok system.

[x] Tokenizing issues... rewriting syntax highlighter! https://til.secretgeek.net/powershell/tokenize_issue.html


[defer] ok writes the current line to history. has a bug
	- BUG is: if the current line contains a tab character - it writes that as "^I"
	test:write-host "thing"		# hello
	is displayed as:
	test:write-host "thing"^I^I# hello
	...though if you copy and paste it, it becomes a "	"
	Write-Host "thing"		# hello
	(that's a bug in either powershell or console... not mine.)

# Highest priority

- [x] - [ ] bug in Invoke-OKCommand -
	Given a .ok file with a line this line "\ninit: \n" -- this error occurs.

		Get-Token : Cannot bind argument to parameter 'code' because it is an empty string.
		At C:\apps\Nimble\gh\util\Powershell\Scriptlets\ok\Invoke-OKCommand.ps1:88 char:50
		+ ...           $commandInfo.Tokens = (Get-Token $commandInfo.commandText);
		+                                                ~~~~~~~~~~~~~~~~~~~~~~~~
			+ CategoryInfo          : InvalidData: (:) [Get-Token], ParameterBindingValidationException
			+ FullyQualifiedErrorId : ParameterArgumentValidationErrorEmptyStringNotAllowed,Get-Token

		Get-CommandLength : Cannot bind argument to parameter 'Tokens' because it is null.
		At C:\apps\Nimble\gh\util\Powershell\Scriptlets\ok\Invoke-OKCommand.ps1:103 char:57
		+                     $commandLength = (Get-CommandLength ($c.tokens));
		+                                                         ~~~~~~~~~~~
			+ CategoryInfo          : InvalidData: (:) [Get-CommandLength], ParameterBindingValidationException
			+ FullyQualifiedErrorId : ParameterArgumentValidationErrorNullNotAllowed,Get-CommandLength

		Get-CommandLength : Cannot bind argument to parameter 'Tokens' because it is null.
		At C:\apps\Nimble\gh\util\Powershell\Scriptlets\ok\Invoke-OKCommand.ps1:122 char:53
		+                 $commandLength = (Get-CommandLength ($c.tokens));
		+                                                     ~~~~~~~~~~~
			+ CategoryInfo          : InvalidData: (:) [Get-CommandLength], ParameterBindingValidationException
			+ FullyQualifiedErrorId : ParameterArgumentValidationErrorNullNotAllowed,Get-CommandLength

- [ ] Show number or name... numbers are not contiguous.

- [ ] Make a TECHNOTES folder... for all the documentation
	- in the .ok for that folder use NPX markserve to let local users browse it... https://www.npmjs.com/package/markserv
		- describe all options and error messages


- [ ] Config...
	- [ ] need a sample script to read/write json settings (simple booleans) in a localappdata subfolder named ok-ps.
	- [ ] Given a parameter of "get-okconfiglocation", ok will tell the folder where it's config file is stored.
				each config file in that location is only loaded for a first time when certain events occur within ok. those files will be named like "{event}-ok-config.json" where event is a documented event name. Currently the


	- [ ] Command Name Error Handling and edge cases

			doeke suggests -- use levenshtein distance when checking command.

		- I guess in this case it would suggest 'todo' --

				> OK ODO
				ok: unknown command 'ODO'

	- [ ] What if a name given is TOO long... e.g.
			> OK todoooo

		-	...mercurial would do this:

				> hg pulllll
				hg: unknown command 'pulllll'
				(did you mean pull?)

		[ ] similarly, even when there's no common prefix..

				> hg patents
				hg: unknown command 'patents'
				(did you mean one of parents, paths, update?)

		- both the previous can be solved with levenshtein I expect.




- [ ] verbosity: do not show the existing command, or other guff, depends on verbose level.
	- see how -verbose works -- and review every write-host.




## Bug ---

- [ ] a named command with no text after it produces this error:


		ts: Show-HighlightedOKCode : Cannot bind argument to parameter 'code' because it is an empty string.
		At C:\users\leonb\Dropbox\secretGeek\util\Powershell\Scriptlets\ok\Invoke-OKCommand.ps1:129 char:42
		+             Show-HighlightedOKCode -code $c.commandText -CommentOffse ...
		+                                          ~~~~~~~~~~~~~~
				+ CategoryInfo          : InvalidData: (:) [Show-HighlightedOKCode], ParameterBindingValidationException
				+ FullyQualifiedErrorId : ParameterArgumentValidationErrorEmptyStringNotAllowed,Show-HighlightedOKCode


	- [ ] maybe just 'silentlyContinue on those, with null token. '(Get-Command "ConvertTo-Json" -errorAction SilentlyContinue)


## Document:

- [ ] OK
		- how to tell VSCode that a .ok and .ok-ps file should be syntax highlighted as powershell. (or bash)
		- how to tell Notepad++ same.

## Comment-Based Help

i.e. 'help ok' should return meaningful stuff.

[read about it here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help#comment-based-help-keywords)

invoke-ok:
	- [ ] parameters:
		- [ ] each parameter
- [ ] related links
- notes
	- [ ] I am not sure what to put in notes. [online description](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help#notes)
- technical help
- help on parameters
- verbose -- pass this to children
  - use verbose to decide to... show or not show the command being run.
    - show or not show comments from the code.

			This cmdlet supports the common parameters:
				Verbose,
				Debug,
				ErrorAction,
				ErrorVariable,
				WarningAction,
				WarningVariable,
				OutBuffer,
				PipelineVariable, and
				OutVariable.

				For more information, see
				about_CommonParameters
				(https:/go.microsoft.com/fwlink/?LinkID=113216).
				--------- EXAMPLE 1 ---------
				PS C:\>.\verb-noun.ps1 "TERROR!"


## Syntax highlighting

- [x] quotes around string tokens. (double?)

shows:

  2: echo arg

should be

	echo $arg

## User commands and numbers -- intermix properly per doeke's plan

## Consistent name for named commands

commands and named commands.

not
- verbs
- custom commands


## Don't let named commands collide with reserved words

from `ok-bash` -- all of these are used, so reserve them for future use.
(any others?)

	reset
	prompt
	prompt_default
	auto_show
	comment_align N
	verbose
	quiet
	l
	list
	L
	list-once
	p
	list-prompt
	h
	help
	?, /? -? --? -h --h  (maybe these too)


## Publish as module

Defer until after commands/syntax/etc.

See [what is a module](https://til.secretgeek.net/powershell/module_what_is_it.html) and [how to publish a module](https://til.secretgeek.net/powershell/publish_module.html)

- [ ] Make a module
	- [ ] Implement a module `.psm1` file
	- [ ] Ensure correct exports
	- [ ] Requires renaming
- [ ] Publish to the powershell gallery
	- see https://mcpmag.com/articles/2017/03/16/submit-module-to-the-powershell-gallery.aspx?m=1

- note modules can export aliases
- see https://stackoverflow.com/questions/5677136/how-to-export-powershell-module-aliases-with-a-module-manifest

## Let ok-ps by default try .ok-ps and .ok in succession.

- [x] Let ok-ps by default try .ok-ps and .ok in succession.

# DONE

**EVERYTHING BELOW HERE IS DONE**

## Done: Fix all warnings from Script Analyzer

See output from:

	Invoke-ScriptAnalyzer .\_ok.ps1

Several related commands are now in the local .ok file.

### Warning: `PSAvoidUsingWriteHost`

This is my most common issue. See discussion here: https://github.com/PowerShell/PSScriptAnalyzer/issues/267

> Avoid using Write-Host because it might not work in all hosts, does not work when there is no host, and (prior to PS 5.0) cannot be suppressed, captured, or redirected. Instead, use Write-Output, Write-Verbose, or Write-Information.

Eleven of these warnings... suppressed with:

	Invoke-ScriptAnalyzer .\_ok.ps1 -ExcludeRule PSAvoidUsingWriteHost



### Warning: `PSAvoidUsingCmdletAliases`

Ok, they got me here. I must fix these in published work.

Replaced `%` with `ForEach-Object`
Replaced `type` with `Get-Content` (i sometimes use `cat` too.)

But honestly, which line is better out of these two......

	cat $file | % {
	Get-Content $file | ForEach-Object {

I guess only the second is "readable" but the first is more "typable"


### Warning: `PSPossibleIncorrectComparisonWithNull`

Apparently "$null should be on the left side of equality comparisons"

Changed anything like `$number -ne $null` to`$null -ne $number`

### Information: `PSAvoidTrailingWhitespace`

Ok fixed these, my personal enemies.


### Warning: `PSAvoidUsingInvokeExpression`

Ah, well this is deliberate. So I need to put a `please ignore` on this one.

	function ok {
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]

Done. Though I'd rather put it somewhere closer to the invoke.

### Information: `PSAvoidUsingPositionalParameters`

Changed:

	ok_file ".\.ok" $number $arg

To:

	ok_file -file ".\.ok" -number $number -arg $arg




## Feature Parity with ok-bash

[ok-bash](https://github.com/secretGeek/ok-bash) has a lot of amazing features thanks to [doeke](https://github.com/secretGeek/ok-bash/commits?author=doekman)

Where appropriate they should be incorporated into `ok-ps`.


## Name commands and use helper functions to call those names.

done.

* Get-OKCommand
* Invoke-OKCommand






- [x] Check if command name portions work.

	- When a fragment is not ambiguous:

			> ok t
			ok: No such command! Assume you meant: 'todo'...
			> n todo.md

	- When a fragment is not ambiguous:

			> ok tod
			ok: command 'tod' is ambiguous, did you mean:
						todoo todo

## DONE:

10:09 AM Saturday, 27 February 2021


- [x] don't put `("-" * commandNameLength)` dashes at start of comment line:
	- put spaces and then a '#'

- [x] Allow dots after the first character in names of commands.

- [x] ok help does nothing.
			- now help is returned if you run "ok help" (or any of these: ? /? -? --? /help --help -h --h /h)

- [x] Trailing white space causes it to incorrectly measure location of final comment for some commands, and decide it is past the end.
		  e.g.
				3: ". .\profile.ps1" | clipp      # dot profile
			gets written
				3: ". .\profile.ps1" | clipp
				                             # dot profile

- [x] when calculating longest command -- only consider commands that have a comment

- [x] when writing the command (at go time) it says the offset is 0 so it goes to a new line.... it shouldn't do that if offset is zero.


- Comment based help (i.e. "help invoke-ok")
	- [x] synopsis
	- [x] description

