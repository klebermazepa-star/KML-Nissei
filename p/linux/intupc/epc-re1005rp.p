/******************************************************************************************
**  Programa: epc-re1005rp
******************************************************************************************/
              
{include/i-epc200.i epc-re1005rp}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEF BUFFER b-docum-est FOR docum-est.
DEF VAR c-erro AS CHAR.

IF p-ind-event = "inicio-verifica-documento" 
THEN DO:

    FOR FIRST tt-epc WHERE 
              tt-epc.cod-event     = p-ind-event AND
              tt-epc.cod-parameter = "docum-est rowid" NO-LOCK:
    END.
    IF AVAIL tt-epc 
    THEN DO:
       FIND FIRST b-docum-est WHERE
                  ROWID(b-docum-est) = TO-ROWID(tt-epc.val-parameter) NO-LOCK NO-ERROR.
       IF AVAIL b-docum-est 
       THEN DO:
          
          FOR FIRST int_ds_docto_xml WHERE
                int(int_ds_docto_xml.nnf)         = int(b-docum-est.nro-docto) AND 
                    int_ds_docto_xml.serie        = b-docum-est.serie-docto    AND 
                    int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   AND
                    int_ds_docto_xml.tipo_nota  = 1 AND
                   (int_ds_docto_xml.tipo_docto = 0 OR
                    int_ds_docto_xml.tipo_docto = 4) NO-LOCK: 
          END.

          IF AVAIL int_ds_docto_xml 
          THEN DO:
   
               FOR FIRST dupli-apagar NO-LOCK where 
                         dupli-apagar.serie-docto  = b-docum-est.serie-docto  and
                         dupli-apagar.nro-docto    = b-docum-est.nro-docto    and     
                         dupli-apagar.cod-emitente = b-docum-est.cod-emitente and 
                         dupli-apagar.nat-operacao = b-docum-est.nat-operacao: 
               END.
               IF AVAIL dupli-apagar THEN DO:
                  IF dupli-apagar.dt-trans <> b-docum-est.dt-trans
                  THEN DO:

                     ASSIGN c-erro = "Data de transa‡Æo do documento " + string(b-docum-est.dt-trans) + " diferente da data de transa‡Æo da duplicata " + STRING(dupli-apagar.dt-trans) + ".". 
                                      
                     DISP b-docum-est.serie-docto  
                          b-docum-est.nro-docto    
                          b-docum-est.cod-emitente 
                          b-docum-est.nat-operacao 
                          string(33988,">>>>>9") at 43 COLUMN-LABEL "Erro"
                          c-erro FORMAT "X(100)" COLUMN-LABEL "Mensagem" AT 53
                          WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro-dup.
                          DOWN WITH FRAME f-erro-dup.

                     RETURN "NOK". 

                  END. 
               END.
          END. 
       END.
    END.
END. 

RETURN "OK".
     

