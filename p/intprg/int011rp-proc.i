/* ESTA INCLUDE ESTÁ SENDO UTLIZADA NOS PROGRAMAS INT011, INT217 E INT237 */
/* QUALQUER ALTERAÇÃO DEVE SER TESTADA NOS TRES PROGRAMAS                 */

DEFINE BUFFER b-emitente FOR ems2mult.emitente.


def var l-sub as logical no-undo.
def var de-quantidade like int_ds_pedido_retorno.rpp_quantidade_n.
def var l-ok as logical no-undo.
def var i-pedido as integer no-undo.
def var i-ped-nota-saida-item AS INTEGER NO-UNDO.
def var i-ped-nota-entrada-item AS INTEGER NO-UNDO.
def var de-despesas as decimal no-undo.
def var c-cfop as char no-undo.
def var l-ped-balanco as logical no-undo.
def var de-tot-bicms  as decimal no-undo.
def var de-tot-icms   as decimal no-undo.
def var de-tot-bsubs  as decimal no-undo.
def var de-tot-icmst  as decimal no-undo.
def var c-disp-sistema as char no-undo.
DEFINE VARIABLE tipo-nota AS CHARACTER   NO-UNDO.
define buffer b-estabelec for ems2mult.estabelec.
define temp-table tt-lote like int_ds_pedido_retorno 
    field tipo as char
    index chave 
        ppr_produto_n 
        rpp_quantidade_n
        rpp_lote_s
        tipo.

form
    c-disp-sistema
    nota-fiscal.cod-estabel
    nota-fiscal.serie
    nota-fiscal.nr-nota-fis
    nota-fiscal.dt-emis-nota
    nota-fiscal.dt-cancela
  with frame f-rel down stream-io width 300.

/* ESTA INCLUDE ESTÁ SENDO UTLIZADA NOS PROGRAMAS INT011, INT217 E INT237 */
/* QUALQUER ALTERAÇÃO DEVE SER TESTADA NOS TRES PROGRAMAS                 */

