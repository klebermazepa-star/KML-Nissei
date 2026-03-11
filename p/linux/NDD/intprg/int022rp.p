/********************************************************************************
** Programa: int022 - Retorno de Notas Fiscais NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/
/* KIND 
0 Œ Envio;
1 Œ Cancelamento;
2 Œ Inutilizaá∆o;
3 Œ Impress∆o;
4 Œ DPEC;
5 Œ Erros;
6 Œ Substituiá∆o;
7 Œ Evento;
8 Œ procEvento;
9 Œ Rejeiá∆o ADe;
10 Œ EPEC.
11 Œ Retorno auditoria Vaccine;
12 Œ Retorno da consulta de documentos MDF-e n∆o encerrados.
*/

/* include de controle de versao */
{include/i-prgvrs.i int022rp 2.12.03.AVB}
{cdp/cdcfgdis.i}

/* definiÁao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
        field raw-digita	as raw.

define temp-table tt-param-re1005
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

define temp-table tt-digita-re1005
    field r-docum-est        as rowid.

DEFINE TEMP-TABLE tt-param-ft2100
    FIELD destino           AS intEGER  
    FIELD arquivo           AS CHAR
    FIELD usuario           AS CHAR
    FIELD data-exec         AS date
    FIELD hora-exec         AS intEGER
    FIELD tipo-atual        AS intEGER   /* 1 - Atualiza, 2 - Desatualiza */
    FIELD c-desc-tipo-atual AS CHAR format "x(15)"
    FIELD da-emissao-ini    AS date format "99/99/9999"
    FIELD da-emissao-fim    AS date format "99/99/9999"
    FIELD da-saida          AS date format "99/99/9999"
    FIELD da-vencto-ipi     AS date format "99/99/9999"
    FIELD da-vencto-icms    AS date format "99/99/9999"
    FIELD da-vencto-iss     AS date format "99/99/9999"
    FIELD c-estabel-ini     AS CHAR
    FIELD c-estabel-fim     AS CHAR
    FIELD c-serie-ini       AS CHAR
    FIELD c-serie-fim       AS CHAR
    FIELD c-nr-nota-ini     AS CHAR
    FIELD c-nr-nota-fim     AS CHAR
    FIELD de-embarque-ini   AS DEC
    FIELD de-embarque-fim   AS DEC
    FIELD c-preparador      AS CHAR
    FIELD l-disp-men        AS LOG
    FIELD l-b2b             AS LOG
    FIELD log-1             AS LOG.


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
    

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
if tt-param.arquivo = "" then 
assign tt-param.arquivo = "int022.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

/* include padrao para vari·veis de relatÛrio  */
{include/i-rpvar.i}


/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def var h-acomp         as handle no-undo.
def var r-rowid         as rowid no-undo.
def var h-bodi135       as handle no-undo.
def var h-boin090       as handle no-undo.
def var cRetorno        as longchar no-undo.
def var c-mensagem      as char format "X(50)" no-undo.
def var c-informacao    as char format "X(100)" no-undo.
def var h-boad107na     as handle no-undo.
def var h-bodi135na-sitnfe as handle no-undo.
def var i-sit-nfe-aux   as int no-undo.
def var c-sit-nfe-aux   as char format "x(50)" no-undo.
def var l-erro          as logical no-undo.
def var l-ok            as logical no-undo.
def var l-emite-danfe-estab as logical no-undo.

define buffer b-docum-est for docum-est.
define buffer b-item-doc-est  for item-doc-est.
define buffer b2-item-doc-est for item-doc-est.
define buffer b-nota-fiscal for nota-fiscal.

define temp-table tt-retorno-emissao
    field idMovto   as int64
    field infProt   as char
    field tpAmb     as char
    field verAplic  as char
    field chNFe     as char
    field dhRecbto  as char
    field nProt     as char
    field digVal    as char
    field cStat     as char
    field xMotivo   as char
    field tpEmis    as char
    field chNFe2    as char
    index chave idMovto.

define temp-table tt-retorno-cancelamento
    field idMovto   as int64
    field Id        as char 
    field cStat     as char 
    field xMotivo   as char 
    field chNFe     as char 
    field dhRecbto  as char 
    field nProt     as char 
    field chNFe2    as char 
    index chave idMovto.

define temp-table tt-retorno-inutilizacao
    field idMovto   as int64
    field Id        as char  
    field tpAmb     as char  
    field verAplic  as char  
    field cStat     as char  
    field xMotivo   as char  
    field cUF       as char  
    field ano       as char  
    field CNPJ      as char  
    field modelo    as char  
    field serie     as char  
    field nNFIni    as char  
    field nNFFin    as char  
    field dhRecbto  as char   
    field nProt     as char   
    index chave idMovto.

define temp-table tt-retorno-impressao
    field idMovto    as int64
    field chave      as char
    field statusnum  as char /* 1 -Imp / 2 Nao Imp */
    field statusDesc as char /* Impresso / Nao Impresso*/
    field tpImp      as char
    field tpImpDesc  as char
    field tpOp       as char
    field tpOpDesc   as char
    index chave idMovto.

DEFINE TEMP-TABLE ttReturnInvoicedocument NO-UNdo
    FIELD chNFe     AS CHARACTER INITIAL ?  /* Chaves de acesso da NF-e, compostas por: UF do emitente, AAMM da emiss∆o da NFe, CNPJ do emitente, modelo, sÇrie e n£mero da NF-e e c¢digo numÇrico+DV. */
    FIELD cStat     AS CHARACTER INITIAL ?  /* C¢digo do status da mensagem enviada. */
    FIELD dhRecbto  AS CHARACTER INITIAL ?  /* Data e hora de processamento, no formato AAAA-MM-DDTHH:MM:SS. Deve ser preenchida com data e hora da gravaá∆o no Banco em caso de Confirmaá∆o. Em caso de Rejeiá∆o, com data e hora do recebimento do Lote de NF-e enviado. */
    FIELD digVal    AS CHARACTER INITIAL ?  /* Digest Value da NF-e processada. Utilizado para conferir a integridade da NF-e original. */
    FIELD id        AS CHARACTER INITIAL ?  
    FIELD nProt     AS CHARACTER            /* N£mero do Protocolo de Status da NF-e. 1 posiá∆o (1 Œ Secretaria de Fazenda Estadual 2 Œ Receita Federal); 2 - c¢diga da UF - 2 posiá‰es ano; 10 seqÅencial no ano. */
    FIELD Signature AS CHARACTER INITIAL ?  
    FIELD tpAmb     AS CHARACTER INITIAL ?  /* Identificaá∆o do Ambiente: 1 - Produá∆o 2 - Homologaá∆o */
    FIELD verAplic  AS CHARACTER INITIAL ?  /* Vers∆o do Aplicativo que processou a NF-e */
    FIELD versao    AS DECIMAL   INITIAL ?  /* Vers∆o do Layout */
    FIELD xMotivo   AS CHARACTER INITIAL ?  /* Descriá∆o literal do status do serviáo solicitado. */
    FIELD tpEmis    AS CHARACTER INITIAL ?  /* Tipo Emissao:  1- Normal, 2- Contingencia SCAN, 3- Contingencia off-line */
    FIELD lDanfe    AS LOGICAL.             /* NO - "Danfe N∆o Impresso na Aplicaá∆o de Transmiss∆o" e YES - "Danfe Impresso na Aplicaá∆o de Transmiss∆o" */


define temp-table tt-retorno-substituicao
    field idMovto    as int64
    field chaveAtual as char
    field chaveNova  as char
    index chave idMovto.


define temp-table tt-retorno-erro
    field idMovto    as int64
    field chNFe      as char
    field tipo       as char
    field xMotivo    as char
    index chave idMovto.

def var i-ind as integer no-undo.

{utp/ut-glob.i}
{cdp/cd0666.i}

