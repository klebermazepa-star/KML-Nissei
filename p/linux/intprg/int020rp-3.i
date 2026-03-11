/*******************************************************
**
**  INT020RP.I1 - Include do programa INT020RP.P
**
*******************************************************/
/*
55. Condiá∆o de pagamento n∆o informada no cupom
46. Cliente de convenio NAO cadastrado
37. Cupom inconsistente ou sem itens
44. CPF NAO informado para venda por convenio


*/
define buffer b-it-nota-fisc for it-nota-fisc.

{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.
DEF VAR c-cest                  AS CHAR.

procedure gera-duplicatas:
    i-cont  = 0.
    i-cont2 = 0.
    de-vl-tot-dup = 0.

    /* eliminando cst_fat_duplic anterior, se houver */
    for each cst_fat_duplic exclusive where 
        cst_fat_duplic.cod_estabel = c-cod-estabel and
        cst_fat_duplic.serie       = c-serie and
        cst_fat_duplic.nr_fatura   = c-num-nota
        query-tuning(no-lookahead):
        delete cst_fat_duplic.
    end.

    if c-status <> "C" /* cancelado */ and
       c-status <> "I" /* inutilizado */ then do:
        /*
        if de-valor-dinh <> 0 and
           de-valor-dinh < de-vl-tot-cup then do:
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            assign i-cont  = i-cont + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = 3 /* antecipacao */
                   tt-fat-duplic.dt-venciment      = d-dt-emissao
                   tt-fat-duplic.dt-desconto       = ? /*tt-fat-duplic.dt-venciment*/
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont,"99"))
                   tt-fat-duplic.vl-parcela        = de-valor-dinh
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = "DI".
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   i-cont2                         = i-cont
                   de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod-portador  = i-cod-port-dinh
                       cst_fat_duplic.modalidade    = i-modalid-dinh
                       cst_fat_duplic.cod-cond-pag  = i-cond-pag-dinh
                       cst_fat_duplic.condipag      = string(i-cond-pag-dinh,"99")
                       cst_fat_duplic.cod-estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr-fatura     = c-num-nota.
                assign cst_fat_duplic.adm-cartao    = ""
                       cst_fat_duplic.autorizacao   = ""
                       cst_fat_duplic.nsu-admin     = ""
                       cst_fat_duplic.nsu-numero    = ""
                       cst_fat_duplic.taxa-admin    = 0.
        end.
        if de-valor-cartaoc <> 0 or 
           de-valor-cartaod <> 0 or
           de-valor-vale    <> 0 then do:
           
            for each tt-int_ds_nota_loja_cartao no-lock where 
                tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
                tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
                tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota
                query-tuning(no-lookahead):
                if tt-int_ds_nota_loja_cartao.valor <= 0 then next.
                
                if tt-int_ds_nota_loja_cartao.vencimento < int_ds_nota_loja.emissao then do:
                    /*
                    assign i-erro = 47
                           c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial) + 
                                          " Vencto.: " + string(tt-int_ds_nota_loja_cartao.vencimento,"99/99/9999") +
                                          " Emiss∆o: " + string(int_ds_nota_loja.emissao,"99/99/9999")
                           l-cupom-com-erro = yes.
                    run gera-log. 
                    return.
                    */
                    assign tt-int_ds_nota_loja_cartao.vencimento = int_ds_nota_loja.emissao.
                end.
                assign i-seq-fat-duplic = i-seq-fat-duplic + 1
                       i-cont           = i-cont + 1
                       i-cont2          = i-cont.
                create tt-fat-duplic.
                assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                       tt-fat-duplic.seq-tt-docto      = i-nr-registro
                       tt-fat-duplic.cod-vencto        = tt-int_ds_nota_loja_cartao.cod-vencto
                       tt-fat-duplic.dt-venciment      = tt-int_ds_nota_loja_cartao.vencimento
                       tt-fat-duplic.dt-desconto       = ? 
                       tt-fat-duplic.vl-desconto       = 0 /* tt-int_ds_nota_loja_cartao.taxa_admin */
                       tt-fat-duplic.parcela           = trim(string(i-cont,"99"))
                       tt-fat-duplic.vl-parcela        = tt-int_ds_nota_loja_cartao.valor  /* - tt-int_ds_nota_loja_cartao.taxa_admin */
                       tt-fat-duplic.vl-comis          = 0
                       tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                       tt-fat-duplic.cod-esp           = tt-int_ds_nota_loja_cartao.cod-esp.
                assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                       de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
                create cst_fat_duplic.
                buffer-copy tt-fat-duplic to cst_fat_duplic
                    assign cst_fat_duplic.cod-portador  = tt-int_ds_nota_loja_cartao.cod-portador
                           cst_fat_duplic.modalidade    = tt-int_ds_nota_loja_cartao.modalidade
                           cst_fat_duplic.cod-cond-pag  = tt-int_ds_nota_loja_cartao.cod-cond-pag
                           cst_fat_duplic.adm-cartao    = tt-int_ds_nota_loja_cartao.adm_cartao
                           cst_fat_duplic.autorizacao   = tt-int_ds_nota_loja_cartao.autorizacao
                           cst_fat_duplic.condipag      = tt-int_ds_nota_loja_cartao.condipag
                           cst_fat_duplic.nsu-admin     = substring(tt-int_ds_nota_loja_cartao.nsu_admin,1,10) /* retirar apos aumentado o campo */
                           cst_fat_duplic.nsu-numero    = substring(tt-int_ds_nota_loja_cartao.nsu_numero,1,10) /* retirar apos aumentado o campo */
                           cst_fat_duplic.taxa-admin    = tt-int_ds_nota_loja_cartao.taxa_admin
                           cst_fat_duplic.cod-estabel   = c-cod-estabel
                           cst_fat_duplic.serie         = c-serie
                           cst_fat_duplic.nr-fatura     = c-num-nota.
            end.
        end.
        i-num-parcelas = i-num-parcelas + i-cont2.
        i-cont2 = i-cont2 + 1.
        if de-vl-tot-cup > 0.01 then 
        do i-cont = i-cont2 to i-num-parcelas:
        
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = i-cod-vencto
                   tt-fat-duplic.dt-venciment      = d-dt-emissao + 
                                                     i-prazos[i-cont]
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont,"99"))
                   tt-fat-duplic.vl-parcela        = (if i-cont = i-num-parcelas then de-vl-tot-cup
                                                      else (de-vl-tot-cup * de-per-pg-dup[i-cont] / 100))
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = c-cod-esp-princ.
                   
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
            
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod-portador  = i-cod-portador
                       cst_fat_duplic.modalidade    = i-modalidade
                       cst_fat_duplic.cod-cond-pag  = i-cod-cond-pag
                       cst_fat_duplic.condipag      = c-condipag
                       cst_fat_duplic.cod-estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr-fatura     = c-num-nota.
                assign cst_fat_duplic.adm-cartao    = ""
                       cst_fat_duplic.autorizacao   = ""
                       cst_fat_duplic.nsu-admin     = ""
                       cst_fat_duplic.nsu-numero    = ""
                       cst_fat_duplic.taxa-admin    = 0.
        end.
        */

        /* foráar parcelamento do convànio iniciando com parcela 1 - AVB 24/07/2018 */
        for each tt-int_ds_nota_loja_cartao no-lock where 
            tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota and
            tt-int_ds_nota_loja_cartao.cod-esp = "CV"
            by tt-int_ds_nota_loja_cartao.parcela
            query-tuning(no-lookahead):
            if tt-int_ds_nota_loja_cartao.valor <= 0 then next.
            
            if tt-int_ds_nota_loja_cartao.vencimento < int_ds_nota_loja.emissao then do:
                assign tt-int_ds_nota_loja_cartao.vencimento = int_ds_nota_loja.emissao.
            end.
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1
                   i-cont           = /*i-cont + 1*/ tt-int_ds_nota_loja_cartao.parcela.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = tt-int_ds_nota_loja_cartao.cod-vencto
                   tt-fat-duplic.dt-venciment      = tt-int_ds_nota_loja_cartao.vencimento
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont,"99")) /*string(tt-int_ds_nota_loja_cartao.parcela,"99")*/
                   tt-fat-duplic.vl-parcela        = tt-int_ds_nota_loja_cartao.valor
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = tt-int_ds_nota_loja_cartao.cod-esp.
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
                   
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod_portador  = tt-int_ds_nota_loja_cartao.cod-portador
                       cst_fat_duplic.modalidade    = tt-int_ds_nota_loja_cartao.modalidade
                       cst_fat_duplic.cod_cond_pag  = tt-int_ds_nota_loja_cartao.cod-cond-pag
                       cst_fat_duplic.adm_cartao    = tt-int_ds_nota_loja_cartao.adm_cartao
                       cst_fat_duplic.autorizacao   = tt-int_ds_nota_loja_cartao.autorizacao
                       cst_fat_duplic.condipag      = tt-int_ds_nota_loja_cartao.condipag
                       cst_fat_duplic.nsu_admin     = substring(tt-int_ds_nota_loja_cartao.nsu_admin,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.nsu_numero    = substring(tt-int_ds_nota_loja_cartao.nsu_numero,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.taxa_admin    = tt-int_ds_nota_loja_cartao.taxa_admin
                       cst_fat_duplic.cod_estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr_fatura     = c-num-nota.
        end.


        /* foráar parcelamento das demais formas de pagamento ap¢s o convànio - AVB 24/07/2018 */
        for each tt-int_ds_nota_loja_cartao no-lock where 
            tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota and
            tt-int_ds_nota_loja_cartao.cod-esp <> "CV"
            by tt-int_ds_nota_loja_cartao.parcela
            query-tuning(no-lookahead):
            if tt-int_ds_nota_loja_cartao.valor <= 0 then next.
            
            if tt-int_ds_nota_loja_cartao.vencimento < int_ds_nota_loja.emissao then do:
                assign tt-int_ds_nota_loja_cartao.vencimento = int_ds_nota_loja.emissao.
            end.
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1
                   i-cont           = i-cont + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = tt-int_ds_nota_loja_cartao.cod-vencto
                   tt-fat-duplic.dt-venciment      = tt-int_ds_nota_loja_cartao.vencimento
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont,"99")) /*string(tt-int_ds_nota_loja_cartao.parcela,"99") procfit envia parcela duplicada */
                   tt-fat-duplic.vl-parcela        = tt-int_ds_nota_loja_cartao.valor
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = tt-int_ds_nota_loja_cartao.cod-esp.
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
                   
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod_portador  = tt-int_ds_nota_loja_cartao.cod-portador
                       cst_fat_duplic.modalidade    = tt-int_ds_nota_loja_cartao.modalidade
                       cst_fat_duplic.cod_cond_pag  = tt-int_ds_nota_loja_cartao.cod-cond-pag
                       cst_fat_duplic.adm_cartao    = tt-int_ds_nota_loja_cartao.adm_cartao
                       cst_fat_duplic.autorizacao   = tt-int_ds_nota_loja_cartao.autorizacao
                       cst_fat_duplic.condipag      = tt-int_ds_nota_loja_cartao.condipag
                       cst_fat_duplic.nsu_admin     = substring(tt-int_ds_nota_loja_cartao.nsu_admin,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.nsu_numero    = substring(tt-int_ds_nota_loja_cartao.nsu_numero,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.taxa_admin    = tt-int_ds_nota_loja_cartao.taxa_admin
                       cst_fat_duplic.cod_estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr_fatura     = c-num-nota.
        end.

        if not can-find(first tt-fat-duplic where
                        tt-fat-duplic.seq-tt-docto = i-nr-registro) then do:
           run pi-erros-nota (input 15299, input trim(return-value)).
           return.
        end.
        create tt-fat-repre.
        assign tt-fat-repre.seq-tt-docto = i-nr-registro
               tt-fat-repre.sequencia    = 1
               tt-fat-repre.cod-rep      = i-cod-rep
               tt-fat-repre.nome-ab-rep  = c-nome-repres
               tt-fat-repre.perc-comis   = 0
               tt-fat-repre.comis-emis   = 0
               tt-fat-repre.vl-comis     = 0
               tt-fat-repre.vl-emis      = 0.
    end.
end.

procedure valida-registro-cabecalho.
    
    define buffer bint_ds_nota_loja_item for int_ds_nota_loja_item.

    if i-nr-registro mod 100 = 0 then
        run pi-acompanhar in h-acomp (input "Validando cupom").

    assign  c-cod-estabel = ""
            c-estado      = ""
            c-cidade      = ""
            c-bairro      = ""
            c-endereco    = ""
            c-pais        = ""
            i-cep         = 0
            i-ep-codigo   = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                            0 &else "" &endif.
    assign  c-sistema-lj  = ""
            d-dt-procfit  = ?.

    if d-dt-emissao = ? then do:
        assign c-sistema-lj = "PROCFIT"
               i-erro = 06
               c-informacao = "SÇrie: " + c-serie + " - " + "Cupom: " + c-num-nota + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial) + " Data: ?" 
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.

    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_nota_loja.cnpj_filial,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= d-dt-emissao
        query-tuning(no-lookahead):
        assign c-cod-estabel = estabelec.cod-estabel
               c-estado      = estabelec.estado
               c-cidade      = estabelec.cidade
               c-bairro      = estabelec.bairro
               c-endereco    = estabelec.endereco
               c-pais        = estabelec.pais
               i-cep         = estabelec.cep
               i-ep-codigo   = estabelec.ep-codigo
               d-dt-procfit  = cst_estabelec.dt_inicio_oper
               c-sistema-lj  = if d-dt-procfit <= d-dt-emissao then "PROCFIT" else "OBLAK".
        leave.
    end.
                            

    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial)
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.
    if c-cod-estabel = "500" then
    do:
       assign i-erro = 30
              c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "CNPJ Filial: " + string(int_ds_nota_loja.cnpj_filial)
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    /* validar totais do cupom se estabelecimento Ç Procfit */
    if d-dt-procfit <= d-dt-emissao then do:
        de-aux = 0.
        for each bint_ds_nota_loja_item fields (preco_liqu quantidade) of int_ds_nota_loja:
            de-aux = de-aux + (bint_ds_nota_loja_item.preco_liqu * bint_ds_nota_loja_item.quantidade).
        end.
        if  de-aux <> de-vl-tot-cup then do:
            assign i-erro = 56
                   c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab.: " + c-cod-estabel + " - " + 
                                  "Valor Itens: " + string(de-aux) + " - " + 
                                  "Valor Cupom: " + string(de-vl-tot-cup)
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.

    for first estabelec no-lock where 
        estabelec.cod-estabel = c-cod-estabel
        query-tuning(no-lookahead): end.
   
    /* Oblak - enviode sÇrie 1 indevidamente quando contingencia */
    if  int(int_ds_nota_loja.serie) = 1 and 
        int_ds_nota_loja.num_identi begins "cont"
    then
        assign c-serie = "801".
    else do:
        if (int(int_ds_nota_loja.serie) = 1 and 
            not int_ds_nota_loja.num_identi begins "cont")
        then
            assign c-serie = estabelec.serie-manual.
        else
            assign c-serie = trim(int_ds_nota_loja.serie).
    end.

    /* Procfit ou sÇrie n∆o informada no estabelecimento */
    if  c-serie = ? or d-dt-procfit <= d-dt-emissao 
    then 
        assign c-serie = trim(int_ds_nota_loja.serie).
       
   
    for first ser-estab no-lock where
         ser-estab.serie = c-serie and
         ser-estab.cod-estabel = c-cod-estabel
        query-tuning(no-lookahead): end.
    if not avail ser-estab then do:
       assign i-erro = 36
              c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                             "SÇrie: " + c-serie + " - " + "Estab.: " + c-cod-estabel
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.  
    if avail ser-estab and
       ser-estab.forma-emis = 1 /* Automatica */ then do:
        assign i-erro = 19
               c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                             "SÇrie: " + c-serie 
              l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.
    
    /**************** Nota Fiscal j† existe *********************************/
    if can-find(nota-fiscal
       where nota-fiscal.cod-estabel = c-cod-estabel
       and   nota-fiscal.serie       = c-serie
       and   nota-fiscal.nr-nota-fis = c-num-nota) then do:
        {utp/ut-table.i mgdis nota-fiscal 1}
        run pi-erros-nota (input 1, input trim(return-value) + " Estab.: " + c-cod-estabel + " SÇrie: " + c-serie + " Nr. Nota: " + c-num-nota).
        run finaliza-cupom.
        return.
    end.


    for first param-estoq no-lock query-tuning(no-lookahead): 
        if month (param-estoq.ult-fech-dia) = 12 then 
            assign c-aux = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
        else
            assign c-aux = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").
        
        if (c-aux = string(year(d-dt-emissao),"9999") + string(month(d-dt-emissao),"99") and
           (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes)) or
            param-estoq.ult-fech-dia >= d-dt-emissao then do:
            assign i-erro = 51
                   c-informacao = "SÇrie: "   + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + 
                                  "Estab: "   + c-cod-estabel                               + " - " +
                                  "Emiss∆o: " + string(d-dt-emissao,"99/99/9999")           + " - " +
                                  "Valor: "   + string(int_ds_nota_loja.valor_total)
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.                
    end.

    if int_ds_nota_loja.valor_convenio = 0 and 
       can-find (first int_ds_nota_loja_cartao of int_ds_nota_loja no-lock where
                 int_ds_nota_loja_cartao.condipag = "4" or  /* Convenio */
                 int_ds_nota_loja_cartao.condipag = "83" or /* Goldenfarma */ 
                 int_ds_nota_loja_cartao.condipag = "65" or /* Convenio parcelado */
                 int_ds_nota_loja_cartao.condipag = "66" or /* Convenio parcelado */
                 int_ds_nota_loja_cartao.condipag = "69" or /* Convenio parcelado */
                 int_ds_nota_loja_cartao.condipag = "99")   /* cartao Convenio */ then do:
        assign i-erro = 59
               c-informacao = "SÇrie: "   + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + 
                              "Estab: "   + c-cod-estabel                               + " - " +
                              "Emiss∆o: " + string(d-dt-emissao,"99/99/9999")           + " - " +
                              "Valor: "   + string(int_ds_nota_loja.valor_total)
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.

    if int_ds_nota_loja.valor_convenio <> 0 and (
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cpf_cliente))) <= 0 or
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cpf_cliente))) = ? or
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cpf_cliente))) = 1) then do:
        assign i-erro = 44
               c-informacao = "Est: " + c-cod-estabel + "/" + "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + " - " + 
                              "CPF Cliente: " + 
                              (if int_ds_nota_loja.cpf_cliente <> ? then trim (int_ds_nota_loja.cpf_cliente) else "?") + " - " + 
                              "Convànio: " +
                              c-convenio
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.

    if int_ds_nota_loja.valor_convenio <> 0 and 
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cpf_cliente))) > 0 then do:

        if not can-find (first emitente no-lock where 
                 emitente.cgc = trim(OnlyNumbers(int_ds_nota_loja.cpf_cliente))) AND
               can-find (first int_ds_nota_loja_cartao of int_ds_nota_loja no-lock where
                 int_ds_nota_loja_cartao.condipag <> "83") then do:
           assign i-erro = 46
                  c-informacao = "Est: " + c-cod-estabel + "/" + "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + " - " + 
                                 "CPF Cliente: " + 
                                 (if int_ds_nota_loja.cpf_cliente <> ? then trim (int_ds_nota_loja.cpf_cliente) else "?") + " - " + 
                                 "Convànio: " +
                                 c-convenio
                  l-cupom-com-erro = yes.
           run gera-log. 
           return.
        end.                
    end.
    


    assign  c-nome-abrev = if int_ds_nota_loja.valor_convenio <> 0 
                           then "CONSUMIDORCV" else "CONSUMIDOR"
            i-cod-emitente = 0
            i-canal-vendas = 0
            i-cod-rep      = 1.

    if int_ds_nota_loja.cnpjcpf_imp_cup <> ? AND 
       trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup)) <> "" AND
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup))) > 1 then do:
        for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                   cod-rep ind-cre-cli identific pais estado cgc)
            no-lock where
            emitente.cgc = trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup))
            query-tuning(no-lookahead):
            assign  c-nome-abrev   = emitente.nome-abrev
                    i-cod-emitente = emitente.cod-emitente
                    i-canal-vendas = emitente.cod-canal-venda
                    i-cod-rep      = if emitente.cod-rep <> 0 
                                     then emitente.cod-rep
                                     else i-cod-rep
                    c-cpf           = emitente.cgc
                    i-tip-cob-desp  = emitente.tip-cob-desp    .
        end.
        if not avail emitente then do:
           IF c-nome-abrev begins "CONSUMIDOR" THEN DO:
              for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                         cod-rep ind-cre-cli identific pais estado cgc)
                  no-lock where
                  emitente.nome-abrev = c-nome-abrev
                  query-tuning(no-lookahead):
                  assign  c-nome-abrev   = emitente.nome-abrev
                          i-cod-emitente = emitente.cod-emitente
                          i-canal-vendas = emitente.cod-canal-venda
                          i-cod-rep      = if emitente.cod-rep <> 0 
                                           then emitente.cod-rep
                                           else i-cod-rep
                          c-cpf          = emitente.cgc
                          i-tip-cob-desp = emitente.tip-cob-desp    .
               end.
            END.
        END.
        IF NOT AVAIL emitente THEN DO:
           assign i-erro = 2
                  c-informacao = "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + " - " + 
                                 "CPF Cupom: " + 
                                 int_ds_nota_loja.cnpjcpf_imp_cup
                  l-cupom-com-erro = yes.
           run gera-log. 
           return.
        end.
    end.
    else do:
        for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                   cod-rep ind-cre-cli identific pais estado cgc)
            no-lock where
            emitente.nome-abrev = c-nome-abrev
            query-tuning(no-lookahead):
            assign  c-nome-abrev   = emitente.nome-abrev
                    i-cod-emitente = emitente.cod-emitente
                    i-canal-vendas = emitente.cod-canal-venda
                    i-cod-rep      = if emitente.cod-rep <> 0 
                                     then emitente.cod-rep
                                     else i-cod-rep
                    c-cpf          = emitente.cgc
                    i-tip-cob-desp = emitente.tip-cob-desp    .
        end.
        if not avail emitente then do:
            assign i-erro = 2
                   c-informacao = "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + " - " + 
                                  "Nome Abrev.: " + c-nome-abrev
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.

    /*    
    if emitente.ind-cre-cli = 4 then do:
        assign i-erro = 27
               c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Emitente: " + string(i-cod-emitente)
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end. 
    */

    if emitente.identific = 2 then do:     /* Fornecedor */
        run pi-erros-nota (input 15143, input "Fornecedor: " + string(emitente.cod-emitente)).
        return.                                 
    end.

    /*
    if not can-find(unid-feder 
                    where unid-feder.pais   = emitente.pais 
                    and   unid-feder.estado = emitente.estado) then do:
       {utp/ut-table.i mguni unid-feder 1}              
       run pi-erros-nota (input 56, input trim(return-value) + " UF: " + emitente.estado).
       return.
    end.
    */

    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres fields (cod-rep nome-abrev) no-lock where 
            repres.cod-rep = i-cod-rep
            query-tuning(no-lookahead):
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if i-tab-finan = 0 OR i-tab-finan = ? then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    /*
    if not can-find (first tab-finan no-lock where 
                    tab-finan.nr-tab-finan = i-tab-finan) then do:
      assign i-erro = 35
             c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                            "SÇrie: " + c-serie + " - " +
                            "Tab. Financ.: " + string(i-tab-finan)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    */
    /*
    if i-canal-vendas <> 0 then
    do:
       for first canal-venda fields (cod-canal-venda) no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas
           query-tuning(no-lookahead): end.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                "Canal Vendas: " + string(i-canal-vendas) + " - " + "Emitente: " + string(i-cod-emitente)
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.
    */


    i-num-parcelas = 0.
    if c-status <> "C" and /* cancelado */
       c-status <> "I" /* inutilizado */
       /* duplicatas vir∆o todas do frente de loja
       and  (
       de-valor-cartaod <> 0 or 
       de-valor-cartaoc <> 0 or 
       de-valor-vale    <> 0 )*/ then do:

        /* condicao de pagamento principal preenchida - Oblak */
        if trim(c-condipag) <> "" and c-condipag <> ? and
           trim(c-condipag) <> "0" then do:
            
            for first int_ds_loja_cond_pag no-lock where
                int_ds_loja_cond_pag.condipag = trim(c-condipag)
                query-tuning(no-lookahead):

                if  c-cod-esp-princ = "" or i-cod-portador = ? or i-cod-cond-pag = ? then do:

                    IF int_ds_loja_cond_pag.log_adquirente = NO OR 
                      (int_ds_nota_loja.televendas = "S" AND int_ds_nota_loja.indterminal = "97") THEN DO:
                        assign  i-cod-cond-pag  = int_ds_loja_cond_pag.cod_cond_pag 
                                i-cod-portador  = int_ds_loja_cond_pag.cod_portador
                                i-modalidade    = int_ds_loja_cond_pag.modalidade
                                c-cod-esp-princ = int_ds_loja_cond_pag.cod_esp.
                    END.
                    ELSE DO:
                        ASSIGN  i-cod-cond-pag  = int_ds_loja_cond_pag.cod_cond_pag 
                                i-modalidade    = int_ds_loja_cond_pag.modalidade
                                c-cod-esp-princ = int_ds_loja_cond_pag.cod_esp.

                        FIND FIRST cst_estabelec
                             WHERE cst_estabelec.cod_estabel = c-cod-estabel NO-LOCK NO-ERROR.
                        IF AVAIL cst_estabelec THEN DO:

                            ASSIGN d-dt-procfit  = cst_estabelec.dt_inicio_oper.

                            IF cst_estabelec.sistema = YES THEN DO:

                                IF c-cod-esp-princ = "CC" THEN DO:
                                     ASSIGN i-cod-portador = cst_estabelec.cod_portador_cr.
                                END.
                                ELSE IF c-cod-esp-princ = "CD" THEN DO:
                                     ASSIGN i-cod-portador = cst_estabelec.cod_portador_db.
                                END.
                                ELSE ASSIGN i-cod-portador = int_ds_loja_cond_pag.cod_portador.
                            END.
                            ELSE DO:
                                IF d-dt-emissao < d-dt-procfit THEN DO:
                                    IF c-cod-esp-princ = "CC" THEN DO:
                                         ASSIGN i-cod-portador = INT(cst_estabelec.cod_portador_cr).
                                    END.
                                    ELSE IF c-cod-esp-princ = "CD" THEN DO:
                                         ASSIGN i-cod-portador = INT(cst_estabelec.cod_portador_db).
                                    END.
                                    ELSE ASSIGN i-cod-portador = int_ds_loja_cond_pag.cod_portador.
                                END.
                                ELSE DO:

                                    ASSIGN i-cod-portador  = int_ds_loja_cond_pag.cod_portador.

                                    FOR EACH int_ds_nota_loja_cartao NO-LOCK WHERE 
                                            int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial AND
                                            int_ds_nota_loja_cartao.serie       = int_ds_nota_loja.serie       AND
                                            int_ds_nota_loja_cartao.num_nota    = int_ds_nota_loja.num_nota    AND
                                            int_ds_nota_loja_cartao.condipag    = int_ds_loja_cond_pag.condipag
                                            query-tuning(no-lookahead):

                                        IF int_ds_loja_cond_pag.log_adquirente AND (int_ds_nota_loja_cartao.cod_adquirente = 0 OR int_ds_nota_loja_cartao.cod_adquirente = ?) THEN DO:
                                            assign i-erro = 34
                                                   c-informacao = "Estab: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                                                  "Cond. Pagto.: " + string(int_ds_loja_cond_pag.cod_cond_pag) + " - Adquirente n∆o Informado - PROCFIT" 
                                                   l-cupom-com-erro = yes.
                                            run gera-log. 
                                            return.
                                        END.

                                        IF int_ds_nota_loja_cartao.cod_adquirente = 125 THEN DO:
                                            IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 90101.
                                            IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 90102.
                                        END.
                                        ELSE IF int_ds_nota_loja_cartao.cod_adquirente = 082 THEN DO:
                                            IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 91601.
                                            IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 91602.
                                        END.
                                        ELSE IF int_ds_nota_loja_cartao.cod_adquirente = 296 THEN DO:
                                            IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 91501.
                                            IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 91502.
                                        END.
                                        ELSE IF int_ds_nota_loja_cartao.cod_adquirente = 005 THEN DO:
                                            IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 90201.
                                            IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 90202.
                                        END.
                                        ELSE ASSIGN i-cod-portador  = int_ds_loja_cond_pag.cod_portador.
                                    END.

                                END.
                            END.
                        END.
                        ELSE ASSIGN i-cod-portador  = 0.
                    END.

                    IF i-cod-portador = ? THEN ASSIGN i-cod-portador = 0.

                    if c-cod-esp-princ = "" or 
                       not can-find (first esp-doc no-lock where 
                                     esp-doc.cod-esp = c-cod-esp-princ) then do:
                        assign i-erro = 43
                               c-informacao = "Nr. Nota: " + c-num-nota          + " - " + 
                                              "Cod. EspÇcie: " + c-cod-esp-princ + " - " +
                                              "Cond Pag: " + c-condipag 
                               l-cupom-com-erro = yes.
                        run gera-log. 
                        return.
                    end.

                    if i-cod-portador <> 0
                    then do:
                       if not can-find (first mgadm.portador no-lock where
                            portador.ep-codigo    = i-ep-codigo and
                            portador.cod-portador = i-cod-portador and
                            portador.modalidade   = i-modalidade)
                       then do:
                          assign i-erro = 34
                                 c-informacao = "Estab: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                                "Portador: " + string(i-cod-portador) + "/" + "Modalidade: " + string(i-modalidade)
                                 l-cupom-com-erro = yes.
                          run gera-log. 
                          return.
                       end.    
                    end.

                    for first cond-pagto fields (cod-vencto
                                                 nr-tab-finan 
                                                 nr-ind-finan 
                                                 cod-vencto   
                                                 prazos       
                                                 per-pg-dup   
                                                 num-parcelas) no-lock where 
                        cond-pagto.cod-cond-pag = int_ds_loja_cond_pag.cod_cond_pag
                        query-tuning(no-lookahead):
                        assign i-tab-finan    = cond-pagto.nr-tab-finan
                               i-indice       = cond-pagto.nr-ind-finan
                               i-cod-vencto   = cond-pagto.cod-vencto  
                               i-prazos       = cond-pagto.prazos      
                               de-per-pg-dup  = cond-pagto.per-pg-dup  
                               i-num-parcelas = cond-pagto.num-parcelas.

                    end.
                    if not avail cond-pagto then do:
                        assign i-erro = 15
                               c-informacao = "Est: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                              "Cond. Pagto.: " + c-condipag
                               l-cupom-com-erro = yes.
                        run gera-log. 
                        return.
                    end.
                end.
            end.
        end.

        if not can-find(first int_ds_nota_loja_cartao no-lock where
            int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota) then do:
            assign i-erro = 39
                   c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "CNPJ Filial: " + int_ds_nota_loja.cnpj_filial + " - " + "Estab.: " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
        else do:
            assign de-aux = 0.
            for each tt-int_ds_nota_loja_cartao no-lock where 
                tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
                tt-int_ds_nota_loja_cartao.serie       = int_ds_nota_loja.serie and
                tt-int_ds_nota_loja_cartao.num_nota    = int_ds_nota_loja.num_nota
                query-tuning(no-lookahead):
                delete tt-int_ds_nota_loja_cartao.
            end.

            for each int_ds_nota_loja_cartao no-lock where 
                int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
                int_ds_nota_loja_cartao.serie       = int_ds_nota_loja.serie and
                int_ds_nota_loja_cartao.num_nota    = int_ds_nota_loja.num_nota
                query-tuning(no-lookahead):

                if trim(int_ds_nota_loja_cartao.condipag) = ? then do:
                    assign i-erro = 55
                           c-informacao = "Est: " + c-cod-estabel + "- SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                          "Cond. Pagto.: ?"
                           l-cupom-com-erro = yes.
                    run gera-log. 
                    return.
                end.

                /* Condicá∆o de pagamento principal n∆o preenchida - Procfit */
                if c-condipag = "" or c-condipag = ? then
                    assign c-condipag = trim(string(int(int_ds_nota_loja_cartao.condipag),">>>99")).

                if int_ds_nota_loja_cartao.valor <= 0 then next.
                de-aux = de-aux + int_ds_nota_loja_cartao.valor.
                create tt-int_ds_nota_loja_cartao.
                buffer-copy int_ds_nota_loja_cartao to tt-int_ds_nota_loja_cartao.

                for first int_ds_loja_cond_pag no-lock where 
                    int_ds_loja_cond_pag.condipag = trim(string(int(int_ds_nota_loja_cartao.condipag),">>>99"))
                    query-tuning(no-lookahead):

                    assign  i-cod-cond-pag = int_ds_loja_cond_pag.cod_cond_pag
                            i-modalidade   = int_ds_loja_cond_pag.modalidade.

                    IF int_ds_loja_cond_pag.log_adquirente = NO OR 
                      (int_ds_nota_loja.televendas = "S" AND int_ds_nota_loja.indterminal = "97") THEN DO:
                        ASSIGN  i-cod-portador = int_ds_loja_cond_pag.cod_portador.
                    END.
                    ELSE DO:
                        
                        FIND FIRST cst_estabelec
                             WHERE cst_estabelec.cod_estabel = c-cod-estabel NO-LOCK NO-ERROR.
                        IF AVAIL cst_estabelec THEN DO:

                            ASSIGN d-dt-procfit  = cst_estabelec.dt_inicio_oper.

                            IF cst_estabelec.sistema = YES THEN DO:
                                IF int_ds_loja_cond_pag.cod_esp = "CC" THEN DO:
                                     ASSIGN i-cod-portador = cst_estabelec.cod_portador_cr.
                                END.
                                ELSE IF int_ds_loja_cond_pag.cod_esp = "CD" THEN DO:
                                     ASSIGN i-cod-portador = cst_estabelec.cod_portador_db.
                                END.
                                ELSE ASSIGN i-cod-portador = int_ds_loja_cond_pag.cod_portador.
                            END.
                            ELSE DO:
                                IF d-dt-emissao < d-dt-procfit THEN DO:
                                    IF int_ds_loja_cond_pag.cod_esp = "CC" THEN DO:
                                         ASSIGN i-cod-portador = cst_estabelec.cod_portador_cr.
                                    END.
                                    ELSE IF int_ds_loja_cond_pag.cod_esp = "CD" THEN DO:
                                         ASSIGN i-cod-portador = cst_estabelec.cod_portador_db.
                                    END.
                                    ELSE ASSIGN i-cod-portador = int_ds_loja_cond_pag.cod_portador.
                                END.
                                ELSE DO:

                                    IF int_ds_loja_cond_pag.log_adquirente AND (int_ds_nota_loja_cartao.cod_adquirente = 0 OR int_ds_nota_loja_cartao.cod_adquirente = ?) THEN DO:
                                        assign i-erro = 34
                                               c-informacao = "Estab: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                                              "Cond. Pagto.: " + string(int_ds_loja_cond_pag.cod_cond_pag) + " - Adquirente n∆o Informado - PROCFIT" 
                                               l-cupom-com-erro = yes.
                                        run gera-log. 
                                        return.
                                    END.

                                    IF int_ds_nota_loja_cartao.cod_adquirente = 125 THEN DO:
                                        IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 90101.
                                        IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 90102.
                                    END.
                                    ELSE IF int_ds_nota_loja_cartao.cod_adquirente = 082 THEN DO:
                                        IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 91601.
                                        IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 91602.
                                    END.
                                    ELSE IF int_ds_nota_loja_cartao.cod_adquirente = 296 THEN DO:
                                        IF int_ds_loja_cond_pag.cod_esp = "CC" THEN ASSIGN i-cod-portador  = 91501.
                                        IF int_ds_loja_cond_pag.cod_esp = "CD" THEN ASSIGN i-cod-portador  = 91502.
                                    END.
                                    ELSE ASSIGN i-cod-portador  = int_ds_loja_cond_pag.cod_portador.
                                END.
                            END.
                        END.
                        ELSE ASSIGN i-cod-portador  = 0.
                    END.


                    
                    for first cond-pagto fields (cod-vencto
                                                 nr-tab-finan 
                                                 nr-ind-finan 
                                                 cod-vencto   
                                                 prazos       
                                                 per-pg-dup   
                                                 num-parcelas) no-lock where 
                        cond-pagto.cod-cond-pag = int_ds_loja_cond_pag.cod_cond_pag
                        query-tuning(no-lookahead):

                        assign tt-int_ds_nota_loja_cartao.cod-vencto = cond-pagto.cod-vencto.

                        if  c-cod-esp-princ = "" then do:
                            assign c-cod-esp-princ = int_ds_loja_cond_pag.cod_esp.
                            assign i-tab-finan     = cond-pagto.nr-tab-finan
                                   i-indice        = cond-pagto.nr-ind-finan
                                   i-cod-vencto    = cond-pagto.cod-vencto  
                                   i-prazos        = cond-pagto.prazos      
                                   de-per-pg-dup   = cond-pagto.per-pg-dup  
                                   i-num-parcelas  = cond-pagto.num-parcelas.
                        end.
                    end.
                    if not avail cond-pagto then do:
                        assign i-erro = 15
                               c-informacao = "Est: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                              "Cond. Pagto.: " + string(int_ds_loja_cond_pag.cod_cond_pag)
                               l-cupom-com-erro = yes.
                        run gera-log. 
                        return.
                    end.
                    
                    assign tt-int_ds_nota_loja_cartao.cod-portador  = i-cod-portador /* int_ds_loja_cond_pag.cod_portador */
                           tt-int_ds_nota_loja_cartao.modalidade    = int_ds_loja_cond_pag.modalidade
                           tt-int_ds_nota_loja_cartao.cod-esp       = int_ds_loja_cond_pag.cod_esp
                           tt-int_ds_nota_loja_cartao.cod-cond-pag  = int_ds_loja_cond_pag.cod_cond_pag.
                           
                    if not can-find (first mgadm.portador no-lock where
                         portador.ep-codigo    = i-ep-codigo and
                         portador.cod-portador = tt-int_ds_nota_loja_cartao.cod-portador and
                         portador.modalidade   = tt-int_ds_nota_loja_cartao.modalidade)
                    then do:
                       assign i-erro = 34
                              c-informacao = "Estab: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                             "Portador: " + string(tt-int_ds_nota_loja_cartao.cod-portador) + "/" + "Modalidade: " + string(tt-int_ds_nota_loja_cartao.modalidade)
                              l-cupom-com-erro = yes.
                       run gera-log. 
                       return.
                    end.    
                end. /* int_ds_loja_cond_pag */

                if not avail int_ds_loja_cond_pag or i-cod-cond-pag = ? then do:
                    assign i-erro = 15
                           c-informacao = "Est: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                          "Cond. Pagto.: " + trim(string(int(c-condipag),">>>99"))
                           l-cupom-com-erro = yes.
                    run gera-log. 
                    return.
                end.
                      
                /*
                for first int-ds-classif-fisc no-lock 
                    where rowid(int-ds-classif-fisc) = v-row-classif-fisc
                    query-tuning(no-lookahead):
                     for first natur-oper 
                       fields (nat-ativa nat-operacao emite-duplic tipo char-2 cod-esp log-ipi-bicms 
                               terceiros cd-trib-icm cd-trib-ipi cod-mensagem 
                               consum-final perc-red-ipi perc-red-icm mercado)
                       no-lock where
                       natur-oper.nat-operacao = int-ds-classif-fisc.cod-nat-oper-cupom
                       query-tuning(no-lookahead):
                     end.
                end.

                if not avail int-ds-classif-fisc or not avail natur-oper then do:
                    assign i-erro = 21
                           c-informacao = "Nr. Nota: "       + c-num-nota            + " - " + 
                                          "Classif Fiscal: " + trim(item.class-fisc) + " - " +    
                                          "Item: "           + item.it-codigo
                           l-cupom-com-erro = yes.
                    run gera-log. 
                    return.
                end.
                */
            end.
            
            if i-cod-cond-pag = ? then do:
                assign i-erro = 15
                       c-informacao = "Est: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                      "Cond. Pagto.: " + c-condipag
                       l-cupom-com-erro = yes.
                run gera-log. 
                return.
            end.
            

            if  de-aux <> /*(de-valor-cartaoc + de-valor-cartaod + de-valor-vale)*/ de-vl-tot-cup then do:
                assign i-erro = 40
                       c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab.: " + c-cod-estabel + " - " + 
                                      "Valor Duplicata: " + string(de-aux) + " - " + 
                                      "Valor Cupom: "     + string(de-vl-tot-cup)
                       l-cupom-com-erro = yes.
                run gera-log. 
                return.
            end.
        end.
    end.
    else if (c-status = "C" or c-status = "I") and i-cod-cond-pag = ? then do:
        assign i-tab-finan = 1
               i-indice    = 0
               i-cod-cond-pag = 0.
    end.

    if c-condipag = ? or c-condipag = "0"
    then do:
        assign i-erro = 55
               c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                              "Cond. Pagto.: ?"
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.

    if i-cod-cond-pag = ? then do:
        assign i-erro = 15
               c-informacao = "Est: " + c-cod-estabel + " - " + "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                              "Cond. Pagto.: " + c-condipag
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.


    if c-estado = "PR" and int_ds_nota_loja.nfce_chave_s  /* chave acesso */ = ? 
       and c-status <> "C" and c-status <> "I" /* inutilizado */ then do:
        l-servico = NO.
        FOR EACH bint_ds_nota_loja_item NO-LOCK OF int_ds_nota_loja.
            FOR FIRST ITEM NO-LOCK WHERE
                ITEM.it-codigo = trim(string(int(bint_ds_nota_loja_item.produto)))
                query-tuning(no-lookahead): END.
            IF avail item and item.tipo-contr <> 4 THEN DO:
                l-servico = NO.
                LEAVE.
            END.
            l-servico = YES.
        END.
        IF l-servico THEN NEXT.
        assign i-erro = 48
               c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab.: " + c-cod-estabel
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.               

    /* chave acesso para cupons emitidos em ambiente normal */
    if  int_ds_nota_loja.nfce_chave_s <> ? and 
        trim(int_ds_nota_loja.nfce_chave_s) <> "" and
        not trim(int_ds_nota_loja.num_identi) begins "CONT"
    then do:
        /* alterado para buscar da chave, posicao (35,1)
        if int_ds_nota_loja.nfce_transmissao_s /* tipo transmissao*/  = ? then do:
            assign i-erro = 54
                   c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab.: " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
        */
        if TrataNuloChar(int_ds_nota_loja.nfce_protocolo_s) /* protocolo */ = ?
        then do:
            assign i-erro = 53
                   c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab.: " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.                   
    end.
