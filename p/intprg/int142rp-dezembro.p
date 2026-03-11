/********************************************************************************
** Programa: int012 - Importaá∆o de Notas de Entrada do Procfit - Transferencias
**
** Versao : 12 - 14/02/2018 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i int142rp 2.12.05.AVB}
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
    field nen_cnpj_origem_s like int_ds_nota_entrada.nen_cnpj_origem_s
    field nen_cfop_n        like int_ds_nota_entrada.nen_cfop_n
    field numero-ordem      like item-doc-est.numero-ordem
    field parcela           like item-doc-est.parcela
    field num-pedido        like item-doc-est.num-pedido
    field tp-despesa        like dupli-apagar.tp-despesa
    field tipo_nota         like int_ds_nota_entrada.tipo_nota
    field dt-trans          like int_ds_nota_entrada.nen_datamovimentacao_d
    field perc-red-icms     like int_ds_nota_entrada_produt.nep_redutorbaseicms_n
    field cod-cond-pag      like emitente.cod-cond-pag
    field base-pis          like item-doc-est.base-pis
    field valor-pis         like item-doc-est.valor-pis
    field cd-trib-pis       like item-doc-est.idi-tributac-pis
    field aliquota-pis      like item-doc-est.val-aliq-pis
    field base-cofins       like item-doc-est.val-base-calc-cofins
    field valor-cofins      like item-doc-est.val-cofins
    field cd-trib-cofins    like item-doc-est.idi-tributac-cofins
    field aliquota-cofins   like item-doc-est.val-aliq-cofins
    field estab-de-or       like docum-est.estab-de-or
    field nat-orig          like nota-fiscal.nat-operacao
    field ct-codigo         like item-doc-est.ct-codigo
    field sc-codigo         like item-doc-est.sc-codigo
    field class-fisc        like item-doc-est.class-fisc
    field chave-acesso as char
    INDEX chave is PRIMARY 
            serie        
            nr-nota-fis  
            nr-sequencia .


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
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
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

/* recebimento de par‚metros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int142.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padr∆o para vari·veis de relatÛrio  */
{include/i-rpvar.i}

/* definiá∆o de vari·veis  */
def var h-acomp    as handle no-undo.
def var h-boin090  as handle no-undo.
def var h-boin176  as handle no-undo.
def var h-aux      as handle no-undo.
def var l-erro     as logical no-undo.
def var c-nat-operacao as char no-undo.
def var c-nat-principal as char no-undo.
def var i-cfop     as integer no-undo.
def var c-cod-estabel as char no-undo.
def var i-ind      as integer no-undo.
def var i-trib-icm as integer no-undo.
def var i-trib-ipi as integer no-undo.
def var c-cod-estabel-ori as char no-undo.
def var i-sit-reg  as int no-undo.
def var c-tp-pedido     as character.
def var c-uf-destino    as char no-undo. 
def var c-uf-origem     as char no-undo. 
def var i-cod-emitente  like emitente.cod-emitente.
def var c-class-fiscal  as char no-undo.
def var c-nat-saida     as char no-undo.
def var r-rowid         as rowid no-undo.
def var d-data-procfit  as date no-undo.
def var d-data-movimento as date no-undo.
DEF VAR i-lock          AS INT NO-UNDO.
DEF VAR i-tempoLock     AS INT INIT 2 NO-UNDO.


DEFINE VARIABLE h-reapi414 AS HANDLE      NO-UNDO.

DEFINE VARIABLE c-cod-sit-tribut-icms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-ipi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-pis    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-cofins AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-aliq-pis             AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins          AS DECIMAL     NO-UNDO.


def buffer bint_ds_nota_entrada for int_ds_nota_entrada.
def buffer btt-item-doc-est-nova for tt-item-doc-est-nova.
def buffer btt-movto for tt-movto.
DEF BUFFER bint_dp_nota_entrada_ret FOR int_dp_nota_entrada_ret.
DEFINE BUFFER bitem-doc-est FOR item-doc-est.

/* definiá∆o de frames do relatÛrio */

for first param-re no-lock where param-re.usuario = c-seg-usuario
    : end.
if not avail param-re then do:
    PUT unformatted "ParÉmetros do usu†rio recebimento n∆o cadastrados...." SKIP.
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

assign c-programa     = "int142"
       c-versao       = "2.13"
       c-revisao      = ".05.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Transferencias Recebimento".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock
    : end.
for first mgadm.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin
    : end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 180
           tt-param.dt-emis-nota-fim = TODAY - 1.

if tt-param.cod-estabel-fim  = "" then
    assign tt-param.cod-estabel-ini  = ""
           tt-param.cod-estabel-fim  = "ZZZZZ".

if tt-param.serie-docto-fim  = "" then
    assign tt-param.serie-docto-ini  = ""
           tt-param.serie-docto-fim  = "ZZZZZ".

if tt-param.nro-docto-fim  = 0 then
    assign tt-param.nro-docto-ini  = 0
           tt-param.nro-docto-fim  = 999999999.

if tt-param.cod-emitente-fim  = 0 then
    assign tt-param.cod-emitente-ini  = 0
           tt-param.cod-emitente-fim  = 999999999.

DEFINE BUFFER bestabelec FOR estabelec.
DEFINE BUFFER b-int_ds_nota_entrada FOR int_ds_nota_entrada.
DEFINE BUFFER b2-nota-fiscal FOR nota-fiscal.
DEFINE BUFFER b-natur-oper FOR natur-oper.
DEFINE BUFFER b-int_dp_nota_entrada_ret FOR int_dp_nota_entrada_ret.

/******* LE NOTA E GERA TEMP TABLES  *************/

DEFINE VARIABLE i-volume-notas AS INT NO-UNDO.

//MESSAGE "dentro int142 v2" VIEW-AS ALERT-BOX.


FIND FIRST emitente NO-LOCK
    WHERE emitente.cod-emitente = tt-param.cod-emitente-ini NO-ERROR.

