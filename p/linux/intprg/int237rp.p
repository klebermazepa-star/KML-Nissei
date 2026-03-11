/***********************************************************************************
** Programa: INT237 - Importaá∆o de Notas de Saida PROCFIT - CANCELAMENTO
**
** Versao : 12 - 22/03/2018 - Alessandro V Baccin
**
************************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i int237rp 2.12.06.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* definiá∆o das temp-tables para recebimento de parÉmetros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".


function TrataNulochar returns char
    (input pc-string as char):

    if pc-string = ? then return "".
    else return trim(pc-string).
    
end.

function TrataNuloDec returns decimal
    (input pc-dec as decimal):

    if pc-dec = ? then return 0.
    else return pc-dec.
    
end.

/* recebimento de parÉmetros */
def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

define temp-table tt-param-ft2100
    field destino           as integer 
    field arquivo           as char
    field usuario           as char
    field data-exec         as date
    field hora-exec         as integer
    field tipo-atual        as integer   /* 1 - Atualiza, 2 - Desatualiza */
    field c-desc-tipo-atual as char format "x(15)"
    field da-emissao-ini    as date format "99/99/9999"
    field da-emissao-fim    as date format "99/99/9999"
    field da-saida          as date format "99/99/9999"
    field da-vencto-ipi     as date format "99/99/9999"
    field da-vencto-icms    as date format "99/99/9999"
    field da-vencto-iss     as date format "99/99/9999"
    field c-estabel-ini     as char
    field c-estabel-fim     as char
    field c-serie-ini       as char
    field c-serie-fim       as char
    field c-nr-nota-ini     as char
    field c-nr-nota-fim     as char
    field de-embarque-ini   as dec
    field de-embarque-fim   as dec
    field c-preparador      as char
    field l-disp-men        as log
    field l-b2b             as log
    field log-1             as log.

define temp-table tt-param-FT2200 no-undo
    field destino           as integer
    field arquivo           as char format "x(35)"
    field usuario           as char format "x(12)"
    field data-exec         as date
    field hora-exec         as integer
    field cod-estabel       like nota-fiscal.cod-estabel
    field serie             like nota-fiscal.serie
    field nr-nota-fis       like nota-fiscal.nr-nota-fis
    field dt-cancela        like nota-fiscal.dt-cancela
    field desc-cancela      like nota-fiscal.desc-cancela
    field arquivo-estoq     as char
    field reabre-resumo     as logi
    field cancela-titulos   as logi
    field imprime-ajuda     as logi
    field l-valida-dt-saida as logi
    field l-elinia-nfse     as logical.

def temp-table tt-item-doc-est-fat no-undo like item-doc-est.

def temp-table tt_cancelamento_estorno_apb_1 no-undo
    field ttv_ind_niv_operac_apb           as character format "X(10)"
    field ttv_ind_tip_operac_apb           as character format "X(12)"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field ttv_des_histor                   as character format "x(40)" label "ContÇm" column-label "Hist¢rico"
    field ttv_ind_tip_estorn               as character format "X(10)"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field ttv_cod_estab_reembol            as character format "x(8)"
    field ttv_log_reaber_item              as logical format "Sim/N∆o" initial yes
    field ttv_log_reembol                  as logical format "Sim/N∆o" initial yes
    field ttv_log_estorn_impto_retid       as logical format "Sim/N∆o" initial yes
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cdn_fornecedor               as integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc".

def temp-table tt_estornar_agrupados no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "SeqÅància" column-label "Seq"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_estab_pagto              as character format "x(3)" label "Estab Pagto" column-label "Estab Pagto"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_dat_pagto                    as date format "99/99/9999" initial today label "Data Pagamento" column-label "Data Pagto"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_movto_ap                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor  Movimento" column-label "Valor Movto"
    field tta_ind_modo_pagto               as character format "X(10)" label "Modo  Pagamento" column-label "Modo Pagto"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field ttv_num_seq_abrev                as integer format ">>9" label "Sq" column-label "Sq"
    field tta_ind_trans_ap_abrev           as character format "X(04)" label "Trans Abrev" column-label "Trans Abrev"
    field ttv_rec_compl_movto_pagto        as recid format ">>>>>>9"
    field ttv_rec_movto_tit_ap             as recid format ">>>>>>9"
    field ttv_rec_item_cheq_ap             as recid format ">>>>>>9"
    field ttv_rec_item_bord_ap             as recid format ">>>>>>9"
    field ttv_rec_item_lote_pagto          as recid format ">>>>>>9"
    index tt_ind_modo                     
          tta_ind_modo_pagto               ascending.

