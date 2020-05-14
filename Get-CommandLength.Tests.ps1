$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-CommandLength" {
    It "Measures length of a single keyword" {
        $code = "dir";
        Get-CommandLength ($code | Get-Token) | Should -Be $code.Length
    }
    It "Do not ignore leading space" {
        $code = " dir";
        Get-CommandLength ($code | Get-Token) | Should -Be $code.Length
    }
    It "Do Ignore trailing space (before first comment)" {
        $code = "dir  ";
        Get-CommandLength ($code | Get-Token) | Should -Be $code.TrimEnd().Length
    }
    It "Do not ignore internal space within a command" {
        $code = "dir   *.*";
        Get-CommandLength ($code | Get-Token) | Should -Be $code.Length
    }
    It "Simple Variable, Operator, Number" {
        $code = "`$x = 3";
        Get-CommandLength ($code | Get-Token) | Should -Be $code.Length
    }
    It "Simple Variable, Operator, Number, Comment" {
        $code = "`$x = 3 # Hi!";
        #$code | Get-Token | ft | out-host;
        Get-CommandLength ($code | Get-Token) | Should -Be ($code.Split("#")[0].TrimEnd().Length)
    }
    It "Complex comment" {
        $code = "`$x = 3 <# Hi! #>";
        Get-CommandLength ($code | Get-Token) | Should -Be ($code.Split("<#")[0].TrimEnd().Length)
    }
    It "Code with dollar embedded in quotes" {
        $code = ".\publish.ps1 `"`$arg`";  # commit and push";
        #$code | Get-Token | ft | out-host;
        Get-CommandLength ($code | Get-Token) | Should -Be ($code.Split("#")[0].TrimEnd().Length)
    }

    It "Code with comment embedded in quotes" {
        $code = "echo `"#`"    # commit and push";
        $parts = $code.Split("#");
        $expected = ($parts[0].Length + "#".Length + $parts[1].TrimEnd().Length)
				#write-host $code
				#write-host "Expected length: $expected";
        Get-CommandLength ($code | Get-Token) | Should -Be $expected;
    }
		#". .\profile.ps1" | clipp
#"`". .\profile.ps1`" | clipp"
		It "This one fails in the wild" {
        $code = "`". .\profile.ps1`" | clipp # dot profile";
        #$code | Get-Token | ft | out-host;
        Get-CommandLength ($code | Get-Token) | Should -Be ($code.Split("#")[0].TrimEnd().Length)
    }
}