/* definiÁao de frames do relatÛrio */
form c-mensagem       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a definiÁao da frame de cabeÁalho e rodapÈ */
{include/i-rpcab.i}
/* bloco principal do programa */

find first tt-param no-lock no-error.
assign c-programa       = "int022rp"
       c-versao         = "2.12"
       c-revisao        = ".03.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Retorno de Notas Fiscais NDD".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

/* chamada integraá∆o WebServices NDD */
RUN intprg/int022a.p.

if not valid-handle(h-boin090) then run inbo/boin090.p persistent set h-boin090.
if not valid-handle(h-bodi135) then run dibo/bodi135.p persistent set h-bodi135.
if not valid-handle(h-bodi135na-sitnfe) then run dibo/bodi135na.p persistent set h-bodi135na-sitnfe.

if not valid-handle(h-boad107na) then do:
    run adbo/boad107na.p persistent set h-boad107na.
    run openQueryStatic in h-boad107na(input 'Main':U).
end.

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i}
                     
    view frame f-cabec.
    view frame f-rodape.
end.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").

run pi-elimina-tabelas.
run pi-importa.
run pi-processa.
run pi-elimina-tabelas.
run pi-finaliza-bos.

run pi-finalizar in h-acomp.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
end.
/* elimina BO's */
return "OK".

/* procedures */
procedure pi-elimina-tabelas:
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   /*empty temp-table RowErrors.   */
   empty temp-table tt-retorno-emissao.
   empty temp-table tt-retorno-cancelamento.
   empty temp-table tt-retorno-inutilizacao.
   empty temp-table tt-retorno-impressao.
   empty temp-table tt_cancelamento_estorno_apb_1.
   empty temp-table tt_estornar_agrupados.
   empty temp-table tt_log_erros_atualiz.
   empty temp-table tt_log_erros_estorn_cancel_apb.
   empty temp-table tt_estorna_tit_imptos.
   empty temp-table tt-erro.
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Retornos").

    for each int_ndd_retorno no-lock where 
        int_ndd_retorno.STATUSNUMBER = 0 /* A PROCESAR */ and
        int_ndd_retorno.kind <= 10 AND
        int_ndd_retorno.kind <> 4 and
        int_ndd_retorno.kind <> 9 and
        int_ndd_retorno.kind <> 8 and
        int_ndd_retorno.kind <> 7
        query-tuning(no-lookahead)
        by int_ndd_retorno.id:

        copy-lob int_ndd_retorno.documentdata to cRetorno.
        run pi-acompanhar in h-acomp (input "Retorno: " + trim(string(int_ndd_retorno.ID))).
        /*
        PUT int_ndd_retorno.ID " "
            int_ndd_retorno.KIND
            SKIP.
            */


        /*
        PUT UNFORMATTED
            int_ndd_retorno.id " " 
            int_ndd_retorno.kind " " 
            string(cRetorno)
            SKIP.
        */

        if cRetorno MATCHES "*xmlns=*" and
           cRetorno MATCHES "*www.portalfiscal.inf.br*" then do:
            PUT "RETORNO INCORRETO EM XML - SOLICITAR NDD ENVIO EM formatO TEXTO!!!!!" SKIP.
            run pi-marca-processado (int_ndd_retorno.ID).
            NEXT.
        end.
        IF (int_ndd_retorno.KIND = 0 AND entry(9,cRetorno,";") MATCHES "*MDF-e*") OR
           (int_ndd_retorno.KIND = 1 AND entry(3,cRetorno,";") MATCHES "*MDF-e*") OR
           (int_ndd_retorno.KIND = 2 AND entry(5,cRetorno,";") MATCHES "*MDF-e*") OR
           (int_ndd_retorno.KIND = 10 AND entry(5,cRetorno,";") MATCHES "*MDF-e*")
        THEN DO:
            run pi-marca-processado (int_ndd_retorno.ID).
            NEXT.
        END.

        case int_ndd_retorno.KIND:
            when 0 /* Envio */ then do:

                create  tt-retorno-emissao.
                assign  tt-retorno-emissao.idMovto   = int_ndd_retorno.ID.
                assign  tt-retorno-emissao.infProt   = entry(1,cRetorno,";") 
                        tt-retorno-emissao.tpAmb     = entry(2,cRetorno,";") 
                        tt-retorno-emissao.verAplic  = entry(3,cRetorno,";") 
                        tt-retorno-emissao.chNFe     = entry(4,cRetorno,";") 
                        tt-retorno-emissao.dhRecbto  = substring(entry(5,cRetorno,";"),1,19) 
                        tt-retorno-emissao.nProt     = entry(6,cRetorno,";") 
                        tt-retorno-emissao.digVal    = entry(7,cRetorno,";") 
                        tt-retorno-emissao.cStat     = entry(8,cRetorno,";") 
                        tt-retorno-emissao.xMotivo   = entry(9,cRetorno,";") 
                        tt-retorno-emissao.tpEmis    = entry(10,cRetorno,";")
                        tt-retorno-emissao.chNFe2    = entry(11,cRetorno,";").
                
            end.
            when 10 /* Envio EPEC */ then do:
                create  tt-retorno-emissao.
                assign  tt-retorno-emissao.idMovto   = int_ndd_retorno.ID.
                assign  tt-retorno-emissao.infProt   = entry(1,cRetorno,";") 
                        tt-retorno-emissao.tpAmb     = entry(2,cRetorno,";") 
                        tt-retorno-emissao.verAplic  = entry(3,cRetorno,";") 
                        tt-retorno-emissao.chNFe     = entry(6,cRetorno,";") 
                        tt-retorno-emissao.dhRecbto  = substring(entry(7,cRetorno,";"),1,19) 
                        tt-retorno-emissao.nProt     = entry(8,cRetorno,";") 
                        tt-retorno-emissao.digVal    = ""
                        tt-retorno-emissao.cStat     = entry(4,cRetorno,";") 
                        tt-retorno-emissao.xMotivo   = entry(5,cRetorno,";") 
                        tt-retorno-emissao.tpEmis    = ""
                        tt-retorno-emissao.chNFe2    = entry(9,cRetorno,";").
                
            end.
            when 1 /* Cancelamento */ then do:
                create  tt-retorno-cancelamento.
                assign  tt-retorno-cancelamento.idMovto   = int_ndd_retorno.ID.
                assign  tt-retorno-cancelamento.Id        = entry(1,cRetorno,";") 
                        tt-retorno-cancelamento.cStat     = entry(2,cRetorno,";") 
                        tt-retorno-cancelamento.xMotivo   = entry(3,cRetorno,";") 
                        tt-retorno-cancelamento.chNFe     = entry(4,cRetorno,";")
                        tt-retorno-cancelamento.dhRecbto  = substring(entry(5,cRetorno,";"),1,19)
                        tt-retorno-cancelamento.nProt     = entry(6,cRetorno,";") 
                        tt-retorno-cancelamento.chNFe2    = entry(7,cRetorno,";").
            end.
            when 2 /* Inutilizacao */ then do:
                create  tt-retorno-inutilizacao.
                assign  tt-retorno-inutilizacao.idMovto   = int_ndd_retorno.ID.
                assign  tt-retorno-inutilizacao.Id        = replace(entry(1,cRetorno,";"),"ID","")
                        tt-retorno-inutilizacao.tpAmb     = entry(2,cRetorno,";")  
                        tt-retorno-inutilizacao.verAplic  = entry(3,cRetorno,";")  
                        tt-retorno-inutilizacao.cStat     = entry(4,cRetorno,";")  
                        tt-retorno-inutilizacao.xMotivo   = entry(5,cRetorno,";")  
                        tt-retorno-inutilizacao.cUF       = entry(6,cRetorno,";")  
                        tt-retorno-inutilizacao.ano       = entry(7,cRetorno,";")  
                        tt-retorno-inutilizacao.CNPJ      = entry(8,cRetorno,";")  
                        tt-retorno-inutilizacao.modelo    = entry(9,cRetorno,";")  
                        tt-retorno-inutilizacao.serie     = entry(10,cRetorno,";")  
                        tt-retorno-inutilizacao.nNFIni    = trim(string(dec(entry(11,cRetorno,";")),">>>>>>>9999999"))
                        tt-retorno-inutilizacao.nNFFin    = trim(string(dec(entry(12,cRetorno,";")),">>>>>>>9999999"))
                        tt-retorno-inutilizacao.dhRecbto  = substring(entry(13,cRetorno,";"),1,19)
                        tt-retorno-inutilizacao.nProt     = entry(14,cRetorno,";").
            end.
            when 3 /* Impressao */ then do:
                /*run pi-marca-processado (int_ndd_retorno.ID).*/
                
                create  tt-retorno-impressao.
                assign  tt-retorno-impressao.idMovto    = int_ndd_retorno.ID.
                assign  tt-retorno-impressao.chave      = entry(1,cRetorno,";")
                        tt-retorno-impressao.statusnum  = entry(2,cRetorno,";") 
                        tt-retorno-impressao.statusDesc = entry(3,cRetorno,";") 
                        /*
                        tt-retorno-impressao.tpImp      = entry(4,cRetorno,";")
                        tt-retorno-impressao.tpImpDesc  = entry(5,cRetorno,";")
                        tt-retorno-impressao.tpOp       = entry(6,cRetorno,";")
                        tt-retorno-impressao.tpOpDesc   = entry(7,cRetorno,";")
                        */.
                        
            end.
            when 5 /* erro estrutura NDD */ then do:
                create  tt-retorno-erro.
                assign  tt-retorno-erro.idMovto     = int_ndd_retorno.ID
                        tt-retorno-erro.chNfe       = trim(entry(1,cRetorno,"|") )
                        tt-retorno-erro.tipo        = trim(entry(2,cRetorno,"|"))
                        tt-retorno-erro.xMotivo     = trim(replace(replace(entry(6,cRetorno,"|"),chr(13),""),chr(10),"")).
            end.

            when 6 /* substituicao */ then do:
                create  tt-retorno-substituicao.
                assign  tt-retorno-substituicao.idMovto     = int_ndd_retorno.ID
                        tt-retorno-substituicao.chaveAtual  = entry(1,cRetorno,";") 
                        tt-retorno-substituicao.chaveNova   = entry(2,cRetorno,";").
            end.
        end.

    end.
    /*PUT "importa OK" SKIP.*/

