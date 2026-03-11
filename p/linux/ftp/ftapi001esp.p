/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FTAPI001 2.00.00.034 } /*** 010034 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ftapi001 MFT}
&ENDIF

/************************************************************************
**
** FTAPI001.P - Integra‡Æo Notas Faturamento x Contas a Receber 
**
*************************************************************************/

/* Defini‡Æo vari veis integra‡Æo FT x CR */

{cdp/cdcfgdis.i}  /* pre-processador */
{cdp/cdcfgfin.i}  /* pre-processadores financeiro */
{cdp/cdcfgcex.i}  /* Pre-Processadores COMEX      */
{crp/crapi001c.i} /* Temp-Tables API Implanta‡Æo de Documentos CR.*/
{crp/crapi009.i}  /* Defini‡Æo de temp-tables */
{utp/ut-glob.i}
{ftp/ftapi001.i}
{ftp/ftapi207.i}  /* Multi-planta */
{method/dbotterr.i}
{crp/cr0501d.i4}

/* Defini‡Æo temp-table de erros na integra‡Æo com CR */
def temp-table tt_log_erros_atualiz_vdr no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento".


/*Inicio Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/
DEF VAR i-empresaCtContabel LIKE param-global.empresa-prin NO-UNDO.
def var h_api_cta          as handle no-undo.
def var h_api_ccust        as handle no-undo.
def var v_cod_cta          as char   no-undo.
def var v_des_cta          as char   no-undo.
def var v_cod_ccust        as char   no-undo.
def var v_des_ccust        as char   no-undo.
def var v_cod_format_cta   as char   no-undo.
def var v_cod_format_ccust as char   no-undo.
def var v_cod_format_inic  as char   no-undo.
def var v_cod_format_fim   as char   no-undo.
def var v_ind_finalid_cta  as char   no-undo.
def var v_num_tip_cta      as int    no-undo.
def var v_num_sit_cta      as int    no-undo.
def var v_log_utz_ccust    as log    no-undo.


def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia".

/*Fim Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/


/* Temp-table definida para manter compatibilidade com a crapi009 */
def temp-table tt-ext-lin-i-cr-aux no-undo like lin-i-cr
    field tp-ret-iva   as int  format ">>>9"
    field tp-ret-gan   as int  format ">>9"
    field acum-ant-gan as dec  format ">>>,>>9.99"      decimals 2
    field vl-base-gan  as dec  format ">>>,>>9.99"      decimals 2
    field gravado      as dec  format ">>>,>>>,>>9.99"  decimals 2
    field no-gravado   as dec  format ">>>,>>>,>>9.99"  decimals 2
    field isento       as dec  format ">>>,>>>,>>9.99"  decimals 2
    field uf-entrega   as char format "x(4)".

/*** Impostos USA ***/
&IF DEFINED(BF_DIS_VERSAO_EMS) &THEN
     &IF '{&BF_DIS_VERSAO_EMS}' >= '2.042' &THEN
            {ftp/ftapi001.i1}
     &ENDIF
&ENDIF

/* Tabela para nao ocorrer problemas na include cd7300.i4 */
def temp-table tt-param
    field usuario as char.
do  trans:
    create tt-param. 
    assign tt-param.usuario = c-seg-usuario.
end.

/* Defini‡Æo de Parƒmetros */
def input  parameter i-versao-integracao as int                 no-undo.
def input  parameter i-cod-pais-imposto  as int                 no-undo.
def input  parameter i-portador          like mgadm.portador.cod-port no-undo.
def input  parameter i-gera-titulo       as int                 no-undo.
def input  parameter c-arquivo-exp       as char                no-undo.
def input  parameter table for tt-nota-fiscal.
def output parameter table for tt-retorno-nota-fiscal.
def output parameter table for tt-total-refer.

/* Defini‡Æo de stream */
def stream s-exporta.

/* Defini‡Æo de vari veis */
def new shared var c-referencia like lin-i-cr.referencia no-undo.

DEF VAR l-grava-var    AS LOG    INIT YES NO-UNDO.
DEF VAR l-comissao-epc as log    no-undo.
DEF VAR h-acomp        as handle no-undo.
DEF VAR i-time         AS INT    NO-UNDO.
DEF VAR h-api          as handle no-undo.
DEF VAR h-ftapi016     as handle no-undo.
DEF VAR c-acomp-titulo as char   no-undo.
DEF VAR c-acomp-nota   as char   no-undo.
DEF VAR c-acomp-duplic as char   no-undo.
DEF VAR c-acomp-mp     as char   no-undo.
DEF VAR c-ref-aux      as char   no-undo.
DEF VAR i-seq-erro     AS INT                           NO-UNDO.
DEF VAR l-nr-processo  AS LOG                           NO-UNDO.
DEF VAR l-erro-repres  AS LOG                           NO-UNDO.
DEF VAR de-tot-nf-me       as decimal decimals 5        NO-UNDO.
DEF VAR de-tot-vl-tot-nota AS DECIMAL INIT 0            NO-UNDO.
DEF VAR de-tot-vl-tot-merc AS DECIMAL INIT 0            NO-UNDO.
DEF VAR de-vl-aprop-me     AS DECIMAL                   NO-UNDO.
DEF VAR i-empresa     like param-global.empresa-prin    NO-UNDO.
DEF VAR c-estabelec as char                             NO-UNDO.
DEF var l-gerou-tt-nota-db-cr as logi                   NO-UNDO.
DEF VAR de-gravable    like it-nota-fisc.vl-merc-liq    NO-UNDO.
DEF VAR de-no-gravable like it-nota-fisc.vl-merc-liq    NO-UNDO.
DEF VAR de-exento      like it-nota-fisc.vl-merc-liq    NO-UNDO.
DEF VAR de-base-imp    like nota-fiscal.vl-tot-nota     NO-UNDO.
DEF VAR l-ems5             as logical                   NO-UNDO.
DEF VAR rw-maior-parc      as rowid                     NO-UNDO.
DEF VAR de-acum-vl-parc-me as decimal decimals 5        NO-UNDO.
DEF VAR de-maior-parc-me   as decimal decimals 5        NO-UNDO.
DEF VAR v-dt-venciment     LIKE fat-duplic.dt-venciment NO-UNDO.
DEF VAR v-dt-desconto      LIKE fat-duplic.dt-desconto  NO-UNDO.
DEF VAR i-cont-nota-trans AS INTEGER NO-UNDO. /* contador auxiliar */
DEF VAR i-nr-nota-a-nota AS INTEGER NO-UNDO. /* n£mero de notas por transa‡Æo, gravado no campo funcao.int-1 */
DEF VAR l-last-dupli  AS LOG NO-UNDO.
DEF VAR l-first-dupli AS LOG NO-UNDO.
DEF VAR l-iva         AS LOG NO-UNDO.
DEF VAR c-cgc         AS CHAR NO-UNDO.
DEF VAR c-cod-emitente LIKE nota-fiscal.cod-emitente NO-UNDO.
DEF VAR l-continua    AS LOG INIT NO NO-UNDO.
DEFINE VARIABLE l-comissao-por-item AS LOGICAL INIT NO NO-UNDO.


{dibo/bodi317.i7} /* l-america-latina */ 

/* Verifica o n£mero de notas que serÆo atualizadas em uma £nica transa‡Æo */
/* O n£mero m ximo estÿ gravado no campo fun‡Æo.int-1                      */
DEF TEMP-TABLE tt-nf-por-transacao NO-UNDO
    FIELD r-nota-fis AS ROWID
    INDEX idx1 r-nota-fis.

FOR FIRST funcao NO-LOCK
    where funcao.cd-funcao = "ems5-nota-a-nota"
      and   funcao.ativo     = YES:
    ASSIGN i-nr-nota-a-nota = funcao.int-1.
END.
/* campos que podem ser manipulados por epc */
DEF VAR dt-venciment-epc   LIKE fat-duplic.dt-venciment  NO-UNDO.
DEF VAR dt-desconto-epc LIKE fat-duplic.vl-desconto   NO-UNDO.   /*de-vl-desconto-epc*/

def var l-funcao-spp-fatura as log no-undo.
assign l-funcao-spp-fatura = can-find(funcao where funcao.cd-funcao = "spp-fat-ser-est"
                                             and   funcao.ativo).

/* Engenharia Comissoes Agentes Externos */
DEFINE VARIABLE l-integ-mcr-ems5 AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE l-spp-comagext   AS LOGICAL INITIAL NO NO-UNDO.

&IF "{&bf_cex_versao_ems}":U >= "2.062":U &THEN
    ASSIGN l-spp-comagext = YES.
&ELSE
    &IF "{&bf_dis_versao_ems}":U >= "2.04":U &THEN
        ASSIGN l-spp-comagext = CAN-FIND (FIRST funcao
                                          WHERE funcao.cd-funcao = "spp-comagext":U AND
                                                funcao.ativo     = YES).
    &ENDIF
&ENDIF

define buffer b-nota-fiscal        for nota-fiscal.
define buffer b-nota-fiscal-fatura for nota-fiscal.

find first param-global no-lock no-error.
find first para-ped     no-lock no-error.
find first para-fat     no-lock no-error.

/****************************** Vendor ***********************************/
assign l-vendor = no.
if param-global.modulo-05 then 
    assign l-vendor = yes.
/*************************************************************************/

{include/i-epc200.i ft0603rp}
DEF VAR p-c-retorno-epc AS CHAR NO-UNDO.

assign v_cod_usuar_corren = c-seg-usuario.

find first comissao where comissao.situacao = 1 no-lock no-error.
assign l-comissao = if  avail comissao then yes else no.

assign l-confirma = no.

DEF VAR h-bodi390 AS HANDLE NO-UNDO.

/************************************************************************/
if  i-versao-integracao <> 3 then do:
    run utp/ut-msgs.p (input "msg",
                       input 3941,
                       input "").
     
     
    create tt-retorno-nota-fiscal.
    assign tt-retorno-nota-fiscal.tipo      = 1
           tt-retorno-nota-fiscal.cod-erro  = "3941"
           tt-retorno-nota-fiscal.desc-erro = return-value
           tt-retorno-nota-fiscal.situacao  = no
           tt-retorno-nota-fiscal.cod-chave = ",,,,,,,,,".
    return.
end.

/************************************************************************/
if can-find(funcao where funcao.cd-funcao = "adm-acr-ems-5.00" 
                     and funcao.ativo     = yes
                     and funcao.log-1     = yes) 
THEN DO:
    /* Engenharia Comissoes Agentes Externos */
    ASSIGN l-integ-mcr-ems5 = YES.

    IF param-global.modulo-mp = NO
    THEN assign l-ems5 = yes.
    ELSE DO: /* param-global.modulo-mp = YES */
        RUN ftp/ftapi001a.p. /* verifica‡Æo de transa‡Æo do mp adm046 */
        IF RETURN-VALUE = "NOK":U 
        THEN assign l-ems5 = yes.
    END.
END.

find first param-cr NO-LOCK NO-ERROR.

/* Se o param-cr nÆo estiver aval e nÆo tiver integra‡Æo com o 5 e Gera‡Æo CR estiver igual ¹ Integra, apresenta par³metro n cadastrado*/
if not avail param-cr and not l-ems5 and avail para-fat and para-fat.int-exp-cr = 1 then do:
    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-parametros-do-contas-a-receber AS CHARACTER   NO-UNDO.
    {utp/ut-liter.i "Parƒmetros_do_Contas_a_Receber_nÆo_cadastrado._Ajuda:_Para_que_os_t¡tulos_possam_ser_enviados_para_o_m¢dulo_do_ACR_deve_obrigatoriamente_existir_cadastro_dos_par metros_do_ACR" *}
    ASSIGN c-lbl-liter-parametros-do-contas-a-receber = RETURN-VALUE.
    run utp/ut-msgs.p (input "msg",
                       input 17006,
                       input c-lbl-liter-parametros-do-contas-a-receber).
      
    create tt-retorno-nota-fiscal.
    assign tt-retorno-nota-fiscal.tipo      = 1
           tt-retorno-nota-fiscal.cod-erro  = "17006"
           tt-retorno-nota-fiscal.desc-erro = c-lbl-liter-parametros-do-contas-a-receber
           tt-retorno-nota-fiscal.situacao  = no
           tt-retorno-nota-fiscal.cod-chave = ",,,,,,,,,".
    return.
end.

{utp/ut-liter.i "Atualizando_Contas_a_Receber" * R}
assign c-acomp-titulo = trim(return-value).
{utp/ut-liter.i "Gerando_dados_da_nota" * R}
assign c-acomp-nota = trim(return-value).
{utp/ut-liter.i "Gerando_dados_das_duplicatas" * R}
assign c-acomp-duplic = trim(return-value).
{utp/ut-liter.i "Atualizando_dados_Multiplanta" * R}
assign c-acomp-mp = trim(return-value).
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input c-acomp-titulo).

/* Tratamento para criar um novo arquivo, quando a op‡Æo de integra‡Æo for exporta.
   Isto ‚ necess rio pois foi implementado a op‡Æo "append" no output da procedure 
   pi-exporta-dados para nÆo sobrepor as notas atualizadas */ 

if  para-fat.int-exp-cr = 2 then do :
    output stream s-exporta to value(c-arquivo-exp).
    output stream s-exporta close.
end.

if  no then do:
    find first estabelec NO-LOCK NO-ERROR.
    find first cond-pagto  NO-LOCK NO-ERROR.
end.

run ftp/ftapi016.p persistent set h-ftapi016 (input  ?,
                                              input  ?,
                                              output c-referencia).
assign i-empresa = param-global.empresa-prin.

RUN dibo/bodi390.p PERSISTENT SET h-bodi390.

/* SUBSTRING(para-fat.char-1,100,1): FT0301 - Aba Outros - Calcula comissÆo por item na implanta‡Æo do Pedido/Nota? */
IF AVAIL para-fat AND SUBSTRING(para-fat.char-1,100,1) = "S" 
   THEN ASSIGN l-comissao-por-item = YES.
   ELSE ASSIGN l-comissao-por-item = NO.


atualiza:
for each tt-nota-fiscal:
    for each nota-fiscal fields (nome-ab-cli dt-emis-nota mo-codigo cod-estabel
                                 serie nr-nota-fis dt-cancela nr-fatura cod-cond-pag
                                 nr-pedcli nat-operacao cod-entrega cod-portador
                                 dt-emis modalidade ind-tip-nota nr-proc-exp vl-taxa-exp
                                 estado vl-tot-nota no-ab-reppri dt-atual-cr serie-orig
                                 nro-nota-orig cdd-embarq replica-nf vl-frete vl-seguro vl-embalagem 
                                 cod-estab-proces-export log-var-cambial)
        where rowid(nota-fiscal) = tt-nota-fiscal.r-nota-fiscal NO-LOCK,
        each natur-oper of nota-fiscal NO-LOCK
        break by nota-fiscal.dt-emis-nota
              by nota-fiscal.mo-codigo
              by nota-fiscal.cod-estabel
              by nota-fiscal.serie
              by nota-fiscal.nr-nota-fis on stop undo, leave:

        FIND FIRST emitente WHERE 
                   emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.

        FOR FIRST estabelec NO-LOCK WHERE     
                  estabelec.cod-estabel = nota-fiscal.cod-estabel:  
        END.

        /* Posicionar Cliente Correspondente - Atualizar pelo CPF do Cupom Fiscal */
        IF nota-fiscal.cod-portador = 99501 OR nota-fiscal.cod-portador = 99801 THEN DO:

            ASSIGN c-cgc = ''.

            FIND FIRST cst_nota_fiscal 
                 WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                   AND cst_nota_fiscal.serie       = nota-fiscal.serie
                   AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK  NO-ERROR.
            IF AVAIL cst_nota_fiscal THEN DO:
                ASSIGN c-cod-emitente = nota-fiscal.cod-emitente.
                       c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                       c-cgc = replace(c-cgc,"/","").
                       c-cgc = replace(c-cgc,"-","").
                       
               IF emitente.cgc <> c-cgc THEN DO:

                   FIND FIRST emitente WHERE 
                              emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
                   IF AVAIL emitente AND DEC(c-cgc) >  1 THEN DO:
                      ASSIGN c-cod-emitente = emitente.cod-emitente.
                   END.
                   ELSE DO:
                       
                      CREATE tt-retorno-nota-fiscal.
                      assign tt-retorno-nota-fiscal.tipo       = 1
                             tt-retorno-nota-fiscal.cod-erro   = "4350"
                             tt-retorno-nota-fiscal.desc-erro  = "CPF Financeiro: " + string(cst_nota_fiscal.cpf_cupom) + " nÆo cadastrado." 
                             tt-retorno-nota-fiscal.situacao   = NO
                             tt-retorno-nota-fiscal.referencia = ""
                             tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                           string(i-empresa) + "," +
                                                           nota-fiscal.cod-estabel + ",," +
                                                           nota-fiscal.serie + "," +
                                                           (if nota-fiscal.nr-fatura = "" then
                                                              nota-fiscal.nr-nota-fis 
                                                           else 
                                                              nota-fiscal.nr-fatura) + ",,,".

                      NEXT.

                   END.
               END.   
            END.
            ELSE DO:
                  CREATE tt-retorno-nota-fiscal.
                  assign tt-retorno-nota-fiscal.tipo       = 1
                         tt-retorno-nota-fiscal.cod-erro   = "17006"
                         tt-retorno-nota-fiscal.desc-erro  = "ExtensÆo da Nota Fiscal nÆo foi encontrada." 
                         tt-retorno-nota-fiscal.situacao   = NO
                         tt-retorno-nota-fiscal.referencia = ""
                         tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                       string(i-empresa) + "," +
                                                       nota-fiscal.cod-estabel + ",," +
                                                       nota-fiscal.serie + "," +
                                                       (if nota-fiscal.nr-fatura = "" then
                                                          nota-fiscal.nr-nota-fis 
                                                       else 
                                                          nota-fiscal.nr-fatura) + ",,,".

                  NEXT.
             END.
            RELEASE cst_nota_fiscal.
        END.

        
/*             FOR FIRST int-ds-nota-loja NO-LOCK WHERE                                                                                                        */
/*                   int(int-ds-nota-loja.num_nota)   = int(nota-fiscal.nr-fatura) AND                                                                         */
/*                       int-ds-nota-loja.cnpj_filial = estabelec.cgc :                                                                                        */
/*             END.                                                                                                                                            */
/*                                                                                                                                                             */
/*             ASSIGN c-cgc = ''.                                                                                                                              */
/*                                                                                                                                                             */
/*             IF AVAIL int-ds-nota-loja                                                                                                                       */
/*             THEN DO:                                                                                                                                        */
/*                                                                                                                                                             */
/*                ASSIGN c-cod-emitente = nota-fiscal.cod-emitente.                                                                                            */
/*                       c-cgc = replace(int-ds-nota-loja.cpf_cliente,".","").                                                                                 */
/*                       c-cgc = replace(c-cgc,"/","").                                                                                                        */
/*                       c-cgc = replace(c-cgc,"-","").                                                                                                        */
/*                                                                                                                                                             */
/*                IF emitente.cgc <> c-cgc                                                                                                                     */
/*                THEN DO:                                                                                                                                     */
/*                                                                                                                                                             */
/*                    FIND FIRST emitente WHERE                                                                                                                */
/*                               emitente.cgc =  c-cgc NO-LOCK NO-ERROR.                                                                                       */
/*                    IF AVAIL emitente AND                                                                                                                    */
/*                            DEC(c-cgc) >  1                                                                                                                  */
/*                    THEN DO:                                                                                                                                 */
/*                       ASSIGN c-cod-emitente = emitente.cod-emitente.                                                                                        */
/*                    END.                                                                                                                                     */
/*                    ELSE DO:                                                                                                                                 */
/*                       CREATE tt-retorno-nota-fiscal.                                                                                                        */
/*                       assign tt-retorno-nota-fiscal.tipo       = 1                                                                                          */
/*                              tt-retorno-nota-fiscal.cod-erro   = "4350"                                                                                     */
/*                              tt-retorno-nota-fiscal.desc-erro  = "CPF Financeiro: " + string(int-ds-nota-loja.cpf_cliente) + " do Convˆnio nÆo cadastrado." */
/*                              tt-retorno-nota-fiscal.situacao   = NO                                                                                         */
/*                              tt-retorno-nota-fiscal.referencia = ""                                                                                         */
/*                              tt-retorno-nota-fiscal.cod-chave  = "" + ",," +                                                                                */
/*                                                            string(i-empresa) + "," +                                                                        */
/*                                                            nota-fiscal.cod-estabel + ",," +                                                                 */
/*                                                            nota-fiscal.serie + "," +                                                                        */
/*                                                            (if nota-fiscal.nr-fatura = "" then                                                              */
/*                                                               nota-fiscal.nr-nota-fis                                                                       */
/*                                                            else                                                                                             */
/*                                                               nota-fiscal.nr-fatura) + ",,,".                                                               */
/*                                                                                                                                                             */
/*                       NEXT.                                                                                                                                 */
/*                                                                                                                                                             */
/*                    END.                                                                                                                                     */
/*                                                                                                                                                             */
/*                END.                                                                                                                                         */
/*             END.                                                                                                                                            */
/*         END.        
                                                                                                                                        */
                if  c-nom-prog-upc-mg97 <> "" then do:
                  /*--------- INICIO UPC ---------*/
                  for each tt-epc where tt-epc.cod-event = "troca-empresa":
                      delete tt-epc.
                  end.
                  create tt-epc.
                  assign tt-epc.cod-event     = "troca-empresa"
                         tt-epc.cod-parameter = "nota-fiscal rowid"
                         tt-epc.val-parameter = string(rowid(nota-fiscal)).
                  create tt-epc.
                  assign tt-epc.cod-event     = "troca-empresa"
                         tt-epc.cod-parameter = "i-empresa-prin"
                         tt-epc.val-parameter =  string(i-empresa).
    
                  {include/i-epc201.i "troca-empresa"}
                  /*--------- FINAL UPC ---------*/
    
                  find first tt-epc where
                             tt-epc.cod-event     = "troca-empresa" and
                             tt-epc.cod-parameter = "i-empresa-prin" no-lock no-error.
            &IF "{&mguni_version}" >= "2.071" &THEN
            assign i-empresa = tt-epc.val-parameter.
            &ELSE
