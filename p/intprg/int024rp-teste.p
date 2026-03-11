/********************************************************************************
** Programa: INT024 - Importaá∆o de Devoluá‰es de CUPOM do Toturial/PRS
**
** Versao : 12 - 10/05/2016 - Alessandro V Baccin
**
********************************************************************************/
{utp/ut-glob.i}

/* include de controle de vers∆o */
{include/i-prgvrs.i INT024RP 2.12.03.AVB}
{cdp/cdcfgdis.i}

{cdp/cd4305.i1}  /* Definicao da temp-table tt-docto e tt-it-doc            */
{cdp/cd4314.i2}  /* Definicao da temp-table tt-nota-trans                   */
{cdp/cd4401.i3}  /* Definicao da temp-table tt-saldo-estoq                  */
{cdp/cd4313.i1}  /* Def da temp-table tt-cond-pag e tt-fat-duplic           */
{cdp/cd4313.i4}  /* Def da temp-table tt-rateio-it-duplic                   */
{ftp/ft2070.i1}  /* Definicao da temp-table tt-fat-repre                    */
{ftp/ft2073.i1}  /* Definicao das temp-tables tt-nota-embal e tt-item-embal */
{ftp/ft2010.i1}  /* Definicao da temp-table tt-notas-geradas                */
{ftp/ft2015.i}   /* Temp-table tt-docto-bn e tt-it-docto-bn                 */
{cdp/cd4305.i2}  /* Temp-table tt-it-nota-doc                               */
{ftp/ft2015.i2}  /* Temp-table tt-desp-nota-fisc                            */

{intprg/int020rp.i2} /* Definiá∆o de vari†veis */

def temp-table tt-cst-nota-fiscal like cst-nota-fiscal.
def temp-table tt-int-ds-nota-loja-cartao like int-ds-nota-loja-cartao
    field cod-esp       like fat-duplic.cod-esp
    field cod-vencto    like fat-duplic.cod-vencto
    field cod-cond-pag  like nota-fiscal.cod-cond-pag
    field cod-portador  like nota-fiscal.cod-portador
    field modalidade    like nota-fiscal.modalidade.

function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    return c-aux.
end.

/* temp-tables das API's e BO's 
{method/dbotterr.i}
*/

/* definiáao de frames do relat¢rio */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* definiá∆o das temp-tables para recebimento de parÉmetros */
def temp-table tt-movto
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
    field cd-trib-ipi  like natur-oper.cd-trib-ipi
    field aliquota-ipi like item-doc-est.aliquota-ipi  
    field perc-red-ipi like natur-oper.perc-red-ipi  
    field cd-trib-icm  like natur-oper.cd-trib-icm   
    field aliquota-icm like item-doc-est.aliquota-icm  
    field perc-red-icm like natur-oper.perc-red-icm  
    field vl-bicms-it  like docum-est.base-icm
    field vl-icms-it   like it-nota-fisc.vl-icms-it    
    field vl-bipi-it   like it-nota-fisc.vl-bipi-it    
    field vl-ipi-it    like it-nota-fisc.vl-ipi-it
    field vl-bsubs-it  like it-nota-fisc.vl-bsubs-it
    field vl-icmsub-it like it-nota-fisc.vl-icmsub-it
    field cod-emitente like docum-est.cod-emitente
    field uf           like docum-est.uf
    field peso-liquido like item.peso-liquido
    field cnpj_filial_dev   like int-ds-devolucao-cupom.cnpj_filial_dev
    field numero_dev        like int-ds-devolucao-cupom.numero_dev
    field cnpj_filial_cup   like int-ds-devolucao-cupom.cnpj_filial_cup
    field numero_cup        like int-ds-devolucao-cupom.numero_cup
    field observacao        like docum-est.observacao
    field tipo-compra       like natur-oper.tipo-compra
    field cd-trib-iss       like natur-oper.cd-trib-iss
    field base-pis              like item-doc-est.base-pis extent 0
    field valor-pis             like item-doc-est.valor-pis extent 0
    field cd-trib-pis           as integer format "9"
    field aliquota-pis          as decimal format ">>9.99"
    field base-cofins           like item-doc-est.base-cofins extent 0
    field valor-cofins          as decimal format ">>>,>>>,>>>,>>9.99" extent 0
    field cd-trib-cofins        as integer format "9"      
    field aliquota-cofins       as decimal format ">>9.99" 
    field serie-comp            like item-doc-est.serie-comp
    field nro-comp              like item-doc-est.nro-comp
    field nat-comp              like item-doc-est.nat-comp
    field seq-comp              like item-doc-est.seq-comp            
    field data-comp             like item-doc-est.data-comp    
    field cod-estab-ori         like nota-fiscal.cod-estabel
    field conta-aplicacao       like item.conta-aplicacao
    field sc-codigo             like item.sc-codigo
    field class-fiscal          like item.class-fiscal
    field nat-of                like item-doc-est.nat-of
    field cod-esp               like cst-fat-devol.cod-esp.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

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

/******* TEMP TABLES DA API *****************/
{rep/reapi191.i1}
{rep/reapi190b.i}

define temp-table tt-bo-docum-est no-undo
    like docum-est
    field r-docum-est as rowid.

define temp-table tt-cst-fat-devol like cst-fat-devol.
define temp-table tt-it-nota-fisc like it-nota-fisc
    field qt-saldo as decimal.

define buffer bint-ds-devolucao-cupom for int-ds-devolucao-cupom.
define buffer bdocum-est for docum-est.
{method/dbotterr.i}

/* recebimento de parÉmetros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
ASSIGN tt-param.arquivo = "INT024.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.


/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
/*def var h-acomp    as handle no-undo.*/
def var h-api      as handle no-undo.
def var h-aux      as handle no-undo.
def var l-erro     as logical no-undo.
def var c-nat-operacao  as char no-undo.
def var c-nat-of        as char no-undo.
/*def var c-condipag      as char no-undo.*/
/*def var c-convenio      as char no-undo.*/
/*def var i-cod-portador  as integer no-undo.*/
/*def var i-modalidade    as integer no-undo.*/
/*def var c-estado        as char no-undo. 
def var c-cidade        as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-serie         as char no-undo.
def var r-rowid         as rowid no-undo.
def var c-natur         like ped-venda.nat-operacao.
def var i-cod-cond-pag  as integer.
*/
def var c-estado-ori    as char no-undo. 
def var c-cidade-ori    as char no-undo. 
def var c-cod-estab-ori as char no-undo.
def var i-cod-port-ori  as integer no-undo.
def var i-modalid-ori   as integer no-undo.
def var c-cod-esp-dev   as char no-undo.
/*def var i-cod-emitente  as integer no-undo.*/
def var c-modo-devolucao  like cst-fat-devol.modo-devolucao.
def var i-seq           as integer no-undo.
def var i-cod-cliente   as integer no-undo.
def var de-vl-fat-devol as decimal no-undo.
def var i-parcela       as integer no-undo.
/*def var i-cod-port-dinh as integer initial 99901 no-undo.
def var i-modalid-dinh  as integer initial 6 no-undo.
def var i-cond-pag-dinh as integer initial 1 no-undo.
*/
def var c-serie-ori     as char no-undo.
def var c-conta         as char no-undo.
def var c-subconta      as char no-undo.
def var c-numero-cup    as char no-undo.
/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 

assign c-programa     = "INT024"
       c-versao       = "2.12"
       c-revisao      = ".03.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Devoluá∆o Cupom Recebimento".

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i /*&stream = "stream str-rp"*/}
    view /* stream str-rp */ frame f-cabec.
    view /* stream str-rp */ frame f-rodape.
end.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Devoluá‰es").

for first param-global fields (empresa-prin) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

