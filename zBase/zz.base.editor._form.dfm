object zFormEditorCollectionItem: TzFormEditorCollectionItem
  Left = 784
  Top = 435
  Caption = 'Item Editor'
  ClientHeight = 446
  ClientWidth = 596
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 15
  object OkCancel: TOkCancel
    Left = 0
    Top = 418
    Width = 596
    Height = 28
    Align = alBottom
    TabOrder = 0
    OnApply = OkCancelApply
    DefaultOk = False
    DefaultCancel = False
  end
end
