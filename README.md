# ok-ps

## "ok" gives you .ok folder profiles for powershell

(There is also a [bash version](https://github.com/secretGeek/ok-bash/))

`ok` makes you smarter and more efficient.

Do you work on many different projects? And in each project, are there commands or URLs you use that are specific to that project? You need a `.ok` file.

A `.ok` file is a place to store any handy one-liners specific to the folder it is in. It can be viewed with a simple command. And commands in the `.ok` file can be executed immediately with the command `ok {number}` (example, `ok 3` to run the 3rd command.)

Imagine your `.ok` file contains these three lines:

    build.ps1 # builds the project
    deploy.ps1 # deploys the project
    commit_push.ps1 $arg[0] # commit with comment, rebase and push

A `.ok` file acts as a neat place to document how a given project works. This is useful if you have many projects, or many people working on a project. It's such a little file; it's quick to write, follows a [specification](#language-specification) (still in draft) and easy to edit.

But it's not just a document, it's executable.

If you run the command `ok` (with no parameters) you'll see the file listed, with numbers against each command:

    > ok
    1: build.ps1             # builds the project
    2: deploy.ps1            # deploys the project
    3: commit_push.ps1 $arg  # commit with comment, rebase and push

Then if you run `ok {number}` (ok followed by a number) you'll execute that line of the file.

	> ok 1
	> build.ps1 # builds the project
	building.....

And you can pass simple arguments to the commands. For example:

	> ok 3 Added laser guidance system
    > commit_push.ps1 $arg # commit with comment, rebase and push

	Committing with comment "Added laser guidance system"
	Commit succeeded.
	Rebase successful
	Pushing to master.


💡 Tip: "." (i.e. source) the "Invoke-OKCommand.ps1" script from your `$profile`, e.g:

    . .\Invoke-OKCommand.ps1

It will give you the `ok` command (which is really an alias to `Invoke-OK`)


## .ok file specficiation

An ok file consists of lines of text.

each line is finished by a line break, or an end of file marker.

each line either:

- starts with a '#' character - indicating it is a comment. (can be preceeded by whitespace - spaces, tabs etc.)
- or starts with a "command name" followed by a colon. A command name followed by a colon is currently identified by this regex:

        [regex]$rx = "^[ `t]*(?<commandName>[A-Za-z_][A-Za-z0-9-_.]*)[ `t]*\:(?<commandText>.*)$";

- or matched neither of the above... in which case it is treated as a command. (like the command above, but with a number as its name.)
    - it will be a command in whatever language your implementation of .ok is using.

- (the target language can be specified in a .ok-config file, either locally or in your "ok-home" or in your "~", with precedence/rank descending in that order.)

- if the instance of .ok is specified to use a language you don't have, then you can look for an executor for that language at ok central or another repository system. i have "readers" for every package system. I have plugins for those other package systems.

- the package downloaded from ok central should include sufficient instructions that given my current language and my target language it can determine the relevant steps to perform. it might be... The .ok download language is specified in the .ok "systems family of languages" document.

- it is being translated into many languages including "angry teenager."



-----

See <https://secretgeek.net/ok> for the blog post launching (and describing) "ok"
