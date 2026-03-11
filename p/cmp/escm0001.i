DEF TEMP-TABLE tt-param NO-UNDO 
    FIELD destino                   AS INT 
    FIELD arquivo                   AS CHAR FORMAT "x(35)"
    FIELD usuario                   AS CHAR FORMAT "x(12)"
    FIELD modelo-rtf                AS CHAR FORMAT "x(35)"
    FIELD l-habilitaRtf             AS LOG
    FIELD cod-emitente-ini          LIKE ems2mult.emitente.cod-emitente
    FIELD cod-emitente-fim          LIKE ems2mult.emitente.cod-emitente
    FIELD nome-abrev-ini            LIKE ems2mult.emitente.nome-abrev
    FIELD nome-abrev-fim            LIKE ems2mult.emitente.nome-abrev
    
                                    .
                                    
                                    
