unit FormReportAbsUnit;

interface

uses
  Windows, Forms, ImgList, Controls, dxBar, cxClasses, Classes, ActnList;

type
  TFormReportAbs = class(TForm)
    ActionList: TActionList;
    acCheck: TAction;
    acPrint: TAction;
    acClose: TAction;
    acRefresh: TAction;
    acExcel: TAction;
    dxBarManager: TdxBarManager;
    dxActions: TdxBar;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    ImageList: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acCloseExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);

    public
      class function Execute(IsModal: Boolean = false):TForm;
  end;

var
  FormReportAbs: TFormReportAbs;

implementation

uses
  IniFiles
  ;

{$R *.dfm}
class function TFormReportAbs.Execute(IsModal: Boolean = false):TForm;
var
  F : TFormReportAbs;
begin
  F := Create(Application);

  if IsModal then
  begin
    F.FormStyle := fsNormal;

    F.Hide;
    
    F.ShowModal
  end;
  {
  else
    F.Show;
  }
  result := F;
end;


procedure TFormReportAbs.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  Ini : TIniFile;
begin
  if Top < 0 then Top := 0;
  if Left < 0 then Left := 0;
  if Width > Screen.WorkAreaWidth - 50 then Width := Screen.WorkAreaWidth - 50;
  if Height > Screen.WorkAreaHeight - 175 then Height := Screen.WorkAreaHeight - 175;

  Ini := TIniFile.Create(self.Name);

  INI.WriteInteger(self.Name, 'Top', Top);
  INI.WriteInteger(self.Name, 'Left', Left);
  INI.WriteInteger(self.Name, 'Width', Width);
  INI.WriteInteger(self.Name, 'Height', Height);

  case self.WindowState of
    wsNormal    : INI.WriteString(self.Name, 'State', 'wsNormal');
    wsMinimized : INI.WriteString(self.Name, 'State', 'wsMinimized');
    wsMaximized : INI.WriteString(self.Name, 'State', 'wsMaximized');
  end;

  Ini.Free;

  Action := caFree;
end;

procedure TFormReportAbs.acCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormReportAbs.FormShow(Sender: TObject);
var
  state: string;

  Ini : TIniFile;
begin
  Ini := TIniFile.Create(self.Name);

  Top   := INI.ReadInteger(self.Name, 'Top',   0);
  Left  := INI.ReadInteger(self.Name, 'Left',  0);
  Width := INI.ReadInteger(self.Name, 'Width', 400);
  Height:= INI.ReadInteger(self.Name, 'Height',400);

  State := INI.ReadString(self.Name, 'State','wsNormal');

  if State = 'wsNormal' then
    self.WindowState := wsNormal
  else
    if State = 'wsMinimized' then
      self.WindowState := wsMinimized
    else
      if State = 'wsMaximized' then
        self.WindowState := wsMaximized;
end;

end.
