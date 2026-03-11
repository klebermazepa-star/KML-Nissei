/********************************************************************************
** Programa : int002e
** Funá∆o   : gera nota no recebimento re1001.
** Data     : 12/2015
********************************************************************************/
{include/i-prgvrs.i int002e 2.06.00.001}  
{utp/ut-glob.i}

{inbo/boin090.i tt-docum-est}      /* Definiá∆o TT-DOCUM-EST       */
{inbo/boin366.i tt-rat-docum}      /* Definiá∆o TT-RAT-DOCUM       */
{inbo/boin366.i tt2-rat-docum}     /* Definiá∆o TT-RAT-DOCUM       */
{inbo/boin176.i tt-item-doc-est}   /* Definiá∆o TT-ITEM-DOC-EST    */
{inbo/boin176.i tt2-item-doc-est}  /* Definiá∆o TT-ITEM-DOC-EST    */
{inbo/boin092.i tt-dupli-apagar}   /* Definiá∆o TT-DUPLI-APAGAR    */
{inbo/boin092.i tt2-dupli-apagar}  /* Definiá∆o TT-DUPLI-APAGAR    */
{inbo/boin567.i tt-dupli-imp}      /* Definiá∆o TT-DUPLI-IMP       */
{inbo/boin567.i tt2-dupli-imp}     /* Definiá∆o TT-DUPLI-IMP       */
{inbo/boin366.i tt-imposto}        /* Definiá∆o TT-IMPOSTO         */
{inbo/boin176.i5 tt-item-terc }    /* Definiá∆o TT-ITEM-TERC       */
{inbo/boin404.i tt-saldo-terc}     /* TT-SALDO-TERC                */ 
{cdp/cdcfgmat.i}
{method/dbotterr.i }              /* Definiá∆o RowErrors          */
{cdp/cd0666.i}

def temp-table tt-valida-erro  NO-UNDO LIKE RowErrors.
def temp-table tt-valida-param NO-UNDO LIKE RowErrors.

DEF TEMP-TABLE tt-nota no-undo
FIELD situacao     AS   INTEGER
FIELD nro-docto    LIKE docum-est.nro-docto   
FIELD serie-nota   LIKE docum-est.serie-docto
FIELD serie-docum  LIKE docum-est.serie-docto        
FIELD cod-emitente LIKE docum-est.cod-emitente
FIELD nat-operacao LIKE docum-est.nat-operacao
FIELD tipo-nota    LIKE int_ds_docto_xml.tipo_nota
FIELD valor-mercad LIKE doc-fisico.valor-mercad.

define temp-table tt-param
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

define temp-table tt-digita
    field r-docum-est        as rowid.

def temp-table tt-raw-digita
   field raw-digita   as raw.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
FIELD serie        AS CHAR FORMAT "x(03)"
FIELD nro-docto    AS CHAR FORMAT "9999999"
FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
FIELD descricao    AS CHAR. 

DEF TEMP-TABLE tt-arquivo-erro
FIELD c-linha AS CHAR.

DEF INPUT  PARAM TABLE  FOR tt-nota.
def INPUT  param table  for tt-docum-est.
def input  param table  for tt-item-doc-est.

DEF BUFFER b-docum-est FOR docum-est.

def var raw-param              as raw              no-undo.
def var h-boin090              as handle           no-undo.
def var h-boin366              as handle           no-undo.
def var h-boin176              as handle           no-undo.
def var h-boin092              as handle           no-undo.
def var h-boin567              as handle           no-undo.
def var h-boin404              as handle           no-undo.
def var h-boin223              as handle           no-undo.
def VAR h-boin404re            as handle           no-undo.
def var l-terceiros            as logical          no-undo.
DEF VAR de-tot-dup             AS DEC              no-undo.       
DEF VAR de-qtd-saldo           AS DEC              no-undo.       
DEF VAR de-qtd-saldo-menor     AS DEC              no-undo.
DEF VAR de-qtd-saldo-total     AS DEC              no-undo.
DEF VAR d-proporcao            AS DECIMAL          no-undo.
DEF VAR de-qt-componente       LIKE componente.quantidade   NO-UNDO.
DEF VAR i-dias                 AS INT                       NO-UNDO. 
DEF VAR da-data                AS DATE                      NO-UNDO.
DEF VAR l-avail                AS LOGICAL                   NO-UNDO.
DEF VAR c-arquivo              AS CHAR FORMAT "x(200)"      NO-UNDO.
DEF VAR r-docum-est-transf     AS ROWID                     NO-UNDO.
DEF VAR c-mensagem-advertencia AS CHAR FORMAT "x(100)"      NO-UNDO.
DEF VAR h-bodi515              AS HANDLE                    NO-UNDO.
DEF VAR l-emite-nfe            AS LOGICAL                   NO-UNDO.
DEF VAR r-docum-est            AS ROWID                     NO-UNDO.
DEF VAR l-erro-imp             AS LOGICAL                   NO-UNDO.
DEF VAR c-linha                AS CHAR                      NO-UNDO.
DEF VAR c-nr-nota              AS CHAR FORMAT "x(07)"       NO-UNDO.
DEF VAR i-cont                 AS INTEGER                   NO-UNDO.
DEF VAR i-pos-arq              AS INTEGER                   NO-UNDO.
DEF VAR c-dt-venc              AS CHAR    FORMAT "x(10)"    NO-UNDO.
DEF VAR dt-vencto              AS DATE                      NO-UNDO.
DEF VAR d-tot-valor            LIKE doc-fisico.valor-mercad NO-UNDO.

DEF NEW GLOBAL SHARED VAR i-nro-docto-int038  AS INTEGER FORMAT "9999999"  NO-UNDO.

