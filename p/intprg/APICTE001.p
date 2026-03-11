MESSAGE "ENTROU MEU PROGRAMA"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.


/********************************************************************************
** Programa: INT112 - Importaá∆o de Notas de Entrada do VNDA
**
** Versao : 1 - 15/06/2024 - Kleber Mazepa
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i int112rp 1.00.01.KML}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* definiá∆o das temp-tables para recebimento de parÉmetros */
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
    field lote         LIKE rat-lote.lote
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
    field nen_cnpj_origem_s like int_ds_nota_entrada.nen_cnpj_origem_s
    field nen_cfop_n        like int_ds_nota_entrada.nen_cfop_n
    field numero-ordem      like item-doc-est.numero-ordem
    field parcela           like item-doc-est.parcela
    field num-pedido        like item-doc-est.num-pedido
    field tp-despesa        like dupli-apagar.tp-despesa
    field tipo_nota         like int_ds_nota_entrada.tipo_nota
    field dt-trans          like int_ds_nota_entrada.nen_datamovimentacao_d
    field perc-red-icms     like int_ds_nota_entrada_produt.nep_redutorbaseicms_n
    field vl-icms-des       like int_ds_nota_entrada_produt.nep_valor_icms_des_n
    field cod-cond-pag      like emitente.cod-cond-pag
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
    field class-fiscal      like item.class-fiscal.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cnpj_origem      as CHAR
    field nro-docto        as INT
    field serie-docto      as char.

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

/* recebimento de parÉmetros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 
DEF OUTPUT PARAMETER c-retorno AS CHAR NO-UNDO.


define buffer bestabelec for estabelec.
DEFINE BUFFER bitem-doc-est FOR item-doc-est.


DEFINE VARIABLE h-reapi414 AS HANDLE      NO-UNDO.

DEFINE VARIABLE c-cod-sit-tribut-icms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-ipi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-pis    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-cofins AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-aliq-pis             AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins          AS DECIMAL     NO-UNDO.


create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 

/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
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
def var i-sit-reg as int no-undo.
def var de-total-bruto as decimal decimals 5 no-undo.
def var de-total-descto as decimal decimals 5 no-undo.
def var d-data-movimento as date no-undo.
def var d-data-procfit as date no-undo.
DEF VAR de-tot-desp-nf AS decimal decimals 5 no-undo.
DEF VAR nome_transp    AS CHAR NO-UNDO.
DEF VAR c-item         AS CHAR NO-UNDO.

def buffer bint_ds_nota_entrada for int_ds_nota_entrada.
define buffer btt-movto for tt-movto.

def var de-tot-despesas as decimal decimals 4 no-undo.
/* definiá∆o de frames do relat¢rio */

for first param-re no-lock where param-re.usuario = c-seg-usuario
    query-tuning(no-lookahead): end.
if not avail param-re then do:
    return "NOK".
end.

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i /*&stream = "stream str-rp"*/}
END.

assign c-programa     = "int112"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Documento Recebimento".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock
    query-tuning(no-lookahead): end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin
    query-tuning(no-lookahead): end.
assign c-empresa = mgadm.empresa.razao-social.

/******* LE NOTA E GERA TEMP TABLES  *************/
DEFINE VARIABLE cont-registros AS INTEGER     NO-UNDO.

for-nota:
for each int_ds_nota_entrada no-lock where
    int_ds_nota_entrada.situacao >= 1 AND
    int_ds_nota_entrada.nen_conferida_n < 2 AND 
    int_ds_nota_entrada.nen_serie_s         = tt-param.serie-docto AND
    int_ds_nota_entrada.nen_notafiscal_n    = tt-param.nro-docto AND
    int_ds_nota_entrada.nen_cnpj_origem_s   = tt-param.cnpj_origem AND 
    int_ds_nota_entrada.tipo_nota = 1,
    FIRST bestabelec no-lock where
        int_ds_nota_entrada.nen_cnpj_destino_s = bestabelec.cgc :
        
     
    log-manager:write-message("KML 1 - APITEC001 - ANTES CRIAR - ") NO-ERROR.

    FIND first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = bestabelec.cod-estabel and
        cst_estabelec.dt_inicio_oper <> ? NO-ERROR.
        
    if not avail cst_estabelec then next.
    
    log-manager:write-message("KML 2 - APITEC001 - ANTES CRIAR - ") NO-ERROR.

    /* notas de balanáo ou impostos */
    if int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_destino_s then DO:
    
        run pi-gera-log (input "Nota fiscal de balanáo nao pode ser gerada por essa chamada: " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s)
                         + " Emiss∆o: " + string(int_ds_nota_entrada.nen_dataemissao_d,"99/99/9999") + " Movto: " + string(d-data-movimento, "99/99/9999"),
                         input 1).
    
    END.

    assign d-data-movimento = TODAY.

    if d-data-movimento < int_ds_nota_entrada.nen_dataemissao_d then do:
        run pi-gera-log (input "Data de movimentaá∆o menor que a data de emiss∆o da nota." + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s)
                         + " Emiss∆o: " + string(int_ds_nota_entrada.nen_dataemissao_d,"99/99/9999") + " Movto: " + string(d-data-movimento, "99/99/9999"),
                         input 1).
 
       
    end.

    assign de-tot-despesas = 0
           c-nat-principal = "".

    assign l-erro = no.
    empty temp-table tt-movto.

    for first emitente fields (cod-emitente estado tp-desp-padrao cod-cond-pag) no-lock where 
        emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s,
        first dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1: end.
    if not avail emitente then do:
        run pi-gera-log (input "Fornecedor n∆o cadastrado ou inativo. CNPJ: " + string(int_ds_nota_entrada.nen_cnpj_origem_s),
                         input 1).
        empty temp-table tt-movto.
        
    end.


    c-cod-estabel  = "".
    d-data-procfit = ?.
    for each estabelec fields (cod-estabel estado cidade cep pais endereco bairro ep-codigo)  no-lock 
        WHERE estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s,
        first cst_estabelec no-lock 
            WHERE cst_estabelec.cod_estabel = estabelec.cod-estabel 
              AND cst_estabelec.dt_fim_operacao >= int_ds_nota_entrada.nen_dataemissao_d:
              
        c-cod-estabel = estabelec.cod-estabel.
        d-data-procfit   = cst_estabelec.dt_inicio_oper.
        leave.
    end.
    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int_ds_nota_entrada.nen_cnpj_destino_s,
                         input 1).
        empty temp-table tt-movto.
        
    end.
    
    log-manager:write-message("KML 3 - APITEC001 - ANTES CRIAR - ") NO-ERROR.

    for first docum-est no-lock where 
        docum-est.serie-docto  = int_ds_nota_entrada.nen_serie_s and
        docum-est.nro-docto    = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) and
        docum-est.cod-emitente = emitente.cod-emitente:
        
        assign de-qt-enviada = 0.
