unit zDocumentale.Providers;

// Unit aggregatrice dei provider documentali: esiste solo per collegare le
// initialization dei provider (auto-registrazione nelle factory). Inclusa
// nei .dpr di entrambe le applicazioni: aggiungere un fornitore = aggiungere
// una riga QUI, i .dpr non si toccano piu'.

interface

uses
  // provider inerti (ricaduta 'NESSUNO' delle factory)
  zDocumentale.Firma.Nessuno,
  zDocumentale.Protocollo.Nessuno,
  zDocumentale.Conservazione.Nessuno,
  zDocumentale.Messaggi.Nessuno,
  // provider reali gia' in libreria
  zDocumentale.Messaggi.Smtp;


// zDocumentale.Firma.SignHub,
// zDocumentale.Protocollo.Maggioli,
// zDocumentale.Firma.ESignAnyWhere

implementation

end.