def temp-table tt_estorna_tit_imptos no-undo
    field ttv_cod_refer_imp                as character format "x(10)" label "Referància" column-label "Referància"
    field ttv_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field ttv_cod_estab_imp                as character format "x(3)" label "Estabelec. Impto." column-label "Estab. Imp."
    field ttv_cdn_fornecedor_imp           as integer format ">>>,>>>,>>9" label "Fornecedor" column-label "Fornecedor"
    field ttv_cod_espec_docto_imp          as character format "x(3)" label "EspÇcie documento" column-label "EspÇcie"
    field ttv_cod_ser_docto_imp            as character format "x(3)" label "SÇrie documento" column-label "SÇrie"
    field ttv_cod_tit_ap_imp               as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field ttv_cod_parcela_imp              as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_tit_ap_imp               as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor T°tulo" column-label "Valor T°tulo"
    field ttv_val_sdo_tit_ap_imp           as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Saldo" column-label "Valor Saldo"
    field ttv_num_id_tit_ap_imp            as integer format "9999999999" label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    field ttv_cod_estab_2                  as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cdn_fornecedor               as integer format ">>>,>>>,>>9" label "Fornecedor" column-label "Fornecedor"
    field ttv_cod_espec_docto              as character format "x(3)" label "EspÇcie documento" column-label "EspÇcie"
    field ttv_cod_ser_docto                as character format "x(3)" label "SÇrie docto" column-label "SÇrie"
    field ttv_cod_tit_ap                   as character format "x(10)" label "T°tulo Ap" column-label "T°tulo Ap"
    field ttv_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_tit_ap                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor T°tulo" column-label "Valor T°tulo"
    field ttv_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Saldo" column-label "Valor Saldo"
    field ttv_num_id_tit_ap                as integer format "9999999999" label "Token Tit AP" column-label "Token Tit AP"
    field ttv_ind_trans_ap_abrev           as character format "X(04)" label "Transaá∆o" column-label "Transaá∆o"
    field ttv_cod_refer_2                  as character format "x(10)" label "Referància" column-label "Referància"
    field ttv_num_order                    as integer format ">>>>,>>9" label "Ordem" column-label "Ordem"
    field ttv_val_tot_comprtdo             as decimal format "->>>,>>>,>>9.99" decimals 2
    index tt_idimpto                      
          ttv_cod_estab_imp                ascending
          ttv_cdn_fornecedor_imp           ascending
          ttv_cod_espec_docto_imp          ascending
          ttv_cod_ser_docto_imp            ascending
          ttv_cod_tit_ap_imp               ascending
          ttv_cod_parcela_imp              ascending
    index tt_idimpto_pgef                 
          ttv_cod_estab                    ascending
          ttv_cod_refer                    ascending
    index tt_idtit_refer                  
          ttv_cod_estab_2                  ascending
          ttv_cdn_fornecedor               ascending
          ttv_cod_espec_docto              ascending
          ttv_cod_ser_docto                ascending
          ttv_cod_tit_ap                   ascending
          ttv_cod_parcela                  ascending
          ttv_cod_refer_2                  ascending
    index tt_numsg                        
          ttv_num_mensagem                 ascending
    index tt_order                        
          ttv_num_order                    ascending.

def temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento".

def temp-table tt_log_erros_estorn_cancel_apb no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_mensagem                 as integer format ">>,>>>,>>9" initial 0 label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda".


{cdp/cd0666.i}

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int237.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
def var h-aux               as handle no-undo.
def var h-acomp             as handle no-undo.
def var l-erro              as logical no-undo.
def var l-aux               as logical no-undo.
def var r-rowid             as rowid no-undo.
def var c-cod-estabel       as char no-undo.
def var d-dt-procfit        as date no-undo.
def var c-num-nota          as char no-undo.
def var c-aux               as char no-undo.

def buffer bint_dp_nota_saida_cancela for int_dp_nota_saida_cancela.
def buffer bnota-fiscal for nota-fiscal.
def buffer bitem-doc-est for item-doc-est.
def buffer bdocum-est for docum-est.
def buffer b2-item-doc-est for item-doc-est.

/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i}
/* bloco principal do programa */

FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i}
END.

assign c-programa     = "int237"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Faturamento"
       c-titulo-relat = "Importacao NF Procfit - CANCELAMENTO".

IF tt-param.arquivo <> "" THEN DO:
    view frame f-cabec.
    view frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.


/******* LE NOTA E GERA TEMP TABLES  *************/
for-nota:
for each int_dp_nota_saida_cancela no-lock where 
    int_dp_nota_saida_cancela.situacao = 1
    query-tuning(no-lookahead):

    assign c-num-nota = trim(string(int_dp_nota_saida_cancela.nsa_notafiscal_n,">>>9999999")).
    assign l-erro = no.

    run pi-elimina-tabelas.

    run pi-acompanhar in h-acomp (input "Validando Nota:" + 
                                  int_dp_nota_saida_cancela.nsa_cnpj_origem_s + "/" + 
                                  int_dp_nota_saida_cancela.nsa_serie_s + "/" + 
                                  string(int_dp_nota_saida_cancela.nsa_notafiscal_n)).

    run pi-valida-cabecalho.
    if not l-erro then do:
        run pi-cancela-nota.
    end.
    run pi-elimina-tabelas.
end. /* for-nota */

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpclo.i}
END.

RUN intprg/int888.p (input "NF CANC",
                     input "int237rp.p").

run pi-finalizar in h-acomp.
return "OK":U.

