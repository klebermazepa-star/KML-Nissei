/*******************************************************
**
**  INT020RP.I - Include do programa INT020RP.P
**
*******************************************************/

        if int-ds-nota-loja.tipo-movto <> 1 then next.
        
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
                i-cod-mensagem      = 0 .

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

        assign  c-num-nota          = if trim(int-ds-nota-loja.num_identi) begins "CONT" 
                                      then trim(string(int(int-ds-nota-loja.cupom_ecf),">>>9999999"))
                                      else trim(string(int(int-ds-nota-loja.num_nota),">>>9999999"))
                d-dt-implantacao    = today
                d-dt-emissao        = int-ds-nota-loja.emissao
                de-valor-dinh       = int-ds-nota-loja.Valor_din_mov
                de-valor-cartaod    = int-ds-nota-loja.valor_cartaod
                de-valor-cartaoc    = int-ds-nota-loja.valor_cartaoc
                de-valor-vale       = int-ds-nota-loja.valor_vale
                de-vl-tot-cup       = int-ds-nota-loja.valor_total
                c-condipag          = int-ds-nota-loja.condipag
                c-convenio          = if int(int-ds-nota-loja.convenio) > 0 then "S" else "N"
                c-serie             = int-ds-nota-loja.serie
                c-status            = trim(int-ds-nota-loja.istatus).

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
        for each int-ds-nota-loja-item NO-LOCK of int-ds-nota-loja
            query-tuning(no-lookahead)
            break by int-ds-nota-loja-item.num_nota
                    by int-ds-nota-loja-item.sequencia
                      by int-ds-nota-loja-item.produto:

            assign  c-it-codigo         = trim(string(int(int-ds-nota-loja-item.produto)))
                    de-quantidade       = int-ds-nota-loja-item.quantidade
                    de-vl-uni           = int-ds-nota-loja-item.preco_unit
                                          /* retirando gambiarras de desconto para produtos em cortesia */
                    de-vl-liq           = if int-ds-nota-loja-item.desconto = 100 and
                                             int-ds-nota-loja-item.tipo_desco = "P" and
                                             int-ds-nota-loja-item.preco_liqu = 0.01 
                                          then 0
                                          else int-ds-nota-loja-item.preco_liqu
                                        /*/ int-ds-nota-loja-item.quantidade*/
                    de-desconto         = /*int-ds-nota-loja-item.desconto*/
                                           ((de-vl-uni - de-vl-liq) / de-vl-uni) * 100
                    c-numero-lote       = if trim(int-ds-nota-loja-item.lote) <> ? and
                                             trim(int-ds-nota-loja-item.lote) <> "?" then 
                                             trim(int-ds-nota-loja-item.lote) else ""
                    i-nr-seq-item       = int(int-ds-nota-loja-item.sequencia) * 10
                    de-aliq-icms        = int-ds-nota-loja-item.aliq_icms
                    de-base-icms        = if de-vl-liq = 0 then 0
                                          else int-ds-nota-loja-item.base_icms
                    de-valor-icms       = if int-ds-nota-loja-item.trib_icms = "1" OR
                                             int-ds-nota-loja-item.trib_icms = "3" 
                                          then ((de-aliq-icms * de-base-icms) / 100)
                                          else 0
                    c-trib-icms         = trib_icms.
                    /*
                    int-ds-nota-loja-item.trib_icms
                    int-ds-nota-loja-item.valortrib
                    int-ds-nota-loja-item.valortribestadual
                    */

            
            run valida-registro-item.        
            if l-cupom-com-erro then next.
            if not can-find (first tt-docto no-lock where 
                tt-docto.cod-estabel = c-cod-estabel and
                tt-docto.serie       = c-serie and
                tt-docto.nr-nota     = c-num-nota) then do:
                run cria-tt-docto.
            end.
            run cria-tt-it-docto.
        end.
        for first tt-it-docto: end.
        if not l-cupom-com-erro and not avail tt-it-docto then do:
            assign i-erro = 37
                   c-informacao = "S‚rie: " + c-serie + " - " + "Cupom: " + c-num-nota + " - " + "CNPJ Filial: " + string(int-ds-nota-loja.cnpj_filial)
                   l-cupom-com-erro = yes.
            run gera-log. 
        end.
        if not l-cupom-com-erro then run gera-duplicatas.
        else run apaga-registro-atual.
        if i-nr-registro mod 1000 = 0 then do:
            run importa-nota.
        end.