for-nota:
for each int_ds_nota_entrada no-lock where
    int_ds_nota_entrada.situacao >= 1 and
    /*int_ds_nota_entrada.nen_conferida_n = 0 and */
    int_ds_nota_entrada.nen_conferida_n < 2 and 
   // int_ds_nota_entrada.nen_dataemissao_d = tt-param.dt-emis-nota-ini AND
    int_ds_nota_entrada.nen_serie_s = tt-param.serie-docto-ini AND
    int_ds_nota_entrada.nen_notafiscal_n = tt-param.nro-docto-ini AND 
    int_ds_nota_entrada.nen_cnpj_origem_s = emitente.cgc AND
    int_ds_nota_entrada.tipo_nota = 3 ,
    first int_dp_nota_entrada_ret NO-LOCK where
    int_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s and
    int_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n  and
    int_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s:

    //MESSAGE "dentro laáo de notas " SKIP i-volume-notas VIEW-AS ALERT-BOX.
    ASSIGN i-volume-notas = i-volume-notas + 1.
    
   // IF i-volume-notas >= 3 THEN LEAVE.
    
    FIND FIRST bestabelec NO-LOCK
        WHERE bestabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino NO-ERROR.

    IF NOT AVAIL bestabelec THEN DO:

        run pi-gera-log (input "Estabelecimento n∆o cadastrado com o CNPJ: " + string(int_ds_nota_entrada.nen_cnpj_destino),
                         input 1).
        NEXT.
    END.

    for first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = bestabelec.cod-estabel and
        cst_estabelec.dt_inicio_oper <> ?
        : end.
    if not avail cst_estabelec then next.

    /* Nota rejeitada pelo recebimento */
    if int_ds_nota_entrada.situacao = 9 THEN NEXT.
    /* pular notas a serem integradas manualmente pelo int520 */
    if int_ds_nota_entrada.situacao = 5 and nro-docto-ini = 0 then next.

    /*
    for first int_dp_nota_entrada_ret EXCLUSIVE-LOCK where
        int_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s and
        int_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n  and
        int_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s
        query-tuning(no-lookahead): end.
    if not avail int_dp_nota_entrada_ret then next.
    */
    
    if int_ds_nota_entrada.nen_datamovimentacao_d = ? and 
       int_dp_nota_entrada_ret.nen_datamovimentacao_d = ? 
    then do: 
        run pi-gera-log (input "Data de movimentaá∆o em branco. Liberando atualizaá∆o manual: " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s),
                         input 1).
        for first bint_ds_nota_entrada exclusive where rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada)
            :
            assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */.
            next for-nota.
        end.
    end.
    
    IF int_dp_nota_entrada_ret.nen_datamovimentacao_d < int_ds_nota_entrada.nen_dataemissao_d THEN DO:

        FIND FIRST bint_dp_nota_entrada_ret EXCLUSIVE-LOCK
            WHERE ROWID(bint_dp_nota_entrada_ret) = ROWID(int_dp_nota_entrada_ret) NO-ERROR.
        IF AVAIL bint_dp_nota_entrada_ret THEN DO:
            ASSIGN bint_dp_nota_entrada_ret.nen_datamovimentacao_d = int_ds_nota_entrada.nen_dataemissao_d.
        END.
        RELEASE bint_dp_nota_entrada_ret.

    END.
    /* Se preencher a data de movimentaá∆o no INT520 pega aquela data, 
       se n∆o, pega a data da geraá∆o pelo PROCFIT-chegada f°sica na loja */
    assign d-data-movimento = if int_ds_nota_entrada.nen_datamovimentacao_d <> ?
                              then int_ds_nota_entrada.nen_datamovimentacao_d
                              else int_dp_nota_entrada_ret.nen_datamovimentacao_d.
    if d-data-movimento < 08/01/2016 then next.

    assign l-erro = no.
    empty temp-table tt-movto.

    c-nat-principal = "".
    d-data-procfit = ?.
    c-cod-estabel = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_ds_nota_entrada.nen_dataemissao_d
        :
        c-cod-estabel  = estabelec.cod-estabel.
        c-uf-destino   = estabelec.estado.
        d-data-procfit = cst_estabelec.dt_inicio_oper.
        leave.
    end.
    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int_ds_nota_entrada.nen_cnpj_destino_s,
                         input 1).
        next.
    end.
    if  c-cod-estabel < cod-estabel-ini or
        c-cod-estabel > cod-estabel-fim then next.

    /* Operaá∆o Procfit ainda n∆o iciciada na filial */
    if d-data-procfit <> ? and d-data-procfit > d-data-movimento then next.

    c-cod-estabel-ori = "".
    for each estabelec 
        fields (cod-estabel estado cidade cod-emitente
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_nota_entrada.nen_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_ds_nota_entrada.nen_dataemissao_d
        :
        c-cod-estabel-ori = estabelec.cod-estabel.
        c-uf-origem = estabelec.estado.        
        i-cod-emitente = estabelec.cod-emitente.
        leave.
    end.
    if c-cod-estabel-ori = "" then do:
        run pi-gera-log (input "Estabelecimento ORIGEM n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int_ds_nota_entrada.nen_cnpj_origem_s,
                         input 1).
        next.
    end.
    for first estabelec no-lock where estabelec.cod-estabel = c-cod-estabel-ori
        : end.
    for first emitente fields (cod-emitente estado tp-desp-padrao cod-cond-pag) no-lock where 
        emitente.cod-emitente = estabelec.cod-emitente
        : end.
    if not avail emitente then do:
        run pi-gera-log (input "Fornecedor n∆o cadastrado. CNPJ: " + string(int_ds_nota_entrada.nen_cnpj_origem_s),
                         input 1).
        next.
    end.
    if  emitente.cod-emitente < cod-emitente-ini or
        emitente.cod-emitente > cod-emitente-fim then next.

   /* if int_ds_nota_entrada.tipo_movto = 3 then do:

        FIND FIRST b-int_ds_nota_entrada EXCLUSIVE-LOCK
            WHERE ROWID(b-int_ds_nota_entrada) = ROWID(int_ds_nota_entrada) NO-ERROR.

        IF AVAIL b-int_ds_nota_entrada THEN  DO:
            ASSIGN b-int_ds_nota_entrada.situacao = 9   /* como a saida est† cancelada Ç deixado a situaá∆o como 9 para n∆o tentar importar novamente */
                   b-int_ds_nota_entrada.nen_conferida_n = 2.    
        END.
        RELEASE b-int_ds_nota_entrada.

        run pi-gera-log (input "Nota Fiscal de sa°da est† cancelada " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s) + " Estab.: " + c-cod-estabel,
                         input 1).
        next.
    end. */

    FIND FIRST b2-nota-fiscal NO-LOCK
        WHERE b2-nota-fiscal.nr-nota-fis   =  trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999"))
          AND b2-nota-fiscal.serie         =  int_ds_nota_entrada.nen_serie_s
          AND b2-nota-fiscal.cod-estabel   = c-cod-estabel-ori NO-ERROR.

    IF AVAIL b2-nota-fiscal THEN DO:
        IF b2-nota-fiscal.dt-cancel <> ?  THEN DO:
        
            FIND FIRST b-int_ds_nota_entrada EXCLUSIVE-LOCK
                WHERE ROWID(b-int_ds_nota_entrada) = ROWID(int_ds_nota_entrada) NO-ERROR.
    
            IF AVAIL b-int_ds_nota_entrada THEN 
                ASSIGN b-int_ds_nota_entrada.situacao = 9   /* como a saida est† cancelada Ç deixado a situaá∆o como 9 para n∆o tentar importar novamente */
                       b-int_ds_nota_entrada.nen_conferida_n = 2.    

            run pi-gera-log (input "Nota Fiscal de sa°da est† cancelada " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s) + " Estab.: " + c-cod-estabel,
                             input 1).
        END.
    END.

    for first docum-est no-lock USE-INDEX documento where 
        docum-est.serie-docto  = int_ds_nota_entrada.nen_serie_s and
        docum-est.nro-docto    = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) and
        docum-est.cod-emitente = emitente.cod-emitente: 

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

            assign  bint_ds_nota_entrada.nen_conferida_n = 2 
                    bint_ds_nota_entrada.situacao = 2 /* processada */
                    bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
            release bint_ds_nota_entrada.

            FIND FIRST b-int_dp_nota_entrada_ret EXCLUSIVE-LOCK
                WHERE rowid(b-int_dp_nota_entrada_ret) = ROWID(int_dp_nota_entrada_ret) NO-ERROR.
            IF AVAIL b-int_dp_nota_entrada_ret THEN
                assign  b-int_dp_nota_entrada_ret.situacao     = 2.

            release b-int_dp_nota_entrada_ret.
        end.
        empty temp-table tt-movto.
        assign l-erro = yes.
        next for-nota.
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
                rowid(bint_ds_nota_entrada) = rowid(int_ds_nota_entrada):
                assign bint_ds_nota_entrada.situacao = 5 /* atualizaá∆o manual */
                       bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                next for-nota.
            end.
            empty temp-table tt-movto.
            assign l-erro = yes.
            next for-nota.
        end.
    end.

    /*
    i-cfop = 0.
    i-ind  = 0.
    for each int_ds_nota_entrada_produt exclusive-lock of int_ds_nota_entrada
        query-tuning(no-lookahead):

        /* preencher c¢digo do produto quando n∆o encontrado no INT500 */
        if int_ds_nota_entrada_produt.nep_produto_n = 0 then
        for each int_dp_nota_entrada_ret-item exclusive of int_dp_nota_entrada_ret where
            int_dp_nota_entrada_ret-item.nep_sequencia_n = int_ds_nota_entrada_produt.nep_sequencia_n and
            int_dp_nota_entrada_ret-item.npx-ean-n = int_ds_nota_entrada_produt.npx-ean-n
            query-tuning(no-lookahead):
                assign int_ds_nota_entrada_produt.nep_produto_n = int_dp_nota_entrada_ret-item.nep_produto_n.
        end.

        i-cfop = i-cfop + 1.
        for each int_dp_nota_entrada_ret-item of int_ds_nota_entrada_produt
            query-tuning(no-lookahead):
            i-ind = i-ind + 1.
        end.
    end.
    if i-cfop <> i-ind then do:
        run pi-gera-log (input "N£mero de itens retornados inconsistente " + c-cod-estabel
                         + "SÇrie: "     + trim(int_ds_nota_entrada.nen_serie_s)
                         + " Numero: "   + trim(string(int_ds_nota_entrada.nen_notafiscal_n))
                         + " Forn: "     + string(emitente.cod-emitente)
                         + " Data: "     + string(d-data-movimento,"99/99/9999"),
                         input 1).
        empty temp-table tt-movto.
        next .
    end.
    */

    for each int_ds_nota_entrada_produt no-lock where
        int_ds_nota_entrada_produt.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s and
        int_ds_nota_entrada_produt.nen_serie_s       = int_ds_nota_entrada.nen_serie_s       and
        int_ds_nota_entrada_produt.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n:

        create tt-movto.
        assign tt-movto.serie               = int_ds_nota_entrada.nen_serie_s
               tt-movto.nr-nota-fis         = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999"))
               tt-movto.dt-emissao          = int_ds_nota_entrada.nen_dataemissao_d
               tt-movto.tot-frete           = int_ds_nota_entrada.nen_frete_n                                              
               tt-movto.tot-seguro          = int_ds_nota_entrada.nen_seguro_n                                  
               tt-movto.tot-despesas        = IF (int_ds_nota_entrada.nen_despesas_n - int_ds_nota_entrada.nen_frete_n) > 0 
                                              THEN (int_ds_nota_entrada.nen_despesas_n - int_ds_nota_entrada.nen_frete_n)
                                              ELSE 0
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
               tt-movto.perc-red-icms       = int_ds_nota_entrada_produt.nep_redutorbaseicms_n
               tt-movto.cod-cond-pag        = emitente.cod-cond-pag
               tt-movto.estab-de-or         = c-cod-estabel-ori.

        FIND FIRST ITEM no-lock 
        WHERE item.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n) NO-ERROR.
            c-class-fiscal = trim(item.class-fiscal).
   
        if not avail item then do:

            FIND FIRST b-int_ds_nota_entrada EXCLUSIVE-LOCK
                WHERE ROWID(b-int_ds_nota_entrada) = ROWID(int_ds_nota_entrada) NO-ERROR.
    
            IF AVAIL b-int_ds_nota_entrada THEN  DO:
                ASSIGN b-int_ds_nota_entrada.situacao = 9.   
            END.
            RELEASE b-int_ds_nota_entrada.

            run pi-gera-log (input "Item n∆o cadastrado: " + string(int_ds_nota_entrada_produt.nep_produto_n),
                             input 1).
            next.
        end.
        if item.tipo-contr = 1 /* Fisico */ or item.tipo-contr = 4 /* DB Dir */ then do:
            if item.ct-codigo = "" then do:
                run pi-gera-log (input "Item sem conta aplicacao: " + string(int_ds_nota_entrada_produt.nep_produto_n),
                                 input 1).
                next.
            end.
            else do:
                assign tt-movto.ct-codigo = item.ct-codigo
                       tt-movto.sc-codigo = item.sc-codigo.
            end.
        end.
        FIND FIRST item-uni-estab no-lock where 
            item-uni-estab.cod-estabel = tt-movto.cod-estabel and
            item-uni-estab.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n) NO-ERROR. 
        
        if not avail item-uni-estab THEN DO:
           FIND FIRST item-estab NO-LOCK where 
               item-estab.cod-estabel = tt-movto.cod-estabel and
               item-estab.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n) NO-ERROR.
        END.
        if not avail item-estab and not avail item-uni-estab then do:
           run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + string(int_ds_nota_entrada_produt.nep_produto_n) + " Estab.: " + tt-movto.cod-estabel,
                            input 1).
           next.
        end.

        c-tp-pedido = "".
        for first nota-fiscal 
            fields (cod-estabel serie nr-nota-fis nat-operacao nr-pedcli)
            no-lock where 
            nota-fiscal.cod-estabel = c-cod-estabel-ori and
            nota-fiscal.serie       = tt-movto.serie and
            nota-fiscal.nr-nota-fis = tt-movto.nr-nota-fis:
            if c-tp-pedido = "" then
            for first int_ds_pedido no-lock where
                int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli):
                assign c-tp-pedido = trim(string(int_ds_pedido.ped_tipopedido_n)).
            end.

            for each it-nota-fisc no-lock of nota-fiscal where
                it-nota-fisc.nr-seq-fat = int_ds_nota_entrada_produt.nep_sequencia_n and
                it-nota-fisc.it-codigo  = trim(string(int_ds_nota_entrada_produt.nep_produto_n)):
                c-class-fiscal = if trim(it-nota-fisc.class-fiscal) <> "" and 
                                    int (it-nota-fisc.class-fiscal) <> 0 
                                 then trim(item.class-fiscal)
                                 else c-class-fiscal.
                assign tt-movto.nat-orig = IT-NOTA-FISC.nat-operacao.
                i-trib-icm = it-nota-fisc.cd-trib-icm.
                i-trib-ipi = it-nota-fisc.cd-trib-ipi.
                if i-trib-ipi = 4 or
                   i-trib-ipi = 1 then
                    assign tt-movto.vl-bipi-it      = it-nota-fisc.vl-bipi-it
                           tt-movto.vl-ipi-it       = it-nota-fisc.vl-ipi-it.
                if i-trib-ipi = 3 or 
                   i-trib-ipi = 5 then 
                    assign tt-movto.vl-bipi-it      = it-nota-fisc.vl-ipiou-it
                           tt-movto.vl-ipi-it       = 0.
                if i-trib-ipi = 2 then 
                    assign tt-movto.vl-bipi-it      = it-nota-fisc.vl-ipint-it
                           tt-movto.vl-ipi-it       = 0.
                if c-tp-pedido = "" then
                for first int_ds_pedido no-lock where
                    int_ds_pedido.ped_codigo_n = int64(it-nota-fisc.nr-pedcli):
                    assign c-tp-pedido = trim(string(int_ds_pedido.ped_tipopedido_n)).
                end.
            end.
        end.


        i-cfop = int_ds_nota_entrada_produt.nen_cfop_n.
        /*
        /* tratar natur-oper */
        c-nat-operacao = "".
        RUN intprg/int013a.p( input i-cfop,
                              input int_ds_nota_entrada_produt.nep-cstb-n,
                              input /*int_ds_nota_entrada_produt.nep-cstb-ipi-n*/ int(item.fm-codigo),
                              input tt-movto.cod-estabel,
                              input tt-movto.cod-emitente,
                              input tt-movto.dt-emissao,
                              output c-nat-operacao ).
        */
        if c-tp-pedido = "" then
        FIND FIRST int_ds_pedido no-lock where
            int_ds_pedido.ped_codigo_n = (if int_ds_nota_entrada.ped_procfit <> 0 AND int_ds_nota_entrada.ped_procfit <> ? then
                                          int_ds_nota_entrada.ped_procfit
                                          else int_ds_nota_entrada.ped_codigo_n) NO-ERROR.
            assign c-tp-pedido = trim(string(int_ds_pedido.ped_tipopedido_n)).

        if c-tp-pedido = "" then do:

            FIND FIRST b-int_ds_nota_entrada EXCLUSIVE-LOCK
                WHERE ROWID(b-int_ds_nota_entrada) = ROWID(int_ds_nota_entrada) NO-ERROR.
            IF AVAIL b-int_ds_nota_entrada THEN
                    ASSIGN b-int_ds_nota_entrada.situacao = 9.
            RELEASE b-int_ds_nota_entrada.
            run pi-gera-log (input "1-Pedido n∆o localizado: " + string((if int_ds_nota_entrada.ped_procfit <> 0 AND int_ds_nota_entrada.ped_procfit <> ? then
                                          int_ds_nota_entrada.ped_procfit
                                          else int_ds_nota_entrada.ped_codigo_n)),
                             input 1).
            next.
        end.

        /* determina natureza de operacao */
        c-nat-saida = "".
        c-nat-operacao = "".
        run intprg/int115a.p ( input c-tp-pedido   ,
                               input c-uf-destino  ,
                               input c-uf-origem   ,
                               input "" /*nat or*/ ,
                               input i-cod-emitente,
                               input c-class-fiscal,
			                   input item.it-codigo , /* item */
                               INPUT c-cod-estabel,
                               output c-nat-saida,
                               output c-nat-operacao,
                               output r-rowid).

        /*
        display item.it-codigo
                item.class-fiscal
                c-tp-pedido    
                c-uf-destino   
                c-uf-origem    
                i-cod-emitente 
                c-class-fiscal 
                c-nat-saida
                c-nat-operacao
                skip(1)
            with 1 col.
        */

        if c-nat-operacao = "" then do:
            run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                    "Tp Pedido: " + c-tp-pedido + 
                                    " UF Origem: " + c-uf-origem + 
                                    " UF Destino: " + c-uf-destino + 
                                    " NCM: " + c-class-fiscal,
                             input 1).
            next.
        end.
        for first natur-oper no-lock where 
            natur-oper.nat-operacao = c-nat-operacao: end.
        if not avail natur-oper then do:
            run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada. Natur. Oper.: " + c-nat-operacao,
                             input 1).
            next.
        end.
        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
           coment_usuar_hotel itens sem st na nota-conhec */
        if c-nat-principal = "" or 
            &IF '{&bf_dis_versao_ems}' >= '2.08' &THEN
                NOT natur-oper.log-contrib-st-antec then 
            &else
                not SUBSTRING(natur-oper.char-1,149,1) = "1"  then 
            &ENDIF
            assign c-nat-principal = c-nat-operacao.
        
        /* buscando tributaá∆o no destino */
        assign i-trib-icm = natur-oper.cd-trib-icm
               i-trib-ipi = natur-oper.cd-trib-ipi.

        assign tt-movto.it-codigo       = string(int_ds_nota_entrada_produt.nep_produto_n)
               tt-movto.nr-sequencia    = int_ds_nota_entrada_produt.nep_sequencia_n
               tt-movto.qt-recebida     = (int_ds_nota_entrada_produt.nep_quantidade_n /** int_dp_nota_entrada_ret-item.nep_quantidade_n*/)
               tt-movto.cod-depos       = if avail item-uni-estab and trim(item-uni-estab.deposito-pad) <> "" and trim(item-uni-estab.deposito-pad) <> ?
                                          then item-uni-estab.deposito-pad
                                          else if avail item-estab and trim(item-estab.deposito-pad) <> "" and trim(item-estab.deposito-pad) <> ? then item-estab.deposito-pad else "LOJ"
               tt-movto.lote            = if item.tipo-con-est = 3 then int_ds_nota_entrada_produt.nep_lote_s else ""
               tt-movto.dt-vali-lote    = if item.tipo-con-est = 3 then int_ds_nota_entrada_produt.nep_datavalidade_d else ?
               tt-movto.valor-mercad    = int_ds_nota_entrada_produt.nep_valorbruto_n
               tt-movto.vl-despesas     = int_ds_nota_entrada_produt.nep_valordespesa_n
               tt-movto.cd-trib-ipi     = i-trib-ipi
               tt-movto.aliquota-ipi    = int_ds_nota_entrada_produt.nep_percentualipi_n
               tt-movto.tipo-compra     = natur-oper.tipo-compra
               tt-movto.terceiros       = natur-oper.terceiros
               tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
               tt-movto.cd-trib-icm     = i-trib-icm
               tt-movto.nat-operacao    = natur-oper.nat-operacao
               tt-movto.aliquota-icm    = int_ds_nota_entrada_produt.nep_percentualicms_n
               tt-movto.perc-red-icm    = int_ds_nota_entrada_produt.nep_redutorbaseicms_n
               tt-movto.vl-bicms-it     = int_ds_nota_entrada_produt.nep_baseicms_n
               tt-movto.vl-icms-it      = int_ds_nota_entrada_produt.nep_valoricms_n
               tt-movto.vl-bsubs-it     = int_ds_nota_entrada_produt.nep_basest_n
               tt-movto.vl-icmsub-it    = int_ds_nota_entrada_produt.nep_icmsst_n
               tt-movto.peso-liquido    = item.peso-liquido
               tt-movto.class-fisc      = trim(string(int_ds_nota_entrada_produt.nep_ncm_n,"99999999")).

        /* novo tratamento PIS/COFINS - AVB 07/06/2017 */
        assign tt-movto.cd-trib-pis     = int(substr(natur-oper.char-1,86,1)).
        if tt-movto.cd-trib-pis = 1 /* tributado */ then do:
            tt-movto.aliquota-pis       = if substr(item.char-2,52,1) = "1" 
                                          /* Al°quota do Item */
                                          then dec(substr(item.char-2,31,5))
                                          /* Al°quota da natureza */
                                          else natur-oper.perc-pis[1].
      
            if tt-movto.aliquota-pis <> 0 then do:
                tt-movto.base-pis           = int_ds_nota_entrada_produt.nep_valorbruto_n
                                            - int_ds_nota_entrada_produt.nep_valordesconto_n
                                            + int_ds_nota_entrada_produt.nep_valordespesa_n.
                tt-movto.valor-pis          = tt-movto.base-pis * tt-movto.aliquota-pis / 100.
            end.
            else do:
                tt-movto.cd-trib-pis = 2.
                tt-movto.base-pis    = 0.
                tt-movto.valor-pis   = 0.
            end.
        end.
        assign tt-movto.cd-trib-cofins  = int(substr(natur-oper.char-1,87,1)).
        if tt-movto.cd-trib-cofins = 1 /* tributado */ then do:
            tt-movto.aliquota-cofins    = if substr(item.char-2,53,1) = "1"
                                          /* Al°quota do Item */
                                          then dec(substr(item.char-2,36,5))
                                          /* Al°quota da natureza */
                                          else natur-oper.per-fin-soc[1].
            if tt-movto.aliquota-cofins <> 0 then do:
                tt-movto.base-cofins        = int_ds_nota_entrada_produt.nep_valorbruto_n 
                                            - int_ds_nota_entrada_produt.nep_valordesconto_n
                                            + int_ds_nota_entrada_produt.nep_valordespesa_n.
                tt-movto.valor-cofins       = tt-movto.aliquota-cofins * tt-movto.base-cofins / 100.
            end.
            else do:
                tt-movto.base-cofins        = 0.
                tt-movto.valor-cofins       = 0.
                tt-movto.cd-trib-COFINS     = 2.
            end.
        end.
    end.

    if can-find(first tt-movto) then do:
        if not l-erro then
        run PiGeraMovimento (input table tt-movto,   
                             input '').
        for each tt-movto:         delete tt-movto.         end.
    end.
    else do:
        run pi-gera-log (input "Documento n∆o possui Itens. Docto: " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s) + " Estab.: " + c-cod-estabel,
                         input 1).
    end.
    release int_ds_nota_entrada.