def var h-acomp            as handle                      no-undo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "").

run pi-seta-titulo in h-acomp (input "Processando nota de entrada.").


/**** elimina as tabelas *****/
FOR EACH tt2-rat-docum EXCLUSIVE-LOCK:
    DELETE tt2-rat-docum.
END.

FOR EACH tt2-item-doc-est EXCLUSIVE-LOCK:
    DELETE tt2-item-doc-est.
END.

FOR EACH tt2-dupli-apagar EXCLUSIVE-LOCK:
    DELETE tt2-dupli-apagar.
END.

FOR EACH tt2-dupli-imp EXCLUSIVE-LOCK:
    DELETE tt2-dupli-imp.
END.
/*****************************/

DEF BUFFER b7-docum-est FOR docum-est.

FOR EACH tt-nota WHERE
         tt-nota.situacao = 2 /* Liberado */
   BREAK BY tt-nota.nro-docto
         BY tt-nota.nat-operacao:
  
  IF LAST-OF(tt-nota.nat-operacao) 
  THEN DO:   
     
     EMPTY TEMP-TABLE tt-valida-erro.

     bloco:
     do transaction on error undo, NEXT:

         RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + tt-nota.nro-docto).

         for each tt-docum-est WHERE
                  int(tt-docum-est.nro-docto) = int(tt-nota.nro-docto) AND
                  tt-docum-est.serie-docto    = tt-nota.serie-nota     AND   
                  tt-docum-est.cod-emitente   = tt-nota.cod-emitente   AND
                  tt-docum-est.nat-operacao   = tt-nota.nat-operacao: 
            
            run inbo/boin090.p persistent set h-boin090.
    
            for first natur-oper where 
                      natur-oper.nat-operacao = tt-docum-est.nat-operacao no-lock: 
            end.        
            
            if avail natur-oper
            and natur-oper.tipo-compra = 4 then /* Material Agregado */
                assign tt-docum-est.mod-atual = 1.
            
            run pi-atualiza-docum-est.
            
            /* Fazer essa busca somente quando nota for de balanáo */ 

            IF natur-oper.imp-nota /* Gera nota faturamento */
            THEN DO:
               
               FOR FIRST ser-estab NO-LOCK WHERE
                         ser-estab.serie = tt-nota.serie-nota AND 
                         ser-estab.cod-estabel = tt-docum-est.cod-estabel:
               END.

               IF AVAIL ser-estab THEN
                  ASSIGN i-nro-docto-int038 = INT(ser-estab.nr-ult-nota) + 1.
            END.
            ELSE  
               ASSIGN i-nro-docto-int038 = INT(tt-nota.nro-docto).
                   
            FOR FIRST docum-est NO-LOCK WHERE
                     int(docum-est.nro-docto) =    i-nro-docto-int038     AND   
                      docum-est.serie           =  tt-nota.serie-nota     AND
                      docum-est.tipo-nota       =  tt-nota.tipo-nota      AND
                      docum-est.nat-operacao    =  tt-nota.nat-operacao   AND
                      docum-est.cod-emitente    =  tt-nota.cod-emitente  :
            END.
                       
            IF NOT AVAIL docum-est 
            THEN DO:
                  
                 CREATE tt-valida-param.
                 ASSIGN tt-valida-param.ErrorNumber      = 1 
                        tt-valida-param.ErrorDescription = "Documento n∆o gerado.".

                 RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).

                 UNDO bloco, LEAVE bloco.

            END.    
            ELSE DO:

                FOR EACH tt-item-doc-est WHERE
                      int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)        AND
                          tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto  AND
                          tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao AND
                          tt-item-doc-est.cod-emitente   = tt-nota.cod-emitente :
                      
                     ASSIGN tt-item-doc-est.nro-docto = docum-est.nro-docto.     
                END.
                    
                ASSIGN tt-nota.nro-docto       =  docum-est.nro-docto
                       tt-docum-est.nro-docto  =  docum-est.nro-docto.

            END.
                 /* ---------- NOTA DE RATEIO ---------- */
            if  avail natur-oper
            and natur-oper.nota-rateio then do:    
                for each tt-rat-docum of tt-docum-est NO-LOCK:
                    /* Estancia BO Rat-Docum, caso o mesma nío esteja dispon≠vel */
                    if  not valid-handle(h-boin366) then do:
                        run inbo/boin366.p persistent set h-boin366.
                        run openQueryStatic in h-boin366 ( "Main":U ).
                    end.
                    
                    run pi-atualiza-rat-docum.
                    
                end.
                
                /* Geraªío dos itens da nota de rateio */
                
                run pi-atualiza-item-rateio.
                
                /* Elimina Handle BO Rat-Docum */
                if  valid-handle(h-boin366) then 
                    run destroy in h-boin366.
            end.               
                  
                if  avail natur-oper and 
                          natur-oper.terceiros = NO  
                then DO:
                
                    IF NOT CAN-FIND(FIRST tt-item-doc-est WHERE
                                          int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)    AND
                                          tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto  AND
                                          tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao AND
                                          tt-item-doc-est.cod-emitente   = tt-nota.cod-emitente) THEN DO:
                        
                        CREATE tt-valida-param.
                        ASSIGN tt-valida-param.ErrorNumber      = 2 
                               tt-valida-param.ErrorDescription = "Documento nao possui itens.". 
    
                        RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).
                        
                    END.
                END.

                /* ---------- ITENS DA NOTA FISCAL ---------- */
                
                IF tt-docum-est.esp-docto <> 23 THEN DO:
                    for each tt-item-doc-est WHERE 
                             int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)   AND
                             tt-item-doc-est.serie-docto   = tt-docum-est.serie-docto  AND  
                             tt-item-doc-est.nat-operacao  = tt-docum-est.nat-operacao AND   
                             tt-item-doc-est.cod-emitente  = tt-nota.cod-emitente:
                        
                        /* Estancia BO Item-Doc-Est, caso o mesma nío esteja dispon≠vel */
                                
                        RUN pi-acompanhar IN h-acomp(INPUT "Nota/Item :" + tt-nota.nro-docto + " / " + tt-item-doc-est.it-codigo).

                        if  not valid-handle(h-boin176) then do:
                            run inbo/boin176.p persistent set h-boin176.
                            run openQueryStatic in h-boin176 ( "Main":U ).
                        end.
                                                        
                        run pi-atualiza-item-doc-est.
                        
                    end.
                END.

                if  valid-handle(h-boin176) then do:
        
                    if  l-terceiros = NO then DO:
                     
                        run setHandleDocumEst       in h-boin176 ( input h-boin090 ).
                        
                        run transferTotalItensNota  in h-boin176 ( input tt-docum-est.cod-emitente,
                                                                   input tt-docum-est.serie-docto,
                                                                   input tt-docum-est.nro-docto,
                                                                   input tt-docum-est.nat-operacao ).
                    end.
                
                    /* -------------- ACABADO ------------- */
                    if  avail natur-oper
                    and natur-oper.tipo-compra = 4 then do:
                        /* Estancia BO Rat-Docum, caso o mesma nío esteja dispon≠vel */
                        if  not valid-handle(h-boin223) then do:
                            run inbo/boin223.p persistent set h-boin223.
                            run openQueryStatic in h-boin223 ( "Main":U ).
                        end.
                        
                        run pi-atualiza-acabado.
                    end.
                    
                    /* Elimina Handle BO Item-Doc-Est, BO Saldo-Terc e BO Movto-Pend */                                                           
                    if  valid-handle(h-boin176) then 
                        run destroy in h-boin176.
                    
                    if  valid-handle(h-boin404) then 
                        run destroy in h-boin404.
        
                    if  valid-handle(h-boin223) then 
                        run destroy in h-boin223.
            
                end.            
               
                /*--- Procede com a atualiza∂∆o do documento ---*/
                IF NOT VALID-HANDLE(h-boin090) THEN
                    run inbo/boin090.p persistent set h-boin090.
                
                run openQueryStatic in h-boin090 ( "Main":U ).                       
    
                find first docum-est WHERE
                           int(docum-est.nro-docto) = int(tt-docum-est.nro-docto)  AND 
                           docum-est.nat-operacao   = tt-docum-est.nat-operacao AND 
                           docum-est.serie-docto    = tt-docum-est.serie-docto  AND
                           docum-est.cod-emitente   = tt-docum-est.cod-emitente  NO-LOCK no-error.
                                         
                IF NOT AVAIL docum-est THEN DO:
                    CREATE tt-valida-param.
                    ASSIGN tt-valida-param.ErrorNumber      = 2 
                           tt-valida-param.ErrorDescription = "Documento n∆o gerado."
                           tt-valida-param.ErrorType        = 'Erro'.
                    RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).
                END.
                ELSE DO: 
                    /*--- cria duplicata a partir do documento corrente ---*/
                    if avail natur-oper and 
                             natur-oper.emite-duplic
                    then do: 
                        
                       run rep/re9341.p (input rowid(docum-est), input no).

                       RUN pi-atualiza-duplicatas. 

                    END.
                END.
    
                assign TT-DOCUM-EST.r-rowid = rowid(docum-est).
    
                IF NOT CAN-FIND(FIRST tt-valida-erro WHERE
                                      tt-valida-erro.ErrorSubType = "Warning") 
                THEN DO:
                  /* run pi-atualizaDocumento. */
                END.
                ELSE DO:
                    
                END.

                FIND FIRST docum-est OF tt-docum-est NO-LOCK NO-ERROR.
                IF AVAIL docum-est 
                THEN DO:  
                     
                     FIND FIRST b-docum-est EXCLUSIVE-LOCK WHERE
                                rowid(b-docum-est) = ROWID(docum-est) NO-ERROR.
                     IF AVAIL b-docum-est THEN DO:

                       FIND FIRST int_ds_docto_xml NO-LOCK WHERE
                                  int(int_ds_docto_xml.nNF)     = int(b-docum-est.nro-docto) AND
                                  int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   AND
                                  int_ds_docto_xml.serie        = b-docum-est.serie NO-ERROR.
                       IF AVAIL int_ds_docto_xml THEN
                          ASSIGN substring(b-docum-est.char-1,93,60) = IF int_ds_docto_xml.chNfe = ? THEN "" ELSE int_ds_docto_xml.chNfe. 
                           
                       RELEASE b-docum-est.
                     END.  

                     FOR EACH tt-item-doc-est  WHERE
                              int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)   AND
                              tt-item-doc-est.serie-docto   = tt-docum-est.serie-docto  AND  
                              tt-item-doc-est.nat-operacao  = tt-docum-est.nat-operacao AND   
                              tt-item-doc-est.cod-emitente  = tt-nota.cod-emitente:
                         
                         DELETE tt-item-doc-est.
                     END.
    
                     FOR EACH item-doc-est OF docum-est ,
                           FIRST ITEM NO-LOCK WHERE
                                 ITEM.it-codigo = item-doc-est.it-codigo:
                          
                           FIND FIRST item-uni-estab NO-LOCK WHERE
                                      item-uni-estab.cod-estabel = docum-est.cod-estabel AND
                                      item-uni-estab.it-codigo   = item.it-codigo NO-ERROR.
                           IF AVAIL item-uni-estab THEN
                              ASSIGN item-doc-est.cod-depos   = item-uni-estab.deposito-pad
                                     item-doc-est.cod-localiz = item-uni-estab.cod-localiz. 
                           ELSE 
                              ASSIGN item-doc-est.cod-depos   = item.deposito-pad
                                     item-doc-est.cod-localiz = item.cod-localiz.  
                     
                           FOR EACH rat-lote WHERE
                                    int(rat-lote.nro-docto) = int(docum-est.nro-docto) AND
                                    rat-lote.serie-docto  = docum-est.serie-docto  AND
                                    rat-lote.cod-emitente = docum-est.cod-emitente AND
                                    rat-lote.sequencia    = item-doc-est.sequencia AND
                                    rat-lote.it-codigo    = item-doc-est.it-codigo:
                                      
                                IF AVAIL item-uni-estab THEN
                                   ASSIGN rat-lote.cod-depos   = item-uni-estab.deposito-pad
                                          rat-lote.cod-localiz = item-uni-estab.cod-localiz. 
                                ELSE 
                                   ASSIGN rat-lote.cod-depos   = item.deposito-pad
                                          rat-lote.cod-localiz = item.cod-localiz.
                           END.
                     END.

                     DELETE tt-docum-est.                    
                END.
    
                /**********************************************/
    
                /* Elimina Handle BO Dupli-Apagar */
                if  valid-handle(h-boin092) then 
                    run destroy in h-boin092.
            
                /* Elimina Handle BO Dupli-Imp */
                if  valid-handle(h-boin567) then 
                    run destroy in h-boin567.
            
                if  valid-handle(h-boin090) then 
                    run destroy in h-boin090.
    
         end. /* tt-docum-est */
         
         IF CAN-FIND(FIRST tt-valida-erro WHERE 
                           tt-valida-erro.ErrorSubType <> "warning":U) 
         THEN DO:
                    
            UNDO bloco, NEXT. 
            
         END.

     end. /* do transaction */
     
     FOR EACH tt-valida-erro WHERE 
              tt-valida-erro.ErrorSubType <> "warning" /* OR 
             (tt-valida-erro.ErrorSubType = "warning" AND
              (tt-valida-erro.ErrorNumber  = 18799 OR 
               tt-valida-erro.ErrorNumber  = 18796)) */ :

