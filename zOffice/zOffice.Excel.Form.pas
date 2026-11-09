unit zOffice.Excel.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.StdActns,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
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
  cxFontNameComboBox,
  cxDropDownEdit,
  dxSpreadSheetConditionalFormattingRulesActions,
  dxSpreadSheetActions,
  dxGallery,
  dxRibbonGallery,
  dxBar,
  dxRibbonColorGallery,
  cxBarEditItem,
  dxPrinting,
  cxClasses,
  dxRibbon,
  dxActions,
  cxImageList,
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
  cxDrawTextUtils,
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
  cxContainer,
  cxEdit,
  cxGroupBox,
  dxFileActions,
  cxStyles,
  dxScrollbarAnnotations,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  dxPScxTLLnk,
  dxPScxSchedulerLnk,
  cxFilter,
  dxPSdxPDFViewerLnk,
  dxPScxEditorLnks,
  zOffice.types,
  zOffice.Reports.Controller, // TzAzioneDocumento
  zOffice.Reports.ActionsBarHelper, // TzDocumentActionsBarHelper
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  dxShellDialogs,
  dxUIAClasses,
  dxSpreadSheetFormulaBar;

type
  // IRestriction
  TzViewerExcelForm = class(TdxRibbonForm)
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
    dxBarLargeButtonOpen: TdxBarLargeButton;
    dxBarLargeButtonSaveAs: TdxBarLargeButton;
    dxSpreadSheetShowPrintForm: TdxSpreadSheetShowPrintForm;
    dxBarPrint: TdxBar;
    dxBarLargeButtonPrint: TdxBarLargeButton;
    dxSpreadSheetShowPrintPreviewForm: TdxSpreadSheetShowPrintPreviewForm;
    dxBarLargeButtonPrintPreview: TdxBarLargeButton;
    dxSpreadSheetShowPageSetupForm: TdxSpreadSheetShowPageSetupForm;
    dxBarLargeButtonPageSetup: TdxBarLargeButton;
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
    dxSpreadSheetReportDesignerMultipleSheetsReportMode: TdxSpreadSheetReportDesignerMultipleSheetsReportMode;
    dxSpreadSheetReportDesignerMultipleDocumentsReportMode: TdxSpreadSheetReportDesignerMultipleDocumentsReportMode;
    dxSpreadSheetReportDesignerHorizontalOrientation: TdxSpreadSheetReportDesignerHorizontalOrientation;
    dxSpreadSheetReportDesignerVerticalOrientation: TdxSpreadSheetReportDesignerVerticalOrientation;
    dxSpreadSheetReportDesignerHeaderSection: TdxSpreadSheetReportDesignerHeaderSection;
    dxSpreadSheetReportDesignerFooterSection: TdxSpreadSheetReportDesignerFooterSection;
    dxSpreadSheetReportDesignerDetailSection: TdxSpreadSheetReportDesignerDetailSection;
    dxSpreadSheetReportDesignerDetailLevel: TdxSpreadSheetReportDesignerDetailLevel;
    dxBarLargeButtonDetailLevel: TdxBarLargeButton;
    dxSpreadSheetReportDesignerDataMember: TdxSpreadSheetReportDesignerDataMember;
    dxBarLargeButtonDataMember: TdxBarLargeButton;
    dxSpreadSheetReportDesignerResetSection: TdxSpreadSheetReportDesignerResetSection;
    dxSpreadSheetReportDesignerSortFields: TdxSpreadSheetReportDesignerSortFields;
    dxSpreadSheetReportDesignerGroupHeaderSection: TdxSpreadSheetReportDesignerGroupHeaderSection;
    dxSpreadSheetReportDesignerGroupFooterSection: TdxSpreadSheetReportDesignerGroupFooterSection;
    dxSpreadSheetReportDesignerEditFilter: TdxSpreadSheetReportDesignerEditFilter;
    dxSpreadSheetReportDesignerResetFilter: TdxSpreadSheetReportDesignerResetFilter;
    dxSpreadSheetReportDesignerDesignView: TdxSpreadSheetReportDesignerDesignView;
    dxSpreadSheetReportDesignerReportPreview: TdxSpreadSheetReportDesignerReportPreview;
    Chiudi: TAction;
    dxBarManagerBar1: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    dxSpreadSheet: TdxSpreadSheet;
    MostraFormule: TAction;
    dxBarManagerBar2: TdxBar;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarManagerBar4: TdxBar;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    actShellExecute: TAction;
    actExportPDF: TAction;
    dxSaveFileDialogPdf: TdxSaveFileDialog;
    actSalva: TAction;
    dxBarLargeButton5: TdxBarLargeButton;
    actSalvaConNome: TAction;
    dxSaveFileDialogXlsx: TdxSaveFileDialog;
    dxBarManagerBar3: TdxBar;
    Calcola: TAction;
    dxBarLargeButton6: TdxBarLargeButton;
    dxSpreadSheetFormulaBar: TdxSpreadSheetFormulaBar;
    // Azioni documentali: gruppo "Documento" (bar + bottoni + azioni).
    // Il Tag delle 5 azioni documentali lo imposta l'helper per nome.
    barDocumento: TdxBar;
    actDocFirma: TAction;
    actDocProtocolla: TAction;
    actDocConserva: TAction;
    actDocInviaPec: TAction;
    actDocInviaMail: TAction;
    actDocAggiornaStato: TAction;
    actDocVersioni: TAction;
    btnDocFirma: TdxBarLargeButton;
    btnDocProtocolla: TdxBarLargeButton;
    btnDocConserva: TdxBarLargeButton;
    btnDocInviaPec: TdxBarLargeButton;
    btnDocInviaMail: TdxBarLargeButton;
    btnDocAggiornaStato: TdxBarLargeButton;
    btnDocVersioni: TdxBarLargeButton;
    actDocGeneraAllegato: TAction;
    dxBarLargeButton7: TdxBarLargeButton;
    procedure actDocGeneraAllegatoExecute(Sender: TObject);
    procedure actDocGeneraAllegatoUpdate(Sender: TObject);
    procedure actExportPDFExecute(Sender: TObject);
    procedure actSalvaConNomeExecute(Sender: TObject);
    procedure actSalvaExecute(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure dxSpreadSheetOpenDocumentAccept(Sender: TObject);
    procedure dxSpreadSheetOpenDocumentBeforeExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MostraFormuleExecute(Sender: TObject);
    procedure actSalvaUpdate(Sender: TObject);
    procedure CalcolaExecute(Sender: TObject);
    procedure CalcolaUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    // Azioni documentali: handler condivisi dalle TAction del gruppo
    // "Documento" (aggiunte a mano nel DFM). Le cinque azioni documentali
    // usano la coppia AzioneDocumento* e portano Ord(TzAzioneDocumento) nel Tag.
    procedure AzioneDocumentoUpdate(Sender: TObject);
    procedure AzioneDocumentoExecute(Sender: TObject);
    procedure AggiornaStatoDocumentoUpdate(Sender: TObject);
    procedure AggiornaStatoDocumentoExecute(Sender: TObject);
    procedure VersioniDocumentoUpdate(Sender: TObject);
    procedure VersioniDocumentoExecute(Sender: TObject);
  private
    FFileName: string;
    FPdfFontEmbedding: TzPdfFontEmbedding;
    FAzioniDocumento: TzDocumentActionsBarHelper;
    function doSalva: Boolean;
    function doSalvaConNome: Boolean;
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
  private

  public
    constructor Create(aOwner: TComponent); override;
    // silent = niente dialogo di salvataggio e niente domande dopo l'export
    // (usato dall'export temporaneo delle azioni documentali)
    procedure ExportPDF(const FileNamePdf: String; const silent: Boolean = false);

    function ShowModal: Integer; override;
    procedure ShowFile(const FileName: string; const ReadOnly: Boolean = false); overload;
    procedure ShowFile(Params: TExcelParams); overload;
    procedure ShowFile(proc: TProc<TdxSpreadSheet>); overload;

    procedure LoadFile(const FileName: String);
    property FileName: string read FFileName;
    property PdfFontEmbedding: TzPdfFontEmbedding read FPdfFontEmbedding;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
  end;

procedure ViewFileExcel(const FileName: string; const ReadOnly: Boolean = false); overload;
procedure ViewFileExcel(Params: TExcelParams); overload;
procedure ViewFileExcel(proc: TProc<TdxSpreadSheet>); overload;

// Testo nero su fondo bianco per le celle senza colori propri, qualunque sia la skin:
// altrimenti con una skin scura il testo "automatico" diventa chiaro e sulle celle
// colorate del modello (intestazioni grigie) non si legge piu'.
procedure ColoriFoglioIndipendentiDallaSkin(SpreadSheet: TdxCustomSpreadSheet);

implementation

uses
  Winapi.ShellAPI,
  System.IOUtils,
  zdx,
  zBaseLib,
  zMsg,
  zz.Folders;

{$R *.dfm}

procedure ColoriFoglioIndipendentiDallaSkin(SpreadSheet: TdxCustomSpreadSheet);
var
  Contenuto: TcxStyle;
begin
  // Styles.Content vale per le celle inizializzate e non, e scavalca la skin;
  // i colori scritti nel modello (riempimenti, caratteri) restano quelli del modello
  Contenuto := TcxStyle.Create(SpreadSheet);
  Contenuto.Color := clWhite;
  Contenuto.TextColor := clBlack;
  SpreadSheet.Styles.Content := Contenuto;
end;

procedure ViewFileExcel(const FileName: string; const ReadOnly: Boolean = false);
var
  zViewerExcelForm: TzViewerExcelForm;
begin
  Application.CreateForm(TzViewerExcelForm, zViewerExcelForm);
  try
    zViewerExcelForm.ShowFile(FileName, ReadOnly);
  finally
    FreeAndNil(zViewerExcelForm);
  end;
end;

procedure ViewFileExcel(Params: TExcelParams); overload;
var
  zViewerExcelForm: TzViewerExcelForm;
begin
  Application.CreateForm(TzViewerExcelForm, zViewerExcelForm);
  try
    zViewerExcelForm.ShowFile(Params);
  finally
    FreeAndNil(zViewerExcelForm);
  end;
end;

procedure ViewFileExcel(proc: TProc<TdxSpreadSheet>);
var
  zViewerExcelForm: TzViewerExcelForm;
begin
  Application.CreateForm(TzViewerExcelForm, zViewerExcelForm);
  try
    zViewerExcelForm.ShowFile(proc);
  finally
    FreeAndNil(zViewerExcelForm);
  end;
end;

constructor TzViewerExcelForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FFileName := '';
  FPdfFontEmbedding := zfeSubset;

  dxRibbon.ActiveTab := dxRibbonTabFile;

  dx.InitPrinter(dxComponentPrinter);

  dxComponentPrinterLink.Component := dxSpreadSheet;

  ColoriFoglioIndipendentiDallaSkin(dxSpreadSheet);

  WindowState := wsMaximized;
end;

procedure TzViewerExcelForm.actDocGeneraAllegatoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoGeneraAllegato;
end;

procedure TzViewerExcelForm.actDocGeneraAllegatoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoGeneraAllegato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerExcelForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerExcelForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerExcelForm.dxSpreadSheetOpenDocumentBeforeExecute(Sender: TObject);
begin
  dxSpreadSheetOpenDocument.Dialog.InitialDir := ExtractFilePath(FileName);
end;

procedure TzViewerExcelForm.dxSpreadSheetOpenDocumentAccept(Sender: TObject);
begin
  dxSpreadSheet.LoadFromFile(dxSpreadSheetOpenDocument.Dialog.FileName);
end;

procedure TzViewerExcelForm.MostraFormuleExecute(Sender: TObject);
var
  I: Integer;
begin
  dxSpreadSheet.BeginUpdate;
  try
    for I := 0 to dxSpreadSheet.SheetCount - 1 do
      if dxSpreadSheet.Sheets[I] is TdxSpreadSheetTableView then
        TdxSpreadSheetTableView(dxSpreadSheet.Sheets[I]).Options.ShowFormulas := bDefault;

    dxSpreadSheet.OptionsView.ShowFormulas := not dxSpreadSheet.OptionsView.ShowFormulas;
  finally
    dxSpreadSheet.EndUpdate;
  end;
end;

procedure TzViewerExcelForm.LoadFile(const FileName: String);
begin
  dxSpreadSheet.ClearAll;

  if FileExists(FileName) then
  begin
    dxSpreadSheet.LoadFromFile(FileName);
    FFileName := FileName;
  end;
end;

function TzViewerExcelForm.GetReadOnly: Boolean;
begin
  Result := not dxSpreadSheet.OptionsBehavior.Editing;
end;

procedure TzViewerExcelForm.SetReadOnly(const Value: Boolean);
begin
  dxSpreadSheet.OptionsBehavior.Editing := not Value;
end;

procedure TzViewerExcelForm.ShowFile(Params: TExcelParams);
begin
  LoadFile(Params.FileName);

  if assigned(Params.BeforeShow) then
    Params.BeforeShow(Params.TemplateFileName, dxSpreadSheet);

  Self.ReadOnly := Params.ReadOnly;

  // azioni documentali: il gruppo "Documento" e' nel DFM (TdxBar + bottoni +
  // TAction); qui riceviamo l'helper da agganciare all'OnUpdate/OnExecute di
  // quelle azioni. nil = azioni non configurate -> nascondi il gruppo.
  FAzioniDocumento := nil;
  if assigned(Params.OnSetupAzioniDocumento) then
    FAzioniDocumento := Params.OnSetupAzioniDocumento(Self,
      function: string
      begin
        Result := TPath.ChangeExtension(TPath.GetTempFileName, '.pdf');
        ExportPDF(Result, true);
      end);

  // il Tag e la caption iniziale delle azioni li imposta l'helper, per nome,
  // sull'ActionList: nessun Tag "magico" nel DFM
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.InizializzaAzioniDocumento(ActionList);

  barDocumento.Visible := assigned(FAzioniDocumento);

  ShowModal;
end;

// ---------------------------------------------------------------------------
// Azioni documentali: handler condivisi dalle TAction del gruppo "Documento"
// ---------------------------------------------------------------------------

procedure TzViewerExcelForm.AzioneDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag), TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerExcelForm.AzioneDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag));
end;

