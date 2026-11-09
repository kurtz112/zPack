unit zOffice.Excel.Editor;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.StdActns,
  Data.DB,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxFontNameComboBox,
  cxDropDownEdit,
  cxBarEditItem,
  cxClasses,
  cxImageList,
  cxDrawTextUtils,
  cxContainer,
  cxEdit,
  cxGroupBox,
  cxStyles,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  cxFilter,
  dxCore,
  dxCoreClasses,
  dxHashUtils,
  dxSpreadSheetCore,
  dxSpreadSheetCoreFormulas,
  dxSpreadSheetCoreHistory,
  dxSpreadSheetCoreStyles,
  dxSpreadSheetCoreStrs,
  dxSpreadSheetConditionalFormatting,
  dxSpreadSheetConditionalFormattingRules,
  dxSpreadSheetClasses,
  dxSpreadSheetContainers,
  dxSpreadSheetFormulas,
  dxSpreadSheetHyperlinks,
  dxSpreadSheetFunctions,
  dxSpreadSheetStyles,
  dxSpreadSheetGraphics,
  dxSpreadSheetPrinting,
  dxSpreadSheetTypes,
  dxSpreadSheetUtils,
  dxSpreadSheetFormattedTextUtils,
  dxBarBuiltInMenu,
  dxSpreadSheet,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  dxSpreadSheetConditionalFormattingRulesActions,
  dxSpreadSheetActions,
  dxGallery,
  dxRibbonGallery,
  dxBar,
  dxRibbonColorGallery,
  dxPrinting,
  dxRibbon,
  dxActions,
  dxStatusBar,
  dxRibbonStatusBar,
  dxPSGlbl,
  dxPSUtl,
  dxPSEngn,
  dxPrnPg,
  dxBkgnd,
  dxWrap,
  dxPrnDev,
  dxPSCompsProvider,
  dxPSFillPatterns,
  dxPSEdgePatterns,
  dxPSPDFExportCore,
  dxPSPDFExport,
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPSdxSpreadSheetLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxPSBaseGridLnk,
  dxPSdxSpreadSheetLnkCore,
  dxSpreadSheetReportDesigner,
  dxSpreadSheetReportDesignerActions,
  dxPSRichEditControlLnk,
  dxRibbonForm,
  dxLayoutContainer,
  dxLayoutcxEditAdapters,
  dxLayoutControl,
  dxFileActions,
  dxScrollbarAnnotations,
  dxPScxTLLnk,
  dxPScxSchedulerLnk,
  dxPSdxPDFViewerLnk,
  dxPScxEditorLnks,
  dxShellDialogs,
  dxUIAClasses,
  dxSpreadSheetFormulaBar,
  cxDBData,
  zFbDataSet,
  zOffice.types,
  zOffice.Excel.Utils;

