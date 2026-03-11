/********************************************************************************
** Programa: int072 - ImportaÆo de Notas de Entrada do Tutorial/PRS
**
** Versao : 12 - 03/01/2017 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versÆo */
{include/i-prgvrs.i int072RP 2.12.06.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

{cdp/cd4305.i1}  /* Definicao TT-DOCTO, TT-IT-DOCTO p/ calculo dos tributos */

/* definiÆo das temp-tables para recebimento de parmetros */
def temp-table tt-movto no-undo
    field c_tipo       as   char 
    field cod-estabel  as   char
    field nat-operacao as   char
    field serie        like docum-est.serie-docto
    field nr-nota-fis  like docum-est.nro-docto
    field dt-emissao   like docum-est.dt-emissao
    field it-codigo    like item-doc-est.it-codigo     
    field nr-sequencia like item-doc-est.sequencia
    field qt-recebida  as   decimal
    field cod-depos    like rat-lote.cod-depos 
    field lote         like rat-lote.lote
    field dt-vali-lote like rat-lote.dt-vali-lote
    field valor-mercad like docum-est.valor-mercad
    field vl-despesas  like item-doc-est.despesas[1]
    field cd-trib-ipi  like natur-oper.cd-trib-ipi
    field aliquota-ipi like item-doc-est.aliquota-ipi  
    field perc-red-ipi like natur-oper.perc-red-ipi  
    field cd-trib-icm  like natur-oper.cd-trib-icm   
    field aliquota-icm like item-doc-est.aliquota-icm  
    field perc-red-icm like natur-oper.perc-red-icm  
    field tipo-compra  like natur-oper.tipo-compra
    field terceiros    like natur-oper.terceiros
    field cd-trib-iss  like natur-oper.cd-trib-iss
    field vl-bicms-it  like docum-est.base-icm
    field vl-icms-it   like it-nota-fisc.vl-icms-it    
    field vl-bipi-it   like it-nota-fisc.vl-bipi-it    
    field vl-ipi-it    like it-nota-fisc.vl-ipi-it
    field vl-bsubs-it  like it-nota-fisc.vl-bsubs-it
    field vl-icmsub-it like it-nota-fisc.vl-icmsub-it
    field tot-frete    like docum-est.valor-frete 
    field tot-seguro   like docum-est.valor-seguro 
    field tot-despesas like docum-est.valor-outras
    field tot-desconto like docum-est.tot-desconto
    field desconto     like item-doc-est.desconto[1]
    field mod-frete    like docum-est.mod-frete
    field cod-emitente like docum-est.cod-emitente
    field uf           like docum-est.uf
    field peso-liquido like item.peso-liquido
    field CNPJ like int_ds_docto_xml.CNPJ
    field cfop        like int_ds_docto_xml.cfop
    field numero-ordem      like item-doc-est.numero-ordem
    field parcela           like item-doc-est.parcela
    field num-pedido        like item-doc-est.num-pedido
    field tp-despesa        like dupli-apagar.tp-despesa
    field tipo_nota         like int_ds_docto_xml.tipo_nota
    field dt-trans          like int_ds_docto_wms.datamovimentacao_d
    field perc-red-icms     like int_ds_it_docto_xml.predBc
    field vl-icms-des       like int_ds_it_docto_xml.vicmsdeson
    field cod-cond-pag      like ems2mult.emitente.cod-cond-pag
    field base-pis          like item-doc-est.base-pis
    field valor-pis         like item-doc-est.valor-pis
    field cd-trib-pis       like item-doc-est.idi-tributac-pis
    field aliquota-pis      like item-doc-est.val-aliq-pis
    field base-cofins       like item-doc-est.val-base-calc-cofins
    field valor-cofins      like item-doc-est.val-cofins
    field cd-trib-cofins    like item-doc-est.idi-tributac-cofins
    field aliquota-cofins   like item-doc-est.val-aliq-cofins
    field ct-codigo         like item-doc-est.ct-codigo
    field sc-codigo         like item-doc-est.sc-codigo
    field chave-acesso      as char
    field class-fiscal      like item.class-fiscal
    field valor_guia_st     like int_ds_docto_xml.valor_guia_st
    field base_guia_st      like int_ds_docto_xml.base_guia_st
    field dt-imposto        as date
    field nNF               like int_ds_docto_xml.nNF
    field CNPJ_dest         like int_ds_docto_xml.CNPJ_dest
    FIELD vbcstret          AS DEC 
    FIELD vicmsstret        AS DEC
    FIELD cst_icms          AS INT
    FIELD vICMSSubs         LIKE int_ds_it_docto_xml.vICMSSubs 
    FIELD picmsst           LIKE int_ds_it_docto_xml.picmsst.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field dt-trans-fim     as date
    field dt-trans-ini     as date
    field nro-docto-fim    as char
    field nro-docto-ini    as char
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

define temp-table tt-param-re1005 no-undo
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
    
define temp-table tt-digita-re1005 no-undo
    field r-docum-est        as rowid.
    
DEFINE BUFFER b_int_ds_docto_xml FOR int_ds_docto_xml.

/******* TEMP TABLES DA API *****************/


{btb/btb009za.i}
{cdp/cdcfgcex.i}
{cdp/cdcfgmat.i}

{rep/reapi191.i1}
{rep/reapi190b.i}

define temp-table tt-bo-docum-est no-undo
    like docum-est
    field r-docum-est as rowid.    

define temp-table tt-bo-item-doc-est no-undo
    like item-doc-est
    field r-item-doc-est as rowid.

{method/dbotterr.i}

function fnTrataNuloDec returns decimal
    (p-valor as decimal):

    if p-valor = ? then return 0.
    else return p-valor.

end.

DEFINE VARIABLE c-mensagem-erro AS CHARACTER   NO-UNDO.

DEFINE BUFFER btt-movto FOR tt-movto.


/* recebimento de parmetros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 
DEF OUTPUT PARAMETER c-retorno AS CHAR NO-UNDO.

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 



IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int072.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* definiÆo de vari veis  */
def var h-acomp    as handle no-undo.
def var h-boin090  as handle no-undo.
def var h-boin176  as handle no-undo.
def var h-aux      as handle no-undo.
def var l-erro     as logical no-undo.
def var c-nat-operacao as char no-undo.
def var c-nat-principal as char no-undo.
def var i-cfop     as integer no-undo.
def var i-cst      as integer no-undo.
def var c-cod-estabel as char no-undo.
def var i-ind      as integer no-undo.
def var i-trib-icm as integer no-undo.
def var i-trib-ipi as integer no-undo.
def var de-qt-enviada as decimal no-undo.
def var de-qt-importada as decimal no-undo.
def var i-sit_reg as int no-undo.
def var de-total-bruto as decimal decimals 5 no-undo.
def var de-tot-despesas as decimal decimals 4 no-undo.

DEFINE VARIABLE h-reapi414 AS HANDLE      NO-UNDO.

DEFINE VARIABLE c-cod-sit-tribut-icms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-ipi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-pis    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-cofins AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-aliq-pis             AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins          AS DECIMAL     NO-UNDO.
DEF VAR nome_transp                     AS CHAR NO-UNDO.
DEF VAR c-item                          AS CHAR        NO-UNDO.

def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.

def buffer bint_ds_docto_xml for int_ds_docto_xml.
def buffer bint_ds_docto_wms for int_ds_docto_wms.

/* definiÆo de frames do relat¢rio */

/* include com a definiÆo da frame de cabealho e rodap */
{include/i-rpcab.i &STREAM="str-rp"}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i &stream = "stream str-rp"}
END.

assign c-programa     = "int072"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Documento Recebimento CD".
/*                                            */
/* IF tt-param.arquivo <> "" THEN DO:         */
/*     VIEW /*stream str-rp*/ frame f-cabec.  */
/*     view /*stream str-rp */frame f-rodape. */
/* END.                                       */

FIND first param-re no-lock where param-re.usuario = c-seg-usuario NO-ERROR.
if not avail param-re then do:
    put stream str-rp unformatted "Parmetros do usu rio recebimento nÆo cadastrados...." SKIP.
    return "NOK".
end.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

FIND first param-global NO-LOCK NO-ERROR.
FIND first mgadm.empresa no-lock where
     empresa.ep-codigo = param-global.empresa-prin NO-ERROR.
assign c-empresa = mgadm.empresa.razao-social.


if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 60
           tt-param.dt-emis-nota-fim = TODAY .

if tt-param.dt-trans-ini = ? then
    assign tt-param.dt-trans-ini = today - 5
           tt-param.dt-trans-fim = TODAY.


/******* LE NOTA E GERA TEMP TABLES  *************/

MESSAGE "ANTES FOR-NOTA - 2" SKIP
    tt-param.destino              SKIP
    tt-param.arquivo              SKIP
    tt-param.usuario              SKIP
    tt-param.data-exec            SKIP
    tt-param.hora-exec            SKIP
    tt-param.classifica           SKIP
    tt-param.desc-classifica      SKIP
    tt-param.cod-emitente-fim     SKIP
    tt-param.cod-emitente-ini     SKIP
    tt-param.cod-estabel-fim      SKIP
    tt-param.cod-estabel-ini      SKIP
    tt-param.dt-emis-nota-fim     SKIP
    tt-param.dt-emis-nota-ini     SKIP
    tt-param.dt-trans-fim         SKIP
    tt-param.dt-trans-ini         SKIP
    tt-param.nro-docto-fim        SKIP
    tt-param.nro-docto-ini        SKIP
    tt-param.serie-docto-fim      SKIP
    tt-param.serie-docto-ini 
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

