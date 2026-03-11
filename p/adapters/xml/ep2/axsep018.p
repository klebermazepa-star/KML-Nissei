/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i AXSEP018 2.00.00.005 } /*** 010005 ***/
    
      

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i axsep018 MAX}
&ENDIF

&GLOBAL-DEFINE XmlApp            EP2
&GLOBAL-DEFINE XmlMod            MFT
&GLOBAL-DEFINE XmlProdName       EMS2
&GLOBAL-DEFINE XmlProdVersion    204
&GLOBAL-DEFINE XmlTranName       CartaCorrecaoEletronicaEnv
&GLOBAL-DEFINE XmlTranVersion    204.000

{adapters/xml/ep2/axsep018ExtraDeclarations.i}
                                           
{xmlinc/xmlloadmessagehandler.i &MessageHandler="hMessageHandler" &MHReturnValue="cReturnValue"}

IF  cReturnValue <> "OK" THEN DO:
    CREATE TT_LOG_ERRO.
    ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO = 0.
    /* Inicio -- Projeto Internacional */
    {utp/ut-liter.i "Erro_ao_executar_MessageHandle" *}
    ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO = RETURN-VALUE + ": "+ cReturnValue.
    RETURN cReturnValue.
END.
    
CREATE X-DOCUMENT hBusinessContent.

{xmlinc/xmlloadgenxml.i &GenXml="hGenXml" &GXReturnValue="cReturnValue"}

IF  cReturnValue <> "OK" THEN DO:
    CREATE TT_LOG_ERRO.
    ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO = 0.
    /* Inicio -- Projeto Internacional */
    {utp/ut-liter.i "Erro_ao_carregar_a_API_XML" *}
    ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO = RETURN-VALUE + ": "+ cReturnValue.
    RETURN cReturnValue.
END.

/* TOTVS COLAB 2.0 */
DEFINE VARIABLE cTpTrans AS CHARACTER NO-UNDO.
{cdp/cd0666.i}

