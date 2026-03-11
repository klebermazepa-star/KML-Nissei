
/* Temp-table's */

//{rep/re9343.i} 

{method/dbotterr.i}

def temp-table RowErrorsAux no-undo like RowErrors.

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "Seq±¼ncia" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsist¼ncia" column-label "Inconsist¼ncia"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda".
   
/* IRRF */	
/*--- Temp-tables utilizadas para traduzir a empresa/estab ---*/
def temp-table tt_xml_input_output no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_des_conteudo_aux             as character format "x(40)"
    field ttv_num_seq_1                    as integer format ">>>,>>9".                

/*--- Temp-tables utilizadas para retornar os impostos do fornecedor ---*/
def temp-table tt_param_integr_imptos_apb no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_val_pagto_tit_ap             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Pagamentos" column-label "Vl Pagtos"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa‡Æo" column-label "Dat Transac"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  EmissÆo" column-label "Dt EmissÆo"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field ttv_log_impto_obrig              as logical format "Sim/NÆo" initial no label "Imptos Obrigat¢rios"
    field ttv_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP".

def temp-table tt_integr_imptos_pgto_apb no-undo
    field ttv_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_nom_abrev_fornec             as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_des_imposto                  as character format "x(40)" label "Descr  Imposto" column-label "Descri‡Æo"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa‡Æo" column-label "UF"
    field tta_val_aliq_impto               as decimal format ">9.9999" decimals 4 initial 0.00 label "Al¡quota" column-label "Aliq"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tribut vel" column-label "Vl Rendto Tribut"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_log_impto_opcnal             as logical format "Sim/NÆo" initial no label "Imposto Opcional" column-label "Opcional"
    field ttv_log_gilrat                   as logical format "Sim/NÆo" initial no label "GILRAT" column-label "GILRAT"
    field ttv_log_senar                    as logical format "Sim/NÆo" initial no label "SENAR" column-label "SENAR".
	
def temp-table tt_erros_integr_imptos_apb no-undo
    field ttv_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "Número" column-label "Numero"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda".
	
/*IRRF*/    

//{inbo/boin092.i tt-dupli-apagar}   

DEFINE TEMP-TABLE tt-dupli-apagar NO-UNDO LIKE dupli-apagar
    FIELD r-Rowid AS ROWID.

//{inbo/boin567.i tt-dupli-imp}

DEFINE TEMP-TABLE tt-dupli-imp NO-UNDO LIKE dupli-imp
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-es-contrato-docum-dup NO-UNDO
    LIKE es-contrato-docum-dup
    FIELD r-rowid AS ROWID.

def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".


/* Parƒmetros */
define input   param table for tt-es-contrato-docum-dup.
define OUTPUT  param table for tt-erro.

/* define output param table for RowErrors.  */




/* Vari veis **************************************/
DEFINE VARIABLE i-parcela-aux AS INTEGER     NO-UNDO.
def var i-parcela-imp  like dupli-imp.parcela-imp no-undo.
def var h-boin567      as   handle                no-undo.  
def var l-conectado    as   log                   no-undo.
def var l-ja-conectado as   log                   no-undo.
def var h-btb009za     as   handle                no-undo.
def var i-cont         as   int                   no-undo init 1.

DEFINE VARIABLE c-cod-empresa LIKE estabelec.ep-codigo   NO-UNDO.
DEFINE VARIABLE c-cod-estabel LIKE estabelec.cod-estabel NO-UNDO.
DEFINE VARIABLE c-pais           AS CHARACTER            NO-UNDO.
DEFINE VARIABLE c-cod-esp        AS CHARACTER            NO-UNDO.
DEFINE VARIABLE c-ind-tip-impto  AS CHARACTER            NO-UNDO.
DEFINE VARIABLE c-lbl-liter-msg  AS CHARACTER            NO-UNDO.

DEFINE BUFFER b_tt_integr_imptos_pgto_apb FOR tt_integr_imptos_pgto_apb.

DEFINE BUFFER bf-tt-dupli-apagar          FOR tt-dupli-apagar.
DEFINE BUFFER bf-tt-es-contrato-docum-dup FOR tt-es-contrato-docum-dup.

def var h-calc         as handle no-undo.

{btb/btb009za.i}


//{inbo/boin176.m33}

{utp/ut-glob.i}   
{cdp/cd1234.i}    

def buffer b-docum-est for docum-est.

//{dibo/bodi317im2bra.i1} /* Definicao de Temp-Table para Calculo dos Impostos */
   /***********************************************************************************
**
** BODI317IM2BRA.I1 - Defini‡Æo de tabelas tempor rias para calcular os impostos.
**
************************************************************************************/

def temp-table tb-wt-docto no-undo like wt-docto.
/*    field cidade        like wt-docto.cidade                      
    field cidade-cif    like wt-docto.cidade-cif 
    field cod-des-merc  like wt-docto.cod-des-merc
    field cod-emitente  like wt-docto.cod-emitente
    field cod-estabel   like wt-docto.cod-estabel
    field dt-emis-nota  like wt-docto.dt-emis-nota
    field dt-nf-ent-fut like wt-docto.dt-nf-ent-fut
    field esp-docto     like wt-docto.esp-docto
    field estado        like wt-docto.estado
    field ind-tip-nota  like wt-docto.ind-tip-nota  
    field mo-codigo     like wt-docto.mo-codigo
    field nat-operacao  like wt-docto.nat-operacao
    field nome-abrev    like wt-docto.nome-abrev
    field nr-nota       like wt-docto.nr-nota
    field pais          like wt-docto.pais
    field seq-wt-docto  like wt-docto.seq-wt-docto
    field vl-embalagem  like wt-docto.vl-embalagem
    field vl-frete      like wt-docto.vl-frete 
    field vl-mercad     like wt-docto.vl-mercad
    field vl-seguro     like wt-docto.vl-seguro
    field vl-taxa-exp   like wt-docto.vl-taxa-exp
    field char-1        as char form "x(100)":U
    index nota
          cod-estabel
          nr-nota
          cod-emitente
          nat-operacao
    index seq-tabela is primary unique
          seq-wt-docto.
*/  

def temp-table tb-wt-nota-trans no-undo like wt-nota-trans.
/*    field seq-wt-docto like wt-nota-trans.seq-wt-docto 
    field nr-seq-nota  like wt-nota-trans.nr-seq-nota
    field ind-cobranca like wt-nota-trans.ind-cobranca 
    field vl-servico   like wt-nota-trans.vl-servico
    field char-1        as char form "x(100)":U
    index seq-tabela is primary unique
          seq-wt-docto.
*/

