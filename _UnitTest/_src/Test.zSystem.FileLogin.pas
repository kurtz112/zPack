// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-26
// ---------------------------------------------------------------------------
unit Test.zSystem.FileLogin;

// Test DUnitX del file .login accanto all'eseguibile (zSystem.pas): ricorda
// per ogni computer l'ultimo utente, la connessione e lo skin. E' un file di
// comodita': se non e' scrivibile (cartella di rete, file non in linea,
// sola lettura) si perde il ricordo, ma l'accesso non deve fallire.
//
// Il file sotto prova e' zPackTests.login accanto all'eseguibile dei test:
// Setup ne salva contenuto e attributi, TearDown li ripristina.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.IniFiles,
  Vcl.Forms,
  DUnitX.TestFramework,
  zSystem;

type
  [TestFixture]
  TTestFileLogin = class
  private
    FNomeFile: string;
    FEsisteva: Boolean;
    FContenuto: TBytes;
    FAttributi: Integer;
    procedure SolaLettura(const Attiva: Boolean);
    function Leggi(const Chiave: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Mantis #286 - 2026-10-26: file .login in sola lettura, la scrittura non solleva
    [Test]
    procedure ScriviFileLogin_SolaLettura_FalseSenzaEccezione;
    // Mantis #286 - 2026-10-26: l'accesso riuscito non deve fallire per il .login
    [Test]
    procedure SaveLastUserAndConnection_SolaLettura_NessunaEccezione;
    // Mantis #286 - 2026-10-26: con il file scrivibile i valori si salvano
    [Test]
    procedure SaveLastUserAndConnection_Scrivibile_SalvaUtenteEConnessione;
  end;

implementation

type
  // SaveLastUserAndConnection e' protected
  TzSecurityAccesso = class(TzSecurity);

{ TTestFileLogin }

procedure TTestFileLogin.Setup;
begin
  FNomeFile := ChangeFileExt(Application.ExeName, '.login');
  FEsisteva := TFile.Exists(FNomeFile);
  if FEsisteva then
  begin
    FAttributi := FileGetAttr(FNomeFile);
    FileSetAttr(FNomeFile, FAttributi and not faReadOnly);
    FContenuto := TFile.ReadAllBytes(FNomeFile);
  end;
  // si parte sempre da un file vuoto e scrivibile
  TFile.WriteAllText(FNomeFile, '');
end;

procedure TTestFileLogin.TearDown;
begin
  SolaLettura(False);
  if FEsisteva then
  begin
    TFile.WriteAllBytes(FNomeFile, FContenuto);
    FileSetAttr(FNomeFile, FAttributi);
  end
  else
    TFile.Delete(FNomeFile);
end;

procedure TTestFileLogin.SolaLettura(const Attiva: Boolean);
var
  Attributi: Integer;
begin
  Attributi := FileGetAttr(FNomeFile);
  if Attiva then
    FileSetAttr(FNomeFile, Attributi or faReadOnly)
  else
    FileSetAttr(FNomeFile, Attributi and not faReadOnly);
end;

function TTestFileLogin.Leggi(const Chiave: string): string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FNomeFile);
  try
    result := Ini.ReadString(ComputerName, Chiave, '');
  finally
    Ini.Free;
  end;
end;

procedure TTestFileLogin.ScriviFileLogin_SolaLettura_FalseSenzaEccezione;
var
  Esito: Boolean;
begin
  SolaLettura(True);
  Esito := True;

  Assert.WillNotRaise(
    procedure
    begin
      Esito := TzSecurity.ScriviFileLogin('Skin', 'PROVA');
    end);

  Assert.IsFalse(Esito);
  Assert.AreEqual('', Leggi('Skin'));
end;

procedure TTestFileLogin.SaveLastUserAndConnection_SolaLettura_NessunaEccezione;
var
  Sicurezza: TzSecurityAccesso;
begin
  SolaLettura(True);

  Sicurezza := TzSecurityAccesso.Create(nil);
  try
    // prima della correzione sollevava EIniFileException "Impossibile scrivere"
    Assert.WillNotRaise(
      procedure
      begin
        Sicurezza.SaveLastUserAndConnection('PROVA', 'Codebri');
      end);
  finally
    Sicurezza.Free;
  end;
end;

procedure TTestFileLogin.SaveLastUserAndConnection_Scrivibile_SalvaUtenteEConnessione;
var
  Sicurezza: TzSecurityAccesso;
begin
  Sicurezza := TzSecurityAccesso.Create(nil);
  try
    Sicurezza.SaveLastUserAndConnection('PROVA', 'Codebri');
  finally
    Sicurezza.Free;
  end;

  Assert.AreEqual('PROVA', Leggi('UserName'));
  Assert.AreEqual('Codebri', Leggi('Connection'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFileLogin);

end.