end.

/* fechamento do output do relatÛrio  */
IF tt-param.arquivo <> "" THEN DO:

    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.
run pi-finalizar in h-acomp.
for each tt-versao-integr. delete tt-versao-integr. end.
for each tt-docum-est-nova:     delete tt-docum-est-nova.     end.
for each tt-item-doc-est-nova:  delete tt-item-doc-est-nova.  end.
for each tt-dupli-apagar:  delete tt-dupli-apagar.  end.
for each tt-dupli-imp:     delete tt-dupli-imp.     end.
for each tt-unid-neg-nota: delete tt-unid-neg-nota. end.
for each tt-erro:          delete tt-erro.          end.
for each tt-movto:         delete tt-movto.         end.
/*
/*RUN pi-Geraint042.

PROCEDURE pi-Geraint042:

    EMPTY TEMP-TABLE tt-param.

    create  tt-param.
    assign  tt-param.destino          = 2
            tt-param.arquivo          = "INT042.LST"
            tt-param.usuario          = "rpw"
            tt-param.data-exec        = today
            tt-param.hora-exec        = time
            tt-param.classifica       = 0
            tt-param.desc-classifica  = ""
            tt-param.cod-emitente-fim = 999999999
            tt-param.cod-emitente-ini = 0
            tt-param.cod-estabel-fim  = "ZZZZZ"
            tt-param.cod-estabel-ini  = ""
            tt-param.dt-emis-nota-fim = ?
            tt-param.dt-emis-nota-ini = ?
            tt-param.nro-docto-fim    = 999999999
            tt-param.nro-docto-ini    = 0
            tt-param.serie-docto-fim  = "ZZZZZ"
            tt-param.serie-docto-ini  = "".
    raw-transfer tt-param to raw-param.

    RUN intprg/int042rp-old.p ( INPUT raw-param , 
                                input table tt-raw-digita).
    EMPTY TEMP-TABLE tt-param.

END.

*/
*/
return "OK":U.