procedure pi-valida-cabecalho:

    if int_dp_nota_saida_cancela.nsa_datacancelamento_d = ? then do: 
        run pi-gera-log (input "Data de cancelamento em branco: " 
                         + "CNPJ: "      + int_dp_nota_saida_cancela.nsa_cnpj_origem_s
                         + " SÇrie: "    + int_dp_nota_saida_cancela.nsa_serie_s
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.

    for first emitente fields (cod-emitente nome-abrev estado identific) no-lock where 
        emitente.cgc = int_dp_nota_saida_cancela.nsa_cnpj_origem_s query-tuning(no-lookahead): 
    end.
    if not avail emitente then do:
        run pi-gera-log (input "Fornecedor n∆o cadastrado. CNPJ: " + string(int_dp_nota_saida_cancela.nsa_cnpj_origem_s),
                         input 1).
    end.

    c-cod-estabel = "".
    d-dt-procfit  = ?.
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_dp_nota_saida_cancela.nsa_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_dp_nota_saida_cancela.nsa_datacancelamento_d
        query-tuning(no-lookahead):
        c-cod-estabel  = estabelec.cod-estabel.
        d-dt-procfit   = cst_estabelec.dt_inicio_oper.
        leave.
    end.

    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento Origem n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int_dp_nota_saida_cancela.nsa_cnpj_origem_s,
                         input 1).
        return.
    end.

    for each nota-fiscal no-lock where 
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = int_dp_nota_saida_cancela.nsa_serie_s and
        nota-fiscal.nr-nota-fis = c-num-nota
        query-tuning(no-lookahead):
        
        if nota-fiscal.dt-cancela <> ? then do:
            run pi-gera-log (input "Documento j† cancelado: " 
                             + "Est: "      + nota-fiscal.cod-estabel
                             + " SÇrie: "   + nota-fiscal.serie 
                             + " Numero: "  + nota-fiscal.nr-nota-fis,
                             input 2).
            for each bint_dp_nota_saida_cancela where
                bint_dp_nota_saida_cancela.nsa_cnpj_origem_s  = int_dp_nota_saida_cancela.nsa_cnpj_origem_s and
                bint_dp_nota_saida_cancela.nsa_serie_s        = int_dp_nota_saida_cancela.nsa_serie_s       and
                bint_dp_nota_saida_cancela.nsa_notafiscal_n   = int_dp_nota_saida_cancela.nsa_notafiscal_n
                query-tuning(no-lookahead):
                assign  bint_dp_nota_saida_cancela.situacao = 2 /* processada */.
                for each int_ds_pedido_subs exclusive-lock where 
                    int_ds_pedido_subs.ped_codigo_n = int64(nota-fiscal.nr-pedcli)
                    query-tuning(no-lookahead):
                    assign int_ds_pedido_subs.situacao = 3.
                end.
                for each int_ds_pedido exclusive-lock where 
                    int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli)
                    query-tuning(no-lookahead):
                    assign int_ds_pedido.situacao = 3.
                end.
                release bint_dp_nota_saida_cancela.
            end.
            assign l-erro = yes.
            return.
        end.

        if d-dt-procfit = ? or d-dt-procfit > nota-fiscal.dt-emis-nota then do:
            run pi-gera-log (input "Estabelecimento Origem n∆o Ç Procfit na data de emiss∆o. CNPJ: " + int_dp_nota_saida_cancela.nsa_cnpj_origem_s + 
                                   " Data: " + string(int_dp_nota_saida_cancela.nsa_datacancelamento_d ,"99/99/9999"),
                             input 1).
            return.
        end.
    
        for first param-estoq no-lock query-tuning(no-lookahead): 
            if month (param-estoq.ult-fech-dia) = 12 then 
                assign c-aux = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
            else
                assign c-aux = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").
    
            if param-estoq.ult-fech-dia >= nota-fiscal.dt-emis-nota or
               param-estoq.mensal-ate >= nota-fiscal.dt-emis-nota or
              (c-aux = string(year(nota-fiscal.dt-emis-nota),"9999") + string(month(nota-fiscal.dt-emis-nota),"99") and
              (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes))
            then do:
                run pi-gera-log (input "Documento em per°odo fechado ou em fechamento. " 
                                 + "Est: "       + c-cod-estabel
                                 + " SÇrie: "    + int_dp_nota_saida_cancela.nsa_serie_s 
                                 + " Numero: "   + c-num-nota
                                 + " Data NF: "  + string(nota-fiscal.dt-emis-nota,"99/99/9999"),
                                 input 1).
                return.
            end.
        end.
    end.

end procedure.

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-erro.
   empty temp-table tt-param-ft2100.
end.        

