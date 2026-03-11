/********************************************************************************
** Programa: int0142-ecom - Importaá∆o de Notas de Entrada do VNDA - Transferencias
**
** Versao : 01 - 14/04/2024 - KML Consultoria
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i int142rp 1.00.001.KML}
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
    field cod-emitente     as integer
    field cod-estabel      as CHAR
    field dt-emis-nota     as DATE
    field nro-docto        as INT64
    field serie-docto      as CHAR.

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
    
def TEMP-TABLE tt-erro no-undo
    field identif-segment as char
    field cd-erro         as integer
    field desc-erro       as char format "x(80)".
    
    

/******* TEMP TABLES DA API *****************/

{btb/btb009za.i}
{cdp/cdcfgcex.i}
{cdp/cdcfgmat.i} 
//{rep/reapi191.i1}
//{rep/reapi190b.i}

{inbo/boin090.i tt-docum-est}       /* Defini√ß√£o TT-DOCUM-EST       */
{inbo/boin366.i tt-rat-docum}       /* Defini√ß√£o TT-RAT-DOCUM       */
{inbo/boin176.i tt-item-doc-est}    /* Defini√ß√£o TT-ITEM-DOC-EST    */
{inbo/boin092.i tt-dupli-apagar}    /* Defini√ß√£o TT-DUPLI-APAGAR    */
{inbo/boin567.i tt-dupli-imp}       /* Defini√ß√£o TT-DUPLI-IMP       */
//{inbo/boin087.i tt-despesa-aces}    /* defini√ßao tt-despesa-aces    */


define temp-table tt-bo-docum-est no-undo
    like docum-est
    field r-docum-est as rowid.

define temp-table tt-bo-item-doc-est no-undo
    like item-doc-est
    field r-item-doc-est as rowid.
    
DEFINE TEMP-TABLE tt-raw-digita
    FIELD raw-digita      AS RAW.

{method/dbotterr.i}

/* recebimento de par‚metros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita.
DEF OUTPUT PARAMETER c-retorno AS CHAR.


//ASSIGN c-retorno = "N∆o processado nota fiscal".


log-manager:write-message("KML - int142-ecom - entrou programa v2" ) NO-ERROR.  


create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 

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
DEF VAR i-tempoLock     AS INT INIT 10 NO-UNDO.


DEFINE VARIABLE h-reapi414 AS HANDLE      NO-UNDO.

DEFINE VARIABLE c-cod-sit-tribut-icms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-ipi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-pis    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-cofins AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-aliq-pis             AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins          AS DECIMAL     NO-UNDO.


def buffer bint_ds_nota_entrada for int_ds_nota_entrada.
def buffer btt-item-doc-est-nova for tt-item-doc-est.
def buffer btt-movto for tt-movto.
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

assign c-programa     = "int142"
       c-versao       = "2.13"
       c-revisao      = ".05.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Transferencias Recebimento".


run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock
    : end.
for first mgadm.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin
    : end.
assign c-empresa = mgadm.empresa.razao-social.

DEFINE BUFFER bestabelec FOR estabelec.
DEFINE BUFFER b-int_ds_nota_entrada FOR int_ds_nota_entrada.
DEFINE BUFFER b2-nota-fiscal FOR nota-fiscal.
DEFINE BUFFER b-natur-oper FOR natur-oper.

/******* LE NOTA E GERA TEMP TABLES  *************/