PROCEDURE PIUpsert:

    DEFINE INPUT  PARAM cTranAction AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE INPUT  PARAM cEvent      AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE INPUT  PARAM TABLE FOR ttEvento.
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.

    DEF BUFFER bfcarta-correc-eletro FOR carta-correc-eletro.
    
    {xmlinc/xmlloadmessagehandler.i &MessageHandler="hMessageHandler" &MHReturnValue="cReturnValue"}

    IF cReturnValue <> "OK" THEN DO:
         CREATE TT_LOG_ERRO.
              ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
              /* Inicio -- Projeto Internacional */
              {utp/ut-liter.i "Erro_ao_executar_MessageHandle" *}
              ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = RETURN-VALUE + ": "+ cReturnValue
                     tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
         RETURN cReturnValue.
    END.

    RUN isSubscribed IN hMessageHandler ("{&XmlProdName}", "{&XmlApp}", "{&XmlTranName}", "{&XmlTranVersion}", cEvent, cTranAction, OUTPUT lCreateMsg).

    IF RETURN-VALUE <> "OK" THEN DO:
         CREATE TT_LOG_ERRO.
              ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
              /* Inicio -- Projeto Internacional */
              DEFINE VARIABLE c-lbl-liter AS CHARACTER NO-UNDO.
              ASSIGN c-lbl-liter = TRIM(RETURN-VALUE).
              DEFINE VARIABLE c-lbl-liter-erro-ao-executar-issubscribed AS CHARACTER NO-UNDO.
              {utp/ut-liter.i "Erro_ao_executar_isSubscribed_no_MessageHandle" *}
              ASSIGN c-lbl-liter-erro-ao-executar-issubscribed = TRIM(RETURN-VALUE).
              ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = c-lbl-liter-erro-ao-executar-issubscribed + ": "+ c-lbl-liter
                     tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
         RETURN RETURN-VALUE.
    END.

    /*IF NOT lCreateMsg THEN DO:
         CREATE TT_LOG_ERRO.
              ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
              /* Inicio -- Projeto Internacional */
              {utp/ut-liter.i "A_transa‡Æo_'{&XmlTranName}'_nÆo_‚_assinada" *}
              ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = RETURN-VALUE + '.'
                     tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
         RETURN "OK".
    END.*/


    FIND FIRST ttEvento.
    
    RUN setTransInfoComment IN hMessageHandler ("Comment").
    RUN setSystemId         IN hMessageHandler ("{&XmlMod}",  "{&XmlProdVersion}").
    RUN setKeyFields        IN hMessageHandler ("nota-fiscal.cod-chave-aces-nf-eletro", ttEvento.chNFe).

    RUN cdp/cd0360b.p (INPUT nota-fiscal.cod-estabel,
                       INPUT "NF-e":U,
                       OUTPUT cTpTrans).

    /*------------------------- INTEGRA€ÇO TSS [TOTVS] -------------------------*/
    IF  LOOKUP(cTpTrans, "TSS,TC":U) > 0 THEN DO:
    
        FOR FIRST param-nf-estab NO-LOCK WHERE 
                  param-nf-estab.cod-estabel = ttEvento.codEstab AND 
                 (param-nf-estab.ind-empresa <> ""               AND  
                  param-nf-estab.ind-empresa <> ?):
    
            RUN setKeyFields IN hMessageHandler ("ID_ENT", param-nf-estab.ind-empresa).
        END.
    END.
    
    /*--------------------------------------------------------------------------*/
    
    RUN setCompanyId        IN hMessageHandler (STRING(v_cdn_empres_usuar), "").

    RUN reset       IN hGenXml.
    RUN setEncoding IN hGenXml ("UTF-8").
    RUN addNode     IN hGenXml (getStack(), "Upsert", "", OUTPUT iId).

    addStack(iId).
    
       FOR FIRST ttEvento: END.

            RUN addNode      IN hGenXml (getStack(), "Evento",    "", OUTPUT iId).
            RUN setAttribute IN hGenXml (INPUT iId,  "versao",    "1.00").
            RUN setAttribute IN hGenXml (INPUT iId,  "xmlns",     "http://www.portalfiscal.inf.br/nfe").
            addStack(iId).
    
                RUN addNode      IN hGenXml (getStack(), "infEvento", "", OUTPUT iId).
                RUN setAttribute IN hGenXml (INPUT iId, "Id",     ("ID" + ttEvento.infEventoID)).
                addStack(iId).
            
                    RUN addNode      IN hGenXml (getStack(), "cOrgao",     ttEvento.cOrgao,     OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "tpAmb",      ttEvento.tpAmb,      OUTPUT iId).
                    
                    IF  ttEvento.cnpj <> "" THEN
                        RUN addNode  IN hGenXml (getStack(), "CNPJ",       ttEvento.cnpj,       OUTPUT iId).
                    ELSE                                               
                        RUN addNode  IN hGenXml (getStack(), "CPF",        ttEvento.cpf,        OUTPUT iId).

                    RUN addNode      IN hGenXml (getStack(), "chNFe",      ttEvento.chNFe,      OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "dhEvento",   ttEvento.dhEvento,   OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "tpEvento",   ttEvento.tpEvento,   OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "nSeqEvento", ttEvento.nSeqEvento, OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "verEvento",  ttEvento.verEvento,  OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "detEvento",  "",                  OUTPUT iId).
                    RUN setAttribute IN hGenXml (INPUT iId,  "versao",     "1.00").
                    addStack(iId).
                        
                        RUN addNode IN hGenXml (getStack(), "descEvento", ttEvento.descEvento, OUTPUT iId).
                        RUN addNode IN hGenXml (getStack(), "xCorrecao",  ttEvento.xCorrecao,  OUTPUT iId).
                        RUN addNode IN hGenXml (getStack(), "xCondUso",   ttEvento.xCondUso,   OUTPUT iId).
                    delStack().
    
                delStack().
    
            delStack().
         
    delStack().
    
    RUN generateXML         IN hGenXml (OUTPUT hBusinessContent).

    RUN generateXMLToMemptr IN hGenXml (OUTPUT inPtr) NO-ERROR.
    COPY-LOB inPtr TO lcConteudo.

    RUN pi-xml-cce-espec.

    IF RETURN-VALUE = "Leave" THEN RETURN "OK".

    RUN setBusinessContent IN hMessageHandler (INPUT  hBusinessContent).
    DELETE OBJECT hBusinessContent NO-ERROR.
    RUN sendMessage        IN hMessageHandler (INPUT "xmlschema/ep2/CartaCorrecaoEletronica_Env_204_000_v1.00.xsd"). 
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        CREATE TT_LOG_ERRO.
        ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO = 0.
        /* Inicio -- Projeto Internacional */
        DEFINE VARIABLE c-lbl-liter-2 AS CHARACTER NO-UNDO.
        ASSIGN c-lbl-liter-2 = TRIM(RETURN-VALUE).
        DEFINE VARIABLE c-lbl-liter-erro-no-envio-da-mensagem AS CHARACTER NO-UNDO.
        {utp/ut-liter.i "Erro_no_envio_da_Mensagem" *}
        ASSIGN c-lbl-liter-erro-no-envio-da-mensagem = TRIM(RETURN-VALUE).
        ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO = c-lbl-liter-erro-no-envio-da-mensagem + ": "+ c-lbl-liter-2.
        RETURN RETURN-VALUE.
    END.
        
    RUN getReturnStatus IN hMessageHandler (OUTPUT pSendSuccess, OUTPUT pTotalErrors).
        
    IF  NOT pSendSuccess THEN DO:
        REPEAT iCount = 1 TO pTotalErrors:
            CREATE TT_LOG_ERRO.
            RUN getError IN hMessageHandler (iCount, OUTPUT TT_LOG_ERRO.TTV_NUM_COD_ERRO, OUTPUT pErrorType, OUTPUT TT_LOG_ERRO.TTV_DES_MSG_ERRO).
        END.
        RETURN "NOK".
    END.
    ELSE DO: 

        FIND FIRST bfcarta-correc-eletro WHERE 
                   bfcarta-correc-eletro.cod-estab    = ttEvento.codEstab   AND
                   bfcarta-correc-eletro.cod-serie    = ttEvento.codSerie   AND
                   bfcarta-correc-eletro.cod-nota-fis = ttEvento.codNrNota  AND 
                   bfcarta-correc-eletro.num-seq      = INT(ttEvento.nSeqEvento) EXCLUSIVE-LOCK.
        IF  AVAIL bfcarta-correc-eletro THEN
            ASSIGN bfcarta-correc-eletro.dsl-xml-armaz = lcConteudo.
        
        RETURN "OK".

    END.

END PROCEDURE.

{adapters/xml/ep2/axsep018Upsert.i}
{adapters/xml/ep2/axsep018upc.i}
