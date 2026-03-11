/* ESTA INCLUDE ESTµ SENDO UTLIZADA NOS PROGRAMAS INT011, INT217 E INT237 */
/* QUALQUER ALTERAÄ«O DEVE SER TESTADA NOS TRES PROGRAMAS                 */

def var l-sub as logical no-undo.
def var de-quantidade like int-ds-pedido-retorno.rpp-quantidade-n.
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

define buffer b-estabelec for estabelec.
define temp-table tt-lote like int-ds-pedido-retorno 
    field tipo as char
    index chave 
        ppr-produto-n 
        rpp-quantidade-n
        rpp-lote-s
        tipo.

form
    nota-fiscal.cod-estabel
    nota-fiscal.serie
    nota-fiscal.nr-nota-fis
    nota-fiscal.dt-emis-nota
    nota-fiscal.dt-cancela
  with frame f-rel down stream-io width 300.

/* ESTA INCLUDE ESTµ SENDO UTLIZADA NOS PROGRAMAS INT011, INT217 E INT237 */
/* QUALQUER ALTERAÄ«O DEVE SER TESTADA NOS TRES PROGRAMAS                 */

procedure pi-saidas:
    define input param p-origem as character.
    define input param p-sit-oblak-s as integer.
    define input param p-sit-procfit-s as integer.

    define input param p-sit-oblak-e as integer.
    define input param p-sit-procfit-e as integer.

    for first int-ds-nota-saida where 
        int-ds-nota-saida.nsa-cnpj-origem-s = estabelec.cgc and
        int-ds-nota-saida.nsa-serie-s = nota-fiscal.serie AND
        int-ds-nota-saida.nsa-notafiscal-n = int(nota-fiscal.nr-nota-fis)
        query-tuning(no-lookahead): end.

    /* inclusao da nota */
    if not avail int-ds-nota-saida 
    then do transaction:

        if tt-param.arquivo <> "" then DO:
            display
                nota-fiscal.cod-estabel
                nota-fiscal.serie
                nota-fiscal.nr-nota-fis
                nota-fiscal.dt-emis-nota
                nota-fiscal.dt-cancela
                with frame f-rel.
            down with frame f-rel.
        END.

        for each tt-lote query-tuning(no-lookahead). delete tt-lote. end.
        for each int-ds-pedido-retorno no-lock where
            int-ds-pedido-retorno.ped-codigo-n = int(nota-fiscal.nr-pedcli) and
            int-ds-pedido-retorno.rpp-lote <> ? and int-ds-pedido-retorno.rpp-lote <> ""
            query-tuning(no-lookahead):
            create tt-lote.
            buffer-copy int-ds-pedido-retorno to tt-lote.

            if estabelec.cgc = nota-fiscal.cgc then do: /* Balanáo */
               assign de-quantidade = int-ds-pedido-retorno.rpp-quantidade-n - int-ds-pedido-retorno.rpp-qtd-inventario-n.
               if de-quantidade < 0 then do:
                    assign  tt-lote.rpp-quantidade = de-quantidade * -1
                            tt-lote.tipo = "S".
               end.
               else do:
                    assign  tt-lote.rpp-quantidade = de-quantidade
                            tt-lote.tipo = "E".
               end.
            end.
        end.

        for each it-nota-fisc no-lock of nota-fiscal
            query-tuning(no-lookahead):

            for first int-ds-nota-saida-item of int-ds-nota-saida where
                int-ds-nota-saida-item.nsp-sequencia-n = it-nota-fisc.nr-seq-fat and
                int-ds-nota-saida-item.nsp-produto-n   = int(it-nota-fisc.it-codigo)
                query-tuning(no-lookahead): end.

            if not avail int-ds-nota-saida-item then do:

                for first item fields (codigo-orig class-fiscal fm-codigo char-1) no-lock where 
                    item.it-codigo = it-nota-fisc.it-codigo
                    query-tuning(no-lookahead): end.

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
                for first natur-oper 
                    fields (cod-cfop tipo tp-oper-terc char-2
                            log-ipi-contrib-social log-ipi-outras-contrib-social) 
                    no-lock where 
                    natur-oper.nat-operacao = it-nota-fisc.nat-operacao
                    query-tuning(no-lookahead):
                    assign  int-ds-nota-saida-item.nsp-cfop-n = int(replace(natur-oper.cod-cfop,".","")).
                end.


                assign  i-ped-nota-saida-item                          = if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".",""))   
                                                                         else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".",""))
                                                                         else integer(replace(nota-fiscal.docto-orig,".",""))                                   
                        int-ds-nota-saida-item.ped-codigo-n            = /*if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                         else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                         else integer(replace(nota-fiscal.docto-orig,".",""))*/ 0
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
                for first fat-ser-lote no-lock of it-nota-fisc
                    query-tuning(no-lookahead):
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
                        rat-lote.lote = int-ds-nota-saida-item.nsp-lote-s
                        query-tuning(no-lookahead):
                        assign int-ds-nota-saida-item.nep-sequencia-n  = rat-lote.sequencia.
                    end.
                end.

                if /*int-ds-nota-saida-item.ped-codigo-n*/ i-ped-nota-saida-item <> 0 then 
                   assign i-pedido = /*int-ds-nota-saida-item.ped-codigo-n*/ i-ped-nota-saida-item.
                
               assign int-ds-nota-saida-item.nsp-caixa-n = int(it-nota-fisc.nr-seq-ped).
               for first cst-ped-item no-lock where
                   cst-ped-item.nome-abrev     = nota-fiscal.nome-ab-cli and
                   cst-ped-item.nr-pedcli      = it-nota-fisc.nr-pedcli  and
                   cst-ped-item.nr-sequencia   = it-nota-fisc.nr-seq-ped and
                   cst-ped-item.it-codigo      = it-nota-fisc.it-codigo  and
                   cst-ped-item.cod-refer      = it-nota-fisc.cod-refer
                   query-tuning(no-lookahead):
                   assign int-ds-nota-saida-item.nsp-lote-s = cst-ped-item.numero-lote.
               end.

               if not avail cst-ped-item then do:
                   l-ok = no.
                   if estabelec.cgc = nota-fiscal.cgc then do: /* Balanáo */
                       for first tt-lote where 
                           tt-lote.ppr-produto-n  = int-ds-nota-saida-item.nsp-produto-n   and
                           tt-lote.rpp-quantidade = int-ds-nota-saida-item.nsp-quantidade  and
                           tt-lote.rpp-lote      <> ?                                      and
                           tt-lote.rpp-lote      <> ""                                     and
                           tt-lote.tipo           = "S"
                           query-tuning(no-lookahead):
                           assign int-ds-nota-saida-item.nsp-lote-s = tt-lote.rpp-lote
                                  int-ds-nota-saida-item.nsp-datavalidade-d = tt-lote.rpp-validade-d
                                  l-ok = yes.
                           delete tt-lote.
                       end.
                   end.
                   /* demais notas */
                   else do:
                       for first tt-lote where 
                           tt-lote.ppr-produto-n  = int-ds-nota-saida-item.nsp-produto-n   and
                           tt-lote.rpp-quantidade = int-ds-nota-saida-item.nsp-quantidade  and
                           /* uma nota por caixa - caixa informada na nota */
                           tt-lote.rpp-caixa      = int-ds-nota-saida-item.nsp-caixa       and
                           tt-lote.rpp-lote      <> ?                                      and
                           tt-lote.rpp-lote      <> ""
                           query-tuning(no-lookahead):
                           assign int-ds-nota-saida-item.nsp-lote-s = tt-lote.rpp-lote
                                  int-ds-nota-saida-item.nsp-datavalidade-d = tt-lote.rpp-validade-d
                                  l-ok = yes.
                           delete tt-lote.
                       end.
                       /* notas fiscais sem caixa */
                       if not l-ok then
                           for first tt-lote where 
                               tt-lote.ppr-produto-n  = int-ds-nota-saida-item.nsp-produto-n   and
                               tt-lote.rpp-quantidade = int-ds-nota-saida-item.nsp-quantidade  and
                               tt-lote.rpp-lote      <> ?                                      and
                               tt-lote.rpp-lote      <> ""
                               query-tuning(no-lookahead):
                               assign int-ds-nota-saida-item.nsp-lote = tt-lote.rpp-lote
                                      int-ds-nota-saida-item.nsp-datavalidade-d = tt-lote.rpp-validade-d
                                      l-ok = yes.
                               delete tt-lote.
                           end.
                   end.
               end. /* avail cst-ped-item */
            end.
            release int-ds-nota-saida-item.
        end.  /* it-nota-fisc */

        create  int-ds-nota-saida.
        assign  int-ds-nota-saida.nsa-cnpj-origem-s  = estabelec.cgc
                int-ds-nota-saida.nsa-notafiscal-n   = integer(nota-fiscal.nr-nota-fis)
                int-ds-nota-saida.nsa-serie-s        = nota-fiscal.serie
                int-ds-nota-saida.nsa-cnpj-destino-s = nota-fiscal.cgc
                int-ds-nota-saida.nsa-dataemissao-d  = nota-fiscal.dt-emis-nota
                int-ds-nota-saida.nsa-chaveacesso-s  = &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                                            trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44))
                                                       &else
                                                            trim(substring(nota-fiscal.char-2,3,44))
                                                       &endif
                int-ds-nota-saida.ped-codigo-n       = if nota-fiscal.cod-estabel <> "973" AND
                                                          /* virada procfit lj 14 */
                                                          nota-fiscal.cod-estabel <> "014" and
                                                          nota-fiscal.cod-estabel <> "247" /*and p-origem <> "PROCFIT"*/ then
                                                         (if i-pedido <> 0 then i-pedido else int(nota-fiscal.nr-pedcli))
                                                       else 0 
                int-ds-nota-saida.ped-procfit        = if nota-fiscal.cod-estabel = "973" OR
                                                          /* virada procfit lj 14 */
                                                          nota-fiscal.cod-estabel = "014" or
                                                          nota-fiscal.cod-estabel = "247"
                                                           /*or p-origem = "PROCFIT"*/ then
                                                         (if i-pedido <> 0 then i-pedido else int(nota-fiscal.nr-pedcli))
                                                       else 0
                int-ds-nota-saida.id_sequencial      = next-VALUE(seq-int-ds-nota-saida) /* Preparaá∆o para integraá∆o com Procfit */
                int-ds-nota-saida.ENVIO_STATUS       = p-sit-procfit-s
                int-ds-nota-saida.ENVIO_DATA_HORA    = datetime(today).

        for first natur-oper 
            fields (cod-cfop tipo tp-oper-terc char-2
                    log-ipi-contrib-social log-ipi-outras-contrib-social) 
            no-lock where 
            natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead):
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

        assign  int-ds-nota-saida.dt-geracao   = today
                int-ds-nota-saida.hr-geracao   = string(time,"HH:MM:SS")
                int-ds-nota-saida.situacao     = p-sit-oblak-s.
    end.  /* not avail int-ds-nota-saida - transaction */
    /* notas de transferencia  - gerar entrada no destino */
    if  (nota-fiscal.nat-operacao begins "5" or
         nota-fiscal.nat-operacao begins "6" or
         nota-fiscal.nat-operacao begins "7") and 
         nota-fiscal.esp-docto = 23 and
         avail int-ds-nota-saida and
         int-ds-nota-saida.nsa-cnpj-destino-s <> int-ds-nota-saida.nsa-cnpj-origem-s then do: /* Balanáo os CNPJ s∆o iguais -> tratado em outro ponto */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel <> "973"
             query-tuning(no-lookahead):

            c-cfop = "".
            de-despesas = 0.
            for each int-ds-nota-saida-item no-lock of int-ds-nota-saida
                query-tuning(no-lookahead):
                de-despesas = de-despesas + int-ds-nota-saida-item.nsp-valordespesa-n.
                for first int-ds-nota-entrada-produto where 
                    int-ds-nota-entrada-produto.nen-cnpj-origem-s = int-ds-nota-saida.nsa-cnpj-origem-s     and
                    int-ds-nota-entrada-produto.nen-serie-s       = int-ds-nota-saida.nsa-serie-s           and
                    int-ds-nota-entrada-produto.nen-notafiscal-n  = int-ds-nota-saida.nsa-notafiscal-n      and
                    int-ds-nota-entrada-produto.nep-sequencia-n   = int-ds-nota-saida-item.nsp-sequencia-n  and
                    int-ds-nota-entrada-produto.nep-produto-n     = int-ds-nota-saida-item.nsp-produto-n    and
                    int-ds-nota-entrada-produto.nep-lote-s        = int-ds-nota-saida-item.nsp-lote-s
                    query-tuning(no-lookahead):      end.
                if not avail int-ds-nota-entrada-produto then do:

                    /*
                    put int-ds-nota-saida.nsa-cnpj-origem-s    " " 
                        int-ds-nota-saida.nsa-serie-s          " " 
                        int-ds-nota-saida.nsa-notafiscal-n     " " 
                        int-ds-nota-saida-item.nsp-sequencia-n " " 
                        int-ds-nota-saida-item.nsp-produto-n   " " 
                        int-ds-nota-saida-item.nsp-lote-s
                        skip.
                     */

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
                            int-ds-nota-entrada-produto.ped-codigo-n            = /*int-ds-nota-saida-item.ped-codigo-n*/ 0.

                    for first item fields (codigo-orig class-fiscal fm-codigo) no-lock where 
                        item.it-codigo = trim(string(int-ds-nota-saida-item.nsp-produto-n))
                        query-tuning(no-lookahead): end.
                    for first natur-oper 
                        fields (cod-cfop tipo tp-oper-terc char-2
                                log-ipi-contrib-social log-ipi-outras-contrib-social) 
                        no-lock where 
                        natur-oper.nat-operacao = nota-fiscal.nat-operacao
                        query-tuning(no-lookahead): end.

                    c-cfop = STRING(int-ds-nota-saida.nsa-cfop-n).
                    assign int-ds-nota-entrada-produto.nen-cfop-n = int(c-cfop).
                    release int-ds-nota-entrada-produto.
                end. /* not avail int-ds-nota-saida-produto */
            end. /* int-ds-nota-saida-produto */
            for first int-ds-nota-entrada where 
                int-ds-nota-entrada.nen-cnpj-origem-s = int-ds-nota-saida.nsa-cnpj-origem-s     and
                int-ds-nota-entrada.nen-serie-s       = int-ds-nota-saida.nsa-serie-s           and
                int-ds-nota-entrada.nen-notafiscal-n  = int-ds-nota-saida.nsa-notafiscal-n
                query-tuning(no-lookahead):     end.
            if not avail int-ds-nota-entrada then do:
                create  int-ds-nota-entrada.
                assign  int-ds-nota-entrada.dt-geracao          = today
                        int-ds-nota-entrada.hr-geracao          = string(time,"HH:MM:SS")
                        int-ds-nota-entrada.nen-basediferido-n  = int-ds-nota-saida.nsa-basediferido-n
                        int-ds-nota-entrada.nen-baseicms-n      = int-ds-nota-saida.nsa-baseicms-n
                        int-ds-nota-entrada.nen-baseipi-n       = int-ds-nota-saida.nsa-baseipi-n
                        int-ds-nota-entrada.nen-baseisenta-n    = int-ds-nota-saida.nsa-baseisenta-n
                        int-ds-nota-entrada.nen-basest-n        = int-ds-nota-saida.nsa-basest-n
                        int-ds-nota-entrada.nen-cfop-n          = int-ds-nota-saida.nsa-cfop-n
                        int-ds-nota-entrada.nen-chaveacesso-s   = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                                       trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44)) 
                                                                  &else                                         
                                                                       trim(substring(nota-fiscal.char-2,3,44)) 
                                                                  &endif                                        
                        int-ds-nota-entrada.nen-cnpj-destino-s  = int-ds-nota-saida.nsa-cnpj-destino-s
                        int-ds-nota-entrada.nen-cnpj-origem-s   = int-ds-nota-saida.nsa-cnpj-origem-s
                        int-ds-nota-entrada.nen-conferida-n     = 0
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
                        int-ds-nota-entrada.situacao                 = p-sit-oblak-e
                        int-ds-nota-entrada.tipo-movto               = 1
                        int-ds-nota-entrada.tipo-nota                = 3
                        int-ds-nota-entrada.ped-codigo-n             = int-ds-nota-saida.ped-codigo-n
                        int-ds-nota-entrada.ped-procfit              = int-ds-nota-saida.ped-procfit
                        int-ds-nota-entrada.id_sequencial            = next-VALUE(seq-int-ds-nota-entrada) /* Preparaá∆o para integraá∆o com Procfit */
                        int-ds-nota-entrada.ENVIO_STATUS             = p-sit-procfit-e
                        int-ds-nota-entrada.ENVIO_DATA_HORA          = datetime(today).

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
                        estabelec.cod-estabel
                        b-estabelec.cod-estabel
                        int-ds-nota-entrada.nen-serie-s
                        int-ds-nota-entrada.nen-notafiscal-n
                        int-ds-nota-entrada.nen-dataemissao-d
                        nota-fiscal.dt-cancela
                        with frame f-rel-entrada width 300 stream-io.
                    down with frame f-rel-entrada.
                END.

                release int-ds-nota-entrada.
            end. /* avail int-ds-nota-entrada */
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
    end.
