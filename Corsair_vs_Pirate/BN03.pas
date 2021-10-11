unit BN03;    // Editeur de tableaux

interface                               

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,
  BN02, Menus;

type
  TFEdit = class(TForm)
    Pano: TImage;
    Panel1: TPanel;
    Lb_Jou: TLabeledEdit;
    Lb_Col: TLabeledEdit;
    Lb_Lig: TLabeledEdit;
    Label1: TLabel;
    Bt_Appli: TButton;
    Bt_Abandon: TButton;
    Bt_Charger: TButton;
    Bt_Enregistrer: TButton;
    Bt_Nouveau: TButton;
    SB4: TSpeedButton;
    SB3: TSpeedButton;
    SB2: TSpeedButton;
    SB1: TSpeedButton;
    Bevel1: TBevel;
    Lb_Bato: TLabeledEdit;
    SVDlg: TSaveDialog;
    OPdlg: TOpenDialog;
    Bline: TImage;
    Aline: TImage;
    aPanel2: TPanel;
    Bevel2: TBevel;
    Bima: TImage;
    Pion: TImage;
    procedure SB1Click(Sender: TObject);
    procedure AffichePano;
    procedure AfficheValeurs(nb : byte);
    procedure Bt_NouveauClick(Sender: TObject);
    procedure Bt_EnregistrerClick(Sender: TObject);
    procedure PanoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AlineMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BlineMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MovePion(nb : byte;x1,y1,x2,y2 : integer);
    procedure Bt_ChargerClick(Sender: TObject);
    procedure JeuEnCours;
    procedure BimaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Déclarations privées }
    procedure AfficheBateau(nb : byte);
  public
    { Déclarations publiques }
  end;

var
  FEdit: TFEdit;
  tba : array[0..11,0..7] of byte;
  eba : array[1..20] of TBato;
  Fba : file of TBato;

implementation

{$R *.dfm}

var
  sns : byte = 0;
  bac : TBato;
  nba : byte;
  tali : array[1..10] of byte;
  tbli : array[1..10] of byte;
  dx,dy,fx,fy,
  cl1,lg1,cl2,lg2 : integer;
  bta : byte = 0;
  btb : byte = 0;
  pha : byte = 0;

procedure TFEdit.SB1Click(Sender: TObject);  // change de direction
begin
  sns := (Sender as TSpeedButton).Tag;
  nba := StrToInt(Lb_Bato.Text);
  eba[nba].sens := sns;
  AfficheBateau(nba);
end;

procedure TFEdit.AffichePano;
var  i : byte;
     cl,lg : integer;
begin
  for lg := 0 to 7 do
    for cl := 0 to 11 do
    begin
      i := tba[cl,lg];
      if i > 0 then
        Pano.Canvas.Draw(cl*30,lg*30,ron[eba[i].joueur])
      else Pano.Canvas.Draw(cl*30,lg*30,ron[0]);
    end;
end;

procedure TFEdit.AfficheValeurs(nb : byte);
begin
  bac := eba[nb];
  Lb_Bato.Text := IntToStr(nb);
  Lb_Jou.Text := IntToStr(bac.joueur);
  Lb_Col.Text := IntToStr(bac.cl);
  Lb_Lig.Text := IntToStr(bac.lg);
  sns := bac.sens;
end;

procedure TFEdit.Bt_NouveauClick(Sender: TObject);
var  i,x,y : byte;
     cl,lg : integer;
     ok  : boolean;
begin
  for y := 0 to 7 do
    for x := 0 to 11 do tba[x,y] := 0;
  AffichePano;
  MelangeVies;
  for i := 1 to 10 do
  begin
    tali[i] := i;
    Aline.Canvas.Draw(i*30,0,ron[0]);
    tbli[i] := i+10;
    Bline.Canvas.Draw(i*30,0,ron[0]);
  end;
  for i := 1 to 10 do
  begin
    ok := false;
    repeat
      cl := Random(6);
      lg := Random(7);
      if tba[cl,lg] = 0 then ok := true;
    until ok;
    tba[cl,lg] := i;
    eba[i].sens := Random(4)+1;
    tba[11-cl,7-lg] := i+10;
    eba[i+10].sens := Random(4)+1;
    eba[i].joueur := 1;
    Pano.Canvas.Draw(cl*30,lg*30,ron[1]);
    eba[i+10].joueur := 2;
    Pano.Canvas.Draw((11-cl)*30,(7-lg)*30,ron[2]);
    eba[i].vies := tbvie[i];
    eba[i].cl := cl;
    eba[i].lg := lg;
    eba[i+10].vies := tbvie[i+10];
    eba[i+10].cl := 11-cl;
    eba[i+10].lg := 7-lg;
    jr := Random(2)+1;
  end;