/*             assign i-empresa = integer(tt-epc.val-parameter). */
            &ENDIF
                  for each tt-epc where tt-epc.cod-event = "troca-empresa":
                     delete tt-epc.
                  end.
                  if first-of(nota-fiscal.cod-estabel) then do:
    
                       /*--------- INICIO UPC ---------*/
                       for each tt-epc where tt-epc.cod-event = "verifica-estabelec":
                           delete tt-epc.
                       end.
                       create tt-epc.
                       assign tt-epc.cod-event     = "verifica-estabelec"
                              tt-epc.cod-parameter = "nota-fiscal-estabelec"
                              tt-epc.val-parameter = nota-fiscal.cod-estabel.
                       {include/i-epc201.i "verifica-estabelec"}
                       ASSIGN l-grava-var = YES.  
                       find first tt-epc where
                                  tt-epc.cod-event     = "verifica-estabelec" and
                                  tt-epc.cod-parameter = "nota-fiscal-estabelec" no-lock no-error.
                       if  avail tt-epc 
                       AND tt-epc.val-parameter = "N" THEN ASSIGN l-grava-var = NO.
                       for each tt-epc where tt-epc.cod-event = "verifica-estabelec":
                           delete tt-epc.
                       end.
                       /*--------- FINAL UPC ---------*/
    
                  END. /* end do first-of((nota-fiscal.cod-estabel) */
              END.
    
        do  trans:
            run geracaoReferencia in h-ftapi016 (input  "F",
                                                 input  nota-fiscal.cod-estabel,
                                                 output c-referencia).
        end.
    
        ASSIGN i-cont-nota-trans = i-cont-nota-trans + 1. /*notas por transa‡Æo - fun‡Æo*/

        /*Caso se utilize a op‡Æo de atualizar trasa‡Æo por volume de notas (fun‡Æo ems5-nota-a-nota)*/
        IF  i-nr-nota-a-nota > 0 THEN DO:
            CREATE tt-nf-por-transacao.
            ASSIGN tt-nf-por-transacao.r-nota-fis = ROWID(nota-fiscal).
        END.
    
        do trans:

        
            if  not avail estabelec
            or  estabelec.cod-estabel <> nota-fiscal.cod-estabel then do:
                assign i-empresa = param-global.empresa-prin.
    
                &if defined (bf_dis_consiste_conta) &then
    
                    find estabelec where
                         estabelec.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
    
                    run cdp/cd9970.p (input rowid(estabelec),
                                      output i-empresa).
                &endif
                find first param-cr 
                     where param-cr.ep-codigo = i-empresa no-lock no-error.
            end.
    
            /* Se o param-cr nÆo estiver aval e nÆo tiver integra‡…o com o 5 e Gera‡Æo CR estiver igual ¹ Integra */
            if not avail param-cr and not l-ems5 and avail para-fat and para-fat.int-exp-cr = 1 then 
                next.     
    
            if  time - i-time > 0 then do:
                assign i-time = time.
                run pi-acompanhar in h-acomp (input c-acomp-nota + " (" + nota-fiscal.nr-nota-fis + ")").
            END.

        
            /************ Atualiza notas canceladas sem gerar t¡tulos ************/
            if  nota-fiscal.dt-cancela <> ? then do:
                find b-nota 
                     where rowid(b-nota) = tt-nota-fiscal.r-nota-fiscal EXCLUSIVE-LOCK no-error.
                assign b-nota.dt-atual-cr       = today
                       tt-nota-fiscal.atualizar = no.
                 
                create tt-retorno-nota-fiscal.
                {utp/ut-liter.i Atualizada_situa‡Æo_da_nota_cancelada * R}
                assign tt-retorno-nota-fiscal.tipo       = 1
                       tt-retorno-nota-fiscal.cod-erro   = "0000"
                       tt-retorno-nota-fiscal.desc-erro  = return-value
                       tt-retorno-nota-fiscal.situacao   = yes
                       tt-retorno-nota-fiscal.referencia = ""
                       tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                           string(i-empresa) + "," +
                                                           nota-fiscal.cod-estabel + ",," +
                                                           nota-fiscal.serie + "," +
                                                           (if nota-fiscal.nr-fatura = "" then
                                                              nota-fiscal.nr-nota-fis 
                                                           else 
                                                              nota-fiscal.nr-fatura) + ",,,".
                next.
            end.
    
            /************ Atualiza notas de diferen‡a de pre‡os de varia‡Æo cambial ***
                          sem gerar t¡tulos ************/
            if  nota-fiscal.ind-tip-nota = 3 
            and nota-fiscal.log-var-cambial
            and (   nota-fiscal.nat-operacao BEGINS "7" 
                 OR nota-fiscal.nat-operacao BEGINS "3" )
            and nota-fiscal.vl-taxa-exp <> 1 then do:
    
                find b-nota 
                     where rowid(b-nota) = tt-nota-fiscal.r-nota-fiscal EXCLUSIVE-LOCK no-error.
    
                assign b-nota.dt-atual-cr       = today
                       tt-nota-fiscal.atualizar = no.
                 
                create tt-retorno-nota-fiscal.
                {utp/ut-liter.i Atualizada_situa‡Æo_da_nota_de_diferen‡a_de_Pre‡os * R}
                assign tt-retorno-nota-fiscal.tipo       = 1
                       tt-retorno-nota-fiscal.cod-erro   = "0000"
                       tt-retorno-nota-fiscal.desc-erro  = return-value
                       tt-retorno-nota-fiscal.situacao   = yes
                       tt-retorno-nota-fiscal.referencia = ""
                       tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                           string(i-empresa) + "," +
                                                           nota-fiscal.cod-estabel + ",," +
                                                           nota-fiscal.serie + "," +
                                                           (if nota-fiscal.nr-fatura = "" then
                                                              nota-fiscal.nr-nota-fis 
                                                           else 
                                                              nota-fiscal.nr-fatura) + ",,,".
                /*** Espec¡fico Grendene ***/
                IF c-nom-prog-upc-mg97 <> "" THEN
                    run upc-nota-diferenca-cambial.
    
                if l-continua = NO then
                    next.
                ELSE DO:
                    
                    ASSIGN tt-nota-fiscal.atualizar = YES. 
                    IF AVAIL tt-retorno-nota-fiscal THEN
                        delete tt-retorno-nota-fiscal.
                END.
    
    
            end.
            if not l-ems5 then
                run pi-elimina-temp-tables. /* Elimina registros das temp tables */
    
            if  not avail estabelec
            or  estabelec.cod-estabel <> nota-fiscal.cod-estabel then
                find estabelec
                     where estabelec.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
            if  not avail cond-pagto
            or  cond-pagto.cod-cond-pag <> nota-fiscal.cod-cond-pag then
                find cond-pagto 
                     where cond-pagto.cod-cond-pag = nota-fiscal.cod-cond-pag no-lock no-error.
    
            assign de-vl-comisnota           = 0
                   i-nr-seq                  = 0
                   i-num-parcelas            = 0
                   r-registro                = tt-nota-fiscal.r-nota-fiscal
                   tt-nota-fiscal.referencia = c-referencia.
    
            find ped-venda use-index ch-pedido
                 where ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
                 and   ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli 
                 no-lock no-error.
    
            if  avail ped-venda then
                find b-repres 
                     where b-repres.nome-abrev = ped-venda.no-ab-reppri no-lock no-error.
    
            /* Internacional */
            if  i-cod-pais-imposto <> 1 then do:
                for each tt-imposto :
                    delete tt-imposto.
                end.
    
                for each tt-previsao-remito:
                   delete tt-previsao-remito.
                end.
    
                for each it-nota-fisc 
                    where it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel 
                    and   it-nota-fisc.serie       = nota-fiscal.serie       
                    and   it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis no-lock:
    
                    for first b-ped-venda fields (nr-pedido)
                        where b-ped-venda.nr-pedcli  = it-nota-fisc.nr-pedcli and
                              b-ped-venda.nome-abrev = nota-fiscal.nome-ab-cli no-lock:
                        assign c-nr-pedido = b-ped-venda.nr-pedido.      
                    end.                                   
    
                    if  it-nota-fisc.ind-fat-qtfam = yes then
                        assign de-total-item = it-nota-fisc.qt-faturada[2] * it-nota-fisc.vl-preuni.
                    else 
                        assign de-total-item = it-nota-fisc.qt-faturada[1] * it-nota-fisc.vl-preuni.
    
                    find first tt-previsao-remito 
                         where tt-previsao-remito.cod-estabel = it-nota-fisc.cod-estabel 
                         and   tt-previsao-remito.serie       = it-nota-fisc.serie-docum 
                         and   tt-previsao-remito.nr-remito   = it-nota-fisc.nr-remito no-error.
    
                    if  avail tt-previsao-remito then
                        assign tt-previsao-remito.vl-faturado = tt-previsao-remito.vl-faturado + de-total-item.
                    else do:
                        create tt-previsao-remito.
                        assign tt-previsao-remito.cod-estabel = it-nota-fisc.cod-estabel
                               tt-previsao-remito.serie       = it-nota-fisc.serie-docum
                               tt-previsao-remito.nr-remito   = it-nota-fisc.nr-remito
                               tt-previsao-remito.vl-faturado = de-total-item.
                    end.
                end.    
    
    
                /*** NOTAS CRÔDITO - INTERNACIONAL ***/
                &if defined(bf_dis_nota_credito) &then 
                    if  nota-fiscal.ind-tip-nota = 10 then do:
                        run ftp/ft0603b.p ( input tt-nota-fiscal.r-nota-fiscal,
                                            input-output table tt-retorno-nota-fiscal ).
                        ASSIGN tt-nota-fiscal.referencia = RETURN-VALUE.
    
                        next.
                    end.            
                &endif
    
            end.    
    
            if  c-nom-prog-upc-mg97 <> "" 
            OR  c-nom-prog-dpc-mg97 <> "" then DO:
                /**** DPC para calcular valores GRAVADO NO-GRAVADO e EXENTO - Argentina */
                for each tt-epc where tt-epc.cod-event = "Calcula valores":
                    delete tt-epc.
                end.
    
                create tt-epc.
                assign tt-epc.cod-event     = "Calcula valores"
                       tt-epc.cod-parameter = "nota-fiscal"
                       tt-epc.val-parameter = string(tt-nota-fiscal.r-nota-fiscal).
    
                {include/i-epc201.i "Calcula valores"}
    
                for each tt-epc where tt-epc.cod-event = "Calcula valores":
                    if tt-epc.cod-parameter = "vl-gravable" then
                       assign de-gravable = dec(tt-epc.val-parameter).
                    if tt-epc.cod-parameter = "vl-no-gravable" then
                       assign de-no-gravable = dec(tt-epc.val-parameter).
                    if tt-epc.cod-parameter = "vl-exento" then
                       assign de-exento = dec(tt-epc.val-parameter).
    
                    delete tt-epc.
                end.
    
                /**** Final DPC Argentina */
            END.
    
            /** Total da NF em moeda forte - usado na exportacao **/
            assign de-tot-nf-me       = 0
                   de-tot-vl-tot-nota = 0
                   de-tot-vl-tot-merc = 0.
    
            IF  nota-fiscal.emite-duplic 
            AND  CAN-FIND(FIRST fat-duplic 
                 WHERE fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                 AND   fat-duplic.serie         = nota-fiscal.serie
                 AND   fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
                 AND   fat-duplic.flag-atualiz  = no
                 AND  (fat-duplic.cod-esp = "CV" 
                  OR   fat-duplic.cod-esp = "CE") 
                 AND   tt-nota-fiscal.atualizar 
                 AND   int(fat-duplic.mo-negoc) <> 0 ) THEN DO:
    
                IF   para-fat.ind-pro-fat
                OR   CAN-FIND(FIRST funcao   /* Fechamento de Duplicatas por Pedido */
                              WHERE  funcao.cd-funcao = "spp-FechaDuplic"
                              AND funcao.ativo) THEN
    
                    FOR EACH b-nota-fiscal-fatura fields (vl-tot-nota cod-estabel nr-nota-fis serie 
                                                          vl-mercad vl-frete vl-seguro vl-embalagem)
                        WHERE b-nota-fiscal-fatura.cod-estabel = nota-fiscal.cod-estabel
                        AND   b-nota-fiscal-fatura.serie       = nota-fiscal.serie
                        AND   b-nota-fiscal-fatura.nr-fatura   = nota-fiscal.nr-fatura NO-LOCK:
    
                        ASSIGN de-tot-vl-tot-nota = de-tot-vl-tot-nota + b-nota-fiscal-fatura.vl-tot-nota
                               de-tot-vl-tot-merc = de-tot-vl-tot-merc + b-nota-fiscal-fatura.vl-mercad
                                                                       + b-nota-fiscal-fatura.vl-frete
                                                                       + b-nota-fiscal-fatura.vl-seguro
                                                                       + b-nota-fiscal-fatura.vl-embalagem.
    
                        FOR EACH it-nota-fisc fields (cod-estabel serie nr-nota-fis vl-mercliq-e vl-despesit-e it-nota-fisc.vl-merc-liq-me it-nota-fisc.vl-despes-it-me)
                            WHERE it-nota-fisc.cod-estabel = b-nota-fiscal-fatura.cod-estabel
                            AND   it-nota-fisc.serie       = b-nota-fiscal-fatura.serie
                            AND   it-nota-fisc.nr-nota-fis = b-nota-fiscal-fatura.nr-nota-fis NO-LOCK:
                              ASSIGN de-tot-nf-me = de-tot-nf-me +  IF   it-nota-fisc.vl-mercliq-e[1] <> 0  
                                                                    THEN it-nota-fisc.vl-mercliq-e[1] + it-nota-fisc.vl-despesit-e[1]
                                                                    ELSE it-nota-fisc.vl-merc-liq-me  + it-nota-fisc.vl-despes-it-me.
    
    
    
                        END.
                    END.
                ELSE DO:
                    ASSIGN de-tot-vl-tot-nota = nota-fiscal.vl-tot-nota
                           de-tot-vl-tot-merc = nota-fiscal.vl-mercad + nota-fiscal.vl-frete + nota-fiscal.vl-seguro + nota-fiscal.vl-embalagem.
    
                 
                    for each it-nota-fisc fields (it-nota-fisc.vl-mercliq-e it-nota-fisc.vl-despesit-e it-nota-fisc.vl-merc-liq-me it-nota-fisc.vl-despes-it-me)
                        where it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel and
                              it-nota-fisc.serie       = nota-fiscal.serie       and
                              it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis no-lock: 
                        ASSIGN de-tot-nf-me = de-tot-nf-me +  IF   it-nota-fisc.vl-mercliq-e[1] <> 0  
                                                              THEN it-nota-fisc.vl-mercliq-e[1] + it-nota-fisc.vl-despesit-e[1]
                                                              ELSE it-nota-fisc.vl-merc-liq-me  + it-nota-fisc.vl-despes-it-me.
    
    
                    end.
                END.
            END.
    
            assign l-gerou-tt-nota-db-cr = NO
                   de-maior-parc-me      = 0
                   de-acum-vl-parc-me    = 0
                   rw-maior-parc         = ?
                   l-nr-processo         = (   (   nota-fiscal.ind-tip-nota = 1
                                                or nota-fiscal.ind-tip-nota = 4
                                                or nota-fiscal.ind-tip-nota = 3)
                                            and (   emitente.natureza          = 3
                                                 or emitente.natureza          = 4)
                                            and nota-fiscal.nr-proc-exp > "0"
                                            and para-fat.ind-docum-fatura  = 2).   

            /* Duplicatas da nota */
            fat-dup: 
            for each fat-duplic use-index ch-fatura
                where fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                and   fat-duplic.serie         = nota-fiscal.serie
                and   fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
                and   fat-duplic.flag-atualiz  = no
                AND  (fat-duplic.cod-esp = "CV"
                 OR   fat-duplic.cod-esp = "CE") 
                and   tt-nota-fiscal.atualizar = yes no-lock
                break by fat-duplic.nr-fatura:
                
                if  time - i-time > 0 then do:
                    assign i-time = time.
                    run pi-acompanhar in h-acomp (input c-acomp-duplic       + " (" + 
                                              nota-fiscal.nr-nota-fis + "/"  + 
                                              string(fat-duplic.parcela) + ")").
                END.
    
                if  fat-duplic.ind-fat-nota <> 1 then do:
                    tt-nota-fiscal.atualizar = no.
                    next fat-dup.
                end.
    
                if  l-ems5 
                and can-find (tt-fat-duplic-lido of fat-duplic) then next. 
    
                assign i-num-parcelas = i-num-parcelas + 1
                       de-comis-tot   = 0.                
    
                accumulate fat-duplic.vl-parcela (total by fat-duplic.nr-fatura).
    
                FIND FIRST esp-doc 
                    WHERE  esp-doc.cod-esp = fat-duplic.cod-esp NO-LOCK NO-ERROR.
    
                 /* Notas de Cr‚dito de D‚bito nÆo vinculadas devem ser levadas como Antecipa‡Æo para o EMS 5 */
                ASSIGN c-cod-esp = IF (   nota-fiscal.ind-tip-nota = 10 
                                       OR nota-fiscal.ind-tip-nota = 9)
                                   AND nota-fiscal.nro-nota-orig = "":U 
                                   AND l-ems5
                                   THEN esp-doc.esp-ligacao
                                   ELSE fat-duplic.cod-esp.
    
                find b-emitente
                     where b-emitente.cod-emitente = emitente.end-cobranca
                     no-lock no-error.
    
                /*find conta-contab 
                     where conta-contab.ep-codigo = i-empresa
                     and conta-contab.ct-codigo   = fat-duplic.ct-recven
                     and conta-contab.sc-codigo   = fat-duplic.sc-recven no-lock no-error.*/
    
                if l-ems5 then do:
                    /*** Ter por finalidade prever o processo gera‡Æo fatura evitando 
                         registros duplicados sendo levados para o CR ***/
                    create tt-fat-duplic-lido. 
                    assign tt-fat-duplic-lido.cod-estabel  = fat-duplic.cod-estabel
                           tt-fat-duplic-lido.serie        = fat-duplic.serie
                           tt-fat-duplic-lido.nr-fatura    = fat-duplic.nr-fatura
                           tt-fat-duplic-lido.ind-fat-nota = fat-duplic.ind-fat-nota
                           tt-fat-duplic-lido.flag-atualiz = fat-duplic.flag-atualiz
                           tt-fat-duplic-lido.parcela      = fat-duplic.parcela.
                end.
    
                if  l-funcao-spp-fatura then
                    for first ser-estab 
                        where ser-estab.serie       = fat-duplic.serie
                        and   ser-estab.cod-estabel = fat-duplic.cod-estabel no-lock:
                end.
    
                ASSIGN v-dt-venciment = fat-duplic.dt-venciment
                       v-dt-desconto  = fat-duplic.dt-desconto.
    
                IF c-nom-prog-upc-mg97 <> "" THEN DO:
                    /*INICIO CHAMADA UPC*/
                    FOR EACH tt-epc WHERE tt-epc.cod-event = "fat-duplic":
                        DELETE tt-epc.
                    END.
    
                    CREATE tt-epc.
                    ASSIGN tt-epc.cod-event     = "fat-duplic":U
                           tt-epc.cod-parameter = "fat-duplic rowid":U
                           tt-epc.val-parameter = STRING(ROWID(fat-duplic)).
    
                    {include/i-epc201.i "fat-duplic"}
    
                    IF  RETURN-VALUE = "OK":U THEN DO:
                        FIND FIRST tt-epc
                             WHERE tt-epc.cod-event     = "fat-duplic":U
                               AND tt-epc.cod-parameter = "dt-venciment":U NO-ERROR.
                        IF AVAIL tt-epc THEN DO:
                        ASSIGN v-dt-desconto  = IF fat-duplic.vl-desconto <> 0 THEN 
                                                       DATE(tt-epc.val-parameter)
                                                   ELSE
                                                       fat-duplic.dt-desconto
                                    v-dt-venciment = DATE(tt-epc.val-parameter).
                        END.
                    END.
                    /*FINAL CHAMADA UPC*/
                END.
    
                FOR FIRST distrib-emit-estab
                    WHERE distrib-emit-estab.cod-estabel  = fat-duplic.cod-estabel
                      AND distrib-emit-estab.cod-emitente = emitente.cod-emitente NO-LOCK:
                END.
    
                create tt-lin-i-cr.
    
                RUN pi-cria-tt-lin-i-cr.
    
                /****/
    
                /*--------- Inicio - UPc para atualizar o tipo de receita  ---------*/
        
                RUN ExecutaEpc (INPUT "Atualiza valores",
                                OUTPUT p-c-retorno-epc ) .
        
                IF  p-c-retorno-epc <> "" then
                    assign tt-lin-i-cr.tp-codigo = INT(p-c-retorno-epc). 
        
                /*--------- Fim da upc para atualizar o tipo de receita  ---------*/  
    
                /*--------- Inicio - upc para atualizar condi‡Æo de pagamento da Parcela de ICMST  ---------*/
    
                RUN ExecutaEpc (INPUT "Condicao Pagto",
                                OUTPUT p-c-retorno-epc ).
        
                IF  p-c-retorno-epc <> "" THEN
                    assign tt-lin-i-cr.cod-cond-pag = INT(p-c-retorno-epc). 
        
                /*--------- Fim da upc para atualizar condi‡Æo de pagamento da Parcela de ICMST  ---------*/
                
    
                /*--------- Inicio - UPc para atualizar o portador Modalidae ---------*/
                IF  c-nom-prog-upc-mg97 <> "" THEN DO:
                    FOR EACH tt-epc:
                        DELETE tt-epc.
                    END.
                    CREATE tt-epc.
                    ASSIGN tt-epc.cod-event     = "AtualizaPortModal"
                           tt-epc.cod-parameter = "rowid-fat-duplic"
                           tt-epc.val-parameter = STRING(ROWID(fat-duplic)).
                    CREATE tt-epc.
                    ASSIGN tt-epc.cod-event     = "AtualizaPortModal"
                           tt-epc.cod-parameter = "cod-portador"
                           tt-epc.val-parameter = STRING(tt-lin-i-cr.cod-portador).
                    CREATE tt-epc.
                    ASSIGN tt-epc.cod-event     = "AtualizaPortModal"
                           tt-epc.cod-parameter = "modalidade"
                           tt-epc.val-parameter = STRING(tt-lin-i-cr.modalidade).
                    {include/i-epc201.i "AtualizaPortModal"}
                    FOR EACH tt-epc 
                        WHERE tt-epc.cod-event = "AtualizaPortModal":
                        IF  tt-epc.cod-parameter = "cod-portador" THEN
                            ASSIGN tt-lin-i-cr.cod-portador = INT(tt-epc.val-parameter).
                        IF  tt-epc.cod-parameter = "modalidade" THEN 
                            ASSIGN tt-lin-i-cr.modalidade = INT(tt-epc.val-parameter).
                        DELETE tt-epc.
                    END.
                END.
                /*--------- Fim da upc para atualizar o portador modalidade  ---------*/  
    
                /* Integracao M¢dulo Cƒmbio */
                &if defined(bf_fin_modul_cambio) &then
                    assign tt-lin-i-cr.nr-proc-exp = nota-fiscal.nr-proc-exp.
                &endif
    
                /***Percentual de Desconto Antecipado***/
                &IF DEFINED(BF_DIS_VERSAO_EMS) &THEN
                  &IF '{&BF_DIS_VERSAO_EMS}' >= '2.03' &THEN
                                     
                      assign tt-lin-i-cr.perc-desc-an = fat-duplic.perc-desc-an.
    
                  &ENDIF
                &ENDIF
    
                /******************************************/
                /* Pre-processado Faturamento outra Moeda */
                /******************************************/
                &if  defined (bf_dis_fat_moeda) &then 
                 do:
                    if  nota-fiscal.mo-codigo = '0' 
                    or  nota-fiscal.mo-codigo = " " then
                    do:
    
                        assign tt-lin-i-cr.mo-codigo        = fat-duplic.mo-negoc 
                               tt-lin-i-cr.cotacao-dia      = 1.
    
                        if  fat-duplic.mo-negoc <> 0 then do:
    
                            find b-fat-duplic where rowid(b-fat-duplic) = rowid(fat-duplic) exclusive-lock no-error.
                                /** Ivomar - alterado para acumular o valor em moeda forte e ratear pelo valor da parcela **/
                            /*--------- Inicio - UPc para alterar a base da comissao em moeda estrangeira  ---------*/
                            IF  c-nom-prog-upc-mg97 <> "" THEN DO:
                                FOR EACH tt-epc:
                                    DELETE tt-epc.
                                END.
                                CREATE tt-epc.
                                ASSIGN tt-epc.cod-event     = "Trata-tt-lin-i-cr"
                                       tt-epc.cod-parameter = "rowid-Nota-Fiscal"
                                       tt-epc.val-parameter = STRING(ROWID(nota-fiscal)).
                                CREATE tt-epc.
                                ASSIGN tt-epc.cod-event     = "Trata-tt-lin-i-cr"
                                       tt-epc.cod-parameter = "rowid-fat-Duplic"
                                       tt-epc.val-parameter = STRING(ROWID(fat-duplic)).
                                CREATE tt-epc.
                                ASSIGN tt-epc.cod-event     = "Trata-tt-lin-i-cr"
                                       tt-epc.cod-parameter = "handle-tt-lin-i-cr"
                                       tt-epc.val-parameter = string(temp-table tt-lin-i-cr:handle).
                                {include/i-epc201.i "Trata-tt-lin-i-cr"}
                                FOR EACH tt-epc 
                                    WHERE tt-epc.cod-event = "Trata-tt-lin-i-cr":
                                    IF  tt-epc.cod-parameter = "de-tot-vl-tot-nota" THEN
                                        ASSIGN de-tot-vl-tot-nota = INT(tt-epc.val-parameter).
                                    DELETE tt-epc.
                                 END.
                            END.
                            /*--------- Fim da upc para alterar a base da comissao em moeda estrangeira  ---------*/  
    
                            assign tt-lin-i-cr.vl-bruto-me    = de-tot-nf-me * fat-duplic.vl-parcela  / de-tot-vl-tot-nota
                                   tt-lin-i-cr.vl-desconto-me = de-tot-nf-me * fat-duplic.vl-desconto / de-tot-vl-tot-nota 
                                   tt-lin-i-cr.vl-liquido-me  = de-tot-nf-me * fat-duplic.vl-comis    / de-tot-vl-tot-nota
                                   tt-lin-i-cr.vl-fatura-me   = de-tot-nf-me * fat-duplic.vl-parcela  / de-tot-vl-tot-nota
                                   b-fat-duplic.vl-parcela-me   = tt-lin-i-cr.vl-bruto-me
                                   b-fat-duplic.vl-comis-me     = tt-lin-i-cr.vl-liquido-me
                                   b-fat-duplic.vl-desconto-me  = tt-lin-i-cr.vl-desconto-me
                                   de-acum-vl-parc-me           = de-acum-vl-parc-me + tt-lin-i-cr.vl-fatura-me
                                   tt-lin-i-cr.cotacao-dia      = fat-duplic.vl-parcela / b-fat-duplic.vl-parcela-me.
    
                            &IF '{&bf_dis_versao_ems}' >= '2.062' &THEN
                                 IF  l-america-latina THEN
                                     ASSIGN de-vl-aprop-me               = de-tot-nf-me * fat-duplic.val-base-contrib-social / de-tot-vl-tot-merc
                                            tt-lin-i-cr.cotacao-dia      = tt-lin-i-cr.vl-base-calc-ret / de-vl-aprop-me
                                            tt-lin-i-cr.vl-base-calc-ret = de-vl-aprop-me.
                            &ENDIF
                            if tt-lin-i-cr.vl-bruto-me > de-maior-parc-me then
                                assign de-maior-parc-me = tt-lin-i-cr.vl-bruto-me
                                       rw-maior-parc    = rowid(tt-lin-i-cr).
    
                        end.
                        ELSE DO:  
                             assign tt-lin-i-cr.vl-bruto-me      = fat-duplic.vl-parcela  / tt-lin-i-cr.cotacao-dia
                                    tt-lin-i-cr.vl-liquido-me    = fat-duplic.vl-comis    / tt-lin-i-cr.cotacao-dia
                                    tt-lin-i-cr.vl-fatura-me     = fat-duplic.vl-parcela  / tt-lin-i-cr.cotacao-dia
                                    tt-lin-i-cr.vl-desconto-me   = fat-duplic.vl-desconto / tt-lin-i-cr.cotacao-dia.      
    
                            &IF '{&bf_dis_versao_ems}' >= '2.062' &THEN
                                 IF  l-america-latina THEN
                                     ASSIGN tt-lin-i-cr.vl-base-calc-ret = fat-duplic.val-base-contrib-social / tt-lin-i-cr.cotacao-dia.
                            &ENDIF
                        END.
                    end.
                    else
                    do:
                        assign tt-lin-i-cr.mo-codigo        = integer(nota-fiscal.mo-codigo) 
                               tt-lin-i-cr.cotacao-dia      = nota-fiscal.vl-cotacao-fatur
                               tt-lin-i-cr.vl-bruto-me      = fat-duplic.vl-parcela-me
                               tt-lin-i-cr.vl-liquido-me    = fat-duplic.vl-comis-me
                               tt-lin-i-cr.vl-fatura-me     = fat-duplic.vl-parcela-me
                               tt-lin-i-cr.vl-desconto-me   = fat-duplic.vl-desconto-me.
                    end.
                 end.
                &else
                    assign tt-lin-i-cr.mo-codigo        = fat-duplic.mo-negoc 
                           tt-lin-i-cr.cotacao-dia      = if  tt-lin-i-cr.mo-codigo <> 0
                                                          then nota-fiscal.vl-taxa-exp
                                                          else 1 
                           tt-lin-i-cr.vl-bruto-me      = fat-duplic.vl-parcela / tt-lin-i-cr.cotacao-dia
                           tt-lin-i-cr.vl-liquido-me    = fat-duplic.vl-comis / tt-lin-i-cr.cotacao-dia
                           tt-lin-i-cr.vl-fatura-me     = fat-duplic.vl-parcela / tt-lin-i-cr.cotacao-dia
                           tt-lin-i-cr.vl-desconto-me   = fat-duplic.vl-desconto / tt-lin-i-cr.cotacao-dia
                &endif.
    
                /******************************************/
                /* Pre-processado Faturamento outra Moeda */
                /******************************************/
    
                    /*find conta-contab 
                    where conta-contab.ep-codigo = i-empresa
                    and conta-contab.ct-codigo   = fat-duplic.ct-recven
                    and conta-contab.sc-codigo   = fat-duplic.sc-recven no-lock no-error.*/
    
                    run prgint/utb/utb743za.py persistent set h_api_cta.
                    run pi_valida_conta_contabil in h_api_cta (input  i-empresa,                /* EMPRESA EMS2 */
                                                               input  fat-duplic.cod-estabel,   /* ESTABELECIMENTO EMS2 */
                                                               input  "",                       /* UNIDADE NEGàCIO */
                                                               input  "",                       /* PLANO CONTAS */ 
                                                               input  fat-duplic.ct-recven,     /* CONTA */
                                                               input  "",                       /* PLANO CCUSTO */ 
                                                               input  fat-duplic.sc-recven,     /* CCUSTO */
                                                               input  today,                    /* DATA TRANSACAO */
                                                               output table tt_log_erro).       /* ERROS */
    
                    DELETE OBJECT h_api_cta.
                    assign de-abatim                    = 0
                           de-vl-total                  = de-vl-total + fat-duplic.vl-parcela
                           de-vl-vista                  = de-vl-vista + 
                                                          if  fat-duplic.cod-vencto = 2
                                                          then fat-duplic.vl-parcela
                                                          else 0
                           de-vl-prazo                  = de-vl-prazo +
                                                          if  fat-duplic.cod-vencto = 2
                                                          then 0
                                                          else fat-duplic.vl-parcela
                           c-conta                      = IF RETURN-VALUE = "OK" THEN
                                                             fat-duplic.ct-recven
                                                          ELSE "" /*if avail conta-contab 
                                                          then conta-contab.conta-contabil
                                                          else "".*/
                           c-ccusto                     = IF RETURN-VALUE = "OK" THEN
                                                             fat-duplic.sc-recven
                                                          ELSE "".
    
                /* No Brasil o par³metro log-1 nÆo ‚ utilizado */
                if  i-cod-pais-imposto = 1 then /* Brasil */
                   assign  tt-lin-i-cr.log-1 = no.
    
                IF  emitente.calcula-multa 
                AND NOT l-ems5 
                AND AVAIL para-fat 
                AND para-fat.int-exp-cr = 1 THEN  DO:
               /* Buscar os valores da nova tabela */
                    {crp/cr0501d.i3 "tt-lin-i-cr.dt-emissao"
                                    "de-perc-juro"
                                    "i-car-juro"
                                    "de-valor-min"
                                    "l-gera-ad"
                                    "de-perc-multa"
                                    "i-car-multa"
                                    "i-tp-juros"
                                    "i-mo-vl-min"}
                   
                    assign tt-lin-i-cr.dt-multa = tt-lin-i-cr.dt-vencimen + i-car-multa
                           tt-lin-i-cr.perc-multa = de-perc-multa.
                end.
                else assign tt-lin-i-cr.dt-multa = ?
                            tt-lin-i-cr.perc-multa = 0.
    
                /*--------- INICIO UPC SEVEN BOYS ---------*/
                
                RUN ExecutaEpc (INPUT "eseven1",
                                OUTPUT p-c-retorno-epc ) .
    
                if  l-seven AND p-c-retorno-epc <> "yes" then
                    assign tt-lin-i-cr.perc-multa = DECIMAL(p-c-retorno-epc). 
                
                /*--------- FINAL UPC SEVEN BOYS ---------*/         
    
                /*Alterado para testar apenas se o banco LCARG estÿ conectado e nÆo mais se o 
                  pais dos impostos ‚ argentina..... isto ‚ necessÿrio pois os clientes do uruguai
                  irÆo utilizar o LCARG e algumas DPC‹S de cÿlculo mas o pa¡s de impostos serÿ a 
                  URUGUAY*/
                if  connected("lcarg") then do: 
    
                   find loc-entr 
                        where loc-entr.nome-abrev  = nota-fiscal.nome-ab-cli
                        and   loc-entr.cod-entrega = nota-fiscal.cod-entrega
                        no-lock no-error.
                   create tt-ext-lin-i-cr.
                   assign tt-ext-lin-i-cr.ep-codigo    = tt-lin-i-cr.ep-codigo
                          tt-ext-lin-i-cr.cod-estabel  = tt-lin-i-cr.cod-estabel
                          tt-ext-lin-i-cr.cod-esp      = tt-lin-i-cr.cod-esp
                          tt-ext-lin-i-cr.serie        = tt-lin-i-cr.serie
                          tt-ext-lin-i-cr.nr-docto     = tt-lin-i-cr.nr-docto
                          tt-ext-lin-i-cr.parcela      = tt-lin-i-cr.parcela
                          tt-ext-lin-i-cr.referencia   = tt-lin-i-cr.referencia
                          tt-ext-lin-i-cr.sequencia    = tt-lin-i-cr.sequencia
                          tt-ext-lin-i-cr.seq-import   = tt-lin-i-cr.seq-import
                          tt-ext-lin-i-cr.dt-vencimen  = tt-lin-i-cr.dt-vencimen
                          tt-ext-lin-i-cr.dt-emissao   = tt-lin-i-cr.dt-emissao
                          tt-ext-lin-i-cr.cod-emitente = tt-lin-i-cr.cod-emitente
                          tt-ext-lin-i-cr.uf-entrega   = if avail loc-entr 
                                                         then loc-entr.estado
                                                         else nota-fiscal.estado
                          de-base-imp                  = de-gravable + de-no-gravable + de-exento.
                   if last-of(fat-duplic.nr-fatura) then do:
                      if int(fat-duplic.parcela) <> 1 then 
                         assign tt-ext-lin-i-cr.gravado    = ( (fat-duplic.vl-comis / de-base-imp) 
                                                               * de-gravable   )      / tt-lin-i-cr.cotacao-dia
                                tt-ext-lin-i-cr.no-gravado = ( (fat-duplic.vl-comis / de-base-imp) 
                                                              * de-no-gravable )      / tt-lin-i-cr.cotacao-dia
                                tt-ext-lin-i-cr.isento     = ( (fat-duplic.vl-comis / de-base-imp) 
                                                               * de-exento     )      / tt-lin-i-cr.cotacao-dia.
                      else /* somente uma parcela */
                          assign tt-ext-lin-i-cr.gravado    = de-gravable    / tt-lin-i-cr.cotacao-dia
                                 tt-ext-lin-i-cr.no-gravado = de-no-gravable / tt-lin-i-cr.cotacao-dia
                                 tt-ext-lin-i-cr.isento     = de-exento      / tt-lin-i-cr.cotacao-dia.                         .
                   end.
                   else 
                       assign tt-ext-lin-i-cr.gravado    = ( (fat-duplic.vl-comis / de-base-imp) 
                                                             * de-gravable    )     / tt-lin-i-cr.cotacao-dia
                              tt-ext-lin-i-cr.no-gravado = ( (fat-duplic.vl-comis / de-base-imp) 
                                                             * de-no-gravable )     / tt-lin-i-cr.cotacao-dia
                              tt-ext-lin-i-cr.isento     = ( (fat-duplic.vl-comis / de-base-imp) 
                                                             * de-exento      )     / tt-lin-i-cr.cotacao-dia.
    
                   assign  tt-ext-lin-i-cr.gravado    = if tt-ext-lin-i-cr.gravado = ? then 0
                                                        else tt-ext-lin-i-cr.gravado    /* Qdo VL total NF ‚ Zero */
                           tt-ext-lin-i-cr.no-gravado = if tt-ext-lin-i-cr.no-gravado = ? then 0
                                                        else tt-ext-lin-i-cr.no-gravado
                           tt-ext-lin-i-cr.isento     = if tt-ext-lin-i-cr.isento = ? then 0
                                                        else tt-ext-lin-i-cr.isento.
    
    
                    if tt-lin-i-cr.vl-liquido-me <> tt-ext-lin-i-cr.gravado
                                  + tt-ext-lin-i-cr.no-gravado 
                                  + tt-ext-lin-i-cr.isento  then do:
    
                    if tt-ext-lin-i-cr.gravado <> 0 then
                      assign tt-ext-lin-i-cr.gravado = tt-lin-i-cr.vl-liquido-me 
                                                      - tt-ext-lin-i-cr.no-gravado 
                                                      - tt-ext-lin-i-cr.isento .
                    else if tt-ext-lin-i-cr.no-gravado <> 0 then
                           assign tt-ext-lin-i-cr.no-gravado = tt-lin-i-cr.vl-liquido-me 
                                                             - tt-ext-lin-i-cr.gravado 
                                                             - tt-ext-lin-i-cr.isento .
                        else if tt-ext-lin-i-cr.isento <> 0 then
                             assign tt-ext-lin-i-cr.isento = tt-lin-i-cr.vl-liquido-me 
                                                           - tt-ext-lin-i-cr.gravado 
                                                           - tt-ext-lin-i-cr.no-gravado .
                   end.
    
                end.
    
                if i-gera-titulo = 2 /* Gera dup p/ end. cobranca */
                and avail b-emitente then
                    assign c-nome-abrev = b-emitente.nome-abrev.
                else
                    assign c-nome-abrev = emitente.nome-abrev.

                   
                /***************************************************************/
                /** Impostos do internacional                                 **/
                /***************************************************************/ 
                if  i-cod-pais-imposto <> 1 then do:
                    assign de-vl-imposto = 0.
    
                    /* Os impostos para o internacional serÆo sempre rateados entre as parcelas */
                    assign de-tot-base     = 0
                           de-tot-imposto  = 0
                           de-acum-base    = 0
                           de-acum-imposto = 0.
    
                    /*** Tratamento dos Impostos dos USA - 2.04B ***/
                    &IF DEFINED(BF_DIS_VERSAO_EMS) &THEN
                          &IF '{&BF_DIS_VERSAO_EMS}' >= '2.042' &THEN
                          
                             ASSIGN l-last-dupli  = IF LAST(fat-duplic.nr-fatura)  THEN YES ELSE NO.
                                    l-first-dupli = IF FIRST(fat-duplic.nr-fatura) THEN YES ELSE NO.
    
                             RUN pi-impostos-internacional.
                          &ELSE
                                for each it-nota-imp no-lock 
                                    where it-nota-imp.cod-estabel = nota-fiscal.cod-estabel and
                                          it-nota-imp.serie       = nota-fiscal.serie       and
                                          it-nota-imp.nr-nota-fis = nota-fiscal.nr-nota-fis
                                    break by it-nota-imp.cod-taxa :
    
                                    assign de-tot-base    = de-tot-base + it-nota-imp.vl-base-imp
                                           de-tot-imposto = de-tot-imposto + it-nota-imp.vl-imposto.
    
                                    if last-of(it-nota-imp.cod-taxa) then do:
                                       if  last(fat-duplic.nr-fatura) then do:
                                           find tt-imposto 
                                           where tt-imposto.cod-imposto = it-nota-imp.cod-tax no-error.
                                           if avail tt-imposto then 
                                               assign de-vl-base    = de-tot-base - tt-imposto.vl-base
                                                      de-vl-imposto = de-tot-imposto - tt-imposto.vl-imposto.
                                           else /* somente uma parcela */
                                               assign de-vl-base    = de-tot-base
                                                      de-vl-imposto = de-tot-imposto.
                                       end.
                                       else  do:
                                           find tt-imposto 
                                           where tt-imposto.cod-imposto = it-nota-imp.cod-tax no-lock no-error.
    
                                           if not avail tt-imposto then do:
                                              create tt-imposto.
                                              assign tt-imposto.cod-imposto = it-nota-imp.cod-tax.
                                           end.
    
                                           assign de-vl-base = (tt-lin-i-cr.vl-bruto / nota-fiscal.vl-tot-nota) 
                                                                   * de-tot-base
                                                  de-vl-imposto = (tt-lin-i-cr.vl-bruto / nota-fiscal.vl-tot-nota) 
                                                                 * de-tot-imposto
                                                  tt-imposto.vl-base = tt-imposto.vl-base + de-vl-base
                                                  tt-imposto.vl-imposto = tt-imposto.vl-imposto + de-vl-imposto.
                                       end.
    
                                       find tipo-tax where tipo-tax.cod-tax = it-nota-imp.cod-taxa no-lock no-error.
                                       create tt-impto-tit-pend-cr.
                                       assign tt-impto-tit-pend-cr.cod-classificacao   = if avail tipo-tax then tipo-tax.cod-classificacao else 0
                                              tt-impto-tit-pend-cr.cod-emitente        = tt-lin-i-cr.cod-emitente
                                              tt-impto-tit-pend-cr.cod-esp             = tt-lin-i-cr.cod-esp
                                              tt-impto-tit-pend-cr.cod-estabel         = tt-lin-i-cr.cod-estabel
                                              tt-impto-tit-pend-cr.cod-imposto         = it-nota-imp.cod-taxa
                                              tt-impto-tit-pend-cr.conta-retencao      = ""
                                              tt-impto-tit-pend-cr.conta-saldo-credito = ""
                                              tt-impto-tit-pend-cr.ct-retencao         = ""
                                              tt-impto-tit-pend-cr.ct-saldo-credito    = ""
                                              tt-impto-tit-pend-cr.dt-emissao          = tt-lin-i-cr.dt-emissao
                                              tt-impto-tit-pend-cr.ep-codigo           = tt-lin-i-cr.ep-codigo
                                              tt-impto-tit-pend-cr.ind-tip-calculo     = if avail tipo-tax then tipo-tax.ind-tip-calculo else 1
                                              tt-impto-tit-pend-cr.ind-tipo-imposto    = if avail tipo-tax then tipo-tax.ind-tipo-imposto else 1
                                              tt-impto-tit-pend-cr.mo-codigo           = tt-lin-i-cr.mo-codigo  
                                              tt-impto-tit-pend-cr.nat-operacao        = nota-fiscal.nat-operacao
                                              tt-impto-tit-pend-cr.nr-docto            = tt-lin-i-cr.nr-docto
                                              tt-impto-tit-pend-cr.num-seq-impto       = it-nota-imp.nr-seq-imp
                                              tt-impto-tit-pend-cr.parcela             = tt-lin-i-cr.parcela
                                              tt-impto-tit-pend-cr.perc-retencao       = 0
                                              tt-impto-tit-pend-cr.sc-retencao         = ""
                                              tt-impto-tit-pend-cr.sc-saldo-credito    = ""
                                              tt-impto-tit-pend-cr.contabilizou        = yes
                                              tt-impto-tit-pend-cr.serie               = tt-lin-i-cr.serie 
                                              tt-impto-tit-pend-cr.tipo                = if avail tipo-tax then tipo-tax.tipo else 1
                                              tt-impto-tit-pend-cr.vl-base             = de-vl-base
                                              tt-impto-tit-pend-cr.vl-base-me          = de-vl-base
                                              tt-impto-tit-pend-cr.ind-data-base       = if avail tipo-tax then tipo-tax.ind-data-base else 1
                                              tt-impto-tit-pend-cr.lancamento          = 2  
                                              tt-impto-tit-pend-cr.origem-impto        = 13
                                              tt-impto-tit-pend-cr.transacao-impto     = 14
                                              tt-impto-tit-pend-cr.vl-saldo-imposto    = de-vl-imposto
                                              tt-impto-tit-pend-cr.vl-saldo-imposto-me = de-vl-imposto
                                              tt-impto-tit-pend-cr.cotacao-dia         = tt-lin-i-cr.cotacao-dia.
    
                                       case it-nota-imp.int-2:
                                           when 1 or when 2 then do: /* IVA INSCRIPTO E N€O INSCRIPTO */
                                              assign 
                                              tt-impto-tit-pend-cr.ct-imposto    = if avail tipo-tax then tipo-tax.ct-tax else ""
                                              tt-impto-tit-pend-cr.sc-imposto    = if avail tipo-tax then tipo-tax.sc-tax else ""
                                              tt-impto-tit-pend-cr.perc-imposto  = if avail tipo-tax then tipo-tax.tax-perc else 0
                                              tt-impto-tit-pend-cr.vl-imposto    = de-vl-imposto
                                              tt-impto-tit-pend-cr.vl-imposto-me = de-vl-imposto.
    
                                           end.
                                           when 3 or when 4 then do: /* PERCEP°€O DE IVA e INGRESSOS BRUTOS */
                                              assign 
                                              /*tt-impto-tit-pend-cr.ct-percepcao    *
                                               *tt-impto-tit-pend-cr.sc-percepcao    */
                                              tt-impto-tit-pend-cr.conta-percepcao = if avail tipo-tax then tipo-tax.conta-percepcao else ""
                                              tt-impto-tit-pend-cr.ct-percepcao    = IF AVAIL tipo-tax THEN tipo-tax.ct-tax ELSE ""
                                              tt-impto-tit-pend-cr.sc-percepcao    = IF AVAIL tipo-tax THEN tipo-tax.sc-tax ELSE ""
                                              tt-impto-tit-pend-cr.perc-percepcao  = if avail tipo-tax then tipo-tax.perc-percepcao else 0
                                              tt-impto-tit-pend-cr.vl-percepcao    = de-vl-imposto
                                              tt-impto-tit-pend-cr.vl-percepcao-me = de-vl-imposto.
                                           end.
                                       end.
    
                                       if  tt-impto-tit-pend-cr.mo-codigo <> 0 then
                                           assign tt-impto-tit-pend-cr.vl-base-me = 
                                                  tt-impto-tit-pend-cr.vl-base-me / tt-lin-i-cr.cotacao-dia
                                                  tt-impto-tit-pend-cr.vl-imposto-me =
                                                  tt-impto-tit-pend-cr.vl-imposto-me / tt-lin-i-cr.cotacao-dia
                                                  tt-impto-tit-pend-cr.vl-saldo-imposto-me = 
                                                  tt-impto-tit-pend-cr.vl-saldo-imposto-me / tt-lin-i-cr.cotacao-dia
                                                  tt-impto-tit-pend-cr.vl-percepcao-me =
                                                  tt-impto-tit-pend-cr.vl-percepcao / tt-lin-i-cr.cotacao-dia
                                                  tt-impto-tit-pend-cr.vl-retencao-me =
                                                  tt-impto-tit-pend-cr.vl-retencao / tt-lin-i-cr.cotacao-dia.
    
                                       assign de-tot-base    = 0
                                              de-tot-imposto = 0.
    
                                    end.
                                end.
                          &ENDIF
                     &ENDIF
                end.
                else
                /*********************************************************************************/
                /** Lei 9430 que trata dos impostos pendentes na baixa de t¡tulos de autarquias **/
                /*********************************************************************************/
                if  emitente.agente-retencao = yes and fat-duplic.log-1 = no then do:
                   assign i-cod-tax = 0.
                   for each it-nota-imp NO-LOCK
                        where it-nota-imp.cod-estabel = nota-fiscal.cod-estabel and
                              it-nota-imp.serie       = nota-fiscal.serie       and
                              it-nota-imp.nr-nota-fis = nota-fiscal.nr-nota-fis by it-nota-imp.cod-taxa: 
                         if i-cod-tax = 0 then
                            assign i-cod-tax = it-nota-imp.cod-taxa.
    
                         if it-nota-imp.cod-taxa = i-cod-tax then do:
                            assign de-vl-imposto = de-vl-imposto + it-nota-imp.vl-imposto.
                         end.     
                         else do:
                            find cond-pagto where cond-pagto.cod-cond-pag = nota-fiscal.cod-cond-pag no-lock no-error.
                            if avail cond-pagto then do:
                               assign i-parcela = integer(fat-duplic.parcela)
                                      i-num-parcela = cond-pagto.num-parcelas
                                      de-vl-parcela = (de-vl-imposto * (cond-pagto.per-pg-dup[i-parcela] / 100)).
                               if i-num-parcela = integer(fat-duplic.parcela) then do:
                                  assign de-vl-tot-imposto = 0.
                                  for each tt-impto-tit-pend-cr
                                      where tt-impto-tit-pend-cr.cod-estabel = fat-duplic.cod-estabel and
                                            tt-impto-tit-pend-cr.serie       = fat-duplic.serie       and
                                            tt-impto-tit-pend-cr.nr-docto    = fat-duplic.nr-fatura   and
                                            tt-impto-tit-pend-cr.cod-imposto = i-cod-tax no-lock:
                                            assign de-vl-tot-imposto = de-vl-tot-imposto + tt-impto-tit-pend-cr.vl-imposto.
                                  end.         
                                  de-vl-parcela = de-vl-imposto - de-vl-tot-imposto.
                               end.
    
    
                               /** Cria os impostos pendentes **/
                               if  de-vl-parcela <> 0 then do:
                                   find tipo-tax where tipo-tax.cod-tax = i-cod-tax no-lock no-error.
                                   create tt-impto-tit-pend-cr.
                                   assign tt-impto-tit-pend-cr.cod-classificacao    = if avail tipo-tax then tipo-tax.cod-classificacao else 0
                                          tt-impto-tit-pend-cr.cod-emitente         = tt-lin-i-cr.cod-emitente
                                          tt-impto-tit-pend-cr.cod-esp              = tt-lin-i-cr.cod-esp
                                          tt-impto-tit-pend-cr.cod-estabel          = tt-lin-i-cr.cod-estabel
                                          tt-impto-tit-pend-cr.cod-imposto          = i-cod-tax
                                          tt-impto-tit-pend-cr.ct-imposto           = tipo-tax.ct-tax
                                          tt-impto-tit-pend-cr.sc-imposto           = tipo-tax.sc-tax 
                                          tt-impto-tit-pend-cr.ct-retencao          = tipo-tax.ct-retencao
                                          tt-impto-tit-pend-cr.sc-retencao          = tipo-tax.sc-retencao
                                          tt-impto-tit-pend-cr.ct-saldo-credito     = tipo-tax.ct-saldo-credito
                                          tt-impto-tit-pend-cr.sc-saldo-credito     = tipo-tax.sc-saldo-credito
                                          tt-impto-tit-pend-cr.dt-emissao           = tt-lin-i-cr.dt-emissao
                                          tt-impto-tit-pend-cr.ep-codigo            = tt-lin-i-cr.ep-codigo
                                          tt-impto-tit-pend-cr.ind-tip-calculo      = if tipo-tax.ind-tip-calculo <> 0 then tipo-tax.ind-tip-calculo else 1
                                          tt-impto-tit-pend-cr.ind-tipo-imposto     = if tipo-tax <> 0 then tipo-tax.ind-tipo-imposto else 1
                                          tt-impto-tit-pend-cr.mo-codigo            = tt-lin-i-cr.mo-codigo  
                                          tt-impto-tit-pend-cr.nat-operacao         = nota-fiscal.nat-operacao
                                          tt-impto-tit-pend-cr.nr-docto             = tt-lin-i-cr.nr-docto
                                          tt-impto-tit-pend-cr.num-seq-impto        = it-nota-imp.nr-seq-imp
                                          tt-impto-tit-pend-cr.parcela              = tt-lin-i-cr.parcela
                                          tt-impto-tit-pend-cr.perc-imposto         = tipo-tax.tax-perc 
                                          tt-impto-tit-pend-cr.perc-retencao        = 0
                                          tt-impto-tit-pend-cr.serie                = tt-lin-i-cr.serie
                                          tt-impto-tit-pend-cr.tipo                 = if tipo-tax.tipo <> 0 then tipo-tax.tipo else 1
                                          tt-impto-tit-pend-cr.vl-base              = de-vl-base
                                          tt-impto-tit-pend-cr.vl-base-me           = de-vl-base
                                          tt-impto-tit-pend-cr.vl-imposto           = de-vl-parcela
                                          tt-impto-tit-pend-cr.vl-imposto-me        = de-vl-parcela
                                          tt-impto-tit-pend-cr.vl-retencao          = de-vl-parcela
                                          tt-impto-tit-pend-cr.ind-data-base        = if tipo-tax.ind-data-base <> 0 then tipo-tax.ind-data-base else 1
                                          tt-impto-tit-pend-cr.lancamento           = 2
                                          tt-impto-tit-pend-cr.origem-impto         = if it-nota-imp.int-1 = 9 then 9 else 13 
                                          tt-impto-tit-pend-cr.transacao-impto      = 14
                                          tt-impto-tit-pend-cr.vl-saldo-imposto     = de-vl-parcela
                                          tt-impto-tit-pend-cr.vl-saldo-imposto-me  = de-vl-parcela
                                          tt-impto-tit-pend-cr.cotacao-dia          = tt-lin-i-cr.cotacao-dia.
    
                                       /* IVA Taxado - Paraguai */
                                       IF i-cod-pais-imposto = 9 THEN DO:
                                          ASSIGN tt-impto-tit-pend-cr.tipo = 2 /* Sempre enviar o imposto taxado como Tipo Valor Agregado ao ACR */
                                                 tt-impto-tit-pend-cr.ind-tip-calculo      = 1
                                                 tt-impto-tit-pend-cr.ind-tipo-imposto     = 2.
                                              END.
    
                                   if  tt-impto-tit-pend-cr.mo-codigo <> 0 then
                                       assign tt-impto-tit-pend-cr.vl-base-me = 
                                              tt-impto-tit-pend-cr.vl-base-me / tt-lin-i-cr.cotacao-dia
                                              tt-impto-tit-pend-cr.vl-imposto-me =
                                              tt-impto-tit-pend-cr.vl-imposto-me / tt-lin-i-cr.cotacao-dia
                                              tt-impto-tit-pend-cr.vl-saldo-imposto-me = 
                                              tt-impto-tit-pend-cr.vl-saldo-imposto-me / tt-lin-i-cr.cotacao-dia
                                              tt-impto-tit-pend-cr.vl-percepcao-me =
                                              tt-impto-tit-pend-cr.vl-percepcao / tt-lin-i-cr.cotacao-dia
                                              tt-impto-tit-pend-cr.vl-retencao-me =
                                              tt-impto-tit-pend-cr.vl-retencao / tt-lin-i-cr.cotacao-dia.
    
                                   assign i-cod-tax         = it-nota-imp.cod-tax
                                          de-vl-parcela     = 0
                                          de-vl-tot-imposto = 0
                                          de-vl-imposto     = 0
                                          de-vl-imposto     = it-nota-imp.vl-imposto
                                          gr-imposto        = rowid(it-nota-imp).
                               end.
                            end.
                         end.
                   end.
    
                   /** Para o £ltimo imposto da parcela "**/
    
                   find it-nota-imp where rowid(it-nota-imp) = gr-imposto no-lock no-error.
                   if avail it-nota-imp then do:
                      find cond-pagto where cond-pagto.cod-cond-pag = nota-fiscal.cod-cond-pag no-lock no-error.
                      if avail cond-pagto then do:
                         assign i-parcela = integer(fat-duplic.parcela)
                                i-num-parcela = cond-pagto.num-parcelas
                                de-vl-tot-imposto = de-vl-tot-imposto + de-vl-parcela
                                de-vl-parcela = (de-vl-imposto * (cond-pagto.per-pg-dup[i-parcela] / 100)).
                         if i-num-parcela = integer(fat-duplic.parcela) then do:
                            assign de-vl-tot-imposto = 0.
                            for each tt-impto-tit-pend-cr
                                where tt-impto-tit-pend-cr.cod-estabel = fat-duplic.cod-estabel and
                                      tt-impto-tit-pend-cr.serie       = fat-duplic.serie       and
                                      tt-impto-tit-pend-cr.nr-docto    = fat-duplic.nr-fatura   and
                                      tt-impto-tit-pend-cr.cod-imposto = i-cod-tax no-lock:
                                 assign de-vl-tot-imposto = de-vl-tot-imposto + tt-impto-tit-pend-cr.vl-imposto.
                            end.         
                            de-vl-parcela = de-vl-imposto - de-vl-tot-imposto.
                         end.
                         /** Cria os impostos pendentes **/
                         RUN pi-cria-tt-impto-tit-pend-cr.
                      end.
                   end.   
                end.
    
                find first fat-repre use-index ch-fatrep
                    where fat-repre.cod-estabel = fat-dupl.cod-estabel
                    and   fat-repre.serie       = fat-dupl.serie
                    and   fat-repre.nr-fatura   = fat-dupl.nr-fatura
                    no-lock no-error.
    
                ASSIGN l-erro-repres = NO.
    
                if  avail fat-repre
                and ((emitente.natureza = 3
                    and nota-fiscal.ind-tip-nota <> 3)
                    or emitente.natureza <> 3) then do:
    
                    assign i-emitente-cod-gr-cli = emitente.cod-gr-cli.
                    /* criar w-fat-repre */
                    for each  fat-repre use-index ch-fatrep
                        where fat-repre.cod-estabel = fat-duplic.cod-estabel
                        and   fat-repre.serie       = fat-duplic.serie
                        and   fat-repre.nr-fatura   = fat-duplic.nr-fatura 
                        no-lock:
                        create w-fat-repre.
                        assign w-fat-repre.nome-ab-rep  = fat-repre.nome-ab-rep
                               w-fat-repre.posicao = if fat-repre.nome-ab-rep =
                                                     nota-fiscal.no-ab-reppri
                                                     then 0 else 1.
                    end.
    
                    for each  fat-repre use-index ch-fatrep
                        where fat-repre.cod-estabel = fat-duplic.cod-estabel
                        and   fat-repre.serie       = fat-duplic.serie
                        and   fat-repre.nr-fatura   = fat-duplic.nr-fatura 
                        no-lock,
                        each repres use-index abrev
                        where repres.nome-abrev = fat-repre.nome-ab-rep
                        no-lock,
                        first w-fat-repre NO-LOCK
                        where w-fat-repre.nome-ab-rep = fat-repre.nome-ab-rep
                        by w-fat-repre.posicao : /*1a. seja o diret*/
    
                        assign i-cod-rep = repres.cod-rep.
    
                        if fat-repre.nome-ab-rep = nota-fiscal.no-ab-reppri then
                           assign de-comis-ind  = 0
                                  de-comis-emis = 0
                                  l-principal   = no.
                        
                        RUN ExecutaEpc (INPUT "Commission",
                                        OUTPUT p-c-retorno-epc ) .
                    
                        IF (p-c-retorno-epc = "yes" 
                        OR  p-c-retorno-epc = ""   ) THEN
                           ASSIGN l-comissao-epc = YES.
                        ELSE 
                           ASSIGN l-comissao-epc = NO.
    
                        /*
                        IF c-nom-prog-upc-mg97 <> "" THEN DO:
    
                            /***** Chamada UPC *****/
                            for each tt-epc where tt-epc.cod-event = "Commission":
                                delete tt-epc.
                            end.
                            create tt-epc.
                            assign tt-epc.cod-event     = "Commission"
                                   tt-epc.cod-parameter = "fat-duplic"
                                   tt-epc.val-parameter = string(rowid(fat-duplic)).
    
                            {include/i-epc201.i "Commission"}
    
                            find tt-epc where
                                 tt-epc.cod-event     = "Commission" and
                                 tt-epc.cod-parameter = "Use-Commission" no-error.
                            if  avail tt-epc then do:
                                if  tt-epc.val-parameter  = "no" then
                                    assign l-comissao-epc = no.
                                else
                                    assign l-comissao-epc = yes.
                            end.
                            else
                                assign l-comissao-epc = yes.
                            /***** Fim UPC *****/
                        END.
                        else
                            assign l-comissao-epc = yes.
                        */
    
                        /* Verifica se existe ped-repres-item */
    
                        IF l-comissao-por-item THEN 
                           FIND FIRST fatur-repres-item 
                                WHERE fatur-repres-item.cod-estabel = fat-repre.cod-estabel
                                AND   fatur-repres-item.cod-serie   = fat-repre.serie
                                AND   fatur-repres-item.nr-fatura   = fat-repre.nr-fatura
                                NO-LOCK NO-ERROR.
    
                        IF AVAIL fatur-repres-item THEN
                           ASSIGN l-comissao = NO.
    
                        /**/
    
                        if (l-comissao and l-comissao-epc) 
                        or substring(para-fat.char-1,100,1) <> "S"
                        then 
                            run ftp/ft0603a.p (r-registro,
                                               fat-repre.nome-ab-rep,
                                               fat-repre.perc-comis,
                                               fat-repre.comis-emis,
                                               h-bodi390).
                        else
                           assign de-comis      = fat-repre.perc-comis
                                  de-comis-emis = fat-repre.comis-emis.
    
                        find tt-rep-i-cr
                             where tt-rep-i-cr.ep-codigo         = tt-lin-i-cr.ep-codigo
                             and   tt-rep-i-cr.cod-estabel       = fat-repre.cod-estabel
                             and   tt-rep-i-cr.cod-esp           = tt-lin-i-cr.cod-esp
                             and   tt-rep-i-cr.nr-docto          = tt-lin-i-cr.nr-docto
                             and   tt-rep-i-cr.parcela           = string(fat-duplic.parcela)
                             and   tt-rep-i-cr.serie             = fat-duplic.serie
                             and   tt-rep-i-cr.cod-rep           = repres.cod-rep
                             and   tt-rep-i-cr.cod-classificador = fat-repre.cod-classificador
                             no-lock no-error.
    
                        ASSIGN l-erro-repres = (    AVAIL tt-rep-i-cr
                                                AND l-nr-processo
                                                AND tt-rep-i-cr.comissao <> de-comis).
    
                        if  not avail tt-rep-i-cr then do:
                            create tt-rep-i-cr.
                            assign tt-rep-i-cr.cod-rep           = repres.cod-rep
                                   tt-rep-i-cr.cod-estabel       = fat-duplic.cod-estabel
                                   tt-rep-i-cr.serie             = fat-duplic.serie
                                   tt-rep-i-cr.cod-classificador = fat-repre.cod-classificador
                                   tt-rep-i-cr.cod-esp           = tt-lin-i-cr.cod-esp
                                   tt-rep-i-cr.ep-codigo         = tt-lin-i-cr.ep-codigo
                                   tt-rep-i-cr.nr-docto          = tt-lin-i-cr.nr-docto
                                   tt-rep-i-cr.parcela           = string(fat-duplic.parcela)
                                   tt-rep-i-cr.comis-emis        = round(de-comis-emis,8)
                                   tt-rep-i-cr.comissao          = round(de-comis,8)
                                   de-comis-tot                  = de-comis-tot 
                                                           + round(de-comis,8)
                                   de-vl-comisnota               = de-vl-comisnota 
                                                           + (fat-duplic.vl-comis * (tt-rep-i-cr.comissao / 100)).
    
                            &IF DEFINED(BF_FIN_RAC) &THEN
                                IF  AVAIL param-global AND param-global.modulo-rac = YES THEN
                                    ASSIGN tt-rep-i-cr.comis-propor = repres.comis-propor.
                            &ENDIF
    
                            /* Engenharia Comissoes Agentes Externos */
                            IF  l-integ-mcr-ems5 AND
                                l-spp-comagext   THEN DO:
                                &IF "{&bf_dis_versao_ems}":U >= "2.062":U &THEN
                                    ASSIGN OVERLAY(tt-rep-i-cr.char-1,1,1) = STRING(fat-repre.idi-tip-comis-agent)
                                           OVERLAY(tt-rep-i-cr.char-1,2,1) = STRING(fat-repre.idi-liber-pagto-comis-agent).
                                &ELSE
                                    &IF "{&bf_dis_versao_ems}":U >= "2.04":U &THEN
                                        ASSIGN OVERLAY(tt-rep-i-cr.char-1,1,1) = SUBSTRING(fat-repre.char-1,1,1)
                                               OVERLAY(tt-rep-i-cr.char-1,2,1) = SUBSTRING(fat-repre.char-1,3,1).
                                    &ENDIF
                                &ENDIF
                            END.
                        end.
                     end.
                     for each w-fat-repre EXCLUSIVE-LOCK:
                         delete w-fat-repre.
                     end.
                end.
    
                if  fat-duplic.nr-fatura > "999999" then do:
                    {utp/ut-liter.i ATEN€ÇO:_N£mero_do_Documento_excede_a_999.999 * R}

                     assign tt-retorno-nota-fiscal.tipo       = 1
                            tt-retorno-nota-fiscal.cod-erro   = "0002"
                            tt-retorno-nota-fiscal.desc-erro  = return-value
                            tt-retorno-nota-fiscal.situacao   = yes
                            tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                            tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                                string(i-empresa) + "," +
                                                                nota-fiscal.cod-estabel + "," +
                                                                fat-duplic.cod-esp + "," +
                                                                nota-fiscal.serie + "," +
                                                                (if nota-fiscal.nr-fatura = "" then
                                                                   nota-fiscal.nr-nota-fis 
                                                                else 
                                                                   nota-fiscal.nr-fatura) + "," + "," +
                                                                (if avail tt-lin-i-cr 
                                                                    then
                                                                       string(tt-lin-i-cr.cod-portador) + "," +
                                                                       string(tt-lin-i-cr.modalidade)
                                                                    else ",").
                end.
                /* consistˆncia criada em funcao da fo nr. 1195236 - motivo limita‡Æo da temp-table tt-rep-i-cr */
                IF  l-erro-repres  THEN DO:
                    {utp/ut-liter.i Nota_gerada_por_processo_de_exporta‡Æo_possui_representante_com_comissäes_diferentes * R}

                    CREATE tt-retorno-nota-fiscal.
                    assign tt-retorno-nota-fiscal.tipo       = 1
                           tt-retorno-nota-fiscal.cod-erro   = "9000"
                           tt-retorno-nota-fiscal.desc-erro  = return-value
                           tt-retorno-nota-fiscal.situacao   = NO
                           tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                           tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                               string(i-empresa) + "," +
                                                               nota-fiscal.cod-estabel + "," +
                                                               fat-duplic.cod-esp + "," +
                                                               nota-fiscal.serie + "," +
                                                               (if nota-fiscal.nr-fatura = "" 
                                                                THEN nota-fiscal.nr-nota-fis 
                                                                else  nota-fiscal.nr-fatura) + "," + "," +
                                                               (if avail tt-lin-i-cr 
                                                                THEN string(tt-lin-i-cr.cod-portador) + "," + string(tt-lin-i-cr.modalidade)
                                                                else ",")
                           tt-nota-fiscal.atualizar = no.
                    NEXT atualiza.
                END.
    
                IF  i-pais-impto-usuario   <> 1 /* Internacional  */ AND
                    AVAIL tt-lin-i-cr                                AND
                    tt-lin-i-cr.tipo-titulo = 4 /* Nota de Debito */ THEN DO:
                    RUN pi-valida-comissao-rep.
                END.
    
                /* Somente precisa rodar o ft0603c se o modulo de FASB estiver implantado */
                if  param-global.modulo-fc then
                    run pi-ft0603c (input rowid(fat-duplic),
                                    input c-referencia).
    
                if  avail para-ped and
                    de-comis-tot > para-ped.perc-max-com then do:
                    {utp/ut-liter.i Nota_Fiscal_excedeu_o_perc_max_de_comissäes * R}

                    create tt-retorno-nota-fiscal.
                    assign tt-retorno-nota-fiscal.tipo       = 1
                           tt-retorno-nota-fiscal.cod-erro   = "0003"
                           tt-retorno-nota-fiscal.desc-erro  = return-value
                           tt-retorno-nota-fiscal.situacao   = no
                           tt-retorno-nota-fiscal.referencia = c-referencia
                           tt-retorno-nota-fiscal.cod-chave  = c-referencia + ",," +
                                                               string(i-empresa) + "," +
                                                               nota-fiscal.cod-estabel + "," +
                                                               fat-duplic.cod-esp + "," +
                                                               nota-fiscal.serie + "," +
                                                               (if nota-fiscal.nr-fatura = "" 
                                                               then nota-fiscal.nr-nota-fis 
                                                               else nota-fiscal.nr-fatura) 
                                                               + "," +
                                                               fat-duplic.parcela + ","+
                                                               (if avail tt-lin-i-cr 
                                                                then
                                                                  string(tt-lin-i-cr.cod-portador) + "," +
                                                                  string(tt-lin-i-cr.modalidade)
                                                                else ",").
                           tt-nota-fiscal.atualizar = no.
                   next atualiza.
                end.
    
                /* Vendor ****************************************************/
                if  l-vendor and nota-fiscal.modalidade = 7 then do:
                    run pdp/pd2022.p (input nota-fiscal.cod-estabel,
                                      input nota-fiscal.serie,
                                      input nota-fiscal.nr-nota-fis, 
                                      input tt-lin-i-cr.ep-codigo,
                                      input tt-lin-i-cr.cod-estabel,
                                      input tt-lin-i-cr.cod-esp,
                                      input tt-lin-i-cr.serie,
                                      input tt-lin-i-cr.nr-docto,
                                      input tt-lin-i-cr.parcela,
                                      input-output table tt-lin-ven,
                                      OUTPUT TABLE tt_log_erros_atualiz_vdr).
    
                    FOR EACH tt_log_erros_atualiz_vdr:

                        CREATE tt-retorno-nota-fiscal.
                        ASSIGN tt-retorno-nota-fiscal.tipo      = 1
                               tt-retorno-nota-fiscal.cod-erro  = STRING (tt_log_erros_atualiz_vdr.ttv_num_mensagem)
                               tt-retorno-nota-fiscal.desc-erro = tt_log_erros_atualiz_vdr.ttv_des_msg_erro
                               tt-retorno-nota-fiscal.situacao  = NO
                               tt-retorno-nota-fiscal.cod-chave = tt-nota-fiscal.referencia + ",," +
                                                                   string(i-empresa) + "," +
                                                                   nota-fiscal.cod-estabel + "," +
                                                                   fat-duplic.cod-esp + "," +
                                                                   nota-fiscal.serie + "," +
                                                                   (if nota-fiscal.nr-fatura = "" then
                                                                      nota-fiscal.nr-nota-fis 
                                                                   else 
                                                                      nota-fiscal.nr-fatura) + "," + ","+
                                                                   (if avail tt-lin-i-cr 
                                                                    then
                                                                        string(tt-lin-i-cr.cod-portador) + "," +
                                                                        string(tt-lin-i-cr.modalidade)
                                                                    else ",").
                        DELETE tt_log_erros_atualiz_vdr.
                    END.
                end.
                /* Fim Vendor ************************************************/
                /***   Notas de D‚bito/Cr‚dito   ****************/
    
                find esp-doc where esp-doc.cod-esp = tt-lin-i-cr.cod-esp no-lock no-error.
                if (esp-doc.tipo = 4 or esp-doc.tipo = 5) 
                AND NOT l-ems5 /* Se for EMS 5, sempre atualiza a tt-doc-i-cr */ THEN do:
    
                    find b-nota-fiscal-orig
                         where b-nota-fiscal-orig.cod-estabel = nota-fiscal.cod-estabel
                         and   b-nota-fiscal-orig.serie       = nota-fiscal.serie-orig
                         and   b-nota-fiscal-orig.nr-nota-fis = nota-fiscal.nro-nota-orig no-lock no-error.
                    if not avail b-nota-fiscal-orig then do:
                       if fat-duplic.log-1 = yes then do:
                          find b-nota-fiscal-orig
                               where b-nota-fiscal-orig.cod-estabel = nota-fiscal.cod-estabel
                               and   b-nota-fiscal-orig.serie       = nota-fiscal.serie
                               and   b-nota-fiscal-orig.nr-nota-fis = nota-fiscal.nr-nota-fis no-lock no-error.
                       end.
                    end.     
                    if  avail b-nota-fiscal-orig then do:
    
                        /*** O campo fat-duplic.log-1 esta sendo usado pela SUPER     ***/
                        /*** identificando se trata-se de um t¡tulo de cr‚dito ou nÆo ***/
                        /*** Usado para estornar valores e impostos no CR             ***/
                        if fat-duplic.log-1 = yes then do:
                           assign c-parcela-orig = substring(fat-duplic.parcela,1,(length(fat-duplic.parcela) - 1)).
                           assign tt-lin-i-cr.cod-port = fat-duplic.int-1.
                           if length(c-parcela-orig) = 1 then
                               assign c-parcela-orig = "0" + c-parcela-orig.
                        end.
                        else assign c-parcela-orig = fat-duplic.parcela.
    
                        find first b-fat-duplic-orig
                             where b-fat-duplic-orig.cod-estabel = b-nota-fiscal-orig.cod-estabel
                             and   b-fat-duplic-orig.serie       = b-nota-fiscal-orig.serie
                             and   b-fat-duplic-orig.nr-fatura   = b-nota-fiscal-orig.nr-fatura
                             and   b-fat-duplic-orig.parcela     = c-parcela-orig no-lock no-error.
    
                    end.
    
                    /*----- Valida tipo receita/despesa ------*/
                    find tipo-rec-desp 
                    where tipo-rec-desp.tp-codigo = natur-oper.tp-rec-desp
                    no-lock no-error.
                    if  not avail tipo-rec-desp then do:    
                        run utp/ut-msgs.p (input "msg",
                                           input 4270,
                                           input "").

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "4270"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = no
                               tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                               tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                                   string(i-empresa) + "," +
                                                                   nota-fiscal.cod-estabel + "," +
                                                                   fat-duplic.cod-esp + "," +
                                                                   nota-fiscal.serie + "," +
                                                                   (if nota-fiscal.nr-fatura = "" then
                                                                      nota-fiscal.nr-nota-fis 
                                                                   else 
                                                                      nota-fiscal.nr-fatura) + "," + ","+
                                                                   (if avail tt-lin-i-cr 
                                                                    then
                                                                        string(tt-lin-i-cr.cod-portador) + "," +
                                                                        string(tt-lin-i-cr.modalidade)
                                                                    else ",").
                        next atualiza.
                    end.
    
                    if  avail tipo-rec-desp
                    and tipo-rec-desp.tipo = 2 
                    and (esp-doc.tipo = 1
                     or esp-doc.tipo = 4 
                     or esp-doc.tipo = 5) then do: /* NFS‹s e Notas de cr‚dito devem ser receita */    
                        run utp/ut-msgs.p (input "msg",
                                           input 4265,
                                           input "").

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "4265"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = no
                               tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                               tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                                   string(i-empresa) + "," +
                                                                   nota-fiscal.cod-estabel + "," +
                                                                   fat-duplic.cod-esp + "," +
                                                                   nota-fiscal.serie + "," +
                                                                   (if nota-fiscal.nr-fatura = "" then
                                                                      nota-fiscal.nr-nota-fis 
                                                                   else 
                                                                      nota-fiscal.nr-fatura) + "," + ","+
                                                                   (if avail tt-lin-i-cr 
                                                                    then
                                                                        string(tt-lin-i-cr.cod-portador) + "," +
                                                                        string(tt-lin-i-cr.modalidade)
                                                                    else ",").
                        next atualiza.
                    end.
    
                    assign l-gerou-tt-nota-db-cr = yes.
    
                    create tt-nota-db-cr.
                    assign tt-nota-db-cr.ep-codigo       = i-empresa
                           tt-nota-db-cr.cod-estabel     = tt-lin-i-cr.cod-estabel
                           tt-nota-db-cr.cod-esp         = tt-lin-i-cr.cod-esp
                           tt-nota-db-cr.cod-rep         = tt-lin-i-cr.cod-rep
                           tt-nota-db-cr.serie           = tt-lin-i-cr.serie
                           tt-nota-db-cr.nr-docto        = tt-lin-i-cr.nr-docto
                           tt-nota-db-cr.parcela         = tt-lin-i-cr.parcela
                           tt-nota-db-cr.obs-gerada      = tt-lin-i-cr.observacao
                           tt-nota-db-cr.cod-emitente    = tt-lin-i-cr.cod-emitente
                           tt-nota-db-cr.nome-abrev      = nota-fiscal.nome-ab-cli
                           tt-nota-db-cr.referencia      = tt-lin-i-cr.referencia
                           tt-nota-db-cr.referencia-cb   = tt-lin-i-cr.referencia
                           tt-nota-db-cr.dt-emissao      = tt-lin-i-cr.dt-emissao
                           tt-nota-db-cr.dt-trans        = tt-lin-i-cr.dt-emissao
                           tt-nota-db-cr.cod-port        = tt-lin-i-cr.cod-port
                           tt-nota-db-cr.modalidade      = tt-lin-i-cr.modalidade
                           tt-nota-db-cr.mo-codigo       = tt-lin-i-cr.mo-codigo
                           tt-nota-db-cr.cotacao-dia     = tt-lin-i-cr.cotacao-dia
                           tt-nota-db-cr.vl-original     = tt-lin-i-cr.vl-bruto
                           tt-nota-db-cr.diversos        = tt-lin-i-cr.diversos
                           tt-nota-db-cr.frete           = tt-lin-i-cr.frete                   
                           tt-nota-db-cr.vl-original-me  = tt-nota-db-cr.vl-original / tt-nota-db-cr.cotacao-dia
                           tt-nota-db-cr.diversos-me     = tt-nota-db-cr.diversos    / tt-nota-db-cr.cotacao-dia
                           tt-nota-db-cr.frete-me        = tt-nota-db-cr.frete       / tt-nota-db-cr.cotacao-dia
                           /*tt-nota-db-cr.conta-credito   = tt-lin-i-cr.conta-credito*/
                           tt-nota-db-cr.observacao      = tt-lin-i-cr.observacao
                           tt-nota-db-cr.tem-docto-orig  = avail b-fat-duplic-orig
                           tt-nota-db-cr.ep-codigo-orig  = i-empresa
                           tt-nota-db-cr.cod-est-orig    = b-fat-duplic-orig.cod-estabel  when avail b-fat-duplic-orig 
                           tt-nota-db-cr.cod-esp-orig    = b-fat-duplic-orig.cod-esp      when avail b-fat-duplic-orig
                           tt-nota-db-cr.serie-orig      = b-fat-duplic-orig.serie        when avail b-fat-duplic-orig
                           tt-nota-db-cr.nr-docto-orig   = b-fat-duplic-orig.nr-fatura    when avail b-fat-duplic-orig 
                           tt-nota-db-cr.parcela-orig    = b-fat-duplic-orig.parcela      when avail b-fat-duplic-orig 
                           tt-nota-db-cr.obs-orig        = b-nota-fiscal-orig.observ-nota when avail b-nota-fiscal-orig
                           tt-nota-db-cr.sequencia       = tt-lin-i-cr.sequencia
                           tt-nota-db-cr.cod-programa    = "ftapi001"
                           tt-nota-db-cr.tp-codigo       = natur-oper.tp-rec-desp
                           tt-nota-db-cr.ind-contabiliza = if para-fat.ind-transitoria then 2
                                                           else 1.
    
                    if tt-nota-db-cr.tem-docto-orig then
                       assign tt-nota-db-cr.nr-docto-gerado = tt-nota-db-cr.nr-docto
                              tt-nota-db-cr.parcela-gerada  = tt-nota-db-cr.parcela.
                    else
                       assign tt-nota-db-cr.nr-docto-gerado = tt-nota-db-cr.nr-docto 
                              tt-nota-db-cr.parcela-gerada  = tt-nota-db-cr.parcela.
    
                    for each tt-impto-tit-pend-cr
                       where tt-impto-tit-pend-cr.ep-codigo   = tt-nota-db-cr.ep-codigo
                       and   tt-impto-tit-pend-cr.cod-estabel = tt-nota-db-cr.cod-estabel
                       and   tt-impto-tit-pend-cr.cod-esp     = tt-nota-db-cr.cod-esp
                       and   tt-impto-tit-pend-cr.serie       = tt-nota-db-cr.serie
                       and   tt-impto-tit-pend-cr.nr-docto    = tt-nota-db-cr.nr-docto:
    
                       create tt-impto-nota-db-cr.
                       assign tt-impto-nota-db-cr.ep-codigo           = tt-impto-tit-pend-cr.ep-codigo
                              tt-impto-nota-db-cr.cod-estabel         = tt-impto-tit-pend-cr.cod-estabel
                              tt-impto-nota-db-cr.cod-esp             = tt-impto-tit-pend-cr.cod-esp
                              tt-impto-nota-db-cr.serie               = tt-impto-tit-pend-cr.serie
                              tt-impto-nota-db-cr.nr-docto            = tt-impto-tit-pend-cr.nr-docto
                              tt-impto-nota-db-cr.parcela             = tt-impto-tit-pend-cr.parcela
                              tt-impto-nota-db-cr.cod-imposto         = tt-impto-tit-pend-cr.cod-imposto
                              tt-impto-nota-db-cr.tipo                = tt-impto-tit-pend-cr.tipo
                              tt-impto-nota-db-cr.conta-imposto       = tt-impto-tit-pend-cr.conta-imposto
                              tt-impto-nota-db-cr.conta-percepcao     = tt-impto-tit-pend-cr.conta-percepcao
                              tt-impto-nota-db-cr.conta-retencao      = tt-impto-tit-pend-cr.conta-retencao
                              tt-impto-nota-db-cr.conta-saldo-credito = tt-impto-tit-pend-cr.conta-saldo-credito
                              tt-impto-nota-db-cr.cotacao-dia         = tt-impto-tit-pend-cr.cotacao-dia
                              tt-impto-nota-db-cr.mo-codigo           = tt-impto-tit-pend-cr.mo-codigo
                              tt-impto-nota-db-cr.perc-imposto        = tt-impto-tit-pend-cr.perc-imposto
                              tt-impto-nota-db-cr.perc-percepcao      = tt-impto-tit-pend-cr.perc-percepcao
                              tt-impto-nota-db-cr.perc-retencao       = tt-impto-tit-pend-cr.perc-retencao
                              tt-impto-nota-db-cr.vl-base-me          = tt-impto-tit-pend-cr.vl-base-me
                              tt-impto-nota-db-cr.vl-base             = tt-impto-tit-pend-cr.vl-base
                              tt-impto-nota-db-cr.vl-imposto          = tt-impto-tit-pend-cr.vl-imposto
                              tt-impto-nota-db-cr.vl-imposto-me       = tt-impto-tit-pend-cr.vl-imposto-me
                              tt-impto-nota-db-cr.vl-percepcao        = tt-impto-tit-pend-cr.vl-percepcao
                              tt-impto-nota-db-cr.vl-percepcao-me     = tt-impto-tit-pend-cr.vl-percepcao-me
                              tt-impto-nota-db-cr.vl-retencao         = tt-impto-tit-pend-cr.vl-retencao
                              tt-impto-nota-db-cr.vl-retencao-me      = tt-impto-tit-pend-cr.vl-retencao-me
                              tt-impto-nota-db-cr.vl-saldo-imposto-me = tt-impto-tit-pend-cr.vl-saldo-imposto-me
                              tt-impto-nota-db-cr.vl-saldo-imposto    = tt-impto-tit-pend-cr.vl-saldo-imposto.
    
                       if  tt-impto-tit-pend-cr.mo-codigo <> 0 then
                           assign tt-impto-nota-db-cr.vl-base-me = 
                                  tt-impto-nota-db-cr.vl-base-me / tt-impto-nota-db-cr.cotacao-dia
                                  tt-impto-nota-db-cr.vl-imposto-me =
                                  tt-impto-nota-db-cr.vl-imposto-me / tt-impto-nota-db-cr.cotacao-dia
                                  tt-impto-nota-db-cr.vl-saldo-imposto-me = 
                                  tt-impto-nota-db-cr.vl-saldo-imposto-me / tt-impto-nota-db-cr.cotacao-dia
                                  tt-impto-nota-db-cr.vl-percepcao-me =
                                  tt-impto-nota-db-cr.vl-percepcao / tt-impto-nota-db-cr.cotacao-dia
                                  tt-impto-nota-db-cr.vl-retencao-me =
                                  tt-impto-nota-db-cr.vl-retencao / tt-impto-nota-db-cr.cotacao-dia.
    
                       delete tt-impto-tit-pend-cr.
                    end.
                    delete tt-lin-i-cr.
                    assign i-tot-doc   = i-tot-doc - 1
                           &if  defined (bf_dis_fat_moeda) &then 
                               de-vl-total = de-vl-total - fat-duplic.vl-parcela-me.
                           &else
                               de-vl-total = de-vl-total - fat-duplic.vl-parcela.
                           &endif               
                 end. /** fim das notas de d‚bito/credito **/
            end. /** for each fat-duplic **/
    
            /* acerta diferenca de valor em moeda forte apos rateio do valor dos itens ***/
            run pi-acerta-dif-me-exportacao.
    
            /*****************************************/
            /*** Abatimento de previs„es  do remito **/
            /*****************************************/
            if  i-cod-pais-imposto <> 1 then do:
                for each tt-previsao-remito:
                    find first ser-estab 
                         where ser-estab.serie       = tt-previsao-remito.serie
                         and   ser-estab.cod-estabel = tt-previsao-remito.cod-estabel no-lock no-error.
                    if  avail ser-estab then
                        assign c-especie-pre = ser-estab.cod-esp.
                    else 
                        assign c-especie-pre = "".     
    
                    if  nota-fiscal.cod-cond-pag <> 0 then do:
                        find first cond-pagto 
                             where cond-pagto.cod-cond-pag = nota-fiscal.cod-cond-pag no-lock no-error.
                        do  i-cont-parc = 1 to i-num-parcelas:
                            assign de-vl-parcela-pre = tt-previsao-remito.vl-faturado * 
                                                       (cond-pagto.per-pg-dup[i-cont-parc] / 100).
                            if  de-vl-parcela-pre > 0 then 
                                run pi-cria-lin-prev.
                        end.
                    end.
                    else do:
                        for each cond-ped where cond-ped.nr-pedido = c-nr-pedido no-lock:
                            assign de-vl-parcela-pre = (tt-previsao-remito.vl-faturado * (cond-ped.perc-pagto / 100)).
                            if de-vl-parcela-pre > 0 then
                               run pi-cria-lin-prev.
                        end.
                    end.
                end.
            end.
    
            if  i-tot-doc > 0 then do:
                find tt-doc-i-cr
                     where tt-doc-i-cr.ep-codigo   = i-empresa
                     and   tt-doc-i-cr.cod-estabel = nota-fiscal.cod-estabel
                     and   tt-doc-i-cr.referencia  = c-referencia
                     exclusive-lock no-error.
    
                if  not avail tt-doc-i-cr then do:
                    FOR first tt-lin-i-cr 
                        where tt-lin-i-cr.referencia = c-referencia no-lock: 
                        create tt-doc-i-cr.
                        assign tt-doc-i-cr.cod-versao-integ = 4
                               tt-doc-i-cr.cod-estabel = nota-fiscal.cod-estabel
                               tt-doc-i-cr.serie       = nota-fiscal.serie
                               tt-doc-i-cr.ct-credito  = estabelec.ct-recven
                               tt-doc-i-cr.sc-credito  = estabelec.sc-recven
                               tt-doc-i-cr.dt-movto    = tt-lin-i-cr.dt-emissao
                               tt-doc-i-cr.ep-codigo   = i-empresa
                               tt-doc-i-cr.referencia  = c-referencia
                               tt-doc-i-cr.total-movto = 0
                               /*tt-doc-i-cr.conta-credito = estabelec.conta-recven*/
                               tt-doc-i-cr.ct-credito  = estabelec.ct-recven
                               tt-doc-i-cr.sc-credito  = estabelec.sc-recven
                               tt-doc-i-cr.ind-elimina-lote =  1  /* 1 - nÆo deixa lote pendente */
                               tt-doc-i-cr.mo-codigo = tt-lin-i-cr.mo-codigo.
                        create doc-work.
                        assign doc-work.reg-doc = rowid(tt-doc-i-cr).
                    END.
                end.
    
              /* Nao atualizar este campo para que nao ocorra o erro 377 no cr0501d */    
              /*  assign tt-doc-i-cr.total-movto = de-vl-total. */
    
    
            end.
    
    
            create tt-total-refer.
            assign tt-total-refer.referencia     = c-referencia
                   tt-total-refer.nr-doctos      = i-tot-doc
                   tt-total-refer.vendas-a-vista = de-vl-vista
                   tt-total-refer.vendas-a-prazo = de-vl-prazo
                   tt-total-refer.vl-total       = de-vl-total
                   de-vl-total = 0
                   de-vl-vista = 0
                   de-vl-prazo = 0
                   i-tot-doc   = 0
                   i-nr-seq    = 0.
    
            find b-nota where rowid(b-nota) = tt-nota-fiscal.r-nota-fiscal EXCLUSIVE-LOCK no-error.
            if  avail b-nota then
                assign b-nota.vl-comis-nota = de-vl-comisnota.    
    
            IF c-nom-prog-upc-mg97 <> "" THEN DO:
                FOR EACH tt-epc WHERE tt-epc.cod-event = "AtualizaRepresentantes":
                    DELETE tt-epc.
                END.
    
                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "AtualizaRepresentantes"
                       tt-epc.cod-parameter = "nota-fiscal"
                       tt-epc.val-parameter = STRING(tt-nota-fiscal.r-nota-fiscal).
    
                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "AtualizaRepresentantes"
                       tt-epc.cod-parameter = "ftapi001"
                       tt-epc.val-parameter = STRING(THIS-PROCEDURE).
    
                /*------------- INICIO UPC SHV GµS -------------*/
                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "AtualizaRepresentantes"
                       tt-epc.cod-parameter = "tt-lin-ant(handle)"
                       tt-epc.val-parameter = string(temp-table tt-lin-ant:handle).
    
                {include/i-epc201.i "AtualizaRepresentantes"}
            END.        
    
            if  not l-ems5 then do:
    
                RUN AtualizaNotasEMS2.
    
            end. /*** Bloco not l-ems5 ***/
            ELSE if can-find(funcao where funcao.cd-funcao = "ems5-nota-a-nota":U
                                    and   funcao.ativo     = yes) 
                 AND i-cont-nota-trans >= i-nr-nota-a-nota then do: /* FT0603 - Nota a Nota */
    
                 DEF VAR r-nota-fiscal-auxiliar AS ROWID no-undo.
                 ASSIGN r-nota-fiscal-auxiliar = ROWID(nota-fiscal).
    
                 ASSIGN i-cont-nota-trans = 0 /* Reinicia contagem de notas por transa‡Æo */.

                 run AtualizaNotasEMS5.
    
                 /* Notas por transa‡Æo */
                 FOR EACH tt-nf-por-transacao:
                     run SetaNotasEMS5(input tt-nf-por-transacao.r-nota-fis).
                     DELETE tt-nf-por-transacao.
                 END.
    
                 IF  i-nr-nota-a-nota = 0 THEN
                     run SetaNotasEMS5(input r-nota-fiscal-auxiliar).
    
            END.    
        end. /* do trans */        
    END.