procedure pi-saidas:

    define input param p-origem as character.
    define input param p-sit-oblak-s as integer.
    define input param p-sit-procfit-s as integer.

    define input param p-sit-oblak-e as integer.
    define input param p-sit-procfit-e as integer.

    FIND first int_ds_nota_saida where 
        int_ds_nota_saida.nsa_cnpj_origem_s = ems2mult.estabelec.cgc and
        int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND
        int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis) NO-ERROR.

    /*
    display
        p-origem column-label "Origem"
        nota-fiscal.cod-estabel
        nota-fiscal.serie
        nota-fiscal.nr-nota-fis
        nota-fiscal.dt-emis-nota
        nota-fiscal.dt-cancela
        with frame f-rel.
    down with frame f-rel.
    */

    /* inclusao da nota */
    if not avail int_ds_nota_saida 
    then DO:

        if tt-param.arquivo <> "" then DO:
            display
                p-origem @ c-disp-sistema column-label "Origem"
                nota-fiscal.cod-estabel                           
                nota-fiscal.serie
                nota-fiscal.nr-nota-fis
                nota-fiscal.dt-emis-nota
                nota-fiscal.dt-cancela
                with frame f-rel.
            down with frame f-rel.
        END.

        for each tt-lote query-tuning(no-lookahead). delete tt-lote. end.
        for each int_ds_pedido_retorno no-lock where
            int_ds_pedido_retorno.ped_codigo_n = int64(nota-fiscal.nr-pedcli) and
            int_ds_pedido_retorno.rpp_lote <> ? and int_ds_pedido_retorno.rpp_lote <> ""
            query-tuning(no-lookahead):
            create tt-lote.
            buffer-copy int_ds_pedido_retorno to tt-lote.

            if ems2mult.estabelec.cgc = nota-fiscal.cgc then do: /* Balanço */
               assign de-quantidade = int_ds_pedido_retorno.rpp_quantidade_n - int_ds_pedido_retorno.rpp_qtd_inventario_n.
               if de-quantidade < 0 then do:
                    assign  tt-lote.rpp_quantidade = de-quantidade * -1
                            tt-lote.tipo = "S".
               end.
               else do:
                    assign  tt-lote.rpp_quantidade = de-quantidade
                            tt-lote.tipo = "E".
               end.
            end.
        end.

        for each it-nota-fisc no-lock of nota-fiscal:

            //Alteracao 17-02-2025 (de For First para Find First
            FIND FIRST int_ds_nota_saida_item WHERE
                int_ds_nota_saida_item.nsa_cnpj_origem_s = ems2mult.estabelec.cgc and
                int_ds_nota_saida_item.nsa_serie_s =  nota-fiscal.serie AND
                int_ds_nota_saida_item.nsa_notafiscal_n =  int(nota-fiscal.nr-nota-fis) AND
                int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat and
                int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo) NO-ERROR.

            if not avail int_ds_nota_saida_item then do:

                find first item no-lock 
					where item.it-codigo = it-nota-fisc.it-codigo no-error.
                    

                IF NOT AVAIL ITEM THEN NEXT.

                .MESSAGE "Criando int_ds_nota_saida_item"  skip  
                        integer(nota-fiscal.nr-nota-fis)  skip 
                        nota-fiscal.serie                 skip 
                        it-nota-fisc.nr-seq-fat           skip 
                        int(it-nota-fisc.it-codigo)
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                create  int_ds_nota_saida_item.                        
                assign  int_ds_nota_saida_item.nsa_cnpj_origem_s       = estabelec.cgc      
                        int_ds_nota_saida_item.nsa_notafiscal_n        = integer(nota-fiscal.nr-nota-fis)                      
                        int_ds_nota_saida_item.nsa_serie_s             = nota-fiscal.serie                                     
                        int_ds_nota_saida_item.nsp_sequencia_n         = it-nota-fisc.nr-seq-fat
                        int_ds_nota_saida_item.nsp_produto_n           = int(it-nota-fisc.it-codigo)
                        int_ds_nota_saida_item.nsp_quantidade_n        = it-nota-fisc.qt-faturada[1]
                        int_ds_nota_saida_item.nsp_valorbruto_n        = it-nota-fisc.vl-merc-ori
                        int_ds_nota_saida_item.nsp_desconto_n          = it-nota-fisc.vl-desconto
                        int_ds_nota_saida_item.nsp_valorliquido_n      = it-nota-fisc.vl-merc-liq
                        int_ds_nota_saida_item.nsp_baseicms_n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int_ds_nota_saida_item.nsp_valoricms_n         = it-nota-fisc.vl-icms-it
                        int_ds_nota_saida_item.nsp_basediferido_n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int_ds_nota_saida_item.nsp_baseisenta_n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                         then it-nota-fisc.vl-icmsnt-it else 0.

                assign  int_ds_nota_saida_item.nsp_valoripi_n          = 0 /*it-nota-fisc.vl-ipi-it*/
                        int_ds_nota_saida_item.nsp_icmsst_n            = it-nota-fisc.vl-icmsub-it
                        int_ds_nota_saida_item.nsp_basest_n            = it-nota-fisc.vl-bsubs-it
                        int_ds_nota_saida_item.nsp_valortotalproduto_n = it-nota-fisc.vl-tot-item.

                assign  int_ds_nota_saida_item.nsp_percentualicms_n    = it-nota-fisc.aliquota-icm
                        int_ds_nota_saida_item.nsp_percentualipi_n     = 0 /*it-nota-fisc.aliquota-ipi*/
                        int_ds_nota_saida_item.nsp_redutorbaseicms_n   = it-nota-fisc.perc-red-icm.
                assign  int_ds_nota_saida_item.nsp_valordespesa_n      = it-nota-fisc.vl-despes-it
                        int_ds_nota_saida_item.nsp_valorpis_n          = it-nota-fisc.vl-pis
                        int_ds_nota_saida_item.nsp_valorcofins_n       = it-nota-fisc.vl-finsocial
                        int_ds_nota_saida_item.nsp_peso_n              = it-nota-fisc.peso-bruto
                        int_ds_nota_saida_item.nsp_baseipi_n           = 0 /*it-nota-fisc.vl-bipi-it*/.
                assign  int_ds_nota_saida_item.nsp_ncm_s               = if   it-nota-fisc.class-fiscal <> ""
                                                                         then it-nota-fisc.class-fiscal
                                                                         else item.class-fiscal
                        int_ds_nota_saida_item.nsp_csta_n              = item.codigo-orig
                        int_ds_nota_saida_item.nsp_valortributos_n     = int_ds_nota_saida_item.nsp_valoricms_n 
                                                                       + int_ds_nota_saida_item.nsp_valoripi_n
                                                                       + int_ds_nota_saida_item.nsp_icmsst_n
                                                                       + int_ds_nota_saida_item.nsp_valorpis_n
                                                                       + int_ds_nota_saida_item.nsp_valorcofins_n.

                RUN pi-custo-grade (OUTPUT int_ds_nota_saida_item.nsp_valorgrade_n).

                run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                                   output int_ds_nota_saida_item.nsp_cstb_n,
                                   output l-sub).
                
                FIND FIRST natur-oper NO-LOCK                           
                    WHERE natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-ERROR.
             
                    assign  int_ds_nota_saida_item.nsp_cfop_n = int(replace(natur-oper.cod-cfop,".","")).
               
				
				find first item no-lock 
					where item.it-codigo = it-nota-fisc.it-codigo no-error.


                assign  i-ped-nota-saida-item                          = if it-nota-fisc.nr-pedcli <> "" then int64(replace(it-nota-fisc.nr-pedcli,".",""))   
                                                                         else if nota-fiscal.nr-pedcli <> "" then int64(replace(nota-fiscal.nr-pedcli,".",""))
                                                                         else integer(replace(nota-fiscal.docto-orig,".",""))                                   
                        int_ds_nota_saida_item.ped_codigo_n            = /*if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                         else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                         else integer(replace(nota-fiscal.docto-orig,".",""))*/ 0
                        int_ds_nota_saida_item.nsp_basepis_n           = it-nota-fisc.vl-tot-item
                                                                        - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                           or  substr(item.char-1,50,5) = "Sim"
                                                                           then   it-nota-fisc.vl-pis
                                                                                + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                        - (if natur-oper.tp-oper-terc = 4
                                                                           then it-nota-fisc.vl-icmsubit-e[3]
                                                                           else it-nota-fisc.vl-icmsub-it)
                        int_ds_nota_saida_item.nsp_basecofins_n        = it-nota-fisc.vl-tot-item
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
                     assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                                   /*- it-nota-fisc.vl-ipi-it*/
                                                                   - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                      then it-nota-fisc.vl-ipiit-e[3]
                                                                      else 0).
                     assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                                    /*- it-nota-fisc.vl-ipi-it*/
                                                                    - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                       then it-nota-fisc.vl-ipiit-e[3]
                                                                       else 0).
                end.
                /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
                if  it-nota-fisc.cd-trib-ipi = 3 
                and substring(natur-oper.char-2,16,1) = "1":U
                and not natur-oper.log-ipi-outras-contrib-social then do:
                    assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                    assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                end.
                assign  int_ds_nota_saida_item.nsp_cstbpis_s           = if substr(it-nota-fisc.char-2,96,1) = "1" then "01"
                                                                         else if substr(it-nota-fisc.char-2,96,1) = "1" then "07"
                                                                         else if substr(it-nota-fisc.char-2,96,1) = "3" then "02"
                                                                         else if it-nota-fisc.idi-forma-calc-pis = 2 then "03" else "99"
                        int_ds_nota_saida_item.nsp_cstbcofins_s        = if substr(it-nota-fisc.char-2,97,1) = "1" then "01"
                                                                         else if substr(it-nota-fisc.char-2,97,1) = "1" then "07"
                                                                         else if substr(it-nota-fisc.char-2,97,1) = "3" then "02"
                                                                         else if it-nota-fisc.idi-forma-calc-cofins = 2 then "03" else "99"
                        int_ds_nota_saida_item.nsp_percentualpis_n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                else 0)
                                                                       / 10000.
                        int_ds_nota_saida_item.nsp_percentualcofins_n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                else 0)
                                                                       / 10000.
                for first fat-ser-lote no-lock of it-nota-fisc
                    query-tuning(no-lookahead):
                    assign  int_ds_nota_saida_item.nsp_lote_s  = substring(fat-ser-lote.nr-serlote,1,10)
                            int_ds_nota_saida_item.nsp_datavalidade_d = fat-ser-lote.dt-vali-lote.
                end.

                assign  int_ds_nota_saida_item.nen_notafiscal_n = integer(it-nota-fisc.nr-docum)
                        int_ds_nota_saida_item.nen_serie_s      = it-nota-fisc.serie-docum.
                if it-nota-fisc.nr-docum <> "" then do:
                    for first rat-lote fields (sequencia) no-lock where 
                        rat-lote.serie-docto  = it-nota-fisc.nr-docum and    
                        rat-lote.nro-docto    = it-nota-fisc.serie-docum and 
                        rat-lote.nat-operacao = it-nota-fisc.nat-docum and   
                        rat-lote.cod-emitente = nota-fiscal.cod-emitente and 
                        rat-lote.sequencia    > 0 and 
                        rat-lote.it-codigo    = it-nota-fisc.it-codigo and
                        rat-lote.lote = int_ds_nota_saida_item.nsp_lote_s
                        query-tuning(no-lookahead):
                        assign int_ds_nota_saida_item.nep_sequencia_n  = rat-lote.sequencia.
                    end.
                end.

                if /*int_ds_nota_saida_item.ped_codigo_n*/ i-ped-nota-saida-item <> 0 then 
                   assign i-pedido = /*int_ds_nota_saida_item.ped_codigo_n*/ i-ped-nota-saida-item.
                
               assign int_ds_nota_saida_item.nsp_caixa_n = int(it-nota-fisc.nr-seq-ped).
               for first cst_ped_item no-lock where
                   cst_ped_item.nome_abrev     = nota-fiscal.nome-ab-cli and
                   cst_ped_item.nr_pedcli      = it-nota-fisc.nr-pedcli  and
                   cst_ped_item.nr_sequencia   = it-nota-fisc.nr-seq-ped and
                   cst_ped_item.it_codigo      = it-nota-fisc.it-codigo  and
                   cst_ped_item.cod_refer      = it-nota-fisc.cod-refer
                   query-tuning(no-lookahead):
                   assign int_ds_nota_saida_item.nsp_lote_s = cst_ped_item.numero_lote.
               end.

               if not avail cst_ped_item then do:
                   l-ok = no.
                   IF ems2mult.estabelec.cgc = nota-fiscal.cgc then do: /* Balanço */
                       for first tt-lote where 
                           tt-lote.ppr_produto_n  = int_ds_nota_saida_item.nsp_produto_n   and
                           tt-lote.rpp_quantidade = int_ds_nota_saida_item.nsp_quantidade  and
                           tt-lote.rpp_lote      <> ?                                      and
                           tt-lote.rpp_lote      <> ""                                     and
                           tt-lote.tipo           = "S"
                           query-tuning(no-lookahead):
                           assign int_ds_nota_saida_item.nsp_lote_s = tt-lote.rpp_lote
                                  int_ds_nota_saida_item.nsp_datavalidade_d = tt-lote.rpp_validade_d
                                  l-ok = yes.
                           //delete tt-lote.
                       end.
                   end.
                   /* demais notas */
                   else do:
                       for first tt-lote where 
                           tt-lote.ppr_produto_n  = int_ds_nota_saida_item.nsp_produto_n   and
                           tt-lote.rpp_quantidade = int_ds_nota_saida_item.nsp_quantidade  and
                           /* uma nota por caixa - caixa informada na nota */
                           tt-lote.rpp_caixa      = int_ds_nota_saida_item.nsp_caixa       and
                           tt-lote.rpp_lote      <> ?                                      and
                           tt-lote.rpp_lote      <> ""
                           query-tuning(no-lookahead):
                           assign int_ds_nota_saida_item.nsp_lote_s = tt-lote.rpp_lote
                                  int_ds_nota_saida_item.nsp_datavalidade_d = tt-lote.rpp_validade_d
                                  l-ok = yes.
                           //delete tt-lote.
                       end.
                       /* notas fiscais sem caixa */
                       if not l-ok then
                           for first tt-lote where 
                               tt-lote.ppr_produto_n  = int_ds_nota_saida_item.nsp_produto_n   and
                               tt-lote.rpp_quantidade = int_ds_nota_saida_item.nsp_quantidade  and
                               tt-lote.rpp_lote      <> ?                                      and
                               tt-lote.rpp_lote      <> ""
                               query-tuning(no-lookahead):
                               assign int_ds_nota_saida_item.nsp_lote = tt-lote.rpp_lote
                                      int_ds_nota_saida_item.nsp_datavalidade_d = tt-lote.rpp_validade_d
                                      l-ok = yes.
                               //delete tt-lote.
                           end.
                   end.
               end. /* avail cst_ped_item */

               FIND FIRST int_ds_nota_saida_relacto EXCLUSIVE-LOCK
                   WHERE int_ds_nota_saida_relacto.cod_estabel = it-nota-fisc.cod-estabel
                   AND   int_ds_nota_saida_relacto.serie       = it-nota-fisc.serie      
                   AND   int_ds_nota_saida_relacto.nr_nota_fis = it-nota-fisc.nr-nota-fis
                   AND   int_ds_nota_saida_relacto.nr_seq_fat  = it-nota-fisc.nr-seq-fat 
                   AND   int_ds_nota_saida_relacto.it_codigo   = it-nota-fisc.it-codigo NO-ERROR.

               FIND FIRST nar-it-nota NO-LOCK
                    WHERE nar-it-nota.cod-estabel   =  it-nota-fisc.cod-estabel 
                      AND nar-it-nota.nr-nota-fis   =  it-nota-fisc.nr-nota-fis
                      AND nar-it-nota.serie         =  it-nota-fisc.serie
                      AND nar-it-nota.it-codigo     =  it-nota-fisc.it-codigo    
                      AND nar-it-nota.nr-sequencia  =  it-nota-fisc.nr-seq-fat NO-ERROR.


               FIND FIRST INT_ds_pedido NO-LOCK
                   WHERE INT_Ds_pedido.ped_codigo_n = INT64(it-nota-fisc.nr-pedcli) NO-ERROR.

               IF AVAIL int_ds_nota_saida_relacto THEN DO:

                   .MESSAGE "Alterando int_ds_nota_saida_relacto"  skip  
                        integer(nota-fiscal.nr-nota-fis)  skip 
                        nota-fiscal.serie                 skip 
                        it-nota-fisc.nr-seq-fat           skip 
                        int(it-nota-fisc.it-codigo)       SKIP
                        AVAIL INT_Ds_pedido               SKIP
                        AVAIL nar-it-nota                 SKIP
                        int(it-nota-fisc.nr-pedcli)       SKIP
                        int(nota-fiscal.nr-pedcli)        
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                    ASSIGN int_ds_nota_saida_relacto.nsp_lote_s         = IF AVAIL nar-it-nota THEN trim(SUBSTR(nar-it-nota.narrativa,5,20))  ELSE ""      
                           int_ds_nota_saida_relacto.nsp_caixa_n        = int(it-nota-fisc.nr-seq-ped)    .
               END.
               ELSE DO:


                    .MESSAGE "Criando int_ds_nota_saida_relacto"  skip  
                        integer(nota-fiscal.nr-nota-fis)  skip 
                        nota-fiscal.serie                 skip 
                        it-nota-fisc.nr-seq-fat           skip 
                        int(it-nota-fisc.it-codigo)       SKIP
                        AVAIL INT_Ds_pedido               SKIP
                        AVAIL nar-it-nota                 SKIP
                        int(it-nota-fisc.nr-pedcli)       SKIP
                        int(nota-fiscal.nr-pedcli)
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                   CREATE int_ds_nota_saida_relacto.
                   ASSIGN int_ds_nota_saida_relacto.cod_estabel        = it-nota-fisc.cod-estabel
                          int_ds_nota_saida_relacto.serie              = it-nota-fisc.serie      
                          int_ds_nota_saida_relacto.nr_nota_fis        = it-nota-fisc.nr-nota-fis
                          int_ds_nota_saida_relacto.nr_seq_fat         = it-nota-fisc.nr-seq-fat 
                          int_ds_nota_saida_relacto.it_codigo          = it-nota-fisc.it-codigo
                          int_ds_nota_saida_relacto.nsa_cnpj_origem_s  = IF AVAIL int_ds_pedido THEN int_ds_pedido.ped_cnpj_origem_s ELSE ""
                          int_ds_nota_saida_relacto.nsa_cnpj_destino_s = IF AVAIL int_ds_pedido THEN int_ds_pedido.ped_cnpj_destino_s ELSE "" 
                          int_ds_nota_saida_relacto.nsa_notafiscal_n   = int(it-nota-fisc.nr-nota-fis)
                          int_ds_nota_saida_relacto.nsa_serie_s        = it-nota-fisc.serie       
                          int_ds_nota_saida_relacto.ped_codigo_n       = IF AVAIL int_ds_pedido THEN int_ds_pedido.ped_codigo_n ELSE INT(it-nota-fisc.nr-pedcli)     
                          int_ds_nota_saida_relacto.nsp_produto_n      = INT(it-nota-fisc.it-codigo)    
                          int_ds_nota_saida_relacto.nsp_lote_s         = IF AVAIL nar-it-nota THEN trim(SUBSTR(nar-it-nota.narrativa,5,20)) ELSE ""      
                          int_ds_nota_saida_relacto.nsp_caixa_n        = int(it-nota-fisc.nr-seq-ped)      
                          int_ds_nota_saida_relacto.nsp_sequencia_n    = int(it-nota-fisc.nr-seq-fat)
                          int_ds_nota_saida_relacto.rpp_validade_d     = ?.                            



               END.
               ASSIGN int_ds_nota_saida_item.nsp_lote           = int_ds_nota_saida_relacto.nsp_lote_s    
                      int_ds_nota_saida_item.nsp_datavalidade_d = int_ds_nota_saida_relacto.rpp_validade_d.
               
            end.
            RELEASE int_ds_nota_saida_relacto.
            release int_ds_nota_saida_item.
        end.  /* it-nota-fisc */

        create  int_ds_nota_saida.
        assign  int_ds_nota_saida.ENVIO_STATUS       = IF nota-fiscal.serie = "402"
                                                        OR nota-fiscal.nome-ab-cli <> "DN CD ADM"
                                                        
                                                        
                                                        THEN 8 ELSE 0
                                                         
                                                       
                int_ds_nota_saida.nsa_cnpj_origem_s  = estabelec.cgc
                int_ds_nota_saida.nsa_notafiscal_n   = integer(nota-fiscal.nr-nota-fis)
                int_ds_nota_saida.nsa_serie_s        = nota-fiscal.serie
                int_ds_nota_saida.nsa_cnpj_destino_s = nota-fiscal.cgc
                int_ds_nota_saida.nsa_dataemissao_d  = nota-fiscal.dt-emis-nota
                int_ds_nota_saida.nsa_chaveacesso_s  = &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                                            trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44))
                                                       &else
                                                            trim(substring(nota-fiscal.char-2,3,44))
                                                       &endif
                int_ds_nota_saida.ped_codigo_n       = if nota-fiscal.cod-estabel <> "973" and 
                                                          nota-fiscal.cod-estabel <> "014" and 
                                                          nota-fiscal.cod-estabel <> "247" and 
                                                          nota-fiscal.cod-estabel <> "192" and 
                                                          nota-fiscal.cod-estabel <> "199" and 
                                                          nota-fiscal.cod-estabel <> "193" and 
                                                          p-origem <> "PROCFIT" then 
                                                         (if i-pedido <> 0 then i-pedido else int64(nota-fiscal.nr-pedcli))
                                                       else 0 
                int_ds_nota_saida.ped_procfit        = if nota-fiscal.cod-estabel = "973" or 
                                                          nota-fiscal.cod-estabel = "014" or  
                                                          nota-fiscal.cod-estabel = "247" or  
                                                          nota-fiscal.cod-estabel = "192" or   
                                                          nota-fiscal.cod-estabel = "199" or   
                                                          nota-fiscal.cod-estabel = "193" or   
                                                          p-origem = "PROCFIT" then
                                                         (if i-pedido <> 0 then i-pedido else int64(nota-fiscal.nr-pedcli))
                                                       else 0
                int_ds_nota_saida.id_sequencial      = next-VALUE(seq-int-ds-nota-saida)
                int_ds_nota_saida.ENVIO_DATA_HORA    = datetime(today).

        FIND first natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao  NO-ERROR.
            
        ASSIGN  int_ds_nota_saida.nsa_cfop_n       = integer(replace(natur-oper.cod-cfop,".",""))
                int_ds_nota_saida.tipo_movto          = 1 /* inclusao */
                int_ds_nota_saida.nsa_cnpj_destino_s  = nota-fiscal.cgc
                int_ds_nota_saida.nsa_dataemissao_d   = nota-fiscal.dt-emis-nota
                int_ds_nota_saida.nsa_placaveiculo_s  = substring(replace(nota-fiscal.placa," ",""),1,7)
                int_ds_nota_saida.nsa_estadoveiculo_s = substring(replace(nota-fiscal.uf-placa," ",""),1,2)
                int_ds_nota_saida.nsa_observacao_s    = substring(nota-fiscal.observ-nota,1,4000).

        /*
        for first transporte fields (cgc) no-lock where 
            transporte.nome-abrev = nota-fiscal.nome-transp:
            assign  int_ds_nota_saida.nsa-cnpj-transportadora-s = transporte.cgc.
        end.
        */
        for each int_ds_nota_saida_item no-lock of int_ds_nota_saida:

            assign  int_ds_nota_saida.nsa_valortotalprodutos_n     = int_ds_nota_saida.nsa_valortotalprodutos_n
                                                                   + int_ds_nota_saida_item.nsp_valortotalproduto_n
                    int_ds_nota_saida.nsa_quantidade_n             = int_ds_nota_saida.nsa_quantidade_n 
                                                                   + int_ds_nota_saida_item.nsp_quantidade_n
                    int_ds_nota_saida.nsa_desconto_n               = int_ds_nota_saida.nsa_desconto_n 
                                                                   + int_ds_nota_saida_item.nsp_desconto_n
                    int_ds_nota_saida.nsa_baseicms_n               = int_ds_nota_saida.nsa_baseicms_n
                                                                   + int_ds_nota_saida_item.nsp_baseicms_n
                    int_ds_nota_saida.nsa_valoricms_n              = int_ds_nota_saida.nsa_valoricms_n
                                                                   + int_ds_nota_saida_item.nsp_valoricms_n
                    int_ds_nota_saida.nsa_basediferido_n           = int_ds_nota_saida.nsa_basediferido_n 
                                                                   + int_ds_nota_saida_item.nsp_basediferido_n
                    int_ds_nota_saida.nsa_baseisenta_n             = int_ds_nota_saida.nsa_baseisenta_n
                                                                   + int_ds_nota_saida_item.nsp_baseisenta_n
                    int_ds_nota_saida.nsa_baseipi_n                = int_ds_nota_saida.nsa_baseipi_n
                                                                   + int_ds_nota_saida_item.nsp_baseipi_n
                    int_ds_nota_saida.nsa_valoripi_n               = int_ds_nota_saida.nsa_valoripi_n 
                                                                   + int_ds_nota_saida_item.nsp_valoripi_n
                    int_ds_nota_saida.nsa_basest_n                 = int_ds_nota_saida.nsa_basest_n
                                                                   + int_ds_nota_saida_item.nsp_basest_n
                    int_ds_nota_saida.nsa_icmsst_n                 = int_ds_nota_saida.nsa_icmsst_n
                                                                   + int_ds_nota_saida_item.nsp_icmsst_n.

        end. /* int_ds_nota_saida_item */

        assign  int_ds_nota_saida.dt_geracao   = today
                int_ds_nota_saida.hr_geracao   = string(time,"HH:MM:SS")
                int_ds_nota_saida.situacao     = IF nota-fiscal.serie = "402"     
                                                  OR nota-fiscal.nome-ab-cli <> "DN CD ADM"
                                                  
                                                  THEN 2 ELSE p-sit-oblak-s
               
                int_ds_nota_saida.ENVIO_STATUS = IF nota-fiscal.serie = "402"     
                                                 OR nota-fiscal.nome-ab-cli <> "DN CD ADM"
                                                 
                                                 THEN 8 ELSE p-sit-procfit-s.

    end.  /* not avail int_ds_nota_saida - transaction */
    /* notas de transferencia  - gerar entrada no destino */
    if  (nota-fiscal.nat-operacao begins "5" or
         nota-fiscal.nat-operacao begins "6" or
         nota-fiscal.nat-operacao begins "7") and 
         nota-fiscal.esp-docto = 23 and
         avail int_ds_nota_saida and
         int_ds_nota_saida.nsa_cnpj_destino_s <> int_ds_nota_saida.nsa_cnpj_origem_s then do: /* Balanço os CNPJ são iguais -> tratado em outro ponto */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel <> "973":

            c-cfop = "".
            de-despesas = 0.
            
            //Alteracao 17-02-2025 (alterado de For First para Find First
            for each int_ds_nota_saida_item no-lock of int_ds_nota_saida:
                de-despesas = de-despesas + int_ds_nota_saida_item.nsp_valordespesa_n.
                FIND first int_ds_nota_entrada_produt where 
                    int_ds_nota_entrada_produt.nen_cnpj_origem_s = int_ds_nota_saida.nsa_cnpj_origem_s     and
                    int_ds_nota_entrada_produt.nen_serie_s       = int_ds_nota_saida.nsa_serie_s           and
                    int_ds_nota_entrada_produt.nen_notafiscal_n  = int_ds_nota_saida.nsa_notafiscal_n      and
                    int_ds_nota_entrada_produt.nep_sequencia_n   = int_ds_nota_saida_item.nsp_sequencia_n  and
                    int_ds_nota_entrada_produt.nep_produto_n     = int_ds_nota_saida_item.nsp_produto_n    and
                    int_ds_nota_entrada_produt.nep_lote_s        = int_ds_nota_saida_item.nsp_lote_s
                    NO-LOCK NO-ERROR.
                if not avail int_ds_nota_entrada_produt then do:

                    /*
                    put int_ds_nota_saida.nsa_cnpj_origem_s    " " 
                        int_ds_nota_saida.nsa_serie_s          " " 
                        int_ds_nota_saida.nsa_notafiscal_n     " " 
                        int_ds_nota_saida_item.nsp-sequencia-n " " 
                        int_ds_nota_saida_item.nsp_produto_n   " " 
                        int_ds_nota_saida_item.nsp_lote_s
                        skip.
                     */

                    create  int_ds_nota_entrada_produt.
                    assign  int_ds_nota_entrada_produt.nen_cnpj_origem_s       = int_ds_nota_saida.nsa_cnpj_origem_s   
                            int_ds_nota_entrada_produt.nen_serie_s             = int_ds_nota_saida.nsa_serie_s         
                            int_ds_nota_entrada_produt.nen_notafiscal_n        = int_ds_nota_saida.nsa_notafiscal_n    
                            int_ds_nota_entrada_produt.nep_sequencia_n         = int_ds_nota_saida_item.nsp_sequencia_n
                            int_ds_nota_entrada_produt.nep_produto_n           = int_ds_nota_saida_item.nsp_produto_n  
                            int_ds_nota_entrada_produt.nep_lote_s              = int_ds_nota_saida_item.nsp_lote_s.
                    assign  int_ds_nota_entrada_produt.nep_basecofins_n        = int_ds_nota_saida_item.nsp_basecofins_n
                            int_ds_nota_entrada_produt.nep_basediferido_n      = int_ds_nota_saida_item.nsp_basediferido_n
                            int_ds_nota_entrada_produt.nep_baseicms_n          = int_ds_nota_saida_item.nsp_baseicms_n
                            int_ds_nota_entrada_produt.nep_baseipi_n           = int_ds_nota_saida_item.nsp_baseipi_n
                            int_ds_nota_entrada_produt.nep_baseisenta_n        = int_ds_nota_saida_item.nsp_baseisenta_n
                            int_ds_nota_entrada_produt.nep_basepis_n           = int_ds_nota_saida_item.nsp_basepis_n
                            int_ds_nota_entrada_produt.nep_basest_n            = int_ds_nota_saida_item.nsp_basest_n
                            int_ds_nota_entrada_produt.nep_csta_n              = int_ds_nota_saida_item.nsp_csta_n
                            int_ds_nota_entrada_produt.nep_cstb_icm_n          = int_ds_nota_saida_item.nsp_cstb_n
                            int_ds_nota_entrada_produt.nep_cstb_ipi_n          = 0
                            int_ds_nota_entrada_produt.nep_datavalidade_d      = int_ds_nota_saida_item.nsp_datavalidade_d
                            int_ds_nota_entrada_produt.nep_icmsst_n            = int_ds_nota_saida_item.nsp_icmsst_n
                            int_ds_nota_entrada_produt.nep_percentualcofins_n  = int_ds_nota_saida_item.nsp_percentualcofins_n
                            int_ds_nota_entrada_produt.nep_percentualicms_n    = int_ds_nota_saida_item.nsp_percentualicms_n
                            int_ds_nota_entrada_produt.nep_percentualipi_n     = int_ds_nota_saida_item.nsp_percentualipi_n
                            int_ds_nota_entrada_produt.nep_percentualpis_n     = int_ds_nota_saida_item.nsp_percentualpis_n
                            int_ds_nota_entrada_produt.nep_quantidade_n        = int_ds_nota_saida_item.nsp_quantidade_n
                            int_ds_nota_entrada_produt.nep_redutorbaseicms_n   = int_ds_nota_saida_item.nsp_redutorbaseicms_n
                            int_ds_nota_entrada_produt.nep_valorbruto_n        = int_ds_nota_saida_item.nsp_valorbruto_n
                            int_ds_nota_entrada_produt.nep_valorcofins_n       = int_ds_nota_saida_item.nsp_valorcofins_n
                            int_ds_nota_entrada_produt.nep_valordesconto_n     = int_ds_nota_saida_item.nsp_desconto_n
                            int_ds_nota_entrada_produt.nep_valordespesa_n      = int_ds_nota_saida_item.nsp_valordespesa_n
                            int_ds_nota_entrada_produt.nep_valoricms_n         = int_ds_nota_saida_item.nsp_valoricms_n
                            int_ds_nota_entrada_produt.nep_valoripi_n          = int_ds_nota_saida_item.nsp_valoripi_n
                            int_ds_nota_entrada_produt.nep_valorliquido_n      = int_ds_nota_saida_item.nsp_valorliquido_n
                            int_ds_nota_entrada_produt.nep_valorpis_n          = int_ds_nota_saida_item.nsp_valorpis_n
                            int_ds_nota_entrada_produt.ped_codigo_n            = /*int_ds_nota_saida_item.ped_codigo_n*/ 0.

                    
					
					
					
					find first item  no-lock 
					where item.it-codigo = trim(string(int_ds_nota_saida_item.nsp_produto_n)) no-error.
                       
                    IF NOT AVAIL ITEM THEN NEXT.

                    assign  int_ds_nota_entrada_produt.nep_ncm_n               = if   int_ds_nota_saida_item.nsp_ncm_s <> ""
                                                                                  then int(int_ds_nota_saida_item.nsp_ncm_s)
                                                                                  else int(item.class-fiscal)
                            int_ds_nota_entrada_produt.nep_csta_n              = item.codigo-orig.

                    FIND FIRST natur-oper NO-LOCK
                        WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao NO-ERROR.
                     
                    c-cfop = STRING(int_ds_nota_saida.nsa_cfop_n).
                    assign int_ds_nota_entrada_produt.nen_cfop_n = int(c-cfop).
                    release int_ds_nota_entrada_produt.
                end. /* not avail int_ds_nota_saida-produto */
            end. /* int_ds_nota_saida-produto */
            FIND first int_ds_nota_entrada where 
                int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_nota_saida.nsa_cnpj_origem_s     and
                int_ds_nota_entrada.nen_serie_s       = int_ds_nota_saida.nsa_serie_s           and
                int_ds_nota_entrada.nen_notafiscal_n  = int_ds_nota_saida.nsa_notafiscal_n NO-ERROR.
            if not avail int_ds_nota_entrada then do:
                create  int_ds_nota_entrada.
                assign  int_ds_nota_entrada.dt_geracao          = today
                        int_ds_nota_entrada.hr_geracao          = string(time,"HH:MM:SS")
                        int_ds_nota_entrada.nen_basediferido_n  = int_ds_nota_saida.nsa_basediferido_n
                        int_ds_nota_entrada.nen_baseicms_n      = int_ds_nota_saida.nsa_baseicms_n
                        int_ds_nota_entrada.nen_baseipi_n       = int_ds_nota_saida.nsa_baseipi_n
                        int_ds_nota_entrada.nen_baseisenta_n    = int_ds_nota_saida.nsa_baseisenta_n
                        int_ds_nota_entrada.nen_basest_n        = int_ds_nota_saida.nsa_basest_n
                        int_ds_nota_entrada.nen_cfop_n          = int_ds_nota_saida.nsa_cfop_n
                        int_ds_nota_entrada.nen_chaveacesso_s   = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                                       trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44)) 
                                                                  &else                                         
                                                                       trim(substring(nota-fiscal.char-2,3,44)) 
                                                                  &endif                                        
                        int_ds_nota_entrada.nen_cnpj_destino_s  = int_ds_nota_saida.nsa_cnpj_destino_s
                        int_ds_nota_entrada.nen_cnpj_origem_s   = int_ds_nota_saida.nsa_cnpj_origem_s
                        int_ds_nota_entrada.nen_conferida_n     = 0
                        int_ds_nota_entrada.nen_dataemissao_d   = int_ds_nota_saida.nsa_dataemissao_d
                        int_ds_nota_entrada.nen_desconto_n      = int_ds_nota_saida.nsa_desconto_n
                        int_ds_nota_entrada.nen_despesas_n      = de-despesas
                        int_ds_nota_entrada.nen_frete_n         = nota-fiscal.vl-frete
                        int_ds_nota_entrada.nen_icmsst_n        = int_ds_nota_saida.nsa_icmsst_n
                        int_ds_nota_entrada.nen_modalidade_frete_n   = nota-fiscal.ind-tp-frete
                        int_ds_nota_entrada.nen_notafiscal_n         = int_ds_nota_saida.nsa_notafiscal_n
                        int_ds_nota_entrada.nen_observacao_s         = int_ds_nota_saida.nsa_observacao_s
                        int_ds_nota_entrada.nen_quantidade_n         = int_ds_nota_saida.nsa_quantidade_n
                        int_ds_nota_entrada.nen_seguro_n             = 0
                        int_ds_nota_entrada.nen_serie_s              = int_ds_nota_saida.nsa_serie_s
                        int_ds_nota_entrada.nen_valoricms_n          = int_ds_nota_saida.nsa_valoricms_n
                        int_ds_nota_entrada.nen_valoripi_n           = int_ds_nota_saida.nsa_valoripi_n
                        int_ds_nota_entrada.nen_valortotalprodutos_n = int_ds_nota_saida.nsa_valortotalprodutos_n
                        int_ds_nota_entrada.situacao                 = p-sit-oblak-e
                        int_ds_nota_entrada.tipo_movto               = 1
                        int_ds_nota_entrada.tipo_nota                = 3
                        int_ds_nota_entrada.ped_codigo_n             = int_ds_nota_saida.ped_codigo_n
                        int_ds_nota_entrada.ped_procfit              = int_ds_nota_saida.ped_procfit
                        int_ds_nota_entrada.id_sequencial            = next-VALUE(seq-int-ds-nota-entrada) /* Preparação para integração com Procfit */
                        int_ds_nota_entrada.ENVIO_STATUS             = p-sit-procfit-e
                        int_ds_nota_entrada.ENVIO_DATA_HORA          = datetime(today).

                for first ndd_entryintegration EXCLUSIVE-LOCK 
					where NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int_ds_nota_entrada.nen_notafiscal_n  
					  and NDD_ENTRYINTEGRATION.SERIE          = int(int_ds_nota_entrada.nen_serie_s)  
					  and NDD_ENTRYINTEGRATION.CNPJEMIT       = int(int_ds_nota_entrada.nen_cnpj_origem_s) 
					  and NDD_ENTRYINTEGRATION.CNPJDEST       = int(int_ds_nota_entrada.nen_cnpj_origem_s):
                    assign status_ = 1.
                end.
				RELEASE ndd_entryintegration.
				
                if tt-param.arquivo <> "" then DO:
                    display
                        p-origem @ c-disp-sistema column-label "Origem"
                        estabelec.cod-estabel
                        b-estabelec.cod-estabel                           
                        int_ds_nota_entrada.nen_serie_s
                        int_ds_nota_entrada.nen_notafiscal_n
                        int_ds_nota_entrada.nen_dataemissao_d
                        nota-fiscal.dt-cancela
                        with frame f-rel-entrada width 300 stream-io.
                    down with frame f-rel-entrada.
                END.

                release int_ds_nota_entrada.
            end. /* avail int_ds_nota_entrada */
         end. /* avail b-estabelec */

         /* notas de transferencia Lj->CD - Retirado do INT500 */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel = "973"
             query-tuning(no-lookahead):
             if substring(nota-fiscal.nat-operacao,1,4) <> "5605" /* Transferencia de saldo de ICMS */ and
                not nota-fiscal.nat-operacao begins "5929" /* outras */ then 
               run pi-entrada-cd (1,1).
         end.
         
         /* CAJAMAR- Retirado do INT500 */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel = "977"  //validar para o CD cajamar
             query-tuning(no-lookahead):
             if substring(nota-fiscal.nat-operacao,1,4) <> "5605" /* Transferencia de saldo de ICMS */ and
                not nota-fiscal.nat-operacao begins "5929" /* outras */ then 
               run pi-entrada-cd (1,1).
         end.
         
         
         
         
    end.
    // Envio da Nota para o Datahub
  
    IF int_ds_nota_saida.situacao = 2 AND int_ds_nota_saida.envio_status = 8 THEN
    DO:

    IF nota-fiscal.serie = "402" THEN DO:

        RUN intprg/int301rp.p ( INPUT "Saida"  ,
                                INPUT "Saida-Ecommerce" ,
                                INPUT ROWID(nota-fiscal) ).        
    END.

    IF natur-oper.especie-doc = "NFS" AND natur-oper.transf = NO AND natur-oper.tipo = 2 AND natur-oper.cod-mensagem = 2 THEN
    DO:

        ASSIGN tipo-nota = "Saida-Transferencia".

    END.

    IF natur-oper.especie-doc = "NFT" AND natur-oper.transf = YES AND natur-oper.tipo = 2 THEN
    DO:

        ASSIGN tipo-nota = "Saida-Transferencia".

    END.

    ELSE IF natur-oper.especie-doc = "NFD" AND natur-oper.transf = NO AND natur-oper.tipo = 2 THEN
    DO:

        ASSIGN tipo-nota = "Saida-DevolucaoCompra".

    END.

    ELSE IF natur-oper.especie-doc = "NFD" AND natur-oper.transf = NO AND natur-oper.tipo = 1  THEN
    DO:

        FIND FIRST it-nota-fisc OF nota-fiscal NO-LOCK NO-ERROR.

        IF it-nota-fisc.nr-docum <> "" THEN
        DO:

            ASSIGN tipo-nota = "Entrada-DevolucaoVenda".

        END.

    END.  
    
    IF nota-fiscal.cod-estabel = "973" OR nota-fiscal.cod-estabel = "977" AND (nota-fiscal.nome-ab-cli <> "DN CD ADM" OR nota-fiscal.nome-ab-cli <> "NISSEI 977") THEN DO:
                                         
        RUN intprg/int301rp.r (INPUT "Saida" ,
                               INPUT tipo-nota ,
                               INPUT ROWID(nota-fiscal)). // Envio de notas para datahub (Datahub/PROCFIT)

    END.
                                                   
    ASSIGN int_ds_nota_saida.envio_status = 2.

    END.
