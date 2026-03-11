//****************************************************************************************************
// vers∆o = 31
//****************************************************************************************************

{utp/ut-glob.i}

// definiá∆o tt-dados-nota, tt-ordens e tt-erros
{esp\roboteasy\apiCriarNotaEntrada.i}

DEF TEMP-TABLE tt-row-errors NO-UNDO
    FIELD ErrorSequence    AS INTEGER
    FIELD ErrorNumber      AS INTEGER
    FIELD ErrorDescription AS CHARACTER
    FIELD ErrorParameters  AS CHARACTER
    FIELD ErrorType        AS CHARACTER
    FIELD ErrorHelp        AS CHARACTER
    FIELD ErrorSubType     AS CHARACTER.

DEF TEMP-TABLE tt-relat NO-UNDO
    FIELD linha AS CHAR.

{inbo/boin090.i tt-docum-est}    
{inbo/boin176.i tt-item-doc-est} 
{inbo/boin092.i tt-dupli-apagar}
{inbo/boin366.i tt-rat-docum}
{inbo/boin567.i tt-dupli-imp}

//****************************************************************************************************

DEF INPUT  PARAM TABLE FOR tt-dados-nota.
DEF INPUT  PARAM TABLE FOR tt-ordens.
DEF OUTPUT PARAM TABLE FOR tt-erros.

DEF VAR h-boin090 AS HANDLE NO-UNDO.   
DEF VAR h-boin176 AS HANDLE NO-UNDO.  
DEF VAR h-boin092 AS HANDLE NO-UNDO.   
DEF VAR i-seq AS INTE NO-UNDO.

//****************************************************************************************************

FOR FIRST tt-dados-nota:
END.

RUN pi-validar-parametros.

IF  RETURN-VALUE <> "NOK" THEN DO:

    RUN pi-cria-tt-docum-est.

    FOR FIRST tt-erros:
        RUN pi-formatar-tt-erros.
        RETURN.
    END.

    FOR FIRST tt-docum-est:
    END.

    /***
    FOR FIRST docum-est NO-LOCK
        WHERE docum-est.cod-emitente = tt-docum-est.cod-emitente  
        AND   docum-est.serie-docto  = tt-docum-est.serie-docto  
        AND   docum-est.nro-docto    = tt-docum-est.nro-docto    
        AND   docum-est.nat-operacao = tt-docum-est.nat-operacao:
    END.

    IF  AVAIL docum-est THEN
        MESSAGE "docum-est ok" SKIP
                "tt-docum-est.cod-emitente = |" tt-docum-est.cod-emitente "|" skip
                "tt-docum-est.serie-docto = |" tt-docum-est.serie-docto   "|" skip
                "tt-docum-est.nro-docto = |" tt-docum-est.nro-docto       "|" skip
                "tt-docum-est.nat-operacao = |" tt-docum-est.nat-operacao "|" skip
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    ELSE
        MESSAGE "docum-est Nok" SKIP
                "tt-docum-est.cod-emitente = |" tt-docum-est.cod-emitente "|" skip
                "tt-docum-est.serie-docto = |" tt-docum-est.serie-docto   "|" skip
                "tt-docum-est.nro-docto = |" tt-docum-est.nro-docto       "|" skip
                "tt-docum-est.nat-operacao = |" tt-docum-est.nat-operacao "|" skip
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    ***/

    RUN pi-cria-tt-item-doc-est.
    FOR FIRST tt-erros:
        RUN pi-formatar-tt-erros.
        RETURN.
    END.

    RUN pi-efetivar-docto.
    FOR FIRST tt-erros:
        RUN pi-formatar-tt-erros.
        RETURN.
    END.
        
END.

//****************************************************************************************************