for-nota:      
for each int_ds_docto_xml no-lock USE-INDEX idx_tipo_estab
    where
    int_ds_docto_xml.situacao <= 2 AND
    int_ds_docto_xml.tipo_estab = 1 AND
    int_ds_docto_xml.dEmi >= dt-emis-nota-ini and
    int_ds_docto_xml.dEmi <= dt-emis-nota-fim and
    int_ds_docto_xml.serie >= serie-docto-ini and
    int_ds_docto_xml.serie <= serie-docto-fim and
    int_ds_docto_xml.nNF >= nro-docto-ini and
    int_ds_docto_xml.nNF <= nro-docto-fim and
    int_ds_docto_xml.cod_emitente >= cod-emitente-ini and
    int_ds_docto_xml.cod_emitente <= cod-emitente-fim and
    int_ds_docto_xml.cod_estab >= cod-estabel-ini and
    int_ds_docto_xml.cod_estab <= cod-estabel-fim and
    int_ds_docto_xml.tipo_nota <> 3 /* transferencia faz no int052 */ AND
    (int_ds_docto_xml.CNPJ_dest = "79430682025540" OR int_ds_docto_xml.CNPJ_dest = "05912018000183")  /* 973 */ :

 
    MESSAGE "ACHOU INT_DS_DOCTO DENTRO DO FOR NOTA"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    /* pular notas a serem integradas manualmente pelo int520 */
    if int_ds_docto_xml.situacao = 7 and nro-docto-ini = "" then next.

    /* notas de balano ou impostos */
    if int_ds_docto_xml.CNPJ = int_ds_docto_xml.CNPJ_dest then next.

    assign l-erro = no.
    empty temp-table tt-movto.

    FIND FIRST ems2mult.emitente no-lock where 
        emitente.cod-emitente = int_ds_docto_xml.cod_emitente NO-ERROR.
    FIND FIRST ems2mult.dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1 NO-ERROR.
    if not avail ems2mult.emitente then do:
        run pi-gera-log (input "Fornecedor nÆo cadastrado ou inativo. CNPJ: " + string(int_ds_docto_xml.CNPJ),
                         input 1).
        empty temp-table tt-movto.
        next.
    end.

    c-cod-estabel = int_ds_docto_xml.cod_estab.
    
    FIND FIRST  ems2mult.estabelec 
        no-lock where
        estabelec.cgc = int_ds_docto_xml.CNPJ_dest NO-ERROR.
        
    
    c-cod-estabel = estabelec.cod-estabel.
        
    IF c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento nÆo cadastrado ou fora de operaÆo. CNPJ: " + int_ds_docto_xml.CNPJ_dest,
                         input 1).
        empty temp-table tt-movto.
        next.
    end.

    if  c-cod-estabel < cod-estabel-ini or
        c-cod-estabel > cod-estabel-fim then next.



    if not can-find (first usuar_financ_estab_apb no-lock where 
                           usuar_financ_estab_apb.cod_estab = c-cod-estabel and
                           usuar_financ_estab_apb.cod_usuario = c-seg-usuario) then do:
        
        run pi-gera-log (input "Usu rio Financeiro nÆo cadastrado para estabelecimento " + c-cod-estabel
                         + "Srie: "     + trim(int_ds_docto_xml.serie)
                         + " Numero: "   + trim(int_ds_docto_xml.nNF)
                         + " Forn: "     + string(emitente.cod-emitente)
                         + " Data: "     + string(int_ds_docto_xml.dt_trans,"99/99/9999"),
                         input 1).
        empty temp-table tt-movto.
        next .
    end.  
    
    de-total-bruto = 0.

    IF ems2mult.estabelec.estado <> emitente.estado THEN
    DO:
        FOR EACH custom.esp-integracao-cte NO-LOCK:

        ASSIGN c-item = item-fora
               c-nat-operacao = nat-operacao-fora.

        END.
    END.

    ELSE DO:

        FOR EACH custom.esp-integracao-cte NO-LOCK:

        ASSIGN c-item = item-dentro
               c-nat-operacao = nat-operacao-dentro.

        END.

    END.
        
 
    create tt-movto.
    assign tt-movto.CNPJ_dest           = int_ds_docto_xml.CNPJ_dest
           tt-movto.nNF                 = int_ds_docto_xml.nNF
           tt-movto.serie               = int_ds_docto_xml.serie
           tt-movto.nr-nota-fis         = trim(string(int(int_ds_docto_xml.nNF),">>>9999999"))
           tt-movto.dt-emissao          = int_ds_docto_xml.dEmi
           tt-movto.tot-frete           = fnTrataNuloDec(int_ds_docto_xml.valor_frete)
           tt-movto.tot-seguro          = fnTrataNuloDec(int_ds_docto_xml.valor_seguro)
           tt-movto.tot-despesas        = fnTrataNuloDec(int_ds_docto_xml.valor_outras) + fnTrataNuloDec(int_ds_docto_xml.despesa_nota) /* verificar */
           tt-movto.tot-desconto        = fnTrataNuloDec(int_ds_docto_xml.tot_desconto) + fnTrataNuloDec(int_ds_docto_xml.valor_icms_des)
           tt-movto.chave-acesso        = int_ds_docto_xml.chnfe   //comentado pois nao sei ainda como enviar o tipo-cte por parametro
           tt-movto.mod-frete           = int_ds_docto_xml.modFrete
           tt-movto.CNPJ                = int_ds_docto_xml.CNPJ
           tt-movto.cfop                = int_ds_docto_xml.cfop
           tt-movto.tp-despesa          = emitente.tp-desp-padrao
           tt-movto.cod-estabel         = c-cod-estabel
           tt-movto.cod-emitente        = emitente.cod-emitente
           tt-movto.uf                  = emitente.estado
           tt-movto.tipo_nota           = int_ds_docto_xml.tipo_nota
           tt-movto.dt-trans            = int_ds_docto_xml.dt_trans
           tt-movto.dt-imposto          = int_ds_docto_xml.dt_guia_st
           tt-movto.base_guia_st        = if fnTrataNuloDec(int_ds_docto_xml.base_guia_st) <> ? and
                                             fnTrataNuloDec(int_ds_docto_xml.base_guia_st) <> 0 
                                          then fnTrataNuloDec(int_ds_docto_xml.base_guia_st)
                                          else fnTrataNuloDec(int_ds_docto_xml.vbc_cst)
           //tt-movto.perc-red-icms       = fnTrataNuloDec(int_ds_it_docto_xml.predBc)
           //tt-movto.vl-icms-des         = fnTrataNuloDec(int_ds_it_docto_xml.vicmsdeson)
           tt-movto.cod-cond-pag        = emitente.cod-cond-pag
           tt-movto.nat-operacao        = c-nat-operacao
           tt-movto.valor_guia_st       = fnTrataNuloDec(int_ds_docto_xml.valor_guia_st)
           tt-movto.vbcstret            = 0 //int_ds_it_docto_xml.vbcstret     
           tt-movto.vicmsstret          = 0 //int_ds_it_docto_xml.vicmsstret
           tt-movto.cst_icms            = 0 //int_ds_it_docto_xml.cst_icms 
           tt-movto.vICMSSubs           = 0 //int_ds_it_docto_xml.vICMSSubs
           tt-movto.picmsst             = 0 //int_ds_it_docto_xml.picmsst
           .  
                                                                                                 


    if  tt-movto.cod-emitente = 1000 or
        tt-movto.cod-emitente = 5000 or
        tt-movto.cod-emitente = 9574 then do:
        if  day(tt-movto.dt-emissao) >= 1 and 
            day(tt-movto.dt-emissao) <= 7 then tt-movto.cod-cond-pag = 259.
        else tt-movto.cod-cond-pag = 241.
    end.
    
    
           
    FIND first ITEM no-lock 
    WHERE item.it-codigo = c-item NO-ERROR.

    if item.tipo-contr = 1 /* Fisico */ or item.tipo-contr = 4 /* DB Dir */ then do:
        if item.ct-codigo = "" then do:
            run pi-gera-log (input "Item sem conta aplicacao: " + string(ITEM.it-codigo),
                             input 1).
            next.
        end.
        else do:
            assign tt-movto.ct-codigo = item.ct-codigo
                   tt-movto.sc-codigo = item.sc-codigo.
        end.
    end.
    
    FIND first item-uni-estab no-lock where 
              item-uni-estab.cod-estabel = tt-movto.cod-estabel and
              item-uni-estab.it-codigo = string(ITEM.it-codigo) NO-ERROR. 

    if not avail item-uni-estab THEN DO:
       FIND first item-estab NO-LOCK where 
                 item-estab.cod-estabel = tt-movto.cod-estabel and
                 item-estab.it-codigo = string(ITEM.it-codigo) NO-ERROR. 
    END.
    if not avail item-estab and not avail item-uni-estab then do:
       run pi-gera-log (input "Item nÆo cadastrado no estabelecimento. Item: " + string(ITEM.it-codigo) + " Estab.: " + tt-movto.cod-estabel,
                        input 1).
       next.
    end.
        //i-cfop = int_ds_it_docto_xml.cfop.
    if i-cfop = ? then do:
        run pi-gera-log (input "CFOP do Item nÆo informada. Item: " + string(ITEM.it-codigo),
                         input 1).
        next.
    end.
        //assign i-cst = int_ds_it_docto_xml.cst_icms.

        /* tratar natur-oper */
    c-nat-operacao = tt-movto.nat-operacao.
