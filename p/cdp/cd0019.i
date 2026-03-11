
DEFINE VARIABLE h-onfind     AS HANDLE NO-UNDO.
														 
FIND FIRST param_seg_estab 
    &IF "{1}" = "MCC" &THEN
       WHERE param_seg_estab.cdn_param = 1  /* Compras */
    &ENDIF
    &IF "{1}" = "MCE" &THEN
       WHERE param_seg_estab.cdn_param = 2 /* Estoque */
    &ENDIF
    &IF "{1}" = "MCN" &THEN
       WHERE param_seg_estab.cdn_param = 3 /* Contratos */
    &ENDIF
    &IF "{1}" = "MIN" &THEN
       WHERE param_seg_estab.cdn_param = 4 /* Investimentos */
    &ENDIF
    &IF "{1}" = "MRE" &THEN
       WHERE param_seg_estab.cdn_param = 5 /* Recebimento */
    &ENDIF
    &IF "{1}" = "WMS" &THEN
       WHERE param_seg_estab.cdn_param = 6 /* WMS */
    &ENDIF                             
    &IF "{1}" = "MPD" &THEN
       WHERE param_seg_estab.cdn_param = 1001 /* Pedidos de Vendas*/
    &ENDIF                             
    &IF "{1}" = "MQO" &THEN
       WHERE param_seg_estab.cdn_param = 1002 /* CotaªÑes de Vendas */
    &ENDIF                             
    &IF "{1}" = "MEQ" &THEN
       WHERE param_seg_estab.cdn_param = 1003 /* Embarques */
    &ENDIF                             
    &IF "{1}" = "MFT" &THEN
       WHERE param_seg_estab.cdn_param = 1004 /* Faturamento */
    &ENDIF                             
    &IF "{1}" = "EQ1007" &THEN
       WHERE param_seg_estab.cdn_param = 1005 /* Programa EQ1007 do Modulo de Embarques */
    &ENDIF
    &IF "{1}" = "CD1508" &THEN
       WHERE param_seg_estab.cdn_param = 1006 /* Programa CD1508 -  Tabela de Preáo */
    &ENDIF
    &IF "{1}" = "MCP" &THEN
       WHERE param_seg_estab.cdn_param = 2001 /* Controle de Producao */
    &ENDIF
    &IF "{1}" = "MAB" &THEN
       WHERE param_seg_estab.cdn_param = 3001 /* MAB */
    &ENDIF	
    &IF "{1}" = "MMV" &THEN
       WHERE param_seg_estab.cdn_param = 3002 /* MMV */
    &ENDIF
	&IF "{1}" = "MAO" &THEN
       WHERE param_seg_estab.cdn_param = 3003 /* MAO */
    &ENDIF
	&IF "{1}" = "MGF" &THEN
       WHERE param_seg_estab.cdn_param = 3004 /* MGF */
    &ENDIF
	&IF "{1}" = "MND" &THEN
       WHERE param_seg_estab.cdn_param = 3005 /* MND */
    &ENDIF	
	&IF "{1}" = "MPN" &THEN
       WHERE param_seg_estab.cdn_param = 3006 /* MPN */
    &ENDIF
	&IF "{1}" = "MMI" &THEN
       WHERE param_seg_estab.cdn_param = 3007 /* MMI */
    &ENDIF
	&IF "{1}" = "MGC" &THEN
       WHERE param_seg_estab.cdn_param = 3008 /* MGC */
    &ENDIF
	&IF "{1}" = "MIP" &THEN
       WHERE param_seg_estab.cdn_param = 3009 /* MIP */
    &ENDIF
	&IF "{1}" = "MPI" &THEN
       WHERE param_seg_estab.cdn_param = 3010 /* MPI */
    &ENDIF
	&IF "{1}" = "MPO" &THEN
       WHERE param_seg_estab.cdn_param = 3011 /* MPO */
    &ENDIF	
	&IF "{1}" = "MCO" &THEN
       WHERE param_seg_estab.cdn_param = 3012 /* MPO */
    &ENDIF	
    &IF "{1}" = "GGP" &THEN
       WHERE param_seg_estab.cdn_param = 4000 /* Gr∆os */
    &ENDIF
    NO-LOCK NO-ERROR.
	

IF  AVAIL param_seg_estab
AND param_seg_estab.des_valor = "SIM":U
AND NOT VALID-HANDLE(h-onfind) THEN DO:

	IF ("{1}" = "MCC") or ("{1}" = "MCE")  
	 or ("{1}" = "MCN") or ("{1}" = "MIN") 
	 or ("{1}" = "MRE") or ("{1}" = "WMS") THEN
		RUN cdp/cdapi3000.p PERSISTENT SET h-onfind.

	ELSE DO:

		IF ("{1}" = "MPD") or ("{1}" = "MQO") 
		 or ("{1}" = "MEQ") or ("{1}" = "MFT") 
		 or ("{1}" = "EQ1007") or ("{1}" = "CD1508") THEN 
			RUN cdp/cdapi3001.p PERSISTENT SET h-onfind (INPUT "{2}", INPUT param_seg_estab.cdn_param). 
		ELSE DO:

            IF ("{1}" = "MAB") or ("{1}" = "MMV") 
             or ("{1}" = "MAO") or ("{1}" = "MGF") 
             or ("{1}" = "MND") or("{1}" = "MPN")
			 or("{1}" = "MCO") THEN 
                RUN cdp/cdapi3003.p PERSISTENT SET h-onfind (input "{2}").
            ELSE DO:

    			IF ("{1}" = "MMI") or ("{1}" = "MGC")
    			 or ("{1}" = "MIP") or ("{1}" = "MPI") 
    			 or ("{1}" = "MPO") THEN
    				RUN cdp/cdapi3005.p PERSISTENT SET h-onfind (input "{2}").
					
				ELSE DO:
					IF ("{1}" = "MCP") THEN DO:
						RUN cdp/cdapi3002.p PERSISTENT SET h-onfind.
					END.
					ELSE DO:
                        IF "{1}" = "GGP" THEN DO:
                            RUN cdp/cdapi3004.p PERSISTENT SET h-onfind (INPUT "{2}").
                        END.
                    END.
				END.
    		END.
    	END.
    END.

end.

/* Seguranáa por estabelecimento - Tabela de Preáo */
IF ("{1}" = "MPD" OR "{1}" = "MFT" OR "{1}" = "MQO") 
AND CAN-FIND(FIRST param_seg_estab 
             WHERE param_seg_estab.cdn_param = 1006 /* Programa CD1508 -  Tabela de Preáo */
               AND param_seg_estab.des_valor = "SIM":U) THEN
    RUN cdp/cdapi3001.p PERSISTENT SET h-onfind (input "{2}", INPUT 1006).
    