end procedure.

procedure pi-entradas-balanco:
    define input param p-origem as char.
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.

    FIND first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen_cnpj_origem_s = ems2mult.estabelec.cgc and
        int_ds_nota_entrada.nen_serie_s = nota-fiscal.serie AND
        int_ds_nota_entrada.nen_notafiscal_n = int(nota-fiscal.nr-nota-fis) NO-LOCK NO-ERROR.

    /* inclusÆo da nota */
    if not avail int_ds_nota_entrada then do :

        if tt-param.arquivo <> "" then DO:
            display
                p-origem @ c-disp-sistema column-label "Origem"
                nota-fiscal.cod-estabel
                nota-fiscal.serie
                nota-fiscal.nr-nota-fis                          
                nota-fiscal.dt-emis-nota
                nota-fiscal.dt-cancela
                with frame f-rel.
            down with frame f-rel.
        END.

        for each tt-lote. delete tt-lote. end.
        for each int_ds_pedido_retorno no-lock where
            int_ds_pedido_retorno.ped_codigo_n = INT64(nota-fiscal.nr-pedcli) and
            int_ds_pedido_retorno.rpp_lote <> ? and int_ds_pedido_retorno.rpp_lote <> ""
            query-tuning(no-lookahead):
            create tt-lote.
            buffer-copy int_ds_pedido_retorno to tt-lote.

            if ems2mult.estabelec.cgc = nota-fiscal.cgc then do: /* Balanço */
               assign de-quantidade = int_ds_pedido_retorno.rpp_quantidade_n - int_ds_pedido_retorno.rpp_qtd_inventario_n.
               if de-quantidade < 0 then do:
                    assign  tt-lote.rpp_quantidade = de-quantidade * -1
                            tt-lote.tipo = "S".
               end.
               else do:
                    assign  tt-lote.rpp_quantidade = de-quantidade
                            tt-lote.tipo = "E".
               end.
            end.
        end.

        for each it-nota-fisc no-lock of nota-fiscal
            query-tuning(no-lookahead):

            for first int_ds_nota_entrada_produt of int_ds_nota_entrada where
                int_ds_nota_entrada_produt.nep_sequencia_n = it-nota-fisc.nr-seq-fat and
                int_ds_nota_entrada_produt.nep_produto_n   = int(it-nota-fisc.it-codigo)
                query-tuning(no-lookahead): end.

            if not avail int_ds_nota_entrada_produt then do:

                find first item  no-lock
				where item.it-codigo = it-nota-fisc.it-codigo no-error.
         
                IF NOT AVAIL ITEM THEN NEXT.

                create  int_ds_nota_entrada_produt.
                assign  int_ds_nota_entrada_produt.nen_cnpj_origem_s       = estabelec.cgc      
                        int_ds_nota_entrada_produt.nen_notafiscal_n        = integer(nota-fiscal.nr-nota-fis)                      
                        int_ds_nota_entrada_produt.nen_serie_s             = nota-fiscal.serie                                     
                        int_ds_nota_entrada_produt.nep_sequencia_n         = it-nota-fisc.nr-seq-fat
                        int_ds_nota_entrada_produt.nep_produto_n           = int(it-nota-fisc.it-codigo)
                        int_ds_nota_entrada_produt.nep_quantidade_n        = it-nota-fisc.qt-faturada[1]
                        int_ds_nota_entrada_produt.nep_valorbruto_n        = it-nota-fisc.vl-merc-ori
                        int_ds_nota_entrada_produt.nep_valordesconto_n     = it-nota-fisc.vl-desconto
                        int_ds_nota_entrada_produt.nep_valorliquido_n      = it-nota-fisc.vl-merc-liq
                        int_ds_nota_entrada_produt.nep_baseicms_n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int_ds_nota_entrada_produt.nep_valoricms_n         = it-nota-fisc.vl-icms-it
                        int_ds_nota_entrada_produt.nep_basediferido_n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int_ds_nota_entrada_produt.nep_baseisenta_n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                         then it-nota-fisc.vl-icmsnt-it else 0.

                assign  int_ds_nota_entrada_produt.nep_valoripi_n          = it-nota-fisc.vl-ipi-it
                        int_ds_nota_entrada_produt.nep_icmsst_n            = it-nota-fisc.vl-icmsub-it
                        int_ds_nota_entrada_produt.nep_basest_n            = it-nota-fisc.vl-bsubs-it
                        /*int_ds_nota_entrada_produt.nep_valortotalproduto_n = it-nota-fisc.vl-tot-item*/.

                assign  int_ds_nota_entrada_produt.nep_percentualicms_n    = it-nota-fisc.aliquota-icm
                        int_ds_nota_entrada_produt.nep_percentualipi_n     = it-nota-fisc.aliquota-ipi
                        int_ds_nota_entrada_produt.nep_redutorbaseicms_n   = it-nota-fisc.perc-red-icm.
                assign  int_ds_nota_entrada_produt.nep_valordespesa_n      = it-nota-fisc.vl-despes-it
                        int_ds_nota_entrada_produt.nep_valorpis_n          = it-nota-fisc.vl-pis
                        int_ds_nota_entrada_produt.nep_valorcofins_n       = it-nota-fisc.vl-finsocial
                        /*int_ds_nota_entrada_produt.nep_peso_n              = it-nota-fisc.peso-bruto*/
                        int_ds_nota_entrada_produt.nep_baseipi_n           = it-nota-fisc.vl-bipi-it.
                assign  int_ds_nota_entrada_produt.nep_ncm_n               = if   it-nota-fisc.class-fiscal <> ""
                                                                              then int(it-nota-fisc.class-fiscal)
                                                                              else int(item.class-fiscal)
                        int_ds_nota_entrada_produt.nep_csta_n              = item.codigo-orig
                        /*int_ds_nota_entrada_produt.nep_valortributos_n     = int_ds_nota_entrada_produt.nep_valoricms_n 
                                                                       + int_ds_nota_entrada_produt.nep_valoripi_n
                                                                       + int_ds_nota_entrada_produt.nep_icmsst_n
                                                                       + int_ds_nota_entrada_produt.nep_valorpis_n
                                                                       + int_ds_nota_entrada_produt.nep_valorcofins_n*/.
                run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                                   output int_ds_nota_entrada_produt.nep_cstb_icm_n,
                                   output l-sub).
                FIND first natur-oper  NO-LOCK
                    WHERE natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-ERROR.
                  
                
                assign  int_ds_nota_entrada_produt.nen_cfop_n = int(replace(natur-oper.cod-cfop,".","")).
     


                assign  i-ped-nota-entrada-item                             = if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".",""))   
                                                                              else if nota-fiscal.nr-pedcli <> "" then int64(replace(nota-fiscal.nr-pedcli,".",""))
                                                                              else integer(replace(nota-fiscal.docto-orig,".",""))                                   
                        int_ds_nota_entrada_produt.ped_codigo_n            = /*if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                              else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                              else integer(replace(nota-fiscal.docto-orig,".",""))*/ 0
                        int_ds_nota_entrada_produt.nep_basepis_n           = it-nota-fisc.vl-tot-item
                                                                        - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                           or  substr(item.char-1,50,5) = "Sim"
                                                                           then   it-nota-fisc.vl-pis
                                                                                + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                        - (if natur-oper.tp-oper-terc = 4
                                                                           then it-nota-fisc.vl-icmsubit-e[3]
                                                                           else it-nota-fisc.vl-icmsub-it)
                        int_ds_nota_entrada_produt.nep_basecofins_n        = it-nota-fisc.vl-tot-item
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
                     assign int_ds_nota_entrada_produt.nep_basepis_n = int_ds_nota_entrada_produt.nep_basepis_n
                                                                   - it-nota-fisc.vl-ipi-it
                                                                   - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                      then it-nota-fisc.vl-ipiit-e[3]
                                                                      else 0).
                     assign int_ds_nota_entrada_produt.nep_basecofins_n = int_ds_nota_entrada_produt.nep_basecofins_n
                                                                    - it-nota-fisc.vl-ipi-it
                                                                    - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                       then it-nota-fisc.vl-ipiit-e[3]
                                                                       else 0).
                end.
                /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
                if  it-nota-fisc.cd-trib-ipi = 3 
                and substring(natur-oper.char-2,16,1) = "1":U
                and not natur-oper.log-ipi-outras-contrib-social then do:
                    assign int_ds_nota_entrada_produt.nep_basepis_n = int_ds_nota_entrada_produt.nep_basepis_n
                                                               - it-nota-fisc.vl-ipi-it
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                    assign int_ds_nota_entrada_produt.nep_basecofins_n = int_ds_nota_entrada_produt.nep_basecofins_n
                                                               - it-nota-fisc.vl-ipi-it
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                end.
                assign 
                        int_ds_nota_entrada_produt.nep_percentualpis_n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                else 0)
                                                                       / 10000.
                        int_ds_nota_entrada_produt.nep_percentualcofins_n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                else 0)
                                                                       / 10000.
                for first fat-ser-lote no-lock of it-nota-fisc
                    query-tuning(no-lookahead):
                    assign  int_ds_nota_entrada_produt.nep_lote_s  = substring(fat-ser-lote.nr-serlote,1,10)
                            int_ds_nota_entrada_produt.nep_datavalidade_d = fat-ser-lote.dt-vali-lote.
                end.

                if /*int_ds_nota_entrada_produt.ped_codigo_n*/ i-ped-nota-entrada-item <> 0 then 
                   assign i-pedido = /*int_ds_nota_entrada_produt.ped_codigo_n*/ i-ped-nota-entrada-item.

                for first cst_ped_item no-lock where
                    cst_ped_item.nome_abrev     = nota-fiscal.nome-ab-cli and
                    cst_ped_item.nr_pedcli      = it-nota-fisc.nr-pedcli  and
                    cst_ped_item.nr_sequencia   = it-nota-fisc.nr-seq-ped and
                    cst_ped_item.it_codigo      = it-nota-fisc.it-codigo  and
                    cst_ped_item.cod_refer      = it-nota-fisc.cod-refer
                    query-tuning(no-lookahead):
                    assign int_ds_nota_entrada_produt.nep_lote_s = cst_ped_item.numero_lote.
                end.
                if not avail cst_ped_item then do:
                    for first tt-lote where 
                        tt-lote.ppr_produto_n  = int_ds_nota_entrada_produt.nep_produto_n  and
                        tt-lote.rpp_quantidade = int_ds_nota_entrada_produt.nep_quantidade and
                        tt-lote.rpp_lote      <> ?                                          and
                        tt-lote.rpp_lote      <> ""                                         and
                        tt-lote.tipo           = "E"
                        query-tuning(no-lookahead):
                        assign int_ds_nota_entrada_produt.nep_lote = tt-lote.rpp_lote
                               int_ds_nota_entrada_produt.nep_datavalidade_d = tt-lote.rpp_validade_d.
                        delete tt-lote.
                    end.
                end.
            end.
            release int_ds_nota_entrada_produt.
        end.  /* it-nota-fisc */

        create  int_ds_nota_entrada.
        assign  int_ds_nota_entrada.ENVIO_STATUS        = 0
                int_ds_nota_entrada.nen_cnpj_origem_s   = estabelec.cgc
                int_ds_nota_entrada.nen_notafiscal_n    = integer(nota-fiscal.nr-nota-fis)
                int_ds_nota_entrada.nen_serie_s         = nota-fiscal.serie
                int_ds_nota_entrada.nen_cnpj_destino_s  = nota-fiscal.cgc
                int_ds_nota_entrada.nen_dataemissao_d   = nota-fiscal.dt-emis-nota
                int_ds_nota_entrada.ped_codigo_n       = if nota-fiscal.cod-estabel <> "973" and  
                                                            nota-fiscal.cod-estabel <> "014" and  
                                                            nota-fiscal.cod-estabel <> "247" and  
                                                            nota-fiscal.cod-estabel <> "192" and  
                                                            nota-fiscal.cod-estabel <> "199" and  
                                                            nota-fiscal.cod-estabel <> "193" and  
                                                            p-origem <> "PROCFIT" then 
                                                           (if i-pedido <> 0 then i-pedido else int64(nota-fiscal.nr-pedcli))
                                                         else 0 
                int_ds_nota_entrada.ped_procfit        = if nota-fiscal.cod-estabel = "973" or  
                                                            nota-fiscal.cod-estabel = "014" or  
                                                            nota-fiscal.cod-estabel = "247" or  
                                                            nota-fiscal.cod-estabel = "192" or  
                                                            nota-fiscal.cod-estabel = "199" or  
                                                            nota-fiscal.cod-estabel = "193" or  
                                                            p-origem = "PROCFIT" then
                                                           (if i-pedido <> 0 then i-pedido else int64(nota-fiscal.nr-pedcli))
                                                         else 0
                int_ds_nota_entrada.id_sequencial       = next-VALUE(seq-int-ds-nota-entrada) /* Preparação para integração com Procfit */
                int_ds_nota_entrada.ENVIO_DATA_HORA     = datetime(today).
   
        for first natur-oper
            WHERE
            natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead):
            assign int_ds_nota_entrada.nen_cfop_n       = integer(replace(natur-oper.cod-cfop,".","")).
        end.
        assign  int_ds_nota_entrada.tipo_movto          = 1 /* inclusao */
                int_ds_nota_entrada.tipo_nota           = 2
                int_ds_nota_entrada.nen_cnpj_destino_s  = nota-fiscal.cgc
                int_ds_nota_entrada.nen_dataemissao_d   = nota-fiscal.dt-emis-nota
                int_ds_nota_entrada.nen_observacao_s    = substring(nota-fiscal.observ-nota,1,4000).

        /*
        for first transporte fields (cgc) no-lock where 
            transporte.nome-abrev = nota-fiscal.nome-transp:
            assign  int_ds_nota_entrada.nen_cnpj_transportadora_s = transporte.cgc.
        end.
        */
        for each int_ds_nota_entrada_produt no-lock of int_ds_nota_entrada
            query-tuning(no-lookahead):

            assign  int_ds_nota_entrada.nen_valortotalprodutos_n     = int_ds_nota_entrada.nen_valortotalprodutos_n
                                                                   + int_ds_nota_entrada_produt.nep_valorbruto_n
                    int_ds_nota_entrada.nen_quantidade_n             = int_ds_nota_entrada.nen_quantidade_n 
                                                                   + int_ds_nota_entrada_produt.nep_quantidade_n
                    int_ds_nota_entrada.nen_desconto_n               = int_ds_nota_entrada.nen_desconto_n 
                                                                   + int_ds_nota_entrada_produt.nep_valordesconto_n
                    int_ds_nota_entrada.nen_baseicms_n               = int_ds_nota_entrada.nen_baseicms_n
                                                                   + int_ds_nota_entrada_produt.nep_baseicms_n
                    int_ds_nota_entrada.nen_valoricms_n              = int_ds_nota_entrada.nen_valoricms_n
                                                                   + int_ds_nota_entrada_produt.nep_valoricms_n
                    int_ds_nota_entrada.nen_basediferido_n           = int_ds_nota_entrada.nen_basediferido_n 
                                                                   + int_ds_nota_entrada_produt.nep_basediferido_n
                    int_ds_nota_entrada.nen_baseisenta_n             = int_ds_nota_entrada.nen_baseisenta_n
                                                                   + int_ds_nota_entrada_produt.nep_baseisenta_n
                    int_ds_nota_entrada.nen_baseipi_n                = int_ds_nota_entrada.nen_baseipi_n
                                                                   + int_ds_nota_entrada_produt.nep_baseipi_n
                    int_ds_nota_entrada.nen_valoripi_n               = int_ds_nota_entrada.nen_valoripi_n 
                                                                   + int_ds_nota_entrada_produt.nep_valoripi_n
                    int_ds_nota_entrada.nen_basest_n                 = int_ds_nota_entrada.nen_basest_n
                                                                   + int_ds_nota_entrada_produt.nep_basest_n
                    int_ds_nota_entrada.nen_icmsst_n                 = int_ds_nota_entrada.nen_icmsst_n
                                                                   + int_ds_nota_entrada_produt.nep_icmsst_n.

        end. /* int_ds_nota_entrada_produto */

        assign  int_ds_nota_entrada.dt_geracao   = today
                int_ds_nota_entrada.hr_geracao   = string(time,"HH:MM:SS")
                int_ds_nota_entrada.situacao     = p-sit-oblak
                int_ds_nota_entrada.ENVIO_STATUS = p-sit-procfit.

        /* KML - MArcar notas de balanço com integradas e conferidas no int014 */
        ASSIGN int_ds_nota_entrada.situacao         = 2  /*Integrado */
               int_ds_nota_entrada.nen_conferida_n  = 1. /*Conferida */
        IF int_ds_nota_entrada.nen_datamovimentacao_d = ? THEN DO:
            ASSIGN int_ds_nota_entrada.nen_datamovimentacao_d = nota-fiscal.dt-emis-nota.
        END.

        /* 06/06/2017 - evitar criacao docto-wms p/ notas de loja - avb */
        if nota-fiscal.cod-estabel = "973" then
        /* 06/06/2017 - evitar criacao docto-wms p/ notas de loja - avb */
        for first ems2mult.emitente no-lock where 
            emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s
            query-tuning(no-lookahead):
            for first int_ds_docto_wms where
                int_ds_docto_wms.doc_numero_n   = string(int_ds_nota_entrada.nen_notafiscal_n) and
                int_ds_docto_wms.doc_serie_s    = int_ds_nota_entrada.nen_serie_s      and
                int_ds_docto_wms.doc_origem_n   = emitente.cod-emitente
                query-tuning(no-lookahead):               end.
            if not avail int_ds_docto_wms then do:
                create int_ds_docto_wms.
                assign int_ds_docto_wms.doc_numero_n    = string(int_ds_nota_entrada.nen_notafiscal_n)
                       int_ds_docto_wms.doc_serie_s     = int_ds_nota_entrada.nen_serie_s
                       int_ds_docto_wms.doc_origem_n    = emitente.cod-emitente
                       int_ds_docto_wms.situacao        = 10 /* Inclusão */
                       int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                       int_ds_docto_wms.tipo_fornecedor = if emitente.natureza = 1 then "F" else "J"
                       int_ds_docto_wms.tipo_nota       = if nota-fiscal.esp-docto = 23 then 3 else if nota-fiscal.esp-docto = 20 then 2 else 1
                       int_ds_docto_wms.id_sequencial   = next-VALUE(seq-int-ds-docto-wms) /* Preparação para integração com Procfit */
                       int_ds_docto_wms.ENVIO_STATUS    = p-sit-procfit
                       int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today).
            end.
        end.

		for first ndd_entryintegration EXCLUSIVE-LOCK 
			where NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int_ds_nota_entrada.nen_notafiscal_n  
			  and NDD_ENTRYINTEGRATION.SERIE          = int(int_ds_nota_entrada.nen_serie_s)  
			  and NDD_ENTRYINTEGRATION.CNPJEMIT       = int(int_ds_nota_entrada.nen_cnpj_origem_s) 
			  and NDD_ENTRYINTEGRATION.CNPJDEST       = int(int_ds_nota_entrada.nen_cnpj_origem_s):
			assign status_ = 1.
		end.
		RELEASE ndd_entryintegration.
    end.  /* not avail int_ds_nota_entrada - transaction */