end. /* for each tt-nota-fiscal */

IF  VALID-HANDLE(h-bodi390) THEN
    delete PROCEDURE h-bodi390.
/********************************************************************************/

/* Se ainda sobraram notas que nÆo foram atualizadas no CR, quando for informado n£mero maximo de notas por transa‡Æo*/
if  l-ems5 AND can-find(funcao where funcao.cd-funcao = "ems5-nota-a-nota"
                                and   funcao.ativo     = yes) 
AND  i-cont-nota-trans <> 0 
AND  i-cont-nota-trans < i-nr-nota-a-nota then do: /* FT0603 - Nota a Nota */
     run AtualizaNotasEMS5.
     FOR EACH tt-nf-por-transacao:
         run SetaNotasEMS5(input tt-nf-por-transacao.r-nota-fis).
         DELETE tt-nf-por-transacao.
     END.
END.
if  valid-handle(h-ftapi016) then do:
    delete procedure h-ftapi016.
    assign h-ftapi016 = ?.
end.

if l-ems5 AND NOT can-find(funcao where funcao.cd-funcao = "ems5-nota-a-nota"
                                  and   funcao.ativo     = yes) then do: /* FT0603 - Nota a Nota */
    run AtualizaNotasEMS5.
    run SetaNotasEMS5(input ?).
