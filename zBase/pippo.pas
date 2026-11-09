
-----------------------------------------------------------

function Path: string;
begin
  result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;


-----------------------------------------------------------
   zFrmParams,

   Params: TParams;


  Params := TParams.Create(nil);
  try
    Params.CreateParam(ftString, 'Metodo_Spedizione', ptInputOutput);
    Params.ParamByName('Metodo_Spedizione').Clear;

    Params.CreateParam(ftDateTime, 'Data_Invio', ptInputOutput);
    Params.ParamByName('Data_Invio').Value := Date;

    Params.CreateParam(ftDateTime, 'Data_Protocollo', ptInputOutput);
    Params.ParamByName('Data_Protocollo').Value := Date;

    Params.CreateParam(ftInteger, 'IdAttoInvio', ptInputOutput);
    Params.ParamByName('IdAttoInvio').Value := IdAttoInvio;

    lkMetodiSpedizione.RevertSQL(true);
    try
      if not ShowParams('RC_Ingiunzioni_NuovoInvioAtto', Params, 'Nuovo Invio Atto',
        procedure(zParamDialog: TzParamDialog)
        var
          edLookup: TcxExtLookupComboBox;
        begin
          zParamDialog.zDialog.Width := 300;
          zParamDialog.zDialog.Height := 200;

          //
          edLookup := zParamDialog.zDialog.zFormBuilder.ChangeControlType(ctLookupExt, 'Metodo_Spedizione', 'Metodo Spedizione', null) as TcxExtLookupComboBox;
          dx.InitLookup('RC_Ingiunzioni_NuovoInvioAtto_MetodoSpedizione', edLookup, lkMetodiSpedizione, lkMetodiSpedizioneSrc, 'METODO_SPEDIZIONE', 'METODO_SPEDIZIONE;DESC_METODO_SPEDIZIONE');
          //
          edLookup := zParamDialog.zDialog.zFormBuilder.ChangeControlType(ctLookupExt, 'IdAttoInvio', 'Invio Corrente', null) as TcxExtLookupComboBox;
          dx.InitLookup('RC_Ingiunzioni_NuovoInvioAtto_IdInvio', edLookup, IngAttiInvii, IngAttiInviiSrc, 'ID_ATTO_INGIUNZIONE_INVIO', 'ID_ATTO_INGIUNZIONE_INVIO');
          edLookup.EditValue := IdAttoInvio;
        end) then
        Exit;

      MetodoSpedizione := Params.ParamByName('Metodo_Spedizione').asString;
      Data_Invio := Params.ParamByName('Data_Invio').AsDateTime;
      Data_Protocollo := Params.ParamByName('Data_Protocollo').AsDateTime;
      IdAttoInvio := Params.ParamByName('IdAttoInvio').asInteger;
    finally
      lkMetodiSpedizione.Active := false;
    end;
  finally
    FreeAndNil(Params);
  end;