function Get-TokenTypeColor([System.Management.Automation.PSTokenType]$tokenType) {
    $c = [System.ConsoleColor]::gray;
    switch ($tokenType)
    {
      ([System.Management.Automation.PSTokenType]::Attribute) { $c = [System.ConsoleColor]::Yellow;}
      ([System.Management.Automation.PSTokenType]::Command) { $c = [System.ConsoleColor]::Yellow;}
      ([System.Management.Automation.PSTokenType]::CommandArgument) { $c = [System.ConsoleColor]::Gray;}
      ([System.Management.Automation.PSTokenType]::CommandParameter) { $c = [System.ConsoleColor]::DarkGray;}
      ([System.Management.Automation.PSTokenType]::Comment) { $c = [System.ConsoleColor]::Green;}
      ([System.Management.Automation.PSTokenType]::GroupEnd) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::GroupStart) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::Keyword) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::LineContinuation) { $c = [System.ConsoleColor]::Gray;}
      ([System.Management.Automation.PSTokenType]::LoopLabel) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::Member) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::NewLine) { $c = [System.ConsoleColor]::Yellow;}
      ([System.Management.Automation.PSTokenType]::Number) { $c = [System.ConsoleColor]::White;}
      ([System.Management.Automation.PSTokenType]::Operator) { $c = [System.ConsoleColor]::Gray;}
      ([System.Management.Automation.PSTokenType]::Position) { $c = [System.ConsoleColor]::Blue;}
      ([System.Management.Automation.PSTokenType]::StatementSeparator) { $c = [System.ConsoleColor]::Yellow;}
      ([System.Management.Automation.PSTokenType]::String) { $c = [System.ConsoleColor]::DarkCyan;}
      ([System.Management.Automation.PSTokenType]::Type) { $c = [System.ConsoleColor]::Gray;}
      ([System.Management.Automation.PSTokenType]::Unknown) { $c = [System.ConsoleColor]::Gray;}
      ([System.Management.Automation.PSTokenType]::Variable) { $c = [System.ConsoleColor]::Green;}
      default { $c = [System.ConsoleColor]::Gray;}
    }
    return $c;
  }
  