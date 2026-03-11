PROCEDURE PITransUpsert:    
    DEFINE INPUT  PARAM cTranAction AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE INPUT  PARAM cEvent      AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE INPUT  PARAM pTpEvento   AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE INPUT  PARAM TABLE FOR tt-dados-evento.
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
        
    DEF VAR l-funcao-tss   AS LOG         NO-UNDO.
    DEF VAR c-dia          AS CHAR        NO-UNDO.
    DEF VAR c-mes          AS CHAR        NO-UNDO.
    DEF VAR c-ano          AS CHAR        NO-UNDO.
    DEF VAR c-hora         AS CHAR        NO-UNDO FORMAT "x(15)".
    DEF VAR da-tz          AS DATETIME-TZ NO-UNDO.
    DEF VAR p-dh-formatada AS CHAR        NO-UNDO.

    FIND FIRST tt-dados-evento NO-LOCK NO-ERROR.
    
    FIND FIRST nota-fiscal WHERE 
               nota-fiscal.cod-estabel = tt-dados-evento.cod-estab    AND
               nota-fiscal.serie       = tt-dados-evento.cod-serie    AND
               nota-fiscal.nr-nota-fis = tt-dados-evento.cod-nota-fis NO-LOCK NO-ERROR.

    IF  AVAIL nota-fiscal THEN DO:

        RUN cdp/cd0360b.p (INPUT  nota-fiscal.cod-estabel,
                           INPUT  "NF-e":U,
                           OUTPUT cTpTrans).
        
        ASSIGN l-funcao-tss =  lookup(cTpTrans,"TSS,TC":U) > 0. 
        
        FOR FIRST param-nf-estab NO-LOCK WHERE 
                  param-nf-estab.cod-estabel = nota-fiscal.cod-estabel: END.
    
        FOR FIRST estabelec NO-LOCK WHERE 
                  estabelec.cod-estabel = nota-fiscal.cod-estabel: END.
                                            
        FOR FIRST unid-feder NO-LOCK WHERE 
                  unid-feder.pais   = estabelec.pais AND
                  unid-feder.estado = estabelec.estado : END.
    
        CREATE ttEvento.

        ASSIGN ttEvento.codEstab     = tt-dados-evento.cod-estab   
               ttEvento.codSerie     = tt-dados-evento.cod-serie   
               ttEvento.codNrNota    = tt-dados-evento.cod-nota-fis
               ttEvento.descEvento   = tt-dados-evento.desc-evento 
               ttEvento.nSeqEvento   = STRING(tt-dados-evento.num-seq)
               ttEvento.tpEvento     = pTpEvento       
               ttEvento.verEvento    = STRING(tt-dados-evento.cod-versao)
               ttEvento.cnpj         = estabelec.cgc
               ttEvento.cpf          = (IF ttEvento.cpf <> ? THEN ttEvento.cpf ELSE "").
        IF  ttEvento.tpEvento = "110110" THEN DO:
            ASSIGN ttEvento.xCondUso     = "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para regularizacao de erro ocorrido na emissao de documento fiscal, desde que o erro nao esteja relacionado com: I - as variaveis que determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao; II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida."
                   ttEvento.xCorrecao    = fn-free-accent(tt-dados-evento.dsl-evento)
                   ttEvento.xCorrecao    = REPLACE(ttEvento.xCorrecao, CHR(10), " ")
                   ttEvento.xCorrecao    = REPLACE(ttEvento.xCorrecao, CHR(13), " ")
                   ttEvento.xCorrecao    = REPLACE(ttEvento.xCorrecao, CHR(9), " ")
                   ttEvento.xCorrecao    = fn-ajusta-espacos-branco(ttEvento.xCorrecao).
        END.
        ELSE
            ASSIGN ttEvento.nProt = &if "{&bf_dis_versao_ems}" >= "2.07" &then nota-fiscal.cod-protoc &else SUBSTR(nota-fiscal.char-1,97,15) &ENDIF 
                   ttEvento.xJust = fn-free-accent(tt-dados-evento.dsl-evento)
                   ttEvento.xJust = REPLACE(ttEvento.xJust, CHR(10), " ")
                   ttEvento.xJust = REPLACE(ttEvento.xJust, CHR(13), " ")
                   ttEvento.xJust = REPLACE(ttEvento.xJust, CHR(9), " ")
                   ttEvento.xJust = fn-ajusta-espacos-branco(ttEvento.xJust).
                   
        
        ASSIGN ttEvento.cOrgao       = STRING(IF  estabelec.pais = "Brasil":U THEN 
                                           (&IF '{&bf_dis_versao_ems}' >= '2.07':U &THEN 
                                               IF  AVAIL unid-feder THEN 
                                                   INT(unid-feder.cod-uf-ibge)
                                               ELSE 0
                                           &ELSE 
                                               IF  AVAIL unid-feder THEN 
                                                   INT(SUBSTRING(unid-feder.char-1,1,2)) 
                                               ELSE 0 &endif)
                                       ELSE 99).
    
        IF  l-funcao-tss THEN DO:
            ASSIGN ttEvento.tpAmb   = IF  AVAIL param-nf-estab THEN 
                                          &IF "{&BF_DIS_VERSAO_EMS}" >= "2.08" &THEN
                                          STRING(param-nf-estab.idi-tip-emis-amb-sefaz)
                                          &ELSE
                                          STRING(param-nf-estab.num-livre-1)
                                          &ENDIF
                                      ELSE 
                                          (IF &IF "{&BF_DIS_VERSAO_EMS}" >= "2.07" &THEN
                                          estabelec.idi-tip-emis-nf-eletro    = 3
                                          &ELSE
                                          INT(SUBSTR(estabelec.char-1,168,1)) = 3  /* Processo EmissÆo NF-e - CD0403 */
                                          &ENDIF
                                      THEN "1"  /* Produ‡Æo    */
                                      ELSE "2") /* Homologa‡Æo */. 
        END.
        ELSE DO:
            ASSIGN ttEvento.tpAmb   = (IF &IF "{&BF_DIS_VERSAO_EMS}" >= "2.07" &THEN
                                          estabelec.idi-tip-emis-nf-eletro    = 3
                                      &ELSE
                                          INT(SUBSTR(estabelec.char-1,168,1)) = 3  /* Processo EmissÆo NF-e - CD0403 */
                                      &ENDIF
                                      THEN "1"  /* Produ‡Æo    */
                                      ELSE "2") /* Homologa‡Æo */.
        END.

        ASSIGN ttEvento.chNFe        = TRIM(&IF  '{&bf_dis_versao_ems}' >= '2.07':U &THEN 
                                            nota-fiscal.cod-chave-aces-nf-eletro 
                                       &ELSE 
                                            SUBSTRING(nota-fiscal.char-2,3,60) 
                                       &ENDIF).
    
        ASSIGN c-dia  = SUBSTRING(tt-dados-evento.des-dat-hora-event,1,2)
               c-mes  = SUBSTRING(tt-dados-evento.des-dat-hora-event,4,2)
               c-ano  = SUBSTRING(tt-dados-evento.des-dat-hora-event,7,4).

        RUN cdp/cd0591.p (INPUT tt-dados-evento.cod-estab,
                          INPUT DATE(c-dia + "/" + c-mes + "/" + c-ano),
                          INPUT SUBSTRING(tt-dados-evento.des-dat-hora-event,12,8),
                          INPUT NO, /* formatar hora sem aplicar o fuso */
                          OUTPUT p-dh-formatada).

        ASSIGN ttEvento.dhEvento     = p-dh-formatada
               ttEvento.infEventoID  = pTpEvento + ttEvento.chNFe + STRING(tt-dados-evento.num-seq,"99"). 
        
        IF  LOOKUP(cTpTrans, "TSS,TC,TC2":U) > 0 THEN
            RUN pi-integra-XML.
        ELSE
            RUN PIUpsert (INPUT cTranAction, INPUT cEvent, INPUT TABLE ttEvento, OUTPUT TABLE tt_log_erro).
                        
    END.
    
    RUN pi-executa-upc.

