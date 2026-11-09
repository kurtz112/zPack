unit zOffice.Word.Editor;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.StdActns,
  Vcl.ExtCtrls,
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
  cxContainer,
  cxEdit,
  cxTrackBar,
  cxDrawTextUtils,
  cxCustomData,
  cxStyles,
  cxTL,
  cxTextEdit,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxFilter,
  dxCore,
  dxCoreClasses,
  dxGDIPlusAPI,
  dxGDIPlusClasses,
  dxRichEdit.Types,
  dxRichEdit.Options,
  dxRichEdit.Control,
  dxRichEdit.Control.SpellChecker,
  dxRichEdit.Dialogs.EventArgs,
  dxBarBuiltInMenu,
  dxRichEdit.NativeApi,
  dxRichEdit.Doc,
  dxRichEdit.OpenXML,
  dxRichEdit.Html,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  dxRichEdit.Actions,
  dxActions,
  dxPrinting,
  dxBar,
  dxRibbon,
  dxGallery,
  dxRibbonGallery,
  dxRibbonColorGallery,
  dxRichEdit.Platform.Win.Control,
  dxRichEdit.Control.Core,
  dxRibbonForm,
  dxStatusBar,
  dxRibbonStatusBar,
  dxZoomTrackBar,
  dxBarExtItems,
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
  dxPSRichEditControlLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxShellDialogs,
  dxLayoutContainer,
  dxX509Certificate,
  dxPDFCore,
  dxPDFBase,
  dxPDFText,
  dxPDFRecognizedObject,
  dxPDFForm,
  dxPDFFormData,
  dxPDFDocument,
  dxPrintUtils,
  dxCustomPreview,
  dxPDFDocumentViewer,
  dxPDFViewer,
  dxLayoutControl,
  dxRichEdit.PlainText,
  dxRichEdit.DocumentServer,
  dxBarApplicationMenu,
  dxFileActions,
  dxScrollbarAnnotations,
  dxPScxTLLnk,
  dxPScxSchedulerLnk,
  dxPSdxSpreadSheetLnk,
  dxPSdxPDFViewerLnk,
  dxRichEdit.Utils.UriStreamService,
  dxLayoutcxEditAdapters,
  cxMaskEdit,
  dxPScxEditorLnks,
  cxEditRepositoryItems,
  zOffice.Types,
  zOffice.Word.UriStreamProvider,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  dxUIAClasses;

