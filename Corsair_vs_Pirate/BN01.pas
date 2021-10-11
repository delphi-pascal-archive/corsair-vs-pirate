unit BN01;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Math, StdCtrls, Buttons, IniFiles,
  BN02, BN03, BN04, BN05, ComCtrls;

type
  TFmain = class(TForm)
    Bt_Nouveau: TButton;
    Image1: TImage;
    Bt_Edit: TButton;
    OPDlg: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    Image2: TImage;
    Image3: TImage;
    Pn1: TPanel;
    Pn2: TPanel;
    Panel1: TPanel;
    Bt_Aide: TButton;
    Bt_Son: TBitBtn;
    SpeedBar: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    Mer: TImage;
    BChoix: TImage;
    Pima: TImage;
    Bevel2: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LectureTableau;
    procedure QuiCommence;
    procedure Angle(bma : TBitmap);
    procedure RotaDroite(bmp : TBitmap);
    procedure RotaGauche(bmp : TBitmap);
    procedure AfficheBateau(nb : byte);
    procedure MoveBateau(nb : byte;x1,y1,x2,y2 : integer);
    procedure MerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Bt_NouveauClick(Sender: TObject);
    procedure Bt_AideClick(Sender: TObject);
    procedure Bt_SonClick(Sender: TObject);
    procedure Bt_EditClick(Sender: TObject);
    procedure SpeedBarChange(Sender: TObject);
    function Quelsens(nb : byte) : byte;
    procedure Combat(nb : byte);
    procedure Canon(sn,nm,ne : byte);
    procedure Coule(nb : byte);
    procedure JeuOrdi;
    function Evaluation(bn,sn : byte) : Tval;
    function EvSens1(cl,lg : byte) : Tval;
    function EvSens2(cl,lg : byte) : Tval;
    function EvSens3(cl,lg : byte) : Tval;
    function EvSens4(cl,lg : byte) : Tval;
    procedure AppliquerTableau;
    procedure BChoixMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Fmain: TFmain;

implementation

uses mmsystem, shellapi;

{$R *.dfm}

var
  fond : TBitmap;
  dx,dy,fx,fy : integer;
  cl1,lg1,cl2,lg2 : integer;
  ja : byte; // joueur attaquant,  adversaire
  vs : array[0..4] of byte;
  fin : boolean = false;
  bson : boolean = true;
  vite : integer;
  fpar : TIniFile;

procedure TFmain.FormCreate(Sender: TObject);
var  i,x,y : integer;
begin
  Randomize;
  DoubleBuffered := true;
  fond := TBitmap.Create;
  fond.LoadFromFile('Images\Lamer.bmp');
  bato := TBitmap.Create;
  bato.Width := dim;
  bato.Height := dim;
  bato.Transparent := true;
  for y := 0 to 7 do
    for x := 0 to 11 do
      Mer.Canvas.Draw(x*dim,y*dim,fond);
  Charge;
  dir := ExtractFilePath(Application.ExeName);
  OPDlg.InitialDir := dir+'Data\';
  fpar := TIniFile.Create('BNav.ini');
  vite := fpar.ReadInteger('Options','Vitesse',15);
  SpeedBar.Position := vite;
  bson := fpar.ReadBool('Options','Son',true);
  if bson then
    Bt_Son.Glyph.Assign(ledon)
  else Bt_Son.Glyph.Assign(ledof);
  if FileExists(dir+kfn) then
  begin
    RestoreJeu;
    nbnav[1] := 0;
    nbnav[2] := 0;
    for i := 1 to 20 do
      if batos[i].vies > 0 then
      begin
        AfficheBateau(i);
        inc(nbnav[batos[i].joueur]);
        tablo[batos[i].cl,batos[i].lg] := i;
      end;  
    Pn1.Caption := IntToStr(nbnav[1]);
    Pn2.Caption := IntToStr(nbnav[2]);
    jr := 1;
    fin := false;
    phase := 0;
  end;
end;

procedure TFmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not fin then SauveJeu
  else if FileExists(dir+kfn) then DeleteFile(dir+kfn);
  fond.Free;
  bato.Free;
  Decharge;
  fpar.Free;
end;

procedure TFmain.Bt_NouveauClick(Sender: TObject);
var  lg,cl : integer;
begin
  fin := false;
  phase := 0;
  for lg := 0 to 7 do
    for cl := 0 to 11 do
    begin
      tablo[cl,lg] := 0;
      Mer.Canvas.Draw(cl*dim,lg*dim,fond);
    end;
  MelangeVies;
  BChoix.Visible := true;
end;