/*         if c-nat-operacao = ? or                                                                    */
/*            c-nat-operacao = "" then do:                                                             */
/*             RUN intprg/int013a.p( input i-cfop,                                                     */
/*                                   input i-cst,                                                      */
/*                                   input /*int_ds_it_docto_xml.nep-cstb-ipi-n*/ int(item.fm-codigo), */
/*                                   input tt-movto.cod-estabel,                                       */
/*                                   input tt-movto.cod-emitente,                                      */
/*                                   INPUT item.class-fiscal,                                          */
/*                                   input tt-movto.dt-emissao,                                        */
/*                                   output c-nat-operacao ).                                          */
    if c-nat-operacao = "" then do:
        run pi-gera-log (input "NÆo encontrada natureza de operaÆo para entrada. " + 
                                "CFOP Nota: " + string(i-cfop) + 
                                " CFOP Calc: " + string(i-cfop) + 
                                //" CSTB ICMS: " + string(int_ds_it_docto_xml.cst_ipi) + 
                                /*" CSTB IPI:" + string(int_ds_it_docto_xml.nep-cstb-ipi-n)*/
                                " Fam¡lia: " + item.fm-codigo + " Estab.: " + ems2mult.estabelec.cod-estabel,
                         input 1).
    end.
        //end.
    FIND first natur-oper no-lock where 
        natur-oper.nat-operacao = c-nat-operacao NO-ERROR.
    if not avail natur-oper then do:
        run pi-gera-log (input "Natureza de operaÆo nÆo cadastrada. Natur. Oper.: " + c-nat-operacao,
                         input 1).
        next.
    end.
        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
           coment_usuar_hotel itens sem st na nota-conhec */
    if c-nat-principal = "" 
       &if "{&bf_dis_versao_ems}" < "2.07" &THEN
        then 
       &else
        or NOT natur-oper.log-contrib-st-antec then
       &endif
        assign c-nat-principal = c-nat-operacao.

    if can-find (first int_ds_docto_xml_dup of int_ds_docto_xml) and
       not can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and
                     natur-oper.emite-duplic) then do:
        run pi-gera-log (input "Duplicatas informadas e Natureza de operaÆo nÆo emite duplicatas. Liberando alteraÆo manual. Natur. Oper.: " + c-nat-principal,
                         input 1).
    end.
    if int_ds_docto_xml.situacao <> 5 and
        can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and
                 natur-oper.venda-ativo) then do:
        run pi-gera-log (input "Natureza de operaÆo de compra de ativo fixo. Liberando alteraÆo manual. Natur. Oper.: " + c-nat-principal,
                         input 1).
    end.
    assign i-trib-icm = natur-oper.cd-trib-icm.
       

    assign tt-movto.it-codigo       = ITEM.it-codigo
           tt-movto.nr-sequencia    = 10
           tt-movto.qt-recebida     = 1
           tt-movto.cod-depos       = if avail item-uni-estab and trim(item-uni-estab.deposito-pad) <> "" and trim(item-uni-estab.deposito-pad) <> ?
                                      then item-uni-estab.deposito-pad
                                      else if avail item-estab and trim(item-estab.deposito-pad) <> "" and trim(item-estab.deposito-pad) <> ? then item-estab.deposito-pad else "LOJ"
           tt-movto.lote            = "" //if item.tipo-con-est = 3 then int_ds_it_docto_xml.Lote else ""
           tt-movto.dt-vali-lote    = ? //if item.tipo-con-est = 3 then int_ds_it_docto_xml.dVal else ?
           tt-movto.valor-mercad    = int_ds_docto_xml.valor_mercad //fnTrataNuloDec(int_ds_it_docto_xml.vProd)
           tt-movto.desconto        = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vDesc) + tt-movto.vl-icms-des
           tt-movto.vl-despesas     = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vOutro)
           //tt-movto.tipo-compra     = natur-oper.tipo-compra
           tt-movto.terceiros       = natur-oper.terceiros
           tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
           tt-movto.cd-trib-icm     = i-trib-icm
           tt-movto.nat-operacao    = natur-oper.nat-operacao
           tt-movto.aliquota-icm    = IF item.cd-trib-icm = 2 THEN 0 ELSE 7.00  //fnTrataNuloDec(int_ds_it_docto_xml.picms)
           tt-movto.perc-red-icm    = 0 //fnTrataNuloDec(int_ds_it_docto_xml.predBc)
           tt-movto.vl-bicms-it     = int_ds_docto_xml.valor_mercad //int_ds_docto_xml.vbc //fnTrataNuloDec(int_ds_it_docto_xml.vbc_icms)
           tt-movto.vl-icms-it      = int_ds_docto_xml.valor_icms //fnTrataNuloDec(int_ds_it_docto_xml.vicms)
           //tt-movto.cd-trib-ipi     = 2 //i-trib-ipi
           //tt-movto.aliquota-ipi    = 0 //fnTrataNuloDec(int_ds_it_docto_xml.pipi)
           tt-movto.vl-bipi-it      = int_ds_docto_xml.valor_mercad  //fnTrataNuloDec(int_ds_it_docto_xml.vbc_ipi)
           tt-movto.vl-ipi-it       = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vipi)
           tt-movto.vl-bsubs-it     = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vbcst)
           tt-movto.vl-icmsub-it    = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vicmsst)
           tt-movto.peso-liquido    = item.peso-liquido
           tt-movto.class-fiscal    = item.class-fiscal //if int_ds_it_docto_xml.ncm <> 0 and int_ds_it_docto_xml.ncm <> ? 
                                      //then trim(string(int_ds_it_docto_xml.ncm,"99999999")) else item.class-fiscal
           .
         
     // KML - 01/03/2025 - Kleber Mazepa - Quando merco o dep¢sito e fixo no REC para depois vir movimento de estoque tirando do REC e colocando no dep¢sito EXP
    assign tt-movto.numero-ordem    = 0. //int_ds_it_docto_xml.numero_ordem.
    assign tt-movto.tp-despesa      = emitente.tp-desp-padrao.

    /* recalculado - SM 88 - PIS/COFINS
    assign tt-movto.cd-trib-pis     = int_ds_it_docto_xml.cst-pis
           tt-movto.aliquota-pis    = fnTrataNuloDec(int_ds_it_docto_xml.ppis   )
           tt-movto.base-pis        = fnTrataNuloDec(int_ds_it_docto_xml.vbc-pis)
           tt-movto.valor-pis       = fnTrataNuloDec(int_ds_it_docto_xml.vpis   ).
    
    assign tt-movto.cd-trib-cofins  = int_ds_it_docto_xml.cst-cofins
           tt-movto.aliquota-cofins = fnTrataNuloDec(int_ds_it_docto_xml.pcofins    )
           tt-movto.base-cofins     = fnTrataNuloDec(int_ds_it_docto_xml.vbc-cofins )
           tt-movto.valor-cofins    = fnTrataNuloDec(int_ds_it_docto_xml.vcofins    ).
        */

    if int(substr(natur-oper.char-1,86,1)) /* CD-TRIB-PIS */ = 1 /* tributado */ then do:
        tt-movto.aliquota-pis       = if substr(ITEM.char-2,52,1) = "1" 
                                      /* Al¡quota do Item */
                                      then dec(substr(item.char-2,31,5))
                                      /* Al¡quota da natureza */
                                      else natur-oper.perc-pis[1].
        if tt-movto.aliquota-pis <> 0 then do:
            tt-movto.base-pis           = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                        - 0 //fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                        + 0. //fnTrataNuloDec(int_ds_it_docto_xml.vOutro).
            tt-movto.valor-pis          = tt-movto.base-pis * tt-movto.aliquota-pis / 100.
        end.
        else do:
            tt-movto.cd-trib-pis = 2.
            tt-movto.base-pis    = 0.
            tt-movto.valor-pis   = 0.
        end.
    end.
    assign tt-movto.cd-trib-cofins  = int(substr(natur-oper.char-1,87,1)).
    if int(substr(natur-oper.char-1,87,1)) /* CD-TRIB-COFINS */ = 1 /* tributado */ then do:
        tt-movto.aliquota-cofins    = if substr(item.char-2,53,1) = "1"
                                      then dec(substr(item.char-2,36,5))
                                      else natur-oper.per-fin-soc[1].
        if tt-movto.aliquota-cofins <> 0 then do:
            tt-movto.base-cofins        = 0 //fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                        - 0 //fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                        + 0. //fnTrataNuloDec(int_ds_it_docto_xml.vOutro).                                                                        
            tt-movto.valor-cofins       = tt-movto.aliquota-cofins * tt-movto.base-cofins / 100.
        end.
        else do:
            tt-movto.base-cofins        = 0.
            tt-movto.valor-cofins       = 0.
            tt-movto.cd-trib-COFINS     = 2.
        end.
    end.

    if not can-find (first classif-fisc no-lock where classif-fisc.class-fiscal = tt-movto.class-fiscal) then do:
        run pi-gera-log (input "NCM nÆo cadastrada. Item: " + tt-movto.it-codigo + " NCM: " + string(string(tt-movto.class-fiscal)),
                         input 1).
    end.
    if not can-find (first estabelec no-lock WHERE ems2mult.estabelec.cod-emitente = tt-movto.cod-emitente) then do:
        for first pedido-compr no-lock where pedido-compr.num-pedido = int_ds_docto_xml.num_pedido:
            if  pedido-compr.cod-cond-pag <> 0 and 
                pedido-compr.cod-cond-pag <> ? and
                pedido-compr.cod-cond-pag <> 999 and
                pedido-compr.cod-emitente = tt-movto.cod-emitente then 
                assign tt-movto.cod-cond-pag = pedido-compr.cod-cond-pag.
            for first ordem-compra fields (numero-ordem it-codigo tp-despesa) no-lock where 
                ordem-compra.num-pedido = pedido-compr.num-pedido and
                ordem-compra.it-codigo  = tt-movto.it-codigo:
                assign tt-movto.tp-despesa = ordem-compra.tp-despesa.
                for first prazo-compra fields (parcela) no-lock of ordem-compra:
                    assign tt-movto.parcela = prazo-compra.parcela.
                end.
            end.
            if pedido-compr.cod-emitente <> tt-movto.cod-emitente and
               not param-re.rec-out-for then do:
                run pi-gera-log (input "Pedido de compra nÆo  deste fornecedor. Pedido: " + string(int_ds_docto_xml.num_pedido),
                                 input 1).
            end.
            assign tt-movto.num-pedido = pedido-compr.num-pedido.
        end.
        if not avail pedido-compr and not param-re.sem-pedido then do:
            run pi-gera-log (input "NÆo encontrado pedido de compra. " + 
                                    "Pedido: " + string(int_ds_docto_xml.num_pedido),
                             input 1).
        end.
        de-tot-despesas = de-tot-despesas + tt-movto.vl-despesas.
    end.
   
        de-total-bruto = de-total-bruto + 0. //fnTrataNuloDec(int_ds_it_docto_xml.vProd).
    //end. /* int_ds_it_docto_xml */

/*     if de-total-bruto <> int_ds_docto_xml.valor_mercad then do:                                                                                                                                   */
/*         run pi-gera-log (input "Total do documento nÆo bate com total dos itens: " + string(int_ds_docto_xml.nNF) + " Srie: " + string(int_ds_docto_xml.serie) + " Estab.: " + c-cod-estabel + */
/*                              " Itens: " + trim(string(de-total-bruto,"->>>,>>>,>>9.99")) + " Nota: " + trim(string(int_ds_docto_xml.valor_mercad,"->>>,>>>,>>9.99")),                             */
/*                          input 1).                                                                                                                                                                */
/*     end.                                                                                                                                                                                          */

    if can-find(first tt-movto) then do:

/*         if abs(de-tot-despesas - tt-movto.tot-despesas) > 0.02 then do:                                                                                                                     */
/*             run pi-gera-log (input "Total das despesas nÆo confere. Docto: " + string(int_ds_docto_xml.nNF) + " Srie: " + string(int_ds_docto_xml.serie) + " Estab.: " + c-cod-estabel + */
/*                              " Itens: " + trim(string(de-tot-despesas,"->>>,>>>,>>9.99")) + " Nota: " + trim(string(tt-movto.tot-despesas,"->>>,>>>,>>9.99")),                              */
/*                              input 1).                                                                                                                                                      */
/*         end.                                                                                                                                                                                */

        if not l-erro then
        run PiGeraMovimento (input table tt-movto,   
                             input '').
    end.
/*     else do:                                                                                                                                                                       */
/*         run pi-gera-log (input "Documento nÆo possui Itens. Docto: " + string(int_ds_docto_xml.nNF) + " Srie: " + string(int_ds_docto_xml.serie) + " Estab.: " + c-cod-estabel, */
/*                          input 1).                                                                                                                                                 */
/*     end.                                                                                                                                                                           */
    release int_ds_docto_xml.
end.

/* fechamento do output do relat¢rio  */
/* IF tt-param.arquivo <> "" THEN DO:              */
/*                                                 */
/*     {include/i-rpclo.i &STREAM="stream str-rp"} */
/* END.                                            */

RUN intprg/int888.p (INPUT "NFE",
                     INPUT "INT072RP.P").

run pi-finalizar in h-acomp.

for each tt-versao-integr. delete tt-versao-integr. end.
for each tt-docum-est-nova:     delete tt-docum-est-nova.     end.
for each tt-item-doc-est-nova:  delete tt-item-doc-est-nova.  end.
for each tt-dupli-apagar:  delete tt-dupli-apagar.  end.
for each tt-dupli-imp:     delete tt-dupli-imp.     end.
for each tt-unid-neg-nota: delete tt-unid-neg-nota. end.
for each tt-erro:          delete tt-erro.          end.
for each tt-movto:         delete tt-movto.         end.

return "OK":U.


procedure PiGeraMovimento:

    def input parameter table for tt-movto.
    def input parameter p-narrativa as char no-undo. 
    def var h-api as handle no-undo.
    
    /******* GERA DOCUMENTO PARA DevolucaoS CONFORME PARAMETRO RECEBIDO *************/

    def buffer b-rat-lote for rat-lote.

    for each tt-versao-integr. delete tt-versao-integr. end.
    for each tt-docum-est-nova:     delete tt-docum-est-nova.     end.
    for each tt-item-doc-est-nova:  delete tt-item-doc-est-nova.  end.
    for each tt-dupli-apagar:  delete tt-dupli-apagar.  end.
    for each tt-dupli-imp:     delete tt-dupli-imp.     end.
    for each tt-unid-neg-nota: delete tt-unid-neg-nota. end.
    for each tt-erro:          delete tt-erro.          end.
    
    find first tt-movto no-error.
    if not avail tt-movto then return.
    
    find first estab-mat 
        no-lock where
        estab-mat.cod-estabel = tt-movto.cod-estabel 
        no-error.
    if not avail estab-mat then do:
        run pi-gera-log (input "Estabelecimento materiais nÆo cadastrado. Estab.: " + tt-movto.cod-estabel,
                         input 1).
        next.
    end.
        
    create tt-versao-integr.
    assign tt-versao-integr.registro              = 1
           tt-versao-integr.cod-versao-integracao = 004.
    
    for each tt-movto
        break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nr-sequencia:

        if first-of (tt-movto.nr-nota-fis) then do:
    
            for each tt-dupli-apagar:  delete tt-dupli-apagar.  end.
            i-ind = 0.
            
                i-ind = i-ind + 1.
       
                create  tt-dupli-apagar.
                assign  tt-dupli-apagar.registro       = 4
                        tt-dupli-apagar.parcela        = string(i-ind,"99")
                        tt-dupli-apagar.nr-duplic      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-esp        = "NF"
                        tt-dupli-apagar.tp-despesa     = tt-movto.tp-despesa
                        tt-dupli-apagar.dt-vencim      = IF day(TODAY) <= 15 THEN DATE("10/" + SUBSTRING(STRING(DATE(ADD-INTERVAL(NOW,1,"months"))),4,5)) ELSE DATE("25/" + SUBSTRING(STRING(DATE(ADD-INTERVAL(NOW,1,"months"))),4,5))
                        tt-dupli-apagar.vl-a-pagar     = int_ds_docto_xml.valor_mercad
                        tt-dupli-apagar.vl-desconto    = 0
                        tt-dupli-apagar.dt-venc-desc   = ?
                        tt-dupli-apagar.serie-docto    = tt-movto.serie
                        tt-dupli-apagar.nro-docto      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-emitente   = tt-movto.cod-emitente
                        tt-dupli-apagar.nat-operacao   = c-nat-principal.

            //end.
