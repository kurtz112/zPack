unit zLocalizer.types;

interface

type
  IzLocalizerListener = interface
    ['{3763B4CA-0E25-4FD6-AA26-0E1E0D1A4D01}']
    procedure TranslationChanged;
  end;

  TResourceKind = (rkProp, rkZZ, rkDX);

  TResourceClassType = (rctComponent, rctScrollingWinControl, rctActionList, rctPageControl, rctLayoutControl, rctLabel, rctRibbonTab, rctCard, rctView, rctPivot, rctFormController, rctTreeMenu,
    rctFileViewer, rctGoogleMaps, rctOkCancel, rctRecordView, rctTree, rctChart, rctScheduler);

implementation

end.
