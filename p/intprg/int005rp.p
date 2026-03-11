/*
/******************************************************************************
**
**       PROGRAMA: int005rp.p
**
**       DATA....: 03/2016
**
**       OBJETIVO: Atualizar saldo estoque para comparar diferen‡as no estoque 
**                 entre Sysfarma e Datasul 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
{include/i-prgvrs.i int005RP 2.06.00.001}  
{include/i_fnctrad.i}

{include/i-rpvar.i}
{include/i-rpcab.i}
 
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD c-cod-estab-ini  LIKE int-ds-saldo-totvs.cod-estab
    FIELD c-cod-estab-fin  LIKE int-ds-saldo-totvs.cod-estab.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.


def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.  
    
DEF VAR l-lote AS LOGICAL INITIAL NO NO-UNDO.
DEF VAR d-vl-cvm  LIKE int-ds-saldo-estoq.valor-cmv NO-UNDO.
DEF VAR h-acomp   AS HANDLE       NO-UNDO.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "Int005rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

FIND FIRST tt-param NO-ERROR.
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integra‡Æo_Saldo * L}
run pi-inicializar in h-acomp (input return-value).

RETURN "OK".

FOR EACH int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
         int-ds-saldo-totvs.cod-estab >= tt-param.c-cod-estab-ini AND 
         int-ds-saldo-totvs.cod-estab <= tt-param.c-cod-estab-fin :

    DELETE int-ds-saldo-totvs.
           
END.

FOR EACH int-ds-cenar-estoq EXCLUSIVE-LOCK WHERE 
         int-ds-cenar-estoq.cod-estab >= tt-param.c-cod-estab-ini AND 
         int-ds-cenar-estoq.cod-estab <= tt-param.c-cod-estab-fin AND
         int-ds-cenar-estoq.situacao = 2 : /* Integrado no estoque */

    DELETE  int-ds-cenar-estoq.
           
END.
    
/* Saldo do estoque atual */
FOR EACH saldo-estoq NO-LOCK WHERE
         saldo-estoq.cod-estab >= tt-param.c-cod-estab-ini AND 
         saldo-estoq.cod-estab <= tt-param.c-cod-estab-fin :

   RUN pi-acompanhar IN h-acomp (INPUT "Saldo Estoque :" + saldo-estoq.cod-estab + "-" + saldo-estoq.it-codigo).
                                          
   FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
              int-ds-saldo-totvs.cod-estabel  = saldo-estoq.cod-estabel AND 
              int-ds-saldo-totvs.it-codigo    = saldo-estoq.it-codigo   AND
              int-ds-saldo-totvs.lote         = saldo-estoq.lote  NO-ERROR.
   IF NOT AVAIL int-ds-saldo-totvs THEN DO:

      CREATE int-ds-saldo-totvs.
      ASSIGN int-ds-saldo-totvs.cod-estabel  = saldo-estoq.cod-estabel 
             int-ds-saldo-totvs.it-codigo    = saldo-estoq.it-codigo
             int-ds-saldo-totvs.lote         = saldo-estoq.lote.

      RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                         INPUT int-ds-saldo-totvs.it-codigo   ,
                         INPUT int-ds-saldo-totvs.lote,
                         OUTPUT d-vl-cvm). 
      
      ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.
                                
                                       
    END.   

    ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + saldo-estoq.qtidade-atu.
    
    RELEASE int-ds-saldo-totvs.

END.
    

/* Documentos de entrada f¡sica - Re2001 */

FOR EACH doc-fisico NO-LOCK  WHERE
         doc-fisico.cod-estabel >= tt-param.c-cod-estab-ini AND 
         doc-fisico.cod-estabel <= tt-param.c-cod-estab-fin AND
         doc-fisico.situacao = 1,
    EACH it-doc-fisico OF doc-fisico NO-LOCK :

    ASSIGN l-lote = NO.
   
    RUN pi-acompanhar IN h-acomp (INPUT "Doc. Fisico :" + doc-fisico.cod-estabel + "-" + doc-fisico.nro-docto).

    FOR EACH rat-lote NO-LOCK WHERE 
             rat-lote.nro-docto    = doc-fisico.nro-docto    AND
             rat-lote.serie-docto  = doc-fisico.serie-docto  AND
             rat-lote.cod-emitente = doc-fisico.cod-emitente AND
             rat-lote.sequencia    = it-doc-fisico.sequencia AND
             rat-lote.tipo-nota    = doc-fisico.tipo-nota    AND
             rat-lote.nat-operacao = " "                     AND
             rat-lote.it-codigo    = it-doc-fisico.it-codigo:

         ASSIGN l-lote = YES.

        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = doc-fisico.cod-estabel  AND 
                   int-ds-saldo-totvs.it-codigo    = it-doc-fisico.it-codigo AND
                   int-ds-saldo-totvs.lote         = rat-lote.lote  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel = doc-fisico.cod-estabel 
                 int-ds-saldo-totvs.it-codigo   = it-doc-fisico.it-codigo
                 int-ds-saldo-totvs.lote        = rat-lote.lote. 

          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + rat-lote.quantidade.
    
        RELEASE int-ds-saldo-totvs.

    END.

    IF l-lote = NO 
    THEN DO:

        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = doc-fisico.cod-estabel  AND 
                   int-ds-saldo-totvs.it-codigo    = it-doc-fisico.it-codigo AND
                   int-ds-saldo-totvs.lote         = ""  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel  = doc-fisico.cod-estabel 
                 int-ds-saldo-totvs.it-codigo    = it-doc-fisico.it-codigo
                 int-ds-saldo-totvs.lote         = "". 

          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + it-doc-fisico.quantidade.  /* NFE/NFT/NFD */
        
        RELEASE int-ds-saldo-totvs.
    END.
            
