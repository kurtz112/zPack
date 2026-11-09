inherited zFrameEditor_DbPivot: TzFrameEditor_DbPivot
  Width = 652
  Height = 417
  HelpContext = 26150
  HorzScrollBar.Increment = 10
  VertScrollBar.Increment = 11
  ExplicitWidth = 652
  ExplicitHeight = 417
  object PageControl1: TcxPageControl
    Left = 0
    Top = 0
    Width = 652
    Height = 417
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tabFields
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 413
    ClientRectLeft = 4
    ClientRectRight = 648
    ClientRectTop = 24
    object tabFields: TcxTabSheet
      Caption = 'Campi'
      object FrameCollection: TFrameCollection
        Left = 0
        Top = 0
        Width = 644
        Height = 389
        Align = alClient
        TabOrder = 0
        CheckBoxes = True
        OnNodeChecked = FrameCollectionNodeChecked
        OnInspectorModified = FrameCollectionInspectorModified
        OnBeforeInsert = FrameCollectionBeforeInsert
        OnBeforeDelete = FrameCollectionBeforeDelete
      end
    end
    object tabPivot: TcxTabSheet
      Caption = 'Propriet'#224
      ImageIndex = 1
      object InspectorDbView: TFrameObjectInspector
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 638
        Height = 383
        Align = alClient
        TabOrder = 0
      end
    end
  end
end
