/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0301RP 2.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}

/***Defini‡äes***/
def var c-sel        as char format "x(10)"       no-undo.
def var c-imp        as char format "x(10)"       no-undo.
def var c-des        as char format "x(10)"       no-undo.
def var c-saida      as char format "x(40)"       no-undo.
def var h-acomp      as handle                    no-undo.
def var c-subs-trib  as char                      no-undo.
DEF VAR c-tipo-nota  AS CHAR                      NO-UNDO.
DEF VAR c-tipo       AS CHAR                      NO-UNDO.
DEF VAR c-data       AS CHARACTER                 NO-UNDO.
DEF VAR dt-per-ini   AS DATE  FORMAT "99/99/9999" NO-UNDO.
DEF VAR dt-per-fim   AS DATE  FORMAT "99/99/9999" NO-UNDO.
DEF VAR d-tot-cred   LIKE it-doc-fisc.vl-icms-it  NO-UNDO.
DEF VAR d-quant-rec  LIKE it-doc-fisc.quantidade  NO-UNDO.
DEF VAR d-quant-vend LIKE it-doc-fisc.quantidade  NO-UNDO.
DEF VAR d-sdo-ajust  AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" NO-UNDO.
        
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field estab-ini        as char format "x(03)"
    field estab-fim        as char format "x(030)"
    field per-ini          as DATE FORMAT "99/99/9999"
    field per-fim          as DATE FORMAT "99/99/9999".

def temp-table tt-digita
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique
        ordem. 

def temp-table tt-raw-digita                   
    field raw-digita as raw.

DEF TEMP-TABLE tt-doc-fiscal NO-UNDO LIKE doc-fiscal 
    FIELD tipo-nota          AS INTEGER
    FIELD tipo-apuracao      AS INTEGER 
    FIELD estab              AS CHARACTER
    FIELD l-valor            AS LOGICAL /* Variavel que define se o documento possui valor de pis ou cofins */
    FIELD cfop-ini           AS CHAR FORMAT "x(01)"
    FIELD cd-trib-pis        AS CHAR FORMAT "x(01)"
    FIELD cd-trib-cofins     AS CHAR FORMAT "x(01)"
    INDEX selecao estab 
                  serie       
                  nr-doc-fis 
                  cod-emitente    
                  nat-operacao  
                  tipo-apuracao.

DEF TEMP-TABLE tt-it-doc-fiscal LIKE it-doc-fisc
FIELD desc-item AS CHAR FORMAT "x(60)".

DEF TEMP-TABLE tt-periodo
FIELD cod-estabel LIKE estabelec.cod-estabel
FIELD dt-ini      LIKE apur-imposto.dt-apur-ini 
FIELD dt-fim      LIKE apur-imposto.dt-apur-fim. 
                         

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

find first param-global no-lock no-error.

find first tt-param NO-LOCK NO-ERROR.

{include/i-rpvar.i}

assign c-titulo-relat = "Relat¢rio Cr‚dito ICMS Cesta B sica"
       c-sistema      = "Espec¡fico"
       c-empresa      = param-global.grupo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Imprimindo").
                        
RUN pi-seleciona-doctos.

/* {include/i-rpcab.i} */

{include/i-rpc255.i}
{include/i-rpout.i}

