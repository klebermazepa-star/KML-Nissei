define new global shared variable wh-bt-atualiza              as handle           no-undo.
define new global shared variable wh-bt-enviar                as handle           no-undo.
define new global shared variable wh-bt-enviar-aux            as handle           no-undo.
define new global shared variable wh-brDoctoMDFE              as handle           no-undo.

{utp/ut-glob.i}
DEF TEMP-TABLE tt-mdfe-docto NO-UNDO
    //LIKE mdfe-docto
    FIELD r-rowid AS ROWID.

DEFINE VARIABLE hBTT AS HANDLE      NO-UNDO.

ASSIGN hBTT = wh-brDoctoMDFE:QUERY:GET-BUFFER-HANDLE(1).

/*IF hBTT:BUFFER-FIELD("idi-sit-mdfe"):BUFFER-VALUE = 3 
OR hBTT:BUFFER-FIELD("idi-sit-mdfe"):BUFFER-VALUE = 7 THEN
    RUN int/wsinventti0010.p (INPUT "RecepcionarMDFe",
                              INPUT hBTT:BUFFER-FIELD("r-rowid"):BUFFER-VALUE).*/

FIND FIRST mdfe-param-monit-usuar NO-LOCK
     WHERE mdfe-param-monit-usuar.cod-usuar = c-seg-usuario NO-ERROR.

IF AVAIL mdfe-param-monit-usuar THEN DO:

    FOR EACH mdfe-docto NO-LOCK
        WHERE mdfe-docto.cod-estab     >= mdfe-param-monit-usuar.cod-estab-inicial   
        AND   mdfe-docto.cod-estab     <= mdfe-param-monit-usuar.cod-estab-final 
        AND   mdfe-docto.cod-num-mdfe  >= mdfe-param-monit-usuar.cod-num-mdfe-inicial       
        AND   mdfe-docto.cod-num-mdfe  <= mdfe-param-monit-usuar.cod-num-mdfe-final   
        AND   mdfe-docto.cod-ser-mdfe  >= mdfe-param-monit-usuar.cod-ser-inicial    
        AND   mdfe-docto.cod-ser-mdfe  <= mdfe-param-monit-usuar.cod-ser-final  
        AND   mdfe-docto.dat-emis-mdfe >= mdfe-param-monit-usuar.dat-emis-mdfe-inicial         
        AND   mdfe-docto.dat-emis-mdfe <= mdfe-param-monit-usuar.dat-emis-mdfe-final : 

        CASE mdfe-docto.idi-sit-mdfe:
            WHEN 1 THEN NEXT.                                                          /*MDF-e N’o Gerado                              */
            WHEN 2 THEN IF mdfe-param-monit-usuar.log-uso-autoriza    = NO THEN NEXT.  /*MDF-e Autorizado                              */
            WHEN 3 THEN IF mdfe-param-monit-usuar.log-docto-rejtdo    = NO THEN NEXT.  /*MDF-e Rejeitado                               */
            WHEN 4 THEN NEXT.  /*MDF-e Cancelado                               */
            WHEN 5 THEN NEXT.  /*MDF-e Encerrado                               */
            WHEN 6 THEN IF mdfe-param-monit-usuar.log-procmto-aplicat = NO THEN NEXT.  /*Em processamento no aplicativo de transmiss’o */
            WHEN 7 THEN NEXT.  /*MDF-e Gerado                                  */
            WHEN 8 THEN IF mdfe-param-monit-usuar.log-proces-cancel   = NO THEN NEXT.  /*MDF-e em Processo de Cancelamento             */
            WHEN 9 THEN IF mdfe-param-monit-usuar.log-proces-encert   = NO THEN NEXT.  /*MDF-e em Processo de Encerramento             */
        END CASE.
               
        CASE mdfe-docto.idi-tip-emis-mdfe:
            WHEN 1 THEN IF mdfe-param-monit-usuar.log-emis-normal    = NO THEN NEXT.
            WHEN 2 THEN IF mdfe-param-monit-usuar.log-emis-contingen = NO THEN NEXT.
        END CASE.
        
        CREATE tt-mdfe-docto.
        //BUFFER-COPY mdfe-docto TO tt-mdfe-docto.
        ASSIGN tt-mdfe-docto.r-rowid = ROWID(mdfe-docto).
    END.
END.

FOR EACH tt-mdfe-docto:
    RUN int/wsinventti0010.p (INPUT "ConsultaMDFe",
                              INPUT tt-mdfe-docto.r-rowid).
END.

IF VALID-HANDLE(wh-bt-atualiza) THEN
    APPLY "CHOOSE" TO wh-bt-atualiza.
