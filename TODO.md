# Todo items

## Publish as module

See [what is a module](https://til.secretgeek.net/powershell/module_what_is_it.html) and [how to publish a module](https://til.secretgeek.net/powershell/publish_module.html)

* [ ] Make a module
	* [ ] Implement a module `.psm1` file
	* [ ] Ensure correct exports
	* [ ] Requires renaming 
* [ ] Publish a module


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
