object zDbViewForm: TzDbViewForm
  Left = 550
  Top = 26
  BorderStyle = bsSizeToolWin
  ClientHeight = 411
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poDesigned
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 381
    Width = 434
    Height = 30
    Align = alBottom
    TabOrder = 0
     
    DefaultOk = False
    DefaultCancel = False
    ExplicitTop = 256
    ExplicitWidth = 364
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 381
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 7
    TabOrder = 1
    ExplicitWidth = 364
    ExplicitHeight = 256
    object zDbView: TzDbView
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 414
      Height = 361
      Align = alClient
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ToolActions = <>
      ExplicitWidth = 344
      ExplicitHeight = 236
    end
  end
  object ActionList: TActionList
    Left = 64
    Top = 224
    object Tutti: TAction
      Caption = 'Tutti'
      OnExecute = TuttiExecute
      OnUpdate = ButtonVisible
    end
    object Nessuno: TAction
      Caption = 'Nessuno'
      OnExecute = NessunoExecute
      OnUpdate = ButtonVisible
    end
  end
end