/*             for first int_ds_docto_xml_dup no-lock of int_ds_docto_xml where                                             */
/*                 int_ds_docto_xml_dup.nDup matches "*GNRE*":                                                              */
/*                 for first tt-dupli-apagar:                                                                               */
/*                    create tt-dupli-imp.                                                                                  */
/*                    assign tt-dupli-imp.registro              = 5                                                         */
/*                           tt-dupli-imp.cod-imp               = 9999                                                      */
/*                           tt-dupli-imp.cod-esp               = "ST"                                                      */
/*                           tt-dupli-imp.dt-venc-imp           = date(int(entry(2,int_ds_docto_xml_dup.dVenc,"/")),        */
/*                                                                     int(entry(1,int_ds_docto_xml_dup.dVenc,"/")),        */
/*                                                                     int(entry(3,int_ds_docto_xml_dup.dVenc,"/")))        */
/*                           tt-dupli-imp.rend-trib             = tt-movto.base_guia_st                                     */
/*                           tt-dupli-imp.aliquota              = (int_ds_docto_xml_dup.vDup / tt-movto.base_guia_st) * 100 */
/*                           tt-dupli-imp.vl-imposto            = int_ds_docto_xml_dup.vDup                                 */
/*                           tt-dupli-imp.tp-codigo             = 399                                                       */
/*                           tt-dupli-imp.cod-retencao          = 9999                                                      */
/*                           tt-dupli-imp.serie-docto           = tt-dupli-apagar.serie-docto                               */
/*                           tt-dupli-imp.nro-docto             = tt-dupli-apagar.nro-docto                                 */
/*                           tt-dupli-imp.cod-emitente          = tt-dupli-apagar.cod-emitente                              */
/*                           tt-dupli-imp.nat-operacao          = tt-dupli-apagar.nat-operacao                              */
/*                           tt-dupli-imp.parcela               = tt-dupli-apagar.parcela.                                  */
/*                    assign tt-dupli-apagar.vl-a-pagar         = tt-dupli-apagar.vl-a-pagar + tt-dupli-imp.vl-imposto.     */
/*                 end.                                                                                                     */
/*             end.                                                                                                         */
            
            if  not can-find (first ems2mult.estabelec no-lock where estabelec.cod-emitente = tt-movto.cod-emitente) and
                not can-find (first tt-dupli-apagar) and
               (tt-movto.cod-cond-pag = 0 or tt-movto.cod-cond-pag = 999 or tt-movto.cod-cond-pag = ?) and
                /* bonificaäes, etc. */
               ((substring(tt-movto.nat-operacao,1,1) = "1" and substring(tt-movto.nat-operacao,1,4) < "1910") or
                (substring(tt-movto.nat-operacao,1,1) = "2" and substring(tt-movto.nat-operacao,1,4) < "2910"))
                then do:
                run pi-gera-log (input "Duplicatas nÆo geradas. Docto.: " + tt-movto.nr-nota-fis + " Srie: "  + tt-movto.serie + " Estab.: " + tt-movto.cod-estabel,
                                 input 1).
            end.
        end.
        
        FIND FIRST ems2mult.TRANSPORTE NO-LOCK
            WHERE TRANSPORTE.cgc = ems2mult.emitente.cgc NO-ERROR.
            
        IF AVAIL TRANSPORTE THEN
        DO:
            
            ASSIGN nome_transp = TRANSPORTE.nome-abrev.
            
        END.
        
        ELSE DO:
        
            ASSIGN nome_transp = " ".
            
        END.
        
        MESSAGE  "ACHOU TRANSPORTADOR"
                 nome_transp
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        FIND FIRST tt-docum-est-nova where 
            tt-docum-est-nova.serie-docto       = tt-movto.serie         and
            tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis   and
            tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente NO-ERROR.
        if not avail tt-docum-est-nova then do:
            create tt-docum-est-nova.
            assign tt-docum-est-nova.registro          = 2
                   tt-docum-est-nova.serie-docto       = tt-movto.serie 
                   tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis
                   tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente
                   tt-docum-est-nova.nat-operacao      = c-nat-principal
                   //tt-docum-est-nova.cod-observa       = tt-movto.tipo-compra
                   tt-docum-est-nova.cod-estabel       = tt-movto.cod-estabel
                   tt-docum-est-nova.estab-fisc        = tt-movto.cod-estabel
                   tt-docum-est-nova.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                            if tt-movto.terceiros then 
                                                            estab-mat.conta-ent-benef
                                                            else if not can-find(first tt-dupli-apagar) then "31101015"
                                                            else estab-mat.conta-fornec
                                                         &else
                                                            if tt-movto.terceiros then 
                                                            estab-mat.cod-cta-e-benef-unif
                                                            else if not can-find(first tt-dupli-apagar) then "31101015"
                                                            else estab-mat.cod-cta-fornec-unif
                                                         &endif                                            
                   tt-docum-est-nova.sc-transit        = ""
                   tt-docum-est-nova.dt-emissao        = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-trans          = tt-movto.dt-trans
                   tt-docum-est-nova.usuario           = c-seg-usuario
                   tt-docum-est-nova.uf                = tt-movto.uf
                   tt-docum-est-nova.nome-transp       = nome_transp //"JOSNEI" //emitente.nome-emit
                   tt-docum-est-nova.via-transp        = 1
                   tt-docum-est-nova.mod-frete         = 1
                   tt-docum-est-nova.Cod-modalid-frete = "1" //teste MODALIDADE
                   tt-docum-est-nova.nff               = yes
                   tt-docum-est-nova.tot-desconto      = tt-movto.tot-desconto
                   tt-docum-est-nova.valor-frete       = tt-movto.tot-frete 
                   tt-docum-est-nova.valor-seguro      = tt-movto.tot-seguro
                   tt-docum-est-nova.valor-embal       = 0
                   tt-docum-est-nova.valor-outras      = tt-movto.tot-despesas
                   tt-docum-est-nova.dt-venc-ipi       = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-venc-icm       = tt-movto.dt-emissao
                   tt-docum-est-nova.efetua-calculo    = 2 /*1 - efetua os c�lculos - <> 1 valor informado*/
                   tt-docum-est-nova.sequencia         = 1
                   tt-docum-est-nova.esp-docto         = if tt-movto.tipo_nota = 1 then 21 /* NFE */ else 23 /* NFT */
                   tt-docum-est-nova.rec-fisico        = no
                   tt-docum-est-nova.origem            = "" /* verificar*/
                   tt-docum-est-nova.pais-origem       = "Brasil"
                   tt-docum-est-nova.cotacao-dia       = 0
                   tt-docum-est-nova.embarque          = ""
                   tt-docum-est-nova.gera-unid-neg     = 0.