PROCEDURE pi-alteraNaturOper:

    def input parameter r-natur-oper as ROWID no-undo. 
    def input parameter l-transf as LOGICAL no-undo. 
    
    ASSIGN i-lock = 0.
    blk_repeat:
    REPEAT WHILE i-lock <= i-tempoLock:
        FIND FIRST b-natur-oper EXCLUSIVE-LOCK
            where rowid(b-natur-oper) = r-natur-oper no-wait no-error.

        IF LOCKED b-natur-oper THEN DO:
            run pi-acompanhar in h-acomp (input "Registro Natur-oper em uso, 1: " + STRING(i-lock) ).
            ASSIGN i-lock = i-lock + 1.
            FIND CURRENT b-natur-oper NO-LOCK NO-ERROR.
            RELEASE b-natur-oper.
            PAUSE random(0,2) NO-MESSAGE.
        END.
        ELSE DO:
            IF AVAIL b-natur-oper THEN
                ASSIGN b-natur-oper.transf = l-transf.
            FIND CURRENT b-natur-oper NO-LOCK NO-ERROR.
            RELEASE b-natur-oper.
            LEAVE blk_repeat.

        END.
    END.
    
  /*      
    FIND FIRST b-natur-oper EXCLUSIVE-LOCK
            where rowid(b-natur-oper) = r-natur-oper no-error.
    IF AVAIL b-natur-oper AND THEN
        ASSIGN b-natur-oper.transf = l-transf.     */
        
    RELEASE b-natur-oper.
