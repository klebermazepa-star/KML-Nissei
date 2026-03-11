/******************************************************************************************
**  Programa: upc-re2001b.p
**  Versao..:  
**  Data....: Validaá∆o do pedido de compra  
******************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR c-seg-usuario            LIKE usuar_mestre.cod_usuario NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-num-pedido-re2001b    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nr-seq-re2001b        AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re2001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re2001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re2001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-tipo-nota-re2001      AS WIDGET-HANDLE no-undo.

DEFINE VARIABLE i-cont-ped      AS INTEGER                     NO-UNDO.
DEFINE VARIABLE i-cod-emitente LIKE it-doc-fisico.cod-emitente no-undo.
DEFINE VARIABLE c-nro-docto    LIKE it-doc-fisico.nro-docto    no-undo.
DEFINE VARIABLE c-serie        LIKE it-doc-fisico.serie-docto  no-undo.
DEFINE VARIABLE i-tipo-nota    LIKE it-doc-fisico.tipo-nota    no-undo.
                
DEF TEMP-TABLE tt-ped-compra
FIELD num-pedido LIKE item-doc-est.num-pedido.

DEFINE BUFFER b-it-doc-fisico  FOR it-doc-fisico.

IF (p-ind-event  = "initialize" AND  
    p-ind-object = "viewer"     AND 
   (p-wgh-object:FILE-NAME = "invwr/v05in163.w" OR
    p-wgh-object:FILE-NAME = "invwr/v04in163.w"))
THEN DO:          
    
    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
       IF wh-frame:NAME = "num-pedido" THEN
         ASSIGN wh-num-pedido-re2001b = wh-frame.
        
       IF wh-frame:NAME = "sequencia" THEN
         ASSIGN wh-nr-seq-re2001b = wh-frame.

        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
END.
 

IF p-ind-event  = "validate" AND  
   p-ind-object = "viewer"     AND 
   p-wgh-object:FILE-NAME = "invwr/v05in163.w"
THEN DO: 

  FIND FIRST int_ds_param_re WHERE 
             int_ds_param_re.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.
  IF AVAILABLE int_ds_param_re AND 
               int_ds_param_re.vld_pedido
  THEN DO:

     FIND FIRST b-it-doc-fisico NO-LOCK WHERE
                ROWID(b-it-doc-fisico) = p-row-table NO-ERROR.
     IF AVAIL b-it-doc-fisico 
     THEN DO:
         ASSIGN i-cod-emitente = b-it-doc-fisico.cod-emitente
                c-nro-docto    = b-it-doc-fisico.nro-docto   
                c-serie        = b-it-doc-fisico.serie-docto 
                i-tipo-nota    = b-it-doc-fisico.tipo-nota.
     END.
     ELSE DO:

         ASSIGN i-cod-emitente = int(wh-cod-emitente-re2001:SCREEN-VALUE)
                c-nro-docto    = wh-nro-docto-re2001:SCREEN-VALUE       
                c-serie        = wh-serie-re2001:SCREEN-VALUE.

         CASE wh-tipo-nota-re2001:SCREEN-VALUE:
              when   "Compra"                  then ASSIGN i-tipo-nota = 1. 
              when   "Devoluá∆o"               then ASSIGN i-tipo-nota = 2. 
              when   "Transferància"           then ASSIGN i-tipo-nota = 3. 
              when   "Entrada Benef"           then ASSIGN i-tipo-nota = 4. 
              when   "Retorno Benef"           then ASSIGN i-tipo-nota = 5. 
              when   "Entrada Consig"          then ASSIGN i-tipo-nota = 6. 
              when   "Fatura Consig"           then ASSIGN i-tipo-nota = 7. 
              when   "Devoluá∆o Consig"        then ASSIGN i-tipo-nota = 8. 
              when   "Nota de Rateio"          then ASSIGN i-tipo-nota = 9. 
              when   "Rem. Entrega Futura"     then ASSIGN i-tipo-nota = 10.
              when   "Rem. Fat. Antecipado"    then ASSIGN i-tipo-nota = 11.
         END CASE.
                 
     END.
               
    
     EMPTY TEMP-TABLE tt-ped-compra.
                       
     FOR EACH it-doc-fisico NO-LOCK WHERE
              it-doc-fisico.cod-emitente = i-cod-emitente AND 
              it-doc-fisico.nro-docto    = c-nro-docto    AND 
              it-doc-fisico.serie-docto  = c-serie        AND    
              it-doc-fisico.tipo-nota    = i-tipo-nota    AND  
              it-doc-fisico.sequencia   <> INT(wh-nr-seq-re2001b:SCREEN-VALUE)
          BREAK BY it-doc-fisico.num-pedido:

          IF FIRST-OF(it-doc-fisico.num-pedido) 
          THEN DO:
             ASSIGN i-cont-ped = i-cont-ped + 1.

             CREATE tt-ped-compra.
             ASSIGN tt-ped-compra.num-pedido = it-doc-fisico.num-pedido.

             MESSAGE it-doc-fisico.sequencia SKIP
                     tt-ped-compra.num-pedido VIEW-AS ALERT-BOX.
                  
          END.  

     END.

     IF i-cont-ped > 0 
     THEN DO:

         FIND FIRST tt-ped-compra NO-LOCK WHERE
                    tt-ped-compra.num-pedido = int(wh-num-pedido-re2001b:SCREEN-VALUE) NO-ERROR.
         IF NOT AVAIL tt-ped-compra 
         THEN DO: 

            Run utp/ut-msgs.p (Input "show":U, 
                               Input 17006, 
                               Input "Pedido Informado n∆o corresponde ao pedido informado em outro item da nota.~~
                                      Verifique o pedido informado nos itens da nota.").

            RETURN "NOK".
                               
         END.

     END. 

  END. /* usuario vl-pedido */
   
END.