/*                    &if "{&bf_dis_versao_ems}" < "2.07" &THEN                                */
/*                         substring(tt-docum-est-nova.char-1,93,60)  = tt-movto.chave-acesso. */
/*                    &else                                                                    */
/*                         tt-docum-est-nova.cod-chave-aces-nf-eletro = tt-movto.chave-acesso. */
/*                    &endif                                                                   */
                   
        end. 
        run pi-acompanhar in h-acomp (input string(tt-movto.nr-sequencia)).
        create tt-item-doc-est-nova.
        assign tt-item-doc-est-nova.registro           = 3
               tt-item-doc-est-nova.it-codigo          = tt-movto.it-codigo
               tt-item-doc-est-nova.cod-refer          = ""
               tt-item-doc-est-nova.numero-ordem       = 0
               tt-item-doc-est-nova.parcela            = 1
               tt-item-doc-est-nova.encerra-pa         = NO
               tt-item-doc-est-nova.nr-ord-prod        = 0
               tt-item-doc-est-nova.cod-roteiro        = ""
               tt-item-doc-est-nova.op-codigo          = 0
               tt-item-doc-est-nova.item-pai           = ""
               tt-item-doc-est-nova.baixa-ce           = yes
               tt-item-doc-est-nova.etiquetas          = 0
               tt-item-doc-est-nova.qt-do-forn         = tt-movto.qt-recebida
               tt-item-doc-est-nova.quantidade         = tt-movto.qt-recebida
               tt-item-doc-est-nova.preco-total        = tt-movto.valor-mercad
               tt-item-doc-est-nova.desconto           = tt-movto.desconto
               tt-item-doc-est-nova.vl-frete-cons      = 0
               tt-item-doc-est-nova.despesas           = tt-movto.vl-despesas
               tt-item-doc-est-nova.peso-liquido       = tt-movto.peso-liquido * tt-movto.qt-recebida
               tt-item-doc-est-nova.cod-depos          = IF tt-movto.cod-depos <> "" THEN tt-movto.cod-depos ELSE "LOJ"
               tt-item-doc-est-nova.cod-localiz        = ""
               tt-item-doc-est-nova.lote               = tt-movto.lote
               tt-item-doc-est-nova.dt-vali-lote       = tt-movto.dt-vali-lote
               tt-item-doc-est-nova.class-fiscal       = tt-movto.class-fisc 
               tt-item-doc-est-nova.aliquota-ipi       = tt-movto.aliquota-ipi
               tt-item-doc-est-nova.cd-trib-ipi        = tt-movto.cd-trib-ipi 
               tt-item-doc-est-nova.base-ipi           = if tt-movto.cd-trib-ipi = 1
                                                         then tt-movto.vl-bipi-it
                                                         else 0
               tt-item-doc-est-nova.ipi-outras         = if tt-movto.cd-trib-ipi = 3 
                                                         then tt-movto.vl-bipi-it    
                                                         else 0                      
               tt-item-doc-est-nova.ipi-ntrib          = if tt-movto.cd-trib-ipi = 2
                                                         then tt-movto.vl-bipi-it    
                                                         else 0                      
               tt-item-doc-est-nova.valor-ipi          = tt-movto.vl-ipi-it
               tt-item-doc-est-nova.cd-trib-iss        = tt-movto.cd-trib-iss
               tt-item-doc-est-nova.aliquota-icm       = tt-movto.aliquota-icm
               tt-item-doc-est-nova.cd-trib-icm        = tt-movto.cd-trib-icm 
               tt-item-doc-est-nova.base-icm           = if tt-movto.cd-trib-icm = 1 or 
                                                            tt-movto.cd-trib-icm = 4 
                                                         then tt-movto.vl-bicms-it
                                                         else 0
               tt-item-doc-est-nova.valor-icm          = tt-movto.vl-icms-it
               tt-item-doc-est-nova.base-subs          = tt-movto.vl-bsubs-it
               tt-item-doc-est-nova.valor-subs         = tt-movto.vl-icmsub-it 
               tt-item-doc-est-nova.icm-complem        = 0
               tt-item-doc-est-nova.ind-icm-ret        = if tt-movto.vl-icmsub-it <> 0 then yes else no
               tt-item-doc-est-nova.narrativa          = p-narrativa
               tt-item-doc-est-nova.icm-outras         = tt-movto.vl-icms-des + 
                                                         if (tt-movto.cd-trib-icm = 3 or tt-movto.cd-trib-icm = 5)
                                                         then tt-movto.vl-bicms-it
                                                         else if tt-movto.cd-trib-icm = 4 then
                                                              (tt-movto.valor-mercad - tt-movto.vl-bicms-it)
                                                         else 0 
               tt-item-doc-est-nova.iss-outras         = 0
               tt-item-doc-est-nova.icm-ntrib          = if tt-movto.cd-trib-icm = 2     
                                                         then tt-movto.vl-bicms-it       
                                                         else 0 
               tt-item-doc-est-nova.iss-ntrib          = 0 
               tt-item-doc-est-nova.serie-docto        = tt-movto.serie
               tt-item-doc-est-nova.nro-docto          = tt-movto.nr-nota-fis
               tt-item-doc-est-nova.cod-emitente       = tt-movto.cod-emitente
               tt-item-doc-est-nova.nat-operacao       = tt-docum-est-nova.nat-operacao /* natureza da nota - chave */
               tt-item-doc-est-nova.nat-of             = tt-movto.nat-operacao /* natureza do item */
               tt-item-doc-est-nova.sequencia          = tt-movto.nr-sequencia
               tt-item-doc-est-nova.nr-proc-imp        = ""
               tt-item-doc-est-nova.nr-ato-concessorio = ""
               tt-item-doc-est-nova.val-perc-red-ipi   = 0
               tt-item-doc-est-nova.val-perc-red-icm   = tt-movto.perc-red-icms.

        assign tt-item-doc-est-nova.base-pis           = tt-movto.base-pis          
               tt-item-doc-est-nova.valor-pis          = tt-movto.valor-pis         
               tt-item-doc-est-nova.cd-trib-pis        = tt-movto.cd-trib-pis
               tt-item-doc-est-nova.aliquota-pis       = tt-movto.aliquota-pis      
               tt-item-doc-est-nova.base-cofins        = tt-movto.base-cofins       
               tt-item-doc-est-nova.valor-cofins       = tt-movto.valor-cofins      
               tt-item-doc-est-nova.cd-trib-cofins     = tt-movto.cd-trib-cofins    
               tt-item-doc-est-nova.aliquota-cofins    = tt-movto.aliquota-cofins.
               
        // KML - 01/03/2025 - Kleber Mazepa - Quando merco o dep¢sito e fixo no REC para depois vir movimento de estoque tirando do REC e colocando no dep¢sito EXP
         
        assign tt-docum-est-nova.valor-mercad          = tt-docum-est-nova.valor-mercad 
                                                       + tt-item-doc-est-nova.preco-total.
                                                       
        ASSIGN  OVERLAY(tt-docum-est-nova.char-1,154,2) =  "1".

        if tt-movto.ct-codigo <> "" then do:
            assign tt-item-doc-est-nova.ct-codigo = tt-movto.ct-codigo
                   tt-item-doc-est-nova.sc-codigo = tt-movto.sc-codigo.
        end.
        if last-of (tt-movto.nr-nota-fis) then do:
            FIND first docum-est of tt-docum-est-nova NO-LOCK NO-ERROR.
            if avail docum-est then return.

            do-trans:
            do transaction:
                run rep/reapi190b.p persistent set h-api.
                run execute in h-api (input  table tt-versao-integr,
                                      input  table tt-docum-est-nova,
                                      input  table tt-item-doc-est-nova,
                                      input  table tt-dupli-apagar,
                                      input  table tt-dupli-imp,
                                      input  table tt-unid-neg-nota,
                                      output table tt-erro).
                if valid-handle(h-api) then delete procedure h-api no-error.
                if can-find (first tt-erro) and
                   not can-find(tt-erro where tt-erro.cd-erro = 1878) then undo do-trans.
            end.
            find first tt-erro no-error.
            if avail tt-erro then do:
               put stream str-rp skip(1).
               for each tt-erro:
                   ASSIGN i-sit_reg = 1.
                   IF tt-erro.cd-erro = 1878 THEN DO:
                      ASSIGN i-sit_reg = 2.
                      for each bint_ds_docto_xml exclusive-lock where
                          Bint_ds_docto_xml.serie         = tt-movto.serie and
                          Bint_ds_docto_xml.nNF           = tt-movto.nNF   and
                          Bint_ds_docto_xml.cod_emitente  = tt-movto.cod-emitente:
                          assign bint_ds_docto_xml.sit_re    = 40
                                 bint_ds_docto_xml.situacao  = 3 /* processada */.
                          for first bint_ds_docto_wms exclusive-lock where 
                              rowid(bint_ds_docto_wms) = rowid(int_ds_docto_wms):
                              assign bint_ds_docto_wms.situacao = 40.
                          end.
                      end.
                   END.
                   RUN utp/ut-msgs.p (INPUT "msg",INPUT STRING(tt-erro.cd-erro),INPUT "").

                   IF tt-erro.cd-erro = 50  THEN
                       ASSIGN c-mensagem-erro = "Modalidade de frete est  diferente de 0, 1, 2 ou 9, dessa forma precisa-se ajustar essa modalidade no pedido do procfit".  
                   ELSE
                       ASSIGN c-mensagem-erro = RETURN-VALUE.

                   RUN pi-gera-log("Erro API. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                   " Srie: " + tt-movto.serie        +
                                   " NF: "  + tt-movto.nr-nota-fis  +
                                   " Natur. Oper.: " + c-nat-principal + 
                                   " Estab.: " + tt-movto.cod-estabel  + " - " +
                                   "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + c-mensagem-erro,
                                   i-sit_reg).
               end.
               return.
            end.
            for first docum-est of tt-docum-est-nova:
                assign docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                release docum-est.
            end.
            for first docum-est EXCLUSIVE-LOCK of tt-docum-est-nova:
            
                //ERA AQUI
            
                run pi-gera-int_ds_doc.

                FOR EACH item-doc-est OF docum-est:

                    RUN rep/reapi414.p PERSISTENT SET h-reapi414.

                    RUN setTipoNota IN h-reapi414 (INPUT 1). 
                    RUN setCodEstabel IN h-reapi414 (INPUT docum-est.cod-estabel).
                    RUN setCodNatOperacao IN h-reapi414 (INPUT IF item-doc-est.nat-of <> "" THEN item-doc-est.nat-of ELSE item-doc-est.nat-operacao).
                    RUN setNcm IN h-reapi414 (INPUT item-doc-est.class-fiscal).
                    RUN setItCodigo IN h-reapi414 (INPUT item-doc-est.it-codigo).
                    RUN setCodGrupEmit IN h-reapi414 (INPUT ems2mult.emitente.cod-gr-forn).
                    RUN setCodEmitente IN h-reapi414 (INPUT item-doc-est.cod-emitente).
                    RUN setDtEmissao IN h-reapi414 (INPUT docum-est.dt-emissao).

                    RUN calcCSTCD0303 IN h-reapi414.

                    RUN posicionarRegistros IN h-reapi414 (INPUT ROWID(item-doc-est)).

                    RUN calcCSTICMS IN h-reapi414.

                 //   RUN getCodOrigemItem IN h-reapi414 (OUTPUT c-cod-origem-item).
                    RUN getCodSitTribICMS IN h-reapi414 (OUTPUT c-cod-sit-tribut-icms).

                    RUN calcCSTIPI IN h-reapi414 (INPUT item-doc-est.cd-trib-ipi, INPUT item-doc-est.aliquota-ipi).

                    RUN getCodSitTribIPI IN h-reapi414 (OUTPUT c-cod-sit-tribut-ipi).

                    RUN getAliqPISCOFINSItDoc IN h-reapi414 (INPUT ROWID(item-doc-est), OUTPUT de-aliq-pis, OUTPUT de-aliq-cofins).
                    RUN calcCSTPIS IN h-reapi414 (INPUT item-doc-est.idi-tributac-pis, INPUT de-aliq-pis).
                    RUN calcCSTCOFINS IN h-reapi414 (INPUT item-doc-est.idi-tributac-cofins, INPUT de-aliq-cofins).
                    RUN getCodSitTribPIS IN h-reapi414 (OUTPUT c-cod-sit-tribut-pis).
                    RUN getCodSitTribCOFINS IN h-reapi414 (OUTPUT c-cod-sit-tribut-cofins).

                    DELETE PROCEDURE h-reapi414.

                    FIND FIRST item-doc-est-tribut NO-LOCK
                                WHERE item-doc-est-tribut.cod-serie-docto   = item-doc-est.serie-docto     
                                  AND item-doc-est-tribut.cod-num-docto     = item-doc-est.nro-docto   
                                  AND item-doc-est-tribut.cdn-emitente      = item-doc-est.cod-emitente   
                                  AND item-doc-est-tribut.cod-natur-operac  = item-doc-est.nat-operacao   
                                  AND item-doc-est-tribut.num-seq           = item-doc-est.sequencia
                                  AND item-doc-est-tribut.cod-campo         = 'CST' 
                                  AND item-doc-est-tribut.nom-trib          = "IPI" NO-ERROR.

                    IF NOT AVAIL item-doc-est-tribut THEN DO:

                        CREATE item-doc-est-tribut.
                        ASSIGN item-doc-est-tribut.cod-serie-docto  = item-doc-est.serie-docto 
                               item-doc-est-tribut.cod-num-docto    = item-doc-est.nro-docto   
                               item-doc-est-tribut.cdn-emitente     = item-doc-est.cod-emitente
                               item-doc-est-tribut.cod-natur-operac = item-doc-est.nat-operacao
                               item-doc-est-tribut.num-seq          = item-doc-est.sequencia   
                               item-doc-est-tribut.cod-campo        = "CST"
                               item-doc-est-tribut.nom-trib         = "IPI"
                               item-doc-est-tribut.cod-conteudo     = c-cod-sit-tribut-ipi.

                        FIND FIRST item-doc-est-tribut NO-LOCK
                            WHERE item-doc-est-tribut.cod-serie-docto   = item-doc-est.serie-docto     
                              AND item-doc-est-tribut.cod-num-docto     = item-doc-est.nro-docto   
                              AND item-doc-est-tribut.cdn-emitente      = item-doc-est.cod-emitente   
                              AND item-doc-est-tribut.cod-natur-operac  = item-doc-est.nat-operacao   
                              AND item-doc-est-tribut.num-seq           = item-doc-est.sequencia
                              AND item-doc-est-tribut.cod-campo         = 'CST' 
                              AND item-doc-est-tribut.nom-trib          = "PIS" NO-ERROR.

                        IF NOT AVAIL item-doc-est-tribut THEN DO:

                            CREATE item-doc-est-tribut.
                            ASSIGN item-doc-est-tribut.cod-serie-docto  = item-doc-est.serie-docto 
                                   item-doc-est-tribut.cod-num-docto    = item-doc-est.nro-docto   
                                   item-doc-est-tribut.cdn-emitente     = item-doc-est.cod-emitente
                                   item-doc-est-tribut.cod-natur-operac = item-doc-est.nat-operacao
                                   item-doc-est-tribut.num-seq          = item-doc-est.sequencia   
                                   item-doc-est-tribut.cod-campo        = "CST"
                                   item-doc-est-tribut.nom-trib         = "PIS"
                                   item-doc-est-tribut.cod-conteudo     = c-cod-sit-tribut-pis.

                        END.

                        FIND FIRST item-doc-est-tribut NO-LOCK
                            WHERE item-doc-est-tribut.cod-serie-docto   = item-doc-est.serie-docto     
                              AND item-doc-est-tribut.cod-num-docto     = item-doc-est.nro-docto   
                              AND item-doc-est-tribut.cdn-emitente      = item-doc-est.cod-emitente   
                              AND item-doc-est-tribut.cod-natur-operac  = item-doc-est.nat-operacao   
                              AND item-doc-est-tribut.num-seq           = item-doc-est.sequencia
                              AND item-doc-est-tribut.cod-campo         = 'CST' 
                              AND item-doc-est-tribut.nom-trib          = "COFINS" NO-ERROR.

                        IF NOT AVAIL item-doc-est-tribut THEN DO:

                            CREATE item-doc-est-tribut.
                            ASSIGN item-doc-est-tribut.cod-serie-docto  = item-doc-est.serie-docto 
                                   item-doc-est-tribut.cod-num-docto    = item-doc-est.nro-docto   
                                   item-doc-est-tribut.cdn-emitente     = item-doc-est.cod-emitente
                                   item-doc-est-tribut.cod-natur-operac = item-doc-est.nat-operacao
                                   item-doc-est-tribut.num-seq          = item-doc-est.sequencia   
                                   item-doc-est-tribut.cod-campo        = "CST"
                                   item-doc-est-tribut.nom-trib         = "COFINS"
                                   item-doc-est-tribut.cod-conteudo     = c-cod-sit-tribut-cofins.


                        END.

                        FIND FIRST item-doc-est-tribut NO-LOCK
                            WHERE item-doc-est-tribut.cod-serie-docto   = item-doc-est.serie-docto     
                              AND item-doc-est-tribut.cod-num-docto     = item-doc-est.nro-docto   
                              AND item-doc-est-tribut.cdn-emitente      = item-doc-est.cod-emitente   
                              AND item-doc-est-tribut.cod-natur-operac  = item-doc-est.nat-operacao   
                              AND item-doc-est-tribut.num-seq           = item-doc-est.sequencia
                              AND item-doc-est-tribut.cod-campo         = 'CST' 
                              AND item-doc-est-tribut.nom-trib          = "ICMS" NO-ERROR.

                        IF NOT AVAIL item-doc-est-tribut THEN DO:

                            CREATE item-doc-est-tribut.
                            ASSIGN item-doc-est-tribut.cod-serie-docto  = item-doc-est.serie-docto 
                                   item-doc-est-tribut.cod-num-docto    = item-doc-est.nro-docto   
                                   item-doc-est-tribut.cdn-emitente     = item-doc-est.cod-emitente
                                   item-doc-est-tribut.cod-natur-operac = item-doc-est.nat-operacao
                                   item-doc-est-tribut.num-seq          = item-doc-est.sequencia   
                                   item-doc-est-tribut.cod-campo        = "CST"
                                   item-doc-est-tribut.nom-trib         = "ICMS"
                                   item-doc-est-tribut.cod-conteudo     = c-cod-sit-tribut-icms.


                        END.

                    END.  

                END.
                    
                IF v_cdn_empres_usuar <> "10" THEN DO:
                
                    create tt-param-re1005.
                    assign 
                        tt-param-re1005.destino            = 3
                        tt-param-re1005.arquivo            = "int072-re1005.txt"
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

                    raw-transfer tt-param-re1005 to raw-param.
                    run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                    empty temp-table tt-digita-re1005.
                    empty temp-table tt-param-re1005.
                    
                END.
                
                
                
                for each bint_ds_docto_xml exclusive-lock where
                    Bint_ds_docto_xml.serie         = tt-movto.serie and
                    Bint_ds_docto_xml.nNF           = tt-movto.nNF   and
                    Bint_ds_docto_xml.cod_emitente  = tt-movto.cod-emitente:
                    assign  bint_ds_docto_xml.sit_re   = 40
                            bint_ds_docto_xml.situacao = 3 /* processada */.
                    for first bint_ds_docto_wms exclusive-lock where 
                        rowid(bint_ds_docto_wms) = rowid(int_ds_docto_wms):
                        assign bint_ds_docto_wms.situacao = bint_ds_docto_xml.sit_re.
                    end.
                end.
                
                //TESTE
                
                FIND FIRST ems2mult.estabelec NO-LOCK
                    WHERE estabelec.cod-estabel = docum-est.cod-estabel NO-ERROR.
                        
                IF AVAIL estabelec THEN
                DO:
                    MESSAGE "DENTRO DO IF ESTABELEC"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                    FIND FIRST ems2dis.cidade NO-LOCK                
                        WHERE cidade.cidade = ems2mult.estabelec.cidade
                        AND   cidade.pais   = ems2mult.estabelec.pais
                        AND   cidade.estado = ems2mult.estabelec.estado NO-ERROR.
                        
                        MESSAGE "TEM CIDADE" SKIP
                                 cidade.cidade
                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                        
                    IF AVAIL cidade THEN
                    DO:
                    
                        docum-est.tot-peso               = 1.000                            NO-ERROR.
                        OVERLAY(docum-est.char-2,151,2)  = "1"                              NO-ERROR.  //TIPO_CTE?.
                        OVERLAY(docum-est.char-2,211,2)  = docum-est.UF                     NO-ERROR.  //c-uf-origem.
                        OVERLAY(docum-est.char-2,236,10) = STRING(cidade.cdn-munpio-ibge)   NO-ERROR.  //cod-ibge-dest.
                        OVERLAY(docum-est.char-2,246,10) = "4105805"                        NO-ERROR.
                        OVERLAY(docum-est.cod-chave-aces-nf-eletro,21,2) = "57"             NO-ERROR. //"CHAVE"

                    END.
                    
                END.
                
                MESSAGE "KML -CHAVE "
                        //natur-oper.tipo-compra
                        SUBSTRING(docum-est.cod-chave-aces-nf-eletro,21,2)
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " Srie: " + tt-movto.serie        +
                                " NF: "  + tt-movto.nr-nota-fis  +
                                " Natur. Oper.: " + c-nat-principal + 
                                " Estab.: " + tt-movto.cod-estabel +
                                " - " + "Documento gerado com sucesso!",
                                2).
                
                 run pi-gera-log("OK",
                                2).

                release docum-est.
            end. /* docum-est */
            empty temp-table tt-docum-est-nova.
            empty temp-table tt-item-doc-est-nova.
            empty temp-table tt-dupli-apagar.
            empty temp-table tt-bo-docum-est.
            empty temp-table tt-bo-item-doc-est.
        end. /* last-of */
    end. /* tt-movto */
    empty temp-table tt-movto.
