/*************************************************************************
**
**  Programa: int200.p - Atualiza cod-obsoleto da tabela item-uni-estab 
**                       … partir do cod-obsoleto do item
**
*************************************************************************/                                                        
        
{intprg/int-rpw.i}         
        
DEF BUFFER b-item-uni-estab FOR item-uni-estab.

FOR EACH ITEM NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    FOR EACH item-uni-estab USE-INDEX codigo WHERE
             item-uni-estab.it-codigo = ITEM.it-codigo NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        IF item-uni-estab.cod-obsoleto <> ITEM.cod-obsoleto
        OR item-uni-estab.ind-item-fat <> ITEM.ind-item-fat THEN DO:
           FOR FIRST b-item-uni-estab OF item-uni-estab EXCLUSIVE-LOCK QUERY-TUNING(NO-LOOKAHEAD):
           END.
           IF AVAIL b-item-uni-estab THEN DO:
              ASSIGN b-item-uni-estab.cod-obsoleto = ITEM.cod-obsoleto
                     b-item-uni-estab.ind-item-fat = ITEM.ind-item-fat.        
           END.
           RELEASE b-item-uni-estab.
        END.
    END.
END.

RETURN "OK".
