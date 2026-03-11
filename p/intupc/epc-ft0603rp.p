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

        FOR FIRST nota-fiscal NO-LOCK
            WHERE ROWID(nota-fiscal) = TO-ROWID(tt-epc.val-parameter) ,
            EACH fat-duplic NO-LOCK
                WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
                  AND fat-duplic.serie       = nota-fiscal.serie
                  AND fat-duplic.nr-fatura   = nota-fiscal.nr-fatura
                  AND fat-duplic.flag-atualiz  = NO :

           IF nota-fiscal.esp-docto <> 23  THEN DO:

               IF fat-duplic.int-1 <> 99501  AND 
                  fat-duplic.int-1 <> 99301  AND 
                  fat-duplic.int-1 <> 99801  AND 
                  fat-duplic.int-1 <> 91801 THEN DO:

                  IF fat-duplic.int-1 = 99999 THEN DO:
                                         
                      IF fat-duplic.cod-esp     = "NF" THEN DO:

                      END.
                      ELSE DO:
                          ASSIGN tt-epc.val-parameter = "Error".
                      END.
                  END.
                  ELSE DO:
                     ASSIGN tt-epc.val-parameter = "Error".
                     
                  END.
               END.
               ELSE DO: 

                    IF fat-duplic.ind-fat-nota  = 1                        and   
                       fat-duplic.flag-atualiz  = NO                       AND 
                       (fat-duplic.cod-esp       = "CV"                     OR
                       fat-duplic.cod-esp       = "CA"                     OR
                       fat-duplic.cod-esp       = "CE"                     OR
                       fat-duplic.cod-esp       = "CR"  )                    THEN DO : 

                    END.
                    ELSE DO:
                       ASSIGN tt-epc.val-parameter = "Error".
                    END.
               END.
           END.
        END.
    END.
END. 

RETURN "OK":U.
     