/*         MESSAGE tt-nota.nro-docto    "tt-nota.nro-docto"     SKIP */
/*             tt-nota.serie-nota   "tt-nota.serie-nota"    SKIP     */
/*             tt-nota.cod-emitente "tt-nota.cod-emitente"  SKIP     */
/*             tt-nota.nat-operacao "tt-nota.nat-operacao"  SKIP     */
/*             tt-nota.tipo-nota    "tt-nota.tipo-nota"     SKIP     */
/*             tt-valida-erro.ErrorNumber   "error number"  SKIP     */
/*             tt-valida-erro.ErrorDescription "error description"   */
/*             VIEW-AS ALERT-BOX.                                    */

         FIND FIRST int_ds_doc_erro NO-LOCK WHERE
                    int_ds_doc_erro.serie_docto  = tt-nota.serie-nota   AND 
                    int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente AND
                    int(int_ds_doc_erro.nro_docto) = int(tt-nota.nro-docto) AND
                    int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota    AND 
                    int_ds_doc_erro.descricao    = tt-valida-erro.ErrorDescription NO-ERROR.
         IF NOT AVAIL int_ds_doc_erro THEN DO:
            CREATE int_ds_doc_erro.
            ASSIGN int_ds_doc_erro.serie_docto  = tt-nota.serie-nota   
                   int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente 
                   int_ds_doc_erro.nro_docto    = tt-nota.nro-docto 
                   int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota
                   int_ds_doc_erro.tipo_erro    = tt-valida-erro.ErrorSubType 
                   int_ds_doc_erro.cod_erro     = tt-valida-erro.ErrorNumber   
                   int_ds_doc_erro.descricao    = tt-valida-erro.ErrorDescription.
         END.
     END.

  END. /* last-of */
  