END.


/* Notas de entrada que nÆo atualizaram estoque ainda - Re1001 */
           
FOR EACH docum-est NO-LOCK WHERE 
         docum-est.cod-estabel >= tt-param.c-cod-estab-ini AND 
         docum-est.cod-estabel <= tt-param.c-cod-estab-fin AND 
         docum-est.nro-docto <> "" AND
         docum-est.ce-atual   = NO  ,
    EACH item-doc-est OF docum-est NO-LOCK :
                               
    RUN pi-acompanhar IN h-acomp (INPUT "Doc. Fiscal:" + docum-est.cod-estabel + "-" + docum-est.nro-docto).

    /* DISP docum-est.nro-docto
         docum-est.ce-atual  
         item-doc-est.it-codigo
         item-doc-est.numero-ordem
         docum-est.tipo-nota 
         docum-est.cod-estabel
         WITH WIDTH 333. */    

    ASSIGN l-lote = NO.

    FOR EACH rat-lote NO-LOCK WHERE 
             rat-lote.cod-emitente = item-doc-est.cod-emitente   AND 
             rat-lote.serie-docto  = item-doc-est.serie-docto    AND
             rat-lote.nro-docto    = item-doc-est.nro-docto      AND
             rat-lote.nat-operacao = item-doc-est.nat-operacao   AND
             rat-lote.sequencia    = item-doc-est.sequencia :

        ASSIGN l-lote = YES.

        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = docum-est.cod-estabel AND 
                   int-ds-saldo-totvs.it-codigo    = item-doc-est.it-codigo AND
                   int-ds-saldo-totvs.lote         = rat-lote.lote  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel  = docum-est.cod-estabel 
                 int-ds-saldo-totvs.it-codigo    = item-doc-est.it-codigo
                 int-ds-saldo-totvs.lote         = rat-lote.lote. 


          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + rat-lote.quantidade.
    
        RELEASE int-ds-saldo-totvs.

    END.

    IF l-lote = NO 
    THEN DO:

        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = docum-est.cod-estabel AND 
                   int-ds-saldo-totvs.it-codigo    = item-doc-est.it-codigo AND
                   int-ds-saldo-totvs.lote         = ""  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel  = docum-est.cod-estabel 
                 int-ds-saldo-totvs.it-codigo    = item-doc-est.it-codigo
                 int-ds-saldo-totvs.lote         = "". 


          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + item-doc-est.quantidade.  /* NFE/NFT/NFD */
        
        RELEASE int-ds-saldo-totvs.
    END.
         
END.

/* Notas de saida que nÆo atualizaram estoque ainda */ 
                  
