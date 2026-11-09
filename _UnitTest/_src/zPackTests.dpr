// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program zPackTests;

// Runner console DUnitX dei test di zPack. Le unit sotto test sono quelle di
// zPack (zBase, zOffice, zCommon, zFIB) raggiunte dal library path, insieme a
// DevExpress e X:\Druido\LIB\: il refactoring di testabilita' e' gia' entrato
// in zPack, quindi questa cartella contiene solo le unit di test.
//
// Opzioni utili da riga di comando (DUnitX):
//   --exit:Continue           nessuna pausa a fine esecuzione (catena di zBuilder)
//   --xmlfile:<file>          esito in formato NUnit (relativo alla cartella corrente)

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  Test.zDbCard.Layout in 'Test.zDbCard.Layout.pas',
  Test.zCodiceFiscale in 'Test.zCodiceFiscale.pas',
  Test.zDbView.Sort in 'Test.zDbView.Sort.pas',
  Test.zDbView.Filter in 'Test.zDbView.Filter.pas',
  Test.zDbView.Storage in 'Test.zDbView.Storage.pas',
  Test.zDbCard.Estrazioni in 'Test.zDbCard.Estrazioni.pas',
  Test.zDbCard.Comandi in 'Test.zDbCard.Comandi.pas',
  Test.zDbCard.Lookup.Corrispondenza in 'Test.zDbCard.Lookup.Corrispondenza.pas',
  // componenti nuovi (grafico, calendario, vista record) e stampe dei grafici
  Test.zDbChart.Types in 'Test.zDbChart.Types.pas',
  Test.zOffice.Grafici in 'Test.zOffice.Grafici.pas',
  Test.zDbScheduler.Types in 'Test.zDbScheduler.Types.pas',
  Test.zDbRecordView.Storage in 'Test.zDbRecordView.Storage.pas',
  Test.zSystem.Componenti in 'Test.zSystem.Componenti.pas',
  // cache dei documenti del controller delle azioni documentali (Mantis #210)
  Test.zOffice.Reports.Controller in 'Test.zOffice.Reports.Controller.pas',
  // dataset: valori predefiniti su SQLite in memoria, senza Firebird
  Test.zFbDataSet.Predefiniti in 'Test.zFbDataSet.Predefiniti.pas',
  // campi binari (dominio UUID) mostrati in esadecimale (Mantis #274)
  Test.zFbDataSet.CampiBinari in 'Test.zFbDataSet.CampiBinari.pas',
  // UPDATE con le sole colonne cambiate (Mantis #257)
  Test.zFbDataSet.UpdateParziale in 'Test.zFbDataSet.UpdateParziale.pas',
  // finestra di attesa DevExpress persa (Mantis #238): crea finestre vere
  Test.zz.SplashWait in 'Test.zz.SplashWait.pas',
  // ordinamento del databinding dei modelli Excel letto anche per nome (Mantis #280)
  Test.zOffice.Excel.Binding in 'Test.zOffice.Excel.Binding.pas',
  // catena "At procedure" dei messaggi di Firebird (Mantis #259, voce R-136)
  Test.zExceptions.Fib in 'Test.zExceptions.Fib.pas',
  // memoria dell'esito con scadenza di FirmaElettronicaAmmessa (Mantis #254, voce R-132)
  Test.zMemoriaConScadenza in 'Test.zMemoriaConScadenza.pas',
  // file .login non scrivibile: l'accesso non deve fallire (Mantis #286)
  Test.zSystem.FileLogin in 'Test.zSystem.FileLogin.pas',
  // controlli sulla definizione dei lookup di TzSystemVerifier (Mantis #320)
  Test.zSystemVerifier.Lookup in 'Test.zSystemVerifier.Lookup.pas',
  // analisi del testo SQL di zFIB: requisiti ZFIB-SQL e prove delle divergenze (voce R-197)
  Test.zSql.TestoSql in 'Test.zSql.TestoSql.pas',
  // spezzatura e transazioni di TzFbScriptRunner: requisiti ZFIB-SCR e divergenze (voce R-197)
  Test.zFbScriptRunner in 'Test.zFbScriptRunner.pas',
  // divergenze di TzFbDataSet dedotte nella specifica (voce R-196): ricerca, chiavi, controlli
  Test.zFbDataSet.Divergenze in 'Test.zFbDataSet.Divergenze.pas',
  // contesto degli errori di FireDAC: requisiti ZFIB-ERR e DIV-ERR-4 (voce R-197)
  Test.zExceptions.Firedac in 'Test.zExceptions.Firedac.pas',
  // totali di piede e casi limite di ordinamento, layout e filtro di zDbView: requisiti ZDBVIEW e divergenze (voce R-210)
  Test.zDbView.Footer in 'Test.zDbView.Footer.pas',
  Test.zDbView.Divergenze in 'Test.zDbView.Divergenze.pas',
  // utilita' e visualizzatori di zPack: specifiche ZBASE-SPR, STO, FVW, MDG, PVT, TLA, NVB, FRB, PGC, LOG, ZLIBS-NUL, GCO, FIL, JSN, ZOFF-OFF (voce R-213)
  Test.zStoredProc in 'Test.zStoredProc.pas',
  Test.zStorage in 'Test.zStorage.pas',
  Test.zz.Nullable in 'Test.zz.Nullable.pas',
  Test.zz.GenericCollection in 'Test.zz.GenericCollection.pas',
  Test.zz.files in 'Test.zz.files.pas',
  // albero dei report: cartelle di archivio escluse e omonimi (Mantis #6949)
  Test.zFileSystem in 'Test.zFileSystem.pas',
  Test.zz.JSON in 'Test.zz.JSON.pas',
  Test.zFileViewer in 'Test.zFileViewer.pas',
  Test.zMemoDialog in 'Test.zMemoDialog.pas',
  Test.zDbPivot in 'Test.zDbPivot.pas',
  Test.zToolActions in 'Test.zToolActions.pas',
  Test.zNavBarTools in 'Test.zNavBarTools.pas',
  Test.zFormBuilder in 'Test.zFormBuilder.pas',
  Test.PageControlController in 'Test.PageControlController.pas',
  Test.zOffice in 'Test.zOffice.pas',
  // pulsanti Ok e Annulla e barra di avanzamento di zCommon (rilascio 021)
  Test.OkCancel in 'Test.OkCancel.pas',
  Test.zProgressBox in 'Test.zProgressBox.pas',
  Test.zDiagnostica.Log in 'Test.zDiagnostica.Log.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.FailsOnNoAsserts := True;

    Runner.AddLogger(TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet));
    // Percorso reso assoluto: con un nome senza cartella (--xmlfile:esito.xml)
    // TDUnitXXMLNUnitFileLogger chiama ForceDirectories('') e solleva
    // EInOutError "Unable to create directory" prima di eseguire i test
    if TDUnitX.Options.XMLOutputFile <> '' then
      Runner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(ExpandFileName(TDUnitX.Options.XMLOutputFile)));

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Premere INVIO per uscire.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
