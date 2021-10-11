unit BN04;     // Routines fin de jeu

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TDlgFin = class(TForm)
    OKBtn: TButton;
    Ccoule: TImage;
    PCoule: TImage;
    PnFin: TPanel;

    procedure Affiche(gagne : byte);
    procedure FormActivate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DlgFin: TDlgFin;
  gagne : byte;

implementation

{$R *.DFM}

procedure TDlgFin.Affiche(gagne : byte);
begin
  case gagne of
    0,
    1 : begin
          DlgFin.Color := clYellow;
          if gagne = 0 then
            DlgFin.PnFin.Caption := 'Abandon des Pirates !'
          else DlgFin.PnFin.Caption := 'Pirates coulés';
          DlgFin.Pcoule.Visible := true;
        end;
    2 : begin
         DlgFin.Color := clAqua;
         DlgFin.PnFin.Caption := 'Pôvres corsaires';
         DlgFin.Pcoule.Visible := false;
       end;
  end;
end;

procedure TDlgFin.FormActivate(Sender: TObject);
begin
  Affiche(gagne);
end;

end.
