object zExceptionDetailForm: TzExceptionDetailForm
  Left = 0
  Top = 0
  Caption = 'Dettagli errore'
  ClientHeight = 576
  ClientWidth = 695
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object dxLayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 695
    Height = 576
    Align = alClient
    TabOrder = 0
    LayoutLookAndFeel = dxLayoutSkinLookAndFeel
    object treeStack: TcxTreeList
      Left = 26
      Top = 472
      Width = 643
      Height = 32
      Bands = <
        item
        end>
      Filtering.ColumnPopupMode = fpmExcel
      OptionsBehavior.ImmediateEditor = False
      OptionsBehavior.ChangeDelay = 1000
      OptionsBehavior.IncSearch = True
      OptionsBehavior.MultiSort = False
      OptionsCustomizing.ColumnFiltering = bTrue
      OptionsCustomizing.ColumnMoving = False
      OptionsData.Editing = False
      OptionsData.Deleting = False
      OptionsView.CellEndEllipsis = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.Indicator = True
      OptionsView.ShowRoot = False
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 8
      object stackSymbolName: TcxTreeListColumn
        Caption.Text = 'Metodo'
        Options.Sorting = False
        Width = 100
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackLineNumber: TcxTreeListColumn
        PropertiesClassName = 'TcxSpinEditProperties'
        BestFitMaxWidth = 70
        Caption.Text = 'Linea'
        Options.Sizing = False
        Options.Sorting = False
        Width = 70
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackRelLineNumber: TcxTreeListColumn
        PropertiesClassName = 'TcxSpinEditProperties'
        BestFitMaxWidth = 70
        Caption.Text = 'Linea Rel.'
        Options.Sizing = False
        Options.Sorting = False
        Width = 70
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackUnitName: TcxTreeListColumn
        Caption.Text = 'Unit'
        Options.Sorting = False
        Width = 100
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackSourceFile: TcxTreeListColumn
        Caption.Text = 'File'
        Options.Sorting = False
        Width = 100
        Position.ColIndex = 4
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackBaseName: TcxTreeListColumn
        Caption.Text = 'Modulo'
        Options.Sorting = False
        Width = 100
        Position.ColIndex = 5
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object stackCallAddress: TcxTreeListColumn
        Visible = False
        Caption.Text = 'Indirizzo'
        Options.Sorting = False
        Width = 100
        Position.ColIndex = 6
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
    end
    object btnSalva: TcxButton
      Left = 162
      Top = 539
      Width = 90
      Height = 25
      Action = Salva
      TabOrder = 10
    end
    object btnOk: TcxButton
      Left = 608
      Top = 539
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Chiudi'
      ModalResult = 1
      TabOrder = 14
    end
    object memoErrorMessage: TcxMemo
      Left = 26
      Top = 47
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 0
      Height = 89
      Width = 643
    end
    object edSQLCode: TcxTextEdit
      Left = 470
      Top = 398
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 7
      Text = 'cxTextEdit1'
      Width = 120
    end
    object edSQLState: TcxTextEdit
      Left = 285
      Top = 398
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 6
      Text = 'cxTextEdit1'
      Width = 120
    end
    object edSQLMessage: TcxTextEdit
      Left = 102
      Top = 368
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 4
      Text = 'cxTextEdit1'
      Width = 567
    end
    object edIBErrorCode: TcxTextEdit
      Left = 102
      Top = 398
      AutoSize = False
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 5
      Text = 'cxTextEdit1'
      Height = 23
      Width = 120
    end
    object memoIBMessage: TcxMemo
      Left = 102
      Top = 208
      Lines.Strings = (
        'memoIBMessage')
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 3
      Height = 153
      Width = 567
    end
    object btnMail: TcxButton
      Left = 259
      Top = 539
      Width = 90
      Height = 25
      Action = Invia
      TabOrder = 11
    end
    object btnCopia: TcxButton
      Left = 356
      Top = 539
      Width = 75
      Height = 25
      Action = Copia
      TabOrder = 12
    end
    object btnModificaDataSet: TcxButton
      Left = 438
      Top = 539
      Width = 110
      Height = 25
      Action = ModificaDataSet
      TabOrder = 13
    end
    object btnRichiestaAssistenza: TcxButton
      Left = 12
      Top = 539
      Width = 143
      Height = 25
      Action = RichiestaAssistenza
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object edDatamodule: TcxTextEdit
      Left = 102
      Top = 178
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 1
      Width = 266
    end
    object edDataset: TcxTextEdit
      Left = 423
      Top = 178
      AutoSize = False
      Properties.ReadOnly = True
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 2
      Height = 23
      Width = 246
    end
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ItemIndex = 1
      ShowBorder = False
      Index = -1
    end
    object dxLayoutItemStack: TdxLayoutItem
      Parent = dxLayoutGroupStack
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Layout = clTop
      Control = treeStack
      ControlOptions.OriginalHeight = 150
      ControlOptions.OriginalWidth = 250
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemSaveLog: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahLeft
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnSalva
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItemModificaDataSet: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahLeft
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnModificaDataSet
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object dxLayoutItemRichiestaAssistenza: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahLeft
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnRichiestaAssistenza
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 143
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemOk: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahRight
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnOk
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object dxLayoutGroupButtons: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avBottom
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      ItemIndex = 1
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 5
    end
    object dxLayoutEmptySpaceItem1: TdxLayoutEmptySpaceItem
      Parent = dxLayoutControlGroup_Root
      SizeOptions.Height = 7
      SizeOptions.Width = 10
      CaptionOptions.Text = 'Empty Space Item'
      Index = 4
    end
    object dxLayoutItemErrorMessage: TdxLayoutItem
      Parent = dxLayoutGroupEccezione
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Layout = clTop
      Control = memoErrorMessage
      ControlOptions.OriginalHeight = 89
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutSplitterItem1: TdxLayoutSplitterItem
      Parent = dxLayoutControlGroup_Root
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Splitter'
      Index = 2
    end
    object dxLayoutItemSQLCode: TdxLayoutItem
      Parent = dxLayoutGroupSQL
      AlignHorz = ahLeft
      CaptionOptions.Text = 'SQLCode:'
      Control = edSQLCode
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 120
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutItemSQLState: TdxLayoutItem
      Parent = dxLayoutGroupSQL
      AlignHorz = ahLeft
      CaptionOptions.Text = 'SQLState:'
      Control = edSQLState
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 120
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItemSQLMessage: TdxLayoutItem
      Parent = dxLayoutGroupIBError
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'SQLMessage:'
      Control = edSQLMessage
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItemIBErrorCode: TdxLayoutItem
      Parent = dxLayoutGroupSQL
      AlignHorz = ahLeft
      AlignVert = avClient
      CaptionOptions.Text = 'IBErrorCode:'
      Control = edIBErrorCode
      ControlOptions.OriginalHeight = 22
      ControlOptions.OriginalWidth = 120
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemIBMessage: TdxLayoutItem
      Parent = dxLayoutGroupIBError
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'IBMessage:'
      Control = memoIBMessage
      ControlOptions.OriginalHeight = 153
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutGroupFIB: TdxLayoutGroup
      Parent = dxLayoutGroupMessage
      AlignHorz = ahClient
      AlignVert = avBottom
      CaptionOptions.Glyph.SourceDPI = 96
      CaptionOptions.Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000018744558745469746C650044617461536F757263653B4F
        7074696F6E7318FCC056000002A749444154785E85915F48935118C69F6F4E6D
        E8226D54282462E63F50872093106B32A61888A05B7FA82C4923BAD09B8ABA30
        24E82E2F52B1F2A284C890C894946C1189A4A685CBF96722EACC744E73EAD86C
        FBBE734EFBD8846A931E38BC1CCEFBFE78CEF372F049D2FFA0AC5802E4714002
        63341E8C4B23948C53C2E689406608211F35B7BB3B0150E615FE9064B0416798
        EEAA634B9F5BD9CF890EE6B0F4326A1F645BD3EDCC36DCC82C863A666CAD62EF
        EA0AFBC47E717EE74801708CD1FC446D25C008403DDEE206E8362215B188888A
        06232EC4A4A460E5714BAE080040E1930F407802C1390F6944BCF80C0E140C14
        5422E0D7EA0FB8D71701F732082F40ECFFCBBE08A08482F29B105C360061E0ED
        0370589AB13A528FD9CE662CBCEF807B6D0144204101A03CC1FF05107F5F8003
        8108D85D1CE4F15990A796E2A8A63CB803C2D3C0B1109937931884EF3F0CD9A1
        2418C678B40C87E2EACD877739AF6AEE3C4575ED137F8842A03569641A363D32
        AC4639B1B44E316076E3824E8DC696379557AE370D6D3B5DC4ED768EFAB710F8
        0571C7AF3FB9C0ED39089B6D1325454AC4C52AA02FC9DD6BE81B6D5744CB3136
        39D7E30B91040FF1D03E0287C389AA722D8CC6299C2AAF85F1DB142E9DD160C3
        BE8135EB4ABF08A0CE6DBE7BA4FD0516478760FF3E230241F9759C504660D23C
        0F8F87C7C097699C56C7598DA639104A31F2758274B5DDBBCFF9530D6F3A9BA1
        97854A8A438023120992E3B20B43C7B714CC8A035CC5B902BCFD608469CA826C
        65225459496878F40A66F3EC2D6E2774FF46A462F5DF433425D52F95E9C99A65
        EB1AB4DA63484F4BC0DCEC229EB5F540BE37122693B9570C2BE81121D9C7CF27
        E4A82F9679EBE582D21B8EE71D7D4CA5AE7064AA745519393A7D6A6651E2AE80
        7F9C85E5155EABCF3F59C33254FA7A00E13B4E7F038A7C6509079C5294000000
        0049454E44AE426082}
      CaptionOptions.Text = 'DB'
      Index = 1
      Buttons = <
        item
          Glyph.SourceDPI = 96
          Glyph.Data = {
            89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
            6100000025744558745469746C6500436F70793B426172733B526962626F6E3B
            5374616E646172643B436C6F6E656D0EDF5B000001B649444154785E7D90318B
            53411446CF7DD94D229AC24A2BC1CADE56248D8A76D65A2B6C6721DA0A82D66A
            A1A58DFD7656168B0B36D6AB85827F40566159F3E6CDBD9F929921210B4E3317
            1EE7BC33D724B17E66B3D9E8F9EBBD0F9DD95C18104842180290109053FAF8E4
            C18D6B5B9C3C9DD07CE7CE65A0C9A9F06A7EF1F6F35560B4149899011D6093C9
            647CE1FC1952EAF9B37000A28266DD3F62C47432C2B303582BE89EBDF954B265
            7CF97EC8C1B79F88AE660702CE9D9D72FBE62526E35364DF10483E7F74FFCA7F
            B39FBEDA27E78C24D210EB02CC73418E6BB6B07207C8C474DC2DB3DD45881305
            960747802464566E00A3CC1572050A11454013903C00080C095001010221897E
            88B5026D3E21832042C8A83308812850CE840721E1B1B18361080484B4064351
            14B1BB2384043E6C1464CFE54314A87A304140CB66BADD11802B00B47AC29254
            2D68FF368450D4820876DF1FF0F5C711B93FDA07721330785058519750E02613
            780A1EEE5CBF381E8F7F0103B06802A2EEE0F4740B54F090210588964D4AE9B0
            EFFBDF8D6B02EFD3F1DEBDC7BB73B15AA299AABD088645C906D814A4772FEFDE
            02B601033879A396BD2EF80B61825062DDA3F2C70000000049454E44AE426082}
          OnClick = dxLayoutGroupFIBButton0Click
        end>
    end
    object dxLayoutGroupIBError: TdxLayoutGroup
      Parent = dxLayoutGroupFIB
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      ShowBorder = False
      Index = 1
    end
    object dxLayoutGroupSQL: TdxLayoutGroup
      Parent = dxLayoutGroupFIB
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object dxLayoutGroupMessage: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      ItemIndex = 1
      ShowBorder = False
      Index = 1
    end
    object dxLayoutEmptySpaceItem2: TdxLayoutEmptySpaceItem
      Parent = dxLayoutControlGroup_Root
      SizeOptions.Height = 7
      SizeOptions.Width = 10
      CaptionOptions.Text = 'Empty Space Item'
      Index = 0
    end
    object dxLayoutGroupStack: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Glyph.SourceDPI = 96
      CaptionOptions.Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000014744558745469746C650054726565566965773B547265
        653B5F4223D70000015F49444154785E95923B4B03511085CF4D3636FE152D52
        D9694220A095F80B6C14B150025A898A885D5008F840496921DA0A5A442C63A3
        36FE0A2D7C10C37DEC1C77371B8B3C76F5C0B0C5DCFD3873663C9250819E8EA6
        1A208B14222A12BEF3EF27D69A25928221F2E26F46AC2B8ECF2D429C059D06AD
        46B37E56009005900A504E3BD8CF37482B286B003502AB5DD403807440DBC07E
        BCC26FBD43AC0E4DC119F93380AD2FD3689E5F95C41122020AA10DEF005005EA
        01312C92BF00BF5C7D990690AD6C9EB40F769746E347F2783879AB80C2A07001
        88872E0AB06155B64EB1BA71FC4D10B5BDE52C9D5F184B08D7438FACB5109188
        B950D987D31789E1F603B481908A22A8D7D673F33B7993106E3F405B83CEBC92
        16AE0C71108D00A174C39D89E7CDC4B609C085BD81006322075D008213BF1976
        E2831D181BFD4C32E1C493B7F0CC8E509E5D81D30FFFDBC2F565358F584AA9DC
        763E6D0B894ADFC20F5D296B4A3DF29D370000000049454E44AE426082}
      CaptionOptions.Text = 'Stack'
      Index = 3
      Buttons = <
        item
          Glyph.SourceDPI = 96
          Glyph.Data = {
            89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
            6100000025744558745469746C6500436F70793B426172733B526962626F6E3B
            5374616E646172643B436C6F6E656D0EDF5B000001B649444154785E7D90318B
            53411446CF7DD94D229AC24A2BC1CADE56248D8A76D65A2B6C6721DA0A82D66A
            A1A58DFD7656168B0B36D6AB85827F40566159F3E6CDBD9F929921210B4E3317
            1EE7BC33D724B17E66B3D9E8F9EBBD0F9DD95C18104842180290109053FAF8E4
            C18D6B5B9C3C9DD07CE7CE65A0C9A9F06A7EF1F6F35560B4149899011D6093C9
            647CE1FC1952EAF9B37000A28266DD3F62C47432C2B303582BE89EBDF954B265
            7CF97EC8C1B79F88AE660702CE9D9D72FBE62526E35364DF10483E7F74FFCA7F
            B39FBEDA27E78C24D210EB02CC73418E6BB6B07207C8C474DC2DB3DD45881305
            960747802464566E00A3CC1572050A11454013903C00080C095001010221897E
            88B5026D3E21832042C8A83308812850CE840721E1B1B18361080484B4064351
            14B1BB2384043E6C1464CFE54314A87A304140CB66BADD11802B00B47AC29254
            2D68FF368450D4820876DF1FF0F5C711B93FDA07721330785058519750E02613
            780A1EEE5CBF381E8F7F0103B06802A2EEE0F4740B54F090210588964D4AE9B0
            EFFBDF8D6B02EFD3F1DEBDC7BB73B15AA299AABD088645C906D814A4772FEFDE
            02B601033879A396BD2EF80B61825062DDA3F2C70000000049454E44AE426082}
          OnClick = dxLayoutGroupStackButton0Click
        end>
    end
    object dxLayoutGroupEccezione: TdxLayoutGroup
      Parent = dxLayoutGroupMessage
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Glyph.SourceDPI = 96
      CaptionOptions.Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000011744558745469746C65004572726F723B4661696C3BE8
        835D03000001E849444154785EC593DB4B93711880BB9A7F43ECA293A5EC4231
        FB9496DA51E82277614442299D46A7F5752168A7455141888850633097611EC8
        4379086994E186B36F35681B692C87E045A690376E8679F5F4FE60775F7853D0
        C573F3BECFEFB97A7F1B80BFE2DF07BEDEBA661174C11032598CECCCB26E60AA
        A1DE2AC416BAFDFC1C7F49E66D0FE9D75DAC04BA5878EA41ED94F3C7404C7759
        84D86287871F1DCD24DD2E9607BCA4FB3D4CD79F61BEA591456F13E2C4851C53
        20E2745E996B7DC852DB03C277DCBCB8DB42543F4BF87C2DBDB79B99BCD1C0B7
        7B9799BB7F13E59A02A19375C6F7A64652D79D4C7ADB59058C9E41463D9DA401
        C3EB2771BA8A79F725946B0ABCA93EB6367BE22029D77112B54748F60FB00C0A
        A69FF7F2F1A8EC2E54335B5789B8BF4C8191C3556B3335FB99729410D8A731EA
        EB230DAC02A1EE61027B77F1D951CA4CCD01C4CD98027DE59546C25141B87813
        A1476D2C01A9E1572407475801261EFB081658255281724D81CEE2327DBC6C0F
        91F27C3EE9E7483D6B67E250A9A0F1E5898FE8C5537C90DD3BFB6E946B0AF86D
        5A8E101F2BD98961DF41B0682BEFED3605C1C2CD6AC69856843809E59A020ACF
        9602AB101BCA578F728968DB855C4285DB18CAB321BBB872D63DE5D68D7916E1
        AA101556B244B333D329FFFFDFF81BEAAAB702F51D56B10000000049454E44AE
        426082}
      CaptionOptions.Text = 'Eccezione'
      Index = 0
    end
    object dxLayoutItemInviaMail: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahLeft
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnMail
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutItemCopia: TdxLayoutItem
      Parent = dxLayoutGroupButtons
      AlignHorz = ahLeft
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnCopia
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutItemDatamodule: TdxLayoutItem
      Parent = dxLayoutGroupDataset
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'Datamodule:'
      Control = edDatamodule
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemDataset: TdxLayoutItem
      Parent = dxLayoutGroupDataset
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Dataset:'
      Control = edDataset
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutGroupDataset: TdxLayoutGroup
      Parent = dxLayoutGroupFIB
      CaptionOptions.Text = 'Dataset'
      ItemIndex = 1
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 192
    Top = 48
    object Salva: TdxFileSaveAs
      Caption = 'Salva Log'
      Dialog.DefaultExt = '*.zlog'
      Dialog.Filter = 'Log|*.zlog|Tutti|*.*'
      ImageIndex = 92
      BeforeExecute = SalvaBeforeExecute
      OnAccept = SalvaAccept
    end
    object Invia: TAction
      Caption = 'Invia Mail'
      ImageIndex = 461
      OnExecute = InviaExecute
    end
    object Copia: TAction
      Caption = 'Copia'
      ImageIndex = 42
      OnExecute = CopiaExecute
    end
    object ModificaDataSet: TAction
      Caption = 'Modifica SQL...'
      OnExecute = ModificaDataSetExecute
    end
    object RichiestaAssistenza: TAction
      Caption = 'Richiedi assistenza'
      ImageIndex = 203
      OnExecute = RichiestaAssistenzaExecute
    end
  end
  object dxLayoutLookAndFeelList: TdxLayoutLookAndFeelList
    Left = 345
    Top = 65
    object dxLayoutSkinLookAndFeel: TdxLayoutSkinLookAndFeel
      PixelsPerInch = 96
    end
  end
end