log-manager:write-message("KML - int142-ecom - antes for first - " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR.  

     
FIND FIRST estabelec
    WHERE estabelec.cod-estabel = tt-param.cod-estabel NO-ERROR.
     
for-nota:
FOR FIRST int_ds_nota_entrada no-lock where
    int_ds_nota_entrada.situacao >= 1 AND
   // int_ds_nota_entrada.nen_conferida_n < 2 and 
    int_ds_nota_entrada.nen_dataemissao_d = tt-param.dt-emis-nota AND
    int_ds_nota_entrada.nen_serie_s = tt-param.serie-docto AND
    int_ds_nota_entrada.nen_notafiscal_n = tt-param.nro-docto AND
    int_ds_nota_entrada.nen_cnpj_origem_s = estabelec.cgc AND 
    int_ds_nota_entrada.tipo_nota = 3 :

    //  MESSAGE int_ds_nota_entrada.nen_notafiscal_n VIEW-AS ALERT-BOX.
      
    log-manager:write-message("KML - int142-ecom - dentro for each " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR. 
    
    FIND FIRST bestabelec NO-LOCK
        WHERE bestabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino NO-ERROR.

    IF NOT AVAIL bestabelec THEN DO:

        //MESSAGE "Estabelecimento n∆o cadastrado com o CNPJ: " + string(int_ds_nota_entrada.nen_cnpj_destino) VIEW-AS ALERT-BOX.
    END.

    for first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = bestabelec.cod-estabel and
        cst_estabelec.dt_inicio_oper <> ?
        : end.
    if not avail cst_estabelec then next.   

    assign d-data-movimento = TODAY.
    
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
    
    
/*     for first docum-est no-lock USE-INDEX documento where                                           */
/*         docum-est.serie-docto  = int_ds_nota_entrada.nen_serie_s and                                */
/*         docum-est.nro-docto    = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) and */
/*         docum-est.cod-emitente = emitente.cod-emitente:                                             */
/*                                                                                                     */
/*         run pi-gera-log (input "Documento j† cadastrado: "                                          */
/*                          + "SÇrie: "     + docum-est.serie-docto                                    */
/*                          + " Numero: "   + docum-est.nro-docto                                      */
/*                          + " Forn: "     + string(docum-est.cod-emitente)                           */
/*                          + " Natureza: " + docum-est.nat-operacao,                                  */
/*                          input 2).                                                                  */
/*         for each bint_ds_nota_entrada where                                                         */
/*             bint_ds_nota_entrada.nen_cnpj_origem_s  = int_ds_nota_entrada.nen_cnpj_origem_s and     */
/*             bint_ds_nota_entrada.nen_serie_s        = int_ds_nota_entrada.nen_serie_s       and     */
/*             bint_ds_nota_entrada.nen_notafiscal_n   = int_ds_nota_entrada.nen_notafiscal_n:         */
/*                                                                                                     */
/*             assign  bint_ds_nota_entrada.nen_conferida_n = 2                                        */
/*                     bint_ds_nota_entrada.situacao = 2 /* processada */                              */
/*                     bint_ds_nota_entrada.nen_datamovimentacao_d = d-data-movimento.                 */
/*             release bint_ds_nota_entrada.                                                           */
/*                                                                                                     */
/*         end.                                                                                        */
/*         empty temp-table tt-movto.                                                                  */
/*         assign l-erro = yes.                                                                        */
/*         next for-nota.                                                                              */
/*     end.                                                                                            */

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
               // next for-nota.
            end.
            empty temp-table tt-movto.
            assign l-erro = yes.
            // next for-nota.
        end.
    end.
    
    log-manager:write-message("KML - int142-ecom - dentro for each 2 " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR.     

    for FIRST int_ds_nota_entrada_produt no-lock where
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

        //MESSAGE "entrou 2"  VIEW-AS ALERT-BOX.
        for first item 
            fields (it-codigo class-fisc tipo-con-est peso-liquido char-1 char-2
                    fm-codigo tipo-contr ct-codigo sc-codigo)
            no-lock where 
            item.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n): 
            c-class-fiscal = trim(item.class-fiscal).
        end.
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
        for first item-uni-estab no-lock where 
            item-uni-estab.cod-estabel = tt-movto.cod-estabel and
            item-uni-estab.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n): 
        end.
        if not avail item-uni-estab THEN DO:
           for first item-estab NO-LOCK where 
               item-estab.cod-estabel = tt-movto.cod-estabel and
               item-estab.it-codigo = string(int_ds_nota_entrada_produt.nep_produto_n): end.
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

       /*   teste por causa do erro 
        
        if c-tp-pedido = "" then
        for first int_ds_pedido no-lock where
            int_ds_pedido.ped_codigo_n = (if int_ds_nota_entrada.ped_procfit <> 0 AND int_ds_nota_entrada.ped_procfit <> ? then 
                                          int_ds_nota_entrada.ped_procfit 
                                          else int_ds_nota_entrada.ped_codigo_n):
            assign c-tp-pedido = trim(string(int_ds_pedido.ped_tipopedido_n)).
        end.
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
        */
        
        IF int_ds_nota_entrada.nen_cnpj_origem_s = "79430682025540"  OR int_ds_nota_entrada.nen_cnpj_origem_s = "79430682057400" THEN
        DO:
        
            c-tp-pedido = "1".  //  transferencia CD x FILIAL
            
        END.
        
        ELSE DO:
            
            ASSIGN c-tp-pedido = "19".  // Sempre transferencia
        END.
        
        /* determina natureza de operacao */
        c-nat-saida = "".
        c-nat-operacao = "".
        run intprg/int115a.p ( input c-tp-pedido   ,
                               input c-uf-destino  ,
                               input c-uf-origem   ,
                               input "" /*nat or*/ ,
                               input i-cod-emitente,
                               input c-class-fiscal,
                               input item.it-codigo	           , /* item */
                               INPUT "", // estabel
                               output c-nat-saida,
                               output c-nat-operacao,
                               output r-rowid).

        if c-nat-operacao = "" then do:
            run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                    "Tp Pedido: " + c-tp-pedido + 
                                    " UF Origem: " + c-uf-origem + 
                                    " UF Destino: " + c-uf-destino + 
                                    " NCM: " + c-class-fiscal,
                             input 1).
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
               tt-movto.qt-recebida     = (int_ds_nota_entrada_produt.nep_quantidade_n)
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

      //  MESSAGE tt-movto.cod-depos VIEW-AS ALERT-BOX.
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

    log-manager:write-message("KML - int142-ecom - dentro for each 3" + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR. 
    
    if can-find(first tt-movto) then do:
        if not l-erro then
        run PiGeraMovimento (input table tt-movto,   
                             input '').
        EMPTY TEMP-TABLE tt-movto.
    end.
    else do:
        run pi-gera-log (input "Documento n∆o possui Itens. Docto: " + string(int_ds_nota_entrada.nen_notafiscal_n) + " SÇrie: " + string(int_ds_nota_entrada.nen_serie_s) + " Estab.: " + c-cod-estabel,
                         input 1).
    end.
    release int_ds_nota_entrada.
    
    
    
    
end.


log-manager:write-message("KML - int142-ecom - depois for first" ) NO-ERROR. 


run pi-finalizar in h-acomp.
//for each tt-versao-integr. delete tt-versao-integr. end.
for each tt-docum-est:     delete tt-docum-est.     end.
for each tt-item-doc-est:  delete tt-item-doc-est.  end.
for each tt-dupli-apagar:  delete tt-dupli-apagar.  end.
for each tt-dupli-imp:     delete tt-dupli-imp.     end.
//for each tt-unid-neg-nota: delete tt-unid-neg-nota. end.
for each tt-erro:          delete tt-erro.          end.
for each tt-movto:         delete tt-movto.         end.

return "OK".


/*
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
END.
 */
procedure PiGeraMovimento:

    
    def input parameter table for tt-movto.
    def input parameter p-narrativa as char no-undo. 
    def var h-api as handle no-undo.
    
    /******* GERA DOCUMENTO PARA DevolucaoS CONFORME PARAMETRO RECEBIDO *************/

    def buffer b-rat-lote for rat-lote.
    
    
    log-manager:write-message("KML - int142-ecom - dentro gera movimento " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR. 
    
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
        
    //create tt-versao-integr.
    //assign tt-versao-integr.registro              = 1
     //      tt-versao-integr.cod-versao-integracao = 004.
    
    
   // MESSAGE "entrou 3" VIEW-AS ALERT-BOX.
   
    ASSIGN c-nat-principal = c-nat-operacao. 
   
    FOR FIRST tt-movto
       /* break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nr-sequencia*/ :              

        for first tt-docum-est where 
            tt-docum-est.serie-docto       = tt-movto.serie         and
            tt-docum-est.nro-docto         = tt-movto.nr-nota-fis   and
            tt-docum-est.cod-emitente      = tt-movto.cod-emitente: end.
        if not avail tt-docum-est then do:
            
            create tt-docum-est.
            assign //tt-docum-est.registro          = 2
                  // tt-docum-est.i-sequencia       = 10
                   tt-docum-est.serie-docto       = tt-movto.serie 
                   tt-docum-est.nro-docto         = tt-movto.nr-nota-fis
                   tt-docum-est.cod-emitente      = tt-movto.cod-emitente
                   tt-docum-est.nat-operacao      = c-nat-principal
                   tt-docum-est.cod-observa       = tt-movto.tipo-compra
                   tt-docum-est.cod-estabel       = tt-movto.cod-estabel
                   tt-docum-est.estab-fisc        = tt-movto.cod-estabel
                   tt-docum-est.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                       estab-mat.conta-transf
                                                    &else
                                                       estab-mat.cod-cta-transf-unif
                                                    &endif                                            
                   tt-docum-est.sc-transit        = ""
                   tt-docum-est.dt-emissao        = tt-movto.dt-emissao
                   tt-docum-est.dt-trans          = tt-movto.dt-trans
                   tt-docum-est.usuario           = c-seg-usuario
                   tt-docum-est.uf                = tt-movto.uf
                   tt-docum-est.via-transp        = 1
                   tt-docum-est.mod-frete         = tt-movto.mod-frete
                   tt-docum-est.nff               = no
                   tt-docum-est.tot-desconto      = tt-movto.tot-desconto
                   tt-docum-est.valor-frete       = tt-movto.tot-frete 
                   tt-docum-est.valor-seguro      = tt-movto.tot-seguro
                   tt-docum-est.valor-embal       = 0
                   tt-docum-est.valor-outras      = tt-movto.tot-despesas
                   tt-docum-est.dt-venc-ipi       = tt-movto.dt-emissao
                   tt-docum-est.dt-venc-icm       = tt-movto.dt-emissao
                                                    /*1 - efetua os c·lculos - <> 1 valor informado*/
                   //tt-docum-est.efetua-calculo    = /*1 */ 2 /* alterdo p¢s c†lculo PIS/COFINS - AV  07/06/2017 */
                   //tt-docum-est.sequencia         = 1
                   tt-docum-est.esp-docto         = 23 /* NFT */
                   tt-docum-est.rec-fisico        = no
                   tt-docum-est.origem            = "" /* verificar*/
                   tt-docum-est.pais-origem       = "Brasil"
                   tt-docum-est.cotacao-dia       = 0
                   tt-docum-est.embarque          = ""   
                   //tt-docum-est.gera-unid-neg     = 0

                   &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        substring(tt-docum-est.char-1,93,60)  = tt-movto.chave-acesso.
                   &else
                        tt-docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                   &endif
                                    

        end. 
        //run pi-acompanhar in h-acomp (input string(tt-movto.nr-sequencia)).

        //if last-of (tt-movto.nr-nota-fis) then do:
            
            log-manager:write-message("KML - int142-ecom - antes criar nota " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR. 
            
            DO TRANSACTION: 
            
                /*
               //  MESSAGE "apagando" VIEW-AS ALERT-BOX.
                 run rep/reapi316b.r (INPUT "DEL",
                                      input  table tt-docum-est,
                                      INPUT  TABLE tt-rat-docum,
                                      input  table tt-item-doc-est,
                                      input  table tt-dupli-apagar,
                                      input  table tt-dupli-imp,
                                      output table tt-erro).
                                              
              //   RUN pi-execute IN h-api.   */                                           
            
                 run rep/reapi316b.r (INPUT "ADD",
                                      input  table tt-docum-est,
                                      INPUT  TABLE tt-rat-docum,
                                      input  table tt-item-doc-est,
                                      input  table tt-dupli-apagar,
                                      input  table tt-dupli-imp,
                                      output table tt-erro).
                                                      
                log-manager:write-message("KML - int142-ecom - **API REAPI316B ** " + "nota - " + STRING(tt-param.nro-docto) ) NO-ERROR. 
                .MESSAGE "Depois execute"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
                
            //    RUN pi-execute IN h-api.

                .MESSAGE "**DEPOIS EXECUTE REAPI316B **" VIEW-AS ALERT-BOX.
                
               // RUN getTTErro IN h-api (OUTPUT TABLE tt-erro). 
                
              //  if valid-handle(h-api) then delete procedure h-api no-error.
    
                  
                find first tt-erro no-error.
                if avail tt-erro then do:
                   put /*stream str-rp*/ skip(1).
                   for each tt-erro :
                   
                        //MESSAGE tt-erro.desc-erro VIEW-AS ALERT-BOX.
                        
                        
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
                       if tt-erro.desc-erro matches "*OK*" then do:
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
                                           "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + tt-erro.desc-erro,
                                           i-sit-reg).
                       end.
                   end.
                  // return.
                end.
                for first docum-est of tt-docum-est :
                    /*assign docum-est.estab-de-or = tt-movto.estab-de-or
                           docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                                                   */
                    for each item-doc-est  of docum-est EXCLUSIVE-LOCK:
                    
                        ASSIGN item-doc-est.cod-depos          = IF tt-movto.cod-depos <> "" THEN tt-movto.cod-depos ELSE "LOJ".
                    
                    END. 
                    
                    for each rat-lote  of docum-est EXCLUSIVE-LOCK:
                    
                        ASSIGN rat-lote.cod-depos          = IF tt-movto.cod-depos <> "" THEN tt-movto.cod-depos ELSE "LOJ".
                    
                    END.                     
                    
                    
                    RELEASE item-doc-est.
                    RELEASE rat-lote.
                    LOG-MANAGER:WRITE-MESSAGE("**ANTES ITEM-DOC-EST **") NO-ERROR.   
                     
                   

                    create tt-param-re1005.
                    assign 
                        tt-param-re1005.destino            = 3
                        tt-param-re1005.arquivo            = "int42-re1005.txt"
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

                    log-manager:write-message("KML - int142-ecom - antes re1005" ) NO-ERROR.
                    raw-transfer tt-param-re1005 to raw-param.
                    run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                    empty temp-table tt-digita-re1005.
                    empty temp-table tt-param-re1005.
                                    
                    
                end.
            END.  /* fim do transaction */
            
            log-manager:write-message("KML - int142-ecom -terminou criar nota" ) NO-ERROR. 

      //  end. /* last-of */
    end. /* tt-movto */
    empty temp-table tt-movto.
    
    DELETE OBJECT h-api NO-ERROR.
    





end procedure. /* PiGeraDocumento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.
    
    
    log-manager:write-message("KML - int142-ecom - dentro pi-gera-log - " + c-informacao + " - " + string(i-situacao)) NO-ERROR.
    
    ASSIGN c-retorno = c-informacao.


end.  
