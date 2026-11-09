// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------
unit zOffice.Grafici;

// Registro dei grafici disponibili per le stampe. Word, FastReport ed Excel
// chiedono l'immagine di un grafico per nome e la ricevono in memoria, senza
// file temporanei. Chi disegna i grafici (TzDbChart) si registra quando e'
// pronto e si toglie quando viene distrutto: zOffice non conosce il componente.
//
// Riferimento a un grafico nei modelli:
//   chart://Nome                  immagine PNG della misura predefinita
//   chart://Nome?svg              formato: png, svg, emf, jpg
//   chart://Nome?png&1600x900     misura dell'immagine in pixel
// Nome e' il nome di stampa del grafico (ReportName delle sue proprieta')
// oppure il suo identificativo Modulo.DataSet; basta anche il solo nome del
// dataset, e vince il grafico aperto per ultimo.
// L'eventuale suffisso " @L:A" dei modelli (centimetri) si ignora qui: lo
// gestisce chi impagina l'immagine (zOffice.Word.Utils, zOffice.Grafici.Excel).
//
// Il registro va usato dal thread principale; una richiesta che arriva da un
// altro thread viene eseguita nel principale, perche' il disegno passa dalla VCL.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TzFormatoGrafico = (fgPng, fgSvg, fgEmf, fgJpeg);

  // Disegna il grafico in un flusso nuovo, che il chiamante libera; nil se il
  // grafico non ha niente da mostrare
  TzSorgenteGrafico = reference to function(Formato: TzFormatoGrafico; Larghezza, Altezza: Integer): TStream;

  TzRiferimentoGrafico = record
    Nome: string;
    Formato: TzFormatoGrafico;
    // pixel; 0 = misura predefinita
    Larghezza: Integer;
    Altezza: Integer;
    // True se Testo e' un riferimento chart://; accetta virgolette ai lati e
    // il suffisso " @L:A" dei modelli, che non entra nel riferimento
    class function Prova(const Testo: string; out Riferimento: TzRiferimentoGrafico): Boolean; static;
  end;

  TzRegistroGrafici = class
  public const
    Schema = 'chart://';
    // 20 x 12,5 cm a 300 punti per pollice
    LarghezzaPredefinita = 2400;
    AltezzaPredefinita = 1500;
  private type
    TVoce = record
      Nome: string;
      Proprietario: TObject;
      Sorgente: TzSorgenteGrafico;
    end;
  private
    class var FVoci: TList<TVoce>;
    class function Trova(const Nome: string; out Voce: TVoce): Boolean; static;
  public
    class constructor Create;
    class destructor Destroy;

    // Lo stesso proprietario puo' registrarsi sotto piu' nomi (nome di stampa e
    // identificativo); un nome gia' suo viene sostituito
    class procedure Registra(const Nome: string; Proprietario: TObject; Sorgente: TzSorgenteGrafico); static;
    class procedure Togli(Proprietario: TObject); static;

    class function Esiste(const Nome: string): Boolean; static;
    class function Nomi: TArray<string>; static;

    // nil se nessun grafico risponde al nome
    class function Immagine(const Nome: string; Formato: TzFormatoGrafico; Larghezza, Altezza: Integer): TStream; static;
    class function ImmagineDaRiferimento(const Testo: string): TStream; static;

    class function PixelDaCentimetri(const Centimetri: Single; const PuntiPerPollice: Integer = 300): Integer; static;
  end;

implementation

{ TzRiferimentoGrafico }

class function TzRiferimentoGrafico.Prova(const Testo: string; out Riferimento: TzRiferimentoGrafico): Boolean;
var
  Corpo: string;
  Opzioni: TArray<string>;
  Opzione: string;
  Posizione: Integer;
  Larghezza, Altezza: Integer;
begin
  Result := False;
  Riferimento.Nome := '';
  Riferimento.Formato := fgPng;
  Riferimento.Larghezza := 0;
  Riferimento.Altezza := 0;

  Corpo := Testo.Trim;

  // suffisso della misura dei modelli: resta a chi impagina
  Posizione := Corpo.IndexOf('@');
  if Posizione >= 0 then
    Corpo := Corpo.Substring(0, Posizione).Trim;

  Corpo := Corpo.Replace('"', '').Trim;

  if not Corpo.StartsWith(TzRegistroGrafici.Schema, True) then
    Exit;

  Corpo := Corpo.Substring(Length(TzRegistroGrafici.Schema));

  Posizione := Corpo.IndexOf('?');
  if Posizione >= 0 then
  begin
    Opzioni := Corpo.Substring(Posizione + 1).Split(['&', ';']);
    Corpo := Corpo.Substring(0, Posizione);

    for Opzione in Opzioni do
    begin
      if SameText(Opzione.Trim, 'png') then
        Riferimento.Formato := fgPng
      else
        if SameText(Opzione.Trim, 'svg') then
          Riferimento.Formato := fgSvg
        else
          if SameText(Opzione.Trim, 'emf') then
            Riferimento.Formato := fgEmf
          else
            if SameText(Opzione.Trim, 'jpg') or SameText(Opzione.Trim, 'jpeg') then
              Riferimento.Formato := fgJpeg
            else
            begin
              // misura in pixel: LxA
              Posizione := Opzione.ToLower.IndexOf('x');
              if Posizione > 0 then
                if TryStrToInt(Opzione.Substring(0, Posizione).Trim, Larghezza) and TryStrToInt(Opzione.Substring(Posizione + 1).Trim, Altezza) then
                  if (Larghezza > 0) and (Altezza > 0) then
                  begin
                    Riferimento.Larghezza := Larghezza;
                    Riferimento.Altezza := Altezza;
                  end;
            end;
    end;
  end;

  // la barra finale di un indirizzo scritto a mano non fa parte del nome
  Riferimento.Nome := Corpo.Trim.TrimRight(['/']);
  Result := Riferimento.Nome <> '';
