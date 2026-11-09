/* ============================================================================
   WinTarif 3 - Esportazione contabile multi-gestionale

   01 - DOMINI E TABELLE (nessuna procedura, nessun trigger, nessun indice)

   Riferimento: Analisi - 20260731 - Integrazione WT Con Gestionali Commerciali.md
   Database   : WT (Firebird)
   Data       : 31/07/2026

   Scopo: esportare da WinTarif prima nota (incassi, fatture emesse),
   anagrafiche e scadenzario verso il gestionale contabile usato dal cliente
   (Mexal, Ad Hoc, Gestionale 1, ...), producendo i file di importazione nel
   tracciato nativo di ciascun gestionale.

   PRINCIPIO GUIDA: il cliente puo' CAMBIARE gestionale nel tempo.
   - La configurazione per azienda indica solo il gestionale ATTIVO.
   - Parametri e corrispondenze sono chiavati per gestionale: al cambio non
     si perde nulla e un eventuale ritorno al vecchio gestionale ritrova
     tutte le sue tabelle di corrispondenza.
   - Ogni esportazione registra il gestionale con cui e' stata prodotta:
     lo storico resta leggibile anche dopo il cambio.
   - Aggiungere un gestionale nuovo NON richiede DDL: una riga nella tabella
     dei gestionali, piu' l'esportatore corrispondente nel codice.

   NOTE
   - I domini riusano quelli gia' presenti in WT (AUTO_INC, FOREIGN_KEY,
     USR_ID, DATA, DATA_ORA, TRUE_FALSE, INTERO, ANNO, MEMO, DESCRIZIONE,
     STR_20, STR_50, STR_100).
   - Stesso schema multi-fornitore gia' in uso per OBJ_FILES_PROTOCOLLO_*
     (gestionali = tabella di appoggio, parametri a chiave/valore,
     corrispondenze per tipo).
   - Le chiavi interne non ripetono il prefisso della tabella.
   ========================================================================= */


/* ============================================================================
   SEZIONE 1 - NUOVI DOMINI
   ========================================================================= */

/* Collegamento alla tabella di appoggio COGE_ESPORTAZIONI_GESTIONALI:
   niente COMMENT ON DOMAIN, la picklist nasce dalla tabella. */
CREATE DOMAIN COGE_ESPORTAZIONI_GESTIONALE AS VARCHAR(20);

CREATE DOMAIN COGE_ESPORTAZIONI_CONTENUTO AS VARCHAR(3)
    CHECK (VALUE IS NULL OR VALUE IN ('PRN', 'ANA', 'SCA'));

COMMENT ON DOMAIN COGE_ESPORTAZIONI_CONTENUTO IS
'Prima nota             = PRN
Anagrafiche clienti     = ANA
Scadenzario             = SCA';

/* Ciclo di vita di una esportazione: vedi matrice degli stati in analisi.
   La consegna e' un passaggio esplicito perche' il file generato resta in
   attesa finche' l''operatore non lo porta davvero nel gestionale. */
CREATE DOMAIN COGE_ESPORTAZIONI_STATO AS VARCHAR(1)
    CHECK (VALUE IS NULL OR VALUE IN ('G', 'C', 'A', 'E'));

COMMENT ON DOMAIN COGE_ESPORTAZIONI_STATO IS
'Generata   = G
Consegnata = C
Annullata  = A
Errore     = E';

CREATE DOMAIN COGE_ESPORTAZIONI_PARAMETRO_TIPO_CORRISPONDENZA AS VARCHAR(20)
    CHECK (VALUE IS NULL OR VALUE IN ('CONTO',
                                      'CAUSALE',
                                      'CODICE_IVA',
                                      'PAGAMENTO',
                                      'REGISTRO_IVA'));

COMMENT ON DOMAIN COGE_ESPORTAZIONI_PARAMETRO_TIPO_CORRISPONDENZA IS
'Conto contabile  = CONTO
Causale contabile = CAUSALE
Codice IVA        = CODICE_IVA
Codice pagamento  = PAGAMENTO
Registro IVA      = REGISTRO_IVA';

CREATE DOMAIN COGE_ESPORTAZIONI_PARAMETRO_CHIAVE AS VARCHAR(50);

CREATE DOMAIN COGE_ESPORTAZIONI_PARAMETRO_VALORE AS VARCHAR(200);


/* ============================================================================
   SEZIONE 2 - TABELLE
   ========================================================================= */

/* ---- Gestionali supportati ----------------------------------------------
   Tabella di appoggio: aggiungere un gestionale non richiede DDL.
   Il codice deve avere un esportatore registrato con lo stesso nome
   (vedi EsportazioneContabile.Registry). */