procedure TFmain.BChoixMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var  no : integer;
begin
  fn := '';
  Bchoix.Visible := false;
  if Y > 365 then
  begin
    if OPDlg.Execute then           // enregistré
    begin
      fn := OPDlg.FileName;
      LectureTableau;
    end
    else Exit;
  end
  else
    if Y > 335 then
    begin
      FEdit.Bt_NouveauClick(self);   // aléatoire
    end
    else
      begin                                     // prédéfini
        no := (Y div 84) * 2 + X div 124 + 1;
        fn := dir+'Data\Predef\Tableau'+IntToStr(no)+'.BN5';
        LectureTableau;
      end;
  AppliquerTableau;
  QuiCommence;
end;

procedure TFmain.LectureTableau;
var  i : byte;
begin
  AssignFile(Fba,fn);
  Reset(Fba);
  for i := 1 to 20 do
  begin
    Read(Fba,eba[i]);
    eba[i].vies := tbvie[i];
  end;
  CloseFile(Fba);
end;

procedure TFmain.QuiCommence;
begin
  jr := Random(2)+1;
  fin := false;
  if jr = 2 then JeuOrdi;
end;

// Affiche un bateau en fonction du sens et du nbre de vies
procedure TFmain.AfficheBateau(nb : byte);
var  bo : TBato;
begin
  bo := batos[nb];
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
  Mer.Canvas.Draw(dim*bo.cl,dim*bo.lg,bato);
  Mer.Repaint;
end;

procedure TFmain.MerMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var  i : integer;
     n : byte;
begin
  if (jr = 2) or fin then exit;        // clic pendant le jeu de l'ordi ou fin
  if phase = 1 then                    // peut-on changer de bateau ?
  begin
    n := tablo[X div dim, Y div dim];
    if (n > 0) and (batos[n].joueur = 1) then       // yes
    begin
      Bevel2.Visible := false;
      Bevel2.Left := 920;
      phase := 0;
    end;
  end;
  if phase = 0 then
  begin
    cl1 := X div dim;
    lg1 := Y div dim;
    noba := tablo[cl1,lg1];
    if noba = 0 then exit;
    if batos[noba].joueur <> jr then exit;
    dx := cl1 * dim;
    dy := lg1 * dim;
    Bevel2.Left := dx+5;
    Bevel2.Top := dy+5;
    Bevel2.Visible := true;
    phase := 1;
  end
  else
    begin
      Bevel2.Visible := false;
      Bevel2.Left := 920;
      phase := 0;
      cl2 := X div dim;
      lg2 := Y div dim;
      if tablo[cl2,lg2] > 0 then exit;  // destination occupée
      if cl2 > cl1 then
      begin
        for i := cl1+1 to cl2 do
          if tablo[i,lg1] > 0 then exit;  // la voie n'est pas libre
      end
      else
        if cl2 < cl1 then
        begin
          for i := cl1-1 downto cl2 do
            if tablo[i,lg1] > 0 then exit;
        end
        else
          if lg2 > lg1 then
          begin
            for i := lg1+1 to lg2 do
              if tablo[cl1,i] > 0 then exit;
          end
          else
            if lg2 < lg1 then
            begin
            for i := lg1-1 downto lg2 do
              if tablo[cl1,i] > 0 then exit;
          end;
      fx := cl2 * dim;
      fy := lg2 * dim;
      if (fx <> dx) and (fy <> dy) then exit; // déplacement en biais
      AfficheBateau(noba);
      Pima.Picture.Bitmap := bato;
      Pima.Left := dx+5;
      Pima.Top := dy+5;
      Mer.Canvas.Draw(dx,dy,fond);
      Pima.Visible := true;
      batos[noba].sens := QuelSens(noba);     // positionne le bateau
      batos[noba].cl := cl2;
      batos[noba].lg := lg2;
      MoveBateau(noba,dx,dy,fx,fy);
      AfficheBateau(noba);
      Pima.Visible := false;
      Pima.Left := 855;
      tablo[cl1,lg1] := 0;
      tablo[cl2,lg2] := noba;
      Combat(noba);
      if jr = 2 then
      begin
        jr := 1;
      end
      else begin
             jr := 2;
           end;
    end;
  if jr = 2 then JeuOrdi;  
end;