END. /* tt-nota */

run pi-finalizar in h-acomp.

FOR EACH tt-nota WHERE
         tt-nota.situacao = 0 /* nao fazer */
   BREAK BY tt-nota.nro-docto
         BY tt-nota.nat-operacao:
    

  IF LAST-OF(tt-nota.nat-operacao) 
  THEN DO:   
    
     EMPTY TEMP-TABLE tt-docum-est.
     EMPTY TEMP-TABLE tt-item-doc-est.
     EMPTY TEMP-TABLE tt-valida-erro.
      
     bloco:
     do transaction on error undo, NEXT:
          
          FIND FIRST doc-fisico NO-LOCK WHERE
                     int(doc-fisico.nro-docto) = int(tt-nota.nro-docto) AND
                     doc-fisico.serie-docto    = tt-nota.serie-docum  AND
                     doc-fisico.cod-emitente   = tt-nota.cod-emitente AND
                     doc-fisico.tipo-nota      = 1 /* Compra */ NO-ERROR.
          IF NOT AVAIL doc-fisico THEN DO:
          
             CREATE tt-valida-param.
             ASSIGN tt-valida-param.ErrorNumber      = 4 
                    tt-valida-param.ErrorSubType     = "Error" 
                    tt-valida-param.ErrorDescription = "Documento fisico nao encontrado".
                   
             RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).

             EMPTY TEMP-TABLE tt-valida-param.
          END.
          ELSE DO:
              IF doc-fisico.situacao = 1 THEN DO:

                 CREATE tt-valida-param.
                 ASSIGN tt-valida-param.ErrorNumber      = 5 
                        tt-valida-param.ErrorSubType     = "Error"
                        tt-valida-param.ErrorDescription = "Situacao Documento fisico nao atualizado".
                   
                 RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).

                 EMPTY TEMP-TABLE tt-valida-param.
              END.
          END.

          FIND FIRST natur-oper NO-LOCK WHERE
                     natur-oper.nat-operacao = tt-nota.nat-operacao NO-ERROR.
          IF AVAIL natur-oper AND 
             AVAIL doc-fisico 
          THEN DO:
          
             IF NOT CAN-FIND(FIRST tt-valida-erro WHERE 
                                   tt-valida-erro.ErrorSubType <> "warning") 
             THEN DO:
                 ASSIGN d-tot-valor = 0.

                 FOR each it-doc-fisico EXCLUSIVE-LOCK where 
                          it-doc-fisico.serie-docto  = doc-fisico.serie-docto  and 
                          it-doc-fisico.cod-emitente = doc-fisico.cod-emitente and 
                          int(it-doc-fisico.nro-docto) = int(doc-fisico.nro-docto)  :
                           
                     ASSIGN it-doc-fisico.int-2 = doc-fisico.tipo-nota.

                     IF it-doc-fisico.char-2 = tt-nota.nat-operacao THEN
                        ASSIGN it-doc-fisico.tipo-nota = doc-fisico.tipo-nota
                               d-tot-valor   =  d-tot-valor + (it-doc-fisico.preco-unit[1] * it-doc-fisico.quantidade).
                     ELSE 
                        ASSIGN it-doc-fisico.tipo-nota = 20.
                 END. 
                 
                 FIND FIRST doc-fisico EXCLUSIVE-LOCK WHERE
                            doc-fisico.serie-docto  = tt-nota.serie-docum  AND                                               
                            doc-fisico.cod-emitente = tt-nota.cod-emitente AND                                               
                            int(doc-fisico.nro-docto) = int(tt-nota.nro-docto)    AND
                            doc-fisico.tipo-nota    = 1 /* Compra */  NO-ERROR.     
                 IF AVAIL doc-fisico THEN 
                    ASSIGN doc-fisico.valor-mercad = d-tot-valor.
                        
                 run rep/re2905.p (input rowid(doc-fisico),
                                   input tt-nota.nat-operacao,
                                   input 1,
                                   input TODAY,
                                   output r-docum-est,
                                   output l-erro-imp,
                                   output table tt-erro).
                 
                 IF NOT CAN-FIND(FIRST tt-erro WHERE
                                       tt-erro.mensagem <> "") 
                 THEN DO:

                    FOR each it-doc-fisico EXCLUSIVE-LOCK where 
                             it-doc-fisico.serie-docto    = doc-fisico.serie-docto  and 
                             it-doc-fisico.cod-emitente   = doc-fisico.cod-emitente and 
                             int(it-doc-fisico.nro-docto) = int(doc-fisico.nro-docto) :
                        
                            FOR EACH rat-lote where 
                                     rat-lote.cod-emitente   = doc-fisico.cod-emitente   and 
                                     rat-lote.serie-docto    = doc-fisico.serie-docto    and 
                                     int(rat-lote.nro-docto) = int(doc-fisico.nro-docto) and 
                                     rat-lote.sequencia      = it-doc-fisico.sequencia   AND 
                                     rat-lote.tipo-nota      = doc-fisico.tipo-nota exclusive-lock:
                                
                                 FIND FIRST docum-est NO-LOCK where
                                            docum-est.cod-emitente = doc-fisico.cod-emitente AND
                                            docum-est.serie-docto  = doc-fisico.serie-docto  AND
                                            int(docum-est.nro-docto) = int(doc-fisico.nro-docto)  AND
                                            docum-est.nat-operacao = it-doc-fisico.char-2 NO-ERROR.
                                 IF NOT AVAIL docum-est THEN
                                    assign rat-lote.nat-operacao = " ".
                            END.
                        
                            ASSIGN it-doc-fisico.tipo-nota = it-doc-fisico.int-2
                                   it-doc-fisico.int-2     = 0.
                    END.  
                    
                    FIND FIRST doc-fisico EXCLUSIVE-LOCK WHERE
                               doc-fisico.serie-docto  = tt-nota.serie-docum  AND                                               
                               doc-fisico.cod-emitente = tt-nota.cod-emitente AND                                               
                               int(doc-fisico.nro-docto) = int(tt-nota.nro-docto)  AND
                               doc-fisico.tipo-nota    = 1 /* Compra */  NO-ERROR.     
                    IF AVAIL doc-fisico THEN DO:         
                       IF LAST(tt-nota.nat-operacao) THEN
                          ASSIGN doc-fisico.situacao = 3.
                       ELSE 
                          ASSIGN doc-fisico.situacao = 2.  
                    END.
                    
                    RELEASE doc-fisico.
                    
                    FIND FIRST docum-est EXCLUSIVE-LOCK WHERE
                               rowid(docum-est) = r-docum-est NO-ERROR.
                    IF AVAIL docum-est  THEN DO:
                       
                       FIND FIRST int_ds_docto_xml NO-LOCK WHERE
                                  int(int_ds_docto_xml.nNF)     = int(docum-est.nro-docto)  AND
                                  int_ds_docto_xml.cod_emitente = docum-est.cod-emitente AND
                                  int_ds_docto_xml.serie        = docum-est.serie NO-ERROR.
                       IF AVAIL int_ds_docto_xml THEN
                          ASSIGN substring(docum-est.char-1,93,60) = IF int_ds_docto_xml.chNfe = ? THEN "" ELSE int_ds_docto_xml.chNfe. 
                       
                       /* RUN pi-atualiza-duplicatas. */
    
                    END.
    
                    RELEASE docum-est.
    
                    CREATE tt-docum-est.    
                    assign TT-DOCUM-EST.r-rowid = r-docum-est.
                    
                    /* run pi-atualizaDocumento. */
    
                 END.
                 ELSE DO:
                    FOR EACH tt-erro:
                        
                        CREATE tt-valida-param.
                        ASSIGN tt-valida-param.ErrorNumber      = tt-erro.cd-erro 
                               tt-valida-param.ErrorDescription = tt-erro.mensagem.
                        
                        RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).
    
                        EMPTY TEMP-TABLE tt-valida-param.
                    END.
                 END.
             END.
          END.

          IF CAN-FIND(FIRST tt-valida-erro WHERE 
                            tt-valida-erro.ErrorSubType <> "warning") 
          THEN DO: 
           
              UNDO bloco, NEXT. 
              
          END.

     end. /* do transaction */
      

     FOR EACH tt-valida-erro WHERE 
              tt-valida-erro.ErrorSubType <> "warning" OR 
             (tt-valida-erro.ErrorSubType = "warning" AND
              (tt-valida-erro.ErrorNumber  = 18799 OR 
               tt-valida-erro.ErrorNumber  = 18796)) :
         
         FIND FIRST int_ds_doc_erro NO-LOCK WHERE
                    int_ds_doc_erro.serie_docto  = tt-nota.serie-nota   AND 
                    int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente AND
                    int(int_ds_doc_erro.nro_docto) = int(tt-nota.nro-docto)  AND 
                    int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota    AND
                    int_ds_doc_erro.descricao    = tt-valida-erro.ErrorDescription NO-ERROR.
         IF NOT AVAIL int_ds_doc_erro THEN DO:
           

            CREATE int_ds_doc_erro.
            ASSIGN int_ds_doc_erro.serie_docto  = tt-nota.serie-nota   
                   int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente 
                   int_ds_doc_erro.nro_docto    = tt-nota.nro-docto 
                   int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota     
                   int_ds_doc_erro.tipo_erro    = tt-valida-erro.ErrorSubType 
                   int_ds_doc_erro.cod_erro     = tt-valida-erro.ErrorNumber       
                   int_ds_doc_erro.descricao    = tt-valida-erro.ErrorDescription.
         END.
     END.

  END. /* last-of */
  
