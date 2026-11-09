object FormEditorSQL: TFormEditorSQL
  Left = 0
  Top = 0
  ClientHeight = 561
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object OkCancel: TOkCancel
    Left = 0
    Top = 526
    Width = 784
    Height = 35
    Align = alBottom
    TabOrder = 0
    DefaultOk = False
    DefaultCancel = False
  end
  object EditorSQL: TFrameEditor_Sql
    Left = 0
    Top = 0
    Width = 784
    Height = 526
    Align = alClient
    TabOrder = 1
    OnFormatSQL = EditorSQLFormatSQL
    ExplicitLeft = 240
    ExplicitTop = 176
    ExplicitWidth = 663
    ExplicitHeight = 559
  end
end
