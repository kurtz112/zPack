object zSecComponentRestrictionsForm: TzSecComponentRestrictionsForm
  Left = 749
  Top = 182
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Component Restrictions'
  ClientHeight = 403
  ClientWidth = 653
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 373
    Width = 653
    Height = 30
    Align = alBottom
    TabOrder = 0
     
    DefaultOk = False
    DefaultCancel = False
    ExplicitTop = 295
    ExplicitWidth = 434
  end
  object cxPageControl: TcxPageControl
    AlignWithMargins = True
    Left = 3
    Top = 7
    Width = 647
    Height = 363
    Margins.Top = 7
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = tabUtenti
    Properties.CustomButtons.Buttons = <>
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 434
    ExplicitHeight = 295
    ClientRectBottom = 362
    ClientRectLeft = 1
    ClientRectRight = 646
    ClientRectTop = 21
    object tabUtenti: TcxTabSheet
      Caption = 'Utenti'
      ImageIndex = 0
      ExplicitWidth = 432
      ExplicitHeight = 273
      object viewUtenti: TzDbView
        Left = 0
        Top = 0
        Width = 645
        Height = 341
        Align = alClient
        Color = clBtnFace
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ToolActions = <>
        ExplicitWidth = 432
        ExplicitHeight = 273
      end
    end
    object tabDettaglio: TcxTabSheet
      Caption = 'Dettaglio'
      ImageIndex = 1
      ExplicitWidth = 651
      ExplicitHeight = 351
      object viewDettaglio: TzDbView
        Left = 0
        Top = 0
        Width = 645
        Height = 341
        Align = alClient
        Color = clBtnFace
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ToolActions = <>
        ExplicitTop = -5
        ExplicitWidth = 432
        ExplicitHeight = 273
      end
    end
  end
  object Utenti: TzFbDataSet
    Transaction = Transaction
    UpdateTransaction = Transaction
    FetchOptions.AssignedValues = [evDetailDelay]
    FetchOptions.DetailDelay = 300
    SQL.Strings = (
      'SELECT'
      '    *'
      'FROM'
      '    USR_WHO_CAN_SEE'
      'WHERE'
      '    USR_WHO_CAN_SEE.APP = :APP AND'
      '    USR_WHO_CAN_SEE.FORM = :FORM AND'
      '    USR_WHO_CAN_SEE.COMPONENT = :COMPONENT'
      'ORDER BY'
      '    CASE USR_WHO_CAN_SEE.ACCESS'
      '      WHEN '#39'W'#39' THEN 1'
      '      WHEN '#39'R'#39' THEN 2'
      '      WHEN '#39'X'#39' THEN 3'
      '    END,'
      '    USR_WHO_CAN_SEE.NOMINATIVO_O_RAGIONE_SOCIALE  ')
    TableName = 'USR_WHO_CAN_SEE'
    UseSqlLocate = False
    Left = 72
    Top = 112
    ParamData = <
      item
        Name = 'APP'
        ParamType = ptInput
      end
      item
        Name = 'FORM'
        ParamType = ptInput
      end
      item
        Name = 'COMPONENT'
        ParamType = ptInput
      end>
  end
  object Transaction: TzFbTransaction
    Options.Isolation = xiReadCommitted
    Left = 64
    Top = 40
  end
  object Dettaglio: TzFbDataSet
    Transaction = Transaction
    UpdateTransaction = Transaction
    FetchOptions.AssignedValues = [evDetailDelay]
    FetchOptions.DetailDelay = 300
    SQL.Strings = (
      'SELECT'
      '    USR_COMPONENT_RESTRICTIONS.*'
      'FROM'
      '    USR_COMPONENT_RESTRICTIONS'
      'WHERE'
      '    USR_COMPONENT_RESTRICTIONS.APP = :APP AND'
      '    USR_COMPONENT_RESTRICTIONS.FORM = :FORM AND'
      '    USR_COMPONENT_RESTRICTIONS.COMPONENT = :COMPONENT'
      'ORDER BY'
      '    CASE USR_COMPONENT_RESTRICTIONS.RESTRICTION_LEVEL'
      '      WHEN '#39'P'#39' THEN 1'
      '      WHEN '#39'G'#39' THEN 2'
      '      WHEN '#39'U'#39' THEN 3'
      '    END,'
      '    USR_COMPONENT_RESTRICTIONS.COMPONENT')
    TableName = 'USR_COMPONENT_RESTRICTIONS'
    UseSqlLocate = False
    Left = 72
    Top = 168
    ParamData = <
      item
        Name = 'APP'
        ParamType = ptInput
      end
      item
        Name = 'FORM'
        ParamType = ptInput
      end
      item
        Name = 'COMPONENT'
        ParamType = ptInput
      end>
  end
end
