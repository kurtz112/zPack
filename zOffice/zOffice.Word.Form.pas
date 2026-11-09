unit zOffice.Word.Form;

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
  dxCore,
  dxCoreClasses,
  cxGraphics,
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
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  cxFontNameComboBox,
  cxDropDownEdit,
  dxRichEdit.Actions,
  dxActions,
  dxPrinting,
  dxBar,
  dxRibbon,
  dxGallery,
  dxRibbonGallery,
  dxRibbonColorGallery,
  cxBarEditItem,
  cxClasses,
  cxImageList,
  dxRichEdit.Platform.Win.Control,
  dxRichEdit.Control.Core,
  dxRibbonForm,
  dxStatusBar,
  dxRibbonStatusBar,
  cxContainer,
  cxEdit,
  cxTrackBar,
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
  cxDrawTextUtils,
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
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTextEdit,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  dxPScxTLLnk,
  dxPScxSchedulerLnk,
  dxPSdxSpreadSheetLnk,
  cxFilter,
  dxPSdxPDFViewerLnk,
  dxPrnDlg,
  zOffice.Types,
  zOffice.Reports.Controller, // TzAzioneDocumento
  zOffice.Reports.ActionsBarHelper, // TzDocumentActionsBarHelper
  dxPScxEditorLnks,
  dxUIAClasses;