procedure pi-cancela-nota.

    for first nota-fiscal exclusive-lock where 
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = int_dp_nota_saida_cancela.nsa_serie_s and
        nota-fiscal.nr-nota-fis = c-num-nota and
        nota-fiscal.dt-cancela  = ?
        query-tuning(no-lookahead):

        run pi-acompanhar in h-acomp (input "Cancelando: " +
                                      nota-fiscal.cod-estabel + "/" + 
                                      nota-fiscal.serie + "/" + 
                                      nota-fiscal.nr-nota-fis).

        /* entradas */
        if int(substring(nota-fiscal.nat-operacao,1,1)) <= 3 then do:
            run pi-desatualiza-entrada.
        end.
        /* saidas */
        else do:
            if nota-fiscal.esp-docto = 23 /* NFT */ then run pi-desatualiza-transferencia.
            run pi-desatualiza-saida.
        end.

        if return-value = "OK" then do:

            for last ret-nf-eletro exclusive-lock where 
                ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel and 
                ret-nf-eletro.cod-serie   = nota-fiscal.serie       and 
                ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                ret-nf-eletro.cod-msg     = TrataNuloChar(int_dp_nota_saida_cancela.nsa_cstat_s) and 
                ret-nf-eletro.dat-ret     = int_dp_nota_saida_cancela.nsa_datacancelamento_d and
                ret-nf-eletro.cod-livre-2 = TrataNuloChar(int_dp_nota_saida_cancela.nsa_observacao_s) and
                ret-nf-eletro.log-ativo   = yes
                query-tuning(no-lookahead): end.
            if not avail ret-nf-eletro then do:
                create  ret-nf-eletro.
                assign  ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel
                        ret-nf-eletro.cod-serie   = nota-fiscal.serie
                        ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis
                        ret-nf-eletro.dat-ret     = int_dp_nota_saida_cancela.nsa_datacancelamento_d
                        ret-nf-eletro.cod-msg     = TrataNuloChar(int_dp_nota_saida_cancela.nsa_cstat_s).
            end.
            assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
                    ret-nf-eletro.cod-livre-2 = TrataNuloChar(int_dp_nota_saida_cancela.nsa_observacao_s)
                    ret-nf-eletro.log-ativo   = yes.
            &if "{&bf_dis_versao_ems}" >= "2.07" &then 
                ret-nf-eletro.cod-protoc  = int_dp_nota_saida_cancela.nsa_protocolo_s.
            &else
                ret-nf-eletro.cod-livre-1 = int_dp_nota_saida_cancela.nsa_protocolo_s.
            &endif

            release ret-nf-eletro.

            if nota-fiscal.dt-cancela = ? then do:
                assign  nota-fiscal.dt-cancela   = int_dp_nota_saida_cancela.nsa_datacancelamento_d
                        nota-fiscal.desc-cancela = TrataNuloChar(int_dp_nota_saida_cancela.nsa_observacao_s)
                        nota-fiscal.cod-protoc   = TrataNuloChar(int_dp_nota_saida_cancela.nsa_protocolo_s).
                for each it-nota-fisc of nota-fiscal
                    query-tuning(no-lookahead):
                    assign  it-nota-fisc.dt-cancela = nota-fiscal.dt-cancela
                            it-nota-fisc.dt-confirma = nota-fiscal.dt-confirma.
                end.
            end.
            for each doc-fiscal exclusive where 
                doc-fiscal.cod-estabel  = nota-fiscal.cod-estabel and
                doc-fiscal.serie        = nota-fiscal.serie and
                doc-fiscal.nr-doc-fis   = nota-fiscal.nr-nota-fis and
                doc-fiscal.cod-emitente = nota-fiscal.cod-emitente
                query-tuning(no-lookahead):
                assign  doc-fiscal.ind-sit-doc = 2 /* cancelado */.
            end.
            if nota-fiscal.idi-sit-nf-eletro <> 4 and /* cancelada */
               nota-fiscal.idi-sit-nf-eletro <> 7 /* inutilizada */ then do:
                assign  nota-fiscal.ind-sit-nota = 6 /* cancelada */.
                        nota-fiscal.idi-sit-nf-eletro = if nota-fiscal.idi-sit-nf-eletro = 3 then 6 /* cancelada */  else 7 /* inutilizada */.
            end.
            /* desatualizaá‰es compleentares*/
            run ftp/ft0911.p (rowid(nota-fiscal), 
                              TrataNuloChar(int_dp_nota_saida_cancela.nsa_cstat_s), 
                              TrataNuloChar(int_dp_nota_saida_cancela.nsa_protocolo_s)).
            run pi-atualizaNotaFiscAdc. /* Atualiza nota-fisc-adc (CD4035) */

            /* Verificar se nota de transferància, qual o destino */
            for each estabelec no-lock where estabelec.cod-emitente = nota-fiscal.cod-emitente,
                each cst_estabelec no-lock WHERE 
                     cst_estabelec.cod_estabel = estabelec.cod-estabel AND 
                     cst_estabelec.dt_fim_operacao <= nota-fiscal.dt-emis-nota
                query-tuning(no-lookahead): 
                /* Detino era Oblak na emissao */
                if cst_estabelec.dt_inicio_oper < nota-fiscal.dt-emis-nota then do:
                    run pi-cancela-saidas ("PROCFIT", /* p-origem */
                                           1,  /* p-sit-oblak-s   */
                                           2,  /* p-sit-procfit-s */
                                           1,  /* p-sit-oblak-e   */
                                           2   /* p-sit-procfit-e */).
                end.
                /* Detino j† era Procfit na emissao */
                else do:
                    run pi-cancela-saidas ("PROCFIT", /* p-origem */
                                           2,  /* p-sit-oblak-s   */
                                           2,  /* p-sit-procfit-s */
                                           2,  /* p-sit-oblak-e   */
                                           2   /* p-sit-procfit-e */).
                end.
            end.
    
            /*
            for first docum-est exclusive-lock where 
                docum-est.cod-emitente = nota-fiscal.cod-emitente   and
                docum-est.serie-docto  = nota-fiscal.serie          and
                docum-est.nro-docto    = nota-fiscal.nr-nota-fis    and
                docum-est.nat-operacao = nota-fiscal.nat-operacao
                query-tuning(no-lookahead):
                /* verificar se devoluá∆o atualizada no financeiro */
                l-aux = yes.
                for each cst-fat-devol of docum-est:
                    if cst-fat-devol.flag-atualiz then l-aux = no.
                end.
                /* apagar documento se n∆o atualizada 
                if l-aux then do:
                    for each item-doc-est of docum-est:
                        for each rat-lote of item-doc-est:
                            delete rat-lote.
                        end.
                        delete item-doc-est.
                    end.
                    for each consist-nota of docum-est:
                        delete consist-nota.
                    end.
                    delete docum-est.
                end.
                */
            end.
            */

            run pi-gera-log (input "Documento cancelado. " 
                             + "Est: "          + nota-fiscal.cod-estabel
                             + " SÇrie: "       + nota-fiscal.serie
                             + " Numero: "      + nota-fiscal.nr-nota-fis
                             + " Fornecedor: "  + string(nota-fiscal.cod-emitente),
                             input 2).

            for each bint_dp_nota_saida_cancela where
                bint_dp_nota_saida_cancela.nsa_cnpj_origem_s  = int_dp_nota_saida_cancela.nsa_cnpj_origem_s and
                bint_dp_nota_saida_cancela.nsa_serie_s        = int_dp_nota_saida_cancela.nsa_serie_s       and
                bint_dp_nota_saida_cancela.nsa_notafiscal_n   = int_dp_nota_saida_cancela.nsa_notafiscal_n
                query-tuning(no-lookahead):
                assign  bint_dp_nota_saida_cancela.situacao = 2 /* processada */.
                for each int_ds_pedido_subs exclusive-lock where 
                    int_ds_pedido_subs.ped_codigo_n = int64(nota-fiscal.nr-pedcli)
                    query-tuning(no-lookahead):
                    assign int_ds_pedido_subs.situacao = 3.
                end.
                for each int_ds_pedido exclusive-lock where 
                    int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli)
                    query-tuning(no-lookahead):
                    assign int_ds_pedido.situacao = 3.
                end.
            end.
        end.
        else do:
            run pi-gera-log (input "Nota fiscal n∆o cancelada. Verifique desatualizaá∆o do estoque das notas. " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida_cancela.nsa_serie_s 
                             + " Numero: "   + c-num-nota
                             + " Data NF: "  + string(nota-fiscal.dt-emis-nota,"99/99/9999"),
                             input 1).
            return.
        end.
    end.
    if not avail nota-fiscal then do:
        run pi-gera-log (input "Nota fiscal n∆o localizada ou n∆o integrada ainda. " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida_cancela.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Data Can: "  + string(int_dp_nota_saida_cancela.nsa_datacancelamento_d,"99/99/9999"),
                         input 1).
        return.
    end.

