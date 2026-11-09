unit dxItalian;

interface

procedure dxLocalizeITA;

implementation

uses
  dxCore,
  dxBarDBNavStrs,
  dxBarStrs,
  cxDataConsts,
  cxFilterConsts,
  dxDockConsts,
  cxEditConsts,
  cxExtEditConsts,
  cxFilterControlStrs,
  cxExportStrs,
  dxFcStrs,
  dxLayoutStrs,
  cxLibraryStrs,
  dxNavBarConsts,
  dxorgchrstrs,
  cxPCConsts,
  cxPivotGridStrs,
  dxPSRes,
  cxGridPopupMenuConsts,
  cxGridStrs,
  cxTLStrs,
  cxSchedulerStrs,
  dxSpellCheckerStrs,
  dxSpreadSheetActionsStrs,
  dxSpreadSheetDialogStrs,
  dxSpreadSheetStrs,
  cxVGridConsts,
  dxWizardControlStrs,
  dxPDFCommandConstructor,
  dxPDFDocumentStrs,
  dxPDFStreamFilter,
  dxPDFViewerActionsStrs,
  dxPDFViewerDialogsStrs,
  dxCustomPreviewStrs;

procedure cxLocalizeFilter;
begin
  // cxFilterConsts
  cxSetResourceString(@cxSFilterOperatorEqual, 'uguale');
  cxSetResourceString(@cxSFilterOperatorNotEqual, 'diverso');
  cxSetResourceString(@cxSFilterOperatorLess, 'minore di ');
  cxSetResourceString(@cxSFilterOperatorLessEqual, 'minore o uguale di');
  cxSetResourceString(@cxSFilterOperatorGreater, 'maggiore di ');
  cxSetResourceString(@cxSFilterOperatorGreaterEqual, 'maggiore o uguale di');
  cxSetResourceString(@cxSFilterOperatorLike, 'contiene');
  cxSetResourceString(@cxSFilterOperatorNotLike, 'non contiene');
  cxSetResourceString(@cxSFilterOperatorBetween, 'compreso tra');
  cxSetResourceString(@cxSFilterOperatorNotBetween, 'non compreso tra');
  cxSetResourceString(@cxSFilterOperatorInList, 'in');
  cxSetResourceString(@cxSFilterOperatorNotInList, 'non in');

  cxSetResourceString(@cxSFilterOperatorYesterday, 'è ieri');
  cxSetResourceString(@cxSFilterOperatorToday, 'è oggi');
  cxSetResourceString(@cxSFilterOperatorTomorrow, 'è domani');

  cxSetResourceString(@cxSFilterOperatorLast7Days, 'negli ultimi 7 giorni');
  cxSetResourceString(@cxSFilterOperatorLastWeek, 'la scorsa settimana');
  cxSetResourceString(@cxSFilterOperatorLast14Days, 'negli ultimi 14 giorni');
  cxSetResourceString(@cxSFilterOperatorLastTwoWeeks, 'nelle ultime due settimane');
  cxSetResourceString(@cxSFilterOperatorLast30Days, 'negli ultimi 30 giorni');
  cxSetResourceString(@cxSFilterOperatorLastMonth, 'nell''ultimo mese');
  cxSetResourceString(@cxSFilterOperatorLastYear, 'nell''ultimo anno');
  cxSetResourceString(@cxSFilterOperatorPast, 'nel passato');

  cxSetResourceString(@cxSFilterOperatorThisWeek, 'è questa settimana');
  cxSetResourceString(@cxSFilterOperatorThisMonth, 'è questo mese');
  cxSetResourceString(@cxSFilterOperatorThisYear, 'è questo anno');

  cxSetResourceString(@cxSFilterOperatorNext7Days, 'negli ultimi 7 giorni');
  cxSetResourceString(@cxSFilterOperatorNextWeek, 'è la prossima settimana');
  cxSetResourceString(@cxSFilterOperatorNext14Days, 'nei prossimi 14 giorni');
  cxSetResourceString(@cxSFilterOperatorNextTwoWeeks, 'nelle prossime due settimane');
  cxSetResourceString(@cxSFilterOperatorNext30Days, 'nei prossimi 30 giorni');
  cxSetResourceString(@cxSFilterOperatorNextMonth, 'il prossimo mese');
  cxSetResourceString(@cxSFilterOperatorNextYear, 'il prossimo anno');
  cxSetResourceString(@cxSFilterOperatorFuture, 'nel futuro');

  cxSetResourceString(@cxSFilterAndCaption, 'e');
  cxSetResourceString(@cxSFilterOrCaption, 'o');
  cxSetResourceString(@cxSFilterNotCaption, 'non');
  cxSetResourceString(@cxSFilterBlankCaption, 'vuoto');

  // derived
  cxSetResourceString(@cxSFilterOperatorIsNull, 'è vuoto');
  cxSetResourceString(@cxSFilterOperatorIsNotNull, 'non è vuoto');
  cxSetResourceString(@cxSFilterOperatorBeginsWith, 'inizia con');
  cxSetResourceString(@cxSFilterOperatorDoesNotBeginWith, 'non inizia con');
  cxSetResourceString(@cxSFilterOperatorEndsWith, 'finisce con');
  cxSetResourceString(@cxSFilterOperatorDoesNotEndWith, 'non finisce con');
  cxSetResourceString(@cxSFilterOperatorContains, 'contiene');
  cxSetResourceString(@cxSFilterOperatorDoesNotContain, 'non contiene');

  // filter listbox's values
  cxSetResourceString(@cxSFilterBoxAllCaption, '(Tutti)');
  cxSetResourceString(@cxSFilterBoxCustomCaption, '(Custom...)');
  cxSetResourceString(@cxSFilterBoxBlanksCaption, '(Vuoto)');
  cxSetResourceString(@cxSFilterBoxNonBlanksCaption, '(Non vuoto)');

  /// //////////////////////////////////////////////////
  // cxFilterBoolOperator
  cxSetResourceString(@cxSFilterBoolOperatorAnd, 'AND'); // all
  cxSetResourceString(@cxSFilterBoolOperatorOr, 'OR'); // any
  cxSetResourceString(@cxSFilterBoolOperatorNotAnd, 'NOT AND'); // not all
  cxSetResourceString(@cxSFilterBoolOperatorNotOr, 'NOT OR'); // not any
  //
  cxSetResourceString(@cxSFilterRootButtonCaption, 'Filtro');
  cxSetResourceString(@cxSFilterAddCondition, 'Aggiungi &Condizione');
  cxSetResourceString(@cxSFilterAddGroup, 'Aggiungi &Gruppo');
  cxSetResourceString(@cxSFilterRemoveRow, '&Rimuovi Riga');
  cxSetResourceString(@cxSFilterClearAll, 'Rimuovi &Tutto');
  cxSetResourceString(@cxSFilterFooterAddCondition, 'premere il bottone per aggiungere una nuova condizione');

  cxSetResourceString(@cxSFilterGroupCaption, 'applica le seguenti condizioni');
  cxSetResourceString(@cxSFilterRootGroupCaption, '<root>');
  cxSetResourceString(@cxSFilterControlNullString, '<vuoto>');

  cxSetResourceString(@cxSFilterErrorBuilding, 'Can''t build filter from source');

  // FilterDialog
  cxSetResourceString(@cxSFilterDialogCaption, 'Filtro personalizzato');
  cxSetResourceString(@cxSFilterDialogInvalidValue, 'Valore non valido');
  cxSetResourceString(@cxSFilterDialogUse, 'Usare');
  cxSetResourceString(@cxSFilterDialogSingleCharacter, 'per rappresentare un singolo carattere');
  cxSetResourceString(@cxSFilterDialogCharactersSeries, 'per rappresentare una serie di caratteri');
  cxSetResourceString(@cxSFilterDialogOperationAnd, 'AND');
  cxSetResourceString(@cxSFilterDialogOperationOr, 'OR');
  cxSetResourceString(@cxSFilterDialogRows, 'Mostra le righe dove:');

  // FilterControlDialog
  cxSetResourceString(@cxSFilterControlDialogCaption, 'Filter builder');
  cxSetResourceString(@cxSFilterControlDialogNewFile, 'untitled.flt');
  cxSetResourceString(@cxSFilterControlDialogOpenDialogCaption, 'Open an existing filter');
  cxSetResourceString(@cxSFilterControlDialogSaveDialogCaption, 'Salva il filtro attivo su file');
  cxSetResourceString(@cxSFilterControlDialogActionSaveCaption, '&Salva...');
  cxSetResourceString(@cxSFilterControlDialogActionSaveHint, 'Save As|Saves the active filter with a new name');
  cxSetResourceString(@cxSFilterControlDialogActionOpenCaption, '&Apri...');
  cxSetResourceString(@cxSFilterControlDialogActionOpenHint, 'Open|Opens an existing filter');
  cxSetResourceString(@cxSFilterControlDialogActionApplyCaption, '&Applica');
  cxSetResourceString(@cxSFilterControlDialogActionOkCaption, 'OK');
  cxSetResourceString(@cxSFilterControlDialogActionCancelCaption, 'Annulla');
  cxSetResourceString(@cxSFilterControlDialogFileExt, 'flt');
  cxSetResourceString(@cxSFilterControlDialogFileFilter, 'Filtri (*.flt)|*.flt');
