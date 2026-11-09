object zDbPivot: TzDbPivot
  AlignWithMargins = True
  Left = 0
  Top = 0
  Width = 682
  Height = 385
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentColor = False
  ParentFont = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Titolo: TcxLabel
    Left = 24
    Top = 35
    Caption = 'Titolo'
    ParentFont = False
    PopupMenu = popPivot
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
  end
  object cxDBPivotGrid: TcxDBPivotGrid
    AlignWithMargins = True
    Left = 3
    Top = 32
    Width = 576
    Height = 350
    Align = alClient
    DataSource = DataSource
    Groups = <>
    PopupMenu = popPivot
    PopupMenus.FieldHeaderMenu.UseBuiltInMenu = False
    PopupMenus.FieldHeaderMenu.Items = [fpmiHide, fpmiOrder, fpmiFieldList, fpmiSummaryType]
    PopupMenus.GroupValueMenu.UseBuiltInMenu = False
    PopupMenus.HeaderAreaMenu.UseBuiltInMenu = False
    Styles.OnGetContentStyle = cxDBPivotGridStylesGetContentStyle
    TabOrder = 1
    OnClick = cxDBPivotGridClick
    OnDblClick = cxDBPivotGridDblClick
    ExplicitWidth = 403
    ExplicitHeight = 294
  end
  object pnlDescrizione: TdxPanel
    Left = 582
    Top = 29
    Width = 100
    Height = 356
    Align = alRight
    Frame.Color = clBtnShadow
    Frame.Drag.Enabled = True
    TabOrder = 6
    Visible = False
    ExplicitLeft = 409
    ExplicitHeight = 300
  end
  object DataSource: TDataSource
    OnStateChange = DataSourceStateChange
    OnDataChange = DataSourceDataChange
    Left = 380
    Top = 92
  end
  object ActionList: TActionList
    Images = dx.Immagini
    OnUpdate = ActionListUpdate
    Left = 376
    Top = 36
    object EditUndo: TEditUndo
      Category = 'Edit_Control'
      Caption = 'Annulla'
      Hint = 'annulla'
      ImageIndex = 54
      ShortCut = 16474
    end
    object EditCut: TEditCut
      Category = 'Edit_Control'
      Caption = 'Taglia'
      Hint = 'taglia'
      ImageIndex = 65
      ShortCut = 16472
    end
    object EditCopy: TEditCopy
      Category = 'Edit_Control'
      Caption = '&Copia'
      Hint = 'copia'
      ImageIndex = 64
      ShortCut = 16451
    end
    object EditPaste: TEditPaste
      Category = 'Edit_Control'
      Caption = '&Incolla'
      Hint = 'incolla'
      ImageIndex = 85
      ShortCut = 16470
    end
    object EditDelete: TEditDelete
      Category = 'Edit_Control'
      Caption = '&Elimina'
      Hint = 'elimina'
      ImageIndex = 66
      ShortCut = 8238
    end
    object EditSelectAll: TEditSelectAll
      Category = 'Edit_Control'
      Caption = 'Seleziona tutto'
      Hint = 'seleziona tutto'
      ImageIndex = 194
      ShortCut = 16449
    end
    object Incolonna: TzFocusedAction
      Category = 'Other'
      Caption = 'Incolonna'
      ImageIndex = 235
      OnExecute = IncolonnaExecute
    end
    object SalvaImpostazioni: TzFocusedAction
      Category = 'Design'
      Caption = 'Salva Impostazioni'
      ImageIndex = 524
      OnExecute = SalvaImpostazioniExecute
    end
    object CaricaImpostazioni: TzFocusedAction
      Category = 'Design'
      Caption = 'Carica Impostazioni'
      ImageIndex = 521
      OnExecute = CaricaImpostazioniExecute
    end
    object actResetColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Reset Colonne'
      ImageIndex = 543
      OnExecute = actResetColonneExecute
    end
    object actSQL: TzFocusedAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 220
      ShortCut = 57432
      OnExecute = actSQLExecute
    end
    object actDbFirst: TzFocusedAction
      Category = 'Dataset'
      Caption = 'All'#39'inizio'
      Hint = 'All'#39'inizio'
      ImageIndex = 146
      ShortCut = 16420
      OnExecute = actDbFirstExecute
    end
    object actDbPrior: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Precedente'
      Hint = 'Precedente'
      ImageIndex = 168
      ShortCut = 16417
      OnExecute = actDbPriorExecute
    end
    object actDbNext: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Successivo'
      Hint = 'Successivo'
      ImageIndex = 161
      ShortCut = 16418
      OnExecute = actDbNextExecute
    end
    object actDbLast: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Ultimo'
      Hint = 'Ultimo'
      ImageIndex = 156
      ShortCut = 16419
      OnExecute = actDbLastExecute
    end
    object actPersonalizza: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza griglia...'
      ImageIndex = 512
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
    end
    object actDbRefresh: TDataSetRefresh
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = actDbRefreshExecute
      DataSource = DataSource
    end
    object Elabora: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elabora'
      ImageIndex = 165
      OnExecute = ElaboraExecute
    end
    object actPersonalizzaColonna: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza Colonna'
      ImageIndex = 270
      ShortCut = 16506
      OnExecute = actPersonalizzaColonnaExecute
    end
    object MostraQueryUtilizzata: TzFocusedAction
      Category = 'Debug'
      Caption = 'Mostra Query Utilizzata'
      ImageIndex = 244
      OnExecute = MostraQueryUtilizzataExecute
    end
    object CopiaQueryUtilizzata: TzFocusedAction
      Category = 'Debug'
      Caption = 'Copia Query Utilizzata'
      ImageIndex = 62
      OnExecute = CopiaQueryUtilizzataExecute
    end
    object CopyName: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia PivotID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
    end
    object SelezionaCampi: TzFocusedAction
      Category = 'Design'
      Caption = 'Campi...'
      ImageIndex = 217
      OnExecute = SelezionaCampiExecute
    end
    object actExcel: TdxFileSaveAs
      Category = 'Export'
      Caption = 'Excel'
      Dialog.DefaultExt = '*.xls'
      Dialog.Filter = 
        'Excel|*.xlsx|Excel (solo dati)|*.xlsx|Excel 97|*.xls|Excel 97 (s' +
        'olo dati)|*.xls'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      Hint = 'esporta in excel'
      ImageIndex = 225
      BeforeExecute = actExcelBeforeExecute
      OnAccept = actExcelAccept
    end
    object ClearIniSectionAllUsers: TzFocusedAction
      Category = 'Design'
      Caption = 'Clear Ini'
      OnExecute = ClearIniSectionAllUsersExecute
    end
    object NomeFileIni: TzFocusedAction
      Category = 'Design'
      Caption = 'Nome File Ini'
      OnExecute = NomeFileIniExecute
    end
    object Espandi: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Espandi'
      ImageIndex = 124
      OnExecute = EspandiExecute
    end
    object Riduci: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Riduci'
      ImageIndex = 126
      OnExecute = RiduciExecute
    end
    object Descrizione: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
    end
    object EditTools: TzFocusedAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
    object actFiltroPerValore: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Filtro per valore (F3)'
      Hint = 
        'filtra la riga selezionata per valore: testo = inizia per, testo' +
        '* = contiene, vuoto = togli'
      ImageIndex = 188
      OnExecute = actFiltroPerValoreExecute
    end
    object actFiltriAvanzati: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Filtri avanzati... (F4)'
      Hint = 'apri la finestra dei filtri avanzati'
      ImageIndex = 80
      OnExecute = actFiltriAvanzatiExecute
    end
    object actEliminaFiltri: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Elimina filtri (Ctrl+Backspace)'
      Hint = 'togli tutti i filtri applicati al pivot'
      ImageIndex = 57
      OnExecute = actEliminaFiltriExecute
    end
    object actSoloQuestoValore: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Solo questo valore'
      Hint = 'mostra solo il valore selezionato'
      OnExecute = actSoloQuestoValoreExecute
    end
    object actEscludiQuestoValore: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Escludi questo valore'
      Hint = 'nascondi il valore selezionato'
      OnExecute = actEscludiQuestoValoreExecute
    end
  end
  object dxBarManager: TdxBarManager
    AutoAlignBars = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    CanCustomize = False
    Categories.Strings = (
      'Default'
      'Design'
      'Other'
      'Dataset'
      'Export'
      'Edit')
    Categories.ItemsVisibles = (
      2
      2
      2
      2
      2
      2)
    Categories.Visibles = (
      True
      True
      True
      True
      True
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.LargeImages = dx.Immagini
    ImageOptions.LargeIcons = True
    ImageOptions.UseLargeImagesForLargeIcons = True
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <
      item
        PopupMenu = popPivot
      end>
    UseSystemFont = True
    OnShowToolbarsPopup = dxBarManagerShowToolbarsPopup
    Left = 297
    Top = 48
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      29
      0)
    object dxBarToolbar: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'Toolbar'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 816
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarControlContainerTitolo'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbFirst'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbPrior'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbNext'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbLast'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbRefresh'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton14'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton13'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonParametri'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarToolbarFree: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'ToolbarFree'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 403
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 816
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object dxBarControlContainerTitolo: TdxBarControlContainerItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      Control = Titolo
    end
    object dxBarButton1: TdxBarButton
      Action = actPersonalizzaColonna
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actResetColonne
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = CaricaImpostazioni
      Category = 0
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          Visible = True
          ItemName = 'dxBarButton11'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton16'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          Visible = True
          ItemName = 'dxBarButton6'
        end>
    end
    object dxBarButton5: TdxBarButton
      Action = MostraQueryUtilizzata
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = CopiaQueryUtilizzata
      Category = 0
    end
    object dxBarEditTitolo: TcxBarEditItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      OnChange = dxBarEditTitoloChange
      PropertiesClassName = 'TcxTextEditProperties'
      InternalEditValue = ''
    end
    object dxBarButton10: TdxBarButton
      Action = CopyName
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = ClearIniSectionAllUsers
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = NomeFileIni
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = Espandi
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = Riduci
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'New SubItem'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxBarButton12: TdxBarButton
      Action = Riduci
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = Espandi
      Category = 0
    end
    object dxBarButton14: TdxBarButton
      Action = Incolonna
      Category = 0
    end
    object dxBarButton15: TdxBarButton
      Action = Descrizione
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton16: TdxBarButton
      Action = EditTools
      Category = 0
    end
    object dxBarButtonactFiltroPerValore: TdxBarButton
      Action = actFiltroPerValore
      Category = 0
    end
    object dxBarButtonactFiltriAvanzati: TdxBarButton
      Action = actFiltriAvanzati
      Category = 0
    end
    object dxBarButtonactEliminaFiltri: TdxBarButton
      Action = actEliminaFiltri
      Category = 0
    end
    object dxBarButtonactSoloQuestoValore: TdxBarButton
      Action = actSoloQuestoValore
      Category = 0
    end
    object dxBarButtonactEscludiQuestoValore: TdxBarButton
      Action = actEscludiQuestoValore
      Category = 0
    end
    object dxBarButtonSalvaImpostazioni: TdxBarButton
      Action = SalvaImpostazioni
      Category = 1
    end
    object dxBarButtonCaricaImpostazioni: TdxBarButton
      Action = CaricaImpostazioni
      Category = 1
    end
    object dxBarButtonSelezionaColonne: TdxBarButton
      Action = SelezionaCampi
      Category = 1
    end
    object dxBarButtonactSQL: TdxBarButton
      Action = actSQL
      Category = 1
    end
    object dxBarButtonactPersonalizza: TdxBarButton
      Action = actPersonalizza
      Category = 1
    end
    object dxBarButtonIncolonna: TdxBarButton
      Action = Incolonna
      Category = 2
    end
    object dxBarButtonactDbFirst: TdxBarButton
      Action = actDbFirst
      Category = 3
    end
    object dxBarButtonactDbPrior: TdxBarButton
      Action = actDbPrior
      Category = 3
    end
    object dxBarButtonactDbNext: TdxBarButton
      Action = actDbNext
      Category = 3
    end
    object dxBarButtonactDbLast: TdxBarButton
      Action = actDbLast
      Category = 3
    end
    object dxBarButtonactDbRefresh: TdxBarButton
      Action = actDbRefresh
      Category = 3
    end
    object dxBarButtonParametri: TdxBarButton
      Action = Elabora
      Category = 3
    end
    object dxBarButtonactExcel: TdxBarButton
      Action = actExcel
      Category = 4
    end
    object dxBarButtonEditUndo: TdxBarButton
      Action = EditUndo
      Category = 5
    end
    object dxBarButtonEditCut: TdxBarButton
      Action = EditCut
      Category = 5
    end
    object dxBarButtonEditCopy: TdxBarButton
      Action = EditCopy
      Category = 5
    end
    object dxBarButtonEditPaste: TdxBarButton
      Action = EditPaste
      Category = 5
    end
    object dxBarButtonEditDelete: TdxBarButton
      Action = EditDelete
      Category = 5
    end
    object dxBarButtonEditSelectAll: TdxBarButton
      Action = EditSelectAll
      Category = 5
    end
  end
  object popPivot: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonParametri'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbRefresh'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactExcel'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactFiltroPerValore'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactSoloQuestoValore'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactEscludiQuestoValore'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactFiltriAvanzati'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactEliminaFiltri'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton4'
      end
      item
        Visible = True
        ItemName = 'dxBarButton7'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonIncolonna'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSelezionaColonne'
      end
      item
        Visible = True
        ItemName = 'dxBarButton1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditTitolo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton15'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItemImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSalvaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButton3'
      end
      item
        Visible = True
        ItemName = 'dxBarButton10'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactSQL'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizza'
      end>
    UseOwnFont = False
    OnPopup = PopupGridPopup
    Left = 297
    Top = 98
    PixelsPerInch = 96
  end
  object popField: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonEditUndo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCut'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCopy'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditPaste'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditDelete'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditSelectAll'
      end>
    UseOwnFont = False
    Left = 297
    Top = 149
    PixelsPerInch = 96
  end
  object cxStyleRepository: TcxStyleRepository
    Left = 96
    Top = 192
    PixelsPerInch = 96
    object cxStyleRed: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = 3158240
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3158240
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
    end
    object cxStyleBold: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
  end
end
