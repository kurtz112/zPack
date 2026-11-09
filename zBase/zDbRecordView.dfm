object zDbRecordView: TzDbRecordView
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
    PopupMenu = popRecordView
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
  end
  object cxDBVerticalGrid: TcxDBVerticalGrid
    AlignWithMargins = True
    Left = 3
    Top = 32
    Width = 576
    Height = 350
    Align = alClient
    OptionsView.RowHeaderWidth = 150
    OptionsView.ValueWidth = 200
    OptionsData.CancelOnExit = False
    OptionsData.Appending = False
    OptionsData.Deleting = False
    OptionsData.DeletingConfirmation = False
    OptionsData.Inserting = False
    PopupMenu = popRecordView
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 1
    DataController.DataSource = DataSource
    Version = 1
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
    object actDbRefresh: TDataSetRefresh
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = actDbRefreshExecute
      DataSource = DataSource
    end
    object actDbEdit: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Modifica'
      Hint = 'Modifica il record'
      ImageIndex = 44
      ShortCut = 113
      OnExecute = actDbEditExecute
    end
    object actDbInsert: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Inserisci'
      Hint = 'Inserisci un record'
      ImageIndex = 38
      ShortCut = 118
      OnExecute = actDbInsertExecute
    end
    object actDbDelete: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elimina'
      Hint = 'Elimina il record'
      ImageIndex = 500
      ShortCut = 16430
      OnExecute = actDbDeleteExecute
    end
    object actDbPost: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Applica'
      Hint = 'Salva le modifiche'
      ImageIndex = 40
      ShortCut = 16397
      OnExecute = actDbPostExecute
    end
    object actDbCancel: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Annulla'
      Hint = 'Annulla le modifiche'
      ImageIndex = 43
      OnExecute = actDbCancelExecute
    end
    object actTrovaCampo: TzFocusedAction
      Category = 'Other'
      Caption = 'Trova campo'
      Hint = 'Trova un campo per etichetta (Ctrl+F)'
      ImageIndex = 189
      OnExecute = actTrovaCampoExecute
    end
    object actNascondiVuote: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Nascondi campi vuoti'
      Hint = 'Mostra solo i campi valorizzati nel record corrente'
      OnExecute = actNascondiVuoteExecute
    end
    object actConfronta: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Confronta record'
      Hint = 'Affianca piu'#39' record ed evidenzia le differenze'
      OnExecute = actConfrontaExecute
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
    object AdattaLarghezze: TzFocusedAction
      Category = 'Other'
      Caption = 'Adatta etichette'
      Hint = 'Adatta la larghezza delle etichette'
      ImageIndex = 438
      OnExecute = AdattaLarghezzeExecute
    end
    object Elabora: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elabora'
      ImageIndex = 165
      OnExecute = ElaboraExecute
    end
    object actExcel: TdxFileSaveAs
      Category = 'Export'
      Caption = 'Excel'
      Dialog.DefaultExt = '*.xlsx'
      Dialog.Filter = 'Excel|*.xlsx|Excel 97|*.xls|CSV|*.csv'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      Hint = 'esporta in excel'
      ImageIndex = 225
      BeforeExecute = actExcelBeforeExecute
      OnAccept = actExcelAccept
    end
    object actStampa: TzFocusedAction
      Category = 'Export'
      Caption = 'Stampa'
      Hint = 'Anteprima di stampa'
      ShortCut = 16464
      OnExecute = actStampaExecute
    end
    object Descrizione: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
    end
    object RipristinaLayout: TzFocusedAction
      Category = 'Other'
      Caption = 'Ripristina layout'
      Hint = 'Torna al layout predefinito della vista'
      ImageIndex = 510
      OnExecute = RipristinaLayoutExecute
    end
    object actPersonalizza: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza la vista...'
      ImageIndex = 512
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
    end
    object actPersonalizzaRighe: TzFocusedAction
      Category = 'Design'
      Caption = 'Righe e categorie...'
      Hint = 
        'Sposta, nascondi e raccogli le righe in categorie; poi Salva Imp' +
        'ostazioni'
      ImageIndex = 217
      OnExecute = actPersonalizzaRigheExecute
    end
    object actPersonalizzaRiga: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza Riga'
      ImageIndex = 270
      OnExecute = actPersonalizzaRigaExecute
    end
    object actPersonalizzaCampo: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza Campo'
      ImageIndex = 270
      ShortCut = 16506
      OnExecute = actPersonalizzaCampoExecute
    end
    object actResetRighe: TzFocusedAction
      Category = 'Design'
      Caption = 'Reset Righe'
      OnExecute = actResetRigheExecute
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
    object actSQL: TzFocusedAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 220
      ShortCut = 57432
      OnExecute = actSQLExecute
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
      Caption = 'Copia RecordViewID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
    end
    object NomeFileIni: TzFocusedAction
      Category = 'Design'
      Caption = 'Nome File Layout'
      OnExecute = NomeFileIniExecute
    end
    object EditTools: TzFocusedAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
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
        PopupMenu = popRecordView
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
          ItemName = 'dxBarButtonactDbInsert'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbEdit'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbDelete'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbPost'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbCancel'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactTrovaCampo'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonEspandi'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonRiduci'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonElabora'
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
      DockedLeft = 528
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
    object dxBarEditTitolo: TcxBarEditItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      OnChange = dxBarEditTitoloChange
      PropertiesClassName = 'TcxTextEditProperties'
      InternalEditValue = ''
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButtonactResetRighe'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonNomeFileIni'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonEditTools'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonMostraQueryUtilizzata'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonCopiaQueryUtilizzata'
        end>
    end
    object dxBarButtonactPersonalizza: TdxBarButton
      Action = actPersonalizza
      Category = 1
    end
    object dxBarButtonactPersonalizzaRighe: TdxBarButton
      Action = actPersonalizzaRighe
      Category = 1
    end
    object dxBarButtonactPersonalizzaRiga: TdxBarButton
      Action = actPersonalizzaRiga
      Category = 1
    end
    object dxBarButtonactPersonalizzaCampo: TdxBarButton
      Action = actPersonalizzaCampo
      Category = 1
    end
    object dxBarButtonactResetRighe: TdxBarButton
      Action = actResetRighe
      Category = 1
    end
    object dxBarButtonSalvaImpostazioni: TdxBarButton
      Action = SalvaImpostazioni
      Category = 1
    end
    object dxBarButtonCaricaImpostazioni: TdxBarButton
      Action = CaricaImpostazioni
      Category = 1
    end
    object dxBarButtonactSQL: TdxBarButton
      Action = actSQL
      Category = 1
    end
    object dxBarButtonMostraQueryUtilizzata: TdxBarButton
      Action = MostraQueryUtilizzata
      Category = 1
    end
    object dxBarButtonCopiaQueryUtilizzata: TdxBarButton
      Action = CopiaQueryUtilizzata
      Category = 1
    end
    object dxBarButtonCopyName: TdxBarButton
      Action = CopyName
      Category = 1
    end
    object dxBarButtonNomeFileIni: TdxBarButton
      Action = NomeFileIni
      Category = 1
    end
    object dxBarButtonEditTools: TdxBarButton
      Action = EditTools
      Category = 1
    end
    object dxBarButtonactTrovaCampo: TdxBarButton
      Action = actTrovaCampo
      Category = 2
    end
    object dxBarButtonactNascondiVuote: TdxBarButton
      Action = actNascondiVuote
      Category = 2
      ButtonStyle = bsChecked
    end
    object dxBarButtonactConfronta: TdxBarButton
      Action = actConfronta
      Category = 2
      ButtonStyle = bsChecked
    end
    object dxBarButtonAdattaLarghezze: TdxBarButton
      Action = AdattaLarghezze
      Category = 2
    end
    object dxBarButtonDescrizione: TdxBarButton
      Action = Descrizione
      Category = 2
      ButtonStyle = bsChecked
    end
    object dxBarButtonRipristinaLayout: TdxBarButton
      Action = RipristinaLayout
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
    object dxBarButtonactDbInsert: TdxBarButton
      Action = actDbInsert
      Category = 3
    end
    object dxBarButtonactDbEdit: TdxBarButton
      Action = actDbEdit
      Category = 3
    end
    object dxBarButtonactDbDelete: TdxBarButton
      Action = actDbDelete
      Category = 3
    end
    object dxBarButtonactDbPost: TdxBarButton
      Action = actDbPost
      Category = 3
    end
    object dxBarButtonactDbCancel: TdxBarButton
      Action = actDbCancel
      Category = 3
    end
    object dxBarButtonElabora: TdxBarButton
      Action = Elabora
      Category = 3
    end
    object dxBarButtonEspandi: TdxBarButton
      Action = Espandi
      Category = 3
    end
    object dxBarButtonRiduci: TdxBarButton
      Action = Riduci
      Category = 3
    end
    object dxBarButtonactExcel: TdxBarButton
      Action = actExcel
      Category = 4
    end
    object dxBarButtonactStampa: TdxBarButton
      Action = actStampa
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
  object popRecordView: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonElabora'
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
        Visible = True
        ItemName = 'dxBarButtonactStampa'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactTrovaCampo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactNascondiVuote'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactConfronta'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonEspandi'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRiduci'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonAdattaLarghezze'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRipristinaLayout'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditTitolo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonDescrizione'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItemImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaRighe'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaRiga'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaCampo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSalvaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonCaricaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonCopyName'
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
    OnPopup = PopupRecordViewPopup
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
    object cxStyleBold: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
    object cxStyleDifferent: TcxStyle
      AssignedValues = [svColor]
      Color = 13434879
    end
  end
end
