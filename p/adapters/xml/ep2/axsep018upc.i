
/*-------------------------------------------------
               AXSEP018UPC.i
-------------------------------------------------*/


PROCEDURE pi-executa-upc:
      
    IF  c-nom-prog-dpc-mg97  <> "" 
    OR  c-nom-prog-appc-mg97 <> "" 
    OR  c-nom-prog-upc-mg97  <> "" THEN DO:
    
        FOR EACH tt-epc 
            WHERE tt-epc.cod-event = "AtualizaDadosCCe":U :
            DELETE tt-epc.
        END.
    
        CREATE tt-epc.
        ASSIGN tt-epc.cod-event     = "AtualizaDadosCCe":U
               tt-epc.cod-parameter = "ttEvento":U
               tt-epc.val-parameter = STRING(TEMP-TABLE ttEvento:HANDLE).
        
        {include/i-epc201.i "AtualizaDadosCCe"}
    END.

END PROCEDURE.

PROCEDURE pi-xml-cce-espec:

    DEF BUFFER bfcarta-correc-eletro2 FOR carta-correc-eletro.

    IF  c-nom-prog-dpc-mg97  <> "" 
    OR  c-nom-prog-appc-mg97 <> "" 
    OR  c-nom-prog-upc-mg97  <> "" THEN DO:
        
        FIND FIRST bfcarta-correc-eletro2 
             WHERE bfcarta-correc-eletro2.cod-estab    = ttEvento.codEstab   AND
                   bfcarta-correc-eletro2.cod-serie    = ttEvento.codSerie   AND
                   bfcarta-correc-eletro2.cod-nota-fis = ttEvento.codNrNota  AND 
                   bfcarta-correc-eletro2.num-seq      = INT(ttEvento.nSeqEvento) NO-LOCK.
        
        FOR EACH tt-epc 
           WHERE tt-epc.cod-event = "TrataCCeEspec":U:
            DELETE tt-epc.
        END.
    
        CREATE tt-epc.
        ASSIGN tt-epc.cod-event     = "TrataCCeEspec":U
               tt-epc.cod-parameter = "ConteudoCCe"
               tt-epc.val-parameter = STRING(lcConteudo).
    
        CREATE tt-epc.
        ASSIGN tt-epc.cod-event     = "TrataCCeEspec":U
               tt-epc.cod-parameter = "RowidCCe":U
               tt-epc.val-parameter = STRING(ROWID(bfcarta-correc-eletro2)) WHEN AVAIL bfcarta-correc-eletro2.
    
        {include/i-epc201.i "TrataCCeEspec"}
    
        FOR FIRST tt-epc NO-LOCK
            WHERE tt-epc.cod-event     = "TrataCCeEspec":U
              AND tt-epc.cod-parameter = "GeraTT_LOG_ERRO":U :
    
            CREATE TT_LOG_ERRO.
            ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 15825.
            ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = tt-epc.val-parameter
                   TT_LOG_ERRO.TTV_DES_MSG_AJUDA = TT_LOG_ERRO.TTV_DES_MSG_ERRO.
        END.
    
        IF  CAN-FIND (FIRST tt-epc
                      WHERE tt-epc.cod-event     = "TrataCCeEspec":U
                        AND tt-epc.cod-parameter = "XMLEspec":U) THEN DO:
    
            RETURN "Leave":U.
        END.
    END.

END.