function TFmain.Quelsens(nb : byte) : byte;
var  sn : byte;
begin
 sn := batos[nb].sens;
 case sn of
   1 : begin
         if cl1 < cl2 then sn := 1
         else if cl1 > cl2 then
              begin
                sn := 3;
                RotaGauche(bato);
                RotaGauche(bato);
              end
              else if lg1 < lg2 then
                   begin
                     sn := 2;
                     RotaDroite(bato);
                   end
                   else if lg1 > lg2 then
                        begin
                          sn := 4;
                          RotaGauche(bato);
                        end;
       end;
   2 : begin
         if lg1 < lg2 then sn := 2
         else if lg1 > lg2 then
              begin
                sn := 4;
                RotaGauche(bato);
                RotaGauche(bato);
              end
              else if cl1 < cl2 then
                   begin
                     sn := 1;
                     RotaGauche(bato);
                   end
                   else if cl1 > cl2 then
                        begin
                          sn := 3;
                          RotaDroite(bato);
                        end;
       end;
   3 : begin
         if cl1 > cl2 then sn := 3
         else if cl1 < cl2 then
              begin
                sn := 1;
                RotaGauche(bato);
                RotaGauche(bato);
              end
              else if lg1 < lg2 then
                   begin
                     sn := 2;
                     RotaGauche(bato);
                   end
                   else if lg1 > lg2 then
                        begin
                          sn := 4;
                          RotaDroite(bato);
                        end;
       end;
   4 : begin
         if lg1 > lg2 then sn := 4
         else if lg1 < lg2 then
              begin
                sn := 2;
                RotaGauche(bato);
                RotaGauche(bato);
              end
              else if cl1 < cl2 then
                   begin
                     sn := 1;
                     RotaDroite(bato);
                   end
                   else if cl1 > cl2 then
                        begin
                          sn := 3;
                          RotaGauche(bato);
                        end;
       end;
  end;
  batos[nb].sens := sn;
  result := sn;
end;

procedure TFmain.Angle(bma : TBitmap);
var  ec : integer;
     bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.Width := dim;
  bmp.Height := dim;
  bmp := RotImage(bma, DegToRad(rangle),
         Point(dim div 2, dim div 2), clWhite);
  ec := (bmp.Width - dim) div 2;
  Pima.Left := ix - ec;
  Pima.Top := iy - ec;
  Pima.Width := bmp.Width;
  Pima.Height := bmp.Height;
  Pima.Picture.Bitmap := bmp;
  Pima.Repaint;
  bmp.Free;
end;

procedure TFmain.RotaDroite(bmp : TBitmap);
begin
  ix := Pima.Left;
  iy := Pima.Top;
  rangle := 0;
  Pima.Transparent := true;
  while rangle < 90 do
  begin
    rangle := rangle+15;
    Angle(bmp);
  end;
  Rotation(bmp);
  Pima.Picture.Bitmap := bmp;
end;

procedure TFmain.RotaGauche(bmp : TBitmap);
var i : byte;
begin
  ix := Pima.Left;
  iy := Pima.Top;
  rangle := 360;
  Pima.Transparent := true;
  while rangle > 270 do
  begin
    rangle := rangle-15;
    Angle(bmp);
  end;
  for i := 1 to 3 do Rotation(bmp);
  Pima.Picture.Bitmap := bmp;
end;

procedure TFmain.MoveBateau(nb : byte;x1,y1,x2,y2 : integer);
var xo,yo,
    xd,yd,df,
    ix,iy,np : integer;
begin             // déplacement glissé
  xo := x1;       // position initiale ddu bateau
  yo := y1;
  xd := x2;       // position finale
  yd := y2;
  df := 0;
  case batos[nb].sens of
    1 : df := cl2 - cl1;
    2 : df := lg2 - lg1;
    3 : df := cl1 - cl2;
    4 : df := lg1 - lg2;
  end;
  np := df * 10;    // nbre de pas = nbre de cases * demi-longeur d'une case
  ix := (xd-xo) div np;    // longueur d'un pas
  iy := (yd-yo) div np;
  repeat
    xo := xo+ix;
    yo := yo+iy;
    Pima.Left := xo+5;      // on déplace le bateau
    Pima.Top := yo+5;
    Pima.Repaint;
    Mer.Repaint;
    dec(np);
    Sleep(vite);
  until np = 0;
end;

procedure TFmain.Combat(nb : byte);
var  i,cl,lg : integer;
     na : byte;