END.

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
              by tt-movto.nr-sequencia:

        for first tt-docum-est-nova where 
            tt-docum-est-nova.serie-docto       = tt-movto.serie         and
            tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis   and
            tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente: end.
        if not avail tt-docum-est-nova then do:
            
            create tt-docum-est-nova.
            assign tt-docum-est-nova.registro          = 2
                   tt-docum-est-nova.serie-docto       = tt-movto.serie 
                   tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis
                   tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente
                   tt-docum-est-nova.nat-operacao      = c-nat-principal
                   tt-docum-est-nova.cod-observa       = tt-movto.tipo-compra
                   tt-docum-est-nova.cod-estabel       = tt-movto.cod-estabel
                   tt-docum-est-nova.estab-fisc        = tt-movto.cod-estabel
                   tt-docum-est-nova.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                            estab-mat.conta-transf
                                                         &else
                                                            estab-mat.cod-cta-transf-unif
                                                         &endif                                            
                   tt-docum-est-nova.sc-transit        = ""
                   tt-docum-est-nova.dt-emissao        = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-trans          = tt-movto.dt-trans
                   tt-docum-est-nova.usuario           = c-seg-usuario
                   tt-docum-est-nova.uf                = tt-movto.uf
                   tt-docum-est-nova.via-transp        = 1
                   tt-docum-est-nova.mod-frete         = tt-movto.mod-frete
                   tt-docum-est-nova.nff               = no
                   tt-docum-est-nova.tot-desconto      = tt-movto.tot-desconto
                   tt-docum-est-nova.valor-frete       = tt-movto.tot-frete 
                   tt-docum-est-nova.valor-seguro      = tt-movto.tot-seguro
                   tt-docum-est-nova.valor-embal       = 0
                   tt-docum-est-nova.valor-outras      = tt-movto.tot-despesas
                   tt-docum-est-nova.dt-venc-ipi       = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-venc-icm       = tt-movto.dt-emissao
                                                         /*1 - efetua os c·lculos - <> 1 valor informado*/
                   tt-docum-est-nova.efetua-calculo    = /*1 */ 2 /* alterdo p¢s c†lculo PIS/COFINS - AV  07/06/2017 */
                   tt-docum-est-nova.sequencia         = 1
                   tt-docum-est-nova.esp-docto         = 23 /* NFT */
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

        FIND FIRST tt-item-doc-est-nova where 
            tt-item-doc-est-nova.serie-docto       = tt-movto.serie                  and
            tt-item-doc-est-nova.nro-docto         = tt-movto.nr-nota-fis            and
            tt-item-doc-est-nova.cod-emitente      = tt-movto.cod-emitente           AND
            tt-item-doc-est-nova.nat-operacao      = tt-docum-est-nova.nat-operacao  AND      
            tt-item-doc-est-nova.sequencia         = tt-movto.nr-sequencia          
            NO-ERROR.

        IF NOT AVAIL tt-item-doc-est-nova  THEN DO: 

            create tt-item-doc-est-nova.
            assign tt-item-doc-est-nova.registro           = 3
                   tt-item-doc-est-nova.it-codigo          = tt-movto.it-codigo
                   tt-item-doc-est-nova.cod-refer          = ""
                   tt-item-doc-est-nova.numero-ordem       = 0
                   tt-item-doc-est-nova.parcela            = 1
                   tt-item-doc-est-nova.encerra-pa         = yes  
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
                   tt-item-doc-est-nova.ipi-outras         = if tt-movto.cd-trib-ipi = 3 or tt-movto.cd-trib-ipi = 5
                                                             then tt-movto.vl-bipi-it    
                                                             else if tt-movto.cd-trib-ipi = 4 then
                                                                  (tt-movto.valor-mercad - tt-movto.vl-bipi-it)
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
                   tt-item-doc-est-nova.icm-outras         = if (tt-movto.cd-trib-icm = 3 or tt-movto.cd-trib-icm = 5)
                                                             then tt-movto.vl-bicms-it       
                                                             else if tt-movto.cd-trib-icm = 4 then
                                                                  (tt-movto.valor-mercad - tt-movto.vl-bicms-it)
                                                             else 0 
                   tt-item-doc-est-nova.icm-ntrib          = if tt-movto.cd-trib-icm = 2     
                                                             then tt-movto.vl-bicms-it       
                                                             else 0 
                   tt-item-doc-est-nova.valor-icm          = tt-movto.vl-icms-it
                   tt-item-doc-est-nova.base-subs          = tt-movto.vl-bsubs-it  
                   tt-item-doc-est-nova.valor-subs         = tt-movto.vl-icmsub-it 
                   tt-item-doc-est-nova.icm-complem        = 0
                   tt-item-doc-est-nova.ind-icm-ret        = if tt-movto.vl-icmsub-it <> 0 then yes else no
                   tt-item-doc-est-nova.narrativa          = p-narrativa
                   tt-item-doc-est-nova.iss-outras         = 0
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

            
        

            if tt-movto.ct-codigo <> "" then do:
                assign tt-item-doc-est-nova.ct-codigo = tt-movto.ct-codigo
                       tt-item-doc-est-nova.sc-codigo = tt-movto.sc-codigo.
            end.

        END. 

        if last-of (tt-movto.nr-nota-fis) then do:
            for first docum-est of tt-docum-est-nova no-lock
                : end.
            if avail docum-est then return.
            
            //MESSAGE "antes API " SKIP i-volume-notas VIEW-AS ALERT-BOX.
            DO TRANSACTION: 

                FIND FIRST natur-oper NO-LOCK 
                    where natur-oper.nat-operacao = tt-docum-est-nova.nat-operacao 
                      AND natur-oper.transf <> NO NO-ERROR.

                IF AVAIL natur-oper THEN  DO:                        
                    RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                           INPUT NO ).
                END.

                FIND CURRENT b-natur-oper NO-LOCK NO-ERROR.
                RELEASE b-natur-oper.
               /*           
                for each btt-item-doc-est-nova :

                    FIND FIRST natur-oper NO-LOCK 
                        where natur-oper.nat-operacao = btt-item-doc-est-nova.nat-operacao  
                          AND natur-oper.transf <> NO NO-ERROR.  

                    IF AVAIL natur-oper THEN DO:
                        RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                               INPUT NO ).
                    END.
                    
                    FIND CURRENT natur-oper NO-LOCK NO-ERROR.
                    RELEASE natur-oper.
                    
                    FIND first natur-oper NO-LOCK 
                        where natur-oper.nat-operacao = btt-item-doc-est-nova.nat-of  
                          AND natur-oper.transf <> NO NO-ERROR.

                    IF AVAIL natur-oper THEN DO:
                        RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                               INPUT NO ).
                    END.
                    FIND CURRENT b-natur-oper NO-LOCK NO-ERROR.
                    RELEASE b-natur-oper.
                end.   */

                run rep/reapi190b.p persistent set h-api.
                run execute in h-api (input  table tt-versao-integr,
                                      input  table tt-docum-est-nova,
                                      input  table tt-item-doc-est-nova,
                                      input  table tt-dupli-apagar,
                                      input  table tt-dupli-imp,
                                      input  table tt-unid-neg-nota,
                                      output table tt-erro).
                if valid-handle(h-api) then delete procedure h-api no-error.
    
                FIND FIRST natur-oper NO-LOCK 
                    WHERE natur-oper.nat-operacao = tt-docum-est-nova.nat-operacao 
                      AND natur-oper.transf <> YES NO-ERROR.
    
                IF AVAIL natur-oper THEN DO:
                    RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                           INPUT YES ).
                END.
                FIND CURRENT natur-oper NO-LOCK NO-ERROR.
                RELEASE natur-oper. 
                
              /*  for each btt-item-doc-est-nova :
                   /*
                    FIND first natur-oper NO-LOCK 
                        WHERE natur-oper.nat-operacao = btt-item-doc-est-nova.nat-operacao 
                          AND natur-oper.transf <> YES NO-ERROR.
    
                    IF AVAIL natur-oper THEN DO:
                        RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                               INPUT YES ).
                    END.
                    FIND CURRENT b-natur-oper NO-LOCK NO-ERROR.
                    RELEASE b-natur-oper.
                                          */
                    FIND first natur-oper NO-LOCK  
                        WHERE natur-oper.nat-operacao = btt-item-doc-est-nova.nat-of 
                          AND natur-oper.transf <> YES NO-ERROR.
    
                    IF AVAIL natur-oper THEN DO:
                        RUN pi-alteraNaturOper(INPUT ROWID(natur-oper),
                                               INPUT YES ).
                    END.
                    FIND CURRENT natur-oper NO-LOCK NO-ERROR.
                    RELEASE natur-oper.
                end. */
    
                find first tt-erro no-error.
                if avail tt-erro then do:
                   put /*stream str-rp*/ skip(1).
                   for each tt-erro :
                       ASSIGN i-sit-reg = 1.
                       IF tt-erro.cd-erro = 1878 THEN DO:
                          ASSIGN i-sit-reg = 2.
                          for each bint_ds_nota_entrada where
                                   bint_ds_nota_entrada.nen_cnpj_origem_s  = tt-movto.nen_cnpj_origem_s and
                                   bint_ds_nota_entrada.nen_serie_s        = tt-movto.serie and
                                   bint_ds_nota_entrada.nen_notafiscal_n   = integer(tt-movto.nr-nota-fis):
                              assign bint_ds_nota_entrada.nen_conferida_n = 2 
                                     bint_ds_nota_entrada.situacao        = 2 /* processada */.
                              release bint_ds_nota_entrada.
                          end.
                       END.
                       if tt-erro.mensagem matches "*OK*" then do:
                           for each cadast_msg no-lock where cdn_msg = tt-erro.cd-erro :
                               RUN pi-gera-log("Erro API. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                               " SÇrie: " + tt-movto.serie        +
                                               " NF: "  + tt-movto.nr-nota-fis  +
                                               " Natur. Oper.: " + c-nat-principal + 
                                               " Estab.: " + tt-movto.cod-estabel  + " - " +
                                               "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + cadast_msg.des_text_msg,
                                               i-sit-reg).
                           end.
                       end.
                       else do:
                           RUN pi-gera-log("Erro API. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                           " SÇrie: " + tt-movto.serie        +
                                           " NF: "  + tt-movto.nr-nota-fis  +
                                           " Natur. Oper.: " + c-nat-principal + 
                                           " Estab.: " + tt-movto.cod-estabel  + " - " +
                                           "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + tt-erro.mensagem,
                                           i-sit-reg).
                       end.
                   end.
                   return.
                end.
                for first docum-est of tt-docum-est-nova :
                    assign docum-est.estab-de-or = tt-movto.estab-de-or
                           docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                    for each item-doc-est of docum-est,
                        each btt-movto no-lock where
                        btt-movto.serie        = docum-est.serie-docto  and
                        btt-movto.nr-nota-fis  = docum-est.nro-docto    and
                        btt-movto.dt-emissao   = docum-est.dt-emissao   and
                        btt-movto.it-codigo    = item-doc-est.it-codigo and    
                        btt-movto.nr-sequencia = item-doc-est.sequencia :
                        assign  item-doc-est.nro-comp     = item-doc-est.nro-docto 
                                item-doc-est.serie-comp   = item-doc-est.serie-docto
                                item-doc-est.nat-comp     = btt-movto.nat-orig
                                item-doc-est.seq-comp     = item-doc-est.sequencia.
                        release item-doc-est.
                    end.
                    release docum-est.
                end.
            END.  /* fim do transaction */

            //MESSAGE "depois API " SKIP i-volume-notas VIEW-AS ALERT-BOX.
            
            for first docum-est no-lock of tt-docum-est-nova:

                empty temp-table tt-bo-docum-est.
                create tt-bo-docum-est.
                buffer-copy docum-est to tt-bo-docum-est
                    assign tt-bo-docum-est.r-docum-est = rowid(docum-est)
                    tt-bo-docum-est.estab-de-or        = tt-movto.estab-de-or
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
                        for each rowErrors:

                            RUN pi-gera-log("Erro BO. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                   " SÇrie: " + tt-movto.serie        +
                                   " NF: "  + tt-movto.nr-nota-fis  +
                                   " Natur. Oper.: " + c-nat-principal +
                                   " Estab.: " + tt-movto.cod-estabel  + " - " +
                                   "Cod. Erro: " + string(rowErrors.errorNumber) + " - " + rowErrors.errorDescription,
                                   1).
                        end.
                    end.
                    if valid-handle(h-boin090) then delete procedure h-boin090.
                end.

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

                        IF int_ds_nota_entrada_produt.nep_baseisenta_n > 0 THEN DO: //arrumando base icms isento - KML 20/04/2023

                            FIND FIRST bitem-doc-est EXCLUSIVE-LOCK
                                WHERE ROWID(bitem-doc-est) = ROWID(item-doc-est) NO-ERROR.
                            ASSIGN bitem-doc-est.icm-ntrib = int_ds_nota_entrada_produt.nep_baseisenta_n.
                            RELEASE bitem-doc-est.

                        END.

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
                           //     END.
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


                /*
                for each item-doc-est no-lock of docum-est:
                    empty temp-table tt-bo-item-doc-est.
                    create tt-bo-item-doc-est.
                    buffer-copy item-doc-est to tt-bo-item-doc-est
                        assign tt-bo-item-doc-est.r-item-doc-est = rowid(item-doc-est).
                    assign  tt-bo-item-doc-est.nro-comp     = item-doc-est.nro-docto 
                            tt-bo-item-doc-est.serie-comp   = item-doc-est.serie-docto
                            tt-bo-item-doc-est.nat-comp     = tt-movto.nat-orig
                            tt-bo-item-doc-est.seq-comp     = item-doc-est.sequencia.
                               
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
                            for each rowErrors
                                query-tuning(no-lookahead):
                                RUN pi-gera-log("Erro BO. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                       " SÇrie: " + tt-movto.serie        +
                                       " NF: "  + tt-movto.nr-nota-fis  +
                                       " Natur. Oper.: " + c-nat-principal +
                                       " Estab.: " + tt-movto.cod-estabel  + " - " +
                                       "Cod. Erro: " + string(rowErrors.errorNumber) + " - " + rowErrors.errorDescription,
                                       1).
                            end.
                        end.
                        if valid-handle(h-boin176) then delete procedure h-boin176.
                    end.
                    
                    run pi-gera-int-ds-doc.
                    
                end. /* item-doc-est */
                */
               /* create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int142-re1005.txt"
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
                         */
                release docum-est.
                for each bint_ds_nota_entrada where
                    bint_ds_nota_entrada.nen_cnpj_origem_s = tt-movto.nen_cnpj_origem_s and
                    bint_ds_nota_entrada.nen_serie_s = tt-movto.serie and
                    bint_ds_nota_entrada.nen_notafiscal_n = integer(tt-movto.nr-nota-fis):
                    assign  bint_ds_nota_entrada.nen_conferida_n = 2 /* conferida */
                            bint_ds_nota_entrada.situacao        = 2 /* processada */
                            bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.
                    release bint_ds_nota_entrada.

                    FIND FIRST b-int_dp_nota_entrada_ret EXCLUSIVE-LOCK
                        WHERE ROWID(b-int_dp_nota_entrada_ret) = ROWID(int_dp_nota_entrada_ret) NO-ERROR.
                    IF AVAIL b-int_dp_nota_entrada_ret THEN
                        assign  b-int_dp_nota_entrada_ret.situacao     = 2.
                    release b-int_dp_nota_entrada_ret.
                end.
                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " SÇrie: " + tt-movto.serie        +
                                " NF: "  + tt-movto.nr-nota-fis  +
                                " Natur. Oper.: " + c-nat-principal + 
                                " Estab.: " + tt-movto.cod-estabel +
                                " - " + "Documento gerado com sucesso!",
                                2).
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

    if avail tt-movto then do: 
        IF tt-param.arquivo <> "" THEN DO:
            put /*stream str-rp*/ unformatted
                tt-movto.nen_cnpj_origem_s + "/" + 
                trim(tt-movto.serie) + "/" + 
                trim(string(tt-movto.nr-nota-fis)) + "/" + 
                trim(string(tt-movto.nen_cfop_n)) + "/" + 
                trim(string(tt-movto.cod-estabel)) + " - " + 
                c-informacao
                skip.
        END.

        /* INICIO - Gravaá∆o LOG Tabela para a PROCFIT */
        FIND CURRENT int_ds_nota_entrada NO-LOCK NO-ERROR.
        IF AVAIL int_ds_nota_entrada THEN DO:
           IF int_ds_nota_entrada.situacao = 2 THEN DO:

                FIND FIRST bint_dp_nota_entrada_ret 
                    WHERE bint_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND bint_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n 
                      AND bint_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s
                   EXCLUSIVE-LOCK NO-ERROR.

               IF AVAIL bint_dp_nota_entrada_ret THEN DO:                                         
                   ASSIGN bint_dp_nota_entrada_ret.envio_status      = 8
                          bint_dp_nota_entrada_ret.retorno_validacao = "".
               END.

           END.
           ELSE IF int_ds_nota_entrada.situacao = 1 OR int_ds_nota_entrada.situacao = 9 THEN DO:

                FIND FIRST bint_dp_nota_entrada_ret 
                    WHERE bint_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND bint_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n  
                      AND bint_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s
                   EXCLUSIVE-LOCK NO-ERROR.
               IF AVAIL bint_dp_nota_entrada_ret THEN DO:   
                   ASSIGN bint_dp_nota_entrada_ret.envio_status      = 9
                          bint_dp_nota_entrada_ret.retorno_validacao = substring(c-informacao,1,500).
               END.

           END.
           RELEASE bint_dp_nota_entrada_ret.
        END.
        /* FIM    - Gravaá∆o LOG Tabela para a PROCFIT */

        RUN intprg/int999.p ("NFE", 
                             tt-movto.nen_cnpj_origem_s + "/" +          
                             trim(tt-movto.serie) + "/" +                
                             trim(string(tt-movto.nr-nota-fis)) + "/" +  
                             trim(string(tt-movto.nen_cfop_n)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "int142rp.p").
    end.
    else do:
        IF tt-param.arquivo <> "" THEN DO:
            put /*stream str-rp*/ unformatted
                int_ds_nota_entrada.nen_cnpj_origem_s + "/" + 
                trim(string(int_ds_nota_entrada.nen_serie_s)) + "/" + 
                trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) + "/" + 
                trim(string(int_ds_nota_entrada.nen_cfop_n)) + " - " + 
                c-informacao
                skip.
        END.


        /* INICIO - Gravaá∆o LOG Tabela para a PROCFIT */
        FIND CURRENT int_ds_nota_entrada NO-LOCK NO-ERROR.
        IF AVAIL int_ds_nota_entrada THEN DO:
           IF int_ds_nota_entrada.situacao = 2 THEN DO:

                FIND FIRST bint_dp_nota_entrada_ret 
                    WHERE bint_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND bint_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n 
                      AND bint_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s
                   EXCLUSIVE-LOCK NO-ERROR.

               IF AVAIL bint_dp_nota_entrada_ret THEN DO:                                         
                   ASSIGN bint_dp_nota_entrada_ret.envio_status      = 8
                          bint_dp_nota_entrada_ret.retorno_validacao = "".
               END.

           END.
           ELSE IF int_ds_nota_entrada.situacao = 1 OR int_ds_nota_entrada.situacao = 9 THEN DO:

                FIND FIRST bint_dp_nota_entrada_ret 
                    WHERE bint_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND bint_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n  
                      AND bint_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s
                   EXCLUSIVE-LOCK NO-ERROR.
               IF AVAIL bint_dp_nota_entrada_ret THEN DO:                                         
                   ASSIGN bint_dp_nota_entrada_ret.envio_status      = 9
                          bint_dp_nota_entrada_ret.retorno_validacao = substring(c-informacao,1,500).
               END.

           END.
           RELEASE bint_dp_nota_entrada_ret.
        END.
        /* FIM    - Gravaá∆o LOG Tabela para a PROCFIT */

        RUN intprg/int999.p ("NFE", 
                             int_ds_nota_entrada.nen_cnpj_origem_s + "/" + 
                             trim(string(int_ds_nota_entrada.nen_serie_s)) + "/" + 
                             trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) + "/" + 
                             trim(string(int_ds_nota_entrada.nen_cfop_n)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "int142rp.p").
    end.
    if i-situacao = 1 then l-erro = yes.