END PROCEDURE.


PROCEDURE pi-integra-XML:

    &IF INTEGER(ENTRY(1,PROVERSION,".")) >= 10 &THEN
    
        DEFINE VARIABLE h-TSSAPI             AS HANDLE      NO-UNDO.
        DEFINE VARIABLE hXMLEvento           AS HANDLE      NO-UNDO.
        DEFINE VARIABLE lEnvioEventoTSSOK    AS LOGICAL     NO-UNDO.
        DEFINE VARIABLE cReturnValue         AS CHARACTER   NO-UNDO.
        
        ASSIGN lcXMLEvento = "".

        RUN reset       IN hGenXml.
        RUN setEncoding IN hGenXml ("UTF-8").
       
        addStack(iId).

           FOR FIRST ttEvento: END.
                IF  NOT cTpTrans = "TC2":U THEN DO:
                    RUN addNode      IN hGenXml (getStack(), "envEvento",    "", OUTPUT iId).
                    addStack(iId).
                    RUN addNode      IN hGenXml (getStack(), "versao",    "1.00", OUTPUT iId).
                    RUN addNode      IN hGenXml (getStack(), "idLote",       "1", OUTPUT iId).
                END.
                    RUN addNode      IN hGenXml (getStack(), "evento",        "", OUTPUT iId).
                    IF  cTpTrans = "TC2":U THEN DO:
                        RUN setAttribute IN hGenXml (INPUT iId,  "versao",    "1.00").
                        RUN setAttribute IN hGenXml (INPUT iId,  "xmlns",   "http://www.portalfiscal.inf.br/nfe").
                    END.    
                    addStack(iId).

                        IF  NOT cTpTrans = "TC2":U THEN
                            RUN addNode      IN hGenXml (getStack(), "versao",    "1.00", OUTPUT iId).
                        RUN addNode      IN hGenXml (getStack(), "infEvento",     "", OUTPUT iId).
                        IF  cTpTrans = "TC2":U THEN
                            RUN setAttribute IN hGenXml (INPUT iId, "Id",     ("ID" + ttEvento.infEventoID)).
                        addStack(iId).
                            
                            IF  NOT cTpTrans = "TC2":U THEN
                                RUN addNode      IN hGenXml (getStack(), "Id",        ("ID" + ttEvento.infEventoID), OUTPUT iId).
                            RUN addNode      IN hGenXml (getStack(), "cOrgao",     ttEvento.cOrgao,              OUTPUT iId).
                            RUN addNode      IN hGenXml (getStack(), "tpAmb",      ttEvento.tpAmb,               OUTPUT iId).
    
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
                            IF  cTpTrans = "TC2":U THEN
                                RUN setAttribute IN hGenXml (INPUT iId,  "versao",     "1.00").
                            addStack(iId).
                                IF  NOT cTpTrans = "TC2":U THEN
                                    RUN addNode IN hGenXml (getStack(), "versao",                  "1.00", OUTPUT iId).
                                RUN addNode IN hGenXml (getStack(), "descEvento", ttEvento.descEvento, OUTPUT iId).
                                IF  tpEvento = "110110" THEN DO:
                                    RUN addNode IN hGenXml (getStack(), "xCorrecao",  ttEvento.xCorrecao,  OUTPUT iId).
                                    RUN addNode IN hGenXml (getStack(), "xCondUso",   ttEvento.xCondUso,   OUTPUT iId).
                                END.
                                ELSE DO:
                                    RUN addNode IN hGenXml (getStack(), "nProt",  ttEvento.nProt,  OUTPUT iId).
                                    RUN addNode IN hGenXml (getStack(), "xJust",   ttEvento.xJust,   OUTPUT iId).
                                END.
                            delStack().
    
                        delStack().

                    delStack().

                delStack().

        delStack().

        RUN generateXML IN hGenXml (OUTPUT hXMLEvento).

        hXMLEvento:SAVE("LONGCHAR",lcXMLEvento).
        
        IF  NOT cTpTrans = "TC2":U THEN
            ASSIGN lcXMLEvento = SUBSTR(lcXMLEvento, INDEX(lcXMLEvento, "<EnvEvento")).

        IF  cTpTrans = "TC2":U THEN DO:
            EMPTY TEMP-TABLE tt-erro.

            /*hXMLEvento:SAVE('FILE', "C:\temp\XML\teste.xml").*/
            RUN cdp/cdapi590.p (INPUT IF  tpEvento = "110110" THEN 301 ELSE 171, /*Codigo Neogrid CC-e Evento*/
                                INPUT hXMLEvento,
                                INPUT ttEvento.chNFe,
                                OUTPUT TABLE tt-erro).
            FOR EACH tt-erro:
                CREATE TT_LOG_ERRO.
                ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = tt-erro.cd-erro
                       TT_LOG_ERRO.TTV_DES_MSG_ERRO  = tt-erro.mensagem
                       TT_LOG_ERRO.TTV_DES_MSG_AJUDA = tt-erro.mensagem.
            END.
        END.

        IF  NOT cTpTrans = "TC2":U THEN DO:
                 
            IF  NOT AVAIL param-nf-estab THEN
                FOR FIRST param-nf-estab NO-LOCK
                    WHERE param-nf-estab.cod-estabel = ttEvento.codEstab: END.
    
            IF  NOT AVAIL param-nf-estab THEN
                RETURN "NOK".
    
            IF  NOT VALID-HANDLE(h-TSSAPI) THEN
                RUN ftp/ftapi511.p PERSISTENT SET h-TSSAPI. 
            
            RUN setTSSURL IN h-TSSAPI (&if "{&bf_dis_versao_ems}" >= "2.08" &then
                                         TRIM(param-nf-estab.cod-url-ws-tss)
                                       &else
                                         TRIM(SUBSTR(param-nf-estab.cod-livre-1,1,100))
                                       &endif).
    
            EMPTY TEMP-TABLE TT_LOG_ERRO.
    
            RUN NFESBRA_NFEREMESSAEVENTO IN h-TSSAPI (INPUT  param-nf-estab.ind-empresa, 
                                                      INPUT  lcXMLEvento,
                                                      OUTPUT cReturnValue). 
    
            /*FIND FIRST tt-carta-correc-eletro WHERE 
                       tt-carta-correc-eletro.cod-estab    = ttEvento.codEstab   AND
                       tt-carta-correc-eletro.cod-serie    = ttEvento.codSerie   AND
                       tt-carta-correc-eletro.cod-nota-fis = ttEvento.codNrNota  AND 
                       tt-carta-correc-eletro.num-seq      = INT(ttEvento.nSeqEvento) EXCLUSIVE-LOCK NO-ERROR.
            IF  AVAIL tt-carta-correc-eletro THEN
                ASSIGN tt-carta-correc-eletro.dsl-xml-armaz = lcXMLEvento.*/
            RUN disconnectTss IN h-TSSAPI ("NFESBRA").
      
            IF  VALID-HANDLE(h-TSSAPI) THEN DO:
                DELETE PROCEDURE h-TSSAPI.
                ASSIGN h-TSSAPI = ?.
            END.

        END.
        
    &ENDIF
    
    RETURN "OK":U.

END PROCEDURE.