end.

procedure pi-processa:

    for-retorno-emissao:
    for each tt-retorno-emissao
        query-tuning(no-lookahead):

        /*
        IF trim(string(tt-retorno-emissao.ChNfe)) BEGINS "411811794306820255405501000061628216" THEN
           NEXT.
        IF tt-retorno-emissao.chNFe <> "41181179430682025540550100006162841813082230" THEN NEXT.
        IF tt-retorno-emissao.idMovto = 1916368 THEN NEXT.
        IF tt-retorno-emissao.idMovto = 1916369 THEN NEXT.
        IF tt-retorno-emissao.idMovto = 1916370 THEN NEXT.
        */

        run pi-acompanhar in h-acomp (input "Emissao: " + trim(string(tt-retorno-emissao.ChNfe))).
        if tt-param.arquivo <> "" then do:
            display "Emissao" format "X(12)"
                    tt-retorno-emissao.idMovto  
                    tt-retorno-emissao.infProt  format "X(20)"
                    tt-retorno-emissao.tpAmb    
                    tt-retorno-emissao.chNFe    format "X(44)"
                    tt-retorno-emissao.dhRecbto format "X(12)"
                    tt-retorno-emissao.nProt    format "X(20)"
                    tt-retorno-emissao.cStat    
                    tt-retorno-emissao.xMotivo  format "X(60)"
                    tt-retorno-emissao.chNFe2   
                    WITH WIDTH 300 STREAM-IO doWN.
        end.

        assign l-ok = no.
        /*PUT "estabelec" SKIP.*/
        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-emissao.chNFe,7,14))
            query-tuning(no-lookahead):
              
            /*PUT "nota" SKIP.*/
            for each nota-fiscal NO-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-emissao.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-emissao.chNFe,26,9))),">>>>>>>9999999"))
                query-tuning(no-lookahead):

                if  dec(nota-fiscal.cod-prot) = 0 or (
                    dec(tt-retorno-emissao.nProt) <> 0 and 
                    dec(nota-fiscal.cod-prot) <> 0 and 
                    nota-fiscal.idi-sit-nf-eletro <> 3)
                    then do:
                    /*PUT "exclusive" SKIP.*/
                    find b-nota-fiscal exclusive-lock where 
                        rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                    if avail b-nota-fiscal then do:
                        /*PUT "avail" SKIP.*/
                        run pi-trata-ret-nfe (
                            input tt-retorno-emissao.idMovto ,
                            input tt-retorno-emissao.Id      ,
                            input tt-retorno-emissao.chNFe   ,
                            input tt-retorno-emissao.cStat   ,
                            input tt-retorno-emissao.nProt   ,
                            input tt-retorno-emissao.tpEmis  ,
                            input tt-retorno-emissao.tpAmb   , 
                            input tt-retorno-emissao.verAplic,
                            input tt-retorno-emissao.dhRecbto,
                            input tt-retorno-emissao.digVal  ,
                            input tt-retorno-emissao.xMotivo).
                        if tt-retorno-emissao.nProt <> "" then do: 
                                assign b-nota-fiscal.cod-protoc = tt-retorno-emissao.nProt.
                                /*PUT "marcando terminado" SKIP.*/
                                run intprg/int999.p ("RETNFNDD", 
                                                     tt-retorno-emissao.chNFe,
                                                     "Retorno nota fiscal NDD " + tt-retorno-emissao.chNFe + " realizado com sucesso!",
                                                     2, /* 1 - Pendente, 2 - Processado */ 
                                                     c-seg-usuario,
                                                     "int022rp.p").
                        end.
                        /*PUT "Release" SKIP.*/
                        run pi-marca-processado (tt-retorno-emissao.IdMovto).
                        assign l-ok = yes.
                        release b-nota-fiscal.
                    end.
                end.
                else do:
                    assign l-ok = yes.
                    run pi-marca-processado (tt-retorno-emissao.IdMovto).
                end.
            end.
        end. /* estabelec */
        if not l-ok then do:
            display tt-retorno-emissao.chNFe format "x(44)" " -> Nota Fiscal nao encontrada ou em uso!".
            run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-emissao.chNFe,
                                 "Nota Fiscal " + tt-retorno-emissao.chNFe + " n∆o encontrada ou em uso!",
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
        end.
        delete tt-retorno-emissao.
    end. /* tt-retorno-emissao */

    for each tt-retorno-cancelamento
        query-tuning(no-lookahead):

        run pi-acompanhar in h-acomp (input "Cancelamento: " + trim(string(tt-retorno-cancelamento.chNFe))).
        if tt-param.arquivo <> "" then do:
            display "Cancelamento" format "X(12)"
                    tt-retorno-cancelamento.idMovto  
                    tt-retorno-cancelamento.id  
                    tt-retorno-cancelamento.chNFe    format "X(44)"
                    tt-retorno-cancelamento.nProt    format "X(20)"
                    tt-retorno-cancelamento.cStat    
                    tt-retorno-cancelamento.xMotivo  format "X(60)"
                    tt-retorno-cancelamento.chNFe2   
                    WITH WIDTH 300 STREAM-IO doWN.
        end.
        l-ok = no.
        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-cancelamento.chNFe,7,14))
            query-tuning(no-lookahead):
            for each nota-fiscal NO-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-cancelamento.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-cancelamento.chNFe,26,9))),">>>>>>>9999999"))
                query-tuning(no-lookahead):

                find b-nota-fiscal exclusive-lock where 
                    rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                if avail b-nota-fiscal then do:
                    /* marcar nota em processo de canelamento para notas canceladas na NDD */
                    if nota-fiscal.idi-sit-nf-eletro <> 12 then assign b-nota-fiscal.idi-sit-nf-eletro = 12.
                    run pi-trata-ret-nfe (
                        input tt-retorno-cancelamento.idMovto ,
                        input tt-retorno-cancelamento.Id      ,
                        input tt-retorno-cancelamento.chNFe   ,
                        input tt-retorno-cancelamento.cStat   ,
                        input tt-retorno-cancelamento.nProt   ,
                        input ""                              ,
                        input ""                              , 
                        input ""                              ,
                        input tt-retorno-cancelamento.dhRecbto,
                        input ""                              ,
                        input tt-retorno-cancelamento.xMotivo).
        
                    if  tt-retorno-cancelamento.cStat = "101" or
                        tt-retorno-cancelamento.cStat = "135" or
                        tt-retorno-cancelamento.cStat = "151" or
                        tt-retorno-cancelamento.cStat = "155" 
                    then do:
                        if not l-erro then do:
    
                             assign b-nota-fiscal.dt-confirma  = ?.
                             if nota-fiscal.idi-sit-nf-eletro <> 6 then assign b-nota-fiscal.idi-sit-nf-eletro = 6.
                             assign b-nota-fiscal.dt-cancela   = /*TODAY*/ date(int(entry(2,tt-retorno-cancelamento.dhRecbto,'-')),
                                                                              int(substring(entry(3,tt-retorno-cancelamento.dhRecbto,'-'),1,2)),
                                                                              int(entry(1,tt-retorno-cancelamento.dhRecbto,'-')))
                                    b-nota-fiscal.ind-sit-nota = 4
                                    b-nota-fiscal.cod-protoc   = tt-retorno-cancelamento.nProt.
        
                             for each it-nota-fisc of nota-fiscal
                                 query-tuning(no-lookahead):
                                 assign it-nota-fisc.dt-cancela  = nota-fiscal.dt-cancela
                                        it-nota-fisc.dt-confirma = nota-fiscal.dt-confirma.
                             end.
        
                             run pi-altera-docum-est.
                             run intprg/int999.p ("RETNFNDD", 
                                      tt-retorno-cancelamento.chNFe,
                                      "Cancelamento nota fiscal NDD " + tt-retorno-cancelamento.chNFe + " realizado com sucesso!",
                                      2, /* 1 - Pendente, 2 - Processado */ 
                                      c-seg-usuario,
                                      "int022rp.p").
                             run pi-marca-processado (tt-retorno-cancelamento.idMovto).
                        end.
                        else do:
                            run intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-cancelamento.chNFe,
                                     "Cancelamento - Nota fiscal n∆o desatualizada do estoque: " + tt-retorno-cancelamento.chNFe,
                                     1, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario,
                                     "int022rp.p").
                        end.
                    end.
                    else do:
                        run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-cancelamento.chNFe,
                                 "Cancelamento nota fiscal NDD " + tt-retorno-cancelamento.chNFe + " n∆o realizado. Cod: " +  tt-retorno-cancelamento.cStat + " - Motivo: " + tt-retorno-cancelamento.xMotivo,
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
                        run pi-marca-processado (tt-retorno-cancelamento.idMovto).
                    end.
                    l-ok = yes.
                    release b-nota-fiscal.
                end.
            end.
        end.
        if not l-ok then do:
            display tt-retorno-cancelamento.chNFe format "X(44)" " -> Nota Fiscal nao encontrada ou em uso!".
            run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-cancelamento.chNFe,
                                 "Nota Fiscal " + tt-retorno-cancelamento.chNFe + " n∆o encontrada ou em uso!",
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
        end.
        delete tt-retorno-cancelamento.
    end.

    for each tt-retorno-inutilizacao
        query-tuning(no-lookahead):

        run pi-acompanhar in h-acomp (input "Inutilizaá∆o: " + trim(string(tt-retorno-inutilizacao.nNFIni))).
        if tt-param.arquivo <> "" then do:
            display "Inutilizacao" format "X(12)"
                    tt-retorno-inutilizacao.idMovto  
                    tt-retorno-inutilizacao.tpAmb
                    tt-retorno-inutilizacao.CNPJ     format "X(16)"
                    tt-retorno-inutilizacao.serie
                    tt-retorno-inutilizacao.nNFIni   format "X(44)"
                    tt-retorno-inutilizacao.nNFFin   format "X(44)"
                    tt-retorno-inutilizacao.dhRecbto format "X(12)"
                    tt-retorno-inutilizacao.nProt    format "X(20)"
                    tt-retorno-inutilizacao.cStat    
                    tt-retorno-inutilizacao.xMotivo  format "X(60)"
                    WITH WIDTH 300 STREAM-IO doWN.
        end.
        l-ok = no.
        for each estabelec no-lock where 
            estabelec.cgc = trim(tt-retorno-inutilizacao.cnpj)
            query-tuning(no-lookahead):
            for each nota-fiscal NO-LOCK where 
                nota-fiscal.cod-estabel  = estabelec.cod-estabel and
                nota-fiscal.serie        = trim(tt-retorno-inutilizacao.serie) and
                nota-fiscal.nr-nota-fis >= trim(tt-retorno-inutilizacao.nNFIni) and
                nota-fiscal.nr-nota-fis <= trim(tt-retorno-inutilizacao.nNFFin)
                query-tuning(no-lookahead):

                find b-nota-fiscal exclusive-lock where 
                    rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                if avail b-nota-fiscal then do:
                    /* marcar nota em processo de inutilizacao para notas inutilizadas4 na NDD */
                    if nota-fiscal.idi-sit-nf-eletro <> 13 then assign b-nota-fiscal.idi-sit-nf-eletro = 13.
                    run pi-trata-ret-nfe (
                        input tt-retorno-inutilizacao.idMovto ,
                        input tt-retorno-inutilizacao.Id      ,
                        input ""                              ,
                        input tt-retorno-inutilizacao.cStat   ,
                        input tt-retorno-inutilizacao.nProt   ,
                        input ""                              ,
                        input tt-retorno-inutilizacao.tpAmb   , 
                        input tt-retorno-inutilizacao.verAplic,
                        input tt-retorno-inutilizacao.dhRecbto,
                        input ""                              ,
                        input tt-retorno-inutilizacao.xMotivo).
    
                    if tt-retorno-inutilizacao.cStat = "102" then do:
                        if not l-erro then do:
    
                            assign b-nota-fiscal.dt-confirma  = ?.
                            if nota-fiscal.idi-sit-nf-eletro <> 7 then
                                assign b-nota-fiscal.idi-sit-nf-eletro = 7.
    
                            assign b-nota-fiscal.dt-cancela   = /*TODAY*/ date(int(entry(2,tt-retorno-inutilizacao.dhRecbto,'-')),
                                                                              int(substring(entry(3,tt-retorno-inutilizacao.dhRecbto,'-'),1,2)),
                                                                              int(entry(1,tt-retorno-inutilizacao.dhRecbto,'-')))
                                   b-nota-fiscal.ind-sit-nota = 4
                                   b-nota-fiscal.cod-protoc   = tt-retorno-inutilizacao.nProt.
        
                            for each it-nota-fisc of nota-fiscal
                                query-tuning(no-lookahead):
                                assign it-nota-fisc.dt-cancela  = nota-fiscal.dt-cancela
                                       it-nota-fisc.dt-confirma = nota-fiscal.dt-confirma.
                            end.
                            run pi-altera-docum-est.
                            run intprg/int999.p ("RETNFNDD", 
                                     &if "{&bf_dis_versao_ems}" < "2.07" &then
                                        trim(substring(nota-fiscal.char-2,3,44)),
                                     &else
                                        nota-fiscal.cod-chave-aces-nf-eletro,
                                     &endif
                                     "Inutilizaá∆o n£mero nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario,
                                     "int022rp.p").
                            run pi-marca-processado (tt-retorno-inutilizacao.idMovto).
                        end.
                        else do:
                            run intprg/int999.p ("RETNFNDD", 
                                     &if "{&bf_dis_versao_ems}" < "2.07" &then
                                        trim(substring(nota-fiscal.char-2,3,44)),
                                     &else
                                        nota-fiscal.cod-chave-aces-nf-eletro,
                                     &endif
                                     "Inutilizaá∆o - Nota fiscal n∆o desatualizada do estoque: " + nota-fiscal.cod-chave-aces-nf-eletro,
                                     1, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario,
                                     "int022rp.p").
                        end.
                    end.
                    else do:
                        run intprg/int999.p ("RETNFNDD", 
                                 &if "{&bf_dis_versao_ems}" < "2.07" &then
                                    trim(substring(nota-fiscal.char-2,3,44))
                                 &else
                                    nota-fiscal.cod-chave-aces-nf-eletro
                                 &endif
                                 ,"Inutilizaá∆o n£mero nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " n∆o realizado. Cod: " +  tt-retorno-inutilizacao.cStat + " - Motivo: " + tt-retorno-inutilizacao.xMotivo,
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
                        run pi-marca-processado (tt-retorno-inutilizacao.idMovto).
                    end.
                    assign l-ok = yes.
                    release b-nota-fiscal.
                end.
            end.
        end.
        if not l-ok then do:
            display tt-retorno-inutilizacao.cnpj + "/" + tt-retorno-inutilizacao.serie + "/" + tt-retorno-inutilizacao.nNFIni format "X(27)" 
                    " -> Nota Fiscal nao encontrada ou em uso!"
                with width 550 stream-io.
            run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-inutilizacao.cnpj + "/" + tt-retorno-inutilizacao.serie + "/" + tt-retorno-inutilizacao.nNFIni,
                                 "Nota Fiscal " + tt-retorno-inutilizacao.cnpj + "/" + tt-retorno-inutilizacao.serie + "/" + tt-retorno-inutilizacao.nNFIni + " n∆o encontrada!",
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
        end.
        delete tt-retorno-inutilizacao.
    end.
    for each tt-retorno-impressao
        query-tuning(no-lookahead):
        if tt-param.arquivo <> "" then do:
            display "Impressao" format "X(12)"
                    tt-retorno-impressao.idMovto  
                    tt-retorno-impressao.id  
                    tt-retorno-impressao.chave    format "X(44)"
                    WITH WIDTH 300 STREAM-IO doWN.
        end.
        run pi-acompanhar in h-acomp (input "Impress∆o: " + trim(string(tt-retorno-impressao.chave))).

        l-ok = no.                                                        
        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-impressao.chave,7,14))
            query-tuning(no-lookahead):
            for each nota-fiscal NO-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-impressao.chave,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-impressao.chave,26,9))),">>>>>>>9999999"))
                query-tuning(no-lookahead):

                if nota-fiscal.ind-sit-nota = 1 then do:
                    
                    find b-nota-fiscal exclusive-lock where 
                        rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                    if avail b-nota-fiscal then do:
                        assign b-nota-fiscal.ind-sit-nota = 3.
                        run intprg/int999.p ("RETNFNDD", 
                                 &if "{&bf_dis_versao_ems}" < "2.07" &then
                                    trim(substring(nota-fiscal.char-2,3,44)),
                                 &else
                                    trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44)),
                                 &endif
                                 "Retorno impress∆o nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                                 2, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
                        run pi-marca-processado (tt-retorno-impressao.idMovto).
                        l-ok = yes.
                        release nota-fiscal.
                    end.
                end.
                else do:
                    assign l-ok = yes.
                    run pi-marca-processado (tt-retorno-impressao.idMovto).
                end.
            end.
        end.
        if not l-ok then do:
            display tt-retorno-impressao.chave format "X(44)" " -> Nota Fiscal nao encontrada ou em uso!".
            run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-impressao.chave,
                                 "Nota Fiscal " + tt-retorno-impressao.chave + " n∆o encontrada ou em uso!",
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
        end.
        delete tt-retorno-impressao.
    end.


    for each tt-retorno-substituicao
        query-tuning(no-lookahead):
        if tt-param.arquivo <> "" then do:
            display "Substituiá∆o" format "X(12)"
                    tt-retorno-substituicao.idMovto  
                    tt-retorno-substituicao.id  
                    tt-retorno-substituicao.chaveAtual format "X(44)"
                    tt-retorno-substituicao.chaveNova  format "X(44)"
                    WITH WIDTH 300 STREAM-IO doWN.
        end.
        run pi-acompanhar in h-acomp (input "Substituiá∆o: " + trim(string(tt-retorno-substituicao.chaveAtual))).

        if length(trim(tt-retorno-substituicao.chaveAtual)) < 44 then next.

        l-ok = no.
        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-substituicao.chaveAtual,7,14))
            query-tuning(no-lookahead):

            for each nota-fiscal NO-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-substituicao.chaveAtual,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-substituicao.chaveAtual,26,9))),">>>>>>>9999999"))
                query-tuning(no-lookahead):

                find b-nota-fiscal exclusive-lock where 
                    rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                if avail b-nota-fiscal then do:
                    &if "{&bf_dis_versao_ems}" < "2.07" &then
                       overlay(b-nota-fiscal.char-2,3,44) = trim(tt-retorno-substituicao.chaveNova).
                    &else
                       assign b-nota-fiscal.cod-chave-aces-nf-eletro = trim(tt-retorno-substituicao.chaveNova).
                    &endif
                
                    run intprg/int999.p ("RETNFNDD", 
                             &if "{&bf_dis_versao_ems}" < "2.07" &then
                                trim(substring(nota-fiscal.char-2,3,44)),
                             &else
                                nota-fiscal.cod-chave-aces-nf-eletro,
                             &endif
                             "Substituiá∆o chave acesso nota fiscal:" + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                             2, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "int022rp.p").
                    run pi-marca-processado (tt-retorno-substituicao.idMovto).
                    l-ok = yes.
                    release b-nota-fiscal.
                end.
            end.
        end.        
        if not l-ok then do:
            display tt-retorno-substituicao.chaveAtual format "X(44)" " -> Nota Fiscal nao encontrada ou em uso!".
            run intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-substituicao.chaveAtual,
                                 "Nota Fiscal " + tt-retorno-substituicao.chaveAtual + " n∆o encontrada ou em uso!",
                                 1, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
        end.
        delete tt-retorno-substituicao.
    end.

    for each tt-retorno-erro
        query-tuning(no-lookahead):
        if tt-param.arquivo <> "" then do:
            display "Erro XML" format "X(12)"
                    tt-retorno-erro.idMovto  
                    tt-retorno-erro.chNFe format "X(44)"
                    tt-retorno-erro.tipo  format "X(1)"
                    tt-retorno-erro.xMotivo format "X(44)"
                    WITH WIDTH 300 STREAM-IO doWN.
        end.
        run pi-acompanhar in h-acomp (input "Erro XML: " + trim(string(tt-retorno-erro.chNFe))).

        if length(trim(tt-retorno-erro.chNFe)) < 44 then next.

        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-erro.chNFe,7,14))
            query-tuning(no-lookahead):

            for each nota-fiscal NO-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-erro.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-erro.chNFe,26,9))),">>>>>>>9999999"))
                query-tuning(no-lookahead):

                if  nota-fiscal.idi-sit-nf-eletro <= 2   and
                    trim(tt-retorno-erro.tipo)     = "1" and
                    nota-fiscal.idi-sit-nf-eletro <> 3   and
                    nota-fiscal.idi-sit-nf-eletro <> 5   and
                    nota-fiscal.idi-sit-nf-eletro <> 6   and
                    nota-fiscal.idi-sit-nf-eletro <> 7 then do:
                    
                    find b-nota-fiscal exclusive-lock where 
                        rowid(b-nota-fiscal) = rowid(nota-fiscal) no-error no-wait.
                    if avail b-nota-fiscal then do:
                        assign b-nota-fiscal.idi-sit-nf-eletro = 1 /* nfe nao gerada */.

                        for last ret-nf-eletro exclusive-lock where 
                            ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel and 
                            ret-nf-eletro.cod-serie   = nota-fiscal.serie       and 
                            ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                            ret-nf-eletro.cod-msg     = tt-retorno-erro.tipo    and 
                            ret-nf-eletro.dat-ret     = today                   and
                            ret-nf-eletro.cod-livre-2 = tt-retorno-erro.xMotivo and
                            ret-nf-eletro.log-ativo   = yes
                            query-tuning(no-lookahead): end.
                        if not avail ret-nf-eletro then do:
                            create  ret-nf-eletro.
                            assign  ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel
                                    ret-nf-eletro.cod-serie   = nota-fiscal.serie
                                    ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis
                                    ret-nf-eletro.dat-ret     = today
                                    ret-nf-eletro.cod-msg     = tt-retorno-erro.tipo.
                        end.
                        assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
                                ret-nf-eletro.cod-livre-2 = tt-retorno-erro.xMotivo
                                ret-nf-eletro.log-ativo   = yes.
                        release ret-nf-eletro.
    
                        run intprg/int999.p ("RETNFNDD", 
                                 &if "{&bf_dis_versao_ems}" < "2.07" &then
                                    trim(substring(nota-fiscal.char-2,3,44)),
                                 &else
                                    nota-fiscal.cod-chave-aces-nf-eletro,
                                 &endif
                                 "Leitura Erro nota fiscal:" + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                                 2, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario,
                                 "int022rp.p").
                        run pi-marca-processado (tt-retorno-erro.idMovto).
                    end.
                end.
            end.
        end.        
        delete tt-retorno-erro.
    end.
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi135) then delete procedure h-bodi135.
    if  valid-handle(h-boin090) then delete procedure h-boin090.
    if  valid-handle(h-bodi135na-sitnfe) then delete procedure h-bodi135na-sitnfe.
    if  valid-handle(h-boad107na) then delete procedure h-boad107na.