end procedure. /* PiGeraDocumento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.
    
    c-retorno = c-informacao.

/*     if avail tt-movto then do:                               */
/*         IF tt-param.arquivo <> "" THEN DO:                   */
/*             put stream str-rp unformatted                    */
/*                 tt-movto.CNPJ + "/" +                        */
/*                 trim(tt-movto.serie) + "/" +                 */
/*                 trim(string(tt-movto.nr-nota-fis)) + "/" +   */
/*                 trim(string(tt-movto.cfop)) + "/" +          */
/*                 trim(string(tt-movto.cod-estabel)) + " - " + */
/*                 c-informacao                                 */
/*                 skip.                                        */
/*         END.                                                 */

        /* INICIO - GravaÆo LOG Tabela para a PROCFIT */

        /* FIM    - GravaÆo LOG Tabela para a PROCFIT */


/*         RUN intprg/int999.p ("NFE",                                         */
/*                              tt-movto.CNPJ + "/" +                          */
/*                              trim(tt-movto.serie) + "/" +                   */
/*                              trim(string(tt-movto.nr-nota-fis)) + "/" +     */
/*                              trim(string(tt-movto.cfop)),                   */
/*                              c-informacao,                                  */
/*                              i-situacao, /* 1 - Pendente, 2 - Processado */ */
/*                              c-seg-usuario,                                 */
/*                              "INT072RP.P").                                 */
/*     end.                                                                    */
/*     else do:                                                                 */
/*         IF tt-param.arquivo <> "" THEN DO:                                   */
/*             put stream str-rp unformatted                                    */
/*                 int_ds_docto_xml.CNPJ + "/" +                                */
/*                 trim(string(int_ds_docto_xml.serie)) + "/" +                 */
/*                 trim(string(int(int_ds_docto_xml.nNF),">>>9999999")) + "/" + */
/*                 trim(string(int_ds_docto_xml.cfop)) + " - " +                */
/*                 c-informacao                                                 */
/*                 skip.                                                        */
/*         END.                                                                 */

        if i-situacao = 1 then do:
            l-erro = yes.
            
            run pi-gera-doc-erro(input 999999,
                                 input c-informacao,
                                 input i-situacao). 

        end.
    //END.

end.

procedure pi-gera-doc-erro:

    def input param p-cod-erro     like int_ds_doc_erro.cod_erro.
    def input param p-desc-erro    like int_ds_doc_erro.descricao.
    def input param p-situacao     as integer.

      
     FOR  FIRST int_ds_doc_erro NO-LOCK WHERE
                int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie  AND 
                int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente AND
                int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ  AND 
                int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF   AND 
                int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota  AND
                int_ds_doc_erro.descricao    = p-desc-erro 
         query-tuning(no-lookahead) : END.

     IF NOT AVAIL int_ds_doc_erro 
     THEN DO:
        CREATE int_ds_doc_erro.
        ASSIGN int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie       
               int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente
               int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ 
               int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF   
               int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota  
               int_ds_doc_erro.tipo_erro    = "RE1001"   
               int_ds_doc_erro.cod_erro     = p-cod-erro       
               int_ds_doc_erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
        IF AVAIL int_ds_it_docto_xml THEN 
           ASSIGN int_ds_doc_erro.sequencia = int_ds_it_docto_xml.sequencia.
    
     END.
     /*
     IF AVAIL int_ds_docto_xml THEN
        ASSIGN int_ds_docto_xml.situacao = p-situacao.
        
     if avail int_ds_it_docto_xml then 
          assign int_ds_it_docto_xml.situacao = p-situacao.
          */

END PROCEDURE.