END. /* tt-nota */



PROCEDURE pi-atualiza-duplicatas:
   
   FOR FIRST int_ds_docto_xml WHERE
         int(int_ds_docto_xml.nnf)  = int(docum-est.nro-docto) AND 
             int_ds_docto_xml.serie = docum-est.serie-docto    AND 
             int_ds_docto_xml.cod_emitente = docum-est.cod-emitente AND
             int_ds_docto_xml.tipo_nota  = 1 AND
            (int_ds_docto_xml.tipo_docto = 0 OR
             int_ds_docto_xml.tipo_docto = 4): 
   END.

   IF AVAIL int_ds_docto_xml 
   THEN DO:
   
       for each dupli-apagar where 
                dupli-apagar.serie-docto  = docum-est.serie-docto  and
                dupli-apagar.nro-docto    = docum-est.nro-docto    and     
                dupli-apagar.cod-emitente = docum-est.cod-emitente and 
                dupli-apagar.nat-operacao = docum-est.nat-operacao : 
                
           ASSIGN dupli-apagar.dt-trans = int_ds_docto_xml.dt_trans. 

       END.                
   END.

END.

PROCEDURE PI-ATUALIZA-DOCUM-EST :

    /* Abertura de Query */       

    run openQueryStatic in h-boin090 ( "Main":U ).

    /* Transfere TT-DOCUM-EST para BO */
    run setRecord in h-boin090 ( input table tt-docum-est ).

    /* Determina Defaults da Nota Fiscal */
    /*run setDefaultsNota in h-boin090.*/
    
    /* Cria DOCUM-EST */    
    run createRecord in h-boin090.
    
    if return-value = "NOK":U then  DO:
        run pi-gera-erros ( input h-boin090 ).
    END.

