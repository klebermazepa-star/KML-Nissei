/********************************************************************************
** Programa: int052 - Importaá∆o de Notas de Entrada do Tutorial/PRS - Retiradas Lj 
**
** Versao : 12 - 18/10/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i INT052RP 2.12.05.AVB}
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
    field CNPJ like int-ds-docto-xml.CNPJ
    field cfop        like int-ds-docto-xml.cfop
    field tipo-nota         like int-ds-docto-xml.tipo-nota
    field dt-trans          like int-ds-docto-xml.dt-atualiza
    field perc-red-icms     like int-ds-it-docto-xml.predBc
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
    field nNF               like int-ds-docto-xml.nNF
    field CNPJ-dest         like int-ds-docto-xml.CNPJ-dest
    field class-fisc        like item-doc-est.class-fisc
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

/******* TEMP TABLES DA API *****************/
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

/* recebimento de par‚metros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param . 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT052.tmp"
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
def var i-sit-reg as int no-undo.
def var i-cstb-icm as int no-undo.
def var l-sub as int no-undo.
def var c-tp-pedido     as character.
def var c-uf-destino    as char no-undo. 
def var c-uf-origem     as char no-undo. 
def var i-cod-emitente  like emitente.cod-emitente.
def var c-class-fiscal  as char no-undo.
def var c-nat-saida     as char no-undo.
def var r-rowid         as rowid no-undo.

def buffer bint-ds-docto-xml for int-ds-docto-xml.
def buffer btt-item-doc-est-nova for tt-item-doc-est-nova.
def buffer btt-movto for tt-movto.
def buffer bint-ds-docto-wms for int-ds-docto-wms.
/* definiá∆o de frames do relatÛrio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i /*&stream = "stream str-rp"*/}
END.

assign c-programa     = "INT052"
       c-versao       = "2.13"
       c-revisao      = ".05.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Retiradas Loja -> CD".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.


for first param-re no-lock where param-re.usuario = c-seg-usuario: end.
if not avail param-re then do:
    put /*stream str-rp*/ unformatted "ParÉmetros do usu†rio recebimento n∆o cadastrados...." SKIP.
    return "NOK".
end.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 360
           tt-param.dt-emis-nota-fim = TODAY - 1.

if tt-param.cod-estabel-fim  = "" then
    assign tt-param.cod-estabel-ini  = ""
           tt-param.cod-estabel-fim  = "ZZZZZ".

if tt-param.serie-docto-fim  = "" then
    assign tt-param.serie-docto-ini  = ""
           tt-param.serie-docto-fim  = "ZZZZZ".

if tt-param.nro-docto-fim  = "" then
    assign tt-param.nro-docto-ini  = "0"
           tt-param.nro-docto-fim  = "999999999".

if tt-param.cod-emitente-fim  = 0 then
    assign tt-param.cod-emitente-ini  = 0
           tt-param.cod-emitente-fim  = 999999999.

DEFINE BUFFER bestabelec FOR estabelec.

