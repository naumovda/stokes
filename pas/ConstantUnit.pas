unit ConstantUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxBar, cxClasses, ActnList, ImgList,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid;

type
  TConstant = class(TFormListAbs)
    tvMainCode: TcxGridDBColumn;
    tvMainName: TcxGridDBColumn;
    tvMainValue: TcxGridDBColumn;
    tvMainValueDouble: TcxGridDBColumn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Constant: TConstant;

implementation

{$R *.dfm}

uses
  DataModuleUnit
  ;

end.
