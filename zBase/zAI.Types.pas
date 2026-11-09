unit zAI.Types;

{
  Vocabolari condivisi del sottosistema AI — unit FOGLIA, senza dipendenze.

  Esiste per spezzare un potenziale ciclo di uses: TzDomain (in zSystem) deve
  esporre una sensibilita' di tipo TAISensitivity, mentre zAI.Context usa
  zSystem (per TzComponentType). Tenere gli enum-vocabolario qui — dipendenti
  solo dalla RTL — permette sia a zSystem sia a zAI.Context di usarli senza
  riferimenti circolari.

  Qui vanno SOLO tipi-vocabolario stabili e privi di logica/dipendenze. Record,
  policy, builder restano nelle rispettive unit (zAI.Context, ecc.).
}

interface

type
  // Grado di sensibilita' di un campo ai fini GDPR. Scala per GRADO DI
  // OCCULTAMENTO (cosa fare in mascheramento), non per categoria semantica.
  // Enum ORDINATO: slNone < slMasked < slRedacted < slSpecial, cosi' la
  // combinazione fra strati di classificazione e' un semplice massimo (Ord).
  TAISensitivity = (
    slNone,      // non sensibile: passa in chiaro (salvo policy ddNone)
    slMasked,    // sensibile, mascherabile parzialmente (es. R*** / ***1234)
    slRedacted,  // sensibile, da omettere del tutto: valore -> [omesso]
    slSpecial    // categoria speciale (art. 9 GDPR): rimosso SEMPRE, ignora la
                 // policy; anche il NOME del campo va nascosto, perche' la sola
                 // presenza del campo e' essa stessa informazione
  );

  // Livello di esposizione dati concesso dalla policy attiva. Tre livelli, non
  // un bool: calcolato a monte combinando provider AI + livello utente con la
  // regola "il piu' restrittivo vince". Ordine di permissivita' DECRESCENTE:
  // ddFull < ddMasked < ddNone (Ord piu' alto = piu' restrittivo).
  TAIDataDisclosure = (
    ddFull,      // accesso pieno al vedibile (categorie speciali escluse sempre)
    ddMasked,    // dati sensibili mascherati secondo il loro TAISensitivity
    ddNone       // nessun dato di record: ogni valore -> [omesso] (restano i
                 // soli metadati strutturali: nomi campo, conteggi, ecc.)
  );

implementation

end.