end procedure.

procedure pi-entradas-balanco:
    define input param p-origem as char.
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.

    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = estabelec.cgc and
        int-ds-nota-entrada.nen-serie-s = nota-fiscal.serie AND
        int-ds-nota-entrada.nen-notafiscal-n = int(nota-fiscal.nr-nota-fis)
        query-tuning(no-lookahead): end.

    /* inclusío da nota */
    if not avail int-ds-nota-entrada then do transaction:

        if tt-param.arquivo <> "" then DO:
            display 
                nota-fiscal.cod-estabel
                nota-fiscal.serie
                nota-fiscal.nr-nota-fis
                nota-fiscal.dt-emis-nota
                nota-fiscal.dt-cancela
                with frame f-rel.
            down with frame f-rel.
        END.

        for each tt-lote. delete tt-lote. end.
        for each int-ds-pedido-retorno no-lock where
            int-ds-pedido-retorno.ped-codigo-n = int(nota-fiscal.nr-pedcli) and
            int-ds-pedido-retorno.rpp-lote <> ? and int-ds-pedido-retorno.rpp-lote <> ""
            query-tuning(no-lookahead):
            create tt-lote.
            buffer-copy int-ds-pedido-retorno to tt-lote.

            if estabelec.cgc = nota-fiscal.cgc then do: /* Balanáo */
               assign de-quantidade = int-ds-pedido-retorno.rpp-quantidade-n - int-ds-pedido-retorno.rpp-qtd-inventario-n.
               if de-quantidade < 0 then do:
                    assign  tt-lote.rpp-quantidade = de-quantidade * -1
                            tt-lote.tipo = "S".
               end.
               else do:
                    assign  tt-lote.rpp-quantidade = de-quantidade
                            tt-lote.tipo = "E".
               end.
            end.
        end.

        for each it-nota-fisc no-lock of nota-fiscal
            query-tuning(no-lookahead):

            for first int-ds-nota-entrada-produto of int-ds-nota-entrada where
                int-ds-nota-entrada-produto.nep-sequencia-n = it-nota-fisc.nr-seq-fat and
                int-ds-nota-entrada-produto.nep-produto-n   = int(it-nota-fisc.it-codigo)
                query-tuning(no-lookahead): end.

            if not avail int-ds-nota-entrada-produto then do:

                for first item fields (codigo-orig class-fiscal fm-codigo) no-lock where 
                    item.it-codigo = it-nota-fisc.it-codigo
                    query-tuning(no-lookahead): end.

                create  int-ds-nota-entrada-produto.                        
                assign  int-ds-nota-entrada-produto.nen-cnpj-origem-s       = estabelec.cgc      
                        int-ds-nota-entrada-produto.nen-notafiscal-n        = integer(nota-fiscal.nr-nota-fis)                      
                        int-ds-nota-entrada-produto.nen-serie-s             = nota-fiscal.serie                                     
                        int-ds-nota-entrada-produto.nep-sequencia-n         = it-nota-fisc.nr-seq-fat
                        int-ds-nota-entrada-produto.nep-produto-n           = int(it-nota-fisc.it-codigo)
                        int-ds-nota-entrada-produto.nep-quantidade-n        = it-nota-fisc.qt-faturada[1]
                        int-ds-nota-entrada-produto.nep-valorbruto-n        = it-nota-fisc.vl-merc-ori
                        int-ds-nota-entrada-produto.nep-valordesconto-n     = it-nota-fisc.vl-desconto
                        int-ds-nota-entrada-produto.nep-valorliquido-n      = it-nota-fisc.vl-merc-liq
                        int-ds-nota-entrada-produto.nep-baseicms-n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int-ds-nota-entrada-produto.nep-valoricms-n         = it-nota-fisc.vl-icms-it
                        int-ds-nota-entrada-produto.nep-basediferido-n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                         then it-nota-fisc.vl-bicms-it else 0
                        int-ds-nota-entrada-produto.nep-baseisenta-n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                         it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                         it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                         then it-nota-fisc.vl-icmsnt-it else 0.

                assign  int-ds-nota-entrada-produto.nep-valoripi-n          = it-nota-fisc.vl-ipi-it
                        int-ds-nota-entrada-produto.nep-icmsst-n            = it-nota-fisc.vl-icmsub-it
                        int-ds-nota-entrada-produto.nep-basest-n            = it-nota-fisc.vl-bsubs-it
                        /*int-ds-nota-entrada-produto.nep-valortotalproduto-n = it-nota-fisc.vl-tot-item*/.

                assign  int-ds-nota-entrada-produto.nep-percentualicms-n    = it-nota-fisc.aliquota-icm
                        int-ds-nota-entrada-produto.nep-percentualipi-n     = it-nota-fisc.aliquota-ipi
                        int-ds-nota-entrada-produto.nep-redutorbaseicms-n   = it-nota-fisc.perc-red-icm.
                assign  int-ds-nota-entrada-produto.nep-valordespesa-n      = it-nota-fisc.vl-despes-it
                        int-ds-nota-entrada-produto.nep-valorpis-n          = it-nota-fisc.vl-pis
                        int-ds-nota-entrada-produto.nep-valorcofins-n       = it-nota-fisc.vl-finsocial
                        /*int-ds-nota-entrada-produto.nep-peso-n              = it-nota-fisc.peso-bruto*/
                        int-ds-nota-entrada-produto.nep-baseipi-n           = it-nota-fisc.vl-bipi-it.
                assign  int-ds-nota-entrada-produto.nep-ncm-n               = if   it-nota-fisc.class-fiscal <> ""
                                                                              then int(it-nota-fisc.class-fiscal)
                                                                              else int(item.class-fiscal)
                        int-ds-nota-entrada-produto.nep-csta-n              = item.codigo-orig
                        /*int-ds-nota-entrada-produto.nep-valortributos-n     = int-ds-nota-entrada-produto.nep-valoricms-n 
                                                                       + int-ds-nota-entrada-produto.nep-valoripi-n
                                                                       + int-ds-nota-entrada-produto.nep-icmsst-n
                                                                       + int-ds-nota-entrada-produto.nep-valorpis-n
                                                                       + int-ds-nota-entrada-produto.nep-valorcofins-n*/.
                run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                                   output int-ds-nota-entrada-produto.nep-cstb-icm-n,
                                   output l-sub).
                for first natur-oper 
                    fields (cod-cfop tipo tp-oper-terc char-2
                            log-ipi-contrib-social log-ipi-outras-contrib-social) 
                    no-lock where 
                    natur-oper.nat-operacao = it-nota-fisc.nat-operacao
                    query-tuning(no-lookahead):
                    assign  int-ds-nota-entrada-produto.nen-cfop-n = int(replace(natur-oper.cod-cfop,".","")).
                end.


                assign  i-ped-nota-entrada-item                             = if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".",""))   
                                                                              else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".",""))
                                                                              else integer(replace(nota-fiscal.docto-orig,".",""))                                   
                        int-ds-nota-entrada-produto.ped-codigo-n            = /*if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                              else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                              else integer(replace(nota-fiscal.docto-orig,".",""))*/ 0
                        int-ds-nota-entrada-produto.nep-basepis-n           = it-nota-fisc.vl-tot-item
                                                                        - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                           or  substr(item.char-1,50,5) = "Sim"
                                                                           then   it-nota-fisc.vl-pis
                                                                                + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                        - (if natur-oper.tp-oper-terc = 4
                                                                           then it-nota-fisc.vl-icmsubit-e[3]
                                                                           else it-nota-fisc.vl-icmsub-it)
                        int-ds-nota-entrada-produto.nep-basecofins-n        = it-nota-fisc.vl-tot-item
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
                     assign int-ds-nota-entrada-produto.nep-basepis-n = int-ds-nota-entrada-produto.nep-basepis-n
                                                                   - it-nota-fisc.vl-ipi-it
                                                                   - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                      then it-nota-fisc.vl-ipiit-e[3]
                                                                      else 0).
                     assign int-ds-nota-entrada-produto.nep-basecofins-n = int-ds-nota-entrada-produto.nep-basecofins-n
                                                                    - it-nota-fisc.vl-ipi-it
                                                                    - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                       then it-nota-fisc.vl-ipiit-e[3]
                                                                       else 0).
                end.
                /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
                if  it-nota-fisc.cd-trib-ipi = 3 
                and substring(natur-oper.char-2,16,1) = "1":U
                and not natur-oper.log-ipi-outras-contrib-social then do:
                    assign int-ds-nota-entrada-produto.nep-basepis-n = int-ds-nota-entrada-produto.nep-basepis-n
                                                               - it-nota-fisc.vl-ipi-it
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                    assign int-ds-nota-entrada-produto.nep-basecofins-n = int-ds-nota-entrada-produto.nep-basecofins-n
                                                               - it-nota-fisc.vl-ipi-it
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                end.
                assign 
                        int-ds-nota-entrada-produto.nep-percentualpis-n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                else 0)
                                                                       / 10000.
                        int-ds-nota-entrada-produto.nep-percentualcofins-n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                       * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                else 0)
                                                                       / 10000.
                for first fat-ser-lote no-lock of it-nota-fisc
                    query-tuning(no-lookahead):
                    assign  int-ds-nota-entrada-produto.nep-lote-s  = substring(fat-ser-lote.nr-serlote,1,10)
                            int-ds-nota-entrada-produto.nep-datavalidade-d = fat-ser-lote.dt-vali-lote.
                end.

                if /*int-ds-nota-entrada-produto.ped-codigo-n*/ i-ped-nota-entrada-item <> 0 then 
                   assign i-pedido = /*int-ds-nota-entrada-produto.ped-codigo-n*/ i-ped-nota-entrada-item.

                for first cst-ped-item no-lock where
                    cst-ped-item.nome-abrev     = nota-fiscal.nome-ab-cli and
                    cst-ped-item.nr-pedcli      = it-nota-fisc.nr-pedcli  and
                    cst-ped-item.nr-sequencia   = it-nota-fisc.nr-seq-ped and
                    cst-ped-item.it-codigo      = it-nota-fisc.it-codigo  and
                    cst-ped-item.cod-refer      = it-nota-fisc.cod-refer
                    query-tuning(no-lookahead):
                    assign int-ds-nota-entrada-produto.nep-lote-s = cst-ped-item.numero-lote.
                end.
                if not avail cst-ped-item then do:
                    for first tt-lote where 
                        tt-lote.ppr-produto-n  = int-ds-nota-entrada-produto.nep-produto-n  and
                        tt-lote.rpp-quantidade = int-ds-nota-entrada-produto.nep-quantidade and
                        tt-lote.rpp-lote      <> ?                                          and
                        tt-lote.rpp-lote      <> ""                                         and
                        tt-lote.tipo           = "E"
                        query-tuning(no-lookahead):
                        assign int-ds-nota-entrada-produto.nep-lote = tt-lote.rpp-lote
                               int-ds-nota-entrada-produto.nep-datavalidade-d = tt-lote.rpp-validade-d.
                        delete tt-lote.
                    end.
                end.
            end.
            release int-ds-nota-entrada-produto.
        end.  /* it-nota-fisc */

        create  int-ds-nota-entrada.
        assign  int-ds-nota-entrada.nen-cnpj-origem-s   = estabelec.cgc
                int-ds-nota-entrada.nen-notafiscal-n    = integer(nota-fiscal.nr-nota-fis)
                int-ds-nota-entrada.nen-serie-s         = nota-fiscal.serie
                int-ds-nota-entrada.nen-cnpj-destino-s  = nota-fiscal.cgc
                int-ds-nota-entrada.nen-dataemissao-d   = nota-fiscal.dt-emis-nota
                int-ds-nota-saida.ped-codigo-n       = if nota-fiscal.cod-estabel <> "973" AND
                                                          /* virada procfit lj 14 */
                                                          nota-fiscal.cod-estabel <> "014" and
                                                          nota-fiscal.cod-estabel <> "247" /*and p-origem <> "PROCFIT"*/ then
                                                         (if i-pedido <> 0 then i-pedido else int(nota-fiscal.nr-pedcli))
                                                       else 0 
                int-ds-nota-saida.ped-procfit        = if nota-fiscal.cod-estabel = "973" OR
                                                          /* virada procfit lj 14 */
                                                          nota-fiscal.cod-estabel = "014" or
                                                          nota-fiscal.cod-estabel = "247"
                                                           /*or p-origem = "PROCFIT"*/ then
                                                         (if i-pedido <> 0 then i-pedido else int(nota-fiscal.nr-pedcli))
                                                       else 0
                int-ds-nota-entrada.id_sequencial       = next-VALUE(seq-int-ds-nota-entrada) /* Preparaá∆o para integraá∆o com Procfit */
                int-ds-nota-entrada.ENVIO_STATUS        = p-sit-procfit
                int-ds-nota-entrada.ENVIO_DATA_HORA     = datetime(today).
   
        for first natur-oper no-lock where 
            natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead):
            assign int-ds-nota-entrada.nen-cfop-n       = integer(replace(natur-oper.cod-cfop,".","")).
        end.
        assign  int-ds-nota-entrada.tipo-movto          = 1 /* inclusao */
                int-ds-nota-entrada.tipo-nota           = 2
                int-ds-nota-entrada.nen-cnpj-destino-s  = nota-fiscal.cgc
                int-ds-nota-entrada.nen-dataemissao-d   = nota-fiscal.dt-emis-nota
                int-ds-nota-entrada.nen-observacao-s    = substring(nota-fiscal.observ-nota,1,4000).

        /*
        for first transporte fields (cgc) no-lock where 
            transporte.nome-abrev = nota-fiscal.nome-transp:
            assign  int-ds-nota-entrada.nen-cnpj-transportadora-s = transporte.cgc.
        end.
        */
        for each int-ds-nota-entrada-produto no-lock of int-ds-nota-entrada
            query-tuning(no-lookahead):

            assign  int-ds-nota-entrada.nen-valortotalprodutos-n     = int-ds-nota-entrada.nen-valortotalprodutos-n
                                                                   + int-ds-nota-entrada-produto.nep-valorbruto-n
                    int-ds-nota-entrada.nen-quantidade-n             = int-ds-nota-entrada.nen-quantidade-n 
                                                                   + int-ds-nota-entrada-produto.nep-quantidade-n
                    int-ds-nota-entrada.nen-desconto-n               = int-ds-nota-entrada.nen-desconto-n 
                                                                   + int-ds-nota-entrada-produto.nep-valordesconto-n
                    int-ds-nota-entrada.nen-baseicms-n               = int-ds-nota-entrada.nen-baseicms-n
                                                                   + int-ds-nota-entrada-produto.nep-baseicms-n
                    int-ds-nota-entrada.nen-valoricms-n              = int-ds-nota-entrada.nen-valoricms-n
                                                                   + int-ds-nota-entrada-produto.nep-valoricms-n
                    int-ds-nota-entrada.nen-basediferido-n           = int-ds-nota-entrada.nen-basediferido-n 
                                                                   + int-ds-nota-entrada-produto.nep-basediferido-n
                    int-ds-nota-entrada.nen-baseisenta-n             = int-ds-nota-entrada.nen-baseisenta-n
                                                                   + int-ds-nota-entrada-produto.nep-baseisenta-n
                    int-ds-nota-entrada.nen-baseipi-n                = int-ds-nota-entrada.nen-baseipi-n
                                                                   + int-ds-nota-entrada-produto.nep-baseipi-n
                    int-ds-nota-entrada.nen-valoripi-n               = int-ds-nota-entrada.nen-valoripi-n 
                                                                   + int-ds-nota-entrada-produto.nep-valoripi-n
                    int-ds-nota-entrada.nen-basest-n                 = int-ds-nota-entrada.nen-basest-n
                                                                   + int-ds-nota-entrada-produto.nep-basest-n
                    int-ds-nota-entrada.nen-icmsst-n                 = int-ds-nota-entrada.nen-icmsst-n
                                                                   + int-ds-nota-entrada-produto.nep-icmsst-n.

        end. /* int-ds-nota-entrada-produto */

        assign  int-ds-nota-entrada.dt-geracao   = today
                int-ds-nota-entrada.hr-geracao   = string(time,"HH:MM:SS")
                int-ds-nota-entrada.situacao     = p-sit-oblak.

        /* 06/06/2017 - evitar criacao docto-wms p/ notas de loja - avb */
        if nota-fiscal.cod-estabel = "973" then
        /* 06/06/2017 - evitar criacao docto-wms p/ notas de loja - avb */
        for first emitente no-lock where 
            emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s
            query-tuning(no-lookahead):
            for first int-ds-docto-wms where
                int-ds-docto-wms.doc_numero_n   = int-ds-nota-entrada.nen-notafiscal-n and
                int-ds-docto-wms.doc_serie_s    = int-ds-nota-entrada.nen-serie-s      and
                int-ds-docto-wms.doc_origem_n   = emitente.cod-emitente
                query-tuning(no-lookahead):               end.
            if not avail int-ds-docto-wms then do:
                create int-ds-docto-wms.
                assign int-ds-docto-wms.doc_numero_n    = int-ds-nota-entrada.nen-notafiscal-n
                       int-ds-docto-wms.doc_serie_s     = int-ds-nota-entrada.nen-serie-s
                       int-ds-docto-wms.doc_origem_n    = emitente.cod-emitente
                       int-ds-docto-wms.situacao        = 10 /* Inclus∆o */
                       int-ds-docto-wms.cnpj_cpf        = emitente.cgc 
                       int-ds-docto-wms.tipo_fornecedor = if emitente.natureza = 1 then "F" else "J"
                       int-ds-docto-wms.tipo-nota       = if nota-fiscal.esp-docto = 23 then 3 else if nota-fiscal.esp-docto = 20 then 2 else 1
                       /*int-ds-docto-wms.id_sequencial   = next-VALUE(seq-int-ds-docto-wms) /* Preparaá∆o para integraá∆o com Procfit */*/
                       int-ds-docto-wms.ENVIO_STATUS    = p-sit-procfit
                       int-ds-docto-wms.ENVIO_DATA_HORA = datetime(today).
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
    end.  /* not avail int-ds-nota-entrada - transaction */