end.

/*
procedure pi-gera-int-ds-doc:
    define buffer uf-origem for unid-feder.
    define buffer uf-destino for unid-feder.
    define variable de-icms-origem as decimal no-undo.
    define variable de-icms-destino as decimal no-undo.
    define variable i-ind as integer no-undo.

    for first int-ds-doc exclusive where
        int-ds-doc.serie-docto = docum-est.serie-docto and
        int-ds-doc.nro-docto = docum-est.nro-docto and
        int-ds-doc.cod-emitente = docum-est.cod-emitente and
        int-ds-doc.nat-operacao = docum-est.nat-operacao and
        int-ds-doc.tipo_nota = docum-est.tipo_nota: end.
    if not avail int-ds-doc then do:
        create int-ds-doc.
        buffer-copy docum-est except docum-est.cod-estabel to int-ds-doc
            assign  int-ds-doc.cod-estabel      = trim(docum-est.cod-estabel)
                    int-ds-doc.situacao         = 3 /* fiscal */
                    int-ds-doc.usuario          = c-seg-usuario
                    int-ds-doc.tipo_movto       = 1 /* inclusao */
                    int-ds-doc.sit-re           = 5 /* rec fiscal */

                    int-ds-doc.chnfe            = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                       substring(docum-est.char-1,93,60)
                                                  &else
                                                       docum-est.cod-chave-aces-nf-eletro
                                                  &endif
                    int-ds-doc.dt_geracao       = today
                    int-ds-doc.hr_geracao       = string(time,"HH:MM:SS")
                    int-ds-doc.situacao_int     = 1 /* pendente */
                    int-ds-doc.nen_chaveacesso  = trim(int-ds-doc.chnfe)
                    int-ds-doc.nen_serie_s      = trim(docum-est.serie-docto)
                    int-ds-doc.nen_notafiscal_n = int(docum-est.nro-docto)
                    int-ds-doc.nen_emissao_d    = docum-est.dt-emissao
                    int-ds-doc.nen_seguro_n     = docum-est.valor-seguro
                    int-ds-doc.nen_entrega_d    = docum-est.dt-trans
                    int-ds-doc.nen_acrescimo_n  = 0
                    int-ds-doc.nen_descontofinanceiro_n = 0.
    end.
    for first natur-oper fields (cod-cfop ind-it-icms) no-lock where 
        natur-oper.nat-operacao = docum-est.nat-operacao:
        assign int-ds-doc.nen_cfop_n = int(natur-oper.cod-cfop).
    end.
    for first estabelec fields (ep-codigo cgc estado pais) no-lock where 
        estabelec.cod-estabel = docum-est.cod-estabel:
        assign  int-ds-doc.ep-codigo = int(estabelec.ep-codigo)
                int-ds-doc.nen_destino_n = trim(estabelec.cgc)
                int-ds-doc.nen_entidadedestino_n = int-ds-doc.nen_destino_n.
    end.
    for first emitente fields (cgc pais estado) no-lock where 
        emitente.cod-emitente = docum-est.cod-emitente:
        assign  int-ds-doc.nen_origem_n = trim(emitente.cgc).
                int-ds-doc.nen_entidadeorigem_n = int-ds-doc.nen_origem_n.
    end.

    de-icms-origem = 0.
    de-icms-destino = 0.
    if emitente.estado <> estabelec.estado then do:
        for first uf-origem no-lock where 
            uf-origem.pais = emitente.pais and
            uf-origem.estado = emitente.estado
            query-tuning(no-lookahead): 
            assign de-icms-origem = uf-origem.per-icms-ext.
            do i-ind = 1 to 12:
                if uf-origem.est-exc[i-ind] = estabelec.estado then 
                    assign de-icms-origem = uf-origem.PERC-exc[i-ind].
            end.
        end.
        for first uf-destino no-lock where 
            uf-destino.pais = estabelec.pais and
            uf-destino.estado = estabelec.estado
            query-tuning(no-lookahead): 
            assign de-icms-origem = UF-destino.per-icms-int.
        end.

    end.
    for each item-doc-est no-lock of docum-est:
        assign  int-ds-doc.nen_pedido_n = item-doc-est.num-pedido.
        assign  int-ds-doc.nen_valortotalprodutos_n     = int-ds-doc.nen_valortotalprodutos_n 
                                                        + item-doc-est.preco-total[1]
                int-ds-doc.nen_valortotalcontabil_n     = int-ds-doc.nen_valortotalcontabil_n 
                                                        + item-doc-est.preco-total[1]
                int-ds-doc.nen_valoripi_n               = int-ds-doc.nen_valoripi_n           
                                                        + item-doc-est.valor-ipi[1]
                int-ds-doc.nen_valoricms_n              = int-ds-doc.nen_valoricms_n          
                                                        + item-doc-est.valor-icm[1]
                int-ds-doc.nen_valorcalculadost_n       = int-ds-doc.nen_valorcalculadost_n   
                                                        + item-doc-est.vl-subs[1]
                int-ds-doc.nen_quantidadeproduto_n      = int-ds-doc.nen_quantidadeproduto_n  
                                                        + item-doc-est.quantidade
                int-ds-doc.nen_quantidadeitens_n        = int-ds-doc.nen_quantidadeitens_n + 1
                int-ds-doc.nen_pis_n                    = int-ds-doc.nen_pis_n  
                                                        + item-doc-est.valor-pis
                int-ds-doc.nen_icmsst_n                 = int-ds-doc.nen_icmsst_n             
                                                        + item-doc-est.vl-subs[1]
                int-ds-doc.nen_guiast_n                 = int-ds-doc.nen_guiast_n 
                                                        + item-doc-est.vl-subs[1]
                int-ds-doc.nen_frete_n                  = int-ds-doc.nen_frete_n              
                                                        + item-doc-est.valor-frete
                int-ds-doc.nen_despesas_n               = int-ds-doc.nen_despesas_n           
                                                        + item-doc-est.despesas[1]
                int-ds-doc.nen_desconto_n               = int-ds-doc.nen_desconto_n  
                                                        + item-doc-est.desconto[1]
                int-ds-doc.nen_cofins_n                 = int-ds-doc.nen_cofins_n             
                                                        + item-doc-est.val-cofins
                int-ds-doc.nen_basest_n                 = int-ds-doc.nen_basest_n             
                                                        + item-doc-est.base-subs[1]
                int-ds-doc.nen_basepis_n                = int-ds-doc.nen_basepis_n            
                                                        + item-doc-est.base-pis
                int-ds-doc.nen_baseisenta_n             = int-ds-doc.nen_baseisenta_n         
                                                        + item-doc-est.icm-ntrib[1]
                int-ds-doc.nen_baseicms_n               = int-ds-doc.nen_baseicms_n           
                                                        + item-doc-est.base-icm[1]
                int-ds-doc.nen_basediferido_n           = int-ds-doc.nen_basediferido_n       
                                                        + item-doc-est.icm-outras[1]
                int-ds-doc.nen_basecofins_n             = int-ds-doc.nen_basecofins_n         
                                                        + item-doc-est.base-pis
                int-ds-doc.nen_cfopsubstituicao_n       = if item-doc-est.vl-subs[1] > 0 
                                                          then int(natur-oper.cod-cfop) 
                                                          else int-ds-doc.nen_cfopsubstituicao_n.

        if de-icms-destino > de-icms-origem then do:
            assign int-ds-doc.nen_repasse_n             = int-ds-doc.nen_repasse_n
                                                        + ((de-icms-destino - de-icms-origem) / 100 * item-doc-est.base-icm[1]).
        end.

        for first int-ds-it-doc exclusive where
            int-ds-it-doc.serie-docto = docum-est.serie-docto and
            int-ds-it-doc.nro-docto = docum-est.nro-docto and
            int-ds-it-doc.cod-emitente = docum-est.cod-emitente and
            int-ds-it-doc.nat-operacao = docum-est.nat-operacao and
            int-ds-it-doc.tipo_nota = docum-est.tipo_nota and
            int-ds-it-doc.sequencia = item-doc-est.sequencia
            query-tuning(no-lookahead): end.
        if not avail int-ds-it-doc then do:
            create  int-ds-it-doc.
            buffer-copy item-doc-est to int-ds-it-doc.
        end.
        assign  int-ds-it-doc.nep_valorunitario_n       = item-doc-est.preco-unit[1]
                int-ds-it-doc.nep_valorpis_n            = item-doc-est.valor-pis
                int-ds-it-doc.nep_valorliquido_n        = item-doc-est.preco-total[1]
                int-ds-it-doc.nep_valoripi_n            = item-doc-est.valor-ipi[1]
                int-ds-it-doc.nep_valoricms_n           = item-doc-est.valor-icm[1]
                int-ds-it-doc.nep_valoricmsst_n         = item-doc-est.vl-subs[1]
                int-ds-it-doc.nep_valordespesas_n       = item-doc-est.despesas[1]
                int-ds-it-doc.nep_valordesconto_n       = item-doc-est.desconto[1]
                int-ds-it-doc.nep_valorcofins_n         = item-doc-est.val-cofins
                int-ds-it-doc.nep_sequencia_n           = item-doc-est.sequencia
                int-ds-it-doc.nep_quantidade_n          = item-doc-est.quantidade
                int-ds-it-doc.nep_produto_n             = int(item-doc-est.it-codigo)
                int-ds-it-doc.nep_percentualreducao_n   = item-doc-est.val-perc-red-icms
                int-ds-it-doc.nep_percentualipi_n       = item-doc-est.val-perc-rep-ipi
                int-ds-it-doc.nep_percentualicms_n      = item-doc-est.aliquota-icm
                int-ds-it-doc.nep_percentualicmsst_n    = (item-doc-est.vl-subs[1] / item-doc-est.base-subs[1]) * 100
                int-ds-it-doc.nep_lote_s                = item-doc-est.lote
                int-ds-it-doc.nep_cfop_n                = int(natur-oper.cod-cfop)
                int-ds-it-doc.nep_basest_n              = item-doc-est.base-subs[1]
                int-ds-it-doc.nep_basepis_n             = item-doc-est.base-pis
                int-ds-it-doc.nep_baseisenta_n          = item-doc-est.icm-ntrib[1]
                int-ds-it-doc.nep_baseipi_n             = item-doc-est.base-ipi[1]
                int-ds-it-doc.nep_baseicms_n            = item-doc-est.base-icm[1]
                int-ds-it-doc.nep_basediferido_n        = item-doc-est.icm-outras[1]
                int-ds-it-doc.nep_basecofins_n          = item-doc-est.base-pis
                int-ds-it-doc.nen_serie_s               = trim(item-doc-est.serie-docto)
                int-ds-it-doc.nen_origem_n              = trim(emitente.cgc)
                int-ds-it-doc.nen_notafiscal_n          = int(item-doc-est.nro-docto)
                int-ds-it-doc.nen_cfop_n                = int-ds-it-doc.nep_cfop_n.


        if item-doc-est.cd-trib-icm = 1 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int-ds-it-doc.nep_csta_n = 0.
                else int-ds-it-doc.nep_csta_n = 1.
        end.
        if item-doc-est.cd-trib-icm = 2 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int-ds-it-doc.nep_csta_n = 4.
                else int-ds-it-doc.nep_csta_n = 3.
        end.
        if item-doc-est.cd-trib-icm = 3 then do:
            int-ds-it-doc.nep_csta_n = 90.
        end.
        if item-doc-est.cd-trib-icm = 4 then do:
            if item-doc-est.vl-subs[1] = 0 
                then int-ds-it-doc.nep_csta_n = 2.
                else int-ds-it-doc.nep_csta_n = 7.
        end.
        if item-doc-est.cd-trib-icm = 5 then do:
            int-ds-it-doc.nep_csta_n = 5.
        end.
        if natur-oper.ind-it-icms then do:
            int-ds-it-doc.nep_csta_n = 6.
        end.
    end.
end.
*/
