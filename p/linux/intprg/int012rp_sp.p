/********************************************************************************
** Programa: int012 - Importaá∆o de Notas de Entrada do Toturial/PRS
**
** Versao : 12 - 09/02/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i INT012RP 2.12.05.AVB}
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
    field nen-cnpj-origem-s like int-ds-nota-entrada.nen-cnpj-origem-s
    field nen-cfop-n        like int-ds-nota-entrada.nen-cfop-n
    field numero-ordem      like item-doc-est.numero-ordem
    field parcela           like item-doc-est.parcela
    field num-pedido        like item-doc-est.num-pedido
    field tp-despesa        like dupli-apagar.tp-despesa
    field tipo-nota         like int-ds-nota-entrada.tipo-nota
    field dt-trans          like int-ds-nota-entrada.nen-datamovimentacao-d
    field perc-red-icms     like int-ds-nota-entrada-produto.nep-redutorbaseicms-n
    field vl-icms-des       like int-ds-nota-entrada-produto.nep-valor-icms-des-n
    field cod-cond-pag      like emitente.cod-cond-pag
    field chave-acesso as char.

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
{rep/reapi191.i1}
{rep/reapi190b.i}

define temp-table tt-bo-docum-est no-undo
    like docum-est
    field r-docum-est as rowid.

{method/dbotterr.i}

/* recebimento de parÉmetros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT012.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
def var h-acomp    as handle no-undo.
def var h-boin090  as handle no-undo.
def var h-aux      as handle no-undo.
def var l-erro     as logical no-undo.
def var c-nat-operacao as char no-undo.
def var i-cfop     as integer no-undo.
def var c-cod-estabel as char no-undo.
def var i-ind      as integer no-undo.
def var i-trib-icm as integer no-undo.
def var i-trib-ipi as integer no-undo.

def buffer bint-ds-nota-entrada for int-ds-nota-entrada.

/* definiá∆o de frames do relat¢rio */

for first param-re no-lock where param-re.usuario = c-seg-usuario: end.
if not avail param-re then do:
    return "NOK".
end.

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i &STREAM="str-rp"}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i &stream = "stream str-rp"}
END.

assign c-programa     = "INT012"
       c-versao       = "2.13"
       c-revisao      = ".05.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Documento Recebimento".

IF tt-param.arquivo <> "" THEN DO:
    view stream str-rp frame f-cabec.
    view stream str-rp frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 7
           tt-param.dt-emis-nota-fim = today.

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