/*         for each int_ds_nota_entrada_produt no-lock where                                            */
/*             int_ds_nota_entrada_produt.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s and */
/*             int_ds_nota_entrada_produt.nen_serie_s       = int_ds_nota_entrada.nen_serie_s       and */
/*             int_ds_nota_entrada_produt.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n:     */
/*                                                                                                      */
/*             assign de-qt-enviada = de-qt-enviada + int_ds_nota_entrada_produt.nep_quantidade_n.      */
/*         end.                                                                                         */
        assign de-qt-importada = 0.
        for each item-doc-est no-lock of docum-est:
            assign de-qt-importada = de-qt-importada + item-doc-est.quantidade.
        end.
        if de-qt-enviada = de-qt-importada then do:
            run pi-gera-log (input "Documento j† cadastrado: " 
                             + "SÇrie: "     + docum-est.serie-docto 
                             + " Numero: "   + docum-est.nro-docto   
                             + " Forn: "     + string(docum-est.cod-emitente)
                             + " Natureza: " + docum-est.nat-operacao,
                             input 2).
            for each bint_ds_nota_entrada where
                bint_ds_nota_entrada.nen_cnpj_origem_s  = int_ds_nota_entrada.nen_cnpj_origem_s and
                bint_ds_nota_entrada.nen_serie_s        = int_ds_nota_entrada.nen_serie_s       and
                bint_ds_nota_entrada.nen_notafiscal_n   = int_ds_nota_entrada.nen_notafiscal_n:

                assign  bint_ds_nota_entrada.nen_conferida_n = 2 /* conferida */
                        bint_ds_nota_entrada.situacao        = 2 /* processada */
                        bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.

                release bint_ds_nota_entrada.

            end.
            empty temp-table tt-movto.
            assign l-erro = yes.
            NEXT .
        end.
        else do:
            run pi-gera-log (input "Documento j† cadastrado com DIFERENÄA de QUANTIDADE " 
                             + "SÇrie: "     + docum-est.serie-docto 
                             + " Numero: "   + docum-est.nro-docto   
                             + " Forn: "     + string(docum-est.cod-emitente)
                             + " Natureza: " + docum-est.nat-operacao
                             + " Qtde Docum: " + string(de-qt-importada)
                             + " Qtde Enviada:" + string(de-qt-enviada),
                             input 1).
            empty temp-table tt-movto.
            assign l-erro = yes.
            NEXT .
        end.
    end.

    for first param-estoq NO-LOCK: 
        if param-estoq.ult-fech-dia >= d-data-movimento or
           param-estoq.mensal-ate >= d-data-movimento then do:

            run pi-gera-log (input "Documento em per°odo fechado. Liberando atualizaá∆o manual. " 
                             + "SÇrie: "     + int_ds_nota_entrada.nen_serie_s
                             + " Numero: "   + string(int_ds_nota_entrada.nen_notafiscal_n)
                             + " Forn: "     + string(emitente.cod-emitente)
                             + " Data: "     + string(d-data-movimento,"99/99/9999"),
                             input 1).
            for first bint_ds_nota_entrada exclusive where 
                rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada)
                query-tuning(no-lookahead):
                assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */
                       bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                NEXT .
            end.
            empty temp-table tt-movto.
            assign l-erro = yes.
            NEXT .
        end.
    end.

    if not can-find (first usuar_financ_estab_apb no-lock where 
                           usuar_financ_estab_apb.cod_estab = c-cod-estabel and
                           usuar_financ_estab_apb.cod_usuario = c-seg-usuario) then do:
        
        run pi-gera-log (input "Usu†rio Financeiro n∆o cadastrado para estabelecimento " + c-cod-estabel
                         + "SÇrie: "     + trim(int_ds_nota_entrada.nen_serie_s)
                         + " Numero: "   + trim(string(int_ds_nota_entrada.nen_notafiscal_n))
                         + " Forn: "     + string(emitente.cod-emitente)
                         + " Data: "     + string(d-data-movimento,"99/99/9999"),
                         input 1).
        empty temp-table tt-movto.
        next .
    end.


    if  int_ds_nota_entrada.nen_modalidade_frete_n <> 0 /* Emitente */ and
        int_ds_nota_entrada.nen_modalidade_frete_n <> 1 /* Destinat†rio/Remetente */ and
        int_ds_nota_entrada.nen_modalidade_frete_n <> 2 /* Terceiros */ and
        int_ds_nota_entrada.nen_modalidade_frete_n <> 9 /* Sem Frete */ then do:
        for first bint_ds_nota_entrada exclusive where 
            rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada)
            query-tuning(no-lookahead):
            if  int_ds_nota_entrada.nen_modalidade_frete_n = 3 or
                int_ds_nota_entrada.nen_modalidade_frete_n = 4 then do:
                assign bint_ds_nota_entrada.nen_modalidade_frete_n = 1 /* Chamado 0718-004169 - AVB 25/07/2018 */.
            end.
            else do:
                assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */
                       bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                NEXT .
            end.
            release bint_ds_nota_entrada.
        end.
        /*find current int_ds_nota_entrada no-lock no-error.*/
    end.

    de-total-bruto = 0.
    de-total-descto = 0.
    de-tot-desp-nf = 0.
    //for each int_ds_nota_entrada_produt no-lock of int_ds_nota_entrada:
    
        log-manager:write-message("KML - int112-ecom - ANTES CRIAR TT-MOVTO - " + c-retorno ) NO-ERROR.

        create tt-movto.
        assign tt-movto.serie               = int_ds_nota_entrada.nen_serie_s
               tt-movto.nr-nota-fis         = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999"))
               tt-movto.dt-emissao          = int_ds_nota_entrada.nen_dataemissao_d
               tt-movto.tot-frete           = int_ds_nota_entrada.nen_frete_n
               tt-movto.tot-seguro          = int_ds_nota_entrada.nen_seguro_n                                  
               tt-movto.tot-despesas        = int_ds_nota_entrada.nen_despesas_n /*- int_ds_nota_entrada.nen_frete_n*/
               tt-movto.tot-desconto        = int_ds_nota_entrada.nen_desconto_n
               tt-movto.chave-acesso        = int_ds_nota_entrada.nen_chaveacesso_s
               tt-movto.mod-frete           = int_ds_nota_entrada.nen_modalidade_frete_n
               tt-movto.nen_cnpj_origem_s   = int_ds_nota_entrada.nen_cnpj_origem_s
               tt-movto.nen_cfop_n          = int_ds_nota_entrada.nen_cfop_n
               tt-movto.tp-despesa          = emitente.tp-desp-padrao
               tt-movto.cod-estabel         = c-cod-estabel
               tt-movto.cod-emitente        = emitente.cod-emitente
               tt-movto.uf                  = emitente.estado
               tt-movto.tipo_nota           = int_ds_nota_entrada.tipo_nota
               tt-movto.dt-trans            = d-data-movimento
               //tt-movto.perc-red-icms       = int_ds_nota_entrada_produt.nep_redutorbaseicms_n
               //tt-movto.vl-icms-des         = int_ds_nota_entrada_produt.nep_valor_icms_des_n
               //tt-movto.cod-cond-pag        = emitente.cod-cond-pag
               de-tot-desp-nf               = int_ds_nota_entrada.nen_despesas_n + int_ds_nota_entrada.nen_frete_n.

        if  tt-movto.cod-emitente = 1000 or
            tt-movto.cod-emitente = 5000 or
            tt-movto.cod-emitente = 9574 then do:
            if  day(tt-movto.dt-emissao) >= 1 and 
                day(tt-movto.dt-emissao) <= 7 then tt-movto.cod-cond-pag = 259.
            else tt-movto.cod-cond-pag = 241.
        end.
        
           
        IF estabelec.estado <> emitente.estado THEN
        DO:
            FOR EACH esp-integracao-cte NO-LOCK:

            ASSIGN c-item = item-fora
                   c-nat-operacao = nat-operacao-fora.

            END.
        END.

        ELSE DO:

            FOR EACH esp-integracao-cte NO-LOCK:

            ASSIGN c-item = item-dentro
                   c-nat-operacao = nat-operacao-dentro.

            END.

        END.
           
        FIND first ITEM no-lock 
        WHERE item.it-codigo = c-item NO-ERROR.


        log-manager:write-message("KML - int112-ecom -SEGUNDO FIND NO ITEM- " + c-retorno ) NO-ERROR.

        IF AVAIL ITEM  THEN
        DO:
            if item.tipo-contr = 1 /* Fisico */ or item.tipo-contr = 4 /* DB Dir */ then do:
                if item.ct-codigo = "" then do:
                    run pi-gera-log (input "Item sem conta aplicacao: " + ITEM.it-codigo ,
                                     input 1).
                                      next.
                end.
                else do:
                    assign tt-movto.ct-codigo = item.ct-codigo
                    tt-movto.sc-codigo = item.sc-codigo.
                end.
            end.

        END.

        log-manager:write-message("KML - APICTE001 - ITEM UNIESTAB - " + c-retorno ) NO-ERROR.

        FIND FIRST item-uni-estab no-lock where 
        item-uni-estab.cod-estabel = tt-movto.cod-estabel and
        item-uni-estab.it-codigo = ITEM.it-codigo NO-ERROR.
        if not avail item-uni-estab THEN DO:
            FIND first item-estab NO-LOCK where 
            item-estab.cod-estabel = tt-movto.cod-estabel and
            item-estab.it-codigo = ITEM.it-codigo NO-ERROR.
        END.
        if not avail item-estab and not avail item-uni-estab then do:
            run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + ITEM.it-codigo + " Estab.: " + tt-movto.cod-estabel,
                             input 1).
                             next.
        end.
       
        log-manager:write-message("KML - APICTE001 - RUN DO INT013 - " + c-nat-operacao ) NO-ERROR.


        if c-nat-operacao = "" then do:
            for first bint_ds_nota_entrada exclusive where 
            rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada)
            QUERY-TUNING(no-lookahead):
                assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */
                bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                NEXT .
            end.
            next.
        end.

        FIND first natur-oper no-lock where 
        natur-oper.nat-operacao = c-nat-operacao NO-ERROR.
        if not avail natur-oper then do:
            run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada. Natur. Oper.: " + c-nat-operacao,
                             input 1).
                              next.
        end.
        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
        coment_usuar_hotel itens sem st na nota-conhec */
        if c-nat-principal = "" or NOT natur-oper.log-contrib-st-antec then 
        assign c-nat-principal = c-nat-operacao.

        FIND FIRST natur-oper no-lock where 
        natur-oper.nat-operacao = c-nat-operacao NO-ERROR.

        if not avail natur-oper then do:
            run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada. Natur. Oper.: " + c-nat-operacao,
            input 1).
            next.
        end.
                                                                                                                   
        assign i-trib-icm = natur-oper.cd-trib-icm.

        ASSIGN  tt-movto.it-codigo       = ITEM.it-codigo
                tt-movto.nr-sequencia    = 10
                /* PROCFIT envia somente fator de convers∆o das caixas */
                tt-movto.qt-recebida     = 1
                tt-movto.cod-depos       = if avail item-uni-estab and trim(item-uni-estab.deposito-pad) <> "" and trim(item-uni-estab.deposito-pad) <> ?
                then item-uni-estab.deposito-pad
                else if avail item-estab and trim(item-estab.deposito-pad) <> "" and trim(item-estab.deposito-pad) <> ? then item-estab.deposito-pad else "LOJ"
                tt-movto.lote            = ""
                tt-movto.dt-vali-lote    = ?
                tt-movto.valor-mercad    = int_ds_nota_entrada.nen_valortotalprodutos_n
                tt-movto.desconto        = 0 
                tt-movto.vl-despesas     = 0
                tt-movto.cd-trib-ipi     = 3
                tt-movto.aliquota-ipi    = 0
                tt-movto.tipo-compra     = 4 //natur-oper.tipo-compra
                tt-movto.terceiros       = natur-oper.terceiros
                tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
                tt-movto.cd-trib-icm     = i-trib-icm
                tt-movto.nat-operacao    = natur-oper.nat-operacao
                tt-movto.aliquota-icm    = IF item.cd-trib-icm = 2 THEN 0 ELSE 7.00 //int_ds_nota_entrada.nen_valoricms_n
                tt-movto.perc-red-icm    = 0
                tt-movto.vl-bicms-it     = int_ds_nota_entrada.nen_baseicms_n
                tt-movto.vl-icms-it      = int_ds_nota_entrada.nen_valoricms_n
                tt-movto.vl-bipi-it      = 0
                tt-movto.vl-ipi-it       = 0
                tt-movto.vl-bsubs-it     = 0
                tt-movto.vl-icmsub-it    = 0
                tt-movto.peso-liquido    = item.peso-liquido
                tt-movto.class-fiscal    = item.class-fiscal
                .


        assign  tt-movto.cd-trib-pis     = int(substr(natur-oper.char-1,86,1)).
        if tt-movto.cd-trib-pis = 1 /* tributado */ then do:
            tt-movto.aliquota-pis       = if substr(item.char-2,52,1) = "1" 
            /* Al°quota do Item */
            then dec(substr(item.char-2,31,5))
            /* Al°quota da natureza */
            else natur-oper.perc-pis[1].
        end.
        assign tt-movto.cd-trib-cofins  = int(substr(natur-oper.char-1,87,1)).
        if tt-movto.cd-trib-cofins = 1 /* tributado */ then do:
            tt-movto.aliquota-cofins    = if substr(item.char-2,53,1) = "1"
            then dec(substr(item.char-2,36,5))
            ELSE natur-oper.per-fin-soc[1].
      
        end.

        if not can-find (first classif-fisc no-lock where classif-fisc.class-fiscal = tt-movto.class-fiscal) then do:
            run pi-gera-log (input "NCM n∆o cadastrada. Item: " + tt-movto.it-codigo + " NCM: " + string(tt-movto.class-fiscal),
                             input 1).
        end.
        if not can-find (first estabelec no-lock where estabelec.cod-emitente = tt-movto.cod-emitente) then do:
            assign tt-movto.num-pedido = int_ds_nota_entrada.ped_codigo_n.
        
        end.

        if can-find(first tt-movto) then do:

            MESSAGE "Antes Gera Movimento - " SKIP
                    tt-movto.chave-acesso 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            run PiGeraMovimento (input table tt-movto,   
            input '').

        end.
        else do:
            run pi-gera-log (input "Documento n∆o possui Itens. Docto: " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s) + " Estab.: " + c-cod-estabel,
                             input 1).
        end.
        
        release int_ds_nota_entrada.
        end.
       

        

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:

    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.


