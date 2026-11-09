object FormFireDacMonitor: TFormFireDacMonitor
  Left = 0
  Top = 0
  Caption = 'FireDAC Monitor'
  ClientHeight = 525
  ClientWidth = 331
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object dxLayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 331
    Height = 505
    Align = alClient
    TabOrder = 0
    object btnOk: TcxButton
      Left = 162
      Top = 468
      Width = 75
      Height = 25
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TcxButton
      Left = 244
      Top = 468
      Width = 75
      Height = 25
      Caption = 'Annulla'
      ModalResult = 2
      TabOrder = 3
    end
    object cxRTTIInspector: TFrameObjectInspector
      Left = 12
      Top = 42
      Width = 307
      Height = 419
      TabOrder = 1
    end
    object edTipoMonitor: TcxImageComboBox
      Left = 12
      Top = 12
      EditValue = 0
      Properties.Items = <
        item
          Description = 'Nessuno'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Remote (TCP)'
          Value = 1
        end
        item
          Description = 'Flat File '
          Value = 2
        end
        item
          Description = 'SmartInspect'
          Value = 3
        end>
      Properties.OnEditValueChanged = edTipoMonitorPropertiesEditValueChanged
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 0
      Width = 307
    end
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object dxLayoutItemTipoMonitor: TdxLayoutItem
      Parent = dxLayoutControlGroup_Root
      CaptionOptions.Text = 'edTipoMonitor'
      CaptionOptions.Visible = False
      Control = edTipoMonitor
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemRTTIInspector: TdxLayoutItem
      Parent = dxLayoutControlGroup_Root
      AlignVert = avClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = cxRTTIInspector
      ControlOptions.OriginalHeight = 200
      ControlOptions.OriginalWidth = 150
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItemOk: TdxLayoutItem
      Parent = dxLayoutGroup1
      AlignHorz = ahRight
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnOk
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemAnnulla: TdxLayoutItem
      Parent = dxLayoutGroup1
      AlignHorz = ahRight
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnCancel
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutGroup1: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignVert = avBottom
      CaptionOptions.Text = 'New Group'
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
  end
  object dxStatusBar: TdxStatusBar
    Left = 0
    Top = 505
    Width = 331
    Height = 20
    Panels = <>
    LookAndFeel.NativeStyle = True
  end
  object cxImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 5767232
  end
end
