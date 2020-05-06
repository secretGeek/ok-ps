# Todo items

## Syntax highlighting

- [x] quotes around string tokens. (double?)

shows:

  2: echo arg

should be

	echo $arg


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


