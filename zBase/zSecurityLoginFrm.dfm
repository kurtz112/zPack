object zSecurityLoginForm: TzSecurityLoginForm
  Left = 521
  Top = 291
  Cursor = crArrow
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Login'
  ClientHeight = 163
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object AppIcon: TImage
    Left = 14
    Top = 12
    Width = 32
    Height = 32
    AutoSize = True
    OnDblClick = IconDblClick
  end
  object KeyImage: TImage
    Left = 10
    Top = 15
    Width = 32
    Height = 32
    AutoSize = True
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF00000000000000000000000000000000008FFFFFFFFFFFFFFFFF000000
      000000008FFFFFFFFFFFFFFFFF000000000000008FFFFFFFFFF00F00FF000000
      000000008FF800FFFFF00F00FF000000000000008F80800FFFF00F00FF000000
      000000008F00FF00000000000F000000000000008F00FF00000000000F000000
      000000008F80800FFFFFFFFFFF000000000000008FF800FFFFFFFFFFFF000000
      000000008FFFFFFFFFFFFFFFFF00000000000000888888888888888888000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000001FFF00001FFF00001FFF00001FFF00001FFF00001FFF00001FFF
      00001FFF00001FFF00001FFF00001FFF00001FFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFF}
    OnDblClick = IconDblClick
  end
  object HintLabel: TLabel
    Left = 64
    Top = 31
    Width = 285
    Height = 13
    AutoSize = False
    Caption = 'Inserire nome utente e password.'
    ShowAccelChar = False
  end
  object UserNameLabel: TLabel
    Left = 64
    Top = 64
    Width = 60
    Height = 13
    AutoSize = False
    Caption = 'Utente'
    FocusControl = UserNameEdit
  end
  object PasswordLabel: TLabel
    Left = 64
    Top = 96
    Width = 60
    Height = 13
    AutoSize = False
    Caption = 'Password'
    FocusControl = PasswordEdit
  end
  object AppTitleLabel: TLabel
    Left = 64
    Top = 12
    Width = 285
    Height = 13
    AutoSize = False
    ShowAccelChar = False
  end
  object CustomLabel: TLabel
    Left = 64
    Top = 128
    Width = 60
    Height = 13
    AutoSize = False
    Caption = 'DataBase'
    FocusControl = ComboConnections
  end
  object UserNameEdit: TcxTextEdit
    Left = 120
    Top = 61
    Cursor = crIBeam
    TabOrder = 0
    Width = 225
  end
  object PasswordEdit: TcxTextEdit
    Left = 120
    Top = 93
    Cursor = crIBeam
    Properties.EchoMode = eemPassword
    Properties.PasswordChar = '*'
    Properties.ShowPasswordRevealButton = True
    TabOrder = 1
    Width = 225
  end
  object OkBtn: TcxButton
    Left = 356
    Top = 12
    Width = 77
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = OkBtnClick
  end
  object CancelBtn: TcxButton
    Left = 356
    Top = 44
    Width = 77
    Height = 25
    Cancel = True
    Caption = 'Annulla'
    ModalResult = 2
    TabOrder = 4
  end
  object ComboConnections: TcxComboBox
    Left = 120
    Top = 125
    Properties.DropDownListStyle = lsEditFixedList
    Properties.DropDownRows = 12
    Properties.DropDownSizeable = True
    Properties.ImmediateDropDownWhenActivated = True
    Properties.Revertable = True
    Properties.Sorted = True
    TabOrder = 2
    OnEnter = ComboConnectionsEnter
    Width = 225
  end
end
