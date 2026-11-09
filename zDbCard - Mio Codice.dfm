object zDbCard: TzDbCard
  Left = 0
  Top = 0
  Width = 317
  Height = 245
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
  OnMouseWheel = FrameMouseWheel
  OnResize = FrameResize
  object cxScrollBox: TcxScrollBox
    Left = 0
    Top = 0
    Width = 217
    Height = 245
    Align = alClient
    BorderStyle = cxcbsNone
    HorzScrollBar.Visible = False
    PopupMenu = popCard
    TabOrder = 0
    Transparent = True
  end
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
    TabOrder = 1
    Visible = False
  end
  object pnlDescrizione: TdxPanel
    Left = 217
    Top = 0
    Width = 100
    Height = 245
    Align = alRight
    Frame.Drag.Enabled = True
    Frame.Visible = False
    TabOrder = 2
    Visible = False
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
    ImageOptions.Images = cxImageList
    ImageOptions.LargeImages = cxImageList
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
    object dxBarButton1: TdxBarButton
      Action = actResetSelected
      Category = 0
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 48
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
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton15'
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
      ImageIndex = 2
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
      Caption = 'Size:   '
      Category = 0
      Hint = 'modifica size'
      Visible = ivAlways
      OnChange = dxBarSpinEditCtrlSizeChange
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      InternalEditValue = 0
    end
    object dxBarSpinEditCtrlLines: TcxBarEditItem
      Caption = 'Lines: '
      Category = 0
      Hint = 'Lines: '
      Visible = ivAlways
      OnChange = dxBarSpinEditCtrlLinesChange
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      InternalEditValue = '0'
    end
    object dxBarEditCtrlCaption: TcxBarEditItem
      Caption = 'Label: '
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
      Action = TitoloCampo
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
      Action = EditTools
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
    object dxBarButtonCtrlSize: TdxBarButton
      Caption = 'Size'
      Category = 1
      Visible = ivAlways
      ImageIndex = 31
      ShortCut = 32851
    end
    object dxBarButtonCtrlLabel: TdxBarButton
      Caption = 'Label'
      Category = 1
      Visible = ivAlways
      ImageIndex = 30
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
    Images = cxImageList
    Left = 38
    Top = 125
    object CopiaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Copia Impostazioni'
      ImageIndex = 2
      OnExecute = CopiaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object IncollaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Incolla Impostazioni'
      ImageIndex = 3
      OnExecute = IncollaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object ModificaMemo: TAction
      Category = 'Memo'
      Caption = 'Modifica'
      ImageIndex = 37
      OnExecute = ModificaMemoExecute
      OnUpdate = ModificaMemoUpdate
    end
    object ModificaRTF: TAction
      Category = 'Memo'
      Caption = 'Modifica'
      ImageIndex = 37
      OnExecute = ModificaRTFExecute
      OnUpdate = ModificaRTFUpdate
    end
    object OpenPicture: TAction
      Category = 'Image'
      Caption = '&Apri immagine'
      Hint = 'apri immagine'
      ImageIndex = 19
      ShortCut = 16463
      OnExecute = OpenPictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object SavePicture: TAction
      Category = 'Image'
      Caption = '&Salva immagine'
      Hint = 'salva immagine'
      ImageIndex = 18
      ShortCut = 16467
      OnExecute = SavePictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object DeletePicture: TAction
      Category = 'Image'
      Caption = '&Elimina immagine'
      ImageIndex = 4
      ShortCut = 16453
      OnExecute = DeletePictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object PreviewPicture: TAction
      Category = 'Image'
      Caption = 'Anteprima'
      ImageIndex = 45
      OnExecute = PreviewPictureExecute
      OnUpdate = actEditorImageUpdate
    end
    object CaricaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Carica Impostazioni'
      ImageIndex = 33
      OnExecute = CaricaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object SalvaImpostazioni: TAction
      Category = 'Design'
      Caption = 'Salva Impostazioni'
      ImageIndex = 32
      OnExecute = SalvaImpostazioniExecute
      OnUpdate = VisibleIfAdmin
    end
    object actDbFirst: TDataSetFirst
      Category = 'Dataset'
      Caption = 'All'#39'inizio'
      Hint = 'All'#39'inizio'
      ImageIndex = 5
      ShortCut = 16420
    end
    object actDbPrior: TDataSetPrior
      Category = 'Dataset'
      Caption = 'Precedente'
      Hint = 'Precedente'
      ImageIndex = 6
      ShortCut = 16417
    end
    object actDbNext: TDataSetNext
      Category = 'Dataset'
      Caption = 'Successivo'
      Hint = 'Successivo'
      ImageIndex = 7
      ShortCut = 16418
    end
    object actDbLast: TDataSetLast
      Category = 'Dataset'
      Caption = 'Ultimo'
      Hint = 'Ultimo'
      ImageIndex = 8
      ShortCut = 16419
    end
    object actDbEdit: TAction
      Category = 'Dataset'
      Caption = 'Modifica'
      Hint = 'Modifica'
      ImageIndex = 9
      SecondaryShortCuts.Strings = (
        'Ctrl+Enter')
      ShortCut = 117
      OnExecute = actDbEditExecute
    end
    object actDbInsert: TAction
      Category = 'Dataset'
      Caption = 'Inserisci'
      Hint = 'Inserisci'
      ImageIndex = 10
      ShortCut = 118
      OnExecute = actDbInsertExecute
    end
    object actDbDelete: TAction
      Category = 'Dataset'
      Caption = 'Elimina'
      Hint = 'Elimina'
      ImageIndex = 11
      SecondaryShortCuts.Strings = (
        'Ctrl+Del')
      ShortCut = 120
      OnExecute = actDbDeleteExecute
    end
    object actDbRefresh: TAction
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 14
      ShortCut = 116
      OnExecute = actDbRefreshExecute
      OnUpdate = actDbRefreshUpdate
    end
    object CopyName: TAction
      Category = 'Design'
      Caption = 'Copia CardID'
      ImageIndex = 50
      OnExecute = CopyNameExecute
      OnUpdate = VisibleIfAdmin
    end
    object actDbPost: TAction
      Category = 'Dataset'
      Caption = 'Applica'
      Hint = 'Applica'
      ImageIndex = 12
      OnExecute = actDbPostExecute
      OnUpdate = actDbPostUpdate
    end
    object actDbCancel: TAction
      Category = 'Dataset'
      Caption = 'Annulla'
      Hint = 'Annulla'
      ImageIndex = 13
      OnExecute = actDbCancelExecute
      OnUpdate = actDbCancelUpdate
    end
    object actEdCut: TEditCut
      Category = 'Edit'
      Caption = 'Taglia'
      Hint = 'taglia'
      ImageIndex = 1
      ShortCut = 16472
    end
    object actEdCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Copia'
      Hint = 'copia'
      ImageIndex = 2
      ShortCut = 16451
    end
    object actEdPaste: TEditPaste
      Category = 'Edit'
      Caption = 'Incolla'
      Hint = 'Incolla'
      ImageIndex = 3
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
      ImageIndex = 0
      ShortCut = 16474
    end
    object actEdDelete: TEditDelete
      Category = 'Edit'
      Caption = 'Elimina'
      Hint = 'elimina'
      ImageIndex = 4
      ShortCut = 8238
    end
    object actSQL: TAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 28
      ShortCut = 57432
      OnExecute = actSQLExecute
      OnUpdate = VisibleIfAdmin
    end
    object actPersonalizza: TAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza griglia...'
      ImageIndex = 21
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
      OnUpdate = VisibleIfAdmin
    end
    object actPersonalizzaCampo: TAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza campo...'
      ImageIndex = 21
      ShortCut = 16506
      OnExecute = actPersonalizzaCampoExecute
      OnUpdate = actPersonalizzaCampoUpdate
    end
    object actPersonalizzaPicklist: TAction
      Category = 'Design'
      Caption = 'Personalizza Picklist'
      Hint = 'Personalizza Picklist...'
      ImageIndex = 21
      OnExecute = actPersonalizzaPicklistExecute
    end
    object actPersonalizzaLookup: TAction
      Category = 'Design'
      Caption = 'Personalizza Lookup'
      Hint = 'Personalizza Lookup...'
      ImageIndex = 19
      ShortCut = 123
      OnExecute = actPersonalizzaLookupExecute
    end
    object MostraQueryLookup: TAction
      Category = 'Design'
      Caption = 'Mostra Query Lookup'
      ImageIndex = 26
      OnExecute = MostraQueryLookupExecute
    end
    object actNuovoLookup: TAction
      Category = 'Design'
      Caption = 'Nuovo Lookup'
      ImageIndex = 62
      OnExecute = actNuovoLookupExecute
    end
    object actSelected: TAction
      Category = 'Design'
      Caption = 'Selected ...'
      ImageIndex = 26
      OnExecute = actSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object CopiaSelected: TAction
      Category = 'Design'
      Caption = 'Copia Selected'
      ImageIndex = 2
      OnExecute = CopiaSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object IncollaSelected: TAction
      Category = 'Design'
      Caption = 'Incolla Selected'
      ImageIndex = 3
      OnExecute = IncollaSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object actResetSelected: TAction
      Category = 'Design'
      Caption = 'Reset Selected'
      OnExecute = actResetSelectedExecute
      OnUpdate = VisibleIfAdmin
    end
    object NascondiCampo: TAction
      Category = 'Design'
      Caption = 'Nascondi Campo'
      ImageIndex = 49
      OnExecute = NascondiCampoExecute
      OnUpdate = NascondiCampoUpdate
    end
    object NewLine: TAction
      Category = 'Design'
      Caption = 'NewLine'
      ImageIndex = 29
      ShortCut = 16462
      OnExecute = NewLineExecute
      OnUpdate = VisibleIfAdmin
    end
    object Separatore: TAction
      Category = 'Design'
      Caption = 'Separatore'
      ImageIndex = 43
      OnExecute = SeparatoreExecute
      OnUpdate = VisibleIfAdmin
    end
    object MostraQueryUtilizzata: TAction
      Category = 'Debug'
      Caption = 'Mostra Query Utilizzata'
      ImageIndex = 15
      OnExecute = MostraQueryUtilizzataExecute
    end
    object CopiaQueryUtilizzata: TAction
      Category = 'Debug'
      Caption = 'Copia Query Utilizzata'
      ImageIndex = 37
      OnExecute = CopiaQueryUtilizzataExecute
    end
    object CopiaControlli: TAction
      Category = 'Design'
      Caption = 'Copia Controlli'
      ImageIndex = 2
      OnExecute = CopiaControlliExecute
    end
    object IncollaControlli: TAction
      Category = 'Design'
      Caption = 'Incolla Controlli'
      ImageIndex = 3
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
    object TitoloCampo: TAction
      Category = 'Design'
      Caption = 'Titolo...'
      ImageIndex = 43
      OnExecute = TitoloCampoExecute
      OnUpdate = TitoloCampoUpdate
    end
    object CopiaImpostazioniPerDX: TAction
      Category = 'Design'
      Caption = 'Copia Impostazioni Per DX'
      ImageIndex = 63
      OnExecute = CopiaImpostazioniPerDXExecute
      OnUpdate = CopiaImpostazioniPerDXUpdate
    end
    object Descrizione: TAction
      Category = 'Design'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 64
      OnExecute = DescrizioneExecute
    end
    object EditTools: TAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 65
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
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
        ItemName = 'dxBarButtonactPersonalizza'
      end>
    UseOwnFont = False
    OnPopup = popCardPopup
    Left = 118
    Top = 125
    PixelsPerInch = 96
  end
  object cxImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 12386342
    ImageInfo = <
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000016744558745469746C6500556E646F3B4172726F773B456469743BCB
          5CF1270000025C49444154785EB5936F48535F18C7BF77D7692BB1561626134D
          63B319230D86FDF951146868BEB0041B2EFB372367D01FEA45FBC1828CD4CA32
          FF65D60BC3B48282B0863175B6B5325A83A814B360D82B11493252B776EFD3BD
          372FAC17BD920E7C38700E9F2F0FCF730E4344F8574B21C00A307F15E4CBB3F7
          FC20020840A569BD28B0275A7A8A793EBA36F0DEADCDD8B0638A40206204688E
          8814DB1D1FBEF03C44F1E0F9CE55A76E3D7FDCDA3F4296DA5E02B04840295733
          323B0399A3D75FFC5189D2DAE0B4DA3B7C537D81090A703C992A9F5045B367F4
          485D6FCFFEEAAEE359397B97018892832C75EEDF7269E57DBDB5D1EDBDE11AA1
          E199107D0C71F46186A3518EA3B7933FC8F9699CEA9F0E51D9D5FEB1DD673A4A
          01C4889EB9BA4FEA015B56F76CACB8401F9F90A8C66C9891BA1726603AC44B84
          391E6A9560D14F74BB3EE3B56FD8EEB85C720940500C5064159DD3A996689A75
          86B4ADD9DB32A18C66C18BD982480078024004250B68E315E8720C62C0EBDFE7
          B9597E9789189932A3B0C6A25E9150BD29D7189BA2D3C0D1E1C1F4F76F58BC34
          0E49698948D5A740C13058AD2634B478C7075D6D99929D5E784D6E649426DBA2
          D3EEACE9CEB33DA2ED27BB2839BBD4B826DF5E6228AAEDDC7CF876F058E73B6A
          F47F255BFB1B5A676AF85F0A48CDBB288F46AE46A5D972FAD0C6F287130016CE
          755E956434AFCDD875C579A0E9253579026430B7BD92029273AB2459461EABC0
          020136E29C15884B2FA86AB3B60E50FA9EF609460AC8A99294C8474102B1CB93
          C10427E557279D0D3DA8508857DAFC0BF59C6AE57FCC3CFE498CB8CFFB372A30
          CFF50B153D09AADDB2FD980000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001F744558745469746C65004375743B426172733B526962626F6E3B53
          74616E646172643B9EE424DE0000032549444154785E85927D4C535718C62FB4
          F845196EF10F3448540644AD12C568158206D94417701D322C6D808252AC42B1
          463E8528D888AD016A6BB063912F8923925AA44D05B2588D18503794206A022D
          E8D46C685B688720218FF734AD1AFFD8DEE4C939E7FEDEF39C73DFF750747817
          CABBBBF34E5DE3D173062DAF8A0B3D54B9FA0E75A2DA44159CEDA48E567450E2
          92364A286DA1084F48AD49DE93A2E82273978154A6970D0D8F4354F49B945EFB
          100080FA5224979BAE940C5BFE0627B6E03459BB1CA3E3327D8F9ED20D3D338F
          439857AFA6C17C023D06EE9398DC749572F4C51B44FF50FA787968EC22CF0D5C
          CE02F185C893D59DB323CFADD82FAAD5AD08DDB6D87D8257F8961F593F65A8DB
          5EFF338954B16A6E3DE7E05617F384B8444B06265FAC91376B1F60ECA51D8919
          AADE90F571419C18E1525EF6C59E37562754759D088F3A5C4972433664501F43
          54D8EABA66087B87FFFE6CCDD3BE47AF68131BE205F2D1B4237516EBC414EEF6
          5BB079E7B127DF04ACFB8AE4AE64F33F1A78AA4BC4D8117F2C263BBF71EEF63D
          332A553730E19886E5B5034942C55C303B693BC901400586FDFCC94090D34006
          4FB158BB92CAAF97290C70FCFB1EC32F9DA8D218111691A6A799BFA7434BBF4D
          A4BE0C06AD45097C5956D119DDECA47306CF9E4FE2CE1F7F215B5A8BBD82CAD9
          A0D55C099D438ACBFCBC035E918212DFCC5FFAAB44F54F270FD50F41DD350AFD
          FD571834DB91537409EAABF7A0348CE0806600A9AA070E9EDCA4647F2FF4F398
          3079D57D35655A0B6E8D38611A7140613023FFD7FB58BB4584D08DE9286E7C08
          B9610C1D8F9D681F7420B77E1071457A156D308F182C8C97F5BCBDF9E23D3859
          4DF8EEB81606F33438E236D06C0D516C8111AD833308E7D5625B56331AFADF61
          6B6EBB95667EC4801529D15BABFF9C42B2C2849CA60154F4391096D264A7D912
          F2CF1B0F5CB51D373AB1ABD8007E4D2FC43A3BCD9B6D84B96E10CC3D5F17997F
          03B9372770F8F70944480C58B2BDBC919813BE7CF7B9BA4D1223922F5BB1AFF9
          2DD8A28ECF39C5F0F93A78198B53DAC28A3E67F58D92DB1644145EF1F60B0A24
          8C88B978D57FF04F2D242F2CC02D7F77ABFE977F003C798BE83E395B10000000
          0049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000025744558745469746C6500436F70793B426172733B526962626F6E3B
          5374616E646172643B436C6F6E656D0EDF5B000001B649444154785E7D90318B
          53411446CF7DD94D229AC24A2BC1CADE56248D8A76D65A2B6C6721DA0A82D66A
          A1A58DFD7656168B0B36D6AB85827F40566159F3E6CDBD9F929921210B4E3317
          1EE7BC33D724B17E66B3D9E8F9EBBD0F9DD95C18104842180290109053FAF8E4
          C18D6B5B9C3C9DD07CE7CE65A0C9A9F06A7EF1F6F35560B4149899011D6093C9
          647CE1FC1952EAF9B37000A28266DD3F62C47432C2B303582BE89EBDF954B265
          7CF97EC8C1B79F88AE660702CE9D9D72FBE62526E35364DF10483E7F74FFCA7F
          B39FBEDA27E78C24D210EB02CC73418E6BB6B07207C8C474DC2DB3DD45881305
          960747802464566E00A3CC1572050A11454013903C00080C095001010221897E
          88B5026D3E21832042C8A83308812850CE840721E1B1B18361080484B4064351
          14B1BB2384043E6C1464CFE54314A87A304140CB66BADD11802B00B47AC29254
          2D68FF368450D4820876DF1FF0F5C711B93FDA07721330785058519750E02613
          780A1EEE5CBF381E8F7F0103B06802A2EEE0F4740B54F090210588964D4AE9B0
          EFFBDF8D6B02EFD3F1DEBDC7BB73B15AA299AABD088645C906D814A4772FEFDE
          02B601033879A396BD2EF80B61825062DDA3F2C70000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000021744558745469746C650050617374653B426172733B526962626F6E
          3B5374616E646172643B259B079D000001EF49444154785E75523B681451143D
          6F77418D86A056DB0AC26A61A512035A8C168A59B0102C5C2C836817145448E3
          070C2954B00AC4C23695209A66D32A29B7B6B050D2C8261A7666DFE7DEEBDC97
          9D0167DD03877BE631E7BC3B87312282024FDF7CD6D18541A2C7C20266C26090
          6D3A3BBC7C78F32E142FBFA428502BC4B7F54EF712DE0A33270B9D8B98BDD0C2
          F9B916CECD9E427FA79F246655EEDC6F775141A3106A6C5D5FC4A7B51E9E3CDB
          867316DE79386B71FCE01E4ECE77B0D3FB904C0E20C1D16333B83DF713DBDF7F
          00C6A05ECBD9A8E1C8D40198BD3EB2D46262000546A30EB4CE9C40B33983DD5F
          BB00044669540A606A58FE9A1D5A8E071000AE2CB1F7EEA69CBEB188D0DF8277
          0E2B1B6721C239B5C89C3183A316D267C6ABA5F654B941F0040916E22D82B5DA
          099E3FB882FFC113E3E18B8F2AEB6500B900D0101C2CC8E72482E277EA2190A8
          45460440C46A336580B701EC33B0B3FB648682D55C1A254E551CE8DF80603DD8
          65FA0991C46A8D09718A1453A20E24E31B884F630FE41C288C0A4434A82E8354
          108F6DE0202103FB7C9203094723AB510C507EC2E40E36BAABEFAFEA4DE93080
          9AED7D33974645D1C578C0FCEBAD6B8536C64C2F3CE23F1C572F8AAC0471A583
          0A586FB8F7783DBEC8C2A31EB8BA519814305C5BB9353DFAD50D14E393000CFE
          023DB570481AE91B650000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000029744558745469746C650052656D6F76653B44656C6574653B426172
          733B526962626F6E3B5374616E646172643B635648300000026449444154785E
          A551494C5351146568194A2B583746627F458902118892AAB811369246043462
          8556D032A82D831664486D8C3FB40B8128E3C68998A289625720314469022591
          26566BC484681C22C6012B5A1556C7F73EBF507FDCF193F3DFBBE7DC7BDE7BF7
          86005811B820E80B2310F16B6880E4F7E10462AAF3F1B2014F889E961FBB307D
          AAE2EBC8FEDC137C72280FB1AB546BA0DAE4F11296C491940F36089F2CD5593F
          DFE8C682771453E71B31909D6D207C044D76166B8C339D1789E6C4A76B5D18D7
          15D9A869B04184A744E7FBED72C03FD08EF9B13BF09CADC1F50C55CDE08182DA
          B7ED562CB807E1BFDB06FF701F3C47753E52131D6C20B2EFCA343C31EAF1D3D1
          89B93E167F1EF5E37155255ED92C989F70E0C74D96E3C734F9B89498749A1E2A
          EC41644F4A6AF5B8F6107C7D2D98ED6D847FE80A7EDDBF8A6FBD4D98ED69C088
          3A0BD678A589E44A843D089844DB141B4D0FF3D5F8D251878FAC9EA08C5B87F6
          EC44B37C6D23C991F2530AF99F81E472BAAA7E42AFC307B612EFEA0E2FC1A52D
          446B5A4633C991090D968A5B93D24D4EAD06336DF5982E5363BA9C07D9BF674F
          62B4F020AC9B53976EF1CF145A36249B1EE4E5E28DA5022F8AB23045706B1383
          DB498974CFE1F599620CAB736061B63409A720ED5624CFBD341E81B760379EE5
          65A23F410183487ACE208EB1F42728E1CDCFE4F0BC641FBA9894395213176C10
          655EA3EC706CDF06778E0A76C57A5447C8E87B63298C91B166BB92817BEF0EDC
          4BDB8A0639D34DF8986083309A58278BEFB0C631BEAAC5E255940F6886A8D566
          A27DAF95ADEB22B15CD883808984208E209A8F859A9C6F6078F0145684BF98E8
          BFC080A205F60000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00E79C
          5200734210007342100073421000734210007B4210007B421000734210007342
          100073421000734210006B39100063391000E7944A00FFFFFF00FFFFFF007B42
          100094521800A55A1800A55A1800A55A1800A55A1800A55A1800A55A1800A55A
          1800A55A18009C5A1800945218007B4210005A311000FFFFFF00FFFFFF008C4A
          1800A55A1800E7A56B00B5632100B5632100BD6B2100CE732100CE732100EFBD
          9400FFFFFF00B56321009C5A1800844A10006B391000FFFFFF00FFFFFF009C5A
          1800B5632100FFFFFF00C66B2100C66B2100CE732100CE732100EFBD9400FFFF
          FF00FFFFFF00BD6B2100A55A18009452180073421000FFFFFF00FFFFFF00A55A
          1800BD6B2100FFFFFF00D6732100CE732100CE732100EFBD9400FFFFFF00FFFF
          FF00FFFFFF00BD6B2100AD6318009C5A180073421000FFFFFF00FFFFFF00B563
          2100CE732100FFFFFF00CE732100CE732100EFBD9400FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00BD6B2100AD631800A55A18007B421000FFFFFF00FFFFFF00BD6B
          2100D6732100FFFFFF00CE732100EFBD9400FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00B5632100A55A1800A55A1800844A1000FFFFFF00FFFFFF00C66B
          2100D67B2100FFFFFF00CE732100EFBD9400FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00AD631800A55A1800A55A1800844A1000FFFFFF00FFFFFF00D673
          2100DE843100FFFFFF00D67B2100CE732100EFBD9400FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00A55A1800A55A1800A55A1800844A1000FFFFFF00FFFFFF00D673
          2100DE8C4200FFFFFF00DE843100DE7B2900D67B2100EFBD9400FFFFFF00FFFF
          FF00FFFFFF00AD631800A55A1800A55A1800844A1000FFFFFF00FFFFFF00DE7B
          2900E79C5200FFFFFF00DE843100DE7B2900DE7B2900D67B2100EFBD9400FFFF
          FF00FFFFFF00B5632100A55A1800A55A1800844A1000FFFFFF00FFFFFF00DE8C
          4200E7A56B00E7A56B00DE8C4200DE843900DE843100DE843100DE7B2900EFBD
          9400FFFFFF00C66B2100B5632100A55A1800844A1000FFFFFF00FFFFFF00E794
          4A00EFB58400E7A56B00E79C5200E7944A00DE8C4200DE843900DE843100DE7B
          2900DE7B2900CE732100C66B2100A55A180073421000FFFFFF00FFFFFF00F7CE
          A500E7944A00DE843900DE7B2900D6732100D6732100CE732100CE732100C66B
          2100BD6B2100B5632100A55A180094521800E7A56300FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0084B5
          840010731000187318001873180018731800187B1800187B1800107B1000107B
          1000087B0800087B0800007B0000007300007BB57B00FFFFFF00FFFFFF001084
          1000218C210029942900319431003194310029942900299C2900219C210018A5
          180018A5180010A5100008A5080000940000006B0000FFFFFF00FFFFFF00188C
          180029942900399C3900399C3900399C390039A539004AA54A00A5D6A500FFFF
          FF004AA54A0031A5310018A51800009C0000007B0000FFFFFF00FFFFFF002194
          2100399C390042A5420042A5420042A542004AA54A00A5D6A500FFFFFF00FFFF
          FF004AA54A0039A5390021A5210008A50800087B0800FFFFFF00FFFFFF002994
          2900429C42004AA54A0052A552004AA54A00A5D6A500FFFFFF00FFFFFF00FFFF
          FF004AA54A0039A5390021A5210010A5100008840800FFFFFF00FFFFFF00319C
          31004AA54A0052A552004AA54A00A5D6A500FFFFFF00FFFFFF00FFFFFF00FFFF
          FF004AA54A0039A5390021A5210018A5180010841000FFFFFF00FFFFFF00429C
          420052A552004AA54A00A5D6A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF0042A5420031A53100219C2100219C210018841800FFFFFF00FFFFFF0042A5
          420052A5520052A55200A5D6A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00399C3900299C2900219C2100219C2100217B2100FFFFFF00FFFFFF0052A5
          52005AAD5A005AAD5A0052A55200A5D6A500FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00399C3900319431002994290029942900217B2100FFFFFF00FFFFFF0052A5
          52006BB56B006BB56B005AAD5A0052AD5200A5D6A500FFFFFF00FFFFFF00FFFF
          FF00399C3900319431002994290029942900217B2100FFFFFF00FFFFFF005AAD
          5A007BBD7B0073BD730063AD63005AAD5A005AAD5A00A5D6A500FFFFFF00FFFF
          FF00429C4200399C39003194310031943100217B2100FFFFFF00FFFFFF006BB5
          6B008CC68C007BBD7B006BB56B0063B5630063AD630063AD6300A5D6A500FFFF
          FF004AA54A0042A54200399C390031943100217B2100FFFFFF00FFFFFF0073BD
          73009CCE9C008CC68C007BBD7B0073BD73006BB56B0063B5630063AD63005AAD
          5A0052AD52004AA54A0042A542003194310018731800FFFFFF00FFFFFF00B5DE
          B50073BD730063B563005AAD5A0052A5520052A552004AA54A004AA54A0042A5
          4200429C4200399C390031943100218C21008CBD8C00FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0084B5
          840010731000187318001873180018731800187B1800187B1800107B1000107B
          1000087B0800087B0800007B0000007300007BB57B00FFFFFF00FFFFFF001084
          1000218C210029942900319431003194310029942900299C2900219C210018A5
          180018A5180010A5100008A5080000940000006B0000FFFFFF00FFFFFF00188C
          180029942900399C3900399C3900399C3900FFFFFF00A5D6A5004AA54A004AA5
          4A004AA54A0029A5290018A51800009C0000007B0000FFFFFF00FFFFFF002194
          2100399C390042A5420042A5420042A54200FFFFFF00FFFFFF00A5D6A5004AA5
          4A004AA54A0039A5390021A5210008A50800087B0800FFFFFF00FFFFFF002994
          2900429C42004AA54A0052A552004AA54A00FFFFFF00FFFFFF00FFFFFF00A5D6
          A5004AA54A0039A5390021A5210010A5100008840800FFFFFF00FFFFFF00319C
          31004AA54A0052A552004AA54A004AA54A00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00A5D6A50039A5390021A5210018A5180010841000FFFFFF00FFFFFF00429C
          420052A552004AA54A004AA54A004AA54A00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00A5D6A500219C2100219C210018841800FFFFFF00FFFFFF0042A5
          420052A5520052A552004AA54A004AA54A00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00A5D6A500219C2100219C2100217B2100FFFFFF00FFFFFF0052A5
          52005AAD5A005AAD5A0052A552004AA54A00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00A5D6A500319431002994290029942900217B2100FFFFFF00FFFFFF0052A5
          52006BB56B006BB56B005AAD5A0052AD5200FFFFFF00FFFFFF00FFFFFF00A5D6
          A500399C3900319431002994290029942900217B2100FFFFFF00FFFFFF005AAD
          5A007BBD7B0073BD730063AD63005AAD5A00FFFFFF00FFFFFF00A5D6A500429C
          4200429C4200399C39003194310031943100217B2100FFFFFF00FFFFFF006BB5
          6B008CC68C007BBD7B006BB56B0063B56300FFFFFF00A5D6A5005AAD5A0052A5
          52004AA54A0042A54200399C390031943100217B2100FFFFFF00FFFFFF0073BD
          73009CCE9C008CC68C007BBD7B0073BD73006BB56B0063B5630063AD63005AAD
          5A0052AD52004AA54A0042A542003194310018731800FFFFFF00FFFFFF00B5DE
          B50073BD730063B563005AAD5A0052A5520052A552004AA54A004AA54A0042A5
          4200429C4200399C390031943100218C21008CBD8C00FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00E79C
          5200734210007342100073421000734210007B4210007B421000734210007342
          100073421000734210006B39100063391000E7944A00FFFFFF00FFFFFF007B42
          100094521800A55A1800A55A1800A55A1800A55A1800A55A1800A55A1800A55A
          1800A55A18009C521800945218007B4210005A311000FFFFFF00FFFFFF008C4A
          1800A55A1800B5632100B5632100FFFFFF00EFBD9400CE732100CE732100CE73
          2100CE732100B5632100DE843100844A10006B391000FFFFFF00FFFFFF009C52
          1800B5632100C66B2100C66B2100FFFFFF00FFFFFF00EFBD9400CE732100CE73
          2100CE732100BD6B2100FFFFFF009452180073421000FFFFFF00FFFFFF00A55A
          1800BD6B2100CE732100D6732100FFFFFF00FFFFFF00FFFFFF00EFBD9400CE73
          2100CE732100BD6B2100FFFFFF009C52180073421000FFFFFF00FFFFFF00B563
          2100CE732100D6732100CE732100FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFBD
          9400CE732100BD6B2100FFFFFF00A55A18007B421000FFFFFF00FFFFFF00BD6B
          2100D6732100CE732100CE732100FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00EFBD9400B5632100FFFFFF00A55A1800844A1000FFFFFF00FFFFFF00C66B
          2100D67B2100D6732100CE732100FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00EFBD9400AD631800FFFFFF00A55A1800844A1000FFFFFF00FFFFFF00D673
          2100DE843100DE7B2900D67B2100FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFBD
          9400B5632100A55A1800FFFFFF00A55A1800844A1000FFFFFF00FFFFFF00D673
          2100DE8C4200DE8C4200DE843100FFFFFF00FFFFFF00FFFFFF00EFBD9400BD6B
          2100B5632100AD631800FFFFFF00A55A1800844A1000FFFFFF00FFFFFF00DE7B
          2900E79C5200E7944A00DE843100FFFFFF00FFFFFF00EFBD9400CE732100C66B
          2100BD6B2100B5632100FFFFFF00A55A1800844A1000FFFFFF00FFFFFF00DE8C
          4200E7A56B00E79C5200DE8C4200FFFFFF00EFBD9400DE843100DE7B2900CE73
          2100CE732100C66B2100DE843100A55A1800844A1000FFFFFF00FFFFFF00E794
          4A00EFB58400E7A56B00E79C5200E7944A00DE8C4200DE843900DE843100DE7B
          2900DE7B2900CE732100C66B2100A55A180073421000FFFFFF00FFFFFF00F7CE
          A500E7944A00DE843900DE7B2900D6732100D6732100CE732100CE732100C66B
          2100BD6B2100B5632100A55A180094521800E7A56300FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000B55A1000AD5A
          1000AD521000AD521000AD4A1000AD4A0800A54A0800A54A0800A5420800A542
          08009C3908009C39080000000000000000000000000000000000B5631000FFF7
          EF00FFF7EF00F7EFE700FFF7E700FFF7DE00FFEFDE00FFEFD600FFEFD600FFEF
          CE00FFE7CE009C42080000000000000000000000000000000000BD631000FFFF
          F700FFF7EF001829310018293100A5C6C600EFE7CE00F7E7CE00FFE7CE00FFEF
          D600FFEFCE00A542080000000000000000000000000000000000BD6B1000FFFF
          F700FFFFF700395A63005A9CA50052BDD6002984A5004A846300E7C6A500E7C6
          A500EFCEAD00A542080000000000000000000000000000000000BD6B1000FFFF
          FF00FFFFF700B5CEDE006BBDD6008CEFEF0021844200086B0800086B0800E7C6
          A500E7BDA500A542080000000000000000000000000000000000C6731000FFFF
          FF00FFFFFF00EFEFF7004294B500318452009CDEB50052BD6B00106B1000086B
          0800E7C6A500A54A080000000000000000000000000000000000C6731800FFFF
          FF00FFFFFF00FFFFFF005A9C9C005294520094C69C0094E7AD004AB56300106B
          1000086B0800AD4A080000000000000000000000000000000000C67B1800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00318431005294520084BD840084DEA50042B5
          5A00106B1000086B080000000000000000000000000000000000C67B1800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0031843100428C42006BB5730073D6
          940039AD5A00106B0800086B9C0084ADBD000000000000000000CE7B1800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0031843100398C39005AAD
          630063D684004294AD0031A5CE00086B9C000000000000000000CE841800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00318431003184
          31004294AD009CFFFF004294AD001018B50008089C0000000000CE841800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF004294
          AD0084EFF7004294AD00426BFF001842F7002131C6004A4AAD00CE841800FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7
          F7004294AD001010A500426BFF001842F70008089C0000000000CE841800CE84
          1800CE841800CE841800CE841800CE841800CE7B1800C67B1800C6731800C673
          1800C673100008089C002131C60008089C000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000004A4AAD00000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000000F0000000F0000000F0000000F0000000F0000000F0000000F
          0000000F0000000300000003000000010000000000000001000000030000FFF7
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000086B0800086B0800086B0800086B080000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000086B080042D6730031BD5A00086B0800A54A0800A5420800A542
          0800A5420800A54208009C3908009C3908009C39080000000000000000000000
          000000000000086B08007BF7A50042D67300086B0800FFF7E700FFF7DE00FFEF
          DE00FFEFD600FFEFD600FFEFCE00FFE7CE009C39080000000000086B0800086B
          0800086B0800086B08007BF7A50042D67300086B0800086B0800086B0800086B
          0800FFEFDE00FFEFD600FFEFD600FFEFCE009C39080000000000086B08007BF7
          A50052E784004AE784004ADE7B004ADE7B0042D6730042D6730031BD5A00086B
          0800FFF7DE00FFEFDE00FFEFD600FFEFD6009C42080000000000086B08007BF7
          A5007BF7A5007BF7A5007BF7A5004ADE7B007BF7A5007BF7A50042D67300086B
          0800FFF7E700FFF7E700FFEFDE00FFEFD600A542080000000000086B0800086B
          0800086B0800086B08007BF7A50052E78400086B0800086B0800086B0800086B
          0800FFF7EF00FFF7E700FFF7E700FFE7D600A542080000000000000000000000
          000000000000086B08007BF7A50052E78400086B0800FFFFF700FFFFF700FFF7
          F700FFF7EF00FFEFDE00F7E7CE00F7DEC600A54A080000000000000000000000
          000000000000086B08007BF7A5007BF7A500086B0800FFFFFF00FFFFF700FFEF
          E700F7E7D600F7DEC600F7D6B500F7D6B500A54A080000000000000000000000
          000000000000086B0800086B0800086B0800086B0800FFFFFF00FFFFFF00AD52
          0800AD520800AD520800AD4A0800AD4A0800AD4A080000000000000000000000
          000000000000BD630800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B552
          0800FFFFFF00FFF7EF00F7DEBD00AD4A08000000000000000000000000000000
          000000000000BD630800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B55A
          0800FFF7EF00F7DEBD00AD520800000000000000000000000000000000000000
          000000000000BD630800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B55A
          0800F7DEBD00B55A080000000000000000000000000000000000000000000000
          000000000000BD630800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B55A
          0800B55A08000000000000000000000000000000000000000000000000000000
          000000000000BD630800BD630800BD630800BD630800BD630800BD630800B563
          0800000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00E1FF0000E0010000E001000000010000000100000001000000010000E001
          0000E0010000E0010000E0030000E0070000E00F0000E01F0000E03F0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000ADAD9C009C9C84009C9C84009C9C84009C846B009C84
          6B00AD9C7B000000000000000000000000000000000000000000000000000000
          000000000000EFDED600FFEFBD00FFDEB500FFDEAD00FFDEB500FFEFBD00FFF7
          CE00FFDEB5009C846B0000000000000000000000000000000000000000000000
          0000EFDED600FFFFD600FFDEAD00FFD69C00FFCE8C0029A52900FFF7DE00FFF7
          DE00FFFFDE00FFFFD6009C846B00000000000000000000000000000000000000
          0000DEB58400FFDEA500FFF7CE00FFD6A500FFCE8C0029A52900008400000084
          0000108C1000BDEFB500FFFFD6009C846B000000000000000000000000000000
          0000F7B57300F7AD6B00FFBD8400FFDEAD00FFF7BD0029A529000084000039AD
          3900EFFFEF0029A52900FFDEB500AD9C7B00000000000000000000000000EFDE
          D600FFB57B00FFB57B00FFB57B00FFB57B00FFD6A50029A5290029A52900108C
          1000D6EFCE0073CE7300BDCE8C00AD9C7B00000000000000000000000000EFD6
          B500FFCE8C00FFCE8C00FFCE8C00FFCE8C00FFDEBD006BBD6300FFF7DE005AB5
          5A0029A5290029A52900D6DEAD00CEBD9C00000000000000000000000000F7D6
          AD00FFD6A500FFD6A500FFD6A500FFD6A500FFDEAD0039AD39006BBD63006BBD
          6B000084000029A52900FFDEB500CEBD9C00000000000000000000000000FFDE
          AD00FFEFB500FFEFB500FFEFB500FFEFB500FFEFB500D6EFB500108C10000084
          00000084000029A52900FFEFCE00CEBD9C00000000000000000000000000FFDE
          AD00FFFFD600FFFFD600FFFFD600FFFFD600FFFFD600FFFFD600EFFFD600ADDE
          A500BDEFB50029A52900FFFFDE00D6D6B500000000000000000000000000FFCE
          9C00FFFFD600FFFFD600FFFFD600FFFFD600FFF7CE00FFEFB500FFD6A500FFDE
          A500FFEFBD00FFFFD600FFFFD600D6D6B500000000000000000000000000FFDE
          BD00FFCE9C00FFCE9C00FFCE9C00EFBD8C00EFA55A00EFA55200EFA55A00F7AD
          6300F7AD6300F7B57300FFDEAD00D6D6B5000000000000000000000000000000
          00000000000000000000000000000000000000000000FFCE9C00EFBD8C00F7AD
          6B00F7AD6B00F7B57300F7B57300FFD69C000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000FFCE9C00FFB57B00FFB57B00F7BD8C000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000F01F0000E00F0000C0070000C0030000C0030000800300008003
          00008003000080030000800300008003000080030000FE030000FFC30000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000006300000063000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000063000018B5310018B5310000630000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000063000031C64A0021B5390018B5290021B53100006300000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000063000042D66B0039CE5A0021AD39000063000018AD290018B531000063
          0000000000000000000000000000000000000000000000000000000000000063
          00004AD67B0052DE7B0031B54A00006300000000000000630000109C210018AD
          3100006300000000000000000000000000000000000000000000000000000000
          00000063000042C6630000630000000000000000000000000000000000000063
          000018AD29000063000000000000000000000000000000000000000000000000
          0000000000000063000000000000000000000000000000000000000000000000
          000000630000109C210000630000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000630000006300000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000006300000063000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000F9FF0000F0FF0000E07F0000C03F0000821F0000C78F
          0000EFC70000FFF30000FFF90000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000009C0000009C00000000000000000000000000000000000000
          00000000000000009C0000009C00000000000000000000000000000000000000
          000000009C00104AFF001039F70000009C000000000000000000000000000000
          000000009C000029FF000031FF0000009C000000000000000000000000000000
          000000009C001842FF00184AFF001039F70000009C0000000000000000000000
          9C000029F7000031FF000029F70000009C000000000000000000000000000000
          00000000000000009C001842F700184AFF001039F70000009C0000009C000029
          FF000031FF000029F70000009C00000000000000000000000000000000000000
          0000000000000000000000009C00184AF7001852FF001039FF000031FF000031
          FF000029F70000009C0000000000000000000000000000000000000000000000
          000000000000000000000000000000009C00184AFF001042FF000839FF000031
          F70000009C000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000009C00214AFF00184AFF001842FF001042
          F70000009C000000000000000000000000000000000000000000000000000000
          0000000000000000000000009C00295AFF00295AFF00214AFF00214AFF002152
          FF001842F70000009C0000000000000000000000000000000000000000000000
          00000000000000009C003163FF00396BFF00295AF70000009C0000009C00214A
          F700215AFF00184AF70000009C00000000000000000000000000000000000000
          000000009C004273FF004273FF00315AF70000009C0000000000000000000000
          9C00214AF700215AFF00214AFF0000009C000000000000000000000000000000
          000000009C004A7BFF003963F70000009C000000000000000000000000000000
          000000009C002152F7002152FF0000009C000000000000000000000000000000
          00000000000000009C0000009C00000000000000000000000000000000000000
          00000000000000009C0000009C00000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000E7E70000C3C30000C1830000E0070000F00F0000F81F
          0000F81F0000F00F0000E0070000C1830000C3C30000E7E70000FFFF0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000B55A1000AD5A1000AD521000AD521000AD4A1000AD4A0800A54A0800A54A
          0800A5420800A54208009C3908009C3908000000000000000000000000000000
          0000B5631000FFF7EF00FFF7EF00FFF7E700FFF7E700FFF7DE00FFEFDE00FFEF
          D600FFEFD600FFEFCE00FFE7CE009C4208000000000000000000000000000000
          0000BD631000FFFFF70073B56B00FFF7EF00E7EFD600ADC69C00A5C68C00DEDE
          BD00FFEFD600FFEFD600FFEFCE00A54208000000000000000000000000000000
          0000BD6B1000FFFFF700087B08007BBD7B00107B1000187B1800087308000873
          08004A944200F7E7CE00FFEFD600A54208000000000000000000000000000000
          0000BD6B1000FFFFFF00087B080008840800087B0800107B1000318C3100529C
          4A00187B1800398C3900FFEFD600A54A08000000000000000000000000000000
          0000C6731000FFFFFF00087B080008840800088408007BBD7B00FFF7EF00FFF7
          EF00F7EFDE006BA56300FFEFDE00AD4A08000000000000000000000000000000
          0000C6731800FFFFFF00087B0800087B0800087B0800087B08007BB57300FFF7
          EF00FFF7EF00FFF7E700FFF7E700AD5210000000000000000000000000000000
          0000C67B1800FFFFFF00FFFFFF00FFFFFF00FFFFFF007BBD7300087B0800087B
          0800087B0800087B0800FFF7E700AD5210000000000000000000000000000000
          0000C67B1800FFFFFF006BBD6B00F7F7F700FFFFFF00FFFFFF007BBD7B000884
          080008840800087B0800FFF7EF00B55A10000000000000000000000000000000
          0000CE7B1800FFFFFF0039AD3900189C180052B5520031A5310010941000088C
          080008840800087B0800FFF7EF00B55A10000000000000000000000000000000
          0000CE841800FFFFFF00F7F7F7004AB54A000894080008940800189418001094
          100073BD7300087B0800FFFFF700B56310000000000000000000000000000000
          0000CE841800FFFFFF00FFFFFF00FFFFFF00DEEFDE00A5D6A500ADDEAD00E7F7
          E700FFFFFF0073BD7300FFFFF700BD6310000000000000000000000000000000
          0000CE841800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00BD6B10000000000000000000000000000000
          0000CE841800CE841800CE841800CE841800CE841800CE841800CE7B1800C67B
          1800C6731800C6731800C6731000BD6B10000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000C0030000C0030000C0030000C0030000C0030000C0030000C003
          0000C0030000C0030000C0030000C0030000C0030000C0030000C0030000FFFF
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000023744558745469746C6500466F72636520546573743B546573743B43
          6865636B3B5265706F72743BE21C20C60000026A49444154785E6D904F489659
          14879FF73328371A1584E04833A3ED828A8666A046A23F339448A4106D8C9040
          1C67461B685331E0A6B1C1465AA80CD810592DAC859B92C4040D82205C994A5A
          C360832E6A94C4AFEFBBF79C13F7E2877C8EF7E52CDE0BBFE7FC9EBB01488014
          90AC0C75E71A36977E567633490A8E99CAE337AF67EAEFDDE95960F528206666
          01909ABE5537944AACD2CCF863AC0C80EAAAEFA928FF8257D3AFAB7AEF3E986F
          6ABEC4F9B217A8281F336EF49BCBC38701170129ACB2F4F8CFCC8DF450B03CCB
          CEBD87705E9878F50FF373EFF87C472963CF06F97B5B8A23A7CF32DED77D1028
          C80112350175A808ED5D7FD1D5DD4367D79FBC9DFD979292EDECD9BD8BC6968B
          2C0EB7623E837A4F4E3700622D0B001552494263433DD5274FF0DFC202E9A565
          0A371552545C4CD1968D64DF4F235EF20089A9806430EF300303B66ED916E7E5
          CC732E75D672BB6D822571E0B3A8F87C808AA09245C4A3668051DB5CCEAF3FDC
          E54AC719FAAE4FE1BD22D9100E2300E40088487413E722C0CCE86D9BE4545305
          F76F4CE1541135C467896F206B150240D2A87768D88445CFBE8E49BC28002A16
          1798B87514BC602E83F70E278A99D25FF51D5F5FFD9DD18BBF50D53F80AA1201
          BA8E82AAC7FC47C465A36BF8BE6AFD8DA1969F38D0D68EA8101B88C3BCFBBF42
          A8AB2E0D80F712B70D5EF891CA6B1D0C353751F36838DE015858B616A07EB581
          9AA1A6D43C7C0210C3B913DDC521A2790A8988C75C3A3ABEE93E1A2B5BB85BD9
          AA2A00F1DF54C2E429987A417C862FF7EF43D38B106A9A400099C62021481E80
          1CC02FA5B323E30383DF9A282A2114801AC32AB990E6860F19790A38804F5AC3
          D2E4891DA0CA0000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000010731000107310000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000010731000B5E7BD0063BD3900086B
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000217B2100B5E7BD0063BD39001073
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000217B2100A5DEB5005AB531001073
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000187318009CD6AD0052B531001073
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000219C390039CE6B0021BD4200088C
          1000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000021A5390042DE7B0029CE5A0018B5390008A5
          1800008400000000000000000000000000000000000000000000000000000000
          0000000000000000000029AD420052EF8C0039D6730029C6520018B5310008A5
          0800009C00000084000000000000000000000000000000000000000000000000
          00000000000031AD4A006BFF9C0052EF8C0039D6730029C6520010B5290000A5
          0800009C0000009C000000840000000000000000000000000000000000000000
          000029A5420052E7840042D6730029B5520018A5390010942100088C08000084
          000000840000008C0000008C0000007B0000000000000000000000000000006B
          0000088408002184000021840000008C100042AD520052DED60000D6DE00089C
          940031AD4A0031BD520029AD420008941800087B10000000000000630000007B
          00008CA50800F7B53900EFAD210094A5100010BD390073DE9C0052F7FF0000E7
          FF0018ADB5005AE78C0042E76B0094D6B500219C310000630000000000000063
          0000E7BD7B00F7EFB500EFDE7B00DEA51000006B0800006B000063A56B0052F7
          FF00007B6B00005A00005A8C5A00FF7BF7005221520000000000000000000000
          0000E7C6A500FFFFF700F7E7A500DEAD21000000000000000000000000000000
          00000000000000000000FFB5FF00FF08FF00BD00BD0094009400000000000000
          000000000000D6B58C00D6AD5A00000000000000000000000000000000000000
          00000000000000000000FFDEFF00FF4AFF00A500A50000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000FFADFF000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FE7F0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F0000F81F0000F00F
          0000E0070000C0030000800100000000000080010000C3F00000E7F10000FFFB
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000001010A5001010A5000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000001010A500848CE7005A5AD6000808
          9C00000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000002121A500848CE7005A5AD6001010
          A500000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000001821A5008484E7005252CE001010
          A500000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000001818A5007B73E700524AD6001010
          A500000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000002110BD003918E7002910DE001810
          BD00000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000002921BD004A39EF003110E7002900E7002910
          DE001810B5000000000000000000000000000000000000000000000000000000
          000000000000000000003131BD006B6BEF00524AEF004221EF002908E7002908
          DE002918D6001810B50000000000000000000000000000000000000000000000
          0000000000003139C6007B84F700737BF700635AEF004A39EF003918EF002900
          E7002910DE002929CE001818B500000000000000000000000000000000000000
          00002931BD005A63E700525ADE00424AD6003939CE002921CE002108C6001800
          C6001800C6001810BD002121BD001010AD000000000000000000000000000000
          A5001010AD0031298C0031298C001010AD004A4AC60052D6EF0000C6EF00088C
          AD003939BD004242CE003139C6002118BD000808A5000000000000009C000808
          AD009C7B5200EFBD3100EFB518009C7B4A002121C6006B7BDE004AFFFF0000E7
          FF0018A5BD00636BD6005A52EF004A8CA5002121B50000009C00000000001010
          A500DEBD7300F7EFB500EFD67B00DEA5100000009C0000009C006363C60052FF
          FF0000639C000000AD00084A6B0008D60000084A310000000000000000000000
          0000E7C69C00FFFFF700F7E7A500DEAD21000000000000000000000000000000
          0000000000000000000008D6000000FF000010BD0000218C0000000000000000
          000000000000D6B58C00D6AD5A00000000000000000000000000000000000000
          0000000000000000000008CE080000EF0000189C000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000008C608000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FE7F0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F0000F81F0000F00F
          0000E0070000C0030000800100000000000080010000C3F00000E7F10000FFFB
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001C744558745469746C65005361766520416E64204E65773B53617665
          3B4E65773BE56EEA4B000001FD49444154785E858F3D6854511085BF97BC2446
          1042AC6C44C1C2609A20D609A8752C5258281AECD3A4B070414CE15F61A98D95
          58D9A8888D221AB016C1803F9558086A347F9BDDECBB3373DC5C36BA289AC33D
          7CD39C73678AE9D91BCFA19858FBF69590131E4474DBD9B16B08779B7F74F7DA
          51494E974A898923874779FAF809B76FCD2189081122CF67A667D93950B2BAD6
          1A077A0F8C1E3304A0D782B132C2B164B8A51CFCF2A3817B6012E1C2DC32DD1C
          A090542010124019EE24B3B613E641658EC7D616EA1407D6662E0841811080D4
          937F4B8699E550B2C05CB9440273CF05EE9D0D10528C654A637983CA0C37E3D4
          E9195C8E2290948302DC024F09A0F7E3BB173DC01BA0CC8D53E72E6AE4D041BE
          2F2E934388F5E5259AF53A1E417FFF20C3BBF7D068ACB377FF0821908208A110
          9C385BD3F92B7734357D417F2AA5A4672F3FE85F9A9DBBAF32CCB094B2011657
          36321154A962ADD10260A591100240CACE27969BC1B4E9AAA2F6F03D16C29DCC
          6AA3C5407D95C9E31088FC3294691194D54673FEEDC2C27811C1C2AB4F2487AA
          55D16A391BF515F60D0F20802053DAA2080F0A6010E8833C6775CD83ED3B3F5F
          AF4DB2B45E91C3D2AFA24B571F504A6A026DFFADA228CC23902024A402BA4E70
          774AFEAF1E772787E37710C8F4D0B605720F666AF740EA147598E7D8B6A079F3
          F2C921A0AFFBB22EA69FCBA9E7D64590FD530000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000000B744558745469746C65004F70656E3B49C97792000002
          8849444154785E7D934F68545718C57FEFCD4B63CBB45D64A3ADD0952D45B40B
          D12E3428044A70530ADDE8AA94820B1BD09D10442D0A0117225D28A5C9AA0B6D
          A14BDB458B055B4C2853D4A869689A2131FFCC4C26C9CCBCCCBCB9F7FBBE4E2E
          1310D11E38F7703F2EE770E07E9199F1324451C4A12FE9EE7E9D736A7C117B70
          19C3A529BE9AF8890CB098FF4794BCC669DFE4F6ED21DEAA57F9D4B78DDED8C9
          C50327102017E5F3F91888003A6A1D6ABD5E8F9E33CCEDFB9CF351CCA0291446
          E84EEE5E3DF86B1C730423C014D2A63FDE7766EC26A0070740141018BD1E0206
          D581582771FCDB8F6CF767C30460F8668DC91F06577E199BF9E0EC77FF947806
          22123BE7726DB5360470893805A9829BC3544910DEFBF8648FB8AFE77E7BFF4D
          3030B3A06A11CED99DFE8B85BE5AADE60012F10A262019917A304F4E53F61C3B
          45F4CA7620025340311346AF0CF402B93F2EF53A5548D44930C03731DF40DB44
          1CA40B98FD05CE612A8004A35A3905C8F70FDD8B0189EE0E1DB60F072EA3EB0F
          28FF5D606D611953421D3503354C0D550DBAF2A48C756AA95829712DA1B1FA94
          6CB1C8FAD33ABB3EB94014C521CDCC817A4C5A04FA8C4069B23A5B64ECFB1B33
          896442756186B5C929F23BF762AD2A1BFFFE8CA960AA604131F52012E6AAC2FC
          C359D6AAFE56E29CB03253245DAEB063DF3B644BE3F8FAEAD643100D06A8EFD4
          F261569E5EE6D17CFA63E2324FA538CDB6AE6D74254263F63ED2A875923DE615
          63CB443011D2F52695D5C6E36BA3A5E9A4B1D1C29696E8D9F32ECDC509B2CA7C
          27B553814DB5700705354AF3752AA9BF05B86423F57FE2ABFB277F2F307967EB
          D304C5009400B370A006CEDBDCF8E2C608D0DA5CA657812EE0459BF9FC3219E0
          80E63747DF1680FF001724CEF504A838340000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CE630000CE63
          0000CE630000CE630000CE630000CE630000CE630000CE630000CE630000CE63
          0000CE630000CE630000CE630000CE630000CE630000CE630000CE630000FFF7
          EF00FFF7E700FFF7E700FFF7E7009C310000FFEFDE0000009C00FFEFD6009C31
          0000FFEFCE00FFEFCE00FFEFCE00FFEFCE00FFEFCE00CE630000CE630000FFFF
          EF00FFF7EF00FFF7E700FFF7E7009C310000FFEFDE0000009C00FFEFD6009C31
          0000FFEFCE00FFEFCE00FFEFCE00FFEFCE00FFEFCE00CE630000CE630000FFFF
          F700FFF7EF00FFF7EF00FFF7E7009C310000FFF7DE0000009C00FFEFD6009C31
          0000FFEFD600FFEFCE00FFEFCE00FFEFCE00FFEFCE00CE630000CE630000FFFF
          F700FFFFEF0000630000FFF7EF009C310000FFF7E70000009C00FFEFDE009C31
          0000FFEFD60000630000FFEFCE00FFEFCE00FFEFCE00CE630000CE630000FFFF
          F7000063000000630000FFF7EF009C310000FFF7E70000009C00FFF7DE009C31
          0000FFEFD6000063000000630000FFEFCE00FFEFCE00CE630000CE6300000063
          000039C65A00006300000063000000630000FFF7E70000009C00FFF7E7000063
          000000630000006300004AD6730000630000FFEFCE00CE630000CE630000FFFF
          FF000063000000630000FFFFF7009C310000FFF7EF0000009C00FFF7E7009C31
          0000FFF7DE000063000000630000FFEFD600FFEFCE00CE630000CE630000FFFF
          FF00FFFFFF0000630000FFFFF7009C310000FFFFEF0000009C00FFF7E7009C31
          0000FFF7DE0000630000FFEFDE00FFEFD600FFEFD600CE630000CE630000FFFF
          FF00FFFFFF00FFFFFF00FFFFF7009C310000FFFFF70000009C00FFF7EF009C31
          0000FFF7E700FFF7DE00FFEFDE00FFEFD600FFEFD600CE630000CE630000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF009C310000FFFFF70000009C00FFF7EF009C31
          0000FFF7E700FFF7E700FFF7DE00FFEFDE00FFEFD600CE630000CE630000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF009C310000FFFFF70000009C00FFFFEF009C31
          0000FFF7E700FFF7E700FFF7E700FFF7DE00FFEFDE00CE630000CE630000CE63
          0000CE630000CE630000CE630000CE630000CE630000CE630000CE630000CE63
          0000CE630000CE630000CE630000CE630000CE630000CE630000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000A5736B00A573
          6B00A5736B00A5736B00A5736B00A5736B00A5736B00A5736B00A5736B00A573
          6B00000000000000000000000000000000000000000000000000A5736B00EFDE
          D600EFDECE00EFDECE00EFD6C600EFD6C600EFD6C600EFD6C600EFDECE00A573
          6B00000000000000000000000000000000000000000000000000BD8C8400FFF7
          E700F7EFE700F7EFDE00F7EFDE00F7E7D600F7E7D600F7E7D600FFEFDE00A573
          6B00000000000000000000000000000000000000000000000000C68C8400FFF7
          EF00FFDEC600FFD6B500FFD6B500FFD6B500FFD6B500F7DEBD00F7EFDE00A573
          6B00000000000000000000000000000000000000000000000000CE948C00FFF7
          EF00FFEFDE00FFE7D600F7E7CE00F7E7CE00F7E7CE00F7DECE00F7EFD600A573
          6B00000000000000000000000000000000000000000000000000D69C8C00FFFF
          F700FFDEC600F7D6B500FFD6B500FFD6B500F7D6AD00DEC6AD00DED6C600A573
          6B00000000000000000000000000000000000000000000000000D6A58C00FFFF
          F700EFDED600D6C6BD00DED6C600EFDECE00CEC6B500A59C9400A5A59C00947B
          7300000000000000000000000000000000000000000000000000DEAD8C00FFFF
          FF009CA5B500AD947B00B5948400BDA58C0052739C005A7BA500636373007363
          5A000000000000000000000000005A5252004242420042424200E7AD8C00FFFF
          FF0052739C0052739C009C9C940052739C007BC6E70052739C0042528400524A
          6300000000008C8C9400525252005A525200393939005A525200E7B58C00FFFF
          FF0052739C00CEEFF70052739C007BC6E70052739C007BC6E70052739C00395A
          8C00314A84008C8C940094949C005A525200524A4A005A525200EFBD9400FFFF
          FF00FFFFFF0052739C00CEEFF70052739C007BC6E70052739C007BC6E7005AAD
          EF004A9CE7008C8C9400F7F7F7005A5252006B636300635A5A00EFBD9400FFF7
          EF00FFF7EF00FFF7EF0052739C00A5EFF70052739C007BC6E7006BBDEF005AAD
          EF004A9CE7008C8C9400F7F7F7005A5252007373730073737300EFBD9400E7B5
          9C00E7B59C00E7B59C00DEB59C0052739C0094C6DE00C6EFF7006BC6F7005AAD
          EF00395A9C008C8C9400F7F7F7005A5252008C8C8C008C8C8C00000000000000
          000000000000000000000000000000000000000000006B94C6005A8CC600526B
          A500000000008C8C94008C8C94005A5252008C8C8C007B7B7B00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000005A5252005A5252005A525200}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000003F0000003F0000003F0000003F0000003F0000003F0000003F
          0000003800000020000000000000000000000000000000000000FE200000FFF8
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000B5848400B5848400B5848400B5848400B5848400B5848400B5848400B584
          8400B5848400B5848400B5848400B5848400B584840000000000000000000000
          0000636B7B00FFEFD600F7E7C600F7DEBD00F7DEB500F7D6AD00F7D6A500F7CE
          9C00F7CE9400F7CE9C00F7CE9C00F7D69C00B584840000000000000000005A9C
          C600318CD6007B849C00F7E7CE00F7DEC600F7DEBD00F7D6B500F7D6AD00F7D6
          A500EFCE9C00EFCE9400EFCE9400F7D69C00B584840000000000000000000000
          00004AB5FF00298CE70084849C00F7E7CE00F7DEC600F7DEBD00F7D6B500F7D6
          AD00F7D6A500EFCE9C00EFCE9400F7D69C00B584840000000000000000000000
          0000B58473004AB5FF00218CDE007B849C00F7E7CE00F7DEC600F7DEBD00F7D6
          B500F7D6AD00F7D6A500EFCE9C00F7D69C00B584840000000000000000000000
          0000BD8C8400FFFFF7004ABDFF005A94BD00A5847B00BD948C00AD7B7B00BD94
          8C00D6B59C00F7D6AD00F7D6A500F7D69C00B584840000000000000000000000
          0000BD8C8400FFFFFF00FFF7EF00BDA59C00C6A59C00E7CEBD00F7DEC600E7C6
          AD00C69C9400D6B59C00F7D6AD00F7D6A500B584840000000000000000000000
          0000CE9C8400FFFFFF00FFFFF700C69C9400E7CEC600FFEFDE00FFE7D600FFFF
          F700E7C6AD00BD948C00F7DEB500F7DEAD00B584840000000000000000000000
          0000CE9C8400FFFFFF00FFFFFF00AD7B7B00FFEFE700FFEFE700FFEFDE00FFFF
          F700F7DEC600AD7B7B00F7DEBD00FFDEB500B584840000000000000000000000
          0000DEAD8400FFFFFF00FFFFFF00C69C9C00E7D6D600FFF7EF00FFEFE700FFFF
          DE00E7CEBD00BD948C00F7E7C600F7DEB500B584840000000000000000000000
          0000DEAD8400FFFFFF00FFFFFF00DECECE00CEADAD00E7D6D600FFEFE700E7CE
          C600C6A59C00C6A59400E7DEC600C6BDAD00B584840000000000000000000000
          0000E7B58C00FFFFFF00FFFFFF00FFFFFF00DECECE00C69C9C00AD7B7B00C69C
          9400D6BDB500BD847B00BD847B00BD847B00B584840000000000000000000000
          0000E7B58C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00E7CECE00BD847B00EFB57300EFA54A00C6846B0000000000000000000000
          0000EFBD9400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00E7D6D600BD847B00FFC67300CE9473000000000000000000000000000000
          0000EFBD9400FFF7F700FFF7F700FFF7F700FFF7F700FFF7F700FFF7F700FFF7
          F700E7D6CE00BD847B00CE9C8400000000000000000000000000000000000000
          0000EFBD9400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD
          8400DEAD8400BD847B0000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00C0010000C001000080010000C0010000C0010000C0010000C0010000C001
          0000C0010000C0010000C0010000C0010000C0010000C0030000C0070000C00F
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000848484008484840084848400848484008484
          8400848484008484840084848400848484000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000848484000000000000000000000000000000
          0000000000000000000000000000000000000000000084848400000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000848484000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008484
          8400000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000848484000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000084848400848484000000000000000000000000000000
          0000000000000000000000000000000000000000000084848400848484008484
          8400848484008484840000000000848484000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000F8030000F0030000F8F70000FC7F0000FE3F0000FF1F
          0000FE7F0000FCF30000F8030000F0070000FFFF0000FFFF0000FFFF0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000B5848400B5848400B5848400B5848400B5848400B5848400B584
          8400000000000000000000000000000000000000000000000000000000000000
          000000000000B5848400EFDEC600FFEFD600B5D69C00CED6AD00EFDEB500F7D6
          B500B5848400B5848400B5848400B58484000000000000000000000000000000
          000000000000B5848400EFD6C600FFEFD60029AD4A0029AD4A005AB56300E7D6
          AD00FFDEBD00EFD6AD00DED69C00E7CE9C00B5848400B5848400000000000000
          000000000000BD8C8400F7DEC600FFEFDE0031AD4A0010A5390021AD4200D6D6
          AD00FFDEBD00CECE9C0031AD4A0010A53900ADC67B00B58484000000000042B5
          DE0042B5DE00BD8C8400F7DEC600FFEFDE00CEDEB50063BD6B007BBD7B00F7DE
          BD00FFDEBD00DED6A50042B5520000A531009CC67B00B584840042B5DE007BDE
          F70094E7FF00CE9C8400F7DECE00FFF7E700FFEFE700DEDEC6006BBD7300EFE7
          C600FFE7C600F7DEBD0063B56300A5C68400EFD6A500B584840042B5DE0094E7
          FF00BDEFFF00CE9C8400F7DECE00FFF7EF00FFEFDE00FFEFDE00ADCE9C009CCE
          9400DEDEB500A5CE940084BD7B00F7DEB500F7DEB500B584840042B5DE009CE7
          FF00D6FFFF00DEAD8400F7DED600FFF7EF00FFEFE700FFEFDE00EFE7CE0052B5
          630021AD420052B56300E7DEB500FFDEBD00F7DEB500B584840042B5DE009CE7
          FF00DEFFFF00E7B58C00F7E7D600FFFFF700FFF7EF00FFF7E700EFE7D60042B5
          5A00009C29004AB55A00EFDEBD00FFDEC600F7DEBD00B584840042B5DE009CE7
          FF00DEFFFF00EFBD9400F7E7DE00FFFFFF00FFFFF700FFF7EF00F7F7E700A5D6
          A50084CE8C00ADD69C00F7E7CE00FFE7C600FFE7C600B584840042B5DE009CE7
          FF00DEFFFF00EFBD9400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD
          8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400B584840042B5DE009CE7
          FF00E7FFFF00D6E7E700ADD6D600A5D6D6008CCED60042B5DE00000000000000
          000000000000000000000000000000000000000000000000000042B5DE0094E7
          F700C6EFFF00ADEFFF007BE7FF0073E7FF006BE7FF0042B5DE00000000000000
          000000000000000000000000000000000000000000000000000042B5DE0042B5
          DE0042B5DE0042B5DE0042B5DE0042B5DE0042B5DE0042B5DE00000000000000
          000000000000000000000000000000000000000000000000000042B5DE0042B5
          DE007BDEEF007BDEF70073DEF70063D6EF0039B5D60042B5DE00000000000000
          00000000000000000000000000000000000000000000000000000000000042B5
          DE0042B5DE0042B5DE0042B5DE0039B5DE0042B5DE0000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00E03F0000E0030000E0000000E00000008000000000000000000000000000
          000000000000000000000000000000FF000000FF000000FF000000FF000081FF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000002184000021840000218400002163000021630000216300002163000021
          6300002163000021630000216300002163000000000000000000000000000021
          A5000021C6000021C6000021C6000021C6000021A5000021A5000021A5000021
          A5000021A5000021A5000021C6000021A5000021630000000000000000000021
          C6000042E7000021E7000021E7000021E7000021C6000021C6000021C6000021
          C6000021C6000021C6000021C6000021C6000021630000000000000000000021
          E7000042E7000042E7000021E7000021E7000021C6000021C6000021C6000021
          C6000021C6000021C6000021C6000021A5000021630000000000000000000021
          E7000042E7000042E7000042E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF000021C6000021C6000021A5000021630000000000000000000021
          E7004263E7000042E7000042E7000042E7000021E7000021E7000021E7000021
          C6000021C6000021C6000021C6000021A5000021630000000000000000000021
          E7004284E7000042E7000042E7000042E7000042E7000042E7000021E7000021
          E7000021C6000021C6000021C6000021C6000021630000000000000000000021
          E7008484E7004263E7000042E7000042E7000042E7000042E7000042E7000021
          E7000021C6000021E7000021C6000021C6000021840000000000000000000021
          E70084A5E7004263E7000042E7000042E7000042E7000042E7000042E7000042
          E7000021E7000021E7000021E7000021C6000021840000000000000000000021
          E70084A5E7004263E7004263E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF000042E7000021E7000021C6000021A50000000000000000000021
          E70084A5E7004284E7004263E7004263E7000042E7000042E7000042E7000042
          E7000042E7000042E7000042E7000021E7000021A50000000000000000000021
          E70084A5E70084A5E7008484E7008484E7004284E7004263E7004263E7000042
          E7000042E7000042E7000042E7000021E7000021A50000000000000000000021
          E70084A5E70084A5E70084C6E70084A5E70084A5E7008484E7004263E7000042
          E7000042E7000042E7000042E7000042E7000021C60000000000000000000000
          00000042E7000042E7000042E7000042E7000042E7000042E7000042E7000042
          E7000021E7000021E7000021E7000021C6000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000C003000080010000800100008001000080010000800100008001
          0000800100008001000080010000800100008001000080010000C0030000FFFF
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000019744558745469746C650050617374655370656369616C3B50617374
          653BDA10A8BE0000026F49444154785E7D8F3F685D7518869FD39B6A4C102C68
          08A536555A514375EA26BA8AD2C1490A5D54D29680922C1D0A0527850AC5F807
          0427C1C9A94537C9D09A288156C9A294DED678894949A2D5DEDC9CF3FB7DFF3C
          DC7B53525A7CE1E19BDEE7E31D8808AE7D3332651A536A31A639900393E4E7DE
          A7DCDA647DE13C23AD8F510D44A3B555C667C73EEA9C8F08031800C8C9A79E18
          9F1E1B7D711277E5DBEB0FF1F74A9B321BB1FF24C75E1FA7F00D7EFBE1E2FEC5
          CB73EF019F007705A4CAC7465F38C1CCBC5026A3CC558D51D5E49A779A87B9D1
          5CE6D2C42057677D5FBF97760802A2C3F7F32D448CAC8EA82166983AE68E9BD3
          BEB385E402A001B07302D83F7C776291667385D6D21AAA99A1878DE121617830
          31FC48896B4516EE17A4E484FE05B2C6D34F1A7B1F1FE4D66A45FBDF92C6AEC4
          EE5D150D2A8A4251895E6FA740AA20649D48B708131A5632BA678B3DF5D776BB
          C435630D439292B2030C15453108786F420E22AF62691DB78CE48A0FE7DFE2DA
          ED437838E1414460EEC4A1E0D533BE64EE684E73770556FD89961B9865AA32D5
          E5831C7D790C0F30F32E52A3352286A833BBF0C74B3B04AB68BA8DA9A349F008
          56363A2CAF7570EF15CDA227F3DE0D77BA0295C0EAB2E68CA9922BE399038F71
          E68D83FC5FDEFCE0724F2012DDEF2A19132367C12CD8CEE9AF7FEF8AD51C55E5
          F393E300A819BD09C2F22F73AD7DCF8E3B9A1D498699B19D73C79FE24151EB4F
          B8D3892FAEFCB83EF9F34FEC750B2A29D0A3CE76DEFDF25744AD8BAAF0D5F491
          7B05672FC8396006D80D3480474FBD6637E9E7D389E779506C7B42440820F453
          14C566D9D9BCF4F6CCC22BBDDD86D5A87917EBDF54B6E7FE03FE69DD2E948B0C
          430000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000009C9C
          9C00848484008484840084848400848484008484840084848400848484008484
          8400848484008484840084848400848484000000000000000000000000009C9C
          9C00F7F7F700F7F7F700EFEFEF00EFEFEF00E7E7E700186B1800186B1800186B
          1800186B1800186B1800186B1800186B1800186B1800186B1800000000009C9C
          9C00F7F7F700F7F7F700F7F7F700EFEFEF00EFEFEF00186B1800FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00186B1800000000009C9C
          9C00FFFFFF00F7F7F700F7F7F700F7F7F700EFEFEF00186B1800FFFFFF00186B
          1800186B1800FFFFFF0029843900186B1800186B1800186B1800000000009C9C
          9C00FFFFFF00FFFFFF00F7F7F700F7F7F700F7F7F700186B1800FFFFFF002984
          3900186B1800186B1800186B1800186B1800FFFFFF00186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7F700186B1800FFFFFF00FFFF
          FF0029843900186B1800186B1800FFFFFF00FFFFFF00186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700186B1800FFFFFF002984
          3900186B1800186B1800186B1800186B1800FFFFFF00186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00186B1800FFFFFF00186B
          1800186B1800FFFFFF0029843900186B1800186B1800186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00186B1800FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00186B1800186B1800186B
          1800186B1800186B1800186B1800186B1800186B1800186B1800000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00E7E7E700DEDEDE00D6D6D600848C8C000000000000000000000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF0094949400848C8C00848C8C00848C8C000000000000000000000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF0094949400FFFFFF00DEDEDE00848C8C000000000000000000000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF0094949400DEDEDE0084848400000000000000000000000000000000009C9C
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00949494008484840000000000000000000000000000000000000000009C9C
          9C00848484008484840084848400848484008484840084848400848484008484
          8400848C8C000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800300008000000080000000800000008000000080000000800000008000
          0000800000008000000080030000800300008003000080070000800F0000801F
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C00000018744558745469746C650044617461536F757263653B4F
          7074696F6E7318FCC056000002A749444154785E85915F48935118C69F6F4E6D
          E8226D54282462E63F50872093106B32A61888A05B7FA82C4923BAD09B8ABA30
          24E82E2F52B1F2A284C890C894946C1189A4A685CBF96722EACC744E73EAD86C
          FBBE734EFBD8846A931E38BC1CCEFBFE78CEF372F049D2FFA0AC5802E4714002
          63341E8C4B23948C53C2E689406608211F35B7BB3B0150E615FE9064B0416798
          EEAA634B9F5BD9CF890EE6B0F4326A1F645BD3EDCC36DCC82C863A666CAD62EF
          EA0AFBC47E717EE74801708CD1FC446D25C008403DDEE206E8362215B188888A
          06232EC4A4A460E5714BAE080040E1930F407802C1390F6944BCF80C0E140C14
          5422E0D7EA0FB8D71701F732082F40ECFFCBBE08A08482F29B105C360061E0ED
          0370589AB13A528FD9CE662CBCEF807B6D0144204101A03CC1FF05107F5F8003
          8108D85D1CE4F15990A796E2A8A63CB803C2D3C0B1109937931884EF3F0CD9A1
          2418C678B40C87E2EACD877739AF6AEE3C4575ED137F8842A03569641A363D32
          AC4639B1B44E316076E3824E8DC696379557AE370D6D3B5DC4ED768EFAB710F8
          0571C7AF3FB9C0ED39089B6D1325454AC4C52AA02FC9DD6BE81B6D5744CB3136
          39D7E30B91040FF1D03E0287C389AA722D8CC6299C2AAF85F1DB142E9DD160C3
          BE8135EB4ABF08A0CE6DBE7BA4FD0516478760FF3E230241F9759C504660D23C
          0F8F87C7C097699C56C7598DA639104A31F2758274B5DDBBCFF9530D6F3A9BA1
          97854A8A438023120992E3B20B43C7B714CC8A035CC5B902BCFD608469CA826C
          65225459496878F40A66F3EC2D6E2774FF46A462F5DF433425D52F95E9C99A65
          EB1AB4DA63484F4BC0DCEC229EB5F540BE37122693B9570C2BE81121D9C7CF27
          E4A82F9679EBE582D21B8EE71D7D4CA5AE7064AA745519393A7D6A6651E2AE80
          7F9C85E5155EABCF3F59C33254FA7A00E13B4E7F038A7C6509079C5294000000
          0049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000024744558745469746C65005061726170726170683B53657061726174
          6F723B456D7074793B50616765DC773B4C000001D149444154785EC5934B4F13
          51008527FC07828805326D9084E9F4017DA4436DEB8C53C9C038B1168DD24642
          142418242624E282B044E3635176B0706F7461D2949669B1D1D405346277FC0B
          B4096CC8F1DE6B27BA28B331C6C549CEE6FB72721F1C80BFCA3F130449722425
          928A5DDAC1610AEC7EAA1FCC2EAD1F25538BA7C9D41214E32162DA7DC4C76711
          D7E630AACEE02CC196F971EF9B6C2C409B5C3CD9366B0DE5DA0224751A9B6FDE
          1D4694BB90AE4CA3FA79BFCE04634F4D0433AF788EE33A5A8252766EAD399A9C
          C14EE5CB57BA26AE3D4030761BB4871219D2EFB04E2272EA9312F4D50A7CB75E
          F09640D6E74F437206DF7F34AB148A12992F728341FE4B37E1957E757688CA72
          1153AFF77175C584254867979BA1C4144AE51A5B1096B310823A833CE1EB1002
          13BF05F1C7058CADEC40483DB3166C7DC8EF367C521A8A7EEFB858AE1D8C90F9
          83DE24838646345CA4DD12441FE529FCE71944A8FDEDFB42C3989C3F12C30699
          9F866B28C1A0018F0A67ABDBBD832849CEBA6B774047DF80C420A790402FE9B6
          820B7C803BCF0FD32E52C8255C46779F9F41FD8351F4F0014B20B6159CEBF572
          5D0E91098A66B54E81CE1E379EBFDC38ECEEF7A3CBE14161BB5CB70476610B6C
          22FEFFDFF8137CDFC27FF08838CF0000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          6300846363000000000000000000000000005A4242005A424200000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          6300D6D6D60084636300000000005A424200B5A5A5005A424200000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          630084636300C6B5B50084636300B5A5A5005A4242005A424200000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000084636300C6B5B5005A4242000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000084636300C6B5B5005A4242000000000000000000088CCE000063
          9C0000639C0000639C0000639C0000639C0000639C0000639C0000639C000063
          9C0000639C0084636300B5A5A5005A42420000639C0000639C00299CDE00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0084636300B5A5A5005A4242007BA5BD0000639C00299CDE00FFFF
          FF004A4A4A00D6D6D6004A4A4A004A4A4A004A4A4A00B5B5B5004A4A4A004A4A
          4A00FFFFFF0084636300B5A5A5005A4242007BA5BD0000639C00299CDE00FFFF
          FF008C8C8C004A4A4A004A4A4A004A4A4A00FFFFFF004A4A4A00B5B5B500E7E7
          E700FFFFFF0084636300B5A5A5005A4242007BADBD0000639C00299CDE00FFFF
          FF00B5B5B50052525200737373004A4A4A005A5A5A00B5B5B5004A4A4A005252
          5200FFFFFF0084636300B5A5A5005A42420084ADBD0000639C00299CDE00FFFF
          FF00E7E7E7004A4A4A00FFFFFF004A4A4A00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0084636300B5A5A5005A42420084ADC60000639C00299CDE00299C
          DE00299CDE00299CDE00299CDE00299CDE00299CDE00299CDE00299CDE00299C
          DE00299CDE0084636300C6B5B5005A424200299CDE00088CCE00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000084636300C6B5B5005A4242000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          630084636300C6B5B50084636300B5A5A5005A4242005A424200000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          6300D6D6D600846363000000000084636300B5A5A5005A424200000000000000
          0000000000000000000000000000000000000000000000000000000000008463
          630084636300000000000000000000000000846363005A424200}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FF9C0000FF880000FF800000FFE30000FFE3000000000000000000000000
          000000000000000000000000000000000000FFE30000FF800000FF880000FF9C
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001B744558745469746C6500537461636B65644C61796F75
          743B4C61796F75743B2B1CD8D50000022449444154785E7D52CF6B1351109EED
          BE6E62F0A0FF879E044D6CA362C5A227A92056C482BF0E82A078F0A0E041C183
          3FC016E945A4541AA9E9A19E228A6D4DD32C85FC17456C74CDAEB16677DF6EDF
          7366DF92476AF05B6667D86FDE9B6F66D600008666C2BF10A90DECE0E98C4CB9
          D8B8FFBA5E65CC2A825494444FD88EF8EAA3AB874FDD7B55AF98E66051EA93C9
          3B8E78EDF1F5E111F6DDF18BE3E7F603DF16C8EAACF242A38891D544FEC2F97D
          10C5A24B52DABBF9C630A967CDA6B73435BD721C7A410A96C90B21A0E97168FB
          518F42A18201F6FED9D93354098826532096AB0BE890AA0A5D6F24DF08ECEE74
          B5C2ACCC10311234221ED49FDC387ADA71DC95F9B9FAB1DE0990C2E04B32C489
          871FE5A58B79E0498F1AA5D23ABC7930BA171476F55118A0FD66D4CB37D7875F
          9D58293094C4B447EBF6E4D2A295C91624E81913C503DF7E716BE404134262B2
          5A2A48451A18D077C4E0A613162E4F1C505BD280D959BB403C6BFD74ABE539FB
          8822B4BE98FB556A550A015F5B3E78A85027A8ED200C56991A1FC320472BD971
          47072D725BDE6AB964D38FA65B2022DCAA91336E3EFF645BD95C3E3D878F410E
          C2606BFDE59DD193A482A4F629C0D102B6F983E7AF5D390861B2055D6266A676
          0823F3E9F2467B4F8EA916A42EF379B1011F26C7806193B0E174C0F3231AA0DE
          8250D74921C1FD1369FDA9CF58261058DB73D716DEDA437D7A5C239954299335
          15A77214A4EC0ADE8D66F5E93144F39319FC077F01AF892C2D1A3B651D000000
          0049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001C744558745469746C65005361766520416E64204E65773B53617665
          3B4E65773BE56EEA4B000001FD49444154785E858F3D6854511085BF97BC2446
          1042AC6C44C1C2609A20D609A8752C5258281AECD3A4B070414CE15F61A98D95
          58D9A8888D221AB016C1803F9558086A347F9BDDECBB3373DC5C36BA289AC33D
          7CD39C73678AE9D91BCFA19858FBF69590131E4474DBD9B16B08779B7F74F7DA
          51494E974A898923874779FAF809B76FCD2189081122CF67A667D93950B2BAD6
          1A077A0F8C1E3304A0D782B132C2B164B8A51CFCF2A3817B6012E1C2DC32DD1C
          A090542010124019EE24B3B613E641658EC7D616EA1407D6662E0841811080D4
          937F4B8699E550B2C05CB9440273CF05EE9D0D10528C654A637983CA0C37E3D4
          E9195C8E2290948302DC024F09A0F7E3BB173DC01BA0CC8D53E72E6AE4D041BE
          2F2E934388F5E5259AF53A1E417FFF20C3BBF7D068ACB377FF0821908208A110
          9C385BD3F92B7734357D417F2AA5A4672F3FE85F9A9DBBAF32CCB094B2011657
          36321154A962ADD10260A591100240CACE27969BC1B4E9AAA2F6F03D16C29DCC
          6AA3C5407D95C9E31088FC3294691194D54673FEEDC2C27811C1C2AB4F2487AA
          55D16A391BF515F60D0F20802053DAA2080F0A6010E8833C6775CD83ED3B3F5F
          AF4DB2B45E91C3D2AFA24B571F504A6A026DFFADA228CC23902024A402BA4E70
          774AFEAF1E772787E37710C8F4D0B605720F666AF740EA147598E7D8B6A079F3
          F2C921A0AFFBB22EA69FCBA9E7D64590FD530000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000000B744558745469746C65004F70656E3B49C97792000002
          8849444154785E7D934F68545718C57FEFCD4B63CBB45D64A3ADD0952D45B40B
          D12E3428044A70530ADDE8AA94820B1BD09D10442D0A0117225D28A5C9AA0B6D
          A14BDB458B055B4C2853D4A869689A2131FFCC4C26C9CCBCCCBCB9F7FBBE4E2E
          1310D11E38F7703F2EE770E07E9199F1324451C4A12FE9EE7E9D736A7C117B70
          19C3A529BE9AF8890CB098FF4794BCC669DFE4F6ED21DEAA57F9D4B78DDED8C9
          C50327102017E5F3F91888003A6A1D6ABD5E8F9E33CCEDFB9CF351CCA0291446
          E84EEE5E3DF86B1C730423C014D2A63FDE7766EC26A0070740141018BD1E0206
          D581582771FCDB8F6CF767C30460F8668DC91F06577E199BF9E0EC77FF947806
          22123BE7726DB5360470893805A9829BC3544910DEFBF8648FB8AFE77E7BFF4D
          3030B3A06A11CED99DFE8B85BE5AADE60012F10A262019917A304F4E53F61C3B
          45F4CA7620025340311346AF0CF402B93F2EF53A5548D44930C03731DF40DB44
          1CA40B98FD05CE612A8004A35A3905C8F70FDD8B0189EE0E1DB60F072EA3EB0F
          28FF5D606D611953421D3503354C0D550DBAF2A48C756AA95829712DA1B1FA94
          6CB1C8FAD33ABB3EB94014C521CDCC817A4C5A04FA8C4069B23A5B64ECFB1B33
          896442756186B5C929F23BF762AD2A1BFFFE8CA960AA604131F52012E6AAC2FC
          C359D6AAFE56E29CB03253245DAEB063DF3B644BE3F8FAEAD643100D06A8EFD4
          F261569E5EE6D17CFA63E2324FA538CDB6AE6D74254263F63ED2A875923DE615
          63CB443011D2F52695D5C6E36BA3A5E9A4B1D1C29696E8D9F32ECDC509B2CA7C
          27B553814DB5700705354AF3752AA9BF05B86423F57FE2ABFB277F2F307967EB
          D304C5009400B370A006CEDBDCF8E2C608D0DA5CA657812EE0459BF9FC3219E0
          80E63747DF1680FF001724CEF504A838340000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF006B73
          FF003131B5003131BD003131BD003131BD003131C6003131C6003131BD003131
          BD003131B5003131B5003131AD003131A5006363FF00FFFFFF00FFFFFF003131
          C6003131DE003131EF003131F7003131F7003131EF003131F7003131EF003131
          EF003131EF003131E7003131DE003131C60031319C00FFFFFF00FFFFFF003131
          D6003131EF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131E7003131CE003131AD00FFFFFF00FFFFFF003131
          E7003139FF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131DE003131B500FFFFFF00FFFFFF003131
          EF003139FF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003139FF003131E7003131BD00FFFFFF00FFFFFF003139
          FF003139FF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003139FF003131EF003131C600FFFFFF00FFFFFF003139
          FF003139FF00848CFF00848CFF00848CFF00848CFF00848CFF00848CFF00848C
          FF00848CFF00848CFF003131F7003131EF003131CE00FFFFFF00FFFFFF003139
          FF003139FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF003942FF003942FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF005252FF005252FF003942FF003139FF003139FF003139FF003139FF003139
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003942
          FF006B6BFF006363FF00424AFF003942FF003942FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131F7003131CE00FFFFFF00FFFFFF005252
          FF00848CFF006B6BFF005252FF004A4AFF00424AFF00424AFF003139FF003139
          FF003139FF003139FF003139FF003131F7003131CE00FFFFFF00FFFFFF006363
          FF009C9CFF00848CFF006B6BFF006363FF005252FF004A4AFF00424AFF003942
          FF003139FF003139FF003139FF003131F7003131BD00FFFFFF00FFFFFF00C6CE
          FF006363FF004A4AFF003942FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131DE007B84FF00FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF006B73
          FF003131B5003131BD003131BD003131BD003131C6003131C6003131BD003131
          BD003131B5003131B5003131AD003131A5006363FF00FFFFFF00FFFFFF003131
          C6003131DE003131EF003131F7003131F7003131EF003131F7003131EF003131
          EF003131EF003131E7003131DE003131C60031319C00FFFFFF00FFFFFF003131
          D6003131EF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131E7003131CE003131AD00FFFFFF00FFFFFF003131
          E7003139FF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131DE003131B500FFFFFF00FFFFFF003131
          EF003139FF00848CFF00848CFF00848CFF00848CFF00848CFF00848CFF00848C
          FF00848CFF00848CFF00848CFF003131E7003131BD00FFFFFF00FFFFFF003139
          FF003139FF00848CFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00848CFF003131EF003131C600FFFFFF00FFFFFF003139
          FF003139FF003139FF00848CFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00848CFF003131F7003131EF003131CE00FFFFFF00FFFFFF003139
          FF003139FF003139FF003139FF00848CFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00848CFF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF003942FF003942FF003139FF003139FF00848CFF00FFFFFF00FFFFFF00848C
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF005252FF005252FF003942FF003139FF003139FF00848CFF00848CFF003139
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003942
          FF006B6BFF006363FF00424AFF003942FF003942FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131F7003131CE00FFFFFF00FFFFFF005252
          FF00848CFF006B6BFF005252FF004A4AFF00424AFF00424AFF003139FF003139
          FF003139FF003139FF003139FF003131F7003131CE00FFFFFF00FFFFFF006363
          FF009C9CFF00848CFF006B6BFF006363FF005252FF004A4AFF00424AFF003942
          FF003139FF003139FF003139FF003131F7003131BD00FFFFFF00FFFFFF00C6CE
          FF006363FF004A4AFF003942FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131DE007B84FF00FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF006B73
          FF003131B5003131BD003131BD003131BD003131C6003131C6003131BD003131
          BD003131B5003131B5003131AD003131A5006363FF00FFFFFF00FFFFFF003131
          C6003131DE003131EF003131F7003131F7003131EF003131F7003131EF003131
          EF003131EF003131E7003131DE003131C60031319C00FFFFFF00FFFFFF003131
          D6003131EF003139FF003139FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131E7003131CE003131AD00FFFFFF00FFFFFF003131
          E7003139FF003139FF003139FF003139FF003139FF00FFFFFF00848CFF003139
          FF003139FF003139FF003131F7003131DE003131B500FFFFFF00FFFFFF003131
          EF003139FF003139FF003139FF003139FF003139FF00FFFFFF00848CFF003139
          FF003139FF003139FF003139FF003131E7003131BD00FFFFFF00FFFFFF003139
          FF003139FF003139FF003139FF003139FF003139FF00FFFFFF00848CFF003139
          FF003139FF003139FF003139FF003131EF003131C600FFFFFF00FFFFFF003139
          FF003139FF00848CFF00848CFF00848CFF00848CFF00FFFFFF00848CFF00848C
          FF00848CFF00848CFF003131F7003131EF003131CE00FFFFFF00FFFFFF003139
          FF003139FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF003942FF003942FF003139FF003139FF003139FF00FFFFFF00848CFF003139
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003139
          FF005252FF005252FF003942FF003139FF003139FF00FFFFFF00848CFF003139
          FF003139FF003131F7003131EF003131EF003131CE00FFFFFF00FFFFFF003942
          FF006B6BFF006363FF00424AFF003942FF003942FF00FFFFFF00848CFF003139
          FF003139FF003139FF003131F7003131F7003131CE00FFFFFF00FFFFFF005252
          FF00848CFF006B6BFF005252FF004A4AFF00424AFF00FFFFFF00848CFF003139
          FF003139FF003139FF003139FF003131F7003131CE00FFFFFF00FFFFFF006363
          FF009C9CFF00848CFF006B6BFF006363FF005252FF004A4AFF00424AFF003942
          FF003139FF003139FF003139FF003131F7003131BD00FFFFFF00FFFFFF00C6CE
          FF006363FF004A4AFF003942FF003139FF003139FF003139FF003139FF003139
          FF003139FF003139FF003131F7003131DE007B84FF00FFFFFF0000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800100000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008001
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000CEB5A5006B4231006B4231006B4231006B4231006B4231006B4231006B42
          31006B4231006B4231006B4231006B4231006B42310000000000000000000000
          0000CEB5A500EFE7E700B5A59400B5A59400B5A59400B5A59400B5A59400B5A5
          9400B5A59400B5A59400B5A59400B5A594006B42310000000000000000000000
          0000CEB5A500F7EFE700EFE7E700EFE7DE00EFDEDE00E7DED600E7D6CE00E7D6
          CE00DECEC600DECEBD00DECEBD00B5A594006B42310000000000000000000000
          0000CEB5A500F7EFEF00F7EFE700EFE7E700EFE7DE00EFDEDE00E7DED600E7D6
          CE00E7D6CE00DECEC600DECEBD00B5A594006B42310000000000000000000000
          0000CEB5A500F7F7F700DE9C4200DE9C4200181818009C6363009C636300E7DE
          D600E7D6CE00E7D6CE00DECEC600B5A594006B42310000000000000000000000
          0000CEB5A500FFF7F700F7F7F700F7EFEF00CE9C9C0018181800009CCE001818
          1800E7DED600E7D6CE00E7D6CE00B5A594006B42310000000000000000000000
          0000CEB5A500FFFFFF00DE9C4200DE9C4200CE9C9C00009CCE004ABDDE00009C
          CE0018181800E7DED600E7D6CE00B5A594006B42310000000000000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFF7F700F7F7F700009CCE0094E7F7004ABD
          DE00009CCE0018181800E7DED600B5A594006B42310000000000000000000000
          0000CEB5A500FFFFFF00DE9C4200DE9C4200DE9C4200DE9C4200009CCE0094E7
          F7004ABDDE00009CCE0018181800B5A594006B42310000000000000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7F700009C
          CE0094E7F7004ABDDE00009CCE00181818006B42310000000000000000000000
          0000CEB5A500FFFFFF00DE9C4200DE9C4200DE9C4200DE9C4200DE9C4200DE9C
          4200009CCE0094E7F7004ABDDE008484840000009C0000000000000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFF7F700009CCE00D6BDAD00738C9C0000009C0000009C00000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00CEB5A5000031FF006B8CFF000031FF0000009C00000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00CEB5A500DECEBD000031FF000031FF0000000000000000000000
          0000CEB5A500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00CEB5A5006B423100000000000000000000000000000000000000
          0000CEB5A500CEB5A500CEB5A500CEB5A500CEB5A500CEB5A500CEB5A500CEB5
          A500CEB5A500CEB5A50000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00C0010000C0010000C0010000C0010000C0010000C0010000C0010000C001
          0000C0010000C0010000C0010000C0000000C0000000C0010000C0070000C00F
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000B5AD
          AD006B4231006B4231006B4231006B4231006B4231006B4231006B4231006B42
          31006B4231006B4231006B4231006B4231006B423100B5ADAD0000000000C6AD
          9C00F7F7EF00CEC6B500CEC6B500CEC6B500CEC6B500CEC6B500CEC6B500CEC6
          B500CEC6B500CEC6B500CEC6B500CEC6B500CEC6B5006B42310000000000C6AD
          9C00F7F7F700F7F7EF00F7EFEF00EFEFE700EFE7DE00EFE7DE00E7DED600E7D6
          D600E7D6CE00DECEC600DECEC600DECEBD00CEC6B5006B42310000000000C6AD
          9C00FFFFF700F7F7F700F7F7EF00F7EFEF00EFEFE700EFE7DE00EFE7DE00E7DE
          D600E7D6D600E7D6CE00DECEC600DECEC600CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFF7009C3100009C3100009C3100009C3100009C3100009C31
          00009C3100009C3100009C310000DECEC600CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFF7EF00F7E7DE00F7DECE00F7D6BD00EFC6
          A500EFBD9400EFBD94009C310000E7D6CE00CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFFFFF00FFF7EF00F7E7DE00F7DECE00F7D6
          C600EFCEB500EFBD9C009C310000E7D6D600CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFFFFF00FFFFFF00FFF7F700FFEFE700F7E7
          D600F7D6C600EFCEB5009C310000EFDEDE00CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFFFFF00FFFFFF00FFFFFF00FFF7F700FFEF
          E700F7E7D600F7D6C6009C310000EFE7DE00CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7
          F700FFEFE700F7E7D6009C310000EFE7E700CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C310000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFF7F700FFEFE7009C310000F7EFE700CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF009C3100009C3100009C3100009C3100009C3100009C31
          00009C3100009C3100009C310000F7EFEF00CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFF700F7F7F700CEC6B5006B42310000000000C6AD
          9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700F7F7F7006B42310000000000B5AD
          AD00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD
          9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00B5ADAD00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800000008000000080000000800000008000000080000000800000008000
          000080000000800000008000000080000000800000008000000080000000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000009C3100009C3100009C523100AD8C
          8400000000000000000000000000000000000000000000000000AD8C73006B42
          31006B4231006B4231006B423100000000000000000000000000000000009C52
          3100000000000000000000000000000000000000000000000000AD8C7300E7DE
          D600DECEC600DECEBD006B4231000000000000000000000000009C3100009C31
          00009C3100000000000000000000000000000000000000000000AD8C7300AD8C
          7300AD8C7300AD8C73006B423100000000000000000000000000000000009C31
          0000000000000000000000000000000000000000000000000000AD8C7300F7EF
          E700EFE7DE00E7DED6006B4231006B4231006B4231006B4231006B4231006B42
          31006B4231006B4231006B4231006B4231006B4231006B423100AD8C7300AD8C
          7300AD8C7300AD8C73006B423100F7EFEF00AD8C7300EFE7E700EFE7DE00E7DE
          D600AD8C7300E7D6CE00DECEC600DECEBD00DECEBD006B423100AD8C7300FFFF
          FF00F7F7F700F7EFE7006B423100AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C73006B423100AD8C7300AD8C
          7300AD8C7300AD8C73006B423100F7F7F700AD8C7300F7EFEF00EFEFE700EFE7
          E700AD8C7300E7DED600E7D6CE00E7D6CE00DECEC6006B423100AD8C7300FFFF
          FF00FFFFFF00FFFFFF006B423100AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C73006B423100AD8C7300AD8C
          7300AD8C7300AD8C73006B423100FFFFFF00AD8C7300F7F7F700F7F7EF00F7EF
          EF00AD8C7300EFE7E700EFE7DE00E7DED600E7D6CE006B423100AD8C7300D6B5
          A500D6B5A500D6B5A5006B423100AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C73006B423100AD8C7300D6B5
          A500D6B5A500D6B5A5006B423100FFFFFF00AD8C7300FFFFFF00FFFFF700F7F7
          F700AD8C7300F7EFEF00EFEFE700EFE7E700EFE7DE006B423100AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C73006B423100000000000000
          0000AD8C7300D6B5A500D6B5A500D6B5A500CEAD9C00CEAD9C00C6A59400C6A5
          8C00C69C8C00BD948400B5947B00B58C7300B58C73006B423100000000000000
          0000AD8C7300D6B5A500D6B5A500D6B5A500D6B5A500CEAD9C00CEAD9C00C6A5
          9400C6A58C00C69C8C00BD948400B5947B00B58C73006B423100000000000000
          0000AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FC3F000007BF0000071F000007BF00000000000000000000000000000000
          00000000000000000000000000000000000000000000C0000000C0000000C000
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000006B42
          3100634A3100634A3100634A3100634A3100634A3100634A3100634A3100634A
          3100634A3100634A3100634A3100634A3100634A31006B423100000000006B42
          3100C6A58C00AD8C73006B423100D6B5A500B58C7B00AD8C73006B423100D6B5
          A500B58C7B00AD8C73006B423100C6A58C00AD8C73006B423100000000006B42
          3100D6B5A500C6A58C006B423100D6B5A500D6B5A500B58C7B006B423100D6B5
          A500D6B5A500B58C7B006B423100D6B5A500C6A58C006B423100000000006B42
          31006B4231006B4231006B4231006B4231006B4231006B4231006B4231006B42
          31006B4231006B4231006B4231006B4231006B4231006B42310000000000AD8C
          7300F7EFEF00F7EFE700D6C6B500EFE7DE00EFE7DE00EFDED600C6AD9C00E7D6
          CE00E7D6CE00DECEC600C6AD9C00DECEBD00DECEBD006B42310000000000AD8C
          7300F7F7EF00F7EFEF0008080800080808000808080008080800080808000808
          080008080800E7D6CE00C6AD9C00DECEC600DECEBD006B42310000000000AD8C
          7300C6AD9C00C6AD9C00DECEBD000808080008080800DECEBD00DECEBD00DECE
          BD0008080800C6AD9C00C6AD9C00C6AD9C00C6AD9C00634A310000000000AD8C
          7300FFF7F700F7F7F700DECEBD00F7EFEF000808080008080800DECEBD00EFE7
          DE00EFDED600E7DED600C6AD9C00E7D6CE00DECEC600634A310000000000AD8C
          7300FFFFFF00FFF7F700DECEBD00F7F7EF00F7EFEF000808080008080800EFE7
          DE00EFE7DE00EFDED600C6AD9C00E7D6CE00E7D6CE006B42310000000000AD8C
          7300C6AD9C00C6AD9C00DECEBD00DECEBD000808080008080800DECEBD00DECE
          BD00DECEBD00C6AD9C00C6AD9C00C6AD9C00C6AD9C006B42310000000000AD8C
          7300FFFFFF00FFFFFF00DECEBD000808080008080800F7F7EF00DECEBD00F7EF
          E70008080800EFE7DE00C6AD9C00EFDED600E7DED6006B42310000000000AD8C
          7300FFFFFF00FFFFFF0008080800080808000808080008080800080808000808
          080008080800EFE7E700C6AD9C00EFE7DE00EFDED6006B42310000000000AD8C
          7300C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD
          9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C00C6AD9C006B42310000000000AD8C
          7300FFFFFF00FFFFFF00E7D6C600FFFFFF00FFFFFF00FFFFFF00E7CEC600F7F7
          F700F7F7EF00F7EFEF00C6AD9C00EFE7E700EFE7DE006B42310000000000AD8C
          7300FFFFFF00FFFFFF00E7D6C600FFFFFF00FFFFFF00FFFFFF00E7CEC600FFF7
          F700F7F7F700F7F7EF00C6AD9C00F7EFE700EFE7E7006B42310000000000AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C
          7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300AD8C7300}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00800000008000000080000000800000008000000080000000800000008000
          0000800000008000000080000000800000008000000080000000800000008000
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001B744558745469746C6500537461636B65644C61796F75
          743B4C61796F75743B2B1CD8D50000022449444154785E7D52CF6B1351109EED
          BE6E62F0A0FF879E044D6CA362C5A227A92056C482BF0E82A078F0A0E041C183
          3FC016E945A4541AA9E9A19E228A6D4DD32C85FC17456C74CDAEB16677DF6EDF
          7366DF92476AF05B6667D86FDE9B6F66D600008666C2BF10A90DECE0E98C4CB9
          D8B8FFBA5E65CC2A825494444FD88EF8EAA3AB874FDD7B55AF98E66051EA93C9
          3B8E78EDF1F5E111F6DDF18BE3E7F603DF16C8EAACF242A38891D544FEC2F97D
          10C5A24B52DABBF9C630A967CDA6B73435BD721C7A410A96C90B21A0E97168FB
          518F42A18201F6FED9D93354098826532096AB0BE890AA0A5D6F24DF08ECEE74
          B5C2ACCC10311234221ED49FDC387ADA71DC95F9B9FAB1DE0990C2E04B32C489
          871FE5A58B79E0498F1AA5D23ABC7930BA171476F55118A0FD66D4CB37D7875F
          9D58293094C4B447EBF6E4D2A295C91624E81913C503DF7E716BE404134262B2
          5A2A48451A18D077C4E0A613162E4F1C505BD280D959BB403C6BFD74ABE539FB
          8822B4BE98FB556A550A015F5B3E78A85027A8ED200C56991A1FC320472BD971
          47072D725BDE6AB964D38FA65B2022DCAA91336E3EFF645BD95C3E3D878F410E
          C2606BFDE59DD193A482A4F629C0D102B6F983E7AF5D390861B2055D6266A676
          0823F3E9F2467B4F8EA916A42EF379B1011F26C7806193B0E174C0F3231AA0DE
          8250D74921C1FD1369FDA9CF58261058DB73D716DEDA437D7A5C239954299335
          15A77214A4EC0ADE8D66F5E93144F39319FC077F01AF892C2D1A3B651D000000
          0049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000CEB5
          AD006B4231006B4231006B4231006B4231006B4231006B4231006B4231006B42
          31006B4231006B4231006B4231006B4231006B4231000000000000000000CEB5
          AD00B5A59400B5A59400B5A59400B5A59400B5A59400B5A59400B5A59400B5A5
          9400B5A59400B5A59400B5A59400B5A594006B4231000000000000000000CEB5
          AD00FFFFFF00FFF7F700F7EFEF00CEB5AD00EFE7DE00EFDEDE00E7DED600B5A5
          9400DECEC600DECEBD00DECEBD00B5A594006B4231000000000000000000CEB5
          AD00FFFFFF00FFFFFF00FFF7F700CEB5AD00F7EFE700EFE7DE00EFDEDE00B5A5
          94006B4231006B4231006B4231006B4231006B4231000000000000000000CEB5
          AD00CEB5AD00CEB5AD00CEB5AD00CEB5AD00B5A59400B5A59400B5A59400B5A5
          94006B423100FFFFFF00738CFF00738CFF006B4231000000000000000000CEB5
          AD00FFFFFF00FFFFFF00FFFFFF00CEB5AD00FFF7F700F7EFEF00F7EFE700B5A5
          94006B423100738CFF000031FF004A63FF006B4231000000000000000000CEB5
          AD00FFFFFF00FFFFFF00FFFFFF00CEB5AD00FFFFFF00FFF7F700F7EFEF00B5A5
          94006B4231000031FF00FFFFFF000031FF004A63FF000000000000000000CEB5
          AD00CEB5AD00CEB5AD00CEB5AD00CEB5AD00CEB5AD00CEB5AD00CEB5AD00B5A5
          94006B4231006B4231006B4231006B4231000031FF004A63FF0000000000CEB5
          AD00FFFFFF00FFFFFF00FFFFFF00CEB5AD00FFFFFF00FFFFFF00FFFFFF00CEB5
          AD00F7F7EF00F7EFEF00EFE7DE00B5A594006B4231000031FF0000000000CEB5
          AD00FFFFFF00FFFFFF00FFFFFF00CEB5AD00FFFFFF00FFFFFF00FFFFFF00CEB5
          AD006B4231006B4231006B4231006B4231006B4231000000000000000000CE73
          2100CE732100CE732100CE732100CE732100CE732100CE732100CE732100CE73
          21006B423100FFFFFF00738CFF00738CFF006B4231000000000000000000CE73
          2100FFC69C00FFC69C00FFC69C00FFC69C00FFC69C00FFC69C00FFB58C00FFA5
          7B006B423100738CFF000031FF004A63FF006B4231000000000000000000CE73
          2100CE732100CE732100CE732100CE732100CE732100CE732100CE732100CE73
          21006B4231000031FF00FFFFFF000031FF004A63FF0000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00006B4231006B4231006B4231006B4231000031FF004A63FF00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000031FF00}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF00008001000080010000800100008001000080010000800100008001
          0000800000008000000080010000800100008001000080010000FFC00000FFFE
          0000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000030744558745469746C6500466C6F6174696E674F626A6563744F7574
          6C696E65436F6C6F723B466C6F6174696E674F626A6563743B7AD16B1E000002
          3D49444154785EA5D25D4853611C06F07767A9FBFEE86BF991F3E3B4746EB5AD
          D92E02CB357573B118052115215418C604C50826495999ADA2A422F2220AFA06
          FBD0928518D445D1A51883D020A48BAEBA29E8A2FAF79CD7B3718849171DF85D
          1C1E9EE77D0F1C46443933379B16854705022C0135A81E1E7232E5C0BFCA052F
          4E064E4DF6D7D3FD84EBB4F40EAA45077E7EEEE1995C2E9C381E189C7DB2937E
          FDFE483377B6D370DC7E46BA0D2F3AFCDBC8B1214A6B7C92568890E80D732817
          3DEBAF1FFA301AE7E51F73097A9574512AB44ACA347C402A296EA23C593376AC
          FE6CE6418C97BFCD74D0546F0D4DA53653B7D7720179212F8838314F59FBB8CF
          7FEEFDED282F7F7DD74E935D22A50736D161B7E922721D08BC50E509D3DF273F
          4AFACF4FDF68E1E52F2FDB28DD594963C98D74A0C6308CDC00C2BE9222C64BD5
          EB9A9403EADDB150C3EB549897E7C7E334D161A7D11E2FB58BBACBC88D20B4D9
          0AD9DE6279A0CA1D520E683C5BBB2F3DBD3E48DFE7DFD2F38376BAD759477BEC
          DA2BC84C20CCDD8DB01DCB0AD8FE72CDC240455D503960F4351F999D7E93A65B
          4347E944A348BB4A3557119841C88C045966A491C52C6AD625EA1706ECCE2DC4
          D53690748AB52C48265BE093CEEABC56663606B3DF1C35A999A4D528B008F4B9
          8D7C2067BCD7C3E45FD50C56D0CBEFAAB041602D7A813583349210756CC06B66
          D96B6B4127170C6092472CF2D052580E2B6025D8A0185D79204F0825500AABA1
          1C2AA012AA4104476E205F086BA1169CE00237AC072FF8C09F1DF82F7F003A7C
          7F2F9B1AF61E0000000049454E44AE426082}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000009C9494008C73730084636300846363008C73
          7300ADA5A5000000000000000000000000000000000000000000000000000000
          00000000000000000000A5949400A5848400B5949400B5949400AD8C8C00A57B
          7B00845A5A00A59C9C0000000000000000000000000000000000000000000000
          000000000000ADADAD009C848400B5A5A500B59C9C00A58C8C00B59C9C00B594
          9400AD84840084636300ADA5A500000000000000000000000000000000000000
          000000000000948C8C00BD9C9C00BDA5A500BDA5A5007B6B6B00523939008473
          7300AD8C8C00A57B7B008C7B7B00000000000000000000000000000000000000
          00000000000094848400CEBDBD00BDADAD00BDADAD00C6ADAD0052393900AD9C
          9C00B5949400AD8C8C0084636300000000000000000000000000000000000000
          000000000000A59C9C00E7E7E700BDB5B500C6BDBD008C73730042292900947B
          7B00B59C9C00B594940084636300000000000000000000000000000000000000
          0000000000009C9C9C00FFFFFF00D6D6D600C6BDBD009C9494008C7373008C7B
          7B00B59C9C00B59494008C737300000000000000000000000000000000000000
          000000000000ADADAD00ADA5A500E7D6D600CECECE00C6BDBD00C6B5B500BDAD
          AD00B5A5A500A58C8C009C949400000000000000000000000000000000000000
          00000000000000000000B59C9C00E7CECE00CEBDBD00DEDEDE00CEBDBD00BDAD
          AD00D6B5B500947B7B0000000000000000000000000000000000000000000000
          00000000000000000000C6B5B500EFD6D600846B6B00ADB5B500ADA5A500AD9C
          9C00EFCECE009C7B7B0000000000000000000000000000000000000000000000
          00000000000000000000CEBDBD00FFEFEF00845A5A00ADADAD0000000000AD9C
          9C00EFCECE009C84840000000000000000000000000000000000000000000000
          00000000000000000000BDB5B500FFFFFF00C6B5B50094737300A58C8C00BD9C
          9C00DEBDBD009C8C8C0000000000000000000000000000000000000000000000
          00000000000000000000ADADAD00CECECE00F7EFEF00E7D6D600DEC6C600E7D6
          D6009C848400ADADAD0000000000000000000000000000000000000000000000
          0000000000000000000000000000ADADAD00B5ADAD00B5A5A500B5A5A5009C8C
          8C00ADADAD000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000F81F0000F00F0000E0070000E0070000E0070000E0070000E007
          0000E0070000F00F0000F00F0000F08F0000F00F0000F00F0000F81F0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003F3F3F0000000000000000000000
          000000000000000000000000000000000000F0F0F0008F4F2000A05F1000A05F
          1000A05F10008F4F20008F4F20008F4F20004040400000000000000000000000
          000000000000000000000000000000000000EFEFEF00F0E0CF00E07F30007F5F
          50009F604000AF603000D0805F00EFEFEF004F50500000000000000000000000
          00004F5050004F5050004F5050004F505000EFEFEF00FFFFFF00AF9F8F00506F
          700050507000A07F5000FFF0F000FFFFFF00505F5F0000000000000000000000
          0000FFFFFF007F7F7F007F7F7F007F7F7F00E0E0E000F0F0F000607FB000607F
          B000607FB000607FB000FFFFFF00FFFFFF006060600000000000000000000000
          0000FFFFFF0080807F007F8FEF0080807F00E0E0E000FFFFFF00E0E0E0007F80
          80009FA0C000006F6F00FFFFFF00FFFFFF00806F6F0000000000000000000000
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00D0D0D000FFFFFF00006F6F00006F
          6F000050500000505000FFFFFF00FFFFFF007070700000000000000000000000
          0000FFFFFF007F7F7F007F7F7F007F7F7F00D0D0D000FFFFFF00006F6F000050
          500000505000006F6F00FFFFFF00FFFFFF007070700000000000000000000000
          0000EFEFEF009F9F9F009F9F9F009F9F9F00D0D0D000D0D0D000D0D0D000D0D0
          D000D0D0D000D0D0D000D0D0D000D0D0D0007F7F7F0000000000000000000000
          0000EFEFEF00EFEFEF00EFEFEF00EFEFEF007F7F7F007F7F7F007F7F7F007F7F
          7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F0000000000000000000000
          0000D0D0D00080807F00FFC0000080807F005F5F5F00707070003F3F3F00D0D0
          D000FFC00000FFC00000D0D0D0009FA0A0000000000000000000000000000000
          0000CFCFCF009F9F9F009F9F9F009F9F9F00CFCFCF00A0A0A000CFCFCF00CFCF
          CF009F9F9F009F9F9F00CFCFCF00A0A0A0000000000000000000000000000000
          0000A0A0A000A0A0A000A0A0A000A0A0A000A0A0A000A0A0A000A0A0A000A0A0
          A000A0A0A000A0A0A000A0A0A000A0A0A0000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FC010000FC010000FC010000C0010000C0010000C0010000C001
          0000C0010000C0010000C0010000C0030000C0030000C0030000FFFF0000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000B1D6E9000F74A4001F81AD0063A6C60000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000002F94BD00007AAD004CD9F7000CA3D2000480B3001981B1004D9B
          C200D5E9F3000000000000000000000000000000000000000000000000000000
          000097C9DE001989B700007DB00090EFFF002ED5F30026D2ED001DC9EB000FA4
          D2000483B500107EB0004797BF00000000000000000000000000000000000000
          000054A9CC003B9FC600007FB2009FF1FF0064B5C40056B1C2004CDDF80034E0
          FF0033E2FF002DD0EE0020B1DD000C86B6001A7BA9000000000000000000A8D4
          E5001389BC00B6F5FB000081B400CAFAFF005D7179007390A20086D6D00082EB
          FE0045E2FF0045E0FF0046E2FF003FCFF000006DA000000000000000000064B5
          D30045A6CA00DDFFFF000084B700D3FDFF0093C0D80034B356002CB4440053BB
          7D0097F2FF0058E9FF0056E4FE0064DAED00006FA200000000000000000037A0
          C800ABDCEA00E5FFFF000086B900DBFFFF0080DBB40066FF98005AEC86002EAD
          460066C892009AF5FF004CC9E300AAFFFF000072A50000000000000000000E90
          C000CAF5FA00F1FFFF000088BB00DEFFFF00BAFAED0053E481006AFF9D0055E1
          7C0029A43D007AD1A80087D8E700D1FFFF000074A7000000000000000000048F
          C2000F92C1007EC4DD00008ABD00C3EDF5008DE0ED009FEDD60053ED830068FF
          9B0050DC7700229E370098DAB900E2FFFF000077AA0000000000000000000000
          00000000000000000000008DC000F2FFFF00C8F7FB00C0EDF4008BEAC10059F6
          880064FF970042DA690033873F00D9E4E100228BB70000000000000000000000
          0000000000000000000025A1D00031A5CD004AB0D30083CDE200E0F5F9008CEF
          AC0055FC88009AC1A400CDBBB600717191006CA9D10000000000000000000000
          000000000000000000000000000000000000C3E7F40080C7E20048AED40085C7
          DE008AC0A900FFFFFF007892F500203DDC001D2EAC0000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000081C4DB008B9ADF004277FF002D4AD8001724A80000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000056B6DC0068A7DA002942C6002134B1008FB0D40000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          7E000000424D7E000000000000003E0000002800000010000000100000000100
          010000000000400000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000E1FF0000E01F0000C0070000C001000080010000800100008001
          00008001000080010000F0010000F0010000FC010000FFC10000FFC10000FFFF
          0000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000040000000F0000001C000000220000001E0000
          0012000000050000000000000000000000000000000000000000000000000000
          000000000001000000050001011F0B34279C125F47EA156D51FF125D45EB0A33
          27A40104032E0000000800000001000000000000000000000000000000000000
          0000000000050105042912523DCD20775AFF2C8463FF2A785AFF358B6CFF1E75
          57FF115640DF0106053700000007000000000000000000000000000000000000
          0001574A46FF1D5B45E3247D5FFF359874FF3AA680FF2E8565FF46AD8AFF3497
          74FF227A5CFF17523EE54F423EFF000000020000000000000000000000000000
          000626382EAB1F7B5CFF389C79FF41B28BFF45BB92FF328C6AFF4FC09BFF40B0
          8AFF389B77FF1B7357FF1F3028B30000000A0000000000000000000000000000
          000B144E3AB22C8A6AFF42B28DFF48BF99FF49C29BFF348E6DFF54C6A2FF46BE
          97FF41B18AFF2A8666FF0F4533BB000000130000000000000000000000000000
          000E1C6D51E33A9F7CFF49BE98FF4FC6A0FF87DBC2FF579C83FF90DDC6FF4DC4
          9FFF46BC96FF389E7BFF166349E8000000190000000000000000000000005D4F
          4AFF227E5FFF46B08DFF51C9A2FF7FDAC0FFADEADAFF5A9E86FFB1EADBFF7CD8
          BCFF4DC49EFF43AF8DFF1B7355FF50433EFF0000000000000000000000000000
          000C217E5EF84BB995FF56CEAAFFA6E8D7FFB1ECDDFF5C9E87FFB6EDDEFF9EE5
          D1FF53CBA5FF4AB994FF1B7457F9000000190000000000000000000000000000
          00091F7256E149B793FF5BD3AFFFB2ECDEFFB4EDDFFF5D9F88FFBAEFE2FFA9E9
          D8FF56CEA9FF46B390FF19684EE4000000140000000000000000000000000000
          000629624CD33EA685FF5CD1AFFF7C8C80FF64594FFF5A473EFF61564DFF7185
          79FF57C8A7FF3BA180FF215944D90000000D0000000000000000000000000000
          0002515D51FF308466FF4C554AFF765F55FFA38979FFAB907FFFA28879FF6E59
          50FF3D4139FF2B7E61FF465348FF000000060000000000000000000000000000
          00000000000533372DB5654E46FF7F685CFF9B8173FFA88D7CFF987F70FF705B
          53FF53423CFF292E28B90000000D000000010000000000000000000000000000
          0000000000010403031448372FBD765B4FFF866B5EFF866D61FF796156FF624D
          45FF3D302BD10403031F00000003000000000000000000000000000000000000
          000000000000000000010403020F47362EA7725649F6715549FF624B41F7372C
          26AA040303180000000300000000000000000000000000000000000000000000
          00000000000000000000614E45F94A3C34B20B09081F000000070A0807213B31
          2CB24C3F3BF90000000000000000000000000000000000000000}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000020744558745469746C65004944453B546F6F6C733B437573746F6D69
          7A3B44657369676E3BAA5D2992000002F249444154785E85527B48936B1CFED4
          CA9C3335EA04411195E2854C83637F6874CE11835C4491E1D41C626A93E6F532
          AD33FD66676ED986CE6C733ADDB48B13CC5B70C8AE33F38FAC59C7AC202D2C99
          6526A94D8D1D88A7F7D3AD697FD4030F2FEFF37B9FE7FDBD17EA277022747690
          99FF1A4E76D63577C34EADC108A1A4F60CD15D0AA5F55441691D259468A9BC7F
          6A97999DD5FA0E6B555DDB0385AAE900115646C564480D6D37C0E056CF6364D3
          6A09D157103A01A072C49AE50187E2B368415E19340D9D902A1BB84C08879B21
          53E95A316D99C78D6E13D24F574A199D09C92C562F185DECE7DCBD276A5D02BF
          088F065E4128BEF0CCB6D0ADA2FE5FBC1E9DC0E4D42CAE1B1F822F54C8989A40
          7481A2649597AC62590DCD2C4C12D062A9B2114F87C79123525A89C622F428D3
          74E2E5C8389E0F8FE1C3E40C8ACA0DE0260B43496D15955354F942AE6A42B6E8
          3C2AB55731F26E0AA61766A4E59EFDD89A145CD62D089DEA1F7C8B583E8DD813
          0C8B915FA2C2B99A769C28AC9053C705345724AD45CFC3E7786DFE84BE41337A
          4CAFD0529281B9F77730FF460F7DE496FF7D3C5D3732DD84471EFD33F3EF0ACC
          7FB1225DAC05C5B4712CA5202135ABD4C4CF9622242C7AA23A239198EFE2CB50
          29EE4BFE021DFC5B1531AFCE95E82966E47005CAE8A453883898C8B3BFFD0A42
          37C2F56A4EA07676EC0EE6064530D2E1E0878520EA30AF8DD4DC977CAAD584EC
          853BB8CC09B287B85745F8575BCCB761799287EBC250C404054051A543738711
          8969229D23C481EF66C51EBFEACFA33761E93B89CECC9D88DBC0D66FD81C7C2D
          BFA416BD03A3686A37223EA540CFECFC63886BC9EFBEF2E9912ECCF426A3252D
          10D16B595AA27B137A6DF2DDDB9853ACC1BDFEB7D019BA10C3CBD62C1EC1018F
          F2DDFE33135D0968E0F980E3E156C7186DBBB8107A6EDC1A7689965FC47F43E3
          E0A58ABE126DCDD2009668C7F62BF25DFE10066C53D9CD644E31B48578FDB12F
          AE66FF613E8EC4A5B72EDE85032E36C1DB7E49B29D7ED452DABA61D9C2D90B1E
          1BBE015F026487EBD860BC0000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001C744558745469746C6500486964653B52656D6F76653B44656C6574
          653B65796578098D2D0000033D49444154785EA58E6D4C5B551CC69F7B6F5FC6
          16824C6453918D59171084CD8C6E401962EB5E70A09D51C7E670B52AB00DB6CC
          A8D987651A852C8B28B8C9B22D7BD100D906DB4C9629A8B8B6300960796DB614
          CA68A3465EEC5E0BA1EDBDE7EF6DD398F8C90FFE925FCEFF7F729E3C871B2B79
          098C00220ACBA4F009620446B28CFD6B5E75A59D834CD7863C628CA008061988
          2390140A44828C85E6C81D0BEFDAABD7B8E65C6D5CE7BADC1649642CABD5AABF
          9697C51462500A372E5AA14188F803477800DC3F46A8CFCE8C5B3C7F5EEB939B
          8BD207CE367543C61F08847E20865AC2C1DD394B63BE284C291178CA2786A53C
          280DAAA81B1AAD81D436FBE309CB131FEEFBE69CA3DF7BF76500E40F0481EE82
          7CC80835454F179FDE96E9B5D6ED2157DB499AB47F4BC1093B4D0C5AC8BAD548
          AECA37E8EA8BCFB33315DB3F02A096E59A9F4941385C6B4C2DFBFEE056FAED7A
          1335D7EEA7E24203BD52B8910E7FF2295DD9B49E5CBBB6D1E5023DDD6C6BA286
          B217A40F7312CC00540D4F69807DF99AA4B3A6ECC08983E5B4C3F416E90CAFD2
          F196EFC831E2A24B1BD6D148E9163AB7DE40473EAF27B3F95DAA7EA788EA8C19
          645A11AF03A0502C5918553AC42F53AE5DB911357BF2F066C52168972F83B362
          27529F88816DD883E49AAFD058DF82A3D555B07558D071B9118931772A01F4F1
          2E756E7176D10EE8F50628954A18D7A6E3D6077B91F25834DA07DD90B69763C0
          EDC5822815385E804E970F6DA109A36A5D3600819F08A80E3B5C7E80E330F3D7
          34622E9E46F223F360734E42535587DBC24368FFB113C682E720318610BD43F7
          317E8FD50190F891AE33E787869D5F77770CE297B7CD488E8B82657412E2EB26
          1C3874025DD60EBCB6290F99CFA6C237E347D3A55EF4FE3A74C1E5B8D808C0CF
          01506E494BCBD0F3C2CFAB9313A27F1A9B46CE97C7C0CD8FC5A38B62E1F9FD36
          EEDD9F454FBF079DDDA3B3DE29CFA9015B6D3500AFACA80020AC999A3EB53227
          3DFA82C5EE164BDEB37F7CD49A341760B1BCA04C0ACCCD8D4BA2FFEECC83E936
          8FF387863B53CE3F00F8AA550B44C82864E1F6CDF8C65AAFF70CAB552596CFDE
          FF138020CB472459493628EB9715E53021021779AC8AEC015956AE5013036109
          AFC47FC11111FE0F7F033DE395AF6E7F66A70000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001B744558745469746C65004D6F64656C3B436F70793B43
          6F70794D6F64656C3B892D59CB0000023849444154785E85D04B685D651486E1
          E7DF7BF79CD3D6548B8338CAC8CBBC4E2452E2A514051147223AAE5010AA139D
          8AD116412D360345080A924127B60E6AD28A62EA95A21369AD974A03A618B56A
          20F1E4649FBDFFA59889A1015F58D38F8755450480919191F2C86BF31F14294D
          84842C070111024D5D7FFCEC93FBF7ADACACD450D95C1162E2E0A37B10202080
          C0AB6F7DB917254095FE090552B7DBED8CDD749DBA5EB73668410E522A9455A9
          D72DB54D0B09A04271F8F5CF37D8915CFCF14FDF5CFA5D280422B2D1DD3D0FDD
          779B6E67BBA6DD6220A29D78FAF13B11B0891E989CFA44D33422423DCCD70852
          DB40E86FB0850422D3EDA67FD96D1B72D85290FA83A140FBDF8F47809C0B7F0D
          86EA8D1175DD6C256808720E91109429294B52E2DEF13123DB3BCA22DC75C798
          A9B6DD9652AA10158AB5412D07C3361022A83A85E5F9F7F43F3BE3562C7FC4CF
          9D5FECEE2EF9F0B93D57370BDA8C902374CAA42A19368DFEA767DC72CF38185C
          B9E2E4DCAC47A68E8095C54B4EBD38AD82619B451011CAA270E2EC0F66CFFD44
          F52067D975FDFB76DD709A7D3B7DF5EEF3E0A9D1DB410579980576F62A45B466
          E6CE9B7CE161B070F937C7670E387C68127C7F79C14B6F4C330A5468D7EBFEFC
          81674E4E84F0C0DD3783535FFC0A16BF5B00B317A6C1C5AF97C18963A7ADD6F9
          E50AF5CCB1C7EEC736A4B75FD1DB7FE8F892FFE989D9A51BB15A4544C6DAC691
          525A5FBEFA87B937DF01B0A337307DF45B00F55A3E8A55D4956BABCFCD1CDC81
          1200090081211AF81B46C61F74A3585C150000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxPNGImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001E744558745469746C6500436F6C756D6E57696474683B
          436F6C756D6E3B477269643B2D8C5D0E0000018A49444154785E6D50BD4AC460
          10DCCDE510AEF469B4933BF039ACEC05116C22B907F015043B5B4B41143B0B1F
          416B2B1B11EEF2ED8F9BDD245FE219986F965D6676367871F3F608004B0328C4
          1B4586FED313E6E7EBD38355F9FEF1B9ACCF568005865C47B2BF469AD79CD7F7
          47464599888158E1EB7B0B4598E410BB62EFEF2FE640446D034B6A0848047EB6
          0CB3C22CB130B48C801846626A11051600B66751CE20992E1234C913246648D4
          0A0454B54F11B5734ED590E4048D15246AE2B8B97D823A208C8A98256E0D3812
          5062171BF2D658396C0D8E898A2548024CD41B903B5AACCEC08539B2B178914F
          48D610E63881A879B8ACEE8E7374578720BB8CFBCE4C9B17AB08DB18863DC3DC
          8030FDD069176A48860D1E2E4FFC0FE95498374F1A6834F4F4F5E9164B11195D
          07958DD7E8C9A76E1A5481CD5573B65294FB6D95516DFDB50C3AED8B9E6A7565
          988481704EEAC7808E624664D7206024A9C1A19D018B4FD19A5655288043429D
          FE0509D5DAE8AA1F942AD2DD886D13043584CE186760285DAC26CE47C12F93C6
          41C20E911C5D0000000049454E44AE426082}
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002C744558745469746C6500507265763B446F75626C653B4172726F77
          3B536C6F773B526577696E643B44656372656173657A53DE51000002C7494441
          54785EA5917B48937B18C77F5DA5A8437634ED58FFD439A0E18514D48E5A201C
          8E7F2CA39AE1AC855A695E32D363DE466547524E1EBC7496E70CAF34D174B510
          AF73A8D3E69C0E346D738A79094D0AB7DCA6730AF2EDFDEDB010EA3F5FF8C2FB
          7E789ECFEFF73E0F01B0A5105EC324C97E3E41D26BC6C89D2A0DC9AA9FF8CA98
          6707933D4CF6D277EE5FCA6F18C9A8D59234A196A4566BC8EDF21146A4A545DB
          695160447E60486A73CFB9CC2E30EC87CDECF7542965FB484AB59AE82C209F56
          616BB43B1596E97A21BBA93EB6706043D8370F81588D1341E17E94C5140D6E08
          150BF82DA9830AEC49A26094366E63B2DB23F8B20B9BD758105B3260AEEC9E43
          FB3B2344430BC8289523A67870B552F6011D3316B44D99119CD44E050769F34E
          26FBD9592FD2AE172A754F2533783D6D8270681129CF4610F78F0A7CC92C7ADF
          9B211AB7E0EF7E136ADEAEE04C422B153810568A901391D733F6583C09F9EC2A
          DAA757F0F0D538A28B95A0AC976192D975548E9A51A05C466ECF12CADF981078
          A3890A1CC9A53FE5681D334236BF8E5AE68492FE4550D6AC36A06B6ECDCA4A87
          5750A434215F6EC4FDAECF783260846F5423151C2241917C2E2B5D3275A74283
          FF5406142AF4B855358C8B0F64486618BFDF80E2C1653CEA3322A77B09D9521D
          1E2B0CF0B92AA602674287B7D7DEC5D1FFCA535E484ABB3EBE4C83DCCE8F486B
          9C02A7A017AC0C296E5226D3E15EA71EE9123D72985B7871445470980427B47D
          DDBBC3B1805FBCC34ACB4F27B658A2046AFCD13287E4BA5170EE8AC1B0B54881
          06773B74E049F57067D753C14FC4FF5A13E1AB4CD655DA36E2E476D6D72D94DF
          1C10DF8AE8322DF2CA143870D48F45D9AF716D88AE9880EBF93A2A3842987F21
          3E5C31F1E6BE24272FBFB08976D11D3B7B455F3C1EF2AFCA33ACC15ABC99FD1C
          6A1538118F70D1FF091311777603F1BC64FDB689EC98FC48A74D67F55D06604B
          D9B2E00B4EFC1D5F135F05C60000000049454E44AE426082}
        FileName = 'Images\Arrows\DoublePrev_16x16.png'
        Keywords = 'Arrows;DoublePrev'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000021744558745469746C6500507265763B4172726F773B4C6566743B42
          61636B3B526577696E640B2B870F000002AF49444154785EA5925D48544114C7
          FF773F52B30DD3DD75AF461BB56AA8E507A91946904451085A1651481F4A1624
          8118B818140616F4854FA1840F5191652941D683681019293D44190422852686
          0865EDAE7BE7CE4C33B39BA43E3670983367E6FCCE7FCE8C76A57B048C039C5B
          60320646394C938372E133310BFF7A759E06C002C08EC83038E70C32C818C029
          404C0642180C932910256236984C9689B1071AEF55545F7DF5AEFADA6048AE11
          1D36599181A3AE221306D3204B71007AAC45552CAFBF5D9498EC6BF67A5DDB4B
          F253D0F1F8A3CA9B07989C8333064D5D83438FB34A867DCFA91B696E6FCEF9D4
          14D7A1E23C1D4EA7039A0610CAF0EFB05111E08C23314625DA4A2AEBDDBEFC5D
          7E97CB5953B0498FF1AD73E247C8C4C44F0309715698730AA0CD032E1DCE910B
          6B7AC16E4761D9E9DA5549BABF60A3BE327B830B220F53B304813045D86408DB
          3418E622804CAEB9FCB4CA1AEFBC98ED4B5E939BE911112BA6030C41126D2C65
          0A103434988C2E01D8E313F48E7D3BD3118205D373F2208149014DE3601CC217
          200A04380531962AA053E35FFDED9DBF1B32D23C4919191E980C02C2401907A5
          5C2A5090B0DD02932C546001403A5B2A6FBEE969CD7D3930D4FAE0E1F0DCE8E7
          EFB0691CC48C48374CE903217925C617020E5EE89311636CB867B2FFD651FFFB
          BE3BF97DBDAF3BBBBB86D8E4F80CC0231F8B080B130EBAA889286B7C81BDE77A
          D13634FD976C05B062EDD6DA92DCFDED033BCEF6F2BABB9F78D3F309659B8FF5
          70006ECE39A4D9C201A2E8B3418696FE2919A34DA59EC097C1B6B700CA576F39
          53FA6D2CAB3975BD372BABD007932D54A06D3BF9049432D51CCA289894C9217C
          8691AE2A4BB4D18ED4A286237687B7DEE1D6BD1FEE573A45A51905283EFE084C
          DE316CCAAE4B5F01B8F223771E7D7642829601588EC8F8250044018483FF197F
          0048B183E0A83E959B0000000049454E44AE426082}
        FileName = 'Images\Arrows\Prev_16x16.png'
        Keywords = 'Arrows;Prev'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001B744558745469746C65004E6578743B506C61793B4172726F773B52
          6967687416E40EAE000002AF49444154785EA5925D6895751CC73FCFD14D46BE
          B41AF6C20A870425152C2F82A08B0ABD295D05416F572184045D2644082A425A
          831A62128E2E448C59108D9430D84A1C81DBD4D6B6D05C3B739B5B3BB1EDAC73
          CEF33CFFDF4BCFE1807076DB173E7CF95FFC3E7C2FFE91BB136501D600D556C0
          3F3839EC8262062A86A9A3E2881B224AE9DF949E032F90A396B5877A46C3BEAF
          0687DF3DDABB0B683CBAE7A99C064352458212AA484053218943F55D3BA4969C
          A8B2E7C5C71E3FF7EBFAEFDEEBFAA56FE1D6C4FECFF73E7D1908638BC1821A6A
          10D439DCD58FA8D7092255A3A5B9898EE71F213FBBF9B99F06365D7CFBE0F9AF
          676E0C1FDED6DC70030803B3154B122388616AF582204A2A30B562DCD5BC8137
          3AB6716DEC9ED7FBD76F7C75C3E6B3DD7F0EF67EFCCC834D7380EC78BFD7D457
          2D90E0A46A9412A5583688E081875A78B3F5DEC6CBD75AF636346D7AAB65EBB3
          9DBF5F387EE242D7AE2520D0E59EBBB320552AC1A8A4423938C58A905F4C3302
          AD5BEE67F72BDB373EB1BDFDC0932F7D34D4FE5AE73B4063DD822408A5D4AB20
          6224197195580966AC6B8878B47D0B0F6FBDAFB5E754F205701A48EE082AA540
          A124148A29E6206A04ABC9725184C6C6D0C84D4606AF2FAE14663E03A47E811A
          CB15214E0D7343CC897211EBD6464C8C4F73F5D278BCFCF7ADEEF93F7A3B97A7
          06E680A44E90A6CA526CC4C18822674D2EC7FCC43C570646AD3033F5CD3F13FD
          870AD7CFFD05C480B5ED3CEEAB048195B262EE141796B87A7194DBF97CDFCAF4
          9583B77F3B35045400FDF0C7593F7DE45B4484D50B982B14B3C33126C76F8E94
          1646F74F0F7ED9079401D9F7C3AC03A880AA60AB7EA2A6B1F27DF7F9A9CAE2E4
          91C94B9F9C014A4068DB71CCCD9C339F9EA5DAA686BB634E9DA0FCF38997EFA6
          961848DB761E7337C7CC5071DC0C73C7AB4419A60044EECEFFC97FFDEAC21326
          FC988F0000000049454E44AE426082}
        FileName = 'Images\Arrows\Next_16x16.png'
        Keywords = 'Arrows;Next'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002C744558745469746C65004E6578743B446F75626C653B4172726F77
          3B466173743B526577696E643B496E637265617365C977401F000002A4494441
          54785EA5937F2C947F00C73F59FA4145B1564C368DFAA3560B49E12F27B34EAD
          E5BEFB2E6B5487B14493CC8F6A213BD250A11885EE34CDF97147256EA2E3B843
          E28E76A8CC6EDCA8DCE122DE3DCFB3E30FFACF677BFFF1BCB6F7EBD93EEFE721
          00D695750BE8634265933126E1057D6B98CFCD26E215F996B85D1191801429F1
          4F6C21CB8C3E9BE3042A843F5548CEDF2A75A3C0162A5BEFBC1E5CCD4C5C2E8B
          C885E48F841D2F21AC9846E219F1861198C594F4A37D588724FEC06220AFB9FC
          C869EED1EAF65148D5BF5698FB7F4907E897D1A26EED0291690CE454683D2330
          8F2AFA8CEFB3C0F0F412848A0970B3E47309056D908F6831A09D43A57C1CDC6C
          F9AC6F7445A6BDF3393BA368C389103123D816F1B407CAA92588BF2DA255B388
          4ECD3C1ED40C8173EF03E29ECB51AFD2423AAA4746B51A67121A275D2FE6C553
          BD9DC63B223BB88F145068FFA07C701E2F9506F0550688870DA856E9702DBF07
          ACEB75887DA18050F573851D0FAAF8E2E89312440B2C02D365681E5B4071DF1C
          0A7B0DC8ED9A4176870E8F3B7528E9D5234B328EC3FF578227195BC368816540
          722BC443BFF1A47B06399D7A64CAF4784809D29A26C1E175C09D5B85E0EC56F0
          5A2656D8218EE0AB9D67E2555AB08B9D2081A07F16E96DD35459878C962904E7
          F5C2234C044EDA7BDCAD53E37EA306C1B99FE01C24FCB19F957AD7D4CCDAC638
          2FB1624537E0591755944E23AC7800EE212203275688941A2552A96268919261
          4E67728AB6DBBAD0739AD3733AB0F9CC0AD62743EA70E3D508BC221BE0E49F5F
          6B61EFE99DC557208AAFA6D83B86591DF477A52F9CCA467AC2DBEFA7C83EBF32
          46B0F3D8A52A38B20B657B9C43CF1AE7D9EDC1AD5DCD4CE9A2035B40ECFDF8C4
          CEB78CECF52E6504A6C692E5F207F22F66E35D42A830455B5629313EAFFF6FFC
          0B0C0C183FEAAD166E0000000049454E44AE426082}
        FileName = 'Images\Arrows\DoubleNext_16x16.png'
        Keywords = 'Arrows;DoubleNext'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001B744558745469746C65004164643B506C75733B426172733B526962
          626F6E3B9506332F0000036349444154785E35927D6C535518C69F73EE6DEB64
          63A3AEFB60A3A36E33B8C56581E0D8707E21CC1A43A2A22304FE3001512A86C4
          E900132451FF503367420043B244364C483031465C248B4441C0980C45B4D065
          CDBA4ECAE82AAC5DBBDE8FF3E1BD27F1397973DE9C3CBFF7233964226FC2D543
          A53E0280443E3FD752525AB14323FA06685A3381E492F329C6ADF39954E2F8C9
          C3DBA6018858DE940A9C2C5870C1D51BB6FAF61DBB327860F81A1BFE25297FB8
          3127C7EFE4E5D5745E9EBB9991239766E481937FE4DE1818DB0DC0EB322EABBA
          B63FD5EB7D6CCBBE6F1B83FE9E67BA82E084C0E4123697CAE0D109BC94805B0C
          E7AFCC606A66EEECF75FBCBB753AFAEB2201A0BD3E7861B02914D8DBF34408A9
          AC0D2181D3672E23319D81AB950D016CEBED824E809A722FC62E4CE17A343130
          D4DF73507FB9FFAB551E9F6FCF93EB82B879BB088D52504A14FCC9CE4E95F79D
          B80CD396284A8179C7D3DD1144F29FEC5BE1D73E1BA6BEB2C09BEDCD955A7CCE
          44D1744C1687C9045C05EBFC686F0DAADCB08413D2098E89B4E1BC5779965687
          5ED585D03ACBFDA548E7197EFA711C776EDFC5FF12200A7075F4E85975D7D4FA
          F1F4A635A82C5F02A2956CD46D2EEB1D160B455BC19FEE5E0F4A885A45828071
          81137D1B61DB0C1E5D43E4C8CF5858E4D0A1810BBA5CB76DEEBDB768C1E604AE
          EA6B1F40D9121F0A265385BC0E5457530109404A8010E27805EEE60598CDA15B
          8699C8E7CD4784EEC3F2BA00767C340A4AA9327E79300CE1505BDEFF0E9AA681
          5082150DD5604CA26858282E1693D428E42F6666B3909068EF68C5E6171FC7E6
          17BA611A260C93A9029C713CF7FC3A3C1BEE404B5B2398E0989FCBA190FD774C
          CFA46243B11B4B77ADADF67BB236478E10500AA5D2121D5C48354D3A674108A1
          56114C201E4BB1D9F86FA70880FB1EDD3E34B0A229B4E7E1350FC2E22E2011BF
          16C3FCBD050557562DC3CA964608B8B4C4E49F4924A27F1F193F1DD9AF03B0FE
          1AFDE03D113EDC6431B1A96575089212B4AD6D555F581280D902398343308EC9
          EB49DC9A981A75E043000CA46D09005A49457059DB4BC78E77EDFCDAEAFDF892
          DC3B1295EF7C13977D4E444E45E52BCE5BE7AE338555E10FDF0650EE32B30E4B
          D24C0212A8F210EAAED3D01969BB3FD0BCDDE32BEB06D56AD5D09CCDDA66EE62
          EED6EF43A9AB2331008603ABCEFF019D3AAD15CCD8D2E00000000049454E44AE
          426082}
        FileName = 'Images\Actions\Add_16x16.png'
        Keywords = 'Actions;Add'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C00000017744558745469746C65004D656469613B506C61793B53
          746172743B51505E670000035F49444154785E55926D4C1C6510C7FFCFEEDE0B
          B71EDCA2C5A650E0A41A110E6CCA8B155B2155D0AA1FB4D6A489DF6CED075B62
          A2506C4C8C126CE2CB07FCA0B4B46A4D246A3150D3C446DB145BE0848289504A
          3572B5722795CBE105EF65DFC7DB2798C667773293999D797E3B336CE16F0D1E
          89C1798AFD2EF6DAF1B14AB7577E5110D876C6841A0020A219CB342EA55757FA
          DF3FF0E83C003BFA8F4EBA454024A96371D50000E1F54F2E77F47C399B1D1C8F
          D20FF3099A5B4AD3D59B19BA782D4183E128750FCC640FF58F7501700160D773
          B91203A1ABE7A4B7EBC4F4E90D77FA5B5BB694406380AA1396351B0420CFEF45
          8592877B4A03DE919FA2473AFB27768C9FF9F8E960C09D66008457FBC2BD65C5
          CA81E6C652C4564D9836E1D6616B9AE0160514E74B1899B8815F2237FB3E686F
          6EC7FE77CE6E3E74ECB239B598A2D3D79234349FA4E69706E899C3A7A8EFC202
          0DE57CC3F38E9F6BFECD5434451D4727CDE70F7FDE20D9F0BCB0A93C20FE9531
          A199361803C0088F3756E09BE13114AC0B60DBC3B5500AFD00311E5F4A99A8BA
          FB0E311E5FD92719A6DD7A7BE16D58552DAC91F3896CDB5C8EA6DA529C9F5CC0
          F05717B0BE643DB63E14822C7B615A40A05076F47641D58C32DB25F1DBF53571
          30DC92888D457EEC7EA40A3D071F435D50C1D017E77071E467A8BA0DB8DCD00D
          AB58D25503C9B4094B641C9140BC6F36112C9BE0F779100AE621164F215F51E0
          F1F9F86589B40E35A3334953B5D8F24A3A2817F8383A7F99008F4B84EC756174
          268A9367E7E02DF0A3A5750B841CAD6A584824D350B36A4CC8A653E7FEFC238E
          AC6E23930BE8860D87239ECCA0BDF73C3E1B89A0A6FE5E84EEDF848C094E9BD6
          2C2C2D267204A9306BD8FD6EBD52B431BC7567830851E213B8F4ED8F5857A4A0
          A63608D92FF3E2A6ED0881FF216C8C9F99B09622333B180057E39E8F3EDC505E
          B2B73AD76502A0C82E981621A35B4E1FFEB7528C31CC8ECE62F1D7DF06A6065F
          DE2B01307F9F3EF58A69ECAAD075B3A5AAA91A098B40B79690DB02085A46C35C
          F80A966FC446AF4F7EDA0E40C3D75756C0E380AF7AE791371AF61C5377BDF91D
          ED3F3E4D1D430BD4391CE1F6B3DDDF53DD737DEA7D6D6F7503C80720F2DCC1D9
          0497B5229EBB1E3C5857D9F6F6D1EA27DEBB1A7AAA97424FF6926357B6F59C28
          ABDFF700803C07E8BFBC7F01914FB3C1BF5BA04D0000000049454E44AE426082}
        FileName = 'Images\Media\Media_16x16.png'
        Keywords = 'Media;Media'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000019744558745469746C650044656C6574653B52656D6F76653B4D696E
          7573EBA98F410000031A49444154785E7D925F4854591CC7BFE7DE3BA3B9EEBA
          0D3BDBE85A3AA5C16A85586DB4B49459490FBD444B62C63EB450ADECD243D4DA
          4345F4982804D58B0F1541FBB02C0B1995AD44160A8B59499A8330E3486AEA4E
          EBCC9D3F77EE3DE7F43BF78A8F9D3F1CB8E77EBE7C7E3F0E8B9816D4585F5CC0
          00B0B6AE87352B8ABF3CAA33A311BA5ECD20B9E43CEAF07CDFC274ECFACD8B2D
          9300C4B86949179C48E7A1C0FAC6E68253D7063ADB6FBD726E3D8BCB0763F372
          E8BD295FCC99F2E1DB0579FBF9946CBFF93279B2A3F73800BF6214CB145CD770
          D8BFE3D0A9BFD7AD0934EDF97E0D3863B0B8844D5B69F90C06BFC6C0F30EFA06
          A6109D9ABFD773E34CF3E4E86046DDEB273A9F76568583BF36ED0C637AD18690
          804680DAF04421A404E52054E247EFD3284646631DDD679BCEB11FCFDEA90D55
          54BDFAE9E0063D9AC843D73417D469330DCB43081522C0395019F0E3CE9F23F6
          D8F0B32DACF5F2A3EB0DDBD69D280EAD84E500BA0E18068530461BCB830BCF82
          73E19AD98945F4F40E771942E8DB4B02C598331D3CF96708EF6712F8D4089506
          B07BDF667C55F21998BE62AF418D2A2716A9ACEDC2577F6BF04AD0DD52BC2E33
          AF177E9F8E63571E2395E130A093955666D836F77FC8E46173CF7755B0044585
          3EA2D4F202A49AEA945E98CD0512A6806353503E67C54CD3DA288C02947D1344
          CBA57B64A0B93F1A7E03B66543231B5DD7C1C86875C52A388E4436974736938D
          1BB9B4D9BF30BBB87165791075DB6A51E8F31A48CBB3905063D9C07238523907
          FFCF27915EFCAF976D3A70A1BEAC7AEBE0D65DB53EEED54B06DEA9A65A588285
          106E9070045E3F7FEB4406FFDAA2AE0BBF6BEDEE585D15FEE5DBCD6B91E79260
          E95A80B632904B0E028A9698781D476CF4CDD5A1BB6DBFAB00AD2850F945CDFE
          8B7F9486CBF7D5D4872135A6743DCC2D4312CE20487F62248E7791E8FDA1BB3F
          1F0190D4E66C29328958EA4DCFF9E6C9B1C88DFEFBC3F6E4F80C72664EE1AE7B
          266D211E99C1C0A39799C8BF03A7096E01909A2596CD399EE3D73EA6A9722AB6
          B76D2A0A56B7FA0A3EFF019A5EEA4A7367D6B692FDC977C3DDD32F6E8F03C811
          EC3A7E0415947A6BBEDAC8770000000049454E44AE426082}
        FileName = 'Images\Actions\Remove_16x16.png'
        Keywords = 'Actions;Remove'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000021744558745469746C65004170706C793B4F4B3B436865636B3B4261
          72733B526962626F6E3B6463C8680000037D49444154785E4D8E7F4C94051CC6
          3FEF7B77E02073EA92742577579B684891E62AB6C4526B6013696BC9DC5A0B33
          D0322DA716D3CA94A21A8E96E976AEB654688E409B46B859CC249500E3F81588
          234EE0F875DC1DF7A3BB7BDFF7DBC16AEBD9F3D9BEFF3CCFF7C13555CB58A801
          40014CC5E5696BF638D24FBEF7EDF2D683550F7B0E5666B4969C5A5EBBEBCB65
          2F0209803A116E6438F82377A66A60385007A0E4EFB2A5BC51B1B4AEF4EC5AB9
          D476583A87AA642C7055BA47CE4A43F72752713157F67D93DE54B0DFBE04308D
          867E9E290050725F4BBDB7F8E8B29EAA86B7C4E5BF203DDEE3D23E71585AC6F6
          48E7E4C7D2E777C870A05E7E68DE277B4F668C6EDE6BCF00D4017F350A607EF5
          48DAB99CECBC9CF4343BC3E1264CAA60C282AAA8288A028A30313E852DE509EE
          0C4D72EEF26967CD17FD4F0EDE0A064DF9BBEDEB6CD6C51F3C9DF5382EFF1540
          104014216E500C2ED6DDA4F67C3BEDB79BC9C95EC3E8F8784AD28288BBADC1D3
          6C4E98652A7C2C7D2543816674430304C4885B0755E1CC99EBCC51D750F14E35
          DBCB32E91DF98DCCA5ABE8FCB36733E0500D3132EF9EAB108C7AE9ED1BA6B4AC
          969F2E39896A11CE5F68212529975D5B4A395A59C40B79CF6049D0489AAD81AA
          3C0A9854436741140FE148809AEA16CA8AAEA34C65F1E9E7F524EBEBD99A7F80
          53751FB2707118EB836642311F31C63174497C286BEE6C55D3F48971DF2088C1
          A60D6BF9BAB6849D0547D8FD520D2F3F5F822FD8C7AFCEEF58B16A11FEC82831
          3DC6A87F8868C488745C9D0C9AF5A8D2E51EF15BE72FD248B127E2F5FE8DE3FB
          FDEC28280755E1FDCFB691BF310B6FC48566C4C030F08D458984B40E4057837E
          ADAAA7CB87A0E2090EB2E491594C1A4DD45C2EC779AB0E53B287C4399384A353
          718288A8F4767B09F8F4F380069094BBDD7AB3E474869CB8B1428E5DCB90AAB6
          0DB2E59055B2B621C72EAF93134D99723C8EE3F79572A83A5336EEB439EF9A67
          990FA82A1071F7855EF9E35AC0D3EB0C010A9EF000799B56F1EEDBAFC7BF87D0
          0D411185BEEE30AD8DFE88AB2B501CF0C4FC5706DE34CC0D7F15E9AB53BF6A17
          784ED78C4AB72BF6803DDD82B6B013D5A420064CB875FABB628CB8A21DEEDBA1
          A2D6FAB11B8066480C7EE92F045000737CD6BCA736DFB77F7D616A63EE769BCC
          B0C326CF6E4D6D5B5D70FF47C9732CF700164099CE4D3373FCA76CAB43052CFF
          62065440001D884E130F19FC4FFF00FE20CB5D5DF1FFF30000000049454E44AE
          426082}
        FileName = 'Images\Actions\Apply_16x16.png'
        Keywords = 'Actions;Apply'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000023744558745469746C650043616E63656C3B53746F703B457869743B
          426172733B526962626F6E3B4C9696B20000038849444154785E1D906B4C5367
          18C7FF3DBD40CB1A2E32B55C9D598B4CA675D8D13836652E9B0359B67D589665
          3259E644A52571644474CB4CB6ECC23770C4449DD38D2885005E4683AB69C616
          8DA12384264EC8AAAC0C9149A1175ACEE9E939CFDE9EE7E477F2CBFFB924E720
          E6E943CC3B8895D12B00A0FEE3D08167A75A5BBAEEB71D9D081E6B4DA549FBDD
          A3CEEFDD1F3658016818AA98A71FD1915E202DE980A19D741E3EF6E0F8A7FC7F
          673B6979E002C5BC43B4C2581EB8480BE7BA68E6441BEF3B72F03300990C8E1D
          5016554E7B55D6C1ED9543C6C2B5BB739FDF025988838424E4240F10A0D2EAA0
          D26540AD37203CFE17C2C187A3EDBFDE7CF3DAD4748403A06EA8A8E830AC5FB3
          3B7BAB1901B717AE23DFE1CEC5EBEC90A0E0EB71A3CFD981C0B017C6F252180B
          D6BD74BCFA856E003A0CBDFD966DF250532AD4FF038DB734D18557DF21CFB08F
          2E37B5D370ED5E72D7D52BEEF9654CE9F91C1FD392EB0C4D3A0E4BE7F6ECD909
          CFDEFAD381AF4ED0A3D35FD399E272BA3F3D478F971234FD2044BDCE930AF798
          CF2FAED0DF5373CACCFCA92F2970B29DDCAFD7F56B48945E918201C41738945A
          2D581C7461ADA3192AB50AD64F9A010272730CC8D4AA313BE44289D58CF85D3F
          2411504BB28D93845489145E041F9CC1863C09A11BD7E1EFEA86240339463DB2
          B3F59025C0DFD98DD0C83594E6886C360831F408523265D208BC0021B20A35A7
          82B8BC0429C2239A10D812417988007088B14C8A8421EA75A094044A8A48F200
          17E78587629220B370E69F2884EA3750F07E23245946868E43A64EA3B8695F23
          F8EA7A046763EC780AC9640AF155FEB1269AE0BD91AC8CFDF910108E26F15A5B
          33788D1E860CF6CDE7CF225D45FB3F02A0C7CE36076E5CBD84825C3562A20E4B
          097E0CAD051B5FFCA97C9BE4ABAEA05B2FDBE9E6BE0F880F8568FCDB0E1AA9AA
          646C579C654AEF564D15FDB96333FDBCC94A8E751B6A0140DF5168B9E42A7B86
          266AB6D2ED1A1BF559CAC853B58DFCB576F2D7D9D3AE64B777D96862D716EA2F
          2BA76F4CE62B008C1A00C2F9C57F9D8DA2C99212C5E72C85323699F320A77FD2
          72040021DF9885F56BF2204457706F9EC74C4CF2F744169A012430DBF21E00A8
          2B754F98BEC82EEEED7AF2291A306FA451EBD3346633938FF13BF341969D62BD
          CF738AAF6ED6EA4B006882CE77A14ABFD255D2799903606830E4EF28E274070C
          1C67D74255041044C25C9CE43B4149F8B16735F41B8038DB9300E07F6924ECFB
          01D589CC0000000049454E44AE426082}
        FileName = 'Images\Actions\Cancel_16x16.png'
        Keywords = 'Actions;Cancel'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000027744558745469746C6500526566726573683B5265706561743B4261
          72733B526962626F6E3B52656C6F6164CD4DF6E90000030249444154785EA593
          6D4C926B18C76F018114A40D6D619DE98433AAE3F16D7CB173AC43666FE69C7A
          D4F48825339D4E6136D314EB2C23B46C332B957484A0522E5B6E2C31B537B437
          319BCECC17B2652D672FC715E03194AEEE875A6BB53E796DBFDDCF7EF7FFFFE1
          DAB3DB0500D052C6E5A7FEC73B70F2FDC89A4D48D664FA5A5AF5DB1FE4E8928B
          E2226D9F11FB0F04459A7B3D052A63DE0E71B11B91C10E77FA9D5D94DF70DF59
          4E93EB7EC957DF1B4F935FE009B3EBB7A59FE8704C59E6E185E503DC9D7C0B9A
          5B66D8A7BA33243AD4E087F3A4E9F98F683FD1959EBD8BF0B8E6D418BB1F3C9B
          855DA57A23871BC00C15D755FD99D508E1521DE49EB90E833356B8D4F71C726A
          7A460285F11EC48A92CF5D44D973CC50A8BDF504C6FE7780F2CA3044481AFEF5
          FE3598C1DD24F5E10A73F88109958A8DD94DF69E171638D53E0AA2A36D07885E
          E6E95E8476E6D5090AD57D0B66DB02F45B1661DC6A87B4B2F685E0D8C3422284
          21619605FC5DA148ADE884F303D3905C6630112EF5C40D449AB550D5BDBDA314
          D9C99BC862B52379ED6DF478E215C595B9AAFE4B9918D2CC4857CBE4F834A22D
          672287831C881D4B9B2F74232EE918CFA81283FDDA4B1B241CE9062F7E441076
          0C0C19438B2CD63F8A3AD8017187BB4033F61E88EFA8920E882CD24F92F8D1D5
          F3383467B3D846269EFE877CBC5928707372CAB7FFFFF9F01D890783BE98951E
          8628542ACACDDC88ACAF5E3B4C8656090ACBBD4C846802514DE9DEDAFBD038F4
          06E28F742F083395C7F91B44416BFEDACDA731BD38214995E519AA01A837CF41
          A2A213BC422455B8C744828C56E78E8C956B3921E226739666109A47DE81E4DC
          0024286E424CE935F83DA95A87337E41A92A93ECEA14B043F63F2451591CE78A
          01BB5B50DB14B105725D199C28F0FF47FD24EEF86D28D19B4139340BCAC15908
          2F6807DFF042317BCD9650FF14ED33EA8AB0F5384F65AC2B40889FD48CD1394F
          42D2D9BCD53E5BE515BC98DA21EC017BE0C52A877DB797CBC8547716CE786068
          74AE1411E0F90132C61DC3C67030DE18CF2F8EFC7D78C9CFF9136643522887EA
          10230000000049454E44AE426082}
        FileName = 'Images\Actions\Refresh_16x16.png'
        Keywords = 'Actions;Refresh'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002D744558745469746C650044423B536F757263653B53746F723B6461
          7461736F757263653B44617461626173653B4564697428F6BA9C000002CB4944
          4154785E85937F48935B1C875F5BD7E59C3F0A6E7F5C1542826B21977185F08F
          CA689933572A3A912B52846228AC5B570B0C6A4C19C950732A0C5774AF190B26
          944DCBED4E3653376992F86366C31F77375CE69C7935AEE8749FCE79D9FEC8B2
          BEF0F9EF3CCFF77CCF97C3900A21E198EB7372FA5592066BA3A4D3AACA19B736
          E4A2AF3E7BDCACCCECFA5B215675CA44B9E4DC6E7A1E00130C2D8EAD29AFC7A9
          97C3FDB215DE8927587519E1FF308815A70E0BF666B84C728CB496C0284FEFA3
          92ED821F6C8DB9C0C63CB03E07ACCDC2FF7112FE9561F897ACD8F2F460735E0F
          DF9C0E46591A2542B70B42FBEBB2E1231DB1F13E20992692096C2EDBF1F18D0E
          5E5B3DBC966B787E434809EE7601F7853213EB0B06F896C788C0830D771BFE73
          48F1CEF41B4695420C57A7C0DD9E0FABFA32257881B7E004DE8FD9635188BF2B
          F0586418EFD2A05B965463BEF52BDAA58714747C2A08335589BE2970FE258577
          E411065B8A31FB341B5BFE69BCD68AD194157B9B15186E9EDE5130A5BD02578F
          0663DA524C3F3EC7C2BE99320C5426A056F823A880F7AC52F855C1E2901CFF9A
          EF62E85E119CBA0C165E7314A1B7FC207A9547512E88A8A382707D45CA1782D5
          99062C4C686127F0E443110BAFD80B61961E80A92A19D244FE1DDA9C15745C3D
          FAB9C063C0F2DB0E0C6B2FC1715FC8C28B16094CA57178762309253FF35484E3
          93EC62B7D05672A47BA0F922662D77B13465C3FAD22B8CF66B6055A6B2B0BBF3
          2C8C2531E8F8E3175C88DFA3264C04850BF6936D062CE1B57989C59A4281FECF
          F302875DD7B45571A50AFA1605FE7F6B83A13806BAB20414C4715B08104D997F
          B4A98C641F8709564860A7BC803D4670EADACCA8AD1B0F6AAEA3FA443CF27F0A
          550761A7E638E3D41C63B2A20806E08B908A8C8E1122627FB22B2CFAB03A3692
          7F3238B3981FC2D0648433CC193EB3A3800E1745B2978E17FCC6E9E47EA23086
          4923A192DFE3B9CC27707A3E75A45EF6F60000000049454E44AE426082}
        FileName = 'Images\Data\EditDataSource_16x16.png'
        Keywords = 'Data;EditDataSource'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C0000001B744558745469746C65004D6F64656C3B436F70793B43
          6F70794D6F64656C3B892D59CB0000023849444154785E85D04B685D651486E1
          E7DF7BF79CD3D6548B8338CAC8CBBC4E2452E2A514051147223AAE5010AA139D
          8AD116412D360345080A924127B60E6AD28A62EA95A21369AD974A03A618B56A
          20F1E4649FBDFFA59889A1015F58D38F8755450480919191F2C86BF31F14294D
          84842C070111024D5D7FFCEC93FBF7ADACACD450D95C1162E2E0A37B10202080
          C0AB6F7DB917254095FE090552B7DBED8CDD749DBA5EB73668410E522A9455A9
          D72DB54D0B09A04271F8F5CF37D8915CFCF14FDF5CFA5D280422B2D1DD3D0FDD
          779B6E67BBA6DD6220A29D78FAF13B11B0891E989CFA44D33422423DCCD70852
          DB40E86FB0850422D3EDA67FD96D1B72D85290FA83A140FBDF8F47809C0B7F0D
          86EA8D1175DD6C256808720E91109429294B52E2DEF13123DB3BCA22DC75C798
          A9B6DD9652AA10158AB5412D07C3361022A83A85E5F9F7F43F3BE3562C7FC4CF
          9D5FECEE2EF9F0B93D57370BDA8C902374CAA42A19368DFEA767DC72CF38185C
          B9E2E4DCAC47A68E8095C54B4EBD38AD82619B451011CAA270E2EC0F66CFFD44
          F52067D975FDFB76DD709A7D3B7DF5EEF3E0A9D1DB410579980576F62A45B466
          E6CE9B7CE161B070F937C7670E387C68127C7F79C14B6F4C330A5468D7EBFEFC
          81674E4E84F0C0DD3783535FFC0A16BF5B00B317A6C1C5AF97C18963A7ADD6F9
          E50AF5CCB1C7EEC736A4B75FD1DB7FE8F892FFE989D9A51BB15A4544C6DAC691
          525A5FBEFA87B937DF01B0A337307DF45B00F55A3E8A55D4956BABCFCD1CDC81
          1200090081211AF81B46C61F74A3585C150000000049454E44AE426082}
        FileName = 'Images\Data\CopyModelDifferences_16x16.png'
        Keywords = 'Data;CopyModelDifferences'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000F744558745469746C65004E6F74653B54657874D1F89A4D00000232
          49444154785EA591CD4B156114879F3333F763EE47A586646569044260B98808
          325C18148651B8095A45D0A24DED5BB6AAA05DB42808FA07C2A042EA22641F64
          2415292582D026B145E9ED7E78E7BEEFE93A776671C55D3F38735ECE99F3CCEF
          BCE3A92AFF234F1A021C40A2E0E0C895E4DEC367AE5B712F4B229B0F82DA9F72
          F1F7C5A93BE75ED294058C36E401CEF4BDB182E3CA9028284AA1D8C39C97A54A
          9ED3473B09EAA6F3D1E30F4FDFDF3D8B88432D30538357C78781C0035CC76168
          60F43CA8052CB7EEFB9C38798089D78BB802DF974B94CA01DBFBFAE9EEED62E6
          D9C471C08B01A2464195DAD78728502C5E2030864C5B1B0F9ECC51AD5428FD5A
          E0E7C7E7EC6A1F24BA3721A288B596B0E62643D0F0CE6F145EE4C8F5F4D3D1BD
          9B85E94906BC4F54D7A05E176CDD6E042808E026C27469609EC5F115DECECE10
          AC55E84BFD60A46B9E7436D70018ACB1000E3140C382205E0A05D2C08DD16566
          3F7F6169E92F6A2DF92D19B675E45171316693154225D2080A809F4871E8482F
          FB4B358AAB15829AC1CF2431564207AD00A3200E783E0268D44D7A8A9BCAE0E7
          F2D48DC51A83E3A5D7730BC0693A7090D881086813E326C0492929AB185D0766
          894C4ACB1D88E7E3F81DC40A41B19FE8E92248622BBA7105AD2B7859C4DFB1E9
          3008A2D167BD1CD66ACB5FC0580B8D8664F74573DA0C51203A139F85F63DBDC0
          243120582D076F0A37AF1D0389DE8D07435A93873679C04A257807ACC580EAD8
          ED57A780142051C4125A15EF55052A00FF0033C70420B6E7BAAB000000004945
          4E44AE426082}
        FileName = 'Images\Content\Notes_16x16.png'
        Keywords = 'Content;Notes'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002E744558745469746C650047726F75703B4669656C643B436F6C6C65
          6374696F6E3B437573746F6D697A3B53657474696E67737CF8E99E0000026049
          444154785E7D924D4854511886DF73E78CA316FDDAAA7D149441663458E354B6
          749389D2A295A2C940B6AE45D1AE3F5121C14594A043191191B4B291EC07940A
          AA456D2A70A0FC9B306C6EF7FC7CA7CEB9339A48BE977B5FCEC7FDDE73BEFB5C
          668CC1A5F43B5C3CB53772FEF6EB5130AF968C81AD13151D2043D0523DEB49D5
          1C33C62814C4AD0949D63C45A83D7D7237C200DB041750F45B436F1300220056
          0648E1D64C48055F687C9EF661C21027632F5A7ACF83D58A80F0044C0A83BC20
          94D8AAF1608ACD602E502882D5AA80200C20DFF79F0EA4DF1C75BB93FB066108
          11B40194F89D01A0DBBAC6C2117561B6966BE3C5A395002803B00EC006009B00
          6C06B0C579582B07100310B53D8EC2BFEAE81947DFD9046FBD3A6A89244212AB
          8928219EDFBD5C5FC71963B04A26934C4AE9A8C46231AE34129DED35CB440ACD
          BAB0EEEACD1C02C0793C1EE7D168941111DF51D598B7F366B3D96DE7FEE2DCCE
          09BE6678F4696125116D89484784EFAC6E923FE6E7C688F454FDF1FD6EA7E9EF
          0DBDFDFDC3F8F2358BBEBE0B288F460A44A84864891C17814067AA29393B9BC3
          81EA5D6E562555F3D68A8DB8DE9DC6DCCC021E0C4E82F4321132800CF2E30014
          CFCD4C358F3C7931D4D17AC2BBD235E8D253ED8DB8D97FDF2CFEFCD65657B3E7
          612E979308C5427359B61670A5B5479AD8AF7C8048C473FC17F381731E890595
          95950B994C46E03FF2C04A878E24AAD8AB89F738D3DAE0EE89C90FA83DBC8F19
          AFF48ED63A8635C4B556B8D13DF0928C9E9742D55BC6C3C3238F8DF12A0CF30E
          1211D612F7E727D773CE1980B2F43D6F0656F98F2DF6A994B2FF848F35F40750
          7F89538840F6FC0000000049454E44AE426082}
        FileName = 'Images\Reports\GroupFieldCollection_16x16.png'
        Keywords = 'Reports;GroupFieldCollection'
      end>
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
        Visible = True
        ItemName = 'dxBarEditCtrlCaption'
      end
      item
        Visible = True
        ItemName = 'dxBarSpinEditCtrlSize'
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