/******* LE NOTA E GERA TEMP TABLES  *************/
define buffer B-ESTABELEC for estabelec.
define buffer b-emitente for emitente.
for first b-emitente no-lock where b-emitente.cod-emitente = 9574: end.
for each B-ESTABELEC no-lock where b-estabelec.ESTADO = "sp"
    BY B-ESTABELEC.cod-estabel:

    for-nota:
    for each int-ds-nota-entrada no-lock where
        int-ds-nota-entrada.situacao >= 2 and
        int-ds-nota-entrada.nen-conferida-n = 1 and 
        int-ds-nota-entrada.nen-dataemissao-d >= dt-emis-nota-ini and
        int-ds-nota-entrada.nen-dataemissao-d <= dt-emis-nota-fim and
        int-ds-nota-entrada.nen-serie-s >= serie-docto-ini and
        int-ds-nota-entrada.nen-serie-s <= serie-docto-fim and
        int-ds-nota-entrada.nen-notafiscal-n >= nro-docto-ini and
        int-ds-nota-entrada.nen-notafiscal-n <= nro-docto-fim and
        int-ds-nota-entrada.nen-datamovimentacao-d <> ?   and 
        int-ds-nota-entrada.nen-datamovimentacao-d >= 08/01/2016 and
        int-ds-nota-entrada.nen-cnpj-destino-s = b-estabelec.cgc:


        /*
        put stream str-rp
            UNFORMATTED int-ds-nota-entrada.nen-notafiscal-n skip.
          */
        /* pular notas a serem integradas manualmente pelo int520 */
        if int-ds-nota-entrada.situacao = 5 and nro-docto-ini = 0 then next.

        assign l-erro = no.
        empty temp-table tt-movto.
    
        for first emitente fields (cod-emitente estado tp-desp-padrao     cod-cond-pag) no-lock where 
            emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s: end.
        if not avail emitente then do:
            run pi-gera-log (input "Fornecedor n∆o cadastrado: CNPJ: " + string(int-ds-nota-entrada.nen-cnpj-origem-s),
                             input 1).
            next.
        end.
        if  emitente.cod-emitente < cod-emitente-ini or
            emitente.cod-emitente > cod-emitente-fim then next.
        c-cod-estabel = "".
        for each estabelec 
            fields (cod-estabel estado cidade 
                    cep pais endereco bairro ep-codigo) 
            no-lock where
            estabelec.cgc = int-ds-nota-entrada.nen-cnpj-destino-s,
            first cst-estabelec no-lock where 
            cst-estabelec.cod-estabel = estabelec.cod-estabel and
            cst-estabelec.dt-fim-operacao >= int-ds-nota-entrada.nen-dataemissao-d:
            c-cod-estabel = estabelec.cod-estabel.
            leave.
        end.
        if c-cod-estabel = "" then do:
            run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o: CNPJ: " + int-ds-nota-entrada.nen-cnpj-destino-s,
                             input 1).
            next.
        end.
        if  estabelec.cod-estabel < cod-estabel-ini or
            estabelec.cod-estabel > cod-estabel-fim then next.
    
        for each int-ds-nota-entrada-produto no-lock where
            int-ds-nota-entrada-produto.nen-cnpj-origem-s = int-ds-nota-entrada.nen-cnpj-origem-s and
            int-ds-nota-entrada-produto.nen-serie-s       = int-ds-nota-entrada.nen-serie-s       and
            int-ds-nota-entrada-produto.nen-notafiscal-n  = int-ds-nota-entrada.nen-notafiscal-n
            query-tuning(no-lookahead):
    
            create tt-movto.
            assign tt-movto.serie               = int-ds-nota-entrada.nen-serie-s
                   tt-movto.nr-nota-fis         = trim(string(int-ds-nota-entrada.nen-notafiscal-n,">>9999999"))
                   tt-movto.dt-emissao          = int-ds-nota-entrada.nen-dataemissao-d
                   tt-movto.tot-frete           = int-ds-nota-entrada.nen-frete-n                                              
                   tt-movto.tot-seguro          = int-ds-nota-entrada.nen-seguro-n                                  
                   tt-movto.tot-despesas        = int-ds-nota-entrada.nen-despesas-n
                   tt-movto.tot-desconto        = int-ds-nota-entrada.nen-desconto-n
                   tt-movto.chave-acesso        = int-ds-nota-entrada.nen-chaveacesso-s
                   tt-movto.mod-frete           = int-ds-nota-entrada.nen-modalidade-frete-n
                   tt-movto.nen-cnpj-origem-s   = int-ds-nota-entrada.nen-cnpj-origem-s
                   tt-movto.nen-cfop-n          = int-ds-nota-entrada.nen-cfop-n
                   tt-movto.tp-despesa          = emitente.tp-desp-padrao
                   tt-movto.cod-estabel         = c-cod-estabel
                   tt-movto.cod-emitente        = emitente.cod-emitente
                   tt-movto.uf                  = emitente.estado
                   tt-movto.tipo-nota           = int-ds-nota-entrada.tipo-nota
                   tt-movto.dt-trans            = int-ds-nota-entrada.nen-datamovimentacao-d
                   tt-movto.perc-red-icms       = int-ds-nota-entrada-produto.nep-redutorbaseicms-n
                   tt-movto.vl-icms-des         = int-ds-nota-entrada-produto.nep-valor-icms-des-n
                   tt-movto.cod-cond-pag        = emitente.cod-cond-pag.
    
            if  tt-movto.cod-emitente = 1000 or
                tt-movto.cod-emitente = 5000 or
                tt-movto.cod-emitente = 9574 then do:
                if  day(tt-movto.dt-emissao) >= 1 and 
                    day(tt-movto.dt-emissao) <= 7 then tt-movto.cod-cond-pag = 259.
                else tt-movto.cod-cond-pag = 241.
            end.
    
            for first item 
                fields (it-codigo class-fisc tipo-con-est peso-liquido fm-codigo)
                no-lock where 
                item.it-codigo = string(int-ds-nota-entrada-produto.nep-produto-n): end.
            if not avail item then do:
                run pi-gera-log (input "Item n∆o cadastrado: Produto: " + string(int-ds-nota-entrada-produto.nep-produto-n),
                                 input 1).
                next.
            end.
        
            for first item-estab no-lock where 
                item-estab.cod-estabel = tt-movto.cod-estabel and
                item-estab.it-codigo = string(int-ds-nota-entrada-produto.nep-produto-n): end.
            if not avail item-estab then
                for first item-uni-estab no-lock where 
                    item-uni-estab.cod-estabel = tt-movto.cod-estabel and
                    item-uni-estab.it-codigo = string(int-ds-nota-entrada-produto.nep-produto-n): end.
            if not avail item-estab and not avail item-uni-estab then do:
                run pi-gera-log (input "Item n∆o cadastrado no estabelecimento: Produto: " + string(int-ds-nota-entrada-produto.nep-produto-n) + " Est: " + tt-movto.cod-estabel,
                                 input 1).
                next.
            end.
            i-cfop = int-ds-nota-entrada-produto.nen-cfop-n.
            /* buscar cfop da saida quando for enviada cfop de entrada (notas antigas) */
            if i-cfop < 5000 then do:
                /* transferencias */
                if can-find(first estabelec no-lock where estabelec.cod-emitente = emitente.cod-emitente) then
                for first int-ds-nota-saida-item no-lock where 
                    int-ds-nota-saida-item.nsa-cnpj-origem-s = int-ds-nota-entrada.nen-cnpj-origem-s and
                    int-ds-nota-saida-item.nsa-serie-s       = int-ds-nota-entrada.nen-serie-s       and
                    int-ds-nota-saida-item.nsa-notafiscal-n  = int-ds-nota-entrada.nen-notafiscal-n  and
                    int-ds-nota-saida-item.nsp-produto-n     = int-ds-nota-entrada-produto.nep-produto-n: 
                    i-cfop = int-ds-nota-saida-item.nsp-cfop-n.
                end.
                /* buscar int013 inverso - nota entrada gravada com cfop de entrada deve achar cfop de saida */
                if not avail int-ds-nota-saida-item or i-cfop < 5000 then
                for-nat:
                for each natur-oper fields (nat-operacao cod-cfop)
                    no-lock where natur-oper.cod-cfop = string(i-cfop,"9999"):
                    for first int-ds-cfop-natur-oper fields (nat-operacao nen-cfop-n) no-lock where
                        int-ds-cfop-natur-oper.nat-operacao = natur-oper.nat-operacao:
                        assign i-cfop = int-ds-cfop-natur-oper.nen-cfop-n.
                        leave for-nat.
                    end.
                end.
            end.
            /* tratar natur-oper */
            c-nat-operacao = "".
            RUN intprg/int013a.p( input i-cfop,
                                  input int-ds-nota-entrada-produto.nep-cstb-icm-n,
                                  input /*int-ds-nota-entrada-produto.nep-cstb-ipi-n*/ int(item.fm-codigo),
                                  input tt-movto.cod-estabel,
                                  input tt-movto.cod-emitente,
                                  input tt-movto.dt-emissao,
                                  output c-nat-operacao ).
            if c-nat-operacao = "" then do:
                run pi-gera-log (input "N∆o encontrada natureza de operacao para entrada: " + 
                                        "CFOP Nota: " + string(int-ds-nota-entrada-produto.nen-cfop-n) + 
                                        " CFOP Calc: " + string(i-cfop) + 
                                        " CSTB ICMS: " + string(int-ds-nota-entrada-produto.nep-cstb-icm-n) + 
                                        /*" CSTB IPI:" + string(int-ds-nota-entrada-produto.nep-cstb-ipi-n)*/
                                        " Familia: " + item.fm-codigo + " Est: " + estabelec.cod-estabel,
                                 input 1).
                next.
            end.
            for first natur-oper no-lock where 
                natur-oper.nat-operacao = c-nat-operacao: end.
            if not avail natur-oper then do:
                run pi-gera-log (input "Natureza de operacao nao cadastrada: Nat: " + c-nat-operacao,
                                 input 1).
                next.
            end.
            
            case int-ds-nota-entrada-produto.nep-cstb-icm-n:
                when 00 then i-trib-icm = 1 /* tributado */.
                when 10 then i-trib-icm = 1 /* tributado */.
                when 20 then i-trib-icm = 4 /* reduzido */ .
                when 30 then i-trib-icm = 2 /* isento */   .
                when 40 then i-trib-icm = 2 /* isento */   .
                when 41 then i-trib-icm = 2 /* isento */   .
                when 50 then i-trib-icm = 3 /* outros */   .
                when 60 then i-trib-icm = 1 /* tributado */.
                when 70 then i-trib-icm = 4 /* reduzido */ .
                when 90 then i-trib-icm = 3 /* outros */   .
                otherwise i-trib-icm = 3 /* outros */ .
            end.
    
            case int-ds-nota-entrada-produto.nep-cstb-ipi-n:
                when 00 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
                when 01 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
                when 02 then i-trib-ipi = 2 /* Entrada Isenta */   .
                when 03 then i-trib-ipi = 2 /* Entrada Isenta */ .
                when 04 then i-trib-ipi = 2 /* Entrada Isenta */   .
                when 05 then i-trib-ipi = 3 /* Entrada com Suspens∆o */   .
                when 49 then i-trib-ipi = 3 /* outros */   .
                otherwise i-trib-ipi = 3 /* outros */ .
            end.
    
            assign tt-movto.it-codigo       = string(int-ds-nota-entrada-produto.nep-produto-n)
                   tt-movto.nr-sequencia    = int-ds-nota-entrada-produto.nep-sequencia-n
                   tt-movto.qt-recebida     = int-ds-nota-entrada-produto.nep-quantidade-n
                   tt-movto.cod-depos       = if avail item-uni-estab 
                                              then item-uni-estab.deposito-pad
                                              else item-estab.deposito-pad
                   tt-movto.lote            = if item.tipo-con-est = 3 then int-ds-nota-entrada-produto.nep-lote-s else ""
                   tt-movto.dt-vali-lote    = if item.tipo-con-est = 3 then int-ds-nota-entrada-produto.nep-datavalidade-d else ?
                   tt-movto.valor-mercad    = int-ds-nota-entrada-produto.nep-valorbruto-n
                   tt-movto.desconto        = int-ds-nota-entrada-produto.nep-valordesconto-n
                   tt-movto.vl-despesas     = int-ds-nota-entrada-produto.nep-valordespesa-n
                   tt-movto.cd-trib-ipi     = i-trib-ipi
                   tt-movto.aliquota-ipi    = int-ds-nota-entrada-produto.nep-percentualipi-n
                   tt-movto.tipo-compra     = natur-oper.tipo-compra
                   tt-movto.terceiros       = natur-oper.terceiros
                   tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
                   tt-movto.cd-trib-icm     = i-trib-icm
                   tt-movto.nat-operacao    = natur-oper.nat-operacao
                   tt-movto.aliquota-icm    = int-ds-nota-entrada-produto.nep-percentualicms-n
                   tt-movto.perc-red-icm    = int-ds-nota-entrada-produto.nep-redutorbaseicms-n
                   tt-movto.vl-bicms-it     = int-ds-nota-entrada-produto.nep-baseicms-n
                   tt-movto.vl-icms-it      = int-ds-nota-entrada-produto.nep-valoricms-n
                   tt-movto.vl-bipi-it      = int-ds-nota-entrada-produto.nep-baseipi-n
                   tt-movto.vl-ipi-it       = int-ds-nota-entrada-produto.nep-valoripi-n
                   tt-movto.vl-bsubs-it     = int-ds-nota-entrada-produto.nep-basest-n
                   tt-movto.vl-icmsub-it    = int-ds-nota-entrada-produto.nep-icmsst-n
                   tt-movto.peso-liquido    = item.peso-liquido.
    
            if not can-find (first estabelec no-lock where estabelec.cod-emitente = tt-movto.cod-emitente) then do:
                for first pedido-compr no-lock where pedido-compr.num-pedido = int-ds-nota-entrada.ped-codigo-n:
                    if  pedido-compr.cod-cond-pag <> 0 and 
                        pedido-compr.cod-cond-pag <> ? and
                        pedido-compr.cod-cond-pag <> 999 and
                        pedido-compr.cod-emitente = tt-movto.cod-emitente then 
                        assign tt-movto.cod-cond-pag = pedido-compr.cod-cond-pag.
                    for first ordem-compra fields (numero-ordem it-codigo tp-despesa) no-lock where 
                        ordem-compra.num-pedido = pedido-compr.num-pedido and
                        ordem-compra.it-codigo  = tt-movto.it-codigo:
                        assign tt-movto.tp-despesa = ordem-compra.tp-despesa.
                               tt-movto.numero-ordem = ordem-compra.numero-ordem.
                        for first prazo-compra fields (parcela) no-lock of ordem-compra:
                            assign tt-movto.parcela = prazo-compra.parcela.
                        end.
                    end.
                    if pedido-compr.cod-emitente <> tt-movto.cod-emitente then do:
                        run pi-gera-log (input "Pedido de compra n∆o Ç deste fornecedor. Liberando p/ atualizaá∆o manual: Pedido: " + string(int-ds-nota-entrada.ped-codigo-n),
                                         input 1).
                        for first bint-ds-nota-entrada exclusive where rowid(bint-ds-nota-entrada) = rowid(int-ds-nota-entrada):
                            assign bint-ds-nota-entrada.situacao = 5 /* atualizaá∆o manual */.
                            next for-nota.
                        end.
                    end.
                    assign tt-movto.num-pedido = pedido-compr.num-pedido.
                end.
                if not avail pedido-compr and not param-re.sem-pedido then do:
                    run pi-gera-log (input "N∆o encontrado pedido de compra. Liberando p/ atualizaá∆o manual: " + 
                                            "Pedido: " + string(int-ds-nota-entrada.ped-codigo-n),
                                     input 1).
                    for first bint-ds-nota-entrada exclusive where rowid(bint-ds-nota-entrada) = rowid(int-ds-nota-entrada):
                        assign bint-ds-nota-entrada.situacao = 5 /* atualizaá∆o manual */.
                        next for-nota.
                    end.
                end.
                release int-ds-nota-entrada-produto.           
            end.
        end. /* int-ds-nota-entrada-produto */
    
        if can-find(first tt-movto) then do:
            if not l-erro then
            run PiGeraMovimento (input table tt-movto,   
                                 input '').
        end.
        else do:
            run pi-gera-log (input "Documento sem itens: ",
                             input 1).
        end.
        release int-ds-nota-entrada.
    end. /* int-ds-nota-entrada */
    