begin
  if jr = 1 then ja := 2
  else ja := 1;
  for i := 0 to 4 do vs[i] := 0;
  cl := batos[nb].cl;
  lg := batos[nb].lg;
  if lg > 0 then            // bateau à portée de tir ?
  begin
    na := tablo[cl,lg-1];
    if na > 0 then
      if batos[na].joueur = ja then vs[4] := na;
  end;
  if lg < 7 then
  begin
    na := tablo[cl,lg+1];
    if na > 0 then
      if batos[na].joueur = ja then vs[2] := na;
  end;
  if cl > 0 then
  begin
    na := tablo[cl-1,lg];
    if na > 0 then
      if batos[na].joueur = ja then vs[3] := na;
  end;
  if cl < 11 then
  begin
    na := tablo[cl+1,lg];
    if na > 0 then
      if batos[na].joueur = ja then vs[1] := na;
  end;
  for i := 1 to 4 do
    if vs[i] > 0 then inc(vs[0]);
  if vs[0] = 0 then Exit;
  case batos[nb].sens of      // bateau ennemi devant et perpendiculaire
    1 : if vs[1] > 0 then
        begin
          na := vs[1];
          if batos[na].sens in[2,4] then Canon(2,na,nb);
        end;
    2 : if vs[2] > 0 then
        begin
          na := vs[2];
          if batos[na].sens in[1,3] then Canon(0,na,nb);
        end;
    3 : if vs[3] > 0 then
        begin
          na := vs[3];
          if batos[na].sens in[2,4] then Canon(3,na,nb);
        end;
    4 : if vs[4] > 0 then
        begin
          na := vs[4];
          if batos[na].sens in[1,3] then Canon(1,na,nb);
        end;
  end;
  case batos[nb].sens of       // bateaux ennemi contre flanc
    1,3 : begin
            if vs[2] > 0 then
            begin
              Canon(1,nb,vs[2]);
              if batos[vs[2]].sens in[2,4] then vs[2] := 0;
            end;
            if vs[4] > 0 then
            begin
              Canon(0,nb,vs[4]);
              if batos[vs[4]].sens in[2,4] then vs[4] := 0;
            end;
          end;
    2,4 : begin
            if vs[1] > 0 then
            begin
              Canon(3,nb,vs[1]);
              if batos[vs[1]].sens in[1,3] then vs[1] := 0;
            end;
            if vs[3] > 0 then
            begin
              Canon(2,nb,vs[3]);
              if batos[vs[3]].sens in[1,3] then vs[3] := 0;
            end;
          end;
  end;
  for i := 1 to 4 do
    if vs[i] > 0 then inc(vs[0]);
  if vs[0] = 0 then Exit;
  case batos[nb].sens of                       // Riposte
    1,3 : begin
            if vs[2] > 0 then Canon(0,vs[2],nb);
            if vs[4] > 0 then Canon(1,vs[4],nb);
          end;
    2,4 : begin
            if vs[1] > 0 then Canon(2,vs[1],nb);
            if vs[3] > 0 then Canon(3,vs[3],nb);
          end;
  end;
end;

procedure TFmain.Canon(sn,nm,ne : byte);
var  bm,be : TBato;
     i,xm,ym : integer;
begin
  bm := batos[nm];
  be := batos[ne];
  xm := bm.cl*dim;
  ym := bm.lg*dim;
  if bm.vies = 0 then exit;
  Pima.Picture := nil;
  if bson then
    SndPlaySound('Data\Boum.wav',snd_nodefault or snd_async);
  case sn of                   //sélection de la direction du tir
    0 : begin
          Pima.Picture.Bitmap.Assign(tbfeu[0]);
          Pima.Left := xm+5;
          Pima.Top := ym+5;
          Pima.Visible := true;
          for i := 1 to 19 do
          begin
            Pima.Top := Pima.Top - 1;
            Mer.Repaint;
            Sleep(20-i);
          end;
        end;
    1 : begin
          Pima.Picture.Bitmap.Assign(tbfeu[1]);
          Pima.Left := xm+5;
          Pima.Top := ym+5;
          Pima.Visible := true;
          for i := 1 to 19 do
          begin
            Pima.Top := Pima.Top + 1;
            Mer.Repaint;
            Sleep(20-i);
          end;
        end;
    2 : begin
          Pima.Picture.Bitmap.Assign(tbfeu[2]);
          Pima.Left := xm+5;
          Pima.Top := ym+5;
          Pima.Visible := true;
          for i := 1 to 19 do
          begin
            Pima.Left := Pima.Left - 1;
            Mer.Repaint;
            Sleep(20-i);
          end;
        end;
    3 : begin
          Pima.Picture.Bitmap.Assign(tbfeu[3]);
          Pima.Left := xm+5;
          Pima.Top := ym+5;
          Pima.Visible := true;
          for i := 1 to 19 do
          begin
            Pima.Left := Pima.Left + 1;
            Mer.Repaint;
            Sleep(20-i);
          end;
        end;
  end;
  Pima.Visible := false;
  Pima.Left := 855;
  Sleep(200);
  Dec(be.vies);
  batos[ne] := be;
  AfficheBateau(ne);
  if be.vies = 0 then
  begin
    Coule(ne);
    Tablo[be.cl,be.lg] := 0;
  end;
  Sleep(200);
