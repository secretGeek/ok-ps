function Get-OKTokenColor([System.Management.Automation.Language.TokenKind]$tokenKind,
    [System.Management.Automation.Language.TokenFlags]$tokenFlags, $debugMode = $false) {

    if ($debugMode) {
        Write-Host "<# tk: $tokenKind, Tf: $tokenFlags #>" -f DarkMagenta -n;
    }

    # [Enum]::GetValues([System.Management.Automation.Language.TokenKind])
    # [Enum]::GetValues([System.Management.Automation.Language.TokenFlags])

    # First, we check the token kind...
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Number) {
        return [System.ConsoleColor]::White;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Variable) {
        return [System.ConsoleColor]::Cyan; #Green;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Parameter) {
        return [System.ConsoleColor]::DarkGray;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::SplattedVariable) {
        return [System.ConsoleColor]::Green;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Redirection) {
        return [System.ConsoleColor]::White;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::NewLine) {
        return [System.ConsoleColor]::Gray;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
        return [System.ConsoleColor]::DarkGreen;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Param) {
        return [System.ConsoleColor]::Green;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Function) {
        return [System.ConsoleColor]::Green;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::StringExpandable -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::StringLiteral -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::HereStringExpandable
    ) {
        return [System.ConsoleColor]::DarkCyan;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::LBracket -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::RBracket) {
        return [System.ConsoleColor]::DarkGray; # another operator
    }

    # Now we switch to checking tokenFlags...
    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::AssignmentOperator)) {
        return [System.ConsoleColor]::DarkGray; # same as 'operator'
    }

    #UnaryOperator
    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::UnaryOperator)) {
        return [System.ConsoleColor]::DarkGray; # same as 'operator'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::CommandName)) {
        return [System.ConsoleColor]::Yellow; # same as 'command'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::TypeName)) {
        return [System.ConsoleColor]::Gray; # same as 'type'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::MemberName)) {
        return [System.ConsoleColor]::White; # same as 'member'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::SpecialOperator)) {
        return [System.ConsoleColor]::DarkGray; # same as 'operator'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::BinaryOperator)) {
        return [System.ConsoleColor]::DarkGray; # same as 'operator'
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::Keyword)) {
        return [System.ConsoleColor]::Green;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::ParseModeInvariant)) {
        return [System.ConsoleColor]::Gray; # same as 'operator'
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Identifier) {
        return [System.ConsoleColor]::Gray;
    }

    # Last chance...
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Generic) {
        return [System.ConsoleColor]::Gray;
    }

    #>
    Write-Host "<# TokenKind: $tokenKind, TokenFlags: $tokenFlags #>" -f red -n;

    return [System.ConsoleColor]::red;
    #Write-Host "`nTokenKind: $tokenKind, TokenFlags: $tokenFlags" -f red;

    <#

Attribute) { $c = [System.ConsoleColor]::Yellow;}
Command) { $c = [System.ConsoleColor]::Yellow;} # DONE
CommandArgument) { $c = [System.ConsoleColor]::Gray;}
CommandParameter) { $c = [System.ConsoleColor]::DarkGray;}
Comment) { $c = [System.ConsoleColor]::DakrGreen;}
GroupEnd) { $c = [System.ConsoleColor]::White;}
GroupStart) { $c = [System.ConsoleColor]::White;}
Keyword) { $c = [System.ConsoleColor]::White;}
LineContinuation) { $c = [System.ConsoleColor]::Gray;} # DONE
LoopLabel) { $c = [System.ConsoleColor]::White;}
Member) { $c = [System.ConsoleColor]::White;} # DONE (memberName)
NewLine) { $c = [System.ConsoleColor]::Yellow;} # DONE
Number) { $c = [System.ConsoleColor]::White;} # DONE
Operator) { $c = [System.ConsoleColor]::Gray;} # DONE
Position) { $c = [System.ConsoleColor]::Blue;}
StatementSeparator) { $c = [System.ConsoleColor]::Yellow;}
String) { $c = [System.ConsoleColor]::DarkCyan;} # DONE once
Type) { $c = [System.ConsoleColor]::Gray;}   # DONE
Unknown) { $c = [System.ConsoleColor]::Gray;}
Variable) { $c = [System.ConsoleColor]::Green;} -- DONE

#>
    # 	switch ($tokenKind) {
    # 		([System.Management.Automation.Language.TokenKind]::Variable) {
    # 			Write-Host "`n$tokenKind" -f yellow -n;
    # 			$c = [System.ConsoleColor]::Yellow;
    #   }
    # 		([System.Management.Automation.Language.TokenKind]::Comment) {
    # 			Write-Host "`n$tokenKind" -f green -n;
    # 			$c = [System.ConsoleColor]::Green;
    #   }
    #   ([System.Management.Automation.Language.TokenKind]::Comment) { c = [System.ConsoleColor]::Green; }
    # 		#    {
    # 		#      ([System.Management.Automation.PSTokenType]::Attribute) { $c = [System.ConsoleColor]::Yellow;}
    # 		#      ([System.Management.Automation.PSTokenType]::Command) { $c = [System.ConsoleColor]::Yellow;}
    # 		default {
    # 			#Write-Host $tokenKind -f red;
    # 			Write-Host "`n$tokenKind $tokenFlags" -f darkred -n;
    # 			$c = [System.ConsoleColor]::Gray;
    # 		}
    # 	}

    #return [System.ConsoleColor]::gray;
}