end.

/* FIM do PROGRAMA */


procedure pi-trata-ret-nfe:

    define input param pIdMovto  as int64 no-undo.
    define input param pcChave   as char no-undo.
    define input param pcId      as char no-undo.
    define input param pcStat    as char no-undo.
    define input param pnProt    as char no-undo.
    define input param ptpEmis   as char no-undo.
    define input param PtpAmb    as char no-undo.
    define input param pverAplic as char no-undo.
    define input param pdhRecbto as char no-undo.
    define input param pdigVal   as char no-undo.
    define input param pxMotivo  as char no-undo.

    /*
    PUT "trata-ret-nfe "
        pIdMovto  " "
        pcChave   " "
        pcId      " "
        pcStat    " "
        pnProt    " "
        ptpEmis   " "
        PtpAmb    " "
        pverAplic " "
        pdhRecbto " "
        pdigVal   " "
        pxMotivo  SKIP.
    */

    l-erro = no.

    if not nota-fiscal.obs-gerada matches "*ID NDD: " + string(pIdMovto) + "*" and
       /*evitar estouro de campo */
       length(trim(nota-fiscal.obs-gerada + " ID NDD: " + string(pIdMovto))) < 2000 then 
        assign b-nota-fiscal.obs-gerada = trim(nota-fiscal.obs-gerada + " ID NDD: " + string(pIdMovto)).
    /* Tratamento p/ Nota Propria gerada no Recebimento */
    if nota-fiscal.ind-tip-nota = 8 then do:
        for first docum-est where 
            docum-est.serie-docto  = nota-fiscal.serie and
            docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
            docum-est.cod-emitente = nota-fiscal.cod-emitente and
            docum-est.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead): end.
        if not avail docum-est then return.
        
        CASE pcStat:
            WHEN "101":U OR       /*101 - Cancelamento de NF-e homologado  */
            WHEN "135":U OR       /*135 - Cancelamento de NF-e Entrada homologado */
            WHEN "151":U OR       /*151 - Cancelamento de NF-e homologado fora de prazo*/                                  
            WHEN "155":U OR       /*155 - Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
            WHEN "102":U then do: /*102 - Inutilizaá∆o de n£mero homologado*/
                /* se estiver em cancelamento ou inutilizaá∆o - filtrar erro de cStat NDD 101 quando documento n∆o est† em cancelamento */
                if  nota-fiscal.idi-sit-nf-eletro = 12 or 
                    nota-fiscal.idi-sit-nf-eletro = 13 then do:
                    run ftp/ft0911.p (rowid(nota-fiscal), pcStat, pnProt).
                    /* se n∆o desatualizar pelo padr∆o chama re0402 */
                    find current docum-est no-lock no-error.
                    if avail docum-est and docum-est.ce-atual then run pi-desatualiza-nota.
                end.
            end. /* cancelamento */
            OTHERWISE do:
                RUN pi-cria-altera-ret-nf-eletro (
                    input pIdMovto  ,
                    input pcChave   ,
                    input pcId      ,
                    input pcStat    ,
                    input pnProt    ,
                    input ptpEmis   ,
                    input PtpAmb    ,
                    input pverAplic ,
                    input pdhRecbto ,
                    input pdigVal   ,
                    input pxMotivo ).
                for first ttReturnInvoicedocument: end.
                for last ret-nf-eletro no-lock where 
                    ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel and 
                    ret-nf-eletro.cod-serie   = nota-fiscal.serie       and 
                    ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                    ret-nf-eletro.cod-msg     = pcStat                  and 
                    ret-nf-eletro.dat-ret     = today                   and 
                    ret-nf-eletro.log-ativo   = yes 
                    query-tuning(no-lookahead): 
                    run pi-atualiza-nota.
                end.
                /*if not l-erro then run pi-marca-processado (pIdMovto).*/
            end.
        end CASE.
    end.
    else do: /* NFS */
        case pcStat:
            WHEN "101":U OR       /*101 - Cancelamento de NF-e homologado  */
            WHEN "135":U OR       /*135 - Cancelamento de NF-e Entrada homologado */
            WHEN "151":U OR       /*151 - Cancelamento de NF-e homologado fora de prazo*/                                  
            WHEN "155":U OR       /*155 - Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
            WHEN "102":U then do: /*102 - Inutilizaá∆o de n£mero homologado*/
                /* se estiver em cancelamento ou inutilizaá∆o - filtrar erro de cStat NDD 101 quando documento n∆o est† em cancelamento */
                if  nota-fiscal.idi-sit-nf-eletro = 12 or 
                    nota-fiscal.idi-sit-nf-eletro = 13 then do:
                    run ftp/ft0911.p (rowid(nota-fiscal), pcStat, pnProt).
                    run pi-desatualiza-ft2100.
                end.
            end.
            /*otherwise if not l-erro then run pi-marca-processado (pIdMovto).*/
        end case.
    end.

    if not l-erro then do:
        RUN pi-cria-altera-ret-nf-eletro (
            input pIdMovto  ,
            input pcChave   ,
            input pcId      ,
            input pcStat    ,
            input pnProt    ,
            input ptpEmis   ,
            input PtpAmb    ,
            input pverAplic ,
            input pdhRecbto ,
            input pdigVal   ,
            input pxMotivo ).

        if nota-fiscal.ind-tip-nota <> 8 then do:
            for first ttReturnInvoicedocument: end.
            for last ret-nf-eletro no-lock where 
                ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel and 
                ret-nf-eletro.cod-serie   = nota-fiscal.serie and 
                ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                ret-nf-eletro.cod-msg     = pcStat and 
                ret-nf-eletro.dat-ret     = today and 
                ret-nf-eletro.log-ativo   = yes 
                query-tuning(no-lookahead): 
                run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                             input table ttReturnInvoicedocument).
            end.
        end.
        release ret-nf-eletro.

        /*run pi-marca-processado (pIdMovto).*/
    end.

