unit ProcessMessage;

interface

uses
  Windows, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Classes, Controls, cxGroupBox, Forms;

type
  TfmProcessMsg = class(TForm)
    cxGroupBox: TcxGroupBox;
    cxMessage: TcxLabel;
  public
    procedure StartMessage(ACaption: string);

    procedure EndMessage;
  end;

var
  fmProcessMsg: TfmProcessMsg;

implementation

{$R *.dfm}

procedure TfmProcessMsg.StartMessage;
begin
  if ACaption = '' then
    fmProcessMsg.cxMessage.Caption := 'Выполняется обработка данных. Это может занять некоторое время.'
  else
    fmProcessMsg.cxMessage.Caption := ACaption;

  fmProcessMsg.Show;

  repeat
    Sleep(10);

    Application.ProcessMessages;

  until fmProcessMsg.Visible;

  Sleep(500);
end;

procedure TfmProcessMsg.EndMessage;
begin
  fmProcessMsg.Hide;
end;

end.