end.
      
procedure valida-registro-item.

   if i-nr-registro mod 100 = 0 then
       run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item 
        fields (it-codigo class-fiscal ind-item-fat cod-obsoleto tipo-contr cd-trib-icm aliquota-ipi char-1 char-2
                aliquota-iss cd-trib-ipi un ind-ipi-dife cod-localiz tipo-con-est perm-saldo-neg)
        no-lock where
        item.it-codigo = c-it-codigo
       query-tuning(no-lookahead):
        c-class-fiscal = item.class-fiscal.
        l-saldo-neg = item.perm-saldo-neg = 3.
        i-tipo-contr = item.tipo-contr.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab: " + c-cod-estabel + 
                            "Item: " + c-it-codigo 
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " + "Estab: " + c-cod-estabel + 
                            "Item: " + c-it-codigo
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item THEN do: /*and not item.ind-item-fat then do:*/
      FOR FIRST item-uni-estab WHERE
                item-uni-estab.it-codigo   = ITEM.it-codigo AND
                item-uni-estab.cod-estabel = c-cod-estabel NO-LOCK
          query-tuning(no-lookahead):  END.
      IF AVAIL item-uni-estab AND item-uni-estab.ind-item-fat = NO THEN DO:
         assign i-erro = 11
                c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                               "Item: " + c-it-codigo
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      END.
   end.     
   /***************** Classificaªío Fiscal *******************************/
   if avail item and i-pais-impto-usuario = 1  /* Brasil */
   and not can-find(classif-fisc where 
                   classif-fisc.class-fiscal = item.class-fiscal) then do:
       {utp/ut-table.i mgind classif-fisc 1}  
       run pi-erros-nota (input 56, input trim(return-value) + " Class. Fiscal: " + item.class-fiscal).
       return.
   end.
   /**************** Item x Referºncia ***********************************/
   /*
   if avail item and item.tipo-con-est = 4 then do:  /* Referencia */
      if not can-find(ref-item where
                      ref-item.it-codigo = tt-it-docto.it-codigo and
                      ref-item.cod-refer = tt-it-docto.cod-refer) then do:        
          {utp/ut-table.i mgind ref-item 1}                        
          run pi-erros-nota (input 56, input trim(return-value) + " Item: " + tt-it-docto.it-codigo + "/" + "Cod. Refer.: " + tt-it-docto.cod-refer).
          return.
      end.
   end.
   */
   if avail item and item.tipo-con-est = 3 and
      c-numero-lote = "" then do:  /* Lote */
       assign i-erro = 41
              c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                             "Item: " + c-it-codigo + " - " + 
                             "Lote: " + c-numero-lote
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