end.

PROCEDURE pi-cria-altera-ret-nf-eletro:
    define input param pIdMovto  as int64 no-undo.
    define input param pcChave   as char no-undo.
    define input param pcId      as char no-undo.
    define input param pcStat    as char no-undo.
    define input param pnProt    as char no-undo.
    define input param ptpEmis   as char no-undo.
    define input param PtpAmb    as char no-undo.
    define input param pverAplic as char no-undo.
    define input param pdhRecbto as char no-undo.
    define input param pdigVal   as char no-undo.
    define input param pxMotivo  as char no-undo.

    empty   temp-table ttReturnInvoicedocument.
    create  ttReturnInvoicedocument.
    assign  ttReturnInvoicedocument.Id        = pcId
            ttReturnInvoicedocument.chNFe     = &if "{&bf_dis_versao_ems}" < "2.07" &then
                                                    trim(substring(nota-fiscal.char-2,3,44))
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &then 
                                                    nota-fiscal.cod-chave-aces-nf-eletro
                                                &endif
            ttReturnInvoicedocument.nProt     = &if "{&bf_dis_versao_ems}" < "2.07" &then
                                                    substr(nota-fiscal.char-1,97,15)
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &then
                                                    nota-fiscal.cod-protoc 
                                                &endif
            ttReturnInvoicedocument.versao    = 0
            ttReturnInvoicedocument.lDanfe    = no
            ttReturnInvoicedocument.tpAmb     = ptpAmb
            ttReturnInvoicedocument.verAplic  = pverAplic
            ttReturnInvoicedocument.dhRecbto  = pdhRecbto
            ttReturnInvoicedocument.digVal    = pdigVal
            ttReturnInvoicedocument.xMotivo   = pxMotivo
            ttReturnInvoicedocument.tpEmis    = &if "{&bf_dis_versao_ems}" < "2.07" &then 
                                                    if int(substr(nota-fiscal.char-2,65,2)) > 0 then
                                                       trim(string(int(substr(nota-fiscal.char-2,65,2))))
                                                    else ""
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &then
                                                    if int(nota-fiscal.idi-forma-emis-nf-eletro) > 0 then
                                                       trim(string(int(nota-fiscal.idi-forma-emis-nf-eletro)))
                                                    else ""
                                                &endif.

    FOR LAST ret-nf-eletro exclusive-lock WHERE
        ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel AND
        ret-nf-eletro.cod-serie   = nota-fiscal.serie AND
        ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis AND
        ret-nf-eletro.cod-msg     = pcStat AND
        ret-nf-eletro.dat-ret     = TODAY AND
        ret-nf-eletro.log-ativo   = YES
        query-tuning(no-lookahead): end.
    if NOT avail ret-nf-eletro then do:
        create  ret-nf-eletro.
        assign  ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel
                ret-nf-eletro.cod-serie   = nota-fiscal.serie
                ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis
                ret-nf-eletro.dat-ret     = today
                ret-nf-eletro.cod-msg     = pcStat.
    end.
    assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
            ret-nf-eletro.cod-livre-2 = pxMotivo
            ret-nf-eletro.log-ativo   = yes
            &if "{&bf_dis_versao_ems}" >= "2.07" &then 
                ret-nf-eletro.cod-protoc  = pnProt.
            &else
                ret-nf-eletro.cod-livre-1 = pnProt.
            &endif
    /* armazenando ID do registro de retorno para reprocessamento se necess†rio AVB 15/08/2017 */            
    assign ret-nf-eletro.val-livre-2 = pIdMovto NO-ERROR.
