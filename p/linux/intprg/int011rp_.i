def var l-ok as logical no-undo.
def var i-pedido as integer no-undo.
def var de-despesas as decimal no-undo.
def var c-cfop as char no-undo.
define buffer b-estabelec for estabelec.
define temp-table tt-lote like int-ds-pedido-retorno.

i-pedido = 0.
for first estabelec fields (cod-estabel cgc cod-emitente) no-lock where 
    estabelec.cod-estabel = nota-fiscal.cod-estabel:

    if (nota-fiscal.nat-operacao begins "5" or
        nota-fiscal.nat-operacao begins "6" or
        nota-fiscal.nat-operacao begins "7") and
        nota-fiscal.esp-docto = 23 /* NFT */ then do: /* saidas */
        run pi-saidas.
    end.
end. /* estabelec */

procedure pi-saidas:
    for first int-ds-nota-saida where 
        int-ds-nota-saida.nsa-cnpj-origem-s = estabelec.cgc and
        int-ds-nota-saida.nsa-serie-s = nota-fiscal.serie AND
        int-ds-nota-saida.nsa-notafiscal-n = int(nota-fiscal.nr-nota-fis): END.


    /* inclus’o da nota */
    do transaction:

        IF tt-param.arquivo <> "" THEN DO:
            display /*stream str-rp*/
                nota-fiscal.cod-estabel
                nota-fiscal.serie
                nota-fiscal.nr-nota-fis
                nota-fiscal.dt-emis-nota
                nota-fiscal.dt-cancela
                with frame f-rel.
            down /*stream str-rp */ with frame f-rel.
        END.

        for each tt-lote. delete tt-lote. end.
        for each int-ds-pedido-retorno no-lock where
            int-ds-pedido-retorno.ped-codigo-n = int(nota-fiscal.nr-pedcli) and
            int-ds-pedido-retorno.rpp-lote <> ? and int-ds-pedido-retorno.rpp-lote <> "":
            create tt-lote.
            buffer-copy int-ds-pedido-retorno to tt-lote.

            IF estabelec.cgc = nota-fiscal.cgc THEN DO: /* Balan‡o */
            
               ASSIGN de-quantidade = int-ds-pedido-retorno.rpp-quantidade-n - int-ds-pedido-retorno.rpp-qtd-inventario-n.

               IF de-quantidade < 0 THEN
                  ASSIGN tt-lote.rpp-quantidade = de-quantidade * -1.
               ELSE
                  ASSIGN tt-lote.rpp-quantidade = de-quantidade.
            END.

        end.

        for each it-nota-fisc no-lock of nota-fiscal
            query-tuning(no-lookahead):

            for first int-ds-nota-saida-item where
                int-ds-nota-saida-item.nsa-cnpj-origem-s = estabelec.cgc AND
                int-ds-nota-saida-item.nsa-serie-s = nota-fiscal.serie and
                int-ds-nota-saida-item.nsa-notafiscal-n = int(nota-fiscal.nr-nota-fis) and
                int-ds-nota-saida-item.nsp-sequencia-n = it-nota-fisc.nr-seq-fat and
                int-ds-nota-saida-item.nsp-produto-n   = int(it-nota-fisc.it-codigo): end.

            if not avail int-ds-nota-saida-item then do:

                for first item fields (codigo-orig class-fiscal fm-codigo) no-lock where 
                    item.it-codigo = it-nota-fisc.it-codigo: end.

                create  int-ds-nota-saida-item.                        
                assign  int-ds-nota-saida-item.nsa-cnpj-origem-s       = estabelec.cgc      
                        int-ds-nota-saida-item.nsa-notafiscal-n        = integer(nota-fiscal.nr-nota-fis)                      
                        int-ds-nota-saida-item.nsa-serie-s             = nota-fiscal.serie                                     
                        int-ds-nota-saida-item.nsp-sequencia-n         = it-nota-fisc.nr-seq-fat
                        int-ds-nota-saida-item.nsp-produto-n           = int(it-nota-fisc.it-codigo)
                        int-ds-nota-saida-item.nsp-quantidade-n        = it-nota-fisc.qt-faturada[1]
                        int-ds-nota-saida-item.nsp-valorbruto-n        = it-nota-fisc.vl-merc-ori
                        int-ds-nota-saida-item.nsp-desconto-n          = it-nota-fisc.vl-desconto
                        int-ds-nota-saida-item.nsp-valorliquido-n      = it-nota-fisc.vl-merc-liq
                        int-ds-nota-saida-item.nsp-baseicms-n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int-ds-nota-saida-item.nsp-valoricms-n         = it-nota-fisc.vl-icms-it
                        int-ds-nota-saida-item.nsp-basediferido-n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int-ds-nota-saida-item.nsp-baseisenta-n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                         then it-nota-fisc.vl-icmsnt-it else 0.

                assign  int-ds-nota-saida-item.nsp-valoripi-n          = 0 /*it-nota-fisc.vl-ipi-it*/
                        int-ds-nota-saida-item.nsp-icmsst-n            = it-nota-fisc.vl-icmsub-it
                        int-ds-nota-saida-item.nsp-basest-n            = it-nota-fisc.vl-bsubs-it
                        int-ds-nota-saida-item.nsp-valortotalproduto-n = it-nota-fisc.vl-tot-item.

                assign  int-ds-nota-saida-item.nsp-percentualicms-n    = it-nota-fisc.aliquota-icm
                        int-ds-nota-saida-item.nsp-percentualipi-n     = 0 /*it-nota-fisc.aliquota-ipi*/
                        int-ds-nota-saida-item.nsp-redutorbaseicms-n   = it-nota-fisc.perc-red-icm.
                assign  int-ds-nota-saida-item.nsp-valordespesa-n      = it-nota-fisc.vl-despes-it
                        int-ds-nota-saida-item.nsp-valorpis-n          = it-nota-fisc.vl-pis
                        int-ds-nota-saida-item.nsp-valorcofins-n       = it-nota-fisc.vl-finsocial
                        int-ds-nota-saida-item.nsp-peso-n              = it-nota-fisc.peso-bruto
                        int-ds-nota-saida-item.nsp-baseipi-n           = 0 /*it-nota-fisc.vl-bipi-it*/.
                assign  int-ds-nota-saida-item.nsp-ncm-s               = if   it-nota-fisc.class-fiscal <> ""
                                                                         then it-nota-fisc.class-fiscal
                                                                         else item.class-fiscal
                        int-ds-nota-saida-item.nsp-csta-n              = item.codigo-orig
                        int-ds-nota-saida-item.nsp-valortributos-n     = int-ds-nota-saida-item.nsp-valoricms-n 
                                                                       + int-ds-nota-saida-item.nsp-valoripi-n
                                                                       + int-ds-nota-saida-item.nsp-icmsst-n
                                                                       + int-ds-nota-saida-item.nsp-valorpis-n
                                                                       + int-ds-nota-saida-item.nsp-valorcofins-n.
                run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                                   output int-ds-nota-saida-item.nsp-cstb-n,
                                   output l-sub).
                for first natur-oper no-lock where 
                    natur-oper.nat-operacao = it-nota-fisc.nat-operacao:
                    assign  int-ds-nota-saida-item.nsp-cfop-n = int(replace(natur-oper.cod-cfop,".","")).
                end.


                assign  int-ds-nota-saida-item.ped-codigo-n            = if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                         else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                         else integer(replace(nota-fiscal.docto-orig,".",""))
                        int-ds-nota-saida-item.nsp-basepis-n           = it-nota-fisc.vl-tot-item
                                                                        - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                           or  substr(item.char-1,50,5) = "Sim"
                                                                           then   it-nota-fisc.vl-pis
                                                                                + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                        - (if natur-oper.tp-oper-terc = 4
                                                                           then it-nota-fisc.vl-icmsubit-e[3]
                                                                           else it-nota-fisc.vl-icmsub-it)
                        int-ds-nota-saida-item.nsp-basecofins-n        = it-nota-fisc.vl-tot-item
                                                                        - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                           or  substr(item.char-1,50,5) = "Sim"
                                                                           then   it-nota-fisc.vl-pis
                                                                                + it-nota-fisc.vl-finsocial
                                                                           else 0)
                                                                        - (if natur-oper.tP-oper-terc = 4
                                                                           then it-nota-fisc.vl-icmsubit-e[3]
                                                                           else it-nota-fisc.vl-icmsub-it).
                /*Nao inclui o valor no IPI na base das contrib sociais*/    
                if  it-nota-fisc.cd-trib-ipi <> 3
                and not natur-oper.log-ipi-contrib-social then do:
                     assign int-ds-nota-saida-item.nsp-basepis-n = int-ds-nota-saida-item.nsp-basepis-n
                                                                   /*- it-nota-fisc.vl-ipi-it*/
                                                                   - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                      then it-nota-fisc.vl-ipiit-e[3]
                                                                      else 0).
                     assign int-ds-nota-saida-item.nsp-basecofins-n = int-ds-nota-saida-item.nsp-basecofins-n
                                                                    /*- it-nota-fisc.vl-ipi-it*/
                                                                    - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                       then it-nota-fisc.vl-ipiit-e[3]
                                                                       else 0).
                end.
                /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
                if  it-nota-fisc.cd-trib-ipi = 3 
                and substring(natur-oper.char-2,16,1) = "1":U
                and not natur-oper.log-ipi-outras-contrib-social then do:
                    assign int-ds-nota-saida-item.nsp-basepis-n = int-ds-nota-saida-item.nsp-basepis-n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                    assign int-ds-nota-saida-item.nsp-basecofins-n = int-ds-nota-saida-item.nsp-basecofins-n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                end.
                assign  int-ds-nota-saida-item.nsp-cstbpis-s           = if substr(it-nota-fisc.char-2,96,1) = "1" then "01"
                                                                         else if substr(it-nota-fisc.char-2,96,1) = "1" then "07"
                                                                         else if substr(it-nota-fisc.char-2,96,1) = "3" then "02"
                                                                         else if it-nota-fisc.idi-forma-calc-pis = 2 then "03" else "99"
                        int-ds-nota-saida-item.nsp-cstbcofins-s        = if substr(it-nota-fisc.char-2,97,1) = "1" then "01"
                                                                         else if substr(it-nota-fisc.char-2,97,1) = "1" then "07"
                                                                         else if substr(it-nota-fisc.char-2,97,1) = "3" then "02"
                                                                         else if it-nota-fisc.idi-forma-calc-cofins = 2 then "03" else "99"
                        int-ds-nota-saida-item.nsp-percentualpis-n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                else 0)
                                                                       / 10000.
                        int-ds-nota-saida-item.nsp-percentualcofins-n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                else 0)
                                                                       / 10000.
                for first fat-ser-lote no-lock of it-nota-fisc:
                    assign  int-ds-nota-saida-item.nsp-lote-s  = substring(fat-ser-lote.nr-serlote,1,10)
                            int-ds-nota-saida-item.nsp-datavalidade-d = fat-ser-lote.dt-vali-lote.
                end.

                assign  int-ds-nota-saida-item.nen-notafiscal-n = integer(it-nota-fisc.nr-docum)
                        int-ds-nota-saida-item.nen-serie-s      = it-nota-fisc.serie-docum.
                if it-nota-fisc.nr-docum <> "" then do:
                    for first rat-lote fields (sequencia) no-lock where 
                        rat-lote.serie-docto  = it-nota-fisc.nr-docum and    
                        rat-lote.nro-docto    = it-nota-fisc.serie-docum and 
                        rat-lote.nat-operacao = it-nota-fisc.nat-docum and   
                        rat-lote.cod-emitente = nota-fiscal.cod-emitente and 
                        rat-lote.sequencia    > 0 and 
                        rat-lote.it-codigo    = it-nota-fisc.it-codigo and
                        rat-lote.lote = int-ds-nota-saida-item.nsp-lote-s:
                        assign int-ds-nota-saida-item.nep-sequencia-n  = rat-lote.sequencia.
                    end.
                end.

                if int-ds-nota-saida-item.ped-codigo-n <> 0 then 
                    i-pedido = int-ds-nota-saida-item.ped-codigo-n.
                
                assign int-ds-nota-saida-item.nsp-caixa-n = int(it-nota-fisc.nr-seq-ped).
                for first cst-ped-item no-lock where
                    cst-ped-item.nome-abrev     = nota-fiscal.nome-ab-cli and
                    cst-ped-item.nr-pedcli      = it-nota-fisc.nr-pedcli  and
                    cst-ped-item.nr-sequencia   = it-nota-fisc.nr-seq-ped and
                    cst-ped-item.it-codigo      = it-nota-fisc.it-codigo  and
                    cst-ped-item.cod-refer      = it-nota-fisc.cod-refer:
                    assign int-ds-nota-saida-item.nsp-lote-s = cst-ped-item.numero-lote.
                end.
                if not avail cst-ped-item then do:
                    l-ok = no.
                    for first tt-lote where 
                        tt-lote.ppr-produto-n  = int-ds-nota-saida-item.nsp-produto-n   and
                        tt-lote.rpp-quantidade = int-ds-nota-saida-item.nsp-quantidade  and
                        /* uma nota por caixa - caixa informada na nota */
                        tt-lote.rpp-caixa      = int-ds-nota-saida-item.nsp-caixa       and
                        tt-lote.rpp-lote      <> ?                                      and
                        tt-lote.rpp-lote      <> "":
                        assign int-ds-nota-saida-item.nsp-lote = tt-lote.rpp-lote
                               l-ok = yes.
                        delete tt-lote.
                    end.
                    /* notas fiscais sem caixa */
                    if not l-ok then
                        for first tt-lote where 
                            tt-lote.ppr-produto-n  = int-ds-nota-saida-item.nsp-produto-n   and
                            tt-lote.rpp-quantidade = int-ds-nota-saida-item.nsp-quantidade  and
                            tt-lote.rpp-lote      <> ?                                      and
                            tt-lote.rpp-lote      <> "":
                            assign int-ds-nota-saida-item.nsp-lote = tt-lote.rpp-lote
                                   l-ok = yes.
                            delete tt-lote.
                        end.
                end.
            end.
            release int-ds-nota-saida-item.
        end.  /* it-nota-fisc */
	if not avail int-ds-nota-saida then do:
        create  int-ds-nota-saida.
        assign  int-ds-nota-saida.nsa-cnpj-origem-s   = estabelec.cgc
                int-ds-nota-saida.nsa-notafiscal-n    = integer(nota-fiscal.nr-nota-fis)
                int-ds-nota-saida.nsa-serie-s         = nota-fiscal.serie
                int-ds-nota-saida.nsa-cnpj-destino-s  = nota-fiscal.cgc
                int-ds-nota-saida.nsa-dataemissao-d   = nota-fiscal.dt-emis-nota
                int-ds-nota-saida.ped-codigo-n        = if i-pedido <> 0 then i-pedido else int(nota-fiscal.nr-pedcli).
        for first natur-oper no-lock where 
            natur-oper.nat-operacao = nota-fiscal.nat-operacao:
            assign int-ds-nota-saida.nsa-cfop-n       = integer(replace(natur-oper.cod-cfop,".","")).
        end.
        assign  int-ds-nota-saida.tipo-movto          = 1 /* inclusao */
                int-ds-nota-saida.nsa-cnpj-destino-s  = nota-fiscal.cgc
                int-ds-nota-saida.nsa-dataemissao-d   = nota-fiscal.dt-emis-nota
                int-ds-nota-saida.nsa-placaveiculo-s  = substring(replace(nota-fiscal.placa," ",""),1,7)
                int-ds-nota-saida.nsa-estadoveiculo-s = substring(replace(nota-fiscal.uf-placa," ",""),1,2)
                int-ds-nota-saida.nsa-observacao-s    = substring(nota-fiscal.observ-nota,1,4000).

        /*
        for first transporte fields (cgc) no-lock where 
            transporte.nome-abrev = nota-fiscal.nome-transp:
            assign  int-ds-nota-saida.nsa-cnpj-transportadora-s = transporte.cgc.
        end.
        */
        for each int-ds-nota-saida-item no-lock of int-ds-nota-saida:

            assign  int-ds-nota-saida.nsa-valortotalprodutos-n     = int-ds-nota-saida.nsa-valortotalprodutos-n
                                                                   + int-ds-nota-saida-item.nsp-valortotalproduto-n
                    int-ds-nota-saida.nsa-quantidade-n             = int-ds-nota-saida.nsa-quantidade-n 
                                                                   + int-ds-nota-saida-item.nsp-quantidade-n
                    int-ds-nota-saida.nsa-desconto-n               = int-ds-nota-saida.nsa-desconto-n 
                                                                   + int-ds-nota-saida-item.nsp-desconto-n
                    int-ds-nota-saida.nsa-baseicms-n               = int-ds-nota-saida.nsa-baseicms-n
                                                                   + int-ds-nota-saida-item.nsp-baseicms-n
                    int-ds-nota-saida.nsa-valoricms-n              = int-ds-nota-saida.nsa-valoricms-n
                                                                   + int-ds-nota-saida-item.nsp-valoricms-n
                    int-ds-nota-saida.nsa-basediferido-n           = int-ds-nota-saida.nsa-basediferido-n 
                                                                   + int-ds-nota-saida-item.nsp-basediferido-n
                    int-ds-nota-saida.nsa-baseisenta-n             = int-ds-nota-saida.nsa-baseisenta-n
                                                                   + int-ds-nota-saida-item.nsp-baseisenta-n
                    int-ds-nota-saida.nsa-baseipi-n                = int-ds-nota-saida.nsa-baseipi-n
                                                                   + int-ds-nota-saida-item.nsp-baseipi-n
                    int-ds-nota-saida.nsa-valoripi-n               = int-ds-nota-saida.nsa-valoripi-n 
                                                                   + int-ds-nota-saida-item.nsp-valoripi-n
                    int-ds-nota-saida.nsa-basest-n                 = int-ds-nota-saida.nsa-basest-n
                                                                   + int-ds-nota-saida-item.nsp-basest-n
                    int-ds-nota-saida.nsa-icmsst-n                 = int-ds-nota-saida.nsa-icmsst-n
                                                                   + int-ds-nota-saida-item.nsp-icmsst-n.

        end. /* int-ds-nota-saida-item */

        assign  int-ds-nota-saida.dt-geracao   = nota-fiscal.dt-emis-nota
                int-ds-nota-saida.hr-geracao   = string(time,"HH:MM:SS")
                int-ds-nota-saida.situacao     = 2.
    end.  /* not avail int-ds-nota-saida - transaction */
    /* notas de trnasferencia  - gerar entrada no destino */
    if  (nota-fiscal.nat-operacao begins "5" or
         nota-fiscal.nat-operacao begins "6" or
         nota-fiscal.nat-operacao begins "7") and 
         nota-fiscal.esp-docto = 23 and
         avail int-ds-nota-saida and
         int-ds-nota-saida.nsa-cnpj-destino-s <> int-ds-nota-saida.nsa-cnpj-origem-s then do: /* Balan‡o os CNPJ sÆo iguais -> tratado em outro ponto */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel <> "973":

            c-cfop = "".
            de-despesas = 0.
            for each int-ds-nota-saida-item no-lock of int-ds-nota-saida:
                de-despesas = de-despesas + int-ds-nota-saida-item.nsp-valordespesa-n.
                for first int-ds-nota-entrada-produto where 
                    int-ds-nota-entrada-produto.nen-cnpj-origem-s = int-ds-nota-saida.nsa-cnpj-origem-s     and
                    int-ds-nota-entrada-produto.nen-serie-s       = int-ds-nota-saida.nsa-serie-s           and
                    int-ds-nota-entrada-produto.nen-notafiscal-n  = int-ds-nota-saida.nsa-notafiscal-n      and
                    int-ds-nota-entrada-produto.nep-sequencia-n   = int-ds-nota-saida-item.nsp-sequencia-n  and
                    int-ds-nota-entrada-produto.nep-produto-n     = int-ds-nota-saida-item.nsp-produto-n    and
                    int-ds-nota-entrada-produto.nep-lote-s        = int-ds-nota-saida-item.nsp-lote-s:      end.
                if not avail int-ds-nota-entrada-produto then do:
                    create  int-ds-nota-entrada-produto.
                    assign  int-ds-nota-entrada-produto.nen-cnpj-origem-s       = int-ds-nota-saida.nsa-cnpj-origem-s   
                            int-ds-nota-entrada-produto.nen-serie-s             = int-ds-nota-saida.nsa-serie-s         
                            int-ds-nota-entrada-produto.nen-notafiscal-n        = int-ds-nota-saida.nsa-notafiscal-n    
                            int-ds-nota-entrada-produto.nep-sequencia-n         = int-ds-nota-saida-item.nsp-sequencia-n
                            int-ds-nota-entrada-produto.nep-produto-n           = int-ds-nota-saida-item.nsp-produto-n  
                            int-ds-nota-entrada-produto.nep-lote-s              = int-ds-nota-saida-item.nsp-lote-s.
                    assign  int-ds-nota-entrada-produto.nep-basecofins-n        = int-ds-nota-saida-item.nsp-basecofins-n
                            int-ds-nota-entrada-produto.nep-basediferido-n      = int-ds-nota-saida-item.nsp-basediferido-n
                            int-ds-nota-entrada-produto.nep-baseicms-n          = int-ds-nota-saida-item.nsp-baseicms-n
                            int-ds-nota-entrada-produto.nep-baseipi-n           = int-ds-nota-saida-item.nsp-baseipi-n
                            int-ds-nota-entrada-produto.nep-baseisenta-n        = int-ds-nota-saida-item.nsp-baseisenta-n
                            int-ds-nota-entrada-produto.nep-basepis-n           = int-ds-nota-saida-item.nsp-basepis-n
                            int-ds-nota-entrada-produto.nep-basest-n            = int-ds-nota-saida-item.nsp-basest-n
                            int-ds-nota-entrada-produto.nep-csta-n              = int-ds-nota-saida-item.nsp-csta-n
                            int-ds-nota-entrada-produto.nep-cstb-icm-n          = int-ds-nota-saida-item.nsp-cstb-n
                            int-ds-nota-entrada-produto.nep-cstb-ipi-n          = 0
                            int-ds-nota-entrada-produto.nep-datavalidade-d      = int-ds-nota-saida-item.nsp-datavalidade-d
                            int-ds-nota-entrada-produto.nep-icmsst-n            = int-ds-nota-saida-item.nsp-icmsst-n
                            int-ds-nota-entrada-produto.nep-lote-s              = int-ds-nota-saida-item.nsp-lote-s
                            int-ds-nota-entrada-produto.nep-percentualcofins-n  = int-ds-nota-saida-item.nsp-percentualcofins-n
                            int-ds-nota-entrada-produto.nep-percentualicms-n    = int-ds-nota-saida-item.nsp-percentualicms-n
                            int-ds-nota-entrada-produto.nep-percentualipi-n     = int-ds-nota-saida-item.nsp-percentualipi-n
                            int-ds-nota-entrada-produto.nep-percentualpis-n     = int-ds-nota-saida-item.nsp-percentualpis-n
                            int-ds-nota-entrada-produto.nep-quantidade-n        = int-ds-nota-saida-item.nsp-quantidade-n
                            int-ds-nota-entrada-produto.nep-redutorbaseicms-n   = int-ds-nota-saida-item.nsp-redutorbaseicms-n
                            int-ds-nota-entrada-produto.nep-valorbruto-n        = int-ds-nota-saida-item.nsp-valorbruto-n
                            int-ds-nota-entrada-produto.nep-valorcofins-n       = int-ds-nota-saida-item.nsp-valorcofins-n
                            int-ds-nota-entrada-produto.nep-valordesconto-n     = int-ds-nota-saida-item.nsp-desconto-n
                            int-ds-nota-entrada-produto.nep-valordespesa-n      = int-ds-nota-saida-item.nsp-valordespesa-n
                            int-ds-nota-entrada-produto.nep-valoricms-n         = int-ds-nota-saida-item.nsp-valoricms-n
                            int-ds-nota-entrada-produto.nep-valoripi-n          = int-ds-nota-saida-item.nsp-valoripi-n
                            int-ds-nota-entrada-produto.nep-valorliquido-n      = int-ds-nota-saida-item.nsp-valorliquido-n
                            int-ds-nota-entrada-produto.nep-valorpis-n          = int-ds-nota-saida-item.nsp-valorpis-n
                            int-ds-nota-entrada-produto.ped-codigo-n            = int-ds-nota-saida-item.ped-codigo-n.

                    for first item fields (codigo-orig class-fiscal fm-codigo) no-lock where 
                        item.it-codigo = trim(string(int-ds-nota-saida-item.nsp-produto-n)): end.
                    for first natur-oper fields (cod-cfop) no-lock where 
                        natur-oper.nat-operacao = nota-fiscal.nat-operacao: end.

                    c-cfop = STRING(int-ds-nota-saida.nsa-cfop-n).
                    assign int-ds-nota-entrada-produto.nen-cfop-n = int(c-cfop).
                    release int-ds-nota-entrada-produto.
                end. /* not avail int-ds-nota-saida-produto */
            end. /* int-ds-nota-saida-produto */
            for first int-ds-nota-entrada where 
                int-ds-nota-entrada.nen-cnpj-origem-s = int-ds-nota-saida.nsa-cnpj-origem-s     and
                int-ds-nota-entrada.nen-serie-s       = int-ds-nota-saida.nsa-serie-s           and
                int-ds-nota-entrada.nen-notafiscal-n  = int-ds-nota-saida.nsa-notafiscal-n:     end.
            if not avail int-ds-nota-entrada then do:
                create  int-ds-nota-entrada.
                assign  int-ds-nota-entrada.dt-geracao          = nota-fiscal.dt-emis-nota
                        int-ds-nota-entrada.hr-geracao          = string(time,"HH:MM:SS")
                        int-ds-nota-entrada.nen-basediferido-n  = int-ds-nota-saida.nsa-basediferido-n
                        int-ds-nota-entrada.nen-baseicms-n      = int-ds-nota-saida.nsa-baseicms-n
                        int-ds-nota-entrada.nen-baseipi-n       = int-ds-nota-saida.nsa-baseipi-n
                        int-ds-nota-entrada.nen-baseisenta-n    = int-ds-nota-saida.nsa-baseisenta-n
                        int-ds-nota-entrada.nen-basest-n        = int-ds-nota-saida.nsa-basest-n
                        int-ds-nota-entrada.nen-cfop-n          = int-ds-nota-saida.nsa-cfop-n
                        int-ds-nota-entrada.nen-chaveacesso-s   = nota-fiscal.cod-chave-aces-nf-eletro
                        int-ds-nota-entrada.nen-cnpj-destino-s  = int-ds-nota-saida.nsa-cnpj-destino-s
                        int-ds-nota-entrada.nen-cnpj-origem-s   = int-ds-nota-saida.nsa-cnpj-origem-s
                        int-ds-nota-entrada.nen-conferida-n     = 1
                        int-ds-nota-entrada.nen-datamovimentacao-d = int-ds-nota-saida.nsa-dataemissao-d
                        int-ds-nota-entrada.nen-dataemissao-d   = int-ds-nota-saida.nsa-dataemissao-d
                        int-ds-nota-entrada.nen-desconto-n      = int-ds-nota-saida.nsa-desconto-n
                        int-ds-nota-entrada.nen-despesas-n      = de-despesas
                        int-ds-nota-entrada.nen-frete-n         = nota-fiscal.vl-frete
                        int-ds-nota-entrada.nen-icmsst-n        = int-ds-nota-saida.nsa-icmsst-n
                        int-ds-nota-entrada.nen-modalidade-frete-n   = nota-fiscal.ind-tp-frete
                        int-ds-nota-entrada.nen-notafiscal-n         = int-ds-nota-saida.nsa-notafiscal-n
                        int-ds-nota-entrada.nen-observacao-s         = int-ds-nota-saida.nsa-observacao-s
                        int-ds-nota-entrada.nen-quantidade-n         = int-ds-nota-saida.nsa-quantidade-n
                        int-ds-nota-entrada.nen-seguro-n             = 0
                        int-ds-nota-entrada.nen-serie-s              = int-ds-nota-saida.nsa-serie-s
                        int-ds-nota-entrada.nen-valoricms-n          = int-ds-nota-saida.nsa-valoricms-n
                        int-ds-nota-entrada.nen-valoripi-n           = int-ds-nota-saida.nsa-valoripi-n
                        int-ds-nota-entrada.nen-valortotalprodutos-n = int-ds-nota-saida.nsa-valortotalprodutos-n
                        int-ds-nota-entrada.situacao                 = 2
                        int-ds-nota-entrada.tipo-movto               = 1
                        int-ds-nota-entrada.tipo-nota                = 3
                        int-ds-nota-entrada.ped-codigo-n             = int-ds-nota-saida.ped-codigo-n.

                IF tt-param.arquivo <> "" THEN DO:
                    display /*stream str-rp*/
                        estabelec.cod-estabel
                        b-estabelec.cod-estabel
                        int-ds-nota-entrada.nen-serie-s
                        int-ds-nota-entrada.nen-notafiscal-n
                        int-ds-nota-entrada.nen-dataemissao-d
                        nota-fiscal.dt-cancela
                        with frame f-rel-entrada width 300 stream-io.
                    down /*stream str-rp */ with frame f-rel-entrada.
                END.

                release int-ds-nota-entrada.
            end. /* avail int-ds-nota-entrada */
         end. /* avail b-estabelec */
    end.  /* avail int-ds-nota-saida - transaction */
end procedure.