/* n∆o ter† mais lote
   if avail item and item.tipo-con-est <> 3 and
      c-numero-lote <> "" then do:  /* Lote */
       assign i-erro = 42
              c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                             "Item: " + c-it-codigo + " - " + 
                             "Lote: " + c-numero-lote
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.
*/
   /******************************************/

   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                            "Item: " + c-it-codigo + " - " + 
                            "Qtde.: " + string(de-quantidade)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end. 



   /*
   /* determina natureza de operacao */
   run intprg/int018a.p (INPUT  c-condipag,
                         INPUT  c-class-fiscal,
                         OUTPUT v-row-loja-cond-pag,
                         OUTPUT v-row-classif-fisc). 
   */

   /*
   assign  c-natur  = "".
   for first int-ds-classif-fisc no-lock 
       where rowid(int-ds-classif-fisc) = v-row-classif-fisc
       query-tuning(no-lookahead):
       assign  c-natur = int-ds-classif-fisc.cod-nat-oper-cupom.
   end.
   
   for first natur-oper no-lock 
       where natur-oper.nat-operacao = int-ds-classif-fisc.cod-nat-oper-cupom
       query-tuning(no-lookahead):
       assign c-cod-esp-princ = natur-oper.cod-esp.
   end.
   */


   /* Transferido para valida-cabecalho 
   for first int_ds_loja_cond_pag no-lock where
       int_ds_loja_cond_pag.condipag = trim(c-condipag)
       query-tuning(no-lookahead):
       assign  i-cod-cond-pag  = int_ds_loja_cond_pag.cod_cond_pag 
               i-cod-portador  = int_ds_loja_cond_pag.cod_portador
               i-modalidade    = int_ds_loja_cond_pag.modalidade
               c-cod-esp-princ = int_ds_loja_cond_pag.cod_esp.
   end.
   
   for first cond-pagto fields (cod-cond-pag nr-tab-finan nr-ind-finan 
                                cod-vencto prazos per-pg-dup num-parcelas)
       where cond-pagto.cod-cond-pag = i-cod-cond-pag
       no-lock query-tuning(no-lookahead): end.
   if not avail cond-pagto then do:
   
      assign i-erro = 15
             c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                            "Cond. Pagto.: " + string(i-cod-cond-pag)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.
   else
       assign i-tab-finan    = cond-pagto.nr-tab-finan
              i-indice       = cond-pagto.nr-ind-finan
              i-cod-vencto   = cond-pagto.cod-vencto  
              i-prazos       = cond-pagto.prazos      
              de-per-pg-dup  = cond-pagto.per-pg-dup  
              i-num-parcelas = cond-pagto.num-parcelas.
   
   for first int_ds_loja_cond_pag no-lock where
       int_ds_loja_cond_pag.condipag = trim(c-condipag)
       query-tuning(no-lookahead):
       
       if  c-cod-esp-princ = "" or i-cod-portador = ? or i-cod-cond-pag = ? then do:
           assign  i-cod-cond-pag  = int_ds_loja_cond_pag.cod_cond_pag 
                   i-cod-portador  = int_ds_loja_cond_pag.cod_portador
                   i-modalidade    = int_ds_loja_cond_pag.modalidade
                   c-cod-esp-princ = int_ds_loja_cond_pag.cod_esp.

           if c-cod-esp-princ = "" or 
              not can-find (first esp-doc no-lock where 
                            esp-doc.cod-esp = c-cod-esp-princ) then do:
               assign i-erro = 43
                      c-informacao = "Nr. Nota: " + c-num-nota          + " - " + 
                                     "Cod. EspÇcie: " + c-cod-esp-princ + " - " +
                                     "Cond Pag: " + c-condipag 
                      l-cupom-com-erro = yes.
               run gera-log. 
               return.
           end.
                      
           if i-cod-portador <> 0
           then do:
              if not can-find (first mgadm.portador no-lock where
                   portador.ep-codigo    = i-ep-codigo and
                   portador.cod-portador = i-cod-portador and
                   portador.modalidade   = i-modalidade)
              then do:
                 assign i-erro = 34
                        c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                       "Portador: " + string(i-cod-portador) + "/" + "Modalidade: " + string(i-modalidade)
                        l-cupom-com-erro = yes.
                 run gera-log. 
                 return.
              end.    
           end.

           for first ser-estab no-lock where
                ser-estab.serie = c-serie and
                ser-estab.cod-estabel = c-cod-estabel
                query-tuning(no-lookahead): 
           end.
           if not avail ser-estab then do:
              assign i-erro = 36
                     c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                                    "SÇrie: " + c-serie + " - " + "Estab.: " + c-cod-estabel
                     l-cupom-com-erro = yes.
              run gera-log. 
              return.
           end.   
              
              /* 
              if avail ser-estab then do:
                 if ser-estab.forma-emis = 1 /* automatica */ then do:
                     assign i-erro = 19
                            c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                                           "SÇrie: " + c-serie + " - " + "Estab.: " + c-cod-estabel
                            l-cupom-com-erro = yes.
                     run gera-log. 
                     return.
                 end.
                 /*
                 else do:
                   assign ser-estab.dt-prox-fat = 01/01/0001
                          ser-estab.dt-ult-fat  = 01/01/0001.
                 end.
                 */
              
              end.
              */

           if can-find (first serie no-lock where 
               serie.serie = c-serie and
               serie.forma-emis = 1 /* Automatica */) then do:
               assign i-erro = 19
                      c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                                     "SÇrie: " + c-serie 
                      l-cupom-com-erro = yes.
               run gera-log. 
               return.
           end.
       end.
   end.
   */

   FOR FIRST estabelec NO-LOCK
       WHERE estabelec.cod-estabel = c-cod-estabel
       query-tuning(no-lookahead):
       c-uf-destino = estabelec.estado.
       c-uf-origem  = estabelec.estado.
   END.

   /* determina natureza de operacao */
   c-tp-pedido = "98".
   if int_ds_nota_loja.nfce_chave_s  /* chave acesso */ <> ? and trim(int_ds_nota_loja.nfce_chave_s)  /* chave acesso */ <> "" then do:
      c-tp-pedido = trim(substring(replace(replace(int_ds_nota_loja.nfce_chave_s,'NFe',''),'CFe',''),21,2)).
   end.               

   run intprg/int115a.p ( /*input "98"          ,*/
                          input c-tp-pedido   ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input "" /*nat or*/ ,  
                          input i-cod-emitente,
                          input c-class-fiscal,
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).

   for first natur-oper 
       fields (nat-ativa nat-operacao emite-duplic tipo char-2 cod-esp log-ipi-bicms 
               terceiros cd-trib-icm cd-trib-ipi cod-mensagem subs-trib char-1 mercado
               consum-final perc-red-ipi perc-red-icm perc-pis natur-oper.per-fin-soc)
       no-lock where
       natur-oper.nat-operacao = c-natur
       query-tuning(no-lookahead): 
       if i-cod-mensagem = 0 then 
           i-cod-mensagem = natur-oper.cod-mensagem.
       assign c-cod-esp-princ = natur-oper.cod-esp.
   end.
   if not avail natur-oper then do:
       assign i-erro = 21
              c-informacao = "Nr. Nota: "      + c-num-nota     + " - " + 
                             "Tp Pedido: "     + c-tp-pedido    + " - " +
                             "Natur. Oper.: "  + c-natur        + " - " + 
                             "Class. Fiscal: " + c-class-fiscal + " - " +
                             "Item: "          + item.it-codigo
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                             "Natur. Oper.: " + c-natur
           l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

   /**************** Natureza nío pode ser de entrada ****************/
   if natur-oper.tipo = 1 then do:     /* Entrada */
      run pi-erros-nota (input 6028, input "Entrada" + " Natur. Oper.: " + natur-oper.nat-operacao).
      return.
   end.

    /*********** Natureza nío pode ser operacao com terceiros *********/
    if natur-oper.terceiros then do:     /* terceiro */
       run pi-erros-nota (input 15126, input "Terceiros" + " Natur. Oper.: " + natur-oper.nat-operacao).
       return.
    end.

    /********** Natureza de Operaªío Inativa ***********************/
    if natur-oper.nat-ativa = no then do:
       run pi-erros-nota (input 26759, input "Inativa" + " Natur. Oper.: " + natur-oper.nat-operacao).
       return.
    end.

    /*************** CΩdigo da Mensagem ***********************************/
    /*
    if  natur-oper.cod-mensagem <> 0 
    and not can-find(mensagem where 
                     mensagem.cod-mensagem = natur-oper.cod-mensagem) then do:
        {utp/ut-table.i mgadm mensagem 1}    
        run pi-erros-nota (input 56, input trim(return-value) + " Cod. Mensagem: " + string(natur-oper.cod-mensagem)).
        return.
    end.
    */

    /* Venda tributada ICMS e natureza NAO tributa 
    if natur-oper.cd-trib-icm <> 1 and
      (trim(c-trib-icms) = "1" or 
       trim(c-trib-icms) = "3") and
       de-valor-icms > 0 then do:
        assign i-erro = 49
               c-informacao = "Nr. Nota: " + c-num-nota + " - " + "Item: " + c-it-codigo + " - " +
                              "NCM: " + c-class-fiscal + " - " + "Cd Pgto: " + c-condipag + " - " +
                              "Natur. Oper.: " + c-natur +
                              " - " + "ICMS: " + trim(string(de-valor-icms,"->>>,>>>,>>9.99"))
            l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.
    */
    /* Natureza c/ ICMS e cupom sem valor de ICMS 
    if natur-oper.cd-trib-icm = 1 and
       trim(c-trib-icms) <> "1" and
       trim(c-trib-icms) <> "3" and
       de-valor-icms = 0 then do:
        assign i-erro = 50
               c-informacao = "Nr. Nota: " + c-num-nota + " - " + "Item: " + c-it-codigo + " - " +
                              "NCM: " + c-class-fiscal + " - " + "Cd Pgto: " + c-condipag + " - " +
                              "Natur. Oper.: " + c-natur +
                              " - " + "ICMS: " + trim(string(de-valor-icms,"->>>,>>>,>>9.99"))
            l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.
    */

   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                              "Item: " + c-it-codigo
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
   end.

