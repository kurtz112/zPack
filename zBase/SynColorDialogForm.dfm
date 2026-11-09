object frmSynColorDialog: TfrmSynColorDialog
  Left = 421
  Top = 327
  BorderStyle = bsDialog
  ClientHeight = 355
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 7
    Width = 42
    Height = 13
    Caption = '&Element:'
  end
  object Label2: TLabel
    Left = 12
    Top = 128
    Width = 88
    Height = 13
    Caption = '&Foreground Color:'
  end
  object Label3: TLabel
    Left = 12
    Top = 173
    Width = 88
    Height = 13
    Caption = 'B&ackground Color:'
  end
  object ListBox1: TListBox
    Left = 10
    Top = 22
    Width = 145
    Height = 100
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListBox1Click
  end
  object SynEdit1: TSynEdit
    Left = 165
    Top = 22
    Width = 329
    Height = 295
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 1
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    ReadOnly = True
  end
  object ColorBox1: TColorBox
    Left = 11
    Top = 144
    Width = 145
    Height = 22
    DefaultColorColor = clNone
    NoneColorColor = clNone
    Selected = clScrollBar
    Style = [cbStandardColors, cbExtendedColors, cbIncludeNone, cbIncludeDefault, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 2
    OnChange = ColorBox1Change
    OnKeyDown = ColorBox1KeyDown
  end
  object ColorBox2: TColorBox
    Left = 10
    Top = 188
    Width = 145
    Height = 22
    DefaultColorColor = clNone
    NoneColorColor = clNone
    Selected = clScrollBar
    Style = [cbStandardColors, cbExtendedColors, cbIncludeNone, cbIncludeDefault, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 3
    OnChange = ColorBox2Change
    OnKeyDown = ColorBox1KeyDown
  end
  object GroupBox1: TGroupBox
    Left = 10
    Top = 217
    Width = 145
    Height = 100
    Caption = ' Text attributes '
    TabOrder = 4
    object CheckBox1: TCheckBox
      Left = 9
      Top = 17
      Width = 46
      Height = 17
      Caption = '&Bold'
      Enabled = False
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 9
      Top = 36
      Width = 46
      Height = 17
      Caption = '&Italic'
      Enabled = False
      TabOrder = 1
      OnClick = CheckBox2Click
    end
    object CheckBox3: TCheckBox
      Left = 9
      Top = 56
      Width = 69
      Height = 17
      Caption = '&Underline'
      Enabled = False
      TabOrder = 2
      OnClick = CheckBox3Click
    end
    object CheckBox4: TCheckBox
      Left = 9
      Top = 76
      Width = 72
      Height = 17
      Caption = '&Strike Out'
      Enabled = False
      TabOrder = 3
      OnClick = CheckBox4Click
    end
  end
  object btnOK: TButton
    Left = 342
    Top = 325
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 419
    Top = 325
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
end