end;

procedure cxLocalizeGrid;
begin
  // cxGridStrs

  cxSetResourceString(@scxGridDeletingFocusedConfirmationText, 'Elimino il record?');
  cxSetResourceString(@scxGridDeletingSelectedConfirmationText, 'Elimino tutti i record selezionati?');

  cxSetResourceString(@scxGridNoDataInfoText, '<Nessun dato da visualizzare>');

  cxSetResourceString(@scxGridFilterRowInfoText, 'Premere qui per definire un filtro');
  cxSetResourceString(@scxGridNewItemRowInfoText, 'Premere qui per aggiungere una riga');

  cxSetResourceString(@scxGridFindPanelClearButtonCaption, 'Annulla');
  cxSetResourceString(@scxGridFindPanelFindButtonCaption, 'Cerca');
  cxSetResourceString(@scxGridFindPanelInfoText, 'Immettere il testo da cercare...');

  cxSetResourceString(@scxGridFilterIsEmpty, '<Nessun filtro>');

  cxSetResourceString(@scxGridCustomizationFormCaption, 'Personalizza');
  cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, 'Colonne');
  cxSetResourceString(@scxGridGroupByBoxCaption, 'Trascinare qui l''intestazione di una colonna per ragguppare');
  cxSetResourceString(@scxGridFilterApplyButtonCaption, 'Applica filtro');
  cxSetResourceString(@scxGridFilterCustomizeButtonCaption, 'Modifica Filtri...');
  cxSetResourceString(@scxGridColumnsQuickCustomizationHint, 'Premere qui per aggiungere/rimuovere colonne');

  cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, 'Bande');
  cxSetResourceString(@scxGridBandsQuickCustomizationHint, 'Premere qui per aggiungere/rimuovere bande');

  cxSetResourceString(@scxGridCustomizationFormRowsPageCaption, 'Righe');

  // date ranges
  cxSetResourceString(@scxGridYesterday, 'Ieri');
  cxSetResourceString(@scxGridToday, 'Oggi');
  cxSetResourceString(@scxGridTomorrow, 'Domani');
  cxSetResourceString(@scxGridLast30Days, 'Ultimi 30 giorni');
  cxSetResourceString(@scxGridLast14Days, 'Ultimi 14 giorni');
  cxSetResourceString(@scxGridLast7Days, 'Ultimi 7 giorni');
  cxSetResourceString(@scxGridNext7Days, 'Prossimi 7 giorni');
  cxSetResourceString(@scxGridNext14Days, 'Prossimi 14 giorni');
  cxSetResourceString(@scxGridNext30Days, 'Prossimi 30 giorni');
  cxSetResourceString(@scxGridLastTwoWeeks, 'Ultime two settimane');
  cxSetResourceString(@scxGridLastWeek, 'Ultima settimana');
  cxSetResourceString(@scxGridThisWeek, 'Questa settimana');
  cxSetResourceString(@scxGridNextWeek, 'Prossima settimana');
  cxSetResourceString(@scxGridNextTwoWeeks, 'Prossime due settimane');
  cxSetResourceString(@scxGridLastMonth, 'Ultimo mese');
  cxSetResourceString(@scxGridThisMonth, 'Questo mese');
  cxSetResourceString(@scxGridNextMonth, 'Prossimo mese');
  cxSetResourceString(@scxGridLastYear, 'Ultimo anno');
  cxSetResourceString(@scxGridThisYear, 'Quest''anno');
  cxSetResourceString(@scxGridNextYear, 'Prossimo anno');
  cxSetResourceString(@scxGridPast, 'Passato');
  cxSetResourceString(@scxGridFuture, 'Future');

  cxSetResourceString(@scxGridLockedStateImageText, 'Attendere...');

  cxSetResourceString(@scxGridInplaceEditFormButtonCancel, 'Annulla');
  cxSetResourceString(@scxGridInplaceEditFormButtonClose, 'Chiudi');
  cxSetResourceString(@scxGridInplaceEditFormButtonUpdate, 'Modifica');
  cxSetResourceString(@scxGridInplaceEditFormSaveChangesQuery, 'Dati variati. Si desidera salvare le modifiche?');
end;