PROCEDURE pi-formatar-tt-erros:
   
   ASSIGN i-seq = 0.
   FOR EACH tt-erros:
       ASSIGN i-seq = i-seq + 1.
       ASSIGN tt-erros.identif-segment = STRING(i-seq, "99").
   END.
   
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-validar-parametros:

    bloco-validar-param:
    DO ON ERROR UNDO, RETRY:
        
        IF  RETRY THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-validar-parametros".
            LEAVE bloco-validar-param.
        END.

        //****************************************************************************************************

        for first docum-est no-lock
            where docum-est.cod-chave-aces-nf-eletro = tt-dados-nota.chave-nfe:
        end.
        
        if  avail docum-est then do:
        
            create tt-erros.
            assign tt-erros.cd-erro = 0.
            
            if  docum-est.ce-atual then
                assign tt-erros.desc-erro = "Documento j† atualizado no Recebimento".
            else
                assign tt-erros.desc-erro = "Documento est† pendente no RE1001".
                
            RETURN "NOK".   
        end.
            
        //****************************************************************************************************

        FOR FIRST emitente NO-LOCK
            WHERE emitente.cgc = tt-dados-nota.cnpj-fornec:
        END.
    
        IF  NOT AVAIL emitente THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Fornecedor n∆o encontrado: CNPH = " + tt-dados-nota.cnpj-fornec.
        END.
    
        FOR FIRST estabelec NO-LOCK
            WHERE estabelec.cgc = tt-dados-nota.cnpj-estab:
        END.
    
        IF  NOT AVAIL estabelec THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Estabelecimento n∆o encontrado: CNPH = " + tt-dados-nota.cnpj-estab.
        END.
    
        FOR EACH tt-ordens:
    
            FOR FIRST ordem-compra NO-LOCK
                WHERE ordem-compra.numero-ordem = tt-ordens.num-ordem:
            END.
    
            IF  NOT AVAIL ordem-compra THEN DO:
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "Ordem de compra n∆o encontrada: NUM ORDEM = " + STRING(tt-ordens.num-ordem).
            END.
    
            IF  ordem-compra.cod-emitente <> emitente.cod-emitente THEN DO:
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "Fornecedor da OC (" + STRING(ordem-compra.cod-emitente) + ") Ç diferente do fornecedor da NF (" + STRING(emitente.cod-emitente) + ")".
            END.
        END.
    
        FOR FIRST tt-erros:
            RETURN "NOK".
        END.
    
    END. // bloco pi-validar-param        
    
    RETURN "OK".

END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-cria-tt-docum-est:

    bloco-cria-doc:
    DO ON ERROR UNDO, RETRY:
    
        IF  RETRY THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-cria-tt-docum-est".
            LEAVE bloco-cria-doc.
        END.
            
        FOR FIRST tt-ordens:
        END.
    
        FOR FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = tt-ordens.nat-operacao:
        END.
    
        CREATE tt-docum-est.
        ASSIGN tt-docum-est.nro-docto                = TRIM(STRING(INT(SUBSTRING(tt-dados-nota.chave-nfe, 26, 9)),">>9999999"))
               tt-docum-est.serie-docto              = TRIM(STRING(INT(SUBSTRING(tt-dados-nota.chave-nfe, 23, 3)),">>9")) 
               tt-docum-est.cod-emitente             = emitente.cod-emitente   
               tt-docum-est.nat-operacao             = natur-oper.nat-operacao
               tt-docum-est.cod-estabel              = estabelec.cod-estabel
               tt-docum-est.estab-fisc               = estabelec.cod-estabel
               tt-docum-est.uf                       = emitente.estado
               tt-docum-est.mod-frete                = 0 // tt-dados-nota.ind-frete  
               tt-docum-est.cod-placa[1]             = ""
               tt-docum-est.cod-uf-placa[1]          = ""
               tt-docum-est.dt-emis                  = tt-dados-nota.dat-emis
               tt-docum-est.dt-trans                 = TODAY
               tt-docum-est.nff                      = NO // Nota fiscal de Fatura
               tt-docum-est.dt-venc-ipi              = tt-dados-nota.dat-emis
               tt-docum-est.observacao               = tt-dados-nota.obs
               OVERLAY(tt-docum-est.char-2,166,2)    = tt-dados-nota.fin-nfe
               tt-docum-est.cod-chave-aces-nf-eletro = tt-dados-nota.chave-nfe
               tt-docum-est.cdn-sit-nfe              = 1
               tt-docum-est.usuario                  = c-seg-usuario
               .
        
    //    ASSIGN tt-docum-est.via-transp = IF tt-dados-nota.ind-modalidade = 1 
    //                                     THEN tt-dados-nota.ind-modalidade
    //                                     ELSE 4.
    
        IF  natur-oper.tipo-compra = 3 THEN
            ASSIGN tt-docum-est.esp-docto = 20.
        ELSE 
            IF  natur-oper.transf = YES THEN
                ASSIGN tt-docum-est.esp-docto = 23.
            ELSE 
                ASSIGN tt-docum-est.esp-docto = 21.
    
        IF  tt-docum-est.esp-docto = 20 THEN
            ASSIGN tt-docum-est.cod-observa = 3.
        ELSE
            IF  natur-oper.log-2 THEN 
                ASSIGN tt-docum-est.cod-observa = 2.  /* Comercio */
            ELSE 
                ASSIGN tt-docum-est.cod-observa = 1.  /* Industria*/        
    
        FIND FIRST estab-mat
             WHERE estab-mat.cod-estabel = estabelec.cod-estabel NO-LOCK NO-ERROR. 
        IF AVAIL estab-mat THEN
            ASSIGN tt-docum-est.conta-transit = estab-mat.conta-sai-consig.
        ELSE
            ASSIGN tt-docum-est.conta-transit = param-estoq.conta-consig.

    END. // bloco-cria-doc

