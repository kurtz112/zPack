object FrameDescription: TFrameDescription
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  OnResize = FrameResize
  object dxFormattedLabel: TdxFormattedLabel
    AlignWithMargins = True
    Left = 3
    Top = 18
    Align = alClient
    Caption = 
      'OnHyperlinkClick, OnHyperlinkMouseEnter, OnHyperlinkMouseLeave, ' +
      'and OnShowHyperlinkHint events may help you respond to user inte' +
      'raction (for example, to replace hyperlink hint text or prevent ' +
      'the activation of certain hyperlinks):'#13#10#13#10'Delphi'#13#10'procedure TFor' +
      'm1.dxLayoutLabeledItem2HyperlinkClick(Sender: TObject;'#13#10'  AArgs:' +
      ' TdxHyperlinkClickEventArgs);'#13#10'begin'#13#10' AArgs.Handled:= True;'#13#10'  ' +
      'dxShowMessage('#39'This click is handled'#39')'#13#10'end;'#13#10#13#10'procedure TForm1' +
      '.dxLayoutLabeledItem2ShowHyperlinkHint(Sender: TObject;'#13#10'  AArgs' +
      ': TdxShowHyperlinkHintEventArgs);'#13#10'begin'#13#10'  if AArgs.Text = '#39'cus' +
      'tomized hint'#39' then'#13#10'    AArgs.Hint := '#39'Customized Hint'#39#13#10'end;'
    PopupMenu = dxBarPopupMenu
    Properties.WordWrap = True
    Transparent = True
    OnDblClick = dxFormattedLabelDblClick
    Width = 634
  end
  object pnlTop: TdxPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 15
    Align = alTop
    Frame.Visible = False
    TabOrder = 1
    object btnClose: TcxButton
      AlignWithMargins = True
      Left = 622
      Top = 0
      Width = 15
      Height = 15
      Margins.Left = 0
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alRight
      Caption = 'x'
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.SourceHeight = 5
      OptionsImage.Glyph.SourceWidth = 5
      OptionsImage.Glyph.Data = {
        3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
        462D38223F3E0D0A3C7376672076657273696F6E3D22312E31222069643D224C
        61796572312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
        323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
        772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
        307078222076696577426F783D2230203020333220333222207374796C653D22
        656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
        2220786D6C3A73706163653D227072657365727665223E262331333B26233130
        3B20203C7374796C6520747970653D22746578742F6373732220786D6C3A7370
        6163653D227072657365727665223E2E426C61636B262331333B262331303B20
        2020207B262331333B262331303B20202020202066696C6C3A23373237323732
        3B262331333B262331303B202020202020666F6E742D66616D696C793A266170
        6F733B64782D666F6E742D69636F6E732661706F733B3B262331333B26233130
        3B202020202020666F6E742D73697A653A333270783B262331333B262331303B
        202020207D262331333B262331303B20203C2F7374796C653E0D0A3C74657874
        20783D22302220793D2233322220636C6173733D22426C61636B223EEE9C913C
        2F746578743E0D0A3C2F7376673E0D0A}
      PaintStyle = bpsCaption
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -8
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnCloseClick
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 48
    Top = 32
    object Editor: TAction
      Caption = 'Editor'
      ImageIndex = 531
      OnExecute = EditorExecute
    end
    object Sinistra: TAction
      AutoCheck = True
      Caption = 'Sinistra'
      GroupIndex = 1
      ImageIndex = 255
      OnExecute = SinistraExecute
    end
    object Alto: TAction
      AutoCheck = True
      Caption = 'Alto'
      GroupIndex = 1
      ImageIndex = 261
      OnExecute = AltoExecute
    end
    object Basso: TAction
      AutoCheck = True
      Caption = 'Basso'
      GroupIndex = 1
      ImageIndex = 250
      OnExecute = BassoExecute
    end
    object Destra: TAction
      AutoCheck = True
      Caption = 'Destra'
      GroupIndex = 1
      ImageIndex = 257
      OnExecute = DestraExecute
    end
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = ChiudiExecute
    end
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Predefinito')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 48
    Top = 144
    PixelsPerInch = 96
    object dxBarButton1: TdxBarButton
      Action = Editor
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = Sinistra
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton3: TdxBarButton
      Action = Destra
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton4: TdxBarButton
      Action = Alto
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton5: TdxBarButton
      Action = Chiudi
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = Basso
      Category = 0
      ButtonStyle = bsChecked
    end
  end
  object dxBarPopupMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton4'
      end
      item
        Visible = True
        ItemName = 'dxBarButton6'
      end
      item
        Visible = True
        ItemName = 'dxBarButton2'
      end
      item
        Visible = True
        ItemName = 'dxBarButton3'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton5'
      end>
    UseOwnFont = False
    OnShow = dxBarPopupMenuShow
    Left = 48
    Top = 208
    PixelsPerInch = 96
  end
  object TimerResize: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerResizeTimer
    Left = 48
    Top = 272
  end
end
