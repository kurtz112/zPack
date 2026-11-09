object OkCancel: TOkCancel
  Left = 0
  Top = 0
  Width = 451
  Height = 35
  Align = alBottom
  TabOrder = 0
  OnResize = FrameResize
  object PaintBox: TPaintBox
    Left = 429
    Top = 0
    Width = 22
    Height = 35
    Align = alRight
    OnPaint = PaintBoxPaint
    ExplicitLeft = 413
    ExplicitHeight = 30
  end
  object OkBtn: TcxButton
    Left = 274
    Top = 3
    Width = 65
    Height = 24
    Caption = 'Ok'
    LookAndFeel.Kind = lfUltraFlat
    ModalResult = 1
    TabOrder = 1
  end
  object CancelBtn: TcxButton
    Left = 347
    Top = 3
    Width = 65
    Height = 24
    Caption = 'Annulla'
    LookAndFeel.Kind = lfUltraFlat
    ModalResult = 2
    TabOrder = 2
  end
  object ApplyBtn: TcxButton
    Left = 201
    Top = 3
    Width = 65
    Height = 24
    Caption = 'Applica'
    LookAndFeel.Kind = lfUltraFlat
    TabOrder = 0
    OnClick = ApplyBtnClick
  end
end