view frame f-cabec-255.
view frame f-rodape-255.
    
    
    ASSIGN d-sdo-ajust = 0.
     
    FOR EACH tt-doc-fiscal WHERE 
             tt-doc-fiscal.tipo-nota > 0 /* 1 Entrada  2 - Saida */,  
        first natur-oper where
              natur-oper.nat-operacao = tt-doc-fiscal.nat-operacao no-lock,
        each tt-it-doc-fiscal where 
             tt-it-doc-fiscal.cod-estabel  = tt-doc-fiscal.cod-estabel  and 
             tt-it-doc-fiscal.serie        = tt-doc-fiscal.serie        and 
             tt-it-doc-fiscal.nr-doc-fis   = tt-doc-fiscal.nr-doc-fis   and 
             tt-it-doc-fiscal.cod-emitente = tt-doc-fiscal.cod-emitente NO-LOCK
        break BY tt-doc-fiscal.cod-estabel
              BY tt-doc-fiscal.tipo-nota
              BY tt-it-doc-fiscal.it-codigo
              BY tt-doc-fiscal.dt-docto:

        IF FIRST-OF(tt-doc-fiscal.tipo-nota) 
        THEN DO:
           IF tt-doc-fiscal.tipo-nota = 1 THEN
              ASSIGN c-tipo-nota = "Entradas"
                     c-tipo      = "Entrada".
           ELSE 
              ASSIGN c-tipo-nota = "Sa¡das"
                     c-tipo      = "Faturamento".

           PUT SKIP(1)
               c-tipo-nota
               SKIP(1).
        END.

        ASSIGN d-quant-rec  = 0
               d-quant-vend = 0.

        IF tt-doc-fiscal.tipo-nota = 1 THEN
           ASSIGN d-quant-rec = tt-it-doc-fiscal.quantidade
                  d-sdo-ajust =  d-sdo-ajust + (tt-it-doc-fiscal.vl-icms-it * tt-it-doc-fiscal.quantidade).
         ELSE
           ASSIGN d-quant-vend = tt-it-doc-fiscal.quantidade
                  d-sdo-ajust  = d-sdo-ajust - (tt-it-doc-fiscal.vl-icms-it * tt-it-doc-fiscal.quantidade).

        DISP tt-doc-fiscal.cod-estab                                      column-label  "Estab."
             tt-doc-fiscal.dt-docto                                       column-label  "Data"
             c-tipo                     FORMAT "x(11)"                    column-label  "Tipo"
             tt-doc-fiscal.nr-doc-fis   FORMAT "x(08)"                    column-label  "Docto"
             tt-it-doc-fiscal.it-codigo                                   column-label  "Produto"
             tt-it-doc-fiscal.desc-item FORMAT "x(30)"                    column-label  "Descri‡Æo"
             "1"                                                          column-label  "Custo Unt"
             d-quant-rec                                                  COLUMN-LABEL  "Qtde Receb"
             d-quant-vend                                                 column-label  "Quant. Vendida"
             tt-it-doc-fiscal.vl-icms-it                                  column-label  "Cr‚dito ICMS unt. compra"
             tt-it-doc-fiscal.vl-icms-it * tt-it-doc-fiscal.quantidade    column-label  "Estorno de cr‚dito"
             WITH  STREAM-IO WIDTH 333 DOWN FRAME f-item.
        DOWN WITH FRAME f-item.

        ASSIGN d-tot-cred = d-tot-cred + (tt-it-doc-fiscal.vl-icms-it * tt-it-doc-fiscal.quantidade).
                         
        IF LAST-OF(tt-doc-fiscal.tipo-nota) 
        THEN DO:
           PUT  SKIP(1)
                "Total"    AT 153
                d-tot-cred TO 178 
                SKIP(1).

           ASSIGN d-tot-cred = 0.

        END.
        
        ASSIGN c-data = "01" + "/" + string(MONTH(tt-doc-fiscal.dt-docto)) + "/" + string(year(tt-doc-fiscal.dt-docto))
               dt-per-ini = date(c-data) 
               dt-per-fim =  dt-per-ini + 45
               c-data     = "01" + "/" + STRING(MONTH(dt-per-fim)) + "/" + STRING(YEAR(dt-per-fim))
               dt-per-fim = DATE(c-data) - 1.  

        FIND FIRST tt-periodo WHERE
                   tt-periodo.cod-estabel = tt-doc-fiscal.cod-estabel AND 
                   tt-periodo.dt-ini      = dt-per-ini                  AND
                   tt-periodo.dt-fim      = dt-per-fim   NO-ERROR.
        IF NOT AVAIL tt-periodo THEN DO:
            CREATE tt-periodo.
            ASSIGN tt-periodo.cod-estabel = tt-doc-fiscal.cod-estabel 
                   tt-periodo.dt-ini      = dt-per-ini                  
                   tt-periodo.dt-fim      = dt-per-fim.
        END.
    
        IF LAST-OF(tt-doc-fiscal.cod-estabel) 
        THEN DO:
           PUT  SKIP(1)
                "Saldo a Ajustar"    AT 143
                d-sdo-ajust TO 178 
                SKIP(1).
              
           FOR EACH tt-periodo WHERE
                    tt-periodo.cod-estabel = tt-doc-fiscal.cod-estabel,
               EACH apur-imposto NO-LOCK WHERE
                    apur-imposto.cod-estabel = tt-doc-fiscal.cod-estabel AND 
                    apur-imposto.tp-imposto  = 1 AND /* ICMS */ 
                    apur-imposto.dt-apur-ini = tt-periodo.dt-ini AND
                    apur-imposto.dt-apur-fim = tt-periodo.dt-fim ,
               EACH imp-valor OF apur-imposto NO-LOCK WHERE
                    imp-valor.cod-lanc = 003 /* Estorno de Cr‚ditos */
               BREAK BY apur-imposto.dt-apur-fim:

               IF FIRST(apur-imposto.dt-apur-fim) 
               THEN DO:
                 PUT "Ajustes" AT 01 SKIP.
               END.  

               IF LAST-OF(apur-imposto.dt-apur-fim) 
               THEN DO:
                 ASSIGN d-sdo-ajust = d-sdo-ajust - imp-valor.vl-lancamento.
                        
                 DISP tt-periodo.cod-estabel   AT 01
                      apur-imposto.dt-apur-fim AT 08
                      "Ajuste" 
                      imp-valor.vl-lancamento TO 178
                      WITH  NO-LABELS STREAM-IO WIDTH 333 DOWN FRAME f-ajustes.
                    DOWN WITH FRAME f-ajustes.
               END.

           END.
                        
           PUT  SKIP(1)
                "Saldo por Ajustar" AT 01
                d-sdo-ajust TO 178 
                SKIP(1).
                   
        END.


    
    END.