def temp-table tb-wt-it-docto no-undo like wt-it-docto.
/*    field calcula             like wt-it-docto.calcula            
    field cod-refer           like wt-it-docto.cod-refer          
    field desconto-zf         like wt-it-docto.desconto-zf
    field despes-moeda-forte  like wt-it-docto.despes-moeda-forte 
    field fat-qtfam           like wt-it-docto.fat-qtfam          
    field it-codigo           like wt-it-docto.it-codigo          
    field mercliq-moeda-forte like wt-it-docto.mercliq-moeda-forte 
    field mercori-moeda-forte like wt-it-docto.mercori-moeda-forte
    field merctab-moeda-forte like wt-it-docto.merctab-moeda-forte
    field nat-operacao        like wt-it-docto.nat-operacao       
    field nr-pedcli           like wt-it-docto.nr-pedcli
    field nr-seq-nota         like wt-it-docto.nr-seq-nota        
    field nr-sequencia        like wt-it-docto.nr-sequencia
    field per-des-item        like wt-it-docto.per-des-item       
    field preori-moeda-forte  like wt-it-docto.preori-moeda-forte  
    field pretab-moeda-forte  like wt-it-docto.pretab-moeda-forte  
    field preuni-moeda-forte  like wt-it-docto.preuni-moeda-forte 
    field quantidade          like wt-it-docto.quantidade         
    field seq-wt-docto        like wt-it-docto.seq-wt-docto       
    field seq-wt-it-docto     like wt-it-docto.seq-wt-it-docto    
    field vl-despes-it        like wt-it-docto.vl-despes-it       
    field vl-embalagem        like wt-it-docto.vl-embalagem       
    field vl-frete            like wt-it-docto.vl-frete           
    field vl-merc-liq         like wt-it-docto.vl-merc-liq        
    field vl-merc-liq-zfm     like wt-it-docto.vl-merc-liq-zfm    
    field vl-merc-ori         like wt-it-docto.vl-merc-ori        
    field vl-merc-s-icms      like wt-it-docto.vl-merc-s-icms     
    field vl-merc-tab         like wt-it-docto.vl-merc-tab
    field vl-preori           like wt-it-docto.vl-preori          
    field vl-pretab           like wt-it-docto.vl-pretab
    field vl-preuni           like wt-it-docto.vl-preuni          
    field vl-preuni-zfm       like wt-it-docto.vl-preuni-zfm
    field vl-seguro           like wt-it-docto.vl-seguro          
    field vl-tot-item         like wt-it-docto.vl-tot-item        
    field vl-tot-item-inf     like wt-it-docto.vl-tot-item-inf
    field char-1        as char form "x(100)":U
    index calcula
          seq-wt-docto
          calcula
    index seq-nota
          seq-wt-docto
          calcula
          nr-seq-nota
    index seq-ped
          seq-wt-docto
          nr-pedcli
          nr-sequencia
    index seq-tabela is primary unique
          seq-wt-docto
          seq-wt-it-docto.
*/
     
def temp-table tb-wt-it-imposto no-undo like wt-it-imposto.
/*    field aliquota-icm      like wt-it-imposto.aliquota-icm      
    field aliquota-ipi      like wt-it-imposto.aliquota-ipi      
    field aliquota-iss      like wt-it-imposto.aliquota-iss      
    field cd-trib-icm       like wt-it-imposto.cd-trib-icm       
    field cd-trib-ipi       like wt-it-imposto.cd-trib-ipi       
    field cd-trib-iss       like wt-it-imposto.cd-trib-iss       
    field icm-complem       like wt-it-imposto.icm-complem       
    field ind-icm-ret       like wt-it-imposto.ind-icm-ret       
    field ind-imprenda      like wt-it-imposto.ind-imprenda      
    field perc-red-icm      like wt-it-imposto.perc-red-icm      
    field perc-red-ipi      like wt-it-imposto.perc-red-ipi      
    field perc-red-iss      like wt-it-imposto.perc-red-iss      
    field per-des-icms      like wt-it-imposto.per-des-icms      
    field seq-wt-docto      like wt-it-imposto.seq-wt-docto       
    field seq-wt-it-docto   like wt-it-imposto.seq-wt-it-docto   
    field vl-bicms-ent-fut  like wt-it-imposto.vl-bicms-ent-fut  
    field vl-bicms-it       like wt-it-imposto.vl-bicms-it       
    field vl-bicms-it-merc  like wt-it-imposto.vl-bicms-it-merc  
    field vl-bipi-ent-fut   like wt-it-imposto.vl-bipi-ent-fut   
    field vl-bipi-it        like wt-it-imposto.vl-bipi-it        
    field vl-biss-it        like wt-it-imposto.vl-biss-it        
    field vl-bsubs-ent-fut  like wt-it-imposto.vl-bsubs-ent-fut  
    field vl-bsubs-it       like wt-it-imposto.vl-bsubs-it       
    field vl-icms-it        like wt-it-imposto.vl-icms-it        
    field vl-icms-it-merc   like wt-it-imposto.vl-icms-it-merc
    field vl-icms-ent-fut   like wt-it-imposto.vl-icms-ent-fut
    field vl-icmsnt-it      like wt-it-imposto.vl-icmsnt-it      
    field vl-icmsou-it      like wt-it-imposto.vl-icmsou-it      
    field vl-icms-outras    like wt-it-imposto.vl-icms-outras
    field vl-icmsub-ent-fut like wt-it-imposto.vl-icmsub-ent-fut 
    field vl-icmsub-it      like wt-it-imposto.vl-icmsub-it      
    field vl-inss-rf        like wt-it-imposto.vl-inss-rf        
    field vl-ipi-ent-fut    like wt-it-imposto.vl-ipi-ent-fut     
    field vl-ipi-it         like wt-it-imposto.vl-ipi-it         
    field vl-ipint-it       like wt-it-imposto.vl-ipint-it        
    field vl-ipiou-it       like wt-it-imposto.vl-ipiou-it        
    field vl-ipi-outras     like wt-it-imposto.vl-ipi-outras     
    field vl-irf-it         like wt-it-imposto.vl-irf-it         
    field vl-iss-it         like wt-it-imposto.vl-iss-it         
    field vl-issnt-it       like wt-it-imposto.vl-issnt-it         
    field vl-issou-it       like wt-it-imposto.vl-issou-it         
    field vl-pauta          like wt-it-imposto.vl-pauta          
    field vl-precon         like wt-it-imposto.vl-precon
    field char-1        as char form "x(100)":U
    index seq-tabela is primary unique
          seq-wt-docto
          seq-wt-it-docto.
*/

def temp-table tb-wt-it-docto-imp no-undo like wt-it-docto-imp.
/*    field aliquota        like wt-it-docto-imp.aliquota 
    field cod-taxa        like wt-it-docto-imp.cod-taxa 
    field conta-percepcao like wt-it-docto-imp.conta-percepcao 
    field conta-retencao  like wt-it-docto-imp.conta-retencao 
    field conta-tax       like wt-it-docto-imp.conta-tax
    field nr-seq-imp      like wt-it-docto-imp.nr-seq-imp
    field perc-percepcao  like wt-it-docto-imp.perc-percepcao 
    field seq-wt-docto    like wt-it-docto-imp.seq-wt-docto
    field seq-wt-it-docto like wt-it-docto-imp.seq-wt-it-docto
    field tipo-tax        like wt-it-docto-imp.tipo-tax 
    field vl-base-imp     like wt-it-docto-imp.vl-base-imp 
    field vl-base-imp-me  like wt-it-docto-imp.vl-base-imp-me
    field vl-imposto      like wt-it-docto-imp.vl-imposto   
    field vl-imposto-me   like wt-it-docto-imp.vl-imposto-me 
    field vl-percepcao    like wt-it-docto-imp.vl-percepcao 
    field vl-percepcao-me like wt-it-docto-imp.vl-percepcao-me
    field char-1        as char form "x(100)":U
    index seq-tabela is primary unique
          seq-wt-docto
          seq-wt-it-docto.
*/


