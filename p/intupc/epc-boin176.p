/*****************************************************************************
**  Programa.: intupc/epc-boin176.p
**  Descriá∆o: EPC para bloquear a digitaá∆o do item caso o pedido de compra 
               informado, seja sempre o mesmo. **             
**  Data.....: 05/2016
**  Autor....: ResultPro
******************************************************************************/                             
{include/i-epc200.i1}

{inbo/boin176.i tt-item-doc-est}
{method/dbotterr.i} /** Definicao temp-table rowErrors **/

DEF TEMP-TABLE tt-ped-compra
FIELD num-pedido LIKE item-doc-est.num-pedido.
                     
DEF INPUT        PARAM p-ind-event  AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE        FOR tt-epc. 

/*** Definicao de Variaveis ***/
DEFINE VARIABLE h-boin176       as HANDLE  NO-UNDO.
DEFINE VARIABLE i-cont-ped      AS INTEGER NO-UNDO.

DEF NEW GLOBAL SHARED VAR c-seg-usuario        LIKE usuar_mestre.cod_usuario NO-UNDO.

/*  MESSAGE PROGRAM-NAME(1)" PROGRAM-NAME(1) " skip  */
/*         PROGRAM-NAME(2)" PROGRAM-NAME(2) " skip   */
/*         PROGRAM-NAME(3)" PROGRAM-NAME(3) " skip   */
/*         PROGRAM-NAME(4)" PROGRAM-NAME(4) " skip   */
/*         PROGRAM-NAME(5)" PROGRAM-NAME(5) " skip   */
/*         PROGRAM-NAME(6)" PROGRAM-NAME(6) " skip   */
/*         PROGRAM-NAME(7)" PROGRAM-NAME(7) " skip   */
/*         PROGRAM-NAME(8)" PROGRAM-NAME(8) " skip   */
/*         p-ind-event                               */
/*         VIEW-AS ALERT-BOX.                        */


IF p-ind-event = "endValidateRecord"  AND
   index(PROGRAM-NAME(5),"saverecord rep/re1001b") > 0 
THEN DO:
      
    FIND FIRST int_ds_param_re WHERE 
               int_ds_param_re.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.
    IF AVAILABLE int_ds_param_re AND 
                 int_ds_param_re.vld_pedido
    THEN DO:

        FIND FIRST tt-epc NO-LOCK
             WHERE tt-epc.cod-event     = p-ind-event
               AND tt-epc.cod-parameter = "OBJECT-HANDLE" NO-ERROR.
        
        IF AVAIL tt-epc THEN DO:
            ASSIGN h-boin176 = WIDGET-HANDLE(tt-epc.val-parameter).
        
            RUN getRecord IN h-boin176 (OUTPUT TABLE tt-item-doc-est).
        
            FIND FIRST tt-item-doc-est NO-LOCK NO-ERROR.
        END.
        
        IF AVAIL tt-item-doc-est
        THEN DO:
                               
           RUN getrowerrors IN h-boin176 (OUTPUT TABLE rowerrors).
    
           IF NOT CAN-FIND(rowerrors WHERE
                           rowerrors.errortype = "Error")  
           THEN DO:
              
              EMPTY TEMP-TABLE tt-ped-compra.
                               
              FOR EACH item-doc-est NO-LOCK WHERE
                       item-doc-est.cod-emitente = tt-item-doc-est.cod-emitente AND 
                       item-doc-est.nro-docto    = tt-item-doc-est.nro-docto    AND 
                       item-doc-est.serie-docto  = tt-item-doc-est.serie-docto  AND    
                       item-doc-est.nat-operacao = tt-item-doc-est.nat-operacao AND  
                       item-doc-est.sequencia <> tt-item-doc-est.sequencia
                  BREAK BY item-doc-est.num-pedido:
    
                  IF FIRST-OF(item-doc-est.num-pedido) 
                  THEN DO:
                     ASSIGN i-cont-ped = i-cont-ped + 1.
    
                     CREATE tt-ped-compra.
                     ASSIGN tt-ped-compra.num-pedido = item-doc-est.num-pedido.
                          
                  END.  
    
              END.
    
              IF i-cont-ped > 0 THEN DO:
    
                 FIND FIRST tt-ped-compra NO-LOCK WHERE
                            tt-ped-compra.num-pedido = tt-item-doc-est.num-pedido NO-ERROR.
                 IF NOT AVAIL tt-ped-compra 
                 THEN DO: 
    
                    RUN _insertErrorManual IN h-boin176(INPUT 17006,
                                                        INPUT "EMS":U,
                                                        INPUT "error":U,
                                                        INPUT "Pedido Informado n∆o corresponde ao pedido informado em outro item da nota",
                                                        INPUT "Verifique o pedido informado nos itens da nota.",
                                                        INPUT "":U).
                 END.
    
              END. 
              
           END. 
            
        END. /* avail tt-item-doc-est */

    END. /* usuario vl-pedido */

END.

RETURN 'OK':U.