end.

if  valid-handle(h-acomp) then 
    run pi-finalizar in h-acomp.

&IF INTEGER(ENTRY(1,PROVERSION,".")) >= 9 &THEN

IF c-nom-prog-upc-mg97 <> "" THEN DO:
    /**** EPC apos integracao com ems5  */
    for each tt-epc where tt-epc.cod-event = "valida-integra":
        delete tt-epc.
    end.

    create tt-epc.
    assign tt-epc.cod-event     = "end_ftapi001"
           tt-epc.cod-parameter = "handle_nota-fiscal"
           tt-epc.val-parameter = string(buffer tt-nota-fiscal:handle).

    {include/i-epc201.i "end_ftapi001"}  
END.

&endif

PROCEDURE pi-cria-tt-lin-i-cr:
    /*** Tratamento dos espa‡os em branco no campo tt-lin-i-cr.num-titulo-banco para corrigir o erro 
         18:26:59 Character field too long; table: EMS505BPORO8P930FIN.ITEM_LOTE_IMPL_TIT_ACR
         column: COD_TIT_ACR_BCO. (2728) ***/

    assign tt-lin-i-cr.cod-vencto        = 1
           tt-lin-i-cr.nat-operacao      = nota-fiscal.nat-operacao
           tt-lin-i-cr.cod-entrega       = nota-fiscal.cod-entrega
           tt-lin-i-cr.cod-cond-pag      = nota-fiscal.cod-cond-pag
           tt-lin-i-cr.cod-emitente      = if  i-gera-titulo = 2 /* Gera dup p/ end. cobranca */
                                           and avail b-emitente 
                                           then b-emitente.cod-emitente
                                           else emitente.cod-emitente
           tt-lin-i-cr.cod-esp           = c-cod-esp
           tt-lin-i-cr.cod-estabel       = fat-duplic.cod-estabel
           tt-lin-i-cr.serie             = fat-duplic.serie
           tt-lin-i-cr.nr-docto-vincul   = nota-fiscal.nr-nota-fis
           tt-lin-i-cr.num-titulo-banco  = trim(fat-duplic.char-1)
           tt-lin-i-cr.cod-portador      = if  not fat-duplic.log-1
                                           then if  i-portador <> 0
                                                and fat-duplic.cod-vencto = 3 
                                                then i-portador
                                                else nota-fiscal.cod-portador
                                           else fat-duplic.int-1
           tt-lin-i-cr.cod-rep          = if  nota-fiscal.cod-rep <> 0 then
                                              nota-fiscal.cod-rep
                                          ELSE  if  avail ped-venda 
                                                and avail b-repres then
                                                    b-repres.cod-rep
                                                else IF AVAIL distrib-emit-estab THEN
                                                        distrib-emit-estab.cod-rep
                                                    ELSE emitente.cod-rep
           tt-lin-i-cr.ct-conta         = fat-duplic.ct-recven 
           tt-lin-i-cr.sc-conta         = fat-duplic.sc-recven 
           /*tt-lin-i-cr.conta-credito    = if avail conta-contab 
                                          then conta-contab.conta-contabil
                                          else ""*/
           tt-lin-i-cr.dt-desconto      = v-dt-desconto
           tt-lin-i-cr.dt-emissao       = if  para-fat.ind-pro-fat
                                          or  (    l-funcao-spp-fatura
                                               and avail ser-estab
                                               and ser-estab.ind-nff)
                                          then fat-duplic.dt-emissao
                                          else nota-fiscal.dt-emis
           tt-lin-i-cr.dt-vencimen      = v-dt-venciment
           tt-lin-i-cr.dt-pg-prev       = v-dt-venciment
           tt-lin-i-cr.emite-bloq       = if  i-gera-titulo = 2 /* Gera dup p/ end. cobranca */
                                          and avail b-emitente
                                          then b-emitente.emite-bloq
                                          else emitente.emite-bloq
           tt-lin-i-cr.ep-codigo        = i-empresa
           tt-lin-i-cr.modalidade       = if  i-portador <> 0
                                          and fat-duplic.cod-vencto = 3
                                          then 1
                                          else if nota-fiscal.modalidade <> 0 
                                               then nota-fiscal.modalidade
                                               else 1
           tt-lin-i-cr.valor-fasb       = fat-duplic.vl-moeda-fasb
           tt-lin-i-cr.mo-negoc         = fat-duplic.mo-negoc
           tt-lin-i-cr.nat-operacao     = fat-duplic.nat-operacao
           tt-lin-i-cr.nr-docto         = IF  l-nr-processo 
                                          then nota-fiscal.nr-proc-exp
                                          else fat-duplic.nr-fatura
           tt-lin-i-cr.nr-pedcli        = nota-fiscal.nr-pedcli
           tt-lin-i-cr.parcela          = string(fat-duplic.parcela)
           tt-lin-i-cr.pedido-rep       = if  avail ped-venda 
                                          then ped-venda.nr-pedrep
                                          else ""
           tt-lin-i-cr.referencia       = c-referencia
           i-nr-seq                     = i-nr-seq + 10
           i-tot-doc                    = i-tot-doc + 1
           i-not-doc                    = i-not-doc + 1
           tt-lin-i-cr.sequencia        = i-nr-seq
           tt-lin-i-cr.situacao         = if  fat-duplic.cod-vencto = 3
                                          then 2
                                          else 1
           tt-lin-i-cr.log-1            = if not para-fat.ind-transitoria then yes else no
           tt-lin-i-cr.vl-bruto         = fat-duplic.vl-parcela
           tt-lin-i-cr.vl-liquido       = fat-duplic.vl-comis
           tt-lin-i-cr.vl-desconto      = fat-duplic.vl-desconto
           tt-lin-i-cr.tipo-titulo      = if  nota-fiscal.ind-tip-nota = 9 /* Nota D‚bito */
                                          then 4 /* Tipo D‚bito */
                                          else if  nota-fiscal.ind-tip-nota = 10 /* Nota Cr‚dito */
                                               then 5 /* Tipo Cr‚dito */
                                               else 1 /* Tipo Normal */
           tt-lin-i-cr.vl-abatimento    = de-abatim
           tt-lin-i-cr.vl-abatimento-me = de-abatim
           tt-lin-i-cr.tp-codigo        = natur-oper.tp-rec-desp
           tt-lin-i-cr.origem           = 2.

    /*** Atribui‡Æo dos Impostos das Duplicatas para CR conforme a LEI 10.925 artigo 31 e LEI 10.485 ***/
    /**** foi aproveitado o campo para tratar os valores para integra‡Æo com M‚xico */
    &IF '{&bf_dis_versao_ems}' >= '2.06' &THEN
        assign tt-lin-i-cr.vl-pis           = fat-duplic.val-retenc-pis
               tt-lin-i-cr.vl-cofins        = fat-duplic.val-retenc-cofins
               tt-lin-i-cr.vl-csll          = fat-duplic.val-retenc-csll
               tt-lin-i-cr.vl-base-calc-ret = IF fat-duplic.val-retenc-pis    > 0 OR  
                                                 fat-duplic.val-retenc-cofins > 0 OR
                                                 fat-duplic.val-retenc-csll   > 0 OR 
                                                 l-america-latina /* mexico */
                                              THEN fat-duplic.val-base-contrib-social
                                              ELSE 0
               tt-lin-i-cr.l-ret-impto      = fat-duplic.log-impto-retid.
    &ELSE
        assign tt-lin-i-cr.vl-pis           = dec(substring(fat-duplic.char-2,1,14))
               tt-lin-i-cr.vl-cofins        = dec(substring(fat-duplic.char-2,15,14))
               tt-lin-i-cr.vl-csll          = dec(substring(fat-duplic.char-2,29,14))
               tt-lin-i-cr.vl-base-calc-ret = IF tt-lin-i-cr.vl-pis    > 0 OR
                                                 tt-lin-i-cr.vl-cofins > 0 OR
                                                 tt-lin-i-cr.vl-csll   > 0
                                              THEN dec(substring(fat-duplic.char-2,43,14))
                                              ELSE 0
               tt-lin-i-cr.l-ret-impto      = (substring(fat-duplic.char-2,57,1) = "S").
    &ENDIF
