object zPanelFrame: TzPanelFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 208
  VertScrollBar.Visible = False
  Color = clBtnFace
  ParentColor = False
  TabOrder = 0
  OnResize = FrameResize
  object fPanello: TScrollBox
    Left = 0
    Top = 3
    Width = 320
    Height = 15
    Align = alTop
    AutoScroll = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInactiveCaption
    ParentColor = False
    TabOrder = 0
    OnDblClick = RiduciEspandi
    DesignSize = (
      320
      15)
    object fBottone: TSpeedButton
      Left = 304
      Top = 0
      Width = 15
      Height = 15
      Anchors = [akTop, akRight]
      Flat = True
      Glyph.Data = {
        EE000000424DEE000000000000007600000028000000100000000F0000000100
        0400000000007800000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDDDDDDD0DDDDDDDDDDDDDD000DDDDDDDDDDDD00000DDDDDDDDDD0000000D
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
      OnClick = RiduciEspandi
    end
    object fTitolo: TStaticText
      Left = 5
      Top = 0
      Width = 35
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      BevelInner = bvNone
      BevelOuter = bvNone
      Caption = 'Titolo'
      Color = clInactiveCaption
      Font.Charset = ANSI_CHARSET
      Font.Color = clInactiveCaptionText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 0
      Transparent = False
      OnDblClick = RiduciEspandi
    end
    object Separatore: TStaticText
      Left = 0
      Top = 0
      Width = 5
      Height = 15
      Align = alLeft
      AutoSize = False
      BevelInner = bvNone
      BevelOuter = bvNone
      Caption = '           '
      Font.Charset = ANSI_CHARSET
      Font.Color = cl3DLight
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Transparent = False
    end
  end
  object SizePanel: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 3
    Cursor = crSizeNS
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 1
    OnMouseDown = SizePanelMouseDown
    OnMouseMove = SizePanelMouseMove
    OnMouseUp = SizePanelMouseUp
  end
end