end;

{ TzRegistroGrafici }

class constructor TzRegistroGrafici.Create;
begin
  FVoci := TList<TVoce>.Create;
end;

class destructor TzRegistroGrafici.Destroy;
begin
  FreeAndNil(FVoci);
end;

class procedure TzRegistroGrafici.Registra(const Nome: string; Proprietario: TObject; Sorgente: TzSorgenteGrafico);
var
  Voce: TVoce;
  Indice: Integer;
begin
  if (Nome.Trim = '') or not Assigned(Sorgente) then
    Exit;

  for Indice := FVoci.Count - 1 downto 0 do
    if (FVoci[Indice].Proprietario = Proprietario) and SameText(FVoci[Indice].Nome, Nome.Trim) then
      FVoci.Delete(Indice);

  Voce.Nome := Nome.Trim;
  Voce.Proprietario := Proprietario;
  Voce.Sorgente := Sorgente;
  FVoci.Add(Voce);
end;

class procedure TzRegistroGrafici.Togli(Proprietario: TObject);
var
  Indice: Integer;
begin
  if not Assigned(FVoci) then
    Exit;

  for Indice := FVoci.Count - 1 downto 0 do
    if FVoci[Indice].Proprietario = Proprietario then
      FVoci.Delete(Indice);
end;

class function TzRegistroGrafici.Trova(const Nome: string; out Voce: TVoce): Boolean;
var
  Indice: Integer;
  Cercato: string;
  Registrato: string;
begin
  Result := False;
  Cercato := Nome.Trim;

  if Cercato = '' then
    Exit;

  // dall'ultimo registrato: con la stessa form aperta due volte vince la piu' recente
  for Indice := FVoci.Count - 1 downto 0 do
    if SameText(FVoci[Indice].Nome, Cercato) then
    begin
      Voce := FVoci[Indice];
      Exit(True);
    end;

  // solo il nome del dataset: si confronta con la parte dopo l'ultimo punto
  // dell'identificativo Modulo.DataSet
  if Cercato.Contains('.') then
    Exit;

  for Indice := FVoci.Count - 1 downto 0 do
  begin
    Registrato := FVoci[Indice].Nome;

    if Registrato.Contains('.') then
      Registrato := Registrato.Substring(Registrato.LastIndexOf('.') + 1);

    if SameText(Registrato, Cercato) then
    begin
      Voce := FVoci[Indice];
      Exit(True);
    end;
  end;
end;

class function TzRegistroGrafici.Esiste(const Nome: string): Boolean;
var
  Voce: TVoce;
begin
  Result := Trova(Nome, Voce);
end;

class function TzRegistroGrafici.Nomi: TArray<string>;
var
  Voce: TVoce;
begin
  Result := nil;

  for Voce in FVoci do
    Result := Result + [Voce.Nome];
end;

class function TzRegistroGrafici.Immagine(const Nome: string; Formato: TzFormatoGrafico; Larghezza, Altezza: Integer): TStream;
var
  Voce: TVoce;
  Flusso: TStream;
begin
  Result := nil;

  if not Trova(Nome, Voce) then
    Exit;

  if Larghezza <= 0 then
    Larghezza := LarghezzaPredefinita;

  if Altezza <= 0 then
    Altezza := AltezzaPredefinita;

  if TThread.CurrentThread.ThreadID = MainThreadID then
    Flusso := Voce.Sorgente(Formato, Larghezza, Altezza)
  else
  begin
    Flusso := nil;
    TThread.Synchronize(nil,
      procedure
      begin
        Flusso := Voce.Sorgente(Formato, Larghezza, Altezza);
      end);
  end;

  if Assigned(Flusso) then
    Flusso.Position := 0;

  Result := Flusso;
end;

class function TzRegistroGrafici.ImmagineDaRiferimento(const Testo: string): TStream;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Result := nil;

  if TzRiferimentoGrafico.Prova(Testo, Riferimento) then
    Result := Immagine(Riferimento.Nome, Riferimento.Formato, Riferimento.Larghezza, Riferimento.Altezza);
end;

class function TzRegistroGrafici.PixelDaCentimetri(const Centimetri: Single; const PuntiPerPollice: Integer): Integer;
begin
  Result := Round(Centimetri / 2.54 * PuntiPerPollice);

  if Result < 1 then
    Result := 1;
end;

end.