def temp-table tb-ct-trib-wt-item-docto no-undo like ct-trib-wt-item-docto.

/*  BODI317IM2BRA.I1  */



DEF VAR h-bodi613calc2        AS HANDLE       NO-UNDO.
DEF VAR h_bodi317im2bra       AS HANDLE       NO-UNDO.
DEF VAR h-bodi317sd           AS HANDLE       NO-UNDO.
DEF VAR l-procedimento-ok     AS LOGICAL      NO-UNDO.
DEFINE VARIABLE l-proc-ok-aux AS LOGICAL      NO-UNDO.

DEF VAR l-calc-pis-cofins-por-unid  as logical                      no-undo.
DEF VAR i-seq-wt-docto-aux          like wt-docto.seq-wt-docto      no-undo.
DEF VAR l-usuario-utiliz-cfg-trib   AS LOG                          NO-UNDO.
DEF VAR de-valor-total-dup          AS DEC                          NO-UNDO.

DEF VAR i-num-parcelas             AS INT  NO-UNDO.
DEF VAR de-percentual-parcela      AS DEC  NO-UNDO.

/************************************************
Gera‡Æo dos impostos retidos - inicio
************************************************/


find first param-global no-lock no-error.
empty temp-table RowErrors. 

/* variável l-usuario-utiliz-cfg-trib - indica se usuário utiliza configurador de tributos */
FOR FIRST param-re fields(char-1) NO-LOCK where  param-re.usuario = c-seg-usuario:
    if substring(param-re.char-1,25,1) = "Y" then   
        ASSIGN l-usuario-utiliz-cfg-trib = YES.
END.


ASSIGN de-valor-total-dup         = 0
       i-num-parcelas             = 0.


FOR EACH bf-tt-es-contrato-docum-dup:
    ASSIGN de-valor-total-dup = de-valor-total-dup + bf-tt-es-contrato-docum-dup.vl-a-pagar /* utilizado para encontrar o percentual da parcela*/
           i-num-parcelas     = i-num-parcelas + 1.
END.