END PROCEDURE. 

PROCEDURE pi-cria-tt-impto-tit-pend-cr:
    if de-vl-parcela <> 0 then do:
        find tipo-tax where tipo-tax.cod-tax = i-cod-tax no-lock no-error.
        create tt-impto-tit-pend-cr.
        assign tt-impto-tit-pend-cr.cod-classificacao    = if avail tipo-tax then tipo-tax.cod-classificacao else 0
               tt-impto-tit-pend-cr.cod-emitente         = tt-lin-i-cr.cod-emitente
               tt-impto-tit-pend-cr.cod-esp              = tt-lin-i-cr.cod-esp
               tt-impto-tit-pend-cr.cod-estabel          = tt-lin-i-cr.cod-estabel
               tt-impto-tit-pend-cr.cod-imposto          = it-nota-imp.cod-taxa
               tt-impto-tit-pend-cr.ct-imposto           = tipo-tax.ct-tax
               tt-impto-tit-pend-cr.sc-imposto           = tipo-tax.sc-tax 
               tt-impto-tit-pend-cr.ct-retencao          = tipo-tax.ct-retencao 
               tt-impto-tit-pend-cr.sc-retencao          = tipo-tax.sc-retencao 
               tt-impto-tit-pend-cr.ct-saldo-credito     = tipo-tax.ct-saldo-credito 
               tt-impto-tit-pend-cr.sc-saldo-credito     = tipo-tax.sc-saldo-credito
               tt-impto-tit-pend-cr.contabilizou         = yes
               tt-impto-tit-pend-cr.dt-emissao           = tt-lin-i-cr.dt-emissao
               tt-impto-tit-pend-cr.ep-codigo            = tt-lin-i-cr.ep-codigo
               tt-impto-tit-pend-cr.ind-tip-calculo      = if tipo-tax.ind-tip-calculo <> 0 then tipo-tax.ind-tip-calculo else 1
               tt-impto-tit-pend-cr.ind-tipo-imposto     = if tipo-tax <> 0 then tipo-tax.ind-tipo-imposto else 1
               tt-impto-tit-pend-cr.mo-codigo            = tt-lin-i-cr.mo-codigo  
               tt-impto-tit-pend-cr.nat-operacao         = nota-fiscal.nat-operacao
               tt-impto-tit-pend-cr.nr-docto             = tt-lin-i-cr.nr-docto
               tt-impto-tit-pend-cr.num-seq-impto        = it-nota-imp.nr-seq-imp
               tt-impto-tit-pend-cr.parcela              = tt-lin-i-cr.parcela
               tt-impto-tit-pend-cr.perc-imposto         = tipo-tax.tax-perc 
               tt-impto-tit-pend-cr.perc-retencao        = tipo-tax.perc-retencao 
               tt-impto-tit-pend-cr.serie                = tt-lin-i-cr.serie
               tt-impto-tit-pend-cr.tipo                 = if tipo-tax.tipo <> 0 then tipo-tax.tipo else 1
               tt-impto-tit-pend-cr.vl-base              = it-nota-imp.vl-base-imp
               tt-impto-tit-pend-cr.vl-base-me           = it-nota-imp.vl-base-imp
               tt-impto-tit-pend-cr.vl-imposto           = de-vl-parcela
               tt-impto-tit-pend-cr.vl-imposto-me        = de-vl-parcela
               tt-impto-tit-pend-cr.vl-retencao          = de-vl-parcela
               tt-impto-tit-pend-cr.ind-data-base        = if tipo-tax.ind-data-base <> 0 then tipo-tax.ind-data-base else 1
               tt-impto-tit-pend-cr.lancamento           = 2
               tt-impto-tit-pend-cr.origem-impto         = if it-nota-imp.int-1 = 9 then 9 else 1 
               tt-impto-tit-pend-cr.transacao-impto      = 14
               tt-impto-tit-pend-cr.vl-saldo-imposto     = de-vl-parcela
               tt-impto-tit-pend-cr.vl-saldo-imposto-me  = de-vl-parcela
               tt-impto-tit-pend-cr.cotacao-dia          = tt-lin-i-cr.cotacao-dia.

               /* IVA Taxado - Tratamento Paraguai */
               IF i-cod-pais-imposto = 9 THEN DO:
                  ASSIGN tt-impto-tit-pend-cr.tipo = 2 /* Sempre enviar o imposto como Tipo Valor Agregado ao ACR */
                         tt-impto-tit-pend-cr.ind-tip-calculo      = 1
                         tt-impto-tit-pend-cr.ind-tipo-imposto     = 2.
               END.

        if  tt-impto-tit-pend-cr.mo-codigo <> 0 then
            assign tt-impto-tit-pend-cr.vl-base-me = 
                   tt-impto-tit-pend-cr.vl-base-me / tt-lin-i-cr.cotacao-dia
                   tt-impto-tit-pend-cr.vl-imposto-me =
                   tt-impto-tit-pend-cr.vl-imposto-me / tt-lin-i-cr.cotacao-dia
                   tt-impto-tit-pend-cr.vl-saldo-imposto-me = 
                   tt-impto-tit-pend-cr.vl-saldo-imposto-me / tt-lin-i-cr.cotacao-dia
                   tt-impto-tit-pend-cr.vl-percepcao-me =
                   tt-impto-tit-pend-cr.vl-percepcao / tt-lin-i-cr.cotacao-dia
                   tt-impto-tit-pend-cr.vl-retencao-me =
                   tt-impto-tit-pend-cr.vl-retencao / tt-lin-i-cr.cotacao-dia.

        assign i-cod-tax         = it-nota-imp.cod-tax
               de-vl-parcela     = 0 
               de-vl-tot-imposto = 0
               de-vl-imposto     = 0
               de-vl-imposto     = 0.
    END.