end procedure.


procedure pi-entrada-cd:
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.

    define buffer bemitente for emitente.

    assign de-tot-bicms = 0
           de-tot-icms  = 0
           de-tot-bsubs = 0
           de-tot-icmst = 0.

    for first estabelec no-lock where estabelec.cod-estabel = nota-fiscal.cod-estabel
        query-tuning(no-lookahead): end.

    for first int-ds-docto-xml no-lock where 
              int-ds-docto-xml.CNPJ         = estabelec.cgc             and
              /*int-ds-docto-xml.CNPJ-dest    = emitente.cgc            and
              int-ds-docto-xml.ep-codigo    = int(estabelec.ep-codigo)  and*/
              int-ds-docto-xml.serie        = nota-fiscal.serie         and
              int-ds-docto-xml.nNF          = nota-fiscal.nr-nota-fis:  end.
    if avail int-ds-docto-xml then return.

    /* destino */
    for first emitente no-lock where emitente.cod-emitente = nota-fiscal.cod-emitente
        query-tuning(no-lookahead): end.

    /* origem */
    for first bemitente no-lock where bemitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead): end.

    if not avail natur-oper then 
        for first natur-oper no-lock where natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead). end.

    display 
        nota-fiscal.cod-estabel
        nota-fiscal.serie
        nota-fiscal.nr-nota-fis
        nota-fiscal.dt-emis-nota
        nota-fiscal.dt-cancela
        with frame f-rel.
    down with frame f-rel.

    create  int-ds-docto-xml.
    assign  int-ds-docto-xml.CNPJ         = estabelec.cgc
            int-ds-docto-xml.CNPJ-dest    = emitente.cgc 
            int-ds-docto-xml.ep-codigo    = int(estabelec.ep-codigo)
            int-ds-docto-xml.serie        = nota-fiscal.serie
            int-ds-docto-xml.nNF          = nota-fiscal.nr-nota-fis
            int-ds-docto-xml.cod-emitente = bemitente.cod-emitente
            int-ds-docto-xml.dEmi         = nota-fiscal.dt-emis-nota
            int-ds-docto-xml.VNF          = nota-fiscal.vl-tot-nota             /* Valor total da nota fiscal */
            int-ds-docto-xml.observacao   = if trim(nota-fiscal.observ-nota) <> ? 
                                            then trim(nota-fiscal.observ-nota) else ""
            int-ds-docto-xml.valor-frete  = nota-fiscal.vl-frete                /* Frete total da nota */
            int-ds-docto-xml.valor-seguro = nota-fiscal.vl-seguro               /* Seguro total da nota  */
            int-ds-docto-xml.valor-outras = nota-fiscal.val-desp-outros         /* Despesas total da nota */
            int-ds-docto-xml.tot-desconto = nota-fiscal.vl-desconto   /*  Desconto total da nota fiscal  */          
            int-ds-docto-xml.valor-mercad = nota-fiscal.vl-mercad
            int-ds-docto-xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
            int-ds-docto-xml.valor-icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
            int-ds-docto-xml.vbc-cst      = de-tot-bsubs              /*  Base ICMS ST */                   
            int-ds-docto-xml.valor-st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */ 
            int-ds-docto-xml.modFrete     = nota-fiscal.ind-tp-frete  /*  Modalidade do frete (0-FOB 1-Cif) */
            int-ds-docto-xml.dt-trans     = nota-fiscal.dt-emis-nota
            int-ds-docto-xml.volume       = nota-fiscal.nr-volumes
            int-ds-docto-xml.cod-usuario  = nota-fiscal.user-calc
            int-ds-docto-xml.despesa-nota = nota-fiscal.val-desp-outros
            int-ds-docto-xml.estab-de-or  = nota-fiscal.cod-estabel
            int-ds-docto-xml.tipo-docto   = 1
            int-ds-docto-xml.tipo-estab   = 1
            int-ds-docto-xml.situacao     = p-sit-oblak
            int-ds-docto-xml.tipo-nota    = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 2
            int-ds-docto-xml.xNome        = emitente.nome-emit
            int-ds-docto-xml.chnfe        = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                 nota-fiscal.cod-chave-aces-nf-eletro
                                            &else                                         
                                                 trim(substring(nota-fiscal.char-2,3,44)) 
                                            &endif                                        
            int-ds-docto-xml.chnft        = &if "{&bf_dis_versao_ems}" >= "2.07" &then     
                                                 nota-fiscal.cod-chave-aces-nf-eletro      
                                            &else                                          
                                                 trim(substring(nota-fiscal.char-2,3,44))  
                                            &endif                                         
            int-ds-docto-xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
            int-ds-docto-xml.num-pedido   = int64(nota-fiscal.nr-pedcli)
            int-ds-docto-xml.valor-mercad = 0.

    for each estabelec no-lock where estabelec.cgc = trim(int-ds-docto-xml.CNPJ-dest),
        each cst-estabelec no-lock of estabelec where
        cst-estabelec.dt-fim-operacao >= nota-fiscal.dt-emis-nota
        query-tuning(no-lookahead):
        assign int-ds-docto-xml.cod-estab = estabelec.cod-estabel.
        leave.
    end.

    for each it-nota-fisc of nota-fiscal no-lock query-tuning(no-lookahead):

        if VALID-HANDLE(h-acomp) then
            RUN pi-acompanhar IN h-acomp(INPUT "Nota: " + string(nota-fiscal.nr-nota-fis)).

        for first int-ds-nota-saida-item of int-ds-nota-saida NO-LOCK where
                  int-ds-nota-saida-item.nsp-sequencia-n = it-nota-fisc.nr-seq-fat     and
                  int-ds-nota-saida-item.nsp-produto-n   = int(it-nota-fisc.it-codigo) 
            query-tuning(no-lookahead): 
        end.
        for first int-dp-nota-saida-item of int-ds-nota-saida NO-LOCK where
                  int-dp-nota-saida-item.nsi-sequencia-n = it-nota-fisc.nr-seq-fat     and
                  int-dp-nota-saida-item.nsi-produto-n   = int(it-nota-fisc.it-codigo) 
            query-tuning(no-lookahead): 
        end.

        if not avail int-ds-nota-saida-item and
           not avail int-dp-nota-saida-item then next.

        for first ITEM fields (item.codigo-orig)
            no-lock where item.it-codigo = it-nota-fisc.it-codigo
            query-tuning(no-lookahead): end.

        assign  de-tot-bicms   = de-tot-bicms   + it-nota-fisc.vl-bicms-it
                de-tot-icms    = de-tot-icms    + it-nota-fisc.vl-icms-it
                de-tot-bsubs   = de-tot-bsubs   + it-nota-fisc.vl-bsubs-it
                de-tot-icmst   = de-tot-icmst   + it-nota-fisc.vl-icmsub-it.
        
        for first natur-oper fields (cod-cfop) no-lock where 
            natur-oper.nat-operacao = it-nota-fisc.nat-operacao
            query-tuning(no-lookahead): end.

        
        for first int-ds-it-docto-xml where
            int-ds-it-docto-xml.tipo-nota  = int-ds-docto-xml.tipo-nota and 
            int-ds-it-docto-xml.CNPJ       = int-ds-docto-xml.CNPJ      and 
            int-ds-it-docto-xml.nNF        = int-ds-docto-xml.nNF       and 
            int-ds-it-docto-xml.serie      = int-ds-docto-xml.serie     and
            int-ds-it-docto-xml.sequencia  = it-nota-fisc.nr-seq-fat    and
            int-ds-it-docto-xml.it-codigo  = it-nota-fisc.it-codigo
            query-tuning(no-lookahead): end.

        if not avail int-ds-it-docto-xml then do:
            create int-ds-it-docto-xml.
            assign int-ds-it-docto-xml.arquivo      = int-ds-docto-xml.arquivo
                   int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota 
                   int-ds-it-docto-xml.CNPJ         = int-ds-docto-xml.CNPJ
                   int-ds-it-docto-xml.cod-emitente = bemitente.cod-emitente
                   int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF
                   int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie
                   int-ds-it-docto-xml.sequencia    = it-nota-fisc.nr-seq-fat 
                   int-ds-it-docto-xml.item-do-forn = it-nota-fisc.it-codigo
                   int-ds-it-docto-xml.it-codigo    = it-nota-fisc.it-codigo
                   int-ds-it-docto-xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
                   int-ds-it-docto-xml.qCom         = it-nota-fisc.qt-faturada[1]
                   /* Preenchido a pedido Renan - 25/04/2018 - AVB */
                   int-ds-it-docto-xml.qCom-forn    = it-nota-fisc.qt-faturada[1]
                   int-ds-it-docto-xml.vProd        = it-nota-fisc.vl-tot-item   
                   int-ds-it-docto-xml.vuncom       = it-nota-fisc.vl-preuni    
                   int-ds-it-docto-xml.vtottrib     = it-nota-fisc.vl-merc-liq                       
                   int-ds-it-docto-xml.vbc-icms     = it-nota-fisc.vl-bicms-it                       
                   int-ds-it-docto-xml.vDesc        = it-nota-fisc.vl-desconto                       
                   int-ds-it-docto-xml.vicms        = it-nota-fisc.vl-icms-it                        
                   int-ds-it-docto-xml.vbc-ipi      = it-nota-fisc.vl-bipi-it                        
                   int-ds-it-docto-xml.vipi         = it-nota-fisc.vl-ipi-it                         
                   int-ds-it-docto-xml.vicmsst      = it-nota-fisc.vl-icmsub-it                      
                   int-ds-it-docto-xml.vbcst        = it-nota-fisc.vl-bsubs-it                       
                   int-ds-it-docto-xml.picmsst      = it-nota-fisc.aliquota-icm                      
                   int-ds-it-docto-xml.pipi         = it-nota-fisc.aliquota-ipi
                   int-ds-it-docto-xml.ppis         = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                  else 0)
                                                                         / 10000
                   int-ds-it-docto-xml.pcofins      = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                  else 0)
                                                                         / 10000
                   int-ds-it-docto-xml.vbc-pis      = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                               else 0)
                                                                          - (if natur-oper.tp-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int-ds-it-docto-xml.vpis         = it-nota-fisc.vl-pis
                   int-ds-it-docto-xml.vbc-cofins   = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                          - (if natur-oper.tP-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int-ds-it-docto-xml.vcofins      = it-nota-fisc.vl-finsocial
                   int-ds-it-docto-xml.num-pedido   = int64(nota-fiscal.nr-pedcli)
                   int-ds-it-docto-xml.orig-icms    = item.codigo-orig
                   int-ds-it-docto-xml.vbcst        = it-nota-fisc.vl-bsubs-it
                   int-ds-it-docto-xml.vbc-ipi      = it-nota-fisc.vl-bipi-it                   
                   int-ds-it-docto-xml.vbcstret     = 0
                   int-ds-it-docto-xml.item-do-forn = it-nota-fisc.it-codigo                  
                   int-ds-it-docto-xml.vOutro       = it-nota-fisc.vl-despes-it.

            if avail int-dp-nota-saida-item then do:
                  assign  int-ds-it-docto-xml.lote         = if int-dp-nota-saida-item.nsi-lote-s <> ? 
                                                             then int-dp-nota-saida-item.nsi-lote-s else ""
                          int-ds-it-docto-xml.dval         = int-dp-nota-saida-item.nsi-datavalidade-d.
            end.
            else if avail int-ds-nota-saida-item then do:

                  assign  int-ds-it-docto-xml.lote         = if int-ds-nota-saida-item.nsp-lote-s <> ? 
                                                             then int-ds-nota-saida-item.nsp-lote-s else ""
                          int-ds-it-docto-xml.dval         = int-ds-nota-saida-item.nsp-datavalidade-d.
            end.
            run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                               output int-ds-it-docto-xml.cst-icms,
                               output l-sub).

            if it-nota-fisc.cd-trib-icm = 2 then assign int-ds-it-docto-xml.cst-icms = 40.
            if it-nota-fisc.cd-trib-icm = 3 then assign int-ds-it-docto-xml.cst-icms = 41.
            else if it-nota-fisc.cd-trib-icm = 5 then assign int-ds-it-docto-xml.cst-icms = 51.
        end.
    end.
    assign int-ds-docto-xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
           int-ds-docto-xml.valor-icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
           int-ds-docto-xml.vbc-cst      = de-tot-bsubs              /*  Base ICMS ST */                   
           int-ds-docto-xml.valor-st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */
           .

    for first emitente no-lock where emitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead):
        CREATE int-ds-docto-wms.
        ASSIGN int-ds-docto-wms.doc_numero_n    = INT(nota-fiscal.nr-nota-fis)
               int-ds-docto-wms.doc_serie_s     = int-ds-docto-xml.serie
               int-ds-docto-wms.cnpj_cpf        = int-ds-docto-xml.CNPJ
               int-ds-docto-wms.situacao        = /*1. /* Inclus∆o */*/ 10 /* novos status */
               int-ds-docto-wms.tipo-nota       = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 2
               int-ds-docto-wms.ENVIO_STATUS    = p-sit-procfit
               int-ds-docto-wms.ENVIO_DATA_HORA = datetime(today).
               /*int-ds-docto-wms.id_sequencial   = NEXT-VALUE(seq-int-ds-docto-wms). /* Preparaá∆o para integraá∆o com Procfit */.*/

        IF AVAIL bemitente THEN 
           ASSIGN int-ds-docto-wms.doc_origem_n    = bemitente.cod-emitente
                  int-ds-docto-wms.tipo_fornecedor = IF bemitente.natureza = 1 THEN "F" ELSE "J".
    end.

