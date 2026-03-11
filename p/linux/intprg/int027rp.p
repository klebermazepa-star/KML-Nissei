/********************************************************************************
** Programa: INT027 - Importaá∆o de Devoluá‰es de CUPOM do Toturial/PRS
**
** Versao : 12 - 10/05/2016 - Alessandro V Baccin
**
********************************************************************************/
{utp/ut-glob.i}

/* include de controle de vers∆o */
{include/i-prgvrs.i int027rp 2.12.04.AVB}
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

{intprg/int020rp-1.i} /* Definiá∆o de vari†veis */

def temp-table tt-cst_nota_fiscal like cst_nota_fiscal.
def temp-table tt-int_ds_nota_loja_cartao like int_ds_nota_loja_cartao
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
    field cnpj_filial_dev   like int_ds_devolucao_cupom.cnpj_filial_dev
    field numero_dev        like int_ds_devolucao_cupom.numero_dev
    field cnpj_filial_cup   like int_ds_devolucao_cupom.cnpj_filial_cup
    field numero_cup        like int_ds_devolucao_cupom.numero_cup
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
    field cod-esp               like cst_fat_devol.cod_esp.

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

define temp-table tt-cst_fat_devol like cst_fat_devol.

define temp-table tt-it-nota-fisc like it-nota-fisc
    field qt-saldo as decimal
    INDEX id-it-nota
            cod-estabel
            serie      
            nr-nota-fis
            nr-seq-fat 
            it-codigo  
    INDEX id-ult-nota
            cod-estabel
            nr-nota-fis
            it-codigo  
            qt-saldo
            dt-emis-nota.

define buffer bint_ds_devolucao_cupom for int_ds_devolucao_cupom.
define buffer bdocum-est for docum-est.
{method/dbotterr.i}

/* recebimento de parÉmetros */

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
ASSIGN tt-param.arquivo = "int027.txt"
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
def var c-nat-origem    as char no-undo.
/*def var c-condipag      as char no-undo.*/
/*def var c-convenio      as char no-undo.*/
/*def var i-cod-portador  as integer no-undo.*/
/*def var i-modalidade    as integer no-undo.*/
def var c-estado-dev        as char no-undo. 
def var c-cidade-dev        as char no-undo. 
def var c-cod-estab-dev   as char no-undo.

def var c-class-fiscal-dev  as char no-undo.
def var c-serie-dev         as char no-undo.

def var c-estado-ori    as char no-undo. 
def var c-cidade-ori    as char no-undo. 
def var c-cod-estab-ori as char no-undo.
def var i-cod-port-ori  as integer no-undo.
def var i-modalid-ori   as integer no-undo.
def var c-cod-esp-dev   as char no-undo.
def var i-cod-emit-dev  as integer no-undo.
def var c-modo-devolucao  like cst_fat_devol.modo_devolucao.
def var i-seq           as integer no-undo.
def var i-cod-cliente   as integer no-undo.
def var de-vl-fat-devol as decimal no-undo.
def var i-parcela       as integer no-undo.
/*def var i-cod-port-dinh as integer initial 99901 no-undo.
def var i-modalid-dinh  as integer initial 6 no-undo.
def var i-cond-pag-dinh as integer initial 1 no-undo.
*/
def var c-serie-ori      as char no-undo.
def var c-conta          as char no-undo.
def var c-subconta       as char no-undo.
def var c-numero-cup     as char no-undo.
def var l-aux            as log  no-undo.
def var c-periodo-fecha  as char no-undo.
/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 

assign c-programa     = "int027"
       c-versao       = "2.12"
       c-revisao      = ".04.AVB"
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
define buffer bdevolucao-cupom for int_ds_devolucao_cupom.
for-dev:
for each int_ds_devolucao_cupom WHERE
    int_ds_devolucao_cupom.situacao = 1
