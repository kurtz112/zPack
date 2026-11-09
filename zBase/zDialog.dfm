object zDialog: TzDialog
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  ClientHeight = 161
  ClientWidth = 184
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 130
    Width = 184
    Height = 31
    Align = alBottom
    PopupMenu = PopupMenu
    TabOrder = 0
     
    DefaultOk = True
    DefaultCancel = True
    ExplicitTop = 282
    ExplicitWidth = 414
  end
  object dxLayoutControl: TdxLayoutControl
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 178
    Height = 124
    Align = alClient
    PopupMenu = PopupMenu
    TabOrder = 1
    ExplicitWidth = 408
    ExplicitHeight = 276
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      Padding.Left = 7
      Padding.Top = 7
      Padding.AssignedValues = [lpavLeft, lpavTop]
      ShowBorder = False
      Index = -1
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 32
    Top = 168
    object Proprieta: TAction
      Caption = 'Propriet'#224
      ImageIndex = 16
      OnExecute = ProprietaExecute
      OnUpdate = ProprietaUpdate
    end
  end
  object PopupMenu: TPopupMenu
    Images = dx.Immagini
    Left = 35
    Top = 219
    object Propriet1: TMenuItem
      Action = Proprieta
    end
  end
end