procedure pi-gera-int_ds_doc:
    define BUFFER uf-origem for ems2mult.unid-feder.
    define buffer uf-destino for ems2mult.unid-feder.
    define variable de-icms-origem as decimal no-undo.
    define variable de-icms-destino as decimal no-undo.
    define variable i-ind as integer no-undo.

    FOR EACH int_ds_doc exclusive where
             int_ds_doc.serie_docto  = "" and
             int_ds_doc.nro_docto    = "" and
             int_ds_doc.cod_emitente = 0  and
             int_ds_doc.nat_operacao = "":
        DELETE int_ds_doc.
    END.

    for first int_ds_doc exclusive where
        int_ds_doc.serie_docto = docum-est.serie-docto and
        int_ds_doc.nro_docto = docum-est.nro-docto and
        int_ds_doc.cod_emitente = docum-est.cod-emitente and
        int_ds_doc.nat_operacao = docum-est.nat-operacao and
        int_ds_doc.tipo_nota = docum-est.tipo-nota: end.
    if not avail int_ds_doc then do:
        create int_ds_doc.
        buffer-copy docum-est except docum-est.cod-estabel to int_ds_doc
            assign  int_ds_doc.cod_estabel      = trim(docum-est.cod-estabel)
                    int_ds_doc.situacao         = 3 /* fiscal */
                    int_ds_doc.usuario          = c-seg-usuario
                    int_ds_doc.tipo_movto       = 1 /* inclusao */
                    int_ds_doc.sit_re           = 5 /* rec fiscal */

                    int_ds_doc.chnfe            = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                       substring(docum-est.char-1,93,60)
                                                  &else
                                                       docum-est.cod-chave-aces-nf-eletro
                                                  &endif
                    int_ds_doc.dt_geracao       = today
                    int_ds_doc.hr_geracao       = string(time,"HH:MM:SS")
                    int_ds_doc.situacao_int     = 1 /* pendente */
                    int_ds_doc.nen_chaveacesso  = trim(int_ds_doc.chnfe)
                    int_ds_doc.nen_serie_s      = trim(docum-est.serie-docto)
                    int_ds_doc.nen_notafiscal_n = int(docum-est.nro-docto)
                    int_ds_doc.nen_emissao_d    = docum-est.dt-emissao
                    int_ds_doc.nen_seguro_n     = docum-est.valor-seguro
                    int_ds_doc.nen_entrega_d    = docum-est.dt-trans
                    int_ds_doc.nen_acrescimo_n  = 0
                    int_ds_doc.nen_descontofinanceiro_n = 0.
    end.
    for first natur-oper fields (cod-cfop ind-it-icms) no-lock where 
        natur-oper.nat-operacao = docum-est.nat-operacao:
        assign int_ds_doc.nen_cfop_n = int(natur-oper.cod-cfop).
    end.
    for first ems2mult.estabelec fields (ep-codigo cgc estado pais) no-lock where 
        estabelec.cod-estabel = docum-est.cod-estabel:
        assign  int_ds_doc.ep_codigo = int(estabelec.ep-codigo)
                int_ds_doc.nen_destino_n = trim(estabelec.cgc)
                int_ds_doc.nen_entidadedestino_n = int_ds_doc.nen_destino_n.
    end.
    for FIRST ems2mult.emitente  no-lock where 
        emitente.cod-emitente = docum-est.cod-emitente:
        assign  int_ds_doc.nen_origem_n = trim(emitente.cgc).
                int_ds_doc.nen_entidadeorigem_n = int_ds_doc.nen_origem_n.
    end.

    de-icms-origem = 0.
    de-icms-destino = 0.
    if emitente.estado <> estabelec.estado then do:
        for first uf-origem no-lock where 
            uf-origem.pais = emitente.pais and
            uf-origem.estado = emitente.estado: 
            assign de-icms-origem = uf-origem.per-icms-ext.
            do i-ind = 1 to 12:
                if uf-origem.est-exc[i-ind] = estabelec.estado then 
                    assign de-icms-origem = uf-origem.PERC-exc[i-ind].
            end.
        end.
        for first uf-destino no-lock where 
            uf-destino.pais = estabelec.pais and
            uf-destino.estado = estabelec.estado: 
            assign de-icms-origem = UF-destino.per-icms-int.
        end.

    end.
    for each item-doc-est no-lock of docum-est:
        assign  int_ds_doc.nen_pedido_n = item-doc-est.num-pedido.
        assign  int_ds_doc.nen_valortotalprodutos_n     = int_ds_doc.nen_valortotalprodutos_n 
                                                        + item-doc-est.preco-total[1]
                int_ds_doc.nen_valortotalcontabil_n     = int_ds_doc.nen_valortotalcontabil_n 
                                                        + item-doc-est.preco-total[1]
                int_ds_doc.nen_valoripi_n               = int_ds_doc.nen_valoripi_n           
                                                        + item-doc-est.valor-ipi[1]
                int_ds_doc.nen_valoricms_n              = int_ds_doc.nen_valoricms_n          
                                                        + item-doc-est.valor-icm[1]
                int_ds_doc.nen_valorcalculadost_n       = int_ds_doc.nen_valorcalculadost_n   
                                                        + item-doc-est.vl-subs[1]
                int_ds_doc.nen_quantidadeproduto_n      = int_ds_doc.nen_quantidadeproduto_n  
                                                        + item-doc-est.quantidade
                int_ds_doc.nen_quantidadeitens_n        = int_ds_doc.nen_quantidadeitens_n + 1
                int_ds_doc.nen_pis_n                    = int_ds_doc.nen_pis_n  
                                                        + item-doc-est.valor-pis
                int_ds_doc.nen_icmsst_n                 = int_ds_doc.nen_icmsst_n             
                                                        + item-doc-est.vl-subs[1]
                int_ds_doc.nen_guiast_n                 = int_ds_doc.nen_guiast_n 
                                                        + item-doc-est.vl-subs[1]
                int_ds_doc.nen_frete_n                  = int_ds_doc.nen_frete_n              
                                                        + item-doc-est.valor-frete
                int_ds_doc.nen_despesas_n               = int_ds_doc.nen_despesas_n           
                                                        + item-doc-est.despesas[1]
                int_ds_doc.nen_desconto_n               = int_ds_doc.nen_desconto_n  
                                                        + item-doc-est.desconto[1]
                int_ds_doc.nen_cofins_n                 = int_ds_doc.nen_cofins_n             
                                                        + item-doc-est.val-cofins
                int_ds_doc.nen_basest_n                 = int_ds_doc.nen_basest_n             
                                                        + item-doc-est.base-subs[1]
                int_ds_doc.nen_basepis_n                = int_ds_doc.nen_basepis_n            
                                                        + item-doc-est.base-pis
                int_ds_doc.nen_baseisenta_n             = int_ds_doc.nen_baseisenta_n         
                                                        + item-doc-est.icm-ntrib[1]
                int_ds_doc.nen_baseicms_n               = int_ds_doc.nen_baseicms_n           
                                                        + item-doc-est.base-icm[1]
                int_ds_doc.nen_basediferido_n           = int_ds_doc.nen_basediferido_n       
                                                        + item-doc-est.icm-outras[1]
                int_ds_doc.nen_basecofins_n             = int_ds_doc.nen_basecofins_n         
                                                        + item-doc-est.base-pis
                int_ds_doc.nen_cfopsubstituicao_n       = if item-doc-est.vl-subs[1] > 0 
                                                          then int(natur-oper.cod-cfop) 
                                                          else int_ds_doc.nen_cfopsubstituicao_n.

        if de-icms-destino > de-icms-origem then do:
            assign int_ds_doc.nen_repasse_n             = int_ds_doc.nen_repasse_n
                                                        + ((de-icms-destino - de-icms-origem) / 100 * item-doc-est.base-icm[1]).
        end.

        FOR EACH int_ds_it_doc exclusive where
                 int_ds_it_doc.serie_docto  = "" and
                 int_ds_it_doc.nro_docto    = "" and
                 int_ds_it_doc.cod_emitente = 0  and
                 int_ds_it_doc.nat_operacao = "":
            DELETE int_ds_it_doc.
        END.

        for first int_ds_it_doc exclusive where
            int_ds_it_doc.serie_docto = docum-est.serie-docto and
            int_ds_it_doc.nro_docto = docum-est.nro-docto and
            int_ds_it_doc.cod_emitente = docum-est.cod-emitente and
            int_ds_it_doc.nat_operacao = docum-est.nat-operacao and
            int_ds_it_doc.tipo_nota = docum-est.tipo-nota and
            int_ds_it_doc.sequencia = item-doc-est.sequencia: end.
        if not avail int_ds_it_doc then do:
            create  int_ds_it_doc.
            buffer-copy item-doc-est to int_ds_it_doc.
        end.
        assign  int_ds_it_doc.nep_valorunitario_n       = item-doc-est.preco-unit[1]
                int_ds_it_doc.nep_valorpis_n            = item-doc-est.valor-pis
                int_ds_it_doc.nep_valorliquido_n        = item-doc-est.preco-total[1]
                int_ds_it_doc.nep_valoripi_n            = item-doc-est.valor-ipi[1]
                int_ds_it_doc.nep_valoricms_n           = item-doc-est.valor-icm[1]
                int_ds_it_doc.nep_valoricmsst_n         = item-doc-est.vl-subs[1]
                int_ds_it_doc.nep_valordespesas_n       = item-doc-est.despesas[1]
                int_ds_it_doc.nep_valordesconto_n       = item-doc-est.desconto[1]
                int_ds_it_doc.nep_valorcofins_n         = item-doc-est.val-cofins
                int_ds_it_doc.nep_sequencia_n           = item-doc-est.sequencia
                int_ds_it_doc.nep_quantidade_n          = item-doc-est.quantidade
                int_ds_it_doc.nep_produto_n             = int(item-doc-est.it-codigo)
                int_ds_it_doc.nep_percentualreducao_n   = item-doc-est.val-perc-red-icms
                int_ds_it_doc.nep_percentualipi_n       = item-doc-est.val-perc-rep-ipi
                int_ds_it_doc.nep_percentualicms_n      = item-doc-est.aliquota-icm
                int_ds_it_doc.nep_percentualicmsst_n    = (item-doc-est.vl-subs[1] / item-doc-est.base-subs[1]) * 100
                int_ds_it_doc.nep_lote_s                = item-doc-est.lote
                int_ds_it_doc.nep_cfop_n                = int(natur-oper.cod-cfop)
                int_ds_it_doc.nep_basest_n              = item-doc-est.base-subs[1]
                int_ds_it_doc.nep_basepis_n             = item-doc-est.base-pis
                int_ds_it_doc.nep_baseisenta_n          = item-doc-est.icm-ntrib[1]
                int_ds_it_doc.nep_baseipi_n             = item-doc-est.base-ipi[1]
                int_ds_it_doc.nep_baseicms_n            = item-doc-est.base-icm[1]
                int_ds_it_doc.nep_basediferido_n        = item-doc-est.icm-outras[1]
                int_ds_it_doc.nep_basecofins_n          = item-doc-est.base-pis
                int_ds_it_doc.nen_serie_s               = trim(item-doc-est.serie-docto)
                int_ds_it_doc.nen_origem_n              = trim(emitente.cgc)
                int_ds_it_doc.nen_notafiscal_n          = int(item-doc-est.nro-docto)
                int_ds_it_doc.nen_cfop_n                = int_ds_it_doc.nep_cfop_n.


        if item-doc-est.cd-trib-icm = 1 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int_ds_it_doc.nep_csta_n = 0.
                else int_ds_it_doc.nep_csta_n = 1.
        end.
        if item-doc-est.cd-trib-icm = 2 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int_ds_it_doc.nep_csta_n = 4.
                else int_ds_it_doc.nep_csta_n = 3.
        end.
        if item-doc-est.cd-trib-icm = 3 then do:
            int_ds_it_doc.nep_csta_n = 90.
        end.
        if item-doc-est.cd-trib-icm = 4 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int_ds_it_doc.nep_csta_n = 2.
                else int_ds_it_doc.nep_csta_n = 7.
        end.
        if item-doc-est.cd-trib-icm = 5 then do:
            int_ds_it_doc.nep_csta_n = 5.
        end.
        if natur-oper.ind-it-icms then do:
            int_ds_it_doc.nep_csta_n = 6.
        end.
    end.
end.

procedure pi-trata-guia-st:


    /*
    def var de-base-subs            like item-doc-est.base-subs   extent 0.
    def var de-vl-subs              like item-doc-est.vl-subs     extent 0.

    assign de-base-subs        = 0
           de-vl-subs          = 0.
    run pi-gera-tt-docto.                  
    run pi-gera-tt-it-doc.              

    find first tt-docto no-error.
    /* CALCULO DE ICMS, SUBST.TRIBUTARIA e ICMS COMPLEMENTAR */
    run rep/re1906.p ( tt-docto.seq-tt-docto,
                       yes,                              /* ICMS */
                       yes,                              /* Subst. Tributaria */
                       yes,                              /* ICMS Complementar */
                       input        table tt-docto,
                       input        table tt-it-docto,
                       input-output table tt-it-imposto).

    for each tt-it-docto fields (seq-tt-it-docto nr-sequencia)
        where tt-it-docto.cod-estabel  = tt-docum-est-nova.cod-estabel
          and tt-it-docto.serie        = tt-docum-est-nova.serie-docto
          and tt-it-docto.nr-nota      = tt-docum-est-nova.nro-docto
          and tt-it-docto.cod-emitente = tt-docum-est-nova.cod-emitente
          and tt-it-docto.nat-operacao = tt-docum-est-nova.nat-operacao  exclusive-lock:

        find tt-it-imposto
            where tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
            exclusive-lock no-error.

        for first tt-item-doc-est-nova where
            tt-item-doc-est-nova.serie-docto   = tt-it-docto.serie        and
            tt-item-doc-est-nova.nro-docto     = tt-it-docto.nr-nota      and
            tt-item-doc-est-nova.cod-emitente  = tt-it-docto.cod-emitente and
            tt-item-doc-est-nova.nat-operacao  = tt-it-docto.nat-operacao and 
            tt-item-doc-est-nova.sequencia     = tt-it-docto.nr-sequencia:
            assign tt-item-doc-est-nova.base-subs     = tt-it-imposto.vl-bsubs-it
                   tt-item-doc-est-nova.valor-subs    = tt-it-imposto.vl-icmsub-it.
            assign de-base-subs  = de-base-subs + tt-item-doc-est-nova.base-subs
                   de-vl-subs    = de-vl-subs   + tt-item-doc-est-nova.valor-subs.
        end.
    end.

    for each tt-item-doc-est-nova where
        tt-item-doc-est-nova.serie-docto   = tt-docum-est-nova.serie-docto  and
        tt-item-doc-est-nova.nro-docto     = tt-docum-est-nova.nro-docto    and
        tt-item-doc-est-nova.cod-emitente  = tt-docum-est-nova.cod-emitente and
        tt-item-doc-est-nova.nat-operacao  = tt-docum-est-nova.nat-operacao:
        assign de-base-subs  = de-base-subs + tt-item-doc-est-nova.base-subs
               de-vl-subs    = de-vl-subs   + tt-item-doc-est-nova.valor-subs.
    end.
    */