type
  // Voce dell'albero dei fragment: il master (radice) o un fragment (figlio),
  // ricavato dal JSON del report (Params.Fragments) o dai file su disco con la
  // convenzione <master>~~~<dataset>.docx.
  TFragmentInfo = class
  public
    NomeVisualizzato: string;
    NomeFileSenzaEstensione: string;
    NomeVariabile: string; // quella del JSON; vuota per i fragment solo su disco
    NomeDataSet: string;
    IsMaster: Boolean;
    DaJson: Boolean;
    FileEsiste: Boolean;
  end;

  TzViewerWordEditor = class(TdxRibbonForm)
    dxRichEditControl: TdxRichEditControl;
    dxRibbon: TdxRibbon;
    dxBarManager: TdxBarManager;
    dxbStatusBarToolbar1: TdxBar;
    dxbStatusBarToolbar2: TdxBar;
    dxbStatusBarToolbar3: TdxBar;
    bsZoom: TdxBarStatic;
    bccZoom: TdxBarControlContainerItem;

    bbCursorLine: TdxBarButton;
    bbCursorColumn: TdxBarButton;
    bbLocked: TdxBarButton;
    bbModified: TdxBarButton;

    dxRichEditControlNewDocument: TdxRichEditControlNewDocument;
    dxRibbonTabFile: TdxRibbonTab;
    dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument;
    SalvaTemplate: TAction;
    dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs;
    dxBarLargeButtonSaveAs: TdxBarLargeButton;
    dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection;
    dxRibbonTabHome: TdxRibbonTab;
    dxBarClipboard: TdxBar;
    dxBarLargeButtonPaste: TdxBarLargeButton;
    dxRichEditControlCutSelection: TdxRichEditControlCutSelection;
    dxBarButtonCut: TdxBarButton;
    dxRichEditControlCopySelection: TdxRichEditControlCopySelection;
    dxBarButtonCopy: TdxBarButton;
    dxRichEditControlSelectAll: TdxRichEditControlSelectAll;
    dxBarButtonSelectAll: TdxBarButton;
    dxRichEditControlChangeFontName: TdxRichEditControlChangeFontName;
    dxBarFont: TdxBar;
    cxBarEditItemFont: TcxBarEditItem;
    dxRichEditControlChangeFontSize: TdxRichEditControlChangeFontSize;
    cxBarEditItemFontSize: TcxBarEditItem;
    dxRichEditControlIncreaseFontSize: TdxRichEditControlIncreaseFontSize;
    dxBarButtonGrowFont: TdxBarButton;
    dxRichEditControlDecreaseFontSize: TdxRichEditControlDecreaseFontSize;
    dxBarButtonShrinkFont: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxRichEditControlTextUpperCase: TdxRichEditControlTextUpperCase;
    dxBarLargeButtonUPPERCASE: TdxBarLargeButton;
    dxRichEditControlTextLowerCase: TdxRichEditControlTextLowerCase;
    dxBarLargeButtonlowercase: TdxBarLargeButton;
    dxRichEditControlToggleTextCase: TdxRichEditControlToggleTextCase;
    dxBarLargeButtontOGGLEcASE: TdxBarLargeButton;
    dxRichEditControlToggleFontBold: TdxRichEditControlToggleFontBold;
    dxBarButtonBold: TdxBarButton;
    dxRichEditControlToggleFontItalic: TdxRichEditControlToggleFontItalic;
    dxBarButtonItalic: TdxBarButton;
    dxRichEditControlToggleFontUnderline: TdxRichEditControlToggleFontUnderline;
    dxBarButtonUnderline: TdxBarButton;
    dxRichEditControlToggleFontDoubleUnderline: TdxRichEditControlToggleFontDoubleUnderline;
    dxBarButtonDoubleUnderline: TdxBarButton;
    dxRichEditControlToggleFontStrikeout: TdxRichEditControlToggleFontStrikeout;
    dxBarButtonStrikethrough: TdxBarButton;
    dxRichEditControlToggleFontDoubleStrikeout: TdxRichEditControlToggleFontDoubleStrikeout;
    dxBarButtonDoubleStrikethrough: TdxBarButton;
    dxRichEditControlToggleFontSubscript: TdxRichEditControlToggleFontSubscript;
    dxBarButtonSubscript: TdxBarButton;
    dxRichEditControlToggleFontSuperscript: TdxRichEditControlToggleFontSuperscript;
    dxBarButtonSuperscript: TdxBarButton;
    dxRichEditControlTextHighlight: TdxRichEditControlTextHighlight;
    dxRibbonColorGalleryItemTextHighlightColor: TdxRibbonColorGalleryItem;
    dxRichEditControlChangeFontColor: TdxRichEditControlChangeFontColor;
    dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem;
    dxRichEditControlToggleBulletedList: TdxRichEditControlToggleBulletedList;
    dxBarParagraph: TdxBar;
    dxBarButtonBullets: TdxBarButton;
    dxRichEditControlToggleSimpleNumberingList: TdxRichEditControlToggleSimpleNumberingList;
    dxBarButtonNumbering: TdxBarButton;
    dxRichEditControlToggleMultiLevelList: TdxRichEditControlToggleMultiLevelList;
    dxBarButtonMultilevellist: TdxBarButton;
    dxRichEditControlDecrementIndent: TdxRichEditControlDecrementIndent;
    dxBarButtonDecreaseIndent: TdxBarButton;
    dxRichEditControlIncrementIndent: TdxRichEditControlIncrementIndent;
    dxBarButtonIncreaseIndent: TdxBarButton;
    dxRichEditControlToggleShowWhitespace: TdxRichEditControlToggleShowWhitespace;
    dxBarButtonShowHide: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentLeft: TdxRichEditControlToggleParagraphAlignmentLeft;
    dxBarButtonAlignTextLeft: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentCenter: TdxRichEditControlToggleParagraphAlignmentCenter;
    dxBarButtonCenter: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentRight: TdxRichEditControlToggleParagraphAlignmentRight;
    dxBarButtonAlignTextRight: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentJustify: TdxRichEditControlToggleParagraphAlignmentJustify;
    dxBarButtonJustify: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    dxRichEditControlSetSingleParagraphSpacing: TdxRichEditControlSetSingleParagraphSpacing;
    dxBarLargeButton10: TdxBarLargeButton;
    dxRichEditControlSetSesquialteralParagraphSpacing: TdxRichEditControlSetSesquialteralParagraphSpacing;
    dxBarLargeButton15: TdxBarLargeButton;
    dxRichEditControlSetDoubleParagraphSpacing: TdxRichEditControlSetDoubleParagraphSpacing;
    dxBarLargeButton20: TdxBarLargeButton;
    dxRichEditControlShowParagraphForm: TdxRichEditControlShowParagraphForm;
    dxBarLargeButtonParagraph: TdxBarLargeButton;
    dxRichEditControlQuickStylesGallery: TdxRichEditControlQuickStylesGallery;
    dxBarStyles: TdxBar;
    dxRibbonGalleryItemQuickStyles: TdxRibbonGalleryItem;
    dxRibbonGalleryItemQuickStylesGroup1: TdxRibbonGalleryGroup;
    dxRichEditControlSearchFind: TdxRichEditControlSearchFind;
    dxBarEditing: TdxBar;
    dxBarButtonFind: TdxBarButton;
    dxRichEditControlSearchReplace: TdxRichEditControlSearchReplace;
    dxBarButtonReplace: TdxBarButton;
    dxRichEditControlUndo: TdxRichEditControlUndo;
    dxBarLargeButtonUndo: TdxBarLargeButton;
    dxRichEditControlRedo: TdxRichEditControlRedo;
    dxBarLargeButtonRedo: TdxBarLargeButton;
    dxRichEditControlInsertPageBreak: TdxRichEditControlInsertPageBreak;
    dxRibbonTabInsert: TdxRibbonTab;
    dxBarPages: TdxBar;
    dxBarLargeButtonPage: TdxBarLargeButton;
    dxRichEditControlShowInsertTableForm: TdxRichEditControlShowInsertTableForm;
    dxBarTables: TdxBar;
    dxBarLargeButtonTable: TdxBarLargeButton;
    dxRichEditControlInsertPicture: TdxRichEditControlInsertPicture;
    dxBarIllustrations: TdxBar;
    dxBarLargeButtonInlinePicture: TdxBarLargeButton;
    dxRichEditControlInsertFloatingObjectPicture: TdxRichEditControlInsertFloatingObjectPicture;
    dxBarLargeButtonPicture: TdxBarLargeButton;
    dxRichEditControlShowBookmarkForm: TdxRichEditControlShowBookmarkForm;
    dxBarLinks: TdxBar;
    dxBarLargeButtonBookmark: TdxBarLargeButton;
    dxRichEditControlShowHyperlinkForm: TdxRichEditControlShowHyperlinkForm;
    dxBarLargeButtonHyperlink: TdxBarLargeButton;
    dxRichEditControlEditPageHeader: TdxRichEditControlEditPageHeader;
    dxBarHeaderFooter: TdxBar;
    dxBarLargeButtonHeader: TdxBarLargeButton;
    dxRichEditControlEditPageFooter: TdxRichEditControlEditPageFooter;
    dxBarLargeButtonFooter: TdxBarLargeButton;
    dxRichEditControlInsertPageNumberField: TdxRichEditControlInsertPageNumberField;
    dxBarLargeButtonPageNumber: TdxBarLargeButton;
    dxRichEditControlInsertPageCountField: TdxRichEditControlInsertPageCountField;
    dxBarLargeButtonPageCount: TdxBarLargeButton;
    dxRichEditControlInsertTextBox: TdxRichEditControlInsertTextBox;
    dxBarText: TdxBar;
    dxBarLargeButtonTextBox: TdxBarLargeButton;
    dxRichEditControlShowSymbolForm: TdxRichEditControlShowSymbolForm;
    dxBarSymbols: TdxBar;
    dxBarLargeButtonSymbol: TdxBarLargeButton;
    dxRichEditControlPageMarginsGallery: TdxRichEditControlPageMarginsGallery;
    dxRibbonTabPageLayout: TdxRibbonTab;
    dxBarPageSetup: TdxBar;
    dxRibbonGalleryItemMargins: TdxRibbonGalleryItem;
    dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRichEditControlShowPageMarginsSetupForm: TdxRichEditControlShowPageMarginsSetupForm;
    dxBarLargeButtonCustomMargins: TdxBarLargeButton;
    dxBarSubItem3: TdxBarSubItem;
    dxRichEditControlSetPortraitPageOrientation: TdxRichEditControlSetPortraitPageOrientation;
    dxBarLargeButtonPortrait: TdxBarLargeButton;
    dxRichEditControlSetLandscapePageOrientation: TdxRichEditControlSetLandscapePageOrientation;
    dxBarLargeButtonLandscape: TdxBarLargeButton;
    dxRichEditControlPaperSizeGallery: TdxRichEditControlPaperSizeGallery;
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
    dxRichEditControlShowPagePaperSetupForm: TdxRichEditControlShowPagePaperSetupForm;
    dxBarLargeButtonMorePaperSizes: TdxBarLargeButton;
    dxBarSubItem4: TdxBarSubItem;
    dxRichEditControlSetSectionOneColumn: TdxRichEditControlSetSectionOneColumn;
    dxBarLargeButtonOne: TdxBarLargeButton;
    dxRichEditControlSetSectionTwoColumns: TdxRichEditControlSetSectionTwoColumns;
    dxBarLargeButtonTwo: TdxBarLargeButton;
    dxRichEditControlSetSectionThreeColumns: TdxRichEditControlSetSectionThreeColumns;
    dxBarLargeButtonThree: TdxBarLargeButton;
    dxRichEditControlShowColumnsSetupForm: TdxRichEditControlShowColumnsSetupForm;
    dxBarLargeButtonMoreColumns: TdxBarLargeButton;
    dxBarSubItem5: TdxBarSubItem;
    dxRichEditControlInsertColumnBreak: TdxRichEditControlInsertColumnBreak;
    dxBarLargeButtonColumn: TdxBarLargeButton;
    dxRichEditControlInsertSectionBreakNextPage: TdxRichEditControlInsertSectionBreakNextPage;
    dxBarLargeButtonSectionNextPage: TdxBarLargeButton;
    dxRichEditControlInsertSectionBreakEvenPage: TdxRichEditControlInsertSectionBreakEvenPage;
    dxBarLargeButtonSectionEvenPage: TdxBarLargeButton;
    dxRichEditControlInsertSectionBreakOddPage: TdxRichEditControlInsertSectionBreakOddPage;
    dxBarLargeButtonSectionOddPage: TdxBarLargeButton;
    dxBarSubItem6: TdxBarSubItem;
    dxRichEditControlSetSectionLineNumberingNone: TdxRichEditControlSetSectionLineNumberingNone;
    dxBarLargeButtonNone: TdxBarLargeButton;
    dxRichEditControlSetSectionLineNumberingContinuous: TdxRichEditControlSetSectionLineNumberingContinuous;
    dxBarLargeButtonContinuous: TdxBarLargeButton;
    dxRichEditControlSetSectionLineNumberingRestartNewPage: TdxRichEditControlSetSectionLineNumberingRestartNewPage;
    dxBarLargeButtonRestartEachPage: TdxBarLargeButton;
    dxRichEditControlSetSectionLineNumberingRestartNewSection: TdxRichEditControlSetSectionLineNumberingRestartNewSection;
    dxBarLargeButtonRestartEachSection: TdxBarLargeButton;
    dxRichEditControlShowLineNumberingForm: TdxRichEditControlShowLineNumberingForm;
    dxBarLargeButtonLineNumberingOptions: TdxBarLargeButton;
    dxRichEditControlChangePageColor: TdxRichEditControlChangePageColor;
    dxBarBackground: TdxBar;
    dxRibbonColorGalleryItemPageColor: TdxRibbonColorGalleryItem;
    dxRichEditControlInsertTableOfContents: TdxRichEditControlInsertTableOfContents;
    dxRibbonTabReferences: TdxRibbonTab;
    dxBarTableofContents: TdxBar;
    dxBarLargeButtonTableofContents: TdxBarLargeButton;
    dxRichEditControlUpdateTableOfContents: TdxRichEditControlUpdateTableOfContents;
    dxBarLargeButtonUpdateTable: TdxBarLargeButton;
    dxRichEditControlAddParagraphsToTableOfContentsPlaceholder: TdxRichEditControlAddParagraphsToTableOfContentsPlaceholder;
    dxBarLargeButtonAddText: TdxBarLargeButton;
    dxRibbonPopupMenu1: TdxRibbonPopupMenu;
    dxRichEditControlTableOfContentsSetParagraphBodyTextLevel: TdxRichEditControlTableOfContentsSetParagraphBodyTextLevel;
    dxBarLargeButtonDoNotShowinTableofContents: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading1Level: TdxRichEditControlTableOfContentsSetParagraphHeading1Level;
    dxBarLargeButtonLevel1: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading2Level: TdxRichEditControlTableOfContentsSetParagraphHeading2Level;
    dxBarLargeButtonLevel2: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading3Level: TdxRichEditControlTableOfContentsSetParagraphHeading3Level;
    dxBarLargeButtonLevel3: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading4Level: TdxRichEditControlTableOfContentsSetParagraphHeading4Level;
    dxBarLargeButtonLevel4: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading5Level: TdxRichEditControlTableOfContentsSetParagraphHeading5Level;
    dxBarLargeButtonLevel5: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading6Level: TdxRichEditControlTableOfContentsSetParagraphHeading6Level;
    dxBarLargeButtonLevel6: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading7Level: TdxRichEditControlTableOfContentsSetParagraphHeading7Level;
    dxBarLargeButtonLevel7: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading8Level: TdxRichEditControlTableOfContentsSetParagraphHeading8Level;
    dxBarLargeButtonLevel8: TdxBarLargeButton;
    dxRichEditControlTableOfContentsSetParagraphHeading9Level: TdxRichEditControlTableOfContentsSetParagraphHeading9Level;
    dxBarLargeButtonLevel9: TdxBarLargeButton;
    dxRichEditControlInsertCaptionPlaceholder: TdxRichEditControlInsertCaptionPlaceholder;
    dxBarCaptions: TdxBar;
    dxBarLargeButtonInsertCaption: TdxBarLargeButton;
    dxRibbonPopupMenu2: TdxRibbonPopupMenu;
    dxRichEditControlInsertFigureCaption: TdxRichEditControlInsertFigureCaption;
    dxBarLargeButtonFiguresCaption: TdxBarLargeButton;
    dxRichEditControlInsertTableCaption: TdxRichEditControlInsertTableCaption;
    dxBarLargeButtonTablesCaption: TdxBarLargeButton;
    dxRichEditControlInsertEquationCaption: TdxRichEditControlInsertEquationCaption;
    dxBarLargeButtonEquationsCaption: TdxBarLargeButton;
    dxRichEditControlInsertTableOfFiguresPlaceholder: TdxRichEditControlInsertTableOfFiguresPlaceholder;
    dxBarLargeButtonInsertTableofFigures: TdxBarLargeButton;
    dxRibbonPopupMenu3: TdxRibbonPopupMenu;
    dxRichEditControlInsertTableOfFigures: TdxRichEditControlInsertTableOfFigures;
    dxBarLargeButtonTableofFigures: TdxBarLargeButton;
    dxRichEditControlInsertTableOfTables: TdxRichEditControlInsertTableOfTables;
    dxBarLargeButtonTableofTables: TdxBarLargeButton;
    dxRichEditControlInsertTableOfEquations: TdxRichEditControlInsertTableOfEquations;
    dxBarLargeButtonTableofEquations: TdxBarLargeButton;
    dxRichEditControlUpdateTableOfFigures: TdxRichEditControlUpdateTableOfFigures;
    dxBarLargeButtonUpdateTable1: TdxBarLargeButton;
    dxRichEditControlShowInsertMergeFieldForm: TdxRichEditControlShowInsertMergeFieldForm;
    dxRichEditControlShowAllFieldCodes: TdxRichEditControlShowAllFieldCodes;
    dxRichEditControlShowAllFieldResults: TdxRichEditControlShowAllFieldResults;
    dxRichEditControlToggleViewMergedData: TdxRichEditControlToggleViewMergedData;
    dxBarLargeButtonViewMergedData: TdxBarLargeButton;
    dxRichEditControlCheckSpelling: TdxRichEditControlCheckSpelling;
    dxRibbonTabReview: TdxRibbonTab;
    dxBarProofing: TdxBar;
    dxBarLargeButtonSpelling: TdxBarLargeButton;
    dxRichEditControlProtectDocument: TdxRichEditControlProtectDocument;
    dxBarProtect: TdxBar;
    dxBarLargeButtonProtectDocument: TdxBarLargeButton;
    dxRichEditControlUnprotectDocument: TdxRichEditControlUnprotectDocument;
    dxBarLargeButtonUnprotectDocument: TdxBarLargeButton;
    dxRichEditControlShowRangeEditingPermissions: TdxRichEditControlShowRangeEditingPermissions;
    dxBarLargeButtonRangeEditingPermissions: TdxBarLargeButton;
    dxRichEditControlEncryptDocument: TdxRichEditControlEncryptDocument;
    dxBarLargeButtonEncryptwithPassword: TdxBarLargeButton;
    dxRichEditControlSwitchToSimpleView: TdxRichEditControlSwitchToSimpleView;
    dxRibbonTabView: TdxRibbonTab;
    dxBarDocumentViews: TdxBar;
    dxBarLargeButtonSimpleView: TdxBarLargeButton;
    dxRichEditControlSwitchToDraftView: TdxRichEditControlSwitchToDraftView;
    dxBarLargeButtonDraftView: TdxBarLargeButton;
    dxRichEditControlSwitchToPrintLayoutView: TdxRichEditControlSwitchToPrintLayoutView;
    dxBarLargeButtonPrintLayout: TdxBarLargeButton;
    dxRichEditControlToggleShowHorizontalRuler: TdxRichEditControlToggleShowHorizontalRuler;
    dxBarShow: TdxBar;
    dxBarLargeButtonHorizontalRuler: TdxBarLargeButton;
    dxRichEditControlToggleShowVerticalRuler: TdxRichEditControlToggleShowVerticalRuler;
    dxBarLargeButtonVerticalRuler: TdxBarLargeButton;
    dxRichEditControlZoomOut: TdxRichEditControlZoomOut;
    dxBarZoom: TdxBar;
    dxBarLargeButtonZoomOut: TdxBarLargeButton;
    dxRichEditControlZoomIn: TdxRichEditControlZoomIn;
    dxBarLargeButtonZoomIn: TdxBarLargeButton;
    dxRichEditControlGoToPageHeader: TdxRichEditControlGoToPageHeader;
    dxRibbonTabHeaderFooterDesign: TdxRibbonTab;
    dxBarNavigation: TdxBar;
    dxBarLargeButtonGotoHeader: TdxBarLargeButton;
    dxRichEditControlGoToPageFooter: TdxRichEditControlGoToPageFooter;
    dxBarLargeButtonGotoFooter: TdxBarLargeButton;
    dxRichEditControlGoToNextPageHeaderFooter: TdxRichEditControlGoToNextPageHeaderFooter;
    dxBarLargeButtonShowNext: TdxBarLargeButton;
    dxRichEditControlGoToPreviousPageHeaderFooter: TdxRichEditControlGoToPreviousPageHeaderFooter;
    dxBarLargeButtonShowPrevious: TdxBarLargeButton;
    dxRichEditControlToggleHeaderFooterLinkToPrevious: TdxRichEditControlToggleHeaderFooterLinkToPrevious;
    dxBarLargeButtonLinktoPrevious: TdxBarLargeButton;
    dxRichEditControlToggleDifferentFirstPage: TdxRichEditControlToggleDifferentFirstPage;
    dxBarOptions: TdxBar;
    dxBarLargeButtonDifferentFirstPage: TdxBarLargeButton;
    dxRichEditControlToggleDifferentOddAndEvenPages: TdxRichEditControlToggleDifferentOddAndEvenPages;
    dxBarLargeButtonDifferentOddEvenPages: TdxBarLargeButton;
    dxRichEditControlClosePageHeaderFooter: TdxRichEditControlClosePageHeaderFooter;
    dxBarClose: TdxBar;
    dxBarLargeButtonCloseHeaderandFooter: TdxBarLargeButton;
    dxRichEditControlToggleShowTableGridLines: TdxRichEditControlToggleShowTableGridLines;
    dxRibbonTabTableLayout: TdxRibbonTab;
    dxBarTable: TdxBar;
    dxBarLargeButtonViewGridlines: TdxBarLargeButton;
    dxRichEditControlShowTablePropertiesForm: TdxRichEditControlShowTablePropertiesForm;
    dxBarLargeButtonTableProperties: TdxBarLargeButton;
    dxBarRowColumns: TdxBar;
    dxBarSubItem7: TdxBarSubItem;
    dxRichEditControlShowDeleteTableCellsForm: TdxRichEditControlShowDeleteTableCellsForm;
    dxBarLargeButtonDeleteCells: TdxBarLargeButton;
    dxRichEditControlDeleteTableColumns: TdxRichEditControlDeleteTableColumns;
    dxBarLargeButtonDeleteColumns: TdxBarLargeButton;
    dxRichEditControlDeleteTableRows: TdxRichEditControlDeleteTableRows;
    dxBarLargeButtonDeleteRows: TdxBarLargeButton;
    dxRichEditControlDeleteTable: TdxRichEditControlDeleteTable;
    dxBarLargeButtonDeleteTable: TdxBarLargeButton;
    dxRichEditControlInsertTableRowAbove: TdxRichEditControlInsertTableRowAbove;
    dxBarLargeButtonInsertAbove: TdxBarLargeButton;
    dxRichEditControlInsertTableRowBelow: TdxRichEditControlInsertTableRowBelow;
    dxBarLargeButtonInsertBelow: TdxBarLargeButton;
    dxRichEditControlInsertTableColumnToTheLeft: TdxRichEditControlInsertTableColumnToTheLeft;
    dxBarLargeButtonInsertLeft: TdxBarLargeButton;
    dxRichEditControlInsertTableColumnToTheRight: TdxRichEditControlInsertTableColumnToTheRight;
    dxBarLargeButtonInsertRight: TdxBarLargeButton;
    dxRichEditControlMergeTableCells: TdxRichEditControlMergeTableCells;
    dxBarMerge: TdxBar;
    dxBarLargeButtonMergeCells: TdxBarLargeButton;
    dxRichEditControlShowSplitTableCellsForm: TdxRichEditControlShowSplitTableCellsForm;
    dxBarLargeButtonSplitCells: TdxBarLargeButton;
    dxRichEditControlSplitTable: TdxRichEditControlSplitTable;
    dxBarLargeButtonSplitTable: TdxBarLargeButton;
    dxBarCellSize: TdxBar;
    dxBarSubItem8: TdxBarSubItem;
    dxRichEditControlToggleTableAutoFitContents: TdxRichEditControlToggleTableAutoFitContents;
    dxBarLargeButtonAutoFitContents: TdxBarLargeButton;
    dxRichEditControlToggleTableAutoFitWindow: TdxRichEditControlToggleTableAutoFitWindow;
    dxBarLargeButtonAutoFitWindow: TdxBarLargeButton;
    dxRichEditControlToggleTableFixedColumnWidth: TdxRichEditControlToggleTableFixedColumnWidth;
    dxBarLargeButtonFixedColumnWidth: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsTopLeftAlignment: TdxRichEditControlToggleTableCellsTopLeftAlignment;
    dxBarAlignment: TdxBar;
    dxBarButtonAlignTopLeft: TdxBarButton;
    dxRichEditControlToggleTableCellsTopCenterAlignment: TdxRichEditControlToggleTableCellsTopCenterAlignment;
    dxBarButtonAlignTopCenter: TdxBarButton;
    dxRichEditControlToggleTableCellsTopRightAlignment: TdxRichEditControlToggleTableCellsTopRightAlignment;
    dxBarButtonAlignTopRight: TdxBarButton;
    dxRichEditControlToggleTableCellsMiddleLeftAlignment: TdxRichEditControlToggleTableCellsMiddleLeftAlignment;
    dxBarButtonAlignCenterLeft: TdxBarButton;
    dxRichEditControlToggleTableCellsMiddleCenterAlignment: TdxRichEditControlToggleTableCellsMiddleCenterAlignment;
    dxBarButtonAlignCenter: TdxBarButton;
    dxRichEditControlToggleTableCellsMiddleRightAlignment: TdxRichEditControlToggleTableCellsMiddleRightAlignment;
    dxBarButtonAlignCenterRight: TdxBarButton;
    dxRichEditControlToggleTableCellsBottomLeftAlignment: TdxRichEditControlToggleTableCellsBottomLeftAlignment;
    dxBarButtonAlignBottomLeft: TdxBarButton;
    dxRichEditControlToggleTableCellsBottomCenterAlignment: TdxRichEditControlToggleTableCellsBottomCenterAlignment;
    dxBarButtonAlignBottomCenter: TdxBarButton;
    dxRichEditControlToggleTableCellsBottomRightAlignment: TdxRichEditControlToggleTableCellsBottomRightAlignment;
    dxBarButtonAlignBottomRight: TdxBarButton;
    dxRichEditControlTableStylesGallery: TdxRichEditControlTableStylesGallery;
    dxBarTableStyles: TdxBar;
    dxRibbonGalleryItemTableStyles: TdxRibbonGalleryItem;
    dxRibbonGalleryItemTableStylesGroup1: TdxRibbonGalleryGroup;
    dxBarSubItem9: TdxBarSubItem;
    dxRichEditControlToggleTableCellsBottomBorder: TdxRichEditControlToggleTableCellsBottomBorder;
    dxBarLargeButtonBottomBorder: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsTopBorder: TdxRichEditControlToggleTableCellsTopBorder;
    dxBarLargeButtonTopBorder: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsLeftBorder: TdxRichEditControlToggleTableCellsLeftBorder;
    dxBarLargeButtonLeftBorder: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsRightBorder: TdxRichEditControlToggleTableCellsRightBorder;
    dxBarLargeButtonRightBorder: TdxBarLargeButton;
    dxRichEditControlResetTableCellsBorders: TdxRichEditControlResetTableCellsBorders;
    dxBarLargeButtonNoBorder: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsAllBorders: TdxRichEditControlToggleTableCellsAllBorders;
    dxBarLargeButtonAllBorders: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsOutsideBorder: TdxRichEditControlToggleTableCellsOutsideBorder;
    dxBarLargeButtonOutsideBorders: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsInsideBorder: TdxRichEditControlToggleTableCellsInsideBorder;
    dxBarLargeButtonInsideBorders: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsInsideHorizontalBorder: TdxRichEditControlToggleTableCellsInsideHorizontalBorder;
    dxBarLargeButtonInsideHorizontalBorder: TdxBarLargeButton;
    dxRichEditControlToggleTableCellsInsideVerticalBorder: TdxRichEditControlToggleTableCellsInsideVerticalBorder;
    dxBarLargeButtonInsideVerticalBorder: TdxBarLargeButton;
    dxRichEditControlChangeFloatingObjectFillColor: TdxRichEditControlChangeFloatingObjectFillColor;
    dxRibbonTabFormat: TdxRibbonTab;
    dxBarShapeStyles: TdxBar;
    dxRibbonColorGalleryItemShapeFill: TdxRibbonColorGalleryItem;
    dxRichEditControlChangeFloatingObjectOutlineColor: TdxRichEditControlChangeFloatingObjectOutlineColor;
    dxRibbonColorGalleryItemShapeOutline: TdxRibbonColorGalleryItem;
    dxBarArrange: TdxBar;
    dxBarSubItem10: TdxBarSubItem;
    dxRichEditControlSetFloatingObjectSquareTextWrapType: TdxRichEditControlSetFloatingObjectSquareTextWrapType;
    dxBarLargeButtonSquare: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectTightTextWrapType: TdxRichEditControlSetFloatingObjectTightTextWrapType;
    dxBarLargeButtonTight: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectThroughTextWrapType: TdxRichEditControlSetFloatingObjectThroughTextWrapType;
    dxBarLargeButtonThrough: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectTopAndBottomTextWrapType: TdxRichEditControlSetFloatingObjectTopAndBottomTextWrapType;
    dxBarLargeButtonTopandBottom: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectBehindTextWrapType: TdxRichEditControlSetFloatingObjectBehindTextWrapType;
    dxBarLargeButtonBehindText: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectInFrontOfTextWrapType: TdxRichEditControlSetFloatingObjectInFrontOfTextWrapType;
    dxBarLargeButtonInFrontofText: TdxBarLargeButton;
    dxBarSubItem11: TdxBarSubItem;
    dxRichEditControlSetFloatingObjectTopLeftAlignment: TdxRichEditControlSetFloatingObjectTopLeftAlignment;
    dxBarLargeButtonTopLeft: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectTopCenterAlignment: TdxRichEditControlSetFloatingObjectTopCenterAlignment;
    dxBarLargeButtonTopCenter: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectTopRightAlignment: TdxRichEditControlSetFloatingObjectTopRightAlignment;
    dxBarLargeButtonTopRight: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectMiddleLeftAlignment: TdxRichEditControlSetFloatingObjectMiddleLeftAlignment;
    dxBarLargeButtonMiddleLeft: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectMiddleCenterAlignment: TdxRichEditControlSetFloatingObjectMiddleCenterAlignment;
    dxBarLargeButtonMiddleCenter: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectMiddleRightAlignment: TdxRichEditControlSetFloatingObjectMiddleRightAlignment;
    dxBarLargeButtonMiddleRight: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectBottomLeftAlignment: TdxRichEditControlSetFloatingObjectBottomLeftAlignment;
    dxBarLargeButtonBottomLeft: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectBottomCenterAlignment: TdxRichEditControlSetFloatingObjectBottomCenterAlignment;
    dxBarLargeButtonBottomCenter: TdxBarLargeButton;
    dxRichEditControlSetFloatingObjectBottomRightAlignment: TdxRichEditControlSetFloatingObjectBottomRightAlignment;
    dxBarLargeButtonBottomRight: TdxBarLargeButton;
    dxBarSubItem12: TdxBarSubItem;
    dxRichEditControlFloatingObjectBringForward: TdxRichEditControlFloatingObjectBringForward;
    dxBarLargeButtonBringForward: TdxBarLargeButton;
    dxRichEditControlFloatingObjectBringToFront: TdxRichEditControlFloatingObjectBringToFront;
    dxBarLargeButtonBringtoFront: TdxBarLargeButton;
    dxRichEditControlFloatingObjectBringInFrontOfText: TdxRichEditControlFloatingObjectBringInFrontOfText;
    dxBarLargeButtonBringinFrontofText: TdxBarLargeButton;
    dxBarSubItem13: TdxBarSubItem;
    dxRichEditControlFloatingObjectSendBackward: TdxRichEditControlFloatingObjectSendBackward;
    dxBarLargeButtonSendBackward: TdxBarLargeButton;
    dxRichEditControlFloatingObjectSendToBack: TdxRichEditControlFloatingObjectSendToBack;
    dxBarLargeButtonSendtoBack: TdxBarLargeButton;
    dxRichEditControlFloatingObjectSendBehindText: TdxRichEditControlFloatingObjectSendBehindText;
    dxBarLargeButtonSendBehindText: TdxBarLargeButton;
    dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm;
    dxBarPrint: TdxBar;
    dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm;
    dxBarLargeButtonPrintPreview: TdxBarLargeButton;
    dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm;
    StatusBar: TdxRibbonStatusBar;
    tbZoom: TdxZoomTrackBar;
    Printer: TdxComponentPrinter;
    RichEditPrinterLink: TdxRichEditControlReportLink;
    dxBarButton1: TdxBarButton;
    actExportPDF: TAction;
    dxBarLargeButton1: TdxBarLargeButton;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    dxLayoutItemEditor: TdxLayoutItem;
    dxBarManagerBar1: TdxBar;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxRichEditControlShowMergeDatabaseRecordsForm: TdxRichEditControlShowMergeDatabaseRecordsForm;
    DataSource: TDataSource;
    dxBarManagerBarQuickAccess: TdxBar;
    dxBarManagerBar2: TdxBar;
    dxBarManagerBar3: TdxBar;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarLargeButton6: TdxBarLargeButton;
    dxBarLargeButton8: TdxBarLargeButton;
    dxBarLargeButton9: TdxBarLargeButton;
    dxBarLargeButton11: TdxBarLargeButton;
    ActionList: TActionList;
    dxBarLargeButton13: TdxBarLargeButton;
    treeFields: TcxTreeList;
    dxLayoutItemFields: TdxLayoutItem;
    dxLayoutGroupEditor: TdxLayoutGroup;
    dxLayoutSplitterItemFields: TdxLayoutSplitterItem;
    treeFieldsColumnFieldName: TcxTreeListColumn;
    treeFieldsColumnFieldValue: TcxTreeListColumn;
    treeFieldsColumnDisplayLabel: TcxTreeListColumn;
    ApriConWord: TAction;
    dxBarButton2: TdxBarButton;
    ApriCartella: TAction;
    dxBarLargeButton18: TdxBarLargeButton;
    dxBarManagerBar5: TdxBar;
    actPoliticheAccessi: TAction;
    actRicaricaPolitiche: TAction;
    dxBarLargeButton23: TdxBarLargeButton;
    ElencoCampiUtilizzati: TAction;
    dxBarManagerBar7: TdxBar;
    dxBarLargeButton24: TdxBarLargeButton;
    Chiudi: TAction;
    dxBarButton3: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxBarButton12: TdxBarButton;
    actPermessiAzione: TAction;
    popActions: TdxBarPopupMenu;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton17: TdxBarButton;
    dxBarButton18: TdxBarButton;
    MailMerge: TAction;
    dxBarLargeButton2: TdxBarLargeButton;
    edDatasets: TcxComboBox;
    dxLayoutItemDataSets: TdxLayoutItem;
    dxLayoutGroupDataSets: TdxLayoutGroup;
    cxEditRepository: TcxEditRepository;
    cxEditRepositoryImageItem: TcxEditRepositoryImageItem;
    cxEditRepositoryMemoItem: TcxEditRepositoryMemoItem;
    cxEditRepositoryTextItem: TcxEditRepositoryTextItem;
    cxEditRepositoryCheckBoxItem: TcxEditRepositoryCheckBoxItem;
    actSalvaConNome: TAction;
    dxBarLargeButton3: TdxBarLargeButton;
    dxSaveFileDialogDocx: TdxSaveFileDialog;
    dxLayoutEmptySpaceItem: TdxLayoutEmptySpaceItem;
    dxBarLargeButton7: TdxBarLargeButton;
    actApriTemplate: TAction;
    dxOpenFileDialog: TdxOpenFileDialog;
    HiddenFields: TAction;
    dxBarLargeButton12: TdxBarLargeButton;
    treeFragments: TcxTreeList;
    treeFragmentsColumnNome: TcxTreeListColumn;
    treeFragmentsColumnDataSet: TcxTreeListColumn;
    dxLayoutItemFragments: TdxLayoutItem;
    dxLayoutSplitterItemFragments: TdxLayoutSplitterItem;
    popFragments: TdxBarPopupMenu;
    AggiungiFragment: TAction;
    EliminaFragment: TAction;
    MostraDatiUniti: TAction;
    dxBarButtonAggiungiFragment: TdxBarButton;
    dxBarButtonEliminaFragment: TdxBarButton;
    procedure actApriTemplateExecute(Sender: TObject);
    procedure actSalvaConNomeExecute(Sender: TObject);
    procedure ApriCartellaExecute(Sender: TObject);
    procedure ApriConWordExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure dxRichEditControlActiveViewChanged(Sender: TObject);
    procedure dxRichEditControlCalculateDocumentVariable(Sender: TObject; E: TdxCalculateDocumentVariableEventArgs);
    procedure dxRichEditControlContentChanged(Sender: TObject);
    procedure dxRichEditControlSelectionChanged(Sender: TObject);
    procedure dxRichEditControlZoomChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbZoomPropertiesChange(Sender: TObject);
    procedure dxRichEditControlDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure dxRichEditControlDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SalvaTemplateExecute(Sender: TObject);
    procedure SalvaTemplateUpdate(Sender: TObject);
    procedure treeFieldsDblClick(Sender: TObject);
    procedure treeFieldsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ElencoCampiUtilizzatiExecute(Sender: TObject);
    procedure dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
    procedure MailMergeExecute(Sender: TObject);
    procedure edDatasetsPropertiesEditValueChanged(Sender: TObject);
    procedure treeFieldsColumnFieldValueGetEditProperties(Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var EditProperties: TcxCustomEditProperties);
    procedure HiddenFieldsExecute(Sender: TObject);
    procedure treeFragmentsFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure AggiungiFragmentExecute(Sender: TObject);
    procedure EliminaFragmentExecute(Sender: TObject);
    procedure EliminaFragmentUpdate(Sender: TObject);
    procedure MostraDatiUnitiExecute(Sender: TObject);
    procedure MostraDatiUnitiUpdate(Sender: TObject);
  private
    FParams: TWordParams;
    FFragmentInfos: TObjectList<TFragmentInfo>; // voci dell'albero, master compreso
    FNomeFileCaricato: string; // fragment (o master) aperto nell'editor, senza estensione
    FCaricamentoInCorso: Boolean; // guardia: il fuoco cambia da codice, non chiedere di salvare
  private
    procedure UpdateZoom;
    procedure FillTreeFields(DataSet: TDataSet);
    procedure AddSelectedField;

    function doSalvaTemplate(const ChiediConferma: Boolean = true): Boolean;
    function doSalvaConNome: Boolean;
    function ChiediSalvataggio: Boolean;
    function CopiaInBackup(const NomeFile: string): string;

    procedure AggiornaImmagini;

    procedure UpdateRibbonContexstsStates;
    procedure InitHints;
  private
    function TemplateFolder: string;
    function MasterInfo: TFragmentInfo;
    function TrovaInfoPerFile(const NomeFileSenzaEstensione: string): TFragmentInfo;
    function TrovaInfoPerNome(const NomeVisualizzato: string): TFragmentInfo;
    function InfoFocalizzato: TFragmentInfo;
    function NodoDi(Info: TFragmentInfo): TcxTreeListNode;
    function RisolviDataSet(Info: TFragmentInfo): TDataSet;
    procedure RiempiTreeFragments;
    procedure FocalizzaNodo(Info: TFragmentInfo);
    procedure SelezionaFragment(Info: TFragmentInfo);
    procedure CaricaFragment(Info: TFragmentInfo);

    function GetField(DataSet: TDataSet; const VariableName: string): TField;
  private
    procedure ShowHiddenFields(const visible: Boolean);
  public
    constructor Create(aOwner: TComponent); Override;
    destructor Destroy; Override;
  public

    procedure EditTemplateWord(Params: TWordParams);
    function ShowModal: Integer; override;

    property Params: TWordParams read FParams;
  end;