end;

procedure TFmain.Coule(nb : byte);    // bateau détruit
var  i,j,x,y : integer;
begin
  x := batos[nb].cl * dim;
  y := batos[nb].lg * dim;
  j := batos[nb].joueur;
  if bson then
    SndPlaySound('Data\Coule.wav',snd_nodefault or snd_async);
  for i := 1 to 5 do
  begin
    Mer.Canvas.Draw(x,y,tbfon[i]);
    Mer.Repaint;
    Sleep(200);
  end;
  if j = 1 then          // décompye des points et test de fin
  begin
    Dec(nbnav[1]);
    Pn1.Caption := IntToStr(nbnav[1]);
    if nbnav[1] = 0 then
    begin
      gagne := 2;
      Dlgfin.ShowModal;
      fin := true;
    end;
  end
  else begin
         Dec(nbnav[2]);
         Pn2.Caption := IntToStr(nbnav[2]);
         if nbnav[2] = 0 then
         begin
           gagne := 1;
           Dlgfin.ShowModal;
           fin := true;
         end;  
       end;
end;
//-------------------------- Jeu ordi --------------------------------------
procedure TFmain.JeuOrdi;
var  i,sn,n : byte;
     cl,lg : integer;
     val,eval : Tval;
begin
  if fin then exit;
  eval.val := -50;
  for i := 20 downto 11 do
  begin
    if batos[i].vies > 0 then
    begin
      for sn := 1 to 4 do
      begin
        val := Evaluation(i,sn);
        val.ba := i;
        if val.val > eval.val then eval := val
        else
          if val.val = eval.val then
          begin
            n := Random(2);
            if n = 0 then eval := val;
          end;
      end;
    end;
  end;
  if eval.val < -40 then         // pas de bateau en vue ou danger
  begin
    eval.val := -50;
    for i := 20 downto 11 do
    begin
      if batos[i].vies > 0 then
      begin
        cl := batos[i].cl;
        lg := batos[i].lg;
        val := EvSens1(cl,lg);
        val.ba := i;
        if val.val > eval.val then eval := val
        else
          if val.val = eval.val then
          begin
            n := Random(2);
            if n = 0 then eval := val;
          end;
        val := EvSens2(cl,lg);
        val.ba := i;
        if val.val > eval.val then eval := val
        else
          if val.val = eval.val then
          begin
            n := Random(2);
            if n = 0 then eval := val;
          end;
        val := EvSens3(cl,lg);
        val.ba := i;
        if val.val > eval.val then eval := val
        else
          if val.val = eval.val then
          begin
            n := Random(2);
            if n = 0 then eval := val;
          end;
        val := EvSens4(cl,lg);
        val.ba := i;
        if val.val > eval.val then eval := val
        else
          if val.val = eval.val then
          begin
            n := Random(2);
            if n = 0 then eval := val;
          end;
      end;
    end;
  end;
  noba := eval.ba;
  cl1 := batos[noba].cl;
  lg1 := batos[noba].lg;
  cl2 := eval.cl;
  lg2 := eval.lg;
  if (cl1 = cl2) and (lg1 = lg2) then
  begin
    gagne := 0;
    Dlgfin.ShowModal;
    fin := true;
    exit;
  end;
  dx := cl1 * dim;
  dy := lg1 * dim;
  fx := cl2 * dim;
  fy := lg2 * dim;
  AfficheBateau(noba);
  Pima.Picture.Bitmap := bato;
  Pima.Left := dx+5;
  Pima.Top := dy+5;
  Mer.Canvas.Draw(dx,dy,fond);
  Pima.Visible := true;
  batos[noba].sens := QuelSens(noba);     // positionne le bateau
  batos[noba].cl := cl2;
  batos[noba].lg := lg2;
  MoveBateau(noba,dx,dy,fx,fy);
  AfficheBateau(noba);
  Pima.Visible := false;
  Pima.Left := 855;
  tablo[cl1,lg1] := 0;
  tablo[cl2,lg2] := noba;
  Combat(noba);
  if jr = 2 then
  begin
    jr := 1;
  end
  else begin
         jr := 2;
       end;
end;

// recherche des bateaux pouvant être attaqués dans les quatre directions
function TFmain.Evaluation(bn,sn : byte) : Tval;
var  nc,cl,lg : integer;
     ba : byte;
     mb : TBato;
     va,eva : Tval;
