object zFormInspector: TzFormInspector
  Left = 861
  Top = 252
  BorderStyle = bsSizeToolWin
  Caption = 'zFormInspector'
  ClientHeight = 516
  ClientWidth = 317
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object OkCancel: TOkCancel
    Left = 0
    Top = 486
    Width = 317
    Height = 30
    Align = alBottom
    TabOrder = 0
     
    DefaultOk = False
    DefaultCancel = False
    ExplicitTop = 474
    ExplicitWidth = 309
  end
  object FrameObjectInspector: TFrameObjectInspector
    Left = 0
    Top = 0
    Width = 317
    Height = 486
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 309
    ExplicitHeight = 474
  end
end