type
  TzViewerWordForm = class(TdxRibbonForm)
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

    dxRichEditControlNewDocument: TdxRichEditControlNewDocument;
    dxRibbonTabFile: TdxRibbonTab;
    dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument;
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
    dxBarButton1: TdxBarButton;
    actExportPDF: TAction;
    dxBarLargeButton1: TdxBarLargeButton;
    dxSaveFileDialogPDF: TdxSaveFileDialog;
    dxBarManagerBar1: TdxBar;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxRichEditControlShowMergeDatabaseRecordsForm: TdxRichEditControlShowMergeDatabaseRecordsForm;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarManagerBarQuickAccess: TdxBar;
    dxBarManagerBar4: TdxBar;
    dxBarLargeButton12: TdxBarLargeButton;
    ActionList: TActionList;
    actSalvaConNome: TAction;
    dxBarLargeButton13: TdxBarLargeButton;
    actShellExecute: TAction;
    dxBarButton2: TdxBarButton;
    ApriCartella: TAction;
    dxBarLargeButton19: TdxBarLargeButton;
    actPoliticheAccessi: TAction;
    actRicaricaPolitiche: TAction;
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
    dxRichEditControl: TdxRichEditControl;
    PrinterLink: TdxRichEditControlReportLink;
    dxBarLargeButton5: TdxBarLargeButton;
    dxSaveFileDialogDocx: TdxSaveFileDialog;
    actSalva: TAction;
    dxBarLargeButton6: TdxBarLargeButton;
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
    dxBarLargeButton4: TdxBarLargeButton;
    procedure actDocGeneraAllegatoExecute(Sender: TObject);
    procedure actDocGeneraAllegatoUpdate(Sender: TObject);
    procedure actExportPDFExecute(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure dxRichEditControlActiveViewChanged(Sender: TObject);
    procedure dxRichEditControlContentChanged(Sender: TObject);
    procedure dxRichEditControlSelectionChanged(Sender: TObject);
    procedure dxRichEditControlZoomChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actSalvaConNomeExecute(Sender: TObject);
    procedure tbZoomPropertiesChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ElencoCampiUtilizzatiExecute(Sender: TObject);
    procedure dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
    procedure actSalvaExecute(Sender: TObject);
    procedure actSalvaUpdate(Sender: TObject);

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
    FParams: TWordParams;
    FAzioniDocumento: TzDocumentActionsBarHelper;
    procedure UpdateZoom;
    procedure ImagesResize;
    procedure UpdateRibbonContexstsStates;
    procedure InitHints;
  private
    function GetFileNamePDF: string;
  private
    function doSalva: Boolean;
    function doSalvaConNome: Boolean;
  public
    constructor Create(aOwner: TComponent); Override;
  public

    procedure ShowFile(Params: TWordParams); overload;
    procedure ShowFile(Stream: TStream; Params: TWordParams); overload;

    procedure LoadFile(const FileName: string; DocumentFormat: TdxRichEditDocumentFormat = TdxRichEditDocumentFormat.OpenXML);
    procedure ExportPDF(const FileNamePdf: String; const silent: Boolean = false);
    function ShowModal: Integer; override;
    property FileName: string read FFileName write FFileName;
    property Params: TWordParams read FParams;
  end;

procedure ViewFileWord(Params: TWordParams); overload;
procedure ViewFileWord(Stream: TStream; Params: TWordParams); overload;

implementation

uses
  Winapi.ShlObj,
  Winapi.ShellAPI,
  System.Rtti,
  System.IOUtils,
  Vcl.Clipbrd,
  dxRichEdit.DocumentModel.RichEditDocumentServer,
  cxGeometry,
  zz.Vcl,
  zdx,
  zBaseLib,
  zMsg,
  zOffice.Word.Utils,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  zz.Folders;

{$R *.dfm}

type
  TdxRichEditControlAccess = class(TdxRichEditControl);

procedure ViewFileWord(Params: TWordParams);
var
  zViewerWordForm: TzViewerWordForm;
begin
  Application.CreateForm(TzViewerWordForm, zViewerWordForm);
  try
    zViewerWordForm.ShowFile(Params);
  finally
    FreeAndNil(zViewerWordForm);
  end;
end;

procedure ViewFileWord(Stream: TStream; Params: TWordParams);
var
  zViewerWordForm: TzViewerWordForm;
begin
  Application.CreateForm(TzViewerWordForm, zViewerWordForm);
  try
    zViewerWordForm.ShowFile(Stream, Params);
  finally
    FreeAndNil(zViewerWordForm);
  end;
end;

constructor TzViewerWordForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FFileName := '';
  FParams.Init;

  dx.InitPrinter(Printer);

  WindowState := wsMaximized;
end;

procedure TzViewerWordForm.actDocGeneraAllegatoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoGeneraAllegato;
end;

procedure TzViewerWordForm.actDocGeneraAllegatoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoGeneraAllegato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerWordForm.UpdateZoom;
begin
  if dxRichEditControl.ActiveView.ZoomFactor > 5 then
    dxRichEditControl.ActiveView.ZoomFactor := 5;
  tbZoom.Position := Round(dxRichEditControl.ActiveView.ZoomFactor * 100);
end;

procedure TzViewerWordForm.tbZoomPropertiesChange(Sender: TObject);
begin
  bsZoom.Caption := Format('%3d %%', [tbZoom.Position]);
  dxRichEditControl.ActiveView.ZoomFactor := tbZoom.Position / 100;
end;

procedure TzViewerWordForm.dxRichEditControlActiveViewChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerWordForm.dxRichEditControlZoomChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerWordForm.dxRichEditControlContentChanged(Sender: TObject);
begin
  // bbCursorLine.Caption := 'Linea: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Row.LineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' +   dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Column.colLineNumber.ToString;
end;

procedure TzViewerWordForm.dxRichEditControlSelectionChanged(Sender: TObject);
begin
  UpdateRibbonContexstsStates;
  // bbCursorLine.Caption := 'Linea: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Row.LineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.Column.colLineNumber.ToString;
  // bbCursorColumn.Caption := 'Colonna: ' + dxRichEditControl.ActiveView.CaretPosition.LayoutPosition.LeftOffset.ToString;
end;

procedure TzViewerWordForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerWordForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerWordForm.dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin
  dx.dxBarAssignPopupMenu(ABar, popActions);
end;

procedure TzViewerWordForm.ElencoCampiUtilizzatiExecute(Sender: TObject);
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
      Clipboard.AsText := list.text;
      ConfirmOk(list.text, mtInformation);
    end;
  finally
    FreeAndNil(list);
  end;
end;

procedure TzViewerWordForm.ImagesResize;
begin
  // stessa procedura condivisa di editor e motore di stampa unione
  TzWordImmagini.RiduciAlVivoPagina(dxRichEditControl.Document);
  TzWordImmagini.ApplicaDimensioni(dxRichEditControl.Document);
end;

procedure TzViewerWordForm.UpdateRibbonContexstsStates;
  procedure SetRibbonContext(Const RibbonContextName: string; Const Visible: Boolean);
  var
    dxRibbonContext: TdxRibbonContext;
  begin
    dxRibbonContext := dxRibbon.Contexts.Find(RibbonContextName);

    if assigned(dxRibbonContext) then
      dxRibbonContext.Visible := Visible;
  end;

begin
  SetRibbonContext('Forme', dxRichEditControl.IsFloatingObjectSelected);
  SetRibbonContext('Header & Footer', dxRichEditControl.IsSelectionInHeaderOrFooter);
  SetRibbonContext('Table', dxRichEditControl.IsSelectionInTable);
end;

procedure TzViewerWordForm.InitHints;
begin

  ForEach<TContainedAction>(
    procedure(Action: TContainedAction)
    begin
      Action.Hint := '';
    end);
end;

procedure TzViewerWordForm.LoadFile(const FileName: string; DocumentFormat: TdxRichEditDocumentFormat = TdxRichEditDocumentFormat.OpenXML);
begin

  if FileExists(FileName) then
  begin
    dxRichEditControl.LoadDocument(FileName, DocumentFormat);
    FFileName := FileName;
    Caption := FileName;
  end;
end;

procedure TzViewerWordForm.ShowFile(Params: TWordParams);
begin
  FParams.Assign(Params);

  LoadFile(Params.FileName, Params.DocumentFormat);

  if assigned(Params.BeforeShowProc) then
  begin
    try
      Params.BeforeShowProc(Params.TemplateFileName, dxRichEditControl);
    except
      on E: Exception do
        Application.HandleException(E);
    end;
  end;

  ImagesResize;

  dxRichEditControl.ReadOnly := Params.ReadOnly;

  ShowModal;
end;

procedure TzViewerWordForm.ShowFile(Stream: TStream; Params: TWordParams);
begin
  FParams.Assign(Params);

  Caption := '';

  FileName := Params.FileName;

  if assigned(Stream) then
  begin
    Stream.Position := 0;
    dxRichEditControl.LoadDocument(Stream, Params.DocumentFormat);
  end;

  if assigned(Params.BeforeShowProc) then
  begin
    try
      Params.BeforeShowProc(Params.TemplateFileName, dxRichEditControl);
    except
      on E: Exception do
        Application.HandleException(E);
    end;
  end;

  // ci deve pensare MailMerge
  // ImagesRepositioning;
  // ImagesResize;

  dxRichEditControl.ReadOnly := Params.ReadOnly;

  ShowModal;
end;

procedure TzViewerWordForm.actShellExecuteExecute(Sender: TObject);
begin

  if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
    if doSalva then
      ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerWordForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;

  if dxRichEditControl.DocumentModelModified then
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

procedure TzViewerWordForm.actSalvaExecute(Sender: TObject);
begin
  doSalva;
end;

procedure TzViewerWordForm.actSalvaUpdate(Sender: TObject);
begin
  actSalva.Enabled := (not FileName.IsEmpty) and dxRichEditControl.DocumentModelModified;
end;

procedure TzViewerWordForm.actSalvaConNomeExecute(Sender: TObject);
begin
  doSalvaConNome;
end;

function TzViewerWordForm.doSalva: Boolean;
begin
  result := true;

  if FileName.IsEmpty then
    result := doSalvaConNome
  else
  begin
    dxRichEditControl.SaveDocument(FileName);
    dxRichEditControl.DocumentModelModified := false;
  end;
end;

function TzViewerWordForm.doSalvaConNome: Boolean;
begin
  dxSaveFileDialogDocx.FileName := FileName;
  // vale quando FileName non ha percorso: altrimenti Windows apre la cartella del documento
  dxSaveFileDialogDocx.InitialDir := TFolders.UserDocumentsFolder;

  result := dxSaveFileDialogDocx.Execute(Self.Handle);

  if result then
  begin
    FileName := dxSaveFileDialogDocx.FileName;
    doSalva;
    Caption := FileName;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFileName := FileName;
    dxRichEditControl.Options.DocumentSaveOptions.CurrentFormat := dxRichEditControl.DocumentModel.AutodetectDocumentFormat(FileName);
  end;
end;

procedure TzViewerWordForm.actExportPDFExecute(Sender: TObject);
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

// ---------------------------------------------------------------------------
// Azioni documentali: handler condivisi dalle TAction del gruppo "Documento"
// ---------------------------------------------------------------------------

procedure TzViewerWordForm.AzioneDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag), TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerWordForm.AzioneDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag));
end;