procedure EditTemplateWord(Params: TWordParams);

//
// Main template (anche per il run)
// Elenco dei suoi fragment
// Selezione del dataset
// TMailMergeEngine.MailMerge con visualizzazione tramite ViewFile(stream)
//
// Verificare il funzionamento dei pulsanti Mostra Codici/Mostra Valori etc
//
// zReportsManager chiama direttamente TMailMergeEngine.MailMerge
//
// zReportsManager chiama EditTemplateWord per l'editing/nuovo report [folder dove salvare?]
//
// PROCEDURE DI CALLBACK!!!!!!

implementation

uses
  Winapi.ShlObj,
  Winapi.ShellAPI,
  System.Rtti,
  System.IOUtils,
  System.Generics.Defaults,
  Vcl.Clipbrd,
  zz.PercorsiLunghi, // Mantis #131 - 2026-09-16: backup oltre i 260 caratteri di MAX_PATH
  cxGeometry,
  dxCoreGraphics,
  dxRichEdit.DocumentModel.RichEditDocumentServer,
  zz.Vcl,
  zdx,
  zBaseLib,
  zRestrictions.Types,
  zOffice.Word.Form,
  zOffice.Word.MailMerge,
  zMsg,
  zOffice,
  zOffice.Word.Utils;

{$R *.dfm}

