object zMultiViewer: TzMultiViewer
  Left = 0
  Top = 0
  Width = 416
  Height = 270
  TabOrder = 0
  object PageControl: TcxPageControl
    Left = 0
    Top = 0
    Width = 416
    Height = 270
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tabNone
    Properties.CustomButtons.Buttons = <>
    LookAndFeel.Kind = lfUltraFlat
    LookAndFeel.NativeStyle = False
    ClientRectBottom = 270
    ClientRectRight = 416
    ClientRectTop = 26
    object tabNone: TcxTabSheet
      Caption = 'None'
      ImageIndex = 4
      object labelEmpty: TcxLabel
        Left = 0
        Top = 0
        Align = alClient
        Caption = 'Nessun file da visualizzare'
        Style.TextStyle = [fsItalic]
        Properties.Alignment.Horz = taCenter
        Properties.Alignment.Vert = taVCenter
        TabOrder = 0
        AnchorX = 208
        AnchorY = 122
      end
    end
    object tabWord: TcxTabSheet
      Caption = 'Word'
      ImageIndex = 3
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabExcel: TcxTabSheet
      Caption = 'Excel'
      ImageIndex = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabPdf: TcxTabSheet
      Caption = 'Pdf'
      ImageIndex = 1
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabImage: TcxTabSheet
      Caption = 'Image'
      ImageIndex = 2
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabMail: TcxTabSheet
      Caption = 'Mail'
      ImageIndex = 5
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
    object tabSynEdit: TcxTabSheet
      Caption = 'SynEdit'
      ImageIndex = 6
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object dxActivityIndicator: TdxActivityIndicator
    AlignWithMargins = True
    Left = 50
    Top = 50
    Width = 316
    Height = 170
    Margins.Left = 50
    Margins.Top = 50
    Margins.Right = 50
    Margins.Bottom = 50
    Align = alClient
    PropertiesClassName = 'TdxActivityIndicatorCircularDotsProperties'
    Transparent = True
  end
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 40
    Top = 64
  end
  object DataSource: TDataSource
    OnDataChange = DataSourceDataChange
    Left = 40
    Top = 120
  end
  object ActionList: TActionList
    Images = cxImageList
    Left = 120
    Top = 120
    object EditTools: TAction
      Caption = 'Tools...'
      ImageIndex = 0
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
  end
  object cxImageList: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 4194424
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002E744558745469746C650047726F75703B4669656C643B436F6C6C65
          6374696F6E3B437573746F6D697A3B53657474696E67737CF8E99E0000026049
          444154785E7D924D4854511886DF73E78CA316FDDAAA7D149441663458E354B6
          749389D2A295A2C940B6AE45D1AE3F5121C14594A043191191B4B291EC07940A
          AA456D2A70A0FC9B306C6EF7FC7CA7CEB9339A48BE977B5FCEC7FDDE73BEFB5C
          668CC1A5F43B5C3CB53772FEF6EB5130AF968C81AD13151D2043D0523DEB49D5
          1C33C62814C4AD0949D63C45A83D7D7237C200DB041750F45B436F1300220056
          0648E1D64C48055F687C9EF661C21027632F5A7ACF83D58A80F0044C0A83BC20
          94D8AAF1608ACD602E502882D5AA80200C20DFF79F0EA4DF1C75BB93FB066108
          11B40194F89D01A0DBBAC6C2117561B6966BE3C5A395002803B00EC006009B00
          6C06B0C579582B07100310B53D8EC2BFEAE81947DFD9046FBD3A6A89244212AB
          8928219EDFBD5C5FC71963B04A26934C4AE9A8C46231AE34129DED35CB440ACD
          BAB0EEEACD1C02C0793C1EE7D168941111DF51D598B7F366B3D96DE7FEE2DCCE
          09BE6678F4696125116D89484784EFAC6E923FE6E7C688F454FDF1FD6EA7E9EF
          0DBDFDFDC3F8F2358BBEBE0B288F460A44A84864891C17814067AA29393B9BC3
          81EA5D6E562555F3D68A8DB8DE9DC6DCCC021E0C4E82F4321132800CF2E30014
          CFCD4C358F3C7931D4D17AC2BBD235E8D253ED8DB8D97FDF2CFEFCD65657B3E7
          612E979308C5427359B61670A5B5479AD8AF7C8048C473FC17F381731E890595
          95950B994C46E03FF2C04A878E24AAD8AB89F738D3DAE0EE89C90FA83DBC8F19
          AFF48ED63A8635C4B556B8D13DF0928C9E9742D55BC6C3C3238F8DF12A0CF30E
          1211D612F7E727D773CE1980B2F43D6F0656F98F2DF6A994B2FF848F35F40750
          7F89538840F6FC0000000049454E44AE426082}
        FileName = 'Images\Reports\GroupFieldCollection_16x16.png'
        Keywords = 'Reports;GroupFieldCollection'
      end>
  end
end