run pi-finalizar in h-acomp.

run pi-elimina-tt.
empty temp-table tt-movto.

log-manager:write-message("KML - APICTE001 - depois for first - " + c-retorno ) NO-ERROR. 

return "OK".


procedure PiGeraMovimento:

    def input parameter table for tt-movto.
    def input parameter p-narrativa as char no-undo. 
    def var h-api as handle no-undo.
    
    /******* GERA DOCUMENTO PARA DevolucaoS CONFORME PARAMETRO RECEBIDO *************/

    def buffer b-rat-lote for rat-lote.

    run pi-elimina-tt.    
    find first tt-movto no-error.
    if not avail tt-movto then return.
    
    find first estab-mat 
        no-lock where
        estab-mat.cod-estabel = tt-movto.cod-estabel 
        no-error.
    if not avail estab-mat then do:
        run pi-gera-log (input "Estabelecimento materiais n∆o cadastrado. Estab.: " + tt-movto.cod-estabel,
                         input 1).
        next.
    end.
        
    create tt-versao-integr.
    assign tt-versao-integr.registro              = 1
           tt-versao-integr.cod-versao-integracao = 004.
    
    for each tt-movto
        break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nr-sequencia
        query-tuning(no-lookahead):

        if first-of (tt-movto.nr-nota-fis) then do:
    
            for each tt-dupli-apagar query-tuning(no-lookahead):  delete tt-dupli-apagar.  end.
            
            MESSAGE "ANTES CRIAR DUPLICATA"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            i-ind = 0.
            
                i-ind = i-ind + 1.
                create  tt-dupli-apagar.
                assign  tt-dupli-apagar.registro       = 4
                        tt-dupli-apagar.parcela        = string(i-ind,"99")
                        tt-dupli-apagar.nr-duplic      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-esp        = "NF"
                        tt-dupli-apagar.tp-despesa     = tt-movto.tp-despesa
                        tt-dupli-apagar.dt-vencim      = DATE("07/" + SUBSTRING(STRING(DATE(ADD-INTERVAL(NOW,1,"months"))),4,5))  //Lembrar de fazer a logica de sempre dia 07
                        tt-dupli-apagar.vl-a-pagar     = int_ds_nota_entrada.nen_valortotalprodutos_n
                        tt-dupli-apagar.vl-desconto    = 0
                        tt-dupli-apagar.dt-venc-desc   = ?
                        tt-dupli-apagar.serie-docto    = tt-movto.serie
                        tt-dupli-apagar.nro-docto      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-emitente   = tt-movto.cod-emitente
                        tt-dupli-apagar.nat-operacao   = c-nat-principal.
            //end.
            
            if  not can-find (first estabelec no-lock where estabelec.cod-emitente = tt-movto.cod-emitente) and
                not can-find (first tt-dupli-apagar) and
               (tt-movto.cod-cond-pag = 0 or tt-movto.cod-cond-pag = 999 or tt-movto.cod-cond-pag = ?) and
                /* bonificaá‰es, etc. */
                can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and natur-oper.emite-duplic)
            then do:
                run pi-gera-log (input "Duplicatas n∆o geradas. Liberado para alteraá∆o manual. Docto.: " + tt-movto.nr-nota-fis + " SÇrie: "  + tt-movto.serie + " Estab.: " + tt-movto.cod-estabel + " Nat: " + c-nat-principal,
                                 input 1).
                for first bint_ds_nota_entrada exclusive where 
                    rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada)
                    query-tuning(no-lookahead):
                    assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */
                           bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                    return.
                end.
            end.
        end.
        
        log-manager:write-message("KML - APICTE001 - DESCOBRIR NATUREZA - " + c-nat-principal ) NO-ERROR. 
        
        FIND FIRST TRANSPORTE NO-LOCK
            WHERE TRANSPORTE.cgc = emitente.cgc NO-ERROR.
            
        IF AVAIL TRANSPORTE THEN
        DO:
            
            ASSIGN nome_transp = TRANSPORTE.nome-abrev.
            
        END.
        
        ELSE DO:
        
            ASSIGN nome_transp = " ".
            
        END.
        
        FIND first tt-docum-est-nova where 
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
                   tt-docum-est-nova.cod-observa       = 4 //tt-movto.tipo-compra
                   tt-docum-est-nova.cod-estabel       = tt-movto.cod-estabel
                   tt-docum-est-nova.estab-fisc        = tt-movto.cod-estabel
                   tt-docum-est-nova.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                            if tt-movto.terceiros then 
                                                            estab-mat.conta-ent-benef
                                                            else estab-mat.conta-fornec
                                                         &else
                                                            if tt-movto.terceiros then 
                                                            estab-mat.cod-cta-e-benef-unif
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
                   tt-docum-est-nova.efetua-calculo    = 2 /*1 - efetua os c†lculos - <> 1 valor informado*/
                   tt-docum-est-nova.sequencia         = 1
                   tt-docum-est-nova.esp-docto         = if tt-movto.tipo_nota = 1 then 21 /* NFE */ else 23 /* NFT */
                   tt-docum-est-nova.rec-fisico        = no
                   tt-docum-est-nova.origem            = "" /* verificar*/
                   tt-docum-est-nova.pais-origem       = "Brasil"
                   tt-docum-est-nova.cotacao-dia       = 0
                   tt-docum-est-nova.embarque          = ""
                   tt-docum-est-nova.gera-unid-neg     = 0
                   &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        substring(tt-docum-est-nova.char-1,93,60)  = tt-movto.chave-acesso.
                   &else
                        tt-docum-est-nova.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                   &endif
                   
        end. 
        run pi-acompanhar in h-acomp (input string(tt-movto.nr-sequencia)).
        
        //IF NOT AVAIL tt-item-doc-est-nova  THEN
        //DO:
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
                   tt-item-doc-est-nova.icm-outras         = if (tt-movto.cd-trib-icm = 3 or tt-movto.cd-trib-icm = 5)
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

            assign tt-docum-est-nova.valor-mercad          = tt-docum-est-nova.valor-mercad 
                                                           + tt-item-doc-est-nova.preco-total.
            ASSIGN SUBSTRING(tt-docum-est-nova.char-1,154,2) =  "1".                                       .

            
        //END.
        
        MESSAGE "QUASE REAPI090"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        if tt-movto.ct-codigo <> "" then do:
            assign tt-item-doc-est-nova.ct-codigo = tt-movto.ct-codigo
                   tt-item-doc-est-nova.sc-codigo = tt-movto.sc-codigo.
        end.
        if last-of (tt-movto.nr-nota-fis) then do:
            FIND first docum-est of tt-docum-est-nova NO-LOCK NO-ERROR.
            if avail docum-est then return.
            
            run rep/reapi190b.p persistent set h-api.
            run execute in h-api (input  table tt-versao-integr,
                                  input  table tt-docum-est-nova,
                                  input  table tt-item-doc-est-nova,
                                  input  table tt-dupli-apagar,
                                  input  table tt-dupli-imp,
                                  input  table tt-unid-neg-nota,
                                  output table tt-erro).
            if valid-handle(h-api) then delete procedure h-api no-error.
            find first tt-erro no-error.
            if avail tt-erro then do:
               put /*stream str-rp*/ skip(1).
               for each tt-erro query-tuning(no-lookahead):
                   ASSIGN i-sit-reg = 1.
                   IF tt-erro.cd-erro = 1878 THEN DO:
                      ASSIGN i-sit-reg = 2.
                      for each bint_ds_nota_entrada where
                               bint_ds_nota_entrada.nen_cnpj_origem_s  = tt-movto.nen_cnpj_origem_s and
                               bint_ds_nota_entrada.nen_serie_s        = tt-movto.serie and
                               bint_ds_nota_entrada.nen_notafiscal_n   = integer(tt-movto.nr-nota-fis):


                          assign bint_ds_nota_entrada.nen_conferida_n = 2 /* conferida */
                                 bint_ds_nota_entrada.situacao        = 2 /* processada */
                                 bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                          
                          release bint_ds_nota_entrada.


                      end.
                   END.
                   
                   RUN pi-gera-log("Erro API. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                   " SÇrie: " + tt-movto.serie        +
                                   " NF: "  + tt-movto.nr-nota-fis  +
                                   " Natur. Oper.: " + c-nat-principal + 
                                   " Estab.: " + tt-movto.cod-estabel  + " - " +
                                   "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + tt-erro.mensagem,
                                   i-sit-reg).
               end.
               return.
            end.
            for first docum-est of tt-docum-est-nova
                query-tuning(no-lookahead):
                assign docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                release docum-est.
            end.
            for first docum-est EXCLUSIVE-LOCK of tt-docum-est-nova:
            
            //ERA AQUI
            
                
   
                /* KML - 16/12/2022 - Colocar dados de CST no documento */ 

                FIND FIRST emitente NO-LOCK
                    WHERE emitente.cod-emitente = docum-est.cod-emitente NO-ERROR.
            
            
                FOR EACH item-doc-est OF docum-est NO-LOCK: 

                    RUN rep/reapi414.p PERSISTENT SET h-reapi414.
            
                    RUN setTipoNota IN h-reapi414 (INPUT 1). 
                    RUN setCodEstabel IN h-reapi414 (INPUT docum-est.cod-estabel).
                    RUN setCodNatOperacao IN h-reapi414 (INPUT IF item-doc-est.nat-of <> "" THEN item-doc-est.nat-of ELSE item-doc-est.nat-operacao).
                    RUN setNcm IN h-reapi414 (INPUT item-doc-est.class-fiscal).
                    RUN setItCodigo IN h-reapi414 (INPUT item-doc-est.it-codigo).
                    RUN setCodGrupEmit IN h-reapi414 (INPUT emitente.cod-gr-forn).
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

                    FIND FIRST emitente NO-LOCK
                        WHERE emitente.cod-emitente = docum-est.cod-emitente NO-ERROR.


                    FOR FIRST int_ds_nota_entrada_produt
                        WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s  = emitente.cgc
                          AND int_ds_nota_entrada_produt.nen_serie_s        = item-doc-est.serie-docto 
                          AND int_ds_nota_entrada_produt.nen_notafiscal_n   = integer(item-doc-est.nro-docto)
                          AND int_ds_nota_entrada_produt.nep_sequencia_n    = item-doc-est.sequencia
                          AND int_ds_nota_entrada_produt.nep_produto_n      = INT(item-doc-est.it-codigo):

                        IF int_ds_nota_entrada_produt.nep_picmsst_n > 0 THEN DO: // TEM ICMS ST
                            
                            FIND FIRST natur-oper NO-LOCK
                                WHERE natur-oper.nat-operacao = item-doc-est.nat-operacao NO-ERROR.

                            IF natur-oper.log-contrib-st-antec OR /*Contrib Substituido Antecip - N∆o retido*/
                               natur-oper.log-icms-substto-antecip THEN DO:

    
                                FIND FIRST ext-item-doc-est EXCLUSIVE-LOCK
                                     WHERE ext-item-doc-est.serie-docto  = item-doc-est.serie-docto
                                       AND ext-item-doc-est.nro-docto    = item-doc-est.nro-docto
                                       AND ext-item-doc-est.cod-emitente = item-doc-est.cod-emitente
                                       AND ext-item-doc-est.nat-operacao = item-doc-est.nat-operacao
                                       AND ext-item-doc-est.sequencia    = item-doc-est.sequencia
                                       AND ext-item-doc-est.cod-param    = "icms-sta":U NO-ERROR.
                
                               // IF int_ds_nota_entrada_produt.nep_icmsst_n <> 0 THEN DO:
            
                                    IF NOT AVAIL ext-item-doc-est THEN DO:
                                        CREATE ext-item-doc-est.
                                        ASSIGN ext-item-doc-est.serie-docto  = item-doc-est.serie-docto
                                               ext-item-doc-est.nro-docto    = item-doc-est.nro-docto
                                               ext-item-doc-est.cod-emitente = item-doc-est.cod-emitente
                                               ext-item-doc-est.nat-operacao = item-doc-est.nat-operacao
                                               ext-item-doc-est.sequencia    = item-doc-est.sequencia
                                               ext-item-doc-est.cod-param    = "icms-sta":U.
                                    END.
                                    ASSIGN ext-item-doc-est.val-livre-1 = int_ds_nota_entrada_produt.nep_picmsst_n.
                             //   END.
                            END.
                            ELSE DO:   // ST RETIDO

                                FIND FIRST item-nf-adc EXCLUSIVE-LOCK
                                    WHERE item-nf-adc.cod-estab        = docum-est.cod-estabel         
                                      and item-nf-adc.cod-serie        = docum-est.serie-docto         
                                      and item-nf-adc.cod-nota-fisc    = docum-est.nro-docto           
                                      and item-nf-adc.cdn-emitente     = docum-est.cod-emitente        
                                      and item-nf-adc.cod-natur-operac = item-doc-est.nat-operacao     
                                      and item-nf-adc.idi-tip-dado     = 1                             
                                      and item-nf-adc.num-seq          = 1                             
                                      and item-nf-adc.num-seq-item-nf  = item-doc-est.sequencia        
                                      and item-nf-adc.cod-item         = item-doc-est.it-codigo NO-ERROR.

                                IF NOT AVAIL item-nf-adc THEN DO:

                                    CREATE item-nf-adc.
                                    ASSIGN  item-nf-adc.cod-estab        = docum-est.cod-estabel    
                                            item-nf-adc.cod-serie        = docum-est.serie-docto          
                                            item-nf-adc.cod-nota-fisc    = docum-est.nro-docto      
                                            item-nf-adc.cdn-emitente     = docum-est.cod-emitente    
                                            item-nf-adc.cod-natur-operac = item-doc-est.nat-operacao 
                                            item-nf-adc.idi-tip-dado     = 1                          
                                            item-nf-adc.num-seq          = 1                          
                                            item-nf-adc.num-seq-item-nf  = item-doc-est.sequencia       
                                            item-nf-adc.cod-item         = item-doc-est.it-codigo.

                                END.

                                ASSIGN  item-nf-adc.val-aliq-icms-st = int_ds_nota_entrada_produt.nep_picmsst_n.


                            END.


                        END.
    
    
                        IF int_ds_nota_entrada_produt.nep_cstb_icm_n = 60 THEN DO:
                        
                            FIND FIRST bitem-doc-est EXCLUSIVE-LOCK
                                WHERE ROWID(bitem-doc-est) = ROWID(item-doc-est) NO-ERROR.

                            IF AVAIL bitem-doc-est THEN
                                ASSIGN bitem-doc-est.log-2              = NO 
                                       bitem-doc-est.vl-subs[1]         = int_ds_nota_entrada_produt.de-vicmsstret
                                       bitem-doc-est.base-subs[1]       = int_ds_nota_entrada_produt.de-vbcstret   .  
                                  
                            RELEASE bitem-doc-est.

                        END.

                    END.
                    
                    

                END.

                /* FIM KML - 16/12/2022 - Colocar dados de CST no documento */ 

                /* gerando duplicatas para notas com pedido ou cond padr∆o no fornecedor */
                if  not can-find (first dupli-apagar no-lock of docum-est) and
                    tt-movto.cod-cond-pag <> 0 and
                    tt-movto.cod-cond-pag <> ? and
                    tt-movto.cod-cond-pag <> 999 then do:

                    if  tt-movto.cod-emitente = 1000 or
                        tt-movto.cod-emitente = 5000 or
                        tt-movto.cod-emitente = 9574 then do:
                        for first emitente exclusive-lock where 
                            emitente.cod-emitente = tt-movto.cod-emitente and
                            emitente.cod-cond-pag <> tt-movto.cod-cond-pag
                            query-tuning(no-lookahead):
                            assign emitente.cod-cond-pag = tt-movto.cod-cond-pag.
                            release emitente.
                        end.
                    end.
                    if can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and natur-oper.emite-duplic) then 
                        run rep/re9341.p (input rowid(docum-est), input no).
                end.

                /*
                empty temp-table tt-bo-docum-est.
                create tt-bo-docum-est.
                buffer-copy docum-est to tt-bo-docum-est
                    assign tt-bo-docum-est.r-docum-est = rowid(docum-est).
                   &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        substring(tt-bo-docum-est.char-1,93,60)  = tt-movto.chave-acesso.
                   &else
                        tt-bo-docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                   &endif
                if not valid-handle(h-boin090) then
                    run inbo/boin090.p persistent set h-boin090.
                if valid-handle(h-boin090) then do:
                    run setConstraintByDocto in h-boin090 (docum-est.nro-docto    ,
                                                           docum-est.nro-docto    ,
                                                           docum-est.cod-emitente ,
                                                           docum-est.cod-emitente ,
                                                           docum-est.dt-trans     ,
                                                           docum-est.dt-trans     ,
                                                           docum-est.cod-estabel  ,
                                                           docum-est.cod-estabel  ,
                                                           docum-est.serie-docto  ,
                                                           docum-est.serie-docto  ).
                    /*run openQueryByDocto in h-boin090.*/
                    run openQueryStatic in h-boin090 ('ByDocto').
                    run emptyRowErrors in h-boin090.

                    run goToKey in h-boin090 (docum-est.serie-docto ,
                                              docum-est.nro-docto   ,
                                              docum-est.cod-emitente,
                                              docum-est.nat-operacao).

                    run setRecord    in h-boin090 (input table tt-bo-docum-est).
                    run updateRecord in h-boin090.
                    run getRowErrors in h-boin090 (output table RowErrors).
                    if can-find (first rowErrors) then do:
                        put /*stream str-rp*/ skip(1).
                        for each rowErrors query-tuning(no-lookahead):
                            RUN pi-gera-log("Erro BO. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                   " SÇrie: " + tt-movto.serie        +
                                   " NF: "  + tt-movto.nr-nota-fis  +
                                   " Natur. Oper.: " + c-nat-principal +
                                   " Estab.: " + tt-movto.cod-estabel  + " - " +
                                   "Cod. Erro: " + string(rowErrors.errorNumber) + " - " + rowErrors.errorDescription,
                                   1).
                        end.
                    end.
                    /* atualiza nota no recebimento/estoque */
                    /* run atualizaDocumento in h-boin090. */
                    if valid-handle(h-boin090) then delete procedure h-boin090.
                end.
                
                for each item-doc-est no-lock of docum-est
                    query-tuning(no-lookahead):
                    empty temp-table tt-bo-item-doc-est.
                    create tt-bo-item-doc-est.
                    buffer-copy item-doc-est to tt-bo-item-doc-est
                        assign tt-bo-item-doc-est.r-item-doc-est = rowid(item-doc-est).
                    if not valid-handle(h-boin176) then
                        run inbo/boin176.p persistent set h-boin176.
                    if valid-handle(h-boin176) then do:
                        run setConstraintOfDocumEst in h-boin176 ( docum-est.cod-emitente ,
                                                                   docum-est.serie-docto  ,
                                                                   docum-est.nro-docto    ,
                                                                   docum-est.nat-operacao ).
                        /*run openQueryByDocto in h-boin176.*/
                        run openQueryStatic in h-boin176 ('OfDocumEst').
                        run emptyRowErrors in h-boin176.

                        run goToKey in h-boin176 (docum-est.serie-docto ,
                                                  docum-est.nro-docto   ,
                                                  docum-est.cod-emitente,
                                                  docum-est.nat-operacao,
                                                  item-doc-est.sequencia).

                        run setRecord    in h-boin176 (input table tt-bo-item-doc-est).
                        run updateRecord in h-boin176.
                        run getRowErrors in h-boin176 (output table RowErrors).
                        if can-find (first rowErrors) then do:
                            put /*stream str-rp*/ skip(1).
                            for each rowErrors:
                                RUN pi-gera-log("Erro BO. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                       " SÇrie: " + tt-movto.serie        +
                                       " NF: "  + tt-movto.nr-nota-fis  +
                                       " Natur. Oper.: " + tt-movto.nat-operacao +
                                       " Estab.: " + tt-movto.cod-estabel  + " - " +
                                       "Cod. Erro: " + string(rowErrors.errorNumber) + " - " + rowErrors.errorDescription,
                                       1).
                            end.
                        end.
                        if valid-handle(h-boin176) then delete procedure h-boin176.
                    end.
                end. /* item-doc-est */
                */
                
                /* Retirado - Para PROCFIT n∆o Ç necess†rio
                run pi-gera-int-ds-doc.*/
                
                //TESTE

                MESSAGE "ANTES DE VER CIDADE"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                FIND FIRST ems2mult.estabelec NO-LOCK
                    WHERE estabelec.cod-estabel = docum-est.cod-estabel NO-ERROR.

                IF AVAIL estabelec THEN
                DO:

                    MESSAGE "IF AVAIL DO ESTABELEC"
                            SKIP estabelec.cod-estabel
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                    FIND FIRST ems2dis.cidade NO-LOCK
                        WHERE cidade.cidade = estabelec.cidade
                        AND   cidade.pais   = estabelec.pais
                        AND   cidade.estado = estabelec.estado NO-ERROR.

                    IF AVAIL cidade THEN
                    DO:

                        OVERLAY(docum-est.char-2,151,2)  = "1"                              NO-ERROR.  //TIPO_CTE?.
                        OVERLAY(docum-est.char-2,211,2)  = docum-est.UF                     NO-ERROR.  //c-uf-origem.
                        OVERLAY(docum-est.char-2,236,10) = STRING(cidade.cdn-munpio-ibge)   NO-ERROR.  //cod-ibge-dest.
                        OVERLAY(docum-est.char-2,246,10) = "4105805"                        NO-ERROR.  //cod-ibge-orig.
                        //OVERLAY(docum-est.cod-chave-aces-nf-eletro,21,2) = "57"             NO-ERROR. //"CHAVE"
                        ASSIGN  docum-est.cod-observa = 4.

                        //RELEASE docum-est.
                    END.
                END.
                
                
                create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int112-re1005.txt"
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
                
                

                for each item-doc-est no-lock of docum-est:

                END.

                empty temp-table tt-digita-re1005.
                empty temp-table tt-param-re1005.
                
   
                MESSAGE "ANTES PI-GERA-LOG-OK"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                run pi-gera-log("OK",
                                 2).
                
                for each bint_ds_nota_entrada where
                    bint_ds_nota_entrada.nen_cnpj_origem_s = tt-movto.nen_cnpj_origem_s and
                    bint_ds_nota_entrada.nen_serie_s = tt-movto.serie and
                    bint_ds_nota_entrada.nen_notafiscal_n = integer(tt-movto.nr-nota-fis)
                    query-tuning(no-lookahead):
                    assign  bint_ds_nota_entrada.nen_conferida_n = 2 /* conferida */
                            bint_ds_nota_entrada.situacao        = 2 /* processada */
                            bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                    release bint_ds_nota_entrada.

 

                end.
                
                release docum-est.
                

                
                
            end. /* docum-est */
            run pi-elimina-tt.
        end. /* last-of */
    end. /* tt-movto */
    empty temp-table tt-movto.
end procedure. /* PiGeraDocumento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.
    
    c-retorno =  c-informacao.
    
    //l-erro = NO.
    
    
    log-manager:write-message("KML - gera-log - " + c-informacao ) NO-ERROR. 

end.

procedure pi-elimina-tt:
    empty temp-table tt-versao-integr. 
    empty temp-table tt-docum-est-nova.     
    empty temp-table tt-item-doc-est-nova.
    empty temp-table tt-dupli-apagar.
    empty temp-table tt-dupli-imp.
    empty temp-table tt-unid-neg-nota.
    empty temp-table tt-erro.
    empty temp-table tt-bo-docum-est.
    empty temp-table tt-bo-item-doc-est.
end.
