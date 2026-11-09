object zDbCard: TzDbCard
  Left = 0
  Top = 0
  Width = 447
  Height = 350
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentDoubleBuffered = False
  ParentFont = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  OnResize = FrameResize
  object Titolo: TcxLabel
    Left = 24
    Top = 35
    Caption = 'Titolo'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -15
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
  end
  object pnlDescrizione: TdxPanel
    Left = 347
    Top = 0
    Width = 100
    Height = 350
    Align = alRight
    Frame.Drag.Enabled = True
    Frame.Visible = False
    TabOrder = 1
    Visible = False
  end
  object dxLayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 347
    Height = 350
    Align = alClient
    PopupMenu = popCard
    TabOrder = 2
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.ShowAccelChar = False
      Hidden = True
      ShowBorder = False
      Index = -1
    end
  end
  object DataSource: TDataSource
    OnStateChange = DataSourceStateChange
    OnDataChange = DataSourceDataChange
    Left = 118
    Top = 61
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
      'Dataset'
      'Edit'
      'Memo'
      'Image')
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
    PopupMenuLinks = <>
    UseSystemFont = True
    OnShowToolbarsPopup = dxBarManagerShowToolbarsPopup
    Left = 38
    Top = 61
    PixelsPerInch = 96
    object dxBarToolbarFree: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'ToolbarFree'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 285
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
      Visible = False
      WholeRow = False
    end
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
      FloatLeft = 810
      FloatTop = 320
      FloatClientWidth = 51
      FloatClientHeight = 142
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarControlContainerTitolo'
        end
        item
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
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbEdit'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbInsert'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbDelete'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbPost'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbCancel'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbRefresh'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
    object dxBarControlContainerTitolo: TdxBarControlContainerItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      Control = Titolo
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          Visible = True
          ItemName = 'dxBarButton10'
        end
        item
          Visible = True
          ItemName = 'dxBarButton6'
        end
        item
          Visible = True
          ItemName = 'dxBarButton7'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonCopiaImpostazioniPerDX'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactSelected'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonCopiaSelected'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonIncollaSelected'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton16'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          Visible = True
          ItemName = 'dxBarButton5'
        end>
    end
    object dxBarButton4: TdxBarButton
      Action = MostraQueryUtilizzata
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = CopiaQueryUtilizzata
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = CopiaControlli
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = IncollaControlli
      Category = 0
    end
    object dxBarEditTitolo: TcxBarEditItem
      Caption = 'Titolo:'
      Category = 0
      Hint = 'display label'
      Visible = ivAlways
      OnChange = dxBarEditTitoloChange
      PropertiesClassName = 'TcxTextEditProperties'
    end
    object dxBarSeparator1: TdxBarSeparator
      Caption = 'New Separator'
      Category = 0
      Hint = 'New Separator'
      Visible = ivAlways
    end
    object dxBarButton9: TdxBarButton
      Action = CopyName
      Category = 0
    end
    object cxBarItemReadOnly: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'Sola Lettura'
        end>
      Properties.OnChange = cxBarEditItem1PropertiesChange
    end
    object cxBarItemModifyFlags: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.Columns = 3
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'Ins'
        end
        item
          Caption = 'Upd'
        end
        item
          Caption = 'Del'
        end>
      Properties.OnChange = cxBarItemModifyFlagsPropertiesChange
      InternalEditValue = ''
    end
    object cxBarItemCtrlType: TcxBarEditItem
      Caption = 'zCtrlTYpe'
      Category = 0
      Hint = 'zCtrlTYpe'
      Visible = ivAlways
      PropertiesClassName = 'TcxComboBoxProperties'
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 12
      Properties.Revertable = True
      Properties.OnChange = cxBarItemCtrlTypePropertiesChange
    end
    object dxBarButton3: TdxBarButton
      Action = CopiaImpostazioni
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = IncollaImpostazioni
      Category = 0
    end
    object cxBarEditItemCtrlFlag: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.Columns = 2
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'ReadOnly'
        end
        item
          Caption = 'Required'
        end>
      Properties.OnChange = cxBarEditItemCtrlFlagPropertiesChange
    end
    object dxBarSpinEditCtrlSize: TcxBarEditItem
      Caption = 'Size'
      Category = 0
      Hint = 'modifica size'
      Visible = ivAlways
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = dxBarSpinEditCtrlSizePropertiesEditValueChanged
      InternalEditValue = 0
    end
    object dxBarSpinEditCtrlLines: TcxBarEditItem
      Caption = 'Lines:      '
      Category = 0
      Hint = 'Lines:      '
      Visible = ivAlways
      OnChange = dxBarSpinEditCtrlLinesChange
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      InternalEditValue = '0'
    end
    object dxBarSpinEditCtrlColSpan: TcxBarEditItem
      Caption = 'Colonne:   '
      Category = 0
      Hint = 'Colonne fisse della griglia (0 = calcolate dal Size)'
      Visible = ivAlways
      OnChange = dxBarSpinEditCtrlColSpanChange
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      InternalEditValue = '0'
    end
    object dxBarEditCtrlCaption: TcxBarEditItem
      Caption = 'Label:     '
      Category = 0
      Hint = 'modifica label'
      Visible = ivAlways
      OnChange = dxBarEditCtrlCaptionChange
      PropertiesClassName = 'TcxTextEditProperties'
      InternalEditValue = ''
    end
    object dxBarButton8: TdxBarButton
      Action = ModificaMemo
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = ModificaRTF
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = CopiaCampiVisibili
      Category = 0
    end
    object dxBarButtonactPersonalizzaCard: TdxBarButton
      Action = actPersonalizza
      Category = 0
    end
    object dxBarSubItemControlloOrtografico: TdxBarSubItem
      Caption = 'Controllo Ortografico'
      Category = 0
      Visible = ivAlways
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000017744558745469746C65005370656C6C436865636B3B5370656C6C3B
        53FC4602000002E349444154785E65927F48936B14C71F9DBFCA19DDA925534B
        9D3A6D9BDBEB720ABAAE9BEE75BB2A9A9699962204A636B2A566D245B952C1D4
        98FD7060964ED3A20CEE3547F68722256AA2E62F340B94B21FE294A4A4A86B9E
        DE07DED1C60E1C5E5EF83C9FF33D0F0F9290258A28D5799028CE92FE3CE5F648
        653944269C03715CB16A978FD09190A9E5118A52D84F960242C81E0090652309
        0587CBD4A911641950024F0C7204C9FE62450978ED8D700B8FD3E0832E543B50
        6D6723C0A01F4FE54F819420914DC8CF00212B0681B4B0D2831DF68730F63416
        3885C5AA112E1B818882451484415FAEC28F02614F488248F0E72970670BDCF9
        078AB080892578059C02A7A1FF1908833EDCF8600C7A07C97D79D242E0490B20
        589273C8DD5BE81A28CE2643A3F30137967805495CD32B7BDA73752340AA0D7F
        E1548ED868F175A6DB819EC6A0EF609B2F5FC64AAF7CD2D534F00E7ADE6C4076
        EDD0EF5D70656B07D1FCFF80E67E6CA1D9EF5B68E6DB4F34F57513E1E89CA834
        4F6AF240F3F07BE89C5B873C6D3F08536AFFB612D0D39CE834F6E6C3DEFB6259
        072F189FB68F2DC3DDE935286A1886B0942B068A71B3143048758BEA58DD1024
        971BBB88240D875E8599A079D87573E02DB48C99A0BC630A84A9D7469C99BB3D
        B0DC52E092553308C685CFD03EFA018E54F77D8AC9A93F292F686BAC33BE02C3
        B809AAFE7D0592CC9B1F77711379F88EF8297A642970921CD5EB4ED40F42EB84
        097A97BE80A669146ABAE7E1CEE42A5CEA5904695EDB265B785C4927B30B4DBC
        6125B0C3718934DDF5DCDA6750D3BB04FFBD5E07C38B15A87EBC08A91546F08B
        2ED36206B3F767D7105779D54A80E887B2839FA4D5675DEE87AAEE05A87CB400
        F9FAE7C0915D1CA7004FCCDC9B594577264D2888D4590BC49906B364E73EE5C5
        C68CEA3E287BF01244690D1BAC00528AD7EC985E45AD132BE8D6E8320A8CBF62
        2D20329A1171F8B659C20A21FF698AC9EF04365150618ECE91D7A1008BB610D8
        1403AF43C766D2529BFA05BA6881B1E52780230000000049454E44AE426082}
      ItemLinks = <>
    end
    object dxBarButtonactNuovoLookup: TdxBarButton
      Action = actNuovoLookup
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = OverrideCampo
      Category = 0
    end
    object dxBarButtonCopiaImpostazioniPerDX: TdxBarButton
      Action = CopiaImpostazioniPerDX
      Category = 0
    end
    object dxBarButtonactPersonalizzaPickList: TdxBarButton
      Action = actPersonalizzaPicklist
      Category = 0
    end
    object dxBarButton14: TdxBarButton
      Action = Descrizione
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton15: TdxBarButton
      Action = LayoutEditor
      Category = 0
    end
    object dxBarButton16: TdxBarButton
      Action = EditTools
      Category = 0
    end
    object dxBarButton1: TdxBarButton
      Action = actSanifica
      Category = 0
    end
    object dxBarButtonCaricaImpostazioni: TdxBarButton
      Action = CaricaImpostazioni
      Category = 1
    end
    object dxBarButtonSalvaImpostazioni: TdxBarButton
      Action = SalvaImpostazioni
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
    object dxBarButtonactPersonalizzaCampo: TdxBarButton
      Action = actPersonalizzaCampo
      Category = 1
    end
    object dxBarButtonactPersonalizzaLookup: TdxBarButton
      Action = actPersonalizzaLookup
      Category = 1
    end
    object dxBarButtonactInfoDebugLookup: TdxBarButton
      Action = MostraQueryLookup
      Category = 1
    end
    object dxBarButtonactSelected: TdxBarButton
      Action = actSelected
      Category = 1
    end
    object dxBarButtonCopiaSelected: TdxBarButton
      Action = CopiaSelected
      Category = 1
    end
    object dxBarButtonIncollaSelected: TdxBarButton
      Action = IncollaSelected
      Category = 1
    end
    object dxBarButtonNascondiCampo: TdxBarButton
      Action = NascondiCampo
      Category = 1
    end
    object dxBarButtonNewLine: TdxBarButton
      Action = NewLine
      Category = 1
    end
    object dxBarButtonSeparatore: TdxBarButton
      Action = Separatore
      Category = 1
    end
    object dxBarButtonFissaColonne: TdxBarButton
      Action = FissaColonne
      Category = 1
    end
    object dxBarButtonLiberaColonne: TdxBarButton
      Action = LiberaColonne
      Category = 1
    end
    object cxBarEditItemGriglia: TcxBarEditItem
      Caption = 'Griglia:   '
      Category = 1
      Hint = 
        'Colonne della griglia della card; Fissa e Libera valgono per tut' +
        'ti i campi'
      Visible = ivAlways
      OnChange = cxBarEditItemGrigliaChange
      Width = 200
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Caption = '-'
          Hint = 'Una colonna in meno'
          Kind = bkText
        end
        item
          Caption = '+'
          Hint = 'Una colonna in piu'#39
          Kind = bkText
        end
        item
          Caption = 'Fissa'
          Hint = 
            'Ogni campo mantiene le colonne che occupa adesso, a qualunque la' +
            'rghezza della card'
          Kind = bkText
        end
        item
          Caption = 'Libera'
          Hint = 'Tutti i campi tornano a calcolare le colonne dal Size'
          Kind = bkText
        end>
      Properties.OnButtonClick = cxBarEditItemGrigliaPropertiesButtonClick
      InternalEditValue = ''
    end
    object dxBarButtonDistribuisciRiga: TdxBarButton
      Action = DistribuisciRiga
      Category = 1
    end
    object dxBarButtonLarghezzaPiena: TdxBarButton
      Action = LarghezzaPiena
      Category = 1
      ButtonStyle = bsChecked
    end
    object dxBarButtonGuideGriglia: TdxBarButton
      Action = GuideGriglia
      Category = 1
      ButtonStyle = bsChecked
    end
    object dxBarButtonCtrlSize: TdxBarButton
      Caption = 'Size'
      Category = 1
      Visible = ivAlways
      ImageIndex = 157
      ShortCut = 32851
    end
    object dxBarButtonCtrlLabel: TdxBarButton
      Caption = 'Label'
      Category = 1
      Visible = ivAlways
      ImageIndex = 128
      ShortCut = 16460
    end
    object dxBarButtonactDbFirst: TdxBarButton
      Action = actDbFirst
      Category = 2
    end
    object dxBarButtonactDbPrior: TdxBarButton
      Action = actDbPrior
      Category = 2
    end
    object dxBarButtonactDbNext: TdxBarButton
      Action = actDbNext
      Category = 2
    end
    object dxBarButtonactDbLast: TdxBarButton
      Action = actDbLast
      Category = 2
    end
    object dxBarButtonactDbEdit: TdxBarButton
      Action = actDbEdit
      Category = 2
    end
    object dxBarButtonactDbInsert: TdxBarButton
      Action = actDbInsert
      Category = 2
    end
    object dxBarButtonactDbDelete: TdxBarButton
      Action = actDbDelete
      Category = 2
    end
    object dxBarButtonactDbRefresh: TdxBarButton
      Action = actDbRefresh
      Category = 2
    end
    object dxBarButtonactDbPost: TdxBarButton
      Action = actDbPost
      Category = 2
    end
    object dxBarButtonactDbCancel: TdxBarButton
      Action = actDbCancel
      Category = 2
    end
    object dxBarButtonactEdCut: TdxBarButton
      Action = actEdCut
      Category = 3
    end
    object dxBarButtonactEdCopy: TdxBarButton
      Action = actEdCopy
      Category = 3
    end
    object dxBarButtonactEdPaste: TdxBarButton
      Action = actEdPaste
      Category = 3
    end
    object dxBarButtonactEdSelectAll: TdxBarButton
      Action = actEdSelectAll
      Category = 3
    end
    object dxBarButtonactEdUndo: TdxBarButton
      Action = actEdUndo
      Category = 3
    end
    object dxBarButtonactEdDelete: TdxBarButton
      Action = actEdDelete
      Category = 3
    end
    object dxBarButtonEditUndo1: TdxBarButton
      Action = actEdUndo
      Category = 3
    end
    object dxBarButtonEditCut1: TdxBarButton
      Action = actEdCut
      Category = 3
    end
    object dxBarButtonEditCopy1: TdxBarButton
      Action = actEdCopy
      Category = 3
    end
    object dxBarButtonEditPaste1: TdxBarButton
      Action = actEdPaste
      Category = 3
    end
    object dxBarButtonEditDelete1: TdxBarButton
      Action = actEdDelete
      Category = 3
    end
    object dxBarButtonEditSelectAll1: TdxBarButton
      Action = actEdSelectAll
      Category = 3
    end
    object dxBarButtonOpenPicture1: TdxBarButton
      Action = OpenPicture
      Category = 5
    end
    object dxBarButtonSavePicture1: TdxBarButton
      Action = SavePicture
      Category = 5
    end
    object dxBarButtonDeletePicture: TdxBarButton
      Action = DeletePicture
      Category = 5
    end
    object dxBarButton2: TdxBarButton
      Action = PreviewPicture
      Category = 5
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 38
    Top = 125
    object CopiaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Copia Impostazioni'
      ImageIndex = 522
      OnExecute = CopiaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object IncollaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Incolla Impostazioni'
      ImageIndex = 523
      OnExecute = IncollaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object ModificaMemo: TAction
      Category = 'Memo'
      Caption = 'Modifica'
      ImageIndex = 44
      OnExecute = ModificaMemoExecute
      OnUpdate = ModificaMemoUpdate
    end
    object ModificaRTF: TAction
      Category = 'Memo'
      Caption = 'Modifica'
      ImageIndex = 44
      OnExecute = ModificaRTFExecute
      OnUpdate = ModificaRTFUpdate
    end
    object OpenPicture: TAction
      Category = 'Image'
      Caption = '&Apri immagine'
      Hint = 'apri immagine'
      ImageIndex = 420
      ShortCut = 16463
      OnExecute = OpenPictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object SavePicture: TAction
      Category = 'Image'
      Caption = '&Salva immagine'
      Hint = 'salva immagine'
      ImageIndex = 423
      ShortCut = 16467
      OnExecute = SavePictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object DeletePicture: TAction
      Category = 'Image'
      Caption = '&Elimina immagine'
      ImageIndex = 66
      ShortCut = 16453
      OnExecute = DeletePictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object PreviewPicture: TAction
      Category = 'Image'
      Caption = 'Anteprima'
      ImageIndex = 169
      OnExecute = PreviewPictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object CaricaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Carica Impostazioni'
      ImageIndex = 521
      OnExecute = CaricaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object SalvaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Salva Impostazioni'
      ImageIndex = 524
      OnExecute = SalvaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object actDbFirst: TDataSetFirst
      Category = 'Dataset'
      Caption = 'All'#39'inizio'
      Hint = 'All'#39'inizio'
      ImageIndex = 146
      ShortCut = 16420
    end
    object actDbPrior: TDataSetPrior
      Category = 'Dataset'
      Caption = 'Precedente'
      Hint = 'Precedente'
      ImageIndex = 168
      ShortCut = 16417
    end
    object actDbNext: TDataSetNext
      Category = 'Dataset'
      Caption = 'Successivo'
      Hint = 'Successivo'
      ImageIndex = 161
      ShortCut = 16418
    end
    object actDbLast: TDataSetLast
      Category = 'Dataset'
      Caption = 'Ultimo'
      Hint = 'Ultimo'
      ImageIndex = 156
      ShortCut = 16419
    end
    object actDbEdit: TAction
      Category = 'Dataset'
      Caption = 'Modifica'
      Hint = 'Modifica'
      ImageIndex = 44
      SecondaryShortCuts.Strings = (
        'Ctrl+Enter')
      ShortCut = 117
      OnExecute = actDbEditExecute
    end
    object actDbInsert: TAction
      Category = 'Dataset'
      Caption = 'Inserisci'
      Hint = 'Inserisci'
      ImageIndex = 38
      ShortCut = 118
      OnExecute = actDbInsertExecute
    end
    object actDbDelete: TAction
      Category = 'Dataset'
      Caption = 'Elimina'
      Hint = 'Elimina'
      ImageIndex = 500
      SecondaryShortCuts.Strings = (
        'Ctrl+Del')
      ShortCut = 120
      OnExecute = actDbDeleteExecute
    end
    object actDbRefresh: TAction
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = actDbRefreshExecute
      OnUpdate = actDbRefreshUpdate
    end
    object CopyName: TAction
      Category = 'Design'
      Caption = 'Copia CardID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
      OnUpdate = VisibleIfAdmin
    end
    object actDbPost: TAction
      Category = 'Dataset'
      Caption = 'Applica'
      Hint = 'Applica'
      ImageIndex = 40
      OnExecute = actDbPostExecute
      OnUpdate = actDbPostUpdate
    end
    object actDbCancel: TAction
      Category = 'Dataset'
      Caption = 'Annulla'
      Hint = 'Annulla'
      ImageIndex = 43
      OnExecute = actDbCancelExecute
      OnUpdate = actDbCancelUpdate
    end
    object actEdCut: TEditCut
      Category = 'Edit'
      Caption = 'Taglia'
      Hint = 'taglia'
      ImageIndex = 65
      ShortCut = 16472
    end
    object actEdCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Copia'
      Hint = 'copia'
      ImageIndex = 62
      ShortCut = 16451
    end
    object actEdPaste: TEditPaste
      Category = 'Edit'
      Caption = 'Incolla'
      Hint = 'Incolla'
      ImageIndex = 85
      ShortCut = 16470
    end
    object actEdSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Seleziona tutto'
      Hint = 'seleziona tutto'
      ShortCut = 16449
    end
    object actEdUndo: TEditUndo
      Category = 'Edit'
      Caption = 'Annulla'
      Hint = 'annulla le modifiche'
      ImageIndex = 96
      ShortCut = 16474
    end
    object actEdDelete: TEditDelete
      Category = 'Edit'
      Caption = 'Elimina'
      Hint = 'elimina'
      ImageIndex = 66
      ShortCut = 8238
    end
    object actSQL: TAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 220
      ShortCut = 57432
      OnExecute = actSQLExecute
      OnUpdate = VisibleIfAdmin
    end
    object actPersonalizza: TAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza griglia...'
      ImageIndex = 512
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
      OnUpdate = VisibleIfAdmin
    end
    object actPersonalizzaCampo: TAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza campo...'
      ImageIndex = 512
      ShortCut = 16506
      OnExecute = actPersonalizzaCampoExecute
      OnUpdate = actPersonalizzaCampoUpdate
    end
    object actPersonalizzaPicklist: TAction
      Category = 'Design'
      Caption = 'Personalizza Picklist'
      Hint = 'Personalizza Picklist...'
      ImageIndex = 517
      OnExecute = actPersonalizzaPicklistExecute
    end
    object actPersonalizzaLookup: TAction
      Category = 'Design'
      Caption = 'Personalizza Lookup'
      Hint = 'Personalizza Lookup...'
      ImageIndex = 407
      ShortCut = 123
      OnExecute = actPersonalizzaLookupExecute
    end
    object MostraQueryLookup: TAction
      Category = 'Design'
      Caption = 'Mostra Query Lookup'
      ImageIndex = 243
      OnExecute = MostraQueryLookupExecute
    end
    object actNuovoLookup: TAction
      Category = 'Design'
      Caption = 'Nuovo Lookup'
      ImageIndex = 79
      OnExecute = actNuovoLookupExecute
    end
    object actSelected: TAction
      Category = 'Design'
      Caption = 'Selected ...'
      ImageIndex = 243
      OnExecute = actSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object CopiaSelected: TAction
      Category = 'Design'
      Caption = 'Copia Selected'
      ImageIndex = 62
      OnExecute = CopiaSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object IncollaSelected: TAction
      Category = 'Design'
      Caption = 'Incolla Selected'
      ImageIndex = 85
      OnExecute = IncollaSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object NascondiCampo: TAction
      Category = 'Design'
      Caption = 'Nascondi Campo'
      ImageIndex = 454
      OnExecute = NascondiCampoExecute
      OnUpdate = NascondiCampoUpdate
    end
    object NewLine: TAction
      Category = 'Design'
      Caption = 'NewLine'
      ImageIndex = 346
      ShortCut = 16462
      OnExecute = NewLineExecute
      OnUpdate = VisibleIfAdmin
    end
    object Separatore: TAction
      Category = 'Design'
      Caption = 'Separatore'
      ImageIndex = 417
      OnExecute = SeparatoreExecute
      OnUpdate = VisibleIfAdmin
    end
    object FissaColonne: TAction
      Category = 'Design'
      Caption = 'Fissa colonne della card'
      Hint = 
        'Ogni campo mantiene le colonne che occupa adesso, a qualunque la' +
        'rghezza della card'
      OnExecute = FissaColonneExecute
      OnUpdate = ColonneUpdate
    end
    object LiberaColonne: TAction
      Category = 'Design'
      Caption = 'Libera colonne della card'
      Hint = 'Tutti i campi tornano a calcolare le colonne dal Size'
      OnExecute = LiberaColonneExecute
      OnUpdate = ColonneUpdate
    end
    object DistribuisciRiga: TAction
      Category = 'Design'
      Caption = 'Distribuisci la riga'
      Hint = 
        'Stessa larghezza a tutti i campi della riga, griglia ridotta per' +
        ' riempirla esattamente'
      OnExecute = DistribuisciRigaExecute
      OnUpdate = DistribuisciRigaUpdate
    end
    object LarghezzaPiena: TAction
      Category = 'Design'
      Caption = 'Larghezza piena'
      Hint = 
        'Il campo occupa tutte le colonne della griglia, anche quando cam' +
        'biano'
      OnExecute = LarghezzaPienaExecute
      OnUpdate = LarghezzaPienaUpdate
    end
    object GuideGriglia: TAction
      Category = 'Design'
      Caption = 'Guide della griglia'
      Hint = 'Mostra i bordi delle colonne della griglia in tutte le card'
      OnExecute = GuideGrigliaExecute
      OnUpdate = GuideGrigliaUpdate
    end
    object MostraQueryUtilizzata: TAction
      Category = 'Debug'
      Caption = 'Mostra Query Utilizzata'
      ImageIndex = 244
      OnExecute = MostraQueryUtilizzataExecute
    end
    object CopiaQueryUtilizzata: TAction
      Category = 'Debug'
      Caption = 'Copia Query Utilizzata'
      ImageIndex = 62
      OnExecute = CopiaQueryUtilizzataExecute
    end
    object CopiaControlli: TAction
      Category = 'Design'
      Caption = 'Copia Controlli'
      ImageIndex = 62
      OnExecute = CopiaControlliExecute
    end
    object IncollaControlli: TAction
      Category = 'Design'
      Caption = 'Incolla Controlli'
      ImageIndex = 85
      OnExecute = IncollaControlliExecute
    end
    object WebCam: TAction
      Category = 'Image'
      Caption = 'WebCam'
      OnExecute = WebCamExecute
      OnUpdate = actEditorImageUpdate
    end
    object CopiaCampiVisibili: TAction
      Category = 'Design'
      Caption = 'Copia Campi Visibili'
      OnExecute = CopiaCampiVisibiliExecute
    end
    object OverrideCampo: TAction
      Category = 'Design'
      Caption = 'Override'
      ImageIndex = 417
      OnExecute = OverrideCampoExecute
      OnUpdate = OverrideCampoUpdate
    end
    object CopiaImpostazioniPerDX: TAction
      Category = 'Design'
      Caption = 'Copia Impostazioni Per DX'
      ImageIndex = 61
      OnExecute = CopiaImpostazioniPerDXExecute
      OnUpdate = CopiaImpostazioniPerDXUpdate
    end
    object Descrizione: TAction
      Category = 'Design'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
    end
    object LayoutEditor: TAction
      Category = 'Design'
      Caption = 'Layout'
      ImageIndex = 157
      OnExecute = LayoutEditorExecute
    end
    object EditTools: TAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
    object actSanifica: TAction
      Category = 'Edit'
      Caption = 'Sanifica'
      Hint = 
        'toglie caratteri invisibili, spazi anomali e punteggiatura tipog' +
        'rafica dal campo'
      ImageIndex = 357
      OnExecute = actSanificaExecute
      OnUpdate = actSanificaUpdate
    end
  end
  object popCard: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonactDbEdit'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbInsert'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbDelete'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactDbPost'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbCancel'
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
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditTitolo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'cxBarItemReadOnly'
      end
      item
        Visible = True
        ItemName = 'cxBarItemModifyFlags'
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
        ItemName = 'dxBarButtonCaricaImpostazioni'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton9'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactSQL'
      end
      item
        Visible = True
        ItemName = 'dxBarButton15'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'cxBarEditItemGriglia'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonGuideGriglia'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactPersonalizza'
      end>
    UseOwnFont = False
    OnPopup = popCardPopup
    Left = 118
    Top = 125
    PixelsPerInch = 96
  end
  object popEdit: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
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
        ItemName = 'dxBarButton2'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonOpenPicture1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSavePicture1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonDeletePicture'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonEditUndo1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCut1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCopy1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditPaste1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditDelete1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditSelectAll1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton1'
      end
      item
        Visible = True
        ItemName = 'dxBarSubItemControlloOrtografico'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonNewLine'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSeparatore'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonNascondiCampo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'cxBarEditItemGriglia'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonDistribuisciRiga'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonLarghezzaPiena'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonGuideGriglia'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditCtrlCaption'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSpinEditCtrlSize'
      end
      item
        Visible = True
        ItemName = 'dxBarSpinEditCtrlColSpan'
      end
      item
        Visible = True
        ItemName = 'dxBarSpinEditCtrlLines'
      end
      item
        Visible = True
        ItemName = 'cxBarEditItemCtrlFlag'
      end
      item
        Visible = True
        ItemName = 'cxBarItemCtrlType'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaPickList'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactInfoDebugLookup'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaLookup'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactNuovoLookup'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton13'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaCampo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaCard'
      end>
    UseOwnFont = False
    OnPopup = popEditPopup
    Left = 118
    Top = 189
    PixelsPerInch = 96
  end
  object cxGridViewRepository: TcxGridViewRepository
    Left = 233
    Top = 16
  end
end
