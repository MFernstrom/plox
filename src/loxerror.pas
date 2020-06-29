unit LoxError;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils;

procedure doError(line: Integer; text: String);

implementation

procedure doError(line: Integer; text: String);
var
  lineWithOffset: String;
begin
  lineWithOffset := PadLeft(IntToStr(line), 4);
  writeln(format('%s: %s',[lineWithOffset, text]));
end;

end.

