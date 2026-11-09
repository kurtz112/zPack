object FormOpzioniRegistrazione: TFormOpzioniRegistrazione
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Registrazione per l''assistenza'
  ClientHeight = 460
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object Wizard: TdxWizardControl
    Left = 0
    Top = 0
    Width = 640
    Height = 460
    Buttons.Back.Caption = '< &Indietro'
    Buttons.Cancel.Caption = 'Annulla'
    Buttons.CustomButtons.Buttons = <>
    Buttons.Finish.Caption = 'Avvia la registrazione'
    Buttons.Finish.Width = 150
    Buttons.Help.Visible = False
    Buttons.Next.Caption = '&Avanti >'
    OnButtonClick = WizardButtonClick
    OnPageChanged = WizardPageChanged
    OnPageChanging = WizardPageChanging
    object pageScopo: TdxWizardControlPage
      Header.Description = 'Registra le tue azioni per permettere all''assistenza di capire il problema.'
      Header.Title = 'Registrazione per l''assistenza'
      object lcScopo: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 618
        Height = 320
        Align = alClient
        ParentBackground = True
        TabOrder = 0
        Transparent = True
        object lblScopo: TcxLabel
          Left = 11
          Top = 11
          Caption = 'Questa procedura registra i passaggi che fai nel programma.'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblComeSiUsaTitolo: TcxLabel
          Left = 11
          Top = 36
          Caption = 'Come procedere:'
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -12
          Style.Font.Name = 'Segoe UI'
          Style.Font.Style = [fsBold]
          Style.HotTrack = False
          Style.TransparentBorder = False
          Style.IsFontAssigned = True
          Transparent = True
        end
        object lblComeSiUsa: TcxLabel
          Left = 11
          Top = 58
          Caption = 'Passi'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblAvviso: TcxLabel
          Left = 11
          Top = 116
          Caption = 'Avviso'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblNota: TcxLabel
          Left = 11
          Top = 150
          Caption = 'Racconta con parole tue cosa stai per fare e cosa non va (per esempio: "Apro l''elenco dei partecipanti del corso 123 e ci mette pi'#249' di un minuto"):'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object memoNota: TcxMemo
          Left = 11
          Top = 190
          Properties.ScrollBars = ssVertical
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 5
          Height = 110
          Width = 596
        end
        object cbInviaAllaFine: TcxCheckBox
          Left = 11
          Top = 290
          Caption = 'Invia la registrazione all''assistenza alla fine'
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 6
          Transparent = True
        end
        object lcScopoGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avTop
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object lcScopoItemScopo: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = lblScopo
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object lcScopoItemComeSiUsaTitolo: TdxLayoutItem
          Parent = lcScopoGroup_Root
          CaptionOptions.Visible = False
          Control = lblComeSiUsaTitolo
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object lcScopoItemComeSiUsa: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = lblComeSiUsa
          ControlOptions.OriginalHeight = 51
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object lcScopoItemAvviso: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = lblAvviso
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object lcScopoItemSpiegazioneNota: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = lblNota
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object lcScopoItemNota: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = memoNota
          ControlOptions.OriginalHeight = 110
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 5
        end
        object lcScopoItemInviaAllaFine: TdxLayoutItem
          Parent = lcScopoGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = cbInviaAllaFine
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 6
        end
      end
    end
    object pageMisure: TdxWizardControlPage
      Header.Description = 'Lascia le impostazioni predefinite, a meno che l''assistenza non ti indichi diversamente.'
      Header.Title = 'Cosa registrare'
      object lcMisure: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 618
        Height = 320
        Align = alClient
        ParentBackground = True
        TabOrder = 0
        Transparent = True
        object cbTempiFetch: TcxCheckBox
          Left = 11
          Top = 11
          Caption = 'Tempi di lettura dei dati'
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 0
          Transparent = True
        end
        object lblTempiFetch: TcxLabel
          Left = 33
          Top = 34
          Caption = 'Misura quanto tempo impiega il database a rispondere.'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 574
        end
        object cbTempiGriglia: TcxCheckBox
          Left = 11
          Top = 60
          Caption = 'Tempi delle griglie'
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 2
          Transparent = True
        end
        object lblTempiGriglia: TcxLabel
          Left = 33
          Top = 83
          Caption = 'Misura quanto tempo impiegano gli elenchi a riempirsi.'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 574
        end
        object cbMonitorFireDAC: TcxCheckBox
          Left = 11
          Top = 110
          Caption = 'Registro dettagliato del database'
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 4
          Transparent = True
        end
        object lblMonitorFireDAC: TcxLabel
          Left = 33
          Top = 133
          Caption = 'Da attivare solo su richiesta dell''assistenza.'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 574
        end
        object cbVideo: TcxCheckBox
          Left = 11
          Top = 165
          Caption = 'Filmato delle finestre del programma (le altre applicazioni restano oscurate)'
          Properties.OnChange = cbVideoPropertiesChange
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 6
          Transparent = True
        end
        object lblVideoNonDisponibile: TcxLabel
          Left = 33
          Top = 188
          Caption = 'Non disponibile'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 574
        end
        object edCodice: TcxTextEdit
          Left = 220
          Top = 213
          Properties.MaxLength = 12
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 8
          Width = 100
        end
        object lblStimaVideo: TcxLabel
          Left = 33
          Top = 242
          Caption = 'Stima'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 574
        end
        object lcMisureGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avTop
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object lcMisureItemTempiFetch: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = cbTempiFetch
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object lcMisureItemSpiegazioneFetch: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Left = 22
          Control = lblTempiFetch
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 574
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object lcMisureItemTempiGriglia: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = cbTempiGriglia
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object lcMisureItemSpiegazioneGriglia: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Left = 22
          Control = lblTempiGriglia
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 574
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object lcMisureItemMonitorFireDAC: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = cbMonitorFireDAC
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object lcMisureItemSpiegazioneMonitor: TdxLayoutItem
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Left = 22
          Control = lblMonitorFireDAC
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 574
          ControlOptions.ShowBorder = False
          Index = 5
        end
        object lcMisureGroupFilmato: TdxLayoutGroup
          Parent = lcMisureGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          ShowBorder = False
          Index = 6
        end
        object lcFilmatoItemVideo: TdxLayoutItem
          Parent = lcMisureGroupFilmato
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = cbVideo
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object lcFilmatoItemNonDisponibile: TdxLayoutItem
          Parent = lcMisureGroupFilmato
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Left = 22
          Control = lblVideoNonDisponibile
          ControlOptions.OriginalHeight = 19
          ControlOptions.OriginalWidth = 574
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object lcFilmatoItemCodice: TdxLayoutItem
          Parent = lcMisureGroupFilmato
          AlignHorz = ahLeft
          CaptionOptions.Text = 'Codice fornito dall''assistenza'
          Offsets.Left = 22
          Control = edCodice
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object lcFilmatoItemStimaVideo: TdxLayoutItem
          Parent = lcMisureGroupFilmato
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Left = 22
          Control = lblStimaVideo
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 574
          ControlOptions.ShowBorder = False
          Index = 3
        end
      end
    end
    object pageAvvio: TdxWizardControlPage
      Header.Description = 'Verifica le impostazioni scelte e avvia la registrazione.'
      Header.Title = 'Pronto per iniziare'
      object lcAvvio: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 618
        Height = 320
        Align = alClient
        ParentBackground = True
        TabOrder = 0
        Transparent = True
        object lblRiepilogo: TcxLabel
          Left = 11
          Top = 11
          Caption = 'Riepilogo'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblChiusura: TcxLabel
          Left = 11
          Top = 80
          Caption = 'Chiusura'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblLimite: TcxLabel
          Left = 11
          Top = 130
          Caption = 'Limite'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblAvvertenze: TcxLabel
          Left = 11
          Top = 180
          Caption = 'Da sapere: mentre registri il programma '#232' un po'' pi'#249' lento, ed '#232' normale. Nella registrazione finiscono anche i dati che scrivi nei filtri e nelle ricerche, che arrivano solo all''assistenza.'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object lblSegnalibro: TcxLabel
          Left = 11
          Top = 230
          Caption = 'Segnalibro'
          Properties.WordWrap = True
          Style.HotTrack = False
          Style.TransparentBorder = False
          Transparent = True
          Width = 596
        end
        object cbProssimoAvvio: TcxCheckBox
          Left = 11
          Top = 270
          Caption = 'Avvia la registrazione al prossimo avvio del programma (per i problemi che compaiono all'#39'apertura)'
          Properties.OnChange = cbProssimoAvvioPropertiesChange
          Style.HotTrack = False
          Style.TransparentBorder = False
          TabOrder = 5
          Transparent = True
        end
        object lcAvvioGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avTop
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object lcAvvioItemRiepilogo: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Control = lblRiepilogo
          ControlOptions.OriginalHeight = 51
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object lcAvvioItemChiusura: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 12
          Control = lblChiusura
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object lcAvvioItemLimite: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = lblLimite
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object lcAvvioItemAvvertenze: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = lblAvvertenze
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 4
        end
        object lcAvvioItemSegnalibro: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 8
          Control = lblSegnalibro
          ControlOptions.OriginalHeight = 34
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object lcAvvioItemProssimoAvvio: TdxLayoutItem
          Parent = lcAvvioGroup_Root
          AlignHorz = ahClient
          CaptionOptions.Visible = False
          Offsets.Top = 12
          Control = cbProssimoAvvio
          ControlOptions.OriginalHeight = 21
          ControlOptions.OriginalWidth = 596
          ControlOptions.ShowBorder = False
          Index = 5
        end
      end
    end
  end
end