for each tt-es-contrato-docum-dup:

    /*
    if can-find(first dupli-imp where                                         
                      dupli-imp.serie-docto  = tt-dupli-apagar.serie-docto  and  
                      dupli-imp.nro-docto    = tt-dupli-apagar.nro-docto    and 
                      dupli-imp.cod-emitente = tt-dupli-apagar.cod-emitente and 
                      dupli-imp.nat-operacao = tt-dupli-apagar.nat-operacao and 
                      dupli-imp.parcela      = tt-dupli-apagar.parcela)     then next.  */

    ASSIGN de-percentual-parcela = tt-es-contrato-docum-dup.vl-a-pagar / de-valor-total-dup. /* utilizado para encontrar o percentual da parcela*/

    empty temp-table tt_log_erros.
    empty temp-table tt_erros_conexao.
    empty temp-table tt_param_integr_imptos_apb.

    FIND FIRST es-contrato-docum NO-LOCK
         WHERE es-contrato-docum.sequencia = tt-es-contrato-docum-dup.sequencia NO-ERROR.
    
    for first estabelec where
              estabelec.cod-estabel = es-contrato-docum.cod-estabel no-lock: 
	 		 
        ASSIGN c-cod-empresa = estabelec.ep-codigo
               c-cod-estabel = estabelec.cod-estabel.	           
    end.

    /*C¢digo Pa¡s EMS2*/
    /* assign c-pais = b-docum-est.pais.  */
    assign c-pais = "Brasil". 

    /*
    IF  i-pais-impto-usuario <> 1
    AND c-pais = "" THEN
        FOR FIRST emitente FIELDS(pais) NO-LOCK
            WHERE emitente.cod-emitente = b-docum-est.cod-emitente: 
            ASSIGN c-pais = emitente.pais.
        END.   */

    /*--- Traducao empresa, estabelecimento, pa¡s ---*/
    RUN pi-traduz-empresa-estab-pais(INPUT-OUTPUT c-cod-empresa,
                                     INPUT-OUTPUT c-cod-estabel,
                                     INPUT-OUTPUT c-pais).

    IF  RETURN-VALUE = "NOK":U THEN DO:

        CREATE tt-erro.
        ASSIGN tt-erro.i-sequen = 1
               tt-erro.cd-erro  = 1 
               tt-erro.mensagem = "Erro traducao Pais".


        RETURN "NOK".

    END.
        
	   
    /*--- Retorna impostos retidos do fornecedor ---*/			
    CREATE tt_param_integr_imptos_apb.
    ASSIGN tt_param_integr_imptos_apb.tta_cod_empresa       = c-cod-empresa
           tt_param_integr_imptos_apb.tta_cdn_fornecedor    = es-contrato-docum.cod-emitente 
           tt_param_integr_imptos_apb.tta_cod_estab         = c-cod-estabel
           tt_param_integr_imptos_apb.tta_val_pagto_tit_ap  = tt-es-contrato-docum-dup.vl-a-pagar - tt-es-contrato-docum-dup.vl-desconto
           tt_param_integr_imptos_apb.tta_dat_transacao     = tt-es-contrato-docum-dup.dt-trans
           tt_param_integr_imptos_apb.tta_dat_emis_docto    = tt-es-contrato-docum-dup.dt-emis
           tt_param_integr_imptos_apb.tta_dat_vencto_tit_ap = tt-es-contrato-docum-dup.dt-vencim
           tt_param_integr_imptos_apb.ttv_log_impto_obrig   = NO.
           
    RUN prgfin/apb/apb719za.py PERSISTENT SET  h-calc.			
    RUN pi_main_retorna_impostos_calculados_03 IN h-calc (INPUT "Ambos",
														  INPUT  TABLE tt_param_integr_imptos_apb,                                                                         
                                                          OUTPUT TABLE tt_integr_imptos_pgto_apb,
                                                          OUTPUT TABLE tt_erros_integr_imptos_apb ).
    DELETE PROCEDURE h-calc.
    ASSIGN h-calc = ?.	
	   
    for each tt_integr_imptos_pgto_apb:  

        ASSIGN tt_integr_imptos_pgto_apb.tta_val_rendto_tribut = tt-es-contrato-docum-dup.vl-a-pagar - tt-es-contrato-docum-dup.vl-desconto.

        FIND FIRST b_tt_integr_imptos_pgto_apb 
             WHERE b_tt_integr_imptos_pgto_apb.tta_cod_imposto       = tt_integr_imptos_pgto_apb.tta_cod_imposto
               AND b_tt_integr_imptos_pgto_apb.tta_cod_classif_impto = tt_integr_imptos_pgto_apb.tta_cod_classif_impto
               AND ROWID(b_tt_integr_imptos_pgto_apb) <> ROWID(tt_integr_imptos_pgto_apb) NO-ERROR.

        IF  AVAIL b_tt_integr_imptos_pgto_apb THEN
            DELETE b_tt_integr_imptos_pgto_apb.

    END.

    /*--- Retorna os impostos do configurador de tributos -
    IF  l-usuario-utiliz-cfg-trib THEN
        RUN piCalculaFiltraImpostosCfgTrib.  */

    for each tt_integr_imptos_pgto_apb:  
        
        RUN pi-busca-especie-imposto(INPUT c-pais, 
                                     INPUT tt_integr_imptos_pgto_apb.tta_cod_unid_federac,
                                     INPUT INT(tt_integr_imptos_pgto_apb.tta_cod_imposto), 
                                     OUTPUT c-cod-esp,
                                     OUTPUT c-ind-tip-impto).

        IF NOT RETURN-VALUE = "NOK" THEN DO:
    
            empty temp-table RowErrorsAux.


            /*
            if not valid-handle(h-boin567) then 
                run inbo/boin567.p persistent set h-boin567.
    
            empty temp-table tt-dupli-imp.
            
    
            run openQueryStatic   in h-boin567 (input "Main":U).
            run getParcelaImposto in h-boin567 (input  tt-dupli-apagar.cod-emitente,
                                                input  tt-dupli-apagar.serie-docto,
                                                input  tt-dupli-apagar.nr-duplic,  
                                                input  tt-dupli-apagar.nat-operacao,
                                                input  tt-dupli-apagar.parcela,     
                                                output i-parcela-imp).
            FOR EACH tt-dupli-imp:
                DELETE tt-dupli-imp.
            END.
            
            */
            
            RUN salvaTipoImpostoSenarGilrat.

            ASSIGN i-parcela-aux = i-parcela-aux + 1.

            CREATE es-contrato-docum-imp.
            ASSIGN es-contrato-docum-imp.sequencia = tt-es-contrato-docum-dup.sequencia                 
                   es-contrato-docum-imp.seq-dup   = tt-es-contrato-docum-dup.seq-dup                 
                   es-contrato-docum-imp.seq-imp   = i-parcela-aux.

            ASSIGN 
            es-contrato-docum-imp.cod-esp          = c-cod-esp             
            es-contrato-docum-imp.cod-imposto      = int(tt_integr_imptos_pgto_apb.tta_cod_imposto)
            es-contrato-docum-imp.serie-imposto    = es-contrato-docum.serie-docto           
            es-contrato-docum-imp.nro-docto-imp    = tt-es-contrato-docum-dup.nr-duplic          
            es-contrato-docum-imp.parcela-imp      = STRING(i-parcela-aux) 
                
            .

            ASSIGN
            es-contrato-docum-imp.cod-retencao    = int(tt_integr_imptos_pgto_apb.tta_cod_classif_impto)              
            es-contrato-docum-imp.dt-venc-imp     = tt_integr_imptos_pgto_apb.tta_dat_vencto_tit_ap            
            es-contrato-docum-imp.rend-trib       = tt_integr_imptos_pgto_apb.tta_val_rendto_tribut            
            es-contrato-docum-imp.aliquota        = tt_integr_imptos_pgto_apb.tta_val_aliq_impto           
            es-contrato-docum-imp.vl-imposto      = tt_integr_imptos_pgto_apb.tta_val_imposto                   
            es-contrato-docum-imp.tp-codigo       = tt-es-contrato-docum-dup.tp-despesa /*Tipo Despesa*/    

            es-contrato-docum-imp.ind-tip-impto    = c-ind-tip-impto
            .
            

            /*

            create tt-dupli-imp.
            assign tt-dupli-imp.serie-docto         = tt-dupli-apagar.serie-docto
                   tt-dupli-imp.nro-docto           = tt-dupli-apagar.nr-duplic
                   tt-dupli-imp.cod-emitente        = tt-dupli-apagar.cod-emitente
                   tt-dupli-imp.nat-operacao        = tt-dupli-apagar.nat-operacao
                   tt-dupli-imp.parcela             = tt-dupli-apagar.parcela
                   tt-dupli-imp.parcela-imp         = i-parcela-imp


                   tt-dupli-imp.int-1               = int(tt_integr_imptos_pgto_apb.tta_cod_imposto)
                   overlay(tt-dupli-imp.char-1,1,5) = tt-dupli-apagar.serie-docto 
                   tt-dupli-imp.nro-docto-imp       = tt-dupli-apagar.nr-duplic
                   tt-dupli-imp.cod-retencao        = int(tt_integr_imptos_pgto_apb.tta_cod_classif_impto)
                   tt-dupli-imp.dt-venc-imp         = tt_integr_imptos_pgto_apb.tta_dat_vencto_tit_ap
                   tt-dupli-imp.aliquota            = tt_integr_imptos_pgto_apb.tta_val_aliq_impto
                   tt-dupli-imp.rend-trib           = tt_integr_imptos_pgto_apb.tta_val_rendto_tribut
                   tt-dupli-imp.vl-imposto          = tt_integr_imptos_pgto_apb.tta_val_imposto
                   tt-dupli-imp.tp-codigo           = tt-dupli-apagar.tp-despesa /*Tipo Despesa*/
                   tt-dupli-imp.cod-esp             = c-cod-esp
                   tt-dupli-imp.ind-tipo-imposto    = c-ind-tip-impto.
            
    
            DELETE tt-dupli-imp.
            
            */
            
            
        END.
        ELSE DO:


            CREATE tt-erro.
            ASSIGN tt-erro.i-sequen = 2
                   tt-erro.cd-erro  = 2 
                   tt-erro.mensagem = "Verifique_o_cadastro_de_Impostos_do_Fornecedor_Financeiro".


            /*

            {utp/ut-liter.i "NÆo_existe_Imposto:_" *}
            ASSIGN c-lbl-liter-msg = RETURN-VALUE + tt_integr_imptos_pgto_apb.tta_cod_imposto.
            {utp/ut-liter.i ",_UF:_" *}
            ASSIGN c-lbl-liter-msg = c-lbl-liter-msg + RETURN-VALUE + tt_integr_imptos_pgto_apb.tta_cod_unid_federac.
            {utp/ut-liter.i ",_Pa¡s:_" *}
            ASSIGN c-lbl-liter-msg = c-lbl-liter-msg + RETURN-VALUE + c-pais.
            {utp/ut-liter.i ",_para_o_Fornecedor_Financeiro." *}
            ASSIGN c-lbl-liter-msg = c-lbl-liter-msg + RETURN-VALUE.
            {utp/ut-liter.i "_Verifique_o_cadastro_de_Impostos_do_Fornecedor_Financeiro." *}

            IF NOT CAN-FIND(FIRST RowErrors
                            WHERE RowErrors.ErrorDescription = c-lbl-liter-msg) THEN DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorSequence    = i-cont
                       RowErrors.ErrorNumber      = 17006
                       RowErrors.ErrorDescription = c-lbl-liter-msg
                       RowErrors.ErrorHelp        = c-lbl-liter-msg + RETURN-VALUE
                       RowErrors.ErrorType        = "EMS"
                       RowErrors.ErrorSubType     = "ERROR"
                       i-cont                     = i-cont + 1.
            END.
            
            */



        END.
    end.
end.

return "OK":U.