end.
 
procedure cria-tt-docto.
    if i-nr-registro mod 100 = 0 then
        run pi-acompanhar in h-acomp (input "Criando Cupom").
    
    create tt-docto.
    assign tt-docto.fat-nota         = if int_ds_nota_loja.valor_convenio <> 0 and 
                                          c-status <> "C" and c-status <> "I" /* inutilizado */
                                       then 1 /* NFF */ else 2 /* nota */
           tt-docto.ind-tip-nota     = 11     /* Importada */
           tt-docto.nr-prog          = 2015
           tt-docto.seq-tt-docto     = i-nr-registro
           tt-docto.cod-des-merc     = 2 /* consumo */
           tt-docto.cod-estabel      = c-cod-estabel
           tt-docto.dt-nf-ent-fut    = ?
           tt-docto.nat-operacao     = c-natur
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.nr-nota          = c-num-nota
           tt-docto.serie            = c-serie
           tt-docto.cgc              = c-cpf
           tt-docto.ins-estadual     = ""
           tt-docto.nome-abrev       = c-nome-abrev
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.tip-cob-desp     = i-tip-cob-desp.

    assign tt-docto.estado         = c-estado
           tt-docto.cep            = string(i-cep)
           tt-docto.pais           = c-pais
           tt-docto.endereco       = c-endereco
           tt-docto.bairro         = c-bairro
           tt-docto.cidade         = c-cidade.
           
    assign tt-docto.perc-embalagem   = 0
           tt-docto.perc-frete       = 0
           tt-docto.perc-desco1      = 0
           tt-docto.perc-desco2      = 0
           tt-docto.perc-seguro      = 0
           tt-docto.peso-bru-tot     = 0
           tt-docto.peso-liq-tot     = 0
           tt-docto.vl-embalagem     = 0
           tt-docto.vl-frete         = 0
           tt-docto.vl-seguro        = 0
           tt-docto.cod-canal-venda  = 0
           tt-docto.cidade-cif       = ""
           tt-docto.cod-cond-pag     = i-cod-cond-pag
           tt-docto.cod-entrega      = ""
           tt-docto.dt-base-dup      = d-dt-emissao
           tt-docto.dt-emis-nota     = d-dt-emissao
           tt-docto.dt-prvenc        = d-dt-emissao
           tt-docto.dt-cancela       = if c-status = "C" or c-status = "I" then d-dt-emissao else ?
           tt-docto.marca-volume     = ""
           tt-docto.mo-codigo        = 0
           tt-docto.no-ab-reppri     = c-nome-repres
           tt-docto.nome-tr-red      = ""
           tt-docto.nome-transp      = "PADRAO"
           tt-docto.nr-fatura        = c-num-nota
           tt-docto.nr-tabpre        = ""
           tt-docto.nr-volumes       = ""
           tt-docto.placa            = ""
           tt-docto.serie-ent-fut    = ""
           tt-docto.nr-nota-ent-fut  = ""
           tt-docto.ind-lib-nota     = yes
           tt-docto.cod-rota         = ""
           tt-docto.cod-msg          = i-cod-mensagem
           tt-docto.vl-taxa-exp      = 0
           tt-docto.nr-proc-exp      = ""
           tt-docto.nr-tab-finan     = i-tab-finan
           tt-docto.nr-ind-finan     = i-indice
           tt-docto.cod-portador     = i-cod-portador
           tt-docto.modalidade       = i-modalidade
           tt-docto.nr-nota-base     = ""
           tt-docto.serie-base       = ""
           tt-docto.uf-placa         = ""
           tt-docto.dt-embarque      = ?
           tt-docto.serie-dif        = ""
           tt-docto.nr-nota-dif      = ""
           tt-docto.perc-acres-dif   = 0
           tt-docto.vl-acres-dif     = 0
           tt-docto.vl-taxa-exp-dif  = 0
           tt-docto.cond-redespa     = ""
           tt-docto.obs              = ""
           tt-docto.esp-docto        = 22 /* NFS */
           tt-docto.motvo-cance      = "".
           
    assign tt-docto.vl-mercad         = de-vl-tot-cup.

    
    /*assign overlay(tt-docto.char-1,174,1)  = substring(TrataNuloChar(int_ds_nota_loja.nfce_transmissao_s),1,1) /* tipo transmissao*/.*/
    c-tp-pedido = "98".
    if int_ds_nota_loja.nfce_chave_s  /* chave acesso */ <> ? and trim(int_ds_nota_loja.nfce_chave_s)  /* chave acesso */ <> "" then do:
        assign overlay(tt-docto.char-1,112,60) = OnlyNumbers(int_ds_nota_loja.nfce_chave_s)  /* chave acesso */
               overlay(tt-docto.char-1,172,2)  = if  c-status <> "C" and 
                                                     c-status <> "I" then "3" 
                                                 else 
                                                     if c-status = "I" then "7" 
                                                     else "6" /* situacao */
               overlay(tt-docto.char-1,175,15) = TrataNuloChar(int_ds_nota_loja.nfce_protocolo_s). /* protocolo */
               c-tp-pedido = trim(substring(onlyNumbers(int_ds_nota_loja.nfce_chave_s),21,2)).
               
        /* acerto tipo transmissao n∆o enviado (Procfit) ou incorreto (Oblak) */
        assign overlay(tt-docto.char-1,174,1)  = if int(substring(OnlyNumbers(int_ds_nota_loja.nfce_chave_s),35,1)) > 7 then "4" /* Totvs n∆o trata acima de 7 */
            else substring(OnlyNumbers(int_ds_nota_loja.nfce_chave_s),35,1).
    end.               
    else do:           
        overlay(tt-docto.char-1,172,2)  = if  c-status <> "C" and 
                                              c-status <> "I" then "3" 
                                          else 
                                              if c-status = "I" then "7" 
                                              else "6" /* situacao */.
    end.

    /*Modalidade de Frete*/
    assign overlay(tt-docto.char-1,190,8) = '9' NO-ERROR.
    /*Fim Modalidade de Frete*/			     

    create tt-cst_nota_fiscal.
    assign tt-cst_nota_fiscal.cod_estabel       = c-cod-estabel
           tt-cst_nota_fiscal.serie             = c-serie
           tt-cst_nota_fiscal.nr_nota_fis       = c-num-nota
           tt-cst_nota_fiscal.condipag          = int_ds_nota_loja.condipag
           tt-cst_nota_fiscal.convenio          = int_ds_nota_loja.convenio
           tt-cst_nota_fiscal.cupom_ecf         = int_ds_nota_loja.cupom_ecf
           tt-cst_nota_fiscal.nfce_chave        = int_ds_nota_loja.nfce_chave_s
           tt-cst_nota_fiscal.valor_chq         = int_ds_nota_loja.valor_chq
           tt-cst_nota_fiscal.valor_chq_pre     = int_ds_nota_loja.valor_chq_pre
           tt-cst_nota_fiscal.valor_convenio    = int_ds_nota_loja.valor_convenio
           tt-cst_nota_fiscal.valor_cartao      = int_ds_nota_loja.valor_cartaod 
                                                + int_ds_nota_loja.valor_cartaoc
           tt-cst_nota_fiscal.valor_dinheiro    = de-valor-dinh
           tt-cst_nota_fiscal.valor_ticket      = int_ds_nota_loja.valor_ticket
           tt-cst_nota_fiscal.valor_vale        = int_ds_nota_loja.valor_vale
           tt-cst_nota_fiscal.nfce_dt_transmissao   = int_ds_nota_loja.nfce_transmissao_d
           tt-cst_nota_fiscal.nfce_protocolo        = int_ds_nota_loja.nfce_protocolo_s
           tt-cst_nota_fiscal.nfce_transmissao      = int_ds_nota_loja.nfce_transmissao_s
           tt-cst_nota_fiscal.cpf_cupom             = if int_ds_nota_loja.condipag <> "83"
                                                      then int_ds_nota_loja.cpf_cliente
                                                      else "00000000985" /* GoldenFarma */
           tt-cst_nota_fiscal.cartao_manual         = (int_ds_nota_loja.cartao_manual = 1)

           tt-cst_nota_fiscal.num_nota          = int_ds_nota_loja.num_nota
           tt-cst_nota_fiscal.indterminal       = int_ds_nota_loja.indterminal
           tt-cst_nota_fiscal.num_identi        = int_ds_nota_loja.num_identi
           tt-cst_nota_fiscal.impressora        = int_ds_nota_loja.impressora
           tt-cst_nota_fiscal.data_ecf          = int_ds_nota_loja.data_ecf
           tt-cst_nota_fiscal.serie_cupom       = int_ds_nota_loja.serie
           tt-cst_nota_fiscal.versaopdv         = int_ds_nota_loja.versaopdv
           tt-cst_nota_fiscal.orgao             = c-orgao
           tt-cst_nota_fiscal.categoria         = c-categoria
           tt-cst_nota_fiscal.id_pedido_convenio = int(TrataNuloDec(int_ds_nota_loja.id_pedido_convenio)).

    for each int_ds_convenio where 
        int_ds_convenio.cod_convenio = int(tt-cst_nota_fiscal.convenio)
        query-tuning(no-lookahead):
        assign tt-cst_nota_fiscal.tipo_venda = int_ds_convenio.tipo_venda.
    end.