FOR EACH nota-fiscal NO-LOCK WHERE
         nota-fiscal.cod-estabel >= tt-param.c-cod-estab-ini AND 
         nota-fiscal.cod-estabel <= tt-param.c-cod-estab-fin AND 
         nota-fiscal.dt-confirma = ? AND 
         nota-fiscal.dt-cancela  = ? ,
    EACH it-nota-fisc OF nota-fiscal NO-LOCK :
              
    ASSIGN l-lote = NO.
                   
    RUN pi-acompanhar IN h-acomp (INPUT "Nota Fiscal:" + nota-fiscal.cod-estabel + "-" + nota-fiscal.nr-nota-fis).

    FOR EACH fat-ser-lote NO-LOCK where 
             fat-ser-lote.cod-estabel = it-nota-fisc.cod-estabel and 
             fat-ser-lote.serie       = it-nota-fisc.serie       and 
             fat-ser-lote.nr-nota-fis = it-nota-fisc.nr-nota-fis and 
             fat-ser-lote.nr-seq-fat  = it-nota-fisc.nr-seq-fat  and 
             fat-ser-lote.it-codigo   = it-nota-fisc.it-codigo :

        ASSIGN l-lote = YES.
         
        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = it-nota-fisc.cod-estabel AND 
                   int-ds-saldo-totvs.it-codigo    = it-nota-fisc.it-codigo AND
                   int-ds-saldo-totvs.lote         = fat-ser-lote.nr-serlote  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel  = it-nota-fisc.cod-estabel 
                 int-ds-saldo-totvs.it-codigo    = it-nota-fisc.it-codigo
                 int-ds-saldo-totvs.lote         = fat-ser-lote.nr-serlote. 

          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        IF nota-fiscal.esp-docto = 20 THEN 
           ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + fat-ser-lote.qt-baixada[1].  /* NFD */
        ELSE IF nota-fiscal.esp-docto = 22 THEN
           ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual - fat-ser-lote.qt-baixada[1]. /* NFS */
           
        RELEASE int-ds-saldo-totvs.

    END.   

    IF l-lote = NO 
    THEN DO:

        FIND FIRST int-ds-saldo-totvs EXCLUSIVE-LOCK WHERE
                   int-ds-saldo-totvs.cod-estabel  = it-nota-fisc.cod-estabel AND 
                   int-ds-saldo-totvs.it-codigo    = it-nota-fisc.it-codigo AND
                   int-ds-saldo-totvs.lote         = ""  NO-ERROR.
        IF NOT AVAIL int-ds-saldo-totvs THEN DO:

          CREATE int-ds-saldo-totvs.
          ASSIGN int-ds-saldo-totvs.cod-estabel  = it-nota-fisc.cod-estabel 
                 int-ds-saldo-totvs.it-codigo    = it-nota-fisc.it-codigo
                 int-ds-saldo-totvs.lote         = "". 

          RUN pi-calula-cvm (INPUT int-ds-saldo-totvs.cod-estabel ,
                             INPUT int-ds-saldo-totvs.it-codigo   ,
                             INPUT int-ds-saldo-totvs.lote,
                             OUTPUT d-vl-cvm). 

          ASSIGN int-ds-saldo-totvs.valor-cmv = d-vl-cvm.

        END.   

        IF nota-fiscal.esp-docto = 20 THEN 
           ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual + it-nota-fisc.qt-faturada[1].  /* NFD */
        ELSE IF nota-fiscal.esp-docto = 22 THEN
           ASSIGN int-ds-saldo-totvs.qtd-atual = int-ds-saldo-totvs.qtd-atual - it-nota-fisc.qt-faturada[1]. /* NFS */
             
        RELEASE int-ds-saldo-totvs.

    END.

END.

FOR EACH int-ds-saldo-totvs NO-LOCK WHERE
         int-ds-saldo-totvs.cod-estabel >= tt-param.c-cod-estab-ini AND 
         int-ds-saldo-totvs.cod-estabel <= tt-param.c-cod-estab-fin :

  DISP int-ds-saldo-totvs
       WITH WIDTH 333 STREAM-IO.
            
END.

{include/i-rpclo.i}   

run pi-finalizar in h-acomp.

PROCEDURE pi-calula-cvm:

DEF INPUT  PARAMETER p-cod-estabel LIKE int-ds-saldo-totvs.cod-estabel.
DEF INPUT  parameter p-it-codigo   LIKE int-ds-saldo-totvs.it-codigo.  
DEF INPUT  PARAMETER p-lote        LIKE int-ds-saldo-totvs.lote.
DEF OUTPUT PARAMETER p-valor-cvm   LIKE int-ds-saldo-totvs.valor-cmv.

    assign p-valor-cvm = 0.

    for first item-estab no-lock where 
              item-estab.it-codigo   = p-it-codigo and
              item-estab.cod-estabel = p-cod-estabel:
   
           assign p-valor-cvm = item-estab.val-unit-mat-m[1] +
                                item-estab.val-unit-ggf-m[1] +
                                item-estab.val-unit-mob-m[1].
    end.  
    
    if p-valor-cvm = 0
    then do:
       
       find last movto-estoq no-lock where
                 movto-estoq.cod-estabel = p-cod-estabel and
                 movto-estoq.it-codigo   = p-it-codigo   and 
                 movto-estoq.tipo-trans  = 1 no-error.
       if avail movto-estoq then do:
          
              assign p-valor-cvm = movto-estoq.valor-mat-m[1] + 
                                   movto-estoq.valor-ggf-m[1] +
                                   movto-estoq.valor-mob-m[1].
       end. 
          
    end.   
    
    if p-valor-cvm = 0
    then do:
       for first item-estab no-lock where 
                 item-estab.it-codigo   = p-it-codigo:                 
   
           assign p-valor-cvm = item-estab.val-unit-mat-m[1] +
                                item-estab.val-unit-ggf-m[1] +
                                item-estab.val-unit-mob-m[1].
       end.      
          
    end.
    
    if p-valor-cvm = 0
    then do:
        find last movto-estoq no-lock where
                  movto-estoq.it-codigo   = p-it-codigo and 
                  movto-estoq.tipo-trans  = 1 no-error.
        if avail movto-estoq then do:
          
              assign p-valor-cvm = movto-estoq.valor-mat-m[1] + 
                                   movto-estoq.valor-ggf-m[1] +
                                   movto-estoq.valor-mob-m[1].
        end.
    end.
     
    if p-valor-cvm = 0 then 
        assign p-valor-cvm = 1. 



END PROCEDURE.

*/

