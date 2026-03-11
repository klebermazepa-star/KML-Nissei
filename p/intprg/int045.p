/******************************************************************************
**
**  Programa: int045.p - Integraá∆o de Item x Fornecedor - Procfit -> Datasul
**
******************************************************************************/                                                        
  
DISABLE TRIGGERS FOR LOAD OF item-fornec.
DISABLE TRIGGERS FOR LOAD OF item-fornec-estab.
DISABLE TRIGGERS FOR LOAD OF item-fornec-umd.

{intprg/int-rpw.i}  
  
DEF VAR i-seq AS INT NO-UNDO.

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR FORMAT "x(12)" NO-UNDO.

FOR EACH int-ds-item-fornec WHERE 
         int-ds-item-fornec.envio_status = 1 /* Pendente */
    BY int-ds-item-fornec.tipo-movto
    BY int-ds-item-fornec.principal DESC QUERY-TUNING(NO-LOOKAHEAD):

    FOR FIRST emitente WHERE
              emitente.cgc = int-ds-item-fornec.cnpj-cpf NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL emitente THEN DO:
       RUN intprg/int999.p (INPUT "ITEMFORN", 
                            INPUT STRING(int-ds-item-fornec.cnpj-cpf),
                            INPUT "Fornecedor n∆o cadastrado no Datasul - CNPJ/CPF: " + int-ds-item-fornec.cnpj-cpf,
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario).
       NEXT.
    END.

    FOR FIRST ITEM WHERE
              ITEM.it-codigo = STRING(int-ds-item-fornec.pro_codigo_n) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL ITEM THEN DO:
       RUN intprg/int999.p (INPUT "ITEMFORN", 
                            INPUT STRING(int-ds-item-fornec.pro_codigo_n),
                            INPUT "Item n∆o cadastrado no Datasul: " + STRING(int-ds-item-fornec.pro_codigo_n),
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario).
       NEXT.
    END.

    IF int-ds-item-fornec.principal = "S" THEN DO:
       IF int-ds-item-fornec.tipo-movto = 1 
       OR int-ds-item-fornec.tipo-movto = 2 THEN DO: /* Inclus∆o / Alteraá∆o */
          FOR FIRST item-fornec USE-INDEX onde-compra WHERE  
                    item-fornec.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) AND 
                    item-fornec.cod-emitente = emitente.cod-emitente QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF NOT AVAILABLE item-fornec THEN DO:                                                              
             CREATE item-fornec.
             ASSIGN item-fornec.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n)
                    item-fornec.cod-emitente = emitente.cod-emitente.
          END.

          ASSIGN item-fornec.item-do-forn        = int-ds-item-fornec.item-do-forn
                 item-fornec.unid-med-for        = item.un
                 item-fornec.ativo               = YES
                 item-fornec.classe-repro        = 3
                 item-fornec.aval-insp           = 5
                 item-fornec.cod-cond-pag        = emitente.cod-cond-pag
                 item-fornec.lote-mul-for        = 1
                 item-fornec.idi-tributac-pis    = 2    /*Tributacao PIS Isento*/ 
                 item-fornec.idi-tributac-cofins = 2    /*Tributacao COFINS Isento*/
                 OVERLAY(item-fornec.char-1,1,1) = "2"  /*Tributacao PIS Isento*/
                 OVERLAY(item-fornec.char-1,8,1) = "2"  /*Tributacao COFINS Isento*/
                 int-ds-item-fornec.envio_status = 2.   /* Integrado */ 

          IF int-ds-item-fornec.fator-conver = 1 THEN DO:
             ASSIGN item-fornec.fator-conver = 1
                    item-fornec.num-casa-dec = 0.
          END.
          ELSE DO:
              ASSIGN item-fornec.fator-conver = (1 / int-ds-item-fornec.fator-conver) * 1000000000
                     item-fornec.num-casa-dec = 9.
          END.

          RELEASE item-fornec.

          FOR EACH estabelec NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
              FOR first cst-estabelec WHERE 
                        cst-estabelec.cod-estabel = estabelec.cod-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
              END.
              IF NOT AVAIL cst-estabelec THEN
                 NEXT.

              IF cst-estabelec.dt-fim-operacao < TODAY THEN
                 NEXT.

              FOR FIRST item-fornec-estab USE-INDEX item-emit-est WHERE 
                        item-fornec-estab.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) AND
                        item-fornec-estab.cod-emitente = emitente.cod-emitente                   AND
                        item-fornec-estab.cod-estabel  = estabelec.cod-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
              END.
              IF NOT AVAILABLE item-fornec-estab THEN DO:
                 CREATE item-fornec-estab.
                 ASSIGN item-fornec-estab.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n)
                        item-fornec-estab.cod-emitente = emitente.cod-emitente 
                        item-fornec-estab.cod-estabel  = estabelec.cod-estabel.
              END.
              ASSIGN item-fornec-estab.item-do-forn = int-ds-item-fornec.item-do-forn
                     item-fornec-estab.unid-med-for = item.un
                     item-fornec-estab.ativo        = YES
                     item-fornec-estab.classe-repro = 3
                     item-fornec-estab.cod-cond-pag = emitente.cod-cond-pag
                     item-fornec-estab.aval-insp    = 5
                     item-fornec-estab.lote-mul-for = 1.

              IF int-ds-item-fornec.fator-conver = 1 THEN DO:
                 ASSIGN item-fornec-estab.fator-conver = 1
                        item-fornec-estab.num-casa-dec = 0.
              END.
              ELSE DO:
                 ASSIGN item-fornec-estab.fator-conver = (1 / int-ds-item-fornec.fator-conver) * 1000000000
                        item-fornec-estab.num-casa-dec = 9.
              END.
          END.

          RELEASE item-fornec-estab.

          RUN intprg/int999.p (INPUT "ITEMFORN", 
                               INPUT STRING(int-ds-item-fornec.pro_codigo_n) + "/" + STRING(emitente.cod-emitente),
                               INPUT "Item: " + STRING(int-ds-item-fornec.pro_codigo_n) + " x Fornecedor: " + STRING(emitente.cod-emitente) + " Principal atualizado no Datasul",
                               INPUT 2, /* 2 - Integrado */
                               INPUT c-seg-usuario).
       END.
    END.

    IF int-ds-item-fornec.principal = "N" THEN DO:
       FOR FIRST item-fornec USE-INDEX onde-compra WHERE  
                 item-fornec.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) AND 
                 item-fornec.cod-emitente = emitente.cod-emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF NOT AVAILABLE item-fornec THEN DO:                                                              
          RUN intprg/int999.p (INPUT "ITEMFORN", 
                               INPUT STRING(int-ds-item-fornec.pro_codigo_n) + "/" + STRING(emitente.cod-emitente),
                               INPUT "Item: " + STRING(int-ds-item-fornec.pro_codigo_n) + " x Fornecedor: " + STRING(emitente.cod-emitente) + " Principal n∆o cadastrado",
                               INPUT 1, /* 1 - Pendente */
                               INPUT c-seg-usuario).
          NEXT.
       END.

       FOR FIRST item-fornec-umd WHERE
                 item-fornec-umd.cod-emitente = emitente.cod-emitente AND 
                 item-fornec-umd.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) AND  
                 item-fornec-umd.cod-livre-1  = int-ds-item-fornec.item-do-forn:
       END.
       IF AVAIL item-fornec-umd THEN DO:
          IF int-ds-item-fornec.fator-conver = 1 THEN DO:
             ASSIGN item-fornec-umd.fator-conver = 1
                    item-fornec-umd.num-casa-dec = 0.
          END.
          ELSE DO:
             ASSIGN item-fornec-umd.fator-conver = (1 / int-ds-item-fornec.fator-conver) * 1000000000
                    item-fornec-umd.num-casa-dec = 9.
          END.
          ASSIGN item-fornec-umd.log-ativo    = YES.
       END.
       ELSE DO:
           ASSIGN i-seq = 1.
           FOR EACH item-fornec-umd NO-LOCK WHERE
                    item-fornec-umd.cod-emitente = emitente.cod-emitente AND 
                    item-fornec-umd.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) 
                 BY item-fornec-umd.unid-med-for:   
               ASSIGN i-seq = i-seq + 1.
           END.

           CREATE item-fornec-umd.
           ASSIGN item-fornec-umd.cod-emitente = emitente.cod-emitente
                  item-fornec-umd.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n)
                  item-fornec-umd.cod-livre-1  = int-ds-item-fornec.item-do-forn
                  item-fornec-umd.unid-med-for = string(i-seq)
                  item-fornec-umd.log-ativo    = YES.

           IF int-ds-item-fornec.fator-conver = 1 THEN DO:
              ASSIGN item-fornec-umd.fator-conver = 1
                     item-fornec-umd.num-casa-dec = 0.
           END.
           ELSE DO:
              ASSIGN item-fornec-umd.fator-conver = (1 / int-ds-item-fornec.fator-conver) * 1000000000
                     item-fornec-umd.num-casa-dec = 9.
           END.
           ASSIGN item-fornec-umd.log-ativo = YES.
       END.

       ASSIGN int-ds-item-fornec.envio_status = 2. /* Integrado */

       RELEASE item-fornec-umd.

       RUN intprg/int999.p (INPUT "ITEMFORN", 
                            INPUT STRING(int-ds-item-fornec.pro_codigo_n) + "/" + STRING(emitente.cod-emitente),
                            INPUT "Item: " + STRING(int-ds-item-fornec.pro_codigo_n) + " x Fornecedor: " + STRING(emitente.cod-emitente) + " Secundario atualizado no Datasul",
                            INPUT 2, /* 2 - Integrado */
                            INPUT c-seg-usuario).
    END.

    IF int-ds-item-fornec.tipo-movto = 3 THEN DO: /* Exclus∆o */
       FOR EACH item-fornec WHERE 
                item-fornec.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) and
                item-fornec.cod-emitente = emitente.cod-emitente QUERY-TUNING(NO-LOOKAHEAD):
           DELETE item-fornec.
       END.

       FOR EACH item-fornec-estab WHERE 
                item-fornec-estab.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) AND
                item-fornec-estab.cod-emitente = emitente.cod-emitente QUERY-TUNING(NO-LOOKAHEAD):
           DELETE item-fornec-estab.
       END.

       FOR EACH item-fornec-umd WHERE 
                item-fornec-umd.it-codigo    = STRING(int-ds-item-fornec.pro_codigo_n) and
                item-fornec-umd.cod-emitente = emitente.cod-emitente QUERY-TUNING(NO-LOOKAHEAD):
           DELETE item-fornec-umd.
       END.
       ASSIGN int-ds-item-fornec.envio_status = 2. /* Integrado */
    END.
END.                                                                                                                         

