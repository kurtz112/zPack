object zFormCollection: TzFormCollection
  Left = 412
  Top = 229
  Caption = 'Collection Editor'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  
  TextHeight = 13
  object FrameCollection: TFrameCollection
    Left = 0
    Top = 0
    Width = 624
    Height = 413
    Align = alClient
    TabOrder = 0
  end
  object OkCancel: TOkCancel
    Left = 0
    Top = 413
    Width = 624
    Height = 28
    Align = alBottom
    TabOrder = 1
     
    DefaultOk = False
    DefaultCancel = False
  end
end