procedure cxLocalizeGriPopup;
begin
  cxSetResourceString(@cxSGridNone, 'None');

  // Header popup menu item captions
  cxSetResourceString(@cxSGridSortColumnAsc, 'Ascendente');
  cxSetResourceString(@cxSGridSortColumnDesc, 'Discendente');
  cxSetResourceString(@cxSGridClearSorting, 'Elimina Ordinamento');
  cxSetResourceString(@cxSGridGroupByThisField, 'Raggruppa Per Questo Campo');
  cxSetResourceString(@cxSGridRemoveThisGroupItem, 'Rimuovi dal raggruppamento');
  cxSetResourceString(@cxSGridGroupByBox, 'Area Raggruppamento');
  cxSetResourceString(@cxSGridAlignmentSubMenu, 'Allineamento');
  cxSetResourceString(@cxSGridAlignLeft, 'Allineamento Sinistra');
  cxSetResourceString(@cxSGridAlignRight, 'Allineamento Destra');
  cxSetResourceString(@cxSGridAlignCenter, 'Allineamento Centro');
  cxSetResourceString(@cxSGridRemoveColumn, 'Rimuovi Questa Colonna');
  cxSetResourceString(@cxSGridFieldChooser, 'Colonne...');
  cxSetResourceString(@cxSGridBestFit, 'Larghezza Automatica');
  cxSetResourceString(@cxSGridBestFitAllColumns, 'Larghezza Automatica (tutte le colonne)');
  cxSetResourceString(@cxSGridShowFooter, 'Sommario');
  cxSetResourceString(@cxSGridShowGroupFooter, 'Sommario Di Gruppo');
  cxSetResourceString(@cxSGridShowFindPanel, 'Pannello Di Ricerca');
  cxSetResourceString(@cxSGridFullExpand, 'Espandi tutto');
  cxSetResourceString(@cxSGridFullCollapse, 'Comprimi Tutto');
  cxSetResourceString(@cxSGridClearGrouping, 'Elimina Raggruppamento');
  cxSetResourceString(@cxSGridHideGroupByBox, 'Nascondi Area Raggruppamento');

  // Footer popup menu item captions
  cxSetResourceString(@cxSGridNoneMenuItem, 'Nessuno');
  cxSetResourceString(@cxSGridSumMenuItem, 'Somma');
  cxSetResourceString(@cxSGridMinMenuItem, 'Minimo');
  cxSetResourceString(@cxSGridMaxMenuItem, 'Massimo');
  cxSetResourceString(@cxSGridCountMenuItem, 'Conteggio');
  cxSetResourceString(@cxSGridAvgMenuItem, 'Media');

  // Group row popup menu item captions
  cxSetResourceString(@cxSGridSortByGroupValues, 'Ordina Per Valore Gruppo');
  cxSetResourceString(@cxSGridSortBySummaryCaption, 'Ordina Per Sommario Gruppo:');
  cxSetResourceString(@cxSGridSortBySummary, '%s per %s');

end;

procedure cxLocalizePageControl;
begin
  // cxPCConsts
  cxSetResourceString(@scxPCDefaultHintCloseButton, 'Chiudi Scheda Attiva');
  cxSetResourceString(@scxPCDefaultHintGoDialogButton, 'Open go dialog');
  cxSetResourceString(@scxPCDefaultHintTopLeftButton, 'Scheda Precedente');
  cxSetResourceString(@scxPCDefaultHintBottomRightButton, 'Scheda Successiva');
  cxSetResourceString(@scxPCDefaultHintTabCloseButton, 'Chiudi Scheda');
  cxSetResourceString(@scxPCDefaultHintNewButton, 'Nuova Scheda');
end;

