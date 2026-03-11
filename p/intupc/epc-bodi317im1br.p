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
DEFINE VARIABLE de-base-icmsst-fp AS DECIMAL     NO-UNDO.
DEFINE BUFFER b-preco-item FOR ems2dis.preco-item.

DEFINE VARIABLE de-reducaopmc AS DECIMAL     NO-UNDO.


.MESSAGE "entrou BODI" VIEW-AS ALERT-BOX INFORMATION button ok.

if p-ind-event  = "after_atualizaInformacoesPISCOFINS" 
then do:

    .MESSAGE "entrou IF p-ind-event 1" VIEW-AS ALERT-BOX INFORMATION button ok.

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
    
    .MESSAGE "entrou p-ind-event 2" VIEW-AS ALERT-BOX INFORMATION button ok.
    /*put unformatted p-ind-event skip(2).*/
    i-seq-wt-docto = ?.
    r-rowid = ?.
    for each tt-epc where 
        tt-epc.cod-event = p-ind-event:
        
        .MESSAGE "entrou epc" VIEW-AS ALERT-BOX INFORMATION button ok.
        
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
    
    .MESSAGE "entrou if not availwt-docto then return OK " VIEW-AS ALERT-BOX INFORMATION button ok.

    /* c¢pia valore originais quando devolu‡Æo a fornecedor loja */
    {intupc/epc-bodi317im1br.i}

    IF  (wt-docto.estado       = "PR"  or wt-docto.estado = "DF" )
    AND CAN-FIND(FIRST estabelec NO-LOCK
                 WHERE estabelec.cod-estabel = wt-docto.cod-estabel
                 AND   estabelec.estado      = "PR" or estabelec.estado = "DF") THEN DO:
                 
        .MESSAGE "entrou IF PR or DF" VIEW-AS ALERT-BOX INFORMATION button ok.         

        FOR EACH wt-it-docto NO-LOCK 
            WHERE wt-it-docto.seq-wt-docto = wt-docto.seq-wt-docto
              /*AND wt-it-docto.nat-operacao = "5409a5" */,
            FIRST item-uf NO-LOCK
            WHERE item-uf.it-codigo = wt-it-docto.it-codigo
            /*AND   item-uf.cod-estado-orig = "SC"
            AND   item-uf.estado          = "PR"*/,
            EACH wt-it-imposto EXCLUSIVE-LOCK
            WHERE wt-it-imposto.seq-wt-docto    = wt-it-docto.seq-wt-docto   
            AND   wt-it-imposto.seq-wt-it-docto = wt-it-docto.seq-wt-it-docto
            AND   wt-it-imposto.ind-icm-ret     = YES
            AND   wt-it-imposto.vl-bsubs-it     > 0:

            ASSIGN de-reducaopmc = 0.


		    ASSIGN wt-it-imposto.vl-bsubs-it  = ROUND((wt-it-imposto.vl-bicms-it) * (1 + item-uf.per-sub-tri / 100),2)
                   wt-it-imposto.vl-icmsub-it = ROUND((wt-it-imposto.vl-bsubs-it * item-uf.dec-1 / 100) - wt-it-imposto.vl-icms-it,2)
                   wt-it-imposto.dec-1        = item-uf.per-sub-tri.

            .MESSAGE "6" SKIP
                    "wt-it-imposto.vl-bsubs-it  - " wt-it-imposto.vl-bsubs-it    skip 
                    "wt-it-imposto.vl-icmsub-it - " wt-it-imposto.vl-icmsub-it   skip 
                    "wt-it-imposto.dec-1        - " wt-it-imposto.dec-1        
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
                IF wt-it-imposto.vl-icmsub-it < 0 THEN
                    ASSIGN wt-it-imposto.vl-bsubs-it  = 0
                           wt-it-imposto.vl-icmsub-it = 0
                           wt-it-imposto.dec-1        = 0.


            FIND FIRST ems2dis.preco-item NO-LOCK
                WHERE preco-item.nr-tabpre = "PR-FP"
                  AND preco-item.it-codigo = wt-it-docto.it-codigo 
                  AND preco-item.situacao  = 1 NO-ERROR.

            IF AVAIL preco-item THEN DO:

                    .MESSAGE "5 - achou pr-fp" SKIP
                            "wt-it-imposto.vl-bsubs-it  - " wt-it-imposto.vl-bsubs-it    skip 
                            "wt-it-imposto.vl-icmsub-it - " wt-it-imposto.vl-icmsub-it   skip 
                            "wt-it-imposto.dec-1        - " wt-it-imposto.dec-1        
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                ASSIGN wt-it-imposto.vl-bsubs-it  = ROUND(preco-item.preco-venda * wt-it-docto.quantidade[1],2)
                       wt-it-imposto.vl-icmsub-it = ROUND((wt-it-imposto.vl-bsubs-it * item-uf.dec-1 / 100) - wt-it-imposto.vl-icms-it,2)
                       wt-it-imposto.dec-1        = item-uf.per-sub-tri.

            END.
            ELSE DO:               
                .MESSAGE "entrou ELSE 1" VIEW-AS ALERT-BOX INFORMATION button ok.
                        
                FOR FIRST b-preco-item
                    WHERE b-preco-item.nr-tabpre    = "PR12"
                    AND   b-preco-item.it-codigo    = wt-it-docto.it-codigo
                    AND   b-preco-item.situacao     = 1 /* ATIVO */
                    BY b-preco-item.dt-inival DESC:

                    FIND FIRST ems2dis.tb-preco NO-LOCK
                        WHERE tb-preco.nr-tabpre = "PR12" NO-ERROR.
                    IF AVAIL tb-preco AND substring(tb-preco.char-1, 120, 6) <> "" THEN DO:

                        ASSIGN de-reducaopmc = (b-preco-item.preco-venda * DEC(substring(tb-preco.char-1, 120, 6)) / 100)  * wt-it-docto.quantidade[1].

                    END.

                    IF b-preco-item.preco-venda  <> 0 THEN DO:
                        ASSIGN wt-it-imposto.vl-bsubs-it  = ROUND(b-preco-item.preco-venda * wt-it-docto.quantidade[1],2) 
                               wt-it-imposto.vl-bsubs-it  = wt-it-imposto.vl-bsubs-it - ((wt-it-imposto.vl-bsubs-it * item-uf.perc-red-sub) / 100)
                               wt-it-imposto.vl-icmsub-it = ROUND((wt-it-imposto.vl-bsubs-it * item-uf.dec-1 / 100) - wt-it-imposto.vl-icms-it,2)
                               wt-it-imposto.dec-1        = item-uf.per-sub-tri.

                        IF wt-it-imposto.vl-icmsub-it < de-reducaopmc THEN DO:

                            ASSIGN wt-it-imposto.vl-icmsub-it = de-reducaopmc.

                        END.
                    END.

                    
                  
                    .MESSAGE "4 fora IF e ELSE" SKIP
                            "wt-it-imposto.vl-bsubs-it  - " wt-it-imposto.vl-bsubs-it    skip 
                            "wt-it-imposto.vl-icmsub-it - " wt-it-imposto.vl-icmsub-it   skip 
                            "item-uf.val-icms-est-subt - " item-uf.val-icms-est-subt SKIP 
                            "item-uf.cod-estado-orig - " item-uf.cod-estado-orig      skip
                            "item-uf.estado          - " item-uf.estado               skip
                            "wt-it-imposto.vl-icms-it - " wt-it-imposto.vl-icms-it    skip
                            "wt-it-imposto.dec-1        - " wt-it-imposto.dec-1        
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    //NEXT.
                END.

                .MESSAGE "entrou ELSE PAUTA" skip
                b-preco-item.nr-tabpre skip
                b-preco-item.it-codigo skip
                b-preco-item.situacao  
    
                VIEW-AS ALERT-BOX INFORMATION button ok.
                
                
                FOR FIRST b-preco-item
                       WHERE b-preco-item.nr-tabpre = STRING("PAUTA " + STRING(wt-docto.estado))
                       AND   b-preco-item.it-codigo = wt-it-docto.it-codigo
                       AND   b-preco-item.situacao  = 1 /* ATIVO */ 
                       BY b-preco-item.dt-inival DESC:
                   
                       .MESSAGE "entrou PAUTA" VIEW-AS ALERT-BOX INFORMATION button ok.
                       
                           .MESSAGE "3 - achou PAUTA" SKIP
                                   "wt-it-imposto.vl-bsubs-it - " wt-it-imposto.vl-bsubs-it SKIP
                                   " val-icms-est-subt- "  val-icms-est-subt SKIP
                                   "wt-it-imposto.vl-icms-it - " wt-it-imposto.vl-icms-it SKIP
                                   "wt-it-docto.quantidade[1] - " wt-it-docto.quantidade[1]
                               VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                           IF b-preco-item.preco-venda  <> 0 THEN DO:
                               ASSIGN wt-it-imposto.vl-bsubs-it  = ROUND(b-preco-item.preco-venda * wt-it-docto.quantidade[1],2)
                                      wt-it-imposto.vl-icmsub-it = ROUND((wt-it-imposto.vl-bsubs-it * item-uf.dec-1 / 100) - wt-it-imposto.vl-icms-it,2)
                                      wt-it-imposto.dec-1        = item-uf.per-sub-tri.
                           END.
                         
                           .MESSAGE "2" SKIP
                                   "wt-it-imposto.vl-bsubs-it  - " wt-it-imposto.vl-bsubs-it    skip 
                                   "wt-it-imposto.vl-icmsub-it - " wt-it-imposto.vl-icmsub-it   skip 
                                   "wt-it-imposto.dec-1        - " wt-it-imposto.dec-1        
                               VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                   END.

            END. 

        
            IF wt-it-imposto.vl-icmsub-it <= 0 THEN
                ASSIGN wt-it-imposto.vl-bsubs-it  = 0
                       wt-it-imposto.vl-icmsub-it = 0
                       wt-it-imposto.dec-1        = 0.

            .MESSAGE "1 -  fim" SKIP
                    "wt-it-imposto.vl-bsubs-it  - " wt-it-imposto.vl-bsubs-it    skip 
                    "wt-it-imposto.vl-icmsub-it - " wt-it-imposto.vl-icmsub-it   skip 
                    "wt-it-imposto.dec-1        - " wt-it-imposto.dec-1        
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        END.
    END.
    

end. /* beforecalculaimpostosbrasil */

return "OK".
     