end procedure.

procedure pi-desatualiza-entrada:
    for first docum-est exclusive-lock where 
        docum-est.cod-emitente = nota-fiscal.cod-emitente   and
        docum-est.serie-docto  = nota-fiscal.serie          and
        docum-est.nro-docto    = nota-fiscal.nr-nota-fis    and
        docum-est.nat-operacao = nota-fiscal.nat-operacao
        query-tuning(no-lookahead):

        if nota-fiscal.ind-tip-nota = 8 then do:
            assign docum-est.idi-sit-nf-eletro = nota-fiscal.idi-sit-nf-eletro
                   docum-est.log-1 = NO.
        end.

        run rep/re0402a.p ( input  rowid(docum-est),
                            input  /*tt-param.l-of*/ no,
                            input  /*tt-param.l-saldo*/ yes,
                            input  /*tt-param.l-desatual*/ yes,
                            input  /*tt-param.l-custo-padrao*/ yes,
                            input  /*tt-param.l-desatualiza-ap*/ yes,
                            input  /*tt-param.i-prc-custo*/ 2,
                            input  /*tt-param.l-desatualiza-aca*/ yes,
                            input  /*tt-param.l-desatualiza-wms*/ no,
                            input  /*tt-param.l-desatualiza-draw*/ no,
                            input  /*tt-param.l-desatualiza-cr*/ yes,
                            output l-erro,
                            output table tt-erro).

        run pi-trata-nota-credito.

        if  not l-erro and 
            docum-est.CE-atual = no 
        then do:
            
            /* verificar se devoluá∆o atualizada no financeiro */
            l-aux = yes.
            for each cst_fat_devol WHERE
                     cst_fat_devol.cod_estabel  = docum-est.cod-estabel  AND
                     cst_fat_devol.serie_docto  = docum-est.serie-docto  AND
                     cst_fat_devol.nro_docto    = docum-est.nro-docto    AND
                     cst_fat_devol.cod_emitente = docum-est.cod-emitente AND 
                     cst_fat_devol.nat_operacao = docum-est.nat-operacao query-tuning(no-lookahead):
                if cst_fat_devol.flag_atualiz then l-aux = no.
            end.
            /* apagar documento se n∆o atualizada 
            if l-aux then do:
                for each item-doc-est of docum-est:
                    for each rat-lote of item-doc-est:
                        delete rat-lote.
                    end.
                    delete item-doc-est.
                end.
                for each consist-nota of docum-est:
                    delete consist-nota.
                end.
                delete docum-est.
            end.
            */
            return "OK".
        end. /*if not l-erro */
        else do:
            for each tt-erro
                query-tuning(no-lookahead):
                run pi-gera-log (input trim(tt-erro.mensagem)
                                 + "Est: "          + nota-fiscal.cod-estabel
                                 + " SÇrie: "       + nota-fiscal.serie
                                 + " Numero: "      + nota-fiscal.nr-nota-fis
                                 + " Fornecedor: "  + string(nota-fiscal.cod-emitente),
                                 input 1).
            end.
            return "NOK".
        end.
    end.
    if not avail docum-est then do:
        run pi-gera-log (input "Documento de estoque n∆o localizado. " 
                         + "Est: "       + nota-fiscal.cod-estabel
                         + " SÇrie: "    + nota-fiscal.serie
                         + " Numero: "   + nota-fiscal.nr-nota-fis
                         + " Cliente: "  + string(nota-fiscal.cod-emitente),
                         input 1).
        return "NOK".
    end.

end procedure.

