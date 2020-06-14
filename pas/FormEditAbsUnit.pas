unit FormEditAbsUnit;

interface

uses
  Windows, Forms, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, dxBarDBNav, dxBar, cxClasses, ImgList, Controls, Classes,
  ActnList, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxPC, ExtCtrls;

type
  TFormEditAbs = class(TForm)
    DS: TDataSource;
    DSMaster: TDataSource;
    ActionList: TActionList;
    acCheck: TAction;
    ImageList: TImageList;
    cxStyleRep: TcxStyleRepository;
    cxStyleSel: TcxStyle;
    cxStyleDis: TcxStyle;
    dxBarManager: TdxBarManager;
    dxActionBar: TdxBar;
    dxButtons: TdxBar;
    dxOKButton: TdxBarButton;
    dxCloseButton: TdxBarButton;
    dxAction: TdxBarSubItem;
    dxSave: TdxBarButton;
    dxOK: TdxBarButton;
    dxSaveButton: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxClose: TdxBarButton;
    acSave: TAction;
    acOk: TAction;
    acCancelEdit: TAction;
    dxBarSeparator1: TdxBarSeparator;
    Panel1: TPanel;
    dxBarManagerBar1: TdxBar;
    cxPageControl: TcxPageControl;
    cxTable: TcxTabSheet;
    dxBarDockControl: TdxBarDockControl;
    Grid: TcxGrid;
    tvMain: TcxGridDBTableView;
    lvMain: TcxGridLevel;
    acNew: TAction;
    acEdit: TAction;
    acDelete: TAction;
    acPost: TAction;
    acCancel: TAction;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarDB: TdxBarDBNavigator;
    dxBarDBNavFirst1: TdxBarDBNavButton;
    dxBarDBNavPrev1: TdxBarDBNavButton;
    dxBarDBNavNext1: TdxBarDBNavButton;
    dxBarDBNavLast1: TdxBarDBNavButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btPostClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btFilterClick(Sender: TObject);
    procedure btNewItemRowClick(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
    procedure acOkExecute(Sender: TObject);
    procedure acCancelEditExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure dxBarManagerDocking(Sender: TdxBar;
      Style: TdxBarDockingStyle; DockControl: TdxDockControl;
      var CanDocking: Boolean);
    procedure acNewExecute(Sender: TObject);
    procedure acEditExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acPostExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure tvMainCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure DSStateChange(Sender: TObject);
  private
  public
    FEditForm   : TFormEditAbs;
    Mode        : TDataSetState;

    can_close   : boolean;

    procedure UpdateMaster();

    procedure RefreshInfo(); virtual;
  end;

var
  FormEditAbs: TFormEditAbs;

implementation

uses
  DataModuleUnit
  ;

{$R *.dfm}

procedure TFormEditAbs.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    tvMain.StoreToIniFile('Ini\'+ self.Name +'.ini');
  except
  end;

    if FormStyle = fsMDIChild then
      Action := caFree
    else
      Action := caHide;
end;

procedure TFormEditAbs.RefreshInfo();
begin
  if Visible then
    begin
      acNew.Enabled           := (DS.DataSet <> nil) and (dsBrowse = DS.Dataset.State);
      acEdit.Enabled          := (DS.DataSet <> nil) and (dsBrowse = DS.Dataset.State) and (not DS.DataSet.IsEmpty);
      acDelete.Enabled        := (DS.DataSet <> nil) and (dsBrowse = DS.Dataset.State) and (not DS.DataSet.IsEmpty);

      acPost.Enabled          := (DS.DataSet <> nil) and (DS.Dataset.State in [dsEdit, dsInsert]);
      acCancel.Enabled        := (DS.DataSet <> nil) and (DS.Dataset.State in [dsEdit, dsInsert]);
    end;
end;

procedure TFormEditAbs.btPostClick(Sender: TObject);
begin
  DS.DataSet.Post;

  RefreshInfo();
end;

procedure TFormEditAbs.FormShow(Sender: TObject);
begin
  try
    case Mode of
      dsEdit    : DSMaster.DataSet.Edit;
      dsInsert  : DSMaster.DataSet.Append;
    end;
  except
  end;

  {
  if DS.DataSet = nil then
    cxPageControl.Visible := false;
  }
  
  try
    tvMain.RestoreFromIniFile('Ini\'+ self.Name +'.ini');
  except
  end;

  FormResize(Sender);

  RefreshInfo();
end;

procedure TFormEditAbs.btFilterClick(Sender: TObject);
begin
  tvMain.FilterRow.Visible := not tvMain.FilterRow.Visible;
end;

procedure TFormEditAbs.btNewItemRowClick(Sender: TObject);
begin
  tvMain.NewItemRow.Visible := not tvMain.NewItemRow.Visible;
end;

procedure TFormEditAbs.UpdateMaster();
begin
  if DSMaster.DataSet.State in [dsEdit, dsInsert] then
    DSMaster.DataSet.Post;
end;

procedure TFormEditAbs.acSaveExecute(Sender: TObject);
begin
  UpdateMaster();

  if DS.DataSet <> nil then begin
    if DS.DataSet.State in [dsEdit, dsInsert] then
      try
        DS.DataSet.Post;
      except
      end;

    DS.DataSet.Refresh;
  end;

  RefreshInfo();
end;

procedure TFormEditAbs.acOkExecute(Sender: TObject);
begin
  acSaveExecute(Sender);

  Close;
end;

procedure TFormEditAbs.acCancelEditExecute(Sender: TObject);
begin
  can_close := true;

  if DSMaster.DataSet <> nil then
    if DSMaster.DataSet.State in [dsEdit, dsInsert] then
      DSMaster.DataSet.Cancel;

  if DS.DataSet <> nil then
    if DS.DataSet.State in [dsEdit, dsInsert] then
      DS.DataSet.Cancel;

  Close;
end;

procedure TFormEditAbs.FormResize(Sender: TObject);
begin
  dxButtons.DockedLeft := Width - 210;
end;

procedure TFormEditAbs.dxBarManagerDocking(Sender: TdxBar;
  Style: TdxBarDockingStyle; DockControl: TdxDockControl;
  var CanDocking: Boolean);
begin
  if Sender.Name = 'dxActionBar' then
    CanDocking := false
  else
    CanDocking := true;
end;

procedure TFormEditAbs.acNewExecute(Sender: TObject);
begin
  UpdateMaster();

  DS.DataSet.Append;

  RefreshInfo();

  if FEditForm <> nil then
    FEditForm.ShowModal
end;

procedure TFormEditAbs.acEditExecute(Sender: TObject);
begin
  DS.DataSet.Edit;

  if FEditForm <> nil then
    FEditForm.ShowModal
end;

procedure TFormEditAbs.acDeleteExecute(Sender: TObject);
begin
  DS.DataSet.Delete;

  RefreshInfo();
end;

procedure TFormEditAbs.acPostExecute(Sender: TObject);
begin
  DS.DataSet.Post;

  DS.DataSet.Close;

  DS.DataSet.Open;

  RefreshInfo();
end;

procedure TFormEditAbs.acCancelExecute(Sender: TObject);
begin
  DS.DataSet.Cancel;

  RefreshInfo();
end;

procedure TFormEditAbs.tvMainCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  acEditExecute(Self);
end;

procedure TFormEditAbs.DSDataChange(Sender: TObject; Field: TField);
begin
   RefreshInfo();
end;

procedure TFormEditAbs.DSStateChange(Sender: TObject);
begin
   RefreshInfo(); 
end;

end.
