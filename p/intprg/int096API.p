DEF TEMP-TABLE tt-devolucao NO-UNDO
    FIELD pedido            AS CHAR
    FIELD cnpj-devolucao    AS CHAR
    FIELD desconto          AS DEC
    FIELD observacao        AS CHAR
    FIELD cpf-cliente       AS CHAR
    FIELD cnpj-loja-origem  AS CHAR
    FIELD nota-origem       AS CHAR
    FIELD serie-origem      AS CHAR.

DEF TEMP-TABLE tt-itens NO-UNDO
    FIELD pedido           AS CHAR
    FIELD cod-item         AS CHAR
    FIELD sequencia        AS DEC
    FIELD quantidade       AS DEC
    FIELD lote             AS CHAR
    FIELD valor-unid       AS DEC.

DEF TEMP-TABLE tt-cond-pagto NO-UNDO
    FIELD pedido         AS CHAR
    FIELD cond-pagto     AS CHAR
    FIELD valor          AS DEC.

DEF TEMP-TABLE tt-nota-devolucao NO-UNDO
    FIELD nr-nota       AS CHAR
    FIELD serie         AS CHAR
    FIELD cnpj-loja     AS CHAR
    FIELD chave-acesso  AS CHAR
    FIELD l-gerada      AS LOG
    FIELD desc-erro     AS CHAR.


DEF INPUT PARAMETER TABLE FOR tt-devolucao.
DEF INPUT PARAMETER TABLE FOR tt-itens.
DEF INPUT PARAMETER TABLE FOR tt-cond-pagto.
DEF OUTPUT PARAMETER TABLE FOR tt-nota-devolucao.

{inbo/boin090.i tt-docum-est}      /* Definiªío tt-docum-est       */
{inbo/boin176.i4 tt-item-devol-cli} 
{method/dbotterr.i }              /* Definiªío RowErrors          */

define temp-table tt-param-re1005 no-undo
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.
    
define temp-table tt-digita-re1005 NO-UNDO
    field r-docum-est        as rowid.

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.


DEFINE TEMP-TABLE tt-it-nota-fisc NO-UNDO LIKE it-nota-fisc
       field r-rowid as rowid.


DEFINE VARIABLE h-boin090       AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-boin176       AS HANDLE      NO-UNDO.
DEFINE VARIABLE rNotaFiscal     AS ROWID    NO-UNDO.
DEFINE VARIABLE c-serie         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE l-erro          AS LOGICAL     NO-UNDO.
DEFINE VARIABLE c-nat-origem    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-class-fiscal  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-it-codigo     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE l-item          AS LOGICAL     NO-UNDO.

DEFINE VARIABLE c-aux     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-nat-of  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE r-rowid   AS ROWID       NO-UNDO.



DEFINE BUFFER b-estab-origem FOR estabelec.
DEFINE BUFFER b-emitente     FOR emitente.

def temp-table tt-docum-est-ent     no-undo like tt-docum-est.

empty temp-table tt-docum-est-ent.

FIND FIRST param-estoq NO-LOCK NO-ERROR.


ASSIGN c-serie = "20". //era 15

