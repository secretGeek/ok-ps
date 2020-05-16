# Todo items


- [x] Check if command name portions work.

	- When a fragment is not ambiguous:

			> ok t
			ok: No such command! Assume you meant: 'todo'...
			> n todo.md

	- When a fragment is not ambiguous:

			> ok tod
			ok: command 'tod' is ambiguous, did you mean:
						todoo todo

	- [ ] doeke suggests -- use levenshtein distance when checking command.

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


- [ ] don't put `("-" * commandNameLength)` dashes at start of comment line:
	- put spaces and then a '#'


- [ ] verbosity: do not show the existing command, or other guff, depends on verbose level.

- [x] Allow dots after the first character in names of commands.

- [x] ok help does nothing.
			- now help is returned if you run "ok help" (or any of these: ? /? -? --? /help --help -h --h /h)

- [ ] Trailing white space causes it to incorrectly measure location of final comment for some commands, and decide it is past the end.
		  e.g.
				3: ". .\profile.ps1" | clipp      # dot profile
			gets written
				3: ". .\profile.ps1" | clipp
				                             # dot profile

- [ ] Show number or name... numbers are not contiguous. And

- [ ] Make a TECHNOTES folder... for all the documentation
	- in the .ok for that folder use NPX markserve to let local users browse it... https://www.npmjs.com/package/markserv


## Bug ---

- [ ] a named command with no text after it produces this error:


     ts: Show-HighlightedOKCode : Cannot bind argument to parameter 'code' because it is an empty string.
At C:\users\leonb\Dropbox\secretGeek\util\Powershell\Scriptlets\ok\Invoke-OKCommand.ps1:129 char:42
+             Show-HighlightedOKCode -code $c.commandText -CommentOffse ...
+                                          ~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Show-HighlightedOKCode], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationErrorEmptyStringNotAllowed,Show-HighlightedOKCode


- [ ] when calculating longest command --- only consider commands that have a comment

- [x] when writing the command (at go time) it says the offset is 0 so it goes to a new line.... it shouldn't do that if offset is zero.

## Document:

	[ ] OK
		- how to tell VSCode that a .ok and .ok-ps file should be syntax highlighted as powershell. (or bash)
		- how to tell Notepad++ same.



## Comment-Based Help

[read about it here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help#comment-based-help-keywords)

invoke-ok:
	- [x] synopsis
	- [x] description
	- parameters:
		- each parameter
- related links
- notes
	- [ ] I am not sure what to put in notes. [online description](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help#notes)
- technical help
- help on parameters
- verbose -- pass this to children
  - use verbose to decide to... show or not show the command being run.
    - show or not show comments from the code.

			<CommonParameters>
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

## Consistent name for user commands

verbs
commands
custom commands
user commands
named commands


## Don't let user commands collide with reserved commands

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

If person


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

## Let ok-ps by default try .ok-ps and .okin succession.

- [ ] Let ok-ps by default try .ok-ps and .ok in succession.

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