procedure pi-desatualiza-transferencia:

    for first estabelec no-lock where 
        estabelec.cod-estabel = nota-fiscal.cod-estabel:
        for first docum-est exclusive-lock where 
            docum-est.cod-emitente = estabelec.cod-emitente     and
            docum-est.serie-docto  = nota-fiscal.serie          and
            docum-est.nro-docto    = nota-fiscal.nr-nota-fis
            query-tuning(no-lookahead):

            run rep/re0402a.p ( input  rowid(docum-est),
                                input  /*tt-param.l-of*/ no,
                                input  /*tt-param.l-saldo*/ yes,
                                input  /*tt-param.l-desatual*/ yes,
                                input  /*tt-param.l-custo-padrao*/ yes,
                                input  /*tt-param.l-desatualiza-ap*/ yes,
                                input  /*tt-param.i-prc-custo*/ 2,
                                input  /*tt-param.l-desatualiza-aca*/ yes,
                                input  /*tt-param.l-desatualiza-wms*/ no,
                                input  /*tt-param.l-desatualiza-draw*/ no,
                                input  /*tt-param.l-desatualiza-cr*/ yes,
                                output l-erro,
                                output table tt-erro).

            if  not l-erro and 
                docum-est.CE-atual = no 
            then do:
                return "OK".
            end. /*if not l-erro */
            else do:
                for each tt-erro
                    query-tuning(no-lookahead):
                    run pi-gera-log (input trim(tt-erro.mensagem)
                                     + "Est: "          + nota-fiscal.cod-estabel
                                     + " SÇrie: "       + nota-fiscal.serie
                                     + " Numero: "      + nota-fiscal.nr-nota-fis
                                     + " Fornecedor: "  + string(nota-fiscal.cod-emitente),
                                     input 1).
                end.
                return "NOK".
            end.
        end.
        if not avail docum-est then do:
            run pi-gera-log (input "Documento de estoque n∆o localizado. " 
                             + "Est: "       + nota-fiscal.cod-estabel
                             + " SÇrie: "    + nota-fiscal.serie
                             + " Numero: "   + nota-fiscal.nr-nota-fis
                             + " Cliente: "  + string(nota-fiscal.cod-emitente),
                             input 1).
            return "NOK".
        end.
    end.

end procedure.

procedure pi-desatualiza-saida. 

    empty temp-table tt-raw-digita.
    empty temp-table tt-param-FT2100.

    create  tt-param-FT2100.
    assign  tt-param-FT2100.usuario           = c-seg-usuario
            tt-param-FT2100.destino           = 2
            tt-param-FT2100.tipo-atual        = 2  /* 1 - Atualiza | 2 - Desatualiza*/
            tt-param-FT2100.c-desc-tipo-atual = ""
            tt-param-FT2100.da-emissao-ini    = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-emissao-fim    = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-saida          = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-vencto-ipi     = today 
            tt-param-FT2100.da-vencto-icms    = today 
            tt-param-FT2100.c-estabel-ini     = nota-fiscal.cod-estabel
            tt-param-FT2100.c-estabel-fim     = nota-fiscal.cod-estabel
            tt-param-FT2100.c-serie-ini       = nota-fiscal.serie
            tt-param-FT2100.c-serie-fim       = nota-fiscal.serie
            tt-param-FT2100.c-nr-nota-ini     = nota-fiscal.nr-nota-fis
            tt-param-FT2100.c-nr-nota-fim     = nota-fiscal.nr-nota-fis
            tt-param-FT2100.de-embarque-ini   = 0
            tt-param-FT2100.de-embarque-fim   = 99999999
            tt-param-FT2100.c-preparador      = ""
            tt-param-FT2100.arquivo           = nota-fiscal.cod-estabel +   
                                                nota-fiscal.serie       +   
                                                nota-fiscal.nr-nota-fis + "-ft2100-1.tmp"
            tt-param-FT2100.l-disp-men        = no.

    raw-transfer tt-param-FT2100 to raw-param.
    run ftp/ft2100rp.p (input raw-param,
                        input table tt-raw-digita).
    /*
    for first bnota-fiscal no-lock where
        rowid(bnota-fiscal) = rowid(nota-fiscal):
        if bnota-fiscal.dt-confirma <> ? then do:
            run pi-gera-log (input "Nota fiscal n∆o desatualizada FT2100. " 
                             + "Est: "          + nota-fiscal.cod-estabel
                             + " SÇrie: "       + nota-fiscal.serie
                             + " Numero: "      + nota-fiscal.nr-nota-fis,
                             input 1).
            return "NOK".
        end.
        else 
            return "OK".
    end.
    */

    empty temp-table tt-raw-digita.
    empty temp-table tt-param-FT2100.

    create  tt-param-FT2200.
    assign  tt-param-FT2200.destino           = 2
            tt-param-FT2200.arquivo           = nota-fiscal.cod-estabel +
                                                nota-fiscal.serie       +
                                                nota-fiscal.nr-nota-fis + "-ft2200.tmp"
            tt-param-FT2200.usuario           = c-seg-usuario
            tt-param-FT2200.data-exec         = today
            tt-param-FT2200.hora-exec         = time
            tt-param-FT2200.cod-estabel       = nota-fiscal.cod-estabel
            tt-param-FT2200.serie             = nota-fiscal.serie
            tt-param-FT2200.nr-nota-fis       = nota-fiscal.nr-nota-fis
            tt-param-FT2200.dt-cancela        = int_dp_nota_saida_cancela.nsa_datacancelamento_d
            tt-param-FT2200.desc-cancela      = TrataNuloChar(int_dp_nota_saida_cancela.nsa_observacao_s)
            tt-param-FT2200.arquivo-estoq     = nota-fiscal.cod-estabel +               
                                                nota-fiscal.serie       +               
                                                nota-fiscal.nr-nota-fis + "-ft2100-2.tmp" 
            tt-param-FT2200.reabre-resumo     = no
            tt-param-FT2200.cancela-titulos   = yes
            tt-param-FT2200.imprime-ajuda     = yes
            tt-param-FT2200.l-valida-dt-saida = no
            tt-param-FT2200.l-elinia-nfse     = no.

    raw-transfer tt-param-FT2200 to raw-param.
    run ftp/ft2200rp.p (input raw-param,
                        input table tt-raw-digita).

    for first bnota-fiscal no-lock where
        rowid(bnota-fiscal) = rowid(nota-fiscal)
        query-tuning(no-lookahead):
        if bnota-fiscal.dt-confirma <> ? then do:
            run pi-gera-log (input "Nota fiscal n∆o cancelada FT2200. " 
                             + "Est: "          + nota-fiscal.cod-estabel
                             + " SÇrie: "       + nota-fiscal.serie
                             + " Numero: "      + nota-fiscal.nr-nota-fis,
                             input 1).
            return "NOK".
        end.
        else 
            return "OK".
    end.