begin
  eva.val := -50;
  mb := batos[bn];
  cl := mb.cl;
  lg := mb.lg;
  case sn of
    1 : begin
          nc := cl;
          while (nc < 11) and (tablo[nc+1,lg] = 0) do
          begin
            inc(nc);
            va.val := 0;
            if nc < 11 then
            begin
              ba := tablo[nc+1,lg];               // bateau devant
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                  begin
                    if mb.vies < 2 then va.val := -80
                    else va.val := -45;
                  end
                  else va.val := -20 - batos[ba].vies;   
                end;
            end;
            if lg > 0 then                        // babord
            begin
              ba  := tablo[nc,lg-1];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if lg < 7 then                       // tribord
            begin
              ba  := tablo[nc,lg+1];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if va.val <> 0 then
              if va.val > eva.val then eva := va;
          end; // while
        end;   // 1
    2 : begin
          nc := lg;
          while (nc < 7) and (tablo[cl,nc+1] = 0) do
          begin
            inc(nc);
            va.val := 0;
            if nc < 7 then
            begin
              ba := tablo[cl,nc+1];               // bateau devant
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                  begin
                    if mb.vies < 2 then va.val := -80
                    else va.val := -45;
                  end
                  else va.val := -20 - batos[ba].vies;
                end;
            end;
            if cl > 0 then                        // tribord
            begin
              ba  := tablo[cl-1,nc];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10  - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if cl < 11 then                       // babord
            begin
              ba  := tablo[cl+1,nc];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if va.val <> 0 then
              if va.val > eva.val then eva := va;
          end; // while
        end;   // 2
    3 : begin
          nc := cl;
          while (nc > 0) and (tablo[nc-1,lg] = 0) do
          begin
            dec(nc);
            va.val := 0;
            if nc > 0 then
            begin
              ba := tablo[nc-1,lg];              // bateau devant
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                  begin
                    if mb.vies < 2 then va.val := -80
                    else va.val := -45;
                  end
                  else va.val := -20 - batos[ba].vies;
                end;
            end;
            if lg > 0 then                      // tribord
            begin
              ba  := tablo[nc,lg-1];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 20 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if lg < 7 then                      // babord
            begin
              ba  := tablo[nc,lg+1];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := nc;
                  va.lg := lg;
                  if batos[ba].sens in [2,4] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 20 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if va.val <> 0 then
              if va.val > eva.val then eva := va;
          end; // while
        end;   // 3
    4 : begin
          nc := lg;
          while (nc > 0) and (tablo[cl,nc-1] = 0) do
          begin
            dec(nc);
            va.val := 0;
            if nc > 0 then
            begin
              ba := tablo[cl,nc-1];               // bateau devant
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                  begin
                    if mb.vies < 2 then va.val := -80
                    else va.val := -45;
                  end
                  else va.val := -20 - batos[ba].vies;
                end;
            end;
            if cl > 0 then                        // babord
            begin
              ba  := tablo[cl-1,nc];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10 - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if cl < 11 then                       // tribord
            begin
              ba  := tablo[cl+1,nc];
              if ba > 0 then
                if batos[ba].joueur = 1 then
                begin
                  va.cl := cl;
                  va.lg := nc;
                  if batos[ba].sens in [1,3] then
                    va.val := va.val + 50 - batos[ba].vies
                  else
                    va.val := va.val + 10  - batos[ba].vies;
                  if batos[ba].vies = 1 then inc(va.val,30);
                end;
            end;
            if va.val <> 0 then
              if va.val > eva.val then eva := va;
          end; // while
        end;   // 4
  end;  // case
  Result := eva;
end;

// 4 fonctions récursives :
//   si aucun combat possible, recherche du meilleur déplacement
function TFmain.EvSens1(cl,lg : byte) : Tval;
var  nc,nl : integer;
     va,eva : tval;
     be,ex : byte;