END PROCEDURE.


PROCEDURE pi-atualizar-nota:
    /*************************************************************************************
     ** O status da nota e atualizado quando a nota nao emite duplicata ou quando emite 
     ** e EFETIVAMENTE as duplicatas da mesma foram geradas para o contas a receber
     **
     ** Obs.: O ind-sit-nota nÆo ‚ mais atualizado em virtude da possibilidade
     **       da integra‡Æo com o CR ser automÿtica (sem imprimir a nota antes) 
     *************************************************************************************/
    if  tt-nota-fiscal.atualizar
    and not can-find(first tt-retorno-nota-fiscal
                     where tt-retorno-nota-fiscal.situacao   = no
                     and   tt-retorno-nota-fiscal.referencia = c-referencia) 
    and (   can-find(first tt-retorno-nota-fiscal
                     where tt-retorno-nota-fiscal.situacao
                     and   tt-retorno-nota-fiscal.referencia = c-referencia) 
         or para-fat.int-exp-cr <> 1                   /* Exporta CR */ 
         or not nota-fiscal.emite-duplic               /* NÆo Gera Duplicatas */
         or avail b-fat-duplic-orig                    /* Outras Notas Relacionadas a Fatura */
         or not param-global.modulo-cr ) then          /* NÆo tem o CR implantado localmente */
    do:
        for each fat-duplic use-index ch-fatura EXCLUSIVE-LOCK
            where fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
            and   fat-duplic.serie         = nota-fiscal.serie
            and   fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
            and  (fat-duplic.cod-esp       = "CV"
             OR   fat-duplic.cod-esp       = "CE" )
            and   fat-duplic.ind-fat-nota  = 1
            and   fat-duplic.flag-atualiz  = no:
            assign fat-duplic.flag-atualiz = yes.
        end.

        find b-nota 
             where rowid(b-nota) = tt-nota-fiscal.r-nota-fiscal EXCLUSIVE-LOCK no-error.

        if  not b-nota.emite-duplic then
            assign b-nota.dt-atual-cr = today.
        else 
            find first fat-duplic
                where fat-duplic.cod-estabel = b-nota.cod-estabel
                and   fat-duplic.serie       = b-nota.serie
                and   fat-duplic.nr-fatura   = b-nota.nr-fatura
                AND  (fat-duplic.cod-esp     = "CV"
                 OR   fat-duplic.cod-esp     = "CE" )
                and   fat-duplic.flag-atualiz no-lock no-error.
            if  avail fat-duplic then
                assign b-nota.dt-atual-cr = today.

        IF i-pais-impto-usuario <> 1 and para-fat.ind-transitoria THEN
            {utp/ut-liter.i Contas_a_Receber_e_Contabilidade_atualizados_com_sucesso * R}
        else
            run utp/ut-msgs.p (input "msg",
                               input 4070,
                               input "").

        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 1
               tt-retorno-nota-fiscal.cod-erro   = "9999"
               tt-retorno-nota-fiscal.desc-erro  = return-value
               tt-retorno-nota-fiscal.situacao   = yes
               tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
               tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                   string(i-empresa) + "," +
                                                   nota-fiscal.cod-estabel + ",," +
                                                   nota-fiscal.serie + "," +
                                                   (if nota-fiscal.nr-fatura = "" then
                                                      nota-fiscal.nr-nota-fis 
                                                   else 
                                                      nota-fiscal.nr-fatura) + "," + "," +
                                                   (if avail tt-lin-i-cr 
                                                       then
                                                          string(tt-lin-i-cr.cod-portador) + "," +
                                                          string(tt-lin-i-cr.modalidade)
                                                       else ",").
        /*--------- INICIO UPC FO 1336840 ---------*/
        if  c-nom-prog-upc-mg97 <> "" then DO:
            for each tt-epc where tt-epc.cod-event = "after-atualiza-nota":
                delete tt-epc.
            end.
    
            create tt-epc.
            assign tt-epc.cod-event     = "after-atualiza-nota"
                   tt-epc.cod-parameter = "nota-fiscal rowid"
                   tt-epc.val-parameter = string(ROWID(nota-fiscal)).
    
            {include/i-epc201.i "after-atualiza-nota"}
        END.
        /*--------- FINAL UPC FO 1336840 ---------*/
        IF i-pais-impto-usuario <> 1 and para-fat.ind-transitoria THEN DO:

            ASSIGN b-nota.ind-contabil = YES.

            &IF DEFINED(bf_dis_versao_ems) &THEN
                &IF '{&bf_dis_versao_ems}' > '2.04' &THEN
                    ASSIGN b-nota.refer-cr = c-referencia.
                &ENDIF
            &ENDIF                    
        END.
        find tt-retorno-nota-fiscal
            where tt-retorno-nota-fiscal.cod-erro = "EMS5_OK"
              and tt-retorno-nota-fiscal.situacao = yes exclusive-lock no-error.
            if avail tt-retorno-nota-fiscal then 
                delete tt-retorno-nota-fiscal.
    end.

END PROCEDURE.

/* Cria registros lin-prev */
procedure pi-cria-lin-prev:
    for first titulo
        fields (ep-codigo cod-estabel serie cod-esp nr-docto parcela mo-codigo vl-saldo)  
        where titulo.ep-codigo = i-empresa      
        and   titulo.cod-estabel  = tt-previsao-remito.cod-estabel 
        and   titulo.serie       = tt-previsao-remito.serie       
        and   titulo.cod-esp     = c-especie-pre                  
        and   titulo.nr-docto    = tt-previsao-remito.nr-remito   
        and   titulo.parcela     = string(i-cont-parc,"99") no-lock:

        find first tt-lin-prev 
             where tt-lin-prev.ep-cod-pre   = titulo.ep-codigo   
             and   tt-lin-prev.serie-pre    = titulo.serie       
             and   tt-lin-prev.cod-est-pre  = titulo.cod-estabel 
             and   tt-lin-prev.cod-esp-pre  = titulo.cod-esp     
             and   tt-lin-prev.nr-docto-pre = titulo.nr-docto    
             and   tt-lin-prev.parcela-pre  = titulo.parcela no-error.

        if (not avail tt-lin-prev and titulo.vl-saldo > 0) then do:
            create tt-lin-prev.
            assign tt-lin-prev.ep-codigo      = i-empresa
                   tt-lin-prev.cod-estabel    = tt-lin-i-cr.cod-estabel
                   tt-lin-prev.cod-esp        = tt-lin-i-cr.cod-esp
                   tt-lin-prev.nr-docto       = tt-lin-i-cr.nr-docto
                   tt-lin-prev.parcela        = titulo.parcela
                   tt-lin-prev.ep-cod-pre     = titulo.ep-codigo
                   tt-lin-prev.cod-est-pre    = titulo.cod-estabel
                   tt-lin-prev.cod-esp-pre    = c-especie-pre
                   tt-lin-prev.nr-docto-pre   = titulo.nr-docto     
                   tt-lin-prev.parcela-pre    = titulo.parcela
                   tt-lin-prev.moeda-pre      = titulo.mo-codigo
                   tt-lin-prev.serie          = tt-lin-i-cr.serie
                   tt-lin-prev.serie-pre      = titulo.serie.

            if (titulo.vl-saldo - de-vl-parcela-pre) < 0 then do:
                assign de-vl-parcela-pre = titulo.vl-saldo.
            end.

            assign tt-lin-prev.vl-previsao    =  de-vl-parcela-pre
                   tt-lin-prev.vl-previsao-me = (tt-lin-prev.vl-previsao / tt-lin-i-cr.cotacao-dia).                            

        end. 
        else do:
            if (titulo.vl-saldo - tt-lin-prev.vl-previsao - de-vl-parcela-pre) < 0 then
                assign de-vl-parcela-pre = (titulo.vl-saldo - tt-lin-prev.vl-previsao).
            assign tt-lin-prev.vl-previsao    = tt-lin-prev.vl-previsao + de-vl-parcela-pre
                   tt-lin-prev.vl-previsao-me = (tt-lin-prev.vl-previsao / tt-lin-i-cr.cotacao-dia).
        end.
    end. 
end.

/* Elimina registros das temp tables */
procedure pi-elimina-temp-tables:
    for each doc-work EXCLUSIVE-LOCK:            
        delete doc-work. 
    end.
    for each tt-doc-i-cr EXCLUSIVE-LOCK:         
        delete tt-doc-i-cr. 
    end.
    for each tt-lin-i-cr EXCLUSIVE-LOCK:         
        delete tt-lin-i-cr. 
    end.
    for each tt-rep-i-cr EXCLUSIVE-LOCK:         
        delete tt-rep-i-cr. 
    end.
    for each tt-retorno-lin-i-cr EXCLUSIVE-LOCK: 
        delete tt-retorno-lin-i-cr. 
    end.
    for each tt-lin-prev EXCLUSIVE-LOCK:         
        delete tt-lin-prev. 
    end.
    for each tt-lin-ant EXCLUSIVE-LOCK:          
        delete tt-lin-ant. 
    end.   
    for each tt-lin-ven EXCLUSIVE-LOCK:          
        delete tt-lin-ven.          
    end.
    for each tt-seven EXCLUSIVE-LOCK:            
        delete tt-seven.            
    end.    
    for each tt-nota-db-cr EXCLUSIVE-LOCK:       
        delete tt-nota-db-cr.       
    end.
    for each tt-impto-nota-db-cr EXCLUSIVE-LOCK: 
        delete tt-impto-nota-db-cr. 
    end.
/*
    for each tt-retorno-nota:     
        delete tt-retorno-nota.     
    end.
*/
    for each tt-parametros-aux:
        delete tt-parametros-aux.
    end.
    for each tt-dados-env:
        delete tt-dados-env.
    end.
    for each tt-fat-duplic-lido:
        delete tt-fat-duplic-lido.
    end.
end procedure.

/*******************************************************************************
** Procedure de exporta‡Æo de dados para arquivo texto sem layout para importa‡Æo,
** pelo programa CR0515
*******************************************************************************/

procedure pi-exporta-dados:

   output stream s-exporta to value(c-arquivo-exp) append.

   for each tt-lin-i-cr
       break by tt-lin-i-cr.dt-emissao:

        put stream s-exporta "1" skip.
        export stream s-exporta tt-lin-i-cr.

        for each tt-rep-i-cr
            where tt-rep-i-cr.ep-codigo   = tt-lin-i-cr.ep-codigo
            and   tt-rep-i-cr.cod-estabel = tt-lin-i-cr.cod-estabel
            and   tt-rep-i-cr.cod-esp     = tt-lin-i-cr.cod-esp
            and   tt-rep-i-cr.serie       = tt-lin-i-cr.serie
            and   tt-rep-i-cr.nr-docto    = tt-lin-i-cr.nr-docto
            and   tt-rep-i-cr.parcela     = tt-lin-i-cr.parcela no-lock:

            put stream s-exporta "2" skip.
            export stream s-exporta tt-rep-i-cr.

        end.    

        /* eccher - colocar dados do vendor */

        if  last-of(tt-lin-i-cr.dt-emissao) then do:
            find tt-doc-i-cr 
                 where tt-doc-i-cr.ep-codigo   = tt-lin-i-cr.ep-codigo
                 and   tt-doc-i-cr.referencia  = tt-lin-i-cr.referencia
                 and   tt-doc-i-cr.cod-estabel = tt-lin-i-cr.cod-estabel
                 no-error.
            put stream s-exporta "4" skip.
            export stream s-exporta tt-doc-i-cr.
        end.

   end.

    output stream s-exporta close.

end procedure.

PROCEDURE AtualizaNotasEMS2:

    if para-fat.int-exp-cr = 1 then do:  /* Integra */
        /* Atualiza‡Æo das notas fiscais no CR */
        RUN crp/crapi001c.p persistent set h-api.
        run execute in h-api (input table tt-doc-i-cr,
                              input table tt-lin-i-cr,
                              input table tt-ext-lin-i-cr,
                              input table tt-rep-i-cr,
                              input table tt-lin-ant,
                              input table tt-lin-prev,
                              input table tt-impto-tit-pend-cr,
                              input table tt-lin-ven,
                              input table tt-ext-impto-tit-pend-cr,
                              output table tt-retorno-lin-i-cr).
        DELETE PROCEDURE h-api.
    end.
    else 
        run pi-exporta-dados.

    for each tt-retorno-lin-i-cr:

        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 2
               tt-retorno-nota-fiscal.cod-erro   = tt-retorno-lin-i-cr.cod-erro
               tt-retorno-nota-fiscal.desc-erro  = tt-retorno-lin-i-cr.desc-erro
               tt-retorno-nota-fiscal.situacao   = tt-retorno-lin-i-cr.situacao
               tt-retorno-nota-fiscal.referencia = entry(1,tt-retorno-lin-i-cr.cod-chave,",")
               tt-retorno-nota-fiscal.cod-chave  = tt-retorno-lin-i-cr.cod-chave + ",," no-error.

        if  entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "" then
           assign ENTRY(7,tt-retorno-nota-fiscal.cod-chave, ",") = nota-fiscal.nr-nota-fis.
    end.

    /* Atualiza‡Æo das notas de D‚bito / Cr‚dito */
    IF  nota-fiscal.ind-tip-nota = 10
    OR  nota-fiscal.ind-tip-nota = 9
    or  l-gerou-tt-nota-db-cr = yes THEN DO:

        /* Implementa‡Æo para manter compatibilidade com a crapi009 */
        for each tt-ext-lin-i-cr:
            create tt-ext-lin-i-cr-aux.
            assign tt-ext-lin-i-cr-aux.ep-codigo         = tt-ext-lin-i-cr.ep-codigo
                   tt-ext-lin-i-cr-aux.referencia        = tt-ext-lin-i-cr.referencia
                   tt-ext-lin-i-cr-aux.sequencia         = tt-ext-lin-i-cr.sequencia
                   tt-ext-lin-i-cr-aux.cod-esp           = tt-ext-lin-i-cr.cod-esp
                   tt-ext-lin-i-cr-aux.cod-estabel       = tt-ext-lin-i-cr.cod-estabel
                   tt-ext-lin-i-cr-aux.nr-docto          = tt-ext-lin-i-cr.nr-docto     
                   tt-ext-lin-i-cr-aux.parcela           = tt-ext-lin-i-cr.parcela      
                   tt-ext-lin-i-cr-aux.cod-emitente      = tt-ext-lin-i-cr.cod-emitente 
                   tt-ext-lin-i-cr-aux.cod-rep           = tt-ext-lin-i-cr.cod-rep      
                   tt-ext-lin-i-cr-aux.cod-portador      = tt-ext-lin-i-cr.cod-portador   
                   tt-ext-lin-i-cr-aux.modalidade        = tt-ext-lin-i-cr.modalidade
                   tt-ext-lin-i-cr-aux.dt-emissao        = tt-ext-lin-i-cr.dt-emissao 
                   tt-ext-lin-i-cr-aux.dt-vencimen       = tt-ext-lin-i-cr.dt-vencimen 
                   tt-ext-lin-i-cr-aux.vl-bruto          = tt-ext-lin-i-cr.vl-bruto      
                   tt-ext-lin-i-cr-aux.vl-liquido        = tt-ext-lin-i-cr.vl-liquido
                   tt-ext-lin-i-cr-aux.dt-desconto       = tt-ext-lin-i-cr.dt-desconto   
                   tt-ext-lin-i-cr-aux.vl-desconto       = tt-ext-lin-i-cr.vl-desconto   
                   tt-ext-lin-i-cr-aux.pedido-rep        = tt-ext-lin-i-cr.pedido-rep    
                   tt-ext-lin-i-cr-aux.nat-operacao      = tt-ext-lin-i-cr.nat-operacao 
                   tt-ext-lin-i-cr-aux.nr-pedcli         = tt-ext-lin-i-cr.nr-pedcli
                   tt-ext-lin-i-cr-aux.situacao          = tt-ext-lin-i-cr.situacao      
                   tt-ext-lin-i-cr-aux.emite-bloq        = tt-ext-lin-i-cr.emite-bloq  
                   tt-ext-lin-i-cr-aux.ct-conta          = tt-ext-lin-i-cr.ct-conta  
                   tt-ext-lin-i-cr-aux.sc-conta          = tt-ext-lin-i-cr.sc-conta 
                   tt-ext-lin-i-cr-aux.cod-cond-pag      = tt-ext-lin-i-cr.cod-cond-pag  
                   tt-ext-lin-i-cr-aux.cod-vencto        = tt-ext-lin-i-cr.cod-vencto
                   tt-ext-lin-i-cr-aux.vl-fatura         = tt-ext-lin-i-cr.vl-fatura     
                   tt-ext-lin-i-cr-aux.seq-import        = tt-ext-lin-i-cr.seq-import   
                   tt-ext-lin-i-cr-aux.tp-codigo         = tt-ext-lin-i-cr.tp-codigo   
                   tt-ext-lin-i-cr-aux.vl-abatimento     = tt-ext-lin-i-cr.vl-abatimento 
                   tt-ext-lin-i-cr-aux.u-data-1          = tt-ext-lin-i-cr.u-data-1      
                   tt-ext-lin-i-cr-aux.valor-cmi         = tt-ext-lin-i-cr.valor-cmi     
                   tt-ext-lin-i-cr-aux.valor-pres        = tt-ext-lin-i-cr.valor-pres     
                   tt-ext-lin-i-cr-aux.valor-fasb        = tt-ext-lin-i-cr.valor-fasb    
                   tt-ext-lin-i-cr-aux.cod-controle      = tt-ext-lin-i-cr.cod-controle   
                   tt-ext-lin-i-cr-aux.origem            = tt-ext-lin-i-cr.origem      
                   tt-ext-lin-i-cr-aux.mercado           = tt-ext-lin-i-cr.mercado        
                   tt-ext-lin-i-cr-aux.mo-negoc          = tt-ext-lin-i-cr.mo-negoc
                   /*tt-ext-lin-i-cr-aux.conta-credito     = tt-ext-lin-i-cr.conta-credito  */
                   tt-ext-lin-i-cr-aux.serie             = tt-ext-lin-i-cr.serie          
                   tt-ext-lin-i-cr-aux.contabilizou      = tt-ext-lin-i-cr.contabilizou 
                   tt-ext-lin-i-cr-aux.cotacao-dia       = tt-ext-lin-i-cr.cotacao-dia
                   tt-ext-lin-i-cr-aux.diversos          = tt-ext-lin-i-cr.diversos  
                   tt-ext-lin-i-cr-aux.dt-pg-prev        = tt-ext-lin-i-cr.dt-pg-prev
                   tt-ext-lin-i-cr-aux.frete             = tt-ext-lin-i-cr.frete      
                   tt-ext-lin-i-cr-aux.l-calc-desc       = tt-ext-lin-i-cr.l-calc-desc          
                   tt-ext-lin-i-cr-aux.mo-codigo         = tt-ext-lin-i-cr.mo-codigo      
                   tt-ext-lin-i-cr-aux.observacao        = tt-ext-lin-i-cr.observacao  
                   tt-ext-lin-i-cr-aux.tipo-titulo       = tt-ext-lin-i-cr.tipo-titulo 
                   tt-ext-lin-i-cr-aux.cod-esp-vincul    = tt-ext-lin-i-cr.cod-esp-vincul 
                   tt-ext-lin-i-cr-aux.serie-vincul      = tt-ext-lin-i-cr.serie-vincul
                   tt-ext-lin-i-cr-aux.nr-docto-vincul   = tt-ext-lin-i-cr.nr-docto-vincul
                   tt-ext-lin-i-cr-aux.parcela-vincul    = tt-ext-lin-i-cr.parcela-vincul 
                   tt-ext-lin-i-cr-aux.vl-bruto-me       = tt-ext-lin-i-cr.vl-bruto-me   
                   tt-ext-lin-i-cr-aux.frete-me          = tt-ext-lin-i-cr.frete-me      
                   tt-ext-lin-i-cr-aux.diversos-me       = tt-ext-lin-i-cr.diversos-me     
                   tt-ext-lin-i-cr-aux.vl-liquido-me     = tt-ext-lin-i-cr.vl-liquido-me  
                   tt-ext-lin-i-cr-aux.vl-desconto-me    = tt-ext-lin-i-cr.vl-desconto-me 
                   tt-ext-lin-i-cr-aux.vl-fatura-me      = tt-ext-lin-i-cr.vl-fatura-me
                   tt-ext-lin-i-cr-aux.vl-abatimento-me  = tt-ext-lin-i-cr.vl-abatimento-me 
                   tt-ext-lin-i-cr-aux.char-1            = tt-ext-lin-i-cr.char-1        
                   tt-ext-lin-i-cr-aux.char-2            = tt-ext-lin-i-cr.char-2         
                   tt-ext-lin-i-cr-aux.dec-1             = tt-ext-lin-i-cr.dec-1         
                   tt-ext-lin-i-cr-aux.dec-2             = tt-ext-lin-i-cr.dec-2          
                   tt-ext-lin-i-cr-aux.int-1             = tt-ext-lin-i-cr.int-1       
                   tt-ext-lin-i-cr-aux.int-2             = tt-ext-lin-i-cr.int-2        
                   tt-ext-lin-i-cr-aux.log-1             = tt-ext-lin-i-cr.log-1         
                   tt-ext-lin-i-cr-aux.log-2             = tt-ext-lin-i-cr.log-2          
                   tt-ext-lin-i-cr-aux.data-1            = tt-ext-lin-i-cr.data-1     
                   tt-ext-lin-i-cr-aux.data-2            = tt-ext-lin-i-cr.data-2          
                   tt-ext-lin-i-cr-aux.perc-multa        = tt-ext-lin-i-cr.perc-multa    
                   tt-ext-lin-i-cr-aux.dt-multa          = tt-ext-lin-i-cr.dt-multa       
                   tt-ext-lin-i-cr-aux.nr-docto-deposito = tt-ext-lin-i-cr.nr-docto-deposito
                   tt-ext-lin-i-cr-aux.cod-entrega       = tt-ext-lin-i-cr.cod-entrega
                   tt-ext-lin-i-cr-aux.check-sum         = tt-ext-lin-i-cr.check-sum
                   tt-ext-lin-i-cr-aux.num-titulo-banco  = tt-ext-lin-i-cr.num-titulo-banco
                   tt-ext-lin-i-cr-aux.tp-ret-iva        = tt-ext-lin-i-cr.tp-ret-iva
                   tt-ext-lin-i-cr-aux.tp-ret-gan        = tt-ext-lin-i-cr.tp-ret-gan
                   tt-ext-lin-i-cr-aux.acum-ant-gan      = tt-ext-lin-i-cr.acum-ant-gan
                   tt-ext-lin-i-cr-aux.vl-base-gan       = tt-ext-lin-i-cr.vl-base-gan
                   tt-ext-lin-i-cr-aux.gravado           = tt-ext-lin-i-cr.gravado
                   tt-ext-lin-i-cr-aux.no-gravado        = tt-ext-lin-i-cr.no-gravado
                   tt-ext-lin-i-cr-aux.isento            = tt-ext-lin-i-cr.isento   
                   tt-ext-lin-i-cr-aux.uf-entrega        = tt-ext-lin-i-cr.uf-entrega.
        end.

        run crp/crapi009.p (input  i-empresa,
                            input  table tt-nota-db-cr,
                            input  table tt-impto-nota-db-cr,
                            input  table tt-ext-lin-i-cr-aux,
                            output table tt-retorno-nota,
                            output table tt-erro).
    END.

    for each tt-retorno-nota:

        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 3
               tt-retorno-nota-fiscal.cod-erro   = tt-retorno-nota.cod-erro
               tt-retorno-nota-fiscal.desc-erro  = tt-retorno-nota.desc-erro
               tt-retorno-nota-fiscal.situacao   = tt-retorno-nota.situacao
               tt-retorno-nota-fiscal.referencia = entry(1,tt-retorno-nota.cod-chave,",")
               tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota.cod-chave + ",," no-error.

        if  entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "" then
           assign ENTRY(7,tt-retorno-nota-fiscal.cod-chave, ",") = nota-fiscal.nr-nota-fis.

    end.

    for first b-fat-duplic-orig fields ()
        where b-fat-duplic-orig.cod-estabel  = nota-fiscal.cod-estabel
          and b-fat-duplic-orig.serie        = nota-fiscal.serie
          and b-fat-duplic-orig.nr-fatura    = nota-fiscal.nr-fatura
          and b-fat-duplic-orig.flag-atualiz   no-lock.
    end.

    RUN pi-atualizar-nota.