DO TRANSACTION :

    FOR EACH tt-devolucao:
    
   
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cgc = tt-devolucao.CNPJ-DEVOLUCAO NO-ERROR.
        IF NOT AVAIL estabelec THEN DO:

            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = "Estabelecimento n∆o encontrado: " + tt-devolucao.CNPJ-DEVOLUCAO.
                .
    
            ASSIGN l-erro = YES.
            undo, leave.
    
    
        END.
    
        FIND FIRST b-estab-origem NO-LOCK
            WHERE b-estab-origem.cgc = tt-devolucao.cnpj-loja-origem NO-ERROR.

        IF NOT AVAIL b-estab-origem THEN DO:
            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = "Estabelecimento nota origem n∆o encontrado: " + tt-devolucao.cnpj-loja-origem.
                .
    
             ASSIGN l-erro = YES.
             undo, leave.
    
    
        END.

    
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.cod-estabel = b-estab-origem.cod-estabel
            AND   nota-fiscal.serie       = tt-devolucao.SERIE-ORIGEM
            AND   nota-fiscal.nr-nota-fis = tt-devolucao.nOTA-ORIGEM NO-ERROR.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.

        IF NOT AVAIL emitente THEN DO:
    
            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = "Emitente n∆o encontrado: " + tt-devolucao.CPF-CLIENTE.
                .
    
             ASSIGN l-erro = YES.
             undo, leave.
    
        END.

        FOR EACH tt-itens NO-LOCK:

            ASSIGN c-nat-origem     = ""
                   c-class-fiscal   = "" 
                   c-it-codigo      = "".

            FOR  FIRST it-nota-fisc NO-LOCK
                WHERE it-nota-fisc.cod-estabel   = b-estab-origem.cod-estabel
                  AND it-nota-fisc.serie         = tt-devolucao.SERIE-ORIGEM
                  AND it-nota-fisc.nr-nota-fis   = string(INT(tt-devolucao.NOTA-ORIGEM), "9999999")
                  AND it-nota-fisc.it-codigo     = tt-itens.cod-item
                  AND it-nota-fisc.nr-seq-fat    = int(tt-itens.sequencia)
                 ,FIRST ITEM NO-LOCK
                  WHERE ITEM.it-codigo = it-nota-fisc.it-codigo: 
    
                   ASSIGN c-nat-origem      = it-nota-fisc.nat-operacao
                          c-class-fiscal    = ITEM.class-fiscal
                          c-it-codigo       = ITEM.it-codigo .

            END.

            IF c-nat-origem = "" THEN DO:

                CREATE tt-nota-devolucao.
                ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                       tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                       tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                       tt-nota-devolucao.l-gerada   = NO
                       tt-nota-devolucao.desc-erro  = "Item n∆o encontrado na nota fiscal de origem, item: " + tt-itens.cod-item.
                    .
    
                 ASSIGN l-erro = YES.
                 undo, leave.
            END.

       END.


       ASSIGN c-nat-of = "".

       run intprg/int115a.p ( input "99"    ,
                      input estabelec.estado   ,
                      input estabelec.estado  ,
                      input c-nat-origem   ,
                      input emitente.cod-emitente ,
                      input c-class-fiscal ,
                      input c-it-codigo    , /* item */
                      INPUT estabelec.cod-estabel, 
                      output c-aux         ,
                      output c-nat-of      ,
                      output r-rowid   ).

       IF c-nat-of = "" THEN DO:

            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = "N∆o encontrado natureza de operacao da nota fiscal".
                .
    
             ASSIGN l-erro = YES.
             undo, leave.


       END.


    
        FIND FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = c-nat-of NO-ERROR. // KML Buscar a correta natureza atravÇs do int115

        FIND FIRST ser-estab
            WHERE ser-estab.cod-estabel = b-estab-origem.cod-estabel
              AND ser-estab.serie       = c-serie NO-ERROR.
    
        IF NOT AVAIL ser-estab THEN DO:
    
            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = "Serie x estabelecimento n∆o encontrado, revisar ft0114 - Serie: " + c-serie + " Estab: " + estabelec.cod-estabel.
                .
    
             ASSIGN l-erro = YES.
             undo, leave.
    
        END.

        log-manager:write-message("KML - Terminou validacoes basicas -  " + string(l-erro)) no-error.

        IF l-erro THEN
            UNDO, LEAVE.
            
         FIND FIRST b-emitente NO-LOCK
              WHERE b-emitente.cgc = estabelec.cgc NO-ERROR.
            
        
        create tt-docum-est-ent.
        assign tt-docum-est-ent.nro-docto    = STRING(INT(ser-estab.nr-ult-nota) + 1, "9999999")
               tt-docum-est-ent.cod-emitente = emitente.cod-emitente
               tt-docum-est-ent.serie-docto  = c-serie
               tt-docum-est-ent.char-2       = c-serie /* Serie documento principal */
               tt-docum-est-ent.nat-operacao = natur-oper.nat-operacao                             
               tt-docum-est-ent.cod-observa  = 3 // devoluá∆o
               tt-docum-est-ent.cod-estabel  = b-estab-origem.cod-estabel //estabelec.cod-estabel
               tt-docum-est-ent.estab-fisc   = estabelec.cod-estabel //Era estabelec.cod-estabel 
               tt-docum-est-ent.estab-de-or  = b-estab-origem.cod-estabel 
               tt-docum-est-ent.usuario      = "RPW"
               tt-docum-est-ent.uf           = emitente.estado 
               tt-docum-est-ent.pais         = emitente.pais 
               tt-docum-est-ent.via-transp   = 1
               tt-docum-est-ent.dt-emis      = TODAY   
               tt-docum-est-ent.dt-trans     = TODAY                          
               tt-docum-est-ent.nff          = no                              
               tt-docum-est-ent.observacao   = "Devoluá∆o cliente : TESTES TESTES TESTE "  
               tt-docum-est-ent.valor-mercad = 0 
               tt-docum-est-ent.tot-valor    = 0
               tt-docum-est-ent.conta-transit = param-estoq.conta-fornec
               tt-docum-est-ent.ct-transit    = "91102040" 
               tt-docum-est-ent.sc-transit    = ""
               OVERLAY(tt-docum-est-ent.char-1,93,60)  = ""
               OVERLAY(tt-docum-est-ent.char-1,192,16) = "" /* Aviso de recolhimento */     
               tt-docum-est-ent.esp-docto     = 21.
        
        
        log-manager:write-message("KML - Antes criar docum-est -  " + string(l-erro)) no-error.

        FOR EACH tt-docum-est-ent:
        
            create tt-docum-est.
            buffer-copy tt-docum-est-ent TO tt-docum-est.
            RUN pi-grava-docum-est.
        
        END.

        log-manager:write-message("KML - Depois criar docum-est -  " + string(l-erro)) no-error.

        IF l-erro THEN
            UNDO, LEAVE.
        
        // VALIDA NOTA DE DEVOLUÄ«O INFORMADA
        
        run emptyRowErrors in h-boin090.
        
        run setconstraintnotafiscal in h-boin090 (input no). /*Indicando que a geraªío nío serˇ por item*/
        
        log-manager:write-message("KML - tt-devolucao.SERIE-ORIGEM -  " + tt-devolucao.SERIE-ORIGEM) no-error.
        log-manager:write-message("KML - tt-devolucao.nota-ORIGEM - " + tt-devolucao.nota-ORIGEM) no-error.
    
        run consistNotaDevolCli in h-boin090 ( input  nota-fiscal.serie , //tt-devolucao.SERIE-ORIGEM ,
                                               input  nota-fiscal.nr-nota-fis , //STRING(int(tt-devolucao.NOTA-ORIGEM), "9999999") ,
                                               input  "",
                                               input  0,
                                               output rNotaFiscal ).
                                               
        log-manager:write-message("KML - Antes RUN - " + string(rNotaFiscal)) no-error.                                       

        run getRowErrors in h-boin090( output table rowErrors ).

        log-manager:write-message("KML - Antes valida nota origem -  " + string(l-erro)) no-error.

        FOR EACH rowErrors:
            // Retornar esse erro caso n∆o valide a nota de saida

            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = string(RowErrors.ErrorNumber) + " - " + RowErrors.ErrorDescription.
            .

            ASSIGN l-erro = YES.
            //undo, leave.

        END.

        log-manager:write-message("KML - Depois valida nota origem -  " + string(l-erro)) no-error.

   

        IF l-erro THEN
            UNDO, LEAVE.
    
        // CRIA ITENS PARA SEREM DEVOLVIDOS
    
        log-manager:write-message("KML - Antes cria itens -  " + string(l-erro)) no-error.
        
        FOR EACH nota-fiscal NO-LOCK   //ROWID(nota-fiscal) = rNotaFiscal:
            WHERE nota-fiscal.cod-estabel = b-estab-origem.cod-estabel
            AND   nota-fiscal.serie       = tt-devolucao.SERIE-ORIGEM
            AND   nota-fiscal.nr-nota-fis = tt-devolucao.nOTA-ORIGEM :
            
            

            MESSAGE nota-fiscal.cod-estabel SKIP
                    nota-fiscal.serie       SKIP
                    nota-fiscal.nr-nota-fis
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

         log-manager:write-message("KML - Depois Message -  " + string(nota-fiscal.cod-estabel)) no-error.
         LOG-MANAGER:WRITE-MESSAGE("KML - TESTE nota  - " + STRING(nota-fiscal.nr-nota-fis)) NO-ERROR.
        
            FOR EACH tt-itens:
    
                FIND FIRST it-nota-fisc NO-LOCK
                    WHERE it-nota-fisc.cod-estabel  = nota-fiscal.cod-estabel
                      AND it-nota-fisc.serie        = nota-fiscal.serie
                      AND it-nota-fisc.nr-nota-fis  = nota-fiscal.nr-nota-fis
                      AND it-nota-fisc.nr-seq-fat   = int(tt-itens.sequencia)
                      AND it-nota-fisc.it-codigo    = tt-itens.cod-item NO-ERROR.
    
                IF NOT AVAIL it-nota-fisc THEN DO:
    
                    CREATE tt-nota-devolucao.
                    ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                           tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                           tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                           tt-nota-devolucao.l-gerada   = NO                                             
                           tt-nota-devolucao.desc-erro  = "Item n∆o encontrado nessa nota fiscal - Item: " + tt-itens.cod-item.
                    .
                
                    ASSIGN l-erro = YES.
                    undo, leave.
    
                END.
    
                log-manager:write-message("KML - Depois cria itens a devolver -  " + string(l-erro)) no-error.

                FIND FIRST ITEM NO-LOCK
                    WHERE ITEM.it-codigo = it-nota-fisc.it-codigo NO-ERROR.

                ASSIGN c-nat-origem      = it-nota-fisc.nat-operacao
                       c-class-fiscal    = ITEM.class-fiscal
                       c-it-codigo       = ITEM.it-codigo.

                ASSIGN c-nat-of = "".
                     
                run intprg/int115a.p ( input "99"    ,
                               input estabelec.estado   ,
                               input estabelec.estado  ,                   
                               input c-nat-origem   ,
                               input emitente.cod-emitente ,
                               input c-class-fiscal ,
                               input c-it-codigo    , /* item */
                               INPUT estabelec.cod-estabel, 
                               output c-aux         ,
                               output c-nat-of      ,
                               output r-rowid   ).


                IF c-nat-of = "" THEN DO:
                 
                     CREATE tt-nota-devolucao.
                     ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                            tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                            tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                            tt-nota-devolucao.l-gerada   = NO
                            tt-nota-devolucao.desc-erro  = "N∆o encontrado natureza de operacao do item ".
                         .
            
                      ASSIGN l-erro = YES.
                      undo, leave.
        
                END.
            
                create tt-item-devol-cli.
                assign tt-item-devol-cli.rw-it-nota-fisc = rowid(it-nota-fisc)
                       tt-item-devol-cli.quant-devol     = tt-itens.quantidade
                       tt-item-devol-cli.preco-devol     = tt-itens.valor-unid
                       tt-item-devol-cli.cod-depos       = it-nota-fisc.cod-depos
                       tt-item-devol-cli.reabre-pd       = NO
                       tt-item-devol-cli.vl-desconto     = it-nota-fisc.vl-desconto
                       tt-item-devol-cli.nat-of          = c-nat-of. 
            
                
            END.
        END.
    
    
        log-manager:write-message("KML - Depois cria itens a devolver -  " + string(l-erro)) no-error.
    
        IF l-erro THEN
            UNDO, LEAVE.
    
    
        // Cria itens de devoluá∆o
        
    
        log-manager:write-message("KML - Antes valida itens a devolver -  " + string(l-erro)) no-error.
        
        if  not valid-handle( h-boin176 ) then do:
            run inbo/boin176.p persistent set h-boin176.
            run openQueryStatic in h-boin176 ( input "Main":U ).
        end.
        
        RUN emptyRowErrors IN h-boin176.
        
        run createItemOfNotaFiscal in h-boin176 ( input h-boin090,                    //h-boin176 
                                                  input table tt-item-devol-cli ).
        
        run getRowErrors in h-boin176 ( output table RowErrors ).
        
        MESSAGE "valida item - " RETURN-VALUE
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
        FIND FIRST RowErrors NO-ERROR.      
        
        IF CAN-FIND(FIRST RowErrors) THEN DO:

            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.l-gerada   = NO
                   tt-nota-devolucao.desc-erro  = string(RowErrors.ErrorNumber) + "-" +  RowErrors.ErrorDescription.
            .
        
            ASSIGN l-erro = YES.
            undo, leave.
    
            // Retornar esse erro caso n∆o valide a nota de saida
  
        END.
    
        log-manager:write-message("KML - Depois valida itens a devolver -  " + string(l-erro)) no-error.
    
        IF l-erro THEN
            UNDO, LEAVE.
    END.
    // Atualiza RE1005

    IF l-erro THEN
    UNDO, LEAVE.
    
    log-manager:write-message("KML - antes RE1005 V2 -  " + string(l-erro)) no-error.

    run getRecord in h-boin090 (output table tt-docum-est).
    find first tt-docum-est no-error.

    create tt-param-re1005.
    assign 
        tt-param-re1005.destino            = 3
        tt-param-re1005.arquivo            = "int42-re1005.txt"
        tt-param-re1005.usuario            = "RPW"
        tt-param-re1005.data-exec          = today
        tt-param-re1005.hora-exec          = time
        tt-param-re1005.classifica         = 1
        tt-param-re1005.c-cod-estabel-ini  = tt-docum-est.cod-estabel
        tt-param-re1005.c-cod-estabel-fim  = tt-docum-est.cod-estabel
        tt-param-re1005.i-cod-emitente-ini = tt-docum-est.cod-emitente
        tt-param-re1005.i-cod-emitente-fim = tt-docum-est.cod-emitente
        tt-param-re1005.c-nro-docto-ini    = tt-docum-est.nro-docto
        tt-param-re1005.c-nro-docto-fim    = tt-docum-est.nro-docto
        tt-param-re1005.c-serie-docto-ini  = tt-docum-est.serie-docto
        tt-param-re1005.c-serie-docto-fim  = tt-docum-est.serie-docto
        tt-param-re1005.c-nat-operacao-ini = tt-docum-est.nat-operacao
        tt-param-re1005.c-nat-operacao-fim = tt-docum-est.nat-operacao
        tt-param-re1005.da-dt-trans-ini    = tt-docum-est.dt-trans
        tt-param-re1005.da-dt-trans-fim    = tt-docum-est.dt-trans.


    create tt-digita-re1005.
    assign tt-digita-re1005.r-docum-est  = rowid(tt-docum-est).

    raw-transfer tt-param-re1005 to raw-param.
    run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

    empty temp-table tt-digita-re1005.
    empty temp-table tt-param-re1005.

    log-manager:write-message("KML - Depois RE1005 V2 -  " + string(l-erro)) no-error.

    run getRecord in h-boin090 (output table tt-docum-est).
    find first tt-docum-est no-error.


    FIND FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel   = tt-docum-est.cod-estabel
          AND nota-fiscal.serie         = tt-docum-est.serie-docto
          AND nota-fiscal.nr-nota-fis   = tt-docum-est.nro-docto NO-ERROR.
          
    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.

    CREATE tt-nota-devolucao.
    ASSIGN tt-nota-devolucao.nr-nota    = tt-docum-est.nro-docto
           tt-nota-devolucao.serie      = tt-docum-est.serie-docto
           tt-nota-devolucao.cnpj-loja  = estabelec.cgc
           tt-nota-devolucao.l-gerada   = YES
           tt-nota-devolucao.desc-erro  = "Nota fiscal criada com sucesso".
            .
    IF AVAIL nota-fiscal THEN
        ASSIGN tt-nota-devolucao.chave-acesso = nota-fiscal.cod-chave-aces-nf-eletro.

    MESSAGE tt-docum-est.nro-docto
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    log-manager:write-message("KML - FIM -  " + string(l-erro)) no-error.

    IF l-erro THEN
        UNDO, LEAVE.