END PROCEDURE.

/* --------------------------------- */

PROCEDURE PI-ATUALIZA-RAT-DOCUM :

    /* Limpa Temp-Table de Itens */
    run emptyRowObject in h-boin366.
           
    for each tt2-rat-docum EXCLUSIVE-LOCK:
        delete tt2-rat-docum.
    end.               

    /* Como a BO somente trabalha com 1 registro, o conteúdo da temp-table 
       ≤ transferido para outra temp-table idºntica */

    create tt2-rat-docum.
    buffer-copy tt-rat-docum to tt2-rat-docum.
    
    /* Transfere TT-RAT-DOCUM para BO */
    run setRecord in h-boin366 ( input table tt2-rat-docum ).

    /* Cria RAT-DOCUM */    
    run createRecord in h-boin366.

    if  return-value = "NOK":U THEN DO:
        run pi-gera-erros ( input h-boin366 ).
    END.

END PROCEDURE.           

/* --------------------------------- */

PROCEDURE PI-ATUALIZA-ITEM-DOC-EST :
    
    /* Atualiza Funªío FIFO nas Ordens de Compra */
    if  ( tt-item-doc-est.num-pedido <> 0 
    or    tt-item-doc-est.numero-ordem <> 0 )
    and tt-item-doc-est.parcela = 0 then 
        assign tt-item-doc-est.log-1 = YES.
      
    /* Acessa Chave do Documento */
    run linktoDocumEst in h-boin176 ( input h-boin090 ).
    
    /* Limpa Temp-Table de Itens */
    run emptyRowObject in h-boin176.
           
    for each tt2-item-doc-est EXCLUSIVE-LOCK:
        delete tt2-item-doc-est.
    end.               

    /* Como a BO somente trabalha com 1 registro, o conteúdo da temp-table 
       ≤ transferido para outra temp-table idºntica */
    
    create tt2-item-doc-est.
    buffer-copy tt-item-doc-est to tt2-item-doc-est.
    
    /*Se emite duplicata atualiza a conta cont†bil.*/
    /*IF natur-oper.emite-duplic THEN
        ASSIGN tt2-item-doc-est.conta-contabil = gg-mov-contr.conta-fertilizante.    */     

    /* Transfere TT-ITEM-DOC-EST para BO */
    run setRecord in h-boin176 ( input table tt2-item-doc-est ).    
      
    
    run goToKey IN h-boin176 (INPUT tt2-item-doc-est.serie-docto  ,
                              INPUT tt2-item-doc-est.nro-docto    ,
                              INPUT tt2-item-doc-est.cod-emitente ,
                              INPUT tt2-item-doc-est.nat-operacao ,
                              INPUT tt2-item-doc-est.sequencia).  
    
    RUN validateRecord IN h-boin176(INPUT "create").
    
    /* Cria ITEM-DOC-EST */
    run createRecord in h-boin176.     

    run pi-gera-erros (input h-boin176).
    
    