END PROCEDURE.

procedure AtualizaNotasEMS5:
    /****************** BLOCO DE ATUALIZA°€O DAS TEMP-TABLES ************************/
    if  para-fat.int-exp-cr = 1 then do: /* Integra */

        run ftp/ftapi017esp.p 
                           (input table tt-doc-i-cr,
                            input table tt-lin-i-cr,
                            input table tt-ext-lin-i-cr,
                            input table tt-rep-i-cr,
                            input table tt-lin-ant,
                            input table tt-lin-prev,
                            input table tt-impto-tit-pend-cr,
                            &IF DEFINED(BF_DIS_VERSAO_EMS) &THEN
                                 &IF '{&BF_DIS_VERSAO_EMS}' >= '2.042' &THEN
                                     input table tt-impto-tit-pend-cr-1,
                                 &ENDIF
                            &ENDIF
                            input table tt-lin-ven,
                            input table tt-ext-impto-tit-pend-cr,
                            input-output table tt-retorno-nota-fiscal).


        IF i-pais-impto-usuario <> 1 
        and para-fat.ind-transitoria = yes THEN 
            for each tt-retorno-nota-fiscal WHERE tt-retorno-nota-fiscal.situacao = no:

                find tt-nota-fiscal 
                    where tt-nota-fiscal.referencia = tt-retorno-nota-fiscal.referencia no-lock no-error.

                for first nota-fiscal fields(cod-estabel serie nr-nota-fis)
                    where rowid(nota-fiscal) = tt-nota-fiscal.r-nota-fiscal no-lock:
                end.

                FIND FIRST sumar-ft
                    WHERE sumar-ft.nr-nota-fis = nota-fiscal.nr-nota-fis NO-LOCK NO-ERROR.

                IF AVAIL tt-retorno-nota-fiscal 
                and avail sumar-ft THEN
                    FOR EACH sumar-ft 
                        WHERE sumar-ft.cod-estabel = nota-fiscal.cod-estabel
                        AND   sumar-ft.serie       = nota-fiscal.serie
                        AND   sumar-ft.nr-nota-fis = nota-fiscal.nr-nota-fis EXCLUSIVE-LOCK:
                        DELETE sumar-ft VALIDATE (TRUE, "").
                    END.
            end.
    end.
    else 
        run pi-exporta-dados.

    for each tt-retorno-lin-i-cr:
        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 2
               tt-retorno-nota-fiscal.cod-erro   = tt-retorno-lin-i-cr.cod-erro
               tt-retorno-nota-fiscal.desc-erro  = tt-retorno-lin-i-cr.desc-erro
               tt-retorno-nota-fiscal.situacao   = tt-retorno-lin-i-cr.situacao
               tt-retorno-nota-fiscal.referencia = entry(1,tt-retorno-lin-i-cr.cod-chave,",")
               tt-retorno-nota-fiscal.cod-chave  = tt-retorno-lin-i-cr.cod-chave + ",," no-error.

        if  entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "" then
           assign ENTRY(7,tt-retorno-nota-fiscal.cod-chave, ",") = nota-fiscal.nr-nota-fis.
    end.

    for each tt-retorno-nota:
        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 3
               tt-retorno-nota-fiscal.cod-erro   = tt-retorno-nota.cod-erro
               tt-retorno-nota-fiscal.desc-erro  = tt-retorno-nota.desc-erro
               tt-retorno-nota-fiscal.situacao   = tt-retorno-nota.situacao
               tt-retorno-nota-fiscal.referencia = entry(1,tt-retorno-nota.cod-chave,",")
               tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota.cod-chave + ",," no-error.

        if  entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "" then
           assign ENTRY(7,tt-retorno-nota-fiscal.cod-chave, ",") = nota-fiscal.nr-nota-fis.

    end.

    run pi-elimina-temp-tables. /* Elimina registros das temp tables */
end.

procedure SetaNotasEMS5:
    /**************** BLOCO DE ATUALIZA°€O DE FLAGS DAS NOTAS FISCAIS ***************/
    def input param p-rw-nota-fiscal as rowid no-undo.

    for each tt-nota-fiscal
        where if p-rw-nota-fiscal <> ? 
              then tt-nota-fiscal.r-nota-fiscal = p-rw-nota-fiscal
              else yes:

        IF NOT tt-nota-fiscal.atualizar THEN NEXT.

        find nota-fiscal
            where rowid(nota-fiscal) = tt-nota-fiscal.r-nota-fiscal EXCLUSIVE-LOCK NO-ERROR.

        for first b-fat-duplic-orig fields ()
            where b-fat-duplic-orig.cod-estabel  = tt-nota-fiscal.cod-estabel
              and b-fat-duplic-orig.serie        = tt-nota-fiscal.serie
              and b-fat-duplic-orig.nr-fatura    = tt-nota-fiscal.nr-fatura
              and b-fat-duplic-orig.flag-atualiz = yes no-lock:
        end.

        if  not can-find(first tt-retorno-nota-fiscal
                         where tt-retorno-nota-fiscal.situacao   = no
                         and   tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia) 

        and (   can-find(first tt-retorno-nota-fiscal
                         where tt-retorno-nota-fiscal.situacao   = yes
                         and   tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia) 
             or para-fat.int-exp-cr <> 1                   /* Exporta CR */ 
             or not nota-fiscal.emite-duplic               /* NÆo Gera Duplicatas */
             or avail b-fat-duplic-orig                    /* Outras Notas Relacionadas a Fatura */
             or not param-global.modulo-cr ) then          /* NÆo tem o CR implantado localmente */
        do:

            for each b-fat-duplic  fields (flag-atualiz) EXCLUSIVE-LOCK use-index ch-fatura
                where b-fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                and   b-fat-duplic.serie         = nota-fiscal.serie
                and   b-fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
                and   b-fat-duplic.ind-fat-nota  = 1
                and   b-fat-duplic.flag-atualiz  = no:
                assign b-fat-duplic.flag-atualiz = yes.
            end.

            if  not nota-fiscal.emite-duplic then
                assign nota-fiscal.dt-atual-cr = today.
            else 
            do:
                find first b-fat-duplic
                    where b-fat-duplic.cod-estabel  = nota-fiscal.cod-estabel
                    and   b-fat-duplic.serie        = nota-fiscal.serie
                    and   b-fat-duplic.nr-fatura    = nota-fiscal.nr-fatura
                    and   b-fat-duplic.flag-atualiz = yes no-lock no-error.
                if  avail b-fat-duplic then
                    assign nota-fiscal.dt-atual-cr = today.
            end.

            IF i-pais-impto-usuario <> 1 and para-fat.ind-transitoria THEN
                {utp/ut-liter.i Contas_a_Receber_e_Contabilidade_atualizados_com_sucesso * R}
            else
                run utp/ut-msgs.p (input "msg",
                                   input 4070,
                                   input "").
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo       = 1
                   tt-retorno-nota-fiscal.cod-erro   = "9999"
                   tt-retorno-nota-fiscal.desc-erro  = return-value
                   tt-retorno-nota-fiscal.situacao   = yes
                   tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                   tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +
                                                       string(i-empresa) + "," +
                                                       nota-fiscal.cod-estabel + ",," +
                                                       nota-fiscal.serie + "," +
                                                       (if nota-fiscal.nr-fatura = "" then
                                                          nota-fiscal.nr-nota-fis 
                                                       else                                                        
                                                          nota-fiscal.nr-fatura) + "," + "," + "," + "," + ",".

            IF i-pais-impto-usuario <> 1 and para-fat.ind-transitoria THEN DO:

                ASSIGN nota-fiscal.ind-contabil = YES.

                &IF DEFINED(bf_dis_versao_ems) &THEN
                    &IF {&bf_dis_versao_ems} > 2.04 &THEN
                        ASSIGN nota-fiscal.refer-cr = tt-nota-fiscal.referencia.
                    &ENDIF
                &ENDIF                    

            END.
        end.
        find tt-retorno-nota-fiscal
            where tt-retorno-nota-fiscal.cod-erro   = "EMS5_OK"
              and tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
              and tt-retorno-nota-fiscal.situacao   = yes exclusive-lock no-error.
        if avail tt-retorno-nota-fiscal then
            delete tt-retorno-nota-fiscal.
    end.

    /* --------------------------------------- Procedures internas ------------------------------------------ */
end.

/***Espec¡fico Grendene***/
procedure upc-nota-diferenca-cambial:

    def var h-cd4351 as handle no-undo.

    run cdp/cd4351.p persistent set h-cd4351.

    run pi-assign-tt-retorno-nota-fiscal in h-cd4351 (input table tt-retorno-nota-fiscal).

    create tt-epc.
    assign tt-epc.cod-event     = "EVENT-001"
           tt-epc.cod-parameter = "Handle CD4351"
           tt-epc.val-parameter = string(h-cd4351).

    create tt-epc.
    assign tt-epc.cod-event     = "EVENT-001"
           tt-epc.cod-parameter = "nota-fiscal"
           tt-epc.val-parameter = string(tt-nota-fiscal.r-nota-fiscal).

    create tt-epc.
    assign tt-epc.cod-event     = "EVENT-001"
           tt-epc.cod-parameter = "l-continua"
           tt-epc.val-parameter = "no".

    {include/i-epc201.i "EVENT-001"}


    FOR FIRST tt-epc 
        WHERE tt-epc.cod-event     = "EVENT-001"
        AND   tt-epc.cod-parameter = "l-continua":
        ASSIGN l-continua = tt-epc.val-parameter = "YES".
    END.
    

    for each tt-epc where
             tt-epc.cod-event = "" or
             tt-epc.cod-event = "":

        delete tt-epc.
    end.
    run pi-read-tt-retorno-nota-fiscal in h-cd4351 (output table tt-retorno-nota-fiscal).

    delete procedure h-cd4351.

end procedure.

procedure pi-acerta-dif-me-exportacao:

    if  de-acum-vl-parc-me = de-tot-nf-me then  /* nao tem diferenca para acertar */
        return.

    find first tt-lin-i-cr where rowid(tt-lin-i-cr) = rw-maior-parc no-error.
    IF NOT AVAIL tt-lin-i-cr THEN RETURN.

    assign tt-lin-i-cr.vl-bruto-me  = tt-lin-i-cr.vl-bruto-me  + de-tot-nf-me - de-acum-vl-parc-me
           tt-lin-i-cr.vl-fatura-me = tt-lin-i-cr.vl-fatura-me + de-tot-nf-me - de-acum-vl-parc-me.

    for first b-fat-duplic use-index ch-fatura EXCLUSIVE-LOCK
        where b-fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
        and   b-fat-duplic.serie         = nota-fiscal.serie
        and   b-fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
        and   b-fat-duplic.ind-fat-nota  = 1
        and   b-fat-duplic.flag-atualiz  = no
        and   b-fat-duplic.parcela       = tt-lin-i-cr.parcela:

        assign b-fat-duplic.vl-parcela-me = b-fat-duplic.vl-parcela-me + de-tot-nf-me - de-acum-vl-parc-me.

        IF b-fat-duplic.vl-comis-me > b-fat-duplic.vl-parcela-me THEN
            ASSIGN b-fat-duplic.vl-comis-me   = b-fat-duplic.vl-parcela-me
                   tt-lin-i-cr.vl-liquido-me  = tt-lin-i-cr.vl-bruto-me.

    end.

end procedure.
PROCEDURE pi-InputTable:
    DEF INPUT PARAM TABLE FOR tt-rep-i-cr.

END PROCEDURE.

PROCEDURE pi-OutputTable:
    DEF OUTPUT PARAM TABLE FOR tt-rep-i-cr.

END PROCEDURE.

/* Procedures criadas segundo FO 943.858 - para utilizacao via UPC */
PROCEDURE pi-InputTableLin:
    DEF INPUT PARAM TABLE FOR tt-lin-i-cr.

END PROCEDURE.

PROCEDURE pi-OutputTableLin:
    DEF OUTPUT PARAM TABLE FOR tt-lin-i-cr.

END PROCEDURE.

PROCEDURE pi-InputTableDoc:
    DEF INPUT PARAM TABLE FOR tt-doc-i-cr.

END PROCEDURE.

PROCEDURE pi-OutputTableDoc:
    DEF OUTPUT PARAM TABLE FOR tt-doc-i-cr.

END PROCEDURE.
/* fim procedures FO 943.858 */

PROCEDURE pi-ft0603c:
    def input parameter r-registro    as rowid no-undo.
    def input parameter c-referencia  as char format "x(10)" no-undo.

    def var i-empresa    like param-global.empresa-prin no-undo.

    def buffer b-fat-dupl for fat-duplic. 
    def buffer b-nota for nota-fiscal.

    assign i-empresa = param-global.empresa-prin.

    find b-fat-dupl where rowid(b-fat-dupl) = r-registro EXCLUSIVE-LOCK NO-ERROR.

    &if defined (bf_dis_consiste_conta) &then
        find estabelec where
             estabelec.cod-estabel = b-fat-dupl.cod-estabel no-lock no-error.  
        run cdp/cd9970.p (input rowid(estabelec),
                          output i-empresa).
    &endif

    if  c-nom-prog-upc-mg97 <> "" then DO:

        /*--------- INICIO UPC ---------*/

        for each tt-epc where tt-epc.cod-event = "troca-empresa":
            delete tt-epc.
        end.

        create tt-epc.
        assign tt-epc.cod-event     = "troca-empresa"
               tt-epc.cod-parameter = "fat-duplic rowid"
               tt-epc.val-parameter = string(r-registro).


        create tt-epc.
        assign tt-epc.cod-event     = "troca-empresa"
               tt-epc.cod-parameter = "i-empresa-prin"
               tt-epc.val-parameter =  string(i-empresa).

        {include/i-epc201.i "troca-empresa"}

        /*--------- FINAL UPC ---------*/
        find first tt-epc where
                   tt-epc.cod-event     = "troca-empresa" and
                   tt-epc.cod-parameter = "i-empresa-prin" no-lock no-error.
        if  avail tt-epc then
            &IF "{&mguni_version}" >= "2.071" &THEN
            assign i-empresa = tt-epc.val-parameter.
            &ELSE
/*             assign i-empresa = integer(tt-epc.val-parameter). */
            &ENDIF
            

    END.

    find first param-fasb where param-fasb.ep-codigo = i-empresa
                                no-lock no-error.

    if  avail param-fasb and param-global.modulo-fc then do:

        if  param-fasb.moeda-cmi <> 0 then do: 
            find     cotacao  
               where cotacao.mo-codigo   = param-fasb.moeda-cmi
               and   cotacao.ano-periodo = string(year(b-fat-dupl.dt-emissao)) 
                                         + string(month(b-fat-dupl.dt-emissao),"99")
               and   cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))] <> 0 no-lock no-error.
            if  avail cotacao then do:
                assign b-fat-dupl.tx-cmi-emis = cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))].
                if  b-fat-dupl.tx-cmi-emis = 0 then do:
                    if  not can-find (tt-retorno-nota-fiscal where
                                      tt-retorno-nota-fiscal.tipo      = 1 and
                                      tt-retorno-nota-fiscal.cod-erro  = "0316" and
                                      tt-retorno-nota-fiscal.cod-chave = c-referencia + ",,,,,,,") then do:
                        run utp/ut-msgs.p (input "msg",
                                           input 316,
                                           input cotacao.mo-codigo, b-fat-dupl.dt-emissao).

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "0316"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = yes
                               tt-retorno-nota-fiscal.referencia = c-referencia
                               tt-retorno-nota-fiscal.cod-chave  = c-referencia + ",,,,,,,".
                    end.
                end.
            end.  
        end.

        if  param-fasb.moeda-anbid <> 0 then do:
            find cotacao
                 where cotacao.mo-codigo   = param-fasb.moeda-anbid
                 and   cotacao.ano-periodo = string(year(b-fat-dupl.dt-emissao)) 
                                           + string(month(b-fat-dupl.dt-emissao),"99")
            and   cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))] <> 0 no-lock no-error.
            if  avail cotacao then do:
                assign b-fat-dupl.tx-anbid-emis-cmi = 
                                  cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))].
                if  b-fat-dupl.tx-anbid-emis-cmi = 0 then do:
                    if  not can-find (tt-retorno-nota-fiscal where
                                      tt-retorno-nota-fiscal.tipo      = 1 and
                                      tt-retorno-nota-fiscal.cod-erro  = "0316" and
                                      tt-retorno-nota-fiscal.cod-chave = c-referencia + ",,,,,,,") then do:
                        run utp/ut-msgs.p (input "msg",
                                           input 316,
                                           input cotacao.mo-codigo, b-fat-dupl.dt-emissao).

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "0316"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = yes
                               tt-retorno-nota-fiscal.referencia = c-referencia
                               tt-retorno-nota-fiscal.cod-chave  = c-referencia + ",,,,,,,".
                    end.
                end.
            end.
        end.

        if  param-fasb.moeda-fasb <> 0 then do:

            /* ser for nota de exportacao usa cotacao informada */
            if substr(b-fat-dupl.nat-operacao,1,1) = "7" then do:
                find first b-nota where
                    b-nota.cod-estabel = b-fat-dupl.cod-estabel and
                    b-nota.serie       = b-fat-dupl.serie       and
                    b-nota.nr-fatura   = b-fat-dupl.nr-fatura
                no-lock no-error.

                if avail b-nota and
                b-nota.vl-taxa-exp <> 0 then
                    assign b-fat-dupl.tx-pr-emis-fasb = b-nota.vl-taxa-exp.
            end.

            find cotacao
                 where cotacao.mo-codigo   = param-fasb.moeda-fasb
                 and   cotacao.ano-periodo = string(year(b-fat-dupl.dt-emissao))
                                           + string(month(b-fat-dupl.dt-emissao),"99")
                 and   cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))] <> 0 no-lock no-error.

            if  avail cotacao
            and b-fat-dupl.tx-pr-emis-fasb = 0 then do:
                assign b-fat-dupl.tx-pr-emis-fasb = 
                                    cotacao.cotacao[int(day(b-fat-dupl.dt-emissao))].
                if  b-fat-dupl.tx-pr-emis-fasb = 0 then do:
                    if  not can-find (tt-retorno-nota-fiscal where
                                      tt-retorno-nota-fiscal.tipo      = 1 and
                                      tt-retorno-nota-fiscal.cod-erro  = "0316" and
                                      tt-retorno-nota-fiscal.cod-chave = c-referencia + ",,,,,,,") then do:
                        run utp/ut-msgs.p (input "msg",
                                           input 316,
                                           input cotacao.mo-codigo, b-fat-dupl.dt-emissao).

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "0316"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = yes
                               tt-retorno-nota-fiscal.referencia = c-referencia
                               tt-retorno-nota-fiscal.cod-chave  = c-referencia + ",,,,,,,".
                    end.
                end.
            end.
            do:
                assign b-fat-dupl.tx-pr-vcto-fasb = 1.
                find tb-prev-corr where tb-prev-corr.cd-tabela = string(month(b-fat-dupl.dt-vencimen),"99") +
                                                                 string(year(b-fat-dupl.dt-vencimen), "9999")
                                    and tb-prev-corr.seq-mes = 1 no-lock no-error.
                if  avail tb-prev-corr then
                    assign b-fat-dupl.tx-pr-vcto-fasb = (if  tb-prev-corr.indice[day(b-fat-dupl.dt-vencimen)] <> 0 then
                                      tb-prev-corr.indice[day(b-fat-dupl.dt-vencimen)]
                                  else
                                      1).
                else do:    
                    {utp/ut-table.i mgadm tb-prev-corr 1}
                    run utp/ut-msgs.p (input "msg",
                                       input 47,
                                       input return-value).
                    if  not can-find (tt-retorno-nota-fiscal where
                                      tt-retorno-nota-fiscal.tipo      = 1 and
                                      tt-retorno-nota-fiscal.cod-erro  = "0047" and
                                      tt-retorno-nota-fiscal.cod-chave = c-referencia + ",,,,,,,") then do:

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 1
                               tt-retorno-nota-fiscal.cod-erro   = "0047"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = yes
                               tt-retorno-nota-fiscal.referencia = c-referencia
                               tt-retorno-nota-fiscal.cod-chave  = c-referencia + ",,,,,,,".
                    end.
                end.
            end.
        end.
    end.