END.

PROCEDURE pi-marca-processado:
    DEFINE INPUT PARAMETER pid AS intEGER.
    /* marcando como processado */
    for first int_ndd_retorno EXCLUSIVE where int_ndd_retorno.ID = pid
        query-tuning(no-lookahead):
        assign int_ndd_retorno.STATUSNUMBER = 1.
    end.
    release int_ndd_retorno.
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

procedure pi-desatualiza-nota:
    run rep/re0402a.p ( INPUT  ROWID(docum-est),
                        INPUT  /*tt-param.l-of*/ no,
                        INPUT  /*tt-param.l-saldo*/ yes,
                        INPUT  /*tt-param.l-desatual*/ no,
                        INPUT  /*tt-param.l-custo-padrao*/ yes,
                        INPUT  /*tt-param.l-desatualiza-ap*/ yes,
                        INPUT  /*tt-param.i-prc-custo*/ 2,
                        INPUT  /*tt-param.l-desatualiza-aca*/ yes,
                        INPUT  /*tt-param.l-desatualiza-wms*/ no,
                        INPUT  /*tt-param.l-desatualiza-draw*/ no,
                        INPUT  /*tt-param.l-desatualiza-cr*/ yes,
                        OUTPUT l-erro,
                        OUTPUT table tt-erro ).

    /*Desatualiza Nota de Credito*/
    if  not l-erro then do:

        l-erro = no.
        for each fat-ser-lote no-lock of nota-fiscal:
            for each movto-estoq no-lock where 
                movto-estoq.cod-estabel = fat-ser-lote.cod-estabel  and
                movto-estoq.cod-depos   = fat-ser-lote.cod-depos    and
                movto-estoq.it-codigo   = fat-ser-lote.it-codigo    and
                movto-estoq.lote        = fat-ser-lote.nr-serlote   and
                movto-estoq.cod-localiz = fat-ser-lote.cod-localiz  and
                movto-estoq.serie-docto = fat-ser-lote.serie        and
                movto-estoq.nro-docto   = fat-ser-lote.nr-nota-fis  and
                movto-estoq.sequen-nf   = fat-ser-lote.nr-seq-fat:
                l-erro = yes.
                leave.
            end.
            if l-erro then return.
        end.

        run goToKey IN h-boad107na (INPUT nota-fiscal.cod-estabel).
        if RETURN-VALUE = "OK":U then
           run getLogField IN h-boad107na (INPUT "log-emite-danfe":U, OUTPUT l-emite-danfe-estab).

        run retornaSitNF-e IN h-bodi135na-sitnfe (INPUT nota-fiscal.cod-estabel,
                                                  INPUT nota-fiscal.serie,
                                                  INPUT nota-fiscal.nr-nota-fis,
                                                  INPUT nota-fiscal.dt-emis-nota,
                                                  OUTPUT i-sit-nfe-aux,
                                                  OUTPUT c-sit-nfe-aux).
        if l-emite-danfe-estab then
             run trataNotaFiscalEletronica in  h-boin090 (input rowid(ret-nf-eletro),
                                                          input table ttReturnInvoicedocument).

        run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                     input table ttReturnInvoicedocument).
        run pi-trata-nota-credito.

        run pi-atualizaNotaFiscAdc. /* Atualiza nota-fisc-adc (CD4035) */

    end. /*if not l-erro */