end.
 
procedure cria-tt-it-docto.

   define var i-cd-trib-ipi as integer no-undo.
   define var i-cd-trib-icm as integer no-undo.

   if i-nr-registro mod 100 = 0 then
       run pi-acompanhar in h-acomp (input "Criando Itens do Cupom").

   if not avail natur-oper then
       find natur-oper no-lock where natur-oper.nat-operacao = c-natur no-error.

   if not avail item then
       find item no-lock where item.it-codigo = c-it-codigo no-error.
   assign i-cd-trib-ipi = natur-oper.cd-trib-ipi.
   if i-cd-trib-ipi <> 2 /* Isento */ and 
      i-cd-trib-ipi <> 3 /* Outros */ then
        if item.cd-trib-ipi = 1 /* tributado */ or  
           item.cd-trib-ipi = 4 /* reduzido */ then
            assign i-cd-trib-ipi = item.cd-trib-ipi.

   assign de-red-base-ipi = 0 /* base normal */
          de-base-ipi = (de-vl-liq * de-quantidade). 
   if avail natur-oper and /* IPI SOBRE O BRUTO */
     substring(natur-oper.char-2,11,1) = "1" then
   do:
      de-base-ipi = (de-vl-uni * de-quantidade). 
   end.
   
   if i-cd-trib-ipi <> 2 and    /* isento */
      i-cd-trib-ipi <> 3 then do: /* outros */ 
      if i-cd-trib-ipi = 4 /* reduzido */ then
      do:
         assign de-red-base-ipi = natur-oper.perc-red-ipi.
                de-base-ipi = (de-vl-liq * de-quantidade) * 
                               (1 - (de-red-base-ipi / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliquota-ipi = 0.
   end.
   /*
   assign i-cd-trib-icm = natur-oper.cd-trib-icm.
   if i-cd-trib-icm <> 2 /* Isento */ and 
      i-cd-trib-icm <> 3 /* Outros */ then
        if item.cd-trib-icm = 1 /* tributado */ or  
           item.cd-trib-icm = 4 /* reduzido */ then
            assign i-cd-trib-icm = item.cd-trib-icm.

   assign de-red-base-icm = 0 /* base normal */
          de-base-icms = (de-vl-liq * de-quantidade). 
   
   if natur-oper.log-ipi-bicms or trim(substr(natur-oper.char-2,1,5)) = "1" then 
       assign de-base-icms = de-base-icms + it-nota-fisc.vl-ipi-it.
   
   if i-cd-trib-icm <> 2 and    /* isento */
      i-cd-trib-icm <> 3 then do: /* outros */ 
      if i-cd-trib-icm = 4 /* reduzido */ then
      do:
         assign de-red-base-icm = natur-oper.perc-red-icm.
                de-base-icms = (de-vl-liq * de-quantidade) * 
                               (1 - (de-red-base-icm / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliq-icms = 0.
   end.
   */

   i-cd-trib-icm = 0.
   case c-trib-icms:
       when "1" then do:
           i-cd-trib-icm = 1.
       end.
       when "2" then do:
           i-cd-trib-icm = 2.
       end.
       when "3" then do:
           i-cd-trib-icm = 1.
       end.
       when "4" then do:
           i-cd-trib-icm = 3.
       end.
       when "5" then do:
           i-cd-trib-icm = 3.
       end.
       otherwise do:
           assign i-erro = 57
                   c-informacao = "SÇrie: " + c-serie + " - " + "Nr. Nota: " + c-num-nota + " - " +
                                  "Item: " + c-it-codigo + " - Trib: " + c-trib-icms
                  l-cupom-com-erro = yes.
           run gera-log. 
           return.
       end.
   end case.
   i-nr-sequencia = i-nr-sequencia + 1.

   create tt-it-docto.
   assign tt-it-docto.calcula             = yes
          tt-it-docto.tipo-atend          = 1   /* Total */
          tt-it-docto.seq-tt-it-docto     = i-nr-sequencia
          tt-it-docto.baixa-estoq         = if c-status <> "C" and c-status <> "I" 
                                            then i-tipo-contr <> 4 else no
          tt-it-docto.class-fiscal        = item.class-fiscal
          tt-it-docto.cod-estabel         = c-cod-estabel
          tt-it-docto.cod-refer           = ""
          tt-it-docto.data-comp           = ?
          tt-it-docto.it-codigo           = c-it-codigo
          tt-it-docto.nat-comp            = ""
          tt-it-docto.nat-operacao        = c-natur
          tt-it-docto.nr-nota             = c-num-nota
          tt-it-docto.nr-sequencia        = i-nr-seq-item
          tt-it-docto.nro-comp            = ""
          tt-it-docto.per-des-item        = de-desconto
          tt-it-docto.peso-liq-it-inf     = 0
          tt-it-docto.peso-embal-it       = 0
          tt-it-docto.quantidade[1]       = de-quantidade
          tt-it-docto.quantidade[2]       = de-quantidade
          tt-it-docto.seq-comp            = 0
          tt-it-docto.serie               = c-serie
          tt-it-docto.serie-comp          = ""
          tt-it-docto.un[1]               = item.un
          tt-it-docto.un[2]               = item.un
          tt-it-docto.vl-despes-it        = 0
          tt-it-docto.vl-embalagem        = 0
          tt-it-docto.vl-frete            = 0
          tt-it-docto.vl-merc-liq         = truncate(de-vl-liq * de-quantidade,2)
          tt-it-docto.vl-merc-ori         = truncate(de-vl-uni * de-quantidade,2)
          tt-it-docto.vl-merc-tab         = truncate(de-vl-uni * de-quantidade,2)
          tt-it-docto.vl-preori           = de-vl-uni
          tt-it-docto.vl-pretab           = de-vl-uni
          tt-it-docto.vl-preuni           = de-vl-liq
          tt-it-docto.vl-seguro           = 0
          tt-it-docto.vl-tot-item         = tt-it-docto.vl-merc-liq /*+ (de-base-ipi * (de-aliquota-ipi / 100))*/
          tt-it-docto.ind-imprenda        = no
          tt-it-docto.mercliq-moeda-forte = 0
          tt-it-docto.mercori-moeda-forte = 0
          tt-it-docto.merctab-moeda-forte = 0
          tt-it-docto.peso-bru-it-inf     = 0
          tt-it-docto.vl-taxa-exp         = 0
          tt-it-docto.vl-desconto         = if tt-it-docto.vl-merc-ori >= tt-it-docto.vl-merc-liq 
                                            then (tt-it-docto.vl-merc-ori - tt-it-docto.vl-merc-liq) else 0
          tt-it-docto.desconto            = tt-it-docto.vl-desconto
          tt-it-docto.vl-desconto-perc    = 0.
   
   create tt-it-imposto.
   assign tt-it-imposto.seq-tt-it-docto   = i-nr-sequencia
          tt-it-imposto.aliquota-icm      = de-aliq-icms
          tt-it-imposto.aliquota-ipi      = de-aliquota-ipi
          tt-it-imposto.cd-trib-icm       = i-cd-trib-icm
          tt-it-imposto.cd-trib-iss       = 2 /* isento */
          tt-it-imposto.cod-servico       = 0
          tt-it-imposto.ind-icm-ret       = no
          tt-it-imposto.per-des-icms      = 0
          tt-it-imposto.perc-red-icm      = de-red-base-icm
          tt-it-imposto.perc-red-iss      = 0
          tt-it-imposto.vl-bicms-ent-fut  = 0
          tt-it-imposto.vl-bicms-it       = if i-cd-trib-icm = 1 then de-base-icms else 0
          tt-it-imposto.vl-icms-it        = if i-cd-trib-icm = 1 then de-valor-icms else 0
          tt-it-imposto.vl-icms-outras    = if i-cd-trib-icm = 3 then de-base-icms else
                                            if de-red-base-icm <> 0 then ((de-vl-liq * de-quantidade) - de-base-icms) 
                                            else 0                                                                 
          tt-it-imposto.vl-icmsou-it      = tt-it-imposto.vl-icms-outras
          tt-it-imposto.vl-icmsnt-it      = if i-cd-trib-icm = 2 then de-base-icms else 0
          tt-it-imposto.cd-trib-ipi       = i-cd-trib-ipi
          tt-it-imposto.perc-red-ipi      = de-red-base-ipi
          tt-it-imposto.vl-bipi-ent-fut   = 0
          tt-it-imposto.vl-ipi-ent-fut    = 0
          tt-it-imposto.vl-bipi-it        = if i-cd-trib-ipi = 1 or i-cd-trib-ipi = 4 then de-base-ipi else 0
          tt-it-imposto.vl-ipi-it         = de-base-ipi * (de-aliquota-ipi / 100)
          tt-it-imposto.vl-ipi-outras     = if i-cd-trib-ipi = 3 then de-base-ipi else 
                                            if de-red-base-ipi <> 0 then ((de-vl-liq * de-quantidade) - de-base-ipi)
                                            else 0
          tt-it-imposto.vl-ipiou-it       = tt-it-imposto.vl-ipi-outras
          tt-it-imposto.vl-ipint-it       = if i-cd-trib-ipi = 2 then de-base-ipi else 0.

   assign tt-it-imposto.vl-biss-it        = 0
          tt-it-imposto.vl-bsubs-ent-fut  = 0
          tt-it-imposto.vl-bsubs-it       = 0
          tt-it-imposto.icm-complem       = 0
          tt-it-imposto.vl-icms-ent-fut   = 0
          tt-it-imposto.vl-icmsub-ent-fut = 0
          tt-it-imposto.vl-icmsub-it      = 0
          tt-it-imposto.aliq-icm-comp     = 0
          tt-it-imposto.aliquota-iss      = 0
          tt-it-imposto.vl-irf-it         = 0
          tt-it-imposto.vl-iss-it         = 0
          tt-it-imposto.vl-issnt-it       = 0
          tt-it-imposto.vl-issou-it       = 0
          tt-it-docto.desconto-zf         = 0
          tt-it-docto.narrativa           = c-numero-lote.
          
   /* Loja OBLAK */
   if  d-dt-procfit = ? or 
       d-dt-procfit > d-dt-emissao then do:

       /* Tributaá∆o PIS    */ 
       overlay(tt-it-docto.char-2,96,1) = (substr(natur-oper.char-1,86,1)).
    
       /* Aliquota PIS      */ 
       overlay(tt-it-docto.char-2,76,5) = "00,00".
       if int(substring(tt-it-docto.char-2,96,1)) = 1 then do:
           if natur-oper.mercado = 1 then                         /* Mercado Interno */
               if substr(item.char-2,52,1) = "1" then             /* Al°quota do Item */
                   overlay(tt-it-docto.char-2,76,5) = string(dec(substr(item.char-2,31,5)),"99.99").
               else /* aliquota da natureza*/
                   overlay(tt-it-docto.char-2,76,5) = string(natur-oper.perc-pis[1],"99.99").
           else  /* Mercado externo */
               overlay(tt-it-docto.char-2,76,5) = string(natur-oper.perc-pis[2],"99.99").
       end.
       /* sem aliquota deve ficar como isento */
       if dec(substring(tt-it-docto.char-2,76,5)) = 0 then
           overlay(tt-it-docto.char-2,96,1) = "2".
    

       /*
       display c-it-codigo
               c-natur
               natur-oper.nat-operacao
              (substr(natur-oper.char-1,86,1)) label "NATTrib"
               int(substring(tt-it-docto.char-2,96,1)) label "ITTrib"
               string(dec(substr(item.char-2,31,5)),"99.99") label "%IT"
           with width 550 stream-io.
                .
       */        
           
       /* Tributaá∆o COFINS */
       overlay(tt-it-docto.char-2,97,1) = (substr(natur-oper.char-1,87,1)).
    
       /* Aliquota COFINS   */ 
       overlay(tt-it-docto.char-2,81,5) = "00,00".
       if int(substring(tt-it-docto.char-2,97,1)) = 1 then do:
           if natur-oper.mercado = 1 then                    /* Mercado Interno */               
               if substr(item.char-2,53,1) = "1" then        /* aliquota do item */
                   overlay(tt-it-docto.char-2,81,5) = string(dec(substr(item.char-2,36,5)),"99.99").
               else /* aliquota da natureza*/
                   overlay(tt-it-docto.char-2,81,5) = string(natur-oper.per-fin-soc[1],"99.99").
           else /* Mercado externo */ 
               overlay(tt-it-docto.char-2,81,5) = string(natur-oper.per-fin-soc[2],"99.99").
       end.
       /* sem aliquota deve ficar como isento */
       if dec(substring(tt-it-docto.char-2,81,5)) = 0 then 
           overlay(tt-it-docto.char-2,97,1) = "2" .
    
       overlay(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
       overlay(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".
    
       /* Unidade de Negocio */
       assign overlay(tt-it-docto.char-2,172,03) = "000"
              tt-it-imposto.vl-pauta             = 0.
   end.

   /* Loja PROCFIT */
   else do:
       /*  CSTÔs */
       assign  overlay(tt-it-docto.char-1,75,2)  = TrataNuloChar(string(int_ds_nota_loja_item.cstbipi,"99"))
               overlay(tt-it-docto.char-1,77,2)  = TrataNuloChar(string(int_ds_nota_loja_item.cstbpis,"99"))
               overlay(tt-it-docto.char-1,79,2)  = TrataNuloChar(string(int_ds_nota_loja_item.cstbcofins,"99")).

       /* Modalidades de base */
       assign  overlay(tt-it-docto.char-1,81,2)  = TrataNuloChar(string(int_ds_nota_loja_item.modbcicms))
               overlay(tt-it-docto.char-1,85,2)  = TrataNuloChar(string(int_ds_nota_loja_item.modbcst))
               overlay(tt-it-docto.char-1,83,2)  = TrataNuloChar(string(int_ds_nota_loja_item.modbipi)).

       /* preenchendo mod base ipi caso n∆o preenchido */
       if substring(tt-it-docto.char-1,83,2) = "0" then overlay(tt-it-docto.char-1,83,2) = "1".

       /* Tributaá∆o PIS    */ 
       overlay(tt-it-docto.char-2,96,1)          = if int_ds_nota_loja_item.valorpis > 0 then "1" else "2".
       overlay(tt-it-docto.char-2,76,5)          = string(TrataNuloDec(int_ds_nota_loja_item.percentualpis),"99.99").

       /* sem aliquota deve ficar como isento */
       if dec(substring(tt-it-docto.char-2,76,5)) = 0 then
           overlay(tt-it-docto.char-2,96,1) = "2".

       /* Tributaá∆o COFINS */
       overlay(tt-it-docto.char-2,97,1)           = if int_ds_nota_loja_item.valorcofins > 0 then "1" else "2".
       overlay(tt-it-docto.char-2,81,5)           = string(TrataNuloDec(int_ds_nota_loja_item.percentualcofins),"99.99").

       /* sem aliquota deve ficar como isento */
       if dec(substring(tt-it-docto.char-2,81,5)) = 0 then 
           overlay(tt-it-docto.char-2,97,1) = "2" .

       overlay(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
       overlay(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".
   end.

   /*assign de-vl-tot-cup = de-vl-tot-cup + tt-it-docto.vl-merc-liq.
   assumido total enviado */

   if  i-tipo-contr <> 4 /* debito direto */ and 
       c-status <> "C" and 
       c-status <> "I" then do:

       if item.tipo-con-est = 3 /* lote */ then
       for first saldo-estoq fields (dt-vali-lote) no-lock where 
           saldo-estoq.cod-estabel = c-cod-estabel and
           saldo-estoq.cod-depos   = "LOJ" and
           saldo-estoq.cod-localiz = "" and
           saldo-estoq.cod-refer   = "" and
           saldo-estoq.it-codigo   = c-it-codigo and
           saldo-estoq.lote        = c-numero-lote
           query-tuning(no-lookahead):
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = c-numero-lote
                  tt-saldo-estoq.dt-vali-lote       = saldo-estoq.dt-vali-lote
                  tt-saldo-estoq.quantidade         = de-quantidade
                  tt-saldo-estoq.qtd-contada        = de-quantidade.
       end.
       if not avail saldo-estoq /*and l-saldo-neg avb 18/09/2017 */ then do:
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = if item.tipo-con-est = 3 /* lote */ then c-numero-lote else ""
                  tt-saldo-estoq.dt-vali-lote       = if item.tipo-con-est = 3 /* lote */ then today else ?
                  tt-saldo-estoq.quantidade         = de-quantidade
                  tt-saldo-estoq.qtd-contada        = de-quantidade.
       end.
       /*************** Baixa do Estoque *************************************/
       if  tt-it-docto.baixa-estoq then do:

           for first tt-saldo-estoq no-lock where
               tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia and
               tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia and
               tt-saldo-estoq.it-codigo          = c-it-codigo    and
               tt-saldo-estoq.cod-depos          = "LOJ"          and
               tt-saldo-estoq.cod-localiz        = ""
               query-tuning(no-lookahead):            end.
           if not avail tt-saldo-estoq then do:
               run pi-erros-nota (input 26082, input "Item: " + trim(tt-it-docto.it-codigo)).
               return.
           end.
       end.
   end.
end.
 
procedure importa-nota.

    DEFINE VARIABLE tipo-nota AS INTEGER     NO-UNDO.

    IF NOT VALID-HANDLE(h-cdapi1001) THEN
        RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.

    if i-nr-registro mod 100 = 0 then
        run pi-acompanhar in h-acomp (input "Gerando Nota").
    if  can-find (first tt-docto) and
        can-find (first tt-it-docto) then do:
        run ftp/ft2010.p (input  no,
                          output l-cupom-com-erro,
                          input  table tt-docto,
                          input  table tt-it-docto,
                          input  table tt-it-imposto,
                          input  table tt-nota-trans,
                          input  table tt-saldo-estoq,
                          input  table tt-fat-duplic,
                          input  table tt-fat-repre,
                          input  table tt-nota-embal,
                          input  table tt-item-embal,
                          input  table tt-it-docto-imp,
                          &IF DEFINED(bf_dis_desc_bonif) &THEN
                          input  table tt-docto-bn,
                          input  table tt-it-docto-bn,
                          &ENDIF
                          &IF DEFINED(bf_dis_unid_neg) &THEN
                          input table tt-rateio-it-duplic ,
                          &ENDIF
                          input-output table tt-notas-geradas
                          &IF DEFINED(bf_dis_ciap) &THEN ,
                          input table tt-it-nota-doc
                          &ENDIF ,
                          input table tt-desp-nota-fisc).                         
    end.
    for each tt-notas-geradas query-tuning(no-lookahead):
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal
            query-tuning(no-lookahead):
            run pi-acompanhar in h-acomp (input "Altera Duplicata: " + nota-fiscal.nr-nota-fis).

            /* inicio - alteraá∆o kleber para CEST / CST */

            FIND FIRST emitente
                WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.

            IF NOT AVAIL emitente THEN NEXT.

            /* acertar documento inutilizado */
            if nota-fiscal.dt-cancela <> ? then
            for first tt-docto no-lock where
                tt-docto.cod-estabel = nota-fiscal.cod-estabel and
                tt-docto.serie = nota-fiscal.serie and
                tt-docto.nr-nota = nota-fiscal.nr-nota-fis:
                if trim(substring(tt-docto.char-1,172,2)) = "7" then do:
                    if nota-fiscal.idi-sit-nf-eletro = 0 then nota-fiscal.idi-sit-nf-eletro = 7.
                    if nota-fiscal.idi-forma-emis-nf-eletro = 0 then nota-fiscal.idi-forma-emis-nf-eletro = 1.
                end.
            end.
                
            FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:

                
                  FIND FIRST natur-oper NO-LOCK
                      WHERE natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-ERROR.

                  IF NOT AVAIL natur-oper THEN NEXT.
            
                  if  natur-oper.nat-operacao > "4" then 
                      assign tipo-nota = 2. /*Sa≠da*/
                  else 
                      assign tipo-nota = 1. /*Entrada*/
            
                  EMPTY TEMP-TABLE tt-sit-tribut.
                  RUN pi-seta-tributos IN h-cdapi1001 (input "1,2,3,11").
                  RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  tipo-nota,
                                                            INPUT  it-nota-fisc.cod-estabel,
                                                            INPUT  natur-oper.nat-operacao,
                                                            INPUT  it-nota-fisc.class-fiscal,
                                                            INPUT  it-nota-fisc.it-codigo,
                                                            INPUT  emitente.cod-gr-cli,
                                                            INPUT  emitente.cod-emitente,
                                                            INPUT  nota-fiscal.dt-emis-nota,
                                                            OUTPUT TABLE tt-sit-tribut).

                  FOR EACH tt-sit-tribut:

                        IF  tt-sit-tribut.cdn-sit-tribut <> 0
                        AND tt-sit-tribut.seq-tab-comb   <> 0 THEN DO:

                            FIND FIRST b-it-nota-fisc WHERE ROWID(b-it-nota-fisc) = ROWID(it-nota-fisc) EXCLUSIVE-LOCK NO-ERROR.
                            IF AVAIL b-it-nota-fisc THEN DO:
                            
                                CASE tt-sit-tribut.cdn-tribut:

                                    WHEN 1 THEN 
                                        ASSIGN b-it-nota-fisc.cod-sit-tributar-ipi        = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
                                    WHEN 2 THEN 
                                        ASSIGN b-it-nota-fisc.cod-sit-tributar-pis        = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
                                    WHEN 3 THEN 
                                        ASSIGN b-it-nota-fisc.cod-sit-tributar-cofins     = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
                                    WHEN 11 THEN /** CEST **/ 
                                        ASSIGN overlay(b-it-nota-fisc.char-2,298,20)      = STRING(tt-sit-tribut.cdn-sit-tribut,"9999999").

                                END.
                            END.
                        END.
                  END.
    
            END.
    
            /* fim - alteraá∆o kleber para CEST */

            for each cst_fat_duplic no-lock where 
                cst_fat_duplic.cod_estabel = nota-fiscal.cod-estabel and
                cst_fat_duplic.serie       = nota-fiscal.serie and
                cst_fat_duplic.nr_fatura   = nota-fiscal.nr-fatura
                query-tuning(no-lookahead):
                for each fat-duplic exclusive where 
                    fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel  and
                    fat-duplic.serie        = cst_fat_duplic.serie        and
                    fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura    and
                    fat-duplic.parcela      = cst_fat_duplic.parcela
                    query-tuning(no-lookahead):
                    assign fat-duplic.int-1 = cst_fat_duplic.cod_portador
                           fat-duplic.int-2 = cst_fat_duplic.modalidade.
                    /* nota - nao gera ACR */
                    if fat-duplic.cod-esp <> "CV" and
                       fat-duplic.cod-esp <> "CE" then 
                        assign fat-duplic.ind-fat-nota = 2.
                end.
            end.
            for first tt-cst_nota_fiscal no-lock where
                tt-cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel and
                tt-cst_nota_fiscal.serie       = nota-fiscal.serie       and
                tt-cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis
                query-tuning(no-lookahead):
                create cst_nota_fiscal.
                buffer-copy tt-cst_nota_fiscal to cst_nota_fiscal.
            end.
            /* acerto pis/cofins */
            for each it-nota-fisc EXCLUSIVE of nota-fiscal query-tuning(no-lookahead):

                /*
                display it-nota-fisc.cod-estabel
                        it-nota-fisc.serie
                        it-nota-fisc.nr-nota-fis
                        it-nota-fisc.it-codigo
                        substring(it-nota-fisc.char-2,96,1) label "TribNFPS"
                        substring(it-nota-fisc.char-2,76,5) label "%NFPS"
                    with width 550 stream-io.
                */

                for each tt-it-docto where
                    tt-it-docto.cod-estabel         = it-nota-fisc.cod-estabel  and
                    tt-it-docto.serie               = it-nota-fisc.serie        and
                    tt-it-docto.nr-nota             = it-nota-fisc.nr-nota-fis  and
                    tt-it-docto.nr-sequencia        = it-nota-fisc.nr-seq-fat   and
                    tt-it-docto.it-codigo           = it-nota-fisc.it-codigo
                    query-tuning(no-lookahead):

                    /*
                    display tt-it-docto.cod-estabel  
                            tt-it-docto.serie        
                            tt-it-docto.nr-nota      
                            tt-it-docto.nr-sequencia 
                            tt-it-docto.it-codigo    
                            substring(tt-it-docto.char-2,96,1) label "TribNFPS"
                            substring(tt-it-docto.char-2,76,5) label "%NFPS"
                        with width 550 stream-io.
                    */

                   assign overlay(it-nota-fisc.char-2,76,5) = substr(tt-it-docto.char-2,76,5)  /* Aliquota PIS      */
                          overlay(it-nota-fisc.char-2,81,5) = substr(tt-it-docto.char-2,81,5)  /* Aliquota COFINS   */
                          overlay(it-nota-fisc.char-2,86,5) = substr(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */
                          overlay(it-nota-fisc.char-2,91,5) = substr(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */
                          overlay(it-nota-fisc.char-2,96,1) = substr(tt-it-docto.char-2,96,1)  /* Tributaá∆o PIS    */
                          overlay(it-nota-fisc.char-2,97,1) = substr(tt-it-docto.char-2,97,1). /* Tributaá∆o COFINS */

                   /*
                   display it-nota-fisc.cod-estabel
                           it-nota-fisc.serie
                           it-nota-fisc.nr-nota-fis
                           it-nota-fisc.it-codigo
                           substring(it-nota-fisc.char-2,96,1) label "TribNFPS2"
                           substring(it-nota-fisc.char-2,76,5) label "%NFPS2" 
                       with width 550 stream-io.
                   */

                   &if "{&bf_dis_versao_ems}" < "2.07" &then
                       /*  CSTÔs */
                       assign  overlay(it-nota-fisc.char-1,75,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,75,2)),"99"))
                               overlay(it-nota-fisc.char-1,77,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,77,2)),"99"))
                               overlay(it-nota-fisc.char-1,79,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,79,2)),"99")).
    
                       /* Modalidades de base */
                       assign  overlay(it-nota-fisc.char-1,81,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,81,2)),"99"))
                               overlay(it-nota-fisc.char-1,85,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,85,2)),"99"))
                               overlay(it-nota-fisc.char-1,83,2)  = TrataNuloChar(string(int(substring(tt-it-docto.char-1,83,2)),"99")).
                       /* acertar mod base de ipi n∆o informada */
                       if substring(it-nota-fisc.char-1,83,2)     = 0 then overlay(it-nota-fisc.char-1,83,2) = "1".
                   &else  
                       /*  CSTÔs */
                       assign  it-nota-fisc.cod-sit-tributar-ipi   = TrataNuloChar(string(int(substring(tt-it-docto.char-1,75,2)),"99")) 
                               it-nota-fisc.cod-sit-tributar-pis   = TrataNuloChar(string(int(substring(tt-it-docto.char-1,77,2)),"99")) 
                               it-nota-fisc.cod-sit-tributar-cofin = TrataNuloChar(string(int(substring(tt-it-docto.char-1,79,2)),"99")).
                       
                       /* Modalidades de base */
                       assign  it-nota-fisc.idi-modalid-base-icms    = int(TrataNuloChar(substring(tt-it-docto.char-1,81,2))) 
                               it-nota-fisc.idi-modalid-base-icms-st = int(TrataNuloChar(substring(tt-it-docto.char-1,85,2)))
                               it-nota-fisc.idi-modalid-base-ipi     = int(TrataNuloChar(substring(tt-it-docto.char-1,83,2))).
                       /* acertar mod base de ipi n∆o informada */
                       if it-nota-fisc.idi-modalid-base-ipi = 0 then  it-nota-fisc.idi-modalid-base-ipi = 1. 
                   &endif
                end.
            end.
            for first estabelec fields (cod-estabel cgc) no-lock where 
                estabelec.cod-estabel = nota-fiscal.cod-estabel
                query-tuning(no-lookahead): 
                for each int_ds_nota_loja where
                        int_ds_nota_loja.cnpj_filial = estabelec.cgc and
                        int_ds_nota_loja.serie       = nota-fiscal.serie and
                        int_ds_nota_loja.num_nota    = trim(string(int(nota-fiscal.nr-nota-fis),"999999")) and
                        int_ds_nota_loja.emissao     = nota-fiscal.dt-emis-nota and
                        int_ds_nota_loja.situacao    = 1
                        query-tuning(no-lookahead):

                        for each cst_estabelec no-lock WHERE cst_estabelec.cod_estabel = estabelec.cod-estabel:
                            d-dt-procfit  = cst_estabelec.dt_inicio_oper.
                            c-sistema-lj  = if d-dt-procfit <= d-dt-emissao then "PROCFIT" else "OBLAK".
                        end.
                        assign i-erro       = 1
                               c-informacao = "Estab.: " + nota-fiscal.cod-estabel + "/" + "SÇrie: " + nota-fiscal.serie + "/" + "Nr. Nota: " + nota-fiscal.nr-nota-fis + "/" + "Nome Abrev.: " + nota-fiscal.nome-ab-cli.
                        assign int_ds_nota_loja.situacao = 2 /* integrado */.
                        run gera-log.
                        release int_ds_nota_loja.
                 end.
            end.
        end.
    end.
    
    /* verificando notas n∆o importadas */
    for each tt-docto query-tuning(no-lookahead):
        if not can-find (first nota-fiscal no-lock where
                               nota-fiscal.cod-estabel = tt-docto.cod-estabel and
                               nota-fiscal.serie       = tt-docto.serie       and
                               nota-fiscal.nr-nota-fis = tt-docto.nr-nota) then do:
            for first estabelec fields (cod-estabel cgc) no-lock where 
                estabelec.cod-estabel = tt-docto.cod-estabel
                query-tuning(no-lookahead): 
                for each cst_estabelec no-lock WHERE cst_estabelec.cod_estabel = estabelec.cod-estabel:
                    d-dt-procfit  = cst_estabelec.dt_inicio_oper.
                    c-sistema-lj  = if d-dt-procfit <= d-dt-emissao then "PROCFIT" else "OBLAK".
                end.

                for first int_ds_nota_loja where
                    int_ds_nota_loja.cnpj_filial = estabelec.cgc and
                    int_ds_nota_loja.serie       = nota-fiscal.serie and
                    int_ds_nota_loja.num_nota    = trim(string(int(tt-docto.nr-nota),"999999")) and
                    int_ds_nota_loja.emissao     = tt-docto.dt-emis-nota and
                    int_ds_nota_loja.situacao    = 1
                    query-tuning(no-lookahead):
                    
                    run pi-acompanhar in h-acomp (input "Marcando N∆o Integrada: " + tt-docto.nr-nota).
                    assign i-erro       = 22
                           c-serie      = tt-docto.serie
                           c-num-nota   = tt-docto.nr-nota
                           c-informacao = "Estab.: " + tt-docto.cod-estabel
                                        + "/" +
                                        "SÇrie: " + tt-docto.serie
                                        + "/" +
                                        "Nr. Nota: " + tt-docto.nr-nota
                                        + "/" +
                                        "Nome Abrev.: " + tt-docto.nome-abrev
                                        + " Nota Fiscal n∆o integrada" .
                    run gera-log.
                end.
            end.
            for each cst_fat_duplic exclusive-lock where 
                cst_fat_duplic.cod_estabel = tt-docto.cod-estabel and
                cst_fat_duplic.serie       = tt-docto.serie and
                cst_fat_duplic.nr_fatura   = tt-docto.nr-fatura
                query-tuning(no-lookahead):
                delete cst_fat_duplic.
            end.                
        end.
    end.
    
    IF VALID-HANDLE(h-cdapi1001) THEN DO:
       DELETE PROCEDURE h-cdapi1001.
       ASSIGN h-cdapi1001 = ?.
    END.
    
    run pi-elimina-tabelas.
