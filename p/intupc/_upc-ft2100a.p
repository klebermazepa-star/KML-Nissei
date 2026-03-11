/********************************************************************************************   

  UPC FT2010A
  
  Cria‡Æo: 25/11/2021 - KML

*********************************************************************************************/

{include/i-epc200.i ft2100a}
{utp\ut-glob.i}

DEF INPUT        PARAM            p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR  tt-epc.

DEFINE VARIABLE r-it-nota-fisc AS ROWID       NO-UNDO.
DEFINE VARIABLE l-valoriza-medio AS LOGICAL     NO-UNDO.

//message p-ind-event view-as alert-box.

IF p-ind-event = "TIPO-VALORIZA" THEN DO:   //TIPO-VALORIZA

    message "Entrou ponto upc" view-as alert-box.

    FIND FIRST tt-epc
         WHERE tt-epc.cod-event = "TIPO-VALORIZA"
          AND  tt-epc.cod-parameter = "rw-it-nota-fisc" NO-ERROR.

    IF AVAIL tt-epc THEN DO:

        ASSIGN r-it-nota-fisc = TO-ROWID(tt-epc.val-parameter).

        FOR FIRST it-nota-fisc NO-LOCK
            WHERE ROWID(it-nota-fisc) = r-it-nota-fisc:

            FIND FIRST int_ds_natur_oper NO-LOCK
                 WHERE int_ds_natur_oper.nat_operacao = it-nota-fisc.nat-operacao NO-ERROR.

            /* flag especifico */
            IF AVAIL int_ds_natur_oper
            AND int_ds_natur_oper.trata_valoriza THEN  DO:

                   ASSIGN l-valoriza-medio = IF int_ds_natur_oper.id_valoriza = 1 THEN YES ELSE NO.

				   message "Entrou retorno de ponto upc" skip
							l-valoriza-medio view-as alert-box.

                   CREATE tt-epc.
                   ASSIGN tt-epc.cod-event = "TIPO-VALORIZA"
                          tt-epc.cod-parameter = "VALORIZA-MEDIO"
                          tt-epc.val-parameter = IF l-valoriza-medio THEN "yes" ELSE "no".


            END.
        END.


    END. /* avail tt-epc */
	
  

END. /* p-ind-event */

RETURN "OK".