end procedure.


procedure pi-entrada-cd:
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.

    define buffer bemitente for ems2mult.emitente.

    assign de-tot-bicms = 0
           de-tot-icms  = 0
           de-tot-bsubs = 0
           de-tot-icmst = 0.

    for first ems2mult.estabelec no-lock where estabelec.cod-estabel = nota-fiscal.cod-estabel
        query-tuning(no-lookahead): end.

    for first int_ds_docto_xml NO-LOCK where 
              int_ds_docto_xml.CNPJ         = estabelec.cgc             and
              /*int_ds_docto_xml.CNPJ_dest    = emitente.cgc            and
              int_ds_docto_xml.ep_codigo    = int(estabelec.ep-codigo)  and*/
              int_ds_docto_xml.serie        = nota-fiscal.serie         and
              int_ds_docto_xml.nNF          = nota-fiscal.nr-nota-fis:  end.
    if avail int_ds_docto_xml then return.

    /* destino */
    for first ems2mult.emitente no-lock where emitente.cod-emitente = nota-fiscal.cod-emitente
        query-tuning(no-lookahead): end.

    /* origem */
    for first bemitente no-lock where bemitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead): end.

    if not avail natur-oper then 
        for first natur-oper no-lock 
        WHERE
        natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead). end.

    /*
    display 
        nota-fiscal.cod-estabel
        nota-fiscal.serie
        nota-fiscal.nr-nota-fis
        nota-fiscal.dt-emis-nota
        nota-fiscal.dt-cancela
        AVAIL int_ds_nota_saida
        with frame f-rel.
    down with frame f-rel.
    */

    create  int_ds_docto_xml.
    assign  int_ds_docto_xml.envio_status = 0
            int_ds_docto_xml.CNPJ         = estabelec.cgc
            int_ds_docto_xml.CNPJ_dest    = emitente.cgc 
            int_ds_docto_xml.ep_codigo    = int(estabelec.ep-codigo)
            int_ds_docto_xml.serie        = nota-fiscal.serie
            int_ds_docto_xml.nNF          = nota-fiscal.nr-nota-fis
            int_ds_docto_xml.cod_emitente = bemitente.cod-emitente
            int_ds_docto_xml.dEmi         = nota-fiscal.dt-emis-nota
            int_ds_docto_xml.VNF          = nota-fiscal.vl-tot-nota             /* Valor total da nota fiscal */
            int_ds_docto_xml.observacao   = if trim(nota-fiscal.observ-nota) <> ? 
                                            then trim(nota-fiscal.observ-nota) else ""
            int_ds_docto_xml.valor_frete  = nota-fiscal.vl-frete                /* Frete total da nota */
            int_ds_docto_xml.valor_seguro = nota-fiscal.vl-seguro               /* Seguro total da nota  */
            int_ds_docto_xml.valor_outras = nota-fiscal.val-desp-outros         /* Despesas total da nota */
            int_ds_docto_xml.tot_desconto = nota-fiscal.vl-desconto   /*  Desconto total da nota fiscal  */          
            int_ds_docto_xml.valor_mercad = nota-fiscal.vl-mercad
            int_ds_docto_xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
            int_ds_docto_xml.valor_icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
            int_ds_docto_xml.vbc_cst      = de-tot-bsubs              /*  Base ICMS ST */                   
            int_ds_docto_xml.valor_st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */ 
            int_ds_docto_xml.modFrete     = nota-fiscal.ind-tp-frete  /*  Modalidade do frete (0-FOB 1-Cif) */
            int_ds_docto_xml.dt_trans     = nota-fiscal.dt-emis-nota
            int_ds_docto_xml.volume       = nota-fiscal.nr-volumes
            int_ds_docto_xml.cod_usuario  = nota-fiscal.user-calc
            int_ds_docto_xml.despesa_nota = nota-fiscal.val-desp-outros
            int_ds_docto_xml.estab_de_or  = nota-fiscal.cod-estabel
            int_ds_docto_xml.tipo_docto   = 1
            int_ds_docto_xml.tipo_estab   = 1
            int_ds_docto_xml.situacao     = p-sit-oblak
            int_ds_docto_xml.tipo_nota    = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 1
            int_ds_docto_xml.xNome        = emitente.nome-emit
            int_ds_docto_xml.chnfe        = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                 nota-fiscal.cod-chave-aces-nf-eletro
                                            &else                                         
                                                 trim(substring(nota-fiscal.char-2,3,44)) 
                                            &endif                                        
            int_ds_docto_xml.chnft        = &if "{&bf_dis_versao_ems}" >= "2.07" &then     
                                                 nota-fiscal.cod-chave-aces-nf-eletro      
                                            &else                                          
                                                 trim(substring(nota-fiscal.char-2,3,44))  
                                            &endif                                         
            int_ds_docto_xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
            int_ds_docto_xml.num_pedido   = int64(nota-fiscal.nr-pedcli)
            int_ds_docto_xml.valor_mercad = 0.

    for each ems2mult.estabelec no-lock where estabelec.cgc = trim(int_ds_docto_xml.CNPJ_dest),
        each cst_estabelec no-lock WHERE
             cst_estabelec.cod_estabel = estabelec.cod-estabel AND
             cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota 
        query-tuning(no-lookahead):
        assign int_ds_docto_xml.cod_estab = estabelec.cod-estabel.
        leave.
    end.

    for each it-nota-fisc of nota-fiscal no-lock query-tuning(no-lookahead):

        if VALID-HANDLE(h-acomp) then
            RUN pi-acompanhar IN h-acomp(INPUT "Nota: " + string(nota-fiscal.nr-nota-fis)).

        FIND first int_ds_nota_saida_item of int_ds_nota_saida NO-LOCK where
                  int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat     and
                  int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo) NO-ERROR.
             
       
        FIND first int_dp_nota_saida_item NO-LOCK where
                  int_dp_nota_saida_item.nsa_cnpj_origem_s       = int_ds_docto_xml.CNPJ          and
                  int_dp_nota_saida_item.nsa_serie_s             = int_ds_docto_xml.serie         and
                  int64(int_dp_nota_saida_item.nsa_notafiscal_n) = INT64(int_ds_docto_xml.nnf)    AND
                  int_dp_nota_saida_item.nsi_sequencia_n         = (it-nota-fisc.nr-seq-fat / 10) and
                  int_dp_nota_saida_item.nsi_produto_n           = int64(IT-NOTA-FISC.it-codigo) NO-ERROR.
          
        

        if not avail int_ds_nota_saida_item and
           not avail int_dp_nota_saida_item then next.

        find first ITEM no-lock 
		where item.it-codigo = it-nota-fisc.it-codigo no-error.
           

        IF NOT AVAIL ITEM THEN NEXT.

        assign  de-tot-bicms   = de-tot-bicms   + it-nota-fisc.vl-bicms-it
                de-tot-icms    = de-tot-icms    + it-nota-fisc.vl-icms-it
                de-tot-bsubs   = de-tot-bsubs   + it-nota-fisc.vl-bsubs-it
                de-tot-icmst   = de-tot-icmst   + it-nota-fisc.vl-icmsub-it.
        
        FIND first natur-oper NO-LOCK        
            WHERE  natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-ERROR.
   
        
        FIND first int_ds_it_docto_xml where
            int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
            int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
            int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
            int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie     and
            int_ds_it_docto_xml.sequencia  = it-nota-fisc.nr-seq-fat    and
            int_ds_it_docto_xml.it_codigo  = it-nota-fisc.it-codigo NO-LOCK NO-ERROR.

        if not avail int_ds_it_docto_xml then do:
            create int_ds_it_docto_xml.
            assign int_ds_it_docto_xml.arquivo      = int_ds_docto_xml.arquivo
                   int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota 
                   int_ds_it_docto_xml.CNPJ         = int_ds_docto_xml.CNPJ
                   int_ds_it_docto_xml.cod_emitente = bemitente.cod-emitente
                   int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF
                   int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie
                   int_ds_it_docto_xml.sequencia    = it-nota-fisc.nr-seq-fat 
                   int_ds_it_docto_xml.item_do_forn = it-nota-fisc.it-codigo
                   int_ds_it_docto_xml.it_codigo    = it-nota-fisc.it-codigo
                   int_ds_it_docto_xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
                   int_ds_it_docto_xml.qCom         = it-nota-fisc.qt-faturada[1]
                   int_ds_it_docto_xml.qCom_Forn    = it-nota-fisc.qt-faturada[1]
                   int_ds_it_docto_xml.vProd        = it-nota-fisc.vl-tot-item   
                   int_ds_it_docto_xml.vuncom       = it-nota-fisc.vl-preuni    
                   int_ds_it_docto_xml.vtottrib     = it-nota-fisc.vl-merc-liq                       
                   int_ds_it_docto_xml.vbc_icms     = it-nota-fisc.vl-bicms-it                       
                   int_ds_it_docto_xml.vDesc        = it-nota-fisc.vl-desconto                       
                   int_ds_it_docto_xml.vicms        = it-nota-fisc.vl-icms-it                        
                   int_ds_it_docto_xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                        
                   int_ds_it_docto_xml.vipi         = it-nota-fisc.vl-ipi-it                         
                   int_ds_it_docto_xml.vicmsst      = it-nota-fisc.vl-icmsub-it                      
                   int_ds_it_docto_xml.vbcst        = it-nota-fisc.vl-bsubs-it                       
                   int_ds_it_docto_xml.picmsst      = it-nota-fisc.aliquota-icm                      
                   int_ds_it_docto_xml.pipi         = it-nota-fisc.aliquota-ipi
                   int_ds_it_docto_xml.ppis         = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                  else 0)
                                                                         / 10000
                   int_ds_it_docto_xml.pcofins      = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                  else 0)
                                                                         / 10000
                   int_ds_it_docto_xml.vbc_pis      = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                               else 0)
                                                                          - (if natur-oper.tp-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int_ds_it_docto_xml.vpis         = it-nota-fisc.vl-pis
                   int_ds_it_docto_xml.vbc_cofins   = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                          - (if natur-oper.tP-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int_ds_it_docto_xml.vcofins      = it-nota-fisc.vl-finsocial
                   int_ds_it_docto_xml.num_pedido   = int64(nota-fiscal.nr-pedcli)
                   int_ds_it_docto_xml.orig_icms    = item.codigo-orig
                   int_ds_it_docto_xml.vbcst        = it-nota-fisc.vl-bsubs-it
                   int_ds_it_docto_xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                   
                   int_ds_it_docto_xml.vbcstret     = 0
                   int_ds_it_docto_xml.item_do_forn = it-nota-fisc.it-codigo                  
                   int_ds_it_docto_xml.vOutro       = it-nota-fisc.vl-despes-it.

            if avail int_dp_nota_saida_item then do:
                  assign  int_ds_it_docto_xml.lote         = if int_dp_nota_saida_item.nsi_lote_s <> ? 
                                                             then int_dp_nota_saida_item.nsi_lote_s else ""
                          int_ds_it_docto_xml.dval         = int_dp_nota_saida_item.nsi_datavalidade_d.
            end.
            else if avail int_ds_nota_saida_item then do:

                  assign  int_ds_it_docto_xml.lote         = if int_ds_nota_saida_item.nsp_lote_s <> ? 
                                                             then int_ds_nota_saida_item.nsp_lote_s else ""
                          int_ds_it_docto_xml.dval         = int_ds_nota_saida_item.nsp_datavalidade_d.
            end.
            run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                               output int_ds_it_docto_xml.cst_icms,
                               output l-sub).

            if it-nota-fisc.cd-trib-icm = 2 then assign int_ds_it_docto_xml.cst_icms = 40.
            if it-nota-fisc.cd-trib-icm = 3 then assign int_ds_it_docto_xml.cst_icms = 41.
            else if it-nota-fisc.cd-trib-icm = 5 then assign int_ds_it_docto_xml.cst_icms = 51.
        end.
    end.
    assign int_ds_docto_xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
           int_ds_docto_xml.valor_icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
           int_ds_docto_xml.vbc_cst      = de-tot-bsubs              /*  Base ICMS ST */                   
           int_ds_docto_xml.valor_st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */
           int_ds_docto_xml.envio_status = 1.

    for first ems2mult.emitente no-lock where emitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead):
        CREATE int_ds_docto_wms.
        ASSIGN int_ds_docto_wms.doc_numero_n    = nota-fiscal.nr-nota-fis
               int_ds_docto_wms.doc_serie_s     = int_ds_docto_xml.serie
               int_ds_docto_wms.cnpj_cpf        = int_ds_docto_xml.CNPJ
               int_ds_docto_wms.situacao        = /*1. /* Inclusão */*/ 10 /* novos status */
               int_ds_docto_wms.tipo_nota       = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 2
               int_ds_docto_wms.ENVIO_STATUS    = p-sit-procfit
               int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today).
               int_ds_docto_wms.id_sequencial   = NEXT-VALUE(seq-int-ds-docto-wms). /* Preparação para integração com Procfit */ .

        IF AVAIL bemitente THEN 
           ASSIGN int_ds_docto_wms.doc_origem_n    = bemitente.cod-emitente
                  int_ds_docto_wms.tipo_fornecedor = IF bemitente.natureza = 1 THEN "F" ELSE "J".
    end.

