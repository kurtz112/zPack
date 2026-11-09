// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zMsg;

// Test DUnitX per zBase\zMsg.pas (specifica ZBASE-MSG, "Finestre di dialogo.md").
// BOZZA scritta senza poterla compilare ne' eseguire.
//
// Si provano solo le parti che non mostrano nessuna finestra:
// - AltezzaCarattere e AssegnaCarattere, su una TForm creata con CreateNew e mai
//   mostrata (ZBASE-MSG-011);
// - i valori iniziali di TInputDialog dopo CreateNew, senza ShowModal
//   (ZBASE-MSG-004).
//
// Restano senza prova, perche' aprono una finestra modale o toccano gli appunti:
// Confirm e i suoi involucri, Input* ed Edit, la formattazione delle voci della
// combo (CreateCombo e' privato), la validazione delle date
// (cxDateEditPropertiesValidate e' privato) e TcxSpinEdit.PasteFromClipboard.
// Le finestre non si possono sostituire con un gestore: Confirm chiama
// dxCreateMessageDialog e Execute chiama ShowModal senza punti di aggancio. Per
// provarle servirebbe una variabile di aggancio come OnStartWait di zBaseLib
// (dichiarata, non implementata qui).

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  dxDPIAwareUtils,
  DUnitX.TestFramework,
  zMsg;

type
  [TestFixture]
  TTestzMsgCarattere = class
  public
    // ZBASE-MSG-011
    [Test]
    procedure AltezzaCarattere_ZeroPuntiInPiu_UgualeAlCarattereDellaFinestra;
    // ZBASE-MSG-011
    [Test]
    procedure AltezzaCarattere_PuntiInPiu_AltezzaPiuNegativa;
    // ZBASE-MSG-011
    [Test]
    procedure AltezzaCarattere_PuntiInMeno_AltezzaMenoNegativa;
    // ZBASE-MSG-011
    [Test]
    procedure AltezzaCarattere_Formula_AltezzaMenoPuntiPerDpiSuSettantadue;
    // ZBASE-MSG-011
    [Test]
    procedure AssegnaCarattere_SenzaFinestreAperte_NovePunti;
  end;

  [TestFixture]
  TTestzMsgDialogoDiInput = class
  public
    // ZBASE-MSG-004
    [Test]
    procedure CreateNew_ValoriIniziali_ElencoMappatoEDigitabile;
    // ZBASE-MSG-004
    [Test]
    procedure CreateNew_Pulsanti_OkEAnnulla;
    // ZBASE-MSG-004
    [Test]
    procedure CreateNew_Aspetto_BordoRidimensionabileCentratoSuProprietario;
  end;

implementation

{ TTestzMsgCarattere }

procedure TTestzMsgCarattere.AltezzaCarattere_ZeroPuntiInPiu_UgualeAlCarattereDellaFinestra;
var
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Assert.AreEqual(Finestra.Font.Height, AltezzaCarattere(Finestra, 0));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzMsgCarattere.AltezzaCarattere_PuntiInPiu_AltezzaPiuNegativa;
var
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    // l'altezza del carattere e' negativa: piu' punti, numero piu' piccolo
    Assert.IsTrue(AltezzaCarattere(Finestra, 2) < AltezzaCarattere(Finestra, 0));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzMsgCarattere.AltezzaCarattere_PuntiInMeno_AltezzaMenoNegativa;
var
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Assert.IsTrue(AltezzaCarattere(Finestra, -1) > AltezzaCarattere(Finestra, 0));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzMsgCarattere.AltezzaCarattere_Formula_AltezzaMenoPuntiPerDpiSuSettantadue;
var
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Assert.AreEqual(Finestra.Font.Height - MulDiv(4, dxGetFormDPI(Finestra), 72), AltezzaCarattere(Finestra, 4));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzMsgCarattere.AssegnaCarattere_SenzaFinestreAperte_NovePunti;
var
  Finestra: TForm;
begin
  // la regola dei nove punti vale solo senza finestra attiva e senza finestra
  // principale: se il programma di prova ne ha una, la prova non si applica
  if (Screen.ActiveCustomForm <> nil) or (Application.MainForm <> nil) then
  begin
    Assert.Pass('esiste una finestra attiva o principale, prova non applicabile');
    Exit;
  end;

  Finestra := TForm.CreateNew(nil);
  try
    AssegnaCarattere(Finestra);

    Assert.AreEqual(-MulDiv(9, dxGetFormDPI(Finestra), 72), Finestra.Font.Height);
  finally
    Finestra.Free;
  end;
end;

{ TTestzMsgDialogoDiInput }

procedure TTestzMsgDialogoDiInput.CreateNew_ValoriIniziali_ElencoMappatoEDigitabile;
var
  Dialogo: TInputDialog;
begin
  Dialogo := TInputDialog.CreateNew(nil);
  try
    Assert.IsTrue(Dialogo.MapList, 'MapList');
    Assert.IsTrue(Dialogo.EditList, 'EditList');
    Assert.IsFalse(Assigned(Dialogo.proc), 'nessuna richiamata');
    Assert.IsTrue(Dialogo.cxCustomEdit = nil, 'nessun editor prima di Edit');
    Assert.AreEqual('', Dialogo.Caption);
  finally
    Dialogo.Free;
  end;
end;

procedure TTestzMsgDialogoDiInput.CreateNew_Pulsanti_OkEAnnulla;
var
  Dialogo: TInputDialog;
begin
  Dialogo := TInputDialog.CreateNew(nil);
  try
    Assert.AreEqual('Ok', Dialogo.btnOk.Caption, 'testo di Ok');
    Assert.AreEqual(Integer(mrOk), Integer(Dialogo.btnOk.ModalResult), 'risultato di Ok');
    Assert.IsTrue(Dialogo.btnOk.Default, 'Ok e'' il pulsante predefinito');

    Assert.AreEqual('Annulla', Dialogo.btnCancel.Caption, 'testo di Annulla');
    Assert.AreEqual(Integer(mrCancel), Integer(Dialogo.btnCancel.ModalResult), 'risultato di Annulla');
    Assert.IsTrue(Dialogo.btnCancel.Cancel, 'Annulla risponde a Esc');
  finally
    Dialogo.Free;
  end;
end;

procedure TTestzMsgDialogoDiInput.CreateNew_Aspetto_BordoRidimensionabileCentratoSuProprietario;
var
  Dialogo: TInputDialog;
begin
  Dialogo := TInputDialog.CreateNew(nil);
  try
    Assert.AreEqual(Ord(bsSizeToolWin), Ord(Dialogo.BorderStyle), 'bordo');
    Assert.AreEqual(Ord(poOwnerFormCenter), Ord(Dialogo.Position), 'posizione');
    Assert.IsTrue(Dialogo.DoubleBuffered, 'doppio buffer');
  finally
    Dialogo.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzMsgCarattere);
  TDUnitX.RegisterTestFixture(TTestzMsgDialogoDiInput);

end.
