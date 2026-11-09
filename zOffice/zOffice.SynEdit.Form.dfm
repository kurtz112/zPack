object zViewerSynEditForm: TzViewerSynEditForm
  Left = 0
  Top = 0
  ClientHeight = 440
  ClientWidth = 938
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  inline zViewerSynEditFrame: TzViewerSynEditFrame
    Left = 0
    Top = 132
    Width = 938
    Height = 308
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 275
    ExplicitTop = -119
    inherited PanelEditor: TPanel
      Width = 938
      Height = 286
      StyleElements = [seFont, seClient, seBorder]
      inherited StatusBar: TdxStatusBar
        Top = 266
        Width = 938
      end
      inherited Editor: TSynEdit
        Width = 921
        Height = 249
        ExplicitWidth = 921
        ExplicitHeight = 381
      end
      inherited VScrollBar: TcxScrollBar
        Left = 921
        Height = 249
      end
      inherited HScrollBar: TcxScrollBar
        Top = 249
        Width = 921
      end
    end
    inherited dxBarManager: TdxBarManager
      PopupMenuLinks = <
        item
          Control = zViewerSynEditFrame.Editor
          PopupMenu = zViewerSynEditFrame.dxBarPopupMenu
        end>
      PixelsPerInch = 96
      inherited dxBarManagerBar1: TdxBar
        Caption = 'File'
      end
    end
    inherited dxBarPopupMenu: TdxBarPopupMenu
      PixelsPerInch = 96
    end
  end
  object dxRibbon: TdxRibbon
    Left = 0
    Top = 0
    Width = 938
    Height = 132
    ApplicationButton.Visible = False
    BarManager = dxBarManagerForm
    CapitalizeTabCaptions = bDefault
    Style = rs2019
    ColorSchemeAccent = rcsaGreen
    ColorSchemeName = 'Colorful'
    PopupMenuItems = [rpmiQATPosition, rpmiQATAddRemoveItem, rpmiMinimizeRibbon]
    SupportNonClientDrawing = True
    Contexts = <>
    TabOrder = 1
    TabStop = False
    object dxRibbonTabHome: TdxRibbonTab
      Active = True
      Caption = 'File'
      Groups = <
        item
          Caption = 'File'
        end
        item
          Caption = 'Trova'
        end
        item
          Caption = 'Strumenti'
        end
        item
          Caption = 'Navigazione'
        end
        item
          Caption = 'Vista'
        end
        item
        end
        item
          ToolbarName = 'dxBarManagerBar1'
        end
        item
          ToolbarName = 'dxBarManagerFormBar2'
        end>
      Index = 0
    end
  end
  object dxBarManagerForm: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Predefinito')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.UseLargeImagesForLargeIcons = True
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 416
    Top = 48
    PixelsPerInch = 96
    object dxBarManagerFormBar2: TdxBar
      Caption = 'Costume1'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 966
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton3'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButton4'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButton5'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButton6'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = zViewerSynEditFrame.SalvaSuFile
      Category = 0
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = zViewerSynEditFrame.Apri
      Category = 0
    end
    object dxBarButton1: TdxBarButton
      Action = zViewerSynEditFrame.Stampa
      Category = 0
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Action = zViewerSynEditFrame.Stampa
      Category = 0
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Action = zViewerSynEditFrame.actCopia
      Category = 0
    end
    object dxBarLargeButton5: TdxBarLargeButton
      Action = zViewerSynEditFrame.actTrova
      Category = 0
    end
    object dxBarLargeButton6: TdxBarLargeButton
      Action = Chiudi
      Category = 0
      ImageIndex = 60
    end
  end
  object ActionListForm: TActionList
    Images = dx.Immagini
    Left = 544
    Top = 48
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 54
      OnExecute = ChiudiExecute
    end
  end
end