type
  TdxRichEditControlAccess = class(TdxRichEditControl);

procedure EditTemplateWord(Params: TWordParams);
var
  zViewerWordEditor: TzViewerWordEditor;
begin
  Application.CreateForm(TzViewerWordEditor, zViewerWordEditor);
  try
    zViewerWordEditor.EditTemplateWord(Params);
  finally
    FreeAndNil(zViewerWordEditor);
  end;
end;

constructor TzViewerWordEditor.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FParams.Init;

  FFragmentInfos := TObjectList<TFragmentInfo>.Create(true);
  FNomeFileCaricato := '';
  FCaricamentoInCorso := false;

  dx.InitLayoutControl(dxLayoutControl);
  dx.InitPrinter(Printer);

  InitHints;

  edDatasets.Properties.Items.Clear;
  edDatasets.Text := '';

  dxRichEditControl.Options.MailMerge.DataSource := DataSource;
end;

destructor TzViewerWordEditor.Destroy;
begin
  FreeAndNil(FFragmentInfos);
  inherited;
end;

procedure TzViewerWordEditor.actSalvaConNomeExecute(Sender: TObject);
begin
  doSalvaConNome;
end;

procedure TzViewerWordEditor.UpdateZoom;
begin
  if dxRichEditControl.ActiveView.ZoomFactor > 5 then
    dxRichEditControl.ActiveView.ZoomFactor := 5;
  tbZoom.Position := Round(dxRichEditControl.ActiveView.ZoomFactor * 100);