end procedure.

procedure pi-erros-nota:

    define input parameter pcod-erro as integer.
    define input parameter pmensagem as character.

    &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN
        for first cadast_msg fields (des_text_msg) no-lock where 
            cadast_msg.cdn_msg = pcod-erro
            query-tuning(no-lookahead): end.
           
        assign i-erro = 22
               c-informacao = "Estab.: " + trim(substring(c-cod-estabel + "/" + "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + "/" + "Nome Abrev.: " + c-nome-abrev               
                              + " - " + 
                              "Cod. Erro: " + string(pcod-erro) + " - " +
                              replace(des_text_msg,"&1", pmensagem),1,400)).
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    &else
        for first Cad-msgs fields (Cad-msgs.texto-msg) no-lock where 
            Cad-msgs.cd-msg = pcod-erro query-tuning(no-lookahead): end.
            
        assign i-erro = 22
               c-informacao = "Estab.: " + trim(substring(c-cod-estabel + "/" + "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + "/" + "Nome Abrev.: " + c-nome-abrev               
                              + " - " + 
                              "Cod. Erro: " + string(pcod-erro) + " - " +
                              replace(Cad-msgs.texto-msg,"$1", pmensagem),1,400)).
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    &endif
end.

procedure gera-log.

   if c-sistema-lj <> "" then
       assign c-informacao = c-sistema-lj + "-" + c-informacao.

   if i-nr-registro mod 100 = 0 then
       run pi-acompanhar in h-acomp (input "Listando Erros").
   IF tt-param.arquivo <> "" THEN DO:

           display /*stream str-rp*/
                   i-nr-registro
                   with frame f-erro width 550 stream-io. 
               
           display /*stream str-rp*/
                   tb-erro[i-erro] @ tb-erro[1]
                   c-informacao
                   with frame f-erro width 550 stream-io.
           down /*stream str-rp*/
                with frame f-erro.
   end.        
   
   assign c-chave = trim(int_ds_nota_loja.cnpj_filial + "/" + c-serie  + "/" + trim(string(int(c-num-nota),">>>9999999"))).

   run intprg/int999.p ("CUPOM", 
                        c-chave,
                        substring(trim(tb-erro[i-erro]) + " - " + c-informacao,1,500),
                        int_ds_nota_loja.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario,
                        c-prog-log).

   for each  int_ds_log use-index orig_chave_sit_dt 
       where int_ds_log.origem = "CUPOM" 
         and int_ds_log.chave  = c-chave query-tuning(no-lookahead):
      assign int_ds_log.dt_movto = int_ds_nota_loja.emissao.
      IF int_ds_log.dt_movto = ? THEN
         ASSIGN int_ds_log.dt_movto = int_ds_log.dt_ocorrencia.
   end.
   release int_ds_log.

   assign c-informacao = " ".
