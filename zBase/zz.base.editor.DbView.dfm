inherited zFrameEditor_DbView: TzFrameEditor_DbView
  Width = 591
  Height = 415
  HelpContext = 26150
  HorzScrollBar.Increment = 10
  VertScrollBar.Increment = 11
  ExplicitWidth = 591
  ExplicitHeight = 415
  object PageControl1: TcxPageControl
    Left = 0
    Top = 0
    Width = 591
    Height = 415
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tabColumns
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 411
    ClientRectLeft = 4
    ClientRectRight = 587
    ClientRectTop = 24
    object tabColumns: TcxTabSheet
      Caption = 'Colonne'
      object FrameCollection: TFrameCollection
        Left = 0
        Top = 0
        Width = 583
        Height = 387
        Align = alClient
        TabOrder = 0
        CheckBoxes = True
        OnNodeChecked = FrameCollectionNodeChecked
        OnInspectorModified = FrameCollectionInspectorModified
      end
    end
    object tabView: TcxTabSheet
      Caption = 'Propriet'#224
      ImageIndex = 1
      object InspectorDbView: TFrameObjectInspector
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 577
        Height = 381
        Align = alClient
        TabOrder = 0
      end
    end
  end
end