end.
/*
procedure pi-gera-tt-docto:

    def var i-seq-docto     as integer  no-undo.

    find last tt-docto use-index seq no-lock no-error.
    assign i-seq-docto = if avail tt-docto then tt-docto.seq-tt-docto + 1
                         else 1.

    create tt-docto.
    assign tt-docto.seq-tt-docto    = i-seq-docto
           tt-docto.cod-estabel     = tt-docum-est-nova.cod-estabel
           tt-docto.serie           = tt-docum-est-nova.serie-docto
           tt-docto.nr-nota         = tt-docum-est-nova.nro-docto
           tt-docto.cod-emitente    = tt-docum-est-nova.cod-emitente
           tt-docto.nat-operacao    = tt-docum-est-nova.nat-operacao  
           tt-docto.dt-emis-nota    = tt-docum-est-nova.dt-trans
           tt-docto.dt-trans        = tt-docum-est-nova.dt-emissao
           tt-docto.nome-abrev      = emitente.nome-abrev
           tt-docto.usuario         = param-re.usuario  
           tt-docto.inc-seq         = param-re.inc-seq
           tt-docto.seq-item-um     = param-re.seq-item-um.

    for first estabelec NO-LOCK WHERE estabelec.cod-estabel = tt-docum-est-nova.cod-estabel:
        assign tt-docto.estado          = estabelec.estado
               tt-docto.cidade          = estabelec.cidade
               tt-docto.pais            = estabelec.pais.
    end.
    for first natur-oper fields (consum-final cod-mensagem tipo tp-oper-terc)
        no-lock where 
        natur-oper.nat-operacao = tt-docum-est-nova.nat-operacao: end.

    assign tt-docto.cod-des-merc    = if natur-oper.consum-final then 2 else 1
           tt-docto.esp-docto       = tt-docum-est-nova.esp-docto
           tt-docto.cod-msg         = natur-oper.cod-mensagem
           tt-docto.cod-portador    = 0
           tt-docto.modalidade      = 0
           tt-docto.ind-lib-nota    = yes
           tt-docto.ind-tip-nota    = 8
           tt-docto.vl-mercad       = tt-docum-est-nova.valor-mercad  
           tt-docto.vl-frete        = tt-docum-est-nova.valor-frete
           tt-docto.vl-seguro       = tt-docum-est-nova.valor-seguro
           tt-docto.vl-embalagem    = tt-docum-est-nova.valor-embal
           tt-docto.vl-outras       = tt-docum-est-nova.valor-outras
           tt-docto.perc-desco1     = if  tt-docum-est-nova.tot-desconto <> 0 then 1 else 0.

    if  tt-docum-est-nova.cod-observa = 3        /* Devolucao de Cliente */ 
    or (    avail natur-oper             
        and natur-oper.tipo = 1
        and natur-oper.tp-oper-terc = 5) /*Devolucao de Consignacao */ then

        assign tt-docto.estado = emitente.estado
               tt-docto.cidade = emitente.cidade
               tt-docto.pais   = emitente.pais.
end.

procedure pi-gera-tt-it-doc:

    def var de-qtd-aux  like item-doc-est.quantidade no-undo.
    def var i-seq-aux   as   integer                 no-undo.

    find last tt-it-docto use-index seq no-lock no-error.

    assign i-seq-aux = if  avail tt-it-docto 
                       then tt-it-docto.seq-tt-it-docto + 1
                       else 1. 

    for each tt-item-doc-est-nova no-lock where
        tt-item-doc-est-nova.serie-docto   = tt-docum-est-nova.serie-docto  and
        tt-item-doc-est-nova.nro-docto     = tt-docum-est-nova.nro-docto    and
        tt-item-doc-est-nova.cod-emitente  = tt-docum-est-nova.cod-emitente and
        tt-item-doc-est-nova.nat-operacao  = tt-docum-est-nova.nat-operacao:

        assign de-qtd-aux = if  tt-item-doc-est-nova.qt-do-forn <> 0 then 
                                tt-item-doc-est-nova.qt-do-forn
                            else 1.

        create tt-it-docto.
        assign tt-it-docto.seq-tt-it-docto = i-seq-aux
               tt-it-docto.cod-emitente   = tt-docto.cod-emitente
               tt-it-docto.nr-nota        = tt-docto.nr-nota
               tt-it-docto.serie          = tt-docto.serie
               tt-it-docto.cod-estabel    = tt-docto.cod-estabel
               tt-it-docto.nat-operacao   = tt-docto.nat-operacao
               tt-it-docto.calcula        = yes
               tt-it-docto.alterado       = yes
               i-seq-aux                  = i-seq-aux + 1.

        if (natur-oper.terceiro and (natur-oper.tp-oper-terc = 2 or natur-oper.tp-oper-terc = 5)) or 
            natur-oper.tipo-compra = 3 then 
            assign de-qtd-aux = if tt-item-doc-est-nova.quantidade <> 0 
                                then tt-item-doc-est-nova.quantidade
                                else 1.

        assign tt-it-docto.nr-sequencia   = tt-item-doc-est-nova.sequencia
               tt-it-docto.quantidade[1]  = tt-item-doc-est-nova.quantidade
               tt-it-docto.quantidade[2]  = tt-item-doc-est-nova.qt-do-forn

               /* Valor do Frete a Nivel de Item - Utilizado para Calculo Imposto */   
               tt-it-docto.vl-frete       = 0
               tt-it-docto.vl-despes-it   = tt-item-doc-est-nova.despesas
               tt-it-docto.vl-embalagem   = tt-item-doc-est-nova.despesas
                                          - tt-it-docto.vl-frete
               tt-it-docto.peso-liq-it    = tt-item-doc-est-nova.peso-liquido
               tt-it-docto.baixa-estoq    = tt-item-doc-est-nova.baixa-ce
               tt-it-docto.calcula        = yes
               tt-it-docto.alterado       = no
               tt-it-docto.vl-cotacao[1]  = 1
               tt-it-docto.vl-cotacao[2]  = 1
               tt-it-docto.vl-unit-mob    = 0
               tt-it-docto.un[2]          = tt-item-doc-est-nova.un
               tt-it-docto.nat-of         = tt-item-doc-est-nova.nat-of. /* Natureza fiscal do item... */

        for first item no-lock where 
            item.it-codigo = tt-item-doc-est-nova.it-codigo: end.

        for first ordem-compra no-lock where 
            ordem-compra.numero-ordem = tt-item-doc-est-nova.numero-ordem: end.

        if  avail item 
            and item.tipo-contr = 4
            and avail ordem-compra  then do:

                for first prazo-compra no-lock
                    where prazo-compra.numero-ordem = ordem-compra.numero-ordem 
                      and prazo-compra.parcela      = tt-item-doc-est-nova.parcela: end.
                if not avail prazo-compra then
                    for first prazo-compra no-lock where 
                    prazo-compra.numero-ordem = ordem-compra.numero-ordem: end.

                assign tt-it-docto.un[1] = if avail prazo-compra then prazo-compra.un 
                                           else if avail item  then item.un else "".
        end.
        else
            assign tt-it-docto.un[1] = if avail item then item.un else "".

        assign tt-it-docto.it-codigo      = tt-item-doc-est-nova.it-codigo
               tt-it-docto.class-fiscal   = tt-item-doc-est-nova.class-fiscal
               tt-it-docto.data-comp      = tt-item-doc-est-nova.data-comp
               tt-it-docto.num-pedido     = tt-item-doc-est-nova.num-pedido
               tt-it-docto.numero-ordem   = tt-item-doc-est-nova.numero-ordem
               tt-it-docto.parcela        = tt-item-doc-est-nova.parcela
               tt-it-docto.cod-refer      = tt-item-doc-est-nova.cod-refer.

        assign tt-it-docto.desconto       = tt-item-doc-est-nova.desconto
               tt-it-docto.per-des-item   = int(tt-it-docto.desconto > 0)
               tt-it-docto.vl-preuni      = (tt-item-doc-est-nova.preco-total
                                          -  tt-item-doc-est-nova.desconto)
                                          /  de-qtd-aux
               tt-it-docto.vl-preori      = tt-item-doc-est-nova.preco-total
                                          / de-qtd-aux

               tt-it-docto.vl-merc-liq    = (tt-item-doc-est-nova.preco-total
                                          -  tt-item-doc-est-nova.desconto)
               tt-it-docto.calcula        = yes
               tt-it-docto.vl-merc-ori    = tt-item-doc-est-nova.preco-total
               tt-it-docto.vl-merc-tab    = tt-it-docto.vl-merc-ori
               tt-it-docto.vl-pretab      = tt-it-docto.vl-preori.

        create tt-it-imposto.
        assign tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto

               tt-it-imposto.ind-icm-ret     = /*tt-item-doc-est-nova.log-2*/ yes
               tt-it-imposto.cd-trib-icm     = tt-item-doc-est-nova.cd-trib-icm
               tt-it-imposto.aliquota-icm    = tt-item-doc-est-nova.aliquota-icm

               tt-it-imposto.vl-bicms-it     = tt-item-doc-est-nova.base-icm
               tt-it-imposto.vl-icms-it      = tt-item-doc-est-nova.valor-icm
               tt-it-imposto.vl-icmsnt-it    = tt-item-doc-est-nova.icm-ntrib
               tt-it-imposto.vl-icmsou-it    = tt-item-doc-est-nova.icm-outras

               tt-it-imposto.vl-bsubs-it     = tt-item-doc-est-nova.base-subs
               tt-it-imposto.vl-icmsub-it    = tt-item-doc-est-nova.valor-subs
               tt-it-imposto.icm-complem     = tt-item-doc-est-nova.icm-complem
               tt-it-imposto.perc-red-icm    = tt-item-doc-est-nova.val-perc-red-icm
            
               
               tt-it-imposto.aliquota-ipi    = tt-item-doc-est-nova.aliquota-ipi    
               tt-it-imposto.cd-trib-ipi     = tt-item-doc-est-nova.cd-trib-ipi     
               tt-it-imposto.perc-red-ipi    = tt-item-doc-est-nova.val-perc-red-ipi    
               tt-it-imposto.vl-ipi-it       = tt-item-doc-est-nova.valor-ipi
               tt-it-imposto.vl-bipi-it      = tt-item-doc-est-nova.base-ipi
               tt-it-imposto.vl-ipint-it     = tt-item-doc-est-nova.ipi-nt
               tt-it-imposto.vl-ipiou-it     = tt-item-doc-est-nova.ipi-ou.

    end.
end.

*/