PROCEDURE piCalculaFiltraImpostosCfgTrib:
/*--- CONFIGURADOR DE TRIBUTOS PARA CALCULAR IMPOSTOS RETIDOS ---*/
    DEF VAR c-cod-chave-cenar          AS CHAR NO-UNDO.
    
    /*busca imposto do cenario*/
    DEF VAR c-idi-entr-saida             AS CHAR NO-UNDO.
    DEF VAR c-cod-territor-orig          AS CHAR NO-UNDO.
    DEF VAR c-cod-territor-dest          AS CHAR NO-UNDO.
    DEF VAR c-cod-clas-fisc-emit         AS CHAR NO-UNDO.
    DEF VAR c-cod-clas-fisc-item         AS CHAR NO-UNDO.
    DEF VAR c-cod-clas-fisc-natur-operac AS CHAR NO-UNDO.
    DEF VAR c-dat-inic-valid             AS CHAR NO-UNDO.

    DEF VAR l-cfg-trib-2 AS LOG NO-UNDO.
    DEF VAR l-cfg-trib-3 AS LOG NO-UNDO.

    /**************************/

    ASSIGN c-cod-chave-cenar          = "".
            
    IF  NOT VALID-HANDLE(h-bodi613calc2) THEN
        RUN dibo/bodi613calc2.p persistent set h-bodi613calc2.

    IF  NOT VALID-HANDLE(h_bodi317im2bra) THEN
        RUN dibo/bodi317im2bra.p PERSISTENT SET h_bodi317im2bra.

    IF  NOT VALID-HANDLE(h-bodi317sd) THEN
        RUN dibo/bodi317sd.p PERSISTENT SET h-bodi317sd.

    /**************************************************
    ** FUN€ÇO: cfg-trib
    ** FASE: 2
    ** DESCRI€ÇO: Cen rio Fiscal por Empresa
    **************************************************/
    RUN pi-retorna-status-cdcfgfiscal in h-bodi613calc2 ("cfg-trib", 2).
    IF  RETURN-VALUE = "OK":U THEN
        ASSIGN l-cfg-trib-2 = YES.
    ELSE
        ASSIGN l-cfg-trib-2 = NO.

    /**************************************************
    ** FUN€ÇO: cfg-trib
    ** FASE: 3
    ** DESCRI€ÇO: Cen rio Fiscal com Tabela de Pauta
    **************************************************/
    RUN pi-retorna-status-cdcfgfiscal in h-bodi613calc2 ("cfg-trib", 3).
    IF  RETURN-VALUE = "OK":U THEN
        ASSIGN l-cfg-trib-3 = YES.
    ELSE
        ASSIGN l-cfg-trib-3 = NO.
             
    RUN createTbWtDocto.
    RUN createTbWtItDocto.

    /* enviar temp-tables */
    run enviaTbWtDocto     in h-bodi613calc2 (input table tb-wt-docto).            
    run enviaTbWtItDocto   in h-bodi613calc2 (input table tb-wt-it-docto ).            
    run enviaTbWtItImposto in h-bodi613calc2 (input table tb-wt-it-imposto).

    RUN localizaWtDocto in h-bodi613calc2 ( input 1,
                                            output l-procedimento-ok ). 
                                            
    if  not l-procedimento-ok then do:
        delete procedure h-bodi613calc2.
        RETURN "NOK":U.
    end.

    RUN pi-recebe-handle in h_bodi317im2bra (input "h-bodi613calc2",
                                             input h-bodi613calc2).

    RUN trataImpDupliNotaEntr in h_bodi317im2bra. /*variável l-imp-dupli-nota-entr assume valor yes*/     

    RUN trataConfigTributos in h_bodi317im2bra.

    RUN getRowErrors IN h_bodi317im2bra(OUTPUT TABLE rowErrors).
                                                                        
    /* retornar temp-table */       
    run retornaTbCtTribWtItemDocto in h-bodi613calc2 ( output table tb-ct-trib-wt-item-docto ).
    run retornaTbWtItImposto       in h-bodi613calc2 ( output table tb-wt-it-imposto ).
  
    /*--- Faz o filtro dos impostos retidos conforme tributos retornados pelo cenario fiscal.
          Faz o recalculo do imposto retido conforme valor retornado para o tributo ---*/
    FOR EACH tb-ct-trib-wt-item-docto:
        ASSIGN c-cod-chave-cenar            = REPLACE(tb-ct-trib-wt-item-docto.cod-chave-cenar, "]", "")
               c-idi-entr-saida             = TRIM(ENTRY(2, c-cod-chave-cenar, "["))
               c-cod-territor-orig          = TRIM(ENTRY(3, c-cod-chave-cenar, "["))
               c-cod-territor-dest          = TRIM(ENTRY(4, c-cod-chave-cenar, "[")).

        IF (NOT l-cfg-trib-2) AND (NOT l-cfg-trib-3) THEN DO:                              /* as duas variaveis "no" */
            ASSIGN c-dat-inic-valid             = TRIM(ENTRY(5, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-emit         = TRIM(ENTRY(6, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-item         = TRIM(ENTRY(7, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-natur-operac = TRIM(ENTRY(8, c-cod-chave-cenar, "[")).
        END.

        IF (l-cfg-trib-2 OR l-cfg-trib-3) AND NOT (l-cfg-trib-2 AND l-cfg-trib-3) THEN DO: /* pelo menos uma "yes"   */
            ASSIGN c-dat-inic-valid             = TRIM(ENTRY(6, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-emit         = TRIM(ENTRY(7, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-item         = TRIM(ENTRY(8, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-natur-operac = TRIM(ENTRY(9, c-cod-chave-cenar, "[")).
        END.

        IF l-cfg-trib-2 AND l-cfg-trib-3 THEN DO:                                          /* as duas "yes"          */
            ASSIGN c-dat-inic-valid             = TRIM(ENTRY(7, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-emit         = TRIM(ENTRY(8, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-item         = TRIM(ENTRY(9, c-cod-chave-cenar, "["))
                   c-cod-clas-fisc-natur-operac = TRIM(ENTRY(10, c-cod-chave-cenar, "[")).
        END.

        FOR EACH ct-trib-cenar-fisc NO-LOCK   /* busca o cenario pela chave */
            WHERE ct-trib-cenar-fisc.idi-entr-saida             = 1
              AND ct-trib-cenar-fisc.cod-territor-orig          = c-cod-territor-orig
              AND ct-trib-cenar-fisc.cod-territor-dest          = c-cod-territor-dest
              AND ct-trib-cenar-fisc.dat-inic-valid             = DATE(c-dat-inic-valid)
              AND ct-trib-cenar-fisc.cod-clas-fisc-emit         = c-cod-clas-fisc-emit
              AND ct-trib-cenar-fisc.cod-clas-fisc-item         = c-cod-clas-fisc-item
              AND ct-trib-cenar-fisc.cod-clas-fisc-natur-operac = c-cod-clas-fisc-natur-operac
              AND ct-trib-cenar-fisc.cod-tip-trib               = tb-ct-trib-wt-item-docto.cod-tip-trib:

            IF SUBSTRING(ct-trib-cenar-fisc.cod-livre-1,15,5) <> "" AND      /* cod-imposto no cenario         */       /*se for diferente de branco*/ 
               SUBSTRING(ct-trib-cenar-fisc.cod-livre-1,20,5) <> "" THEN DO: /* cod-classif-imposto no cenario */       /*usuario informou no cd0759*/
                ASSIGN OVERLAY(tb-ct-trib-wt-item-docto.cod-livre-2,1,5) = SUBSTRING(ct-trib-cenar-fisc.cod-livre-1,15,5)
                       OVERLAY(tb-ct-trib-wt-item-docto.cod-livre-2,6,5) = SUBSTRING(ct-trib-cenar-fisc.cod-livre-1,20,5).
            END.
        END.
    END. /*FOR EACH tb-ct-trib-wt-item-docto:*/
    /****************************************************/

    IF c-cod-chave-cenar <> "" THEN DO:
        FOR EACH tt_integr_imptos_pgto_apb EXCLUSIVE-LOCK:
            FIND FIRST tb-ct-trib-wt-item-docto
                 WHERE SUBSTRING(tb-ct-trib-wt-item-docto.cod-livre-2,1,5) = tt_integr_imptos_pgto_apb.tta_cod_imposto
                   AND SUBSTRING(tb-ct-trib-wt-item-docto.cod-livre-2,6,5) = tt_integr_imptos_pgto_apb.tta_cod_classif_impto NO-ERROR.
            IF  NOT AVAIL tb-ct-trib-wt-item-docto THEN DO:
                DELETE tt_integr_imptos_pgto_apb.
                NEXT.
            END.

            /*Zerando as variaveis para nao acumular incorretamente*/
            ASSIGN tt_integr_imptos_pgto_apb.tta_val_rendto_tribut = 0
                   tt_integr_imptos_pgto_apb.tta_val_imposto       = 0 
                   tt-dupli-apagar.vl-a-pagar                      = 0 .
        END.

        FOR EACH tt_integr_imptos_pgto_apb EXCLUSIVE-LOCK:
            FOR EACH tb-ct-trib-wt-item-docto EXCLUSIVE-LOCK
                WHERE SUBSTRING(tb-ct-trib-wt-item-docto.cod-livre-2,1,5) = tt_integr_imptos_pgto_apb.tta_cod_imposto      
                  AND SUBSTRING(tb-ct-trib-wt-item-docto.cod-livre-2,6,5) = tt_integr_imptos_pgto_apb.tta_cod_classif_impto:

                ASSIGN tt_integr_imptos_pgto_apb.tta_val_rendto_tribut = (tt_integr_imptos_pgto_apb.tta_val_rendto_tribut + truncate(tb-ct-trib-wt-item-docto.val-base-calc * de-percentual-parcela, 2)) /*C lculo do Rendimento Tributavel*/
                       tb-ct-trib-wt-item-docto.val-trib               = truncate(tb-ct-trib-wt-item-docto.val-trib * de-percentual-parcela, 2) /* valor será dividido entre o núm de parcelas da duplicata do documento */
                       tt_integr_imptos_pgto_apb.tta_val_imposto       = (tt_integr_imptos_pgto_apb.tta_val_imposto + tb-ct-trib-wt-item-docto.val-trib)
                       tt_integr_imptos_pgto_apb.tta_val_aliq_impto    = tb-ct-trib-wt-item-docto.val-aliq.    
            END. /*FOR EACH tb-ct-trib-wt-item-docto*/
        END. /*FOR EACH tt_integr_imptos_pgto_apb*/   
    END. /*IF c-cod-chave-cenar <> ""*/

    IF  VALID-HANDLE(h-bodi613calc2) THEN
        DELETE PROCEDURE h-bodi613calc2 NO-ERROR.

    IF  VALID-HANDLE(h_bodi317im2bra) THEN
        DELETE PROCEDURE h_bodi317im2bra NO-ERROR.

    IF  VALID-HANDLE(h-bodi317sd) THEN
        DELETE PROCEDURE h-bodi317sd NO-ERROR.

    /********************************************/

END PROCEDURE. 



PROCEDURE pi-traduz-empresa-estab-pais:
          
    DEF INPUT-OUTPUT PARAM v_cod_empre LIKE estabelec.ep-codigo   NO-UNDO. 
    DEF INPUT-OUTPUT PARAM v_cod_estab LIKE estabelec.cod-estabel NO-UNDO. 
	DEF INPUT-OUTPUT PARAM v_cod_pais  AS   CHARACTER             NO-UNDO. 
	
	EMPTY TEMP-TABLE tt_xml_input_output NO-ERROR.
	EMPTY TEMP-TABLE tt_log_erros        NO-ERROR.
    
    CREATE tt_xml_input_output.
    ASSIGN tt_xml_input_output.ttv_cod_label = 'Fun‡Æo':U
           tt_xml_input_output.ttv_des_conteudo = "Faturamento 2.00"
           tt_xml_input_output.ttv_num_seq_1 = 1.
    
    CREATE tt_xml_input_output.
    ASSIGN tt_xml_input_output.ttv_cod_label = 'Produto':U
           tt_xml_input_output.ttv_des_conteudo = "EMS 5"
           tt_xml_input_output.ttv_num_seq_1 = 1.

    CREATE tt_xml_input_output.
    ASSIGN tt_xml_input_output.ttv_cod_label = 'Empresa':U
           tt_xml_input_output.ttv_des_conteudo = v_cod_empre /* Codigo da Empresa no EMS2 */
           tt_xml_input_output.ttv_num_seq_1 = 1.
    
    CREATE tt_xml_input_output.
    ASSIGN tt_xml_input_output.ttv_cod_label = 'Estabel':U 
           tt_xml_input_output.ttv_des_conteudo = v_cod_estab /* Codigo do Estabelecimento no EMS2 */
           tt_xml_input_output.ttv_num_seq_1 = 1.

    CREATE tt_xml_input_output.
    ASSIGN tt_xml_input_output.ttv_cod_label = 'Pais':U 
           tt_xml_input_output.ttv_des_conteudo = v_cod_pais /* Codigo do Pa¡s no EMS2 */
           tt_xml_input_output.ttv_num_seq_1 = 1.	   
    
    RUN prgint/utb/utb786za.py (INPUT-OUTPUT TABLE tt_xml_input_output,
                                OUTPUT TABLE tt_log_erros).
    
    FIND tt_log_erros WHERE tt_log_erros.ttv_num_cod_erro <> 0 NO-ERROR.
    IF  AVAIL tt_log_erros THEN DO:		   
          for each tt_log_erros:
              create RowErrors.
              assign RowErrors.ErrorSequence    = tt_log_erros.ttv_num_seq 
                     RowErrors.ErrorNumber      = tt_log_erros.ttv_num_cod_erro
                     RowErrors.ErrorDescription = tt_log_erros.ttv_des_erro
                     RowErrors.ErrorHelp        = tt_log_erros.ttv_des_ajuda.
          end.
          return "NOK":U.       
    END.
    ELSE DO:
        FOR EACH tt_xml_input_output BREAK BY tt_xml_input_output.ttv_num_seq_1:
            IF  tt_xml_input_output.ttv_cod_label = 'Empresa':U THEN
                ASSIGN v_cod_empre = tt_xml_input_output.ttv_des_conteudo_aux.
            IF  tt_xml_input_output.ttv_cod_label = 'Estabel':U THEN
                ASSIGN v_cod_estab = tt_xml_input_output.ttv_des_conteudo_aux.
		    IF  tt_xml_input_output.ttv_cod_label = 'Pais':U THEN
                ASSIGN v_cod_pais = tt_xml_input_output.ttv_des_conteudo_aux.
        END. 
		
    END.
     
    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-busca-especie-imposto:
/*********************************************
   pc-pais        -> cod-pais traduzido
   pc-uf          -> uf financeiro
   pc-cod-imposto -> cod-imposto traduzido
   pc-cod-esp     -> espécie do imposto 
**********************************************/   
   
    define input  param pc-pais          like docum-est.pais        no-undo.
    define input  param pc-uf            like docum-est.uf          no-undo.
    define input  param pc-cod-imposto   as character format "x(5)" no-undo.
    define output param pc-cod-esp       as character               no-undo.
    define output param pc-ind-tip-impto as character               no-undo.
    
    define variable hDBO      as handle no-undo.
    define variable hRegDBO   as handle no-undo.
    define variable hCampoDBO as handle no-undo.
    
    run prgint/utb/utb944wb.py persistent set hDBO.
    run openQueryDynamic in hDBO.
    
    RUN gotoKey IN hDBO(INPUT pc-pais, 
                        INPUT pc-uf, 
                        INPUT pc-cod-imposto).
    
    IF RETURN-VALUE = "OK":U THEN DO:
        run getRecordInHandle in hDBO (output hRegDBO).
        assign hCampoDBO  = hRegDBO:buffer-field("cod_espec_docto_impto")
               pc-cod-esp = hCampoDBO:buffer-value. 

        assign hCampoDBO        = hRegDBO:buffer-field("ind_tip_impto")
               pc-ind-tip-impto = hCampoDBO:buffer-value. 

        delete procedure hDBO.
        assign hDBO = ?     
               hRegDBO = ?  
               hCampoDBO = ?.
        RETURN "OK":U.
    END.
    ELSE DO:
        delete procedure hDBO.
        assign hDBO = ?     
               hRegDBO = ?  
               hCampoDBO = ?.
        RETURN "NOK":U.
    END.
	   
END PROCEDURE.

PROCEDURE createTbWtDocto:

/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: Criacao da temp-table de documentos (tb-wt-docto), para calculo dos 
         impostos.      
------------------------------------------------------------------------------*/

    FOR FIRST docum-est FIELDS (cod-estabel dt-trans esp-docto mo-codigo valor-embal valor-frete valor-mercad valor-seguro valor-outras)
         WHERE docum-est.cod-emitente = tt-dupli-apagar.cod-emitente
           AND docum-est.serie-docto  = tt-dupli-apagar.serie-docto
           AND docum-est.nro-docto    = tt-dupli-apagar.nro-docto
           AND docum-est.nat-operacao = tt-dupli-apagar.nat-operacao NO-LOCK: END.

    FOR FIRST natur-oper FIELDS (consum-final perc-red-iss)
         WHERE natur-oper.nat-operacao = docum-est.nat-operacao NO-LOCK: END.

    FOR FIRST emitente FIELDS (nome-abrev)
         WHERE emitente.cod-emitente = docum-est.cod-emitente NO-LOCK: END.

    FOR FIRST estabelec FIELDS (cidade estado pais)
         WHERE estabelec.cod-estabel = docum-est.cod-estabel NO-LOCK: END.

    find tb-wt-docto 
        where tb-wt-docto.seq-wt-docto = 1 exclusive-lock no-error.
        
    if  not avail tb-wt-docto then do:
        create tb-wt-docto.
        assign tb-wt-docto.seq-wt-docto = 1
               tb-wt-docto.cod-emitente = docum-est.cod-emitente
               tb-wt-docto.nr-nota      = docum-est.nro-docto
               tb-wt-docto.nat-operacao = docum-est.nat-operacao.
    end.

    RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT tb-wt-docto.seq-wt-docto,
                                                  INPUT NO,
                                                  OUTPUT l-proc-ok-aux).

    assign tb-wt-docto.cod-des-merc = if  natur-oper.consum-final then 2
                                          else 1
           tb-wt-docto.cod-estabel  = docum-est.cod-estabel
           tb-wt-docto.dt-emis-nota = docum-est.dt-trans
           tb-wt-docto.esp-docto    = docum-est.esp-docto
           tb-wt-docto.ind-tip-nota = 8
           tb-wt-docto.mo-codigo    = docum-est.mo-codigo
           tb-wt-docto.nome-abrev   = emitente.nome-abrev
           tb-wt-docto.vl-embalagem = docum-est.valor-embal
           tb-wt-docto.vl-frete     = docum-est.valor-frete
           tb-wt-docto.vl-mercad    = docum-est.valor-mercad
           tb-wt-docto.nr-prog      = 176  /* para indicar no bodi317im1br.i1 que a boin176 que chamou */
           tb-wt-docto.vl-seguro    = docum-est.valor-seguro + docum-est.valor-outras  /* Soma Valor Outros no Seguro para considerar no calculo dos impostos */
           tb-wt-docto.cidade       = estabelec.cidade
           tb-wt-docto.estado       = estabelec.estado
           tb-wt-docto.pais         = estabelec.pais.

    if  valid-handle(h_bodi317im2bra) then DO:
        run enviaTbWtDocto in h_bodi317im2bra ( input table tb-wt-docto ) .            
        RUN localizaWtDocto IN h_bodi317im2bra (INPUT 1,
                                                OUTPUT l-procedimento-ok).
        RUN localizaNaturOper IN h_bodi317im2bra (INPUT docum-est.nat-operacao,
                                                  OUTPUT l-procedimento-ok).
    END.

END PROCEDURE.

PROCEDURE createTbWtItDocto:

    /*****
    Cria temp-table tb-wt-it-docto para que o configurador de tributos possa 
    calcular os impostos retidos do cenario fiscal em que a NFE encontra-se.
    ****/

    DEF VAR c-un-estoque like item.un    no-undo.
    DEF BUFFER bf-pauta-item         for item.
    DEF BUFFER bf-pauta-prazo-compra for prazo-compra.
    DEF BUFFER bf-item-doc-est       FOR item-doc-est.

    FOR EACH item-doc-est
         WHERE item-doc-est.cod-emitente = tt-dupli-apagar.cod-emitente 
           AND item-doc-est.serie-docto  = tt-dupli-apagar.serie-docto
           AND item-doc-est.nro-docto    = tt-dupli-apagar.nro-docto
           AND item-doc-est.nat-operacao = tt-dupli-apagar.nat-operacao NO-LOCK:

        find tb-wt-it-docto 
            where tb-wt-it-docto.seq-wt-docto    = 1
              and tb-wt-it-docto.seq-wt-it-docto = item-doc-est.sequencia 
            exclusive-lock no-error.
    
        if  not avail tb-wt-it-docto then do:
            create tb-wt-it-docto.
            assign tb-wt-it-docto.seq-wt-docto    = 1
                   tb-wt-it-docto.seq-wt-it-docto = item-doc-est.sequencia.
        end.               
    
        FOR FIRST bf-item-doc-est FIELDS (nat-of)
            WHERE bf-item-doc-est.cod-emitente = docum-est.cod-emitente
            AND   bf-item-doc-est.serie-docto  = docum-est.serie-docto
            AND   bf-item-doc-est.nro-docto    = docum-est.nro-docto
            AND   bf-item-doc-est.nat-operacao = docum-est.nat-operacao
            AND   bf-item-doc-est.it-codigo    = item-doc-est.it-codigo
            AND   bf-item-doc-est.sequencia    = item-doc-est.sequencia:
        END.
    
        assign tb-wt-it-docto.calcula         = yes
               tb-wt-it-docto.it-codigo       = item-doc-est.it-codigo
               tb-wt-it-docto.nat-operacao    = (IF  AVAIL bf-item-doc-est THEN
                                                     IF  NO AND bf-item-doc-est.nat-of <> "" THEN /* l-mult-natur-receb -> cd9701.i */
                                                         bf-item-doc-est.nat-of /* Se usa Multi. Naturezas e ela foi informada: usa ela */
                                                     ELSE docum-est.nat-operacao /* Sen’o usa a natureza da nota. */
                                                ELSE IF NO AND item-doc-est.nat-of <> "" THEN 
                                                     item-doc-est.nat-of 
                                                ELSE docum-est.nat-operacao) 
               tb-wt-it-docto.nr-sequencia    = item-doc-est.sequencia
               tb-wt-it-docto.nr-seq-nota     = 1
               tb-wt-it-docto.quantidade      = item-doc-est.quantidade
               tb-wt-it-docto.vl-merc-ori     = item-doc-est.preco-total[1]
               tb-wt-it-docto.vl-merc-liq     = tb-wt-it-docto.vl-merc-ori 
                                                - item-doc-est.desconto[1] 
               tb-wt-it-docto.vl-despes-it    = item-doc-est.desconto[1]
               tb-wt-it-docto.vl-frete        = item-doc-est.pr-total-cmi /* frete */
               tb-wt-it-docto.vl-seguro       = item-doc-est.despesas[1]
                                                - item-doc-est.pr-total-cmi /* frete */
               tb-wt-it-docto.vl-preori       = tb-wt-it-docto.vl-merc-ori 
                                                / tb-wt-it-docto.quantidade[1]
               tb-wt-it-docto.vl-preuni       = tb-wt-it-docto.vl-merc-liq 
                                               / tb-wt-it-docto.quantidade[1]
               tb-wt-it-docto.vl-merc-s-icms  = tb-wt-it-docto.vl-merc-liq
               tb-wt-it-docto.vl-merc-tab     = tb-wt-it-docto.vl-merc-liq
               /*
               ** Integracao Modulo Importacao
               ** Objetivo: gravar a serie para achar as despesas de importacao
               */
               substring(tb-wt-it-docto.char-1,1,5) = docum-est.serie-docto.

        ASSIGN overlay(tb-wt-it-docto.char-1,33,16) = SUBSTR(item-doc-est.char-2,819,13) /*Pedagio*/
               tb-wt-it-docto.un[2]                 = item-doc-est.un
               tb-wt-it-docto.class-fiscal          = item-doc-est.class-fiscal
               tb-wt-it-docto.peso-liq-it-inf       = item-doc-est.peso-liquido.

        IF  AVAIL item-doc-est THEN 
            ASSIGN tb-wt-it-docto.un[2] = item-doc-est.un.
    
        for first bf-pauta-item FIELDS (un tipo-contr)
            where bf-pauta-item.it-codigo = item-doc-est.it-codigo no-lock: end.
        
        if  avail bf-pauta-item
            and avail item-doc-est
            and bf-pauta-item.tipo-contr = 4 then do:
            
                for first bf-pauta-prazo-compra
                    fields (un)
                    where bf-pauta-prazo-compra.numero-ordem = item-doc-est.numero-ordem 
                      and bf-pauta-prazo-compra.parcela      = item-doc-est.parcela no-lock:
                end.
        
                if  not avail bf-pauta-prazo-compra then 
                    find first bf-pauta-prazo-compra 
                         where bf-pauta-prazo-compra.numero-ordem = item-doc-est.numero-ordem
                         no-lock no-error.
                    
                assign c-un-estoque = if avail bf-pauta-prazo-compra
                                          then bf-pauta-prazo-compra.un
                                      else if avail bf-pauta-item 
                                               then bf-pauta-item.un
                                           else "".
                
        end.
        else 
            assign c-un-estoque = if avail bf-pauta-item 
                                      then bf-pauta-item.un
                                  else "".
                                  

        assign tb-wt-it-docto.un[1] = c-un-estoque.

        RUN createTbWtItImposto.
           
    END.

    if  valid-handle(h_bodi317im2bra) then 
        run enviaTbWtItDocto in h_bodi317im2bra ( input table tb-wt-it-docto ) .            

    RETURN "OK":U.

END PROCEDURE.

PROCEDURE createTbWtItImposto:
   
    /*************************************/

    if  not avail docum-est then
        return "NOK":U.

    IF  NOT AVAIL item-doc-est THEN
        RETURN "NOK":U.
        
    find tb-wt-it-imposto
        where tb-wt-it-imposto.seq-wt-docto    = 1
          and tb-wt-it-imposto.seq-wt-it-docto = item-doc-est.sequencia 
        exclusive-lock no-error.

    if  not avail tb-wt-it-imposto then do:
        create tb-wt-it-imposto.
        assign tb-wt-it-imposto.seq-wt-docto    = 1
               tb-wt-it-imposto.seq-wt-it-docto = item-doc-est.sequencia.
    end.  
        
    assign tb-wt-it-imposto.perc-red-iss = natur-oper.perc-red-iss
           tb-wt-it-imposto.aliquota-ipi = item-doc-est.aliquota-ipi
           tb-wt-it-imposto.aliquota-icm = item-doc-est.aliquota-icm
           tb-wt-it-imposto.aliquota-iss = item-doc-est.aliquota-iss
           tb-wt-it-imposto.cd-trib-ipi  = item-doc-est.cd-trib-ipi
           tb-wt-it-imposto.cd-trib-icm  = item-doc-est.cd-trib-icm
           tb-wt-it-imposto.cd-trib-iss  = item-doc-est.cd-trib-iss
           tb-wt-it-imposto.ind-icm-ret  = item-doc-est.log-2 /* ICM Retido */ . 

    if  valid-handle(h_bodi317im2bra) then 
        run enviaTbWtItImposto in h_bodi317im2bra ( input table tb-wt-it-imposto ).

    /************************************/

END PROCEDURE.

/* Procedure adicionada para tratar os novos tipos de impostos GILRAT e SENAR */

PROCEDURE salvaTipoImpostoSenarGilrat:
    
    IF c-ind-tip-impto = "Inst Nacional Seguro Social (INSS)" THEN DO:
        IF tt_integr_imptos_pgto_apb.ttv_log_gilrat THEN
            ASSIGN c-ind-tip-impto = "GILRAT".

        IF tt_integr_imptos_pgto_apb.ttv_log_senar THEN
            ASSIGN c-ind-tip-impto = "SENAR".
    END.
    

END PROCEDURE.