end.
/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:

    {include/i-rpclo.i &STREAM="stream str-rp"}
END.

run pi-finalizar in h-acomp.

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
        run pi-gera-log (input "Estabelecimento materiais n∆o cadastrado: Est: " + tt-movto.cod-estabel,
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

        /*
        put stream str-rp unformatted 
            tt-movto.serie        " " 
            tt-movto.nr-nota-fis  " "
            tt-movto.nr-sequencia skip.
          */
        if first-of (tt-movto.nr-nota-fis) then do:
    
            i-ind = 0.
            for each int-ds-nota-entrada-dup no-lock of int-ds-nota-entrada
                by int-ds-nota-entrada-dup.nen-data-vencto-d:
                i-ind = i-ind + 1.
                create  tt-dupli-apagar.
                assign  tt-dupli-apagar.registro       = 4
                        tt-dupli-apagar.parcela        = string(i-ind,"99")
                        tt-dupli-apagar.nr-duplic      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-esp        = param-re.esp-def-dup
                        tt-dupli-apagar.tp-despesa     = tt-movto.tp-despesa
                        tt-dupli-apagar.dt-vencim      = int-ds-nota-entrada-dup.nen-data-vencto-d
                        tt-dupli-apagar.vl-a-pagar     = int-ds-nota-entrada-dup.nen-valor-duplicata-n
                        tt-dupli-apagar.vl-desconto    = 0
                        tt-dupli-apagar.dt-venc-desc   = ?
                        tt-dupli-apagar.serie-docto    = tt-movto.serie
                        tt-dupli-apagar.nro-docto      = tt-movto.nr-nota-fis
                        tt-dupli-apagar.cod-emitente   = tt-movto.cod-emitente
                        tt-dupli-apagar.nat-operacao   = tt-movto.nat-operacao.
            end.
            
            if  not can-find (first estabelec no-lock where estabelec.cod-emitente = tt-movto.cod-emitente) and
                not can-find (first tt-dupli-apagar) and
               (tt-movto.cod-cond-pag = 0 or tt-movto.cod-cond-pag = 999 or tt-movto.cod-cond-pag = ?) and
                /* bonificaá‰es, etc. */
               ((substring(tt-movto.nat-operacao,1,1) = "1" and substring(tt-movto.nat-operacao,1,4) < "1910") or
                (substring(tt-movto.nat-operacao,1,1) = "2" and substring(tt-movto.nat-operacao,1,4) < "2910"))
                then do:
                run pi-gera-log (input "Duplicatas n∆o geradas liberando para alteraá∆o manual.",
                                 input 1).
                for first bint-ds-nota-entrada exclusive where rowid(bint-ds-nota-entrada) = rowid(int-ds-nota-entrada):
                    assign bint-ds-nota-entrada.situacao = 5 /* atualizaá∆o manual */.
                    return.
                end.
            end.
        end.

        /*
        put stream str-rp unformatted 
            tt-movto.serie        " " 
            tt-movto.nr-nota-fis  " "
            tt-movto.nr-sequencia " DUP OK " skip.
          */
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
                   tt-docum-est-nova.nat-operacao      = tt-movto.nat-operacao
                   tt-docum-est-nova.cod-observa       = tt-movto.tipo-compra
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
                   tt-docum-est-nova.via-transp        = 1
                   tt-docum-est-nova.mod-frete         = tt-movto.mod-frete
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
                   tt-docum-est-nova.esp-docto         = 21 /* NFE */
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
               tt-item-doc-est-nova.cod-depos          = tt-movto.cod-depos
               tt-item-doc-est-nova.cod-localiz        = ""
               tt-item-doc-est-nova.lote               = tt-movto.lote
               tt-item-doc-est-nova.dt-vali-lote       = tt-movto.dt-vali-lote
               tt-item-doc-est-nova.class-fiscal       = item.class-fisc 
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
               tt-item-doc-est-nova.ipi-outras         = 0
               tt-item-doc-est-nova.iss-outras         = 0
               tt-item-doc-est-nova.icm-ntrib          = if tt-movto.cd-trib-icm = 2     
                                                         then tt-movto.vl-bicms-it       
                                                         else 0 
               tt-item-doc-est-nova.ipi-ntrib          = tt-movto.vl-bipi-it
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

        assign tt-docum-est-nova.valor-mercad          = tt-docum-est-nova.valor-mercad 
                                                       + tt-item-doc-est-nova.preco-total.

        if last-of (tt-movto.nr-nota-fis) then do:
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
               put stream str-rp skip(1).
               for each tt-erro:
                   RUN pi-gera-log('Erro API: Emit: ' + trim(string(tt-movto.cod-emitente)) +
                                   ' Ser: ' + tt-movto.serie        +
                                   ' NF: '  + tt-movto.nr-nota-fis  +
                                   ' Nat: ' + tt-movto.nat-operacao + 
                                   ' Est: ' + tt-movto.cod-estabel  + " - " +
                                   string(tt-erro.cd-erro) + "-" + tt-erro.mensagem,
                                   1).
               end.
               return.
            end.
            for first docum-est no-lock of tt-docum-est-nova:

                /* gerando duplicatas para notas com pedido ou cond padr∆o no fornecedor */
                if  not can-find (first dupli-apagar no-lock of docum-est) and
                    tt-movto.cod-cond-pag <> 0 and
                    tt-movto.cod-cond-pag <> ? and
                    tt-movto.cod-cond-pag <> 999 then do:

                    if  tt-movto.cod-emitente = 1000 or
                        tt-movto.cod-emitente = 5000 or
                        tt-movto.cod-emitente = 9574 then do:
                        for first emitente exclusive where 
                            emitente.cod-emitente = tt-movto.cod-emitente and
                            emitente.cod-cond-pag <> tt-movto.cod-cond-pag:
                            assign emitente.cod-cond-pag = tt-movto.cod-cond-pag.
                            release emitente.
                        end.
                    end.

                    run rep/re9341.p (input rowid(docum-est), input no).
                end.

                /* atualizando registro via BO 
                create tt-bo-docum-est.
                buffer-copy docum-est to tt-bo-docum-est
                    assign tt-bo-docum-est.r-docum-est = rowid(docum-est).
                   &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        substring(docum-est.char-1,93,60)  = tt-movto.chave-acesso.
                   &else
                        docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
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
                        put stream str-rp skip(1).
                        for each rowErrors:
                            RUN pi-gera-log('Erro BO: Emit: ' + trim(string(tt-movto.cod-emitente)) +
                                   ' Ser: ' + tt-movto.serie        +
                                   ' NF: '  + tt-movto.nr-nota-fis  +
                                   ' Nat: ' + tt-movto.nat-operacao + " - " +
                                   string(rowErrors.errorNumber) + "-" + rowErrors.errorDescription,
                                   1).
                        end.
                        undo do-trans, leave do-trans.
                    end.
                    /* atualiza nota no recebimento/estoque */
                    /* run atualizaDocumento in h-boin090. */
                    delete procedure h-boin090.
                */
                do:
                    /*run pi-gera-int-ds-doc.*/

                    /*
                    create tt-param-re1005.
                    assign 
                        tt-param-re1005.destino            = 3
                        tt-param-re1005.arquivo            = "int012-re1005_sc.txt"
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
                    release docum-est.

                    raw-transfer tt-param-re1005 to raw-param.
                    run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                    empty temp-table tt-digita-re1005.
                    empty temp-table tt-param-re1005.
                    */
                    run pi-gera-log('Emit: ' + trim(string(tt-movto.cod-emitente)) +
                                    ' Ser: ' + tt-movto.serie        +
                                    ' NF: '  + tt-movto.nr-nota-fis  +
                                    ' Nat: ' + tt-movto.nat-operacao + 
                                    ' Est: ' + tt-movto.cod-estabel +
                                    " - " + "Documento gerado com sucesso!",
                                    2).
                end.
                release docum-est.
            end. /* docum-est */
            for each int-ds-nota-entrada where
                int-ds-nota-entrada.nen-cnpj-origem-s = tt-movto.nen-cnpj-origem-s and
                int-ds-nota-entrada.nen-serie-s = tt-movto.serie and
                int-ds-nota-entrada.nen-notafiscal-n = integer(tt-movto.nr-nota-fis):
                assign  int-ds-nota-entrada.nen-conferida-n = 2 
                        int-ds-nota-entrada.situacao = 2 /* processada */.
                release int-ds-nota-entrada.
            end.
            empty temp-table tt-docum-est-nova.
            empty temp-table tt-item-doc-est-nova.
            empty temp-table tt-dupli-apagar.
        end. /* last-of */
    end. /* tt-movto */
    empty temp-table tt-movto.
end procedure. /* PiGeraDocumento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    if avail tt-movto then do: 
        IF tt-param.arquivo <> "" THEN DO:
            put stream str-rp unformatted
                tt-movto.nen-cnpj-origem-s + "/" + 
                trim(tt-movto.serie) + "/" + 
                trim(string(tt-movto.nr-nota-fis)) + "/" + 
                trim(string(tt-movto.nen-cfop-n)) + "/" + 
                trim(string(tt-movto.cod-estabel)) + " - " + 
                c-informacao
                skip.
        END.

        RUN intprg/int999.p ("NFE", 
                             tt-movto.nen-cnpj-origem-s + "/" +          
                             trim(tt-movto.serie) + "/" +                
                             trim(string(tt-movto.nr-nota-fis)) + "/" +  
                             trim(string(tt-movto.nen-cfop-n)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
    end.
    else do:
        IF tt-param.arquivo <> "" THEN DO:
            put stream str-rp unformatted
                int-ds-nota-entrada.nen-cnpj-origem-s + "/" + 
                trim(string(int-ds-nota-entrada.nen-serie-s)) + "/" + 
                trim(string(int-ds-nota-entrada.nen-notafiscal-n,">>9999999")) + "/" + 
                trim(string(int-ds-nota-entrada.nen-cfop-n)) + " - " + 
                c-informacao
                skip.
        END.

        RUN intprg/int999.p ("NFE", 
                             int-ds-nota-entrada.nen-cnpj-origem-s + "/" + 
                             trim(string(int-ds-nota-entrada.nen-serie-s)) + "/" + 
                             trim(string(int-ds-nota-entrada.nen-notafiscal-n,">>9999999")) + "/" + 
                             trim(string(int-ds-nota-entrada.nen-cfop-n)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
    end.
    if i-situacao = 1 then l-erro = yes.

end.


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
        int-ds-doc.tipo-nota = docum-est.tipo-nota: end.
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
            int-ds-it-doc.tipo-nota = docum-est.tipo-nota and
            int-ds-it-doc.sequencia = item-doc-est.sequencia: end.
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