/******* LE NOTA E GERA TEMP TABLES  *************/
define buffer bdevolucao-cupom for int-ds-devolucao-cupom.
for-dev:
for each int-ds-devolucao-cupom WHERE
    int-ds-devolucao-cupom.situacao = 1 AND
    (
     (int(int-ds-devolucao-cupom.numero_dev) = 015445 AND
      int-ds-devolucao-cupom.numero_cup = "177816") OR
     (int(int-ds-devolucao-cupom.numero_dev) = 009427 AND
      int-ds-devolucao-cupom.numero_cup = "178666")
    )

    /*and int(int-ds-devolucao-cupom.numero_dev) = 028376*/
    query-tuning(no-lookahead)
    break by int-ds-devolucao-cupom.cnpj_filial_dev
            by int-ds-devolucao-cupom.numero_dev
                by int-ds-devolucao-cupom.produto
                  by int-ds-devolucao-cupom.quantidade desc
                    by int-ds-devolucao-cupom.sequencia:


    if first-of (int-ds-devolucao-cupom.numero_dev) then do:
        assign c-nat-operacao = "".
        assign l-erro = no.
        empty temp-table tt-movto.
        empty temp-table tt-it-nota-fisc.
    end.
    else if l-erro then next.

    c-estado        = ''.
    c-cidade        = ''.
    c-cod-estabel   = ''.
    i-cod-emitente  = 0.
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo cod-emitente) 
        no-lock where
        estabelec.cgc = int-ds-devolucao-cupom.cnpj_filial_dev,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= int-ds-devolucao-cupom.data
        query-tuning(no-lookahead):
        c-estado        = estabelec.estado.
        c-cidade        = estabelec.cidade.
        c-cod-estabel   = estabelec.cod-estabel.
        i-cod-emitente  = estabelec.cod-emitente.
        leave.
    end.
    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-ds-devolucao-cupom.cnpj_filial_dev,
                         input 1).
        next.
    end.
    if c-cod-estabel = "500" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-ds-devolucao-cupom.cnpj_filial_dev,
                         input 1).
        next.
    end.

    c-estado-ori    = "".
    c-cidade-ori    = "". 
    c-cod-estab-ori = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int-ds-devolucao-cupom.cnpj_filial_cup,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= int-ds-devolucao-cupom.data
        query-tuning(no-lookahead):
        c-estado-ori    = estabelec.estado.
        c-cidade-ori    = estabelec.cidade.
        c-cod-estab-ori = estabelec.cod-estabel.
        leave.
    end.
    if c-cod-estab-ori = "" then do:
        run pi-gera-log (input "Estabelecimento CUPOM n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-ds-devolucao-cupom.cnpj_filial_cup,
                         input 1).
        next.
    end.
    assign c-condipag      = '01' /* dinheiro */
           c-convenio      = "N".
    for last int-ds-nota-loja no-lock where
        int-ds-nota-loja.cnpj_filial = int-ds-devolucao-cupom.cnpj_filial_cup and
        int-ds-nota-loja.num_nota = int-ds-devolucao-cupom.numero_cup and
        int-ds-nota-loja.emissao <= int-ds-devolucao-cupom.data: 
        assign c-condipag      = int-ds-nota-loja.condipag
               c-convenio      = if int(int-ds-nota-loja.convenio) > 0 then "S" else "N"
               c-numero-cup    = if trim(int-ds-nota-loja.num_identi) begins "CONT" 
                                 then int-ds-nota-loja.cupom_ecf
                                 else int-ds-nota-loja.num_nota.
    end.
    /* se cupom pendente de importaá∆o, importa pelo int020 */
    if avail int-ds-nota-loja then do:
       if int-ds-nota-loja.situacao = 1 then do:
            {intprg/int020rp.i}
            run importa-nota.
            run pi-elimina-tabelas.
            /* busca novamente */
            for last int-ds-nota-loja no-lock where
                int-ds-nota-loja.cnpj_filial = int-ds-devolucao-cupom.cnpj_filial_cup and
                int-ds-nota-loja.num_nota = int-ds-devolucao-cupom.numero_cup and
                int-ds-nota-loja.emissao <= int-ds-devolucao-cupom.data: end.
       end.
    end.
    else do:
        run pi-gera-log (input "Cupom origem ainda n∆o disponivel na integracao. CNPJ Filial: " + 
                         string(int-ds-devolucao-cupom.cnpj_filial_dev) + " Nr. Devoluá∆o: " + 
                         string(int-ds-devolucao-cupom.numero_dev) + " Cupom: " + 
                         string(int-ds-devolucao-cupom.numero_cup) + " Item: " +
                         string(int(int-ds-devolucao-cupom.produto)) +
                         " Data: " + string(int-ds-devolucao-cupom.data,"99/99/9999"),
                         input 1).
        next.
    end.
    for first int-ds-nota-loja-item no-lock of int-ds-nota-loja where
        int-ds-nota-loja-item.produto = int-ds-devolucao-cupom.produto: end.
    if not avail int-ds-nota-loja-item then do:
        run pi-gera-log (input "Produto n∆o encontrado no cupom origem. CNPJ Filial: " + 
                         string(int-ds-devolucao-cupom.cnpj_filial_dev) + " Nr. Devoluá∆o: " + 
                         string(int-ds-devolucao-cupom.numero_dev) + " Cupom: " + 
                         string(int-ds-devolucao-cupom.numero_cup) + " Item: " +
                         string(int(int-ds-devolucao-cupom.produto)),
                         input 1).
        next.
    end.
    c-class-fiscal = "".
    c-conta = "".
    c-subconta = "".
    for first item 
        fields (it-codigo class-fiscal tipo-con-est peso-liquido aliquota-ipi ct-codigo
                sc-codigo conta-aplicacao tipo-contr cd-trib-icm cd-trib-ipi cd-trib-iss)
        no-lock where 
        item.it-codigo = string(int(int-ds-devolucao-cupom.produto)): 
        c-class-fiscal  = item.class-fiscal.
        c-conta = item.ct-codigo.
        c-subconta = item.sc-codigo.
    end.
    if not avail item then do:
        run pi-gera-log (input "Item n∆o cadastrado: " + string(int(int-ds-devolucao-cupom.produto)),
                         input 1).
        next.
    end.
    for first item-estab no-lock where 
        item-estab.cod-estabel = c-cod-estabel and
        item-estab.it-codigo = string(int(int-ds-devolucao-cupom.produto)): 
    end.
    if not avail item-estab then
        for first item-uni-estab no-lock where 
            item-uni-estab.cod-estabel = c-cod-estabel and
            item-uni-estab.it-codigo = string(int(int-ds-devolucao-cupom.produto)): end.
    if not avail item-estab and not avail item-uni-estab then do:
        run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + string(int(int-ds-devolucao-cupom.produto)) + "/" + "Estab.: " + c-cod-estabel,
                         input 1).
        next.
    end.
    
    if item.tipo-contr = 4 and c-conta = "" then do:
        run pi-gera-log (input "Item dÇbito direto exige conta aplicaá∆o: " + string(int(int-ds-devolucao-cupom.produto)),
                         input 1).
        next.
    end.
    if item.class-fiscal = "" or
       item.class-fiscal = ? then do:
        run pi-gera-log (input "Item sem classificaá∆o fiscal: " + string(int(int-ds-devolucao-cupom.produto)),
                         input 1).
        next.
    end.

    /* SêRIE ORIGEM */
    c-serie-ori = "".
    for-ser-estab:
    for each ser-estab no-lock where 
        ser-estab.cod-estabel = c-cod-estab-ori and
        ser-estab.forma-emis = 2 /* manual */
        query-tuning(no-lookahead):
        /* item origem */
        for each it-nota-fisc no-lock where 
            it-nota-fisc.cod-estabel = c-cod-estab-ori and
            it-nota-fisc.serie       = ser-estab.serie and
            it-nota-fisc.nr-nota-fis = trim(string(int(c-numero-cup),">>9999999")) and
            it-nota-fisc.it-codigo   = trim(string(int(int-ds-devolucao-cupom.produto))) and
            it-nota-fisc.dt-emis-nota >= today - 180
            query-tuning(no-lookahead): 
            for first tt-it-nota-fisc where 
                tt-it-nota-fisc.cod-estabel = it-nota-fisc.cod-estabel and
                tt-it-nota-fisc.serie       = it-nota-fisc.serie and
                tt-it-nota-fisc.nr-nota-fis = it-nota-fisc.nr-nota-fis and
                tt-it-nota-fisc.nr-seq-fat  = it-nota-fisc.nr-seq-fat and
                tt-it-nota-fisc.it-codigo   = trim(string(int(int-ds-devolucao-cupom.produto))): end.
            if not avail tt-it-nota-fisc then do:
                create tt-it-nota-fisc.
                buffer-copy it-nota-fisc to tt-it-nota-fisc
                    assign tt-it-nota-fisc.qt-saldo = it-nota-fisc.qt-faturada[1].
            end.
            assign c-serie-ori = ser-estab.serie.
            /*leave for-ser-estab.*/
        end.
    end.
    /* se nota nao encontrada, tenta importar mesmo se situacao do cupom j† processado 
    if not can-find(first tt-it-nota-fisc no-lock where
                    tt-it-nota-fisc.cod-estabel = c-cod-estab-ori and
                    tt-it-nota-fisc.serie       = c-serie-ori and
                    tt-it-nota-fisc.nr-nota-fis = trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999"))) then do:
        {intprg/int020rp.i}
        run importa-nota.
        run pi-elimina-tabelas.
        /* busca novamente */
        for last int-ds-nota-loja no-lock where
            int-ds-nota-loja.cnpj_filial = int-ds-devolucao-cupom.cnpj_filial_cup and
            int-ds-nota-loja.num_nota = int-ds-devolucao-cupom.numero_cup and
            int-ds-nota-loja.emissao <= int-ds-devolucao-cupom.data: end.
    end.
    */
    if not can-find(first tt-it-nota-fisc no-lock where
                    tt-it-nota-fisc.cod-estabel = c-cod-estab-ori and
                    tt-it-nota-fisc.serie       = c-serie-ori and
                    tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-numero-cup),">>9999999")) and
                    tt-it-nota-fisc.it-codigo   = trim(string(int(int-ds-devolucao-cupom.produto)))) then do:
        run pi-gera-log (input "Item da nota origem n∆o encontrado. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                         " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) +
                         " Item: " + string(int(int-ds-devolucao-cupom.produto)),
                         input 1).
        next for-dev.
    end.
    /*
    if not avail ser-estab then do:
        run pi-gera-log (input "SÇrie X Estabelecimento com forma emiss∆o manual n∆o encontrada. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                         " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")),
                         input 1).
        next.
    end.
    */
    for first tt-it-nota-fisc no-lock where 
        tt-it-nota-fisc.cod-estabel = c-cod-estab-ori and
        tt-it-nota-fisc.serie       = c-serie-ori and
        tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-numero-cup),">>9999999")) and
        tt-it-nota-fisc.it-codigo   = trim(string(int(int-ds-devolucao-cupom.produto))) and
        tt-it-nota-fisc.qt-saldo   >= int-ds-devolucao-cupom.quantidade:
        create tt-movto.
        assign tt-movto.nr-nota-fis     = trim(string(int(int-ds-devolucao-cupom.numero_dev),">>>999999"))
               tt-movto.dt-emissao      = int-ds-devolucao-cupom.data
               tt-movto.cnpj_filial_dev = int-ds-devolucao-cupom.cnpj_filial_dev
               tt-movto.numero_dev      = int-ds-devolucao-cupom.numero_dev
               tt-movto.cnpj_filial_cup = int-ds-devolucao-cupom.cnpj_filial_cup
               tt-movto.numero_cup      = int-ds-devolucao-cupom.numero_cup
               tt-movto.it-codigo       = string(int(int-ds-devolucao-cupom.produto))
               tt-movto.cod-estab-ori   = c-cod-estab-ori
               tt-movto.class-fiscal    = c-class-fiscal.
        assign tt-movto.qt-recebida     = int-ds-devolucao-cupom.quantidade.
        assign tt-movto.cd-trib-pis     = int(substring(tt-it-nota-fisc.char-2,96,1))
               tt-movto.cd-trib-cofins  = int(substring(tt-it-nota-fisc.char-2,97,1))
               tt-movto.base-pis        = if tt-movto.cd-trib-pis = 1 then tt-it-nota-fisc.vl-merc-liq else 0
               tt-movto.valor-pis       = if tt-movto.cd-trib-pis = 1 then (tt-it-nota-fisc.vl-merc-liq * decimal(substring(tt-it-nota-fisc.char-2,76,5)) / 100) else 0
               tt-movto.aliquota-pis    = if tt-movto.cd-trib-pis = 1 then dec(substring(tt-it-nota-fisc.char-2,76,5)) else 0
               tt-movto.base-cofins     = if tt-movto.cd-trib-cofins = 1 then tt-it-nota-fisc.vl-merc-liq else 0
               tt-movto.valor-cofins    = if tt-movto.cd-trib-cofins = 1 then (tt-it-nota-fisc.vl-merc-liq * decimal(substring(tt-it-nota-fisc.char-2,81,5)) / 100) else 0
               tt-movto.aliquota-cofins = if tt-movto.cd-trib-cofins = 1 then dec(substring(tt-it-nota-fisc.char-2,81,5)) else 0

               tt-movto.serie-comp      = tt-it-nota-fisc.serie
               tt-movto.nro-comp        = tt-it-nota-fisc.nr-nota-fis
               tt-movto.nat-comp        = tt-it-nota-fisc.nat-operacao
               tt-movto.seq-comp        = tt-it-nota-fisc.nr-seq-fat
               tt-movto.data-comp       = tt-it-nota-fisc.dt-emis-nota
               tt-it-nota-fisc.qt-saldo = tt-it-nota-fisc.qt-saldo - tt-movto.qt-recebida.

        assign tt-movto.cod-estabel     = c-cod-estabel
               tt-movto.uf              = c-estado
               tt-movto.nr-sequencia    = int(int-ds-devolucao-cupom.sequencia)
               tt-movto.valor-mercad    = if int-ds-devolucao-cupom.valor_unit <> 0 
                                          then int-ds-devolucao-cupom.valor_unit * int-ds-devolucao-cupom.quantidade
                                          else tt-it-nota-fisc.vl-preuni * int-ds-devolucao-cupom.quantidade
               tt-movto.cd-trib-ipi     = tt-it-nota-fisc.cd-trib-ipi
               tt-movto.aliquota-ipi    = tt-it-nota-fisc.aliquota-ipi
               tt-movto.cd-trib-icm     = if tt-it-nota-fisc.cd-trib-icm < 5 then tt-it-nota-fisc.cd-trib-icm else 4  /* nota no faturaento s¢ aceita atÇ 4 */
               tt-movto.aliquota-icm    = tt-it-nota-fisc.aliquota-icm
               tt-movto.cd-trib-iss     = tt-it-nota-fisc.cd-trib-iss
               tt-movto.perc-red-icm    = tt-it-nota-fisc.perc-red-icm
               tt-movto.vl-bicms-it     = (tt-it-nota-fisc.vl-bicms-it  / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade
               tt-movto.vl-icms-it      = (tt-it-nota-fisc.vl-icms-it   / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade
               tt-movto.vl-bipi-it      = (tt-it-nota-fisc.vl-bipi-it   / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade
               tt-movto.vl-ipi-it       = (tt-it-nota-fisc.vl-ipi-it    / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade
               tt-movto.vl-bsubs-it     = (tt-it-nota-fisc.vl-bsubs-it  / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade
               tt-movto.vl-icmsub-it    = (tt-it-nota-fisc.vl-icmsub-it / tt-it-nota-fisc.qt-faturada[1]) * int-ds-devolucao-cupom.quantidade.
        
        if tt-movto.vl-ipi-it > 0 then tt-movto.cd-trib-ipi = 3 /* outros */.

        assign tt-movto.observacao = "Devoluá∆o: " + tt-movto.numero_dev + " - "
                                   + " Cupom: " + tt-movto.numero_cup + " Filial: " + c-cod-estab-ori.

        assign tt-movto.observacao = tt-movto.observacao + " - " + 
                    (if trim(int-ds-devolucao-cupom.descricao) <> ? then trim(int-ds-devolucao-cupom.descricao) + "-" else "") +  
                    (if trim(int-ds-devolucao-cupom.vendedor) <> ? then trim(int-ds-devolucao-cupom.vendedor) + "-" else "") + 
                    (if trim(int-ds-devolucao-cupom.gerente) <> ? then trim(int-ds-devolucao-cupom.gerente) + "-" else "").

        for first fat-ser-lote no-lock of tt-it-nota-fisc: 
            assign tt-movto.lote            = fat-ser-lote.nr-serlote
                   tt-movto.dt-vali-lote    = fat-ser-lote.dt-vali-lote.
        end.
    
    end. /* tt-it-nota-fisc */
    
    if not avail tt-it-nota-fisc then do:
        run pi-gera-log (input "Produto n∆o encontrado na nota origem com saldo para devoluá∆o. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                         " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                         " SÇrie: " + c-serie-ori  + 
                         " Item: " + item.it-codigo +
                         " Qtde: " + string(int-ds-devolucao-cupom.quantidade),
                         input 1).
        next.
    end.
    /*
    /* SEM ORIGEM */ 
    if not avail tt-it-nota-fisc then do:
        create tt-movto.
        assign tt-movto.nr-nota-fis     = trim(string(int(int-ds-devolucao-cupom.numero_dev),">>9999999"))
               tt-movto.dt-emissao      = int-ds-devolucao-cupom.data
               tt-movto.cnpj_filial_dev = int-ds-devolucao-cupom.cnpj_filial_dev
               tt-movto.numero_dev      = int-ds-devolucao-cupom.numero_dev
               tt-movto.cnpj_filial_cup = int-ds-devolucao-cupom.cnpj_filial_cup
               tt-movto.numero_cup      = int-ds-devolucao-cupom.numero_cup
               tt-movto.cod-estabel     = ""
               tt-movto.it-codigo       = string(int(int-ds-devolucao-cupom.produto)).
        assign tt-movto.qt-recebida     = int-ds-devolucao-cupom.quantidade.
    
        assign tt-movto.cd-trib-pis    = 2
               tt-movto.cd-trib-cofins = 2
               tt-movto.serie-comp  = ""
               tt-movto.nro-comp    = ""
               tt-movto.nat-comp    = ""
               tt-movto.seq-comp    = 0
               tt-movto.data-comp   = tt-movto.dt-emissao.
        assign tt-movto.cod-estabel     = c-cod-estabel
               tt-movto.uf              = c-estado
               tt-movto.nr-sequencia    = int(int-ds-devolucao-cupom.sequencia)
               tt-movto.qt-recebida     = int-ds-devolucao-cupom.quantidade
               tt-movto.valor-mercad    = int-ds-devolucao-cupom.valor_unit * int-ds-devolucao-cupom.quantidade
               tt-movto.cd-trib-ipi     = natur-oper.cd-trib-ipi
               tt-movto.cd-trib-icm     = if natur-oper.cd-trib-icm < 5 then natur-oper.cd-trib-icm else 4 /* nota no faturaento s¢ aceita atÇ 4 */
               tt-movto.cd-trib-iss     = natur-oper.cd-trib-iss
               tt-movto.aliquota-ipi    = ITEM.aliquota-ipi
               tt-movto.aliquota-icm    = natur-oper.aliquota-icm
               tt-movto.perc-red-icm    = natur-oper.perc-red-icm.

        /*
        DISPLAY 
            natur-oper.nat-operacao
            natur-oper.cd-trib-ipi 
            natur-oper.cd-trib-icm 
            natur-oper.cd-trib-iss 
            ITEM.aliquota-ipi      
            natur-oper.perc-red-icm
            natur-oper.aliquota-icm
            tt-movto.cd-trib-icm
            tt-movto.cd-trib-ipi
            tt-movto.cd-trib-iss
            WITH FRAME f-natureza WIDTH 300 STREAM-IO.
        DOWN WITH FRAME f-natureza.
        */

        assign tt-movto.observacao = "Devoluá∆o: " + tt-movto.numero_dev + " - "
                                   + " Cupom: " + tt-movto.numero_cup + " Filial: " + c-cod-estab-ori.
        
        assign tt-movto.observacao = tt-movto.observacao + " - " + 
             (if trim(int-ds-devolucao-cupom.descricao) <> ? then trim(int-ds-devolucao-cupom.descricao) + "-" else "") +  
             (if trim(int-ds-devolucao-cupom.vendedor) <> ? then trim(int-ds-devolucao-cupom.vendedor) + "-" else "") + 
             (if trim(int-ds-devolucao-cupom.gerente) <> ? then trim(int-ds-devolucao-cupom.gerente) + "-" else "").
    end.
    */             

    assign tt-movto.peso-liquido    = item.peso-liquido * tt-movto.qt-recebida.
    if item.tipo-contr = 4 /* debito direto */ then do:
        assign tt-movto.conta-aplicacao = c-conta
               tt-movto.sc-codigo = c-subconta.
    end.


    assign tt-movto.cod-depos = /*if avail item-uni-estab 
                                then item-uni-estab.deposito-pad
                                else item-estab.deposito-pad.*/ "LOJ".
    
    tt-movto.cod-esp = "DI".
    case int-ds-devolucao-cupom.tipo_titulo:
        when "V" then tt-movto.cod-esp = "CV". /* V   CONV“NIO           */
        when "P" then tt-movto.cod-esp = "CH". /* P   CHEQUE-PRê         */
        when "K" then tt-movto.cod-esp = "DI". /* K   TICKET             */
        when "D" then tt-movto.cod-esp = "DI". /* D   DINHEIRO           */
        when "C" then tt-movto.cod-esp = "CH". /* C   CHEQUE ∑ VISTA     */
        when "T" then tt-movto.cod-esp = "CD". /* T   CART«O DE CRêDITO  */
        when "E" then tt-movto.cod-esp = "CC". /* E   CART«O DE DêBITO   */
        when "L" then tt-movto.cod-esp = "DI". /* L   PBM                */
    end case.

    for first nota-fiscal no-lock of tt-it-nota-fisc: 
       /*
       i-cod-cliente = 0.
       if  int-ds-devolucao-cupom.cpf_cliente <> "" and
           int-ds-devolucao-cupom.cpf_cliente <> ? then do:
           for first emitente FIELDS (cod-emitente)
               no-lock where emitente.cgc = trim(int-ds-devolucao-cupom.cpf_cliente): 
               assign i-cod-cliente = emitente.cod-emitente.
           end.
           if  i-cod-cliente = 0 or 
               not available emitente then do:
               run pi-gera-log (input "Cliente da nota origem n∆o cadastrado: Filial: " + c-cod-estab-ori + 
                                " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                                " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                                " SÇrie: " + c-serie-ori  +
                                " CPF: " +  if int-ds-devolucao-cupom.cpf_cliente <> ? then int-ds-devolucao-cupom.cpf_cliente else "NAO INFORMADO",
                                input 1).
               next.
           end.
       end.
       else do:
           run pi-gera-log (input "CPF do Cliente da devoluá∆o n∆o informado: Filial: " + c-cod-estab-ori + 
                            " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                            " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                            " SÇrie: " + c-serie-ori  + 
                            " CPF: " +  if int-ds-devolucao-cupom.cpf_cliente <> ? then int-ds-devolucao-cupom.cpf_cliente else "NAO INFORMADO",
                            input 1).
           next.
       end.
       */
       /*
       if i-cod-cliente = 0 then 
       for first cst-nota-fiscal no-lock where 
           cst-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel and
           cst-nota-fiscal.serie       = nota-fiscal.serie and
           cst-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis:
           for first emitente FIELDS (cod-emitente)
               no-lock where emitente.cgc = trim(cst-nota-fiscal.cpf-cupom): 
               assign i-cod-cliente = emitente.cod-emitente.
           end.
       end.
       if i-cod-cliente = 0 and not nota-fiscal.nome-ab-cli begins "CONSUMID" then 
       for first emitente FIELDS (cod-emitente)
           no-lock where emitente.cod-emitente = nota-fiscal.cod-emitente: 
           assign i-cod-cliente = emitente.cod-emitente.
       end.
       */
        /*
       for first emitente no-lock where emitente.cod-emitente = i-cod-cliente: end.
       if  i-cod-cliente = 0 or 
           not available emitente then do:
           run pi-gera-log (input "Cliente da nota origem n∆o cadastrado: Filial: " + c-cod-estab-ori + 
                            " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                            " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                            " SÇrie: " + c-serie-ori  +
                            " CPF: " +  if int-ds-devolucao-cupom.cpf_cliente <> ? then int-ds-devolucao-cupom.cpf_cliente else "NAO INFORMADO",
                            input 1).
           next.
       end.
       run cdp/cd6666.p (input emitente.cgc, 
                         input emitente.natureza).
       if decimal(emitente.cgc) = 1 or 
          return-value = 'NOK' then do:
           run pi-gera-log (input "CPF Cliente da devoluá∆o inv†lido: Filial: " + c-cod-estab-ori + 
                            " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                            " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                            " SÇrie: " + c-serie-ori  + 
                            " CPF: " +  if int-ds-devolucao-cupom.cpf_cliente <> ? then int-ds-devolucao-cupom.cpf_cliente else "NAO INFORMADO",
                            input 1).
           next.
       end.
       
       if not can-find (dist-emitente no-lock where
                        dist-emitente.cod-emitente = i-cod-cliente) then do:
          /* cria dist-emitente */
          RUN cdp/cd4336.p(i-cod-cliente).

          if not can-find (dist-emitente no-lock where
                           dist-emitente.cod-emitente = i-cod-cliente) then do:
               run pi-gera-log (input "Emitente da distribuiá∆o para Cliente da nota origem n∆o cadastrado: Filial: " + c-cod-estab-ori + 
                                " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) +
                                " Cupom: " + trim(string(int(int-ds-devolucao-cupom.numero_cup),">>9999999")) + 
                                " SÇrie: " + c-serie-ori  + 
                                " CPF: " +  if int-ds-devolucao-cupom.cpf_cliente <> ? then int-ds-devolucao-cupom.cpf_cliente else "NAO INFORMADO",
                                input 1).
               next.
          end.
       end.
       */
       for first emitente no-lock where emitente.cod-emitente = i-cod-emitente /* emitente do estabelecimento */: end.

       if not can-find(first mgdis.cidade no-lock where 
           cidade.pais = emitente.pais and
           cidade.estado = emitente.estado and
           cidade.cidade = emitente.cidade) then do:
           run pi-gera-log (input "Cidade do cliente n∆o encontrada. Pa°s: " + emitente.pais + " UF: " + emitente.estado + " Cidade: " + emitente.cidade + " Cliente: " + string(emitente.cod-emitente),
                            input 1).
           next.
       end.
       assign tt-movto.cod-emitente = i-cod-emitente.

       /* determina natureza de operacao */
       run intprg/int018a.p (input c-condipag      ,
                             input c-estado        ,
                             input c-cidade        ,
                             input c-cod-estabel   ,
                             input c-convenio      ,
                             input c-class-fiscal  ,
                             output r-rowid).

       c-serie = "1". 
       for last ser-estab no-lock where 
           ser-estab.cod-estabel = c-cod-estabel and
           ser-estab.forma-emis = 1 /* automatica */ and 
           ser-estab.log-nf-eletro /* NFe */:
           c-serie = ser-estab.serie.
       end.
       c-nat-of = "".
       for first int-ds-loja-natur-oper 
           no-lock where rowid(int-ds-loja-natur-oper) = r-rowid: 
           c-nat-of = int-ds-loja-natur-oper.nat-devolucao.
           /*c-serie = int-ds-loja-natur-oper.serie.  fixo atÇ incluir sÇrie no int018 */
       end.

       if  c-nat-of = "" or c-nat-of = ? then do:
           assign c-nat-of = "".
           run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. CNPJ Filial: " + string(int-ds-devolucao-cupom.cnpj_filial_dev) + 
                            " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) + 
                            " Cupom: " + string(int-ds-devolucao-cupom.numero_cup) + 
                            " Natur. Oper.: " + c-nat-of +
                            " Cond. Pagto.: " + c-condipag +
                            " UF: " + c-estado +
                            " Cidade: " + c-cidade + 
                            " Estab.: " + c-cod-estabel +
                            " Convànio: " + c-convenio +
                            " NCM: " + c-class-fiscal,
                            input 1).
           next.
       end.
       for first natur-oper no-lock where 
           natur-oper.nat-operacao = c-nat-of: end.
       if not avail natur-oper then do:
           run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada: " + c-nat-of,
                            input 1).
           next.
       end.
       if c-nat-operacao = "" then c-nat-operacao = c-nat-of.
       assign tt-movto.nat-operacao    = c-nat-operacao
              tt-movto.nat-of          = c-nat-of
              tt-movto.serie           = c-serie. 

       if natur-oper.tipo-compra <> 3 then do:
           run pi-gera-log (input "Natureza de operaá∆o deve ter tipo de compra Devoluá∆o de Cliente. CNPJ Filial: " + 
                            string(int-ds-devolucao-cupom.cnpj_filial_dev) + " Nr. Devoluá∆o: " + 
                            string(int-ds-devolucao-cupom.numero_dev) + " Cupom: " + 
                            string(int-ds-devolucao-cupom.numero_cup) + " Natur. Oper.: " +
                            c-nat-of,
                            input 1).
           next.
       end.
       assign tt-movto.tipo-compra     = natur-oper.tipo-compra.

       /*
       if tt-movto.cod-emitente <> nota-fiscal.cod-emitente then do:
           run pi-altera-nota-origem.
       end.
       */
    end. /* nota-fiscal */
    /*
    if not avail nota-fiscal then do:
       /* determina natureza de operacao */
       run intprg/int018a.p (input c-condipag      ,
                             input c-estado-ori    ,
                             input c-cidade-ori    ,
                             input c-cod-estab-ori ,
                             input c-convenio      ,
                             input c-class-fiscal  ,
                             output r-rowid).

       for first emitente where nome-abrev = "CONSUMIDOR":
           if not can-find(first mgdis.cidade no-lock where 
               cidade.pais = emitente.pais and
               cidade.estado = emitente.estado and
               cidade.cidade = emitente.cidade) then do:
               run pi-gera-log (input "Cidade do cliente n∆o encontrada. Pa°s: " + emitente.pais + " UF: " + emitente.estado + " Cidade: " + emitente.cidade + " Cliente: " + string(emitente.cod-emitente),
                                input 1).
               next.
           end.
           assign tt-movto.cod-emitente = emitente.cod-emitente.
       end.
       for first int-ds-loja-natur-oper no-lock where 
           rowid(int-ds-loja-natur-oper) = r-rowid:
           i-cod-port-ori = int-ds-loja-natur-oper.cod-portador.
           i-modalid-ori = int-ds-loja-natur-oper.modalidade.
           for first cst-cond-pagto no-lock where 
               cst-cond-pagto.cod-cond-pag = int-ds-loja-natur-oper.cod-cond-pag:
               modo-devolucao    = cst-cond-pagto.modo-devolucao.
           end.
       end.
       if not avail int-ds-loja-natur-oper then do:
           run pi-gera-log (input "N∆o encontrado cadastro INT018 para devoluá∆o sem origem. CNPJ Filial: " + string(int-ds-devolucao-cupom.cnpj_filial_dev) + 
                            " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) + 
                            " Cupom: " + string(int-ds-devolucao-cupom.numero_cup) + 
                            " Cond. Pagto.: " + c-condipag +
                            " UF: " + c-estado-ori +
                            " Cidade: " + c-cidade-ori + 
                            " Estab.: " + c-cod-estab-ori +
                            " Convànio: " + c-convenio +
                            " NCM: " + c-class-fiscal,
                            input 1).
           next.
       end.
    end.
    */
    if last-of (int-ds-devolucao-cupom.numero_dev)  then do:
        if not can-find(first tt-movto) then do:
            run pi-gera-log (input "Documento sem itens. CNPJ Filial: " + string(int-ds-devolucao-cupom.cnpj_filial_dev) + 
                                   " Nr. Devoluá∆o: " + string(int-ds-devolucao-cupom.numero_dev) + " Cupom: " + string(int-ds-devolucao-cupom.numero_cup),
                             input 1).
            next.
        end.
        for first docum-est no-lock where
            tt-movto.cod-estabel    = docum-est.cod-estabel   and
            tt-movto.cod-emitente   = docum-est.cod-emitente  and 
            tt-movto.serie          = docum-est.serie-docto   and 
            tt-movto.nr-nota-fis    = docum-est.nro-docto     /*and 
            tt-movto.nat-operacao   = docum-est.nat-operacao*/: end.
        if avail docum-est then do:
            run pi-gera-log (input "Documento de estoque j† cadastrado. Filial: " + 
                             c-cod-estabel + " Emitente: " + string(docum-est.cod-emitente) + 
                             " SÇrie: " + docum-est.serie-docto +
                             " Docto.: " + docum-est.nro-docto +
                             /*" Natur. Oper.: " + docum-est.nat-operacao + */
                             " Cupom: " + string(int-ds-devolucao-cupom.numero_cup),
                             input 1).
            next.
        end.
        for each cst-fat-devol no-lock where
            cst-fat-devol.cod-estabel = tt-movto.cod-estabel and 
            cst-fat-devol.numero-dev  = trim(string(tt-movto.numero_dev))
            query-tuning(no-lookahead):
            /* devolucoes antes de alterar para nfd do estabelecimento */
            for first it-nota-fisc fields (dt-cancela nr-nota-fis)
                no-lock where 
                it-nota-fisc.cod-estabel = cst-fat-devol.cod-estabel and
                it-nota-fisc.serie-docum = cst-fat-devol.serie-comp and
                it-nota-fisc.nr-docum    = cst-fat-devol.nro-comp and
                it-nota-fisc.dt-cancela  = ?: 
                run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                 c-cod-estabel + " Emitente: " + string(cst-fat-devol.cod-emitente) + 
                                 " SÇrie: " + cst-fat-devol.serie-docto +
                                 " Docto.: " + cst-fat-devol.nro-docto +
                                 " Natur. Oper.: " + cst-fat-devol.nat-operacao + 
                                 " Cupom: " + string(tt-movto.numero_cup) + 
                                 " Devoluá∆o PRS: " + cst-fat-devol.numero-dev +
                                 " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                 input 1).
                for each bint-ds-devolucao-cupom exclusive where
                    bint-ds-devolucao-cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint-ds-devolucao-cupom.numero_dev       = trim(string(int(tt-movto.numero_dev)))
                    query-tuning(no-lookahead):
                    assign  bint-ds-devolucao-cupom.situacao = 5 /* processada */.
                    release bint-ds-devolucao-cupom.
                end.
                next for-dev.
            end.
            /* devolucoes depois de alterar para nfd do estabelecimento */
            for first it-nota-fisc fields (dt-cancela nr-nota-fis)
                no-lock where 
                it-nota-fisc.cod-estabel = cst-fat-devol.cod-estabel and
                it-nota-fisc.serie       = cst-fat-devol.serie-docto and
                it-nota-fisc.nr-nota-fis = cst-fat-devol.nro-docto   and
                it-nota-fisc.dt-cancela  = ?: 
                run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                 c-cod-estabel + " Emitente: " + string(cst-fat-devol.cod-emitente) + 
                                 " SÇrie: " + cst-fat-devol.serie-docto +
                                 " Docto.: " + cst-fat-devol.nro-docto +
                                 " Natur. Oper.: " + cst-fat-devol.nat-operacao + 
                                 " Cupom: " + string(tt-movto.numero_cup) + 
                                 " Devoluá∆o PRS: " + cst-fat-devol.numero-dev +
                                 " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                 input 1).
                for each bint-ds-devolucao-cupom exclusive where
                    bint-ds-devolucao-cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint-ds-devolucao-cupom.numero_dev       = trim(string(int(tt-movto.numero_dev)))
                    query-tuning(no-lookahead):
                    assign  bint-ds-devolucao-cupom.situacao = 5 /* processada */.
                    release bint-ds-devolucao-cupom.
                end.
                next for-dev.
            end.
            if not avail it-nota-fisc then do:
                for each docum-est no-lock where 
                    docum-est.cod-estabel  = c-cod-estabel               and
                    docum-est.cod-emitente = cst-fat-devol.cod-emitente  and
                    docum-est.serie-docto  = cst-fat-devol.serie-docto   and
                    docum-est.nat-operacao = cst-fat-devol.nat-operacao  and
                    docum-est.dt-trans    >= int-ds-devolucao-cupom.data and
                    docum-est.esp-docto    = 20,
                    first item-doc-est no-lock of docum-est where 
                    item-doc-est.it-codigo = tt-movto.it-codigo,
                    first it-nota-fisc fields (nr-nota-fis dt-cancela) no-lock where 
                    it-nota-fisc.cod-estabel = docum-est.cod-estabel and
                    it-nota-fisc.serie       = docum-est.serie-docto and
                    it-nota-fisc.nr-nota-fis = docum-est.nro-docto   and
                    it-nota-fisc.dt-cancela   = ?
                    query-tuning(no-lookahead):
                    if int(item-doc-est.nr-pedcli) = int(tt-movto.nr-nota-fis) then do:
                        run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                         c-cod-estabel + " Emitente: " + string(cst-fat-devol.cod-emitente) + 
                                         " SÇrie: " + cst-fat-devol.serie-docto +
                                         " Docto.: " + cst-fat-devol.nro-docto +
                                         " Natur. Oper.: " + cst-fat-devol.nat-operacao + 
                                         " Cupom: " + string(tt-movto.numero_cup) + 
                                         " Devoluá∆o PRS: " + cst-fat-devol.numero-dev +
                                         " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                         input 1).
                        for each bint-ds-devolucao-cupom exclusive where
                            bint-ds-devolucao-cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                            bint-ds-devolucao-cupom.numero_dev       = trim(string(int(tt-movto.numero_dev)))
                            query-tuning(no-lookahead):
                            assign  bint-ds-devolucao-cupom.situacao = 5 /* processada */.
                            release bint-ds-devolucao-cupom.
                        end.
                        next for-dev.
                    end.
                end.
            end.
        end.
        if not l-erro then
            run PiGeraMovimento (input table tt-movto,   
                                 input '').
    end.
    release int-ds-devolucao-cupom.
end.
run pi-elimina-tt.

/* fechamento do output do relat¢rio  */
if tt-param.arquivo <> "" then do:
    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
end.

run pi-finalizar in h-acomp.

return "OK":U.


procedure PiGeraMovimento:

    def input parameter table for tt-movto.
    def input parameter p-narrativa as char no-undo. 
    
    /******* GERA DOCUMENTO PARA DevolucaoS CONFORME PARAMETRO RECEBIDO *************/
    empty temp-table tt-versao-integr. 
    empty temp-table tt-docum-est-nova.     
    empty temp-table tt-item-doc-est-nova.  
    empty temp-table tt-dupli-apagar.  
    empty temp-table tt-dupli-imp.     
    empty temp-table tt-unid-neg-nota. 
    empty temp-table tt-erro.

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
        estab-mat.cod-estabel = c-cod-estabel 
        no-error.
    if not avail estab-mat then do:
        run pi-gera-log (input ("Estabelecimento materiais n∆o cadastrado: " + estabelec.cod-estabel),
                         input 1).
        next.
    end.
        
    create tt-versao-integr.
    assign tt-versao-integr.registro              = 1
           tt-versao-integr.cod-versao-integracao = 4.

    run pi-gera-tt-fat-devol.
    i-seq = 0.
    for each tt-movto
        break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nat-operacao
              by tt-movto.nr-sequencia
              by tt-movto.it-codigo:

        if first-of (tt-movto.nr-nota-fis) then do:
            i-seq = i-seq + 1.
            create tt-docum-est-nova.
            assign tt-docum-est-nova.registro          = 2
                   tt-docum-est-nova.serie-docto       = tt-movto.serie 
                   tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis
                   tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente
                   tt-docum-est-nova.nat-operacao      = tt-movto.nat-operacao
                   tt-docum-est-nova.cod-observa       = tt-movto.tipo-compra
                   tt-docum-est-nova.cod-estabel       = tt-movto.cod-estabel
                   tt-docum-est-nova.estab-fisc        = tt-movto.cod-estabel
                   tt-docum-est-nova.observacao        = tt-movto.observacao
                   tt-docum-est-nova.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                    estab-mat.conta-dev-cli
                                                    &else
                                                    estab-mat.cod-cta-devol-c-unif
                                                    &endif
                   tt-docum-est-nova.sc-transit        = ""
                   tt-docum-est-nova.dt-emissao        = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-trans          = today
                   tt-docum-est-nova.usuario           = c-seg-usuario
                   tt-docum-est-nova.uf                = tt-movto.uf
                   tt-docum-est-nova.via-transp        = 1
                   tt-docum-est-nova.mod-frete         = 1
                   tt-docum-est-nova.nff               = yes
                   tt-docum-est-nova.tot-desconto      = 0
                   tt-docum-est-nova.valor-frete       = 0
                   tt-docum-est-nova.valor-seguro      = 0
                   tt-docum-est-nova.valor-embal       = 0
                   tt-docum-est-nova.valor-outras      = 0
                   tt-docum-est-nova.dt-venc-ipi       = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-venc-icm       = tt-movto.dt-emissao
                   tt-docum-est-nova.efetua-calculo    = 1 /*1 - efetua os c†lculos - <> 1 valor informado*/
                   tt-docum-est-nova.sequencia         = i-seq
                   tt-docum-est-nova.esp-docto         = 20 /* NFD */
                   tt-docum-est-nova.rec-fisico        = no
                   tt-docum-est-nova.origem            = "" /* verificar*/
                   tt-docum-est-nova.pais-origem       = "Brasil"
                   tt-docum-est-nova.cotacao-dia       = 0
                   tt-docum-est-nova.embarque          = ""
                   tt-docum-est-nova.gera-unid-neg     = 0.
        end.

        run pi-acompanhar in h-acomp (input string(tt-movto.nr-nota-fis + "/" + tt-movto.it-codigo)).
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
               tt-item-doc-est-nova.desconto           = 0
               tt-item-doc-est-nova.vl-frete-cons      = 0
               tt-item-doc-est-nova.despesas           = 0
               tt-item-doc-est-nova.peso-liquido       = tt-movto.peso-liquido * tt-movto.qt-recebida
               tt-item-doc-est-nova.cod-depos          = tt-movto.cod-depos
               tt-item-doc-est-nova.cod-localiz        = ""
               tt-item-doc-est-nova.lote               = tt-movto.lote
               tt-item-doc-est-nova.dt-vali-lote       = tt-movto.dt-vali-lote
               tt-item-doc-est-nova.class-fiscal       = tt-movto.class-fiscal
               tt-item-doc-est-nova.aliquota-ipi       = tt-movto.aliquota-ipi
               tt-item-doc-est-nova.cd-trib-ipi        = tt-movto.cd-trib-ipi 
               tt-item-doc-est-nova.base-ipi           = tt-item-doc-est-nova.preco-total
               tt-item-doc-est-nova.valor-ipi          = tt-movto.vl-ipi-it
               tt-item-doc-est-nova.cd-trib-iss        = tt-movto.cd-trib-iss
               tt-item-doc-est-nova.aliquota-icm       = tt-movto.aliquota-icm
               tt-item-doc-est-nova.cd-trib-icm        = tt-movto.cd-trib-icm 
               tt-item-doc-est-nova.base-icm           = tt-item-doc-est-nova.preco-total
               tt-item-doc-est-nova.valor-icm          = tt-movto.vl-icms-it
               tt-item-doc-est-nova.base-subs          = tt-movto.vl-bsubs-it  
               tt-item-doc-est-nova.valor-subs         = tt-movto.vl-icmsub-it 
               tt-item-doc-est-nova.icm-complem        = 0
               tt-item-doc-est-nova.ind-icm-ret        = if tt-movto.vl-icmsub-it <> 0 then yes else no
               tt-item-doc-est-nova.narrativa          = p-narrativa
               tt-item-doc-est-nova.icm-outras         = 0
               tt-item-doc-est-nova.ipi-outras         = 0
               tt-item-doc-est-nova.iss-outras         = 0
               tt-item-doc-est-nova.icm-ntrib          = 0
               tt-item-doc-est-nova.ipi-ntrib          = 0
               tt-item-doc-est-nova.iss-ntrib          = 0 
               tt-item-doc-est-nova.serie-docto        = tt-docum-est-nova.serie-docto
               tt-item-doc-est-nova.nro-docto          = tt-docum-est-nova.nro-docto   
               tt-item-doc-est-nova.cod-emitente       = tt-docum-est-nova.cod-emitente
               tt-item-doc-est-nova.nat-operacao       = tt-docum-est-nova.nat-operacao 
               tt-item-doc-est-nova.nat-of             = tt-movto.nat-of
               tt-item-doc-est-nova.sequencia          = tt-movto.nr-sequencia
               tt-item-doc-est-nova.nr-proc-imp        = ""
               tt-item-doc-est-nova.nr-ato-concessorio = ""
               tt-item-doc-est-nova.cd-trib-pis        = tt-movto.cd-trib-pis
               tt-item-doc-est-nova.cd-trib-cofins     = tt-movto.cd-trib-cofins
               tt-item-doc-est-nova.data-comp          = if tt-movto.data-comp <> ? and c-cod-estab-ori = c-cod-estabel then tt-movto.data-comp else today
               tt-item-doc-est-nova.ct-codigo          = tt-movto.conta-aplicacao
               tt-item-doc-est-nova.sc-codigo          = tt-movto.sc-codigo
               tt-item-doc-est-nova.base-pis           = tt-movto.base-pis       
               tt-item-doc-est-nova.valor-pis          = tt-movto.valor-pis      
               tt-item-doc-est-nova.aliquota-pis       = tt-movto.aliquota-pis   
               tt-item-doc-est-nova.base-cofins        = tt-movto.base-cofins    
               tt-item-doc-est-nova.valor-cofins       = tt-movto.valor-cofins   
               tt-item-doc-est-nova.aliquota-cofins    = tt-movto.aliquota-cofins
               tt-docum-est-nova.valor-mercad          = tt-docum-est-nova.valor-mercad + tt-item-doc-est-nova.preco-total.
        /* para entrada com cliente do estabelecimento n∆o pode preencher origem pois a origem Ç de outro cliente
        assign tt-item-doc-est-nova.serie-comp         = if c-cod-estab-ori = c-cod-estabel then tt-movto.serie-comp else ""
               tt-item-doc-est-nova.nro-comp           = if c-cod-estab-ori = c-cod-estabel then tt-movto.nro-comp   else ""
               tt-item-doc-est-nova.nat-comp           = if c-cod-estab-ori = c-cod-estabel then tt-movto.nat-comp   else ""
               tt-item-doc-est-nova.seq-comp           = if c-cod-estab-ori = c-cod-estabel then tt-movto.seq-comp   else 0.
               */
        /*
        PUT tt-movto.numero_dev     " " 
            tt-movto.cod-estabel    " "
            tt-movto.serie          " " 
            tt-movto.nr-nota-fis    " " 
            tt-movto.nat-operacao   " " 
            tt-movto.it-codigo      " " 
            tt-movto.nr-sequencia   " " 
            tt-movto.cod-estab-ori  " " 
            tt-movto.serie-comp     " " 
            tt-movto.nro-comp       " " 
            tt-movto.seq-comp       " "
            tt-movto.valor-mercad   " " 
            SKIP.
        */
        /* erro na api reapi190b - divis∆o por zero quando desconto de 100 % */
        for FIRST it-nota-fisc
            WHERE it-nota-fisc.cod-estabel = tt-movto.cod-estabel
              and it-nota-fisc.serie       = tt-movto.serie-comp
              and it-nota-fisc.nr-nota-fis = tt-movto.nro-comp
              and it-nota-fisc.nr-seq-fat  = tt-movto.seq-comp
              and it-nota-fisc.it-codigo   = tt-movto.it-codigo. 
            /* evitando erro api pis subs - retornar ap¢s entrada do documento */
            IF it-nota-fisc.vl-merc-liq = 0 THEN
                it-nota-fisc.vl-merc-liq = 0.00001.
        END.
        /*
        if NOT AVAIL it-nota-fisc then PUT "CAD“ A NOTA!!!" SKIP.*/
        
        if last-of (tt-movto.nr-nota-fis) then 
        do-trans:
        do on error undo, leave:
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
                /*
               find first tt-docum-est-nova.
               for first tt-movto where
                   tt-movto.cod-emitente = tt-docum-est-nova.cod-emitente  and 
                   tt-movto.serie        = tt-docum-est-nova.serie-docto   and 
                   tt-movto.nr-nota-fis  = tt-docum-est-nova.nro-docto     and 
                   tt-movto.nat-operacao = tt-docum-est-nova.nat-operacao: end.
                   */
               put /* stream str-rp */ skip(1).
               for each tt-erro:
                   RUN pi-gera-log("Erro API. Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                   " SÇrie: " + tt-movto.serie        +
                                   " NF: "  + tt-movto.nr-nota-fis  +
                                   " Natur. Oper.: " + tt-movto.nat-operacao + 
                                   " Estab.: " + tt-movto.cod-estabel  + " - " + 
                                   "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + tt-erro.mensagem,
                                   1).
               end.
               undo do-trans, leave do-trans.
            end.
            /* erro na api reapi190b - divis∆o por zero quando desconto de 100 % */
            for EACH it-nota-fisc
                WHERE it-nota-fisc.cod-estabel = tt-movto.cod-estabel
                  and it-nota-fisc.serie       = tt-movto.serie-comp
                  and it-nota-fisc.nr-nota-fis = tt-movto.nro-comp
                query-tuning(no-lookahead):
                /* evitando erro api pis subs - retornar ap¢s entrada do documento */
                IF it-nota-fisc.vl-merc-liq = 0.00001 THEN
                    it-nota-fisc.vl-merc-liq = 0.00000.
            END.

            for first docum-est exclusive-lock of tt-docum-est-nova:

                for first emitente fields (nome-abrev)
                    no-lock where emitente.cod-emitente = docum-est.cod-emitente: end.
                if docum-est.cod-emitente = 8484 /* consumidor */ then do:
                    for first loc-entr no-lock where
                        loc-entr.nome-abrev  = emitente.nome-abrev and
                        loc-entr.cod-entrega = c-estado:
                        assign  docum-est.endereco = loc-entr.endereco
                                docum-est.cidade   = loc-entr.cidade
                                docum-est.uf       = loc-entr.estado
                                docum-est.bairro   = loc-entr.bairro
                                docum-est.cep      = loc-entr.cep
                                docum-est.pais     = loc-entr.pais.
                    end.
                end.
                for first estabelec no-lock where estabelec.cod-estabel = docum-est.cod-estabel:
                    if docum-est.uf <> estabelec.estado then
                    assign  docum-est.endereco = estabelec.endereco
                            docum-est.cidade   = estabelec.cidade
                            docum-est.uf       = estabelec.estado
                            docum-est.bairro   = estabelec.bairro
                            docum-est.cep      = string(estabelec.cep)
                            docum-est.pais     = estabelec.pais.
                end.

                /* armazenando numro do documento j† que nro-docto que ser† alterado quando calculada a nota */
                for each item-doc-est of docum-est
                    query-tuning(no-lookahead):
                    assign item-doc-est.nr-pedcli = tt-movto.nr-nota-fis.
                end.

                for each tt-cst-fat-devol where 
                    tt-cst-fat-devol.cod-estabel  = tt-docum-est-nova.cod-estabel   and  
                    tt-cst-fat-devol.cod-emitente = tt-docum-est-nova.cod-emitente  and  
                    tt-cst-fat-devol.serie-docto  = tt-docum-est-nova.serie-docto   and  
                    tt-cst-fat-devol.nro-docto    = tt-docum-est-nova.nro-docto     and  
                    tt-cst-fat-devol.nat-operacao = tt-docum-est-nova.nat-operacao
                    query-tuning(no-lookahead):
                    for first cst-fat-devol where
                        cst-fat-devol.cod-estabel  = tt-cst-fat-devol.cod-estabel   and  
                        cst-fat-devol.cod-emitente = tt-cst-fat-devol.cod-emitente  and  
                        cst-fat-devol.serie-docto  = tt-cst-fat-devol.serie-docto   and  
                        cst-fat-devol.nro-docto    = tt-cst-fat-devol.nro-docto     and  
                        cst-fat-devol.nat-operacao = tt-cst-fat-devol.nat-operacao  and
                        cst-fat-devol.parcela      = tt-cst-fat-devol.parcela:
                        if not cst-fat-devol.flag-atualiz then delete cst-fat-devol.
                    end.
                    if not avail cst-fat-devol then do:
                        create cst-fat-devol.
                        buffer-copy tt-cst-fat-devol to cst-fat-devol.
                    end.
                end.
                create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int024-re1005.txt"
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

                for each tt-cst-fat-devol where 
                    tt-cst-fat-devol.cod-estabel  = tt-docum-est-nova.cod-estabel   and  
                    tt-cst-fat-devol.cod-emitente = tt-docum-est-nova.cod-emitente  and  
                    tt-cst-fat-devol.serie-docto  = tt-docum-est-nova.serie-docto   and  
                    tt-cst-fat-devol.nro-docto    = tt-docum-est-nova.nro-docto     and  
                    tt-cst-fat-devol.nat-operacao = tt-docum-est-nova.nat-operacao
                    query-tuning(no-lookahead):
                    for first cst-fat-devol where
                        cst-fat-devol.cod-estabel  = tt-cst-fat-devol.cod-estabel   and  
                        cst-fat-devol.cod-emitente = tt-cst-fat-devol.cod-emitente  and  
                        cst-fat-devol.serie-docto  = tt-cst-fat-devol.serie-docto   and  
                        cst-fat-devol.nro-docto    = tt-cst-fat-devol.nro-docto     and  
                        cst-fat-devol.nat-operacao = tt-cst-fat-devol.nat-operacao  and
                        cst-fat-devol.parcela      = tt-cst-fat-devol.parcela:
                        /* devolucao no mesmo estabelecimento de compra 
                        if cst-fat-devol.cod-estabel = cst-fat-devol.cod-estab-comp then 
                            for last it-nota-fisc no-lock where 
                                it-nota-fisc.cod-estabel = cst-fat-devol.cod-estabel and
                                it-nota-fisc.serie       = cst-fat-devol.serie-docto and
                                it-nota-fisc.nr-docum    = cst-fat-devol.nro-comp    and
                                it-nota-fisc.serie-docum = cst-fat-devol.serie-comp  and
                                it-nota-fisc.dt-emis-nota = today:
                                assign cst-fat-devol.nro-docto = it-nota-fisc.nr-nota-fis.
                            end.
                        else*/
                            for last item-doc-est no-lock where 
                                item-doc-est.cod-emitente = cst-fat-devol.cod-emitente and
                                item-doc-est.serie-docto  = cst-fat-devol.serie-docto  and
                                item-doc-est.nat-operacao = cst-fat-devol.nat-operacao and
                                item-doc-est.nr-pedcli    = cst-fat-devol.nro-docto,
                                first bdocum-est of item-doc-est no-lock where
                                bdocum-est.dt-trans       = tt-docum-est-nova.dt-trans:
                                assign cst-fat-devol.nro-docto = item-doc-est.nro-docto.
                            end.
                    end.
                end.
                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " SÇrie: " + tt-movto.serie        +
                                " NF: "  + tt-movto.nr-nota-fis  +
                                " Natur. Oper.: " + tt-movto.nat-operacao + " - " + "Documento gerado com sucesso!",
                                2).
                for each bint-ds-devolucao-cupom exclusive where
                    bint-ds-devolucao-cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint-ds-devolucao-cupom.numero_dev       = trim(string(int(tt-movto.numero_dev),"999999"))
                    query-tuning(no-lookahead):
                    assign  bint-ds-devolucao-cupom.situacao = 2 /* processada */.
                    release bint-ds-devolucao-cupom.
                end.
            end.
            run pi-elimina-tt.
        end. /* trans */
    end.
    run pi-elimina-tt.
end procedure. /* PiGeraMovimento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    if tt-param.arquivo <> "" then do:    
        put /* stream str-rp */ unformatted
            int-ds-devolucao-cupom.cnpj_filial_cup + "/" + 
            int-ds-devolucao-cupom.numero_dev + "/" + 
            int-ds-devolucao-cupom.numero_cup + " - " +
            c-informacao
            skip.
    end.
    if i-situacao = 1 then l-erro = yes.

    RUN intprg/int999.p ("NFDCUP", 
                         int-ds-devolucao-cupom.cnpj_filial_cup + "/" + 
                         int-ds-devolucao-cupom.numero_dev + "/" + 
                         int-ds-devolucao-cupom.numero_cup,
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario).
end.

procedure pi-gera-tt-fat-devol:

    i-parcela = 0.
    for each tt-movto break by tt-movto.cod-esp:

        if first-of (tt-movto.cod-esp) then do:
            de-vl-fat-devol = 0.
            i-cod-port-ori  = i-cod-port-dinh.
            i-modalid-ori   = i-modalid-dinh.
            c-modo-devolucao = "Dinheiro".
            for first cst-cond-pagto no-lock where 
                cst-cond-pagto.cod-cond-pag = i-cond-pag-dinh:
                c-modo-devolucao = cst-cond-pagto.modo-devolucao.
            end.
            for each fat-duplic no-lock where
                fat-duplic.cod-estabel  = tt-movto.cod-estab-ori and
                fat-duplic.serie        = tt-movto.serie-comp    and
                fat-duplic.nr-fatura    = tt-movto.nro-comp      and
                fat-duplic.cod-esp      = tt-movto.cod-esp,
                first cst-fat-duplic no-lock of fat-duplic
                query-tuning(no-lookahead):
    
                i-cod-port-ori = cst-fat-duplic.cod-portador.
                i-modalid-ori  = cst-fat-duplic.modalidade.
    
                for first cst-cond-pagto no-lock where 
                    cst-cond-pagto.cod-cond-pag = cst-fat-duplic.cod-cond-pag:
                    c-modo-devolucao = cst-cond-pagto.modo-devolucao.
                end.
            end.
        end.

        de-vl-fat-devol = de-vl-fat-devol + tt-movto.valor-mercad.
        if last-of (tt-movto.cod-esp) then do:
            i-parcela = i-parcela + 1.
            create  tt-cst-fat-devol.
            assign  tt-cst-fat-devol.cod-estabel    = tt-movto.cod-estabel
                    tt-cst-fat-devol.serie-docto    = tt-movto.serie
                    tt-cst-fat-devol.nro-docto      = tt-movto.nr-nota-fis
                    tt-cst-fat-devol.cod-emitente   = tt-movto.cod-emitente
                    tt-cst-fat-devol.nat-operacao   = tt-movto.nat-operacao
                    tt-cst-fat-devol.cod-esp        = tt-movto.cod-esp
                    tt-cst-fat-devol.parcela        = trim(string(i-parcela))
                    tt-cst-fat-devol.vl-devolucao   = de-vl-fat-devol
                    tt-cst-fat-devol.dt-vencto      = tt-movto.dt-emissao
                    tt-cst-fat-devol.cod-portador   = i-cod-port-ori
                    tt-cst-fat-devol.modalidade     = i-modalid-ori
                    tt-cst-fat-devol.modo-devolucao = c-modo-devolucao
                    tt-cst-fat-devol.serie-comp     = tt-movto.serie-comp
                    tt-cst-fat-devol.nro-comp       = tt-movto.nro-comp
                    tt-cst-fat-devol.numero-dev     = trim(string(tt-movto.numero_dev))
                    tt-cst-fat-devol.cod-estab-comp = tt-movto.cod-estab-ori.
        end.
    end.

end.

procedure pi-altera-nota-origem:
    define buffer bnota-fiscal for nota-fiscal.
    define buffer bit-nota-fisc for it-nota-fisc.
    define buffer bemitente for emitente.
    for first bemitente fields (cod-emitente nome-abrev)
        no-lock where bemitente.cod-emitente = tt-movto.cod-emitente:
        for first bnota-fiscal exclusive where
            rowid(bnota-fiscal) = rowid(nota-fiscal):
            for each bit-nota-fisc exclusive of bnota-fiscal
                query-tuning(no-lookahead):
                assign  bit-nota-fisc.nome-ab-cli = bemitente.nome-abrev.
            end.
            assign  bnota-fiscal.cod-emitente = bemitente.cod-emitente 
                    bnota-fiscal.nome-ab-cli  = bemitente.nome-abrev
                    bnota-fiscal.cgc          = bemitente.cgc.
        end.
        for first doc-fiscal exclusive where 
            doc-fiscal.cod-estabel  = nota-fiscal.cod-estabel  and
            doc-fiscal.serie        = nota-fiscal.serie        and
            doc-fiscal.nr-doc-fis   = nota-fiscal.nr-nota-fis  and
            doc-fiscal.cod-emitente = nota-fiscal.cod-emitente:
            for each it-doc-fisc exclusive of doc-fiscal
                query-tuning(no-lookahead):
                assign  it-doc-fisc.cod-emitente = bemitente.cod-emitente.
            end.
            assign  doc-fiscal.cod-emitente = bemitente.cod-emitente
                    doc-fiscal.nome-ab-emi  = bemitente.nome-abrev
                    doc-fiscal.cgc          = bemitente.cgc.
        end.
    end.
end.

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-docto.
   empty temp-table tt-it-docto.
   empty temp-table tt-it-imposto.
   empty temp-table tt-saldo-estoq.
   empty temp-table tt-nota-trans.
   empty temp-table tt-fat-duplic.
   empty temp-table tt-fat-repre.
   empty temp-table tt-nota-embal.
   empty temp-table tt-item-embal.
   empty temp-table tt-cst-nota-fiscal. 
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-int-ds-nota-loja-cartao. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
end.        

procedure pi-elimina-tt:
    empty temp-table tt-versao-integr. 
    empty temp-table tt-docum-est-nova.
    empty temp-table tt-item-doc-est-nova.
    empty temp-table tt-dupli-apagar.  
    empty temp-table tt-dupli-imp.     
    empty temp-table tt-unid-neg-nota. 
    empty temp-table tt-erro.
    empty temp-table tt-movto.
    empty temp-table tt-cst-fat-devol.
    empty temp-table tt-it-nota-fisc.
end.



{intprg/int020rp.i1}