procedure cxLocalizeEditors;
begin
  // cxEditConsts
  cxSetResourceString(@cxSEditButtonCancel, 'Annulla');
  cxSetResourceString(@cxSEditButtonOK, 'OK');
  cxSetResourceString(@cxSEditDateConvertError, 'Could not convert to date');
  cxSetResourceString(@cxSEditInvalidRepositoryItem, 'The repository item is not acceptable');
  cxSetResourceString(@cxSEditNumericValueConvertError, 'Could not convert to numeric value');
  cxSetResourceString(@cxSEditPopupCircularReferencingError, 'Circular referencing is not allowed');
  cxSetResourceString(@cxSEditPostError, 'An error occurred during posting edit value');
  cxSetResourceString(@cxSEditTimeConvertError, 'Could not convert to time');
  cxSetResourceString(@cxSEditValidateErrorText, 'Invalid input value. Use escape key to abandon changes');
  cxSetResourceString(@cxSEditValueOutOfBounds, 'Value out of bounds');

  cxSetResourceString(@cxSEditCheckBoxChecked, 'True');
  cxSetResourceString(@cxSEditCheckBoxGrayed, '');
  cxSetResourceString(@cxSEditCheckBoxUnchecked, 'False');
  cxSetResourceString(@cxSRadioGroupDefaultCaption, '');

  cxSetResourceString(@cxSTextTrue, 'True');
  cxSetResourceString(@cxSTextFalse, 'False');

  // Combo
  cxSetResourceString(@cxSNoMatchesFound, 'No matches found');

  // Blob
  cxSetResourceString(@cxSBlobButtonOK, '&OK');
  cxSetResourceString(@cxSBlobButtonCancel, '&Annulla');
  cxSetResourceString(@cxSBlobButtonClose, '&Chiudi');
  cxSetResourceString(@cxSBlobMemo, '(MEMO)');
  cxSetResourceString(@cxSBlobMemoEmpty, '(memo)');
  cxSetResourceString(@cxSBlobPicture, '(IMMAGINE)');
  cxSetResourceString(@cxSBlobPictureEmpty, '(immagine)');

  // popup menu items
  cxSetResourceString(@cxSMenuItemCaptionCut, 'Cu&t');
  cxSetResourceString(@cxSMenuItemCaptionCopy, '&Copy');
  cxSetResourceString(@cxSMenuItemCaptionPaste, '&Paste');
  cxSetResourceString(@cxSMenuItemCaptionDelete, '&Delete');
  cxSetResourceString(@cxSMenuItemCaptionLoad, '&Load...');
  cxSetResourceString(@cxSMenuItemCaptionSave, 'Save &As...');
  cxSetResourceString(@cxSMenuItemCaptionAssignFromWebCam, 'Assign From Ca&mera...');

  // Date
  cxSetResourceString(@cxSDatePopupClear, 'Cancella');
  cxSetResourceString(@cxSDatePopupNow, 'Ora');
  cxSetResourceString(@cxSDatePopupOK, 'OK');
  cxSetResourceString(@cxSDatePopupToday, 'Oggi');
  cxSetResourceString(@cxSDatePopupCancel, 'Annulla');
  cxSetResourceString(@cxSDateError, 'Data non valida');

  // Calculator
  cxSetResourceString(@scxSCalcError, 'Errore');

  // HyperLink
  cxSetResourceString(@scxSHyperLinkPrefix, 'http://');
  cxSetResourceString(@scxSHyperLinkDoubleSlash, '//');

  // Navigator
  cxSetResourceString(@cxNavigatorHint_First, 'First record');
  cxSetResourceString(@cxNavigatorHint_Prior, 'Prior record');
  cxSetResourceString(@cxNavigatorHint_PriorPage, 'Prior page');
  cxSetResourceString(@cxNavigatorHint_Next, 'Next record');
  cxSetResourceString(@cxNavigatorHint_NextPage, 'Next page');
  cxSetResourceString(@cxNavigatorHint_Last, 'Last record');
  cxSetResourceString(@cxNavigatorHint_Insert, 'Insert record');
  cxSetResourceString(@cxNavigatorHint_Append, 'Append record');
  cxSetResourceString(@cxNavigatorHint_Delete, 'Delete record');
  cxSetResourceString(@cxNavigatorHint_Edit, 'Edit record');
  cxSetResourceString(@cxNavigatorHint_Post, 'Post edit');
  cxSetResourceString(@cxNavigatorHint_Cancel, 'Cancel edit');
  cxSetResourceString(@cxNavigatorHint_Refresh, 'Refresh data');
  cxSetResourceString(@cxNavigatorHint_SaveBookmark, 'Save Bookmark');
  cxSetResourceString(@cxNavigatorHint_GotoBookmark, 'Goto Bookmark');
  cxSetResourceString(@cxNavigatorHint_Filter, 'Filter data');
  cxSetResourceString(@cxNavigator_DeleteRecordQuestion, 'Delete record?');
  cxSetResourceString(@cxNavigatorInfoPanelDefaultDisplayMask, '[RecordIndex] of [RecordCount]');

  // BreadcrumbEdit
  cxSetResourceString(@sdxBreadcrumbEditInvalidPath, 'Cannot find "%s". Check the spelling and try again.');
  cxSetResourceString(@sdxBreadcrumbEditInvalidStreamVersion, 'Invalid data version: %d');

  // Edit Repository
  cxSetResourceString(@scxSEditRepositoryBlobItem, 'BlobEdit|Represents an editor of BLOB (Binary Large OBject) data');
  cxSetResourceString(@scxSEditRepositoryButtonItem, 'ButtonEdit|Represents an editor with embedded buttons');
  cxSetResourceString(@scxSEditRepositoryCalcItem, 'CalcEdit|Represents an editor with a dropdown calculator window');
  cxSetResourceString(@scxSEditRepositoryCheckBoxItem, 'CheckBox|Represents a check box control that allows selecting an option');
  cxSetResourceString(@scxSEditRepositoryComboBoxItem, 'ComboBox|Represents the combo box editor');
  cxSetResourceString(@scxSEditRepositoryCurrencyItem, 'CurrencyEdit|Represents an editor enabling editing currency data');
  cxSetResourceString(@scxSEditRepositoryDateItem, 'DateEdit|Represents an editor with a dropdown calendar');
  cxSetResourceString(@scxSEditRepositoryHyperLinkItem, 'HyperLink|Represents a text editor with hyperlink functionality');
  cxSetResourceString(@scxSEditRepositoryImageComboBoxItem, 'ImageComboBox|Represents an editor displaying the list of images and text strings within the dropdown window');
  cxSetResourceString(@scxSEditRepositoryImageItem, 'Image|Represents an image editor');
  cxSetResourceString(@scxSEditRepositoryLookupComboBoxItem, 'LookupComboBox|Represents a lookup combo box control');
  cxSetResourceString(@scxSEditRepositoryMaskItem, 'MaskEdit|Represents a generic masked editor');
  cxSetResourceString(@scxSEditRepositoryMemoItem, 'Memo|Represents an editor that allows editing memo data');
  cxSetResourceString(@scxSEditRepositoryMRUItem, 'MRUEdit|Represents a text editor displaying the list of most recently used items (MRU) within a dropdown window');
  cxSetResourceString(@scxSEditRepositoryPopupItem, 'PopupEdit|Represents an editor with a dropdown list');
  cxSetResourceString(@scxSEditRepositorySpinItem, 'SpinEdit|Represents a spin editor');
  cxSetResourceString(@scxSEditRepositoryRadioGroupItem, 'RadioGroup|Represents a group of radio buttons');
  cxSetResourceString(@scxSEditRepositoryTextItem, 'TextEdit|Represents a single line text editor');
  cxSetResourceString(@scxSEditRepositoryTimeItem, 'TimeEdit|Represents an editor displaying time values');
  cxSetResourceString(@scxSEditRepositoryToggleSwitchItem, 'ToggleSwitch|Represents a toggle switch editor that allows selecting an option');
  cxSetResourceString(@scxSEditRepositoryDateTimeWheelPickerItem, 'DateTimeWheelPicker|Represents an editor that allows the selection of a date-time value using a wheel picker');
  cxSetResourceString(@scxSEditRepositorySparklineItem, 'Sparkline|Represents a sparkline editor');
  cxSetResourceString(@scxSEditRepositoryLookupSparklineItem, 'LookupSparkline|Represents a lookup sparkline editor');
  cxSetResourceString(@scxSEditRepositoryNumericWheelPickerItem, 'NumericWheelPicker|Represents an editor that allows the selection of a numeric value using a wheel picker');
  cxSetResourceString(@scxSEditRepositoryBarCodeItem, 'BarCode|Represents a barcode editor');
  cxSetResourceString(@scxSEditRepositoryTokenItem, 'TokenEdit|Represents an editor that visualizes text list items as simpler tokens');
  cxSetResourceString(@scxSEditRepositoryFormattedLabelItem, 'FormattedLabel|Represents a label that displays text formatted using BBCode-inspired markup tags');

  // Regular Expressions
  cxSetResourceString(@scxRegExprLine, 'Line');
  cxSetResourceString(@scxRegExprChar, 'Char');
  cxSetResourceString(@scxRegExprNotAssignedSourceStream, 'The source stream is not assigned');
  cxSetResourceString(@scxRegExprEmptySourceStream, 'The source stream is empty');
  cxSetResourceString(@scxRegExprCantUsePlusQuantifier, 'The ''+'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantUseStarQuantifier, 'The ''*'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantCreateEmptyAlt, 'The alternative should not be empty');
  cxSetResourceString(@scxRegExprCantCreateEmptyBlock, 'The block should not be empty');
  cxSetResourceString(@scxRegExprIllegalSymbol, 'Illegal ''%s''');
  cxSetResourceString(@scxRegExprIllegalQuantifier, 'Illegal quantifier ''%s''');
  cxSetResourceString(@scxRegExprNotSupportQuantifier, 'The parameter quantifiers are not supported');
  cxSetResourceString(@scxRegExprIllegalIntegerValue, 'Illegal integer value');
  cxSetResourceString(@scxRegExprTooBigReferenceNumber, 'Too big reference number');
  cxSetResourceString(@scxRegExprCantCreateEmptyEnum, 'Can''t create empty enumeration');
  cxSetResourceString(@scxRegExprSubrangeOrder, 'The starting character of the subrange must be less than the finishing one');
  cxSetResourceString(@scxRegExprHexNumberExpected0, 'Hexadecimal number expected');
  cxSetResourceString(@scxRegExprHexNumberExpected, 'Hexadecimal number expected but ''%s'' found');
  cxSetResourceString(@scxRegExprMissing, 'Missing ''%s''');
  cxSetResourceString(@scxRegExprUnnecessary, 'Unnecessary ''%s''');
  cxSetResourceString(@scxRegExprIncorrectSpace, 'The space character is not allowed after ''\''');
  cxSetResourceString(@scxRegExprNotCompiled, 'Regular expression is not compiled');
  cxSetResourceString(@scxRegExprIncorrectParameterQuantifier, 'Incorrect parameter quantifier');
  cxSetResourceString(@scxRegExprCantUseParameterQuantifier, 'The parameter quantifier cannot be applied here');

  // MaskEdit
  cxSetResourceString(@scxMaskEditRegExprError, 'Regular expression errors:');
  cxSetResourceString(@scxMaskEditInvalidEditValue, 'The edit value is invalid');
  cxSetResourceString(@scxMaskEditNoMask, 'None');
  cxSetResourceString(@scxMaskEditIllegalFileFormat, 'Illegal file format');
  cxSetResourceString(@scxMaskEditEmptyMaskCollectionFile, 'The mask collection file is empty');
  cxSetResourceString(@scxMaskEditMaskCollectionFiles, 'Mask collection files');
  cxSetResourceString(@cxSSpinEditInvalidNumericValue, 'Invalid numeric value');

  // AlertWindow
  cxSetResourceString(@sdxAlertWindowNavigationPanelDefaultDisplayMask, '[MessageIndex] of [MessageCount]');
  cxSetResourceString(@sdxAlertWindowPreviousMessage, 'Previous message');
  cxSetResourceString(@sdxAlertWindowNextMessage, 'Next message');
  cxSetResourceString(@sdxAlertWindowPin, 'Pin');
  cxSetResourceString(@sdxAlertWindowClose, 'Close');
  cxSetResourceString(@sdxAlertWindowDropdown, 'Show Drop-down Menu');

  // ColorGallery
  cxSetResourceString(@sdxColorGalleryThemeColors, 'Theme Colors');
  cxSetResourceString(@sdxColorGalleryStandardColors, 'Standard Colors');

  // ColorDialog
  cxSetResourceString(@sdxColorDialogAddToCustomColors, '&Add to Custom Colors');
  cxSetResourceString(@sdxColorDialogApply, '&OK');
  cxSetResourceString(@sdxColorDialogCancel, '&Cancel');
  cxSetResourceString(@sdxColorDialogDefineCustomColor, '&Define Custom Colors >>');
  cxSetResourceString(@sdxColorDialogBasicColors, 'Basic Colors');
  cxSetResourceString(@sdxColorDialogCaption, 'Color Editor');
  cxSetResourceString(@sdxColorDialogCustomColors, 'Custom Colors');

  // ColorPicker
  cxSetResourceString(@sdxColorPickerAlphaLabel, 'A:');
  cxSetResourceString(@sdxColorPickerBlueLabel, 'B:');
  cxSetResourceString(@sdxColorPickerGreenLabel, 'G:');
  cxSetResourceString(@sdxColorPickerHexCodeLabel, '#');
  cxSetResourceString(@sdxColorPickerHueLabel, 'H:');
  cxSetResourceString(@sdxColorPickerLightnessLabel, 'L:');
  cxSetResourceString(@sdxColorPickerRedLabel, 'R:');
  cxSetResourceString(@sdxColorPickerSaturationLabel, 'S:');

  // ShellBrowser
  cxSetResourceString(@scxShellBrowserDlgCaption, 'Browse for Folder');
  cxSetResourceString(@scxShellBrowserDlgCurrentFolderCaption, 'Current Folder');

  // CameraControl
  cxSetResourceString(@sdxCameraDialogAssign, '&Assign');
  cxSetResourceString(@sdxCameraDialogCancel, '&Cancel');
  cxSetResourceString(@sdxCameraDialogPause, '&Pause');
  cxSetResourceString(@sdxCameraDialogPlay, '&Play');
  cxSetResourceString(@sdxCameraDialogCaption, 'Camera Preview');
  cxSetResourceString(@sdxCameraInactive, 'Inactive');
  cxSetResourceString(@sdxCameraRunning, 'Running');
  cxSetResourceString(@sdxCameraPaused, 'Paused');
  cxSetResourceString(@sdxCameraNotDetected, 'No camera detected');
  cxSetResourceString(@sdxCameraInitializing, 'Initializing...');
  cxSetResourceString(@sdxCameraIsBusy, 'Camera is inaccessible.'#13#10'Try closing other programs that might be using your camera');
  cxSetResourceString(@sdxCameraControlSettingsFormSettings, 'Settings');
  cxSetResourceString(@sdxCameraControlSettingsFormDevice, 'Device');
  cxSetResourceString(@sdxCameraControlSettingsFormDevices, 'Devices');
  cxSetResourceString(@sdxCameraControlSettingsFormResolution, 'Resolution');
  cxSetResourceString(@sdxCameraControlSettingsFormResolutions, 'Resolutions');

  // ToggleSwitch
  cxSetResourceString(@sdxDefaultToggleSwitchOffText, 'Off');
  cxSetResourceString(@sdxDefaultToggleSwitchOnText, 'On');

  // DateTimeWheelPicker
  cxSetResourceString(@sdxDateTimeWheelPickerHours, 'Hours');
  cxSetResourceString(@sdxDateTimeWheelPickerMinutes, 'Minutes');
  cxSetResourceString(@sdxDateTimeWheelPickerSeconds, 'Seconds');

  // Sparkline
  cxSetResourceString(@sdxSparklineNoData, '<No data>');

  // BarCode
  cxSetResourceString(@sdxBarCodeInvalidCharactersError, 'Invalid characters in the text');
  cxSetResourceString(@sdxBarCodeInvalidTextFormatError, 'Invalid text format');
  cxSetResourceString(@sdxBarCodeControlTooNarrowError, 'The control is too narrow to display a barcode');

  // TokenEdit
  cxSetResourceString(@sdxTokenEditMoreTokensCaption, '...');
  cxSetResourceString(@sdxTokenEditMoreTokensHint, '%d hidden token(s):'#13#10'(%s)');

  // RangeControl
  cxSetResourceString(@sdxRangeControlRangeIsEmpty, 'Range is empty');

  // UIAdorners
  cxSetResourceString(@sdxUIAdornerManagerBadOwner, 'TdxUIAdornerManager should have TWinControl as its Owner');

  // ExcelFilterValueContainer
  cxSetResourceString(@sdxExcelFilterFromValueText, 'From');
  cxSetResourceString(@sdxExcelFilterToValueText, 'To');
  cxSetResourceString(@sdxExcelFilterTopNBottomNValueLabel, 'Value');
  cxSetResourceString(@sdxExcelFilterTopNBottomNTypeLabel, 'Type');
  cxSetResourceString(@sdxExcelFilterCustomFilterAndOperatorLabel, 'And');
  cxSetResourceString(@sdxExcelFilterCustomFilterOrOperatorLabel, 'Or');
  cxSetResourceString(@sdxExcelFilterCustomFilterFirstConditionLabel, 'First');
  cxSetResourceString(@sdxExcelFilterCustomFilterSecondConditionLabel, 'Second');
  cxSetResourceString(@sdxExcelFilterValuesTabCaption, 'Values');
  cxSetResourceString(@sdxExcelFilterDateFiltersTabCaption, 'Date Filters');
  cxSetResourceString(@sdxExcelFilterTextFiltersTabCaption, 'Text Filters');
  cxSetResourceString(@sdxExcelFilterTimeFiltersTabCaption, 'Time Filters');
  cxSetResourceString(@sdxExcelFilterNumericFiltersTabCaption, 'Numeric Filters');
  cxSetResourceString(@sdxExcelFilterSelectValueHintText, 'Select a value...');
  cxSetResourceString(@sdxExcelFilterSelectDateHintText, 'Select a date...');
  cxSetResourceString(@sdxExcelFilterEnterValueHintText, 'Enter a value...');
  cxSetResourceString(@sdxExcelFilterSpecificDatePeriodsConditionText, 'Specific Date Periods');
  cxSetResourceString(@sdxExcelFilterEqualsConditionText, 'Equals');
  cxSetResourceString(@sdxExcelFilterDoesNotEqualConditionText, 'Does Not Equal');
  cxSetResourceString(@sdxExcelFilterBeginsWithConditionText, 'Begins With');
  cxSetResourceString(@sdxExcelFilterEndsWithConditionText, 'Ends With');
  cxSetResourceString(@sdxExcelFilterContainsConditionText, 'Contains');
  cxSetResourceString(@sdxExcelFilterDoesNotContainConditionText, 'Does Not Contain');
  cxSetResourceString(@sdxExcelFilterIsBlankConditionText, 'Is Blank');
  cxSetResourceString(@sdxExcelFilterIsNotBlankConditionText, 'Is Not Blank');
  cxSetResourceString(@sdxExcelFilterBetweenConditionText, 'Between');
  cxSetResourceString(@sdxExcelFilterGreaterThanConditionText, 'Greater Than');
  cxSetResourceString(@sdxExcelFilterGreaterThanOrEqualToConditionText, 'Greater Than Or Equal To');
  cxSetResourceString(@sdxExcelFilterLessThanConditionText, 'Less Than');
  cxSetResourceString(@sdxExcelFilterLessEqualThanOrEqualToConditionText, 'Less Than Or Equal To');
  cxSetResourceString(@sdxExcelFilterTopNConditionText, 'Top N');
  cxSetResourceString(@sdxExcelFilterBottomNConditionText, 'Bottom N');
  cxSetResourceString(@sdxExcelFilterAboveAverageConditionText, 'Above Average');
  cxSetResourceString(@sdxExcelFilterBelowAverageConditionText, 'Below Average');
  cxSetResourceString(@sdxExcelFilterBeforeConditionText, 'Before');
  cxSetResourceString(@sdxExcelFilterAfterConditionText, 'After');
  cxSetResourceString(@sdxExcelFilterYesterdayConditionText, 'Yesterday');
  cxSetResourceString(@sdxExcelFilterTodayConditionTypeText, 'Today');
  cxSetResourceString(@sdxExcelFilterTomorrowConditionText, 'Tomorrow');
  cxSetResourceString(@sdxExcelFilterLastWeekConditionText, 'Last Week');
  cxSetResourceString(@sdxExcelFilterThisWeekConditionText, 'This Week');
  cxSetResourceString(@sdxExcelFilterNextWeekConditionText, 'Next Week');
  cxSetResourceString(@sdxExcelFilterLastMonthConditionText, 'Last Month');
  cxSetResourceString(@sdxExcelFilterThisMonthConditionText, 'This Month');
  cxSetResourceString(@sdxExcelFilterNextMonthConditionText, 'Next Month');
  cxSetResourceString(@sdxExcelFilterLastYearConditionText, 'Last Year');
  cxSetResourceString(@sdxExcelFilterThisYearConditionText, 'This Year');
  cxSetResourceString(@sdxExcelFilterNextYearConditionText, 'Next Year');
  cxSetResourceString(@sdxExcelFilterCustomFilterConditionText, 'Custom Filter');
  cxSetResourceString(@sdxExcelFilterTopNBottomNItemsText, 'Items');
  cxSetResourceString(@sdxExcelFilterTopNBottomNPercentText, 'Percent');

  // FilterPopupWindow
  cxSetResourceString(@sdxFilterPopupWindowClearButtonCaption, 'Clear Filter');
  cxSetResourceString(@sdxFilterPopupWindowCloseButtonCaption, 'Close');
  cxSetResourceString(@sdxFilterPopupWindowCancelButtonCaption, 'Cancel');
  cxSetResourceString(@sdxFilterPopupWindowOKButtonCaption, 'OK');
end;

procedure cxLocalizePivot;
begin
  cxSetResourceString(@scxDataField, 'Data');
  cxSetResourceString(@scxDropFilterFields, 'Drop Filter Fields Here');
  cxSetResourceString(@scxDropDataItems, 'Drop Data Fields Here');
  cxSetResourceString(@scxDropRowFields, 'Drop Row Fields Here');
  cxSetResourceString(@scxDropColumnFields, 'Drop Column Fields Here');
  cxSetResourceString(@scxGrandTotal, 'Totale');
  cxSetResourceString(@scxNoDataToDisplay, '<Nessun dato da visualizzare>');
  cxSetResourceString(@scxAddTo, 'Add To');
  cxSetResourceString(@scxDragItems, 'Drag Items to the PivotGrid');
  cxSetResourceString(@scxFieldListCaption, 'PivotGrid Field List');
  cxSetResourceString(@scxMeasureGroups, 'Measure Groups');
  cxSetResourceString(@scxRowArea, 'Row Area');
  cxSetResourceString(@scxColumnArea, 'Column Area');
  cxSetResourceString(@scxFilterArea, 'Filter Area');
  cxSetResourceString(@scxDataArea, 'Data Area');
  cxSetResourceString(@scxGroupTotal, 'Totale per %s');
  cxSetResourceString(@scxGroupCount, '%s Count');
  cxSetResourceString(@scxGroupSum, '%s Sum');
  cxSetResourceString(@scxGroupMin, '%s Min');
  cxSetResourceString(@scxGroupMax, '%s Max');
  cxSetResourceString(@scxGroupAverage, '%s Average');
  cxSetResourceString(@scxGroupStdDev, '%s StdDev');
  cxSetResourceString(@scxGroupStdDevP, '%s StdDevP');
  cxSetResourceString(@scxGroupVariance, '%s Var');
  cxSetResourceString(@scxGroupVarianceP, '%s VarP');
  cxSetResourceString(@scxGroupCustom, '%s Custom');
  cxSetResourceString(@scxOthers, 'Others');
  cxSetResourceString(@scxPivotGridShowAll, '(Show All)');
  cxSetResourceString(@scxPivotGridOk, 'OK');
  cxSetResourceString(@scxPivotGridCancel, 'Annulla');
  cxSetResourceString(@scxQuarterFormat, 'Qtr %d');
  cxSetResourceString(@scxFieldNotADataField, 'Field must be in data area!');
  cxSetResourceString(@scxInvalidLayout, 'Invalid layout!');
  cxSetResourceString(@scxNotImplemented, 'Not implemented yet!');
  cxSetResourceString(@scxSeparator, '-');
  cxSetResourceString(@scxHide, 'Hide');
  cxSetResourceString(@scxOrder, 'Order');
  cxSetResourceString(@scxMoveToBeginning, 'Move to Beginning');
  cxSetResourceString(@scxMoveToEnd, 'Move to End');
  cxSetResourceString(@scxMoveToLeft, 'Move to Left');
  cxSetResourceString(@scxMoveToRight, 'Move to Right');
  cxSetResourceString(@scxExpand, 'Espandi');
  cxSetResourceString(@scxCollapse, 'Raccogli');
  cxSetResourceString(@scxExpandAll, 'Espandi tutto');
  cxSetResourceString(@scxCollapseAll, 'Raccogli tutto');
  cxSetResourceString(@scxShowCustomization, 'Mostra Lista Campi');
  cxSetResourceString(@scxHideCustomization, 'Nascondi Lista Campi');
  cxSetResourceString(@scxShowPrefilterDialog, 'Show Prefilter Dialog');
  cxSetResourceString(@scxSortGroupByThisColumn, 'Sort "%s" by This Column');
  cxSetResourceString(@scxSortGroupByThisRow, 'Sort "%s" by This Row');
  cxSetResourceString(@scxRemoveAllSorting, 'Remove All Sorting');
  cxSetResourceString(@scxPrefilterIsEmpty, '<Prefilter is Empty>');
  cxSetResourceString(@scxPrefilterCustomizeButtonCaption, 'Prefilter...');
  cxSetResourceString(@scxConnectUsing, 'Connect using');
  cxSetResourceString(@scxAnalysisServer, 'Analysis server');
  cxSetResourceString(@scxCubeFile, 'Cube file');
  cxSetResourceString(@scxFile, 'File');
  cxSetResourceString(@scxServer, 'Server');
  cxSetResourceString(@scxDatabase, 'Database');
  cxSetResourceString(@scxCube, 'Cube');
  cxSetResourceString(@scxMeasures, 'Measures');
  cxSetResourceString(@scxKPIs, 'KPIs');
  cxSetResourceString(@scxSets, 'Sets');
  cxSetResourceString(@scxUnsupportedProviderVersion, 'Unsupported data provider version:%d');
  cxSetResourceString(@scxInvalidCubeName, 'Invalid %s cube name.');
  cxSetResourceString(@scxInvalidProviderVersion, 'Provider version doesn''t match the OLAP data source version');
  cxSetResourceString(@scxUpdate, 'Update');
  cxSetResourceString(@scxDeferLayoutUpdate, 'Defer Layout Update');
  cxSetResourceString(@scxAdvancedCustomizationFormMainCaption, 'Drag fields to the pivot grid');
  cxSetResourceString(@scxAdvancedCustomizationFormFieldsCaption, 'Drag fields between areas below:');
  cxSetResourceString(@scxAdvancedCustomizationFormFilterAreaCaption, 'Filter Area');
  cxSetResourceString(@scxAdvancedCustomizationFormColumnAreaCaption, 'Column Area');
  cxSetResourceString(@scxAdvancedCustomizationFormRowAreaCaption, 'Row Area');
  cxSetResourceString(@scxAdvancedCustomizationFormDataAreaCaption, 'Data Area');
  cxSetResourceString(@scxAdvancedCustomizationFormBottomPanelOnly1by4, 'Areas Section Only (1 by 4)');
  cxSetResourceString(@scxAdvancedCustomizationFormBottomPanelOnly2by2, 'Areas Section Only (2 by 2)');
  cxSetResourceString(@scxAdvancedCustomizationFormStackedDefault, 'Fields Section and Areas Section Stacked');
  cxSetResourceString(@scxAdvancedCustomizationFormStackedSideBySide, 'Fields Section and Areas Section Side-By-Side');
  cxSetResourceString(@scxAdvancedCustomizationFormTopPanelOnly, 'Fields Section Only');
end;

procedure cxLocalizeTreeList;
begin
  cxSetResourceString(@scxIndexOutOfBounds, 'Index %d out of bounds');
  cxSetResourceString(@scxInvalidStreamFormat, 'Invalid stream format');
  cxSetResourceString(@scxMultiSelectRequired, 'Multi select required');

  // designer constants
  cxSetResourceString(@scxDesignerCaption, 'TreeListDesigner editing - ');
  cxSetResourceString(@scxBands, 'Bands...');
  cxSetResourceString(@scxColumns, 'Columns...');
  cxSetResourceString(@scxCreateAllItems, 'Create All Columns');
  cxSetResourceString(@scxCreateMissingItems, 'Create Missing Columns');
  cxSetResourceString(@scxDeleteAllItems, 'Delete All Columns');
  cxSetResourceString(@scxConditionalFormatting, 'Conditional Formatting...');
  cxSetResourceString(@scxItems, 'Items Editor...');

  // customization form
  cxSetResourceString(@scxCustomizeCaption, 'Personalizza');
  cxSetResourceString(@scxColumnsCaption, '   Colonne   ');
  cxSetResourceString(@scxBandsCaption, '    Bande    ');

  // find Panel

  cxSetResourceString(@scxTreeListFindPanelClearButtonCaption, 'Elimina');
  cxSetResourceString(@scxTreeListFindPanelInfoText, 'Testo di ricerca...');
  cxSetResourceString(@scxTreeListFindPanelFindButtonCaption, 'Cerca');
  cxSetResourceString(@scxTreeListFindPanelNextButtonCaption, 'Prossimo');
  cxSetResourceString(@scxTreeListFindPanelPreviousButtonCaption, 'Precedente');

  // Summary menu item captions
  cxSetResourceString(@scxTreeListNoneMenuItem, 'None');
  cxSetResourceString(@scxTreeListSumMenuItem, 'Sum');
  cxSetResourceString(@scxTreeListMinMenuItem, 'Min');
  cxSetResourceString(@scxTreeListMaxMenuItem, 'Max');
  cxSetResourceString(@scxTreeListCountMenuItem, 'Count');
  cxSetResourceString(@scxTreeListAvgMenuItem, 'Average');
  cxSetResourceString(@scxTreeListAllNodesMenuItem, 'All Nodes');
  // Column Header menu item captions
  cxSetResourceString(@scxTreeListSortAscendingMenuItem, '&Sort Ascending');
  cxSetResourceString(@scxTreeListSortDescendingMenuItem, 'S&ort Descending');
  cxSetResourceString(@scxTreeListClearSortingMenuItem, '&Clear Sorting');
  cxSetResourceString(@scxTreeListFooterMenuItem, '&Footer');
  cxSetResourceString(@scxTreeListGroupFootersMenuItem, '&Group Footers');
  cxSetResourceString(@scxTreeListGroupFootersInvisibleMenuItem, '&Hidden');
  cxSetResourceString(@scxTreeListGroupFootersVisibleWhenExpandedMenuItem, '&Visible When Expanded');
  cxSetResourceString(@scxTreeListGroupFootersAlwaysVisibleMenuItem, '&Always Visible');
  cxSetResourceString(@scxTreeListRemoveThisColumnMenuItem, 'R&emove This Column');
  cxSetResourceString(@scxTreeListFieldChooserMenuItem, 'F&ield Chooser');
  cxSetResourceString(@scxTreeListHorizontalAlignmentMenuItem, 'Ho&rizontal Alignment');
  cxSetResourceString(@scxTreeListHorizontalAlignmentLeftMenuItem, '&Left');
  cxSetResourceString(@scxTreeListHorizontalAlignmentCenterMenuItem, 'Ce&nter');
  cxSetResourceString(@scxTreeListHorizontalAlignmentRightMenuItem, '&Right');
  cxSetResourceString(@scxTreeListVerticalAlignmentMenuItem, 'Ver&tical Alignment');
  cxSetResourceString(@scxTreeListVerticalAlignmentBottomMenuItem, '&Bottom');
  cxSetResourceString(@scxTreeListVerticalAlignmentCenterMenuItem, 'Ce&nter');
  cxSetResourceString(@scxTreeListVerticalAlignmentTopMenuItem, '&Top');
  cxSetResourceString(@scxTreeListBestFitMenuItem, 'Larghezza Ottimale');
  cxSetResourceString(@scxTreeListBestFitAllColumnsMenuItem, 'Larghezza Ottimale (tutte le colonne)');

  cxSetResourceString(@scxOperationNotSupported, 'Operation is not supported');

  cxSetResourceString(@scxTreeListDeletingFocusedConfirmationText, 'Elimina righe?');
  cxSetResourceString(@scxTreeListDeletingConfirmationCaption, 'Conferma');

  cxSetResourceString(@scxExportNotVisibleControl, 'Control must be visible for export');

  cxSetResourceString(@scxTreeListYesterday, 'Ieri');
  cxSetResourceString(@scxTreeListToday, 'Oggi');
  cxSetResourceString(@scxTreeListTomorrow, 'Domani');
  cxSetResourceString(@scxTreeListLast30Days, 'Ultimi 30 giorni');
  cxSetResourceString(@scxTreeListLast14Days, 'Ultimi 14 giorni');
  cxSetResourceString(@scxTreeListLast7Days, 'Ultimi 7 giorni');
  cxSetResourceString(@scxTreeListNext7Days, 'Prossimi 7 giorni');
  cxSetResourceString(@scxTreeListNext14Days, 'Prossimi 14 giorni');
  cxSetResourceString(@scxTreeListNext30Days, 'Prossimi 30 giorni');
  cxSetResourceString(@scxTreeListLastTwoWeeks, 'Ultime due settimane');
  cxSetResourceString(@scxTreeListLastWeek, 'Settimana scorsa');
  cxSetResourceString(@scxTreeListThisWeek, 'Questa settimana');
  cxSetResourceString(@scxTreeListNextWeek, 'Settimana prossima');
  cxSetResourceString(@scxTreeListNextTwoWeeks, 'Prossime due settimane');
  cxSetResourceString(@scxTreeListLastMonth, 'Mese scorso');
  cxSetResourceString(@scxTreeListThisMonth, 'Questo mese');
  cxSetResourceString(@scxTreeListNextMonth, 'Prossimo mese');
  cxSetResourceString(@scxTreeListLastYear, 'Ultimo anno');
  cxSetResourceString(@scxTreeListThisYear, 'Quest''anno');
  cxSetResourceString(@scxTreeListNextYear, 'Prossimo anno');
  cxSetResourceString(@scxTreeListPast, 'Passato');
  cxSetResourceString(@scxTreeListFuture, 'Futuro');

  cxSetResourceString(@scxTreeListMonthFormat, 'mmmm yyyy');
  cxSetResourceString(@scxTreeListYearFormat, 'yyyy');

  cxSetResourceString(@scxTreeListFilterApplyButtonCaption, 'Applica Filtro');

  cxSetResourceString(@scxTreeListFilterIsEmpty, '<Nessun filtro>');
  cxSetResourceString(@scxTreeListFilterCustomizeButtonCaption, 'Modifica...');
end;

procedure cxLocalizeCustomPreview;
begin
  cxSetResourceString(@sdxPreviewPage, '&Pagina');
  cxSetResourceString(@sdxPreviewBottomMargin, 'Margine Inferiore');
  cxSetResourceString(@sdxPreviewHeaderMargin, 'Intestazione');
  cxSetResourceString(@sdxPreviewFooterMargin, 'Piè di pagina');
  cxSetResourceString(@sdxPreviewLeftMargin, 'Margine Sinistro');
  cxSetResourceString(@sdxPreviewRightMargin, 'Margine Destro');
  cxSetResourceString(@sdxPreviewTopMargin, 'Margine Superiore');

  cxSetResourceString(@sdxPreviewNoPages, 'Nessuna pagina da visualizzare');

  // cxSetResourceString(@sdxPreviewUnitsCentimeters = 'cm';
  // cxSetResourceString(@sdxPreviewUnitsInches = 'in';
  // cxSetResourceString(@sdxPreviewUnitsMillimeters = 'mm';
  // cxSetResourceString(@sdxPreviewUnitsPicas = 'pi';
  // cxSetResourceString(@sdxPreviewUnitsPoints = 'pt';

  cxSetResourceString(@sdxPreviewOutOfResources, 'Risorse di sistema esaurite');
end;

procedure dxLocalizeITA;
begin
  // occhio: chiamato anche da ==> class procedure TzLocalizer.Translate;
  cxLocalizeGrid;
  cxLocalizeGriPopup;
  cxLocalizePageControl;
  cxLocalizeEditors;
  cxLocalizeFilter;
  cxLocalizePivot;
  cxLocalizeTreeList;
  cxLocalizeCustomPreview;
end;

initialization

dxLocalizeITA

end.

  dxRichEdit.Strs dxRichEdit.Commands.Strs dxRichEdit.Dialogs.Strs dxRichEdit.Utils.Exceptions.Strs
