/*************************************************************************
**
** FT0717.i3 - Include para rateio de despesas da unidade de neg¢cio
**

*************************************************************************/

DEFINE TEMP-TABLE tt-rateio-desp-it NO-UNDO
    FIELD cod-estabel    LIKE nota-fiscal.cod-estabel
    FIELD serie          LIKE nota-fiscal.serie
    FIELD nr-nota-fis    LIKE nota-fiscal.nr-nota-fis
    FIELD cod-despesa    LIKE despesa.cod-despesa
    FIELD nr-seq-fat     LIKE it-nota-fisc.nr-seq-fat
    FIELD it-codigo      LIKE it-nota-fisc.it-codigo
    FIELD cod-unid-negoc   AS CHAR FORMAT "x(3)"
    FIELD cdn-ctconta    as char format "x(20)"
    FIELD cdn-ccusto     as char format "x(20)"
    FIELD valor-rateio     AS DECIMAL
    INDEX ch-codigo  IS UNIQUE PRIMARY
        cod-estabel  ASCENDING   
        serie        ASCENDING
        nr-nota-fis  ASCENDING
        cod-despesa  ASCENDING
        nr-seq-fat   ASCENDING
        it-codigo    ASCENDING
    INDEX ch-item
        cod-estabel  ASCENDING    
        serie        ASCENDING
        nr-nota-fis  ASCENDING
        nr-seq-fat   ASCENDING
        it-codigo    ASCENDING
    INDEX ch-item-valor 
        cod-estabel  ASCENDING   
        serie        ASCENDING
        nr-nota-fis  ASCENDING
        nr-seq-fat   ASCENDING
        it-codigo    ASCENDING
        valor-rateio ASCENDING.

