/******************************************************************************************
**  Programa: epc-ft0603rp.p
**  Versao..:  
**  Data....: Somente notas do convˆnio  
******************************************************************************************/
              
{include/i-epc200.i ft0603rp}


DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 

IF  p-ind-event  = "Point-One" 
THEN DO:

    FOR FIRST tt-epc
        WHERE tt-epc.cod-event     = p-ind-event 
        AND   tt-epc.cod-parameter = "rowid-nota-fiscal":

        FOR FIRST nota-fiscal
            WHERE ROWID(nota-fiscal) = TO-ROWID(tt-epc.val-parameter) NO-LOCK:

           IF nota-fiscal.esp-docto <> 23  THEN DO:

               IF nota-fiscal.cod-portador <> 99501  AND 
                  nota-fiscal.cod-portador <> 99801  THEN DO:
                  IF nota-fiscal.cod-portador = 99999 THEN DO:
                      FIND FIRST fat-duplic NO-LOCK
                           WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
                             AND fat-duplic.serie       = nota-fiscal.serie
                             AND fat-duplic.nr-fatura   = nota-fiscal.nr-fatura
                             AND fat-duplic.cod-esp     = "NF" NO-ERROR.
                      IF NOT AVAIL fat-duplic THEN DO:
                          ASSIGN tt-epc.val-parameter = "Error".
                      END.
                  END.
                  ELSE DO:
                      ASSIGN tt-epc.val-parameter = "Error".
                  END.
    /*               FIND FIRST natur-oper NO-LOCK WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao NO-ERROR. */
    /*               IF natur-oper.cod-cfop <> '6933'                                                                 */
    /*               AND natur-oper.cod-cfop <> '5933' THEN                                                           */
                     
               END.
               ELSE DO: 
                    FIND FIRST fat-duplic use-index ch-fatura NO-LOCK where 
                               fat-duplic.cod-estabel   = nota-fiscal.cod-estabel  and
                               fat-duplic.serie         = nota-fiscal.serie        and  
                               fat-duplic.nr-fatura     = nota-fiscal.nr-fatura    and 
                               fat-duplic.ind-fat-nota  = 1                        and   
                               fat-duplic.flag-atualiz  = NO                       AND 
                              (fat-duplic.cod-esp       = "CV"                     OR
                               fat-duplic.cod-esp       = "CE")                    AND  
                               fat-duplic.int-1         = nota-fiscal.cod-portador NO-ERROR.
                    IF NOT AVAIL fat-duplic THEN DO:
                       ASSIGN tt-epc.val-parameter = "Error".
                    END.
               END.
           END.
        END.
    END.
END. 

RETURN "OK":U.
     