end;

procedure TzViewerWordEditor.tbZoomPropertiesChange(Sender: TObject);
begin
  bsZoom.Caption := Format('%3d %%', [tbZoom.Position]);
  dxRichEditControl.ActiveView.ZoomFactor := tbZoom.Position / 100;
end;

procedure TzViewerWordEditor.dxRichEditControlActiveViewChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerWordEditor.dxRichEditControlZoomChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerWordEditor.dxRichEditControlContentChanged(Sender: TObject);
begin
  // bbCursorLine.Caption := 'Linea: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Row.LineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' +   dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Column.colLineNumber.ToString;
end;

procedure TzViewerWordEditor.dxRichEditControlSelectionChanged(Sender: TObject);
begin
  UpdateRibbonContexstsStates;
  // bbCursorLine.Caption := 'Linea: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Row.LineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Column.colLineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.LeftOffset.ToString;
end;

procedure TzViewerWordEditor.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerWordEditor.treeFieldsDblClick(Sender: TObject);
begin
  AddSelectedField;
end;

procedure TzViewerWordEditor.treeFieldsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_return then
  begin
    AddSelectedField;
    Key := 0;
  end;
end;

procedure TzViewerWordEditor.ApriCartellaExecute(Sender: TObject);
begin
  if TemplateFolder.IsEmpty then
    exit;

  ShellExecute(0, PCHAR('open'), PCHAR(TemplateFolder), nil, nil, SW_RESTORE);
end;

