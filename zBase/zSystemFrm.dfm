object zSystemForm: TzSystemForm
  Left = 658
  Top = 232
  ClientHeight = 539
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  Position = poScreenCenter
  ScreenSnap = True
  TextHeight = 15
  object OkCancel1: TOkCancel
    Left = 0
    Top = 511
    Width = 784
    Height = 28
    Align = alBottom
    TabOrder = 0
    DefaultOk = False
    DefaultCancel = False
    OnApply = OkCancel1Apply
  end
  object SearchPanel: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 27
    Width = 778
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    ShowCaption = False
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 12
      Width = 36
      Height = 15
      Caption = 'Cerca:'
    end
    object edCerca: TcxTextEdit
      Left = 60
      Top = 9
      TabOrder = 0
      Width = 265
    end
    object cxButton1: TcxButton
      Left = 328
      Top = 8
      Width = 75
      Height = 25
      Action = CercaDallInizio
      TabOrder = 1
    end
    object cxButton2: TcxButton
      Left = 408
      Top = 8
      Width = 100
      Height = 25
      Action = CercaSuccessivo
      TabOrder = 2
    end
  end
  object pageMain: TcxPageControl
    AlignWithMargins = True
    Left = 3
    Top = 74
    Width = 778
    Height = 434
    Align = alClient
    TabOrder = 6
    Properties.ActivePage = tabVerifyResults
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 430
    ClientRectLeft = 4
    ClientRectRight = 774
    ClientRectTop = 26
    object tabSystem: TcxTabSheet
      Caption = 'Sistema'
      ImageIndex = 0
      object FrameCollection: TFrameCollection
        Left = 0
        Top = 0
        Width = 770
        Height = 404
        Align = alClient
        PopupMenu = PopupMenu
        TabOrder = 0
        CheckBoxes = False
      end
    end
    object tabMetadata: TcxTabSheet
      Caption = 'Metadata'
      ImageIndex = 1
      OnShow = cxTabSheet2Show
      object FrameMetadata: TFrameMetadata
        Left = 0
        Top = 0
        Width = 770
        Height = 404
        Align = alClient
        TabOrder = 0
      end
    end
    object tabVerifyResults: TcxTabSheet
      Caption = 'Verifiche'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object VerifyTree: TcxTreeList
        Left = 0
        Top = 137
        Width = 770
        Height = 267
        Align = alClient
        Bands = <
          item
          end>
        Images = VerificheImageList
        OptionsCustomizing.ColumnFiltering = bTrue
        OptionsData.Deleting = False
        OptionsSelection.MultiSelect = True
        OptionsView.GridLines = tlglBoth
        PopupMenu = popVerifyTree
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 0
        OnCollapsed = VerifyTreeCollapsed
        OnCustomDrawDataCell = VerifyTreeCustomDrawDataCell
        OnDblClick = VerifyTreeDblClick
        OnExpanded = VerifyTreeExpanded
        OnResize = VerifyTreeResize
        OnSelectionChanged = VerifyTreeSelectionChanged
        ExplicitTop = 138
        object colSeverity: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          BestFitMaxWidth = 150
          Caption.Text = 'Severit'#224
          Width = 150
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colCategory: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          BestFitMaxWidth = 200
          Caption.Text = 'Categoria'
          Width = 200
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colSubItem: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Caption.Text = 'Dettaglio'
          Width = 120
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colMessage: TcxTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Caption.Text = 'Messaggio'
          Width = 300
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
      end
      object layoutVerifica: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 770
        Height = 137
        Align = alTop
        TabOrder = 1
        AutoSize = True
        object btnRecheck: TcxButton
          Left = 11
          Top = 98
          Width = 120
          Height = 25
          Action = VerificaRiVerifica
          TabOrder = 14
        end
        object btnFixSelected: TcxButton
          Left = 137
          Top = 98
          Width = 140
          Height = 25
          Action = VerificaRiparaSelezionato
          TabOrder = 15
        end
        object btnFixAllSafe: TcxButton
          Left = 283
          Top = 98
          Width = 160
          Height = 25
          Action = VerificaRiparaTutti
          TabOrder = 16
        end
        object btnPurgeDeadDomains: TcxButton
          Left = 449
          Top = 98
          Width = 200
          Height = 25
          Action = VerificaRimuoviDominiObsoleti
          TabOrder = 17
        end
        object chkStopOnFirstError: TcxCheckBox
          Left = 11
          Top = 11
          Caption = '1'#176' errore'
          TabOrder = 0
          Transparent = True
        end
        object chkCheckSql: TcxCheckBox
          Left = 117
          Top = 11
          Caption = 'Check SQL'
          TabOrder = 1
          Transparent = True
        end
        object chkCheckEmptySelect: TcxCheckBox
          Left = 223
          Top = 11
          Caption = 'Select vuoto'
          TabOrder = 2
          Transparent = True
        end
        object chkCheckStoredProcs: TcxCheckBox
          Left = 329
          Top = 11
          Caption = 'Stored Proc'
          TabOrder = 3
          Transparent = True
        end
        object chkCheckLookups: TcxCheckBox
          Left = 435
          Top = 11
          Caption = 'Lookup'
          TabOrder = 4
          Transparent = True
        end
        object chkCheckLookupFieldsExist: TcxCheckBox
          Left = 541
          Top = 11
          Caption = 'Campi LK'
          TabOrder = 5
          Transparent = True
        end
        object chkCheckRefIntegrity: TcxCheckBox
          Left = 11
          Top = 40
          Caption = 'Integrit'#224' ref.'
          TabOrder = 6
          Transparent = True
        end
        object chkCheckDomainDataSet: TcxCheckBox
          Left = 117
          Top = 40
          Caption = 'Copertura DS'
          TabOrder = 7
          Transparent = True
        end
        object chkCheckAutoSql: TcxCheckBox
          Left = 223
          Top = 40
          Caption = 'AutoSQL'
          TabOrder = 8
          Transparent = True
        end
        object chkCheckLookupCardinality: TcxCheckBox
          Left = 329
          Top = 40
          Caption = 'Cardinalit'#224
          TabOrder = 9
          Transparent = True
        end
        object chkCheckDuplicates: TcxCheckBox
          Left = 435
          Top = 40
          Caption = 'Duplicati'
          TabOrder = 10
          Transparent = True
        end
        object chkCheckGenerators: TcxCheckBox
          Left = 541
          Top = 40
          Caption = 'Generatori'
          TabOrder = 11
          Transparent = True
        end
        object chkCheckSeparators: TcxCheckBox
          Left = 11
          Top = 69
          Caption = 'Separatori'
          TabOrder = 12
          Transparent = True
        end
        object chkLookupMappingsWarning: TcxCheckBox
          Left = 117
          Top = 69
          Caption = 'Mappings'
          TabOrder = 13
          Transparent = True
        end
        object chkCheckDomainExists: TcxCheckBox
          Left = 223
          Top = 69
          Caption = 'Domini morti'
          TabOrder = 18
          Transparent = True
        end
        object layoutVerificaGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avClient
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object dxLayoutItemVerificaRiVerifica: TdxLayoutItem
          Parent = dxLayoutGroupBottoni
          CaptionOptions.Text = 'btnRecheck'
          CaptionOptions.Visible = False
          Control = btnRecheck
          ControlOptions.OriginalHeight = 25
          ControlOptions.OriginalWidth = 120
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItemVerificaRiparaSelezionato: TdxLayoutItem
          Parent = dxLayoutGroupBottoni
          CaptionOptions.Text = 'btnFixSelected'
          CaptionOptions.Visible = False
          Control = btnFixSelected
          ControlOptions.OriginalHeight = 25
          ControlOptions.OriginalWidth = 140
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItemVerificaRiparaTutti: TdxLayoutItem
          Parent = dxLayoutGroupBottoni
          CaptionOptions.Text = 'btnFixAllSafe'
          CaptionOptions.Visible = False
          Control = btnFixAllSafe
          ControlOptions.OriginalHeight = 25
          ControlOptions.OriginalWidth = 160
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutItemVerificaPurgeDomini: TdxLayoutItem
          Parent = dxLayoutGroupBottoni
          CaptionOptions.Text = 'btnPurgeDeadDomains'
          CaptionOptions.Visible = False
          Control = btnPurgeDeadDomains
          ControlOptions.OriginalHeight = 25
          ControlOptions.OriginalWidth = 200
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItemStopOnFirstError: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkStopOnFirstError
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItemCheckSql: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckSql
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 84
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItemCheckEmptySelect: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckEmptySelect
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 88
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutItemCheckStoredProcs: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckStoredProcs
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 86
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItemCheckLookups: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckLookups
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 63
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object dxLayoutItemCheckLookupFieldsExist: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow1
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckLookupFieldsExist
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 77
          ControlOptions.ShowBorder = False
          Index = 5
        end
        object dxLayoutItemCheckRefIntegrity: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckRefIntegrity
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 86
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItemCheckDomainDataSet: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckDomainDataSet
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 86
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItemCheckAutoSql: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckAutoSql
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutItemCheckLookupCardinality: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckLookupCardinality
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 82
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object dxLayoutItemCheckDuplicates: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckDuplicates
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object dxLayoutItemCheckGenerators: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow2
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckGenerators
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 80
          ControlOptions.ShowBorder = False
          Index = 5
        end
        object dxLayoutItemCheckSeparators: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow3
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckSeparators
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 79
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object dxLayoutItemLookupMappingsWarning: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow3
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkLookupMappingsWarning
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 76
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object dxLayoutItemCheckDomainExists: TdxLayoutItem
          Parent = dxLayoutGroupFlagsRow3
          SizeOptions.Width = 100
          CaptionOptions.Visible = False
          Control = chkCheckDomainExists
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 88
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object dxLayoutGroupBottoni: TdxLayoutGroup
          Parent = layoutVerificaGroup_Root
          AlignHorz = ahLeft
          AlignVert = avTop
          CaptionOptions.Text = 'New Group'
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object dxLayoutGroupFlagsRow1: TdxLayoutGroup
          Parent = dxLayoutGroupFlags
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object dxLayoutGroupFlagsRow2: TdxLayoutGroup
          Parent = dxLayoutGroupFlags
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object dxLayoutGroupFlagsRow3: TdxLayoutGroup
          Parent = dxLayoutGroupFlags
          AlignHorz = ahClient
          AlignVert = avTop
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object dxLayoutGroupFlags: TdxLayoutGroup
          Parent = layoutVerificaGroup_Root
          CaptionOptions.Visible = False
          ShowBorder = False
          Index = 0
        end
      end
    end
    object tabRename: TcxTabSheet
      Caption = 'Rename SQL'
      object PanelRenameTop: TPanel
        Left = 0
        Top = 0
        Width = 770
        Height = 96
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblRenameMode: TcxLabel
          Left = 6
          Top = 9
          Caption = 'Modalit'#224':'
          TabOrder = 7
        end
        object lblRenameQualifier: TcxLabel
          Left = 6
          Top = 39
          Caption = 'Qualificatore (tab/alias):'
          TabOrder = 8
        end
        object lblRenameOld: TcxLabel
          Left = 280
          Top = 39
          Caption = 'Da:'
          TabOrder = 9
        end
        object lblRenameNew: TcxLabel
          Left = 440
          Top = 39
          Caption = 'A:'
          TabOrder = 10
        end
        object cbRenameMode: TcxComboBox
          Left = 80
          Top = 6
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Tabella'
            'Campo (globale)'
            'Campo (qualificato)')
          TabOrder = 0
          Text = 'Tabella'
          Width = 180
        end
        object chkRenameCase: TcxCheckBox
          Left = 280
          Top = 6
          Caption = 'Case-sensitive'
          TabOrder = 1
          Transparent = True
        end
        object edRenameQualifier: TcxTextEdit
          Left = 160
          Top = 36
          TabOrder = 2
          Width = 100
        end
        object edRenameOld: TcxTextEdit
          Left = 310
          Top = 36
          TabOrder = 3
          Width = 120
        end
        object edRenameNew: TcxTextEdit
          Left = 460
          Top = 36
          TabOrder = 4
          Width = 120
        end
        object btnRenamePreview: TcxButton
          Left = 6
          Top = 68
          Width = 120
          Height = 25
          Action = RenameAnteprima
          TabOrder = 5
        end
        object btnRenameApply: TcxButton
          Left = 132
          Top = 68
          Width = 160
          Height = 25
          Action = RenameApplica
          TabOrder = 6
        end
      end
      object RenameTree: TcxTreeList
        Left = 0
        Top = 96
        Width = 770
        Height = 308
        Align = alClient
        Bands = <
          item
          end>
        OptionsCustomizing.ColumnFiltering = bTrue
        OptionsData.Editing = False
        OptionsView.ColumnAutoWidth = True
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 1
        OnDblClick = RenameTreeDblClick
        object colRnObject: TcxTreeListColumn
          Caption.Text = 'Oggetto'
          Width = 160
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colRnScript: TcxTreeListColumn
          Caption.Text = 'Script'
          Width = 90
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colRnLine: TcxTreeListColumn
          Caption.Text = 'Riga'
          Width = 50
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colRnStatus: TcxTreeListColumn
          Caption.Text = 'Stato'
          Width = 90
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
        object colRnPreview: TcxTreeListColumn
          Caption.Text = 'Anteprima'
          Width = 300
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
      end
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 128
    Top = 120
    object RenameAnteprima: TAction
      Caption = 'Anteprima'
      OnExecute = RenameAnteprimaExecute
    end
    object RenameApplica: TAction
      Caption = 'Applica Rename'
      OnExecute = RenameApplicaExecute
    end
    object Verifica: TAction
      Caption = 'Verifica Sql/Strutture'
      ImageIndex = 55
      ShortCut = 120
      OnExecute = VerificaExecute
    end
    object VerificaRiVerifica: TAction
      Caption = 'Ri-Verifica'
      OnExecute = VerificaRiVerificaExecute
    end
    object VerificaRiparaSelezionato: TAction
      Caption = 'Ripara Selezionato'
      OnExecute = VerificaRiparaSelezionatoExecute
    end
    object VerificaRiparaTutti: TAction
      Caption = 'Ripara Tutti'
      OnExecute = VerificaRiparaTuttiExecute
    end
    object VerificaRimuoviDominiObsoleti: TAction
      Caption = 'Rimuovi Domini Obsoleti'
      Hint =
        'Elimina dall'#39'LZ i domini non pi'#249' presenti nel database e non usa' +
        'ti da alcuna DbView/DbCard/DbPivot'
      OnExecute = VerificaRimuoviDominiObsoletiExecute
    end
    object VerificaApplyBestFit: TAction
      Caption = 'Incolonna'
      OnExecute = VerificaApplyBestFitExecute
    end
    object VerificaElimina: TAction
      Caption = 'Elimina'
      ImageIndex = 66
      OnExecute = VerificaEliminaExecute
    end
    object Nuovo: TAction
      Caption = 'Nuovo'
      ImageIndex = 38
      OnExecute = NuovoExecute
    end
    object Elimina: TAction
      Caption = 'Elimina'
      ImageIndex = 66
      OnExecute = EliminaExecute
    end
    object SelezionaTutto: TAction
      Caption = 'Seleziona Tutto'
      ShortCut = 16449
    end
    object Aggiorna: TAction
      Caption = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = AggiornaExecute
    end
    object AggiornaCache: TAction
      Caption = 'Aggiorna Cache'
      ImageIndex = 88
      OnExecute = AggiornaCacheExecute
    end
    object Duplica: TAction
      Caption = 'Duplica'
      ImageIndex = 42
      OnExecute = DuplicaExecute
    end
    object Sicurezza: TAction
      Caption = 'Sicurezza'
      ImageIndex = 506
      OnExecute = SicurezzaExecute
    end
    object Generatori: TAction
      Caption = 'Generatori'
      Hint = 'aggiorna generatori'
      ImageIndex = 519
      OnExecute = GeneratoriExecute
    end
    object GeneraStoredProc: TdxFileSaveAs
      Caption = 'Genera StoredProc'
      Dialog.DefaultExt = '*.pas'
      Dialog.Filter = 'Pascal|*.pas|Tutti|*.*'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      Hint = 'genera sorgente per le StoredProc'
      ImageIndex = 1
      OnAccept = GeneraStoredProcAccept
    end
    object CercaSQL: TAction
      Caption = 'Cerca SQL'
      ImageIndex = 185
      ShortCut = 114
      OnExecute = CercaSQLExecute
    end
    object CercaDallInizio: TAction
      Caption = 'Cerca'
      ImageIndex = 185
      OnExecute = CercaDallInizioExecute
    end
    object CercaSuccessivo: TAction
      Caption = 'Successivo'
      ImageIndex = 161
      ShortCut = 114
      OnExecute = CercaSuccessivoExecute
    end
    object SostituisciSQL: TAction
      Caption = 'Sostituisci SQL'
      ImageIndex = 30
      OnExecute = SostituisciSQLExecute
    end
    object SostituisciCampo: TAction
      Caption = 'Sostituisci Campo'
      Hint = 'sostituisci campo selected/lookup'
      ImageIndex = 202
      OnExecute = SostituisciCampoExecute
    end
    object SostituisciNomeDataset: TAction
      Caption = 'Sostituisci Nome Dataset'
      Hint = 'sostituisci nome dataset in dataset/view/card'
      ImageIndex = 219
      OnExecute = SostituisciNomeDatasetExecute
    end
    object UserConfigFolder: TAction
      Caption = 'Cartella Config Personale'
      ImageIndex = 489
      OnExecute = UserConfigFolderExecute
    end
    object UserPersonalDataFolder: TAction
      Caption = 'Cartella Dati Personale'
      ImageIndex = 489
      OnExecute = UserPersonalDataFolderExecute
    end
    object UsersRootConfigFolder: TAction
      Caption = 'Root Cartella Utenti'
      ImageIndex = 489
      OnExecute = UsersRootConfigFolderExecute
    end
    object FilesAppRootFolder: TAction
      Caption = 'Cartella Files'
      ImageIndex = 292
      OnExecute = FilesAppRootFolderExecute
    end
  end
  object PopupMenu: TPopupMenu
    Images = dx.Immagini
    Left = 280
    Top = 160
    object Nuovo1: TMenuItem
      Action = Nuovo
    end
    object Elimina1: TMenuItem
      Action = Elimina
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Duplica1: TMenuItem
      Action = Duplica
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Aggiorna1: TMenuItem
      Action = Aggiorna
    end
  end
  object popVerifyTree: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton18'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton19'
      end>
    UseOwnFont = False
    Left = 488
    Top = 296
    PixelsPerInch = 96
  end
  object TimerEditor: TTimer
    Interval = 100
    OnTimer = TimerEditorTimer
    Left = 208
    Top = 90
  end
  object ProgressBox: TProgressBox
    MaxValue = 0
    Progress = 0
    CancelEnabled = True
    Left = 40
    Top = 128
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.LargeImages = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 280
    Top = 216
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      24
      0)
    object dxBarManagerBar1: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      BorderStyle = bbsNone
      Caption = 'Toolbar'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 744
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton7'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton6'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem1'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton9'
        end>
      NotDocking = [dsNone]
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRecentItems = False
      UseRestSpace = True
      Visible = True
      WholeRow = True
    end
    object dxBarButton1: TdxBarButton
      Action = Nuovo
      Category = 0
      PaintStyle = psCaptionGlyph
    end
    object dxBarButton2: TdxBarButton
      Action = Elimina
      Category = 0
      PaintStyle = psCaptionGlyph
    end
    object dxBarButton3: TdxBarButton
      Action = Aggiorna
      Category = 0
      PaintStyle = psCaptionGlyph
    end
    object dxBarButton4: TdxBarButton
      Action = Generatori
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = AggiornaCache
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = CercaSQL
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = Verifica
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = Sicurezza
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = GeneraStoredProc
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = SostituisciSQL
      Category = 0
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'Strumenti'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton10'
        end
        item
          Visible = True
          ItemName = 'dxBarButton11'
        end
        item
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton14'
        end
        item
          Visible = True
          ItemName = 'dxBarButton15'
        end
        item
          Visible = True
          ItemName = 'dxBarButton16'
        end
        item
          Visible = True
          ItemName = 'dxBarButton17'
        end>
    end
    object dxBarButton11: TdxBarButton
      Action = SostituisciCampo
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = SostituisciNomeDataset
      Category = 0
    end
    object dxBarButton14: TdxBarButton
      Action = UserConfigFolder
      Category = 0
    end
    object dxBarButton15: TdxBarButton
      Action = UserPersonalDataFolder
      Category = 0
    end
    object dxBarButton16: TdxBarButton
      Action = UsersRootConfigFolder
      Category = 0
    end
    object dxBarButton17: TdxBarButton
      Action = FilesAppRootFolder
      Category = 0
    end
    object dxBarButton18: TdxBarButton
      Action = VerificaElimina
      Category = 0
    end
    object dxBarButton19: TdxBarButton
      Action = VerificaApplyBestFit
      Category = 0
    end
  end
  object ReplaceDialog: TReplaceDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown, frReplaceAll]
    OnReplace = ReplaceDialogReplaceSQL
    Left = 280
    Top = 105
  end
  object CollectionImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 17301584
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D22546162
          6C654175746F46697457696E646F772220786D6C6E733D22687474703A2F2F77
          77772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E6B3D
          22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B222078
          3D22307078220A0920793D22307078222076696577426F783D22302030203332
          20333222207374796C653D22656E61626C652D6261636B67726F756E643A6E65
          77203020302033322033323B2220786D6C3A73706163653D2270726573657276
          65223E0A3C7374796C6520747970653D22746578742F637373223E0A092E426C
          61636B7B66696C6C3A233732373237323B7D0A092E426C75657B66696C6C3A23
          3131373744373B7D0A092E7374307B6F7061636974793A302E353B7D0A3C2F73
          74796C653E0A3C7061746820636C6173733D22426C75652220643D224D31302C
          32324832762D3668385632327A204D32302C3136682D38763668385631367A20
          4D33302C3136682D38763668385631367A222F3E0A3C6720636C6173733D2273
          7430223E0A093C7061746820636C6173733D22426C61636B2220643D224D3130
          2C33304832762D3668385633307A204D32302C3234682D38763668385632347A
          204D33302C3234682D38763668385632347A204D342C38683476324834763448
          32762D3456385634683256387A204D32382C347634682D347632683476346832
          762D3456380A090956344832387A222F3E0A3C2F673E0A3C7061746820636C61
          73733D22426C61636B2220643D224D31322E362C392E31632D302E382C302D31
          2E342D302E322D312E392D302E374331302E322C382C31302C372E342C31302C
          362E3663302D302E382C302E322D312E352C302E372D312E3963302E352D302E
          352C312E322D302E372C322D302E370A0963302E382C302C312E342C302E322C
          312E392C302E3663302E342C302E342C302E372C312C302E372C312E3863302C
          302E382D302E322C312E342D302E372C312E394331342C382E382C31332E342C
          392E312C31322E362C392E317A204D32302C346C2D362E322C31304831326C36
          2E322D31304832307A0A09204D31322E372C352E32632D302E372C302D312E31
          2C302E352D312E312C312E3463302C302E392C302E332C312E332C312C312E33
          63302E372C302C312E312D302E352C312E312D312E344331332E372C352E362C
          31332E342C352E322C31322E372C352E327A204D31392E332C31340A09632D30
          2E382C302D312E342D302E322D312E392D302E37632D302E352D302E342D302E
          372D312D302E372D312E3863302D302E382C302E322D312E352C302E372D312E
          3973312E322D302E372C322D302E3763302E382C302C312E342C302E322C312E
          392C302E3673302E372C312C302E372C312E380A0963302C302E382D302E322C
          312E342D302E372C312E395332302E312C31342C31392E332C31347A204D3139
          2E342C31302E31632D302E372C302D312E312C302E352D312E312C312E346330
          2C302E392C302E342C312E332C312E312C312E3363302E372C302C312E312D30
          2E352C312E312D312E340A0963302D302E342D302E312D302E372D302E332D31
          4332302C31302E322C31392E372C31302E312C31392E342C31302E317A222F3E
          0A3C2F7376673E0A}
        FileName = 'tableautofitwindow.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D227461626C655F63
          616C63756C61746F7222207472616E73666F726D3D227363616C6528312E3629
          223E0A093C7061746820643D224D3133203748313756352E3543313720342E31
          313932392031352E3838303720332031342E35203348313356375A4D37203132
          5638483356313248375A4D313220382E34393938325638483856313248313156
          31302E3543313120392E36383230392031312E3339323820382E393535393220
          313220382E34393938325A4D313120313348385631374831315631335A4D3720
          313348335631342E3543332031352E3838303720342E31313932392031372035
          2E3520313748375631335A4D313220375633483856374831325A4D3720335637
          483356352E35433320342E313139323920342E3131393239203320352E352033
          48375A4D31322031302E3543313220392E36373135372031322E363731362039
          2031332E3520394831372E354331382E33323834203920313920392E36373135
          372031392031302E355631372E354331392031382E333238342031382E333238
          342031392031372E352031394831332E354331322E3637313620313920313220
          31382E333238342031322031372E355631302E355A4D31342E35203133483133
          2E354331332E323233392031332031332031332E323233392031332031332E35
          4331332031332E373736312031332E323233392031342031332E352031344831
          342E354331342E373736312031342031352031332E373736312031352031332E
          354331352031332E323233392031342E373736312031332031342E352031335A
          4D31382031332E354331382031332E323233392031372E373736312031332031
          372E352031334831362E354331362E323233392031332031362031332E323233
          392031362031332E354331362031332E373736312031362E3232333920313420
          31362E352031344831372E354331372E373736312031342031382031332E3737
          36312031382031332E355A4D31342E352031354831332E354331332E32323339
          2031352031332031352E323233392031332031352E354331332031352E373736
          312031332E323233392031362031332E352031364831342E354331342E373736
          312031362031352031352E373736312031352031352E354331352031352E3232
          33392031342E373736312031352031342E352031355A4D31382031352E354331
          382031352E323233392031372E373736312031352031372E352031354831362E
          354331362E323233392031352031362031352E323233392031362031352E3543
          31362031352E373736312031362E323233392031362031362E35203136483137
          2E354331372E373736312031362031382031352E373736312031382031352E35
          5A4D31342E352031374831332E354331332E323233392031372031332031372E
          323233392031332031372E354331332031372E373736312031332E3232333920
          31382031332E352031384831342E354331342E37373631203138203135203137
          2E373736312031352031372E354331352031372E323233392031342E37373631
          2031372031342E352031375A4D31382031372E354331382031372E3232333920
          31372E373736312031372031372E352031374831362E354331362E3232333920
          31372031362031372E323233392031362031372E354331362031372E37373631
          2031362E323233392031382031362E352031384831372E354331372E37373631
          2031382031382031372E373736312031382031372E355A4D31332E3520313043
          31332E323233392031302031332031302E323233392031332031302E35563131
          2E354331332031312E373736312031332E323233392031322031332E35203132
          4831372E354331372E373736312031322031382031312E373736312031382031
          312E355631302E354331382031302E323233392031372E373736312031302031
          372E352031304831332E355A2220636C6173733D22426C61636B22202F3E0A3C
          2F673E0A3C2F7376673E0A}
        FileName = 'table_calculator.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C75657B66696C6C3A2331
          31373744373B7D0A3C2F7374796C653E0A3C672069643D2263616C656E646172
          5F7265636F726422207472616E73666F726D3D227363616C6528312E33333333
          333329223E0A093C7061746820643D224D323120382E355631322E3032313843
          31392E393839372031312E3337352031382E373838362031312031372E352031
          314331332E393130312031312031312031332E393130312031312031372E3543
          31312031382E373838362031312E3337352031392E393839372031322E303231
          3820323148362E323543342E343535303720323120332031392E353434392033
          2031372E373556382E354832315A4D31372E373520334331392E353434392033
          20323120342E343535303720323120362E32355637483356362E323543332034
          2E343535303720342E3435353037203320362E323520334831372E37355A4D31
          372E352031332E354331392E373039312031332E352032312E352031352E3239
          30392032312E352031372E354332312E352031392E373039312031392E373039
          312032312E352031372E352032312E354331352E323930392032312E35203133
          2E352031392E373039312031332E352031372E354331332E352031352E323930
          392031352E323930392031332E352031372E352031332E355A4D31372E352032
          334332302E353337362032332032332032302E353337362032332031372E3543
          32332031342E343632342032302E353337362031322031372E35203132433134
          2E343632342031322031322031342E343632342031322031372E354331322032
          302E353337362031342E343632342032332031372E352032335A4D3230203137
          2E354332302031382E383830372031382E383830372032302031372E35203230
          4331362E313139332032302031352031382E383830372031352031372E354331
          352031362E313139332031362E313139332031352031372E352031354331382E
          383830372031352032302031362E313139332032302031372E355A2220636C61
          73733D22426C756522202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'calendar_record.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D22626F6C74222074
          72616E73666F726D3D227363616C6528312E33333333333329223E0A093C7061
          746820643D224D31342C31372E375632314831305632302E334C31342C31372E
          374D31372C334837563648313756334D31352C374C31342C372E375637483130
          5631302E334C392C31315631324C31352C382E3156374D31352C31314C31342C
          31312E3756392E374C31302C31322E345631342E344C392C31355631364C3135
          2C31322E315631314D31352C31354C31342C31352E375631332E374C31302C31
          362E345631382E344C392C31395632304C31352C31362E315631355A2220636C
          6173733D22426C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'bolt.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A2337
          32373237323B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A
          092E426C75657B66696C6C3A233131373744373B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E57686974657B66696C6C3A234646464646463B7D0A092E7374307B6F
          7061636974793A302E37353B7D0A092E7374317B6F7061636974793A302E353B
          7D0A092E7374327B6F7061636974793A302E32353B7D0A3C2F7374796C653E0A
          3C672069643D2257696E646F7773223E0A093C7061746820636C6173733D2242
          6C61636B2220643D224D31382C31382E31563136683276302E394331392E332C
          31372E322C31382E362C31372E362C31382C31382E317A204D31342E372C3236
          4832563136483076313163302C302E352C302E352C312C312C316831352E310A
          09094331352E352C32372E332C31352E312C32362E362C31342E372C32367A20
          4D32342C313863352E372C302C382C362C382C36732D322E332C362D382C3663
          2D352E372C302D382D362D382D365331382E332C31382C32342C3138204D3234
          2C3230632D332E332C302D352E312C322E372D352E382C340A090963302E372C
          312E332C322E352C342C352E382C3463332E332C302C352E312D322E372C352E
          382D344332392E312C32322E372C32372E332C32302C32342C32304C32342C32
          307A204D32342C3232632D312E312C302D322C302E392D322C3273302E392C32
          2C322C3263312E312C302C322D302E392C322D320A09095332352E312C32322C
          32342C32327A204D32362C31362E325638683276382E394332372E342C31362E
          362C32362E372C31362E342C32362C31362E327A204D31302C38483876326832
          56387A222F3E0A093C7061746820636C6173733D22426C75652220643D224D30
          2C3136762D3563302D302E352C302E352D312C312D3168313863302E352C302C
          312C302E352C312C31763548307A204D32382C38563363302D302E352D302E35
          2D312D312D31483943382E352C322C382C322E352C382C3376354832387A222F
          3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'windows.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C75657B66696C6C3A2331
          31373744373B7D0A3C2F7374796C653E0A3C672069643D226172726F775F736F
          727422207472616E73666F726D3D227363616C6528312E33333333333329223E
          0A093C7061746820643D224D362E323838323920342E32393332374C322E3239
          32353220382E32393332374C322E323039333820382E333837353243312E3930
          34353620382E373739393720312E393332353920392E333437313920322E3239
          33323720392E37303734384C322E333837353220392E373930363243322E3737
          3939372031302E3039353420332E33343731392031302E3036373420332E3730
          37343820392E37303637334C362E30303120372E34314C362E30303130312031
          392E303030374C362E30303737342031392E3131373343362E30363535203139
          2E3631343620362E34383831372032302E3030303720372E3030313031203230
          2E303030374C372E31313736332031392E3939333943372E3631343937203139
          2E3933363220382E30303130312031392E3531333520382E3030313031203139
          2E303030374C382E30303120372E3431374C31302E3239343420392E37303735
          374C31302E3338383620392E373930374331302E373831312031302E30393535
          2031312E333438332031302E303637342031312E3730383620392E3730363634
          4331322E3039383820392E33313538362031322E3039383420382E3638323720
          31312E3730373720382E32393234334C372E373032343220342E32393234334C
          372E363038313620342E323039333143372E323135373120332E393034353620
          362E363438353520332E393332363220362E323838323920342E32393332375A
          4D313720342E30303331374C31362E3838333420342E303039394331362E3338
          3620342E303637363720313620342E343930333420313620352E30303331374C
          31362031362E3538334C31332E373036382031342E323932354C31332E363132
          352031342E323039344331332E323230312031332E393034352031322E363532
          392031332E393332352031322E323932362031342E323933324331312E393032
          322031342E363833392031312E393032352031352E333137312031322E323933
          322031352E373037344C31362E3239372031392E373037344C31362E33393132
          2031392E373930354331362E373833372032302E303935342031372E33353039
          2032302E303637342031372E373131322031392E373036374C32312E37303734
          2031352E373036374C32312E373930362031352E363132354332322E30393534
          2031352E32322032322E303637342031342E363532382032312E373036382031
          342E323932354C32312E363132352031342E323039344332312E323230312031
          332E393034352032302E363532392031332E393332352032302E323932362031
          342E323933324C31382031362E3538374C313820352E30303331374C31372E39
          39333320342E38383635354331372E3933353520342E33383932312031372E35
          31323820342E303033313720313720342E30303331375A2220636C6173733D22
          426C756522202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'arrow_sort.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A2337
          32373237323B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A
          092E426C75657B66696C6C3A233131373744373B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E57686974657B66696C6C3A234646464646463B7D0A092E7374307B6F
          7061636974793A302E37353B7D0A092E7374317B6F7061636974793A302E353B
          7D0A092E7374327B6F7061636974793A302E32353B7D0A3C2F7374796C653E0A
          3C672069643D2257696E646F7773223E0A093C7061746820636C6173733D2242
          6C61636B2220643D224D31382C31382E31563136683276302E394331392E332C
          31372E322C31382E362C31372E362C31382C31382E317A204D31342E372C3236
          4832563136483076313163302C302E352C302E352C312C312C316831352E310A
          09094331352E352C32372E332C31352E312C32362E362C31342E372C32367A20
          4D32342C313863352E372C302C382C362C382C36732D322E332C362D382C3663
          2D352E372C302D382D362D382D365331382E332C31382C32342C3138204D3234
          2C3230632D332E332C302D352E312C322E372D352E382C340A090963302E372C
          312E332C322E352C342C352E382C3463332E332C302C352E312D322E372C352E
          382D344332392E312C32322E372C32372E332C32302C32342C32304C32342C32
          307A204D32342C3232632D312E312C302D322C302E392D322C3273302E392C32
          2C322C3263312E312C302C322D302E392C322D320A09095332352E312C32322C
          32342C32327A204D32362C31362E325638683276382E394332372E342C31362E
          362C32362E372C31362E342C32362C31362E327A204D31302C38483876326832
          56387A222F3E0A093C7061746820636C6173733D22426C75652220643D224D30
          2C3136762D3563302D302E352C302E352D312C312D3168313863302E352C302C
          312C302E352C312C31763548307A204D32382C38563363302D302E352D302E35
          2D312D312D31483943382E352C322C382C322E352C382C3376354832387A222F
          3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'windows.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D227461626C655F63
          616C63756C61746F7222207472616E73666F726D3D227363616C6528312E3629
          223E0A093C7061746820643D224D3133203748313756352E3543313720342E31
          313932392031352E3838303720332031342E35203348313356375A4D37203132
          5638483356313248375A4D313220382E34393938325638483856313248313156
          31302E3543313120392E36383230392031312E3339323820382E393535393220
          313220382E34393938325A4D313120313348385631374831315631335A4D3720
          313348335631342E3543332031352E3838303720342E31313932392031372035
          2E3520313748375631335A4D313220375633483856374831325A4D3720335637
          483356352E35433320342E313139323920342E3131393239203320352E352033
          48375A4D31322031302E3543313220392E36373135372031322E363731362039
          2031332E3520394831372E354331382E33323834203920313920392E36373135
          372031392031302E355631372E354331392031382E333238342031382E333238
          342031392031372E352031394831332E354331322E3637313620313920313220
          31382E333238342031322031372E355631302E355A4D31342E35203133483133
          2E354331332E323233392031332031332031332E323233392031332031332E35
          4331332031332E373736312031332E323233392031342031332E352031344831
          342E354331342E373736312031342031352031332E373736312031352031332E
          354331352031332E323233392031342E373736312031332031342E352031335A
          4D31382031332E354331382031332E323233392031372E373736312031332031
          372E352031334831362E354331362E323233392031332031362031332E323233
          392031362031332E354331362031332E373736312031362E3232333920313420
          31362E352031344831372E354331372E373736312031342031382031332E3737
          36312031382031332E355A4D31342E352031354831332E354331332E32323339
          2031352031332031352E323233392031332031352E354331332031352E373736
          312031332E323233392031362031332E352031364831342E354331342E373736
          312031362031352031352E373736312031352031352E354331352031352E3232
          33392031342E373736312031352031342E352031355A4D31382031352E354331
          382031352E323233392031372E373736312031352031372E352031354831362E
          354331362E323233392031352031362031352E323233392031362031352E3543
          31362031352E373736312031362E323233392031362031362E35203136483137
          2E354331372E373736312031362031382031352E373736312031382031352E35
          5A4D31342E352031374831332E354331332E323233392031372031332031372E
          323233392031332031372E354331332031372E373736312031332E3232333920
          31382031332E352031384831342E354331342E37373631203138203135203137
          2E373736312031352031372E354331352031372E323233392031342E37373631
          2031372031342E352031375A4D31382031372E354331382031372E3232333920
          31372E373736312031372031372E352031374831362E354331362E3232333920
          31372031362031372E323233392031362031372E354331362031372E37373631
          2031362E323233392031382031362E352031384831372E354331372E37373631
          2031382031382031372E373736312031382031372E355A4D31332E3520313043
          31332E323233392031302031332031302E323233392031332031302E35563131
          2E354331332031312E373736312031332E323233392031322031332E35203132
          4831372E354331372E373736312031322031382031312E373736312031382031
          312E355631302E354331382031302E323233392031372E373736312031302031
          372E352031304831332E355A2220636C6173733D22426C61636B22202F3E0A3C
          2F673E0A3C2F7376673E0A}
        FileName = 'table_calculator.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A23
          4646423131353B7D0A092E5265647B66696C6C3A234431314331433B7D0A092E
          426C75657B66696C6C3A233131373744373B7D0A092E477265656E7B66696C6C
          3A233033394332333B7D0A092E426C61636B7B66696C6C3A233732373237323B
          7D0A092E57686974657B66696C6C3A234646464646463B7D0A092E7374307B6F
          7061636974793A302E37353B7D0A3C2F7374796C653E0A3C672069643D22496D
          706F7274223E0A093C7061746820636C6173733D22426C61636B2220643D224D
          31322C31324838563668345631327A204D32342C31377631763963302C302E36
          2D302E342C312D312C314833632D302E362C302D312D302E342D312D31563763
          302D302E362C302E342D312C312D31683376386831344C32342C31377A204D32
          302C313848360A090976366831345631387A222F3E0A093C706F6C79676F6E20
          636C6173733D22477265656E2220706F696E74733D2233322C362032342C3620
          32342C322031362C382032342C31342032342C31302033322C31302009222F3E
          0A3C2F673E0A3C2F7376673E0A}
        FileName = 'import.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032322E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E5265647B66696C6C3A234431314331433B7D0A092E477265656E7B66696C6C
          3A233033394332333B7D0A092E59656C6C6F777B66696C6C3A23464642313135
          3B7D0A092E57686974657B66696C6C3A234646464646463B7D0A092E7374307B
          6F7061636974793A302E353B7D0A092E7374317B6F7061636974793A302E3735
          3B7D0A092E7374327B646973706C61793A6E6F6E653B7D0A092E7374337B6469
          73706C61793A696E6C696E653B66696C6C3A234646423131353B7D0A092E7374
          347B646973706C61793A696E6C696E653B7D0A092E7374357B646973706C6179
          3A696E6C696E653B6F7061636974793A302E37353B7D0A092E7374367B646973
          706C61793A696E6C696E653B6F7061636974793A302E353B7D0A092E7374377B
          646973706C61793A696E6C696E653B66696C6C3A233033394332333B7D0A092E
          7374387B646973706C61793A696E6C696E653B66696C6C3A234431314331433B
          7D0A092E7374397B646973706C61793A696E6C696E653B66696C6C3A23313137
          3744373B7D0A092E737431307B646973706C61793A696E6C696E653B66696C6C
          3A234646464646463B7D0A3C2F7374796C653E0A3C672069643D22466F6C6465
          72223E0A093C6720636C6173733D22737431223E0A09093C7061746820636C61
          73733D2259656C6C6F772220643D224D322E322C32352E326C352E352D313043
          382C31342E352C382E372C31342C392E352C3134483234762D3363302D302E36
          2D302E342D312D312D31483132563763302D302E362D302E342D312D312D3148
          3343322E342C362C322C362E352C322C377631380A09090963302C302E322C30
          2C302E332C302E312C302E3443322E312C32352E342C322E322C32352E332C32
          2E322C32352E327A222F3E0A093C2F673E0A093C7061746820636C6173733D22
          59656C6C6F772220643D224D32392E332C313648392E364C342C32366831392E
          3863302E352C302C312E312D302E322C312E332D302E366C342E392D382E3943
          33302E312C31362E322C32392E382C31362C32392E332C31367A222F3E0A3C2F
          673E0A3C2F7376673E0A}
        FileName = 'bo_folder.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D227265736973746F
          722D6E6F64657322207472616E73666F726D3D227363616C6528312E33333333
          333329223E0A093C7061746820643D224D322C313148332E363743342E30382C
          392E383320352E31392C3920362E352C3941332C33203020302C3120392E352C
          313243392E352C31322E363520392E32392C31332E323520382E39342C31332E
          37344C31302E30372C31352E33354C31332E31312C344C31342E36312C362E31
          334C31362E372C392E31314C31372E352C394331382E38312C392031392E3932
          2C392E38332032302E33332C31314832325631334832302E33334331392E3932
          2C31342E31372031382E38312C31352031372E352C313541332C33203020302C
          312031342E352C31324331342E352C31312E33352031342E37312C31302E3735
          2031352E30362C31302E32364C31332E39332C382E36354C31302E38392C3230
          4C372E332C31342E383943372E30352C31342E393620362E37382C313520362E
          352C313543352E31392C313520342E30382C31342E313720332E36372C313348
          325631314D31372E352C31302E3541312E352C312E35203020302C302031362C
          313241312E352C312E35203020302C302031372E352C31332E3541312E352C31
          2E35203020302C302031392C313241312E352C312E35203020302C302031372E
          352C31302E354D362E352C31302E3541312E352C312E35203020302C3020352C
          313241312E352C312E35203020302C3020362E352C31332E3541312E352C312E
          35203020302C3020382C313241312E352C312E35203020302C3020362E352C31
          302E355A2220636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F7376
          673E0A}
        FileName = 'resistor-nodes.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A23
          4646423131353B7D0A092E5265647B66696C6C3A234431314331433B7D0A092E
          426C61636B7B66696C6C3A233732373237323B7D0A092E426C75657B66696C6C
          3A233131373744373B7D0A092E57686974657B66696C6C3A234646464646463B
          7D0A092E477265656E7B66696C6C3A233033394332333B7D0A092E7374307B6F
          7061636974793A302E37353B7D0A092E7374317B6F7061636974793A302E353B
          7D0A092E7374327B6F7061636974793A302E32353B7D0A092E7374337B66696C
          6C3A234646423131353B7D0A3C2F7374796C653E0A3C673E0A3C2F673E0A3C67
          2069643D2247726964223E0A093C6720636C6173733D22737431223E0A09093C
          7061746820636C6173733D22426C61636B2220643D224D32322C313268387636
          682D385631327A204D31322C313276366838762D364831327A204D31302C3138
          762D36483276364831307A204D32322C32366838762D36682D385632367A204D
          31322C323076366838762D364831327A204D31302C3236762D3648320A090909
          76364831307A222F3E0A093C2F673E0A093C7265637420783D22322220793D22
          342220636C6173733D22426C7565222077696474683D22323822206865696768
          743D2236222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'grid.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A2337
          32373237323B7D0A092E426C75657B66696C6C3A233131373744373B7D0A3C2F
          7374796C653E0A3C7061746820636C6173733D22426C61636B2220643D224D32
          362C3134763132483130762D34762D32762D3648387636483656366831367638
          6832563563302D302E362D302E342D312D312D31483543342E342C342C342C34
          2E342C342C3576313663302C302E362C302E342C312C312C31683376350A0963
          302C302E352C302E352C312C312C3168313863302E352C302C312D302E352C31
          2D315631344832367A222F3E0A3C7061746820636C6173733D22426C75652220
          643D224D32382C313163302D302E362D302E342D312D312D314839632D302E36
          2C302D312C302E342D312C317632763176326832305631317A222F3E0A3C2F73
          76673E0A}
        FileName = 'action_windowlist.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E477265656E7B66696C6C3A233033394332333B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F7061
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D22436865636B
          223E0A093C706F6C79676F6E20636C6173733D22477265656E2220706F696E74
          733D2232372C352031312C323120352C313520322C31382031312C3237203330
          2C382009222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_check.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E426C61636B7B66696C6C3A233732373237323B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F7061
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D225365747469
          6E6773223E0A093C7061746820636C6173733D22426C75652220643D224D3330
          2C3138762D346C2D342E342D302E37632D302E322D302E382D302E352D312E35
          2D302E392D322E316C322E362D332E366C2D322E382D322E386C2D332E362C32
          2E36632D302E372D302E342D312E342D302E372D322E312D302E394C31382C32
          682D340A09096C2D302E372C342E34632D302E382C302E322D312E352C302E35
          2D322E312C302E394C372E352C342E374C342E372C372E356C322E362C332E36
          632D302E342C302E372D302E372C312E342D302E392C322E314C322C31347634
          6C342E342C302E3763302E322C302E382C302E352C312E352C302E392C322E31
          0A09096C2D322E362C332E366C322E382C322E386C332E362D322E3663302E37
          2C302E342C312E342C302E372C322E312C302E394C31342C333068346C302E37
          2D342E3463302E382D302E322C312E352D302E352C322E312D302E396C332E36
          2C322E366C322E382D322E386C2D322E362D332E360A090963302E342D302E37
          2C302E372D312E342C302E392D322E314C33302C31387A204D31362C3230632D
          322E322C302D342D312E382D342D3463302D322E322C312E382D342C342D3473
          342C312E382C342C344332302C31382E322C31382E322C32302C31362C32307A
          222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_settings.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2277616E64222074
          72616E73666F726D3D227363616C6528312E33333333333329223E0A093C7061
          746820643D224D31312E3430343820392E34363437384C322E36393831342031
          382E3137383543312E38313231322031392E3036353220312E38313236322032
          302E3530323220322E36393932342032312E3338383343332E35383538352032
          322E3237343320352E30323238342032322E3237333820352E39303839352032
          312E333837314C31342E363134382031322E363734384C31312E343034382039
          2E34363437385A4D31362E383531382031352E303036384C31362E3735203135
          4331362E333730332031352031362E303536352031352E323832322031362E30
          3036382031352E363438324C31362031352E37355631362E354831352E323543
          31342E383730332031362E352031342E353536352031362E373832322031342E
          353036382031372E313438324C31342E352031372E32354331342E352031372E
          363239372031342E373832322031372E393433352031352E313438322031372E
          393933324C31352E32352031384831365631382E37354331362031392E313239
          372031362E323832322031392E343433352031362E363438322031392E343933
          324C31362E37352031392E354331372E313239372031392E352031372E343433
          352031392E323137382031372E343933322031382E383531384C31372E352031
          382E37355631384831382E32354331382E363239372031382031382E39343335
          2031372E373137382031382E393933322031372E333531384C31392031372E32
          354331392031362E383730332031382E373137382031362E353536352031382E
          333531382031362E353036384C31382E32352031362E354831372E355631352E
          37354331372E352031352E333730332031372E323137382031352E3035363520
          31362E383531382031352E303036384C31362E37352031354C31362E38353138
          2031352E303036385A4D31332E3331333620372E35363533384C31332E313737
          3520372E36393039324C31322E3436353820382E34303337384C31352E363735
          382031312E363133384C31362E333837392031302E393030334331372E323635
          342031302E303231332031372E3236353120382E35393733382031362E333836
          3820372E37313834384C31362E3233303420372E353731354331352E33393331
          20362E38353338382031342E3135333320362E38353139312031332E33313336
          20372E35363533385A4D362E383531373720352E30303638354C362E37352035
          43362E33373033203520362E303536353120352E323832313520362E30303638
          3520352E36343832334C3620352E373556362E3548352E323543342E38373033
          20362E3520342E353536353120362E373832313520342E353036383520372E31
          343832334C342E3520372E323543342E3520372E3632393720342E3738323135
          20372E393433343920352E313438323320372E39393331354C352E3235203848
          3656382E3735433620392E3132393720362E323832313520392E343433343920
          362E363438323320392E34393331354C362E373520392E3543372E3132393720
          392E3520372E343433343920392E323137383520372E343933313520382E3835
          3137374C372E3520382E3735563848382E323543382E36323937203820382E39
          3433343920372E373137383520382E393933313520372E33353137374C392037
          2E3235433920362E3837303320382E373137383520362E353536353120382E33
          3531373720362E35303638354C382E323520362E3548372E3556352E37354337
          2E3520352E3337303320372E323137383520352E303536353120362E38353137
          3720352E30303638354C362E373520354C362E383531373720352E3030363835
          5A4D31382E3835313820332E30303638354C31382E373520334331382E333730
          3320332031382E3035363520332E32383231352031382E3030363820332E3634
          3832334C313820332E373556342E354831372E32354331362E3837303320342E
          352031362E3535363520342E37383231352031362E3530363820352E31343832
          334C31362E3520352E32354331362E3520352E363239372031362E3738323220
          352E39343334392031372E3134383220352E39393331354C31372E3235203648
          313856362E373543313820372E313239372031382E3238323220372E34343334
          392031382E3634383220372E34393331354C31382E373520372E354331392E31
          32393720372E352031392E3434333520372E32313738352031392E3439333220
          362E38353137374C31392E3520362E373556364832302E32354332302E363239
          3720362032302E3934333520352E37313738352032302E3939333220352E3335
          3137374C323120352E323543323120342E383730332032302E3731373820342E
          35353635312032302E3335313820342E35303638354C32302E323520342E3548
          31392E3556332E37354331392E3520332E333730332031392E3231373820332E
          30353635312031382E3835313820332E30303638354C31382E373520334C3138
          2E3835313820332E30303638355A2220636C6173733D22426C61636B22202F3E
          0A3C2F673E0A3C2F7376673E0A}
        FileName = 'wand.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D22637562655F6D75
          6C7469706C6522207472616E73666F726D3D227363616C6528312E3333333333
          3329223E0A093C7061746820643D224D31302E3531383620342E323530383243
          31312E3437373920332E39313633392031322E3532323120332E393136333920
          31332E3438313420342E32353038324331332E3531373220342E323632353720
          31332E3535323920342E32373437362031332E3538383420342E32383733384C
          31392E3530333220362E33383631384331392E3837383720362E353139343120
          32302E3231353120362E37323232392032302E3520362E393737323256362E35
          363230394332302E3520352E37313533372031392E3936363820342E39363033
          392031392E3136383820342E36373732344C31342E3030363520322E38343534
          334331322E3730383520322E33383438362031312E3239313520322E33383438
          3620392E393933353420322E38343534334C342E383331313820342E36373732
          3443342E3033333220342E393630333920332E3520352E373135333720332E35
          20362E353632303956362E393737323243332E373834383920362E3732323239
          20342E313231323920362E353139343120342E343936373720362E3338363138
          4C31302E3431313620342E32383733384331302E3434373120342E3237343736
          2031302E3438323820342E32363235372031302E3531383620342E3235303832
          5A4D31332E32353420352E32323837324331322E3434323820342E3934303836
          2031312E3535373220342E39343038362031302E37343620352E32323837324C
          342E383331313820372E333237353143342E3033333220372E36313036372033
          2E3520382E333635363420332E3520392E32313233375631372E343436374333
          2E352031382E3239333520342E303333322031392E3034383420342E38333131
          382031392E333331364C31302E3734362032312E343330344331312E35353732
          2032312E373138332031322E343432382032312E373138332031332E32353420
          32312E343330344C31392E313638382031392E333331364331392E3936363820
          31392E303438342032302E352031382E323933352032302E352031372E343436
          3756392E32313233374332302E3520382E33363536342031392E393636382037
          2E36313036372031392E3136383820372E33323735314C31332E32353420352E
          32323837325A4D362E34343934332031302E3131313543362E35383739352039
          2E373231313320372E303136363920392E353136393720372E34303730362039
          2E36353534384C31322031312E323835324C31362E3539323920392E36353534
          384331362E3938333320392E35313639372031372E3431323120392E37323131
          332031372E353530362031302E313131354331372E363839312031302E353031
          392031372E343834392031302E393330362031372E303934362031312E303639
          314C31322E37352031322E363130375631372E333331314331322E3735203137
          2E373435332031322E343134322031382E303831312031322031382E30383131
          4331312E353835382031382E303831312031312E32352031372E373435332031
          312E32352031372E333331315631322E363130374C362E39303534342031312E
          3036393143362E35313530382031302E3933303620362E33313039312031302E
          3530313920362E34343934332031302E313131355A2220636C6173733D22426C
          61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'cube_multiple.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C75657B66696C6C3A2331
          31373744373B7D0A3C2F7374796C653E0A3C672069643D227765622D73796E63
          22207472616E73666F726D3D227363616C6528312E33333333333329223E0A09
          3C7061746820643D224D31362E352031312E37344331362E352031312E313520
          31362E34332031302E35382031362E33362031304831392E37344331392E3832
          2031302E33332031392E38392031302E36372031392E39332031314332302E36
          352031312E30372032312E33342031312E32332032322031312E354332312E37
          3120362E32312031372E33352032203132203243362E34372032203220362E35
          203220313243322031372E3520362E352032322031322032324331322E383720
          32322031332E37312032312E38382031342E352032312E36374331332E373120
          32302E37312031332E31382031392E352031332E30342031382E324331322E37
          332031382E38312031322E33392031392E342031322031392E39364331312E31
          372031382E37362031302E352031372E34332031302E30392031364831332E31
          384331332E33352031352E32382031332E36342031342E36312031342E303320
          313448392E363643392E35362031332E333420392E352031322E363820392E35
          20313253392E35362031302E363520392E36362031304831342E33344331342E
          34332031302E36352031342E352031312E33322031342E352031324331342E35
          2031322E352031342E34362031332031342E342031332E354331342E39372031
          322E37362031352E36382031322E31372031362E352031312E37344D342E3236
          20313443342E312031332E333620342031322E3639203420313253342E312031
          302E363420342E323620313048372E363443372E35362031302E363620372E35
          2031312E333220372E3520313253372E35362031332E333420372E3634203134
          48342E32364D352E3038203136483843382E33352031372E323520382E382031
          382E343520392E342031392E353643372E35372031382E393320362E30332031
          372E363520352E30382031364D38203848352E303843362E303320362E333420
          372E353720352E303620392E3420342E343443382E3820352E353520382E3335
          20362E3735203820384D31302E303920384331302E3520362E35372031312E31
          3720352E323320313220342E30334331322E383320352E32332031332E352036
          2E35372031332E393120384831302E30394D31382E393220384831352E393743
          31352E363520362E37352031352E313920352E35352031342E353920342E3434
          4331362E343320352E30372031372E393620362E33342031382E393220384D32
          332031372E354332332031382E33322032322E37352031392E30382032322E33
          332031392E37314C32312E32342031382E36324332312E34312031382E323820
          32312E352031372E392032312E352031372E354332312E352031362E31322032
          302E33382031352031392031355631362E354C31362E37352031342E32354C31
          392031325631332E354332312E32312031332E352032332031352E3239203233
          2031372E354D31392031382E354C32312E32352032302E37354C313920323356
          32312E354331362E37392032312E352031352031392E37312031352031372E35
          4331352031362E36382031352E32352031352E39322031352E36372031352E32
          394C31362E37362031362E33384331362E35392031362E37322031362E352031
          372E312031362E352031372E354331362E352031382E38382031372E36322032
          302031392032305631382E355A2220636C6173733D22426C756522202F3E0A3C
          2F673E0A3C2F7376673E0A}
        FileName = 'web-sync.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A23
          4646423131353B7D0A092E5265647B66696C6C3A234431314331433B7D0A092E
          5265647B66696C6C3A234431314331433B7D0A092E426C75657B66696C6C3A23
          3131373744373B7D0A092E57686974657B66696C6C3A234646464646463B7D0A
          092E477265656E7B66696C6C3A233033394332333B7D0A092E7374307B6F7061
          636974793A302E37353B7D0A092E7374317B6F7061636974793A302E353B7D0A
          092E7374327B6F7061636974793A302E32353B7D0A092E7374337B66696C6C3A
          234646423131353B7D0A3C2F7374796C653E0A3C673E0A3C2F673E0A3C672069
          643D2252656D6F7665446174614974656D73223E0A093C7061746820636C6173
          733D22426C75652220643D224D31382E312C32332E316C2D342E342C342E3463
          2D302E372C302E372D312E392C302E372D322E362C306C2D362E362D362E3663
          2D302E372D302E372D302E372D312E392C302D322E366C342E342D342E344C31
          382E312C32332E317A222F3E0A093C7061746820636C6173733D225265642220
          643D224D32372E352C31332E376C2D382C386C2D392E322D392E326C382D3863
          302E372D302E372C312E392D302E372C322E362C306C362E362C362E36433238
          2E322C31312E382C32382E322C31332C32372E352C31332E377A222F3E0A3C2F
          673E0A3C2F7376673E0A}
        FileName = 'removedataitems.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A
          234646423131353B7D0A3C2F7374796C653E0A3C672069643D22666F6C646572
          22207472616E73666F726D3D227363616C6528312E33333333333329223E0A09
          3C7061746820643D224D31302C34483443322E38392C3420322C342E38392032
          2C3656313841322C32203020302C3020342C323048323041322C32203020302C
          302032322C313856384332322C362E38392032312E312C362032302C36483132
          4C31302C345A2220636C6173733D2259656C6C6F7722202F3E0A3C2F673E0A3C
          2F7376673E0A}
        FileName = 'folder.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6F6F
          6B75705F5F7832365F5F5265666572656E63652220786D6C6E733D2268747470
          3A2F2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C
          696E6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E
          6B220A0920783D223070782220793D22307078222076696577426F783D223020
          3020333220333222207374796C653D22656E61626C652D6261636B67726F756E
          643A6E6577203020302033322033323B2220786D6C3A73706163653D22707265
          7365727665223E0A3C7374796C6520747970653D22746578742F637373223E0A
          092E426C75657B66696C6C3A233131373744373B7D0A3C2F7374796C653E0A3C
          7061746820636C6173733D22426C75652220643D224D31302C313663302D322E
          322C312E382D342C342D3473342C312E382C342C34732D312E382C342D342C34
          5331302C31382E322C31302C31367A204D342C3563302C302E362C302E342C31
          2C312C3168323376323363302C302E362D302E342C312D312C3148350A09632D
          312E372C302D332D312E332D332D33563563302D312E372C312E332D332C332D
          3368323263302E362C302C312C302E342C312C317631483543342E342C342C34
          2C342E342C342C357A204D382E322C31372E3463302E352C322E322C322E322C
          342C342E342C342E350A0963312E382C302E342C332E342C302C342E372D302E
          386C342E362C342E3663302E352C302E352C312E332C302E352C312E372C3063
          302E352D302E352C302E352D312E332C302D312E374C31392C31392E3363302E
          392D312E332C312E322D332C302E382D342E370A09632D302E352D322E322D32
          2E332D332E392D342E352D342E344331312C392E322C372E322C31332C382E32
          2C31372E347A222F3E0A3C2F7376673E0A}
        FileName = 'documentstatistics.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D22446174
          615F4C6162656C732220786D6C6E733D22687474703A2F2F7777772E77332E6F
          72672F323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F
          2F7777772E77332E6F72672F313939392F786C696E6B2220783D22307078220A
          0920793D22307078222076696577426F783D2230203020333220333222207374
          796C653D22656E61626C652D6261636B67726F756E643A6E6577203020302033
          322033323B2220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E426C75657B66696C6C
          3A233131373744373B7D0A092E477265656E7B66696C6C3A233033394332333B
          7D0A092E7374307B6F7061636974793A302E353B7D0A3C2F7374796C653E0A3C
          6720636C6173733D22737430223E0A093C7061746820636C6173733D22426C75
          652220643D224D31302C3238483456313868365632387A204D31382C3134682D
          3676313468365631347A204D32362C3130682D3676313868365631307A222F3E
          0A3C2F673E0A3C7061746820636C6173733D22477265656E2220643D224D3130
          2C31364834762D3468365631367A204D31382C38682D367634683656387A204D
          32362C34682D367634683656347A222F3E0A3C2F7376673E0A}
        FileName = 'chartdatalabelsgroup.svg'
      end>
  end
  object VerificheImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    Left = 80
    Top = 328
    Bitmap = {
      494C010109001800040010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BD1FF110C2D8400000000229C02FF229C02FF229C
      02FF229C02FF229C02FF09230B84000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BD1FF402DAAFF00000000229C02FF229C02FF229C
      02FF229C02FF229C02FF21832BFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BD1FF402DAAFF00000000229C02FF229C02FF229C
      02FF229C02FF229C02FF21832BFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BD1FF402DAAFF00000000229C02FF229C02FF229C
      02FF229C02FF229C02FF21832BFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BD1FF402DAAFF00000000229C02FF229C02FF229C
      02FF229C02FF229C02FF21832BFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000001010337C4848
      DAFF4848DAFF4848DAFF4848DAFF443BC3FF0000000012290C7C4EB034FF4EB0
      34FF4EB034FF4EB034FF389A30FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D77610FFD77610FFD77610FFD77610FFD77610FF2F1A
      0E84000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D77610FFD77610FFD77610FFD77610FFD77610FFB264
      37FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D77610FFD77610FFD77610FFD77610FFD77610FFB264
      37FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D77610FFD77610FFD77610FFD77610FFD77610FFB264
      37FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D77610FFD77610FFD77610FFD77610FFD77610FFB264
      37FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000034220F7CDF9240FFDF9240FFDF9240FFDF9240FFC97B
      3CFF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D77610FFD77610FFD77610FF2F1A0E8400000000229C02FF229C02FF229C
      02FF09230B840000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004224058ED37410FDD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD77610FFC76E0FF600000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D77610FFD77610FFD77610FFB26437FF00000000229C02FF229C02FF229C
      02FF21832BFF000000000000000000000000000000000808408E121287CD0A0A
      4B9A000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CF7210FAD77610FFD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFCF72
      10FBD77610FFD77610FF000000000000000000000000636363EF717171FF7171
      71FF717171FF717171FF666666F20000000000000000636363EF717171FF7171
      71FF717171FF717171FF666666F2000000000000000000000000000000000000
      0000D77610FFD77610FFD77610FFB26437FF00000000229C02FF229C02FF229C
      02FF21832BFF0000000000000000000000000000000004041C5F01010D421818
      BAF10000000000000000717171FF717171FF717171FF717171FF717171FF7171
      71FF717171FF717171FF717171FF0000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FF4E2B069A0101
      0018D77610FFD77610FF000000000000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000666666F2717171FF0000
      000034220F7CDF9240FFDF9240FFC97B3CFF0000000012290C7C4EB034FF4EB0
      34FF389A30FF0000000006274184000000000000000004041E620505246B0F0F
      74BE000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD17410FCD17410FCD77610FF4E2B069A000000056235
      07ACD77610FFD77610FF000000000000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000001694F6FF000000000000000005052971141496D80A0A
      4998000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FFC96E0FF72011026300000007000000060F080144000000055D3307A8D776
      10FFD77610FFD77610FF000000000000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      000000000000000000001B1BD1FF1B1BD1FF1B1BD1FF402DAAFF0000000014B1
      FFFF14B1FFFF14B1FFFF1694F6FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FF2816036F150B0150B6640EEBB9650EED180D0256130A014ED77610FFD776
      10FFD77610FFD77610FF000000000000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      000000000000000000001010337C4848DAFF4848DAFF443BC3FF000000000F2D
      3C7C43C1FFFF43C1FFFF2DABFBFF0000000000000000121288CE14149EDE1111
      7FC7000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FF01000017AD5F0DE5D77610FFD77610FFB9650EED0000000CD77610FFD776
      10FFD77610FFD77610FF000000000000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      00000000000000000000717171FF0000000000000000717171FF000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000010108340F0F77C10202
      144F0000000000000000717171FF717171FF717171FF717171FF717171FF7171
      71FF717171FF717171FF717171FF0000000000000000D77610FFD77610FFD776
      10FF01010018AA5D0DE3D77610FFD77610FFB6640EEB00000010D77610FFD776
      10FFD77610FFD77610FF000000000000000000000000717171FF0000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000717171FF0000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000717171FF000000000000
      000000000000000000000000000000000000717171FF00000000000000007171
      71FF000000000000000000000000000000000000000007073A870000021D1414
      99DB000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FF2E190377110A014AAA5D0DE3AD5F0DE5150B015029160370D77610FFD776
      10FFD77610FFD77610FF000000000000000000000000606060EB717171FF14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000606060EB717171FF14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000717171FF000000000000
      000000000000666666F2717171FF717171FF717171FF00000000000000007171
      71FF000000000000000000000000000000000000000005052870141498DA0A0A
      4B99000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FFCF7210FA2E19037701000016020100192E190377CF7210FAD77610FFD776
      10FFD77610FFD77610FF000000000000000000000000000000000000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000000000000000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF00000000717171FF000000000000
      000000000000717171FF717171FF717171FF1A1A1A7C00000000000000007171
      71FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD77610FFD77610FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000717171FF000000000000
      000000000000717171FF717171FF1A1A1A7C0000000000000000000000007171
      71FF0000000000000000000000000000000000000000000000001B1BD1FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD77610FFD77610FF00000000000000000000000000000000000000000000
      0000D77610FFD77610FFD77610FF321C037C0000000000000000000000000000
      0000160C015281460AC5000000000000000000000000626262EE717171FF7171
      71FF717171FF717171FF1A1A1A7C00000000666666F2717171FF717171FF7171
      71FF0000000000000000000000000000000000000000000000001B1BD1FF0000
      00000000000000000000717171FF717171FF717171FF717171FF717171FF7171
      71FF717171FF717171FF717171FF0000000000000000CD700FF90201001E0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D77610FFD77610FF3D220489000000000000000000000000000000000100
      00149E570CDB170C015400000000000000000000000000000000000000000000
      0000717171FF000000000000000000000000717171FF717171FF717171FF1A1A
      1A7C00000000000000000000000000000000000000000B0B5AA71B1BD1FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003B200486CD7010F9D776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD77610FFC16A0FF200000000000000000000000000000000000000000000
      0000D77610FF7C4409C2A65B0DE0180D02560000001100000010160C01539D56
      0CDA4024048C0000000000000000000000000000000000000000000000000000
      0000717171FF000000000000000000000000717171FF717171FF1A1A1A7C0000
      0000000000000000000000000000000000000000000001010A381818B6EE0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000321C037C00000000140A014E774209BEC16A0FF2C16A0FF2774209BE140B
      014F000000000000000000000000000000000000000000000000000000000000
      0000626262EE717171FF717171FF717171FF717171FF1A1A1A7C000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000201001A3E22048998530BD7D07210FBD17410FC9A550BD84023048C0201
      001D000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000021A08083B89141494D71B1BCAFB1B1BCBFC141496D808083E8C0000
      021D000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000001A0E
      0259C16A0FF2D77610FFD77610FFD77610FFD77610FFD77610FFD77610FFC56C
      0FF41D10025F000000000000000000000000000000000F89C6E114B1FFFF14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF14B1FFFF1191D1E7000000000000000000000000000000000303
      19591919BCF21B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1919
      BFF403031C5F0000000000000000000000000000000000000000000000000000
      0009031F2D6C0B608ABC1194D4E914AFFDFE14AFFDFE1195D6EA0B628DBE0321
      306F0000000B0000000000000000000000000000000000000000190D0257D575
      10FED77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD57610FE1D10025F0000000000000000000000000427397914B1FFFF14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF14B1FFFF052C4080000000000000000000000000030318571B1B
      CFFE1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1B
      D1FF1B1BCFFE03031C5F00000000000000000000000000000000000000000C6A
      99C614B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF0D73A6CE0000000000000000000000000000000001010018C0690FF1D776
      10FFD77610FFD77610FF00000000000000000000000000000000D77610FFD776
      10FFD77610FFC56C0FF40201001D0000000000000000000000070F82BCDB14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF5C8091FF5F7D8DFF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF0F87C3DF000000090000000000000000000001181818BAF11B1B
      D1FF0101083505052B751B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF0606317D0000
      062D1B1BD1FF1919BFF40000021D0000000000000000000000000000000013A5
      EDF6063A5493010C114300010116000000010000000100010115010B10410638
      519013A2E9F400000000000000000000000000000000391F0484D77610FFD776
      10FFD77610FFD77610FFD77610FF0000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FF4023048C000000000000000000000000010F174D14B1
      FFFF14B1FFFF14B1FFFF14B1FFFF598296FF5C8091FF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF02121A52000000000000000000000000070737841B1BD1FF1B1B
      D1FF08083D8B0000000005052B741B1BD1FF1B1BD1FF0606307C000000000707
      37841B1BD1FF1B1BD1FF08083E8C00000000000000000000000000000000010B
      1142031F2D6C0B608ABC1194D4E914AFFDFE14AFFDFE1195D6EA0B628DBE0321
      306F01090E3C000000000000000000000000000000008F4E0BD0D77610FFD776
      10FFD77610FFD77610FFD77610FF0000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FF9B550BD8000000000000000000000000000000000A59
      82B614B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF0A5E87BA0000000000000000000000000000000012128BD01B1BD1FF1B1B
      D1FF1B1BD1FF08083D8B0000000005052B740606307C00000000070737841B1B
      D1FF1B1BD1FF1B1BD1FF141496D8000000000000000000000000000000000C6A
      99C614B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF0D73A6CE00000000000000000000000000000000C56C0FF4D77610FFD776
      10FFD77610FFD77610FFD77610FF0000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD17310FC000000000000000000000000000000000004
      052714A9F3F914B1FFFF14B1FFFF717171FF717171FF14B1FFFF14B1FFFF14A9
      F5FA00040629000000000000000000000000000000001919BFF41B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF08083D8B0000000000000000070737841B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BCBFC0000000000000000000000000000000013A5
      EDF6063A5493010C114300010116000000010000000100010115010B10410638
      519013A2E9F400000000000000000000000000000000C46C0FF4D77610FFD776
      10FFD77610FFD77610FFD77610FF0000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FFD07210FB000000000000000000000000000000000000
      000005334A8A14B1FFFF14B1FFFF717171FF717171FF14B1FFFF14B1FFFF0635
      4D8C00000000000000000000000000000000000000001919BEF41B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF0606307C000000000000000005052B741B1BD1FF1B1B
      D1FF1B1BD1FF1B1BD1FF1B1BCAFB00000000000000000000000000000000010B
      1142031F2D6C0B608ABC1194D4E914AFFDFE14AFFDFE1195D6EA0B628DBE0321
      306F01090E3C000000000000000000000000000000008D4D0BCFD77610FFD776
      10FFD77610FFD77610FF000000000000000000000000D77610FFD77610FFD776
      10FFD77610FFD77610FF98530BD7000000000000000000000000000000000000
      00000000000E1190CFE614B1FFFF717171FF717171FF14B1FFFF1190CFE60000
      000E0000000000000000000000000000000000000000121289CF1B1BD1FF1B1B
      D1FF1B1BD1FF0606307C000000000707378408083D8B0000000005052B741B1B
      D1FF1B1BD1FF1B1BD1FF141494D7000000000000000000000000000000000C6A
      99C614B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF0D73A6CE00000000000000000000000000000000361E0481D77610FFD776
      10FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFD776
      10FFD77610FFD77610FF3E220489000000000000000000000000000000000000
      0000000000000217225E14B1FFFF717171FF717171FF14B1FFFF0217225E0000
      00000000000000000000000000000000000000000000070735811B1BD1FF1B1B
      D1FF0606327D00000000070737841B1BD1FF1B1BD1FF08083D8B000000000505
      2B751B1BD1FF1B1BD1FF08083B890000000000000000000000000000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF0000000000000000000000000000000001000016BC670EEFD776
      10FFD77610FFD77610FFD77610FF0A06003907040031D77610FFD77610FFD776
      10FFD77610FFC16A0FF20201001A000000000000000000000000000000000000
      000000000000000000010C6B99C614B1FFFF14B1FFFF0C6A98C5000000010000
      00000000000000000000000000000000000000000000000001161818B7EF1B1B
      D1FF01010B3C070737841B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF08083D8B0101
      08351B1BD1FF1919BCF20000021A0000000000000000000000000000000014B1
      FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF14B1FFFF0000000000000000000000000000000000000000160C0152D374
      10FDD77610FFD77610FFD77610FF0D0701410A060039D77610FFD77610FFD776
      10FFD57510FE1A0E025900000000000000000000000000000000000000000000
      0000000000000000000000070A3414AEFBFD14ADFBFD00060932000000000000
      0000000000000000000000000000000000000000000000000000020215521B1B
      CDFD1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1B
      D1FF1B1BCFFE0303195900000000000000000000000000000000000000000C64
      90C014B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1FFFF14B1
      FFFF0C6D9DC8000000000000000000000000000000000000000000000000160C
      0152BC670EEFD77610FFD77610FFD77610FFD77610FFD77610FFD77610FFC069
      0FF1190D02570000000000000000000000000000000000000000000000000000
      0000000000000000000000000000073D5997063A539200000000000000000000
      0000000000000000000000000000000000000000000000000000000000000202
      15521818B7EF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1B1BD1FF1818
      BAF1030318570000000000000000000000000000000000000000000000000000
      0006031A27640A577FB41089C6E113A5EDF613A5EDF6108BC8E20A5982B6031C
      2967000000080000000000000000000000000000000000000000000000000000
      000001000016361E04818D4D0BCFC36C0FF3C56C0FF48F4E0BD0391F04840101
      0018000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000011607073581121289CF1919BDF31919BFF412128BD0070737840000
      0118000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
    DesignInfo = 21495888
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
          462D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078222076696577426F783D2230203020333220333222207374796C653D22
          656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
          2220786D6C3A73706163653D227072657365727665223E262331333B26233130
          3B3C7374796C6520747970653D22746578742F637373223E2E426C75657B6669
          6C6C3A233131373744373B7D3C2F7374796C653E0A3C7061746820636C617373
          3D22426C75652220643D224D31362C3243382E332C322C322C382E332C322C31
          3673362E332C31342C31342C31347331342D362E332C31342D31345332332E37
          2C322C31362C327A204D31362C3663312E312C302C322C302E392C322C32732D
          302E392C322D322C32732D322D302E392D322D3220202623393B5331342E392C
          362C31362C367A204D32302C3234682D38762D326832762D38682D32762D3268
          32683476313068325632347A222F3E0A3C2F7376673E0A}
        FileName = 'action_aboutinfo.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
          462D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078222076696577426F783D2230203020333220333222207374796C653D22
          656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
          2220786D6C3A73706163653D227072657365727665223E262331333B26233130
          3B3C7374796C6520747970653D22746578742F6373732220786D6C3A73706163
          653D227072657365727665223E2E426C61636B7B66696C6C3A23373237323732
          3B7D262331333B262331303B2623393B2E5265647B66696C6C3A234431314331
          433B7D262331333B262331303B2623393B2E59656C6C6F777B66696C6C3A2346
          46423131353B7D262331333B262331303B2623393B2E477265656E7B66696C6C
          3A233033394332333B7D3C2F7374796C653E0A3C672069643D225761726E696E
          67223E0A09093C7061746820636C6173733D2259656C6C6F772220643D224D31
          342E392C342E3763302E362D312C312E352D312C322E312C306C31322E372C32
          312E3563302E362C312C302E312C312E382D312C312E3848332E33632D312E32
          2C302D312E362D302E382D312D312E384C31342E392C342E377A222F3E0A0909
          3C636972636C6520636C6173733D22426C61636B222063783D22313622206379
          3D2232322220723D2232222F3E0A09093C7265637420783D2231342220793D22
          31302220636C6173733D22426C61636B222077696474683D2234222068656967
          68743D2238222F3E0A093C2F673E0A3C2F7376673E0A}
        FileName = 'security_warning.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
          462D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078222076696577426F783D2230203020333220333222207374796C653D22
          656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
          2220786D6C3A73706163653D227072657365727665223E262331333B26233130
          3B3C7374796C6520747970653D22746578742F6373732220786D6C3A73706163
          653D227072657365727665223E2E59656C6C6F777B66696C6C3A234646423131
          353B7D262331333B262331303B2623393B2E5265647B66696C6C3A2344313143
          31433B7D262331333B262331303B2623393B2E426C75657B66696C6C3A233131
          373744373B7D262331333B262331303B2623393B2E477265656E7B66696C6C3A
          233033394332333B7D262331333B262331303B2623393B2E426C61636B7B6669
          6C6C3A233732373237323B7D262331333B262331303B2623393B2E5768697465
          7B66696C6C3A234646464646463B7D262331333B262331303B2623393B2E7374
          307B6F7061636974793A302E353B7D262331333B262331303B2623393B2E7374
          317B646973706C61793A6E6F6E653B7D262331333B262331303B2623393B2E73
          74327B646973706C61793A696E6C696E653B66696C6C3A233033394332333B7D
          262331333B262331303B2623393B2E7374337B646973706C61793A696E6C696E
          653B66696C6C3A234431314331433B7D262331333B262331303B2623393B2E73
          74347B646973706C61793A696E6C696E653B66696C6C3A233732373237323B7D
          3C2F7374796C653E0A3C672069643D22436C6F7365223E0A09093C7061746820
          636C6173733D225265642220643D224D31362C3243382E332C322C322C382E33
          2C322C313673362E332C31342C31342C31347331342D362E332C31342D313453
          32332E372C322C31362C327A204D32332E372C32312E3763302E342C302E342C
          302E342C312C302C312E346C2D302E362C302E3620202623393B2623393B632D
          302E342C302E342D312C302E342D312E342C304C31362C31386C2D352E372C35
          2E37632D302E342C302E342D312C302E342D312E342C306C2D302E362D302E36
          632D302E342D302E342D302E342D312C302D312E344C31342C31366C2D352E37
          2D352E37632D302E342D302E342D302E342D312C302D312E3420202623393B26
          23393B6C302E362D302E3663302E342D302E342C312D302E342C312E342C304C
          31362C31346C352E372D352E3763302E342D302E342C312D302E342C312E342C
          306C302E362C302E3663302E342C302E342C302E342C312C302C312E344C3138
          2C31364C32332E372C32312E377A222F3E0A093C2F673E0A3C2F7376673E0A}
        FileName = 'error.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E426C75657B66696C6C3A233131373744373B7D0A092E477265656E7B66696C
          6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B7D
          0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F706163
          6974793A302E353B7D0A3C2F7374796C653E0A3C672069643D22446174616261
          7365223E0A093C7061746820636C6173733D2259656C6C6F772220643D224D31
          362C3234632D352E352C302D31302D312E382D31302D34763463302C322E322C
          342E352C342C31302C347331302D312E382C31302D34762D344332362C32322E
          322C32312E352C32342C31362C32347A222F3E0A093C7061746820636C617373
          3D2259656C6C6F772220643D224D31362C3138632D352E352C302D31302D312E
          382D31302D34763463302C322E322C342E352C342C31302C347331302D312E38
          2C31302D34762D344332362C31362E322C32312E352C31382C31362C31387A22
          2F3E0A093C7061746820636C6173733D2259656C6C6F772220643D224D31362C
          344331302E352C342C362C352E382C362C38763463302C322E322C342E352C34
          2C31302C347331302D312E382C31302D3456384332362C352E382C32312E352C
          342C31362C347A222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_database.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6F6F
          6B75705F5F7832365F5F5265666572656E63652220786D6C6E733D2268747470
          3A2F2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C
          696E6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E
          6B220A0920783D223070782220793D22307078222076696577426F783D223020
          3020333220333222207374796C653D22656E61626C652D6261636B67726F756E
          643A6E6577203020302033322033323B2220786D6C3A73706163653D22707265
          7365727665223E0A3C7374796C6520747970653D22746578742F637373223E0A
          092E426C75657B66696C6C3A233131373744373B7D0A3C2F7374796C653E0A3C
          7061746820636C6173733D22426C75652220643D224D31302C313663302D322E
          322C312E382D342C342D3473342C312E382C342C34732D312E382C342D342C34
          5331302C31382E322C31302C31367A204D342C3563302C302E362C302E342C31
          2C312C3168323376323363302C302E362D302E342C312D312C3148350A09632D
          312E372C302D332D312E332D332D33563563302D312E372C312E332D332C332D
          3368323263302E362C302C312C302E342C312C317631483543342E342C342C34
          2C342E342C342C357A204D382E322C31372E3463302E352C322E322C322E322C
          342C342E342C342E350A0963312E382C302E342C332E342C302C342E372D302E
          386C342E362C342E3663302E352C302E352C312E332C302E352C312E372C3063
          302E352D302E352C302E352D312E332C302D312E374C31392C31392E3363302E
          392D312E332C312E322D332C302E382D342E370A09632D302E352D322E322D32
          2E332D332E392D342E352D342E344331312C392E322C372E322C31332C382E32
          2C31372E347A222F3E0A3C2F7376673E0A}
        FileName = 'lookup&reference.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C696E
          6B546F50726576696F75732220786D6C6E733D22687474703A2F2F7777772E77
          332E6F72672F323030302F7376672220786D6C6E733A786C696E6B3D22687474
          703A2F2F7777772E77332E6F72672F313939392F786C696E6B2220783D223070
          78220A0920793D22307078222076696577426F783D2230203020333220333222
          207374796C653D22656E61626C652D6261636B67726F756E643A6E6577203020
          302033322033323B2220786D6C3A73706163653D227072657365727665223E0A
          3C7374796C6520747970653D22746578742F637373223E0A092E426C75657B66
          696C6C3A233131373744373B7D0A092E59656C6C6F777B66696C6C3A23464642
          3131353B7D0A092E426C75657B66696C6C3A233131373744373B7D0A3C2F7374
          796C653E0A3C7061746820636C6173733D2259656C6C6F772220643D224D3136
          2C31364836762D366831305631367A204D33322C313048323276366831305631
          307A222F3E0A3C7061746820636C6173733D22426C75652220643D224D31342C
          313676313163302C302E352D302E352C312D312C314833632D302E352C302D31
          2D302E352D312D3156313363302D302E352C302E352D312C312D316833763248
          3476313268385631364831347A204D32382C3136763130682D38563134683276
          2D32682D330A09632D302E352C302D312C302E352D312C3176313463302C302E
          352C302E352C312C312C3168313063302E352C302C312D302E352C312D315631
          364832387A222F3E0A3C7061746820636C6173733D22426C75652220643D224D
          31302E392C322E394331322E372C312E312C31352E322C302C31382C3063342E
          382C302C382E392C332E342C392E382C38682D322E31632D302E392D332E342D
          342D362D372E372D36632D322E322C302D342E322C302E392D352E362C322E34
          4C31362C38483856300A094C31302E392C322E397A222F3E0A3C2F7376673E0A}
        FileName = 'linktoprevious.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
          462D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078222076696577426F783D2230203020333220333222207374796C653D22
          656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
          2220786D6C3A73706163653D227072657365727665223E262331333B26233130
          3B3C7374796C6520747970653D22746578742F6373732220786D6C3A73706163
          653D227072657365727665223E2E477265656E7B66696C6C3A23303339433233
          3B7D262331333B262331303B2623393B2E426C75657B66696C6C3A2331313737
          44373B7D262331333B262331303B2623393B2E426C61636B7B66696C6C3A2337
          32373237323B7D262331333B262331303B2623393B2E59656C6C6F777B66696C
          6C3A234646423131353B7D262331333B262331303B2623393B2E57686974657B
          66696C6C3A234646464646463B7D262331333B262331303B2623393B2E526564
          7B66696C6C3A234431314331433B7D262331333B262331303B2623393B2E7374
          307B6F7061636974793A302E323B7D3C2F7374796C653E0A3C673E0A09093C70
          61746820636C6173733D22426C61636B2220643D224D342C3234563868346832
          763563302C302E362C302E342C312C312C31683576326832762D32762D326C2D
          362D36682D3256326836763563302C302E362C302E342C312C312C3168357638
          6832563856366C2D362D36682D32483920202623393B2623393B43382E342C30
          2C382C302E342C382C317635483343322E342C362C322C362E342C322C377631
          3863302C302E362C302E342C312C312C316833762D3248347A222F3E0A093C2F
          673E0A3C706F6C79676F6E20636C6173733D22426C75652220706F696E74733D
          2231302C323420382C323620382C33322031342C33322031362C33302031362C
          323420222F3E0A3C6720636C6173733D22737430223E0A09093C706F6C79676F
          6E20636C6173733D2257686974652220706F696E74733D2231342C323620382C
          32362031302C32342031362C3234202623393B222F3E0A093C2F673E0A3C6720
          636C6173733D22737430223E0A09093C706F6C79676F6E20636C6173733D2252
          65642220706F696E74733D2231362C33302031342C33322031342C3236203136
          2C3234202623393B222F3E0A093C2F673E0A3C706F6C79676F6E20636C617373
          3D22477265656E2220706F696E74733D2232302C32342031382C32362031382C
          33322032342C33322032362C33302032362C323420222F3E0A3C6720636C6173
          733D22737430223E0A09093C706F6C79676F6E20636C6173733D225768697465
          2220706F696E74733D2232342C32362031382C32362032302C32342032362C32
          34202623393B222F3E0A093C2F673E0A3C6720636C6173733D22737430223E0A
          09093C706F6C79676F6E20636C6173733D225265642220706F696E74733D2232
          362C33302032342C33322032342C32362032362C3234202623393B222F3E0A09
          3C2F673E0A3C706F6C79676F6E20636C6173733D225265642220706F696E7473
          3D2232302C31382031342C31382031322C32302031322C32322032302C323220
          222F3E0A3C6720636C6173733D22737430223E0A09093C706F6C79676F6E2063
          6C6173733D2257686974652220706F696E74733D2231382C32302031322C3230
          2031342C31382032302C3138202623393B222F3E0A093C2F673E0A3C6720636C
          6173733D22737430223E0A09093C706F6C79676F6E20636C6173733D22426C75
          652220706F696E74733D2232302C32322031382C32322031382C32302032302C
          3138202623393B222F3E0A093C2F673E0A3C706F6C79676F6E20636C6173733D
          2259656C6C6F772220706F696E74733D2232342C31382032322C32302032322C
          32322032382C32322032382C32362033302C32342033302C313820222F3E0A3C
          6720636C6173733D22737430223E0A09093C706F6C79676F6E20636C6173733D
          2257686974652220706F696E74733D2232382C32302032322C32302032342C31
          382033302C3138202623393B222F3E0A093C2F673E0A3C6720636C6173733D22
          737430223E0A09093C706F6C79676F6E20636C6173733D225265642220706F69
          6E74733D2233302C32342032382C32362032382C32302033302C313820262339
          3B222F3E0A093C2F673E0A3C2F7376673E0A}
        FileName = 'action_modeldifferences_copy.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6973
          744E756D626572732220786D6C6E733D22687474703A2F2F7777772E77332E6F
          72672F323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F
          2F7777772E77332E6F72672F313939392F786C696E6B2220783D22307078220A
          0920793D22307078222076696577426F783D2230203020333220333222207374
          796C653D22656E61626C652D6261636B67726F756E643A6E6577203020302033
          322033323B2220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A092E426C61636B7B66696C6C3A233732373237323B7D
          0A3C2F7374796C653E0A3C7061746820636C6173733D22426C61636B2220643D
          224D33302C38483132563668313856387A204D33302C3138483132762D326831
          385631387A204D33302C3238483132762D326831385632387A222F3E0A3C7061
          746820636C6173733D225265642220643D224D362C327638483456352E336C2D
          322C3056332E376C302E322C3063302E322C302C302E352C302C302E372D302E
          3163302E332C302C302E352D302E312C302E372D302E3363302E322D302E312C
          302E342D302E332C302E352D302E350A0963302E312D302E322C302E322D302E
          342C302E332D302E376C302D302E3148367A204D382C3230762D312E3648342E
          3643342E372C31382E322C342E392C31382E312C352C313863302E322D302E32
          2C302E352D302E342C302E372D302E3563302E332D302E322C302E352D302E33
          2C302E382D302E350A0963302E332D302E322C302E352D302E342C302E372D30
          2E3663302E322D302E322C302E342D302E352C302E352D302E3863302E312D30
          2E332C302E322D302E362C302E322D3163302D302E342D302E312D302E372D30
          2E322D312E31632D302E312D302E332D302E342D302E362D302E362D302E380A
          09632D302E332D302E322D302E352D302E342D302E392D302E35632D302E332D
          302E312D302E372D302E322D312D302E32632D302E352C302D302E392C302E31
          2D312E332C302E32632D302E342C302E322D302E372C302E342D302E392C302E
          37632D302E322C302E332D302E342C302E362D302E352C310A09632D302E312C
          302E342D302E322C302E382D302E322C312E336C302C302E3168312E38762D30
          2E3163302D302E322C302D302E342C302E312D302E3663302D302E322C302E31
          2D302E342C302E322D302E3563302E312D302E312C302E322D302E332C302E33
          2D302E340A0963302E312D302E312C302E332D302E312C302E352D302E316330
          2E332C302C302E352C302E312C302E372C302E3363302E322C302E322C302E33
          2C302E342C302E332C302E3863302C302E322C302C302E342D302E312C302E35
          632D302E312C302E322D302E322C302E332D302E342C302E350A09632D302E31
          2C302E312D302E332C302E332D302E352C302E34632D302E322C302E312D302E
          342C302E322D302E352C302E3443342E332C31362E362C342C31362E382C332E
          372C3137632D302E332C302E322D302E362C302E352D302E382C302E37632D30
          2E322C302E332D302E342C302E362D302E352C302E390A09632D302E312C302E
          332D302E322C302E372D302E322C312E3256323048387A204D362E312C32392E
          3863302E332D302E312C302E372D302E332C302E392D302E3563302E332D302E
          322C302E352D302E352C302E362D302E3843372E392C32382E322C382C32372E
          382C382C32372E340A0963302D302E352D302E312D302E392D302E342D312E32
          632D302E322D302E322D302E342D302E342D302E372D302E3563302E322D302E
          312C302E342D302E332C302E352D302E3563302E322D302E332C302E332D302E
          362C302E332D3163302D302E342D302E312D302E372D302E322D310A09632D30
          2E322D302E332D302E342D302E352D302E362D302E37632D302E322D302E322D
          302E352D302E332D302E382D302E3443352E372C32322C352E342C32322C352E
          312C3232632D302E342C302D302E382C302E312D312E312C302E32632D302E33
          2C302E312D302E362C302E332D302E392C302E360A09632D302E322C302E322D
          302E342C302E352D302E362C302E39632D302E312C302E332D302E322C302E37
          2D302E322C312E316C302C302E3168312E376C302D302E3163302D302E332C30
          2E312D302E362C302E332D302E3963302E322D302E322C302E342D302E332C30
          2E382D302E330A0963302E322C302C302E352C302E312C302E362C302E324335
          2E392C32332E392C362C32342E312C362C32342E3463302C302E322C302C302E
          332D302E312C302E3443352E382C32342E392C352E362C32352C352E352C3235
          632D302E312C302E312D302E332C302E312D302E352C302E310A09632D302E31
          2C302D302E322C302D302E332C30632D302E312C302D302E322C302D302E322C
          306C2D302E322C3076312E3468302E3163302E322C302C302E342C302C302E36
          2C3063302E322C302C302E342C302C302E352C302E3163302E312C302E312C30
          2E332C302E312C302E342C302E330A0963302E312C302E312C302E312C302E33
          2C302E312C302E3663302C302E332D302E312C302E362D302E332C302E37632D
          302E322C302E322D302E352C302E332D302E382C302E33632D302E322C302D30
          2E342C302D302E352D302E31632D302E312D302E312D302E332D302E322D302E
          342D302E330A0943342E312C32382C342C32372E382C342C32372E37632D302E
          312D302E322D302E312D302E332D302E312D302E356C302D302E3148322E326C
          302C302E3163302C302E342C302E312C302E392C302E322C312E3263302E312C
          302E342C302E332C302E372C302E362C302E390A0963302E332C302E322C302E
          362C302E342C302E392C302E3643342E322C32392E392C342E362C33302C352E
          312C333043352E342C33302C352E382C32392E392C362E312C32392E387A222F
          3E0A3C2F7376673E0A}
        FileName = 'listnumbers.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E5265647B66696C6C3A234431314331433B7D0A092E4772
          65656E7B66696C6C3A233033394332333B7D0A092E57686974657B66696C6C3A
          234646464646463B7D0A092E7374307B6F7061636974793A302E323B7D0A3C2F
          7374796C653E0A3C706F6C79676F6E20636C6173733D22477265656E2220706F
          696E74733D2232302C31362031382C31382031382C32382032382C3238203330
          2C32362033302C313620222F3E0A3C6720636C6173733D22737430223E0A093C
          706F6C79676F6E20636C6173733D2257686974652220706F696E74733D223238
          2C31382031382C31382032302C31362033302C31362009222F3E0A3C2F673E0A
          3C6720636C6173733D22737430223E0A093C706F6C79676F6E20636C6173733D
          225265642220706F696E74733D2233302C32362032382C32382032382C313820
          33302C31362009222F3E0A3C2F673E0A3C706F6C79676F6E20636C6173733D22
          5265642220706F696E74733D22362C313620342C313820342C32382031342C32
          382031362C32362031362C313620222F3E0A3C6720636C6173733D2273743022
          3E0A093C706F6C79676F6E20636C6173733D2257686974652220706F696E7473
          3D2231342C313820342C313820362C31362031362C31362009222F3E0A3C2F67
          3E0A3C6720636C6173733D22737430223E0A093C706F6C79676F6E20636C6173
          733D22426C75652220706F696E74733D2231362C32362031342C32382031342C
          31382031362C31362009222F3E0A3C2F673E0A3C706F6C79676F6E20636C6173
          733D22426C75652220706F696E74733D2231342C322031322C342031322C3134
          2032322C31342032342C31322032342C3220222F3E0A3C6720636C6173733D22
          737430223E0A093C706F6C79676F6E20636C6173733D2257686974652220706F
          696E74733D2232322C342031322C342031342C322032342C322009222F3E0A3C
          2F673E0A3C6720636C6173733D22737430223E0A093C706F6C79676F6E20636C
          6173733D225265642220706F696E74733D2232342C31322032322C3134203232
          2C342032342C322009222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'modeleditor_business_object_model.svg'
      end>
  end
end