end.
/* FIM DO PROGRAMA */

procedure apaga-registro-atual:
    for first tt-docto where 
        tt-docto.cod-estabel = c-cod-estabel and
        tt-docto.serie       = c-serie       and
        tt-docto.nr-nota     = c-num-nota
        query-tuning(no-lookahead):
        for each tt-it-docto where
            tt-it-docto.cod-estabel = c-cod-estabel and
            tt-it-docto.serie       = c-serie       and
            tt-it-docto.nr-nota     = c-num-nota
            query-tuning(no-lookahead):
            for each tt-it-imposto where 
                tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
                query-tuning(no-lookahead):
                delete tt-it-imposto.
            end.
            for each tt-saldo-estoq where 
                tt-saldo-estoq.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
                query-tuning(no-lookahead):
                delete tt-saldo-estoq.
            end.
            delete tt-it-docto. 
        end.
        for each tt-fat-duplic where tt-fat-duplic.seq-tt-docto = tt-docto.seq-tt-docto
            query-tuning(no-lookahead):
            delete tt-fat-duplic.
        end.
        for each tt-fat-repre where tt-fat-repre.seq-tt-docto = tt-docto.seq-tt-docto
            query-tuning(no-lookahead):
            delete tt-fat-repre.
        end.
        for each tt-cst_nota_fiscal where 
            tt-cst_nota_fiscal.cod_estabel = c-cod-estabel and
            tt-cst_nota_fiscal.serie       = c-serie       and
            tt-cst_nota_fiscal.nr_nota     = c-num-nota
            query-tuning(no-lookahead):
            delete tt-cst_nota_fiscal.
        end.
        for each tt-int_ds_nota_loja_cartao no-lock where 
            tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota
            query-tuning(no-lookahead):
            delete tt-int_ds_nota_loja_cartao.
        end.
        delete tt-docto.
    end.
end.