end procedure. 

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    IF tt-param.arquivo <> "" THEN DO:
        put unformatted
            int_dp_nota_saida_cancela.nsa_cnpj_origem_s + "/" + 
            trim(int_dp_nota_saida_cancela.nsa_serie_s) + "/" + 
            trim(string(int_dp_nota_saida_cancela.nsa_notafiscal_n)) + " - " + 
            c-informacao
            skip.
    END.

    RUN intprg/int999.p ("NF CANC", 
                         int_dp_nota_saida_cancela.nsa_cnpj_origem_s + "/" + 
                         trim(int_dp_nota_saida_cancela.nsa_serie_s) + "/" + 
                         trim(string(int_dp_nota_saida_cancela.nsa_notafiscal_n)),
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario,
                         "int237rp.p").
    if i-situacao = 1 then l-erro = yes.
end.

procedure pi-atualizaNotaFiscAdc :
    define variable h-bodi515 as handle     no-undo.
    
    /* Atualiza nota-fisc-adc (CD4035) */
    if  NOT VALID-HANDLE(h-bodi515) then
        run dibo/bodi515.p PERSISTENT SET h-bodi515.

    if  VALID-HANDLE(h-bodi515) then do:
        run cancelaNotaFiscAdc IN h-bodi515 (INPUT nota-fiscal.cod-estabel,
                                             INPUT nota-fiscal.serie,
                                             INPUT nota-fiscal.nr-nota-fis,
                                             INPUT nota-fiscal.cod-emitente,
                                             INPUT nota-fiscal.nat-operacao,
                                             INPUT &if "{&bf_dis_versao_ems}":U >= "2.07":U &then
                                                        nota-fiscal.idi-sit-nf-eletro
                                                   &else
                                                        sit-nf-eletro.idi-sit-nf-eletro
                                                   &endif).
        DELETE PROCEDURE h-bodi515.
    end.

    assign h-bodi515 = ?.
    /* Fim - Atualiza nota-fisc-adc (CD4035) */

    RETURN "OK".
end PROCEDURE.