end procedure.

procedure pi-cancela-saidas:
    define input param p-origem as character.
    define input param p-sit-oblak-s as integer.
    define input param p-sit-procfit-s as integer.
    define input param p-sit-oblak-e as integer.  //
    define input param p-sit-procfit-e as integer.

    /* cancelar saida */
    for first int_ds_nota_saida EXCLUSIVE-LOCK where 
        int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc     and
        int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie and
        int_ds_nota_saida.nsa_notafiscal_n  = int64(nota-fiscal.nr-nota-fis):
        
        if int_ds_nota_saida.tipo_movto = 1 /* inclusao */ then do:
            assign  int_ds_nota_saida.tipo_movto   = 3 /* exclusao */
                    int_ds_nota_saida.dt_geracao   = today
                    int_ds_nota_saida.hr_geracao   = string(time,"HH:MM:SS")
                    int_ds_nota_saida.situacao     = p-sit-oblak-s
                    int_ds_nota_saida.envio_status = p-sit-procfit-s
                    int_ds_nota_saida.ENVIO_DATA_HORA = datetime(today).
            if tt-param.arquivo <> "" then DO:
                display
                    p-origem @ c-disp-sistema column-label "Origem"
                    nota-fiscal.cod-estabel
                    nota-fiscal.serie
                    nota-fiscal.nr-nota-fis                           
                    nota-fiscal.dt-emis-nota
                    nota-fiscal.dt-cancela
                    with frame f-rel.
                down with frame f-rel.
            END.

            /* cancelar entrada transferenia no CD */
            if  int_ds_nota_saida.nsa_cnpj_destino_s <> int_ds_nota_saida.nsa_cnpj_origem_s and /* nao eh balanco */
                nota-fiscal.esp-docto = 23 /* NFT */ then do:
                /* destino CD */
                for first b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
                    b-estabelec.cgc = nota-fiscal.cgc and
                    b-estabelec.cod-estabel = "973"
                    query-tuning(no-lookahead):

                    create int_ds_docto_wms.
                    assign int_ds_docto_wms.doc_numero_n    = string(int_ds_nota_saida.nsa_notafiscal_n)
                           int_ds_docto_wms.doc_serie_s     = int_ds_nota_saida.nsa_serie 
                           int_ds_docto_wms.cnpj_cpf        = int_ds_nota_saida.nsa_cnpj_origem_s
                           int_ds_docto_wms.tipo_nota       = if nota-fiscal.esp-docto = 23 then 3 else 1
                           int_ds_docto_wms.situacao        = 65
                           int_ds_docto_wms.ENVIO_STATUS    = p-sit-procfit-e
                           int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                           int_ds_docto_wms.ID_SEQUENCIAL   = next-value(seq-int-ds-docto-wms) .
                    for first ems2mult.emitente no-lock where emitente.cgc = int_ds_nota_saida.nsa_cnpj_origem_s
                        query-tuning(no-lookahead): 
                        assign  int_ds_docto_wms.doc_origem_n     = emitente.cod-emitente.
                                int_ds_docto_wms.tipo_fornecedor  = if emitente.natureza = 1 then "F" else "J".
                    end.
                    release int_ds_docto_wms.
                end.
            end.
        end.
    end.
    /* nota saida nova p/ cancelar */
    if not avail int_ds_nota_saida and
       (nota-fiscal.nat-operacao begins "5" or
        nota-fiscal.nat-operacao begins "6" or
        nota-fiscal.nat-operacao begins "7") and
        nota-fiscal.esp-docto <> 21 /* NFE */ then do: /* saidas */            
        run pi-saidas (p-origem,
                       p-sit-oblak-s, p-sit-procfit-s,
                       p-sit-oblak-e, p-sit-procfit-e).
    end.
    /* cancelar entrada LJ */
    for first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_nota_saida.nsa_cnpj_origem_s     and
        int_ds_nota_entrada.nen_serie_s       = int_ds_nota_saida.nsa_serie_s           and
        int_ds_nota_entrada.nen_notafiscal_n  = int_ds_nota_saida.nsa_notafiscal_n
        query-tuning(no-lookahead): 

        if int_ds_nota_entrada.tipo_movto = 1 /* inclusao*/ then do:
            assign  int_ds_nota_entrada.tipo_movto  = 3 /* exclusao */
                    int_ds_nota_entrada.dt_geracao  = today
                    int_ds_nota_entrada.hr_geracao  = string(time,"HH:MM:SS")
                    int_ds_nota_entrada.situacao    = p-sit-oblak-e.

            if tt-param.arquivo <> "" then do:
                display
                    p-origem @ c-disp-sistema column-label "Origem"
                    nota-fiscal.cod-estabel                        
                    nota-fiscal.serie
                    nota-fiscal.nr-nota-fis
                    nota-fiscal.dt-emis-nota
                    nota-fiscal.dt-cancela
                    with frame f-rel.
                down with frame f-rel.
            end.
        end.
    end.
    /* nota entrada nova p/ cancelar */
    if not avail int_ds_nota_entrada and
      (nota-fiscal.nat-operacao begins "1" or
       nota-fiscal.nat-operacao begins "2" or
       nota-fiscal.nat-operacao begins "3") and
       nota-fiscal.cgc = estabelec.cgc and
       nota-fiscal.esp-docto <> 20 /* NFD */ then do:
        run pi-entradas-balanco (p-origem, p-sit-oblak-e, p-sit-procfit-e).
    end.