END PROCEDURE.

PROCEDURE ExecutaEpc : 
    DEF INPUT  PARAMETER p-cod-event AS CHAR    NO-UNDO.
    DEF OUTPUT PARAMETER p-c-retorno AS CHAR  INITIAL "YES" NO-UNDO.

    ASSIGN p-c-retorno = "":U.

    IF  c-nom-prog-upc-mg97  <> '':U THEN DO:

       FOR EACH tt-epc:
           DELETE tt-epc.
       END.

       CASE p-cod-event:

            WHEN "eseven1" THEN DO:

                /*--------- INICIO UPC SEVEN BOYS ---------*/
                create tt-seven.
                assign tt-seven.ep-codigo   = tt-lin-i-cr.ep-codigo
                       tt-seven.cod-estabel = tt-lin-i-cr.cod-estabel
                       tt-seven.referencia  = tt-lin-i-cr.referencia
                       tt-seven.sequencia   = tt-lin-i-cr.sequencia
                       tt-seven.seq-import  = tt-lin-i-cr.seq-import
                       tt-seven.perc-multa  = tt-lin-i-cr.perc-multa.

                for each tt-epc where tt-epc.cod-event = "eseven1":
                    delete tt-epc.
                end.

                create tt-epc.
                assign tt-epc.cod-event     = "eseven1" 
                       tt-epc.cod-parameter = "atualiza-cr"
                       tt-epc.val-parameter = string(tt-seven.ep-codigo)  + "," +
                                                     tt-seven.cod-estabel + "," +
                                                     tt-seven.referencia  + "," +
                                              string(tt-seven.sequencia)  + "," +
                                              string(tt-seven.seq-import).

                {include/i-epc201.i "eseven1"}                

                if  l-seven then
                    assign /*tt-lin-i-cr.perc-multa*/ p-c-retorno  = string(tt-seven.perc-multa).
                /*--------- FINAL UPC SEVEN BOYS ---------*/       

            END.

            WHEN "Commission" THEN DO:

                IF c-nom-prog-upc-mg97 <> "" THEN DO:

                    /***** Chamada UPC *****/
                    for each tt-epc where tt-epc.cod-event = "Commission":
                        delete tt-epc.
                    end.
                    create tt-epc.
                    assign tt-epc.cod-event     = "Commission"
                           tt-epc.cod-parameter = "fat-duplic"
                           tt-epc.val-parameter = string(rowid(fat-duplic)).

                    {include/i-epc201.i "Commission"}

                    find tt-epc where
                         tt-epc.cod-event     = "Commission" and
                         tt-epc.cod-parameter = "Use-Commission" no-error.
                    if  avail tt-epc then do:

                        if  tt-epc.val-parameter  = "no" then
                            assign /*l-comissao-epc*/ p-c-retorno  = string(no).
                        else
                            assign /*l-comissao-epc*/ p-c-retorno = string(yes).
                    end.
                    else
                        assign /*l-comissao-epc*/ p-c-retorno = string(yes).
                    /***** Fim UPC *****/
                END.
                else
                    assign /*l-comissao-epc*/ p-c-retorno = string(yes).

            END.
            WHEN "Atualiza valores" THEN DO:

                create tt-epc.
                assign tt-epc.cod-event     = "Atualiza valores"
                       tt-epc.cod-parameter = "nota-fiscal"
                       tt-epc.val-parameter = string(ROWID(nota-fiscal)).

                create tt-epc.
                assign tt-epc.cod-event     = "Atualiza valores"
                       tt-epc.cod-parameter = "fat-duplic"
                       tt-epc.val-parameter = string(ROWID(fat-duplic)).

                create tt-epc.
                assign tt-epc.cod-event     = "Atualiza valores"
                       tt-epc.cod-parameter = "tipo-receita-despesa"
                       tt-epc.val-parameter = string(tt-lin-i-cr.tp-codigo).

                {include/i-epc201.i "Atualiza valores"}

                for each tt-epc where tt-epc.cod-event = "Atualiza valores":
                    if tt-epc.cod-parameter = "tipo-receita-despesa" then
                       assign p-c-retorno = STRING(tt-epc.val-parameter).

                    delete tt-epc.
                end.

                /**** Final EPC Valores */
            END.
            WHEN "Condicao Pagto":U THEN DO:

                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "Condicao Pagto"
                       tt-epc.cod-parameter = "fat-duplic"
                       tt-epc.val-parameter = STRING(ROWID(fat-duplic)).

                {include/i-epc201.i "Condicao Pagto"}

                FOR EACH tt-epc WHERE tt-epc.cod-event = "Condicao Pagto":
                    IF tt-epc.cod-parameter = "cod-cond-pag" THEN
                       ASSIGN p-c-retorno = STRING(tt-epc.val-parameter).

                    DELETE tt-epc.
                END.
                /**** Final EPC Valores */
            END.
       END.
   END.

END PROCEDURE.

PROCEDURE pi-valida-comissao-rep:

    FOR EACH tt-rep-i-cr EXCLUSIVE-LOCK:
    
        /* A l¢gica pode entrar nessa valida‡Æo quando for feito uma nota de d‚bito apenas por despesas para o internacional */ 
        /* e dessa forma o valor liquido das mercadorias serÿ zero. Se as despesas nÆo forem incluidas na base ocorre o erro. */
        IF (tt-rep-i-cr.comissao < 0 
        OR  tt-rep-i-cr.comissao = ?)THEN DO: 
            ASSIGN tt-rep-i-cr.comissao = 0.
/*             {utp/ut-liter.i ComissÆo_deve_ser_maior_que_zero._Valor_base_para_cÿlculo_da_comissÆo_nÆo_foi_informado * R} */
/*             CREATE tt-retorno-nota-fiscal.                                                                               */
/*             assign tt-retorno-nota-fiscal.tipo       = 1                                                                 */
/*                    tt-retorno-nota-fiscal.cod-erro   = "28253"                                                           */
/*                    tt-retorno-nota-fiscal.desc-erro  = return-value                                                      */
/*                    tt-retorno-nota-fiscal.situacao   = NO                                                                */
/*                    tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia                                         */
/*                    tt-retorno-nota-fiscal.cod-chave  = tt-nota-fiscal.referencia + ",," +                                */
/*                                                        string(i-empresa) + "," +                                         */
/*                                                        nota-fiscal.cod-estabel + "," +                                   */
/*                                                        fat-duplic.cod-esp + "," +                                        */
/*                                                        nota-fiscal.serie + "," +                                         */
/*                                                       (if nota-fiscal.nr-fatura = ""                                     */
/*                                                        THEN nota-fiscal.nr-nota-fis                                      */
/*                                                        else nota-fiscal.nr-fatura) + "," + "," +                         */
/*                                                            (if avail tt-lin-i-cr                                         */
/*                                                             THEN string(tt-lin-i-cr.cod-portador) + "," +                */
/*                                                                  string(tt-lin-i-cr.modalidade)                          */
/*                                                             else ",").                                                   */
/*             DELETE tt-rep-i-cr.                                                                                          */
        END.
    END.

END PROCEDURE.

&IF '{&BF_DIS_VERSAO_EMS}' >= '2.042':U &THEN
PROCEDURE pi-impostos-internacional:

   DEF VAR de-valor-mercad-mais-desp AS DEC NO-UNDO.
  /*** Tratamento dos Impostos dos USA - 2.04B ***/
  if  i-cod-pais-imposto = 3 then do:
        for each it-nota-imp no-lock where
                 it-nota-imp.cod-estabel = nota-fiscal.cod-estabel and
                 it-nota-imp.serie       = nota-fiscal.serie       and
                 it-nota-imp.nr-nota-fis = nota-fiscal.nr-nota-fis
            break by it-nota-imp.cd-jurisdicao:

            assign de-tot-base    = de-tot-base    + it-nota-imp.vl-base-imp
                   de-tot-imposto = de-tot-imposto + it-nota-imp.vl-imposto.

            if  last-of(it-nota-imp.cd-jurisdicao) then do:
                if  l-last-dupli then do:
                    find tt-imposto-1 where
                         tt-imposto-1.cod-imposto = it-nota-imp.cd-jurisdicao no-error.
                    if  avail tt-imposto-1 then
                        assign de-vl-base    = de-tot-base    - tt-imposto-1.vl-base
                               de-vl-imposto = de-tot-imposto - tt-imposto-1.vl-imposto.
                    else
                        assign de-vl-base    = de-tot-base
                               de-vl-imposto = de-tot-imposto.
                end.
                else do:
                    find tt-imposto-1 where
                         tt-imposto-1.cod-imposto = it-nota-imp.cd-jurisdicao no-lock no-error.

                    if  not avail tt-imposto-1 then do:
                        create tt-imposto-1.
                        assign tt-imposto-1.cod-imposto = it-nota-imp.cd-jurisdicao.
                    end.

                    assign de-vl-base              = (tt-lin-i-cr.vl-bruto / nota-fiscal.vl-tot-nota) * de-tot-base
                           de-vl-imposto           = (tt-lin-i-cr.vl-bruto / nota-fiscal.vl-tot-nota) * de-tot-imposto
                           tt-imposto-1.vl-base    = tt-imposto-1.vl-base    + de-vl-base
                           tt-imposto-1.vl-imposto = tt-imposto-1.vl-imposto + de-vl-imposto.
                end.

                for first jurisdicao where
                          jurisdicao.cd-jurisdicao = it-nota-imp.cd-jurisdicao and
                          jurisdicao.cod-estabel   = it-nota-imp.cod-estabel no-lock:
                end.

                for first tipo-tax where
                          string(tipo-tax.cod-tax) = it-nota-imp.cd-jurisdicao no-lock:
                end.

                create tt-impto-tit-pend-cr-1.
                assign tt-impto-tit-pend-cr-1.cod-classificacao   = if avail tipo-tax then tipo-tax.cod-classificacao else 0
                       tt-impto-tit-pend-cr-1.cod-emitente        = tt-lin-i-cr.cod-emitente
                       tt-impto-tit-pend-cr-1.cod-esp             = tt-lin-i-cr.cod-esp
                       tt-impto-tit-pend-cr-1.cod-estabel         = tt-lin-i-cr.cod-estabel
                       tt-impto-tit-pend-cr-1.cod-imposto         = it-nota-imp.cod-taxa
                       tt-impto-tit-pend-cr-1.conta-retencao      = ""
                       tt-impto-tit-pend-cr-1.conta-saldo-credito = ""
                       tt-impto-tit-pend-cr-1.ct-retencao         = ""
                       tt-impto-tit-pend-cr-1.ct-saldo-credito    = ""
                       tt-impto-tit-pend-cr-1.dt-emissao          = tt-lin-i-cr.dt-emissao
                       tt-impto-tit-pend-cr-1.ep-codigo           = tt-lin-i-cr.ep-codigo
                       tt-impto-tit-pend-cr-1.ind-tip-calculo     = if avail tipo-tax then tipo-tax.ind-tip-calculo else 1
                       tt-impto-tit-pend-cr-1.ind-tipo-imposto    = if avail tipo-tax then tipo-tax.ind-tipo-imposto else 1
                       tt-impto-tit-pend-cr-1.mo-codigo           = tt-lin-i-cr.mo-codigo  
                       tt-impto-tit-pend-cr-1.nat-operacao        = nota-fiscal.nat-operacao
                       tt-impto-tit-pend-cr-1.nr-docto            = tt-lin-i-cr.nr-docto
                       tt-impto-tit-pend-cr-1.num-seq-impto       = it-nota-imp.nr-seq-imp
                       tt-impto-tit-pend-cr-1.cd-jurisdicao       = it-nota-imp.cd-jurisdicao
                       tt-impto-tit-pend-cr-1.cod-certif-isencao  = it-nota-imp.cod-certif-isencao
                       tt-impto-tit-pend-cr-1.parcela             = tt-lin-i-cr.parcela
                       tt-impto-tit-pend-cr-1.perc-retencao       = 0
                       tt-impto-tit-pend-cr-1.sc-retencao         = ""
                       tt-impto-tit-pend-cr-1.sc-saldo-credito    = ""
                       tt-impto-tit-pend-cr-1.contabilizou        = yes
                       tt-impto-tit-pend-cr-1.serie               = tt-lin-i-cr.serie 
                       tt-impto-tit-pend-cr-1.tipo                = if avail tipo-tax then tipo-tax.tipo else 1
                       tt-impto-tit-pend-cr-1.vl-base             = de-vl-base
                       tt-impto-tit-pend-cr-1.vl-base-me          = de-vl-base
                       tt-impto-tit-pend-cr-1.ind-data-base       = if avail tipo-tax then tipo-tax.ind-data-base else 1
                       tt-impto-tit-pend-cr-1.lancamento          = 2  
                       tt-impto-tit-pend-cr-1.origem-impto        = 13
                       tt-impto-tit-pend-cr-1.transacao-impto     = 14
                       tt-impto-tit-pend-cr-1.vl-saldo-imposto    = de-vl-imposto
                       tt-impto-tit-pend-cr-1.vl-saldo-imposto-me = de-vl-imposto
                       tt-impto-tit-pend-cr-1.ct-imposto          = if avail tipo-tax then tipo-tax.ct-tax else ""
                       tt-impto-tit-pend-cr-1.sc-imposto          = if avail tipo-tax then tipo-tax.sc-tax else ""
                       tt-impto-tit-pend-cr-1.perc-imposto        = if avail tipo-tax then tipo-tax.tax-perc else 0
                       tt-impto-tit-pend-cr-1.vl-imposto          = de-vl-imposto
                       tt-impto-tit-pend-cr-1.vl-imposto-me       = de-vl-imposto
                       tt-impto-tit-pend-cr-1.cotacao-dia         = tt-lin-i-cr.cotacao-dia.

               if  tt-impto-tit-pend-cr-1.mo-codigo <> 0 then
                   assign tt-impto-tit-pend-cr-1.vl-base-me          = tt-impto-tit-pend-cr-1.vl-base-me /
                                                                       tt-lin-i-cr.cotacao-dia
                          tt-impto-tit-pend-cr-1.vl-imposto-me       = tt-impto-tit-pend-cr-1.vl-imposto-me /
                                                                       tt-lin-i-cr.cotacao-dia
                          tt-impto-tit-pend-cr-1.vl-saldo-imposto-me = tt-impto-tit-pend-cr-1.vl-saldo-imposto-me /
                                                                       tt-lin-i-cr.cotacao-dia
                          tt-impto-tit-pend-cr-1.vl-percepcao-me     = tt-impto-tit-pend-cr-1.vl-percepcao /
                                                                       tt-lin-i-cr.cotacao-dia
                          tt-impto-tit-pend-cr-1.vl-retencao-me      = tt-impto-tit-pend-cr-1.vl-retencao /
                                                                       tt-lin-i-cr.cotacao-dia.

               assign de-tot-base    = 0
                      de-tot-imposto = 0.
            end.
        end.                     
  end. /* USA */ 
  else do: /* Am‚rica Latina */

      ASSIGN de-valor-mercad-mais-desp = (nota-fiscal.vl-mercad + nota-fiscal.vl-frete + nota-fiscal.vl-seguro + nota-fiscal.vl-embalagem).

     for each it-nota-imp no-lock 
        where it-nota-imp.cod-estabel = nota-fiscal.cod-estabel and
              it-nota-imp.serie       = nota-fiscal.serie       and
              it-nota-imp.nr-nota-fis = nota-fiscal.nr-nota-fis
        break by it-nota-imp.cod-taxa:
        
        assign de-tot-base    = de-tot-base + it-nota-imp.vl-base-imp
               de-tot-imposto = de-tot-imposto + it-nota-imp.vl-imposto.
        for first tipo-tax where
                  tipo-tax.cod-tax = it-nota-imp.cod-tax no-lock: end.
        
        if last-of(it-nota-imp.cod-taxa) then do:
           if  l-last-dupli then do:
               find tt-imposto 
               where tt-imposto.cod-imposto = it-nota-imp.cod-tax no-error.
               if avail tt-imposto then 
                   assign de-vl-base    = de-tot-base - tt-imposto.vl-base
                          de-vl-imposto = de-tot-imposto - tt-imposto.vl-imposto.
               else /* somente uma parcela */
                   assign de-vl-base    = de-tot-base
                          de-vl-imposto = de-tot-imposto.
           end.
           else  do:
               find tt-imposto 
               where tt-imposto.cod-imposto = it-nota-imp.cod-tax no-lock no-error.
        
               if not avail tt-imposto then do:
                  create tt-imposto.
                  assign tt-imposto.cod-imposto = it-nota-imp.cod-tax.
               end.

                assign de-vl-base            = (tt-lin-i-cr.vl-base-calc-ret / de-valor-mercad-mais-desp) * de-tot-base
                       de-vl-imposto         = (tt-lin-i-cr.vl-base-calc-ret / de-valor-mercad-mais-desp) * de-tot-imposto
                       tt-imposto.vl-base    = round(tt-imposto.vl-base    + de-vl-base,9) 
                       tt-imposto.vl-imposto = round(tt-imposto.vl-imposto + de-vl-imposto,9).
        
           end.

            /* aqui ‚ a grava‡Æo da tt-impto-tit-pend-cr-1 */
           create tt-impto-tit-pend-cr-1.
           assign tt-impto-tit-pend-cr-1.cod-classificacao   = if avail tipo-tax then tipo-tax.cod-classificacao else 0
                  tt-impto-tit-pend-cr-1.cod-emitente        = tt-lin-i-cr.cod-emitente
                  tt-impto-tit-pend-cr-1.cod-esp             = tt-lin-i-cr.cod-esp
                  tt-impto-tit-pend-cr-1.cod-estabel         = tt-lin-i-cr.cod-estabel
                  tt-impto-tit-pend-cr-1.cod-imposto         = it-nota-imp.cod-taxa
                  tt-impto-tit-pend-cr-1.conta-retencao      = ""
                  tt-impto-tit-pend-cr-1.conta-saldo-credito = ""
                  tt-impto-tit-pend-cr-1.ct-retencao         = ""
                  tt-impto-tit-pend-cr-1.ct-saldo-credito    = ""
                  tt-impto-tit-pend-cr-1.dt-emissao          = tt-lin-i-cr.dt-emissao
                  tt-impto-tit-pend-cr-1.ep-codigo           = tt-lin-i-cr.ep-codigo
                  tt-impto-tit-pend-cr-1.ind-tip-calculo     = if avail tipo-tax then tipo-tax.ind-tip-calculo else 1
                  tt-impto-tit-pend-cr-1.ind-tipo-imposto    = if avail tipo-tax then tipo-tax.ind-tipo-imposto else 1
                  tt-impto-tit-pend-cr-1.mo-codigo           = tt-lin-i-cr.mo-codigo  
                  tt-impto-tit-pend-cr-1.nat-operacao        = nota-fiscal.nat-operacao
                  tt-impto-tit-pend-cr-1.nr-docto            = tt-lin-i-cr.nr-docto
                  tt-impto-tit-pend-cr-1.num-seq-impto       = it-nota-imp.nr-seq-imp
                  tt-impto-tit-pend-cr-1.parcela             = tt-lin-i-cr.parcela
                  tt-impto-tit-pend-cr-1.perc-retencao       = 0
                  tt-impto-tit-pend-cr-1.sc-retencao         = ""
                  tt-impto-tit-pend-cr-1.sc-saldo-credito    = ""
                  tt-impto-tit-pend-cr-1.contabilizou        = yes
                  tt-impto-tit-pend-cr-1.serie               = tt-lin-i-cr.serie 
                  tt-impto-tit-pend-cr-1.tipo                = if avail tipo-tax then tipo-tax.tipo else 1
                  tt-impto-tit-pend-cr-1.vl-base             = de-vl-base
                  tt-impto-tit-pend-cr-1.vl-base-me          = de-vl-base
                  tt-impto-tit-pend-cr-1.ind-data-base       = if avail tipo-tax then tipo-tax.ind-data-base else 1
                  tt-impto-tit-pend-cr-1.lancamento        = IF (i-pais-impto-usuario <> 4 OR i-pais-impto-usuario <> 17) THEN 2
                                                             ELSE IF NOT AVAIL tipo-tax THEN 2
                                                                  ELSE IF tipo-tax.tipo = 1 THEN 1 /* Reten‡Æo -> 1- debito */
                                                                       ELSE 2 
                  tt-impto-tit-pend-cr-1.origem-impto        = 13
                  tt-impto-tit-pend-cr-1.transacao-impto     = 14
                  tt-impto-tit-pend-cr-1.vl-saldo-imposto    = de-vl-imposto
                  tt-impto-tit-pend-cr-1.vl-saldo-imposto-me = de-vl-imposto
                  tt-impto-tit-pend-cr-1.cotacao-dia         = tt-lin-i-cr.cotacao-dia.
        
           case it-nota-imp.int-2:
               when 1 or when 2 then do: /* IVA INSCRIPTO E N€O INSCRIPTO */
                  assign 
                  tt-impto-tit-pend-cr-1.ct-imposto    = if avail tipo-tax then tipo-tax.ct-tax else ""
                  tt-impto-tit-pend-cr-1.sc-imposto    = if avail tipo-tax then tipo-tax.sc-tax else ""
                  tt-impto-tit-pend-cr-1.perc-imposto  = if avail tipo-tax then tipo-tax.tax-perc else 0
                  tt-impto-tit-pend-cr-1.vl-imposto    = de-vl-imposto
                  tt-impto-tit-pend-cr-1.vl-imposto-me = de-vl-imposto.
        
               end.
               when 3 or when 4 then do: /* PERCEP°€O DE IVA e INGRESSOS BRUTOS */
                  assign 
                  tt-impto-tit-pend-cr-1.conta-percepcao = if avail tipo-tax then tipo-tax.conta-percepcao else ""
                  tt-impto-tit-pend-cr-1.ct-percepcao    = IF AVAIL tipo-tax THEN tipo-tax.ct-percepcao ELSE ""
                  tt-impto-tit-pend-cr-1.sc-percepcao    = IF AVAIL tipo-tax THEN tipo-tax.sc-percepcao ELSE ""
                  tt-impto-tit-pend-cr-1.perc-percepcao  = if avail tipo-tax then tipo-tax.perc-percepcao else 0
                  tt-impto-tit-pend-cr-1.vl-percepcao    = de-vl-imposto
                  tt-impto-tit-pend-cr-1.vl-percepcao-me = de-vl-imposto.
               end.
           end.
        
           /* IVA Taxado - Imposto Paraguai */
           IF i-cod-pais-imposto = 9 THEN DO:
              ASSIGN tt-impto-tit-pend-cr-1.tipo = 2 /* Sempre enviar o IVA Taxado como Tipo Valor Agregado ao ACR */
                     tt-impto-tit-pend-cr-1.ind-tip-calculo    = 1
                     tt-impto-tit-pend-cr-1.ind-tipo-imposto   = 2
                     tt-impto-tit-pend-cr-1.ct-imposto    = if avail tipo-tax then tipo-tax.ct-tax else ""
                     tt-impto-tit-pend-cr-1.sc-imposto    = if avail tipo-tax then tipo-tax.sc-tax else ""
                     tt-impto-tit-pend-cr-1.perc-imposto  = if avail tipo-tax then tipo-tax.tax-perc else 0
                     tt-impto-tit-pend-cr-1.vl-imposto    = de-vl-imposto
                     tt-impto-tit-pend-cr-1.vl-imposto-me = de-vl-imposto.
           END.

           if  tt-impto-tit-pend-cr-1.mo-codigo <> 0 then
               assign tt-impto-tit-pend-cr-1.vl-base-me          = tt-impto-tit-pend-cr-1.vl-base-me / tt-lin-i-cr.cotacao-dia
                      tt-impto-tit-pend-cr-1.vl-imposto-me       = tt-impto-tit-pend-cr-1.vl-imposto-me / tt-lin-i-cr.cotacao-dia
                      tt-impto-tit-pend-cr-1.vl-saldo-imposto-me = tt-impto-tit-pend-cr-1.vl-saldo-imposto-me / tt-lin-i-cr.cotacao-dia
                      tt-impto-tit-pend-cr-1.vl-percepcao-me     = tt-impto-tit-pend-cr-1.vl-percepcao / tt-lin-i-cr.cotacao-dia
                      tt-impto-tit-pend-cr-1.vl-retencao-me      = tt-impto-tit-pend-cr-1.vl-retencao / tt-lin-i-cr.cotacao-dia.
        
           assign de-tot-base    = 0
                  de-tot-imposto = 0.

        end.
     end.

  end.

  RETURN "OK":U.

END PROCEDURE.
&ENDIF