begin
  ex := 0;
  if cl < 11 then
  begin
    eva.val := 0;
    if tablo[cl+1,lg] = 0 then
    begin
      nc := cl+1;
      eva.cl := nc;
      eva.lg := lg;
      if lg > 0 then
      begin
        if tablo[nc,lg-1] = 0 then
        begin
          nl := lg-1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            dec(nl);
          until nl < 0;
        end;
      end;
      if lg < 7 then
      begin
        if tablo[nc,lg+1] = 0 then
        begin
          nl := lg+1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            inc(nl);
          until nl > 7;
        end;
      end;
      if nc+1 <= 11 then
      begin
        be := tablo[nc+1,lg];
        if be in[1..10] then
          if batos[be].sens in[2,4] then dec(eva.val,20)
          else inc(eva.val,10);
        if lg > 0 then
          for nl := lg-1 downto 0 do
            if tablo[nc+1,nl] in[1..10] then dec(eva.val,20);
        if lg < 7 then
          for nl := lg+1 to 7 do
            if tablo[nc+1,nl] in[1..10] then dec(eva.val,20);
      end;
      if lg > 0 then
        for nl := lg-1 downto 0 do
          if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
      if lg < 7 then
          for nl := lg+1 to 7 do
            if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
    end
    else
      begin
        be := tablo[cl+1,lg];
        eva.cl := cl;
        eva.lg := lg;
        ex := 1;
        if be < 11 then eva.val := 0
        else
          if batos[be].sens in[1,3] then eva.val := -20
          else eva.val := -40;
      end;
  end
  else
    begin
      eva.cl := cl;
      eva.lg := lg;
      eva.val := -50;
      ex := 1;
    end;
  if (cl+1 < 11) and (ex = 0) then
  begin
    va := EvSens1(cl+1,lg);              // examen case suivante
    if va.val > eva.val then eva := va;
  end;
  Result := eva;
end;

function TFmain.EvSens2(cl,lg : byte) : Tval;
var  nc,nl : integer;
     va,eva : tval;
     be,ex : byte;
begin
  ex := 0;
  if lg < 7 then
  begin
    eva.val := 0;
    if tablo[cl,lg+1] = 0 then
    begin
      nl := lg+1;
      eva.cl := cl;
      eva.lg := nl;
      if cl > 0 then
      begin
        if tablo[cl-1,nl] = 0 then
        begin
          nc := cl-1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            dec(nc);
          until nc < 0;
        end;
      end;
      if cl < 11 then
      begin
        if tablo[cl+1,nl] = 0 then
        begin
          nc := cl+1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            inc(nc);
          until nc > 11;
        end;
       end;
      if nl+1 <= 7 then
      begin
        be := tablo[cl,nl+1];
        if be in[1..10] then
          if batos[be].sens in[1,3] then dec(eva.val,20)
          else inc(eva.val,10);
        if cl > 0 then
          for nc := cl-1 downto 0 do
            if tablo[nc,nl+1] in[1..10] then dec(eva.val,20);
        if cl < 11 then
          for nc := cl+1 to 11 do
            if tablo[nc,nl+1] in[1..10] then dec(eva.val,20);
      end;
      if cl > 0 then
        for nc := cl-1 downto 0 do
          if tablo[nc,nl-1] in[1..10] then dec(eva.val,20);
      if cl < 11 then
          for nc := cl+1 to 11 do
            if tablo[nc,nl-1] in[1..10] then dec(eva.val,20);
    end
    else
      begin
        be := tablo[cl,lg+1];
        eva.cl := cl;
        eva.lg := lg;
        ex := 1;
        if be < 11 then eva.val := 0
        else
          if batos[be].sens in[2,4] then eva.val := -20
          else eva.val := -40;
      end;
  end
  else
    begin
      eva.cl := cl;
      eva.lg := lg;
      eva.val := -50;
      ex := 1;
    end;
  if (lg+1 < 7) and (ex = 0) then
  begin
    va := EvSens2(cl,lg+1);
    if va.val > eva.val then eva := va;
  end;
  Result := eva;
end;

function TFmain.EvSens3(cl,lg : byte) : Tval;
var  nc,nl : integer;
     va,eva : tval;
     be,ex : byte;
begin
  ex := 0;
  if cl > 0 then
  begin
    eva.val := 0;
    if tablo[cl-1,lg] = 0 then
    begin
      nc := cl-1;
      eva.cl := nc;
      eva.lg := lg;
      if lg > 0 then
      begin
        if tablo[nc,lg-1] = 0 then
        begin
          nl := lg-1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            dec(nl);
          until nl < 0;
        end;
      end;
      if lg < 7 then
      begin
        if tablo[nc,lg+1] = 0 then
        begin
          nl := lg+1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            inc(nl);
          until nl > 7;
        end;
      end;
      if nc-1 >= 0 then
      begin
        be := tablo[nc-1,lg];
        if be in[1..10] then
          if batos[be].sens in[2,4] then dec(eva.val,20)
          else inc(eva.val,10);
        if lg > 0 then
          for nl := lg-1 downto 0 do
            if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
        if lg < 7 then
          for nl := lg+1 to 7 do
            if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
      end;
      if lg > 0 then
        for nl := lg-1 downto 0 do
          if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
      if lg < 7 then
          for nl := lg+1 to 7 do
            if tablo[nc-1,nl] in[1..10] then dec(eva.val,20);
    end
    else
      begin
        be := tablo[cl-1,lg];
        eva.cl := cl;
        eva.lg := lg;
        ex := 1;
        if be < 11 then eva.val := 0
        else
          if batos[be].sens in[1,3] then eva.val := -20
          else eva.val := -40;
      end;
  end
  else
    begin
      eva.cl := cl;
      eva.lg := lg;
      eva.val := -50;
      ex := 1;
    end;
  if (cl-1 > 0) and (ex = 0) then
  begin
    va := EvSens3(cl-1,lg);
    if va.val > eva.val then eva := va;
  end;
  Result := eva;