procedure pi-trata-nota-credito:
    if  docum-est.esp-docto = 20 then do: /*Devolucao*/

        /*

        PUT "trata-nota-credito "
            docum-est.serie-docto  " "
            docum-est.nro-docto    " "
            docum-est.cod-emitente " "
            docum-est.nat-operacao " "
            SKIP.
        */    


        empty temp-table tt_cancelamento_estorno_apb_1.
        empty temp-table tt_estornar_agrupados.
        empty temp-table tt_log_erros_atualiz.
        empty temp-table tt_log_erros_estorn_cancel_apb.
        empty temp-table tt_estorna_tit_imptos.

        FOR FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = docum-est.nat-operacao
              AND natur-oper.tipo         = 2
            query-tuning(no-lookahead): /*Saida*/

            /*Item Devolucao*/
            for each item-doc-est exclusive-lock {cdp/cd8900.i item-doc-est docum-est}
                query-tuning(no-lookahead):

                /*Item Fatura ou Item Remito*/
                for each bitem-doc-est NO-LOCK
                   WHERE bitem-doc-est.cod-emitente = item-doc-est.cod-emitente
                     AND bitem-doc-est.serie-docto  = item-doc-est.serie-comp
                     AND bitem-doc-est.nro-docto    = item-doc-est.nro-comp
                     AND bitem-doc-est.nat-operacao = item-doc-est.nat-comp
                     AND bitem-doc-est.it-codigo    = item-doc-est.it-codigo
                     AND bitem-doc-est.sequencia    = item-doc-est.seq-comp,
                   FIRST bdocum-est of bitem-doc-est NO-LOCK
                    query-tuning(no-lookahead):

                    if  NOT bdocum-est.nff then do:

                        /*Item Fatura*/
                        FOR FIRST b2-item-doc-est NO-LOCK
                            WHERE b2-item-doc-est.cod-emitente = bitem-doc-est.cod-emitente
                              AND b2-item-doc-est.serie-comp   = bitem-doc-est.serie-docto
                              AND b2-item-doc-est.nro-comp     = bitem-doc-est.nro-docto
                              AND b2-item-doc-est.nat-comp     = bitem-doc-est.nat-operacao
                              AND b2-item-doc-est.it-codigo    = bitem-doc-est.it-codigo
                              AND b2-item-doc-est.seq-comp     = bitem-doc-est.sequencia
                            query-tuning(no-lookahead):

                            CREATE tt-item-doc-est-fat.
                            BUFFER-COPY b2-item-doc-est TO tt-item-doc-est-fat.
                        end.
                    end.
                    else do:
                        CREATE tt-item-doc-est-fat.
                        BUFFER-COPY bitem-doc-est TO tt-item-doc-est-fat.
                    end.
                end.

                /*Itens da Fatura*/
                for each tt-item-doc-est-fat
                    query-tuning(no-lookahead):
                    FIND FIRST bdocum-est of tt-item-doc-est-fat NO-LOCK NO-ERROR.
                    /*Se gerou nota de credito*/
                    if  &if "{&bf_mat_versao_ems}":U >= "2.071":U &then
                            item-doc-est.log-gerou-ncredito
                        &else
                            substring(item-doc-est.char-2,449,1) = "1"
                        &endif then do:


                        /*Cria tt estorno*/
                        if  NOT CAN-FIND(FIRST tt_cancelamento_estorno_apb_1
                                         WHERE tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = bdocum-est.cod-estabel
                                           AND tt_cancelamento_estorno_apb_1.tta_cod_espec_docto    = natur-oper.cod-esp
                                           AND tt_cancelamento_estorno_apb_1.tta_cod_ser_docto      = tt-item-doc-est-fat.serie-docto
                                           AND tt_cancelamento_estorno_apb_1.tta_cod_tit_ap         = tt-item-doc-est-fat.nro-docto
                                           AND tt_cancelamento_estorno_apb_1.tta_cdn_fornecedor     = tt-item-doc-est-fat.cod-emitente
                                           AND tt_cancelamento_estorno_apb_1.tta_cod_parcela        = &if "{&bf_mat_versao_ems}":U >= "2.071":U &then
                                                                                                          item-doc-est.cod-parc-devol
                                                                                                      &else
                                                                                                          substring(item-doc-est.char-2,450,2)
                                                                                                      &endif) then do:

                            CREATE tt_cancelamento_estorno_apb_1.
                            assign tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = bdocum-est.cod-estabel
                                   tt_cancelamento_estorno_apb_1.tta_cod_espec_docto    = natur-oper.cod-esp
                                   tt_cancelamento_estorno_apb_1.tta_cod_ser_docto      = tt-item-doc-est-fat.serie-docto
                                   tt_cancelamento_estorno_apb_1.tta_cod_tit_ap         = tt-item-doc-est-fat.nro-docto
                                   tt_cancelamento_estorno_apb_1.tta_cdn_fornecedor     = tt-item-doc-est-fat.cod-emitente
                                   tt_cancelamento_estorno_apb_1.ttv_ind_niv_operac_apb = "Titulo" 
                                   tt_cancelamento_estorno_apb_1.ttv_ind_tip_operac_apb = "Cancelamento"
                                   tt_cancelamento_estorno_apb_1.ttv_ind_tip_estorn     = "Total"
                                   tt_cancelamento_estorno_apb_1.ttv_log_reaber_item    = NO
                                   tt_cancelamento_estorno_apb_1.ttv_log_reembol        = NO
                                   tt_cancelamento_estorno_apb_1.ttv_rec_tit_ap         = 0
                                   tt_cancelamento_estorno_apb_1.tta_cod_parcela        = &if "{&bf_mat_versao_ems}":U >= "2.071":U &then
                                                                                              item-doc-est.cod-parc-devol.
                                                                                          &else
                                                                                              substring(item-doc-est.char-2,450,2).
                                                                                          &endif
                        end.
                    end.
                end.
            end.

            /*integraá∆o com o EMS 5*/
            if  CAN-FIND(FIRST tt_cancelamento_estorno_apb_1) then do:

                run prgfin/apb/apb768zd.py (INPUT 1,
                                            INPUT "REP",
                                            INPUT "",
                                            INPUT TABLE tt_cancelamento_estorno_apb_1,
                                            INPUT TABLE tt_estornar_agrupados,
                                            OUTPUT TABLE tt_log_erros_atualiz,
                                            OUTPUT TABLE tt_log_erros_estorn_cancel_apb,
                                            OUTPUT TABLE tt_estorna_tit_imptos,
                                            OUTPUT l-erro).

                /*Tratamento de erro*/
                FIND FIRST tt_log_erros_atualiz           NO-ERROR.
                FIND FIRST tt_log_erros_estorn_cancel_apb NO-ERROR.

                if  avail tt_log_erros_atualiz OR
                    avail tt_log_erros_estorn_cancel_apb then do:

                    /* Criacao dos erros do documento */
                    for each tt_log_erros_atualiz
                        query-tuning(no-lookahead):
                        CREATE tt-erro.
                        assign tt-erro.cd-erro  = tt_log_erros_atualiz.ttv_num_mensagem
                               tt-erro.mensagem = tt_log_erros_atualiz.ttv_des_msg_erro.
                    end.

                    for each tt_log_erros_estorn_cancel_apb
                        query-tuning(no-lookahead):
                        CREATE tt-erro.
                        assign tt-erro.cd-erro  = tt_log_erros_estorn_cancel_apb.tta_num_mensagem
                               tt-erro.mensagem = tt_log_erros_estorn_cancel_apb.ttv_des_msg_erro.
                        display tt_log_erros_estorn_cancel_apb.tta_num_mensagem
                                tt_log_erros_estorn_cancel_apb.ttv_des_msg_erro
                            WITH WIDTH 300 STREAM-IO.
                    end.
                end.
            end.
        end. /* natur-oper */
    end. /* devolucao */
end.

{intprg/int011rp-proc.i} /* pi-saidas */