end procedure.

procedure pi-cancela-saidas:
    define input param p-origem as character.
    define input param p-sit-oblak-s as integer.
    define input param p-sit-procfit-s as integer.
    define input param p-sit-oblak-e as integer.
    define input param p-sit-procfit-e as integer.

    /* cancelar saida */
    for first int-ds-nota-saida where 
        int-ds-nota-saida.nsa-cnpj-origem-s = estabelec.cgc     and
        int-ds-nota-saida.nsa-serie-s       = nota-fiscal.serie and
        int-ds-nota-saida.nsa-notafiscal-n  = int64(nota-fiscal.nr-nota-fis)
        query-tuning(no-lookahead):
        if int-ds-nota-saida.tipo-movto = 1 /* inclusao */ then do:
            assign  int-ds-nota-saida.tipo-movto   = 3 /* exclusao */
                    int-ds-nota-saida.dt-geracao   = today
                    int-ds-nota-saida.hr-geracao   = string(time,"HH:MM:SS")
                    int-ds-nota-saida.situacao     = p-sit-oblak-s
                    int-ds-nota-saida.envio_status = p-sit-procfit-s
                    int-ds-nota-saida.ENVIO_DATA_HORA = datetime(today).
            if tt-param.arquivo <> "" then DO:
                display 
                    nota-fiscal.cod-estabel
                    nota-fiscal.serie
                    nota-fiscal.nr-nota-fis
                    nota-fiscal.dt-emis-nota
                    nota-fiscal.dt-cancela
                    with frame f-rel.
                down with frame f-rel.
            END.

            /* cancelar entrada transferenia no CD */
            if  int-ds-nota-saida.nsa-cnpj-destino-s <> int-ds-nota-saida.nsa-cnpj-origem-s and /* nao eh balanco */
                nota-fiscal.esp-docto = 23 /* NFT */ then do:
                /* destino CD */
                for first b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
                    b-estabelec.cgc = nota-fiscal.cgc and
                    b-estabelec.cod-estabel = "973"
                    query-tuning(no-lookahead):

                    create int-ds-docto-wms.
                    assign int-ds-docto-wms.doc_numero_n    = int-ds-nota-saida.nsa-notafiscal-n
                           int-ds-docto-wms.doc_serie_s     = int-ds-nota-saida.nsa-serie 
                           int-ds-docto-wms.cnpj_cpf        = int-ds-nota-saida.nsa-cnpj-origem-s
                           int-ds-docto-wms.tipo-nota       = if nota-fiscal.esp-docto = 23 then 3 else 1
                           int-ds-docto-wms.situacao        = 65
                           int-ds-docto-wms.ENVIO_STATUS    = p-sit-procfit-e
                           int-ds-docto-wms.ENVIO_DATA_HORA = datetime(today)
                           /*int-ds-docto-wms.ID_SEQUENCIAL   = next-value(seq-int-ds-docto-wms)*/ .
                    for first emitente no-lock where emitente.cgc = int-ds-nota-saida.nsa-cnpj-origem-s
                        query-tuning(no-lookahead): 
                        assign  int-ds-docto-wms.doc_origem_n     = emitente.cod-emitente.
                                int-ds-docto-wms.tipo_fornecedor  = if emitente.natureza = 1 then "F" else "J".
                    end.
                    release int-ds-docto-wms.
                end.
            end.
        end.
    end.
    /* nota saida nova p/ cancelar */
    if not avail int-ds-nota-saida and
       (nota-fiscal.nat-operacao begins "5" or
        nota-fiscal.nat-operacao begins "6" or
        nota-fiscal.nat-operacao begins "7") and
        nota-fiscal.esp-docto <> 21 /* NFE */ then do: /* saidas */            
        run pi-saidas (p-origem,
                       p-sit-oblak-s, p-sit-procfit-s,
                       p-sit-oblak-e, p-sit-procfit-e).
    end.
    /* cancelar entrada LJ */
    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = int-ds-nota-saida.nsa-cnpj-origem-s     and
        int-ds-nota-entrada.nen-serie-s       = int-ds-nota-saida.nsa-serie-s           and
        int-ds-nota-entrada.nen-notafiscal-n  = int-ds-nota-saida.nsa-notafiscal-n
        query-tuning(no-lookahead): 

        if int-ds-nota-entrada.tipo-movto = 1 /* inclusao*/ then do:
            assign  int-ds-nota-entrada.tipo-movto  = 3 /* exclusao */
                    int-ds-nota-entrada.dt-geracao  = today
                    int-ds-nota-entrada.hr-geracao  = string(time,"HH:MM:SS")
                    int-ds-nota-entrada.situacao    = p-sit-oblak-e.

            if tt-param.arquivo <> "" then do:
                display 
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
    /* nota entrada balanco nova p/ cancelar */
    if not avail int-ds-nota-entrada and
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
    
    for first estabelec no-lock where 
        estabelec.cod-estabel = nota-fiscal.cod-estabel and
        estabelec.cgc = nota-fiscal.cgc /* balanáo destino = origem */
        query-tuning(no-lookahead):

        if estabelec.cod-estabel = "973" /* Destino CD */
        then do:
            for first int-ds-docto-xml where
                int-ds-docto-xml.cnpj     = estabelec.cgc and
                int(int-ds-docto-xml.nnf) = int(nota-fiscal.nr-nota-fis) and
                int-ds-docto-xml.serie    = nota-fiscal.serie
                query-tuning(no-lookahead):

                create int-ds-docto-wms.
                assign int-ds-docto-wms.doc_numero_n    = INT(int-ds-docto-xml.nnf)
                       int-ds-docto-wms.doc_serie_s     = int-ds-docto-xml.serie   
                       int-ds-docto-wms.doc_origem_n    = int-ds-docto-xml.cod-emitente
                       int-ds-docto-wms.situacao        = 65 /* Cancelada 50 - PRS - 65 - Procfit */
                       int-ds-docto-wms.tipo-nota       = int-ds-docto-xml.tipo-nota
                       int-ds-docto-wms.ENVIO_STATUS    = p-sit-procfit
                       int-ds-docto-wms.ENVIO_DATA_HORA = datetime(today)
                       /*int-ds-docto-wms.id_sequencial  = NEXT-VALUE(seq-int-ds-docto-wms) /* Preparaá∆o para integraá∆o com Procfit */*/.

                for each emitente where
                    emitente.cod-emitente = int-ds-docto-xml.cod-emitente no-lock
                    query-tuning(no-lookahead):
                    assign int-ds-docto-wms.cnpj_cpf        = emitente.cgc 
                           int-ds-docto-wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".
                end.
            end.
        end.
        /* Destino Loja */
        else do:
            for each int-ds-nota-entrada where 
                int-ds-nota-entrada.nen-cnpj-origem-s  = estabelec.cgc     and
                int-ds-nota-entrada.nen-serie-s        = nota-fiscal.serie and
                int-ds-nota-entrada.nen-notafiscal-n   = int(nota-fiscal.nr-nota-fis)
                query-tuning(no-lookahead):
                assign int-ds-nota-entrada.tipo-movto        = 3 /* exclusío */
                       int-ds-nota-entrada.dt-geracao        = today
                       int-ds-nota-entrada.hr-geracao        = string(time,"HH:MM:SS")
                       int-ds-nota-entrada.situacao          = p-sit-oblak
                       int-ds-nota-entrada.ENVIO_STATUS      = p-sit-procfit.
            end.
        end.
    end.

end.
