inherited FrameEditor_DataModule: TFrameEditor_DataModule
  AlignWithMargins = True
  Width = 1110
  Height = 615
  ExplicitWidth = 1110
  ExplicitHeight = 615
  object cxSplitterInspector: TcxSplitter
    Left = 306
    Top = 25
    Width = 4
    Height = 590
    Control = pnlLeft
  end
  object cxSplitterMetadata: TcxSplitter
    Left = 767
    Top = 25
    Width = 4
    Height = 590
    AlignSplitter = salRight
    Control = pnlMetadata
  end
  object pnlMetadata: TPanel
    AlignWithMargins = True
    Left = 774
    Top = 28
    Width = 333
    Height = 584
    Align = alRight
    BevelOuter = bvNone
    Caption = ' '
    ShowCaption = False
    TabOrder = 2
    object MetaTree: TcxTreeView
      Left = 0
      Top = 27
      Width = 333
      Height = 557
      Align = alClient
      DragMode = dmAutomatic
      TabOrder = 0
      OnDblClick = MetaTreeDblClick
      OnKeyPress = MetaTreeKeyPress
      Images = imagesTreeView
      MultiSelect = True
      MultiSelectStyle = [msControlSelect, msShiftSelect]
      ReadOnly = True
    end
    object edSearch: TcxButtonEdit
      AlignWithMargins = True
      Left = 3
      Top = 3
      Align = alTop
      Properties.Buttons = <
        item
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424DC2010000000000003600000028000000090000000B000000010020000000
            000000000000C40E0000C40E00000000000000000000FAFBFB00F6F9F9FFF6F9
            F9FFF6F9F9FFF5F8F8FFF5F8F8FFF5F8F8FFF5F8F8FFF9FBFBFFF1F4F5FFE8EE
            EFFFE8EEEFFFE8EEEFFFE5EDEDFFE5EDEDFFE5ECEDFFE5ECEDFFEFF3F4FFF1F4
            F5FFE8EEEFFFE8EEEFFFE8EEEFFFAABCF2FFE5EDEDFFE5ECEDFFE5ECEDFFEFF3
            F4FFF1F4F5FF044FF5FF91C4FFFF044FF5FF044FF5FFBECCF1FF044FF5FFE5EC
            EDFFEFF3F4FFF1F4F5FF71A3FFFF194FFFFF044FF5FF044FF5FF2E59FCFF7995
            F6FFE8EEEEFFF1F4F4FFF1F4F5FF044FF5FF044FF5FF43C0FEFF49CEFFFF044F
            F5FF044FF5FFE8EEEEFFF1F4F4FFF1F4F5FF044FF5FF044FF5FF79EAFFFF73F0
            FEFF044FF5FF044FF5FFE8EEEEFFF1F4F4FFF1F4F5FFE8EEEFFF044FF5FF1285
            FEFF168AFEFF1A54FDFF99B1F3FFE8EEEEFFF1F4F4FFF1F4F5FF044FF5FF657F
            F8FF044FF5FF044FF5FF738EF7FF044FF5FFE8EEEEFFF1F4F4FFF1F4F5FFE8EE
            EFFFE4EBF0FF044FF5FF044FF5FFE5ECEFFFE8EEEFFFE8EEEEFFF1F4F4FFF6F8
            F9FFF1F5F5FFF1F5F5FFEFF4F6FFEFF3F5FFF1F4F4FFF1F4F4FFF1F4F4FFF6F8
            F8FF}
          Kind = bkGlyph
        end>
      Properties.OnButtonClick = edSearchPropertiesButtonClick
      Properties.OnChange = edSearchPropertiesChange
      TabOrder = 1
      Width = 327
    end
  end
  object pnlLeft: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 28
    Width = 300
    Height = 584
    Align = alLeft
    BevelOuter = bvNone
    Caption = ' '
    ShowCaption = False
    TabOrder = 3
    object FrameObjectInspector: TFrameObjectInspector
      AlignWithMargins = True
      Left = 3
      Top = 281
      Width = 294
      Height = 300
      Align = alBottom
      TabOrder = 0
    end
    object cxSplitter: TcxSplitter
      Left = 0
      Top = 270
      Width = 300
      Height = 8
      AlignSplitter = salBottom
    end
    object pnlTreeMenu: TPanel
      Left = 0
      Top = 0
      Width = 300
      Height = 270
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
    end
  end
  object tree: TcxTreeList
    AlignWithMargins = True
    Left = 313
    Top = 28
    Width = 451
    Height = 584
    Align = alClient
    Bands = <
      item
        Caption.Text = 'Dataset'
      end
      item
        Caption.Text = 'Controls'
      end
      item
        Caption.Text = 'Report'
      end>
    DragMode = dmAutomatic
    FindPanel.Behavior = fcbFilter
    FindPanel.DisplayMode = fpdmAlways
    FindPanel.FocusContentOnApplyFilter = True
    FindPanel.Layout = fplCompact
    Images = treeImages24
    OptionsBehavior.ChangeDelay = 1000
    OptionsBehavior.DragDropText = True
    OptionsBehavior.DragFocusing = True
    OptionsCustomizing.BandCustomizing = False
    OptionsCustomizing.BandMoving = False
    OptionsCustomizing.ColumnFiltering = bTrue
    OptionsCustomizing.ColumnMoving = False
    OptionsSelection.HideFocusRect = False
    OptionsSelection.InvertSelect = False
    OptionsView.Bands = True
    OptionsView.DropNodeIndicator = True
    OptionsView.DynamicIndent = True
    OptionsView.Indicator = True
    OptionsView.IndicatorWidth = 18
    PopupMenu = PopupMenu
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 4
    OnDblClick = treeDblClick
    OnDragDrop = treeDragDrop
    OnDragOver = treeDragOver
    OnEdited = treeEdited
    OnEndDrag = treeEndDrag
    OnFocusedNodeChanged = treeFocusedNodeChanged
    OnGetDragDropText = treeGetDragDropText
    OnGetNodeImageIndex = treeGetNodeImageIndex
    object colName: TcxTreeListColumn
      PropertiesClassName = 'TcxTextEditProperties'
      Properties.OnEditValueChanged = colNamePropertiesEditValueChanged
      Caption.Text = 'Name'
      MinWidth = 200
      Width = 200
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
    end
    object colGroup: TcxTreeListColumn
      Caption.Text = 'Group'
      MinWidth = 150
      Width = 150
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
    end
    object colCaption: TcxTreeListColumn
      Caption.Text = 'Caption'
      MinWidth = 150
      Width = 150
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 0
    end
    object colVisible: TcxTreeListColumn
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = colVisiblePropertiesEditValueChanged
      Caption.Text = 'Visible'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 3
      Position.RowIndex = 0
      Position.BandIndex = 0
    end
    object colLookup: TcxTreeListColumn
      PropertiesClassName = 'TcxCheckBoxProperties'
      Caption.Text = 'Lookup'
      Position.ColIndex = 4
      Position.RowIndex = 0
      Position.BandIndex = 0
    end
    object colViews: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'View'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colCards: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Card'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colCubes: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Cubi'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colFileViewers: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Pdf'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 3
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colGoogleMaps: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Map'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 4
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colRecordViews: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Record'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 5
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colTrees: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Albero'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 6
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colCharts: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Grafico'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 7
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colSchedulers: TcxTreeListColumn
      PropertiesClassName = 'TcxButtonEditProperties'
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = colPropertiesButtonClick
      Caption.Text = 'Calend.'
      MinWidth = 50
      Width = 50
      Position.ColIndex = 8
      Position.RowIndex = 0
      Position.BandIndex = 1
    end
    object colReportGroup: TcxTreeListColumn
      Caption.Text = 'Report Group'
      MinWidth = 150
      Width = 150
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 2
    end
    object colPipeName: TcxTreeListColumn
      Caption.Text = 'PipeName'
      MinWidth = 150
      Width = 150
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 2
    end
    object colSharedReports: TcxTreeListColumn
      PropertiesClassName = 'TcxBlobEditProperties'
      Properties.BlobEditKind = bekMemo
      Properties.BlobPaintStyle = bpsText
      Caption.Text = 'Shared Reports'
      MinWidth = 150
      Width = 150
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 2
    end
  end
  object pnlSposta: TPanel
    Left = 344
    Top = 131
    Width = 225
    Height = 265
    ShowCaption = False
    TabOrder = 9
    Visible = False
    OnMouseDown = pnlSpostaMouseDown
    OnMouseMove = pnlSpostaMouseMove
    OnMouseUp = pnlSpostaMouseUp
    DesignSize = (
      225
      265)
    object cxButton1: TcxButton
      Left = 144
      Top = 235
      Width = 75
      Height = 25
      Action = Sposta
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object treeSposta: TcxTreeView
      AlignWithMargins = True
      Left = 2
      Top = 2
      Width = 221
      Height = 227
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 35
      Align = alClient
      TabOrder = 1
      OnDblClick = treeSpostaDblClick
      Images = treeImages16
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 424
    Top = 96
    object NuovoDataSet: TAction
      Caption = 'Nuovo DataSet'
      ImageIndex = 48
      ShortCut = 24621
      OnExecute = NuovoDataSetExecute
    end
    object ModificaDataSet: TAction
      Caption = 'Modifica DataSet'
      ImageIndex = 79
      ShortCut = 16397
      OnExecute = ModificaDataSetExecute
    end
    object EliminaDataSet: TAction
      Caption = 'Elimina DataSet'
      ImageIndex = 69
      ShortCut = 24622
      OnExecute = EliminaDataSetExecute
    end
    object Metadata: TAction
      AutoCheck = True
      Caption = 'Metadata'
      ImageIndex = 185
      ShortCut = 123
      OnExecute = MetadataExecute
    end
    object DFM_CaricaDaFile: TdxFileOpen
      Caption = 'Carica da file dfm'
      Dialog.DefaultExt = '*.dfm'
      Dialog.Filter = 'DFM|*.dfm|Tutti|*.*'
      Hint = 'Open|Opens an existing file'
      ImageIndex = 23
      ShortCut = 16463
      OnAccept = DFM_CaricaDaFileAccept
    end
    object DFM_SalvaSuFile: TdxFileSaveAs
      Caption = 'Salva su file dfm'
      Dialog.DefaultExt = '*.dfm'
      Dialog.Filter = 'DFM|*.dfm|Tutti|*.*'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 9
      OnAccept = DFM_SalvaSuFileAccept
    end
    object CopiaNomiDataSet: TAction
      Caption = 'Copia Nomi DataSet'
      ImageIndex = 42
      OnExecute = CopiaNomiDataSetExecute
    end
    object CaricaDaClipboard: TAction
      Caption = 'Carica Da Clipboard'
      ImageIndex = 85
      OnExecute = CaricaDaClipboardExecute
    end
    object ApplicaCaption: TAction
      Caption = 'Applica Caption'
      ImageIndex = 55
      OnExecute = ApplicaCaptionExecute
    end
    object ApplicaBorderStyle: TAction
      Caption = 'Applica BorderStyle'
      ImageIndex = 249
      OnExecute = ApplicaBorderStyleExecute
    end
    object BuildGUI: TAction
      AutoCheck = True
      Caption = 'Build GUI'
      ImageIndex = 515
      OnExecute = BuildGUIExecute
    end
    object Ripulisci: TAction
      Caption = 'Ripulisci'
      ImageIndex = 86
      OnExecute = RipulisciExecute
    end
    object SolaLettura: TAction
      Caption = 'Sola Lettura'
      ImageIndex = 496
      OnExecute = SolaLetturaExecute
    end
    object Modificabile: TAction
      Caption = 'Modificabile'
      ImageIndex = 17
      OnExecute = ModificabileExecute
    end
    object SpostaInAlto: TAction
      Caption = 'Sposta In Alto'
      ImageIndex = 134
      ShortCut = 16422
      OnExecute = SpostaInAltoExecute
    end
    object SpostaInBasso: TAction
      Caption = 'Sposta In Basso'
      ImageIndex = 130
      ShortCut = 16424
      OnExecute = SpostaInBassoExecute
    end
    object MuoviAllaRadice: TAction
      Caption = 'Muovi Alla Radice'
      ImageIndex = 132
      ShortCut = 24658
      OnExecute = MuoviAllaRadiceExecute
    end
    object Sposta: TAction
      Caption = 'Sposta'
      ImageIndex = 160
      OnExecute = SpostaExecute
    end
    object Proprieta: TAction
      Caption = 'Propriet'#224
      ImageIndex = 512
      OnExecute = ProprietaExecute
    end
    object Copia: TAction
      Caption = 'Copia'
      ImageIndex = 64
      OnExecute = CopiaExecute
    end
    object Incolla: TAction
      Caption = 'Incolla'
      ImageIndex = 85
      OnExecute = IncollaExecute
    end
    object CaricaDaFile: TdxFileOpen
      Caption = 'Carica'
      Dialog.DefaultExt = '.json'
      Dialog.Filter = 'json|*.json|tutti|*.*'
      ImageIndex = 178
      OnAccept = CaricaDaFileAccept
    end
    object SalvaSuFile: TdxFileSaveAs
      Caption = 'Salva'
      Dialog.DefaultExt = '.json'
      Dialog.Filter = 'json|*.json|tutti|*.*'
      ImageIndex = 92
      OnAccept = SalvaSuFileAccept
    end
    object ResetLayout: TAction
      Caption = 'Reset Layout'
      ImageIndex = 69
      OnExecute = ResetLayoutExecute
    end
    object VerificaSQL: TAction
      Caption = 'Verifica SQL'
      ImageIndex = 13
      OnExecute = VerificaSQLExecute
    end
  end
  object imagesTreeView: TImageList
    DrawingStyle = dsTransparent
    Left = 64
    Top = 56
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000E80AA000E80
      AA000E80AA000E80AA000E80AA00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000E80AA000E80
      AA000E80AA000E80AA000E80AA00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000993300009933
      0000993300000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000E80AA0061DDEE0031E2
      FF0047E3FF0093F1FF003AB7DD000E80AA00B7818300A4787400A4787400A478
      7400A4787400A4787400A4787400A4787400A4787400078DBB0061DDEE0031E2
      FF0047E3FF0093F1FF003AB7DD000E80AA000000000000000000000000000E80
      AA000E80AA000E80AA000E80AA006E4C35007D4D2B00AD480200AC4A0A00F9B7
      5A00D28844009933000099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A0502700944A2400944A2400944A
      2400944A2400944A2400944A2400944A2400944A24000E80AA007EF9FF0023D9
      FE0037DAFF0083E8FC0030B7E0000E80AA00B7818300F6E4C900F5E1C200F4DE
      BC00F4DEBC00F1D8AF00F2D6AD00F2D6AD00F0D2A400078DBB007EF9FF0023D9
      FE0037DAFF0083E8FC0030B7E0000E80AA000000000000000000078DBB0049D5
      EE0023D7FE0036D9FE006FE6FF009F451000B04D0800FFA11300FFA51D00FFB3
      4000FFC16300FFCF850099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080402000FEF4E900FEF0E100FEEC
      D7000019CC00FEE4C700FEE4C700FEDDB900FEDDB9000E80AA00B6F9FD00B2EF
      FC00CDF3FD00D5F5FC0097DAEF000E80AA00B4817600F7E8D000F6E4C900F5E1
      C200F4DEBC00F4DEBC00F1D8AF00F1D8AF00F2D6AD00078DBB00B6F9FD00B2EF
      FC00CDF3FD00D5F5FC0097DAEF000E80AA0000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE0072DBEF00A0521F00A9460800FFB34000DF7E0D00B251
      0B00C56C2200FFC1630099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080402000FEF8F200FEF4E900FEF0
      E1000019CC00FEECD700FEE4C700FEE4C700FEDDB9000E80AA007CCCE0002FAC
      D000219CC40046ABCC0064B3D2000E80AA00B4817600F8ECD600F8ECD6000066
      00000066000000660000F4DEBC000066000000660000078DBB007CCCE0002FAC
      D000219CC40046ABCC0064B3D2000E80AA0000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE009E623000AC4A0A00E6B48300FFCC7E00835734009933
      00009F390000EC9E3C00F2B05900993300000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000804020000019CC000019CC000019
      CC000019CC000019CC000019CC000019CC000019CC000E80AA0055D0E3002ED6
      F60045DFFE0084E4F6002FACD0000E80AA00BA8E8500F9EEDD00F9EEDD001693
      2C0032D9650000660000F5E1C20016932C0032D96500078DBB0055D0E3002ED6
      F60045DFFE0084E4F6002FACD0000E80AA0000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE009E623000B2510B00ECC19300FFDFAD00835B3F009933
      0000A6400000EC932000F9AE4400993300000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080402000FEFEFD00FEFEFD00FEF8
      F2000019CC00FEF0E100FEEFDE00FEECD700FEE7CD000E80AA007EF7FE0028D9
      FE003ED9FF0088E7FC0035B8DF000E80AA00BA8E8500FAF2E500F9EEDD001693
      2C0016932C0016932C00F6E4C90016932C0016932C00078DBB007EF7FE0028D9
      FE003ED9FF0088E7FC0035B8DF000E80AA0000000000078DBB00B3FCFE00B6F6
      FF00C6F5FF00E3FAFF00E6EEEF00BD662100BA580B00FFE2B500ECC08F00B55D
      2200CC721E00FF9F0E0099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F401F00FEFEFD00FEFEFD00FEFE
      FD000019CC00FEF8F200FEF4E900FEF0E100FEECD7000E80AA0099FDFF006DFB
      FF0081FFFF00AAFDFF0050D1F3000E80AA00CB9A8200FBF6EC00FBF6EC00FAF2
      E500007F0000F9EEDD00F8ECD600F6E4C900007F0000088CB90099FDFF006DFB
      FF0081FFFF00AAFDFF0050D1F3000E80AA0000000000078DBB00BAEEF60030BC
      DD0011A7D200129FCB0020A2CB00B2590D00C56C2200FFE2B500FFE2B500FFDC
      A700FFC66F00FFAC300099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F401F00FEFEFD00FEFEFD00FEFE
      FD000019CC00FEFEFD00FEF7F000FEF4E900FEF0E1000E80AA00D0F0F700FEFE
      FD00D9FFFF00CCFFFF0099FDFF000E80AA00CB9A8200FCF9F200FBF6EC00FBF6
      EC00007F0000007F0000007F0000007F0000007F0000078DBB00D0F0F700FEFE
      FE00D9FFFF00CCFFFF0099FDFF000E80AA0000000000078DBB004AC5DD0059EA
      FE0023D7FE0036D9FE006FE6FF00A2794E00926844009D4E2200BD662100F9D7
      AA00993300009933000099330000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000804020000019CC000019CC000019
      CC000019CC000019CC000019CC000019CC000019CC000019CC000E80AA000E80
      AA000E80AA000E80AA000E80AA0000000000DCA88700FEFEFE00FCF9F200FBF6
      EC00FBF6EC00FAF2E500007F0000F9EEDD00F8ECD600F8ECD600078DBB00078D
      BB00078DBB00088CB900088CB9000000000000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE006FE6FF008DE7FA0049C1E300357C8E00B34D00009933
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F3F1F00FEFEFD00FEFEFD00FEFE
      FD000019CC00FEFEFD00FEFEFD00FEFEFD00FEF8F2000019CC00FEF4E900FEEF
      DE00FEECD700FEE7CD008E47220000000000DCA88700FEFEFE00FCF9F200FEFE
      FE00FCF9F2000A14B1000618BB000B0EA700F9EEDD00F8ECD600F7E8D000F6E4
      C900986B660000000000000000000000000000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE006FE6FF008DE7FA0049C1E300089DCF000E80AA000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080402000E4E4E400E4E4E400E4E4
      E4000019CC00E4E4E400E4E4E400E4E4E400E4E4E4000019CC00E4E4E400E4E0
      DC00E4DED600E4DACF00944D290000000000E3B18E00FEFEFE00FEFEFE00FEFE
      FE00FCF9F2000B3EFF002867FF000C1DBF00FAF2E500FAF2E500F9EEDD00F8EC
      D600986B660000000000000000000000000000000000078DBB008CFBFE0059EA
      FE0023D7FE0036D9FE006FE6FF008DE7FA0049C1E300089DCF000E80AA000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000AE5C2700AE612200AE5C2700AD5F
      2000AD5F2000AE5C2700AD5F2000AD5F2000AE5C2700AD5F2000AD5F2000AE61
      2200AE5C2700AE6122008F48230000000000E3B18E00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00243AC9000B3EFF000A14B100FBF6EC00FAF2E500FAF2E500F9EE
      DD00986B660000000000000000000000000000000000078DBB0091FCFE0082F8
      FF006FF8FF007AFEFF0091FCFE00A0FCFE0063DAF5000DA2D4000E80AA000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000AE5C2700EE973300EE973300EE97
      3300EE973300EE973300EE973300EE973300EE973300EE973300EE973300EE97
      3300EE973300EE973300B95D190000000000EDBD9200FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FCF9F200FCF9F200FBF6EC00FAF2E500FAF2
      E500986B660000000000000000000000000000000000078DBB00FCFFFF00F4FF
      FF00D3FFFF00B3FCFE00B3FCFE00ADFFFF00ADFFFF006FF8FF000E80AA000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CC731900CC731900CC73
      1900CC731900CC731900CC731900CC731900CC731900CC731900CC731900CC73
      1900CC731900CC7319000000000000000000EDBD9200FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FCF9F200FCF9F200FDF7F000FBF6
      EC00986B660000000000000000000000000000000000000000000C92C000F4FF
      FF00E3FAFF00C7FFFF00ADFFFF00A0FCFE009BFBFC001385AF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EDBD9200DAA48200DAA48200DAA4
      8200DAA48200DAA48200DAA48200DAA48200DAA48200DAA48200DAA48200DAA4
      8200986B6600000000000000000000000000000000000000000000000000078D
      BB00078DBB00078DBB00078DBB00078DBB00078DBB0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFC1FFC1FFC70000FF800000E0010000
      00000000C0010000000000008001000000000000800000000000000080000000
      00000000800100000000000080010000000000008001000000010001800F0000
      00010007801F000000010007801F000000010007801F000000010007801F0000
      80030007C03F0000FFFF0007E07F000000000000000000000000000000000000
      000000000000}
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default'
      'PopupMenu')
    Categories.ItemsVisibles = (
      2
      2)
    Categories.Visibles = (
      True
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <
      item
      end>
    UseSystemFont = True
    Left = 224
    Top = 136
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      25
      0)
    object dxBarManagerBar: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'Custom 1'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 411
      FloatTop = 116
      FloatClientWidth = 51
      FloatClientHeight = 22
      IsMainMenu = True
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem1'
        end>
      MultiLine = True
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = True
    end
    object dxBarButton2: TdxBarButton
      Action = NuovoDataSet
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = ModificaDataSet
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = Metadata
      Category = 0
      AllowAllUp = True
      ButtonStyle = bsChecked
      PaintStyle = psCaptionGlyph
    end
    object dxBarButton17: TdxBarButton
      Caption = 'Lazy Create'
      Category = 0
      Visible = ivAlways
      ButtonStyle = bsChecked
      ImageIndex = 216
      PaintStyle = psCaptionGlyph
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'Sola Lettura'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarButton4'
        end>
    end
    object dxBarButton1: TdxBarButton
      Action = SolaLettura
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = Modificabile
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = SpostaInAlto
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = SpostaInBasso
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = MuoviAllaRadice
      Category = 0
    end
    object cxBarEditItemSposta: TcxBarEditItem
      Caption = 'Sposta'
      Category = 0
      Hint = 'Sposta'
      Visible = ivAlways
      PropertiesClassName = 'TcxPopupEditProperties'
      Properties.PopupControl = pnlSposta
      Properties.OnInitPopup = cxBarEditItemSpostaPropertiesInitPopup
    end
    object dxBarButton8: TdxBarButton
      Action = Proprieta
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = Copia
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = Incolla
      Category = 0
    end
    object dxBarSubItem2: TdxBarSubItem
      Caption = 'Struttura'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButton9'
        end
        item
          Visible = True
          ItemName = 'dxBarButton11'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          Visible = True
          ItemName = 'dxBarButton13'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton14'
        end>
    end
    object dxBarButton12: TdxBarButton
      Action = CaricaDaFile
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = SalvaSuFile
      Category = 0
    end
    object dxBarButton14: TdxBarButton
      Action = ResetLayout
      Category = 0
    end
    object dxBarButton15: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton16: TdxBarButton
      Action = VerificaSQL
      Category = 0
    end
    object Apri1: TdxBarButton
      Action = ModificaDataSet
      Category = 1
    end
    object Add1: TdxBarButton
      Action = NuovoDataSet
      Category = 1
    end
    object SubMenuFK: TdxBarSubItem
      Caption = 'FK'
      Category = 1
      Visible = ivAlways
      ImageIndex = 179
      ItemLinks = <>
    end
    object Delete1: TdxBarButton
      Action = EliminaDataSet
      Category = 1
    end
    object Copia1: TdxBarButton
      Caption = 'Copia'
      Category = 1
      Visible = ivAlways
      ShortCut = 16451
    end
    object Incolla1: TdxBarButton
      Caption = 'Incolla'
      Category = 1
      Visible = ivAlways
      ShortCut = 16470
    end
  end
  object PopupMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'Apri1'
      end
      item
        Visible = True
        ItemName = 'Add1'
      end
      item
        Visible = True
        ItemName = 'Delete1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton5'
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
        Visible = True
        ItemName = 'cxBarEditItemSposta'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'SubMenuFK'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton16'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton17'
      end
      item
        Visible = True
        ItemName = 'dxBarButton10'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItem2'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton8'
      end>
    UseOwnFont = False
    OnPopup = PopupMenuPopup
    Left = 224
    Top = 240
    PixelsPerInch = 96
  end
  object MetaTimer: TTimer
    Enabled = False
    Interval = 750
    OnTimer = MetaTimerTimer
    Left = 424
    Top = 40
  end
  object DiagramImages24: TImageList
    Height = 24
    Width = 24
    Left = 64
    Top = 176
    Bitmap = {
      494C010104000900040018001800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000600000003000000001002000000000000048
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC6600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000099990000999900009999000099
      9900009999000099990000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000066
      9900006699000066990000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000CC660000F8F8F800F8F8F800F1F1F100FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC6600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000099CC0033CCFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC0000999900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000066990033CC
      CC000099CC000066990000669900000000000000000000000000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC66000000000000000000000000000000000000000000000000
      00000000000000000000CC660000F8F8F800F8F8F800F1F1F100FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC6600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC00009999000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000066990033CCFF0033CC
      FF0000CCCC000099CC0000669900006699000000000000000000CC660000FFFF
      FF00F8F8F800F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CAA600F0CAA600FFCC
      9900FFCC9900CC6600000000000000000000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC6600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC00009999000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000066990066CCFF000099CC0033CC
      FF0000CCFF000099CC000099CC00006699000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1F100FFECCC00FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CAA600F0CA
      A600FFCC9900CC6600000000000000000000CC660000FFFFFF00F8F8F800F8F8
      F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CA
      A600F0CAA600F0CAA600F0CAA600F0CAA600FFECCC00CC660000F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC6600009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      330099663300996633000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC00009999009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      33009933330066330000663333000066990066CCFF000099CC0066FFFF0000CC
      FF000099CC000099CC000099CC00006699000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F1F1F100F1F1
      F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CA
      A600F0CAA600CC6600000000000000000000CC660000FFFFFF00F8F8F800F1F1
      F100F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600F0CAA600FFECCC00CC660000F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC66000099663300F8F8F800F8F8F800F8F8
      F800F1F1F1000000CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC000000
      CC00FFECCC00FFECCC000099CC00CCFFFF00CCFFFF00CCFFFF00F0FBFF00F0FB
      FF00F0FBFF00C6D6EF0066CCCC000099990099663300F8F8F800F8F8F800F1F1
      F100F1F1F10000800000FFECCC00FFECCC00FFECCC00FFECCC00FFECCC000080
      0000CC999900969696000066990066CCFF000099CC0066FFFF0000CCFF000099
      CC0033CCFF000099CC0000669900000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8
      F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFEC
      CC00F0CAA600CC6600000000000000000000CC660000FFFFFF00F8F8F800F8F8
      F800F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00F0CA
      A600F0CAA600F0CAA600F0CAA600F0CAA600FFECCC00CC660000F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC66000099663300F8F8F800F8F8F800F8F8
      F800F8F8F8000000CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC000000
      CC00FFECCC00FFECCC000099CC00CCFFFF0033CCCC000099CC000099CC003399
      CC003399CC003399CC0099CCCC000099990099663300F8F8F800F8F8F800F8F8
      F800F1F1F10000800000FFECCC00FFECCC00FFECCC00FFECCC00FFECCC000066
      0000969696000066990066CCFF000099CC0066FFFF0000CCFF000066CC0066CC
      FF0033CCFF000066990099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00F8F8
      F800F8F8F800F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFEC
      CC00F0CAA600F0CAA600F0CAA600F0CAA600FFECCC00CC660000FFECCC00F0CA
      A600F0CAA600F0CAA600F0CAA600CC66000099663300FFFFFF00FFFFFF00F8F8
      F800F8F8F8000000CC00F8F8F800FFECCC00FFECCC00FFECCC00FFECCC000000
      CC00FFECCC00FFECCC000099CC0033CCCC0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC000099990099663300FFFFFF00F8F8F800F8F8
      F800F8F8F80000800000F1F1F100FFECCC00FFECCC00FFECCC00FFECCC000080
      000086868600006699000099CC0066FFFF0000CCFF000066990066CCFF0033CC
      FF0000669900F0CAA60099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F8F8F800F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00F0CAA600F0CAA600F0CAA600FFECCC00CC660000FFECCC00FFEC
      CC00F0CAA600F0CAA600F0CAA600CC660000996633000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000000CC000000CC000000
      CC000000CC006666CC000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC00009999009966330000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000066
      0000006600000066990033CCFF0000CCFF000099CC0066CCFF0033CCFF000066
      9900008000000080000099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1F100FFECCC00FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00F0CAA600FFECCC00CC660000FFECCC00FFEC
      CC00F0CAA600F0CAA600F0CAA600CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00F8F8F800F8F8F800F8F8F800F1F1F100FFECCC000000
      CC00FFECCC00FFECCC000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC000099990099663300FFFFFF00FFFFFF00FFFF
      FF00F8F8F80000800000F8F8F800F8F8F800F1F1F100D7D7D700B2B2B2000066
      6600006699003399CC0033CCCC000099CC000099CC0033CCFF0000669900F0CA
      A600F0CAA600F0CAA60099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F1F1F100FFECCC00FFECCC00FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1F100FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC660000FFECCC00FFEC
      CC00FFECCC00F0CAA600F0CAA600CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00F8F8F800F8F8F800F8F8F800F8F8F800F1F1F1000000
      CC00FFECCC00FFECCC000099CC0099FFFF0066FFFF0033CCFF0033CCFF0066FF
      FF0099FFFF0033CCCC000099CC000099990099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000800000F8F8F800F8F8F800F8F8F800B2B2B200006699000066
      990033CCFF0000CCFF0000669900006699000066990000669900FFECCC00F0CA
      A600F0CAA600F0CAA60099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F1F1F100FFECCC00FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1F100FFEC
      CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC660000FFECCC00FFEC
      CC00FFECCC00FFECCC00F0CAA600CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00F8F8F800F8F8F800F8F8F8000000
      CC00FFECCC00F8F8F8000099CC0099FFFF0099FFFF0066FFFF0066FFFF0099FF
      FF0099FFFF0066CCFF000099CC000099990099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000800000FFFFFF00F8F8F800F8F8F800C0C0C0000066990033CC
      FF0000CCFF000099CC0000669900D7D7D700CBCBCB0000800000FFECCC00FFEC
      CC00FFECCC00F0CAA60099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1F100FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F1F1
      F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC660000FFECCC00FFEC
      CC00FFECCC00FFECCC00F0CAA600CC660000996633000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000000CC000000CC000000
      CC000000CC006666CC000099CC00FFFFFF00F0FBFF00CCFFFF00CCFFFF00CCFF
      FF0099FFFF0099FFFF0066FFFF00009999009966330000800000008000000080
      00000080000000660000006600000066000000660000006600003399990000CC
      FF000099CC000066990000663300008000000080000000800000008000000080
      0000008000000080000099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800FFEC
      CC00FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8
      F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00CC660000FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F8000000
      CC00F8F8F800F8F8F800F8F8F8000099CC00F0FBFF00F0FBFF00CCFFFF0099FF
      FF0099FFFF0099FFFF00009999000000000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000066000066FF990066FF66003399330066996600424242000066
      66000066990000669900F1F1F100FFECCC00FFECCC0000800000FFECCC00FFEC
      CC00FFECCC00FFECCC0099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8
      F800FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8
      F800F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00CC660000FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      CC00F8F8F800F8F8F800F8F8F800F8F8F8000099CC000099CC000099CC000099
      CC000099CC000099CC00996633000000000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000066000066FF990066FF99006699660042424200339933000066
      0000F8F8F800F8F8F800F1F1F100F1F1F100FFECCC0000800000FFECCC00FFEC
      CC00FFECCC00FFECCC0099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F8F8
      F800FFECCC00CC6600000000000000000000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F8F8F800FFFFFF00CC660000F1F1F100FFEC
      CC00FFECCC00FFECCC00FFECCC00CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      CC00FFFFFF00F8F8F800F8F8F800F8F8F800F8F8F8000000CC00FFECCC00FFEC
      CC00FFECCC00FFECCC00996633000000000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000066000066FF9900777777007777770066CC660033CC66000066
      0000F8F8F800F8F8F800F8F8F800F8F8F800F1F1F10000800000FFECCC00FFEC
      CC00FFECCC00FFECCC0099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800CC6600000000000000000000CC660000FFCC6600FFCC6600FFCC
      6600FFCC6600FFCC6600FFCC6600FFCC6600FFCC6600FFCC6600FFCC6600FFCC
      6600FFCC6600FFCC6600FFCC6600FFCC6600FFCC6600CC660000F8F8F800F1F1
      F100FFECCC00FFECCC00FFECCC00CC660000996633000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000000CC000000CC000000
      CC000000CC000000CC0099663300000000009966330000800000008000000080
      0000008000000066000000660000666666005555550000660000006600000066
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000099663300000000000000000000000000CC660000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F8F8F800FFFFFF00F8F8F800F1F1F100F1F1
      F100F8F8F800CC6600000000000000000000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000F8F8F800F1F1
      F100F1F1F100FFECCC00FFECCC00CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      CC00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F8000000CC00F8F8F800F8F8
      F800FFECCC00FFECCC00996633000000000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000080
      0000FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8F80000800000F1F1F100F1F1
      F100FFECCC00FFECCC0099663300000000000000000000000000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000000000000000000000000000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000FFFFFF00F8F8F800F8F8
      F800F1F1F100FFECCC00FFECCC00CC66000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      CC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000CC00F8F8F800F8F8
      F800F1F1F100FFECCC00996633000000000099663300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000080
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F80000800000F8F8F800F1F1
      F100F1F1F100FFECCC0099663300000000000000000000000000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000FF99660000000000000000000000000000000000000000000000
      00000000000000000000CC660000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F8F8
      F800F8F8F800F1F1F100FFECCC00CC66000099663300E3E3E300E3E3E300E3E3
      E300E3E3E3000000CC00E3E3E300E3E3E300E3E3E300E3E3E300E3E3E3000000
      CC00E3E3E300E3E3E300E3E3E300E3E3E300E3E3E3000000CC00E3E3E300E3E3
      E300E3E3E300E3E3E300996633000000000099663300E3E3E300E3E3E300E3E3
      E300E3E3E30000800000E3E3E300E3E3E300E3E3E300E3E3E300E3E3E3000080
      0000E3E3E300E3E3E300E3E3E300E3E3E300E3E3E30000800000E3E3E300E3E3
      E300E3E3E300E3E3E3009966330000000000000000000000000000000000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC6633000000000000000000000000000000000000000000000000000000
      00000000000000000000CC660000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F8F8F800FFFFFF00CC6600009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099663300000000009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099663300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC663300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300CC66330000000000CC663300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300CC663300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC66000000000000CC663300CC663300CC66
      3300CC663300CC663300CC663300CC663300CC663300CC663300CC663300CC66
      3300CC663300CC663300CC663300CC663300CC663300CC663300CC663300CC66
      3300CC663300CC663300000000000000000000000000CC663300CC663300CC66
      3300CC663300CC663300CC663300CC663300CC663300CC663300CC663300CC66
      3300CC663300CC663300CC663300CC663300CC663300CC663300CC663300CC66
      3300CC663300CC66330000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000060000000300000000100010000000000400200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFC0000FFFF03FFFFE3FFFFFFFC
      0000FFFE01FFFFC1C00003FC0000FFFC00FFFF80C00003000000FFFC00FFFF00
      C00003000000000000000000C00003000000000000000001C000030000000000
      00000001C00003000000000000000001C00003000000000000000001C0000300
      0000000000000001C00003000000000000000001C00003000000000000000001
      C00003000000000000000001C00003000000000001000001C000030000000000
      01000001C00003000000000001000001C00003000000000001000001C0000300
      0000000001000001C00003800000000001000001C00003FC0000000001000001
      E00007FC0000000001000001FFFFFFFC0000000001000001FFFFFFFC00008000
      03800003FFFFFFFE0001FFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object DiagramImages16: TImageList
    Left = 64
    Top = 232
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC6600000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000009999000099
      9900009999000099990000999900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000066990000669900006699000000000000000000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC6600000000000000000000000000000000
      0000CC660000FFFFFF00F1F1F100FFECCC00FFECCC00FFECCC00F0CAA600F0CA
      A600FFECCC00FFECCC00FFECCC00CC6600000000000000000000000000000000
      000000000000000000000000000000000000000000000099990066CCFF0033CC
      FF0033CCFF0099FFFF0033CCCC00009999000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000066
      990066CCFF0000CCFF000099CC000066990000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00F1F1F100FFECCC00FFECCC00FFECCC00F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000FFCC9900F0CAA600FFECCC00CC6600009966330099333300993333009933
      330099333300993333009933330099333300993333000099990066FFFF0033CC
      FF0033CCFF0099FFFF0033CCCC00009999009966330099333300993333009933
      33009933330099333300993333009933330066330000663300000066990033CC
      CC0033CCCC0000CCFF0000CCFF000066990000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F1F1F100FFECCC00FFECCC00FFECCC00F0CAA600F0CA
      A600F0CAA600F0CAA600F0CAA600CC660000CC660000FFFFFF00FFFFFF00F8F8
      F800FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC66
      0000FFCC9900F0CAA600FFECCC00CC66000099333300F1F1F100F1F1F100FFEC
      CC000000CC00FFECCC00FFECCC00FFECCC00FFECCC0000999900CCFFFF0099FF
      FF00CCFFFF00CCFFFF0099CCFF000099990099333300F1F1F100FFECCC00FFEC
      CC0000800000FFECCC00F0CAA600CC999900999999000066990033CCCC0033CC
      CC000066990066CCFF000099CC000066990000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00F1F1F100FFECCC00FFECCC00FFECCC00F0CA
      A600F0CAA600F0CAA600F0CAA600CC660000CC660000FFFFFF00F8F8F800F1F1
      F100FFECCC00FFECCC00FFECCC00FFECCC00F0CAA600F0CAA600FFECCC00CC66
      0000F0CAA600F0CAA600FFECCC00CC66000099333300F8F8F800F1F1F100F1F1
      F1000000CC00FFECCC00FFECCC00FFECCC00FFECCC000099990066CCCC003399
      CC003399CC003399CC0066CCCC000099990066333300F8F8F800F1F1F100F1F1
      F10000800000FFECCC00FFCCCC00A4A0A0000066990033CCCC0033CCCC000066
      990066CCFF0033CCFF00006699000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F1F1F100FFECCC00FFECCC00FFEC
      CC00F0CAA600F0CAA600F0CAA600CC660000CC660000FFFFFF00FFFFFF00F8F8
      F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00F0CAA600FFECCC00CC66
      0000F0CAA600F0CAA600FFECCC00CC660000993333000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000099990066CCCC0033CC
      FF0033CCFF0099CCFF003399CC00009999009933330000800000008000000080
      0000008000000080000000800000006600000066990033CCCC000066990066CC
      FF0033CCCC0000669900993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F1F1F100FFECCC00FFEC
      CC00FFECCC00F0CAA600F0CAA600CC660000CC660000FFFFFF00FFFFFF00FFFF
      FF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC66
      0000F0CAA600FFECCC00FFECCC00CC66000099333300FFFFFF00FFFFFF00F8F8
      F8000000CC00F1F1F100FFECCC00FFECCC00FFECCC000099990066FFFF0033CC
      FF0033CCFF0099FFFF0033CCCC000099990099333300FFFFFF00FFFFFF00F8F8
      F80000800000DDDDDD00B2B2B20090A9AD000066990000CCFF0066CCFF0033CC
      CC0000669900FFECCC00993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F1F1F100FFEC
      CC00FFECCC00FFECCC00F0CAA600CC660000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFECCC00CC66
      0000FFECCC00FFECCC00FFECCC00CC66000066333300FFFFFF00FFFFFF00FFFF
      FF000000CC00F8F8F800F1F1F100F1F1F100FFECCC000099990099FFFF0066FF
      FF0099FFFF0099FFFF0066CCFF000099990066333300FFFFFF00FFFFFF00FFFF
      FF0000800000C0C0C000006699003399CC0000CCFF0000669900006699000066
      9900FFECCC00FFECCC00993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F1F1
      F100FFECCC00FFECCC00FFECCC00CC660000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F8F8F800F8F8F800FFECCC00FFECCC00FFECCC00CC66
      0000FFECCC00FFECCC00FFECCC00CC66000066333300FFFFFF00FFFFFF00FFFF
      FF000000CC00FFFFFF00F8F8F800F1F1F100F1F1F10000999900CCFFFF00FFFF
      FF00CCFFFF00CCFFFF0099FFFF000099990066333300FFFFFF00FFFFFF00FFFF
      FF0000800000CCCCCC000066990000CCFF000066990000663300FFECCC00FFEC
      CC00FFECCC00FFECCC00993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F1F1F100FFECCC00FFECCC00CC660000CC660000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F8F800F1F1F100F8F8F800CC66
      0000FFECCC00FFECCC00FFECCC00CC660000993333000000CC000000CC000000
      CC000000CC000000CC000000CC000000CC000000CC000000CC00009999000099
      9900009999000099990000999900000000009933330000800000008000000080
      0000008000003366330039393900009999000066990000800000008000000080
      00000080000000800000993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00F1F1F100FFECCC00CC660000CC660000F1F1F100FFECCC00FFEC
      CC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00FFECCC00CC66
      0000FFECCC00FFECCC00FFECCC00CC66000066333300FFFFFF00FFFFFF00FFFF
      FF000000CC00FFFFFF00FFFFFF00FFFFFF00F8F8F8000000CC00F1F1F100FFEC
      CC00FFECCC00FFECCC0099333300000000006633330066FF990033CC66000099
      00003366330039393900EAEAEA00FFFFFF00F8F8F80000800000F1F1F100FFEC
      CC00FFECCC00FFECCC00993333000000000000000000CC660000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00F1F1F100CC660000CC660000CC663300CC663300CC66
      3300CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000F1F1F100F1F1F100F1F1F100CC66000099333300E3E3E300E3E3E300E3E3
      E3000000CC00E3E3E300E3E3E300E3E3E300E3E3E3000000CC00E3E3E300DDDD
      DD00DDDDDD00D7D7D70099663300000000009933330066FF990066FF990033CC
      330077777700B2B2B200E3E3E300E3E3E300E3E3E30000800000E3E3E300DDDD
      DD00DDDDDD00D7D7D700996633000000000000000000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC66000000000000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000FFCC
      CC00FFFFFF00F8F8F800F8F8F800CC6600009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099333300000000009966330099663300996633009966
      3300996633009966330099663300996633009966330099663300996633009966
      3300996633009966330099333300000000000000000000000000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000000000000000000000000000000000000000
      0000CC660000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00F8F8F800F8F8F800F8F8F800CC66000099663300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300CC6600000000000099663300FF993300FF993300FF99
      3300FF993300FF993300FF993300FF993300FF993300FF993300FF993300FF99
      3300FF993300FF993300CC660000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC66000000000000CC660000CC660000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000000000000000000000000000CC663300CC663300CC66
      3300CC663300CC663300CC663300CC663300CC663300CC663300CC660000CC66
      3300CC663300CC66330000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      0000CC660000CC660000CC660000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFF000FFC1FFF18000F000FF80FFE0
      8000000000000000800000000000000080000000000000018000000000000001
      8000000000000001800000000000000180000000000000018000000000010001
      800000000001000180000000000100018000800000010001C001F00000010001
      FFFFF00080038003FFFFF801FFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object CompletionImageList: TImageList
    Left = 64
    Top = 288
    Bitmap = {
      494C010112001500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000A5A5A500A5A5A500A5A5A500A5A5A500A5A5
      A500A5A5A500A5A5A500A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000A5A5A500A5A5A500A5A5A500A5A5A500A5A5
      A500A5A5A500A5A5A500A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00002929290029292900000000000000000000000000BDBDBD00BDBDBD00BDBD
      BD00BDBDBD0000000000A5A5A500000000000000000000000000000000000000
      00002929290029292900000000000000000000000000BDBDBD00BDBDBD00BDBD
      BD00BDBDBD0000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900DEDEDE00DEDEDE0000000000000000001818180018181800181818001818
      1800BDBDBD0000000000A5A5A500000000000000000000000000000000002929
      2900DEDEDE00DEDEDE0000000000000000001818180018181800181818001818
      18000000000000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900F7CE
      A500FFFFFF0000000000000000000000000018181800BDBDBD00000000001818
      1800BDBDBD0000000000A5A5A50000000000000000000000000029292900F7CE
      A500FFFFFF00000000000000000000000000000000001818180018181800BDBD
      BD000000000000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900F7CE
      A500F7F7F70000000000000000000000000018181800BDBDBD00000000001818
      1800BDBDBD0000000000A5A5A50000000000000000000000000029292900F7CE
      A500F7F7F700000000000000000000000000000000001818180018181800BDBD
      BD00BDBDBD0000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000000000001818180000000000000000001818
      18000000000000000000A5A5A50000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000000000001818180018181800181818001818
      18000000000000000000A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900FFEF
      CE00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900FFEF
      CE00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900CECE
      CE00292929002929290029292900292929002929290063633100292929000000
      000000000000000000000000000000000000000000000000000029292900CECE
      CE00292929002929290029292900292929002929290063633100292929000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000292929002929
      290094949400CECE9C00CECECE00CE9C63006331000029292900292929000000
      0000000000000000000000000000000000000000000000000000292929002929
      290094949400CECE9C00CECECE00CE9C63006331000029292900292929000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900D6D6D600FFFFFF00FFFFFF00FFEFCE00CE9C630029292900000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900D6D6D600FFFFFF00FFFFFF00FFEFCE00CE9C630029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000292929002929290029292900292929002929290000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000292929002929290029292900292929002929290000000000000000000000
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
      000000000000000000000000000000000000000000005A5A5A004A4A4A004A4A
      4A004A4A4A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000A5A5A500A5A5A500A5A5A500A5A5A500A5A5
      A500A5A5A500A5A5A500A5A5A500000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000029292900292929002929290029292900427BFF00427BFF00427B
      FF005A5A5A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000427BFF0000000000DEDEDE00C6C6C600CE9C6300CE9C6300292929000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000427BFF0000000000DEDEDE00C6C6C600CE9C6300DEB5940000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      000029292900DEDEDE00DEDEDE00C6C6C600CE9C6300CE9C6300427BFF004A4A
      4A00000000000000000000000000000000000000000000000000000000000000
      00002929290029292900000000000000000000000000BDBDBD00000000000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000427BFF000042D60000000000FFEFCE00F7CEA500CE9C6300636331002929
      2900000000000000000000000000000000000000000000000000000000000000
      0000427BFF000042D60000000000FFEFCE00F7CEA500DEBD9C0000000000C6C6
      C600008484000000000000000000000000000000000000000000000000002929
      2900F7CEA500FFFFFF0000000000FFEFCE00F7CEA500CE9C6300427BFF004A4A
      4A00000000000000000000000000000000000000000000000000000000002929
      2900DEDEDE00DEDEDE000000000000000000BDBDBD0018181800BDBDBD000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000427BFF000000000000000000FFEFCE00CECE9C009C9C6300636331002929
      2900000000000000000000000000000000000000000000000000000000000000
      0000427BFF000000000000000000FFEFCE00CECE9C009C9C630000000000C6C6
      C600000000000000000000000000000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C6300427BFF004A4A
      4A0000000000000000000000000000000000000000000000000029292900F7CE
      A500FFFFFF000000000000000000000000001818180018181800393939000000
      00000000000000000000A5A5A500000000000000000000000000000000000000
      0000427BFF000042D60000000000FFEFCE00CECE9C009C9C3100636331002929
      2900000000000000000000000000000000000000000000000000000000000000
      0000427BFF000042D60000000000FFEFCE00CECE9C009C9C310000000000C6C6
      C600008484000000000000000000000000000000000000000000000000002929
      2900F7CEA500F7F7F700000000005A5A5A004A4A4A009C9C3100427BFF004A4A
      4A00000000005A5A5A004A4A4A0000000000000000000000000029292900F7CE
      A500F7F7F700000000000000000000000000181818000000000018181800BDBD
      BD000000000000000000A5A5A500000000000000000000000000000000000000
      0000427BFF000000000000000000FFEFCE00CECE9C009C9C6300636331002929
      2900000000000000000000000000000000000000000000000000000000000000
      0000427BFF000000000000000000FFEFCE00CECE9C009C9C630000000000C6C6
      C600000000000000000000000000000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000427BFF004A4A4A004A4A4A00427BFF004A4A
      4A004A4A4A00427BFF004A4A4A0000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000181818000000000000000000000000001818
      1800BDBDBD0000000000A5A5A500000000000000000000000000000000000029
      8400427BFF000042D60000000000FFFFEF00CECE9C009C9C6300636331002929
      2900000000000000000000000000000000000000000000000000000000000029
      8400427BFF000042D60000000000FFFFEF00E7E7C6000000000000848400C6C6
      C600008484000000000000000000000000000000000000000000000000002929
      2900FFEFCE00FFFFFF0000000000427BFF00427BFF00427BFF00427BFF00427B
      FF00427BFF00427BFF000000000000000000000000000000000029292900F7CE
      A500F7F7F7000000000000000000000000000000000000000000000000000000
      0000181818000000000000000000000000000000000021212100427BFF00427B
      FF00427BFF000042D6000042D600000000002929290029292900636331002929
      2900000000000000000000000000000000000000000021212100427BFF00427B
      FF00427BFF000042D6000042D6000000000000000000C6C6C600C6C6C600C6C6
      C60000848400008484004A4A4A00000000000000000000000000000000002929
      2900CECECE002929290029292900292929002929290029292900636331002929
      290000000000000000000000000000000000000000000000000029292900FFEF
      CE00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021212100739CFF00427B
      FF00000000000042D6000042D60000000000DEBD940063310000292929002929
      2900000000000000000000000000000000000000000021212100739CFF00427B
      FF00000000000042D6000042D600000000002929290000FFFF00C6C6C6000000
      0000008484000084840021212100000000000000000000000000000000002929
      29002929290094949400CECE9C00CECECE00CE9C630063310000292929002929
      290000000000000000000000000000000000000000000000000029292900CECE
      CE00292929002929290029292900292929002929290063633100292929000000
      0000000000000000000000000000000000000000000029292900739CFF00739C
      FF00427BFF00427BFF00427BFF0000000000FFF7DE00CE9C6300292929000000
      0000000000000000000000000000000000000000000029292900739CFF00739C
      FF00427BFF00427BFF00427BFF00000000005A52520000FFFF0000FFFF00C6C6
      C600C6C6C600C6C6C60021212100000000000000000000000000000000000000
      000029292900D6D6D600FFFFFF00FFFFFF00FFEFCE00CE9C6300292929000000
      0000000000000000000000000000000000000000000000000000292929002929
      290094949400CECE9C00CECECE00CE9C63006331000029292900292929000000
      000000000000000000000000000000000000000000000000000000000000739C
      FF00739CFF00427BFF0000000000CECECE003939390029292900000000000000
      000000000000000000000000000000000000000000000000000000000000739C
      FF00739CFF00427BFF0000000000CECECE005A5A5A000000000000FFFF0000FF
      FF00C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900D6D6D600FFFFFF00FFFFFF00FFEFCE00CE9C630029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000101010000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000292929002929290029292900292929002929290000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000009C630000636300006363000063630000636300006363
      000063630000636300009C630000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFF7FF00BDB5B500BDBDBD00C6CECE00E7E7EF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F7CEA500CEFFFF00CEFFFF00CEFFFF0063630000CEFF
      FF00CEFFFF00CEFFFF0063630000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000002908DE002908DE002908DE00000000000000
      000000000000000000000000000000000000000000000000000000000000DEA5
      9C00AD392100BD312100B53121009C3118008C4A4200A59C9C00B5B5AD009C9C
      940094948C009C949400D6CECE00000000000000000000000000000000000000
      00000000000039393900F7CEA500CEFFFF0063630000CEFFFF0063630000CEFF
      FF0063630000CEFFFF0063630000000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002908DE00000000000000
      000000000000000000000000000000000000000000000000000000000000D639
      1800FF423100FF634A00F77B5200EF6B4200EF31210063631800319429003194
      2900319C2100088400004A7B3900000000000000000000000000000000000000
      0000000000003939390039393900CEFFFF00CEFFFF00CEFFFF0063630000CEFF
      FF00CEFFFF00CEFFFF0063630000000000000000000000000000000000000000
      000029292900DEDEDE00DEDEDE00C6C6C600CE9C6300DEB5940000000000C6C6
      C600000000000000000000000000000000000000000000000000000000002929
      290029292900393939004252520052636300000000002908DE00000000000000
      0000000000000000000000000000000000000000000000000000000000008452
      4A00FF5A4200EF6B4200F7B57B00FF9C6300FF5231007B8C290094D68C008CC6
      73005ACE4A0021AD10005A945200000000000000000052525200393939003939
      39003939390039393900393939003939390063630000CEFFFF0063630000CEFF
      FF0063630000CEFFFF0063630000000000000000000000000000000000002929
      2900F7CEA500FFFFFF0000000000FFEFCE00F7CEA500DEBD9C0000000000C6C6
      C60000848400000000000000000000000000000000000000000029292900DEDE
      DE00DEDEDE00C6C6C600D6AD8400D6B594006B7B7B002908DE00000000000000
      000000000000000000000000000000000000000000000000000029292900DEDE
      DE007331210039003100392984006B214A008C63310063BD4A009CB5940094AD
      BD00529C4A0063A55200E7E7DE00000000000000000052525200FFEFCE00FFEF
      CE00FFEFCE003939390039393900CEFFFF00CEFFFF00CEFFFF0063630000CEFF
      FF00CEFFFF00CEFFFF0063630000000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C630000000000C6C6
      C600000000000000000000000000000000000000000042424200F7CEA500FFFF
      FF0000000000FFEFD600F7D6B500D6B594002908DE002908DE002908DE000000
      0000000000000000000000000000000000000000000042424200F7CEA5005A42
      4A000000000000087B000018A500000084004A4A6B008CB58C00106BAD000873
      E700085A9C008C848400FFFFFF00000000000000000052525200FFEFCE00CE9C
      6300F7CEA50039393900F7CEA500CEFFFF0063630000CEFFFF0063630000CEFF
      FF0063630000CEFFFF0063630000000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C310000000000C6C6
      C600008484000000000000000000000000000000000042424200F7CEA500F7F7
      F70000000000FFEFD600D6D6AD00ADB58C00949C7B002908DE00000000000000
      0000000000000000000000000000000000000000000042424200EFCEAD001000
      0000080831001052D600185AD6000842CE00394A8C006394D600218CFF003194
      FF00218CFF0029528400D6CEC600000000000000000052525200FFEFCE009C9C
      6300CECE9C00FFEFCE00F7CEA500CEFFFF00CEFFFF00CEFFFF0063630000CEFF
      FF00CEFFFF00CEFFFF0063630000000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C630000000000C6C6
      C600000000000000000000000000000000000000000042424200F7CEA500F7F7
      F70000000000FFEFCE00D6D6A500ADB563008C9C73002908DE00000000000000
      0000000000000000000000000000000000000000000042424200EFCEAD002910
      1000211839001863DE00187BFF001873FF0031529400398CD60042ADFF0042AD
      FF0042ADFF00186BBD00B5ADAD000000000000000000A5A5A5009C9C63009C9C
      3100CECE9C00FFEFCE0063630000636300006363000063630000636300006363
      0000636300006363000063630000000000000000000000000000000000002929
      2900FFEFCE00FFFFFF0000000000FFEFCE00E7E7C6000000000000848400C6C6
      C600008484000000000000000000000000000000000042424200F7CEA500F7F7
      F70000000000FFEFCE00D6D6A500ADAD840084946B002908DE002908DE000000
      00002908DE000000000000000000000000000000000042424200F7CEA5008C84
      8400311821005A5273004A528C00101852006B6B5A00426B8C00218CD6003994
      DE003194E7002973AD00F7F7F70000000000000000006B6B6B009C9C63009C9C
      6300CECE9C00FFEFCE009C630000636300006363000063630000636300006363
      000063630000636300009C630000000000000000000000000000000000002929
      2900CECECE0029292900292929002929290000000000C6C6C600C6C6C600C6C6
      C60000848400008484004A4A4A00000000000000000042424200FFEFCE00FFFF
      FF0000000000FFEFCE00CED6A500A5A57B007B8C63005A6B6B002908DE002908
      DE002908DE000000000000000000000000000000000042424200FFEFCE00FFFF
      FF009C949C00C6B5A5009C947B0063524200636331004A525A004A94C60073AD
      DE008CBDDE007B9CB5000000000000000000000000006B6B6B009C9C63009C9C
      6300CECE9C00FFEFCE0000000000FFFFFF00FFEFCE0084848400000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      29002929290094949400CECE9C00CECECE000000000000FFFF00C6C6C6000000
      0000008484000084840021212100000000000000000042424200CECECE002929
      290029292900292929003131310031393900737B52004A525200000000000000
      0000000000000000000000000000000000000000000042424200CECECE002929
      2900292929003939390039393900292929006363310029292900F7FFFF00F7F7
      FF00EFF7FF00000000000000000000000000000000006B6B6B009C9C63005252
      520052525200525252005252520052525200CECECE0052525200000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000029292900D6D6D600FFFFFF00FFFFFF003131290000FFFF0000FFFF00C6C6
      C600C6C6C600C6C6C60021212100000000000000000042424200292929009494
      9400CECE9C00CECECE00CE9C6B006B3908003139390039424200000000000000
      0000000000000000000000000000000000000000000042424200292929009494
      9400CECE9C00CECECE00CE9C6300633100002929290029292900000000000000
      000000000000000000000000000000000000000000006B6B6B00525252009C9C
      6300CE9C6300CECECE00CECE9C00949494005252520052525200000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000292929002929290029292900525252000000000000FFFF0000FF
      FF00C6C6C600000000000000000000000000000000000000000029292900D6D6
      D600FFFFFF00FFFFFF00FFEFCE00CE9C6B003131310000000000000000000000
      000000000000000000000000000000000000000000000000000029292900D6D6
      D600FFFFFF00FFFFFF00FFEFCE00CE9C63002929290000000000000000000000
      000000000000000000000000000000000000000000000000000052525200CE9C
      6300FFEFCE00FFFFFF00FFFFFF00D6D6D6005252520000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000101010000000000000000000000000000000000000000000000000002929
      2900292929002929290029292900292929000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900292929002929290029292900292929000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005252
      5200525252005252520052525200525252000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008C8C8C008C8C8C005252
      5200525252005252520052525200949494000000000000000000000000000000
      00000000000000000000000000000000000000000000009C0000009C00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008C8C8C00CEFFFF0039393900CEFF
      FF00CEFFFF00CEFFFF00CEFFFF006B6B6B000000000000000000000000000000
      00008C8C8C0052525200525252005252520052525200009C000063CE3100009C
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F7FFFF0000000000A5D6F700086BDE00ADD6F7000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000005A5A5A000000000000000000000000000000
      0000000000005A5A5A0000000000000000000000000000000000000000000000
      00000000000000000000000000008C8C8C00CEFFFF00CEFFFF0039393900CEFF
      FF007373730073737300CEFFFF006B6B6B000000000000000000000000000000
      000052525200CEFFFF00CEFFFF00CEFFFF00CEFFFF00009C000063CE310063CE
      3100009C00000000000000000000000000000000000000000000000000000000
      000000000000EFF7FF0063ADEF00ADD6F700ADD6F7000063DE00A5CEF700B5D6
      F70073B5EF00E7F7FF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A5A5A005A5A
      5A00000000005A5A5A0000000000000000000000000000000000000000004242
      420042424200424242007373730094ADB500CEFFFF00CEFFFF0039393900CEFF
      FF00CEFFFF00CEFFFF00CEFFFF006B6B6B000000000000000000000000006B6B
      6B0052525200CEFFFF00737373007373730073737300009C000063CE310063CE
      310063CE3100009C000000000000000000000000000000000000000000002929
      290029292900636363001084E7001084E7004AA5EF000073E7004A9CEF00107B
      E700006BDE00ADD6F70000000000000000000000000000000000000000002931
      3100394242004A5A5A00637B7B000000000000000000009C000063CE310063CE
      31005A5A5A005A5A5A000000000000000000000000000000000042424200E7E7
      E700DEDEDE00C6C6C60094949400C6DEC60094ADAD00CEFFFF0039393900CEFF
      FF007373730039393900393939006B6B6B0000000000000000006B6B6B00E7E7
      E70039393900CEFFFF00CEFFFF00CEFFFF00CEFFFF00009C000063CE310063CE
      3100C6DEC600639C31000000000000000000000000000000000029292900DEDE
      DE00DEDEDE00CED6D60094CEF700188CEF001084E700188CE7001084E7000873
      E70073B5EF00EFF7FF00FFFFFF0000000000000000000000000029292900DEDE
      DE00E7E7E700CED6D600DEC6AD00E7DECE0000000000009C0000009C000063CE
      31005A5A5A00000000000000000000000000000000005A5A5A00F7CEA500FFFF
      FF0000000000A5A5A500E7E7E700C6DEC600C6C6C60094ADAD0039393900CEFF
      FF00CEFFFF0039393900CEFFFF006B6B6B00000000007B7B7B00F7CEA500FFFF
      FF0039393900CEFFFF00737373007373730073737300009C000063CE3100C6DE
      C600639C31000000000000000000000000000000000042424200F7CEA500FFFF
      FF009CD6FF004AB5F70042ADF7001894EF0084C6F700E7EFFF008CCEF7001884
      E7003994E700319CEF007BC6F700000000000000000042424200F7CEA500FFFF
      FF0000000000FFF7DE00F7E7D6000000000000000000009C0000009C000063CE
      3100000000005A5A5A000000000000000000000000005A5A5A00F7CEA500F7F7
      F700000000009C9C9C00D6E7E700C6DEC600C6C6C60094ADAD00737373003939
      390039393900525252005252520000000000000000007B7B7B00F7CEA500F7F7
      F70039393900CEFFFF00CEFFFF00CEFFFF00CEFFFF00009C0000C6DEC600639C
      3100000000000000000000000000000000000000000042424200F7CEA500F7F7
      F70084CEFF00189CF700109CF700219CEF00CEEFFF0000000000EFF7FF002194
      EF00087BE700107BE7007BBDF700000000000000000042424200F7CEA500F7F7
      F70000000000FFF7DE00DEE7C600CEE7D60000000000007B0000009C000063CE
      310000000000000000000000000000000000000000005A5A5A00F7CEA500F7F7
      F700A5A5A500EFEFEF00E7E7E700C6DEC600C6C6C60094ADAD00CEFFFF00A5A5
      A500A5A5A500A5A5A5000000000000000000000000007B7B7B00F7CEA500F7F7
      F7007373730039393900393939003939390039393900009C0000639C31000000
      0000000000000000000000000000000000000000000042424200F7CEA500F7F7
      F700EFF7FF00D6EFFF00A5DEFF0029ADF7007BC6F700CEEFFF007BC6F7001894
      EF008CCEFF00D6E7FF00E7F7FF00000000000000000042424200F7CEA500F7F7
      F70000000000FFF7DE00DEE7C6000000000000000000007B0000009C000063CE
      310000000000000000000000000000000000000000005A5A5A00F7CEA500F7F7
      F700A5A5A5009C9C9C00949494007373730063636300737373008C8C8C008C8C
      8C0000000000000000000000000000000000000000007B7B7B00F7CEA500F7F7
      F70000000000FFEFCE00FFEFCE00F7CEA5009C9C630094949400000000000000
      0000000000000000000000000000000000000000000042424200F7CEA500F7F7
      F70000000000E7F7FF0042B5F70021A5F70039ADF70021A5F70031ADF700189C
      F700319CEF00D6E7FF0000000000000000000000000042424200F7CEA500F7F7
      F70000000000FFF7D600DEDEBD0000000000B5D6C60000000000000000005A5A
      5A0000000000000000000000000000000000000000005A5A5A00FFEFCE00FFFF
      FF0000000000FFEFCE00CECE9C009C9C63006363310042424200000000000000
      000000000000000000000000000000000000000000007B7B7B00FFEFCE00FFFF
      FF0000000000FFEFCE00CECE9C009C9C6300636331006B6B6B00000000000000
      0000000000000000000000000000000000000000000042424200FFEFCE00FFFF
      FF0000000000DEEFF7004AB5FF007BC6F700A5DEFF00009CF700A5DEFF0084CE
      F7004AADEF00D6EFFF0000000000000000000000000042424200FFEFCE00FFFF
      FF0000000000FFEFD600D6DEB5005A5A5A00A5BDA5000000FF00000000000000
      FF00000000005A5A5A000000000000000000000000005A5A5A00CECECE002929
      2900292929002929290029292900292929006363310042424200000000000000
      000000000000000000000000000000000000000000007B7B7B00CECECE005252
      520052525200525252005252520052525200636331006B6B6B00000000000000
      0000000000000000000000000000000000000000000042424200CECECE002929
      29002929290029292900636363004A4A4A00BDE7F70029ADF700ADDEFF000000
      0000D6EFFF000000000000000000000000000000000042424200CECECE002929
      290031313100393939004A5252005A6B6B0094A58400738C8C00000000000000
      000000000000000000000000000000000000000000005A5A5A00424242009494
      9400CECE9C00CECECE00CE9C6300633100004242420042424200000000000000
      000000000000000000000000000000000000000000007B7B7B006B6B6B009494
      9400CECE9C00CECECE00CE9C63009C9C63006B6B6B006B6B6B00000000000000
      0000000000000000000000000000000000000000000042424200292929009494
      9400CECE9C00CECECE00CE9C63006B31000063636300A5BDD600E7F7FF000000
      0000000000000000000000000000000000000000000042424200292929009494
      9400CECE9C00CECECE00D6A573007B5A29004A5A5A0052636300000000000000
      000000000000000000000000000000000000000000000000000042424200DEDE
      DE00FFFFFF00FFFFFF00FFEFCE00CE9C63004242420000000000000000000000
      00000000000000000000000000000000000000000000000000006B6B6B00DEDE
      DE00FFFFFF00FFFFFF00FFEFCE00CE9C63006B6B6B0000000000000000000000
      000000000000000000000000000000000000000000000000000029292900D6D6
      D600FFFFFF00FFFFFF00FFEFCE00CE9C63002929290000000000000000000000
      000000000000000000000000000000000000000000000000000029292900D6D6
      D600FFFFFF00FFFFFF00FFEFCE00CEA573003942420000000000000000000000
      0000000000000000000000000000000000000000000000000000000000004242
      4200424242004242420042424200424242000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006B6B
      6B006B6B6B006B6B6B006B6B6B006B6B6B000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900292929002929290029292900292929000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900292929002929290029292900293131000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002929290029292900292929002929
      2900292929000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007B7B
      7B005A5A5A005A5A5A005A5A5A005A5A5A005A5A5A005A5A5A005A5A5A007B7B
      7B00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000029292900DEDEDE00DEDEDE00C6C6C600CE9C
      6300CE9C63002929290000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005A5A
      5A00CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF005A5A
      5A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000029292900F7CEA500FFFFFF0000000000FFEFCE00F7CE
      A500CE9C63006363310042424200000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      000000000000000000000000000000000000000000008C8C8C005A5A5A005A5A
      5A00CEFFFF004242420042424200CEFFFF004242420042424200CEFFFF005A5A
      5A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900424242007B7B7B00292929007B6B5A00F7F7F70000000000FFEFCE00CECE
      9C009C9C63006363310042424200000000000000000000000000000000000000
      000029292900DEDEDE00DEDEDE00C6C6C600CE9C6300CE9C6300292929000000
      000000000000000000000000000000000000000000006B6B6B00CEFFFF004242
      4200CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF00CEFFFF005A5A
      5A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029292900DEDE
      DE00DEDEDE00C6C6C600CE9C6300CE9C63005252520000000000FFEFCE00CECE
      9C009C9C31006363310042424200000000000000000000000000000000002929
      2900F7CEA500FFFFFF0000000000FFEFCE00F7CEA500CE9C6300636331002929
      290000000000000000000000000000000000000000006B6B6B00CEFFFF004242
      4200CEFFFF004242420042424200CEFFFF004242420042424200CEFFFF005A5A
      5A00737373000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A5A5A00F7CEA500FFFF
      FF0000000000FFEFCE00F7CEA500CE9C63006363310029292900FFEFCE00CECE
      9C009C9C63006363310042424200000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C6300636331002929
      290000000000000000000000000000000000000000006B6B6B00CEFFFF004242
      4200F7CEA500F7CEA500F7CEA500F7CEA500F7CEA500F7CEA500F7CEA5004242
      42009C9C31004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A5A5A00F7CEA500F7F7
      F70000000000FFEFCE00CECE9C009C9C63006363310029292900FFF7DE00CECE
      9C009C9C63006363310042424200000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C3100636331002929
      290000000000000000000000000000000000000000006B6B6B00CEFFFF009C63
      0000636300006363000063630000636300006363000063630000636300009C63
      00009C9C31004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A5A5A00F7CEA500F7F7
      F70000000000FFEFCE00CECE9C009C9C31006363310029292900525252002929
      2900292929006363310042424200000000000000000000000000000000002929
      2900F7CEA500F7F7F70000000000FFEFCE00CECE9C009C9C6300636331002929
      290000000000000000000000000000000000000000006B6B6B00F7CEA500F7CE
      A500F7CEA500F7CEA500F7CEA500F7CEA500F7CEA50042424200FFEFCE00CECE
      9C00636331004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A5A5A00F7CEA500F7F7
      F70000000000FFEFCE00CECE9C009C9C63006363310042423900CECECE00CE9C
      6300633100002929290042424200000000000000000000000000000000002929
      2900FFEFCE00FFFFFF0000000000FFEFCE00CECE9C009C9C6300636331002929
      290000000000000000000000000000000000000000009C630000636300006363
      000063630000636300006363000063630000636300009C630000FFEFCE009C9C
      6300636331004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A5A5A00FFEFCE00FFFF
      FF0000000000FFEFCE00CECE9C009C9C6300636331004A4A4A00FFFFFF00FFEF
      CE00CE9C63002929290000000000000000000000000000000000000000002929
      2900CECECE002929290029292900292929002929290029292900636331002929
      2900000000000000000000000000000000000000000000000000000000000000
      00000000000073737300FFEFCE00FFFFFF0000000000FFEFCE00CECE9C009C9C
      6300636331004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000063636300CECECE002929
      2900292929002929290029292900292929006363310029292900424242002929
      2900292929000000000000000000000000000000000000000000000000002929
      29002929290094949400CECE9C00CECECE00CE9C630063310000292929002929
      2900000000000000000000000000000000000000000000000000000000000000
      00000000000042424200FFEFCE00292929002929290029292900292929002929
      2900636331004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008C8C8C00292929009494
      9400CECE9C00CECECE00CE9C6300633100002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000029292900D6D6D600FFFFFF00FFFFFF00FFEFCE00CE9C6300292929000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000424242004242420094949400CECE9C00CECECE00CE9C63006331
      0000424242004242420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000031313100D6D6
      D600FFFFFF00FFFFFF00FFEFCE00CE9C63002929290000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000002929290029292900292929002929290029292900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000042424200DEDEDE00FFFFFF00FFFFFF00FFEFCE00CE9C
      6300424242000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002929
      2900292929002929290029292900737373000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000424242004242420042424200424242004242
      4200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FE01FE0100000000
      FC01FC0100000000F181F18100000000E101E10900000000C521C58900000000
      C521C58100000000C569C50900000000C5FBC5FB00000000C403C40300000000
      C01FC01F00000000C01FC01F00000000E03FE03F00000000F07FF07F00000000
      FFFFFFFF00000000FFFFFFFF00000000FFFFFFFFFFFFFFFFFFFFFFFFFF87FE01
      F03FF02FF807FC01E01FE007F00FF1B9E20FE207E20FE119E20FE207E20FC519
      E00FE003E209C549E20FE207E201C4E1C00FC003E203C5F3800F8001E00FC403
      800F8001E00FC01F801F8001F01FC01FC03FC003F83FE03FE3FFE3C7FFFFF07F
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC01FFFFFFFFF07FFC01FFFF
      FE3FE001F801F82FFFABE001F801F007E0B7E0018001E207C02BC0018001E207
      881F80018001E203883F80018001E207883F80018001E203881780018001E001
      88078003823FE001803F8007803FF001803F803F803FF803C07FC07FC07FFFC7
      E0FFE0FFE0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80FF9FFFFFFFFF
      FF00F00FFD1FFEFBFE00F007F803FE8BE000E003E003E003C000C003C001C007
      88008007800188038801800F804188078003801F80018803800F883F8803880B
      883F883F8803880B803F803F8017801F803F803F801F803FC07FC07FC07FC07F
      E0FFE0FFE0FFE0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF07FFFFE00F
      FFFFFE03FFFFE00FFFFFFC41F83F800FFFFFE041F01F800FFFFFC041E20F8007
      FFFF8801E20F8003FFFF8801E20F8003FFFF8801E20F8003FFFF8801E20F8003
      FFFF8803E00FF883FFFF8007E00FF803FFFF803FF01FF803FFFFC07FF83FFC07
      FFFFE0FFFFFFFE0FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object CollectionImageList: TImageList
    Left = 64
    Top = 336
    Bitmap = {
      494C010115001900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000006000000001002000000000000060
      0000000000000000000000000000000000000000000033009900333399003333
      6600330066003300660033006600330066003300660033006600330066003333
      6600333366000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC00807CFF009999FF009999
      FF009966FF009966CC009966CC009966CC006666CC006666CC006666CC006666
      CC006666CC006633CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC00C6D6EF00F8F8F800EAEA
      EA00DDDDDD00CCCCCC00CCCCCC00C0C0C000C0C0C000B2B2B200B2B2B200B2B2
      B2009999CC006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC00C6D6EF00EAEAEA00D7D7
      D700CBCBCB00CCCCCC00CCCCCC00CBCBCB00CBCBCB00CBCBCB00CBCBCB00C0C0
      C0009999CC006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC00C6D6EF00DDDDDD009999
      CC006666CC009999CC00CCCCCC00CCCCCC00D7D7D700D7D7D700D7D7D700CCCC
      CC00C0C0C0006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC009999CC00CCCCCC00C0C0
      C0006666CC006666CC00CBCBCB00DDDDDD00EAEAEA00F1F1F100EAEAEA00DDDD
      DD00C6D6EF006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC009999CC00CBCBCB00CCCC
      CC00CBCBCB009999FF006666CC00EAEAEA00F8F8F800FFFFFF00F8F8F800F1F1
      F100CCCCFF009999CC009999CC00EAEAEA000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC009999CC00C0C0C000CBCB
      CB00CCCCCC00DDDDDD009999FF009999FF009999FF009999FF009999FF009999
      FF009999FF006666CC006666CC00333399000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC009999CC00B2B2B200CBCB
      CB00D7D7D700EAEAEA00F1F1F1006666FF00F8F8F800F1F1F1009999FF005050
      FF006666FF006666CC006666FF00CCCCFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333CC009999CC00B2B2B200CBCB
      CB00D7D7D700EAEAEA00F1F1F1009999FF009999FF00CCCCFF00807CFF00F8F8
      F800F1F1F1009999CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006633CC0096969600A4A0A000C0C0
      C000D7D7D700DDDDDD00F1F1F100F1F1F1006666FF00807CFF00F8F8F800FFFF
      FF00CCCCFF006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006633CC009696960099999900B2B2
      B200CBCBCB00D7D7D700DDDDDD00F1F1F100807CFF009999FF00F8F8F800F1F1
      F100C6D6EF006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006633CC006666CC00996699009966
      99009999CC009999CC009999CC009999CC00807CFF009999FF009999CC009999
      CC00807CFF006666CC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006666CC006666CC006666
      CC006666CC006666CC006666CC009999FF003333CC006666CC006666CC006666
      CC006666CC000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000807CFF009999FF006666CC00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006666FF00807CFF00000000000000
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
      00000000000000000000008CBD00008CBD00008CBD00008CBD00008CBD00008C
      BD00008CBD00008CBD00008CBD00000000000000000000000000000000000000
      0000ADADAD00A5ADAD000000000000000000ADADAD007B9C7B00297B29001073
      1000739C73000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000737373007373
      73007373730052525200000000000000000000000000D6840000000000000000
      0000E78400000000000000842100108421001084210010842100108421001084
      2100108421000000000000000000000000000000000000000000000000006363
      630063636300008CBD0052C6EF00008CBD00BDEFFF006BD6FF0073D6FF0073D6
      FF0073D6FF005ACEF70084D6EF00008CBD000000000000000000A5ADAD005A94
      AD0010739C000073A5005A8CB50063A5630018841800007B000000840000008C
      0800006B00004A8C4A00ADADAD00000000000000000000000000000000000000
      0000000000009C5218009C4A18008C4A21006B4A310042424200D6D6DE00B5B5
      B500ADA5AD00ADA5A5006B6363000000000000000000D6840000D6840000D684
      0000E78400000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000636363006B6B
      6B0073737300008CBD005ACEEF00008CBD00C6F7FF007BDEFF007BDEFF007BDE
      FF007BDEFF0063CEF7008CD6EF00008CBD0000000000639CB500007BAD000084
      B5000094C6000884B5000063AD0000841000008C000000940000009C080018AD
      210000730000006B00004A844A0000000000000000000000000000000000C66B
      1000C66B1000C66B100052735A0039A53100297B39009C9C9C009C9C9C00B5B5
      B5009C949C00847B8400636363000000000000000000D6840000000000000000
      0000E78400000000000000842100108421001084210010842100108421001084
      21001084210010842100108421000000000000000000636363009C9C9C006B6B
      6B0073737300008CBD006BD6F700008CBD00CEFFFF008CEFFF008CEFFF008CEF
      FF008CEFFF0073DEF70094DEEF00008CBD0000000000218CB500009CCE0000A5
      D60000ADDE001894BD000063AD000094100008AD100010AD210018B5310031C6
      52000073000000730000317B3100000000000000000000000000E7840000EF84
      0000F78400008C9421000863A5000063B50039739400C6BDB500B5ADAD009C9C
      A5008484940052525A0000000000000000000000000000000000DE840000DE84
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300A5A5A500D6CED6006B6B
      6B007B737B00008CBD007BDEF700008CBD00C6EFF700C6EFF700C6EFF700C6EF
      F700C6EFF700BDE7F700C6EFF700008CBD00000000001894C60000ADE70000B5
      E70008C6F700219CC600006BB500109C310021BD390021BD4A0029C6520042DE
      730000730000007B0000217B21000000000000000000F7940800F7940800FF9C
      1000F7941800CE9C210010639400086BCE00086BC6001063AD00949C8400FFCE
      7B00EFC69400D6BDA500948C8C00525252000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300DED6DE00C6C6C6006B6B
      6B007B7B7B00008CBD0084EFFF00008CBD00008CBD00008CBD00008CBD00008C
      BD00008CBD00008CBD00008CBD00000000000000000010A5D60000C6FF0000CE
      FF0008E7FF0029A5C6000073B50010A54A0031DE6B0039DE730052EF8C006BFF
      A50008940800007B0000187B18000000000000000000FF9C2100F7A53100E79C
      4200847B6B00316B8C00106BB500188CEF001894FF00086BCE000863B500FFBD
      3900FFBD3900FFBD4200FFB53900636363000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300DED6DE00C6BDC6006B6B
      6B007B7B7B00008CBD008CEFFF00ADFFFF00B5FFFF00B5FFFF00B5FFFF00B5FF
      FF00BDFFFF00008CBD0000000000000000000000000008BDE70000FFFF0021FF
      FF0031FFFF0029E7FF00007BBD00426B2900849442005AFF9C0052FF940052F7
      7B0052EF7B0021BD3900087B080000000000F7A52900FFAD4200FFB55A007384
      8C00186BB5002184D60039ADFF00319CF700299CFF00086BC6008C9C8C00FFD6
      6B00FFCE6B00FFCE5A00FFB5390052525200000000009C3100009C3100009C31
      00009C3100009C3100009C3100009C3100009C3100009C3100009C3100009C31
      00009C3100009C3100009C3100000000000063636300DEDEDE00C6BDC6006B6B
      6B007B7B7B00008CBD00DEFFFF00DEFFFF0094F7F70042BDDE00008CBD00008C
      BD00008CBD00008CBD0000000000000000000000000021BDCE0010DEFF0000D6
      FF0039949C009C5A1800CE420000CE520000BD420000AD2100007373210029C6
      420018B5290031B5390063A56B0000000000FFAD420094B54A0063AD5A002173
      B5002994E700319CE700217BC6002984C600187BD6001063AD00FFDE8400FFE7
      9400FFDE8C00FFDE7B00F7C652004A4A4A00000000009C3100009C3100009C31
      00009C3100009C3100009C3100009C3100009C3100009C3100009C3100009C31
      00009C3100009C3100009C3100000000000063636300E7DEE700CEC6CE006B6B
      6B00848484006B6B6B00008CBD00008CBD00008CBD00008CBD00000000000000
      00000000000000000000000000000000000000000000ADADAD0084A5B5004AA5
      C600C6630000DE6B0000D66B0000DE730000BD631800AD420000AD3100009C39
      1000ADADAD00000000000000000000000000F7B552004ABD420008945A001873
      C600218CE70010639C0010945A00105A7B000863BD009CA58C00FFF79C00FFFF
      B500FFF7AD00FFE78C00F7C66300424242000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300EFE7E700CEC6CE006B73
      73009494940073737300848484007B7B7B008C8C8C005A5A5A00000000000000
      000000000000000000000000000000000000000000000000000000000000B59C
      9400DE6B0000E77B0000E77B0000E77B0000CE732100AD420000AD420000B542
      080000000000000000000000000000000000FFBD6300CEC6730031A56300106B
      BD001073BD001894520021BD3900217B5200295A9400A59C8C00ADAD9400BDB5
      A500D6BD9400E7C68400E7C67300393939000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300F7F7F700D6D6D6006B73
      730094949400848484009C9C9C0094949400A5A5A50063636300000000000000
      000000000000000000000000000000000000000000000000000000000000B59C
      8C00E7840000EF840000EF840000F78C0000D67B3100B54A0000AD4A0000B542
      0000ADADAD0000000000000000000000000000000000FFCE9400EFD6AD00216B
      A500106BA50018B5310018BD390031A53900A5845200946B3900846331007B6B
      42004A735A004A525200525252000000000000000000DE840000000000000000
      0000E78400000000000000842100088421000884210008842100088421000884
      21000884210000000000000000000000000063636300E7E7E700ADADAD006B73
      7300B5B5B50073737300737B7B00948C9400A5A5A50063636300000000000000
      000000000000000000000000000000000000000000000000000000000000B59C
      8C00F78C0000FF940000FF940000FF9C0000DE8C3900BD4A0000B54A0000AD42
      0000ADADAD00000000000000000000000000000000008CC66300FFD6AD007394
      B5001863A50010A5420018B5390021BD39005AC64A0063BD4200FF9C210084A5
      210010B5310000000000000000000000000000000000D6840000D6840000D684
      0000E78400000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000063636300B5B5B500E7E7E700ADAD
      AD0094949400949C9C00A5A5A5007B7B84007B7B7B0063636300000000000000
      000000000000000000000000000000000000000000000000000000000000B59C
      8C00FFB55200FFC67300FFCE8400FFCE9400F7BD7B00D67B2900BD5A0800B54A
      0000ADA5A500000000000000000000000000000000000000000084C66300D6C6
      AD0039739C0021AD420018B5390021B5390010B5390042B53900FF9C180063AD
      29000000000000000000000000000000000000000000D6840000000000000000
      0000E78400000000000000842100108421001084210010842100108421001084
      21001084210010842100108421000000000063636300FFFFFF00F7F7FF00EFEF
      EF00CECECE00B5B5B5009C9C9C009C9C9C009C9C9C006B6B6B00000000000000
      000000000000000000000000000000000000000000000000000000000000ADAD
      AD00C6946B00CE946300CE8C4A00CE843900CE7B3100C67B3900C67B4A00B57B
      52000000000000000000000000000000000000000000000000000000000094C6
      6300ADC6730018B5390021B5390018B5390018B53900BDA52900FF9408000000
      0000000000000000000000000000000000000000000000000000D6840000D684
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840063636300FFFFFF00FFFF
      FF00F7F7FF00E7DEE700B5B5B500636363006363630000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000021B5390021B5390018B5390084AD310000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000636363006363
      6300636363006363630063636300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000009C3100009C31
      00009C3100000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000189400001894000000
      0000000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BD9C7B000000000000000000C6AD7B00FF9C0000FF9C
      0000FF9C0000FF9C0000FF9C0000FFE7BD00A5947B007B7B73009C5A31007B73
      73009C8C6B00FFDEA500C6AD7B00000000000000000000000000000000000884
      AD000884AD000884AD000884AD006B4A31007B4A2900AD4A0000AD4A0800FFB5
      5A00D68C42009C3100009C310000000000000000000000000000000000000000
      000000000000000000000000000000000000001894001039C6002142E7000018
      9400000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BD9C7B000000000000000000FF9C0000FFE7E700FFE7
      E700FFE7E700FFE7E700FFE7E700FFEFEF0084848400F7DECE00AD420000C673
      390084848400FFDEDE00FF9C0000000000000000000000000000008CBD004AD6
      EF0021D6FF0031DEFF006BE7FF009C421000B54A0800FFA51000FFA51800FFB5
      4200FFC66300FFCE84009C310000000000000000000000000000000000000000
      0000000000000000000000000000001894001039C6002142E7008C9CF7001039
      C600000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C
      9C00CE9C9C00FFFFFF00BD9C7B000000000000000000FF9C0000FFEFEF00FFEF
      EF00FFEFEF00FFEFEF00FFE7E700FFF7F70094948C00B5632900AD420000B54A
      0000B56B3900FFCECE00FF9C00000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF0073DEEF00A5521800AD420800FFB54200DE7B0800B552
      0800C66B2100FFC663009C310000000000000000000000000000000000000000
      00000000000000000000001894001039C6002142E7008C9CF7001039C6000000
      0000000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BD9C7B000000000000000000FF9C0000FFF7F700FFF7
      F700FFF7F700FFEFEF00FFEFEF00FFF7F700B5734A00AD420000BD6B3900BD63
      2100C65A0000F7BD9C00FFB54A000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF009C633100AD4A0800E7B58400FFCE7B00845231009C31
      00009C390000EF9C3900F7B55A009C3100000000000000000000000000000000
      000000000000001894001039C6002142E7008C9CF7001039C600000000000000
      0000000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C
      9C00CE9C9C00FFFFFF00BD9C7B000000000000000000FF9C0000FFF7F700FFF7
      F700FFF7F700FFF7F700FFF7F700FFFFFF00B5633100B5733900C6C6C600BD94
      7300C6630800CE6B0000FFB54A000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF009C633100B5520800EFC69400FFDEAD00845A39009C31
      0000A5420000EF942100FFAD42009C3100000000000000000000000000000000
      0000001894001039C6002142E7008C9CF7001039C60000000000000000000000
      0000000000000000000029A5F700088CAD000000000000000000BD9C7B00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BD9C7B000000000000000000FF9C0000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFF7F700FFFFFF00F7D6C600FFF7EF00FFF7F700FFF7
      F700E7A56B00D66B0000E77B00000000000000000000008CBD00B5FFFF00B5F7
      FF00C6F7FF00E7FFFF00E7EFEF00BD632100BD5A0800FFE7B500EFC68C00B55A
      2100CE731800FF9C08009C310000000000000000000000000000000000000018
      94001039C6002142E7008C9CF7001039C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C
      9C00CE9C9C00FFFFFF00BD9C7B000000000000000000FF9C0000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFF7F700FFF7F700FFEFEF00FFE7E700FFE7
      E700FFF7F700E7944A00DE7300000000000000000000008CBD00BDEFF70031BD
      DE0010A5D600109CCE0021A5CE00B55A0800C66B2100FFE7B500FFE7B500FFDE
      A500FFC66B00FFAD31009C310000000000000000000000000000088CAD001039
      C6002142E7008C9CF7001039C600000000000000000000000000000000000000
      0000088CAD000000000000000000000000000000000000000000BD9C7B00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00BD9C7B000000000000000000FF9C0000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFF7F700FFF7F700FFEFEF00FFE7E700FFE7
      E700FFE7E700FFF7F700E78408000000000000000000008CBD004AC6DE005AEF
      FF0021D6FF0031DEFF006BE7FF00A57B4A00946B42009C4A2100BD632100FFD6
      AD009C3100009C3100009C3100000000000000000000088CAD0000BDEF0000CE
      FF008C9CF7001039C600000000000000000000000000000000000000000029A5
      F700A5F7FF00088CAD00000000000000000000000000BD9C7B00BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B000000000000000000FF9C0000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFF7F700FFF7F700FFEFEF00FFE7E700FFE7
      E700FFDEDE00FFE7E700FFDEA5000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF006BE7FF008CE7FF004AC6E700317B8C00B54A00009C31
      00000000000000000000000000000000000000000000009CCE00A5F7FF0000CE
      FF0000CEFF00000000000000000029A5F7000000000052BDDE00000000000000
      000029A5F70000000000000000000000000000000000BD9C7B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFCE
      BD00FFCEBD00FFCEBD00BD9C7B000000000000000000FF9C0000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFF7F700FFF7F700FFEFEF00FFE7E700FFE7
      E700FFDEDE00FFD6D600FF9C00000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF006BE7FF008CE7FF004AC6E700089CCE000884AD000000
      0000000000000000000000000000000000000000000000000000009CCE0029BD
      E70000000000000000000000000029A5F700088CAD0039A5C600000000000000
      00000000000000000000000000000000000000000000BD9C7B00FFFFFF00CE9C
      9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00CE9C9C00FFFFFF00FFD6
      BD0084634A00FFD6BD00BD9C7B000000000000000000FF9C0000D6D6D600D6D6
      D600D6D6D600D6D6D600D6D6D600D6CECE00D6CECE00D6C6C600D6C6C600D6BD
      BD00D6BDBD00D6B5B500FF9C00000000000000000000008CBD008CFFFF005AEF
      FF0021D6FF0031DEFF006BE7FF008CE7FF004AC6E700089CCE000884AD000000
      00000000000000000000000000000000000000000000088CAD000000000052BD
      DE00000000000000000029A5F70029A5F700A5F7FF0039A5C600088CAD000000
      00000000000000000000000000000000000000000000BD9C7B00FFFFFF00DEB5
      B500DEB5B500DEB5B500DEB5B500DEB5B500DEB5B500DEB5B500FFFFFF008463
      4A00FFD6BD0084634A00BD9C7B000000000000000000FF9C0000FF9C0000EF84
      0000EF840000EF840000EF840000EF840000EF840000EF840000EF840000EF84
      0000EF840000F7940000FF9C00000000000000000000008CBD0094FFFF0084FF
      FF006BFFFF007BFFFF0094FFFF00A5FFFF0063DEF70008A5D6000884AD000000
      0000000000000000000000000000000000000000000029A5F700088CAD00088C
      AD000000000000000000000000000000000029A5F70000000000000000000000
      00000000000000000000000000000000000000000000BD9C7B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFDE
      D600FFDED600FFDED600BD9C7B000000000000000000FF9C0000FFCE9C00FFCE
      9C00FFCE9C00FFCE9C00FFCE9C00FFCE9C00FFCE9C00FFCE9C00FFCE9C00FFCE
      9C00FFCE9C00FFAD3900FF9C00000000000000000000008CBD00FFFFFF00F7FF
      FF00D6FFFF00B5FFFF00B5FFFF00ADFFFF00ADFFFF006BFFFF000884AD000000
      00000000000000000000000000000000000029A5F700A5F7FF0042DEFF0042DE
      FF00088CAD000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BD9C7B00BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C7B00BD9C
      7B00BD9C7B00BD9C7B00BD9C7B000000000000000000C6AD7B00FF9C0000FF9C
      0000FF9C0000FF9C0000FF9C0000FF9C0000FF9C0000FF9C0000FF9C0000FF9C
      0000FF9C0000FF9C0000C6AD7B000000000000000000000000000894C600F7FF
      FF00E7FFFF00C6FFFF00ADFFFF00A5FFFF009CFFFF001084AD00000000000000
      0000000000000000000000000000000000000000000029A5F700A5F7FF00088C
      AD00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000008C
      BD00008CBD00008CBD00008CBD00008CBD00008CBD0000000000000000000000
      000000000000000000000000000000000000000000000000000029A5F7000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000B584
      8400B5848400B5848400B5848400B5848400B5848400B5848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000063
      0000000000000000000000000000000000000000000000000000000000000063
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000B584
      8400EFDEC600FFEFD600B5D69C00CED6AD00EFDEB500F7D6B500B5848400B584
      8400B5848400B584840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000063000021B5
      39000063000000000000000000000000000000000000000000000063000021B5
      390000630000000000000000000000000000FFA55200FFA55200FFA55200FFA5
      5200FFA55200FFA55200FFA55200FFA55200FFA55200FFA55200FFA55200FFA5
      5200FFA55200FFA55200FFA55200FFA55200000000000000000000000000B584
      8400EFD6C600FFEFD60029AD4A0029AD4A005AB56300E7D6AD00FFDEBD00EFD6
      AD00DED69C00E7CE9C00B5848400B58484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000063000039CE630029BD
      4A0021B53100006300000000000000000000000000000063000039CE630029BD
      4A0021B53100006300000000000000000000FFA55200FFFFFF00FFFFFF00FFA5
      5200FFE7B500FFE7B500FFF7E700FFA55200FFE7B500FFE7B500FFF7E700FFA5
      5200FFE7B500FFE7B500FFF7E700FFA55200000000000000000000000000BD8C
      8400F7DEC600FFEFDE0031AD4A0010A5390021AD4200D6D6AD00FFDEBD00CECE
      9C0031AD4A0010A53900ADC67B00B58484000000000000000000A56B6B00A56B
      6B00A56B6B00A56B6B00A56B6B00A56B6B00A56B6B00A56B6B00A56B6B00A56B
      6B00A56B6B00A56B6B00A56B6B0000000000006300005AE78C0042D66B0039C6
      5A0029BD420021B531000063000000000000006300005AE78C0042D66B0039C6
      5A0029BD420021B531000063000000000000FFA55200FFFFFF00FFFFFF00FFA5
      5200FFE7B500FFE7B500FFF7E700FFA55200FFE7B500FFE7B500FFF7E700FFA5
      5200FFE7B500FFE7B500FFF7E700FFA552000000000042B5DE0042B5DE00BD8C
      8400F7DEC600FFEFDE00CEDEB50063BD6B007BBD7B00F7DEBD00FFDEBD00DED6
      A50042B5520000A531009CC67B00B5848400000000009C5A6B00FFF7F700F7EF
      E700F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7DEBD00F7DE
      BD00F7DEBD00F7D6AD00F7D6AD00A56B6B0000000000006300005AE78C0042D6
      6B0039CE5A0000630000000000000000000000000000006300005AE78C0042D6
      6B0039CE5A00006300000000000000000000FFA55200FFFFFF00FFFFFF00FFA5
      5200FFA55200FFA55200FFA55200FFA55200FFA55200FFA55200FFA55200FFA5
      5200FFA55200FFA55200FFA55200FFA5520042B5DE007BDEF70094E7FF00CE9C
      8400F7DECE00FFF7E700FFEFE700DEDEC6006BBD7300EFE7C600FFE7C600F7DE
      BD0063B56300A5C68400EFD6A500B5848400000000009C5A6B00FFF7EF00FFF7
      F700F7EFE700F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7E7CE00F7DE
      BD00F7DEBD00F7DEBD00F7D6AD00A56B6B000000000000000000006300005AE7
      8C00006300000000000000000000000000000000000000000000006300005AE7
      8C0000630000000000000000000000000000FFA55200FFFFFF00FFFFFF00FFA5
      5200FFE7B500FFE7B500FFF7E700FFA55200FFE7B500FFE7B500FFF7E700FFA5
      5200FFE7B500FFE7B500FFF7E700FFA5520042B5DE0094E7FF00BDEFFF00CE9C
      8400F7DECE00FFF7EF00FFEFDE00FFEFDE00ADCE9C009CCE9400DEDEB500A5CE
      940084BD7B00F7DEB500F7DEB500B5848400000000009C636B00FFF7EF00FFF7
      EF00F7EFE700F7EFE700F7EFE700F7EFE700F7E7CE00F7E7CE00F7E7CE00F7E7
      CE00F7E7CE00F7DEBD00F7DEBD00A56B6B000000000000000000000000000063
      0000000000000000000000000000000000000000000000000000000000000063
      000000000000000000000000000000000000F78C4200F78C4200F78C4200F78C
      4200FFE7B500FFE7B500FFF7E700F78C4200FFE7B500FFE7B500FFF7E700F78C
      4200FFE7B500FFE7B500FFF7E700F78C420042B5DE009CE7FF00D6FFFF00DEAD
      8400F7DED600FFF7EF00FFEFE700FFEFDE00EFE7CE0052B5630021AD420052B5
      6300E7DEB500FFDEBD00F7DEB500B5848400000000009C636B00FFFFFF00FFF7
      EF00FFF7EF00FFF7EF00F7EFE700F7EFE700F7EFE700F7E7CE00F7E7CE00F7E7
      CE00F7E7CE00F7E7CE00F7DEBD00A56B6B000000000000000000000000000063
      0000000000000000000000000000000000000000000000000000000000000063
      000000000000000000000000000000000000F78C4200FFFFFF00FFFFFF00F78C
      4200F78C4200F78C4200F78C4200F78C4200F78C4200F78C4200F78C4200F78C
      4200F78C4200F78C4200F78C4200F78C420042B5DE009CE7FF00DEFFFF00E7B5
      8C00F7E7D600FFFFF700FFF7EF00FFF7E700EFE7D60042B55A00009C29004AB5
      5A00EFDEBD00FFDEC600F7DEBD00B584840000000000B5737300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFF7EF00FFF7EF00F7EFE700F7EFE700F7EFE700F7EF
      E700F7E7CE00F7E7CE00F7DEBD00A56B6B000000000000000000000000000063
      0000006B0000006B0000006B0000006B0000006B0000006B0000006B00000063
      000000000000000000000000000000000000F78C4200FFFFFF00FFFFFF00F78C
      4200FFE7B500FFE7B500FFF7E700F78C4200FFE7B500FFE7B500FFF7E700F78C
      4200FFE7B500FFE7B500FFF7E700F78C420042B5DE009CE7FF00DEFFFF00EFBD
      9400F7E7DE00FFFFFF00FFFFF700FFF7EF00F7F7E700A5D6A50084CE8C00ADD6
      9C00F7E7CE00FFE7C600FFE7C600B584840000000000B5737300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFF7EF00FFF7EF00FFF7EF00F7EFE700F7EF
      E700F7EFE700F7E7CE00F7E7CE00A56B6B000000000000000000000000000000
      0000000000000000000000000000004A18000000000000000000000000000000
      000000000000000000000000000000000000EF841000FFFFFF00FFFFFF00EF84
      1000FFE7B500FFE7B500FFF7E700EF841000FFE7B500FFE7B500FFF7E700EF84
      1000FFE7B500FFE7B500FFF7E700EF84100042B5DE009CE7FF00DEFFFF00EFBD
      9400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD8400DEAD
      8400DEAD8400DEAD8400DEAD8400B584840000000000C67B7300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7EF00FFF7EF00FFF7
      EF00FFF7EF00FFF7EF00F7EFE700A56B6B000000000000000000000000000000
      000000009C0000009C0000009C0000009C0000009C0000009C0000009C000000
      000000000000000000000000000000000000EF841000EF841000EF841000EF84
      1000EF841000EF841000EF841000EF841000EF841000EF841000EF841000EF84
      1000EF841000EF841000EF841000EF84100042B5DE009CE7FF00E7FFFF00D6E7
      E700ADD6D600A5D6D6008CCED60042B5DE000000000000000000000000000000
      00000000000000000000000000000000000000000000C67B7300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFF7EF00FFF7EF00FFF7EF00A56B6B000000000000000000000000000000
      000000009C001042F7000039FF000029FF000021E7000010C60000009C000000
      000000000000000000000000000000000000EF841000FFFFFF00FFFFFF00EF84
      1000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EF841000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00EF84100042B5DE0094E7F700C6EFFF00ADEF
      FF007BE7FF0073E7FF006BE7FF0042B5DE000000000000000000000000000000
      00000000000000000000000000000000000000000000CE847B00FFA53900FFA5
      3900FFA53900FFA53900FFA53900FFA53900FFA53900FFA53900FFA53900FFA5
      3900FFA53900FFA53900FFA53900000000000000000000000000000000000000
      000000009C002952F7001852FF000039FF000029FF000018DE0000009C000000
      000000000000000000000000000000000000EF841000FFFFFF00FFFFFF00EF84
      1000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EF841000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00EF84100042B5DE0042B5DE0042B5DE0042B5
      DE0042B5DE0042B5DE0042B5DE0042B5DE000000000000000000000000000000
      00000000000000000000000000000000000000000000D68C7B00FFA53900FFA5
      3900FFA53900FFA53900A56B6B00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000009C003963F700316BFF001852FF000842FF000029EF0000009C000000
      000000000000000000000000000000000000EF841000EF841000EF841000EF84
      1000EF841000EF841000EF841000EF841000EF841000EF841000EF841000EF84
      1000EF841000EF841000EF841000EF84100042B5DE0042B5DE007BDEEF007BDE
      F70073DEF70063D6EF0039B5D60042B5DE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000D68C7B00D68C
      7B00D68C7B00D68C7B0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000009C004273F7005284FF003973FF002163FF000842F70000009C000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000042B5DE0042B5DE0042B5
      DE0042B5DE0039B5DE0042B5DE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000009C0000009C0000009C0000009C0000009C0000009C0000009C000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000884AD000884
      AD000884AD000884AD000884AD00000000000000000000000000000000000000
      0000848484008484840084848400848484008484840084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484840084848400848484008484840084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000884AD0063DEEF0031E7
      FF0042E7FF0094F7FF0039B5DE000884AD000000000000000000000000000000
      00008484840084FF000084FF000084FF000084FF000084FF0000848484000000
      000000000000000000000000000000000000A5522100944A2100944A2100944A
      2100944A2100944A2100944A2100944A2100944A2100944A2100944A2100944A
      2100944A2100944A2100A5522100000000000000000000000000000000000000
      00008484840084FF000084FF000084FF000084FF000084FF0000848484000000
      000000000000000000000000000000000000A5522100944A2100944A2100944A
      2100944A2100944A2100944A2100944A2100944A21000884AD007BFFFF0021DE
      FF0031DEFF0084EFFF0031B5E7000884AD000000000000000000000000000000
      00008484840084FF000000000000000000000000000084FF0000848484000000
      00000000000000000000000000000000000084422100FFF7EF00FFF7E700FFEF
      D600FFEFCE00FFE7C600FFE7C600FFDEBD00FFDEBD00FFDEBD00FFDEBD00FFDE
      BD00FFDEBD00FFDEBD00944A2100000000000000000000000000000000000000
      00008484840084FF000000000000000000000000000084FF0000848484000000
      00000000000000000000000000000000000084422100FFF7EF00FFF7E700FFEF
      D600007B0000FFE7C600FFE7C600FFDEBD00FFDEBD000884AD00B5FFFF00B5EF
      FF00CEF7FF00D6F7FF0094DEEF000884AD008484840084848400848484008484
      84008484840084FF00000000000084FF000084FF000084FF0000848484000000
      0000000000000000000000000000000000007B422100FFFFF700FFF7EF00FFF7
      E700FFEFDE00FFEFD600FFE7CE00FFE7C600FFDEBD00FFDEBD00FFDEBD00FFDE
      BD00FFDEBD00FFDEBD008C4A2100000000008484840084848400848484008484
      84008484840084FF00000000000084FF000084FF000084FF0000848484000000
      0000000000000000000000000000000000007B422100FFFFF700FFF7EF00FFF7
      E700007B0000FFEFD600FFE7CE00FFE7C600FFDEBD000884AD007BCEE70029AD
      D600219CC60042ADCE0063B5D6000884AD008484840000FFFF0000FFFF0000FF
      FF008484840084FF000000000000000000000000000084FF0000848484000000
      00000000000000000000000000000000000084422100FFFFFF0000009C000000
      9C0000009C00FFEFDE00AD4A2100AD4A2100AD4A2100AD4A2100AD4A2100AD4A
      21008C521800087308008C4A2100000000008484840000FFFF0000FFFF0000FF
      FF008484840084FF000000000000000000000000000084FF0000848484000000
      00000000000000000000000000000000000084422100007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B00000884AD0052D6E70029D6
      F70042DEFF0084E7F70029ADD6000884AD008484840000FFFF00000000000000
      00008484840084FF000084FF000084FF00000000000084848400848484008484
      84008484840084848400848484008484840084422100FFFFFF00FFFFFF00FFFF
      F700FFF7EF00FFF7E700FFEFDE00FFEFD600FFE7CE00FFE7C600FFE7BD00CEC6
      940008730800087308008C4A2100000000008484840000FFFF00000000000000
      00008484840084FF000084FF000084FF00000000000084848400848484008484
      84008484840084848400848484008484840084422100FFFFFF00FFFFFF00FFFF
      F700007B0000FFF7E700FFEFDE00FFEFD600FFE7CE000884AD007BF7FF0029DE
      FF0039DEFF008CE7FF0031BDDE000884AD008484840000FFFF0000FFFF000000
      00008484840084FF000000000000000000000000000084848400FF840000FF84
      0000FF840000FF840000FF840000848484007B421800FFFFFF00FFFFFF00FFFF
      FF00FFFFF700FFF7F700FFF7EF00FFF7E700FFEFD600FFEFD600CECEA5000873
      080031C652000873080008730800087308008484840000FFFF0000FFFF000000
      00008484840084FF000000000000000000000000000084848400FF840000FF84
      0000FF840000FF840000FF840000848484007B421800FFFFFF00FFFFFF00FFFF
      FF00007B0000FFF7F700FFF7EF00FFF7E700FFEFD6000884AD009CFFFF006BFF
      FF0084FFFF00ADFFFF0052D6F7000884AD008484840000FFFF0000FFFF000000
      00008484840084FF000084FF000084FF000084FF000084848400FF8400000000
      00000000000000000000FF840000848484007B421800FFFFFF0000009C000000
      9C0000009C00FFFFFF00AD4A2100AD4A2100AD4A2100AD4A21000873080052DE
      7B004AD66B0031C6520021B53100087308008484840000FFFF0000FFFF000000
      00008484840084FF000084FF000084FF000084FF000084848400FF8400000000
      00000000000000000000FF840000848484007B421800FFFFFF00FFFFFF00FFFF
      FF00007B0000FFFFFF00FFFFF700FFF7EF00FFF7E7000884AD00D6F7F700FFFF
      FF00DEFFFF00CEFFFF009CFFFF000884AD008484840000FFFF00000000000000
      0000848484008484840084848400848484008484840084848400FF840000FF84
      0000FF84000000000000FF8400008484840084422100FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700FFF7EF00FFF7E700CED6B5000873
      080052DE7B000873080008730800087308008484840000FFFF00000000000000
      0000848484008484840084848400848484008484840084848400FF840000FF84
      0000FF84000000000000FF8400008484840084422100007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B0000007B00000884AD000884
      AD000884AD000884AD000884AD00000000008484840000FFFF0000FFFF000000
      000000FFFF0000FFFF0084848400000000000000000084848400FF8400000000
      00000000000000000000FF840000848484007B391800FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFF700FFF7EF00FFF7E700CED6
      B50008730800087308008C422100000000008484840000FFFF0000FFFF000000
      000000FFFF0000FFFF0084848400000000000000000084848400FF8400000000
      00000000000000000000FF840000848484007B391800FFFFFF00FFFFFF00FFFF
      FF00007B0000FFFFFF00FFFFFF00FFFFFF00FFFFF700007B0000FFF7E700FFEF
      DE00FFEFD600FFE7CE008C422100000000008484840000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0084848400000000000000000084848400FF840000FF84
      0000FF84000000000000FF8400008484840084422100E7E7E700E7E7E700E7E7
      E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7
      DE00B5C6AD0008730800944A2900000000008484840000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0084848400000000000000000084848400FF840000FF84
      0000FF84000000000000FF8400008484840084422100E7E7E700E7E7E700E7E7
      E700007B0000E7E7E700E7E7E700E7E7E700E7E7E700007B0000E7E7E700E7E7
      DE00E7DED600E7DECE00944A2900000000008484840084848400848484008484
      8400848484008484840084848400000000000000000084848400FF8400000000
      00000000000000000000FF84000084848400AD5A2100AD632100AD5A2100AD5A
      2100AD5A2100AD5A2100AD5A2100AD5A2100AD5A2100AD632100AD632100AD63
      2100AD632100AD6329008C4A2100000000008484840084848400848484008484
      8400848484008484840084848400000000000000000084848400FF8400000000
      00000000000000000000FF84000084848400AD5A2100AD632100AD5A2100AD5A
      2100AD5A2100AD5A2100AD5A2100AD5A2100AD5A2100AD632100AD632100AD63
      2100AD632100AD6329008C4A2100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400FF840000FF84
      0000FF840000FF840000FF84000084848400AD5A2100EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100EF943100EF943100EF943100EF94
      3100EF943100EF943100BD5A1800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400FF840000FF84
      0000FF840000FF840000FF84000084848400AD5A2100EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100EF943100EF943100EF943100EF94
      3100EF943100EF943100BD5A1800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484008484
      84008484840084848400848484008484840000000000CE731800CE731800CE73
      1800CE731800CE731800CE731800CE731800CE731800CE731800CE731800CE73
      1800CE731800CE73180000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484008484
      84008484840084848400848484008484840000000000CE731800CE731800CE73
      1800CE731800CE731800CE731800CE731800CE731800CE731800CE731800CE73
      1800CE731800CE73180000000000000000000000000000000000000000000000
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
      000000639C0000639C0000639C0000639C0000639C0000639C0000639C000063
      9C0000639C0000639C0000639C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C64A100000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BD4A0000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A0000BD4A00000000000000000000000000000063
      9C002194BD004AE7FF0000BDFF0000BDFF0000BDFF0000BDFF0000BDFF0000BD
      FF0000BDFF0000BDFF00008CBD0000639C0000000000B5848400A57B7300A57B
      7300A57373009C7373009C736B009C736B009C736B009C737300A5737300A57B
      7300A57B73009C6B630000000000000000000000000000000000000000000000
      00000884AD004A636B00C64A10004A5A5A000884AD000884AD00000000000000
      000000000000000000000000000000000000BD4A0000FFFFFF00FFF7F700FFF7
      EF00FFEFE700F7E7D600F7E7D600F7E7CE00F7DEBD00F7DEB500F7D6B500F7D6
      AD00EFCEA500EFCE9C00EFC69400BD4A0000A5522100944A2100B57B6300107B
      A5006BDEEF002194BD00216B9400397B9C00397B9C00397B9C0000639C00106B
      9400216B9400008CBD0008BDEF000073A50000000000B5848400FFEFDE00F7E7
      CE00E7D6B500D6BDA500CEB59400CEB58C00CEAD8C00CEB58400E7C68C00EFCE
      9400F7D69C009C6B63000000000000000000000000000000000000000000008C
      BD004AD6EF0021D6FF008C634200C64A1000948C840042BDDE000884AD000000
      000000000000000000000000000000000000BD4A0000FFFFFF00FFFFFF00FFF7
      EF00FFEFE700F7E7D600F7E7D600F7E7CE00F7DEBD008400000084000000F7D6
      AD000000FF000000FF00EFC69400BD4A0000AD4A2100FFF7EF00FFF7EF001073
      A50094FFFF00187BA500FFEFD600FFEFD600EFE7CE0000639C0008A5D600217B
      A500FFEFD600107BA50000CEFF000073A50000000000B5847300FFF7E700EFDE
      CE000884AD000884AD000884AD000884AD000884AD00C6AD8400CEB58400E7C6
      9400F7D69C009C6B630000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0042C6DE009C5A2900BD5A10006B847B00089CCE000884
      AD0000000000000000000000000000000000BD4A0000FFFFFF00FFFFFF00FFFF
      FF00FFFFF700FFF7E700FFF7E700FFEFDE00F7E7D6008400000084000000F7DE
      BD000000FF000000FF00EFCEA500BD4A0000AD4A2100FFFFF700FFFFF700187B
      AD009CFFFF002994B500297BA5003984A50000639C0042DEFF0021BDE7001873
      9C00297BA5000084B50000CEFF000073AD0000000000B5847300FFF7EF000884
      AD0063DEEF0031E7FF0042E7FF0094F7FF0039B5DE000884AD00CEAD8C00E7C6
      9400F7D69C009C6B630000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0031DEFF00849C9400AD5A2900C64A10005A5A5A00107B
      A50000000000000000000000000000000000BD4A0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFF700FFF7EF00FFEFE700F7EFDE00F7E7D600F7E7CE00F7DE
      C600F7DEBD00F7DEB500F7D6AD00BD4A0000AD4A2100D6840000E7B56300427B
      8C0039A5C6009CFFFF0084FFFF0084FFFF0084FFFF006BF7FF004AE7FF0029C6
      E70018BDE70008CEFF00008CC60000639C0000000000BD8C8400FFFFF7000884
      AD007BFFFF0021DEFF0031DEFF0084EFFF0031B5E7000884AD00CEB58C00E7C6
      9C00F7D69C009C6B630000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0031DEFF0073E7FF009C6B4A00CE844A00BD420000425A
      630000000000000000000000000000000000BD4A0000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF000000FFEFE7008400000084000000F7E7
      CE000000FF000000FF00F7D6B500BD4A0000AD4A2100FFFFFF00FFFFFF00E7EF
      F700397B8C0000639C0000639C0000639C009CFFFF008CFFFF0063E7F7000063
      9C0000639C0000639C00316B8C000000000000000000BD8C8400FFFFFF000884
      AD00B5FFFF00B5EFFF00CEF7FF00D6F7FF0094DEEF000884AD00CEB59400E7CE
      A500F7D6A5009C6B630000000000000000000000000000000000008CBD00B5FF
      FF00B5F7FF00C6F7FF00E7FFFF00EFFFFF00D6D6CE00A55A3100EFC69400BD42
      000000000000000000000000000000000000BD4A0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFF700FFF7EF00FFEFE700FFEFDE00F7E7
      D600F7E7CE00F7E7C600F7DEB500BD4A0000AD4A2100FFFFFF00FFFFFF00FFFF
      FF00E7B56300FFFFF700FFFFF700CEDEDE0000639C008CF7FF0073DEE700217B
      A500FFEFD600FFE7CE00944A29000000000000000000CE9C8400FFFFFF000884
      AD007BCEE70029ADD600219CC60042ADCE0063B5D6000884AD00CEBD9C00EFCE
      AD00F7DEAD009C6B630000000000000000000000000000000000008CBD00BDEF
      F70031BDDE0010A5D600109CCE00C65A0000C65A0000C65A0000DEA57300FFE7
      BD00BD420000000000000000000000000000BD4A0000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF000000FFF7F7008400000084000000FFEF
      DE000000FF000000FF00F7DEBD00BD4A0000AD4A2100FFFFFF00FFFFFF00FFFF
      FF00D6840000FFFFFF00FFFFF700FFFFF700EFEFEF0000639C0052BDD600217B
      A500FFE7C600FFDEBD008C4A21000000000000000000CE9C8400FFFFFF000884
      AD0052D6E70029D6F70042DEFF0084E7F70029ADD6000884AD00CEBDA500EFD6
      B500FFDEB5009C6B630000000000000000000000000000000000008CBD004AC6
      DE005AEFFF0021D6FF0031DEFF00C65A0000CE8C5A00FFDEAD00F7C69400BD42
      0800BD420000BD4200000000000000000000BD4A0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7F700FFF7EF00FFEF
      E700FFEFDE00F7E7D600F7DEC600BD4A0000AD4A2100D6840000D6840000D684
      0000D6840000D6840000D6840000D6840000E7B56300E7B5630000639C00216B
      8400D6840000D68400008C4A21000000000000000000DEAD8400FFFFFF000884
      AD007BF7FF0029DEFF0039DEFF008CE7FF0031BDDE000884AD00CEBDAD00EFD6
      BD00F7DEB5009C6B630000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0031DEFF006BE7FF00C65A0000CE844A00F7C68400E7A5
      6300BD420800000000000000000000000000BD4A0000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF000000FFFFFF008400000084000000FFF7
      EF000000FF000000FF00F7E7CE00BD4A0000AD4A2100FFFFFF00FFFFFF00FFFF
      FF00D6840000FFFFFF00FFFFFF00FFFFFF00FFFFF700E7B56300FFF7EF00FFEF
      DE00FFEFD600FFE7CE008C4221000000000000000000DEAD8400FFFFFF000884
      AD009CFFFF006BFFFF0084FFFF00ADFFFF0052D6F7000884AD00DECEBD00DED6
      BD00C6BDAD009C6B630000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0031DEFF006BE7FF008CE7FF00C65A0000C66B2900E794
      3100D67B1800BD4200000000000000000000BD4A0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7
      F700FFF7EF00FFEFE700F7E7D600BD4A0000AD4A2100E7E7E700E7E7E700E7E7
      E700D6840000E7E7E700E7E7E700E7E7E700E7E7E700D6840000E7E7E700E7E7
      DE00E7DED600E7DECE00944A29000000000000000000E7B58C00FFFFFF000884
      AD00D6F7F700FFFFFF00DEFFFF00CEFFFF009CFFFF000884AD00AD7B6B00B584
      7300B5847300B584730000000000000000000000000000000000008CBD008CFF
      FF005AEFFF0021D6FF0031DEFF006BE7FF008CE7FF004AC6E700C65A0000C65A
      0000C65A0000BD420000BD42000000000000BD4A0000DE630000DE630000DE63
      0000DE630000DE630000DE630000DE630000DE630000DE630000DE630000DE63
      0000DE630000DE630000DE630000BD4A0000AD5A2100AD632100AD5A2100AD5A
      2100AD5A2100AD5A2100AD5A2100AD5A2100AD5A2100AD632100AD632100AD63
      2100AD632100AD6329008C4A21000000000000000000E7B58C00FFFFFF00FFFF
      FF000884AD000884AD000884AD000884AD000884AD00DECEC600B5847300EFB5
      7300EFA54A00C6846B0000000000000000000000000000000000008CBD0094FF
      FF0084FFFF006BFFFF007BFFFF0094FFFF00A5FFFF0063DEF70008A5D6000884
      AD0000000000000000000000000000000000BD4A0000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A0000BD4A0000AD5A2100EF943100EF943100EF94
      3100EF943100EF943100EF943100EF943100EF943100EF943100EF943100EF94
      3100EF943100EF943100BD5A18000000000000000000EFBD9400FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7D6D600B5847300FFC6
      7300CE9473000000000000000000000000000000000000000000008CBD00FFFF
      FF00F7FFFF00D6FFFF00B5FFFF00B5FFFF00ADFFFF00ADFFFF006BFFFF000884
      AD000000000000000000000000000000000000000000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A0000BD4A
      0000BD4A0000BD4A0000BD4A00000000000000000000CE731800CE731800CE73
      1800CE731800CE731800CE731800CE731800CE731800CE731800CE731800CE73
      1800CE731800CE731800000000000000000000000000EFBD9400FFF7F700FFF7
      F700FFF7F700FFF7F700FFF7F700FFF7F700FFF7F700E7D6CE00B5847300CE9C
      8400000000000000000000000000000000000000000000000000000000000894
      C600F7FFFF00E7FFFF00C6FFFF00ADFFFF00A5FFFF009CFFFF001084AD000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EFBD9400DEA58400DEA5
      8400DEA58400DEA58400DEA58400DEA58400DEA58400DEA58400B58473000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008CBD00008CBD00008CBD00008CBD00008CBD00008CBD00000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000600000000100010000000000000300000000000000000000
      000000000000000000000000FFFFFF0080070000000000000003000000000000
      0003000000000000000300000000000000030000000000000003000000000000
      0000000000000000000000000000000000000000000000000003000000000000
      0003000000000000000300000000000000030000000000008007000000000000
      FE3F000000000000FF3F000000000000FFFFFFFFFFFFFC01F307FFC3B407E000
      C001F80187FFC0008001E001B40180008001C003CFFF000080018000FFFF0001
      80018000FFFF00038001000080010003800100008001003F80070000FFFF003F
      E00F0000FFFF003FE0078001B407003FE007800787FF003FE007C00FB401003F
      E00FE01FCFFF007FFFFFF87FFFFFC1FFC001FFFFFFC7FF9FC0018001E001FF0F
      C0018001C001FE0FC00180018001FC1FC00180018000F83FC00180018000F07C
      C00180018001E0FFC00180018001C1F7C0018001800183E380018001800F86B7
      80018001801FCE3F80018001801FAC1F80018001801F8F7F80018001801F07FF
      80018001C03F8FFFFFFFFFFFE07FDFFFE03FFFFFEFEFFFFFE003FFFFC7C70000
      E000FFFF83830000E000C00101010000800080008383000000008000C7C70000
      00008000EFEF000000008000EFEF000000008000E00F000000008000FEFF0000
      00008000F01F000000FF8000F01F000000FF8001F01F000000FF81FFF01F0000
      00FFC3FFF01FFFFF81FFFFFFF01FFFFFFFFFFFFFFFFFFFC1F01FFFFFF01FFF80
      F01F0001F01F0000F01F0001F01F0000001F0001001F0000001F0001001F0000
      0000000100000000000000000000000000000000000000000000000000000001
      018000010180000101800001018000010180000101800001FF800001FF800001
      FF808003FF808003FFFFFFFFFFFFFFFFFFFFF001FFFFFBFF0000E0008003F03F
      000000008003E01F000000008003C00F000000008003C00F000000008003C00F
      000000018003C00F000000018003C007000000018003C003000000018003C007
      000000018003C003000000018003C001000000018003C00F000000018007C00F
      80018003800FE01FFFFFFFFF801FF03F00000000000000000000000000000000
      000000000000}
  end
  object treeImages16: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 11010648
    ImageInfo = <
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
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D224564697422
          3E0A093C7061746820636C6173733D22426C75652220643D224D32372E362C38
          2E326C2D332E382D332E38632D302E352D302E352D312E342D302E352D312E39
          2C306C2D322E352C322E356C352E382C352E386C322E352D322E354332382E31
          2C392E362C32382E312C382E382C32372E362C382E327A222F3E0A093C706F6C
          79676F6E20636C6173733D22426C75652220706F696E74733D22342C32382039
          2E382C323820342C32322E322009222F3E0A093C7265637420783D22352E3822
          20793D2231332E3422207472616E73666F726D3D226D617472697828302E3730
          37202D302E3730373220302E3730373220302E373037202D382E303732312031
          352E34303438292220636C6173733D22426C7565222077696474683D2231372E
          3622206865696768743D22382E32222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_edit.svg'
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
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D22416464223E
          0A093C7061746820636C6173733D22477265656E2220643D224D32372C313468
          2D39563563302D302E352D302E352D312D312D31682D32632D302E352C302D31
          2C302E352D312C3176394835632D302E352C302D312C302E352D312C31763263
          302C302E352C302E352C312C312C31683976390A090963302C302E352C302E35
          2C312C312C31683263302E352C302C312D302E352C312D31762D39683963302E
          352C302C312D302E352C312D31762D324332382C31342E352C32372E352C3134
          2C32372C31347A222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_add.svg'
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
      end>
  end
  object treeImages24: TcxImageList
    SourceDPI = 96
    Height = 24
    Width = 24
    FormatVersion = 1
    DesignInfo = 14680664
    ImageInfo = <
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
          31373744373B7D0A3C2F7374796C653E0A3C672069643D22736974656D617022
          207472616E73666F726D3D227363616C6528312E33333333333329223E0A093C
          7061746820643D224D392C325638483131563131483543332E38392C31312033
          2C31312E383920332C3133563136483156323248375631364835563133483131
          5631364839563232483135563136483133563133483139563136483137563232
          4832335631364832315631334332312C31312E38392032302E31312C31312031
          392C31314831335638483135563248395A2220636C6173733D22426C75652220
          2F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'sitemap.svg'
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
      end>
  end
  object qryTest: TFDQuery
    Left = 224
    Top = 336
  end
  object ProgressBox: TProgressBox
    MaxValue = 0
    Progress = 0
    CancelEnabled = True
    Left = 222
    Top = 397
  end
end