procedure finaliza-cupom.
   run pi-acompanhar in h-acomp (input "Finalizando Cupom: " + trim(int_ds_nota_loja.num_nota)).
   find current int_ds_nota_loja exclusive-lock no-error.
   if avail int_ds_nota_loja then do:
       for first nota-fiscal fields (cod-estabel nr-fatura
                                    serie cod-cond-pag modalidade
                                    nr-nota-fis cod-portador)
         where nota-fiscal.cod-estabel = c-cod-estabel
         and   nota-fiscal.serie       = c-serie
         and   nota-fiscal.nr-nota-fis = c-num-nota
         exclusive-lock query-tuning(no-lookahead):
    

         if int_ds_nota_loja.istatus = "I" then do:
             if nota-fiscal.idi-sit-nf-eletro = 0 then nota-fiscal.idi-sit-nf-eletro = 7.
             if nota-fiscal.idi-forma-emis-nf-eletro = 0 then nota-fiscal.idi-forma-emis-nf-eletro = 1.
         end.

         for each cst_fat_duplic no-lock where 
             cst_fat_duplic.cod_estabel = nota-fiscal.cod-estabel and
             cst_fat_duplic.serie       = nota-fiscal.serie and
             cst_fat_duplic.nr_fatura   = nota-fiscal.nr-fatura
             query-tuning(no-lookahead):
             for each fat-duplic exclusive where 
                 fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel  and
                 fat-duplic.serie        = cst_fat_duplic.serie        and
                 fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura    and
                 fat-duplic.parcela      = cst_fat_duplic.parcela
                 query-tuning(no-lookahead):
                 assign fat-duplic.int-1 = cst_fat_duplic.cod_portador
                        fat-duplic.int-2 = cst_fat_duplic.modalidade.
                 /* nota - nao gera ACR */
                 if fat-duplic.cod-esp <> "CV" AND 
                    fat-duplic.cod-esp <> "CE" then 
                     assign fat-duplic.ind-fat-nota = 2.
             end.
         end.
    
         for first cst_nota_fiscal WHERE
                   cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel AND
                   cst_nota_fiscal.serie       = nota-fiscal.serie AND
                   cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis exclusive-lock query-tuning(no-lookahead): end.
         if not avail cst_nota_fiscal then do:
             create cst_nota_fiscal.
             assign cst_nota_fiscal.cod_estabel       = nota-fiscal.cod-estabel
                    cst_nota_fiscal.serie             = nota-fiscal.serie
                    cst_nota_fiscal.nr_nota_fis       = nota-fiscal.nr-nota-fis.
         end.
         assign cst_nota_fiscal.condipag            = int_ds_nota_loja.condipag
                cst_nota_fiscal.convenio            = int_ds_nota_loja.convenio
                cst_nota_fiscal.cupom_ecf           = int_ds_nota_loja.cupom_ecf
                cst_nota_fiscal.nfce_chave          = int_ds_nota_loja.nfce_chave_s
                cst_nota_fiscal.valor_chq           = int_ds_nota_loja.valor_chq
                cst_nota_fiscal.valor_chq_pre       = int_ds_nota_loja.valor_chq_pre
                cst_nota_fiscal.valor_convenio      = int_ds_nota_loja.valor_convenio
                cst_nota_fiscal.valor_dinheiro      = int_ds_nota_loja.valor_din_mov
                cst_nota_fiscal.valor_ticket        = int_ds_nota_loja.valor_ticket
                cst_nota_fiscal.valor_vale          = int_ds_nota_loja.valor_vale
                cst_nota_fiscal.valor_cartao        = int_ds_nota_loja.valor_cartaod + 
                                                      int_ds_nota_loja.valor_cartaoc
                cst_nota_fiscal.nfce_dt_transmissao = int_ds_nota_loja.nfce_transmissao_d
                cst_nota_fiscal.nfce_protocolo      = int_ds_nota_loja.nfce_protocolo_s
                cst_nota_fiscal.nfce_transmissao    = int_ds_nota_loja.nfce_transmissao_s
                cst_nota_fiscal.cpf_cupom           = if int_ds_nota_loja.condipag <> "83" 
                                                      then int_ds_nota_loja.cpf_cliente    
                                                      else "00000000985" /* GoldenFarma */ 
                cst_nota_fiscal.cartao_manual       = (int_ds_nota_loja.cartao_manual = 1)
                cst_nota_fiscal.orgao               = c-orgao
                cst_nota_fiscal.categoria           = c-categoria
                .
       end.
       for each it-nota-fisc exclusive of nota-fiscal
           query-tuning(no-lookahead):

           find natur-oper no-lock where natur-oper.nat-operacao = it-nota-fisc.nat-operacao no-error.
           find item no-lock where item.it-codigo = it-nota-fisc.it-codigo no-error.
           find tt-it-docto no-lock where
               tt-it-docto.cod-estabel         = it-nota-fisc.cod-estabel and
               tt-it-docto.serie               = it-nota-fisc.serie       and
               tt-it-docto.nr-nota             = it-nota-fisc.nr-nota-fis and
               tt-it-docto.nr-sequencia        = it-nota-fisc.nr-seq-fat  and
               tt-it-docto.it-codigo           = it-nota-fisc.it-codigo no-error.

           /* recopiar valores pis/cofins alterados pela ft2010 */
           if avail tt-it-docto then do:

               assign overlay(it-nota-fisc.char-2,76,5) = substr(tt-it-docto.char-2,76,5)  /* Aliquota PIS      */
                      overlay(it-nota-fisc.char-2,81,5) = substr(tt-it-docto.char-2,81,5)  /* Aliquota COFINS   */
                      overlay(it-nota-fisc.char-2,86,5) = substr(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */
                      overlay(it-nota-fisc.char-2,91,5) = substr(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */
                      overlay(it-nota-fisc.char-2,96,1) = substr(tt-it-docto.char-2,96,1)  /* Tributaá∆o PIS    */
                      overlay(it-nota-fisc.char-2,97,1) = substr(tt-it-docto.char-2,97,1). /* Tributaá∆o COFINS */

               &if "{&bf_dis_versao_ems}" < "2.07" &then
                   /*  CSTÔs */
                   assign  overlay(it-nota-fisc.char-1,75,2)  = substring(tt-it-docto.char-1,75,2)
                           overlay(it-nota-fisc.char-1,77,2)  = substring(tt-it-docto.char-1,77,2)
                           overlay(it-nota-fisc.char-1,79,2)  = substring(tt-it-docto.char-1,79,2).
    
                   /* Modalidades de base */
                   assign  overlay(it-nota-fisc.char-1,81,2)  = substring(tt-it-docto.char-1,81,2)
                           overlay(it-nota-fisc.char-1,85,2)  = substring(tt-it-docto.char-1,85,2)
                           overlay(it-nota-fisc.char-1,83,2)  = substring(tt-it-docto.char-1,83,2).

                   if substring(it-nota-fisc.char-1,83,2) = "0" then overlay(it-nota-fisc.char-1,83,2) = "1".

               &else
                   assign  it-nota-fisc.cod-sit-tributar-ipi   = substring(tt-it-docto.char-1,75,2) 
                           it-nota-fisc.cod-sit-tributar-pis   = substring(tt-it-docto.char-1,77,2) 
                           it-nota-fisc.cod-sit-tributar-cofin = substring(tt-it-docto.char-1,79,2).
    
                   /*  CSTÔs */
                   assign  it-nota-fisc.idi-modalid-base-icms     = int(substring(tt-it-docto.char-1,81,2))
                           it-nota-fisc.idi-modalid-base-icms-st  = int(substring(tt-it-docto.char-1,85,2))
                           it-nota-fisc.idi-modalid-base-ipi      = int(substring(tt-it-docto.char-1,83,2)).
                   if it-nota-fisc.idi-modalid-base-ipi = 0 then it-nota-fisc.idi-modalid-base-ipi = 1.
               &endif
           end. 
           /* recalcular se tt-it-docto n∆o encontrado - retorno de queda de processamento e cupom importado sem finalizaá∆o */
           else do:

                for each int_ds_nota_loja_item no-lock of int_ds_nota_loja where
                    int_ds_nota_loja_item.produto   = it-nota-fisc.it-codigo:

                    if int(int_ds_nota_loja_item.sequencia) * 10 = it-nota-fisc.nr-seq-fat then do:

                        /* Tributaá∆o PIS    */ 
                        if int_ds_nota_loja_item.valorpis <> ? and /* preenchido = Procfit */
                           int_ds_nota_loja_item.percentualpis <> ? then do:
                            overlay(it-nota-fisc.char-2,96,1)           = if int_ds_nota_loja_item.valorpis > 0 then "1" else "2".
                            overlay(it-nota-fisc.char-2,76,5)           = string(TrataNuloDec(int_ds_nota_loja_item.percentualpis),"99.99").
                        end.
                        else do: /* Nao Preenchido = Oblak */
                            /* Tributaá∆o PIS    */ 
                            overlay(it-nota-fisc.char-2,96,1) = (substr(natur-oper.char-1,86,1)).
    
                            /* Aliquota PIS      */ 
                            overlay(it-nota-fisc.char-2,76,5) = "00,00".
                            if int(substring(it-nota-fisc.char-2,96,1)) = 1 then do:
                                if natur-oper.mercado = 1 then                         /* Mercado Interno */
                                    if substr(item.char-2,52,1) = "1" then             /* Al°quota do Item */
                                        overlay(it-nota-fisc.char-2,76,5) = string(dec(substr(item.char-2,31,5)),"99.99").
                                    else /* aliquota da natureza*/
                                        overlay(it-nota-fisc.char-2,76,5) = string(natur-oper.perc-pis[1],"99.99").
                                else  /* Mercado externo */
                                    overlay(it-nota-fisc.char-2,76,5) = string(natur-oper.perc-pis[2],"99.99").
                            end.
                        end.
                        /* sem aliquota deve ficar como isento */
                        if dec(substring(it-nota-fisc.char-2,76,5)) = 0 then
                            overlay(it-nota-fisc.char-2,96,1) = "2".
    
                        /* Tributaá∆o COFINS */
                        if int_ds_nota_loja_item.valorcofins <> ? and /* preenchido = Procfit */
                           int_ds_nota_loja_item.percentualcofins <> ? then do:
                            overlay(it-nota-fisc.char-2,97,1)           = if int_ds_nota_loja_item.valorcofins > 0 then "1" else "2".
                            overlay(it-nota-fisc.char-2,81,5)           = string(TrataNuloDec(int_ds_nota_loja_item.percentualcofins),"99.99").
                        end.
                        else do: /* Nao Preenchido = Oblak */
                            /* Tributaá∆o COFINS */
                            overlay(it-nota-fisc.char-2,97,1) = (substr(natur-oper.char-1,87,1)).
    
                            /* Aliquota COFINS   */ 
                            overlay(it-nota-fisc.char-2,81,5) = "00,00".
                            if int(substr(it-nota-fisc.char-2,97,1)) = 1 then do:
                                if natur-oper.mercado = 1 then                    /* Mercado Interno */               
                                    if substr(item.char-2,53,1) = "1" then        /* aliquota do item */
                                        overlay(it-nota-fisc.char-2,81,5) = string(dec(substr(item.char-2,36,5)),"99.99").
                                    else /* aliquota da natureza*/
                                        overlay(it-nota-fisc.char-2,81,5) = string(natur-oper.per-fin-soc[1],"99.99").
                                else /* Mercado externo */ 
                                    overlay(it-nota-fisc.char-2,81,5) = string(natur-oper.per-fin-soc[2],"99.99").
                            end.
                        end.
                        /* sem aliquota deve ficar como isento */
                        if dec(substring(it-nota-fisc.char-2,81,5)) = 0 then 
                            overlay(it-nota-fisc.char-2,97,1) = "2" .
    
                        overlay(it-nota-fisc.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
                        overlay(it-nota-fisc.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".
                    
                        &if "{&bf_dis_versao_ems}" < "2.07" &then
                            /*  CSTÔs */
                            assign  overlay(it-nota-fisc.char-1,75,2)   = TrataNuloChar(string(int_ds_nota_loja_item.cstbipi,"99"))
                                    overlay(it-nota-fisc.char-1,77,2)   = TrataNuloChar(string(int_ds_nota_loja_item.cstbpis,"99"))
                                    overlay(it-nota-fisc.char-1,79,2)   = TrataNuloChar(string(int_ds_nota_loja_item.cstbcofins,"99")).
        
                            /* Modalidades de base */
                            assign  overlay(it-nota-fisc.char-1,81,2)   = TrataNuloChar(string(int_ds_nota_loja_item.modbcicms))
                                    overlay(it-nota-fisc.char-1,85,2)   = TrataNuloChar(string(int_ds_nota_loja_item.modbcst))
                                    overlay(it-nota-fisc.char-1,83,2)   = TrataNuloChar(string(int_ds_nota_loja_item.modbipi)).

                            /* preenchendo mod base ipi caso n∆o preenchido */
                            if substring(it-nota-fisc.char-1,83,2) then overlay(it-nota-fisc.char-1,83,2) = "1".

                        &else
                            assign  it-nota-fisc.cod-sit-tributar-ipi   = TrataNuloChar(string(int_ds_nota_loja_item.cstbipi,"99"))
                                    it-nota-fisc.cod-sit-tributar-pis   = TrataNuloChar(string(int_ds_nota_loja_item.cstbpis,"99"))
                                    it-nota-fisc.cod-sit-tributar-cofin = TrataNuloChar(string(int_ds_nota_loja_item.cstbcofins,"99")).
        
                            /* Modalidades de base */
                            assign  it-nota-fisc.idi-modalid-base-icms    = int(TrataNuloDec(int_ds_nota_loja_item.modbcicms))
                                    it-nota-fisc.idi-modalid-base-ipi     = int(TrataNuloDec(int_ds_nota_loja_item.modbipi))
                                    it-nota-fisc.idi-modalid-base-icms-st = int(TrataNuloDec(int_ds_nota_loja_item.modbcst)).

                            if it-nota-fisc.idi-modalid-base-ipi = 0 then it-nota-fisc.idi-modalid-base-ipi = 1.
                        &endif
                    end.                        
                end.
           end.    
       end.
       assign i-erro       = 1
              c-informacao = "Estab.: " + c-cod-estabel + "/" + 
                             "SÇrie: " + c-serie + "/" + "Nr. Nota: " + c-num-nota + "/" + "Nome Abrev.: " + c-nome-abrev.
       assign int_ds_nota_loja.situacao = 2. /* integrado */
       assign l-cupom-com-erro = yes.
       run gera-log. 
       /*release int_ds_nota_loja.*/
   end.
end.