end;

function TFmain.EvSens4(cl,lg : byte) : Tval;
var  nc,nl : integer;
     va,eva : tval;
     be,ex : byte;
begin
  ex := 0;
  if lg > 0 then
  begin
    eva.val := 0;
    if tablo[cl,lg-1] = 0 then
    begin
      nl := lg-1;
      eva.cl := cl;
      eva.lg := nl;
      if cl > 0 then
      begin
        if tablo[cl-1,nl] = 0 then
        begin
          nc := cl-1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            dec(nc);
          until nc < 0;
        end;
      end;
      if cl < 11 then
      begin
        if tablo[cl+1,nl] = 0 then
        begin
          nc := cl+1;
          repeat
            be := tablo[nc,nl];
            if be in[0,11..20] then inc(eva.val,10)
            else dec(eva.val,10);
            inc(nc);
          until nc > 11;
        end;
      end;
      if nl-1 >= 0 then
      begin
        be := tablo[cl,nl-1];
        if be in[1..10] then
          if batos[be].sens in[1,3] then dec(eva.val,20)
          else inc(eva.val,10);
        if cl > 0 then
          for nc := cl-1 downto 0 do
            if tablo[nc,nl+1] in[1..10] then dec(eva.val,20);
        if cl < 11 then
          for nc := cl+1 to 11 do
            if tablo[nc,nl+1] in[1..10] then dec(eva.val,20);
      end;
      if cl > 0 then
        for nc := cl-1 downto 0 do
          if tablo[nc,nl-1] in[1..10] then dec(eva.val,20);
      if cl < 11 then
          for nc := cl+1 to 11 do
            if tablo[nc,nl-1] in[1..10] then dec(eva.val,20);
    end
    else
      begin
        be := tablo[cl,lg-1];
        eva.cl := cl;
        eva.lg := lg;
        ex := 1;
        if be < 11 then eva.val := 0
        else
          if batos[be].sens in[2,4] then eva.val := -20
          else eva.val := -40;
      end;
  end
  else
    begin
      eva.cl := cl;
      eva.lg := lg;
      eva.val := -50;
      ex := 1;
    end;
  if (lg-1 > 0) and (ex = 0) then
  begin
    va := EvSens4(cl,lg-1);
    if va.val > eva.val then eva := va;
  end;
  Result := eva;
end;

//------------------------ Editeur ---------------------------------------
procedure TFmain.Bt_EditClick(Sender: TObject);
begin
  if FEdit.ShowModal = mrOk then
  begin
    AppliquerTableau;
    QuiCommence;
  end;  
end;

procedure TFmain.AppliquerTableau;
var  i : byte;
     cl,lg : integer;
     mb : TBato;
begin
  for i := 1 to 20 do batos[i] := eba[i];
  for lg := 0 to 7 do
    for cl := 0 to 11 do
    begin
      tablo[cl,lg] := 0;
      Mer.Canvas.Draw(cl*dim,lg*dim,fond);
    end;
  nbnav[1] := 0;
  nbnav[2] := 0;
  for i := 1 to 20 do
  begin
    mb := batos[i];
    if mb.vies > 0 then
    begin
      tablo[mb.cl,mb.lg] := i;
      inc(nbnav[mb.joueur]);
      AfficheBateau(i);           
    end;
  end;
  Pn1.Caption := IntToStr(nbnav[1]);
  Pn2.Caption := IntToStr(nbnav[2]);
  Mer.Repaint;
end;

procedure TFmain.Bt_AideClick(Sender: TObject);
begin
  Faide.ShowModal;
end;

procedure TFmain.Bt_SonClick(Sender: TObject);
begin
  bson := not bson;
  if bson then
    Bt_Son.Glyph.Assign(ledon)
  else Bt_Son.Glyph.Assign(ledof);
  Bt_Aide.SetFocus;
  fpar.WriteBool('Options','Son',bson);
end;

procedure TFmain.SpeedBarChange(Sender: TObject);
begin
  vite := SpeedBar.Position;
  fpar.WriteInteger('Options','Vitesse',vite);
end;

end.