procedure TzViewerWordEditor.ApriConWordExecute(Sender: TObject);
begin
  if not doSalvaTemplate then
    exit;

  if Params.TemplateFileName.IsEmpty then
    exit;

  ShellExecute(0, PCHAR('open'), PCHAR(Params.TemplateFileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerWordEditor.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerWordEditor.FillTreeFields(DataSet: TDataSet);
var
  Field: TField;
  node: TcxTreeListNode;
begin
  treeFields.BeginUpdate;
  try
    treeFields.Clear;

    if assigned(DataSet) then
    begin
      for Field in DataSet.Fields do
      begin
        node := treeFields.Add;
        node.Texts[0] := Field.FieldName;
        node.Texts[1] := Field.DisplayName;

        if Field.IsBlob then
          node.Values[2] := Field.Value
        else
          node.Texts[2] := Field.DisplayText;

        node.Data := Field;
      end;
    end
    else
    begin
      node := treeFields.Add;
      node.Texts[0] := 'CAMPO_1';
      node.Texts[1] := 'Campo 1';
      node.Texts[2] := 'Uno';

      node := treeFields.Add;
      node.Texts[0] := 'CAMPO_2';
      node.Texts[1] := 'Campo 2';
      node.Texts[2] := 'Due';

      node := treeFields.Add;
      node.Texts[0] := 'CAMPO_3';
      node.Texts[1] := 'Campo 3';
      node.Texts[2] := 'Tre';
    end;

    treeFields.ApplyBestFit;

    treeFields.GotoBOF;

    if treeFields.Count > 0 then
      treeFields.Items[0].Selected := true;
  finally
    treeFields.EndUpdate;
  end;
end;

procedure TzViewerWordEditor.dxRichEditControlDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = treeFields;
end;

procedure TzViewerWordEditor.dxRichEditControlDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  ARichEdtCtrl: TdxRichEditControlAccess;
begin
  ARichEdtCtrl := TdxRichEditControlAccess(Sender);
  ARichEdtCtrl.MouseDown(mbLeft, [ssLeft], X, Y);
  ARichEdtCtrl.MouseUp(mbLeft, [ssLeft], X, Y);
  AddSelectedField;
end;

function TzViewerWordEditor.doSalvaConNome: Boolean;
var
  EraNuovo: Boolean;
begin
  EraNuovo := Params.TemplateFileName.IsEmpty;

  dxSaveFileDialogDocx.FileName := Params.TemplateFileName;

  if dxSaveFileDialogDocx.FileName <> '' then
    dxSaveFileDialogDocx.InitialDir := ExtractFilePath(dxSaveFileDialogDocx.FileName)
  else
    dxSaveFileDialogDocx.InitialDir := Params.DefaultFolder;

  result := dxSaveFileDialogDocx.Execute(Self.Handle);

  if result then
  begin
    FParams.TemplateFileName := dxSaveFileDialogDocx.FileName;
    // SaveDocument scrive su CurrentFileName: va impostato prima del salvataggio.
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName := Params.TemplateFileName;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFormat := dxRichEditControl.DocumentModel.AutodetectDocumentFormat(Params.TemplateFileName);
    // La conferma e' gia' stata data da chi ha chiesto il salvataggio.
    doSalvaTemplate(false);
    Caption := Params.TemplateFileName;

    // Il master aveva nome vuoto: l'albero dei fragment va rifatto col nome vero.
    if EraNuovo then
    begin
      RiempiTreeFragments;
      FNomeFileCaricato := '';
      SelezionaFragment(MasterInfo);
    end;
  end;
end;

// Copia il file nella sottocartella __backup con il prefisso data/ora e ritorna
// il nome della copia. Serve prima di sovrascrivere un template e prima di
// eliminare un fragment: un file archiviato si recupera, uno cancellato no.
function TzViewerWordEditor.CopiaInBackup(const NomeFile: string): string;
var
  CartellaBackup: string;
begin
  // Mantis #131 - 2026-09-16: la copia di backup falliva con "Impossibile trovare
  // il percorso specificato" quando il percorso del backup superava i 260 caratteri
  // di MAX_PATH. Si usano le funzioni di TzPercorsiLunghi (prefisso esteso \\?\ e
  // \\?\UNC\) e un prefisso data/ora piu' corto, che consuma 6 caratteri in meno.
  CartellaBackup := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(NomeFile)) + '__backup\';
  TzPercorsiLunghi.ForzaCartelle(CartellaBackup);
  result := CartellaBackup + FormatDateTime('yyyymmddhhnnss', now) + '_' + TPath.GetFileName(NomeFile);
  TzPercorsiLunghi.CopiaFile(NomeFile, result);
end;

function TzViewerWordEditor.doSalvaTemplate(const ChiediConferma: Boolean = true): Boolean;
var
  NomeFile: string;
begin
  result := false;

  if ChiediConferma then
    if not ConfirmYesNo('Attenzione: si vuole salvare il template?', mtWarning) then
      exit;

  // Il backup e' del file che si sta davvero salvando: con un fragment aperto
  // CurrentFileName e' il fragment, non il master di Params.TemplateFileName.
  NomeFile := dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName;
  if NomeFile.IsEmpty then
    NomeFile := Params.TemplateFileName;

  // Template nuovo, senza nome: si sceglie dove e come salvarlo.
  if NomeFile.IsEmpty then
    exit(doSalvaConNome);

  if TzPercorsiLunghi.FileEsiste(NomeFile) then
    CopiaInBackup(NomeFile);

  ShowHiddenFields(false);

  // La misura che si vede e' quella che si salva: il suffisso @L:A nel codice
  // dei campi INCLUDEPICTURE viene allineato all'immagine corrente. Con i dati
  // uniti spenti i campi non hanno immagine e la misura salvata resta com'e'.
  TzWordImmagini.SincronizzaDimensioni(dxRichEditControl.Document);

  dxRichEditControl.SaveDocument;
  dxRichEditControl.DocumentModelModified := false;

  result := true;
end;

// Domanda unica per la chiusura della finestra e per il cambio di fragment.
// Ritorna False se l'utente annulla; con "No" le modifiche restano in memoria
// e vengono perse da chi carica il documento successivo.
function TzViewerWordEditor.ChiediSalvataggio: Boolean;
begin
  result := true;

  if not dxRichEditControl.DocumentModelModified then
    exit;

  case ConfirmYesNoCancel('Attenzione: si vuole salvare il template?', mtInformation) of
    mrCancel:
      result := false;
    mrYes:
      // Con un template nuovo si apre "Salva con nome": se l'utente annulla lì,
      // la chiusura o il cambio di fragment si annullano con lui.
      result := doSalvaTemplate(false);
    mrNo:
      begin
        // non fa nulla
      end;
  end;
end;

procedure TzViewerWordEditor.dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin
  dx.dxBarAssignPopupMenu(ABar, popActions);
end;

procedure TzViewerWordEditor.ElencoCampiUtilizzatiExecute(Sender: TObject);
var
  I: Integer;
  s: string;
  list: TStringList;
begin
  s := '';

  list := TStringList.Create;
  try
    list.Duplicates := dupIgnore;

    for I := 0 to dxRichEditControl.Document.Fields.Count - 1 do
    begin
      s := dxRichEditControl.Document.GetText(dxRichEditControl.Document.Fields[I].CodeRange);

      if list.IndexOf(s) = -1 then
        list.Add(s);
    end;

    if list.Count = 0 then
      ConfirmOk('Nessun campo rilevato.', mtInformation)
    else
    begin
      Clipboard.AsText := list.Text;
      ConfirmOk(list.Text, mtInformation);
    end;
  finally
    FreeAndNil(list);
  end;
end;

procedure TzViewerWordEditor.SalvaTemplateExecute(Sender: TObject);
begin
  doSalvaTemplate;
end;

procedure TzViewerWordEditor.SalvaTemplateUpdate(Sender: TObject);
begin
  SalvaTemplate.Enabled := dxRichEditControl.DocumentModelModified;
end;

procedure TzViewerWordEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ChiediSalvataggio;
end;

procedure TzViewerWordEditor.UpdateRibbonContexstsStates;
  procedure SetRibbonContext(Const RibbonContextName: string; Const visible: Boolean);
  var
    dxRibbonContext: TdxRibbonContext;
  begin
    dxRibbonContext := dxRibbon.Contexts.Find(RibbonContextName);

    if assigned(dxRibbonContext) then
      dxRibbonContext.visible := visible;
  end;

begin
  SetRibbonContext('Forme', dxRichEditControl.IsFloatingObjectSelected);
  SetRibbonContext('Header & Footer', dxRichEditControl.IsSelectionInHeaderOrFooter);
  SetRibbonContext('Table', dxRichEditControl.IsSelectionInTable);
  // SetRibbonContext('Mail Merge', true); // Config.IsAdmin); // { TODO : vedere }
end;

procedure TzViewerWordEditor.InitHints;
begin

  ForEach<TContainedAction>(
    procedure(Action: TContainedAction)
    begin
      Action.Hint := '';
    end);
end;

procedure TzViewerWordEditor.EditTemplateWord(Params: TWordParams);
var
  Options: IdxRichEditMailMergeOptions;
  Service: IdxUriStreamService;
  DataSet: TDataSet;
  Provider: TImageUriStreamProvider;
  DataSetNames: TStringList;
  I: Integer;
begin
  FParams.Assign(Params);

  Caption := Params.TemplateFileName;

  DataSetNames := TStringList.Create;
  try
    Params.GetDataSetList(DataSetNames);

    for I := 0 to DataSetNames.Count - 1 do
      DataSetNames[I] := DataSetNames.Names[I].Trim();

    edDatasets.Properties.Items.Assign(DataSetNames);
  finally
    FreeAndNil(DataSetNames);
  end;

  RiempiTreeFragments;
  SelezionaFragment(MasterInfo); // carica il master

  /// /////////////////////////////

  // https://docs.devexpress.com/WindowsForms/9709/controls-and-libraries/rich-text-editor/fields/field-codes

  // begin
  Provider := TImageUriStreamProvider.Create;
  Service := dxRichEditControl.DocumentModel.GetService<IdxUriStreamService>;
  Service.RegisterProvider(Provider);

  Provider.GetImageFunc := function(URI: string): TStream
    begin
      result := Params.GetImage(URI);
    end;

  if assigned(Params.OnGetImages) then
    Params.OnGetImages(Params.TemplateFileName, DataSource.DataSet, Provider);
  // end;

  dxRichEditControl.Options.MailMerge.ViewMergedData := false;
  dxRichEditControl.Options.MailMerge.ViewMergedData := true;

  AggiornaImmagini;
  /// /////////////////////////////

  dxRibbon.ActiveTab := dxRibbonTabFile;

  WindowState := wsMaximized;

  ShowModal;
end;

procedure TzViewerWordEditor.MailMergeExecute(Sender: TObject);
begin

  if CloseQuery then
    zOffice.MailMerge(Params);
end;

procedure TzViewerWordEditor.dxRichEditControlCalculateDocumentVariable(Sender: TObject; E: TdxCalculateDocumentVariableEventArgs);

  procedure EvalDataSetValue;
  var
    v: variant;
  begin
    E.Handled := Params.GetVariable(E.VariableName, v);

    if E.Handled then
      E.Value := TValue.FromVariant(v);
  end;

begin
  EvalDataSetValue;
end;

// ---------------------------------------------------------------------------
// Albero dei fragment
// ---------------------------------------------------------------------------

function TzViewerWordEditor.TemplateFolder: string;
begin
  // Un template nuovo non ha ancora un nome: IncludeTrailingPathDelimiter('')
  // darebbe '\' e il file finirebbe nella radice del disco.
  if Params.TemplateFileName.IsEmpty then
  begin
    if Params.DefaultFolder.IsEmpty then
      result := ''
    else
      result := IncludeTrailingPathDelimiter(Params.DefaultFolder);
  end
  else
    result := IncludeTrailingPathDelimiter(ExtractFilePath(Params.TemplateFileName));
end;

function TzViewerWordEditor.MasterInfo: TFragmentInfo;
var
  Info: TFragmentInfo;
begin
  result := nil;

  for Info in FFragmentInfos do
    if Info.IsMaster then
      exit(Info);
end;

function TzViewerWordEditor.TrovaInfoPerFile(const NomeFileSenzaEstensione: string): TFragmentInfo;
var
  Info: TFragmentInfo;
begin
  result := nil;

  for Info in FFragmentInfos do
    if SameText(Info.NomeFileSenzaEstensione, NomeFileSenzaEstensione) then
      exit(Info);
end;

function TzViewerWordEditor.TrovaInfoPerNome(const NomeVisualizzato: string): TFragmentInfo;
var
  Info: TFragmentInfo;
begin
  result := nil;

  for Info in FFragmentInfos do
    if SameText(Info.NomeVisualizzato, NomeVisualizzato) then
      exit(Info);
end;

function TzViewerWordEditor.InfoFocalizzato: TFragmentInfo;
begin
  result := nil;

  if assigned(treeFragments.FocusedNode) then
    result := TFragmentInfo(treeFragments.FocusedNode.Data);
end;

function TzViewerWordEditor.NodoDi(Info: TFragmentInfo): TcxTreeListNode;
var
  I: Integer;
begin
  result := nil;

  for I := 0 to treeFragments.AbsoluteCount - 1 do
    if treeFragments.AbsoluteItems[I].Data = Info then
      exit(treeFragments.AbsoluteItems[I]);
end;

// Dataset del fragment, con la stessa catena di ricerca del vecchio LoadFile:
// il nome dichiarato (JSON o separatore ~~~), poi il nome del file, poi il
// dataset corrente del chiamante.
function TzViewerWordEditor.RisolviDataSet(Info: TFragmentInfo): TDataSet;
begin
  result := nil;

  if not Info.NomeDataSet.IsEmpty then
    result := Params.GetDataSet(Info.NomeDataSet);

  if not assigned(result) then
    result := Params.GetDataSet(Info.NomeFileSenzaEstensione);

  if not assigned(result) then
    result := Params.GetDataSet('');
end;

procedure TzViewerWordEditor.RiempiTreeFragments;

  procedure AggiungiInfo(const NomeFileSenzaEstensione, NomeDataSet, NomeVariabile: string; const DaJson: Boolean);
  var
    Info: TFragmentInfo;
    NomeVisualizzato: string;
  begin
    NomeVisualizzato := TFragmentHelper.DataSetNameFromFileName(NomeFileSenzaEstensione);

    if NomeVisualizzato.IsEmpty then
      NomeVisualizzato := NomeFileSenzaEstensione;

    Info := TrovaInfoPerNome(NomeVisualizzato);

    if not assigned(Info) then
    begin
      Info := TFragmentInfo.Create;
      Info.NomeVisualizzato := NomeVisualizzato;
      Info.NomeFileSenzaEstensione := NomeFileSenzaEstensione;
      Info.IsMaster := false;
      FFragmentInfos.Add(Info);
    end;

    // la voce del JSON ha la precedenza sul file trovato su disco
    if DaJson or Info.NomeDataSet.IsEmpty then
      Info.NomeDataSet := NomeDataSet;

    if DaJson then
    begin
      Info.DaJson := true;
      Info.NomeVariabile := NomeVariabile;
      Info.NomeFileSenzaEstensione := NomeFileSenzaEstensione;
    end;

    Info.FileEsiste := FileExists(TemplateFolder + Info.NomeFileSenzaEstensione + '.docx');
  end;

  function DescrizioneDataSet(Info: TFragmentInfo): string;
  begin
    result := Info.NomeDataSet;

    if (not Info.IsMaster) and (not Info.NomeDataSet.IsEmpty) then
      if not assigned(Params.GetDataSet(Info.NomeDataSet)) then
        result := result + ' (dataset non trovato)';

    if not Info.FileEsiste then
      result := result + ' (file mancante)';
  end;

var
  Master: TFragmentInfo;
  Info: TFragmentInfo;
  DataSet: TDataSet;
  NomeFile: string;
  NomeDataSet: string;
  Frammento: TWordFragment;
  Radice: TcxTreeListNode;
  Nodo: TcxTreeListNode;
begin
  FCaricamentoInCorso := true;
  treeFragments.BeginUpdate;
  try
    treeFragments.Clear;
    FFragmentInfos.Clear;

    // master: la radice
    Master := TFragmentInfo.Create;
    Master.IsMaster := true;
    Master.NomeFileSenzaEstensione := FileNameNoExt(Params.TemplateFileName);
    if Master.NomeFileSenzaEstensione.IsEmpty then
      Master.NomeVisualizzato := 'Nuovo template'
    else
      Master.NomeVisualizzato := Master.NomeFileSenzaEstensione;
    Master.FileEsiste := FileExists(Params.TemplateFileName);

    DataSet := Params.GetDataSet(Master.NomeFileSenzaEstensione);
    if not assigned(DataSet) then
      DataSet := Params.GetDataSet('');
    if assigned(DataSet) then
      Master.NomeDataSet := DataSet.Name;

    FFragmentInfos.Add(Master);

    // fragment su disco (convenzione <master>~~~<dataset>.docx)
    if (not Params.TemplateFileName.IsEmpty) and TDirectory.Exists(TemplateFolder) then
      for NomeFile in TDirectory.GetFiles(TemplateFolder, TFragmentHelper.SearchPattern(Params.TemplateFileName)) do
        AggiungiInfo(FileNameNoExt(NomeFile), TFragmentHelper.DataSetNameFromFileName(FileNameNoExt(NomeFile)), '', false);

    // fragment dal JSON del report (Params.Fragments)
    for Frammento in Params.Fragments do
    begin
      NomeDataSet := Frammento.DataSetName;
      if NomeDataSet.IsEmpty then
        NomeDataSet := Frammento.VariableName;

      AggiungiInfo(FileNameNoExt(Frammento.TemplateFileName), NomeDataSet, Frammento.VariableName, true);
    end;

    // master primo, poi i fragment in ordine alfabetico
    FFragmentInfos.Sort(TComparer<TFragmentInfo>.Construct(
      function(const Sinistra, Destra: TFragmentInfo): Integer
      begin
        if Sinistra.IsMaster <> Destra.IsMaster then
          exit(Ord(Destra.IsMaster) - Ord(Sinistra.IsMaster));
        result := CompareText(Sinistra.NomeVisualizzato, Destra.NomeVisualizzato);
      end));

    Radice := nil;

    for Info in FFragmentInfos do
    begin
      if Info.IsMaster or (not assigned(Radice)) then
        Nodo := treeFragments.Add
      else
        Nodo := Radice.AddChild;

      Nodo.Texts[0] := Info.NomeVisualizzato;
      Nodo.Texts[1] := DescrizioneDataSet(Info);
      Nodo.Data := Info;

      if Info.IsMaster then
        Radice := Nodo;
    end;

    if assigned(Radice) then
      Radice.Expand(false);

    treeFragments.ApplyBestFit;
  finally
    treeFragments.EndUpdate;
    FCaricamentoInCorso := false;
  end;
end;

// Porta il fuoco sul nodo senza scatenare il caricamento
procedure TzViewerWordEditor.FocalizzaNodo(Info: TFragmentInfo);
var
  Nodo: TcxTreeListNode;
begin
  Nodo := NodoDi(Info);

  if not assigned(Nodo) then
    exit;

  FCaricamentoInCorso := true;
  try
    Nodo.Focused := true;
    Nodo.Selected := true;
    Nodo.MakeVisible;
  finally
    FCaricamentoInCorso := false;
  end;
end;

// Selezione da codice: fuoco sul nodo e caricamento diretto, senza passare
// dalla domanda di salvataggio (chi chiama l'ha gia' fatta)
procedure TzViewerWordEditor.SelezionaFragment(Info: TFragmentInfo);
begin
  if not assigned(Info) then
    exit;

  FocalizzaNodo(Info);
  CaricaFragment(Info);
end;

procedure TzViewerWordEditor.treeFragmentsFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
var
  Info: TFragmentInfo;
begin
  if FCaricamentoInCorso then
    exit;

  if not assigned(AFocusedNode) then
    exit;

  Info := TFragmentInfo(AFocusedNode.Data);

  if not assigned(Info) then
    exit;

  if SameText(Info.NomeFileSenzaEstensione, FNomeFileCaricato) then
    exit;

  if not ChiediSalvataggio then
  begin
    // annullato: il fuoco torna sul nodo di prima, il documento resta com'e'
    if assigned(APrevFocusedNode) and assigned(APrevFocusedNode.Data) then
      FocalizzaNodo(TFragmentInfo(APrevFocusedNode.Data));
    exit;
  end;

  CaricaFragment(Info);
end;

procedure TzViewerWordEditor.CaricaFragment(Info: TFragmentInfo);
var
  DataSet: TDataSet;
  NomeFileCompleto: string;
begin
  DataSet := RisolviDataSet(Info);

  if not assigned(DataSet) then
  begin
    ConfirmOk('Dataset non trovato per il template: ' + Params.TemplateFileName, mtWarning);
    exit;
  end;

  DataSource.DataSet := DataSet;

  // edDatasets e' il dataset dell'elenco campi: a ogni cambio di fragment
  // torna al dataset del fragment, la scelta manuale vale solo sul nodo corrente
  edDatasets.Text := DataSet.Name;
  FillTreeFields(DataSet);

  // Master di un template nuovo: nessun file su disco e nessun nome, il nome
  // lo sceglie l'utente al primo salvataggio ("Salva con nome").
  if Info.IsMaster and Params.TemplateFileName.IsEmpty then
  begin
    dxRichEditControl.Document.CreateNewDocument;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName := '';
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFormat := Params.DocumentFormat;
    dxRichEditControl.DocumentModelModified := false;
    FNomeFileCaricato := Info.NomeFileSenzaEstensione;
    Caption := 'Nuovo template';
    exit;
  end;

  NomeFileCompleto := TemplateFolder + Info.NomeFileSenzaEstensione + '.docx';

  if FileExists(NomeFileCompleto) then
  begin
    dxRichEditControl.Document.LoadDocument(NomeFileCompleto, Params.DocumentFormat);
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName := NomeFileCompleto;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFormat := dxRichEditControl.DocumentModel.AutodetectDocumentFormat(NomeFileCompleto);
    dxRichEditControl.Options.MailMerge.ViewMergedData := false;
    dxRichEditControl.Options.MailMerge.ViewMergedData := true;

    AggiornaImmagini;
  end
  else
  begin
    dxRichEditControl.Document.CreateNewDocument;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName := NomeFileCompleto;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFormat := Params.DocumentFormat;
  end;

  dxRichEditControl.DocumentModelModified := false;
  FNomeFileCaricato := Info.NomeFileSenzaEstensione;
  Caption := NomeFileCompleto;
end;

procedure TzViewerWordEditor.AggiungiFragmentExecute(Sender: TObject);
var
  DataSetName: string;
  NewFragmentFileName: string;
  NewFragmentFileNameNoExt: string;
  Folder: string;
  DocServer: TdxRichEditDocumentServer;
  frags: TArray<TWordFragment>;
  Added: Boolean;
begin
  if Params.TemplateFileName.IsEmpty then
  begin
    ConfirmOk('Salvare prima il template: i fragment si creano accanto al file del template.', mtInformation);
    exit;
  end;

  if not ChiediSalvataggio then
    exit;

  DataSetName := '';
  if not InputQuery('Nuovo Fragment', 'Inserisci il nome del Dataset / Variabile per il Fragment:', DataSetName) then
    exit;

  DataSetName := DataSetName.Trim;
  if DataSetName.IsEmpty then
  begin
    ConfirmOk('Nome dataset non valido.', mtWarning);
    exit;
  end;

  if assigned(TrovaInfoPerNome(DataSetName)) then
  begin
    ConfirmOk('Esiste gia'' un fragment con questo nome: ' + DataSetName, mtWarning);
    exit;
  end;

  Folder := TemplateFolder;
  NewFragmentFileName := '';
  Added := false;

  // Il chiamante, se c'e', decide il nome del file e aggiorna la configurazione (JSON)
  if assigned(Params.OnAddFragment) then
  begin
    try
      NewFragmentFileName := Params.OnAddFragment(DataSetName);
      if NewFragmentFileName <> '' then
        Added := true;
    except
      on E: Exception do
      begin
        ConfirmOk('Errore durante la creazione del fragment: ' + E.Message, mtError);
        exit;
      end;
    end;
  end;

  // Senza chiamante, o se non ha risposto: convenzione <master>~~~<dataset>.docx
  if NewFragmentFileName = '' then
  begin
    NewFragmentFileName := TFragmentHelper.FileName(Params.TemplateFileName, DataSetName);
    Added := true;
  end;

  if ExtractFilePath(NewFragmentFileName).IsEmpty then
    NewFragmentFileName := Folder + NewFragmentFileName;

  NewFragmentFileNameNoExt := FileNameNoExt(NewFragmentFileName);

  // documento Word vuoto, se non esiste gia'
  if not TFile.Exists(NewFragmentFileName) then
  begin
    DocServer := TdxRichEditDocumentServer.Create(nil);
    try
      DocServer.Document.CreateNewDocument;
      DocServer.SaveDocument(NewFragmentFileName, TdxRichEditDocumentFormat.OpenXML);
    finally
      DocServer.Free;
    end;
  end;

  if Added then
  begin
    frags := FParams.Fragments;
    SetLength(frags, Length(frags) + 1);
    frags[High(frags)].VariableName := DataSetName;
    frags[High(frags)].TemplateFileName := ExtractFileName(NewFragmentFileName);
    frags[High(frags)].DataSetName := DataSetName;
    FParams.Fragments := frags;
  end;

  RiempiTreeFragments;
  SelezionaFragment(TrovaInfoPerFile(NewFragmentFileNameNoExt));
end;

procedure TzViewerWordEditor.EliminaFragmentUpdate(Sender: TObject);
var
  Info: TFragmentInfo;
begin
  Info := InfoFocalizzato;
  EliminaFragment.Enabled := assigned(Info) and (not Info.IsMaster);
end;

procedure TzViewerWordEditor.EliminaFragmentExecute(Sender: TObject);
var
  Info: TFragmentInfo;
  NomeFileCompleto: string;
  Frammento: TWordFragment;
  Conservati: TArray<TWordFragment>;
  EraCaricato: Boolean;
  NomeFileCaricato: string;
begin
  Info := InfoFocalizzato;

  if (not assigned(Info)) or Info.IsMaster then
    exit;

  if not ConfirmYesNo(Format('Eliminare il fragment "%s"?'#13#10'Il file viene spostato nella cartella __backup.', [Info.NomeVisualizzato]), mtWarning) then
    exit;

  // 1. configurazione JSON del report (solo per i fragment che ne fanno parte)
  if Info.DaJson and assigned(Params.OnRemoveFragment) then
    if not Params.OnRemoveFragment(Info.NomeVariabile) then
    begin
      ConfirmOk('Il fragment non e'' stato tolto dalla configurazione JSON del report: eliminazione annullata.', mtError);
      exit;
    end;

  // 2. copia in memoria dei fragment
  Conservati := nil;
  for Frammento in FParams.Fragments do
    if not (SameText(Frammento.VariableName, Info.NomeVariabile) or SameText(FileNameNoExt(Frammento.TemplateFileName), Info.NomeFileSenzaEstensione)) then
      Conservati := Conservati + [Frammento];
  FParams.Fragments := Conservati;

  // 3. file su disco: archiviato in __backup, mai cancellato e basta
  NomeFileCompleto := TemplateFolder + Info.NomeFileSenzaEstensione + '.docx';

  if TzPercorsiLunghi.FileEsiste(NomeFileCompleto) then
  begin
    CopiaInBackup(NomeFileCompleto);
    if not System.SysUtils.DeleteFile(TzPercorsiLunghi.Esteso(NomeFileCompleto)) then
      RaiseLastOSError;
  end;

  // 4. albero: se era il fragment aperto, le sue modifiche vanno perse e si torna al master
  EraCaricato := SameText(Info.NomeFileSenzaEstensione, FNomeFileCaricato);
  NomeFileCaricato := FNomeFileCaricato;

  RiempiTreeFragments;

  if EraCaricato then
  begin
    dxRichEditControl.DocumentModelModified := false;
    FNomeFileCaricato := '';
    SelezionaFragment(MasterInfo);
  end
  else
    FocalizzaNodo(TrovaInfoPerFile(NomeFileCaricato));
end;

procedure TzViewerWordEditor.actApriTemplateExecute(Sender: TObject);
begin
  if not ChiediSalvataggio then
    exit;

  // Senza template corrente (nuovo) si parte dalla cartella dei report, non
  // dall'ultima cartella usata dal sistema.
  if Params.TemplateFileName.IsEmpty then
    dxOpenFileDialog.InitialDir := Params.DefaultFolder
  else
    dxOpenFileDialog.InitialDir := ExtractFilePath(Params.TemplateFileName);
  dxOpenFileDialog.FileName := Params.TemplateFileName;

  if dxOpenFileDialog.Execute then
  begin
    FParams.TemplateFileName := dxOpenFileDialog.FileName;
    FNomeFileCaricato := '';
    RiempiTreeFragments;
    SelezionaFragment(MasterInfo); // carica il master
  end;
end;

// ---------------------------------------------------------------------------
// Campi e immagini
// ---------------------------------------------------------------------------

procedure TzViewerWordEditor.edDatasetsPropertiesEditValueChanged(Sender: TObject);
var
  DataSetName: string;
  DataSet: TDataSet;
begin
  DataSetName := edDatasets.Text;
  DataSet := Params.GetDataSet(DataSetName);

  if assigned(DataSet) then
    FillTreeFields(DataSet);
end;

function TzViewerWordEditor.GetField(DataSet: TDataSet; const VariableName: string): TField;
var
  Variable: TzOfficeVariable;
begin
  result := nil;

  Variable.Init(VariableName);

  if assigned(DataSet) then
    if not Variable.DataSetName.IsEmpty then
      if not SameText(Variable.DataSetName, DataSet.Name) then
        DataSet := nil;

  if not assigned(DataSet) then
    DataSet := Params.GetDataSet(Variable.DataSetName);

  if assigned(DataSet) then
    result := DataSet.FindField(Variable.FieldName);
end;

function TzViewerWordEditor.ShowModal: Integer;
begin
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  result := inherited ShowModal;
end;

procedure TzViewerWordEditor.treeFieldsColumnFieldValueGetEditProperties(Sender: TcxTreeListColumn; ANode: TcxTreeListNode; var EditProperties: TcxCustomEditProperties);
var
  Field: TField;
begin
  EditProperties := cxEditRepositoryTextItem.Properties;

  if assigned(ANode.Data) then
    if TObject(ANode.Data) is TField then
    begin
      Field := TField(ANode.Data);

      if Field is TBooleanField then
        EditProperties := cxEditRepositoryCheckBoxItem.Properties
      else
        if Field is TMemoField then
          EditProperties := cxEditRepositoryMemoItem.Properties
        else
          if Field.IsBlob and (TBlobField(Field).BlobType = ftGraphic) then // Base può non assegnarli come TGraphicField
            EditProperties := cxEditRepositoryImageItem.Properties;
    end;
end;

// Riduce al vivo pagina le immagini troppo larghe e riapplica le misure salvate
// nel suffisso @L:A dei campi INCLUDEPICTURE (vedi TzWordImmagini)
procedure TzViewerWordEditor.AggiornaImmagini;
begin
  TzWordImmagini.RiduciAlVivoPagina(dxRichEditControl.Document);
  TzWordImmagini.ApplicaDimensioni(dxRichEditControl.Document);
end;

// Il toggle standard di DevExpress aggiorna i campi e riporta le immagini alla
// misura naturale: qui si riapplicano subito le misure salvate.
procedure TzViewerWordEditor.MostraDatiUnitiExecute(Sender: TObject);
begin
  dxRichEditControl.Options.MailMerge.ViewMergedData := not dxRichEditControl.Options.MailMerge.ViewMergedData;

  if dxRichEditControl.Options.MailMerge.ViewMergedData then
    AggiornaImmagini;
end;

procedure TzViewerWordEditor.MostraDatiUnitiUpdate(Sender: TObject);
begin
  MostraDatiUniti.Checked := dxRichEditControl.Options.MailMerge.ViewMergedData;
end;

procedure TzViewerWordEditor.AddSelectedField;
  function BeginUpdate(Header, Footer: Boolean): IdxRichEditSubDocument;
  begin
    if Header then
      result := dxRichEditControl.Document.Sections[0].BeginUpdateHeader()
    else
      if Footer then
        result := dxRichEditControl.Document.Sections[0].BeginUpdateFooter()
      else
        result := dxRichEditControl.Document;
  end;

  procedure EndUpdate(SubDoc: IdxRichEditSubDocument; Header, Footer: Boolean);
  begin
    if Header then
      dxRichEditControl.Document.Sections[0].EndUpdateHeader(SubDoc)
    else
      if Footer then
        dxRichEditControl.Document.Sections[0].EndUpdateFooter(SubDoc);
  end;

var
  Header, Footer: Boolean;
  ASubDocument: IdxRichEditSubDocument;
  APos: IdxRichEditDocumentPosition;
  AField: IdxRichEditField;
  DataSetName: string;
  FieldName: string;
  Field: TField;
begin

  if treeFields.SelectionCount = 0 then
    exit;

  if TObject(treeFields.Selections[0].Data) is TField then
  begin
    Field := TField(treeFields.Selections[0].Data);
    DataSetName := edDatasets.Text; // deve contenere anche il nome del datamodule Field.DataSet.Name;
    FieldName := Field.FieldName;
  end
  else
  begin
    Field := nil;
    DataSetName := edDatasets.Text;
    FieldName := treeFields.Selections[0].Values[0];
  end;

  DataSetName := Params.GetDataSetName(DataSetName);

  if not DataSetName.IsEmpty then
    FieldName := DataSetName + '.' + FieldName;

  /// /////////////////////////////////////////////////////////////

  Header := dxRichEditControl.IsSelectionInHeader;
  Footer := dxRichEditControl.IsSelectionInFooter;

  ASubDocument := BeginUpdate(Header, Footer);
  try
    APos := dxRichEditControl.Document.CaretPosition;

    if dxRichEditControl.Document.Selections.Count > 0 then
      ASubDocument.Delete(dxRichEditControl.Document.Selection);

    if assigned(Field) and Field.IsBlob and (TBlobField(Field).BlobType = ftGraphic) then
    begin
      AField := ASubDocument.Fields.CreateField(APos, 'INCLUDEPICTURE dbimg://"' + FieldName + '"');
      AField.Update;
    end
    else
    begin
      AField := ASubDocument.Fields.CreateField(APos, 'DOCVARIABLE ' + FieldName);
      AField.Update;
    end;
  finally
    EndUpdate(ASubDocument, Header, Footer);
  end;
end;

procedure TzViewerWordEditor.HiddenFieldsExecute(Sender: TObject);
begin
  ShowHiddenFields(HiddenFields.Checked);
end;

procedure TzViewerWordEditor.ShowHiddenFields(const visible: Boolean);
var
  I: Integer;
  Field: IdxRichEditField;
  ARange: IdxRichEditDocumentRange;
  ACharProperties: IdxRichEditCharacterProperties;
  code: string;
begin

  for I := 0 to dxRichEditControl.Document.Fields.Count - 1 do
  begin
    Field := dxRichEditControl.Document.Fields[I];
    ARange := Field.CodeRange;
    code := dxRichEditControl.Document.GetText(ARange);

    if code.Contains('@hidden') then
    begin
      ACharProperties := dxRichEditControl.Document.BeginUpdateCharacters(Field.Range);

      if visible then
      begin
        ACharProperties.ForeColor := TdxAlphaColors.Red;
        ACharProperties.FontSize := 11;
      end
      else
      begin
        ACharProperties.ForeColor := TdxAlphaColors.White;
        ACharProperties.FontSize := 3;
      end;

      dxRichEditControl.Document.EndUpdateCharacters(ACharProperties);
    end;
  end;
end;

end.