type
  // IRestriction
  TzViewerExcelEditor = class(TdxRibbonForm)
    dxRibbonStatusBar: TdxRibbonStatusBar;
    dxComponentPrinter: TdxComponentPrinter;
    dxComponentPrinterLink: TdxSpreadSheetReportLnk;
    dxRibbon: TdxRibbon;
    dxBarManager: TdxBarManager;
    ActionList: TActionList;
    dxSpreadSheetNewDocument: TdxSpreadSheetNewDocument;
    dxRibbonTabFile: TdxRibbonTab;
    dxBarCommon: TdxBar;
    dxBarLargeButtonNew: TdxBarLargeButton;
    dxSpreadSheetOpenDocument: TdxFileOpen;
    dxSpreadSheetSaveDocumentAs: TdxFileSaveAs;
    dxBarLargeButtonSaveAs: TdxBarLargeButton;
    dxSpreadSheetShowPrintForm: TdxSpreadSheetShowPrintForm;
    dxSpreadSheetShowPrintPreviewForm: TdxSpreadSheetShowPrintPreviewForm;
    dxBarLargeButtonPrintPreview: TdxBarLargeButton;
    dxSpreadSheetShowPageSetupForm: TdxSpreadSheetShowPageSetupForm;
    dxSpreadSheetPasteSelection: TdxSpreadSheetPasteSelection;
    dxRibbonTabHome: TdxRibbonTab;
    dxBarClipboard: TdxBar;
    dxBarLargeButtonPaste: TdxBarLargeButton;
    dxSpreadSheetCutSelection: TdxSpreadSheetCutSelection;
    dxBarButtonCut: TdxBarButton;
    dxSpreadSheetCopySelection: TdxSpreadSheetCopySelection;
    dxBarButtonCopy: TdxBarButton;
    dxSpreadSheetChangeFontName: TdxSpreadSheetChangeFontName;
    dxBarFont: TdxBar;
    cxBarEditItemFontName: TcxBarEditItem;
    dxSpreadSheetChangeFontSize: TdxSpreadSheetChangeFontSize;
    cxBarEditItemFontSize: TcxBarEditItem;
    dxSpreadSheetIncreaseFontSize: TdxSpreadSheetIncreaseFontSize;
    dxBarButtonIncreaseFontSize: TdxBarButton;
    dxSpreadSheetDecreaseFontSize: TdxSpreadSheetDecreaseFontSize;
    dxBarButtonDecreaseFontSize: TdxBarButton;
    dxSpreadSheetToggleFontBold: TdxSpreadSheetToggleFontBold;
    dxBarButtonBold: TdxBarButton;
    dxSpreadSheetToggleFontItalic: TdxSpreadSheetToggleFontItalic;
    dxBarButtonItalic: TdxBarButton;
    dxSpreadSheetToggleFontUnderline: TdxSpreadSheetToggleFontUnderline;
    dxBarButtonUnderline: TdxBarButton;
    dxSpreadSheetToggleFontStrikeout: TdxSpreadSheetToggleFontStrikeout;
    dxBarButtonStrikeout: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxSpreadSheetBordersBottom: TdxSpreadSheetBordersBottom;
    dxBarLargeButtonBottomBorder: TdxBarLargeButton;
    dxSpreadSheetBordersTop: TdxSpreadSheetBordersTop;
    dxBarLargeButtonTopBorder: TdxBarLargeButton;
    dxSpreadSheetBordersLeft: TdxSpreadSheetBordersLeft;
    dxBarLargeButtonLeftBorder: TdxBarLargeButton;
    dxSpreadSheetBordersRight: TdxSpreadSheetBordersRight;
    dxBarLargeButtonRightBorder: TdxBarLargeButton;
    dxSpreadSheetBordersNone: TdxSpreadSheetBordersNone;
    dxBarLargeButtonNoBorder: TdxBarLargeButton;
    dxSpreadSheetBordersAll: TdxSpreadSheetBordersAll;
    dxBarLargeButtonAllBorders: TdxBarLargeButton;
    dxSpreadSheetBordersOutside: TdxSpreadSheetBordersOutside;
    dxBarLargeButtonOutsideBorders: TdxBarLargeButton;
    dxSpreadSheetBordersOutsideThick: TdxSpreadSheetBordersOutsideThick;
    dxBarLargeButtonThickBoxBorder: TdxBarLargeButton;
    dxSpreadSheetBordersBottomDouble: TdxSpreadSheetBordersBottomDouble;
    dxBarLargeButtonBottomDoubleBorder: TdxBarLargeButton;
    dxSpreadSheetBordersBottomThick: TdxSpreadSheetBordersBottomThick;
    dxBarLargeButtonThickBottomBorder: TdxBarLargeButton;
    dxSpreadSheetBordersTopAndBottom: TdxSpreadSheetBordersTopAndBottom;
    dxBarLargeButtonTopandBottomBorder: TdxBarLargeButton;
    dxSpreadSheetBordersTopAndBottomThick: TdxSpreadSheetBordersTopAndBottomThick;
    dxBarLargeButtonTopandThickBottomBorder: TdxBarLargeButton;
    dxSpreadSheetBordersTopAndBottomDouble: TdxSpreadSheetBordersTopAndBottomDouble;
    dxBarLargeButtonTopandDoubleBottomBorder: TdxBarLargeButton;
    dxSpreadSheetBordersMore: TdxSpreadSheetBordersMore;
    dxBarLargeButtonMore: TdxBarLargeButton;
    dxSpreadSheetChangeFillColor: TdxSpreadSheetChangeFillColor;
    dxRibbonColorGalleryItemFillColor: TdxRibbonColorGalleryItem;
    dxSpreadSheetChangeFontColor: TdxSpreadSheetChangeFontColor;
    dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem;
    dxSpreadSheetAlignVerticalTop: TdxSpreadSheetAlignVerticalTop;
    dxBarAlignment: TdxBar;
    dxBarButtonTopAlign: TdxBarButton;
    dxSpreadSheetAlignVerticalCenter: TdxSpreadSheetAlignVerticalCenter;
    dxBarButtonMiddleAlign: TdxBarButton;
    dxSpreadSheetAlignVerticalBottom: TdxSpreadSheetAlignVerticalBottom;
    dxBarButtonBottomAlign: TdxBarButton;
    dxSpreadSheetAlignHorizontalLeft: TdxSpreadSheetAlignHorizontalLeft;
    dxBarButtonAlignTextLeft: TdxBarButton;
    dxSpreadSheetAlignHorizontalCenter: TdxSpreadSheetAlignHorizontalCenter;
    dxBarButtonAlignTextCenter: TdxBarButton;
    dxSpreadSheetAlignHorizontalRight: TdxSpreadSheetAlignHorizontalRight;
    dxBarButtonAlignTextRight: TdxBarButton;
    dxSpreadSheetTextIndentDecrease: TdxSpreadSheetTextIndentDecrease;
    dxBarButtonDecreaseIndent: TdxBarButton;
    dxSpreadSheetTextIndentIncrease: TdxSpreadSheetTextIndentIncrease;
    dxBarButtonIncreaseIndent: TdxBarButton;
    dxSpreadSheetTextWrap: TdxSpreadSheetTextWrap;
    dxBarButtonWrapText: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    dxSpreadSheetMergeCellsAndCenter: TdxSpreadSheetMergeCellsAndCenter;
    dxBarLargeButtonMergeandCenter: TdxBarLargeButton;
    dxSpreadSheetMergeCellsAcross: TdxSpreadSheetMergeCellsAcross;
    dxBarLargeButtonMergeAcross: TdxBarLargeButton;
    dxSpreadSheetMergeCells: TdxSpreadSheetMergeCells;
    dxBarLargeButtonMergeCells: TdxBarLargeButton;
    dxSpreadSheetUnmergeCells: TdxSpreadSheetUnmergeCells;
    dxBarLargeButtonUnmergeCells: TdxBarLargeButton;
    dxBarCells: TdxBar;
    dxBarSubItem3: TdxBarSubItem;
    dxSpreadSheetInsertRows: TdxSpreadSheetInsertRows;
    dxBarLargeButtonInsertSheetRows: TdxBarLargeButton;
    dxSpreadSheetInsertColumns: TdxSpreadSheetInsertColumns;
    dxBarLargeButtonInsertSheetColumns: TdxBarLargeButton;
    dxSpreadSheetInsertSheet: TdxSpreadSheetInsertSheet;
    dxBarLargeButtonInsertSheet: TdxBarLargeButton;
    dxBarSubItem4: TdxBarSubItem;
    dxSpreadSheetDeleteRows: TdxSpreadSheetDeleteRows;
    dxBarLargeButtonDeleteSheetRows: TdxBarLargeButton;
    dxSpreadSheetDeleteColumns: TdxSpreadSheetDeleteColumns;
    dxBarLargeButtonDeleteSheetColumns: TdxBarLargeButton;
    dxSpreadSheetDeleteSheet: TdxSpreadSheetDeleteSheet;
    dxBarLargeButtonDeleteSheet: TdxBarLargeButton;
    dxBarSubItem5: TdxBarSubItem;
    dxSpreadSheetAutoFitRowHeight: TdxSpreadSheetAutoFitRowHeight;
    dxBarLargeButtonAutoFitRowHeight: TdxBarLargeButton;
    dxSpreadSheetAutoFitColumnWidth: TdxSpreadSheetAutoFitColumnWidth;
    dxBarLargeButtonAutoFitColumnWidth: TdxBarLargeButton;
    dxBarSubItem6: TdxBarSubItem;
    dxSpreadSheetHideRows: TdxSpreadSheetHideRows;
    dxBarLargeButtonHideRows: TdxBarLargeButton;
    dxSpreadSheetHideColumns: TdxSpreadSheetHideColumns;
    dxBarLargeButtonHideColumns: TdxBarLargeButton;
    dxSpreadSheetHideSheet: TdxSpreadSheetHideSheet;
    dxBarLargeButtonHideSheet: TdxBarLargeButton;
    dxSpreadSheetUnhideRows: TdxSpreadSheetUnhideRows;
    dxBarLargeButtonUnhideRows: TdxBarLargeButton;
    dxSpreadSheetUnhideColumns: TdxSpreadSheetUnhideColumns;
    dxBarLargeButtonUnhideColumns: TdxBarLargeButton;
    dxSpreadSheetUnhideSheet: TdxSpreadSheetUnhideSheet;
    dxBarLargeButtonUnhideSheet: TdxBarLargeButton;
    dxBarEditing: TdxBar;
    dxBarSubItem7: TdxBarSubItem;
    dxSpreadSheetClearAll: TdxSpreadSheetClearAll;
    dxBarLargeButtonClearAll: TdxBarLargeButton;
    dxSpreadSheetClearFormats: TdxSpreadSheetClearFormats;
    dxBarLargeButtonClearFormats: TdxBarLargeButton;
    dxSpreadSheetClearContents: TdxSpreadSheetClearContents;
    dxBarLargeButtonClearContents: TdxBarLargeButton;
    dxSpreadSheetUndo: TdxSpreadSheetUndo;
    dxBarLargeButtonUndo: TdxBarLargeButton;
    dxSpreadSheetRedo: TdxSpreadSheetRedo;
    dxBarLargeButtonRedo: TdxBarLargeButton;
    dxSpreadSheetFindAndReplace: TdxSpreadSheetFindAndReplace;
    dxBarLargeButtonFindReplace: TdxBarLargeButton;
    dxSpreadSheetInsertPicture: TdxSpreadSheetInsertPicture;
    dxRibbonTabInsert: TdxRibbonTab;
    dxBarIllustrations: TdxBar;
    dxBarLargeButtonPicture: TdxBarLargeButton;
    dxSpreadSheetShowHyperlinkEditor: TdxSpreadSheetShowHyperlinkEditor;
    dxBarLinks: TdxBar;
    dxBarLargeButtonHyperlink: TdxBarLargeButton;
    dxSpreadSheetPageMarginsGallery: TdxSpreadSheetPageMarginsGallery;
    dxRibbonTabPageLayout: TdxRibbonTab;
    dxBarPageSetup: TdxBar;
    dxRibbonGalleryItemMargins: TdxRibbonGalleryItem;
    dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem;
    dxSpreadSheetMorePageMargins: TdxSpreadSheetMorePageMargins;
    dxBarLargeButtonMorePageMargins: TdxBarLargeButton;
    dxSpreadSheetPageOrientationGallery: TdxSpreadSheetPageOrientationGallery;
    dxRibbonGalleryItemOrientation: TdxRibbonGalleryItem;
    dxRibbonGalleryItemOrientationGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemOrientationGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemOrientationGroup1Item2: TdxRibbonGalleryGroupItem;
    dxSpreadSheetPaperSizeGallery: TdxSpreadSheetPaperSizeGallery;
    dxRibbonGalleryItemSize: TdxRibbonGalleryItem;
    dxRibbonGalleryItemSizeGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemSizeGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item10: TdxRibbonGalleryGroupItem;
    dxSpreadSheetMorePaperSizes: TdxSpreadSheetMorePaperSizes;
    dxBarLargeButtonMorePaperSizes: TdxBarLargeButton;
    dxBarSubItem8: TdxBarSubItem;
    dxSpreadSheetSetPrintArea: TdxSpreadSheetSetPrintArea;
    dxBarLargeButtonSetPrintArea: TdxBarLargeButton;
    dxSpreadSheetClearPrintArea: TdxSpreadSheetClearPrintArea;
    dxBarLargeButtonClearPrintArea: TdxBarLargeButton;
    dxBarSubItem9: TdxBarSubItem;
    dxSpreadSheetInsertPageBreak: TdxSpreadSheetInsertPageBreak;
    dxBarLargeButtonInsertPageBreak: TdxBarLargeButton;
    dxSpreadSheetRemovePageBreak: TdxSpreadSheetRemovePageBreak;
    dxBarLargeButtonRemovePageBreak: TdxBarLargeButton;
    dxSpreadSheetResetAllPageBreaks: TdxSpreadSheetResetAllPageBreaks;
    dxBarLargeButtonResetAllPageBreaks: TdxBarLargeButton;
    dxSpreadSheetPrintTitles: TdxSpreadSheetPrintTitles;
    dxBarLargeButtonPrintTitles: TdxBarLargeButton;
    dxSpreadSheetAutoSumGallery: TdxSpreadSheetAutoSumGallery;
    dxRibbonTabFormulas: TdxRibbonTab;
    dxBarFunctionLibrary: TdxBar;
    dxRibbonGalleryItemAutoSum: TdxRibbonGalleryItem;
    dxRibbonGalleryItemAutoSumGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemAutoSumGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemAutoSumGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemAutoSumGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemAutoSumGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemAutoSumGroup1Item5: TdxRibbonGalleryGroupItem;
    dxSpreadSheetFinancialFormulasGallery: TdxSpreadSheetFinancialFormulasGallery;
    dxRibbonGalleryItemFinancial: TdxRibbonGalleryItem;
    dxRibbonGalleryItemFinancialGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemFinancialGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemFinancialGroup1Item7: TdxRibbonGalleryGroupItem;
    dxSpreadSheetLogicalFormulasGallery: TdxSpreadSheetLogicalFormulasGallery;
    dxRibbonGalleryItemLogical: TdxRibbonGalleryItem;
    dxRibbonGalleryItemLogicalGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemLogicalGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLogicalGroup1Item9: TdxRibbonGalleryGroupItem;
    dxSpreadSheetTextFormulasGallery: TdxSpreadSheetTextFormulasGallery;
    dxRibbonGalleryItemText: TdxRibbonGalleryItem;
    dxRibbonGalleryItemTextGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemTextGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item16: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item17: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item18: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item19: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item20: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item21: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item22: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTextGroup1Item23: TdxRibbonGalleryGroupItem;
    dxSpreadSheetDateAndTimeFormulasGallery: TdxSpreadSheetDateAndTimeFormulasGallery;
    dxRibbonGalleryItemDateTime: TdxRibbonGalleryItem;
    dxRibbonGalleryItemDateTimeGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemDateTimeGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item16: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item17: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item18: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item19: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item20: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item21: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item22: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item23: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDateTimeGroup1Item24: TdxRibbonGalleryGroupItem;
    dxSpreadSheetLookupAndReferenceFormulasGallery: TdxSpreadSheetLookupAndReferenceFormulasGallery;
    dxRibbonGalleryItemLookupReference: TdxRibbonGalleryItem;
    dxRibbonGalleryItemLookupReferenceGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemLookupReferenceGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemLookupReferenceGroup1Item16: TdxRibbonGalleryGroupItem;
    dxSpreadSheetMathAndTrigFormulasGallery: TdxSpreadSheetMathAndTrigFormulasGallery;
    dxRibbonGalleryItemMathTrig: TdxRibbonGalleryItem;
    dxRibbonGalleryItemMathTrigGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemMathTrigGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item16: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item17: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item18: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item19: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item20: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item21: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item22: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item23: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item24: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item25: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item26: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item27: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item28: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item29: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item30: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item31: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item32: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item33: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item34: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item35: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item36: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item37: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item38: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item39: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item40: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item41: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item42: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item43: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item44: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item45: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item46: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item47: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item48: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item49: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item50: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item51: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item52: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item53: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item54: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item55: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item56: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item57: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item58: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item59: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item60: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item61: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item62: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item63: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item64: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item65: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item66: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item67: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item68: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMathTrigGroup1Item69: TdxRibbonGalleryGroupItem;
    dxBarSubItem10: TdxBarSubItem;
    dxSpreadSheetStatisticalFormulasGallery: TdxSpreadSheetStatisticalFormulasGallery;
    dxRibbonGalleryItemStatistical: TdxRibbonGalleryItem;
    dxRibbonGalleryItemStatisticalGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemStatisticalGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item16: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item17: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item18: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item19: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item20: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item21: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item22: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item23: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item24: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item25: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item26: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item27: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item28: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item29: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item30: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item31: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item32: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item33: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item34: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item35: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item36: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item37: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item38: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item39: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item40: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item41: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item42: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item43: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item44: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item45: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item46: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item47: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item48: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item49: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item50: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item51: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item52: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item53: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item54: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item55: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item56: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item57: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item58: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item59: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item60: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item61: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item62: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item63: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item64: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item65: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item66: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item67: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item68: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item69: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item70: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item71: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item72: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item73: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item74: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemStatisticalGroup1Item75: TdxRibbonGalleryGroupItem;
    dxSpreadSheetInformationFormulasGallery: TdxSpreadSheetInformationFormulasGallery;
    dxRibbonGalleryItemInformation: TdxRibbonGalleryItem;
    dxRibbonGalleryItemInformationGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemInformationGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemInformationGroup1Item13: TdxRibbonGalleryGroupItem;
    dxSpreadSheetCompatibilityFormulasGallery: TdxSpreadSheetCompatibilityFormulasGallery;
    dxRibbonGalleryItemCompatibility: TdxRibbonGalleryItem;
    dxRibbonGalleryItemCompatibilityGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemCompatibilityGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item12: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item13: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item14: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item15: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item16: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item17: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item18: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item19: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item20: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item21: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item22: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item23: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item24: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemCompatibilityGroup1Item25: TdxRibbonGalleryGroupItem;
    dxSpreadSheetShowDefinedNameManager: TdxSpreadSheetShowDefinedNameManager;
    dxBarDefinedNames: TdxBar;
    dxBarLargeButtonNameManager: TdxBarLargeButton;
    dxSpreadSheetCreateDefinedName: TdxSpreadSheetCreateDefinedName;
    dxBarButtonDefineName: TdxBarButton;
    dxSpreadSheetUseDefinedNameInFormula: TdxSpreadSheetUseDefinedNameInFormula;
    dxRibbonGalleryItemUseinFormula: TdxRibbonGalleryItem;
    dxRibbonGalleryItemUseinFormulaGroup1: TdxRibbonGalleryGroup;
    dxSpreadSheetCreateDefinedNamesFromSelection: TdxSpreadSheetCreateDefinedNamesFromSelection;
    dxBarButtonCreatefromSelection: TdxBarButton;
    dxSpreadSheetSortAscending: TdxSpreadSheetSortAscending;
    dxRibbonTabData: TdxRibbonTab;
    dxBarSortFilter: TdxBar;
    dxBarLargeButtonSortAtoZ: TdxBarLargeButton;
    dxSpreadSheetSortDescending: TdxSpreadSheetSortDescending;
    dxBarLargeButtonSortZtoA: TdxBarLargeButton;
    dxBarGrouping: TdxBar;
    dxBarSubItem11: TdxBarSubItem;
    dxSpreadSheetGroupColumns: TdxSpreadSheetGroupColumns;
    dxBarLargeButtonGroupColumns: TdxBarLargeButton;
    dxSpreadSheetGroupRows: TdxSpreadSheetGroupRows;
    dxBarLargeButtonGroupRows: TdxBarLargeButton;
    dxBarSubItem12: TdxBarSubItem;
    dxSpreadSheetUngroupColumns: TdxSpreadSheetUngroupColumns;
    dxBarLargeButtonUngroupColumns: TdxBarLargeButton;
    dxSpreadSheetUngroupRows: TdxSpreadSheetUngroupRows;
    dxBarLargeButtonUngroupRows: TdxBarLargeButton;
    dxSpreadSheetNewComment: TdxSpreadSheetNewComment;
    dxRibbonTabReview: TdxRibbonTab;
    dxBarComments: TdxBar;
    dxBarLargeButtonNewComment: TdxBarLargeButton;
    dxSpreadSheetEditComment: TdxSpreadSheetEditComment;
    dxBarLargeButtonEditComment: TdxBarLargeButton;
    dxSpreadSheetDeleteComments: TdxSpreadSheetDeleteComments;
    dxBarLargeButtonDeleteComments: TdxBarLargeButton;
    dxSpreadSheetPreviousComment: TdxSpreadSheetPreviousComment;
    dxBarLargeButtonPreviousComment: TdxBarLargeButton;
    dxSpreadSheetNextComment: TdxSpreadSheetNextComment;
    dxBarLargeButtonNextComment: TdxBarLargeButton;
    dxSpreadSheetShowHideComments: TdxSpreadSheetShowHideComments;
    dxBarLargeButtonShowHideComments: TdxBarLargeButton;
    dxSpreadSheetProtectSheet: TdxSpreadSheetProtectSheet;
    dxBarChanges: TdxBar;
    dxBarLargeButtonProtectSheet: TdxBarLargeButton;
    dxSpreadSheetProtectWorkbook: TdxSpreadSheetProtectWorkbook;
    dxBarLargeButtonProtectWorkbook: TdxBarLargeButton;
    dxSpreadSheetZoomOut: TdxSpreadSheetZoomOut;
    dxRibbonTabView: TdxRibbonTab;
    dxBarZoom: TdxBar;
    dxBarLargeButtonZoomOut: TdxBarLargeButton;
    dxSpreadSheetZoomIn: TdxSpreadSheetZoomIn;
    dxBarLargeButtonZoomIn: TdxBarLargeButton;
    dxSpreadSheetZoomDefault: TdxSpreadSheetZoomDefault;
    dxBarLargeButton100: TdxBarLargeButton;
    dxBarFreezePanes: TdxBar;
    dxBarSubItem13: TdxBarSubItem;
    dxSpreadSheetFreezePanes: TdxSpreadSheetFreezePanes;
    dxBarLargeButtonFreezePanes: TdxBarLargeButton;
    dxSpreadSheetUnfreezePanes: TdxSpreadSheetUnfreezePanes;
    dxBarLargeButtonUnfreezePanes: TdxBarLargeButton;
    dxSpreadSheetFreezeTopRow: TdxSpreadSheetFreezeTopRow;
    dxBarLargeButtonFreezeTopRow: TdxBarLargeButton;
    dxSpreadSheetFreezeFirstColumn: TdxSpreadSheetFreezeFirstColumn;
    dxBarLargeButtonFreezeFirstColumn: TdxBarLargeButton;
    dxBarConditionalFormatting: TdxBar;
    dxBarSubItem14: TdxBarSubItem;
    dxSpreadSheetConditionalFormattingTopBottomRulesGallery: TdxSpreadSheetConditionalFormattingTopBottomRulesGallery;
    dxRibbonGalleryItemTopBottomRules: TdxRibbonGalleryItem;
    dxRibbonGalleryItemTopBottomRulesGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemTopBottomRulesGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTopBottomRulesGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTopBottomRulesGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTopBottomRulesGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTopBottomRulesGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemTopBottomRulesGroup1Item6: TdxRibbonGalleryGroupItem;
    dxSpreadSheetConditionalFormattingMoreRules: TdxSpreadSheetConditionalFormattingMoreRules;
    dxBarLargeButtonMoreRules: TdxBarLargeButton;
    dxSpreadSheetConditionalFormattingDataBarsGallery: TdxSpreadSheetConditionalFormattingDataBarsGallery;
    dxRibbonGalleryItemDataBars: TdxRibbonGalleryItem;
    dxRibbonGalleryItemDataBarsGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemDataBarsGroup2: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemDataBarsGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemDataBarsGroup2Item6: TdxRibbonGalleryGroupItem;
    dxSpreadSheetConditionalFormattingColorScalesGallery: TdxSpreadSheetConditionalFormattingColorScalesGallery;
    dxRibbonGalleryItemColorScales: TdxRibbonGalleryItem;
    dxRibbonGalleryItemColorScalesGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemColorScalesGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item10: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item11: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemColorScalesGroup1Item12: TdxRibbonGalleryGroupItem;
    dxSpreadSheetConditionalFormattingIconSetsGallery: TdxSpreadSheetConditionalFormattingIconSetsGallery;
    dxRibbonGalleryItemIconSets: TdxRibbonGalleryItem;
    dxRibbonGalleryItemIconSetsGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemIconSetsGroup2: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemIconSetsGroup3: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemIconSetsGroup4: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemIconSetsGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup2Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup3Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup2Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup2Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup3Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup3Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup4Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup3Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup3Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup4Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup4Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemIconSetsGroup4Item4: TdxRibbonGalleryGroupItem;
    dxSpreadSheetConditionalFormattingNewRule: TdxSpreadSheetConditionalFormattingNewRule;
    dxBarLargeButtonNewRule: TdxBarLargeButton;
    dxBarSubItem15: TdxBarSubItem;
    dxSpreadSheetConditionalFormattingClearRulesFromSelectedCells: TdxSpreadSheetConditionalFormattingClearRulesFromSelectedCells;
    dxBarLargeButtonClearRulesFromSelectedCells: TdxBarLargeButton;
    dxSpreadSheetConditionalFormattingClearRulesFromEntireSheet: TdxSpreadSheetConditionalFormattingClearRulesFromEntireSheet;
    dxBarLargeButtonClearRulesFromEntireSheet: TdxBarLargeButton;
    dxSpreadSheetShowConditionalFormattingRulesManager: TdxSpreadSheetShowConditionalFormattingRulesManager;
    dxBarLargeButtonManageRules: TdxBarLargeButton;
    dxSpreadSheetReportDesignerSingleSheetReportMode: TdxSpreadSheetReportDesignerSingleSheetReportMode;
    dxBarMode: TdxBar;
    dxBarButtonSingleSheet: TdxBarButton;
    dxSpreadSheetReportDesignerMultipleSheetsReportMode: TdxSpreadSheetReportDesignerMultipleSheetsReportMode;
    dxBarButtonMultipleSheets: TdxBarButton;
    dxSpreadSheetReportDesignerMultipleDocumentsReportMode: TdxSpreadSheetReportDesignerMultipleDocumentsReportMode;
    dxBarButtonMultipleDocuments: TdxBarButton;
    dxBarSubItem16: TdxBarSubItem;
    dxSpreadSheetReportDesignerHorizontalOrientation: TdxSpreadSheetReportDesignerHorizontalOrientation;
    dxBarLargeButtonHorizontal: TdxBarLargeButton;
    dxSpreadSheetReportDesignerVerticalOrientation: TdxSpreadSheetReportDesignerVerticalOrientation;
    dxBarLargeButtonVertical: TdxBarLargeButton;
    dxSpreadSheetReportDesignerHeaderSection: TdxSpreadSheetReportDesignerHeaderSection;
    dxBarTemplateSections: TdxBar;
    dxBarButtonHeader: TdxBarButton;
    dxSpreadSheetReportDesignerFooterSection: TdxSpreadSheetReportDesignerFooterSection;
    dxBarButtonFooter: TdxBarButton;
    dxSpreadSheetReportDesignerDetailSection: TdxSpreadSheetReportDesignerDetailSection;
    dxBarLargeButtonDetail: TdxBarLargeButton;
    dxBarSubItem17: TdxBarSubItem;
    dxSpreadSheetReportDesignerDetailLevel: TdxSpreadSheetReportDesignerDetailLevel;
    dxBarLargeButtonDetailLevel: TdxBarLargeButton;
    dxSpreadSheetReportDesignerDataMember: TdxSpreadSheetReportDesignerDataMember;
    dxBarLargeButtonDataMember: TdxBarLargeButton;
    dxSpreadSheetReportDesignerResetSection: TdxSpreadSheetReportDesignerResetSection;
    dxBarLargeButtonReset: TdxBarLargeButton;
    dxSpreadSheetReportDesignerSortFields: TdxSpreadSheetReportDesignerSortFields;
    dxBarSortGroup: TdxBar;
    dxBarLargeButtonSortFields: TdxBarLargeButton;
    dxSpreadSheetReportDesignerGroupHeaderSection: TdxSpreadSheetReportDesignerGroupHeaderSection;
    dxBarButtonGroupHeader: TdxBarButton;
    dxSpreadSheetReportDesignerGroupFooterSection: TdxSpreadSheetReportDesignerGroupFooterSection;
    dxBarButtonGroupFooter: TdxBarButton;
    dxSpreadSheetReportDesignerEditFilter: TdxSpreadSheetReportDesignerEditFilter;
    dxBarFilter: TdxBar;
    dxBarLargeButtonEditFilter: TdxBarLargeButton;
    dxSpreadSheetReportDesignerResetFilter: TdxSpreadSheetReportDesignerResetFilter;
    dxBarLargeButtonResetFilter: TdxBarLargeButton;
    dxSpreadSheetReportDesignerDesignView: TdxSpreadSheetReportDesignerDesignView;
    dxBarDesign: TdxBar;
    dxBarLargeButtonDesignView: TdxBarLargeButton;
    dxSpreadSheetReportDesignerReportPreview: TdxSpreadSheetReportDesignerReportPreview;
    dxBarLargeButtonReportPreview: TdxBarLargeButton;
    Chiudi: TAction;
    dxBarManagerBar1: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    DataSource: TDataSource;
    dxLayoutControl: TdxLayoutControl;
    dxSpreadSheetReportDesigner: TdxSpreadSheetReportDesigner;
    groupCampi: TcxGroupBox;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutItemDesigner: TdxLayoutItem;
    dxLayoutItemCampi: TdxLayoutItem;
    dxLayoutSplitterItem: TdxLayoutSplitterItem;
    dxLayoutGroupDesigner: TdxLayoutGroup;
    MostraFormule: TAction;
    Elabora: TAction;
    dxBarManagerBar2: TdxBar;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    cxRTTIInspector: TcxRTTIInspector;
    dxLayoutItemInspector: TdxLayoutItem;
    dxLayoutGroupDetail: TdxLayoutGroup;
    dxSaveFileDialogXlsx: TdxSaveFileDialog;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    actSalvaConNome: TAction;
    actSalva: TAction;
    actShellExecute: TAction;
    dxLayoutSplitterItemFields: TdxLayoutSplitterItem;
    dxSpreadSheetFormulaBar: TdxSpreadSheetFormulaBar;
    dxLayoutItemFormulaBar: TdxLayoutItem;
    procedure actSalvaConNomeExecute(Sender: TObject);
    procedure actSalvaExecute(Sender: TObject);
    procedure actSalvaUpdate(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure cxRTTIInspectorDblClick(Sender: TObject);
    procedure cxRTTIInspectorEditValueChanged(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties);
    procedure dxSpreadSheetOpenDocumentAccept(Sender: TObject);
    procedure dxSpreadSheetOpenDocumentBeforeExecute(Sender: TObject);
    procedure dxSpreadSheetReportDesignerPopulateField(Sender: TdxSpreadSheetReportDesigner; AField: TField; var Allow: Boolean);
    procedure dxSpreadSheetSaveDocumentAsAccept(Sender: TObject);
    procedure dxSpreadSheetSaveDocumentAsBeforeExecute(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure MostraFormuleExecute(Sender: TObject);
  private
    FParams: TExcelParams;

    procedure doBuildReport;
    procedure dxSpreadSheetReportDesignerNewReportSheet(Sender: TdxSpreadSheetReportDesigner; ANewSheet: TdxSpreadSheetTableView);
    procedure AgganciaPosizionamentoDettagli;
    procedure DettaglioPrimoRecord(Sender: TcxDBDataModeController; ADataSet: TDataSet; const AMasterDetailKeyFieldNames: string;
      const AMasterDetailKeyValues: Variant; var AReopened: Boolean);
  private
    function doSalva: Boolean;
    function doSalvaConNome: Boolean;

    procedure CaricaTemplate(const FileName: string);
    procedure SalvaTemplate(const FileName: string);
    procedure InspectObject;
  public
    constructor Create(aOwner: TComponent); override;
    function ShowModal: Integer; override;
    procedure ShowFile(Params: TExcelParams);
    procedure BuildReport(Params: TExcelParams);

    property Params: TExcelParams read FParams;
  end;

procedure EditTemplateExcel(Params: TExcelParams);

// crea direttamente il file e lo mostra a video
procedure BuildSpreadSheetReport(Params: TExcelParams);

implementation

uses
  Winapi.ShellAPI,
  System.Generics.Collections,
  System.JSON,
  System.IOUtils,
  cxOIComponentCollectionEd, // usato per modificare i dataBinding
  zdx,
  zBaseLib,
  zMsg,
  zOffice,
  zOffice.Excel.Form,
  zOffice.Grafici.Excel,
  zOffice.Excel.Editor.binding,
  zz.Folders;

{$R *.dfm}

type
  // accesso all'evento e ai dizionari protetti con cui il designer risolve FIELD("...")
  TdxSpreadSheetReportDesignerAccess = class(TdxSpreadSheetReportDesigner);
  TdxSpreadSheetReportDataControllerAccess = class(TdxSpreadSheetReportDataController);
  TdxSpreadSheetReportDataBindingAccess = class(TdxSpreadSheetReportDataBinding);

procedure EditTemplateExcel(Params: TExcelParams);
var
  zViewerExcelEditor: TzViewerExcelEditor;
begin
  Application.CreateForm(TzViewerExcelEditor, zViewerExcelEditor);
  try
    zViewerExcelEditor.ShowFile(Params);
  finally
    FreeAndNil(zViewerExcelEditor);
  end;
end;

procedure BuildSpreadSheetReport(Params: TExcelParams);
var
  zViewerExcelEditor: TzViewerExcelEditor;
begin
  Application.CreateForm(TzViewerExcelEditor, zViewerExcelEditor);
  try
    zViewerExcelEditor.BuildReport(Params);
  finally
    FreeAndNil(zViewerExcelEditor);
  end;
end;

constructor TzViewerExcelEditor.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FParams.Init;

  zOffice.Excel.Utils.CurrentGetVariableFunc := function(VariableName: string): variant
    begin

      if not Params.GetVariable(VariableName, result) then
        result := null;
    end;

  dxRibbon.ActiveTab := dxRibbonTabFile;

  dx.InitLayoutControl(dxLayoutControl);

  dx.InitPrinter(dxComponentPrinter);

  dxComponentPrinterLink.Component := dxSpreadSheetReportDesigner;

  dxLayoutControlGroup_Root.ItemIndex := 0;
  dxLayoutGroupDetail.ItemIndex := 0;

  dxSpreadSheetReportDesigner.FieldChooser.Site := groupCampi;
  // dxSpreadSheetReportDesigner.FieldChooser.Show;

  // FIELD("NOME_CAMPO") deve trovare il campo anche quando ha un'etichetta diversa dal nome
  TdxSpreadSheetReportDesignerAccess(dxSpreadSheetReportDesigner).OnNewReportSheet := dxSpreadSheetReportDesignerNewReportSheet;

  dxComponentPrinterLink.Component := dxSpreadSheetReportDesigner;

  ColoriFoglioIndipendentiDallaSkin(dxSpreadSheetReportDesigner);

  InspectObject;

  WindowState := wsMaximized;
end;

procedure TzViewerExcelEditor.actSalvaConNomeExecute(Sender: TObject);
begin
  doSalvaConNome;
end;

procedure TzViewerExcelEditor.actSalvaExecute(Sender: TObject);
begin
  doSalva;
end;

procedure TzViewerExcelEditor.actSalvaUpdate(Sender: TObject);
begin
  actSalva.Enabled := (not Params.TemplateFileName.IsEmpty) and dxSpreadSheetReportDesigner.Modified;
end;

procedure TzViewerExcelEditor.actShellExecuteExecute(Sender: TObject);
begin

  if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
    if doSalva then
      ShellExecute(0, PCHAR('open'), PCHAR(Params.TemplateFileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerExcelEditor.FormShow(Sender: TObject);
begin
  //
  if dx.SkinActive then
    dxRibbon.ColorSchemeName := 'UserSkin'
  else
    // dxRibbon.ColorSchemeName := 'Colorful';
    dxRibbon.ColorSchemeName := 'White';
end;

procedure TzViewerExcelEditor.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerExcelEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  zOffice.Excel.Utils.CurrentGetVariableFunc := nil;
end;

procedure TzViewerExcelEditor.doBuildReport;
begin
  Screen.Cursor := crHourGlass;

  // Feedback visivo durante la generazione. Barra indeterminata: il Build di
  // DevExpress non espone avanzamento/aborto per-record, quindi qui si mostra
  // solo "Generazione in corso". Lo scorrimento visibile della griglia e' gia'
  // eliminato dal DisableControls fatto in TzReportsManager.BeforePrint.
  if assigned(Params.Progress) then
    Params.Progress.Start('Generazione foglio in corso...', 0);

  try
    zOffice.ViewFileExcel(
      procedure(dxSpreadSheet: TdxSpreadSheet)
      begin
        dxSpreadSheet.ClearAll; // WHY????

        try
          if assigned(Params.BeforeBuild) then
            Params.BeforeBuild(Params.TemplateFileName, dxSpreadSheet);

          AgganciaPosizionamentoDettagli;

          dxSpreadSheetReportDesigner.Build(dxSpreadSheet);

          // celle chart://Nome del modello: immagine del grafico al loro posto
          InserisciGrafici(dxSpreadSheet);

          if assigned(Params.AfterBuild) then
            Params.AfterBuild(Params.TemplateFileName, dxSpreadSheet);

          dxSpreadSheet.Modified := false;
        except
          on e: exception do
            Application.HandleException(e);
        end;
      end);
  finally
    if assigned(Params.Progress) then
      Params.Progress.Done;

    // Non si ripristina il cursore trovato all'ingresso: in quel momento era spesso il
    // cursore d'attesa di FireDAC lasciato dalle query di BeforePrint, che FireDAC toglie
    // in ritardo con un timer. Il timer scatta mentre il foglio e' aperto, e rimettere qui
    // il valore salvato lasciava la clessidra dopo la chiusura dell'anteprima.
    Screen.Cursor := crDefault;
  end;
end;

procedure TzViewerExcelEditor.ShowFile(Params: TExcelParams);
begin
  FParams.Assign(Params);

  if FileExists(Params.TemplateFileName) then
  begin
    dxSpreadSheetReportDesigner.LoadFromFile(Params.TemplateFileName);
    dxSpreadSheetOpenDocument.Dialog.InitialDir := ExtractFilePath(Params.TemplateFileName);
    CaricaTemplate(Params.TemplateFileName);
  end;

  DataSource.DataSet := Params.GetDataSet(FileNameNoExt(Params.TemplateFileName));

  if DataSource.DataSet = nil then
    DataSource.DataSet := Params.GetDataSet('');

  dxSpreadSheetReportDesigner.FieldChooser.Site := groupCampi;
  dxSpreadSheetReportDesigner.FieldChooser.Show;

  ShowModal;
end;

procedure TzViewerExcelEditor.BuildReport(Params: TExcelParams);
var
  AllowBuild: Boolean;

  procedure AssegnaDataSourceDataset;
  begin
    DataSource.DataSet := Params.GetDataSet(FileNameNoExt(Params.TemplateFileName));

    if DataSource.DataSet = nil then
      DataSource.DataSet := Params.GetDataSet('');
  end;

begin
  FParams.Assign(Params);

  AssegnaDataSourceDataset;

  if DataSource.DataSet = nil then
  begin
    ConfirmOk('Dataset non trovato per il report.', mtWarning);
    exit;
  end;

  AllowBuild := True;
  if assigned(Params.AllowBuildReport) then
    AllowBuild := Params.AllowBuildReport(Params.TemplateFileName);

  if AllowBuild then
  begin
    if FileExists(Params.TemplateFileName) then
    begin
      CaricaTemplate(Params.TemplateFileName);
      dxSpreadSheetReportDesigner.LoadFromFile(Params.TemplateFileName);
      dxSpreadSheetOpenDocument.Dialog.InitialDir := ExtractFilePath(Params.TemplateFileName);
    end;

    // se carica template lo elimina
    AssegnaDataSourceDataset;

    doBuildReport;
  end
  else
    zOffice.ViewFileExcel(Params);
end;

function TzViewerExcelEditor.doSalva: Boolean;
begin
  result := True;

  if Params.TemplateFileName.IsEmpty then
    result := doSalvaConNome
  else
  begin
    dxSpreadSheetReportDesigner.SaveToFile(Params.TemplateFileName);
    dxSpreadSheetReportDesigner.Modified := false;
    SalvaTemplate(Params.TemplateFileName);
  end;
end;

function TzViewerExcelEditor.doSalvaConNome: Boolean;
begin
  dxSaveFileDialogXlsx.FileName := Params.TemplateFileName;

  // Template nuovo: si parte dalla cartella dei report, non dall'ultima cartella
  // usata dal sistema.
  if Params.TemplateFileName.IsEmpty then
    dxSaveFileDialogXlsx.InitialDir := Params.DefaultFolder
  else
    dxSaveFileDialogXlsx.InitialDir := ExtractFilePath(Params.TemplateFileName);

  result := dxSaveFileDialogXlsx.Execute(Self.Handle);

  if result then
  begin
    FParams.TemplateFileName := dxSaveFileDialogXlsx.FileName;
    doSalva;
    Caption := Params.TemplateFileName;
  end;
end;

procedure TzViewerExcelEditor.dxSpreadSheetOpenDocumentBeforeExecute(Sender: TObject);
begin
  if Params.TemplateFileName.IsEmpty then
    dxSpreadSheetOpenDocument.Dialog.InitialDir := Params.DefaultFolder
  else
    dxSpreadSheetOpenDocument.Dialog.InitialDir := ExtractFilePath(Params.TemplateFileName);
end;

procedure TzViewerExcelEditor.dxSpreadSheetOpenDocumentAccept(Sender: TObject);
begin
  CaricaTemplate(dxSpreadSheetOpenDocument.Dialog.FileName);
  dxSpreadSheetReportDesigner.LoadFromFile(dxSpreadSheetOpenDocument.Dialog.FileName);
end;

procedure TzViewerExcelEditor.dxSpreadSheetReportDesignerPopulateField(Sender: TdxSpreadSheetReportDesigner; AField: TField; var Allow: Boolean);
begin
  Allow := True;
end;

procedure TzViewerExcelEditor.dxSpreadSheetReportDesignerNewReportSheet(Sender: TdxSpreadSheetReportDesigner; ANewSheet: TdxSpreadSheetTableView);
var
  CampiGlobali: TDictionary<string, TdxSpreadSheetReportDesignerDataField>;

  procedure AggiungiNomiCampi(DataController: TdxSpreadSheetReportDataController; Details: TdxSpreadSheetReportDetails);
  var
    Controller: TdxSpreadSheetReportDataControllerAccess;
    Campo: TdxSpreadSheetReportDesignerDataField;
    Chiave: string;
    I: Integer;
  begin
    Controller := TdxSpreadSheetReportDataControllerAccess(DataController);

    for I := 0 to Controller.FieldCount - 1 do
    begin
      Campo := Controller.Fields[I];

      // si aggiunge solo se manca: una chiave gia' presente (etichetta uguale al nome
      // di un altro campo) resta quella di DevExpress, cosi' i modelli esistenti non cambiano
      Chiave := UpperCase(Campo.FieldName);
      if not Controller.FieldNames.ContainsKey(Chiave) then
        Controller.FieldNames.Add(Chiave, Campo);

      Chiave := UpperCase(Controller.DisplayName + '.' + Campo.FieldName);
      if not Controller.FieldNames.ContainsKey(Chiave) then
        Controller.FieldNames.Add(Chiave, Campo);

      // elenco comune a tutti i livelli: da un dettaglio si leggono i campi della testata
      Chiave := UpperCase(Campo.FieldName);
      if not CampiGlobali.ContainsKey(Chiave) then
        CampiGlobali.Add(Chiave, Campo);
    end;

    for I := 0 to Details.Count - 1 do
      AggiungiNomiCampi(Details[I].DataController, Details[I].Details);
  end;

begin
  // Il designer DevExpress risolve FIELD("X") cercando X fra le etichette dei campi
  // (Field.DisplayName), non fra i nomi: TdxSpreadSheetReportDataController.BeforeBuildReport
  // e PopulateFields indicizzano per DisplayName, e un nome non trovato da' un valore nullo
  // senza errore. Con etichette diverse dal nome (FIGURA_PROFESSIONALE -> "Figura
  // Professionale", generata in assenza di metadati LZ) la cella resta vuota.
  // I dizionari vengono ricostruiti a ogni Build prima di creare il foglio e prima di
  // valutare qualunque formula: qui si aggiungono anche i nomi dei campi.
  CampiGlobali := TdxSpreadSheetReportDataBindingAccess(Sender.DataBinding).Fields;
  AggiungiNomiCampi(Sender.DataBinding.DataController, Sender.DataBinding.Details);
end;

procedure TzViewerExcelEditor.AgganciaPosizionamentoDettagli;

  procedure Aggancia(Details: TdxSpreadSheetReportDetails);
  var
    I: Integer;
  begin
    for I := 0 to Details.Count - 1 do
    begin
      Details[I].DataController.DataModeController.OnDetailFirst := DettaglioPrimoRecord;
      Aggancia(Details[I].Details);
    end;
  end;

begin
  // I dettagli si agganciano dopo CaricaTemplate, che li ricrea dal JSON del modello
  Aggancia(dxSpreadSheetReportDesigner.DataBinding.Details);
end;

procedure TzViewerExcelEditor.DettaglioPrimoRecord(Sender: TcxDBDataModeController; ADataSet: TDataSet;
  const AMasterDetailKeyFieldNames: string; const AMasterDetailKeyValues: Variant; var AReopened: Boolean);
begin
  // Per ogni record della testata il data controller DevExpress posiziona il dataset
  // del dettaglio con Locate sulla chiave e legge in avanti finche' la chiave resta
  // uguale: la Locate deve fermarsi sul PRIMO record con quella chiave.
  // TzFbDataSet.Locate con UseSqlLocate (attivo di norma) non lo garantisce: se il
  // record corrente ha gia' la chiave non si sposta, e altrimenti riapre il dataset
  // filtrato. Con le chiavi fisse dei modelli (DUMMY_MASTER/DUMMY_DETAIL) la seconda
  // anteprima, col cursore rimasto sull'ultimo giorno, perdeva tutte le righe.
  // LocateNonSQL e' la Locate di FireDAC: cerca dal primo record e non riapre nulla.
  AReopened := False;

  if ADataSet is TzFbDataSet then
    TzFbDataSet(ADataSet).LocateNonSQL(AMasterDetailKeyFieldNames, AMasterDetailKeyValues, [])
  else
    ADataSet.Locate(AMasterDetailKeyFieldNames, AMasterDetailKeyValues, []);
end;

procedure TzViewerExcelEditor.dxSpreadSheetSaveDocumentAsBeforeExecute(Sender: TObject);

  function SameFolder(folder1, folder2: string): Boolean;
  begin
    // Il risultato non veniva assegnato: la funzione tornava un valore a caso.
    result := sameText(IncludeTrailingPathDelimiter(folder1), IncludeTrailingPathDelimiter(folder2));
  end;

begin
  if dxLayoutControlGroup_Root.ItemIndex = 0 then
  begin

    // se vuota oppure la cartella del template => cartella dei documenti dell'utente
    if dxSpreadSheetSaveDocumentAs.Dialog.InitialDir.IsEmpty or SameFolder(dxSpreadSheetSaveDocumentAs.Dialog.InitialDir, ExtractFilePath(Params.TemplateFileName)) then
      dxSpreadSheetSaveDocumentAs.Dialog.InitialDir := TFolders.UserDocumentsFolder;
  end
  else
    if dxLayoutControlGroup_Root.ItemIndex = 1 then
    begin

      if not ConfirmYesNo('Attenzione: si vuole salvare il template?', mtWarning) then
        Abort
      else
        if Params.TemplateFileName.IsEmpty then
          dxSpreadSheetSaveDocumentAs.Dialog.InitialDir := Params.DefaultFolder
        else
          dxSpreadSheetSaveDocumentAs.Dialog.InitialDir := ExtractFilePath(Params.TemplateFileName);
    end;
end;

procedure TzViewerExcelEditor.dxSpreadSheetSaveDocumentAsAccept(Sender: TObject);
var
  EraNuovo: Boolean;
begin
  EraNuovo := Params.TemplateFileName.IsEmpty and (dxLayoutControlGroup_Root.ItemIndex = 1);

  dxSpreadSheetReportDesigner.SaveToFile(dxSpreadSheetSaveDocumentAs.Dialog.FileName);

  // Salvataggio del template nuovo: da ora il template ha il suo nome, cosi'
  // "Salva" e la chiusura non lo chiedono di nuovo e il JSON dei dati
  // collegati finisce accanto al file.
  if EraNuovo then
  begin
    FParams.TemplateFileName := dxSpreadSheetSaveDocumentAs.Dialog.FileName;
    dxSpreadSheetReportDesigner.Modified := false;
    SalvaTemplate(Params.TemplateFileName);
    Caption := Params.TemplateFileName;
  end;
end;

procedure TzViewerExcelEditor.ElaboraExecute(Sender: TObject);
begin
  doBuildReport;
end;

procedure TzViewerExcelEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;

  if dxSpreadSheetReportDesigner.Modified then
  begin
    case ConfirmYesNoCancel('Attenzione: si vuole salvare le modifiche effettuate al template?', mtInformation) of
      mrCancel:
        CanClose := false;
      mrYes:
        CanClose := doSalva;
      mrNo:
        begin
          // non fa nulla
        end;
    end;
  end;
end;

procedure TzViewerExcelEditor.MostraFormuleExecute(Sender: TObject);
var
  I: Integer;
begin
  dxSpreadSheetReportDesigner.BeginUpdate;
  try
    for I := 0 to dxSpreadSheetReportDesigner.SheetCount - 1 do
      if dxSpreadSheetReportDesigner.Sheets[I] is TdxSpreadSheetTableView then
        TdxSpreadSheetTableView(dxSpreadSheetReportDesigner.Sheets[I]).Options.ShowFormulas := bDefault;

    dxSpreadSheetReportDesigner.OptionsView.ShowFormulas := not dxSpreadSheetReportDesigner.OptionsView.ShowFormulas;
  finally
    dxSpreadSheetReportDesigner.EndUpdate;
  end;
end;

function TzViewerExcelEditor.ShowModal: Integer;
begin
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  result := inherited ShowModal;
end;

procedure TzViewerExcelEditor.cxRTTIInspectorEditValueChanged(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties);
begin
  dxSpreadSheetReportDesigner.FieldChooser.Show;
  // per attivare il pulsante Salva
  dxSpreadSheetReportDesigner.Modified := True;
end;

procedure TzViewerExcelEditor.SalvaTemplate(const FileName: string);
var
  DataBinding: TDataBinding;
  v: TJSONValue;
  jsonStr: string;
  Saved: Boolean;
begin
  DataBinding := TDataBinding.Create;
  try
    DataBinding.LoadFromSpreadSheet(dxSpreadSheetReportDesigner);

    v := DataBinding.ToJSONObject;
    try
      jsonStr := v.Format(4);
    finally
      FreeAndNil(v);
    end;

    Saved := False;
    if Assigned(Params.OnSaveDataBinding) then
    begin
      try
        Saved := Params.OnSaveDataBinding(jsonStr);
      except
        on E: Exception do
          ConfirmOk('Errore nel salvataggio del databinding: ' + E.Message, mtError);
      end;
    end;

    if not Saved then
      TFile.writeallText(ChangeFileExt(FileName, '.json'), jsonStr);

  finally
    FreeAndNil(DataBinding);
  end;
end;

procedure TzViewerExcelEditor.CaricaTemplate(const FileName: string);
var
  j: string;
  DataBinding: TDataBinding;
  jsonFileName: string;
  Loaded: Boolean;
begin
  /// //////////////////////////////////////////////////////////////////////////
  // ATTENZIONE:
  // Il sectionId del detail deve essere uguale al detailLevel della banda
  // Aggiungendo il detail pone il livello a 1, mentre il dataset è a zero.
  /// //////////////////////////////////////////////////////////////////////////
  j := '';
  Loaded := False;

  if Assigned(Params.OnLoadDataBinding) then
  begin
    try
      j := Params.OnLoadDataBinding();
      if j <> '' then
        Loaded := True;
    except
      // ignore
    end;
  end;

  if not Loaded then
  begin
    jsonFileName := ChangeFileExt(FileName, '.json');
    if TFile.Exists(jsonFileName) then
    begin
      j := TFile.ReadAllText(jsonFileName);
      Loaded := True;
    end;
  end;

  if Loaded and (j <> '') then
  begin
    DataBinding := TDataBinding.FromJSON(j);
    try
      DataBinding.SaveToSpreadSheet(dxSpreadSheetReportDesigner,
        function(name: string): TDataSource
        begin

          if sameText(name, DataSource.name) then
            result := DataSource
          else
            result := Params.GetDataSource(name);
        end);
    finally
      FreeAndNil(DataBinding);
    end;
  end;

  InspectObject;
  // cxRTTIInspector.RefreshInspectedProperties;
  dxSpreadSheetReportDesigner.FieldChooser.Show;
end;

procedure TzViewerExcelEditor.cxRTTIInspectorDblClick(Sender: TObject);
begin
  if cxRTTIInspector.HitTest.HitAtEmpty then
    InspectObject;
end;

procedure TzViewerExcelEditor.InspectObject;
begin
  cxRTTIInspector.InspectedObject := dxSpreadSheetReportDesigner; // .DataBinding;.DataBinding;
end;

end.
// =SUBTOTAL(9;RANGE($C$21))
// dxItalian_ExpressSpreadSheet_2