end.

procedure pi-cancela-entradas:
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.
    
    for first ems2mult.estabelec no-lock where 
        estabelec.cod-estabel = nota-fiscal.cod-estabel and
        estabelec.cgc = nota-fiscal.cgc /* balanço destino = origem */
        query-tuning(no-lookahead):

        if estabelec.cod-estabel = "973" /* Destino CD */
        then do:
            for first int_ds_docto_xml where
                int_ds_docto_xml.cnpj     = estabelec.cgc and
                int(int_ds_docto_xml.nnf) = int(nota-fiscal.nr-nota-fis) and
                int_ds_docto_xml.serie    = nota-fiscal.serie
                query-tuning(no-lookahead):

                create int_ds_docto_wms.
                assign int_ds_docto_wms.doc_numero_n    = int_ds_docto_xml.nnf
                       int_ds_docto_wms.doc_serie_s     = int_ds_docto_xml.serie   
                       int_ds_docto_wms.doc_origem_n    = int_ds_docto_xml.cod_emitente
                       int_ds_docto_wms.situacao        = 65 /* Cancelada 50 - PRS - 65 - Procfit */
                       int_ds_docto_wms.tipo_nota       = int_ds_docto_xml.tipo_nota
                       int_ds_docto_wms.ENVIO_STATUS    = p-sit-procfit
                       int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                       int_ds_docto_wms.id_sequencial  = NEXT-VALUE(seq-int-ds-docto-wms) /* Preparação para integração com Procfit */.

                for each ems2mult.emitente where
                    emitente.cod-emitente = int_ds_docto_xml.cod_emitente no-lock
                    query-tuning(no-lookahead):
                    assign int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                           int_ds_docto_wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".
                end.
            end.
        end.
        /* Destino Loja */
        else do:
            for each int_ds_nota_entrada where 
                int_ds_nota_entrada.nen_cnpj_origem_s  = ems2mult.estabelec.cgc     and
                int_ds_nota_entrada.nen_serie_s        = nota-fiscal.serie and
                int_ds_nota_entrada.nen_notafiscal_n   = int(nota-fiscal.nr-nota-fis)
                query-tuning(no-lookahead):
                assign int_ds_nota_entrada.tipo_movto        = 3 /* exclusÆo */
                       int_ds_nota_entrada.dt_geracao        = today
                       int_ds_nota_entrada.hr_geracao        = string(time,"HH:MM:SS")
                       int_ds_nota_entrada.situacao          = p-sit-oblak
                       int_ds_nota_entrada.ENVIO_STATUS      = p-sit-procfit.
            end.
        end.
    end.