/*
     and int_ds_devolucao_cupom.cnpj_filial_dev = "79430682024064" 
     AND int_ds_devolucao_cupom.numero_dev      = "441775"         
     AND int_ds_devolucao_cupom.numero_cup      = "004424"         
*/


    query-tuning(no-lookahead)
    break by int_ds_devolucao_cupom.cnpj_filial_dev
            by int_ds_devolucao_cupom.numero_dev
                by int_ds_devolucao_cupom.produto
                  by int_ds_devolucao_cupom.quantidade desc
                    by int_ds_devolucao_cupom.sequencia:


    if first-of (int_ds_devolucao_cupom.numero_dev) then do:
        assign c-nat-operacao = "".
        assign l-erro = no.
        empty temp-table tt-movto.
        empty temp-table tt-it-nota-fisc.
        assign c-condipag      = '01' /* dinheiro */
               c-convenio      = "N".
        for last int_ds_nota_loja no-lock where
            int_ds_nota_loja.cnpj_filial = int_ds_devolucao_cupom.cnpj_filial_cup and
            int_ds_nota_loja.num_nota = int_ds_devolucao_cupom.numero_cup and
            int_ds_nota_loja.emissao <= int_ds_devolucao_cupom.data: 
            /* se cupom pendente de importaá∆o, importa pelo int020 */
            if int_ds_nota_loja.situacao = 1 then do:
                {intprg/int020rp-2.i}
                run importa-nota.
                run pi-elimina-tabelas.
            end.
        end.
    end.
    else if l-erro then next.

    c-estado-dev    = ''.
    c-cidade-dev    = ''.
    c-cod-estab-dev = ''.
    i-cod-emit-dev  = 0.
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo cod-emitente) 
        no-lock where
        estabelec.cgc = int_ds_devolucao_cupom.cnpj_filial_dev,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= /*int_ds_devolucao_cupom.data*/ TODAY
        query-tuning(no-lookahead):
        c-estado-dev    = estabelec.estado.
        c-cidade-dev    = estabelec.cidade.
        c-cod-estab-dev = estabelec.cod-estabel.
        i-cod-emit-dev  = estabelec.cod-emitente.
        leave.
    end.
    if c-cod-estab-dev = "" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o: " + c-cod-estab-dev,
                         input 1).
        next.
    end.
    if c-cod-estab-dev = "500" then do:
        run pi-gera-log (input "Estabelecimento n∆o cadastrado ou fora de operaá∆o: " + c-cod-estab-dev,
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
        estabelec.cgc = int_ds_devolucao_cupom.cnpj_filial_cup,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_ds_devolucao_cupom.data
        query-tuning(no-lookahead):
        c-estado-ori    = estabelec.estado.
        c-cidade-ori    = estabelec.cidade.
        c-cod-estab-ori = estabelec.cod-estabel.
        leave.
    end.
    if c-cod-estab-ori = "" then do:
        run pi-gera-log (input "Estabelecimento CUPOM n∆o cadastrado ou fora de operaá∆o: " + c-cod-estab-ori,
                         input 1).
        next.
    end.


    /*
    for first param-estoq no-lock: 
        if month (param-estoq.ult-fech-dia) = 12 then 
            assign c-periodo-fecha = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
        else
            assign c-periodo-fecha = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").
        
        if (c-periodo-fecha = string(year(int_ds_devolucao_cupom.data),"9999") + string(month(int_ds_devolucao_cupom.data),"99") and
           (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes)) or
            param-estoq.ult-fech-dia >= int_ds_devolucao_cupom.data then do:

            run pi-gera-log (input "Documento em per°odo fechado ou em fechamento. Filial: "   + c-cod-estab-ori + 
                             " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev)    + 
                             " Item: "          + string(int(int_ds_devolucao_cupom.produto))  +
                             " Data: " + string(int_ds_devolucao_cupom.data,"99/99/9999"),
                             input 1).
            NEXT for-dev.
        end.                
    end.
    */

    assign c-tp-pedido = "98".
    for last int_ds_nota_loja no-lock where
        int_ds_nota_loja.cnpj_filial = int_ds_devolucao_cupom.cnpj_filial_cup and
        int_ds_nota_loja.num_nota = int_ds_devolucao_cupom.numero_cup and
        int_ds_nota_loja.emissao <= int_ds_devolucao_cupom.data: 
        if int_ds_nota_loja.nfce_chave_s  /* chave acesso */ <> ? and 
           trim(int_ds_nota_loja.nfce_chave_s)  /* chave acesso */ <> "" then do:
            assign c-tp-pedido = trim(substring(replace(replace(int_ds_nota_loja.nfce_chave_s,'NFe',''),'CFe',''),21,2)).
        end.
    end.
    if not avail int_ds_nota_loja then do:
        run pi-gera-log (input "Cupom origem ainda n∆o disponivel na integracao. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev)    + 
                         " Cupom: "         + string(int_ds_devolucao_cupom.numero_cup)    + 
                         " Item: "          + string(int(int_ds_devolucao_cupom.produto))  +
                         " Data: " + string(int_ds_devolucao_cupom.data,"99/99/9999"),
                         input 1).
        next.
    end.
    ELSE DO:
        IF  int_ds_nota_loja.situacao = 1 /* Pendente */
        THEN DO:
            run pi-gera-log (input "Cupom origem ainda n∆o processado no ERP. Filial: " + c-cod-estab-ori + 
                             " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev)    + 
                             " Cupom: "         + string(int_ds_devolucao_cupom.numero_cup)    + 
                             " Item: "          + string(int(int_ds_devolucao_cupom.produto))  +
                             " Data: " + string(int_ds_devolucao_cupom.data,"99/99/9999"),
                             input 1).
            next.
        END.
    END.

    ASSIGN l-aux = YES.
    bloco-vld-item-cupom:
    FOR EACH  int_ds_nota_loja NO-LOCK 
        WHERE int_ds_nota_loja.cnpj_filial = int_ds_devolucao_cupom.cnpj_filial_cup 
          AND int_ds_nota_loja.num_nota    = int_ds_devolucao_cupom.numero_cup 
          AND int_ds_nota_loja.emissao    <= int_ds_devolucao_cupom.data: 

        FOR FIRST int_ds_nota_loja_item NO-LOCK OF int_ds_nota_loja 
            WHERE int_ds_nota_loja_item.produto     = int_ds_devolucao_cupom.produto
              AND int_ds_nota_loja_item.quantidade >= int_ds_devolucao_cupom.quantidade:
    
            ASSIGN l-aux = NO
                   c-condipag       = int_ds_nota_loja.condipag
                   c-convenio       = if int(int_ds_nota_loja.convenio) > 0 then "S" else "N"
                   c-numero-cup     = if trim(int_ds_nota_loja.num_identi) begins "CONT" 
                                      then int_ds_nota_loja.cupom_ecf
                                      else int_ds_nota_loja.num_nota.
            LEAVE bloco-vld-item-cupom.
        END.
    end.

    IF l-aux = YES
    THEN DO:
        run pi-gera-log (input "Produto n∆o encontrado no cupom origem. Filial: "       + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) + 
                         " Cupom: "         + string(int_ds_devolucao_cupom.numero_cup) + 
                         " Item: "          + string(int(int_ds_devolucao_cupom.produto)),
                         input 1).
        next.
    END.

    c-class-fiscal-dev = "".
    c-conta = "".
    c-subconta = "".
    for first item 
        fields (it-codigo class-fiscal tipo-con-est peso-liquido aliquota-ipi ct-codigo
                sc-codigo conta-aplicacao tipo-contr cd-trib-icm cd-trib-ipi cd-trib-iss)
        no-lock where 
        item.it-codigo = string(int(int_ds_devolucao_cupom.produto)): 
        c-class-fiscal-dev  = item.class-fiscal.
        c-conta = item.ct-codigo.
        c-subconta = item.sc-codigo.
    end.
    if not avail item then do:
        run pi-gera-log (input "Item n∆o cadastrado: " + string(int(int_ds_devolucao_cupom.produto)),
                         input 1).
        next.
    end.
    for first item-estab no-lock where 
        item-estab.cod-estabel = c-cod-estab-dev and
        item-estab.it-codigo = string(int(int_ds_devolucao_cupom.produto)): 
    end.
    if not avail item-estab then
        for first item-uni-estab no-lock where 
            item-uni-estab.cod-estabel = c-cod-estab-dev and
            item-uni-estab.it-codigo = string(int(int_ds_devolucao_cupom.produto)): end.
    if not avail item-estab and not avail item-uni-estab then do:
        run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + string(int(int_ds_devolucao_cupom.produto)) + "/" + "Estab.: " + c-cod-estab-dev,
                         input 1).
        next.
    end.
    
    if item.tipo-contr = 4 and c-conta = "" then do:
        run pi-gera-log (input "Item dÇbito direto exige conta aplicaá∆o: " + string(int(int_ds_devolucao_cupom.produto)),
                         input 1).
        next.
    end.
    if item.class-fiscal = "" or
       item.class-fiscal = ? then do:
        run pi-gera-log (input "Item sem classificaá∆o fiscal: " + string(int(int_ds_devolucao_cupom.produto)),
                         input 1).
        next.
    end.

    /* SêRIE ORIGEM */
    c-serie-ori = "".
    c-nat-origem = "".
    for-ser-estab:
    for each ser-estab no-lock where 
        ser-estab.cod-estabel = c-cod-estab-ori 
        
        AND ser-estab.forma-emis = 2 /* manual */

        query-tuning(no-lookahead):
        /* item origem */

        for each it-nota-fisc no-lock where 
            it-nota-fisc.cod-estabel   = c-cod-estab-ori and
            it-nota-fisc.serie         = ser-estab.serie and
            it-nota-fisc.nr-nota-fis   = trim(string(int(c-numero-cup),">>9999999")) and
            it-nota-fisc.it-codigo     = trim(string(int(int_ds_devolucao_cupom.produto))) and
            it-nota-fisc.dt-emis-nota <= int_ds_devolucao_cupom.data
            query-tuning(no-lookahead): 
            for first tt-it-nota-fisc where 
                tt-it-nota-fisc.cod-estabel = it-nota-fisc.cod-estabel and
                tt-it-nota-fisc.serie       = it-nota-fisc.serie and
                tt-it-nota-fisc.nr-nota-fis = it-nota-fisc.nr-nota-fis and
                tt-it-nota-fisc.nr-seq-fat  = it-nota-fisc.nr-seq-fat and
                tt-it-nota-fisc.it-codigo   = trim(string(int(int_ds_devolucao_cupom.produto))): end.
            if not avail tt-it-nota-fisc then do:
                create tt-it-nota-fisc.
                buffer-copy it-nota-fisc to tt-it-nota-fisc
                    assign tt-it-nota-fisc.qt-saldo = it-nota-fisc.qt-faturada[1].
            end.
            assign c-serie-ori  = ser-estab.serie.
            assign c-nat-origem = it-nota-fisc.nat-operacao.
            /*leave for-ser-estab.*/
        end.
    end.

    if not can-find(first tt-it-nota-fisc no-lock where
                    tt-it-nota-fisc.cod-estabel = c-cod-estab-ori and
                    tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-numero-cup),">>9999999")) and
                    tt-it-nota-fisc.it-codigo   = trim(string(int(int_ds_devolucao_cupom.produto)))) then do:
        run pi-gera-log (input "Item da nota origem n∆o encontrado. Filial: "           + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) +
                         " Cupom: "         + trim(string(int(int_ds_devolucao_cupom.numero_cup),">>9999999")) +
                         " Item: "          + string(int(int_ds_devolucao_cupom.produto)),
                         input 1).
        next for-dev.
    end.
    /*
    if not avail ser-estab then do:
        run pi-gera-log (input "SÇrie X Estabelecimento com forma emiss∆o manual n∆o encontrada. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) +
                         " Cupom: " + trim(string(int(int_ds_devolucao_cupom.numero_cup),">>9999999")),
                         input 1).
        next.
    end.
    */
    FOR LAST  tt-it-nota-fisc USE-INDEX id-ult-nota NO-LOCK  
        WHERE tt-it-nota-fisc.cod-estabel = c-cod-estab-ori 
          AND tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-numero-cup),">>9999999")) 
          AND tt-it-nota-fisc.it-codigo   = trim(string(int(int_ds_devolucao_cupom.produto))) 
          AND tt-it-nota-fisc.qt-saldo   >= int_ds_devolucao_cupom.quantidade:
        create tt-movto.
        assign tt-movto.nr-nota-fis     = trim(string(int(int_ds_devolucao_cupom.numero_dev),">>>999999"))
               tt-movto.dt-emissao      = /*int_ds_devolucao_cupom.data*/ TODAY
               tt-movto.cnpj_filial_dev = int_ds_devolucao_cupom.cnpj_filial_dev
               tt-movto.numero_dev      = int_ds_devolucao_cupom.numero_dev
               tt-movto.cnpj_filial_cup = int_ds_devolucao_cupom.cnpj_filial_cup
               tt-movto.numero_cup      = int_ds_devolucao_cupom.numero_cup
               tt-movto.it-codigo       = string(int(int_ds_devolucao_cupom.produto))
               tt-movto.cod-estab-ori   = c-cod-estab-ori
               tt-movto.class-fiscal    = c-class-fiscal-dev.
        assign tt-movto.qt-recebida     = int_ds_devolucao_cupom.quantidade.
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

        assign tt-movto.cod-estabel     = c-cod-estab-dev
               tt-movto.uf              = c-estado-dev
               tt-movto.nr-sequencia    = int(int_ds_devolucao_cupom.sequencia)
               tt-movto.valor-mercad    = if int_ds_devolucao_cupom.valor_unit <> 0 
                                          then int_ds_devolucao_cupom.valor_unit * int_ds_devolucao_cupom.quantidade
                                          else tt-it-nota-fisc.vl-preuni * int_ds_devolucao_cupom.quantidade
               tt-movto.cd-trib-ipi     = tt-it-nota-fisc.cd-trib-ipi
               tt-movto.aliquota-ipi    = tt-it-nota-fisc.aliquota-ipi
               tt-movto.cd-trib-icm     = if tt-it-nota-fisc.cd-trib-icm < 5 then tt-it-nota-fisc.cd-trib-icm else 4  /* nota no faturaento s¢ aceita atÇ 4 */
               tt-movto.aliquota-icm    = tt-it-nota-fisc.aliquota-icm
               tt-movto.cd-trib-iss     = tt-it-nota-fisc.cd-trib-iss
               tt-movto.perc-red-icm    = tt-it-nota-fisc.perc-red-icm
               tt-movto.vl-bicms-it     = (tt-it-nota-fisc.vl-bicms-it  / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade
               tt-movto.vl-icms-it      = (tt-it-nota-fisc.vl-icms-it   / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade
               tt-movto.vl-bipi-it      = (tt-it-nota-fisc.vl-bipi-it   / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade
               tt-movto.vl-ipi-it       = (tt-it-nota-fisc.vl-ipi-it    / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade
               tt-movto.vl-bsubs-it     = (tt-it-nota-fisc.vl-bsubs-it  / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade
               tt-movto.vl-icmsub-it    = (tt-it-nota-fisc.vl-icmsub-it / tt-it-nota-fisc.qt-faturada[1]) * int_ds_devolucao_cupom.quantidade.
        
        /*if tt-movto.vl-ipi-it > 0 then*/ tt-movto.cd-trib-ipi = 3 /* outros */.

        assign tt-movto.observacao = "Devoluá∆o: " + tt-movto.numero_dev + " - "
                                   + " Cupom: "    + tt-movto.numero_cup + " Filial: " + c-cod-estab-ori.

        assign tt-movto.observacao = tt-movto.observacao + " - " + 
                    (if trim(int_ds_devolucao_cupom.descricao) <> ? then trim(int_ds_devolucao_cupom.descricao) + "-" else "") +  
                    (if trim(int_ds_devolucao_cupom.vendedor)  <> ? then trim(int_ds_devolucao_cupom.vendedor)  + "-" else "") + 
                    (if trim(int_ds_devolucao_cupom.gerente)   <> ? then trim(int_ds_devolucao_cupom.gerente)   + "-" else "").

        for first fat-ser-lote no-lock 
            WHERE fat-ser-lote.cod-estabel = tt-it-nota-fisc.cod-estabel
              AND fat-ser-lote.serie       = tt-it-nota-fisc.serie
              AND fat-ser-lote.nr-nota-fis = tt-it-nota-fisc.nr-nota-fis
              AND fat-ser-lote.nr-seq-fat  = tt-it-nota-fisc.nr-seq-fat
              AND fat-ser-lote.it-codigo   = tt-it-nota-fisc.it-codigo:
            assign tt-movto.lote            = fat-ser-lote.nr-serlote
                   tt-movto.dt-vali-lote    = fat-ser-lote.dt-vali-lote.
        end.
    
    end. /* tt-it-nota-fisc */
    
    if not avail tt-it-nota-fisc then do:
        run pi-gera-log (input "Produto n∆o encontrado na nota origem com saldo para devoluá∆o. Filial: " + c-cod-estab-ori + 
                         " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) +
                         " Cupom: " + trim(string(int(int_ds_devolucao_cupom.numero_cup),">>9999999")) + 
                         " Item: "  + item.it-codigo +
                         " Qtde: "  + string(int_ds_devolucao_cupom.quantidade),
                         input 1).
        next.
    end.

    assign tt-movto.peso-liquido    = item.peso-liquido * tt-movto.qt-recebida.
    if item.tipo-contr = 4 /* debito direto */ then do:
        assign tt-movto.conta-aplicacao = c-conta
               tt-movto.sc-codigo = c-subconta.
    end.


    assign tt-movto.cod-depos = /*if avail item-uni-estab 
                                then item-uni-estab.deposito-pad
                                else item-estab.deposito-pad.*/ "LOJ".
    
    tt-movto.cod-esp = "DI".
    case int_ds_devolucao_cupom.tipo_titulo:
        when "V" then tt-movto.cod-esp = "CV". /* V   CONV“NIO           */
        when "P" then tt-movto.cod-esp = "CH". /* P   CHEQUE-PRê         */
        when "K" then tt-movto.cod-esp = "DI". /* K   TICKET             */
        when "D" then tt-movto.cod-esp = "DI". /* D   DINHEIRO           */
        when "C" then tt-movto.cod-esp = "CH". /* C   CHEQUE ∑ VISTA     */
        when "T" then tt-movto.cod-esp = "CC". /* T   CART«O DE CRêDITO  */
        when "E" then tt-movto.cod-esp = "CD". /* E   CART«O DE DêBITO   */
        when "L" then tt-movto.cod-esp = "DI". /* L   PBM                */
    end case.

    /* verifica se existe duplicata com a espÇcie devolvida */
    l-aux = no.
    for each fat-duplic no-lock where
        fat-duplic.cod-estabel  = tt-movto.cod-estab-ori and
        fat-duplic.serie        = tt-movto.serie-comp    and
        fat-duplic.nr-fatura    = tt-movto.nro-comp      and
        fat-duplic.cod-esp      = tt-movto.cod-esp,
        first cst_fat_duplic no-lock
        WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
          AND cst_fat_duplic.serie       = fat-duplic.serie
          AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
          AND cst_fat_duplic.parcela     = fat-duplic.parcela
        query-tuning(no-lookahead):
        l-aux = yes.
    end.
    /* se n∆o, busca pelas duplicatas existente na origem (Farmacia popular cod-esp = PO mas vem como T) */
    if not l-aux and (
       tt-movto.cod-esp = "CC" or /* T   CART«O DE CRêDITO  */
       tt-movto.cod-esp = "CD"    /* E   CART«O DE DêBITO   */ )
    then do:
        for each fat-duplic no-lock where
            fat-duplic.cod-estabel  = tt-movto.cod-estab-ori and
            fat-duplic.serie        = tt-movto.serie-comp    and
            fat-duplic.nr-fatura    = tt-movto.nro-comp      and
            fat-duplic.cod-esp      <> "CV"                  and
            fat-duplic.cod-esp      <> "CH"
            break by fat-duplic.cod-esp
            query-tuning(no-lookahead):

            if first-of (fat-duplic.cod-esp) then de-vl-fat-devol = 0.
            de-vl-fat-devol = de-vl-fat-devol + fat-duplic.vl-parcela.
            if last-of (fat-duplic.cod-esp) and 
                de-vl-fat-devol >= tt-movto.valor-mercad then do:
                assign tt-movto.cod-esp = fat-duplic.cod-esp.
            end.
        end.
    end.

    for first nota-fiscal no-lock of tt-it-nota-fisc: 
       for first emitente no-lock where emitente.cod-emitente = i-cod-emit-dev /* emitente do estabelecimento */: end.

       if not can-find(first mgdis.cidade no-lock where 
           cidade.pais = emitente.pais and
           cidade.estado = emitente.estado and
           cidade.cidade = emitente.cidade) then do:
           run pi-gera-log (input "Cidade do cliente n∆o encontrada. Pa°s: " + emitente.pais + " UF: " + emitente.estado + " Cidade: " + emitente.cidade + " Cliente: " + string(emitente.cod-emitente),
                            input 1).
           next.
       end.
       assign tt-movto.cod-emitente = i-cod-emit-dev.

       c-serie-dev = "1". 
       for last ser-estab no-lock where 
           ser-estab.cod-estabel = c-cod-estab-dev and
           ser-estab.forma-emis = 1 /* automatica */ and 
           ser-estab.log-nf-eletro /* NFe */:
           c-serie-dev = ser-estab.serie.
       end.

       c-nat-of = "".
       /*
       /* determina natureza de operacao */
       run intprg/int018a.p (INPUT  c-condipag,
                             INPUT  c-class-fiscal-dev,
                             OUTPUT v-row-loja-cond-pag,
                             OUTPUT v-row-classif-fisc). 
       for first int-ds-classif-fisc no-lock 
           where rowid(int-ds-classif-fisc) = v-row-classif-fisc: 
           c-nat-of = int-ds-classif-fisc.cod-nat-oper-devol.
           /*c-serie = int-ds-loja-natur-oper.serie.  fixo atÇ incluir sÇrie no int018 */
       end.
       */

       /* determina natureza de operacao */
       run intprg/int115a.p ( /*input "98"           ,*/
                              input c-tp-pedido    ,
                              input c-estado-dev   ,
                              input c-estado-dev   ,
                              input c-nat-origem   ,
                              input i-cod-emit-dev ,
                              input c-class-fiscal-dev ,
                              output c-natur       ,
                              output c-nat-of      ,
                              output r-rowid).
    
       if  c-nat-of = "" or c-nat-of = ? then do:
           assign c-nat-of = "".
           run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. Filial: " + c-cod-estab-dev + 
                            " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) + 
                            " Cupom: "         + string(int_ds_devolucao_cupom.numero_cup) + 
                            " Natur. Oper.: "  + c-nat-of        +
                            " Tp Pedido.: "    + c-tp-pedido     +
                            " UF: "            + c-estado-dev    +
                            " Nat Origem: "    + c-nat-origem    + 
                            " Estab.: "        + c-cod-estab-dev +
                            " Convànio: "      + c-convenio      +
                            " NCM: "           + c-class-fiscal-dev,
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
              tt-movto.serie           = c-serie-dev. 

       if natur-oper.tipo-compra <> 3 then do:
           run pi-gera-log (input "Natureza de operaá∆o deve ter tipo de compra Devoluá∆o de Cliente. Filial: " + c-cod-estab-dev + 
                                  " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) + 
                                  " Cupom: "         + string(int_ds_devolucao_cupom.numero_cup) + 
                                  " Natur. Oper.: "  + c-nat-of,
                            input 1).
           next.
       end.
       assign tt-movto.tipo-compra     = natur-oper.tipo-compra.

    end. /* nota-fiscal */

    if last-of (int_ds_devolucao_cupom.numero_dev)  then do:
        if not can-find(first tt-movto) then do:
            run pi-gera-log (input "Documento sem itens. Filial: " + c-cod-estab-dev + 
                                   " Nr. Devoluá∆o: " + string(int_ds_devolucao_cupom.numero_dev) + " Cupom: " + string(int_ds_devolucao_cupom.numero_cup),
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
            run pi-gera-log (input "Documento de estoque j† cadastrado. Filial: " + c-cod-estab-dev + 
                             " Emitente: "   + string(docum-est.cod-emitente) + 
                             " SÇrie: "      + docum-est.serie-docto +
                             " Docto.: "     + docum-est.nro-docto   +
                             /*" Natur. Oper.: " + docum-est.nat-operacao + */
                             " Cupom: "      + string(int_ds_devolucao_cupom.numero_cup),
                             input 1).
            next.
        end.
        for each cst_fat_devol no-lock where
            cst_fat_devol.cod_estabel = tt-movto.cod-estabel and 
            cst_fat_devol.numero_dev  = trim(string(int(tt-movto.numero_dev),"999999")) and
            cst_fat_devol.nro_comp    = trim(string(int(tt-movto.numero_cup),"9999999"))
            query-tuning(no-lookahead):
            /* devolucoes antes de alterar para nfd do estabelecimento */
            for first it-nota-fisc fields (dt-cancela nr-nota-fis)
                no-lock where 
                it-nota-fisc.cod-estabel = cst_fat_devol.cod_estabel and
                it-nota-fisc.serie-docum = cst_fat_devol.serie_comp and
                it-nota-fisc.nr-docum    = cst_fat_devol.nro_comp and
                it-nota-fisc.dt-cancela  = ?: 

                run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                 c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                                 " SÇrie: " + cst_fat_devol.serie_docto +
                                 " Docto.: " + cst_fat_devol.nro_docto +
                                 " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                                 " Cupom: " + string(tt-movto.numero_cup) + 
                                 " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                                 " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                 input 1).

                for each bint_ds_devolucao_cupom exclusive where
                    bint_ds_devolucao_cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint_ds_devolucao_cupom.numero_dev       = trim(string(int(tt-movto.numero_dev),"999999"))
                    query-tuning(no-lookahead):
                    assign  bint_ds_devolucao_cupom.situacao = 5 /* processada */.
                    release bint_ds_devolucao_cupom.
                end.
                next for-dev.
            end.
            /* devolucoes depois de alterar para nfd do estabelecimento */
            for first it-nota-fisc fields (dt-cancela nr-nota-fis)
                no-lock where 
                it-nota-fisc.cod-estabel = cst_fat_devol.cod_estabel and
                it-nota-fisc.serie       = cst_fat_devol.serie_docto and
                it-nota-fisc.nr-nota-fis = cst_fat_devol.nro_docto   and
                it-nota-fisc.dt-cancela  = ?: 

                run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                 c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                                 " SÇrie: " + cst_fat_devol.serie_docto +
                                 " Docto.: " + cst_fat_devol.nro_docto +
                                 " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                                 " Cupom: " + string(tt-movto.numero_cup) + 
                                 " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                                 " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                 input 1).
                for each bint_ds_devolucao_cupom exclusive where
                    bint_ds_devolucao_cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint_ds_devolucao_cupom.numero_dev       = trim(string(int(tt-movto.numero_dev),"999999"))
                    query-tuning(no-lookahead):
                    assign  bint_ds_devolucao_cupom.situacao = 5 /* processada */.
                    release bint_ds_devolucao_cupom.
                end.
                next for-dev.
            end.
            if not avail it-nota-fisc then do:
                for each docum-est no-lock where 
                    docum-est.cod-estabel  = c-cod-estab-dev               and
                    docum-est.cod-emitente = cst_fat_devol.cod_emitente  and
                    docum-est.serie-docto  = cst_fat_devol.serie_docto   and
                    docum-est.nat-operacao = cst_fat_devol.nat_operacao  and
                    docum-est.dt-trans    >= int_ds_devolucao_cupom.data and
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
                                         c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                                         " SÇrie: " + cst_fat_devol.serie_docto +
                                         " Docto.: " + cst_fat_devol.nro_docto +
                                         " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                                         " Cupom: " + string(tt-movto.numero_cup) + 
                                         " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                                         " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                         input 1).
                        for each bint_ds_devolucao_cupom exclusive where
                            bint_ds_devolucao_cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                            bint_ds_devolucao_cupom.numero_dev       = trim(string(int(tt-movto.numero_dev),"999999"))
                            query-tuning(no-lookahead):
                            assign  bint_ds_devolucao_cupom.situacao = 5 /* processada */.
                            release bint_ds_devolucao_cupom.
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
    release int_ds_devolucao_cupom.
end.
run pi-elimina-tt.

/* fechamento do output do relat¢rio  */
if tt-param.arquivo <> "" then do:
    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
end.

RUN intprg/int888.p (INPUT "NF PED",
                     INPUT "int027rp.p").
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

    find first tt-movto no-error.
    if not avail tt-movto then return.

    find first estab-mat 
        no-lock where
        estab-mat.cod-estabel = c-cod-estab-dev 
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
    if return-value = "NOK" then do:
        for first tt-movto:
            run pi-gera-log (input ("Parcelas de devoluá∆o n∆o geradas: " + 
                                    " Emitente: " + string(tt-movto.cod-emitente) + 
                                    " SÇrie: " + tt-movto.serie +
                                    " Docto.: " + tt-movto.nr-nota-fis +
                                    " Natur. Oper.: " + tt-movto.nat-operacao + 
                                    " Cupom: " + tt-movto.nro-comp),
                             input 1).
            return.
        end.
    end.
    i-seq = 0.
    for each tt-movto
        break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nat-operacao
              by tt-movto.nr-sequencia
              by tt-movto.it-codigo:
        for first tt-docum-est-nova where
            tt-docum-est-nova.serie-docto       = tt-movto.serie         and
            tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis   and
            tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente: end.
        if not avail tt-docum-est-nova then do:
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
               tt-item-doc-est-nova.data-comp          = if tt-movto.data-comp <> ? and c-cod-estab-ori = c-cod-estab-dev then tt-movto.data-comp else today
               tt-item-doc-est-nova.ct-codigo          = tt-movto.conta-aplicacao
               tt-item-doc-est-nova.sc-codigo          = tt-movto.sc-codigo
               tt-item-doc-est-nova.base-pis           = tt-movto.base-pis       
               tt-item-doc-est-nova.valor-pis          = tt-movto.valor-pis      
               tt-item-doc-est-nova.aliquota-pis       = tt-movto.aliquota-pis   
               tt-item-doc-est-nova.base-cofins        = tt-movto.base-cofins    
               tt-item-doc-est-nova.valor-cofins       = tt-movto.valor-cofins   
               tt-item-doc-est-nova.aliquota-cofins    = tt-movto.aliquota-cofins
               tt-docum-est-nova.valor-mercad          = tt-docum-est-nova.valor-mercad + tt-item-doc-est-nova.preco-total.

        /* erro na api reapi190b - divis∆o por zero quando desconto de 100 % */
        for each it-nota-fisc
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
            l-erro = yes.
            for each tt-cst_fat_devol where 
                tt-cst_fat_devol.cod_emitente = tt-docum-est-nova.cod-emitente  and  
                tt-cst_fat_devol.serie_docto  = tt-docum-est-nova.serie-docto   and  
                tt-cst_fat_devol.nro_docto    = tt-docum-est-nova.nro-docto     and  
                tt-cst_fat_devol.nat_operacao = tt-docum-est-nova.nat-operacao
                query-tuning(no-lookahead):
                create cst_fat_devol.
                buffer-copy tt-cst_fat_devol to cst_fat_devol.
                l-erro = no.
            end.
            if l-erro then do:
                run pi-gera-log (input ("Parcelas de devoluá∆o n∆o geradas: " + 
                                        " Emitente: " + string(tt-movto.cod-emitente) + 
                                        " SÇrie: " + tt-movto.serie +
                                        " Docto.: " + tt-movto.nr-nota-fis +
                                        " Natur. Oper.: " + tt-movto.nat-operacao + 
                                        " Cupom: " + tt-movto.nro-comp),
                                 input 1).
                undo do-trans, leave do-trans.
            end.
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
                        loc-entr.cod-entrega = c-estado-dev:
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

                create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int027-re1005.txt"
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

                empty temp-table tt-digita-re1005.

                create tt-digita-re1005.
                assign tt-digita-re1005.r-docum-est  = rowid(docum-est).
                release docum-est.

                raw-transfer tt-param-re1005 to raw-param.
                run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                empty temp-table tt-digita-re1005.
                empty temp-table tt-param-re1005.

                for each tt-cst_fat_devol where 
                    tt-cst_fat_devol.cod_estabel  = tt-docum-est-nova.cod-estabel   and  
                    tt-cst_fat_devol.cod_emitente = tt-docum-est-nova.cod-emitente  and  
                    tt-cst_fat_devol.serie_docto  = tt-docum-est-nova.serie-docto   and  
                    tt-cst_fat_devol.nro_docto    = tt-docum-est-nova.nro-docto     and  
                    tt-cst_fat_devol.nat_operacao = tt-docum-est-nova.nat-operacao
                    query-tuning(no-lookahead):
                    for first cst_fat_devol where
                        cst_fat_devol.cod_estabel  = tt-cst_fat_devol.cod_estabel   and  
                        cst_fat_devol.cod_emitente = tt-cst_fat_devol.cod_emitente  and  
                        cst_fat_devol.serie_docto  = tt-cst_fat_devol.serie_docto   and  
                        cst_fat_devol.nro_docto    = tt-cst_fat_devol.nro_docto     and  
                        cst_fat_devol.cod_esp      = tt-cst_fat_devol.cod_esp       and  
                        cst_fat_devol.nat_operacao = tt-cst_fat_devol.nat_operacao  and
                        cst_fat_devol.parcela      = tt-cst_fat_devol.parcela:
                        for last item-doc-est no-lock where 
                            item-doc-est.cod-emitente = cst_fat_devol.cod_emitente  and
                            item-doc-est.serie-docto  = cst_fat_devol.serie_docto   and
                            item-doc-est.nat-operacao = cst_fat_devol.nat_operacao  and
                            item-doc-est.nr-pedcli    = cst_fat_devol.numero_dev,
                            first bdocum-est of item-doc-est no-lock where
                            bdocum-est.dt-trans       = tt-docum-est-nova.dt-trans  and
                            bdocum-est.cod-estabel    = cst_fat_devol.cod_estabel   and
                            bdocum-est.ce-atual       = yes:
                            assign cst_fat_devol.nro_docto = item-doc-est.nro-docto.
                        end.
                    end.
                end.
                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " SÇrie: " + tt-movto.serie        +
                                " NF: "  + tt-movto.nr-nota-fis  +
                                " Natur. Oper.: " + tt-movto.nat-operacao + " - " + "Documento gerado com sucesso!",
                                2).
                for each bint_ds_devolucao_cupom exclusive where
                    bint_ds_devolucao_cupom.cnpj_filial_dev  = tt-movto.cnpj_filial_dev and
                    bint_ds_devolucao_cupom.numero_dev       = trim(string(int(tt-movto.numero_dev),"999999"))
                    query-tuning(no-lookahead):
                    assign  bint_ds_devolucao_cupom.situacao = 2 /* processada */.
                    release bint_ds_devolucao_cupom.
                end.
            end.
            run pi-elimina-tt.
        end. /* trans */
    end. /* tt-movto */
    run pi-elimina-tt.
end procedure. /* PiGeraMovimento */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    if tt-param.arquivo <> "" then do:    
        put /* stream str-rp */ unformatted
            int_ds_devolucao_cupom.cnpj_filial_cup + "/" + 
            int_ds_devolucao_cupom.numero_dev + "/" + 
            int_ds_devolucao_cupom.numero_cup + " - " +
            c-informacao
            skip.
    end.
    if i-situacao = 1 then l-erro = yes.

    RUN intprg/int999.p ("NFDCUP", 
                         int_ds_devolucao_cupom.cnpj_filial_cup + "/" + 
                         int_ds_devolucao_cupom.numero_dev + "/" + 
                         int_ds_devolucao_cupom.numero_cup,
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario,
                         "int027rp.p").
end.

procedure pi-gera-tt-fat-devol:

    i-parcela = 0.
    for each tt-movto break by tt-movto.cod-esp:

        if first-of (tt-movto.cod-esp) then do:
            de-vl-fat-devol = 0.
            i-cod-port-ori  = i-cod-port-dinh.
            i-modalid-ori   = i-modalid-dinh.
            c-modo-devolucao = "Dinheiro".
            for first cst_cond_pagto no-lock where 
                cst_cond_pagto.cod_cond_pag = i-cond-pag-dinh:
                c-modo-devolucao = cst_cond_pagto.modo_devolucao.
            end.
            for each fat-duplic no-lock where
                fat-duplic.cod-estabel  = tt-movto.cod-estab-ori and
                fat-duplic.serie        = tt-movto.serie-comp    and
                fat-duplic.nr-fatura    = tt-movto.nro-comp      and
                fat-duplic.cod-esp      = tt-movto.cod-esp,
          FIRST cst_fat_duplic no-lock
          WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
            AND cst_fat_duplic.serie       = fat-duplic.serie
            AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
            AND cst_fat_duplic.parcela     = fat-duplic.parcela
                query-tuning(no-lookahead):
    
                i-cod-port-ori = cst_fat_duplic.cod_portador.
                i-modalid-ori  = cst_fat_duplic.modalidade.
    
                for first cst_cond_pagto no-lock where 
                    cst_cond_pagto.cod_cond_pag = cst_fat_duplic.cod_cond_pag:
                    c-modo-devolucao = cst_cond_pagto.modo_devolucao.
                end.
            end.
        end.

        de-vl-fat-devol = de-vl-fat-devol + tt-movto.valor-mercad.
        if last-of (tt-movto.cod-esp) then do:
            i-parcela = i-parcela + 1.
            create  tt-cst_fat_devol.
            assign  tt-cst_fat_devol.cod_estabel    = tt-movto.cod-estabel
                    tt-cst_fat_devol.serie_docto    = tt-movto.serie
                    tt-cst_fat_devol.nro_docto      = tt-movto.nr-nota-fis
                    tt-cst_fat_devol.cod_emitente   = tt-movto.cod-emitente
                    tt-cst_fat_devol.nat_operacao   = tt-movto.nat-operacao
                    tt-cst_fat_devol.cod_esp        = tt-movto.cod-esp
                    tt-cst_fat_devol.parcela        = trim(string(i-parcela))
                    tt-cst_fat_devol.vl_devolucao   = de-vl-fat-devol
                    tt-cst_fat_devol.dt_vencto      = tt-movto.dt-emissao
                    tt-cst_fat_devol.cod_portador   = i-cod-port-ori
                    tt-cst_fat_devol.modalidade     = i-modalid-ori
                    tt-cst_fat_devol.modo_devolucao = c-modo-devolucao
                    tt-cst_fat_devol.serie_comp     = tt-movto.serie-comp
                    tt-cst_fat_devol.nro_comp       = tt-movto.nro-comp
                    tt-cst_fat_devol.numero_dev     = trim(string(int(tt-movto.numero_dev),"999999"))
                    tt-cst_fat_devol.cod_estab_comp = tt-movto.cod-estab-ori.
        end.
    end.
    if i-parcela = 0 then return "NOK".
    return "OK".
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
        RELEASE bnota-fiscal.
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
   empty temp-table tt-cst_nota_fiscal. 
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-int_ds_nota_loja_cartao. 
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
    empty temp-table tt-cst_fat_devol.
    empty temp-table tt-it-nota-fisc.
end.

{intprg/int020rp-3.i}
