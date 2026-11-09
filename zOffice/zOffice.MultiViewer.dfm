object zMultiViewer: TzMultiViewer
  Left = 0
  Top = 0
  Width = 416
  Height = 270
  TabOrder = 0
  object PageControl: TcxPageControl
    Left = 0
    Top = 24
    Width = 416
    Height = 246
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tabNone
    Properties.CustomButtons.Buttons = <>
    LookAndFeel.Kind = lfUltraFlat
    LookAndFeel.NativeStyle = False
    ExplicitTop = 0
    ExplicitHeight = 270
    ClientRectBottom = 246
    ClientRectRight = 416
    ClientRectTop = 26
    object tabNone: TcxTabSheet
      Caption = 'None'
      ImageIndex = 4
      object dxBarDockControlNone: TdxBarDockControl
        Left = 0
        Top = 0
        Width = 416
        Align = dalTop
        BarManager = dxBarManagerNone
      end
      object labelEmpty: TcxLabel
        Left = 0
        Top = 3
        Align = alClient
        Caption = 'Nessun file da visualizzare'
        Style.TextStyle = [fsItalic]
        Properties.Alignment.Horz = taCenter
        Properties.Alignment.Vert = taVCenter
        TabOrder = 1
        AnchorX = 208
        AnchorY = 112
      end
    end
    object tabWord: TcxTabSheet
      Caption = 'Word'
      ImageIndex = 3
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabExcel: TcxTabSheet
      Caption = 'Excel'
      ImageIndex = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabPdf: TcxTabSheet
      Caption = 'Pdf'
      ImageIndex = 1
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabImage: TcxTabSheet
      Caption = 'Image'
      ImageIndex = 2
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabMail: TcxTabSheet
      Caption = 'Mail'
      ImageIndex = 5
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabSynEdit: TcxTabSheet
      Caption = 'SynEdit'
      ImageIndex = 6
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object dxActivityIndicator: TdxActivityIndicator
    AlignWithMargins = True
    Left = 50
    Top = 74
    Width = 316
    Height = 146
    Margins.Left = 50
    Margins.Top = 50
    Margins.Right = 50
    Margins.Bottom = 50
    Align = alClient
    PropertiesClassName = 'TdxActivityIndicatorCircularDotsProperties'
    Transparent = True
    ExplicitTop = 72
    ExplicitHeight = 148
  end
  object dxBarManagerNone: TdxBarManager
    AutoAlignBars = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    CanCustomize = False
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 200
    Top = 64
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      24
      0)
    object dxBarManagerNoneBar: TdxBar
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
      FloatLeft = 0
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'btnImportaNone'
        end>
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object btnImportaNone: TdxBarButton
      Action = ImportaNone
      Category = 0
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 40
    Top = 64
  end
  object DataSource: TDataSource
    OnDataChange = DataSourceDataChange
    Left = 40
    Top = 120
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 120
    Top = 120
    object ImportaNone: TdxFileOpen
      Caption = 'Importa File'
      Dialog.Filter = 'Tutti|*.*'
      Hint = 'Importa|Importa un nuovo file'
      ImageIndex = 238
      BeforeExecute = ImportaNoneBeforeExecute
      OnAccept = ImportaNoneAccept
      OnUpdate = ImportaNoneUpdate
    end
    object EditTools: TAction
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
    object actDocGeneraAllegato: TAction
      Caption = 'Genera Allegato'
      ImageIndex = 540
    end
    object actDocFirma: TAction
      Caption = 'Firma'
      ImageIndex = 531
    end
    object actDocProtocolla: TAction
      Caption = 'Protocolla'
      ImageIndex = 12
    end
    object actDocConserva: TAction
      Caption = 'Conserva'
      ImageIndex = 10
    end
    object actDocInviaPec: TAction
      Caption = 'Invia PEC'
      ImageIndex = 467
    end
    object actDocInviaMail: TAction
      Caption = 'Invia Mail'
      ImageIndex = 461
    end
    object actDocAggiornaStato: TAction
      Caption = 'Aggiorna stato'
      ImageIndex = 89
    end
    object actDocVersioni: TAction
      Caption = 'Versioni'
      ImageIndex = 14
    end
  end
end