end.

PROCEDURE pi-custo-grade:
    DEFINE OUTPUT PARAMETER de-vl-custo-grade AS DECIMAL     NO-UNDO.
    def var i-mo        as int init 1                               no-undo.
    def var i-mo-fasb   as int                                      no-undo.
    def var i-mo-cmi    as int                                      no-undo.
    def var i-moeda     as int format 9                             no-undo.
    DEF VAR l-moed-ifrs-1 AS LOG                                    NO-UNDO.
    DEF VAR l-moed-ifrs-2 AS LOG                                    NO-UNDO.
    DEF VAR de-vl-ipi         AS DEC /*LIKE movto-estoq.valor-ipi */ NO-UNDO.
    DEF VAR de-vl-icms        AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    DEF VAR de-vl-pis         AS DEC /*LIKE movto-estoq.valor-pis */ NO-UNDO.
    DEF VAR de-vl-cofins      AS DEC /*LIKE movto-estoq.val-cofins*/ NO-UNDO.
    DEF VAR de-vl-icms-stret  AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    DEFINE VARIABLE de-vl-bonificacao AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE de-vl-importados AS DECIMAL     NO-UNDO.

    ASSIGN de-vl-bonificacao = 0.
    
    find first param-global no-lock no-error.
    find first param-estoq  no-lock no-error.
    find FIRST param-fasb   
       where param-fasb.ep-codigo = "RPW" no-lock no-error.
    
    assign i-mo-fasb = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-fasb 
                            then 2
                            else if param-estoq.moeda2 = param-fasb.moeda-fasb 
                                 then 3
                                 else 0
                       else 0
           i-mo-cmi  = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-cmi 
                            then 2                     
                            else if param-estoq.moeda2 = param-fasb.moeda-cmi 
                                 then 3
                                 else 0
                       else 0.
    IF can-find(first ems2log.funcao 
                where funcao.cd-funcao = "spp-ifrs-contab-estoq":U 
                  and funcao.ativo     = yes) THEN
        ASSIGN l-moed-ifrs-1 = param-estoq.log-moed-ifrs-1 
               l-moed-ifrs-2 = param-estoq.log-moed-ifrs-2.

    ASSIGN de-vl-custo-grade = 0
           de-vl-importados  = 0.

    FOR FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = it-nota-fisc.it-codigo,
        EACH movto-estoq NO-LOCK
        WHERE movto-estoq.cod-estabel  = it-nota-fisc.cod-estabel
        AND   movto-estoq.serie-docto  = it-nota-fisc.serie      
        AND   movto-estoq.nro-docto    = it-nota-fisc.nr-nota-fis
        AND   movto-estoq.cod-emitente = nota-fiscal.cod-emitente
        AND   movto-estoq.sequen-nf    = it-nota-fisc.nr-seq-fat
        AND   movto-estoq.it-codigo    = it-nota-fisc.it-codigo:
    
        ASSIGN de-vl-ipi        = it-nota-fisc.vl-ipi-it  
               de-vl-icms       = it-nota-fisc.vl-icms-it 
               de-vl-pis        = dec(substr(item.char-2,31,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-cofins     = dec(substr(item.char-2,36,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-icms-stret = 0.

        FOR FIRST esp-item-nfs-st NO-LOCK
            WHERE esp-item-nfs-st.cod-estab-nfs = it-nota-fisc.cod-estabel
            AND   esp-item-nfs-st.cod-ser-nfs   = it-nota-fisc.serie      
            AND   esp-item-nfs-st.cod-docto-nfs = it-nota-fisc.nr-nota-fis
            AND   esp-item-nfs-st.num-seq-nfs   = it-nota-fisc.nr-seq-fat
            AND   esp-item-nfs-st.cod-item      = it-nota-fisc.it-codigo,
            FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cod-emitente = INT(esp-item-nfs-st.cod-emitente-entr):

            FOR FIRST int_ds_it_docto_xml EXCLUSIVE-LOCK
                WHERE int_ds_it_docto_xml.nnf       = esp-item-nfs-st.cod-nota-entr
                AND   int_ds_it_docto_xml.serie     = esp-item-nfs-st.cod-ser-entr
                AND   int_ds_it_docto_xml.cnpj      = emitente.cgc
                AND   int_ds_it_docto_xml.sequencia = esp-item-nfs-st.num-seq-item-entr
                AND   int_ds_it_docto_xml.it_codigo = esp-item-nfs-st.cod-item:

                ASSIGN de-vl-custo-grade = de-vl-custo-grade
                                        - (((int_ds_it_docto_xml.vicmsstret + IF int_ds_it_docto_xml.vICMSSubs = ? THEN 0 ELSE int_ds_it_docto_xml.vICMSSubs ) / int_ds_it_docto_xml.qCom) * it-nota-fisc.qt-faturada[1]).


                ASSIGN de-vl-custo-grade = de-vl-custo-grade + IF int_ds_it_docto_xml.cst_icms = 60 THEN it-nota-fisc.vl-icms-it ELSE 0.
    
                 FIND FIRST b-emitente NO-LOCK
                        WHERE b-emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.

                IF int_ds_it_docto_xml.picms = 4 AND 
                   b-emitente.estado = "PR" THEN DO:

                    ASSIGN de-vl-importados = ((int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * 12 / 100) - 
                                          (int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * int_ds_it_docto_xml.picms / 100)) * it-nota-fisc.qt-faturada[1].

                END.
 

                FIND FIRST int_ds_natur_oper NO-LOCK
                    WHERE int_ds_natur_oper.log_bonificacao = YES
                      AND INT_ds_natur_oper.nat_operacao    = int_ds_it_docto_xml.nat_operacao  NO-ERROR.

                IF AVAIL int_ds_natur_oper THEN DO:


                    FIND FIRST item-doc-est NO-LOCK
                        WHERE item-doc-est.nro-docto    = int_ds_it_docto_xml.nnf       
                          AND item-doc-est.serie-docto  = int_ds_it_docto_xml.serie     
                          AND item-doc-est.cod-emitente = emitente.cod-emitente               
                          AND item-doc-est.sequencia    = int_ds_it_docto_xml.sequencia 
                          AND item-doc-est.it-codigo    = int_ds_it_docto_xml.it_codigo NO-ERROR.

                    IF AVAIL item-doc-est THEN DO:

                        ASSIGN de-vl-bonificacao = ROUND(((item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1] )
                                                     / item-doc-est.quantidade * it-nota-fisc.qt-faturada[1] ),2) - it-nota-fisc.vl-icms-it.


                        ASSIGN de-vl-pis     = 0
                               de-vl-cofins  = 0.


                    END.

                END.


            END.

            FOR FIRST int_ds_nota_entrada_produt NO-LOCK
                WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s      = emitente.cgc
                AND   int_ds_nota_entrada_produt.nen_notafiscal_n       = INT(esp-item-nfs-st.cod-nota-entr)
                AND   int_ds_nota_entrada_produt.nen_serie_s            = esp-item-nfs-st.cod-ser-entr
                AND   int_ds_nota_entrada_produt.nep_sequencia_n        = esp-item-nfs-st.num-seq-item-entr
                AND   int_ds_nota_entrada_produt.nep_produto_n          = int(esp-item-nfs-st.cod-item):
    
                ASSIGN de-vl-icms-stret = int_ds_nota_entrada_produt.de-vicmsstret.
            END.
        END.
    
        IF (i-mo = 2 AND l-moed-ifrs-1)
        OR (i-mo = 3 AND l-moed-ifrs-2) THEN DO:
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-ipi,
                              input  movto-estoq.dt-trans,
                              output de-vl-ipi).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-icms,
                              input  movto-estoq.dt-trans,
                              output de-vl-icms).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-pis,
                              input  movto-estoq.dt-trans,
                              output de-vl-pis).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-cofins,
                              input  movto-estoq.dt-trans,
                              output de-vl-cofins).
    
            if  de-vl-ipi    = ? then de-vl-ipi    = 0.
            if  de-vl-icms   = ? then de-vl-icms   = 0.
            if  de-vl-pis    = ? then de-vl-pis    = 0.
            if  de-vl-cofins = ? then de-vl-cofins = 0.
        END.

        if  movto-estoq.tipo-trans = 1 then  do:
            if  movto-estoq.valor-nota > 0 then do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                                 ( movto-estoq.valor-mat-m[i-mo] 
                                                 + movto-estoq.valor-mob-m[i-mo] 
                                                 + movto-estoq.valor-ggf-m[i-mo]) +
        
                                               if  i-mo = i-mo-fasb then
                                                   (movto-estoq.vl-ipi-fasb[1] +
                                                    movto-estoq.vl-icm-fasb[1] +
                                                    DEC(movto-estoq.vl-pis-fasb) +
                                                    DEC(movto-estoq.val-cofins-fasb) )
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       (movto-estoq.vl-ipi-fasb[2] +
                                                        movto-estoq.vl-icm-fasb[2] +
                                                        DEC(movto-estoq.vl-pis-cmi) +
                                                        DEC(movto-estoq.val-cofins-cmi) )
                                                   ELSE
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            end.
            else do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - (  movto-estoq.valor-mat-m[i-mo] 
                                            + movto-estoq.valor-mob-m[i-mo] 
                                            + movto-estoq.valor-ggf-m[i-mo]).
            END.
        
        end.
        
        else do:
            if  movto-estoq.valor-nota > 0 then
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         + if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                               if  i-mo = i-mo-fasb then
                                                   movto-estoq.vl-nota-fasb[1]
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       movto-estoq.vl-nota-fasb[2] 
                                                   else
                                                       ( movto-estoq.valor-mat-m[i-mo] 
                                                       + movto-estoq.valor-mob-m[i-mo] 
                                                       + movto-estoq.valor-ggf-m[i-mo]) + 
        
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            else do:
              assign de-vl-custo-grade = de-vl-custo-grade 
                                       + (  movto-estoq.valor-mat-m[i-mo] 
                                          + movto-estoq.valor-mob-m[i-mo] 
                                          + movto-estoq.valor-ggf-m[i-mo]).
            END.
    
        end.

        IF it-nota-fisc.nat-operacao = "5409a5" or
           it-nota-fisc.nat-operacao = "6409a5" or
		   it-nota-fisc.nat-operacao BEGINS "6152" THEN
            assign de-vl-custo-grade = de-vl-custo-grade 
                                     - de-vl-pis
                                     - de-vl-cofins.
    END.

    IF it-nota-fisc.nat-operacao BEGINS "6152" THEN DO:
        assign de-vl-custo-grade = de-vl-custo-grade     
                             + it-nota-fisc.vl-icmsub-it.

    END.
    ELSE DO:
    
        IF it-nota-fisc.cod-estabel = "977" THEN
        DO:
        
            IF it-nota-fisc.vl-bicms-it > 0  THEN
                assign de-vl-custo-grade = de-vl-custo-grade 
                         + it-nota-fisc.vl-icms-it
                         + it-nota-fisc.vl-icmsub-it.
            ELSE 
                assign de-vl-custo-grade = de-vl-custo-grade
                     + it-nota-fisc.vl-icmsub-it.

        END.
        ELSE DO:
    
            assign de-vl-custo-grade = de-vl-custo-grade 
                                 + it-nota-fisc.vl-icms-it
                                 + it-nota-fisc.vl-icmsub-it.
        END.                             
    END.

    ASSIGN de-vl-custo-grade = de-vl-custo-grade - de-vl-bonificacao + de-vl-importados.


    RETURN "NOK".
END PROCEDURE.