end;

procedure TFEdit.PanoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if pha = 0 then
  begin
    cl1 := X div 30;
    lg1 := Y div 30;
    nba := tba[cl1,lg1];
    if nba = 0 then
    begin
      if bta = 0 then exit;
      if tba[cl1,lg1] = 0 then           // Ajout d'un bateau
      begin
        tba[cl1,lg1] := bta;
        eba[bta].cl := cl1;
        eba[bta].lg := lg1;
        eba[bta].vies := tbvie[bta];
        if bta < 11 then
        begin
          tali[bta] := 0;
          Aline.Canvas.Draw(bta*30,0,ron[0]);
          Pano.Canvas.Draw(cl1*30,lg1*30,ron[1]);
          eba[bta].sens := 1;
        end
        else
          begin                     
            tbli[bta-10] := 0;
            Bline.Canvas.Draw((bta-10)*30,0,ron[0]);
            Pano.Canvas.Draw(cl1*30,lg1*30,ron[2]);
            eba[bta].sens := 3;
          end;
        AfficheValeurs(bta);
        AfficheBateau(bta);
        bta := 0;
      end;
      exit;
    end;
    if Button = mbRight then     // suppression d'un bateau
    begin
      Pano.Canvas.Draw(cl1*30,lg1*30,ron[0]);
      eba[nba].cl := 0;
      eba[nba].lg := 0;
      if nba < 11 then
      begin
        tali[nba] := nba;
        Aline.Canvas.Draw(nba*30,0,ron[1]);
      end
      else
        begin
          tbli[nba-10] := 0;
          Bline.Canvas.Draw((nba-10)*30,0,ron[2]);
        end;
      Exit;
    end;
    dx := cl1 * 30;
    dy := lg1 * 30;
    Pano.Canvas.Draw(dx,dy,ron[3]);
    Pano.Repaint;
    pha := 1;
  end
  else
    begin                 // déplacement d'un bateau
      pha := 0;
      cl2 := X div 30;
      lg2 := Y div 30;
      if tba[cl2,lg2] > 0 then   // destination occupée
      begin
        if nba in[1..10] then Pano.Canvas.Draw(cl1*30,lg1*30,ron[1])
        else Pano.Canvas.Draw(cl1*30,lg1*30,ron[2]);
        if tba[cl2,lg2] <> nba then
        begin
          nba := tba[cl2,lg2];
          cl1 := cl2;
          lg1 := lg2;
          Pano.Canvas.Draw(cl1*30,lg1*30,ron[3]);
          dx := cl1 * 30;
          dy := lg1 * 30;
          pha := 1;
          exit;
        end;
        if nba in[1..10] then Pano.Canvas.Draw(cl1*30,lg1*30,ron[1])
        else Pano.Canvas.Draw(cl1*30,lg1*30,ron[2]);
        Pano.Repaint;
        AfficheValeurs(nba);
        AfficheBateau(nba);
        exit;
      end;
      fx := cl2 * 30;
      fy := lg2 * 30;
      Pion.Picture.Bitmap := ron[3];
      Pion.Left := dx+5;
      Pion.Top := dy+40;
      Pano.Canvas.Draw(dx,dy,ron[0]);
      Pion.Visible := true;
      eba[nba].cl := cl2;
      eba[nba].lg := lg2;
      MovePion(nba,dx,dy,fx,fy);
      if nba in[1..10] then Pano.Canvas.Draw(fx,fy,ron[1])
      else Pano.Canvas.Draw(fx,fy,ron[2]);
      Pion.Visible := false;
      Pion.Top := 5;
      tba[cl1,lg1] := 0;
      tba[cl2,lg2] := nba;
      AfficheValeurs(nba);
      AfficheBateau(nba);
    end;
end;

procedure TFEdit.MovePion(nb : byte;x1,y1,x2,y2 : integer);
var xo,yo,
    xd,yd,
    ix,iy,np : integer;