end procedure.


procedure pi-atualiza-nota:

    /*
    PUT "atualiza-nota "
        nota-fiscal.cod-estabel  " "
        nota-fiscal.serie        " " 
        nota-fiscal.nr-nota-fis  " "
        nota-fiscal.dt-emis-nota 
        SKIP.
    */

    run goToKey IN h-boad107na (INPUT nota-fiscal.cod-estabel).
    if RETURN-VALUE = "OK":U then
       run getLogField IN h-boad107na (INPUT "log-emite-danfe":U, OUTPUT l-emite-danfe-estab).

    run retornaSitNF-e IN h-bodi135na-sitnfe (INPUT nota-fiscal.cod-estabel,
                                              INPUT nota-fiscal.serie,
                                              INPUT nota-fiscal.nr-nota-fis,
                                              INPUT nota-fiscal.dt-emis-nota,
                                              OUTPUT i-sit-nfe-aux,
                                              OUTPUT c-sit-nfe-aux).
    if l-emite-danfe-estab then
        run trataNotaFiscalEletronica in  h-boin090 (input rowid(ret-nf-eletro),
                                                     input table ttReturnInvoicedocument).

    run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                 input table ttReturnInvoicedocument).

    find current nota-fiscal NO-LOCK no-error.
    assign docum-est.idi-sit-nf-eletro = nota-fiscal.idi-sit-nf-eletro
           docum-est.log-1 = if nota-fiscal.dt-cancela <> ? then no else yes
           docum-est.cod-chave-aces-nf-eletro = nota-fiscal.cod-chave-aces-nf-eletro.

    if nota-fiscal.idi-sit-nf-eletro = 3 then do:
        empty temp-table tt-digita-re1005.
        empty temp-table tt-param-re1005.
        empty temp-table tt-raw-digita.

        create  tt-param-re1005.
        assign  tt-param-re1005.destino            = 3
                tt-param-re1005.arquivo            = "re1005_int022_.txt"
                tt-param-re1005.usuario            = c-seg-usuario
                tt-param-re1005.data-exec          = today
                tt-param-re1005.hora-exec          = time
                tt-param-re1005.classifica         = 1
                tt-param-re1005.c-cod-estabel-ini  = docum-est.cod-estabel
                tt-param-re1005.c-cod-estabel-fim  = docum-est.cod-estabel
                tt-param-re1005.i-cod-emitente-ini = docum-est.cod-emitente
                tt-param-re1005.i-cod-emitente-fim = docum-est.cod-emitente
                tt-param-re1005.c-nro-docto-ini    = docum-est.nro-docto
                tt-param-re1005.c-nro-docto-fim    = docum-est.nro-docto
                tt-param-re1005.c-serie-docto-ini  = docum-est.serie-docto
                tt-param-re1005.c-serie-docto-fim  = docum-est.serie-docto
                tt-param-re1005.c-nat-operacao-ini = docum-est.nat-operacao
                tt-param-re1005.c-nat-operacao-fim = docum-est.nat-operacao
                tt-param-re1005.da-dt-trans-ini    = docum-est.dt-trans
                tt-param-re1005.da-dt-trans-fim    = docum-est.dt-trans.

        create tt-digita-re1005.
        assign tt-digita-re1005.r-docum-est  = rowid(docum-est).
        create tt-raw-digita.
        raw-transfer tt-digita-re1005 to tt-raw-digita.raw-DIGITA.

        raw-transfer tt-param-re1005 to raw-param.
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

        empty temp-table tt-digita-re1005.
        empty temp-table tt-param-re1005.
        empty temp-table tt-raw-digita.

    end.
    
