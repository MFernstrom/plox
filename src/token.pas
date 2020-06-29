unit Token;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TokenType;

type

  { TToken }

  TToken = class
    constructor Create(tokentype: TTokenType; lexeme: string; literal: string;
      line: integer);
  private
    Ftokentype: TTokenType;
    Flexeme: string;
    Fline: integer;
    Fliteral: string;
  public
    property tokentype: TTokenType read Ftokentype write Ftokentype;
    property lexeme: string read Flexeme write Flexeme;
    property line: integer read Fline write Fline;
    property literal: string read Fliteral write Fliteral;
    function getString: string;
  end;

implementation

{ TToken }

constructor TToken.Create(tokentype: TTokenType; lexeme: string;
  literal: string; line: integer);
begin
  Ftokentype := tokentype;
  Flexeme := lexeme;
  Fliteral := literal;
  Fline := line;
end;

function TToken.getString: string;
var
  TTokenString: String;
begin
  WriteStr(TTokenString, Ftokentype);
  Result := TTokenString + ' ' + Flexeme + ' ' + Fliteral;
end;

end.
