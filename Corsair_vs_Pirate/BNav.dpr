program BNav;

uses
  Forms,
  BN01 in 'BN01.pas' {Fmain},
  BN02 in 'BN02.pas',
  BN03 in 'BN03.pas' {FEdit},
  BN04 in 'BN04.pas' {DlgFin},
  BN05 in 'BN05.pas' {FAide};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmain, Fmain);
  Application.CreateForm(TFEdit, FEdit);
  Application.CreateForm(TDlgFin, DlgFin);
  Application.CreateForm(TFAide, FAide);
  Application.Run;
end.