end procedure.


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
                for each b-item-doc-est NO-LOCK
                   WHERE b-item-doc-est.cod-emitente = item-doc-est.cod-emitente
                     AND b-item-doc-est.serie-docto  = item-doc-est.serie-comp
                     AND b-item-doc-est.nro-docto    = item-doc-est.nro-comp
                     AND b-item-doc-est.nat-operacao = item-doc-est.nat-comp
                     AND b-item-doc-est.it-codigo    = item-doc-est.it-codigo
                     AND b-item-doc-est.sequencia    = item-doc-est.seq-comp,
                   FIRST b-docum-est of b-item-doc-est NO-LOCK
                    query-tuning(no-lookahead):

                    if  NOT b-docum-est.nff then do:

                        /*Item Fatura*/
                        FOR FIRST b2-item-doc-est NO-LOCK
                            WHERE b2-item-doc-est.cod-emitente = b-item-doc-est.cod-emitente
                              AND b2-item-doc-est.serie-comp   = b-item-doc-est.serie-docto
                              AND b2-item-doc-est.nro-comp     = b-item-doc-est.nro-docto
                              AND b2-item-doc-est.nat-comp     = b-item-doc-est.nat-operacao
                              AND b2-item-doc-est.it-codigo    = b-item-doc-est.it-codigo
                              AND b2-item-doc-est.seq-comp     = b-item-doc-est.sequencia
                            query-tuning(no-lookahead):

                            CREATE tt-item-doc-est-fat.
                            BUFFER-COPY b2-item-doc-est TO tt-item-doc-est-fat.
                        end.
                    end.
                    else do:
                        CREATE tt-item-doc-est-fat.
                        BUFFER-COPY b-item-doc-est TO tt-item-doc-est-fat.
                    end.
                end.

                /*Itens da Fatura*/
                for each tt-item-doc-est-fat
                    query-tuning(no-lookahead):
                    FIND FIRST b-docum-est of tt-item-doc-est-fat NO-LOCK NO-ERROR.
                    /*Se gerou nota de credito*/
                    if  &if "{&bf_mat_versao_ems}":U >= "2.071":U &then
                            item-doc-est.log-gerou-ncredito
                        &else
                            substring(item-doc-est.char-2,449,1) = "1"
                        &endif then do:


                        /*Cria tt estorno*/
                        if  NOT CAN-FIND(FIRST tt_cancelamento_estorno_apb_1
                                         WHERE tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = b-docum-est.cod-estabel
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
                            assign tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = b-docum-est.cod-estabel
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

PROCEDURE pi-altera-docum-est:
    if nota-fiscal.ind-tip-nota = 8 then do:
        for first docum-est where 
            docum-est.serie-docto  = nota-fiscal.serie and
            docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
            docum-est.cod-emitente = nota-fiscal.cod-emitente and
            docum-est.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead): 
            assign docum-est.idi-sit-nf-eletro = nota-fiscal.idi-sit-nf-eletro
                   docum-est.log-1 = NO.
        end.
    end.
end.

PROCEDURE pi-desatualiza-ft2100. 

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
            tt-param-FT2100.de-embarque-ini   = nota-fiscal.cdd-embarq
            tt-param-FT2100.de-embarque-fim   = nota-fiscal.cdd-embarq
            tt-param-FT2100.c-preparador      = ""
            tt-param-FT2100.arquivo           = "ft2100.tmp"
            tt-param-FT2100.l-disp-men        = no.

    raw-transfer tt-param-FT2100 to raw-param.
    run ftp/ft2100rp.p (input raw-param,
                        input table tt-raw-digita).

    l-erro = no.
    for each fat-ser-lote no-lock of nota-fiscal:
        for each movto-estoq no-lock where 
            movto-estoq.cod-estabel = fat-ser-lote.cod-estabel  and
            movto-estoq.cod-depos   = fat-ser-lote.cod-depos    and
            movto-estoq.it-codigo   = fat-ser-lote.it-codigo    and
            movto-estoq.lote        = fat-ser-lote.nr-serlote   and
            movto-estoq.cod-localiz = fat-ser-lote.cod-localiz  and
            movto-estoq.serie-docto = fat-ser-lote.serie        and
            movto-estoq.nro-docto   = fat-ser-lote.nr-nota-fis  and
            movto-estoq.sequen-nf   = fat-ser-lote.nr-seq-fat:
            l-erro = yes.
            leave.
        end.
        if l-erro then leave.
    end.

end PROCEDURE. 
