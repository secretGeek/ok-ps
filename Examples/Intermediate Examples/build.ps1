# Call this with "ok build"
$messages = 
	"Building code...",
	"Reticulating splines....",
	"Calculating vectors...",
	"Deleting files...",
	"Ooops....",
	"Restoring files....",
	"Trying to look busy....",
	"Have you ever noticed...",
	"The way people will patiently wait...",
	"For a script to finish...",
	"Never sure if they should just press Ctrl-C...",
	"Or if it will go on for ever...",

$messages | Foreach-Object {
	Write-host $_ 
	Start-Sleep 1
}

ok build; # Yeh it calls itself and does go on forever. Use Ctrl C to exit.