END PROCEDURE.

/* --------------------------------- */

PROCEDURE PI-ATUALIZA-DUPLI-APAGAR :

    /* Posiciona Documento/Usuario */
    run findDocumEst in h-boin092 ( input tt-docum-est.cod-emitente,
                                    input tt-docum-est.serie-docto,
                                    input tt-docum-est.nro-docto,
                                    input tt-docum-est.nat-operacao ).

    run findUsuario in h-boin092 ( input tt-docum-est.usuario ).

    /* Limpa Temp-Table de Itens */
    run emptyRowObject in h-boin092.
           
    for each tt2-dupli-apagar EXCLUSIVE-LOCK:
        delete tt2-dupli-apagar.
    end.               

    /* Como a BO somente trabalha com 1 registro, o conteúdo da temp-table 
       ≤ transferido para outra temp-table idºntica */

    create tt2-dupli-apagar.
    buffer-copy tt-dupli-apagar to tt2-dupli-apagar.

    /* Transfere TT-DUPLI-APAGAR para BO */
    run setRecord in h-boin092 ( input table tt2-dupli-apagar ).

    /* Seta Default Tipo Despesa */
    run setDefaultTpDespesa in h-boin092.
    
    /* Seta Default Esp≤cie */
    /*run setDefaultCodEsp in h-boin092.*/

    /* Cria DUPLI-APAGAR */    
    run createRecord in h-boin092.

    if  return-value = "NOK":U THEN DO:
        run pi-gera-erros ( input h-boin092 ).
    END.
             

END PROCEDURE.


/* --------------------------------- */

PROCEDURE PI-ATUALIZA-ITEM-RATEIO :

    /* Acessa Chave do Documento */
    run linktoDocumEst in h-boin366 ( input h-boin090 ).
    
    /* Acessa natureza de operacao */
    run findNaturOper in h-boin366 ( tt-docum-est.nat-operacao ).
    
    /* Cria tt-imposto */
    run getTTImposto in h-boin366 ( output table tt-imposto ).

    /* Cria itens da nota */
    run createRateio in h-boin366.

    if  return-value = "NOK":U THEN DO:
        run pi-gera-erros ( input h-boin366 ).
    END.

END PROCEDURE.

/* --------------------------------- */

PROCEDURE PI-ATUALIZA-ACABADO :

    run findDocumento in h-boin223 ( tt-docum-est.cod-emitente,
                                     tt-docum-est.serie-docto,
                                     tt-docum-est.nro-docto,
                                     tt-docum-est.nat-operacao ).

    run createAcabadoByOP in h-boin223.                        

    if  return-value = "NOK":U THEN DO:
        run pi-gera-erros ( input h-boin223 ).
    END.

END PROCEDURE.

/* --------------------------------- */

PROCEDURE pi-atualizaDocumento:

/*------------------------------------------------------------------------------
*     Notes: Faz a atualizaá∆o do documento com base no TT-DOCUM-EST
*
 ------------------------------------------------------------------------------*/

    for each tt-digita:
        delete tt-digita.
    end.

    for each tt-param:
        delete tt-param.
    end.
    
    if  not avail TT-DOCUM-EST then
        return "NOK":U.
        
    find first usuar_mestre no-lock
        where usuar_mestre.cod_usuario = "" /* c-seg-usuario */ no-error.
    
    create tt-param.
    assign tt-param.usuario         =  c-seg-usuario 
           tt-param.destino         = 2
           tt-param.data-exec       = today
           tt-param.hora-exec       = time
           tt-param.arquivo         = if avail usuar_mestre and usuar_mestre.nom_dir_spool <> "" then 
                                      (usuar_mestre.nom_dir_spool + "/")
                                      else session:temp-directory
           tt-param.arquivo         = tt-param.arquivo + "RE1005" + ".txt":U.
    
    for each tt-raw-digita:
        delete tt-raw-digita.
    end.

    create tt-digita.
    assign tt-digita.r-docum-est = TT-DOCUM-EST.r-rowid.
           r-docum-est-transf    = TT-DOCUM-EST.r-rowid.
    
    raw-transfer tt-param  to raw-param.

    for each tt-digita:
        create tt-raw-digita.
        raw-transfer tt-digita to tt-raw-digita.raw-digita.
    end.
    
    if  session:set-wait-state("GENERAL":U) THEN
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita). 
    
    FIND FIRST b-docum-est no-lock
        WHERE ROWID(b-docum-est) = r-docum-est-transf NO-ERROR.
    IF NOT AVAIL b-docum-est THEN DO:

           CREATE tt-valida-param.
           ASSIGN tt-valida-param.ErrorNumber      = 1 
                  tt-valida-param.ErrorDescription = "Nota n∆o atualizada no recebimento - docum-est"
                  tt-valida-param.ErrorHelp        = "Nota n∆o atualizada no recebimento - docum-est".

           RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).
           return "NOK":U.
    END.  
    
    
    INPUT FROM value(tt-param.arquivo) CONVERT TARGET "iso8859-1".
    
        REPEAT:
           IMPORT UNFORMATTED c-linha.
            
           CREATE tt-arquivo-erro.
           ASSIGN tt-arquivo-erro.c-linha = c-linha.
        
        END.

        FOR EACH tt-arquivo-erro WHERE
                 LENGTH(tt-arquivo-erro.c-linha) > 0:
        
            IF tt-arquivo-erro.c-linha BEGINS "-" THEN NEXT. 
        
            ASSIGN c-nr-nota  = "".
               
            DO i-cont = 1 TO 7:    
        
               DO i-pos-arq = 0 TO 10:
        
                  IF SUBSTRING(SUBSTRING(tt-arquivo-erro.c-linha,7,7),i-cont,1) = STRING(i-pos-arq) THEN 
                     ASSIGN c-nr-nota = c-nr-nota + STRING(i-pos-arq).
        
               END.
        
            END.
        
            IF c-nr-nota = "" AND 
               SUBSTRING(tt-arquivo-erro.c-linha,53,90) = "" THEN NEXT.
            
            FIND LAST tt-erro-nota NO-ERROR.

            IF c-nr-nota <> "" THEN DO:
               CREATE tt-erro-nota.
               ASSIGN tt-erro-nota.serie         = SUBSTRING(tt-arquivo-erro.c-linha,1,3)
                      tt-erro-nota.nro-docto     = c-nr-nota
                      tt-erro-nota.cod-emitente  = int(SUBSTRING(tt-arquivo-erro.c-linha,24,9)) 
                      tt-erro-nota.cod-erro      = int(SUBSTRING(tt-arquivo-erro.c-linha,44,6)).
            END.

            IF AVAIL tt-erro-nota THEN
               ASSIGN tt-erro-nota.descricao  = tt-erro-nota.descricao + SUBSTRING(tt-arquivo-erro.c-linha,53,90).
        END.

        FOR EACH tt-erro-nota WHERE
                 tt-erro-nota.serie         =  b-docum-est.serie        AND
                 int(tt-erro-nota.nro-docto)  =  int(c-nr-nota)         AND          
                 tt-erro-nota.cod-emitente  =  b-docum-est.cod-emitente AND                    
                  tt-erro-nota.cod-erro <> 4070 AND
                  tt-erro-nota.cod-erro <> 11010
            BREAK BY tt-erro-nota.cod-erro:
          
            EMPTY TEMP-TABLE tt-valida-param.

            CREATE tt-valida-param.
            ASSIGN tt-valida-param.ErrorNumber      = tt-erro-nota.cod-erro
                   tt-valida-param.ErrorDescription = tt-erro-nota.descricao.
                    
            RUN pi-tt-valida-erro(INPUT TABLE tt-valida-param).

        END.
        
        {include/i-rptrm.i} 
        
        if session:set-wait-state("":U) then.


 
END PROCEDURE.


/* --------------------------------- */

PROCEDURE PI-GERA-ERROS :
        
    def input param piHandle    as handle   no-undo.
            
    run getRowErrors in piHandle ( output table RowErrors ).
    
    for each RowErrors NO-LOCK where 
             RowErrors.ErrorSubType = "ERROR":U OR 
            (RowErrors.ErrorSubType = "Warning":U AND
             (RowErrors.ErrorNumber  = 18799 OR 
              RowErrors.ErrorNumber  = 18796)):
           
        find first tt-valida-erro
             where tt-valida-erro.ErrorNumber       = RowErrors.ErrorNumber
               and tt-valida-erro.ErrorDescription  = RowErrors.ErrorDescription no-lock no-error.
        if  not avail tt-valida-erro then do:

            create tt-valida-erro.
            BUFFER-COPY RowErrors TO tt-valida-erro.
             
            IF AVAIL tt-item-doc-est THEN
               ASSIGN tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription + "."                 + CHR(10) + 
                                                 "Seq:"    + string(tt-item-doc-est.sequencia)  + CHR(10) + 
                                                 "Item:"   + tt-item-doc-est.it-codigo          + CHR(10) +
                                                 "Pedido:" + STRING(tt-item-doc-est.num-pedido) + CHR(10) + 
                                                 "Ordem:"  + STRING(tt-item-doc-est.numero-ordem).
           ELSE 
              ASSIGN tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription           + CHR(10) +  
                                                "Nota : "   + tt-nota.nro-docto    + CHR(10) +  
                                                "Serie: "   + tt-nota.serie-docum  + CHR(10) +
                                                "Natureza:" + tt-nota.nat-operacao + chr(10).
        end.    
    end.        

END PROCEDURE.

PROCEDURE pi-tt-valida-erro:
    DEF INPUT PARAM TABLE FOR tt-valida-param.

    CREATE tt-valida-erro.
    BUFFER-COPY tt-valida-param TO tt-valida-erro.
    
    ASSIGN tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription           + CHR(10) +  
                                      "Nota : "   + tt-nota.nro-docto    + CHR(10) +  
                                      "Serie: "   + tt-nota.serie-docum  + CHR(10) +
                                      "Natureza:" + tt-nota.nat-operacao + chr(10).
END.