CREATE TABLE COGE_ESPORTAZIONI_GESTIONALI (
    GESTIONALE   COGE_ESPORTAZIONI_GESTIONALE NOT NULL,
    DESCRIZIONE  DESCRIZIONE,
    NOTE         MEMO,

    USR_USER_INS USR_ID,
    USR_DATA_INS DATA_ORA,
    USR_USER_MDF USR_ID,
    USR_DATA_MDF DATA_ORA,
    USR_DATA_DBA DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_GESTIONALI PRIMARY KEY (GESTIONALE)
);

/* Prima ondata: solo i gestionali con tracciato pubblico documentato.
   Gli altri (GESTIONALE2, TEAMSYSTEM, ONDA, ESOLVER) si aggiungono con un
   INSERT quando il tracciato arriva dal rivenditore del cliente. */
INSERT INTO COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE, DESCRIZIONE) VALUES ('MEXAL',       'Passepartout Mexal / Passcom');
INSERT INTO COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE, DESCRIZIONE) VALUES ('ADHOC',       'Zucchetti Ad Hoc Enterprise / Revolution');
INSERT INTO COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE, DESCRIZIONE) VALUES ('GESTIONALE1', 'Zucchetti Gestionale 1');


/* ---- Configurazione per azienda ------------------------------------------
   Indica il gestionale ATTIVO. Il cambio di gestionale e' un UPDATE di
   questa riga: parametri, corrispondenze e storico restano al loro posto. */

CREATE TABLE COGE_ESPORTAZIONI_CONFIGURAZIONE (
    ID_AZIENDA            FOREIGN_KEY                       NOT NULL,
    GESTIONALE            COGE_ESPORTAZIONI_GESTIONALE NOT NULL,
    ATTIVO                TRUE_FALSE DEFAULT FALSE,

    CARTELLA_DESTINAZIONE STR_100,

    NOTE                  MEMO,

    USR_USER_INS          USR_ID,
    USR_DATA_INS          DATA_ORA,
    USR_USER_MDF          USR_ID,
    USR_DATA_MDF          DATA_ORA,
    USR_DATA_DBA          DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_CONFIGURAZIONE PRIMARY KEY (ID_AZIENDA),
    CONSTRAINT FK_COGE_ESPORTAZIONI_CONFIG_GESTIONALE
        FOREIGN KEY (GESTIONALE) REFERENCES COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE)
);


/* ---- Parametri specifici del gestionale -----------------------------------
   Chiave/valore per azienda e gestionale: aggiungere un parametro non
   richiede DDL. Chiavi previste alla prima ondata:
   MEXAL : SEPARATORE (1 = punto e virgola, 2 = due punti, 3 = virgola),
           SIGLA_AZIENDA
   ADHOC : CODICE_ESERCIZIO, CODICE_UTENTE, VALUTA
   comuni: PREFISSO_NOME_FILE */

CREATE TABLE COGE_ESPORTAZIONI_CONFIG_PARAMETRI (
    ID_AZIENDA   FOREIGN_KEY                            NOT NULL,
    GESTIONALE   COGE_ESPORTAZIONI_GESTIONALE      NOT NULL,
    CHIAVE       COGE_ESPORTAZIONI_PARAMETRO_CHIAVE NOT NULL,
    VALORE       COGE_ESPORTAZIONI_PARAMETRO_VALORE,
    DESCRIZIONE  DESCRIZIONE,

    USR_USER_INS USR_ID,
    USR_DATA_INS DATA_ORA,
    USR_USER_MDF USR_ID,
    USR_DATA_MDF DATA_ORA,
    USR_DATA_DBA DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_CONFIG_PARAMETRI
        PRIMARY KEY (ID_AZIENDA, GESTIONALE, CHIAVE),
    CONSTRAINT FK_COGE_ESPORTAZIONI_CONFIG_PARAM_GEST
        FOREIGN KEY (GESTIONALE) REFERENCES COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE)
);


/* ---- Corrispondenze codici WinTarif -> codici del gestionale --------------
   Il cuore della portabilita': conti, causali, codici IVA e pagamenti di
   WinTarif tradotti nei codici del gestionale di destinazione. Chiavate per
   gestionale: il cambio di gestionale richiede solo di compilare le
   corrispondenze del nuovo, quelle del vecchio restano. */

CREATE TABLE COGE_ESPORTAZIONI_CORRISPONDENZE (
    ID_AZIENDA     FOREIGN_KEY                               NOT NULL,
    GESTIONALE     COGE_ESPORTAZIONI_GESTIONALE         NOT NULL,
    TIPO           COGE_ESPORTAZIONI_PARAMETRO_TIPO_CORRISPONDENZA NOT NULL,
    CODICE_INTERNO COGE_ESPORTAZIONI_PARAMETRO_CHIAVE   NOT NULL,
    CODICE_ESTERNO COGE_ESPORTAZIONI_PARAMETRO_VALORE,
    DESCRIZIONE    DESCRIZIONE,

    USR_USER_INS   USR_ID,
    USR_DATA_INS   DATA_ORA,
    USR_USER_MDF   USR_ID,
    USR_DATA_MDF   DATA_ORA,
    USR_DATA_DBA   DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_CORRISPONDENZE
        PRIMARY KEY (ID_AZIENDA, GESTIONALE, TIPO, CODICE_INTERNO),
    CONSTRAINT FK_COGE_ESPORTAZIONI_CORRISP_GESTIONALE
        FOREIGN KEY (GESTIONALE) REFERENCES COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE)
);