/******* LE NOTA E GERA TEMP TABLES  *************/
FOR EACH bestabelec NO-LOCK WHERE 
    bestabelec.estado = "SC" OR 
    bestabelec.estado = "SP" OR
    bestabelec.estado = "PR"
    BY bestabelec.estado DESC:
    for-nota:
    for each int-ds-docto-xml no-lock where
        int-ds-docto-xml.situacao < 3 and
        int-ds-docto-xml.dEmi >= dt-emis-nota-ini and
        int-ds-docto-xml.dEmi <= dt-emis-nota-fim and
        int-ds-docto-xml.serie >= serie-docto-ini and
        int-ds-docto-xml.serie <= serie-docto-fim and
        int-ds-docto-xml.nNF >= nro-docto-ini and
        int-ds-docto-xml.nNF <= nro-docto-fim and
        int-ds-docto-xml.tipo-nota = 3
        AND int-ds-docto-xml.CNPJ = bestabelec.cgc,
        each int-ds-docto-wms no-lock where 
        int-ds-docto-wms.doc_numero_n = int64(int-ds-docto-xml.nNF) and
        int-ds-docto-wms.doc_serie_s  = int-ds-docto-xml.serie and
        int-ds-docto-wms.cnpj_cpf     = int-ds-docto-xml.CNPJ and
       (int-ds-docto-wms.situacao = 2 or (int-ds-docto-wms.situacao = 40 /* movimentada PRS */ and int-ds-docto-wms.datamovimentacao_d <> ?)):
    
        assign l-erro = no.
        empty temp-table tt-movto.
        c-nat-principal = "".
    
        c-cod-estabel = "".
        for each estabelec 
            fields (cod-estabel estado cidade 
                    cep pais endereco bairro ep-codigo) 
            no-lock where
            estabelec.cgc = int-ds-docto-xml.CNPJ-dest,
            first cst-estabelec no-lock where 
            cst-estabelec.cod-estabel = estabelec.cod-estabel and
            cst-estabelec.dt-fim-operacao >= int-ds-docto-xml.dEmi:
            c-cod-estabel = estabelec.cod-estabel.
            c-uf-destino  = estabelec.estado.
            leave.
        end.
        if c-cod-estabel = "" then do:
            run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-ds-docto-xml.CNPJ-dest,
                             input 1).
            next.
        end.
        if  c-cod-estabel < cod-estabel-ini or
            c-cod-estabel > cod-estabel-fim then next.
    
        c-cod-estabel-ori = "".
        for each estabelec 
            fields (cod-estabel estado cidade cod-emitente
                    cep pais endereco bairro ep-codigo) 
            no-lock where
            estabelec.cgc = int-ds-docto-xml.CNPJ,
            first cst-estabelec no-lock where 
            cst-estabelec.cod-estabel = estabelec.cod-estabel and
            cst-estabelec.dt-fim-operacao >= int-ds-docto-xml.dEmi:
            c-cod-estabel-ori = estabelec.cod-estabel.
            c-uf-origem = estabelec.estado.        
            i-cod-emitente = estabelec.cod-emitente.
            leave.
        end.
        if c-cod-estabel-ori = "" then do:
            run pi-gera-log (input "Estabelecimento ORIGEM n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-ds-docto-xml.CNPJ,
                             input 1).
            next.
        end.
        for first estabelec no-lock where estabelec.cod-estabel = c-cod-estabel-ori: end.
        for first emitente fields (cod-emitente estado tp-desp-padrao cod-cond-pag) no-lock where 
            emitente.cod-emitente = estabelec.cod-emitente: end.
        if not avail emitente then do:
            run pi-gera-log (input "Fornecedor n∆o cadastrado. CNPJ: " + string(int-ds-docto-xml.CNPJ),
                             input 1).
            next.
        end.
        if  emitente.cod-emitente < cod-emitente-ini or
            emitente.cod-emitente > cod-emitente-fim then next.
    
        /* pular notas a serem integradas manualmente pelo int520 */
        if int-ds-docto-xml.situacao = 7 and nro-docto-ini = "0" then next.

        /* notas de balanáo ou impostos */
        if int-ds-docto-xml.CNPJ = int-ds-docto-xml.CNPJ-dest then next.

        if int-ds-docto-wms.datamovimentacao_d = ? and int-ds-docto-wms.situacao <> 2 then do: 
            run pi-gera-log (input "Data de movimentaá∆o em branco. Imposs°vel atualizar: Nota: " + string(int-ds-docto-xml.nNF) + " SÇrie: " + string(int-ds-docto-xml.serie) + " Fornec: " + string(int-ds-docto-xml.cod-emitente),
                             input 1).
        end.
        if int-ds-docto-wms.datamovimentacao_d < 08/01/2016 then next.

        /* evitando importaá∆o da nota antes do termino da gravacao dos itens pelo PRS */
        if int-ds-docto-wms.datamovimentacao_d = today and 
           substring(int-ds-docto-wms.horamovimentacao_s,4,2) = substring(string(time,"HH:MM:SS"),1,2) then next.

        for first nota-fiscal no-lock where 
            nota-fiscal.cod-estabel = c-cod-estabel-ori and 
            nota-fiscal.serie       = int-ds-docto-xml.serie and
            nota-fiscal.nr-nota-fis = trim(string(int64(int-ds-docto-xml.nNF),">>>9999999")): end.

        if not avail nota-fiscal then do:
            run pi-gera-log (input "Nota Fiscal de sa°da n∆o encontrada " + string(int64(int-ds-docto-xml.nNF)) + " SÇrie: " + string(int-ds-docto-xml.serie) + " Estab.: " + c-cod-estabel-ori,
                             input 1).
            next.
        end.
        if nota-fiscal.dt-cancela <> ? then do:
            run pi-gera-log (input "Nota Fiscal de sa°da est† cancelada " + string(int64(int-ds-docto-xml.nNF)) + " SÇrie: " + string(int-ds-docto-xml.serie) + " Estab.: " + c-cod-estabel-ori,
                             input 1).
            next.
        end.
        
        for first docum-est no-lock where 
            docum-est.serie-docto  = nota-fiscal.serie and
            docum-est.nro-docto    = trim(string(int64(int-ds-docto-xml.nNF),">>9999999")) and
            docum-est.cod-emitente = emitente.cod-emitente: 
            run pi-gera-log (input "Documento j† cadastrado: " 
                             + "SÇrie: "     + docum-est.serie-docto 
                             + " Numero: "   + docum-est.nro-docto   
                             + " Forn: "     + string(docum-est.cod-emitente)
                             + " Natureza: " + docum-est.nat-operacao,
                             input 2).
            for each bint-ds-docto-xml where
                Bint-ds-docto-xml.CNPJ  = int-ds-docto-xml.CNPJ and
                Bint-ds-docto-xml.serie = int-ds-docto-xml.serie and
                Bint-ds-docto-xml.nNF   = int-ds-docto-xml.nNF:
                assign  bint-ds-docto-xml.sit-re          = 40
                        bint-ds-docto-xml.situacao        = 3 /* processada */.
                for first bint-ds-docto-wms exclusive-lock where 
                    rowid(bint-ds-docto-wms) = rowid(int-ds-docto-wms):
                    assign bint-ds-docto-wms.situacao = bint-ds-docto-xml.sit-re.
                end.
            end.
            empty temp-table tt-movto.
            assign l-erro = yes.
            next for-nota.
        end.
        c-tp-pedido = "".
        for first int-ds-pedido no-lock where
            int-ds-pedido.ped-codigo-n = int64(nota-fiscal.nr-pedcli):
            assign c-tp-pedido = trim(string(int-ds-pedido.ped-tipopedido-n)).
        end.

        for each it-nota-fisc no-lock of nota-fiscal
            query-tuning(no-lookahead):
    
            create tt-movto.
            assign tt-movto.CNPJ-dest           = int-ds-docto-xml.CNPJ-dest 
                   tt-movto.nNF                 = int-ds-docto-xml.nNF    
                   tt-movto.serie               = nota-fiscal.serie
                   tt-movto.nr-nota-fis         = trim(string(int64(int-ds-docto-xml.nNF),">>9999999"))
                   tt-movto.dt-emissao          = nota-fiscal.dt-emis-nota
                   tt-movto.tot-frete           = nota-fiscal.vl-frete
                   tt-movto.tot-seguro          = nota-fiscal.vl-seguro
                   tt-movto.tot-despesas        = nota-fiscal.val-desp-outros
                   tt-movto.tot-desconto        = nota-fiscal.vl-desconto
                   tt-movto.chave-acesso        = int-ds-docto-xml.chnfe
                   tt-movto.mod-frete           = nota-fiscal.ind-tp-frete
                   tt-movto.CNPJ                = int-ds-docto-xml.CNPJ
                   tt-movto.cfop                = int-ds-docto-xml.cfop
                   tt-movto.cod-estabel         = c-cod-estabel
                   tt-movto.cod-emitente        = emitente.cod-emitente
                   tt-movto.uf                  = emitente.estado
                   tt-movto.tipo-nota           = int-ds-docto-xml.tipo-nota
                   tt-movto.dt-trans            = if int-ds-docto-wms.datamovimentacao_d <> ? then int-ds-docto-wms.datamovimentacao_d else today
                   tt-movto.perc-red-icms       = it-nota-fisc.perc-red-icm
                   tt-movto.cod-cond-pag        = emitente.cod-cond-pag
                   tt-movto.estab-de-or         = c-cod-estabel-ori.
    
            c-class-fiscal = it-nota-fisc.class-fiscal.
            for first item 
                fields (it-codigo class-fisc tipo-con-est peso-liquido char-1 char-2
                        fm-codigo tipo-contr ct-codigo sc-codigo)
                no-lock where 
                item.it-codigo = string(it-nota-fisc.it-codigo): end.
            if not avail item then do:
                run pi-gera-log (input "Item n∆o cadastrado: " + string(it-nota-fisc.it-codigo),
                                 input 1).
                next.
            end.
            if item.tipo-contr = 1 /* Fisico */ or item.tipo-contr = 4 /* DB Dir */ then do:
                if item.ct-codigo = "" then do:
                    run pi-gera-log (input "Item sem conta aplicacao: " + string(it-nota-fisc.it-codigo),
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
                      item-uni-estab.it-codigo = string(it-nota-fisc.it-codigo): 
            end.
            if not avail item-uni-estab THEN DO:
               for first item-estab NO-LOCK where 
                         item-estab.cod-estabel = tt-movto.cod-estabel and
                         item-estab.it-codigo = string(it-nota-fisc.it-codigo): 
               end.
            END.
            if not avail item-estab and not avail item-uni-estab then do:
               run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + string(it-nota-fisc.it-codigo) + " Estab.: " + tt-movto.cod-estabel,
                                input 1).
               next.
            end.

            assign tt-movto.nat-orig = IT-NOTA-FISC.nat-operacao.
            i-trib-icm = it-nota-fisc.cd-trib-icm.
            tt-movto.vl-ipi-it = it-nota-fisc.vl-ipi-it.
            if i-trib-ipi = 3 or 
               i-trib-ipi = 5 then 
                assign tt-movto.vl-bipi-it      = it-nota-fisc.vl-ipiou-it
                       tt-movto.vl-ipi-it       = 0.
            if i-trib-ipi = 2 then 
                assign tt-movto.vl-bipi-it      = it-nota-fisc.vl-ipint-it
                       tt-movto.vl-ipi-it       = 0.

            assign tt-movto.vl-icms-it      = it-nota-fisc.vl-icms-it.
            if i-trib-icm = 1 or
               i-trib-icm = 4 then 
                assign tt-movto.vl-bicms-it     = it-nota-fisc.vl-bicms-it.
            if i-trib-icm = 3 or 
               i-trib-icm = 5 then 
                assign tt-movto.vl-bicms-it     = it-nota-fisc.vl-icmsou-it.
            if i-trib-icm = 2 then 
                assign tt-movto.vl-bicms-it     = it-nota-fisc.vl-icmsnt-it
                       tt-movto.vl-icms-it      = 0.

            i-cfop = int(substring(it-nota-fisc.nat-operacao,1,4)).
            run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                               output i-cstb-icm,
                               output l-sub).

            /*
            /* tratar natur-oper */
            c-nat-operacao = "".
            RUN intprg/int013a.p( input i-cfop,
                                  input i-cstb-icm,
                                  input /*int-ds-nota-saida-item.nsp-cstb-ipi-n*/ int64(item.fm-codigo),
                                  input tt-movto.cod-estabel,
                                  input tt-movto.cod-emitente,
                                  input tt-movto.dt-emissao,
                                  output c-nat-operacao ).
            */

            if c-tp-pedido = "" then
            for first int-ds-pedido no-lock where
                int-ds-pedido.ped-codigo-n = int64(it-nota-fisc.nr-pedcli):
                assign c-tp-pedido = trim(string(int-ds-pedido.ped-tipopedido-n)).
            end.
            if c-tp-pedido = "" then do:
                run pi-gera-log (input "Pedido n∆o localizado: " + string(nota-fiscal.nr-pedcli),
                                 input 1).
                next.
            end.

            /* determina natureza de operacao */
            run intprg/int115a.p ( input c-tp-pedido   ,
                                   input c-uf-destino  ,
                                   input c-uf-origem   ,
                                   input i-cod-emitente,
                                   input c-class-fiscal,
                                   output c-nat-saida,
                                   output c-nat-operacao,
                                   output r-rowid).

            if c-nat-operacao = "" then do:
                run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                        "CFOP Nota: " + string(i-cfop) + 
                                        " CSTB ICMS: " + string(i-cstb-icm) + 
                                        /*" CSTB IPI:" + string(int-ds-nota-saida-item.nsp-cstb-ipi-n)*/
                                        " Fam°lia: " + item.fm-codigo + " Estab.: " + c-cod-estabel,
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
            if c-nat-principal = "" 
               &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                then 
               &else
                or NOT natur-oper.log-contrib-st-antec then
               &endif
                assign c-nat-principal = c-nat-operacao.


            /* buscando tributaá∆o no destino */
            assign i-trib-icm = natur-oper.cd-trib-icm
                   i-trib-ipi = natur-oper.cd-trib-ipi.

            for first fat-ser-lote no-lock of it-nota-fisc: end.

            assign tt-movto.it-codigo       = string(it-nota-fisc.it-codigo)
                   tt-movto.nr-sequencia    = it-nota-fisc.nr-seq-fat
                   tt-movto.qt-recebida     = it-nota-fisc.qt-faturada[1]
                   tt-movto.cod-depos       = if avail item-uni-estab and trim(item-uni-estab.deposito-pad) <> "" and trim(item-uni-estab.deposito-pad) <> ?
                                              then item-uni-estab.deposito-pad
                                              else if avail item-estab and trim(item-estab.deposito-pad) <> "" and trim(item-estab.deposito-pad) <> ? then item-estab.deposito-pad else "LOJ"
                   tt-movto.lote            = if item.tipo-con-est = 3 then fat-ser-lote.nr-serlote else ""
                   tt-movto.dt-vali-lote    = if item.tipo-con-est = 3 then fat-ser-lote.dt-vali-lote else ?
                   tt-movto.valor-mercad    = it-nota-fisc.vl-merc-ori
                   tt-movto.vl-despesas     = it-nota-fisc.vl-despes-it
                   tt-movto.cd-trib-ipi     = i-trib-ipi
                   tt-movto.aliquota-ipi    = it-nota-fisc.aliquota-ipi
                   tt-movto.tipo-compra     = natur-oper.tipo-compra
                   tt-movto.terceiros       = natur-oper.terceiros
                   tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
                   tt-movto.cd-trib-icm     = i-trib-icm
                   tt-movto.nat-operacao    = natur-oper.nat-operacao
                   tt-movto.aliquota-icm    = it-nota-fisc.aliquota-icm
                   tt-movto.perc-red-icm    = it-nota-fisc.perc-red-icm
                   tt-movto.vl-bsubs-it     = it-nota-fisc.vl-bsubs-it
                   tt-movto.vl-icmsub-it    = it-nota-fisc.vl-icmsub-it
                   tt-movto.peso-liquido    = item.peso-liquido
                   tt-movto.class-fisc      = item.class-fisc.
    
            /* novo tratamento PIS/COFINS - AVB 07/06/2017 */
            if int(substr(natur-oper.char-1,86,1)) /* CD-TRIB-PIS */ = 1 /* tributado */ then do:
                tt-movto.aliquota-pis       = if substr(item.char-2,52,1) = "1" 
                                              /* Al°quota do Item */
                                              then dec(substr(item.char-2,31,5))
                                              /* Al°quota da natureza */
                                              else natur-oper.perc-pis[1].
                if tt-movto.aliquota-pis <> 0 then do:
                    tt-movto.base-pis           = it-nota-fisc.vl-merc-ori
                                                - it-nota-fisc.vl-desconto
                                                + it-nota-fisc.vl-despes-it.
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
                                              /* Al°quota do Item */
                                              then dec(substr(item.char-2,36,5))
                                              /* Al°quota da Natureza */
                                              else natur-oper.per-fin-soc[1].
                if tt-movto.aliquota-cofins <> 0 then do:
                    tt-movto.base-cofins        = it-nota-fisc.vl-merc-ori 
                                                - it-nota-fisc.vl-desconto 
                                                + it-nota-fisc.vl-despes-it.                                                                        
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
        end.
        else do:
            run pi-gera-log (input "Documento n∆o possui Itens. Docto: " + string(int-ds-docto-xml.nNF) + " SÇrie: " + string(nota-fiscal.serie) + " Estab.: " + c-cod-estabel,
                             input 1).
        end.
    end.