procedure TzViewerExcelForm.AggiornaStatoDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoAggiornaStato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerExcelForm.AggiornaStatoDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoAggiornaStato;
end;

procedure TzViewerExcelForm.VersioniDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoVersioni(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerExcelForm.VersioniDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoVersioni;
end;

procedure TzViewerExcelForm.ShowFile(const FileName: string; const ReadOnly: Boolean = false);
begin
  LoadFile(FileName);

  Self.ReadOnly := ReadOnly;

  ShowModal;
end;

procedure TzViewerExcelForm.actShellExecuteExecute(Sender: TObject);
begin

  if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
    if doSalva then
      ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerExcelForm.actExportPDFExecute(Sender: TObject);
begin
  // se il documento puo' diventare un allegato, si chiede all'operatore.
  // Quando la funzione non c'e' o e' gia' stata usata, il comportamento
  // resta quello di sempre.
  if assigned(FAzioniDocumento) and FAzioniDocumento.GeneraAllegatoDisponibile then
    case ConfirmYesNoCancel('Generare anche l''allegato al documento?' + sLineBreak + '(No = solo il file PDF, nessun allegato)', mtConfirmation) of
      mrYes:
        begin
          FAzioniDocumento.EseguiComandoGeneraAllegato;
          exit;
        end;
      mrCancel:
        exit;
      // mrNo: prosegue con l'esportazione normale
    end;

  ExportPDF('');
end;

procedure TzViewerExcelForm.ExportPDF(const FileNamePdf: String; const silent: Boolean);
var
  Options: TdxPSPDFReportExportOptions;
  PdfFileName: string;
begin
  if silent then
    PdfFileName := FileNamePdf
  else
  begin
    dxSaveFileDialogPdf.FilterIndex := Ord(PdfFontEmbedding) + 1; //

    // nome senza percorso: con un percorso Windows ignorerebbe InitialDir e proporrebbe
    // la cartella del foglio, che per i report generati e' quella dei temporanei
    dxSaveFileDialogPdf.InitialDir := TFolders.UserDocumentsFolder;
    if FileNamePdf.IsEmpty then
      dxSaveFileDialogPdf.FileName := ExtractFileName(ChangeFileExt(FileName, '.pdf'))
    else
      dxSaveFileDialogPdf.FileName := FileNamePdf;

    if not dxSaveFileDialogPdf.Execute(Self.Handle) then
      exit;

    PdfFileName := dxSaveFileDialogPdf.FileName;
    try
      ForceDirectories(ExtractFilePath(PdfFileName));
    except
    end;

    case dxSaveFileDialogPdf.FilterIndex of
      1:
        FPdfFontEmbedding := zfeNone;
      2:
        FPdfFontEmbedding := zfeFull;
      3:
        FPdfFontEmbedding := zfeSubset;
      4:
        FPdfFontEmbedding := zfeSubset;
    else
      FPdfFontEmbedding := zfeSubset;
    end;
  end;

  Options := TdxPSPDFReportExportOptions.Create;
  try
    Options.Author := '';
    Options.Creator := '';
    Options.Keywords := '';
    Options.Subject := '';
    Options.Title := '';
    //
    Options.CompressStreams := true;
    Options.DefaultFileName := PdfFileName;
    Options.OpenDocumentAfterExport := false; //
    // Options.SecurityOptions
    // Options.SignatureOptions

    Options.EmbedFonts := PdfFontEmbedding in [zfeFull, zfeSubset];
    Options.UseCIDFonts := PdfFontEmbedding = zfeSubset;
    Options.UseJPEGCompression := true;

    StartWait('Attendere...', true);
    try
      dxComponentPrinter.ExportToPDF(PdfFileName, false, Options);
    finally
      StopWait;
    end;
  finally
    FreeAndNil(Options);
  end;

  if not silent then
    if ConfirmYesNo('Si desidera aprire il file ' + PdfFileName + '?', mtWarning) then
      ShellExecute(0, PCHAR('open'), PCHAR(PdfFileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerExcelForm.ShowFile(proc: TProc<TdxSpreadSheet>);
begin

  if assigned(proc) then
    proc(dxSpreadSheet);

  ShowModal;
end;

procedure TzViewerExcelForm.actSalvaExecute(Sender: TObject);
begin
  doSalva;
end;

procedure TzViewerExcelForm.actSalvaUpdate(Sender: TObject);
begin
  actSalva.Enabled := (not FileName.IsEmpty) and dxSpreadSheet.Modified;
end;

procedure TzViewerExcelForm.actSalvaConNomeExecute(Sender: TObject);
begin
  doSalvaConNome;
end;

function TzViewerExcelForm.doSalva: Boolean;
begin
  Result := true;

  if FileName.IsEmpty then
    Result := doSalvaConNome
  else
  begin
    dxSpreadSheet.SaveToFile(FileName);
    dxSpreadSheet.Modified := false;
  end;
end;

function TzViewerExcelForm.doSalvaConNome: Boolean;
begin
  dxSaveFileDialogXlsx.FileName := FileName;
  // vale quando FileName non ha percorso: altrimenti Windows apre la cartella del foglio
  dxSaveFileDialogXlsx.InitialDir := TFolders.UserDocumentsFolder;

  Result := dxSaveFileDialogXlsx.Execute(Self.Handle);

  if Result then
  begin
    FFileName := dxSaveFileDialogXlsx.FileName;
    doSalva;
    Caption := FileName;
  end;
end;

procedure TzViewerExcelForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;

  if dxSpreadSheet.Modified then
  begin
    case ConfirmYesNoCancel('Attenzione: si vuole salvare le modifiche effettuate?', mtInformation) of
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

procedure TzViewerExcelForm.CalcolaExecute(Sender: TObject);
begin
  dxSpreadSheet.OptionsBehavior.AutomaticCalculation := Calcola.Checked;
end;

procedure TzViewerExcelForm.CalcolaUpdate(Sender: TObject);
begin
  Calcola.Checked := dxSpreadSheet.OptionsBehavior.AutomaticCalculation;
end;

function TzViewerExcelForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabFile;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  Result := inherited ShowModal;
end;

end.
