unit Lox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Scanner, Token;

procedure runPrompt;
procedure runFile(filePath: string);
procedure run(Source: string);

implementation

procedure runPrompt;
var
  line: string;
begin
  while True do
  begin
    Write('> ');
    readln(line);
    run(line);
  end;
end;

procedure runFile(filePath: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(filePath);
    run(sl.Text);
  finally
    sl.Free;
  end;
end;

procedure run(Source: string);
var
  scanner: TScanner;
  tokens: TTokens;
  token: TToken;
begin
  scanner := TScanner.Create(Source);
  tokens := scanner.scanTokens;
  writeln;
  writeln;
  writeln(format('Tokens: %d', [tokens.Count]));
  writeln;
  for token in tokens do
  begin
    writeln(token.getString);
  end;
end;

end.
