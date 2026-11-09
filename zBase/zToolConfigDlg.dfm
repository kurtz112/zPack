object zToolConfigDlgForm: TzToolConfigDlgForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Configurazione barra'
  ClientHeight = 596
  ClientWidth = 772
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object dxLayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 772
    Height = 596
    Align = alClient
    TabOrder = 0
    AutoSize = True
    DesignSize = (
      772
      596)
    object cbOwner: TcxComboBox
      Left = 10000
      Top = 10000
      Properties.DropDownListStyle = lsFixedList
      Properties.OnChange = cbOwnerPropertiesChange
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 2
      Visible = False
      Width = 481
    end
    object btnDefaultOwner: TcxButton
      Left = 10000
      Top = 10000
      Width = 100
      Height = 25
      Caption = 'Predefinita'
      TabOrder = 3
      Visible = False
      OnClick = btnDefaultOwnerClick
    end
    object tlAvailable: TcxTreeList
      Left = 10000
      Top = 10000
      Width = 356
      Height = 424
      Bands = <
        item
        end>
      FindPanel.Behavior = fcbFilter
      FindPanel.DisplayMode = fpdmAlways
      FindPanel.FocusContentOnApplyFilter = True
      FindPanel.Layout = fplCompact
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsData.Deleting = False
      OptionsView.CheckGroups = True
      OptionsView.Headers = False
      OptionsView.ShowRoot = False
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 4
      Visible = False
      OnEditValueChanged = tlAvailableEditValueChanged
      object tlAvailableColSelected: TcxTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Caption.Text = 'Attiva'
        Width = 25
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object tlAvailableColName: TcxTreeListColumn
        Caption.Text = 'Azione'
        Options.Editing = False
        Width = 350
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        SortOrder = soAscending
        SortIndex = 0
      end
      object tlAvailableColOrigin: TcxTreeListColumn
        Caption.Text = 'Origine'
        Options.Editing = False
        Width = 140
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
    end
    object tlSelected: TcxTreeList
      Left = 10000
      Top = 10000
      Width = 294
      Height = 214
      Bands = <
        item
        end>
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsData.Editing = False
      OptionsData.Deleting = False
      OptionsView.Headers = False
      OptionsView.ShowRoot = False
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 5
      Visible = False
      OnSelectionChanged = tlSelectedSelectionChanged
      object tlSelectedColName: TcxTreeListColumn
        Caption.Text = 'Azione Attiva'
        Width = 282
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        SortOrder = soAscending
        SortIndex = 0
      end
    end
    object tlFilters: TcxTreeList
      Left = 39
      Top = 68
      Width = 356
      Height = 456
      Bands = <
        item
        end>
      FindPanel.Behavior = fcbFilter
      FindPanel.DisplayMode = fpdmAlways
      FindPanel.FocusContentOnApplyFilter = True
      FindPanel.Layout = fplCompact
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsView.CheckGroups = True
      OptionsView.Headers = False
      OptionsView.ShowRoot = False
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 7
      OnEditValueChanged = tlFiltersEditValueChanged
      OnSelectionChanged = tlFiltersSelectionChanged
      object tlFiltersColSelected: TcxTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Caption.Text = 'Attivo'
        Width = 25
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object tlFiltersColCaption: TcxTreeListColumn
        Caption.Text = 'Filtro'
        Options.Editing = False
        Width = 350
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object tlFiltersColName: TcxTreeListColumn
        Visible = False
        Caption.Text = 'Name'
        Options.Editing = False
        Width = 100
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        SortOrder = soAscending
        SortIndex = 0
      end
    end
    object memParams: TcxMemo
      Left = 439
      Top = 433
      Anchors = [akLeft, akTop, akRight, akBottom]
      Properties.ScrollBars = ssBoth
      Properties.WordWrap = False
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 9
      OnExit = memParamsExit
      Height = 91
      Width = 294
    end
    object btnOk: TcxButton
      Left = 603
      Top = 558
      Width = 75
      Height = 26
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TcxButton
      Left = 685
      Top = 558
      Width = 75
      Height = 26
      Cancel = True
      Caption = 'Annulla'
      ModalResult = 2
      TabOrder = 1
    end
    object inspActions: TFrameObjectInspector
      Left = 10000
      Top = 10000
      Width = 294
      Height = 194
      Enabled = False
      TabOrder = 6
      Visible = False
    end
    object inspFilters: TFrameObjectInspector
      Left = 439
      Top = 68
      Width = 294
      Height = 328
      Enabled = False
      TabOrder = 8
    end
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ItemIndex = 2
      ShowBorder = False
      Index = -1
    end
    object dxLayoutGroup1: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroupMain: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      ItemIndex = 1
      LayoutDirection = ldTabbed
      ShowBorder = False
      Index = 2
    end
    object dxLayoutGroup3: TdxLayoutGroup
      Parent = dxLayoutGroupMain
      CaptionOptions.Text = 'Azioni'
      ItemIndex = 1
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroup4: TdxLayoutGroup
      Parent = dxLayoutGroup3
      AlignHorz = ahClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroup5: TdxLayoutGroup
      Parent = dxLayoutGroup4
      AlignVert = avTop
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroup6: TdxLayoutGroup
      Parent = dxLayoutGroup5
      AlignHorz = ahLeft
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutItem1: TdxLayoutItem
      Parent = dxLayoutGroup6
      CaptionOptions.Text = 'Sorgente azioni:'
      Control = cbOwner
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 481
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItem2: TdxLayoutItem
      Parent = dxLayoutGroup6
      CaptionOptions.Text = 'btnDefaultOwner'
      CaptionOptions.Visible = False
      Control = btnDefaultOwner
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutGroup7: TdxLayoutGroup
      Parent = dxLayoutGroup3
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutGroup8: TdxLayoutGroup
      Parent = dxLayoutGroup7
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ItemIndex = 2
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroup9: TdxLayoutGroup
      Parent = dxLayoutGroup8
      AlignVert = avClient
      CaptionOptions.Text = 'Azioni disponibili'
      LayoutDirection = ldHorizontal
      Index = 0
    end
    object dxLayoutItem3: TdxLayoutItem
      Parent = dxLayoutGroup9
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'tlAvailable'
      CaptionOptions.Visible = False
      Control = tlAvailable
      ControlOptions.OriginalHeight = 384
      ControlOptions.OriginalWidth = 356
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutSplitterItem1: TdxLayoutSplitterItem
      Parent = dxLayoutGroup8
      AlignVert = avClient
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      Index = 1
    end
    object dxLayoutGroup10: TdxLayoutGroup
      Parent = dxLayoutGroup8
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ShowBorder = False
      Index = 2
    end
    object dxLayoutGroup11: TdxLayoutGroup
      Parent = dxLayoutGroup10
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Azione selezionata'
      ItemIndex = 1
      Index = 0
    end
    object dxLayoutItem4: TdxLayoutItem
      Parent = dxLayoutGroup11
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'tlSelected'
      CaptionOptions.Visible = False
      Control = tlSelected
      ControlOptions.OriginalHeight = 220
      ControlOptions.OriginalWidth = 346
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutGroupFilters: TdxLayoutGroup
      Parent = dxLayoutGroupMain
      CaptionOptions.Text = 'Filtri'
      ItemIndex = 2
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutGroup16: TdxLayoutGroup
      Parent = dxLayoutGroupFilters
      AlignVert = avClient
      CaptionOptions.Text = 'Filtri registrati'
      LayoutDirection = ldHorizontal
      Index = 0
    end
    object dxLayoutItem10: TdxLayoutItem
      Parent = dxLayoutGroup16
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'tlFilters'
      CaptionOptions.Visible = False
      Control = tlFilters
      ControlOptions.OriginalHeight = 425
      ControlOptions.OriginalWidth = 356
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutSplitterItem2: TdxLayoutSplitterItem
      Parent = dxLayoutGroupFilters
      AlignVert = avClient
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      Index = 1
    end
    object dxLayoutGroup17: TdxLayoutGroup
      Parent = dxLayoutGroupFilters
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ShowBorder = False
      Index = 3
    end
    object dxLayoutItem12: TdxLayoutItem
      Parent = dxLayoutGroupFilterDetails
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Parametri (chiave=valore):'
      CaptionOptions.Layout = clTop
      Control = memParams
      ControlOptions.OriginalHeight = 150
      ControlOptions.OriginalWidth = 347
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutGroup20: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avBottom
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutGroup21: TdxLayoutGroup
      Parent = dxLayoutGroup20
      AlignHorz = ahRight
      AlignVert = avTop
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ShowBorder = False
      Index = 0
    end
    object dxLayoutGroup22: TdxLayoutGroup
      Parent = dxLayoutGroup21
      AlignHorz = ahLeft
      CaptionOptions.Text = 'Gruppo nascosto'
      Hidden = True
      ItemIndex = 1
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutItem13: TdxLayoutItem
      Parent = dxLayoutGroup22
      CaptionOptions.Text = 'btnOk'
      CaptionOptions.Visible = False
      Control = btnOk
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItem14: TdxLayoutItem
      Parent = dxLayoutGroup22
      CaptionOptions.Text = 'btnCancel'
      CaptionOptions.Visible = False
      Control = btnCancel
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItemInspActions: TdxLayoutItem
      Parent = dxLayoutGroup11
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Nuovo elemento'
      CaptionOptions.Visible = False
      Control = inspActions
      ControlOptions.OriginalHeight = 200
      ControlOptions.OriginalWidth = 150
      ControlOptions.ShowBorder = False
      Enabled = False
      Index = 2
    end
    object dxLayoutSplitterItem3: TdxLayoutSplitterItem
      Parent = dxLayoutGroup11
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Divisore'
      Index = 1
    end
    object dxLayoutItemInspFilters: TdxLayoutItem
      Parent = dxLayoutGroupFilterDetails
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Nuovo elemento'
      CaptionOptions.Visible = False
      Control = inspFilters
      ControlOptions.OriginalHeight = 500
      ControlOptions.OriginalWidth = 400
      ControlOptions.ShowBorder = False
      Enabled = False
      Index = 0
    end
    object dxLayoutGroupFilterDetails: TdxLayoutGroup
      Parent = dxLayoutGroupFilters
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Nuovo gruppo'
      CaptionOptions.Visible = False
      ItemIndex = 2
      Index = 2
    end
    object dxLayoutSplitterItem4: TdxLayoutSplitterItem
      Parent = dxLayoutGroupFilterDetails
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Divisore'
      Index = 1
    end
  end
end