begin             // déplacement glissé
  xo := x1;       // position initiale ddu bateau
  yo := y1;
  xd := x2;       // position finale
  yd := y2;
  np := 30;    // nbre de pas = nbre de cases * demi-longeur d'une case
  ix := (xd-xo) div np;    // longueur d'un pas
  iy := (yd-yo) div np;
  repeat
    xo := xo+ix;
    yo := yo+iy;
    Pion.Left := xo+5;      // on déplace le bateau
    Pion.Top := yo+40;
    Pion.Repaint;
    Pano.Repaint;
    dec(np);
    Sleep(10);
  until np = 0;
end;

procedure TFEdit.Bt_EnregistrerClick(Sender: TObject);
var  i : byte;
     fn : string;
begin
  if SVDlg.Execute then
  begin
    fn := SVDlg.FileName;
    if ExtractFileExt(fn) = '' then fn := fn+'.BN5';
    AssignFile(Fba,fn);
    Rewrite(Fba);
    for i := 1 to 20 do Write(Fba,eba[i]);
    CloseFile(Fba);
  end;
end;

procedure TFEdit.Bt_ChargerClick(Sender: TObject);
var  i,x,y : byte;
begin
  if OPDlg.Execute then
  begin
    MelangeVies;
    for y := 0 to 7 do
      for x := 0 to 11 do tba[x,y] := 0;
    AssignFile(Fba,OPDlg.FileName);
    Reset(Fba);
    for i := 1 to 20 do
    begin
      Read(Fba,eba[i]);
      with eba[i] do
      begin
        if vies > 0 then
        begin
          tba[cl,lg] := i;
          eba[i].vies := tbvie[i];
          if i < 11 then
          begin
            tali[i] := 0;
            Aline.Canvas.Draw(i*30,0,ron[0]);
            Pano.Canvas.Draw(cl*30,lg*30,ron[1]);
          end
          else begin
                 tbli[i-10] := 0;
                 Bline.Canvas.Draw((i-10)*30,0,ron[0]);
                 Pano.Canvas.Draw(cl*30,lg*30,ron[2]);
               end;
        end
        else begin
               tba[cl,lg] := 0;
               if i < 11 then
               begin
                 tali[i] := i;
                 Aline.Canvas.Draw(i*30,0,ron[1]);
                 Pano.Canvas.Draw(cl*30,lg*30,ron[0]);
               end
               else begin
                      tbli[i-10] := i;
                      Bline.Canvas.Draw((i-10)*30,0,ron[2]);
                      Pano.Canvas.Draw(cl*30,lg*30,ron[0]);
                    end;
             end;
      end;
    end;
    CloseFile(Fba);
    AffichePano;
  end;
end;

procedure TFEdit.JeuEnCours;   // est chargé dans l'éditeur
var  i,x,y : byte;
begin
  for y := 0 to 7 do
    for x := 0 to 11 do tba[x,y] := 0;
  for i := 1 to 20 do
  begin
    eba[i] := batos[i];
    if eba[i].vies > 0 then
      tba[eba[i].cl,eba[i].lg] := i
    else if i in[1..10] then tali[i] := i
         else tbli[i-10] := i;
  end;
  AffichePano;
  for i := 1 to 10 do
  begin
    if tali[i] > 0 then
      Aline.Canvas.Draw(i*30,0,ron[1]);
    if tbli[i] > 0 then
      Bline.Canvas.Draw(i*30,0,ron[2]);
  end;
end;

procedure TFEdit.AfficheBateau(nb : byte);
var  bo : TBato;
begin
  bo := eba[nb];
  bato.Assign(tbmod[bo.joueur,bo.vies]);
  case bo.sens of
    2 : begin
          Rotation(bato);
        end;
    3 : begin
          Rotation(bato);
          Rotation(bato);
        end;
    4 : begin
          Rotation(bato);
          Rotation(bato);
          Rotation(bato);
        end;
  end;
  bato.Transparent := true;
  bima.Picture.Bitmap.Assign(bato);
end;

procedure TFEdit.AlineMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bta := X div 30;
  Aline.Canvas.Draw(bta*30,0,ron[3]);
end;

procedure TFEdit.BlineMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bta := X div 30;
  Bline.Canvas.Draw(bta*30,0,ron[3]);
  inc(bta,10);
end;

procedure TFEdit.BimaClick(Sender: TObject);  // modif nbre de vies
var  nb : byte;
begin
  if not debug then exit;
  nb := StrToInt(Lb_Bato.Text);
  inc(eba[nb].vies);
  if eba[nb].vies > 4 then eba[nb].vies := 1;
  AfficheBateau(nb);
end;

procedure TFEdit.FormActivate(Sender: TObject);
begin
  if debug then JeuEnCours;
end;

end.