END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-cria-tt-item-doc-est:

    bloco-cria-item-doc:
    DO ON ERROR UNDO, RETRY:
    
        IF  RETRY THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-cria-tt-item-doc-est".
            LEAVE bloco-cria-item-doc.
        END.
    
        ASSIGN i-seq = 0.
    
        FOR EACH tt-ordens,
    
            EACH ordem-compra NO-LOCK
            WHERE ordem-compra.numero-ordem = tt-ordens.num-ordem,
            EACH ITEM NO-LOCK
            WHERE ITEM.it-codigo = ordem-compra.it-codigo:
    
            ASSIGN i-seq = i-seq + 10.
            CREATE tt-item-doc-est.                                                                                                    
            ASSIGN tt-item-doc-est.cod-emitente   = tt-docum-est.cod-emitente                                                                         
                   tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto
                   tt-item-doc-est.nro-docto      = tt-docum-est.nro-docto                                                             
                   tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao                                                                     
                   tt-item-doc-est.sequencia      = i-seq
                   tt-item-doc-est.it-codigo      = ordem-compra.it-codigo
                   tt-item-doc-est.qt-do-for      = tt-ordens.quantidade
                   tt-item-doc-est.preco-unit     = tt-ordens.preco-unit
                   tt-item-doc-est.num-pedido     = ordem-compra.num-pedido
                   tt-item-doc-est.numero-ordem   = ordem-compra.numero-ordem
                   tt-item-doc-est.cod-refer      = ""
                   tt-item-doc-est.lote           = ""
                   tt-item-doc-est.un             = item.un                                                                            
                   tt-item-doc-est.parcela        = 1 // everton
                   //tt-item-doc-est.qt-do-forn     = 
                   tt-item-doc-est.encerra-pa     = NO                                                                                 
                   tt-item-doc-est.nr-ord-prod    = 0                                                                                  
                   tt-item-doc-est.cod-roteiro    = ""                                                                                 
                   tt-item-doc-est.op-codigo      = 0                                                                                  
                   tt-item-doc-est.item-pai       = ""                                                                                 
                   tt-item-doc-est.conta-contabil = item.conta-aplicacao
                   tt-item-doc-est.baixa-ce       = YES                                                                                
                   //tt-item-doc-est.cod-depos      = 
                   tt-item-doc-est.class-fiscal   = item.class-fiscal                                                                  
                   //tt-item-doc-est.cod-localiz    = item.cod-localiz 
                   //tt-item-doc-est.peso-liquido   = tt-item-doc-est.qt-do-forn 
                   tt-item-doc-est.cod-unid-negoc = ""
                   //tt-item-doc-est.cd-trib-icm    = IF AVAIL natur-oper THEN natur-oper.cd-trib-icm ELSE 1.
    
                   tt-item-doc-est.conta-contabil = ordem-compra.conta-contabil  
                   tt-item-doc-est.ct-codigo      = ordem-compra.ct-codigo
                   tt-item-doc-est.sc-codigo      = ordem-compra.sc-codigo
                    .
        END.
    
    END. // bloco cria-item-doc
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-efetivar-docto:

    bloco-doc:
    DO TRANSACTION ON ERROR   UNDO bloco-doc, RETRY bloco-doc
                   ON STOP    UNDO bloco-doc, RETRY bloco-doc
                   ON END-KEY UNDO bloco-doc, RETRY bloco-doc: 
                   
        IF  RETRY THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                    tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-efetivar-docto".
            LEAVE bloco-doc.
        END.
    
        RUN rep/reapi316a.p (INPUT  TABLE tt-docum-est,
                             INPUT  TABLE tt-rat-docum,
                             INPUT  TABLE tt-item-doc-est,
                             INPUT  TABLE tt-dupli-apagar,
                             INPUT  TABLE tt-dupli-imp,
                             OUTPUT TABLE tt-erros). //  NO-ERROR.

        // everton v19
        FOR FIRST tt-erros:
            UNDO bloco-doc, LEAVE bloco-doc.
        END.
        
        FOR FIRST docum-est NO-LOCK
            WHERE docum-est.cod-emitente = tt-docum-est.cod-emitente  
            AND   docum-est.serie-docto  = tt-docum-est.serie-docto  
            AND   docum-est.nro-docto    = tt-docum-est.nro-docto    
            AND   docum-est.nat-operacao = tt-docum-est.nat-operacao:
        END.

        IF  NOT AVAIL docum-est THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Gerar Dup - DOCUM-EST n∆o encontrado".
            UNDO bloco-doc, LEAVE bloco-doc.
        END.

        run rep/re9341.p (input ROWID(docum-est), input no). // gerar duplicatas

        FOR FIRST tt-erros:
            UNDO bloco-doc, LEAVE bloco-doc.
        END.
        
    END. // bloco-doc
 
END PROCEDURE.

//****************************************************************************************************