{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.

PROCEDURE pi-seleciona-doctos:
    
    DEF VAR l-cesta-basica AS LOGICAL  NO-UNDO. 
    
   EMPTY TEMP-TABLE tt-doc-fiscal.
   EMPTY TEMP-TABLE tt-it-doc-fiscal.
   EMPTY TEMP-TABLE tt-periodo.
         
   for each doc-fiscal use-index ch-notas where 
            doc-fiscal.dt-docto    >= tt-param.per-ini   and 
            doc-fiscal.dt-docto    <= tt-param.per-fim   and     
            doc-fiscal.cod-estabel >= tt-param.estab-ini and
            doc-fiscal.cod-estabel <= tt-param.estab-fim AND  
            doc-fiscal.ind-sit-doc <> 2 NO-LOCK, /* cancelado */
    first natur-oper where 
          natur-oper.nat-operacao = doc-fiscal.nat-operacao no-lock:
       
    /* VERIFICA SE POSSUI Itens da cesta B sica */     

    RUN pi-acompanhar IN h-acomp (INPUT " Nota : " + doc-fiscal.nr-doc-fis). 
         
    ASSIGN l-cesta-basica = NO.

    FOR EACH it-doc-fisc NO-LOCK WHERE 
             it-doc-fisc.cod-estabel  = doc-fiscal.cod-estabel  AND
             it-doc-fisc.nat-operacao = doc-fiscal.nat-operacao AND 
             it-doc-fisc.cod-emitente = doc-fiscal.cod-emitente AND 
             it-doc-fisc.serie        = doc-fiscal.serie        AND
             it-doc-fisc.nr-doc-fis   = doc-fiscal.nr-doc-fis,
       FIRST ITEM NO-LOCK WHERE
             ITEM.it-codigo = it-doc-fisc.it-codigo,
        EACH it-carac-tec OF ITEM NO-LOCK WHERE
             it-carac-tec.observacao = "S-Sim"  /* 3M */ ,
        EACH comp-folh OF it-carac-tec NO-LOCK WHERE
             comp-folh.log-estado = YES AND 
             comp-folh.seq-de-impres = 370: /* 40 */ 
           
        RUN pi-acompanhar IN h-acomp (INPUT " Item : " + it-doc-fisc.it-codigo).

        FIND FIRST tt-doc-fiscal                                           
            where  tt-doc-fiscal.estab         = doc-fiscal.cod-estabel  
            and    tt-doc-fiscal.serie         = doc-fiscal.serie        
            and    tt-doc-fiscal.nr-doc-fis    = doc-fiscal.nr-doc-fis   
            and    tt-doc-fiscal.cod-emitente  = doc-fiscal.cod-emitente 
            and    tt-doc-fiscal.nat-operacao  = doc-fiscal.nat-operacao NO-LOCK NO-ERROR.
      
        IF NOT AVAIL tt-doc-fiscal 
        THEN DO:
            CREATE tt-doc-fiscal.
            BUFFER-COPY doc-fiscal TO tt-doc-fiscal.
            ASSIGN tt-doc-fiscal.cfop-ini      = trim(substring(doc-fiscal.cod-cfop,1,1)).
            
            RUN pi-tipo-nota.

        END.

        CREATE tt-it-doc-fiscal.
        BUFFER-COPY it-doc-fisc TO tt-it-doc-fiscal.
        ASSIGN tt-it-doc-fiscal.desc-item = ITEM.desc-item.
        
    END.
  
END. /* FOR EACH doc-fiscal */

END PROCEDURE.

PROCEDURE pi-tipo-nota:

    IF int(tt-doc-fiscal.cfop-ini) < 4 THEN 
       ASSIGN tt-doc-fiscal.tipo-nota = 1. /* Entrada */
    ELSE 
       ASSIGN tt-doc-fiscal.tipo-nota = 2. /* Sa¡da */ 
  
    /***** Verifica documentos de entrada/servi‡o  ***/

    if  tt-doc-fiscal.tipo-nota = 1 
    then do: /* entrada */

        if (doc-fiscal.tipo-nat <> 1 and 
            doc-fiscal.tipo-nat <> 3) 
        then 
            ASSIGN tt-doc-fiscal.tipo-nota = 0. 

        IF  doc-fiscal.tipo-nat = 3 AND 
            natur-oper.tipo    <> 1 
        THEN 
            ASSIGN tt-doc-fiscal.tipo-nota = 0.
    end.
    else do: /*** Verifica documentos de Sa¡da ***/
        if  doc-fiscal.tipo-nat <> 2 and 
            doc-fiscal.tipo-nat <> 3 
        then 
            ASSIGN tt-doc-fiscal.tipo-nota = 0. 

        IF doc-fiscal.tipo-nat  = 3 
         THEN DO:
           IF natur-oper.tipo <> 2 and 
              natur-oper.tipo <> 3 
           THEN
              ASSIGN tt-doc-fiscal.tipo-nota = 0.  
        END.
    end.  


END PROCEDURE.
