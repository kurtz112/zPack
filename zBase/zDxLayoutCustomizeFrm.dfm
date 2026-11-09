inherited zLayoutCustomizeForm: TzLayoutCustomizeForm
  Left = 0
  Top = 0
  Caption = 'zLayoutCustomizeForm'
  ClientHeight = 442
  ClientWidth = 628
  StyleElements = [seFont, seClient, seBorder]
  OnShow = FormShow
  ExplicitWidth = 644
  ExplicitHeight = 481
  TextHeight = 13
  inherited lcMain: TdxLayoutControl
    Width = 628
    Height = 442
    ExplicitWidth = 628
    ExplicitHeight = 442
    inherited tvVisibleItems: TdxTreeViewControl
      Width = 198
      Height = 301
      ExplicitWidth = 198
      ExplicitHeight = 301
    end
    inherited tvAvailableItems: TdxTreeViewControl
      Left = 262
      Top = 87
      Width = 342
      Height = 86
      TabOrder = 23
      ExplicitLeft = 262
      ExplicitTop = 87
      ExplicitWidth = 342
      ExplicitHeight = 86
    end
    inherited btnClose: TcxButton
      Left = 542
      Top = 406
      TabOrder = 26
      ExplicitLeft = 542
      ExplicitTop = 406
    end
    inherited cbTabbedView: TcxCheckBox
      Top = 410
      TabOrder = 25
      ExplicitTop = 410
      ExplicitWidth = 86
      ExplicitHeight = 17
    end
    inherited btnAvailableItemsViewAsList: TcxButton
      Left = 435
      ExplicitLeft = 435
    end
    inherited btnAvailableItemsDelete: TcxButton
      Left = 383
      ExplicitLeft = 383
    end
    inherited btnAddItem: TcxButton
      Left = 360
      ExplicitLeft = 360
    end
    inherited btnAddGroup: TcxButton
      Left = 314
      ExplicitLeft = 314
    end
    inherited btnAvailableItemsCollapseAll: TcxButton
      Left = 285
      ExplicitLeft = 285
    end
    inherited btnAvailableItemsExpandAll: TcxButton
      Left = 262
      ExplicitLeft = 262
    end
    inherited cxButton1: TcxButton
      Left = 337
      ExplicitLeft = 337
    end
    inherited cxButton2: TcxButton
      Left = 106
      ExplicitLeft = 106
    end
    inherited cxButton3: TcxButton
      Left = 412
      ExplicitLeft = 412
    end
    object PanelInspector: TdxPanel [25]
      Left = 262
      Top = 187
      Width = 342
      Height = 200
      Frame.Visible = False
      TabOrder = 24
      object cxRTTIInspector: TFrameObjectInspector
        Left = 0
        Top = 0
        Width = 342
        Height = 200
        Align = alClient
        TabOrder = 0
      end
    end
    object btnPopup: TcxButton [26]
      Left = 464
      Top = 58
      Width = 23
      Height = 23
      Caption = 'Hide Borders'
      DropDownMenu = PopupMenu
      Kind = cxbkDropDown
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000018744558745469746C6500426F7264657273416C6C3B426F72646572
        3BE90A127D000000D149444154785EA593510AC3300C432DE8897AB85D63671B
        BD8F355C610B8FFD353F4E507896DCE620194FD651E57C7D58F56641156464A8
        4A54ED7ED7FBC4004A42008230EA66EAD0AC42DD5AE3960394D878B4A43D33C2
        F60A8EE06F849E03655F9E7CA83A2DBD334022558B2F480ADAFAEAC00D702CE9
        2BF3C03995C406D89DD9B6AF009231110DF05DB4E6CEB503EC8CC334C0AD250D
        BF21B9C7D6770DF0650B9E0508E93303FC1B22765F9A9650360AB403EC0816FC
        CB7A266857E218E058E0A637C55F1E32B123F8613C788D4FD6178763CF369993
        5B900000000049454E44AE426082}
      PaintStyle = bpsGlyph
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 22
      OnClick = HideBordersExecute
    end
    inherited lcMainGroup_Root: TdxLayoutGroup
      ItemIndex = 1
    end
    inherited lcMainGroup1: TdxLayoutGroup
      ItemIndex = 2
    end
    inherited lsAlignBy: TdxLayoutSeparatorItem
      Index = 4
    end
    inherited lgAvailableItems: TdxLayoutGroup
      ItemIndex = 11
    end
    inherited lcMainSeparatorItem2: TdxLayoutSeparatorItem
      Index = 7
    end
    inherited lcMainGroup3: TdxLayoutGroup
      ItemIndex = 1
    end
    inherited lcMainItem4: TdxLayoutItem
      ControlOptions.OriginalWidth = 86
    end
    inherited liVisibleItemsMakeFloat: TdxLayoutItem
      Index = 5
    end
    inherited liAvailableItemsMakeFloat: TdxLayoutItem
      Index = 8
    end
    object dxLayoutItemInspector: TdxLayoutItem
      Parent = lcgAvailableItems
      CaptionOptions.Text = 'Nuovo oggetto'
      CaptionOptions.Visible = False
      Control = PanelInspector
      ControlOptions.OriginalHeight = 200
      ControlOptions.OriginalWidth = 335
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutSplitterItem1: TdxLayoutSplitterItem
      Parent = lcgAvailableItems
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Divisore'
      Index = 2
    end
    object dxLayoutItemPopup: TdxLayoutItem
      Parent = lgAvailableItems
      CaptionOptions.Text = 'Nuovo oggetto'
      CaptionOptions.Visible = False
      Control = btnPopup
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 23
      ControlOptions.ShowBorder = False
      Index = 11
    end
    object dxLayoutSeparatorItem1: TdxLayoutSeparatorItem
      Parent = lgAvailableItems
      CaptionOptions.Text = 'Separatore'
      Index = 10
    end
  end
  inherited ilActions: TcxImageList
    FormatVersion = 1
  end
  inherited ilItems: TcxImageList
    FormatVersion = 1
  end
  object ilHelper: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 17301952
  end
  object ActionList: TActionList
    Left = 56
    Top = 152
    object HideTabs: TAction
      Caption = 'Hide Tabs'
      OnExecute = HideTabsExecute
    end
    object ShowTabs: TAction
      Caption = 'Show Tabs'
      OnExecute = ShowTabsExecute
    end
    object HideBorders: TAction
      Caption = 'Hide Borders'
      OnExecute = HideBordersExecute
    end
    object ShowSize: TAction
      Caption = 'Show Size'
      OnExecute = ShowSizeExecute
    end
    object SalvaConNome: TdxFileSaveAs
      Caption = 'Save'
      Dialog.DefaultExt = '*.layoutStream'
      Dialog.Filter = 'LayoutStream|*.layoutStream|Tutti|*.*'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      OnAccept = SalvaConNomeAccept
    end
    object CaricaDaFile: TdxFileOpen
      Caption = 'Load'
      Dialog.DefaultExt = '*.layoutStream'
      Dialog.Filter = 'LayoutStream|*.layoutStream|Tutti|*.*'
      OnAccept = CaricaDaFileAccept
    end
    object FixTabs: TAction
      Caption = 'Fix Tabs'
      OnExecute = FixTabsExecute
    end
    object LayoutRepair: TAction
      Caption = 'Ripara Layout'
      OnExecute = LayoutRepairExecute
    end
    object LayoutReset: TAction
      Caption = 'Reset Layout (ex novo)'
      OnExecute = LayoutResetExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 304
    Top = 224
    object HideTabs1: TMenuItem
      Action = HideTabs
    end
    object ShowTabs1: TMenuItem
      Action = ShowTabs
    end
    object FixTabs1: TMenuItem
      Action = FixTabs
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object N9: TMenuItem
      Action = HideBorders
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object Load1: TMenuItem
      Action = CaricaDaFile
    end
    object Save1: TMenuItem
      Action = SalvaConNome
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object LayoutRepair1: TMenuItem
      Action = LayoutRepair
    end
    object LayoutReset1: TMenuItem
      Action = LayoutReset
    end
  end
  object ExpandTimer: TTimer
    Enabled = False
    Left = 304
    Top = 104
  end
end