END. // Fim transaction



procedure pi-grava-docum-est :

    run inbo/boin090.p persistent set h-boin090.

    /* Abertura de Query */       
    run openQueryStatic in h-boin090 ( "Main":U ).

    /* Transfere tt-docum-est para BO */
    run setRecord in h-boin090 ( input table tt-docum-est ).

    /* Determina Defaults da nota Fiscal */
    /*run setDefaultsnota in h-boin090.*/
    
    /* Cria doCUM-EST */    
    run createRecord in h-boin090.
    

    if return-value = "NOK":U then do:

        run getRowErrors in h-boin090 ( output table RowErrors ).

        for each RowErrors no-lock 
            where RowErrors.ErrorSubType = "ERROR" 
               OR (RowErrors.ErrorSubType = "Warning"
                AND (RowErrors.ErrorNumber  = 18799 OR 
                  RowErrors.ErrorNumber  = 18796)):
               
            CREATE tt-nota-devolucao.
            ASSIGN tt-nota-devolucao.nr-nota    = tt-devolucao.nOTA-ORIGEM  
                   tt-nota-devolucao.serie      = tt-devolucao.SERIE-ORIGEM
                   tt-nota-devolucao.cnpj-loja  = tt-devolucao.CNPJ-LOJA-ORIGEM
                   tt-nota-devolucao.desc-erro  = STRING(RowErrors.ErrorNumber) + " - " +  RowErrors.ErrorDescription
                .
    
            ASSIGN l-erro = YES.
            undo, leave.
        END.

    end.

end procedure.
