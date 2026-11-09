// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit EsportazioneContabile.Registry;

// Registro degli esportatori disponibili. Ogni unit di gestionale si
// registra nella propria sezione initialization con il codice della tabella
// ESPORTAZIONI_CONTABILI_GESTIONALI: il ponte applicativo crea l'esportatore
// dal codice letto in ESPORTAZIONI_CONTABILI_CONFIGURAZIONE, senza conoscere
// le classi concrete. Il cambio di gestionale del cliente e' cosi' solo un
// dato di configurazione.

interface

uses
  System.SysUtils, System.Generics.Collections,
  EsportazioneContabile.Types, EsportazioneContabile.Base;

type
  TzEsportatoriContabili = class
  private
    class var FClassi: TDictionary<string, TzEsportatoreContabileClasse>;
    class function Classi: TDictionary<string, TzEsportatoreContabileClasse>;
  public
    class destructor Destroy;

    class procedure Registra(const Gestionale: string;
      Classe: TzEsportatoreContabileClasse);

    // Solleva EzEsportazioneContabile se il gestionale non ha un esportatore:
    // succede quando in tabella e' stato inserito un gestionale (es. ONDA)
    // per cui il tracciato non e' ancora stato implementato.
    class function Crea(const Gestionale: string;
      Corrispondenze: IzCorrispondenzeContabili): IzEsportatoreContabile;

    class function GestionaliDisponibili: TArray<string>;
  end;

implementation

class function TzEsportatoriContabili.Classi: TDictionary<string, TzEsportatoreContabileClasse>;
begin
  if FClassi = nil then
    FClassi := TDictionary<string, TzEsportatoreContabileClasse>.Create;
  Result := FClassi;
end;

class destructor TzEsportatoriContabili.Destroy;
begin
  FClassi.Free;
end;

class procedure TzEsportatoriContabili.Registra(const Gestionale: string;
  Classe: TzEsportatoreContabileClasse);
begin
  Classi.AddOrSetValue(UpperCase(Gestionale), Classe);
end;

class function TzEsportatoriContabili.Crea(const Gestionale: string;
  Corrispondenze: IzCorrispondenzeContabili): IzEsportatoreContabile;
var
  Classe: TzEsportatoreContabileClasse;
begin
  if not Classi.TryGetValue(UpperCase(Gestionale), Classe) then
    raise EzEsportazioneContabile.CreateFmt(
      'Nessun esportatore registrato per il gestionale "%s": ' +
      'il tracciato non e'' ancora supportato', [Gestionale]);
  Result := Classe.Create(Corrispondenze);
end;

class function TzEsportatoriContabili.GestionaliDisponibili: TArray<string>;
begin
  Result := Classi.Keys.ToArray;
end;

end.
