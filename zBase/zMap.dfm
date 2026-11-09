object zMap: TzMap
  Left = 0
  Top = 0
  Width = 577
  Height = 485
  TabOrder = 0
  object dxStatusBar: TdxStatusBar
    Left = 0
    Top = 465
    Width = 577
    Height = 20
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarContainerPanelStyle'
        PanelStyle.Container = dxStatusBarContainer3
        Width = 100
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Text = 'Zoom: '
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Width = 350
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    PopupMenu = popMenu
    object dxStatusBarContainer3: TdxStatusBarContainerControl
      Left = 0
      Top = 2
      Width = 102
      Height = 18
      object cxProgressBar: TcxProgressBar
        Left = 0
        Top = 0
        Align = alClient
        Properties.AnimationSpeed = 5
        Properties.ShowTextStyle = cxtsText
        TabOrder = 0
        Width = 102
      end
    end
  end
  object Map: TTMSFNCMaps
    Left = 0
    Top = 28
    Width = 477
    Height = 437
    Align = alClient
    ParentDoubleBuffered = False
    DoubleBuffered = True
    TabOrder = 1
    OnZoomChanged = MapZoomChanged
    OnMapTypeChanged = MapMapTypeChanged
    OnMapMoveStart = MapMapMoveStart
    OnMapMoveEnd = MapMapMoveEnd
    OnMapClick = MapMapClick
    OnMapMouseMove = MapMapMouseMove
    OnMarkerClick = MapMarkerClick
    OnPolyElementClick = MapPolyElementClick
    OnMapInitialized = MapMapInitialized
    OnGetCenterCoordinate = MapGetCenterCoordinate
    OnGetBounds = MapGetBounds
    OnGetZoomLevel = MapGetZoomLevel
    Polylines = <>
    Polygons = <>
    Circles = <>
    Rectangles = <>
    Markers = <>
    ElementContainers = <>
    Labels = <>
    HeadLinks = <>
    Options.Locale = 'it-IT'
    Options.DefaultLatitude = 45.317237550000000000
    Options.DefaultLongitude = 8.857966748547639000
    Options.DefaultZoomLevel = 18.000000000000000000
    Service = msOpenLayers
    object Geocoding: TTMSFNCGeocoding
      Left = 16
      Top = 32
      Width = 26
      Height = 26
      Visible = True
      GeocodingRequests = <>
      Service = gsOpenStreetMap
    end
  end
  object pnlDescrizione: TdxPanel
    Left = 477
    Top = 28
    Width = 100
    Height = 437
    Align = alRight
    Frame.Drag.Enabled = True
    Frame.Visible = False
    TabOrder = 6
    Visible = False
  end
  object Timer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = TimerTimer
    Left = 168
    Top = 60
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
      'File')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.StretchGlyphs = False
    ImageOptions.UseLargeImagesForLargeIcons = True
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <
      item
      end>
    UseSystemFont = True
    Left = 88
    Top = 60
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      28
      0)
    object dxBar: TdxBar
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
      FloatLeft = 683
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <>
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object dxBarButton1: TdxBarButton
      Action = actPersonalizza
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actConsole
      Category = 0
      AllowAllUp = True
      ButtonStyle = bsChecked
    end
    object dxBarButton3: TdxBarButton
      Action = Descrizione
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton4: TdxBarButton
      Action = EditTools
      Category = 0
    end
  end
  object popMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    Images = dx.Immagini
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton2'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton3'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton4'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton1'
      end>
    UseOwnFont = False
    OnPopup = popMenuPopup
    Left = 201
    Top = 170
    PixelsPerInch = 96
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 320
    Top = 152
    object actPersonalizza: TAction
      Caption = 'Personalizza'
      ImageIndex = 512
      OnExecute = actPersonalizzaExecute
    end
    object actConsole: TAction
      AutoCheck = True
      Caption = 'Console'
      ImageIndex = 29
      OnExecute = actConsoleExecute
      OnUpdate = actConsoleUpdate
    end
    object Descrizione: TAction
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
    end
    object EditTools: TAction
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
  end
  object TimerVisible: TTimer
    Enabled = False
    OnTimer = TimerVisibleTimer
    Left = 280
    Top = 52
  end
end
