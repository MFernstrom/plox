unit Scanner;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FGL, Token, TokenType, LoxError, strutils, Character;

type

  TKeywords = specialize TFPGMap<string, TTokenType>;
  TTokens = specialize TFPGList<TToken>;
  { Scanner }

  { TScanner }

  TScanner = class
    constructor Create(Source: string);
  private
    FKeywords: TKeywords;
    FTokens: TTokens;
    FSource: string;
    FStart: integer;
    FCurrent: integer;
    FLine: integer;
    function isAtEnd: boolean;
    procedure scanToken;
    function advance: char;
    function match(expected: char): boolean;
    procedure addToken(tokenType: TTokenType);
    procedure addToken(tokenType: TTokenType; Text: string);
    procedure addStringToken;
    procedure addDigitToken;
    procedure identifier;
    function ifthen(avalue: boolean; atrue, afalse: TTokenType): TTokenType;
    function peek: char;
    function peekNext: char;
  public
    function scanTokens: TTokens;
  end;

implementation

{ Scanner }

constructor TScanner.Create(Source: string);
begin
  FKeywords := TKeywords.Create;
  FTokens := TTokens.Create;
  // Insert keywords
  FKeywords.Add('and', TT_AND);
  FKeywords.Add('class', TT_CLASS);
  FKeywords.Add('else', TT_ELSE);
  FKeywords.Add('false', TT_FALSE);
  FKeywords.Add('for', TT_FOR);
  FKeywords.Add('fun', TT_FUN);
  FKeywords.Add('if', TT_IF);
  FKeywords.Add('nil', TT_NIL);
  FKeywords.Add('or', TT_OR);
  FKeywords.Add('print', TT_PRINT);
  FKeywords.Add('return', TT_RETURN);
  FKeywords.Add('super', TT_SUPER);
  FKeywords.Add('this', TT_THIS);
  FKeywords.Add('true', TT_TRUE);
  FKeywords.Add('var', TT_VAR);
  FKeywords.Add('while', TT_WHILE);

  FStart := 1;
  FCurrent := 1;
  FLine := 1;

  // Set up source
  writeln('setting scanner source');
  FSource := Source;
  writeln(Source);
end;

function TScanner.scanTokens: TTokens;
var
  finalToken: TToken;
begin
  while isAtEnd = False do
  begin
    FStart := FCurrent;
    scanToken;
  end;

  finalToken := TToken.Create(TT_EOF, '', '', FLine);
  FTokens.Add(finalToken);

  Result := FTokens;
end;

function TScanner.isAtEnd: boolean;
begin
  Result := FCurrent > length(FSource);
end;

procedure TScanner.scanToken;
var
  c: char;
begin
  c := advance;
  case c of
    '(': addToken(TT_LEFT_PAREN);
    ')': addToken(TT_RIGHT_PAREN);
    '{': addToken(TT_LEFT_BRACE);
    '}': addToken(TT_RIGHT_BRACE);
    ',': addToken(TT_COMMA);
    '.': addToken(TT_DOT);
    '-': addToken(TT_MINUS);
    '+': addToken(TT_PLUS);
    ';': addToken(TT_SEMICOLON);
    '*': addToken(TT_STAR);
    '!': addToken(ifthen(match('='), TT_BANG_EQUAL, TT_BANG));
    '=': addToken(ifthen(match('='), TT_EQUAL_EQUAL, TT_EQUAL));
    '<': addToken(ifthen(match('='), TT_LESS_EQUAL, TT_LESS));
    '>': addToken(ifthen(match('='), TT_GREATER_EQUAL, TT_GREATER));
    '/':
    begin
      if match('/') = True then
      begin
        while (peek <> #10) and (isAtEnd = False) do
        begin
          advance;
        end;
      end
      else
        addToken(TT_SLASH);
    end;
    ' ', #13, #9: ; // We ignore whitespace, carriage return, and tab
    #10: Inc(FLine); // newline character
    '"': addStringToken;
    otherwise
    begin
      // Default handler.
      if IsNumber(c) then
        addDigitToken
      else if IsLetter(c) then
        identifier
      else
        doError(FLine, 'Unexpected character ' + c);
    end;
  end;
end;

function TScanner.advance: char;
begin
  Inc(FCurrent);
  Result := FSource[FCurrent - 1];
end;

function TScanner.match(expected: char): boolean;
begin
  if isAtEnd = True then
  begin
    Result := False;
    exit;
  end;

  if FSource[FCurrent] <> expected then
  begin
    Result := False;
    exit;
  end;

  Inc(FCurrent);
  Result := True;
end;

procedure TScanner.addToken(tokenType: TTokenType);
var
  token: TToken;
begin
  token := TToken.Create(tokenType, '', '', FLine);
  FTokens.Add(token);
end;

procedure TScanner.addToken(tokenType: TTokenType; Text: string);
var
  token: TToken;
begin
  token := TToken.Create(tokenType, Text, '', FLine);
  FTokens.Add(token);
end;

function TScanner.ifthen(avalue: boolean; atrue, afalse: TTokenType): TTokenType;
begin
  if avalue then
    Result := atrue
  else
    Result := afalse;
end;

function TScanner.peek: char;
begin
  if isAtEnd() = True then
    Result := #0
  else
    Result := FSource[FCurrent];
end;

function TScanner.peekNext: char;
begin
  if FCurrent + 1 > Length(FSource) then
    result := #0
  else
    result := FSource[FCurrent +1];
end;

procedure TScanner.addStringToken;
begin
  while (peek <> '"') and (isAtEnd = False) do
  begin
    if peek = #10 then
      Inc(FLine);
    advance;
  end;

  if isAtEnd = True then
  begin
    doError(FLine, 'Unterminated string');
  end;

  advance;
  addToken(TT_STRING, Copy(FSource, FStart + 1, FCurrent - 2 - FStart));
end;

procedure TScanner.addDigitToken;
begin
  while IsNumber(peek) = true do
    advance;

  if (peek = '.') AND (IsNumber(peekNext)) then begin
    advance;

    while isNumber(peek) do
	    advance();
  end;

  addToken(TT_NUMBER, Copy(FSource, FStart, FCurrent - FStart));
end;

procedure TScanner.identifier;
var
  tokenType: TTokenType;
  text: String;
begin
  while IsLetterOrDigit(peek) do
    advance;

  text := Copy(FSource, FStart, FCurrent-FStart);

  if FKeywords.IndexOf(text) <> -1 then
    tokenType := FKeywords.KeyData[text]
  else
    tokenType := TT_IDENTIFIER;
  addToken(tokenType);
end;

end.
