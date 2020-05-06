
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Show-HighlightedCode" {

    Mock Write-Host {};

    It "Outputs accurate code in a simple case" {
        $code = "dir";
        Show-HighlightedOKCode $code ($code.Length + 10);
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq $code }
    }

    It "Outputs accurate code with trailing trimmed" {
        $code = "dir ";
        #Mock Write-Host {};
        Show-HighlightedOKCode $code -CommentOffset ($code.Length + 10);
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq $code.TrimEnd() }
    }

    It "Outputs accurate code with leading space not trimmed" {
        $code = " dir";
        $commentOffset = $code.Length + 100;
        Get-Token $code | Show-HighlightedOKToken -CommentOffset $CommentOffset | out-null
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq " " }
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "dir" }
    }

    It "Outputs accurate code with leading space not trimmed and second token" {
        $code = " dir *.*";
        $commentOffset = $code.Length + 100;
        Get-Token $code | Show-HighlightedOKToken -CommentOffset $CommentOffset | out-null
        Assert-MockCalled Write-Host -Exactly 2 -Scope It -ParameterFilter { $Object -eq " " }
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "dir" }
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "*.*" }
    }

    It "Outputs accurate code including variables" {
        $code = "echo `$arg";
        $commentOffset = $code.Length + 100;
        Get-Token $code | Show-HighlightedOKToken -CommentOffset $CommentOffset | out-null
        #Get-Token $code | ft | out-host;
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "echo" }
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq " " }
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "`$arg" }
    }


}
