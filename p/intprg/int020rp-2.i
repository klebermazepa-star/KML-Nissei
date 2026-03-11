/*******************************************************
**
**  INT020RP.I - Include do programa INT020RP.P
**
*******************************************************/

        if int_ds_nota_loja.tipo_movto <> 1 then next.
        
        ASSIGN i-cupom = i-cupom + 1.

        if i-nr-registro mod 100 = 0 then
            run pi-acompanhar in h-acomp (input "Lendo Cupom: " + string(i-cupom)).
        assign  de-vl-tot-cup       = 0
                de-vl-liq           = 0
                l-cupom-com-erro    = no
                c-estado            = ""
                c-cidade            = ""
                c-condipag          = ""
                c-convenio          = ""
                i-cod-portador      = 0
                i-modalidade        = 0
                c-serie             = ""
                de-valor-dinh       = 0
                de-valor-cartaod    = 0
                de-valor-cartaoc    = 0
                de-valor-vale       = 0
                c-status            = ""
                i-cod-mensagem      = 0
                c-orgao             = ""
                c-categoria         = "".

        assign  i-tab-finan         = ?
                i-indice            = ?
                i-cod-vencto        = ?
                i-prazos            = ?
                de-per-pg-dup       = ?
                i-num-parcelas      = ?.

        assign  c-natur             = ""
                i-cod-cond-pag      = ?
                i-cod-portador      = ?
                i-modalidade        = ?
                c-serie             = ""
                c-cod-esp-princ     = "".

        assign  c-num-nota          = if trim(int_ds_nota_loja.num_identi) begins "CONT" 
                                      then trim(string(int(int_ds_nota_loja.cupom_ecf),">>>9999999"))
                                      else trim(string(int(int_ds_nota_loja.num_nota),">>>9999999"))
                d-dt-implantacao    = today
                d-dt-emissao        = int_ds_nota_loja.emissao
                de-valor-dinh       = int_ds_nota_loja.Valor_din_mov
                de-valor-cartaod    = int_ds_nota_loja.valor_cartaod
                de-valor-cartaoc    = int_ds_nota_loja.valor_cartaoc
                de-valor-vale       = int_ds_nota_loja.valor_vale
                de-vl-tot-cup       = int_ds_nota_loja.valor_total
                c-condipag          = trim(string(int(int_ds_nota_loja.condipag),">>>99"))
                c-convenio          = if int(int_ds_nota_loja.convenio) > 0 then "S" else "N"
                c-serie             = trim(int_ds_nota_loja.serie)
                c-status            = trim(int_ds_nota_loja.istatus)
                c-orgao             = if trim(int_ds_nota_loja.orgao) <> ? then trim(int_ds_nota_loja.orgao) else ""
                c-categoria         = if trim(int_ds_nota_loja.categoria) <> ? then trim(int_ds_nota_loja.categoria) else "" .
                .

        assign i-nr-registro = i-nr-registro + 1.
        /* processa cupom atual */
        run valida-registro-cabecalho.

        assign  c-it-codigo         = ""
                de-quantidade       = 0
                de-vl-uni           = 0
                de-desconto         = 0
                c-class-fiscal      = ""
                l-saldo-neg         = no.

        if not l-cupom-com-erro then
        for each  int_ds_nota_loja_item NO-LOCK of int_ds_nota_loja
            query-tuning(no-lookahead)
            break by int_ds_nota_loja_item.num_nota
                    by int_ds_nota_loja_item.sequencia
                      by int_ds_nota_loja_item.produto:

            assign  c-it-codigo         = trim(string(int(int_ds_nota_loja_item.produto)))
                    de-quantidade       = int_ds_nota_loja_item.quantidade
                    de-vl-uni           = int_ds_nota_loja_item.preco_unit
                                          /* retirando gambiarras de desconto para produtos em cortesia - OBLAK */
                    de-vl-liq           = if int_ds_nota_loja_item.desconto = 100 and
                                             int_ds_nota_loja_item.tipo_desco = "P" and
                                             int_ds_nota_loja_item.preco_liqu = 0.01 
                                          then 0
                                          else int_ds_nota_loja_item.preco_liqu
                                        /*/ int_ds_nota_loja_item.quantidade*/
                    de-desconto         = /*int_ds_nota_loja_item.desconto*/ 
                                           ((de-vl-uni - de-vl-liq) / de-vl-uni) * 100
                    c-numero-lote       = if trim(int_ds_nota_loja_item.lote) <> ? and
                                             trim(int_ds_nota_loja_item.lote) <> "?" then 
                                             trim(int_ds_nota_loja_item.lote) else ""
                    i-nr-seq-item       = int(int_ds_nota_loja_item.sequencia) * 10
                    de-aliq-icms        = int_ds_nota_loja_item.aliq_icms
                    de-base-icms        = if de-vl-liq = 0 then 0
                                          else int_ds_nota_loja_item.base_icms
                    de-valor-icms       = if int_ds_nota_loja_item.trib_icms = "1" OR
                                             int_ds_nota_loja_item.trib_icms = "3" 
                                          then ((de-aliq-icms * de-base-icms) / 100)
                                          else 0
                    c-trib-icms         = trib_icms
                    de-red-base-icm     = TrataNuloDec (int_ds_nota_loja_item.redutorbaseicms).

            /* ICMS Procfit vem preenchido */
            if d-dt-procfit <= d-dt-emissao then do:
                assign de-valor-icms = if TrataNuloDec(int_ds_nota_loja_item.valoricms) > 0 
                                       then int_ds_nota_loja_item.valoricms else de-valor-icms.
                if  TrataNuloDec(de-base-icms) = 0 and de-vl-liq > 0 
                then do:
                    assign i-erro = 58
                           c-informacao = "S‚rie: " + c-serie + " - " + "Cupom: " + c-num-nota + " - " + "Item: " + c-it-codigo + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial)
                                          + " Base ICMS: " + string(TrataNuloDec(de-base-icms),">9.99")
                           l-cupom-com-erro = yes.
                    run gera-log. 
                end.
            end.

            run valida-registro-item.        
            if l-cupom-com-erro then next.
            if not can-find (first tt-docto no-lock where 
                tt-docto.cod-estabel = c-cod-estabel and
                tt-docto.serie       = c-serie and
                tt-docto.nr-nota     = c-num-nota) then do:
                run cria-tt-docto.
            end.
            run cria-tt-it-docto.
        end. /*  int_ds_nota_loja_item */
        for first tt-it-docto no-lock where 
            tt-it-docto.nr-nota     = c-num-nota    and
            tt-it-docto.cod-estabel = c-cod-estabel and
            tt-it-docto.serie       = c-serie
            query-tuning(no-lookahead):      end.
        if not l-cupom-com-erro and not avail tt-it-docto then do:
            assign i-erro = 37
                   c-informacao = "Est: " + c-cod-estabel + " - " + "S‚rie: " + c-serie + " - " + "Cupom: " + c-num-nota + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial)
                   l-cupom-com-erro = yes.
            run gera-log. 
        end.
        for each tt-it-docto no-lock where 
            tt-it-docto.nr-nota     = c-num-nota    and
            tt-it-docto.cod-estabel = c-cod-estabel and
            tt-it-docto.serie       = c-serie       and
            tt-it-docto.baixa-estoq
            query-tuning(no-lookahead):
            for first tt-saldo-estoq no-lock where 
                tt-saldo-estoq.seq-tt-saldo-estoq = tt-it-docto.seq-tt-it-docto and
                tt-saldo-estoq.seq-tt-it-docto    = tt-it-docto.seq-tt-it-docto and
                tt-saldo-estoq.it-codigo          = tt-it-docto.it-codigo       and
                tt-saldo-estoq.cod-depos          = "LOJ"                       and
                tt-saldo-estoq.cod-localiz        = ""
                query-tuning(no-lookahead): end.
            if not avail tt-saldo-estoq then do:
                assign i-erro = 52
                       c-informacao = "S‚rie: " + c-serie + " - " + "Cupom: " + c-num-nota + " - " + "Item: " + tt-it-docto.it-codigo + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial)
                       l-cupom-com-erro = yes.
                run gera-log. 
            end.
        end.
        if not l-cupom-com-erro then run gera-duplicatas.
        if l-cupom-com-erro then run apaga-registro-atual.
        /* alterado para 900 para reduzir system error de muitos ¡ndices */
        if i-nr-registro mod 900 = 0 then do:
            run importa-nota.
        end.
