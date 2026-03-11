/******************************************************************************************
**  Programa: epc-bodi317im1br.p
**   
**  Objetivo: Rec lculo PIS/COFINS 
******************************************************************************************/      
{include/i-epc200.i bodi317im1br}
{cdp/cdcfgdis.i} /* Defini‡Æo dos pr‚-processadores */

define input param p-ind-event as char no-undo.
define INPUT-OUTPUT param table for tt-epc. 

def var i-seq-wt-docto as integer no-undo.
def var i-seq-wt-it-docto as integer no-undo.
def var de-fator as decimal no-undo.
def var r-rowid as rowid no-undo.

if p-ind-event  = "after_atualizaInformacoesPISCOFINS" 
then do:    

    i-seq-wt-docto = ?.
    i-seq-wt-it-docto = ?.
    for first tt-epc where 
        tt-epc.cod-event     = p-ind-event and   
        tt-epc.cod-parameter = "seq_wt_docto": 
        assign i-seq-wt-docto = int(tt-epc.val-parameter).
    end.
    for first tt-epc where 
        tt-epc.cod-event     = p-ind-event and   
        tt-epc.cod-parameter = "seq_wt_it_docto": 
        assign i-seq-wt-it-docto = int(tt-epc.val-parameter).
        for first wt-it-docto where
            wt-it-docto.seq-wt-docto    = i-seq-wt-docto    and
            wt-it-docto.seq-wt-it-docto = i-seq-wt-it-docto:
            
            for first natur-oper fields (nat-operacao mercado perc-pis per-fin-soc char-1)
                no-lock where natur-oper.nat-operacao = wt-it-docto.nat-operacao: end.
            for first item fields (char-2 it-codigo)
                no-lock where item.it-codigo = wt-it-docto.it-codigo: end.

            /* Tributa‡Æo PIS    */ 
            overlay(wt-it-docto.char-2,96,1) = (substr(natur-oper.char-1,86,1)).

            /* Aliquota PIS      */ 
            overlay(wt-it-docto.char-2,76,5) = "00,00".
            if int(substring(wt-it-docto.char-2,96,1)) = 1 then do:
                if natur-oper.mercado = 1 then                         /* Mercado Interno */
                    if substr(item.char-2,52,1) = "1" then             /* Al¡quota do Item */
                        overlay(wt-it-docto.char-2,76,5) = string(dec(substr(item.char-2,31,5)),"99.99").
                    else /* aliquota da natureza*/
                        overlay(wt-it-docto.char-2,76,5) = string(natur-oper.perc-pis[1],"99.99").
                else  /* Mercado externo */
                    overlay(wt-it-docto.char-2,76,5) = string(natur-oper.perc-pis[2],"99.99").
            end.
            /* sem aliquota deve ficar como isento */
            if dec(substring(wt-it-docto.char-2,76,5)) = 0 then do:
                overlay(wt-it-docto.char-2,96,1) = "2".
                overlay(wt-it-docto.char-2,76,5) = "00,00".
            end.


            /* Tributa‡Æo COFINS */
            overlay(wt-it-docto.char-2,97,1) = (substr(natur-oper.char-1,87,1)).

            /* Aliquota COFINS   */ 
            overlay(wt-it-docto.char-2,81,5) = "00,00".
            if int(substring(wt-it-docto.char-2,97,1)) = 1 then do:
                if natur-oper.mercado = 1 then                    /* Mercado Interno */               
                    if substr(item.char-2,53,1) = "1" then        /* aliquota do item */
                        overlay(wt-it-docto.char-2,81,5) = string(dec(substr(item.char-2,36,5)),"99.99").
                    else /* aliquota da natureza*/
                        overlay(wt-it-docto.char-2,81,5) = string(natur-oper.per-fin-soc[1],"99.99").
                else /* Mercado externo */ 
                    overlay(wt-it-docto.char-2,81,5) = string(natur-oper.per-fin-soc[2],"99.99").
            end.
            /* sem aliquota deve ficar como isento */
            if dec(substring(wt-it-docto.char-2,81,5)) = 0 then do:
                overlay(wt-it-docto.char-2,97,1) = "2" .
                overlay(wt-it-docto.char-2,81,5) = "00,00".
            end.

            overlay(wt-it-docto.char-2,86,5)  /* Redu‡Æo PIS       */ = "00,00".
            overlay(wt-it-docto.char-2,91,5)  /* Redu‡Æo COFINS    */ = "00,00".

            &if "{&bf_dis_versao_ems}" >= "2.09" &then 
                ASSIGN wt-it-docto.val-base-PIS-substto    = 0 /* base-pis-st    */ 
                       wt-it-docto.val-base-cofins-substto = 0 /* base-cofins-st */ 
                       wt-it-docto.val-aliq-pis-st         = 0 /* aliq-cofins-st */ 
                       wt-it-docto.Val-aliq-cofins-st      = 0./* aliq-pis-st    */ 
            &else
                    OVERLAY(wt-it-docto.char-1,98,15)  = "0". /* base-pis-st    */ 
                    OVERLAY(wt-it-docto.char-1,113,15) = "0". /* base-cofins-st */ 
                    OVERLAY(wt-it-docto.char-1,162,9) = "0". /* aliq-cofins-st */ 
                    OVERLAY(wt-it-docto.char-1,171,9) = "0". /* aliq-pis-st    */ 
            &endif   

        end.
    end.
end. 

if p-ind-event  = "beforecalculaImpostosBrasil" or p-ind-event = "afterCalculaImpostosBrasil" or
   p-ind-event  = "ControlaAgenteRetencao":U
then do:    
    /*put unformatted p-ind-event skip(2).*/
    i-seq-wt-docto = ?.
    r-rowid = ?.
    for each tt-epc where 
        tt-epc.cod-event = p-ind-event:
        if tt-epc.cod-parameter = "seq_wtdocto" or tt-epc.cod-parameter = "seq-wt-docto" then 
            assign i-seq-wt-docto = int(tt-epc.val-parameter).
        if tt-epc.cod-parameter = "Rowid_wt-docto" then 
            assign r-rowid = to-rowid(tt-epc.val-parameter).
    end.
    
    if i-seq-wt-docto <> ? then 
        find wt-docto where wt-docto.seq-wt-docto = i-seq-wt-docto no-error.
    else 
        find wt-docto where rowid(wt-docto) = r-rowid no-error.

    if not avail wt-docto then return "OK".

    /* c¢pia valore originais quando devolu‡Æo a fornecedor loja */
    {intupc/epc-bodi317im1br.i}

end. /* beforecalculaimpostosbrasil */

return "OK".
     
