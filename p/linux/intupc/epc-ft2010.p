/******************************************************************************************
**  Programa: epc-ft2010.p
**   
**  Objetivo: Rec lculo PIS/COFINS 
******************************************************************************************/      
          
{include/i-epc200.i ft2010}

define input param p-ind-event as char no-undo.
define INPUT-OUTPUT param table for tt-epc. 

def var c-rowid as char no-undo.

if p-ind-event  = "Single-Point"
then do:    
    for first tt-epc where 
        tt-epc.cod-event     = p-ind-event and   
        tt-epc.cod-parameter = "nota-fiscal rowid"
        query-tuning(no-lookahead): 
        assign c-rowid = tt-epc.val-parameter.
    end.
    for first nota-fiscal where 
        rowid(nota-fiscal) = to-rowid(c-rowid)
        query-tuning(no-lookahead):

        /* estabelecimento Procfit */
        if nota-fiscal.cod-estabel <> "973" and
           not nota-fiscal.observ-nota matches "*Pedido Estorno*" and
           not nota-fiscal.observ-nota matches "*Pedido Balan*"   then
        for each cst_estabelec no-lock where 
            cst_estabelec.cod_estabel = nota-fiscal.cod-estabel and
            cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota
            query-tuning(no-lookahead):
            if  cst_estabelec.dt_inicio_oper <> ? and 
                cst_estabelec.dt_inicio_oper <= nota-fiscal.dt-emis-nota then
                return "OK".
        end.

        /* Acertos notas Oblak */
        for each it-nota-fisc of nota-fiscal
            query-tuning(no-lookahead):
            
            for first natur-oper fields (nat-operacao mercado perc-pis per-fin-soc char-1)
                no-lock where natur-oper.nat-operacao = it-nota-fisc.nat-operacao
                query-tuning(no-lookahead): end.
            for first item fields (char-2 it-codigo)
                no-lock where item.it-codigo = it-nota-fisc.it-codigo
                query-tuning(no-lookahead): end.

            /* Tributa‡Æo PIS    */ 
            overlay(it-nota-fisc.char-2,96,1) = (substr(natur-oper.char-1,86,1)).

            /* Aliquota PIS      */ 
            overlay(it-nota-fisc.char-2,76,5) = "00,00".
            if int(substring(it-nota-fisc.char-2,96,1)) = 1 then do:
                if natur-oper.mercado = 1 then                         /* Mercado Interno */
                    if substr(item.char-2,52,1) = "1" then             /* Al¡quota do Item */
                        overlay(it-nota-fisc.char-2,76,5) = string(dec(substr(item.char-2,31,5)),"99.99").
                    else /* aliquota da natureza*/
                        overlay(it-nota-fisc.char-2,76,5) = string(natur-oper.perc-pis[1],"99.99").
                else  /* Mercado externo */
                    overlay(it-nota-fisc.char-2,76,5) = string(natur-oper.perc-pis[2],"99.99").
            end.
            /* sem aliquota deve ficar como isento */
            if dec(substring(it-nota-fisc.char-2,76,5)) = 0 then
                overlay(it-nota-fisc.char-2,96,1) = "2".

            /* Tributa‡Æo COFINS */
            overlay(it-nota-fisc.char-2,97,1) = (substr(natur-oper.char-1,87,1)).

            /* Aliquota COFINS   */ 
            overlay(it-nota-fisc.char-2,81,5) = "00,00".
            if int(substring(it-nota-fisc.char-2,97,1)) = 1 then do:
                if natur-oper.mercado = 1 then                    /* Mercado Interno */               
                    if substr(item.char-2,53,1) = "1" then        /* aliquota do item */
                        overlay(it-nota-fisc.char-2,81,5) = string(dec(substr(item.char-2,36,5)),"99.99").
                    else /* aliquota da natureza*/
                        overlay(it-nota-fisc.char-2,81,5) = string(natur-oper.per-fin-soc[1],"99.99").
                else /* Mercado externo */ 
                    overlay(it-nota-fisc.char-2,81,5) = string(natur-oper.per-fin-soc[2],"99.99").
            end.
            /* sem aliquota deve ficar como isento */
            if dec(substring(it-nota-fisc.char-2,81,5)) = 0 then 
                overlay(it-nota-fisc.char-2,97,1) = "2" .

            overlay(it-nota-fisc.char-2,86,5)  /* Redu‡Æo PIS       */ = "00,00".
            overlay(it-nota-fisc.char-2,91,5)  /* Redu‡Æo COFINS    */ = "00,00".

            &if "{&bf_dis_versao_ems}" >= "2.09" &then 
                ASSIGN it-nota-fisc.val-base-PIS-substto    = 0 /* base-pis-st    */ 
                       it-nota-fisc.val-base-cofins-substto = 0 /* base-cofins-st */ 
                       it-nota-fisc.val-aliq-pis-st         = 0 /* aliq-cofins-st */ 
                       it-nota-fisc.Val-aliq-cofins-st      = 0./* aliq-pis-st    */ 
            &else
                &if "{&bf_dis_versao_ems}" >= "2.08" &then
                    ASSIGN it-nota-fisc.val-base-PIS-substto    = 0 /* base-pis-st    */ 
                           it-nota-fisc.val-base-cofins-substto = 0. /* base-cofins-st */ 
                &else
                    OVERLAY(it-nota-fisc.char-1,98,15)  = "0". /* base-pis-st    */ 
                    OVERLAY(it-nota-fisc.char-1,113,15) = "0". /* base-cofins-st */ 
                &endif
                
                OVERLAY(it-nota-fisc.char-1,162,9) = "0". /* aliq-cofins-st */ 
                OVERLAY(it-nota-fisc.char-1,171,9) = "0". /* aliq-pis-st    */ 
        
            &endif   

        end.
    end.
end. 

return "OK".
     