procedure TzViewerWordForm.AggiornaStatoDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoAggiornaStato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerWordForm.AggiornaStatoDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoAggiornaStato;
end;

procedure TzViewerWordForm.VersioniDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoVersioni(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := false;
end;

procedure TzViewerWordForm.VersioniDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoVersioni;
end;

function TzViewerWordForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabFile;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore

  // gruppo "Documento" a mano nel DFM (TdxBar + bottoni + TAction): qui
  // riceviamo dal ReportsManager l'helper da agganciare all'OnUpdate/OnExecute
  // di quelle azioni. nil = azioni non configurate -> nascondi il gruppo.
  // (fase G3: rimosse le vecchie bar Firma/InviaMail e le relative closure di
  // TWordParams — le azioni passano dal controller)
  FAzioniDocumento := nil;
  if assigned(Params.OnSetupAzioniDocumento) then
    FAzioniDocumento := Params.OnSetupAzioniDocumento(Self,
      function: string
      begin
        result := TPath.ChangeExtension(TPath.GetTempFileName, '.pdf');
        ExportPDF(result, true);
      end);

  // il Tag e la caption iniziale delle azioni li imposta l'helper, per nome,
  // sull'ActionList: nessun Tag "magico" nel DFM
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.InizializzaAzioniDocumento(ActionList);

  barDocumento.Visible := assigned(FAzioniDocumento);

  // Niente piu' dxPrintDevice.ColorMode := true qui (era una richiesta CAPAC): toccare
  // dxPrintDevice all'apertura fa elencare le stampanti e aprire la predefinita, e con
  // una stampante di rete lenta l'anteprima del contratto tardava ad aprirsi. Il colore
  // comunque non arrivava alla stampa: Print e Preview di TdxComponentPrinter chiamano
  // InitDevModeFromPrinterPageSettings, che rimette dmColor da PrinterPage.GrayShading
  // (True nel .dfm, quindi bianco e nero). Se serve il colore, e' GrayShading a deciderlo.

  result := inherited ShowModal;

  // il ShowModal della VCL, alla chiusura, rimette il cursore salvato all'apertura:
  // se nel frattempo la stampa ha lasciato la clessidra (contatore globale di
  // ExpressPrinting) la si toglie qui, prima di tornare alla form chiamante
  Screen.Cursor := crDefault;
end;

function TzViewerWordForm.GetFileNamePDF: string;
var
  DataSet: TDataSet;
  Field: TField;
begin
  result := '';

  Field := Nil;
  DataSet := Nil;

  case Params.Pdf.Method of
    mgfDialog:
      begin
        dxSaveFileDialogPDF.FilterIndex := Ord(Params.Pdf.FontEmbedding) + 1; //

        // dxSaveFileDialogPDF.FileName := FileNamePdf;
        dxSaveFileDialogPDF.InitialDir := TFolders.UserDocumentsFolder;

        if not dxSaveFileDialogPDF.Execute(Self.Handle) then
          exit;

        result := dxSaveFileDialogPDF.FileName;

        FParams.ReadOnly := true;
        case dxSaveFileDialogPDF.FilterIndex of
          1:
            FParams.Pdf.FontEmbedding := zfeNone;
          2:
            FParams.Pdf.FontEmbedding := zfeFull;
          3:
            FParams.Pdf.FontEmbedding := zfeSubset;
          4:
            FParams.Pdf.FontEmbedding := zfeSubset;
        else
          FParams.Pdf.FontEmbedding := zfeSubset;
        end;
      end;
    mgfFileName:
      begin
        result := Params.Pdf.FileName;
      end;
    mgfFieldName:
      begin
        DataSet := Params.GetDataSet('');

        if assigned(DataSet) then
          Field := DataSet.FindField(Params.Pdf.FieldName);

        if assigned(Field) then
          result := ChangeFileExt(Field.AsString, '.pdf');
      end;
    mgfTempFile:
      begin
        result := TPath.ChangeExtension(TPath.GetTempFileName, '.pdf');
      end;
  end;

  // un nome senza percorso finirebbe nella cartella corrente, cioe' quella dell'eseguibile
  if (result <> '') and (ExtractFilePath(result) = '') then
    result := TFolders.UserDocumentsFolder + result;
end;

procedure TzViewerWordForm.ExportPDF(const FileNamePdf: String; const silent: Boolean = false);
var
  Options: TdxPSPDFReportExportOptions;
  FileName: string;

  function GetFileName: string;
  begin
    result := FileNamePdf;

    if result.IsEmpty then
      result := GetFileNamePDF;
  end;

begin

  FileName := GetFileName;
  try
    if FileName.IsEmpty then
      exit;

    try
      ForceDirectories(ExtractFilePath(FileName));
    except
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
      Options.DefaultFileName := FileName;
      Options.OpenDocumentAfterExport := false; //
      // Options.SecurityOptions
      // Options.SignatureOptions

      Options.EmbedFonts := Params.Pdf.FontEmbedding in [zfeFull, zfeSubset];
      Options.UseCIDFonts := Params.Pdf.FontEmbedding = zfeSubset;
      Options.UseJPEGCompression := true;

      StartWait('Attendere...', true);
      try
        Printer.ExportToPDF(FileName, false, Options);

        if assigned(Params.Pdf.AfterExportProc) then
          Params.Pdf.AfterExportProc(FileName);
      finally
        StopWait;
      end;
    finally
      FreeAndNil(Options);
    end;

    ///
    if (Params.Pdf.OpenFileAfterExport) and (Params.Pdf.Method <> mgfTempFile) then
    begin
      if ConfirmYesNo('Si desidera aprire il file ' + FileName + '?', mtWarning) then
        ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
    end
    else
      if not silent then // pilotato dall'export temporaneo delle azioni documentali
        if Params.Pdf.ShowMessageAfterExport then
          ConfirmOk('File pdf generato.', mtInformation);
  finally
    // verificare con il
    if Params.Pdf.Method = mgfTempFile then
      TFile.Delete(FileName);
  end;
end;

end.



