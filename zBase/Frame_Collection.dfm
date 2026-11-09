object FrameCollection: TFrameCollection
  Left = 0
  Top = 0
  Width = 617
  Height = 370
  TabOrder = 0
  object Splitter: TcxSplitter
    Left = 297
    Top = 0
    Width = 8
    Height = 370
    HotZoneClassName = 'TcxMediaPlayer9Style'
  end
  object TreeList: TcxTreeList
    Left = 0
    Top = 0
    Width = 297
    Height = 370
    Align = alLeft
    Bands = <
      item
      end>
    DragMode = dmAutomatic
    FindPanel.Behavior = fcbFilter
    FindPanel.DisplayMode = fpdmManual
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    OptionsBehavior.CopyCaptionsToClipboard = False
    OptionsBehavior.IncSearch = True
    OptionsBehavior.IncSearchItem = TreeListColumn
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsView.ColumnAutoWidth = True
    OptionsView.Headers = False
    ParentFont = False
    PopupMenu = PopupMenu
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 0
    OnCanSelectNode = TreeListCanSelectNode
    OnDragDrop = TreeListDragDrop
    OnDragOver = TreeListDragOver
    OnKeyDown = TreeListKeyDown
    OnMouseDown = TreeListMouseDown
    OnSelectionChanged = TreeListSelectionChanged
    object TreeListColumn: TcxTreeListColumn
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object cxPageControl: TcxPageControl
    Left = 305
    Top = 0
    Width = 312
    Height = 370
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = tabInspector
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControlChange
    ClientRectBottom = 366
    ClientRectLeft = 4
    ClientRectRight = 308
    ClientRectTop = 26
    object tabInspector: TcxTabSheet
      Caption = 'Propriet'#224
      ImageIndex = 0
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object FrameObjectInspector: TFrameObjectInspector
        Left = 0
        Top = 0
        Width = 304
        Height = 340
        Align = alClient
        TabOrder = 0
      end
    end
    object tabEditor: TcxTabSheet
      Caption = 'Editor'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 56
    Top = 88
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
    object Aggiorna: TAction
      Caption = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
    end
    object Duplica: TAction
      Caption = 'Duplica'
      ImageIndex = 42
      OnExecute = DuplicaExecute
    end
  end
  object PopupMenu: TPopupMenu
    Images = dx.Immagini
    Left = 56
    Top = 144
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
  object CheckImages: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 1573008
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A3C2F7374796C653E0A3C636972636C6520636C617373
          3D22526564222063783D2238222063793D22382220723D2237222F3E0A3C2F73
          76673E0A}
        FileName = 'circle_red.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A3C2F7374796C653E0A3C636972636C6520636C617373
          3D22526564222063783D2238222063793D22382220723D2237222F3E0A3C2F73
          76673E0A}
        FileName = 'circle_red.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E477265656E7B66696C
          6C3A233033394332333B7D0A3C2F7374796C653E0A3C636972636C6520636C61
          73733D22477265656E222063783D2238222063793D22382220723D2237222F3E
          0A3C2F7376673E0A}
        FileName = 'circle_green.svg'
      end>
  end
end
