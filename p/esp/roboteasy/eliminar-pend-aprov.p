DEF VAR a AS INTE.
DEF VAR b AS INTE.
DEF VAR C AS INTE.

DEF VAR i-num-pedido like pedido-compr.num-pedido.
DEF VAR l-eliminar   AS LOGICAL FORMAT "Sim/NÆo".

REPEAT TRANS:
    
    ASSIGN l-eliminar = NO.

    UPDATE SKIP(1)
           i-num-pedido LABEL "Pedido" COLON 20
           SKIP(1)
           l-eliminar LABEL "Eliminar" COLON 20
           SKIP(1)        
        WITH FRAME f1 1 COLUMN THREE-D VIEW-AS DIALOG-BOX WIDTH 50 title "Excluir Pend Aprov - v1".
    
    FOR EACH  doc-pend-aprov EXCLUSIVE-LOCK
        WHERE doc-pend-aprov.ind-tip-doc  = 4 /* pedido compra */
        AND   doc-pend-aprov.num-pedido   = i-num-pedido:
        ASSIGN a = a + 1.
        IF  l-eliminar THEN 
            DELETE doc-pend-aprov.
    END.

    FOR EACH mla-doc-pend-aprov EXCLUSIVE-LOCK
        WHERE mla-doc-pend-aprov.cod-tip-doc = 7
          AND mla-doc-pend-aprov.chave-doc   = string(i-num-pedido):
        ASSIGN b = b + 1.
        IF  l-eliminar THEN 
            DELETE mla-doc-pend-aprov.
    END.

    FOR EACH mla-doc-pend-aprov EXCLUSIVE-LOCK
        WHERE mla-doc-pend-aprov.cod-tip-doc = 8
          AND mla-doc-pend-aprov.chave-doc   = string(i-num-pedido):
        ASSIGN C = C + 1.
        IF  l-eliminar THEN 
            DELETE mla-doc-pend-aprov.
    END.

   MESSAGE i-num-pedido skip(1) a SKIP b SKIP C
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
END. // repeat
