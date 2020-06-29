program plox_project;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  lox;



begin
  if ParamCount > 1 then
    writeln('Usage: plox [script]')
  else if ParamCount = 1 then
    lox.runFile(ParamStr(1))
  else
    lox.runPrompt();
end.
