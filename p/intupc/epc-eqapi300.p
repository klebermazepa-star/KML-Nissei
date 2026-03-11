/******************************************************************************
**
**     Programa: epc-eqapi300.p
**
**     Objetivo: Chamada EPC na API EQAPI300 para de Pedidos
**
**     Autor...: Alessandro V. Baccin 
**
**     Vers∆o..: 1.00.00.001 - 05/01/2016
**
******************************************************************************/
{utp/ut-glob.i}
{include/i-epc200.i} /* definicao tt-epc */

defin input        param p-ind-event  as char          no-undo.
defin input-output param table for tt-epc.



/* ------- Variaveis Locais ------------- */
def var r-rowid-estoque as rowid no-undo.
def var r-rowid-ped-ent as rowid no-undo.
def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo NO-UNDO.

IF v_cdn_empres_usuar = "1" THEN DO:


    if p-ind-event = "BEGIN_PI-ALOCA-SALDO-MAN" then do:

        assign r-rowid-estoque = ?.
        for first tt-epc no-lock where 
            tt-epc.cod-event     = p-ind-event and   
            tt-epc.cod-parameter = "ROWID_saldo-estoq":
            assign r-rowid-estoque = to-rowid(tt-epc.val-parameter).
        end.
        assign r-rowid-ped-ent = ?.
        for first tt-epc no-lock where 
            tt-epc.cod-event     = p-ind-event and   
            tt-epc.cod-parameter = "ROWID_ped-ent":
            assign r-rowid-ped-ent = to-rowid(tt-epc.val-parameter).
        end.

        for first ped-ent no-lock where 
            rowid(ped-ent) = r-rowid-ped-ent:

            /* para itens com controle por lote, verifica lote retornado pelo WMS e 
               zera saldo utilizado se for lote diferente do separado */
            for first item fields (it-codigo tipo-con-est) no-lock where 
                item.it-codigo = ped-ent.it-codigo and
                item.tipo-con-est = 3 /* lote */:
                for first saldo-estoq 
                    fields (lote)
                    no-lock where 
                    rowid(saldo-estoq) = r-rowid-estoque:
                    for first cst_ped_item NO-LOCK WHERE 
                              cst_ped_item.nome_abrev   = ped-ent.nome-abrev   AND 
                              cst_ped_item.nr_sequencia = ped-ent.nr-sequencia AND
                              cst_ped_item.nr_pedcli    = ped-ent.nr-pedcli    AND 
                              cst_ped_item.it_codigo    = ped-ent.it-codigo    AND
                              cst_ped_item.cod_refer    = ped-ent.cod-refer:
                        if  trim(cst_ped_item.numero_lote) <> trim(saldo-estoq.lote) or
                            ped-ent.qt-pedida > (saldo-estoq.qtidade-atu - 
                                                 saldo-estoq.qt-alocada -
                                                 saldo-estoq.qt-aloc-ped)
                        then do:
                            for first tt-epc no-lock where 
                                tt-epc.cod-event     = p-ind-event and   
                                tt-epc.cod-parameter = "Value_of_de-saldo":
                                assign tt-epc.val-parameter = "0".
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.
END.
return "OK".

