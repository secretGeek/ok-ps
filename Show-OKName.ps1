. (Join-Path $PSScriptRoot "Get-OKTokenColor.ps1")

# 					Show-Name ($token.Text.Substring(1)) -ForegroundColor $tokenColor -NoNewline
#Show-Name ($token.Text.Substring(1)) -ForegroundColor $tokenColor -NoNewline

# Javascript version:
# String.prototype.toWords = function (): string {
#     return this.replace(/([a-z])([A-Z])/gm, "$1 $2");
# };
# /([a-z])([A-Z])/gm, "$1 $2"


# Inspired by Steve Gilham here -- excellent work. https://stevegilham.blogspot.com/2011/06/splitting-pascal-cased-names-in.html
function OKPascalSplit {
    $args | ForEach-Object {
        if ($_ -is [array]) {
            return ($_ | ForEach-Object { PascalSplit $_ });
        }
        else {
            #return ($_.ToString() -creplace '[A-Z:_]', ' $&').Trim().Split($null);
            # CONSIDER:
            return ($_.ToString() -creplace '(?<!^)([A-Z:_][a-z]|(?<=[a-z])[A-Z:_])', ' $&').Split($null);
        }
    }
}


function Show-OKName {
    Param(
        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            HelpMessage = 'PascalCased Name to be shown (with words in alternating colors)',
            Position = 0)]
        [String]$Name,
        [Alias("f")][System.ConsoleColor]$ForeGroundColor = [ConsoleColor]::Cyan,
        [Alias("s")][System.ConsoleColor]$SecondForeGroundColor = [ConsoleColor]::DarkCyan,
        [Alias("N")][Switch]$NoNewLine = $null,

        #$charNumX,

        [bool]$debugMode = $false
    )
    Begin {
    }
    Process {

        (OKPascalSplit $Name |
			ForEach-Object {
				Write-Host "$_" -N -ForegroundColor $(if ($i++ % 2 -eq 0) {
					$ForeGroundColor
				} else { $SecondForeGroundColor }); });
    }
    End {
    }
}
