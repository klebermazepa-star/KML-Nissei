

OUTPUT TO VALUE("{1}") APPEND NO-CONVERT .

PUT UNFORMATTED p-ind-event SKIP 'BEGIN' SKIP .
FOR EACH tt-epc NO-LOCK:
    PUT UNFORMATTED '   '
        tt-epc.cod-event + ' ; ' +
        tt-epc.cod-parameter + ' ; ' + 
        tt-epc.val-parameter
        SKIP
        .
END.
PUT UNFORMATTED 'END' SKIP . 

OUTPUT CLOSE .
