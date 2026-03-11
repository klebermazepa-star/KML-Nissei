/******************************************************************************
**
**       PROGRAMA: int005.p
**
**       DATA....: 03/2016
**
**       OBJETIVO: Atualizar saldo estoque para comparar diferenáas no estoque 
**                 entre Sysfarma e Datasul 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{intprg/int-rpw.i}   
    
DEF VAR l-lote AS LOGICAL INITIAL NO NO-UNDO.
DEF VAR d-vl-cvm LIKE int-ds-saldo-estoq.valor-cmv NO-UNDO.  

FOR EACH int-ds-saldo-totvs EXCLUSIVE-LOCK:

    DELETE int-ds-saldo-totvs.
           
END.

FOR EACH int-ds-cenar-estoq EXCLUSIVE-LOCK WHERE 
         int-ds-cenar-estoq.situacao = 2 : /* Integrado no estoque */

    DELETE  int-ds-cenar-estoq.
           
END.
    
/* Saldo do estoque atual */
FOR EACH saldo-estoq NO-LOCK:

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
    

/* Documentos de entrada f°sica - Re2001 */

FOR EACH doc-fisico NO-LOCK  WHERE
         doc-fisico.situacao = 1,
    EACH it-doc-fisico OF doc-fisico NO-LOCK :

    ASSIGN l-lote = NO.

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


/* Notas de entrada que n∆o atualizaram estoque ainda - Re1001 */
           
FOR EACH docum-est NO-LOCK WHERE 
         docum-est.nro-docto <> "" AND
         docum-est.ce-atual   = NO  ,
    EACH item-doc-est OF docum-est NO-LOCK :
                               
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

/* Notas de saida que n∆o atualizaram estoque ainda */ 
                  
FOR EACH nota-fiscal NO-LOCK WHERE
         nota-fiscal.dt-confirma = ? AND 
         nota-fiscal.dt-cancela  = ? ,
    EACH it-nota-fisc OF nota-fiscal NO-LOCK :
              
    ASSIGN l-lote = NO.
                   
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