END.

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
for each tt-movto:          delete tt-movto.          end.

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
        if last-of (tt-movto.nr-nota-fis) then do:
            for first docum-est of tt-docum-est-nova no-lock: end.
            if avail docum-est then return.
            for first natur-oper exclusive where 
                natur-oper.nat-operacao = tt-docum-est-nova.nat-operacao:
                /*assign natur-oper.especie-doc = "NFE".*/
                assign natur-oper.transf = no.
            end.
            for each btt-item-doc-est-nova:
                for first natur-oper exclusive where 
                    natur-oper.nat-operacao = btt-item-doc-est-nova.nat-operacao:
                    /*assign natur-oper.especie-doc = "NFE".*/
                    assign natur-oper.transf = no.
                end.
                for first natur-oper exclusive where 
                    natur-oper.nat-operacao = btt-item-doc-est-nova.nat-of:
                    /*assign natur-oper.especie-doc = "NFE".*/
                    assign natur-oper.transf = no.
                end.
            end.
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

            for first natur-oper exclusive where 
                natur-oper.nat-operacao = tt-docum-est-nova.nat-operacao:
                /*assign natur-oper.especie-doc = "NFT".*/
                assign natur-oper.transf = yes.
            end.
            for each btt-item-doc-est-nova:
                for first natur-oper exclusive where 
                    natur-oper.nat-operacao = btt-item-doc-est-nova.nat-operacao:
                    /*assign natur-oper.especie-doc = "NFE".*/
                    assign natur-oper.transf = yes.
                end.
                for first natur-oper exclusive where 
                    natur-oper.nat-operacao = btt-item-doc-est-nova.nat-of:
                    /*assign natur-oper.especie-doc = "NFE".*/
                    assign natur-oper.transf = yes.
                end.
            end.

            find first tt-erro no-error.
            if avail tt-erro then do:
               put /*stream str-rp*/ skip(1).
               for each tt-erro:
                   ASSIGN i-sit-reg = 1.
                   IF tt-erro.cd-erro = 1878 THEN DO:
                      ASSIGN i-sit-reg = 2.
                      for each bint-ds-docto-xml where
                          Bint-ds-docto-xml.CNPJ  = tt-movto.CNPJ and
                          Bint-ds-docto-xml.serie = tt-movto.serie and
                          Bint-ds-docto-xml.nNF   = tt-movto.nNF:
                          assign  bint-ds-docto-xml.sit-re          = 40
                                  bint-ds-docto-xml.situacao        = 3 /* processada */.
                      end.
                   END.
                   if tt-erro.mensagem matches "*OK*" then do:
                       for each cadast_msg no-lock where cdn_msg = tt-erro.cd-erro:
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
            for first docum-est of tt-docum-est-nova:
                assign docum-est.estab-de-or = tt-movto.estab-de-or.
                assign docum-est.cdn-sit-nfe = 3. /* autenticacao de chave */
                       /*docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.*/
                for each item-doc-est of docum-est,
                    each btt-movto no-lock where
                    btt-movto.serie        = docum-est.serie-docto  and
                    btt-movto.nr-nota-fis  = docum-est.nro-docto    and
                    btt-movto.dt-emissao   = docum-est.dt-emissao   and
                    btt-movto.it-codigo    = item-doc-est.it-codigo and    
                    btt-movto.nr-sequencia = item-doc-est.sequencia:
                    assign  item-doc-est.nro-comp     = item-doc-est.nro-docto 
                            item-doc-est.serie-comp   = item-doc-est.serie-docto
                            item-doc-est.nat-comp     = btt-movto.nat-orig
                            item-doc-est.seq-comp     = item-doc-est.sequencia.
                    release item-doc-est.
                end.
                release docum-est.
            end.
            for first docum-est no-lock of tt-docum-est-nova:

                /*
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
                        if valid-handle(h-boin176) then delete procedure h-boin176.
                    end.
                    
                    run pi-gera-int-ds-doc.
                    
                end. /* item-doc-est */
                */
                create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int52-re1005.txt"
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

                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " SÇrie: " + tt-movto.serie        +
                                " NF: "  + tt-movto.nr-nota-fis  +
                                " Natur. Oper.: " + c-nat-principal + 
                                " Estab.: " + tt-movto.cod-estabel +
                                " - " + "Documento gerado com sucesso!",
                                2).
                release docum-est.
                for each bint-ds-docto-xml exclusive-lock where
                    Bint-ds-docto-xml.CNPJ  = tt-movto.CNPJ and
                    Bint-ds-docto-xml.serie = tt-movto.serie and
                    Bint-ds-docto-xml.nNF   = tt-movto.nNF:
                    assign  bint-ds-docto-xml.situacao = 3 /* processada */.
                end.
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
                tt-movto.CNPJ + "/" + 
                trim(tt-movto.serie) + "/" + 
                trim(string(tt-movto.nr-nota-fis)) + "/" + 
                trim(string(tt-movto.cfop)) + "/" + 
                trim(string(tt-movto.cod-estabel)) + " - " + 
                c-informacao
                skip.
        END.

        RUN intprg/int999.p ("NFE", 
                             tt-movto.CNPJ + "/" +          
                             trim(tt-movto.serie) + "/" +                
                             trim(string(tt-movto.nr-nota-fis)) + "/" +  
                             trim(string(tt-movto.cfop)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
    end.
    else do:
        IF tt-param.arquivo <> "" THEN DO:
            put /*stream str-rp*/ unformatted
                int-ds-docto-xml.CNPJ + "/" + 
                trim(string(int-ds-docto-xml.serie)) + "/" + 
                trim(string(int64(int-ds-docto-xml.nNF),">>9999999")) + "/" + 
                trim(string(int-ds-docto-xml.cfop)) + " - " + 
                c-informacao
                skip.
        END.

        RUN intprg/int999.p ("NFE", 
                             int-ds-docto-xml.CNPJ + "/" + 
                             trim(string(int-ds-docto-xml.serie)) + "/" + 
                             trim(string(int64(int-ds-docto-xml.nNF),">>9999999")) + "/" + 
                             trim(string(int-ds-docto-xml.cfop)),
                             c-informacao,
                             i-situacao, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
    end.
    if i-situacao = 1 then do:
        l-erro = yes.
        
        run pi-gera-doc-erro(input 999999,
                             input c-informacao,
                             input i-situacao). 

    end.


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
                    int-ds-doc.nen_notafiscal_n = int64(docum-est.nro-docto)
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
                int-ds-it-doc.nen_notafiscal_n          = int64(item-doc-est.nro-docto)
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


procedure pi-gera-doc-erro:

    def input param p-cod-erro     like int-ds-doc-erro.cod-erro.
    def input param p-desc-erro    like int-ds-doc-erro.descricao.
    def input param p-situacao     as integer.

      
     FOR  FIRST int-ds-doc-erro NO-LOCK WHERE
                int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie  AND 
                int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente AND
                int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ  AND 
                int-ds-doc-erro.nro-docto    = int-ds-docto-xml.nNF   AND 
                int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota  AND
                int-ds-doc-erro.descricao    = p-desc-erro 
         query-tuning(no-lookahead) : END.

     IF NOT AVAIL int-ds-doc-erro 
     THEN DO:
        CREATE int-ds-doc-erro.
        ASSIGN int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie       
               int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente
               int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ 
               int-ds-doc-erro.nro-docto    = int-ds-docto-xml.nNF   
               int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota  
               int-ds-doc-erro.tipo-erro    = "RE1001"   
               int-ds-doc-erro.cod-erro     = p-cod-erro       
               int-ds-doc-erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
        IF AVAIL int-ds-it-docto-xml THEN 
           ASSIGN int-ds-doc-erro.sequencia = int-ds-it-docto-xml.sequencia.
    
     END.
     /*
     IF AVAIL int-ds-docto-xml THEN
        ASSIGN int-ds-docto-xml.situacao = p-situacao.
        
     if avail int-ds-it-docto-xml then 
          assign int-ds-it-docto-xml.situacao = p-situacao.
          */

END PROCEDURE.