PROCEDURE pi-rateio-despesas-unidade-negocio:

    DEFINE BUFFER b-it-nota-fisc FOR it-nota-fisc.

    DEF VAR de-saldo         AS DEC NO-UNDO.
    DEF VAR i-nr-linhas-nota AS INT.

    FOR EACH tt-rateio-desp-it:
        DELETE tt-rateio-desp-it.
    END.

    /*** Inicio bloco cria»’o rateios das despesas por item ***/
    for each desp-nota-fisc no-lock
       where desp-nota-fisc.serie       = nota-fiscal.serie 
       AND   desp-nota-fisc.cod-estabel = nota-fiscal.cod-estabel 
       AND   desp-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis:                    

        find despesa
            where despesa.cod-despesa = desp-nota-fisc.cod-despesa no-lock no-error.

        /* Inicializa vari vel para controle de sobra */
        assign de-saldo        = desp-nota.val-despesa.

        if  despesa.cdn-tp-rateio = 3 /* RATEIO POR PESO */
        AND nota-fiscal.peso-bru-tot > 0 then do:                    

            for each b-it-nota-fisc OF nota-fiscal NO-LOCK
                BREAK BY b-it-nota-fisc.nr-seq-fat:

                FIND tt-rateio-desp-it
                    WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                    AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                    AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                    AND   tt-rateio-desp-it.cod-despesa = despesa.cod-despesa
                    AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                    AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo EXCLUSIVE-LOCK NO-ERROR.

                IF NOT AVAIL tt-rateio-desp-it THEN DO:
                    CREATE tt-rateio-desp-it.
                    ASSIGN tt-rateio-desp-it.cod-estabel    = b-it-nota-fisc.cod-estabel
                           tt-rateio-desp-it.serie          = b-it-nota-fisc.serie      
                           tt-rateio-desp-it.nr-nota-fis    = b-it-nota-fisc.nr-nota-fis
                           tt-rateio-desp-it.cod-despesa    = despesa.cod-despesa       
                           tt-rateio-desp-it.nr-seq-fat     = b-it-nota-fisc.nr-seq-fat 
                           tt-rateio-desp-it.it-codigo      = b-it-nota-fisc.it-codigo
                           tt-rateio-desp-it.cod-unid-negoc = b-it-nota-fisc.cod-unid-negoc 
                           tt-rateio-desp-it.cdn-ctconta    = despesa.cdn-ctconta
                           tt-rateio-desp-it.cdn-ccusto     = despesa.cdn-ccusto. 
                END.

                IF NOT LAST(b-it-nota-fisc.nr-seq-fat) THEN
                    assign tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio 
                                        + TRUNC(b-it-nota-fisc.peso-brut / nota-fiscal.peso-bru-tot * desp-nota-fisc.val-despesa, 2)
                           de-saldo                       = de-saldo - TRUNC(b-it-nota-fisc.peso-brut / nota-fiscal.peso-bru-tot * desp-nota-fisc.val-despesa, 2).
                ELSE 
                    ASSIGN tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio + de-saldo
                           de-saldo                       = 0.
            end.
        end.
        else do:
            IF  despesa.cdn-tp-rateio = 1   /* rateio por Valor */
            AND nota-fiscal.vl-mercad > 0 then do:

                for each b-it-nota-fisc OF nota-fiscal NO-LOCK
                BREAK BY b-it-nota-fisc.nr-seq-fat:

                    FIND tt-rateio-desp-it
                        WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                        AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                        AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                        AND   tt-rateio-desp-it.cod-despesa = despesa.cod-despesa
                        AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                        AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo EXCLUSIVE-LOCK NO-ERROR.

                    IF NOT AVAIL tt-rateio-desp-it THEN DO:
                        CREATE tt-rateio-desp-it.
                        ASSIGN tt-rateio-desp-it.cod-estabel    = b-it-nota-fisc.cod-estabel
                               tt-rateio-desp-it.serie          = b-it-nota-fisc.serie      
                               tt-rateio-desp-it.nr-nota-fis    = b-it-nota-fisc.nr-nota-fis
                               tt-rateio-desp-it.cod-despesa    = despesa.cod-despesa       
                               tt-rateio-desp-it.nr-seq-fat     = b-it-nota-fisc.nr-seq-fat 
                               tt-rateio-desp-it.it-codigo      = b-it-nota-fisc.it-codigo
                               tt-rateio-desp-it.cod-unid-negoc =  b-it-nota-fisc.cod-unid-negoc 
                               tt-rateio-desp-it.cdn-ctconta    = despesa.cdn-ctconta
                               tt-rateio-desp-it.cdn-ccusto     = despesa.cdn-ccusto.
                    END.

                    IF NOT LAST(b-it-nota-fisc.nr-seq-fat) THEN 
                        assign tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio 
                                           + trunc(b-it-nota-fisc.vl-merc-liq / nota-fiscal.vl-mercad * desp-nota-fisc.val-despesa, 2)
                               de-saldo                       = de-saldo - trunc(b-it-nota-fisc.vl-merc-liq / nota-fiscal.vl-mercad * desp-nota-fisc.val-despesa, 2).
                    ELSE 
                        ASSIGN tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio + de-saldo
                               de-saldo                       = 0.

                end.
            end.
            else do:
                /* rateio por linhas da nota fiscal */

                /* Quantas linhas existem na nota? */
                SELECT COUNT(*) INTO i-nr-linhas-nota FROM it-nota-fisc 
                    WHERE it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel
                    AND   it-nota-fisc.serie       = nota-fiscal.serie
                    AND   it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis.


                for each b-it-nota-fisc OF nota-fiscal NO-LOCK
                BREAK BY b-it-nota-fisc.nr-seq-fat:

                    FIND tt-rateio-desp-it
                        WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                        AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                        AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                        AND   tt-rateio-desp-it.cod-despesa = despesa.cod-despesa
                        AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                        AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo EXCLUSIVE-LOCK NO-ERROR.

                    IF NOT AVAIL tt-rateio-desp-it THEN DO:
                        CREATE tt-rateio-desp-it.
                        ASSIGN tt-rateio-desp-it.cod-estabel    = b-it-nota-fisc.cod-estabel
                               tt-rateio-desp-it.serie          = b-it-nota-fisc.serie      
                               tt-rateio-desp-it.nr-nota-fis    = b-it-nota-fisc.nr-nota-fis
                               tt-rateio-desp-it.cod-despesa    = despesa.cod-despesa       
                               tt-rateio-desp-it.nr-seq-fat     = b-it-nota-fisc.nr-seq-fat 
                               tt-rateio-desp-it.it-codigo      = b-it-nota-fisc.it-codigo
                               tt-rateio-desp-it.cod-unid-negoc = b-it-nota-fisc.cod-unid-negoc 
                               tt-rateio-desp-it.cdn-ctconta    = despesa.cdn-ctconta
                               tt-rateio-desp-it.cdn-ccusto     = despesa.cdn-ccusto.
                    END.

                    /* Quando o rateio for por linhas da nota, dividir o valor da despesa pelo nœmero de itens */
                    IF NOT LAST(b-it-nota-fisc.nr-seq-fat) THEN 
                        assign tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio + trunc(desp-nota-fisc.val-despesa / i-nr-linhas-nota, 2)
                           de-saldo                           = de-saldo - trunc(desp-nota-fisc.val-despesa / i-nr-linhas-nota, 2).
                    ELSE 
                        ASSIGN tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio + de-saldo
                               de-saldo                       = 0.
                end.
            end.
        end.
    END.     
    /*** Fim bloco cria»’o rateios das despesas por item ***/

    /*** Inicio bloco acerto dos valores rateados ***/
    FOR EACH b-it-nota-fisc OF nota-fiscal NO-LOCK:
        
        IF CAN-FIND(FIRST tt-rateio-desp-it USE-INDEX ch-item
                    WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                    AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                    AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                    AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                    AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo) THEN DO:
            FOR EACH tt-rateio-desp-it USE-INDEX ch-item
                WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo:
                ACCUMULATE tt-rateio-desp-it.valor-rateio (TOTAL).
            END.
            IF b-it-nota-fisc.vl-despes-it <> (ACCUM TOTAL tt-rateio-desp-it.valor-rateio) THEN DO:
                FIND LAST tt-rateio-desp-it USE-INDEX ch-item-valor
                  WHERE tt-rateio-desp-it.cod-estabel = b-it-nota-fisc.cod-estabel
                  AND   tt-rateio-desp-it.serie       = b-it-nota-fisc.serie
                  AND   tt-rateio-desp-it.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
                  AND   tt-rateio-desp-it.nr-seq-fat  = b-it-nota-fisc.nr-seq-fat
                  AND   tt-rateio-desp-it.it-codigo   = b-it-nota-fisc.it-codigo NO-LOCK NO-ERROR.
                  IF AVAIL tt-rateio-desp-it THEN
                  ASSIGN tt-rateio-desp-it.valor-rateio = tt-rateio-desp-it.valor-rateio 
                                                        + (b-it-nota-fisc.vl-despes-it - (ACCUM TOTAL tt-rateio-desp-it.valor-rateio)).
            END.
        END.
    END. 
    /*** Fim bloco acerto dos valores rateados ***/

    /*** Inicio bloco acerto Unidade de Neg¢cio ***/
    FOR EACH tt-rateio-desp-it NO-LOCK:
            IF  c-nom-prog-dpc-mg97  <> "" OR  
                c-nom-prog-appc-mg97 <> "" OR  
                c-nom-prog-upc-mg97  <> "" THEN DO:
            
                FOR EACH  tt-epc
                    WHERE tt-epc.cod-event = "AtualizaUnidadeNegocio":U :
                    DELETE tt-epc.
                END.
            
                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "AtualizaUnidadeNegocio":U
                       tt-epc.cod-parameter = "AtualizaUnidadeNegocio":U
                       tt-epc.val-parameter = tt-rateio-desp-it.cod-estabel            + "," +  /*Cod Estabelecimento*/
                                              tt-rateio-desp-it.serie                  + "," +  /*Serie*/
                                              tt-rateio-desp-it.nr-nota.                        /*Nota Fiscal*/
                
                {include/i-epc201.i "AtualizaUnidadeNegocio"}
                
                FIND FIRST tt-epc NO-LOCK WHERE tt-epc.cod-event = "AtualizaUnidadeNegocio":U.
                
                ASSIGN tt-rateio-desp-it.cod-unid-negoc = STRING(tt-epc.val-parameter).
                /* sem tratamento de retorno */
                
            END.
    END.
    /*** Fim bloco acerto Unidade de Neg¢cio ***/
    /*** Inicio bloco gera»’o lan»amentos cont beis ***/
    FOR EACH tt-rateio-desp-it NO-LOCK:

        assign de-vl-contab = tt-rateio-desp-it.valor-rateio * de-fator.

        if  de-vl-contab <> 0 then do:
            {ftp/ft0717.i2 tt-rateio-desp-it.cdn-ctconta de-vl-contab 22 tt-rateio-desp-it.cdn-ccusto "tt-rateio-desp-it.cod-unid-negoc"} 
        end.

        /* cria sumar-ft e soma o valor padrao - debito  */
        assign de-vl-contab = tt-rateio-desp-it.valor-rateio * (-1) * de-fator.

        
        {ftp/ft0717.i2 estabelec.ct-recven de-vl-contab 20 estabelec.sc-recven "tt-rateio-desp-it.cod-unid-negoc"}

    END.    
    /*** Fim bloco gera»’o lan»amentos cont beis ***/

END PROCEDURE.