/* ---- Registro delle esportazioni ------------------------------------------
   Ogni lancio della procedura lascia una riga: cosa, per che periodo, con
   quale gestionale, con quale esito. E' la memoria che impedisce le doppie
   esportazioni e che sopravvive al cambio di gestionale. */

CREATE TABLE COGE_ESPORTAZIONI_REGISTRAZIONI (
    ID_ESPORTAZIONE  AUTO_INC                          NOT NULL,
    ID_AZIENDA       FOREIGN_KEY                       NOT NULL,
    GESTIONALE       COGE_ESPORTAZIONI_GESTIONALE NOT NULL,
    CONTENUTO        COGE_ESPORTAZIONI_CONTENUTO  NOT NULL,
    STATO            COGE_ESPORTAZIONI_STATO      NOT NULL,

    /* periodo esportato (solo per prima nota e scadenzario) */
    DATA_DAL         DATA,
    DATA_AL          DATA,

    NUMERO_MOVIMENTI INTERO DEFAULT 0,

    /* esito */
    MESSAGGIO        MEMO,

    USR_USER_INS     USR_ID,
    USR_DATA_INS     DATA_ORA,
    USR_USER_MDF     USR_ID,
    USR_DATA_MDF     DATA_ORA,
    USR_DATA_DBA     DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_REGISTRAZIONI PRIMARY KEY (ID_ESPORTAZIONE),
    CONSTRAINT FK_COGE_ESPORTAZIONI_REG_GESTIONALE
        FOREIGN KEY (GESTIONALE) REFERENCES COGE_ESPORTAZIONI_GESTIONALI (GESTIONALE)
);


/* ---- File prodotti da ogni esportazione -----------------------------------
   Un gestionale puo' volere piu' file per lo stesso contenuto: Mexal ne
   chiede fino a quattro per la sola prima nota (testate, testate Intra,
   righe, righe di contabilita' analitica). */

CREATE TABLE COGE_ESPORTAZIONI_REGISTRAZIONI_FILES (
    ID_ESPORTAZIONE FOREIGN_KEY NOT NULL,
    NOME_FILE       STR_100     NOT NULL,
    RUOLO           STR_20,

    USR_USER_INS    USR_ID,
    USR_DATA_INS    DATA_ORA,
    USR_USER_MDF    USR_ID,
    USR_DATA_MDF    DATA_ORA,
    USR_DATA_DBA    DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_REGISTRAZIONI_FILES
        PRIMARY KEY (ID_ESPORTAZIONE, NOME_FILE),
    CONSTRAINT FK_COGE_ESPORTAZIONI_REG_FILES_ESP
        FOREIGN KEY (ID_ESPORTAZIONE) REFERENCES COGE_ESPORTAZIONI_REGISTRAZIONI (ID_ESPORTAZIONE)
);


/* ---- Documenti WinTarif inclusi in ogni esportazione ----------------------
   Traccia riga per riga quali documenti (fatture, incassi) sono entrati nel
   file: serve al controllo delle doppie esportazioni e alla riesportazione
   selettiva. L'aggancio all'entita' WinTarif segue lo schema di
   OBJ_FILES_PROTOCOLLO_REGISTRAZIONI (OID generico + chiave specifica). */

CREATE TABLE COGE_ESPORTAZIONI_REGISTRAZIONI_DOCUMENTI (
    ID_ESPORTAZIONE FOREIGN_KEY NOT NULL,
    PROGRESSIVO     INTERO      NOT NULL,

    OID             OID,
    ID_DOCUMENTO    FOREIGN_KEY,
    DESCRIZIONE     DESCRIZIONE,

    USR_USER_INS    USR_ID,
    USR_DATA_INS    DATA_ORA,
    USR_USER_MDF    USR_ID,
    USR_DATA_MDF    DATA_ORA,
    USR_DATA_DBA    DATA_ORA,

    CONSTRAINT PK_COGE_ESPORTAZIONI_REGISTRAZIONI_DOC
        PRIMARY KEY (ID_ESPORTAZIONE, PROGRESSIVO),
    CONSTRAINT FK_COGE_ESPORTAZIONI_REG_DOC_ESP
        FOREIGN KEY (ID_ESPORTAZIONE) REFERENCES COGE_ESPORTAZIONI_REGISTRAZIONI (ID_ESPORTAZIONE)
);
