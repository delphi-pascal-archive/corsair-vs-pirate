unit BN05;     // Mode d'emploi

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFAide = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Label3: TLabel;
    Memo2: TMemo;
    Label4: TLabel;
    Memo3: TMemo;
    Memo4: TMemo;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FAide: TFAide;

implementation

{$R *.dfm}

end.
