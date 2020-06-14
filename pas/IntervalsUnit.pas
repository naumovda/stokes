unit IntervalsUnit;

interface

uses
  Windows, FormAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxCalc, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, dxBar, cxClasses, Classes, ActnList,
  ImgList, Controls, cxGridLevel, cxGridCustomView, cxGrid;

type                                    
  TIntervals = class(TFormListAbs)
    tvMainFieldName: TcxGridDBColumn;
    tvMainFieldMin: TcxGridDBColumn;
    tvMainFieldMax: TcxGridDBColumn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Intervals: TIntervals;

implementation

{$R *.dfm}

uses
  DataModuleUnit
  ;

end.
