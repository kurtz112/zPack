object FormDbViewColumns: TFormDbViewColumns
  Left = 915
  Top = 293
  BorderStyle = bsSizeToolWin
  Caption = 'Colonne'
  ClientHeight = 377
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 3
  Padding.Top = 7
  Padding.Right = 3
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 16
  object OkCancel: TOkCancel
    Left = 3
    Top = 347
    Width = 370
    Height = 30
    Align = alBottom
    TabOrder = 0
    OnApply = OkCancelApply
     
    DefaultOk = False
    DefaultCancel = False
  end
  object ListBox: TcxCheckListBox
    AlignWithMargins = True
    Left = 6
    Top = 38
    Width = 364
    Height = 306
    Align = alClient
    DragMode = dmAutomatic
    EditValueFormat = cvfCaptions
    Items = <>
    ParentFont = False
    PopupMenu = dxTBMenu
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.TransparentBorder = False
    Style.IsFontAssigned = True
    TabOrder = 2
    OnDragDrop = ListBoxDragDrop
    OnDragOver = ListBoxDragOver
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 56
    Top = 56
    object MoveUp: TAction
      Caption = 'Sposta in alto'
      ImageIndex = 134
      ShortCut = 16422
      OnExecute = MoveUpExecute
    end
    object MoveDown: TAction
      Caption = 'Sposta in basso'
      ImageIndex = 130
      ShortCut = 16424
      OnExecute = MoveDownExecute
    end
    object Mostra: TAction
      Caption = 'Mostra'
      ImageIndex = 477
      OnExecute = MostraExecute
    end
    object Nascondi: TAction
      Caption = 'Nascondi'
      ImageIndex = 443
      OnExecute = NascondiExecute
    end
    object SelezionaTutto: TAction
      Caption = 'Seleziona Tutto'
      ImageIndex = 193
      ShortCut = 16449
      OnExecute = SelezionaTuttoExecute
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
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.LargeImages = dx.Immagini
    ImageOptions.LargeIcons = True
    ImageOptions.UseLargeImagesForLargeIcons = True
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <>
    UseSystemFont = False
    Left = 56
    Top = 112
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      28
      0)
    object dxBarbar: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'bar'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 736
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          UserDefine = [udWidth]
          UserWidth = 192
          Visible = True
          ItemName = 'cxBarEditItemSearch'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonMostra'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonNascondi'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonMoveUp'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonMoveDown'
        end>
      OneOnRow = True
      Row = 0
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = True
    end
    object dxBarButton1: TdxBarButton
      Action = SelezionaTutto
      Category = 0
    end
    object dxBarEdit1: TdxBarEdit
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
    end
    object cxBarEditItemSearch: TcxBarEditItem
      Caption = 'Cerca'
      Category = 0
      Hint = 'cerca colonna'
      Visible = ivAlways
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000026744558745469746C650046696E643B426172733B526962626F6E3B
        5374616E646172643B536561726368BB659C08000002D149444154785EAD936D
        48936B18C7FF7B369FB5E3CB3C6AEACC66E66C94980AF6C1B74A462FE743E087
        2526299812C519A20B03C98A3AC9D2E8E518519F52222A2789ACF99264C58AD0
        322A848E9BBA6992D95496BACD3DDBF43EF7C62AE9ABFDE1C77D735DF7F5E7BA
        EEFB79788410FC2EF128020A4B09A230AB733FF8454CEDE54EFF7AF8EFC6CD6A
        4DFBA39A069DBDF282565F507A2AD96758A369939EB9D6ABAB6BEA75D55EE9D2
        A9EAEE487D466A4D07FC525FF46F84AAF3DA572F07C7C8F0E814B9DD6A20AA73
        5A0E40485D538F6BE0C3383159BE929B779F90AAFA760300BEEA6CDBCF2E9465
        F5F9FF5CEF21D3338BC43060240DD75BC9D1DA7B04C0969397F464F2CB376234
        5B49F3FD3EA23A7D8F9454DFC8FA3E0E43091286FD59BE4D168B2597070E9717
        939356184DA3D8B1F784D16432C3C97941C0032B12C2EB716085B01500F87E83
        2D698AE820365429A70636BB0B8B4E17161C2E78380F122591F0B8396ABA0CEF
        0A8150148C20FE0ABCCB284ECB514600E031F2F4FDF58A6CB9302E468CD4E418
        A46FDD88785FA1D78D71CB3838B71B3C1E81242A1407F2535176682FC0D9D689
        C2132E0010308C4054989F2547F7D31114553DC4DB8F56ECCE4D839B165A67A6
        C0D1B1A2C422E8FB465158A9C390D981A2821CDAA1BBC46FC0B9BCFCF03021BA
        0CA38854E4A17BC08CED294960593EC6FFD3FF151B17075FBEF38505EBF765A3
        67F013D25393E97D39F900186689B34F8E4DCC4091BB09F3AFFBB13B538A11F3
        17D817E626000C3916178C96092BF6E44961EB7F83FCCC784C4DCF8273DA2D00
        0833373D72B5B9F53912625834AA7642124CD0F2E031E667276E02B0DBAC9F2F
        B5689F214922C0BFD53990867970ABB9034EFBAC06808702B12C43A94EC93B36
        BC2DEF389165161B6365BB6A0044049E6A5D4A56E991949C8A77F2AC32929871
        F0BD44AE2807205AFD2DFC4189A66CA0C450820371040EB18198981242610371
        ACF96F64B046FD0FE22625E3DA6A63E80000000049454E44AE426082}
      ShowCaption = True
      PropertiesClassName = 'TcxComboBoxProperties'
      Properties.ImmediateDropDownWhenKeyPressed = False
      Properties.Revertable = True
      Properties.Sorted = True
      Properties.OnChange = cxBarEditItemSearchPropertiesChange
    end
    object dxBarButton2: TdxBarButton
      Action = SelezionaTutto
      Category = 0
    end
  end
  object dxBarButtonMostra: TdxBarButton
    Action = Mostra
    Category = -1
  end
  object dxBarButtonNascondi: TdxBarButton
    Action = Nascondi
    Category = -1
  end
  object dxBarButtonMoveUp: TdxBarButton
    Action = MoveUp
    Category = -1
  end
  object dxBarButtonMoveDown: TdxBarButton
    Action = MoveDown
    Category = -1
  end
  object dxTBMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonMostra'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonNascondi'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonMoveUp'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonMoveDown'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton1'
      end>
    UseOwnFont = False
    Left = 56
    Top = 176
    PixelsPerInch = 96
  end
end
