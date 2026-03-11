/********************************************************************************
** Programa: INT227 - Importaá∆o de Devoluá‰es de CUPOM do Procfit
**
** Versao : 12 - 31/01/2018 - Alessandro V Baccin
**
********************************************************************************/
{utp/ut-glob.i}
/* include de controle de vers∆o */
{include/i-prgvrs.i int227rp 2.12.04.AVB}
{cdp/cdcfgdis.i}

DEFINE VARIABLE h-reapi414 AS HANDLE      NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-icms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-ipi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-pis    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-sit-tribut-cofins AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-aliq-pis             AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins          AS DECIMAL     NO-UNDO.



function PrintChar returns longchar
    (input pc-string as longchar):

    /* necess†rio para que a funá∆o seja case-sensitive */
    define variable c-string as longchar case-sensitive no-undo.
    define variable i-ind as integer no-undo.

    assign c-string = pc-string.

    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"É","a").
    assign c-string = replace(c-string,"Ñ","a").

    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").
    assign c-string = replace(c-string,"â","e").

    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").
    assign c-string = replace(c-string,"ã","i").

    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"ì","o").
    assign c-string = replace(c-string,"î","o").
    assign c-string = replace(c-string,"‰","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").

    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"§","n").

    assign c-string = replace(c-string,"Ï","y").
    assign c-string = replace(c-string,"ò","y").

    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∂","A").
    assign c-string = replace(c-string,"é","A").

    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"”","E").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"ÿ","I").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"ô","O").
    assign c-string = replace(c-string,"Â","O").

    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").

    assign c-string = replace(c-string,"Ä","C").
    assign c-string = replace(c-string,"•","N").

    assign c-string = replace(c-string,"Ì","Y").

    assign c-string = replace(c-string,CHR(13),"").
    assign c-string = replace(c-string,CHR(10),"").

    assign c-string = replace(c-string,"˚","").
    assign c-string = replace(c-string,"≠","").
    assign c-string = replace(c-string,"˝","2").
    assign c-string = replace(c-string,"¸","3").
    assign c-string = replace(c-string,"œ","o").
    assign c-string = replace(c-string,"∞","E").
    assign c-string = replace(c-string,"¨","1/4").
    assign c-string = replace(c-string,"´","1/2").
    assign c-string = replace(c-string,"Û","3/4").
    assign c-string = replace(c-string,"æ","Y").
    assign c-string = replace(c-string,"û","x").
    assign c-string = replace(c-string,"Á","p").
    assign c-string = replace(c-string,"©","r").
    assign c-string = replace(c-string,"Ü","a").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"–","y").
    assign c-string = replace(c-string,"õ","o").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ë","ae").
    assign c-string = replace(c-string,"Ê","u").
    assign c-string = replace(c-string,"®","").
    assign c-string = replace(c-string,"∫","").
    assign c-string = replace(c-string,"ı","").
    assign c-string = replace(c-string,"è","A").
    assign c-string = replace(c-string,"©","").
    assign c-string = replace(c-string,"Ë","p").
    assign c-string = replace(c-string,"Æ","-").
    assign c-string = replace(c-string,"Ø","-").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ù","0").
    assign c-string = replace(c-string,"—","D").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"í","").
    assign c-string = replace(c-string,"∏","").
    assign c-string = replace(c-string,"ú","").
    assign c-string = replace(c-string,"ı","").

    assign c-string = replace(c-string,"ˆ","").
    assign c-string = replace(c-string,"›","").
    assign c-string = replace(c-string,"¯","o").
    assign c-string = replace(c-string,"Ω","c").

    do i-ind = 1 to 31:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 127 to 144:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 147 to 159:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 162 to 182:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 184 to 191:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 215 to 216:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 248 to 248:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.

    assign c-string = trim(c-string).

    return c-string.

end function.

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

def temp-table tt-cst_nota_fiscal like cst_nota_fiscal.
def temp-table tt-int_ds_nota_loja_cartao like int_ds_nota_loja_cartao
    field cod-esp       like fat-duplic.cod-esp
    field cod-vencto    like fat-duplic.cod-vencto
    field cod-cond-pag  like nota-fiscal.cod-cond-pag
    field cod-portador  like nota-fiscal.cod-portador
    field modalidade    like nota-fiscal.modalidade.

define temp-table tt-nota-fiscal-adc
    field cod-estabel               like nota-fiscal.cod-estabel
    field serie                     like nota-fiscal.serie
    field nr-nota-fis               like nota-fiscal.nr-nota-fis
    field idi-tip-dado              like nota-fisc-adc.idi-tip-dado
    field cod-model-ecf             like nota-fisc-adc.cod-model-ecf          
    field cod-fabricc-ecf           like nota-fisc-adc.cod-fabricc-ecf        
    field cod-cx-ecf                like nota-fisc-adc.cod-cx-ecf             
    field cod-docto-referado-ecf    like nota-fisc-adc.cod-docto-referado-ecf 
    field dat-docto-referado-ecf    like nota-fisc-adc.dat-docto-referado-ecf 
    field cdn-emit-docto-referado   like nota-fisc-adc.cdn-emit-docto-referado
    field cod-ser-docto-referado    like nota-fisc-adc.cod-ser-docto-referado 
    field cod-model-docto-referado  like nota-fisc-adc.cod-model-docto-referado
    field idi-tip-docto-referado    like nota-fisc-adc.idi-tip-docto-referado
    field idi-tip-emit-referado     like nota-fisc-adc.idi-tip-emit-referado 
    index nota-conhec is unique
    cod-estabel   
    serie         
    nr-nota-fis.

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
    field cod-emitente like docum-est.cod-emitente
    field uf           like docum-est.uf
    field cnpj_filial_dev   like int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s
    field numero_dev        like int_dp_nota_devolucao.ndv_notafiscal_n
    field cnpj_filial_cup   like int_dp_nota_devolucao.ndv_cnpjfilialorigem_s
    field numero_cup        like int_dp_nota_devolucao.ndv_notaorigem_n
    field observacao        like docum-est.observacao
    field tipo-compra       like natur-oper.tipo-compra
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
    field cod-estab-comp        like nota-fiscal.cod-estabel
    field conta-aplicacao       like item.conta-aplicacao
    field sc-codigo             like item.sc-codigo
    field nat-of                like item-doc-est.nat-of
    field cod-esp               like cst_fat_devol.cod_esp
    field chave-acesso          as char format "x(44)"
    field idi-sit-nf-eletro     as integer.

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
    index id-it-nota
          cod-estabel
          serie      
          nr-nota-fis
          nr-seq-fat 
          it-codigo  
    index id-ult-nota
          cod-estabel
          nr-nota-fis
          it-codigo  
          qt-saldo
          dt-emis-nota.

define buffer bint_dp_nota_devolucao for int_dp_nota_devolucao.
define buffer bint_dp_nota_devolucao_item for int_dp_nota_devolucao_item.
define buffer bdocum-est for docum-est.
define buffer btt-movto for tt-movto.
DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.

{method/dbotterr.i}

function TrataNuloChar returns char
    (input pc-string as char):

    if pc-string = ? then return "".
    else return trim(pc-string).

end.

function TrataNuloDec returns decimal
    (input pc-dec as decimal):

    if pc-dec = ? then return 0.
    else return pc-dec.

end.

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

/* recebimento de parÉmetros */
def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
ASSIGN tt-param.arquivo = "int227.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.


/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
def var h-api           as handle no-undo.
def var h-aux           as handle no-undo.
def var l-erro          as logical no-undo.
def var c-nat-operacao  as char no-undo.
def var c-nat-of        as char no-undo.
def var c-nat-origem    as char no-undo.
def var c-estado-dev    as char no-undo. 
def var c-cod-estab-dev as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-estado-ori    as char no-undo. 
def var c-cidade-ori    as char no-undo. 
def var c-cod-estab-comp as char no-undo.
def var i-cod-port-ori  as integer no-undo.
def var i-modalid-ori   as integer no-undo.
def var c-cod-esp-dev   as char no-undo.
def var i-cod-emitente  as integer no-undo.
def var c-modo-devolucao  like cst_fat_devol.modo_devolucao.
def var i-cod-cliente   as integer no-undo.
def var i-parcela       as integer no-undo.
def var c-serie-cup      as char no-undo.
def var c-serie-nota     as char no-undo.
def var c-conta          as char no-undo.
def var c-subconta       as char no-undo.
def var l-aux            as log  no-undo.
def var c-periodo-fecha  as char no-undo.
def var c-tp-pedido      as char no-undo.
def var r-rowid          as rowid no-undo.
def var c-num-nota       as char no-undo.
def var c-num-cup        as char no-undo.
def var c-num-cup6       as char no-undo.
def var c-ins-estadual   as char no-undo.
def var c-nome-abrev     as char no-undo.
def var i-tip-cob-desp   as integer no-undo.
def var c-cep            as char no-undo.
def var c-bairro         as char no-undo.
def var c-cidade         as char no-undo.
def var c-pais           as char no-undo.
def var c-endereco       as char no-undo.
def var i-cod-rep        as integer no-undo.
def var c-nome-repres    as char no-undo.
def var i-tab-finan      as integer no-undo.
def var i-indice         as integer no-undo.
def var i-cod-portador   as integer no-undo.
def var i-modalidade     as integer no-undo.
def var i-cod-mensagem   as integer no-undo.
def var c-cod-esp-princ  as char no-undo.
def var i-esp-docto      as integer no-undo.
def var d-dt-nf-orig     as date no-undo.
def var c-aux            as char no-undo.
def var c-it-codigo      as char no-undo.
def var c-cpf            as char no-undo.
def var h-acomp as handle no-undo.

/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i}
/* bloco principal do programa */

FIND FIRST tt-param NO-LOCK NO-ERROR. 

assign c-programa     = "int227"
       c-versao       = "2.12"
       c-revisao      = ".04.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Devoluá∆o Cupom Procfit".

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i}
    view frame f-cabec.
    view frame f-rodape.
end.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Devoluá‰es").

for first param-global fields (empresa-prin) no-lock 
    query-tuning(no-lookahead): end.
for first mgadm.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin 
    query-tuning(no-lookahead): end.
assign c-empresa = mgadm.empresa.razao-social.

/******* LE NOTA E GERA TEMP TABLES  *************/
define buffer bdevolucao-cupom for int_dp_nota_devolucao.
for-dev:
for each int_dp_nota_devolucao WHERE
    int_dp_nota_devolucao.situacao = 1
   //  AND int_dp_nota_devolucao.ndv_dataemissao_d >= 11/01/2016 
   //  AND int_dp_nota_devolucao.ndv_dataemissao_d <= 03/01/2020 
    // AND int_dp_nota_devolucao.ndv_notafiscal_n = 22492  
    // AND int_dp_nota_devolucao.ndv_serieorigem_s = "402"
    :

    run pi-elimina-tabelas.
    assign c-nat-operacao = ""
           c-num-nota     = trim(string(int_dp_nota_devolucao.ndv_notafiscal_n,">>>9999999"))
           c-num-cup      = trim(string(int_dp_nota_devolucao.ndv_notaorigem_n,">>>9999999"))
           c-num-cup6     = trim(string(int_dp_nota_devolucao.ndv_notaorigem_n,">>>>999999"))
           c-serie-cup    = trim(int_dp_nota_devolucao.ndv_serieorigem_s)
           c-serie-nota   = trim(int_dp_nota_devolucao.ndv_serie_s)
           c-cpf          = OnlyNumbers(int_dp_nota_devolucao.ndv_cpf_cliente)
           i-cod-mensagem = 0
           l-erro         = no.

    run pi-valida-cabecalho.
    if not l-erro then do:
        for each int_dp_nota_devolucao_item no-lock of int_dp_nota_devolucao
            query-tuning(no-lookahead):
            run pi-valida-item.
            if not l-erro then run pi-cria-tt-it-docto.
        end. /* int_dp_nota_devolucao_item */
    end.    
    if  not l-erro and 
        not can-find(first tt-movto) then do:
        run pi-gera-log (input "Documento sem itens. Filial: " + c-cod-estab-dev + 
                               " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota + " Cupom: " + c-num-cup,
                         input 1).
        next.
    end.

    if not l-erro then do:
        run pi-cria-tt-docto.
        run pi-importa-nota.
        run pi-elimina-tabelas.
    end.
    release int_dp_nota_devolucao.
end.
run pi-elimina-tabelas.

/* fechamento do output do relat¢rio  */
if tt-param.arquivo <> "" then do:
    {include/i-rpclo.i}
end.

RUN intprg/int888.p (INPUT "DEV PROC",
                     INPUT "int227rp.p").
                     
run pi-finalizar in h-acomp.

return "OK":U.


procedure pi-valida-cabecalho:

    if int_dp_nota_devolucao.ndv_dataemissao_d = ? then do:
        run pi-gera-log (input "Data de emiss∆o da nota n∆o informada: ?",
                         input 1).
        next.
    end.

    c-estado-dev    = ''.
    c-cod-estab-dev = ''.
    c-bairro        = "".
    c-cidade        = "".
    c-pais          = "".
    c-endereco      = "".
    c-cep           = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo cod-emitente) 
        no-lock where
        estabelec.cgc = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_dp_nota_devolucao.ndv_dataemissao_d
        query-tuning(no-lookahead):
        c-estado-dev    = estabelec.estado.
        c-cod-estab-dev = estabelec.cod-estabel.
        /* assume end. da filial caso cliente de outra UF 12/09/2018 AVB */
        assign 
            c-cep           = trim(string(estabelec.cep))
            c-bairro        = estabelec.bairro    
            c-cidade        = PrintChar(estabelec.cidade)
            c-pais          = estabelec.pais
            c-endereco      = estabelec.endereco.
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

    for first ser-estab no-lock where
        ser-estab.serie = c-serie-nota and
        ser-estab.cod-estabel = c-cod-estab-dev
        query-tuning(no-lookahead): end.
    if not avail ser-estab then do:
        run pi-gera-log (input "SÇrie n∆o cadastrada para estabelecimento: " 
                         + "Est: "       + c-cod-estab-dev
                         + " SÇrie: "    + c-serie-nota
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.  

    if c-cpf = "" or c-cpf = "0" then do:
        run pi-gera-log (input "CPF do cliente n∆o informado. Filial: " + c-cod-estab-comp + 
                         " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                         " Cupom: "         + c-num-cup,
                         input 1).
        return.
    end.


    i-cod-emitente  = 0.
    i-tip-cob-desp  = 0.
    i-cod-rep       = 0.
    c-ins-estadual  = "".
    c-nome-abrev    = "".
    /*
    c-bairro        = "".
    c-cidade        = "".
    c-pais          = "".
    c-endereco      = "".
    c-cep           = "".
    */
    for first emitente no-lock where emitente.cgc = c-cpf
        query-tuning(no-lookahead):
        assign  i-cod-emitente  = emitente.cod-emitente
                c-ins-estadual  = emitente.ins-estadual
                c-nome-abrev    = emitente.nome-abrev
                i-cod-rep       = emitente.cod-rep
                i-tip-cob-desp  = emitente.tip-cob-desp.

        /* assume end. cliente somente se este for da mesma UF 12/09/2018 AVB */
        if emitente.estado = c-estado-dev then 
            assign 
                c-cep           = emitente.cep
                c-bairro        = emitente.bairro    
                c-cidade        = PrintChar(emitente.cidade)
                c-pais          = emitente.pais
                c-endereco      = emitente.endereco
                c-estado-dev    = emitente.estado.

    end.
    if not avail emitente then do:
        run pi-gera-log (input "Cliente n∆o cadastrado CPF: " + c-cpf,
                         input 1).
        next.
    end.

    c-estado-ori    = "".
    c-cidade-ori    = "". 
    c-cod-estab-comp = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_dp_nota_devolucao.ndv_dataemissao_d
        query-tuning(no-lookahead):
        c-estado-ori    = estabelec.estado.
        c-cidade-ori    = estabelec.cidade.
        c-cod-estab-comp = estabelec.cod-estabel.
        leave.
    end.
    if c-cod-estab-comp = "" then do:
        run pi-gera-log (input "Estabelecimento CUPOM n∆o cadastrado ou fora de operaá∆o: " + c-cod-estab-comp,
                         input 1).
        next.
    end.

    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres fields (cod-rep nome-abrev) no-lock where 
            repres.cod-rep = i-cod-rep
            query-tuning(no-lookahead):
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.

    for first param-estoq no-lock query-tuning(no-lookahead): 
        if month (param-estoq.ult-fech-dia) = 12 then 
            assign c-periodo-fecha = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
        else
            assign c-periodo-fecha = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").
        
        if (c-periodo-fecha = string(year(int_dp_nota_devolucao.ndv_dataemissao_d),"9999") + string(month(int_dp_nota_devolucao.ndv_dataemissao_d),"99") and
           (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes)) or
            param-estoq.ult-fech-dia >= int_dp_nota_devolucao.ndv_dataemissao_d then do:

          //  ASSIGN int_dp_nota_devolucao.situacao = 5.
          /*  IF int_dp_nota_devolucao.ndv_dataemissao_d < 02/01/2022 THEN
                ASSIGN int_dp_nota_devolucao.ndv_dataemissao_d = 02/01/2022.*/

            run pi-gera-log (input "Documento em per°odo fechado ou em fechamento. Filial: "   + c-cod-estab-comp + 
                             " Nr. Devoluá∆o: " + c-num-nota    + " Serie: " + c-serie-nota +
                             " Data: " + string(int_dp_nota_devolucao.ndv_dataemissao_d,"99/99/9999"),
                             input 1).
        end.                
    end.

    IF int_dp_nota_devolucao.ndv_serieorigem_s <> "402" THEN DO:
        assign c-tp-pedido = "98".
        for last int_ds_nota_loja no-lock where
            int_ds_nota_loja.cnpj_filial = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s and
            int_ds_nota_loja.num_nota    = c-num-cup6   and
            trim(int_ds_nota_loja.serie) = c-serie-cup /* and
            int_ds_nota_loja.emissao    <= int_dp_nota_devolucao.ndv_dataemissao_d  */
            query-tuning(no-lookahead): 
            if int_ds_nota_loja.nfce_chave_s <> ? then
                assign c-tp-pedido = trim(substring(OnlyNumbers(int_ds_nota_loja.nfce_chave_s),21,2)).
        end.
        if not avail int_ds_nota_loja then do:
            for last int_ds_nota_loja no-lock where
                int_ds_nota_loja.cnpj_filial = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s and
                int_ds_nota_loja.num_nota    = string(int(c-num-cup6),"9999999")   and
                trim(int_ds_nota_loja.serie) = c-serie-cup: 
                if int_ds_nota_loja.nfce_chave_s <> ? then
                    assign c-tp-pedido = trim(substring(OnlyNumbers(int_ds_nota_loja.nfce_chave_s),21,2)).
            end.
    
        END.
    
        if not avail int_ds_nota_loja then do:
            run pi-gera-log (input "2-Cupom origem ainda n∆o disponivel na integracao. Filial: " + c-cod-estab-comp + 
                             " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                             " Cupom: "         + c-num-cup + 
                             " Data: " + string(int_dp_nota_devolucao.ndv_dataemissao_d,"99/99/9999"),
                             input 1).
            next.
        end.
        else do:
            if  int_ds_nota_loja.situacao = 1 /* Pendente */
            then do:
                run pi-gera-log (input "Cupom origem ainda n∆o processado no ERP. Filial: " + c-cod-estab-comp + 
                                 " Nr. Devoluá∆o: " + c-num-nota    + " Serie: " + c-serie-nota +
                                 " Cupom: "         + c-num-cup + 
                                 " Data: " + string(int_dp_nota_devolucao.ndv_dataemissao_d,"99/99/9999"),
                                 input 1).
                next.
            end.
        end.
    END.
    ELSE DO:
        assign c-tp-pedido = "99". // Ecommerce Ç 99

    END.

    /* verificar prÇ-existencia */
    for first docum-est no-lock where
        docum-est.cod-estabel   = c-cod-estab-dev   and
        docum-est.cod-emitente  = i-cod-emitente    and 
        docum-est.serie-docto   = c-serie-nota      and 
        docum-est.nro-docto     = c-num-nota
        query-tuning(no-lookahead): end.
    if avail docum-est then do:
        run pi-gera-log (input "Documento de estoque j† cadastrado. Filial: " + c-cod-estab-dev + 
                         " Emitente: "   + string(docum-est.cod-emitente) + 
                         " SÇrie: "      + c-serie-nota +
                         " Docto.: "     + c-num-nota   +
                         /*" Natur. Oper.: " + docum-est.nat-operacao + */
                         " Cupom: "      + c-num-cup,
                         input 1).
        next.
    end.
    for first nota-fiscal no-lock where
        nota-fiscal.cod-estabel = c-cod-estab-dev    and
        nota-fiscal.serie       = c-serie-nota       and 
        nota-fiscal.nr-nota-fis = c-num-nota    
        query-tuning(no-lookahead): end.
    if avail nota-fiscal then do:
        run pi-gera-log (input "Nota fiscal j† cadastrada. Filial: " + c-cod-estab-dev + 
                         " Emitente: "   + string(nota-fiscal.cod-emitente) + 
                         " SÇrie: "      + c-serie-nota +
                         " Docto.: "     + c-num-nota   +
                         /*" Natur. Oper.: " + docum-est.nat-operacao + */
                         " Cupom: "      + c-num-cup,
                         input 1).
        next.
    end.

    for each cst_fat_devol no-lock where
        cst_fat_devol.cod_estabel = c-cod-estab-dev and 
        cst_fat_devol.numero_dev  = c-num-nota      and
        cst_fat_devol.nro_comp    = c-num-cup
        query-tuning(no-lookahead):

        /* devolucoes antes de alterar para nfd do estabelecimento */
        for first it-nota-fisc fields (dt-cancela nr-nota-fis)
            no-lock where 
            it-nota-fisc.cod-estabel = cst_fat_devol.cod_estabel and
            it-nota-fisc.serie-docum = cst_fat_devol.serie_comp and
            it-nota-fisc.nr-docum    = cst_fat_devol.nro_comp and
            it-nota-fisc.dt-cancela  = ?
            query-tuning(no-lookahead): 

            run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                             c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                             " SÇrie: " + cst_fat_devol.serie_docto +
                             " Docto.: " + cst_fat_devol.nro_docto +
                             " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                             " Cupom: " + c-num-cup + 
                             " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                             " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                             input 1).

            for each bint_dp_nota_devolucao exclusive where
                bint_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s  = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s and
                bint_dp_nota_devolucao.ndv_serie_s                = int_dp_nota_devolucao.ndv_serie_s and
                bint_dp_nota_devolucao.ndv_notafiscal_n           = int64(c-num-nota)
                query-tuning(no-lookahead):
                assign  bint_dp_nota_devolucao.situacao = 5 /* processada */.
                release bint_dp_nota_devolucao.
            end.
            next.
        end.
        /* devolucoes depois de alterar para nfd do estabelecimento */
        for first it-nota-fisc fields (dt-cancela nr-nota-fis)
            no-lock where 
            it-nota-fisc.cod-estabel = cst_fat_devol.cod_estabel and
            it-nota-fisc.serie       = cst_fat_devol.serie_docto and
            it-nota-fisc.nr-nota-fis = cst_fat_devol.nro_docto   and
            it-nota-fisc.dt-cancela  = ?
            query-tuning(no-lookahead): 

            run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                             c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                             " SÇrie: " + cst_fat_devol.serie_docto +
                             " Docto.: " + cst_fat_devol.nro_docto +
                             " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                             " Cupom: " + c-num-cup + 
                             " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                             " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                             input 1).
            for each bint_dp_nota_devolucao exclusive where
                bint_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s  = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s and
                bint_dp_nota_devolucao.ndv_serie_s                = int_dp_nota_devolucao.ndv_serie_s and
                bint_dp_nota_devolucao.ndv_notafiscal_n           = int64(c-num-nota)
                query-tuning(no-lookahead):
                assign  bint_dp_nota_devolucao.situacao = 5 /* processada */.
                release bint_dp_nota_devolucao.
            end.
            next.
        end.
        if not avail it-nota-fisc then do:
            for each docum-est no-lock where 
                docum-est.cod-estabel  = c-cod-estab-dev               and
                docum-est.cod-emitente = cst_fat_devol.cod_emitente  and
                docum-est.serie-docto  = cst_fat_devol.serie_docto   and
                docum-est.nat-operacao = cst_fat_devol.nat_operacao  and
                docum-est.dt-trans    >= int_dp_nota_devolucao.ndv_dataemissao_d and
                docum-est.esp-docto    = 20,
                first item-doc-est no-lock of docum-est where 
                item-doc-est.it-codigo = c-it-codigo,
                first it-nota-fisc fields (nr-nota-fis dt-cancela) no-lock where 
                it-nota-fisc.cod-estabel = docum-est.cod-estabel and
                it-nota-fisc.serie       = docum-est.serie-docto and
                it-nota-fisc.nr-nota-fis = docum-est.nro-docto   and
                it-nota-fisc.dt-cancela   = ?
                query-tuning(no-lookahead):
                if int(item-doc-est.nr-pedcli) = int(c-num-nota) then do:
                    run pi-gera-log (input "Documento j† devolvido. Filial: " + 
                                     c-cod-estab-dev + " Emitente: " + string(cst_fat_devol.cod_emitente) + 
                                     " SÇrie: " + cst_fat_devol.serie_docto +
                                     " Docto.: " + cst_fat_devol.nro_docto +
                                     " Natur. Oper.: " + cst_fat_devol.nat_operacao + 
                                     " Cupom: " + c-num-cup + 
                                     " Devoluá∆o PRS: " + cst_fat_devol.numero_dev +
                                     " Nota Devoluá∆o: " + it-nota-fisc.nr-nota-fis,
                                     input 1).
                    for each bint_dp_nota_devolucao exclusive where
                        bint_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s  = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s and
                        bint_dp_nota_devolucao.ndv_serie_s                = int_dp_nota_devolucao.ndv_serie_s and
                        bint_dp_nota_devolucao.ndv_notafiscal_n           = int64(c-num-nota)
                        query-tuning(no-lookahead):
                        assign  bint_dp_nota_devolucao.situacao = 5 /* processada */.
                        release bint_dp_nota_devolucao.
                    end.
                    next.
                end.
            end.
        end.
    end.

end.

procedure pi-valida-item:

    c-it-codigo     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_produto_n)).
    if  int_dp_nota_devolucao_item.ndp_sequencia_n = 0 or 
        int_dp_nota_devolucao_item.ndp_sequencia_n = ? then do:
        run pi-gera-log (input "Sequància do produto n∆o informada na devoluá∆o. Filial: " + c-cod-estab-comp + 
                         " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                         " Cupom: "         + c-num-cup + 
                         " Item: "          + c-it-codigo,
                         input 1).
        next.
    end.
    if  int_dp_nota_devolucao_item.ndp_sequenciaorigem_n = 0 or 
        int_dp_nota_devolucao_item.ndp_sequenciaorigem_n = ? then do:
        run pi-gera-log (input "Sequància do produto no cupom n∆o informada na devoluá∆o. Filial: " + c-cod-estab-comp + 
                         " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                         " Cupom: "         + c-num-cup + 
                         " Item: "          + c-it-codigo,
                         input 1).
        next.
    end.

    assign l-aux    = yes.
        
    IF int_dp_nota_devolucao.ndv_serieorigem_s <> "402" THEN DO:

        bloco-vld-item-cupom:
        for each  int_ds_nota_loja no-lock
            where int_ds_nota_loja.cnpj_filial = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s 
              and trim(int_ds_nota_loja.serie) = c-serie-cup
              and int_ds_nota_loja.num_nota    = c-num-cup6
              and int_ds_nota_loja.emissao    <= int_dp_nota_devolucao.ndv_dataemissao_d
            query-tuning(no-lookahead): 
    
            for each int_ds_nota_loja_item no-lock of int_ds_nota_loja 
                where int(int_ds_nota_loja_item.produto) = int_dp_nota_devolucao_item.ndp_produto_n
                  and int_ds_nota_loja_item.quantidade  >= int_dp_nota_devolucao_item.ndp_quantidade_n
                query-tuning(no-lookahead).
    
                assign l-aux = no.
                leave bloco-vld-item-cupom.
            end.
        end.
        
        if l-aux = YES then do:
            
            bloco-vld-item-cupom2:
            for each  int_ds_nota_loja no-lock
                where int_ds_nota_loja.cnpj_filial = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s 
                  and trim(int_ds_nota_loja.serie) = c-serie-cup
                  and int_ds_nota_loja.num_nota    = string(int(c-num-cup6),"9999999")
                query-tuning(no-lookahead): 
        
                for each int_ds_nota_loja_item no-lock of int_ds_nota_loja 
                    where int(int_ds_nota_loja_item.produto) = int_dp_nota_devolucao_item.ndp_produto_n
                      and int_ds_nota_loja_item.quantidade  >= int_dp_nota_devolucao_item.ndp_quantidade_n
                    query-tuning(no-lookahead).
        
                    assign l-aux = no.
                    leave bloco-vld-item-cupom2.
                end.
            end.
        END.
    
        if l-aux = yes then do:
            
            run pi-gera-log (input "Produto n∆o encontrado no cupom origem. Filial: " + c-cod-estab-comp + 
                             " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                             " Cupom: "         + c-num-cup + 
                             " Item: "          + c-it-codigo,
                             input 1).
            next.
        
        END.
    END.
    c-class-fiscal  = "".
    c-conta         = "".
    c-subconta      = "".
    for first item 
        fields (it-codigo class-fiscal tipo-con-est peso-liquido aliquota-ipi ct-codigo
                sc-codigo conta-aplicacao tipo-contr cd-trib-icm cd-trib-ipi cd-trib-iss un)
        no-lock where 
        item.it-codigo  = c-it-codigo
        query-tuning(no-lookahead): 
        c-class-fiscal  = /*item.class-fiscal*/ TrataNuloChar(OnlyNumbers(int_dp_nota_devolucao_item.ndp_ncm_s)).
        c-conta         = item.ct-codigo.
        c-subconta      = item.sc-codigo.
    end.
    if not avail item then do:
        run pi-gera-log (input "Item n∆o cadastrado: " + c-it-codigo,
                         input 1).
        next.
    end.
    for first item-estab no-lock where 
        item-estab.cod-estabel = c-cod-estab-dev and
        item-estab.it-codigo = c-it-codigo
        query-tuning(no-lookahead): end.
    if not avail item-estab then
        for first item-uni-estab no-lock where 
            item-uni-estab.cod-estabel = c-cod-estab-dev and
            item-uni-estab.it-codigo = c-it-codigo
            query-tuning(no-lookahead): end.
    if not avail item-estab and not avail item-uni-estab then do:
        run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + c-it-codigo + "/" + "Estab.: " + c-cod-estab-dev,
                         input 1).
        next.
    end.

    if item.tipo-contr = 4 and c-conta = "" then do:
        run pi-gera-log (input "Item dÇbito direto exige conta aplicaá∆o: " + c-it-codigo,
                         input 1).
        next.
    end.
    if item.class-fiscal = "" or
       item.class-fiscal = ? then do:
        run pi-gera-log (input "Item sem classificaá∆o fiscal: " + c-it-codigo,
                         input 1).
        next.
    end.

    if int_dp_nota_devolucao_item.ndp_cstbipi_n = ? then do:
        run pi-gera-log (input "CSTB ICMS n∆o informado Filial: " + c-cod-estab-dev + 
                         " Serie: "         + c-serie-nota + 
                         " Nr. Devoluá∆o: " + c-num-nota + 
                         " Item: "          + c-it-codigo,
                         input 1).
        next.
    end.

    if int_dp_nota_devolucao_item.ndp_cstbipi_n = ? then do:
        run pi-gera-log (input "CSTB IPI n∆o informado Filial: " + c-cod-estab-dev + 
                         " Serie: "         + c-serie-nota + 
                         " Nr. Devoluá∆o: " + c-num-nota + 
                         " Item: "          + c-it-codigo,
                         input 1).
        next.
    end.

    /* ORIGEM */
    c-nat-origem = "".
/*    MESSAGE " c-cod-estab-comp                          " c-cod-estab-comp                              skip
            " c-serie-cup                               " c-serie-cup                                   skip
            " c-num-cup                                 " c-num-cup                                     skip
            " c-it-codigo                               " c-it-codigo                                   skip
            " int_dp_nota_devolucao_item.ndp_sequenciaorigem_n " int_dp_nota_devolucao_item.ndp_sequenciaorigem_n SKIP
            " int_dp_nota_devolucao.ndv_dataemissao_d   " int_dp_nota_devolucao.ndv_dataemissao_d


        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    FIND FIRST bint_dp_nota_devolucao_item EXCLUSIVE-LOCK
        WHERE ROWID(bint_dp_nota_devolucao_item) = ROWID(int_dp_nota_devolucao_item) NO-ERROR.

    ASSIGN bint_dp_nota_devolucao_item.ndp_sequenciaorigem_n = 1.
                                                                                            
    RELEASE bint_dp_nota_devolucao_item.
    
    */
    for each it-nota-fisc no-lock where 
        it-nota-fisc.cod-estabel   = c-cod-estab-comp                        and
        it-nota-fisc.serie         = c-serie-cup                             and
        it-nota-fisc.nr-nota-fis   = c-num-cup                               and
        it-nota-fisc.it-codigo     = c-it-codigo                             and
        /* 05/02/2019 - AVB */
        it-nota-fisc.nr-seq-fat    = (if int_dp_nota_devolucao_item.ndp_sequenciaorigem_n > 0 
                                      then int_dp_nota_devolucao_item.ndp_sequenciaorigem_n * 10
                                      else it-nota-fisc.nr-seq-fat): 
        for first tt-it-nota-fisc where 
            tt-it-nota-fisc.cod-estabel = it-nota-fisc.cod-estabel and
            tt-it-nota-fisc.serie       = it-nota-fisc.serie and
            tt-it-nota-fisc.nr-nota-fis = it-nota-fisc.nr-nota-fis and
            tt-it-nota-fisc.nr-seq-fat  = it-nota-fisc.nr-seq-fat and
            tt-it-nota-fisc.it-codigo   = c-it-codigo
            query-tuning(no-lookahead): end.
        if not avail tt-it-nota-fisc then do:
            create tt-it-nota-fisc.
            buffer-copy it-nota-fisc to tt-it-nota-fisc
                assign tt-it-nota-fisc.qt-saldo = it-nota-fisc.qt-faturada[1].
        end.
        assign c-nat-origem = it-nota-fisc.nat-operacao.

        /*
        DISPLAY tt-it-nota-fisc.cod-estabel
                tt-it-nota-fisc.serie      
                tt-it-nota-fisc.nr-nota-fis
                tt-it-nota-fisc.nr-seq-fat 
                tt-it-nota-fisc.it-codigo  
                tt-it-nota-fisc.qt-saldo.
        */
    end.

    if not can-find(first tt-it-nota-fisc no-lock where
                    tt-it-nota-fisc.cod-estabel = c-cod-estab-comp and
                    tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-num-cup), "9999999")) and
                    tt-it-nota-fisc.it-codigo   = c-it-codigo) then do:

        for each it-nota-fisc no-lock where 
            it-nota-fisc.cod-estabel   = c-cod-estab-comp                        and
            it-nota-fisc.serie         = c-serie-cup                             and
            it-nota-fisc.nr-nota-fis   = c-num-cup                               and
            it-nota-fisc.it-codigo     = c-it-codigo                            : 
            for first tt-it-nota-fisc where 
                tt-it-nota-fisc.cod-estabel = it-nota-fisc.cod-estabel and
                tt-it-nota-fisc.serie       = it-nota-fisc.serie and
                tt-it-nota-fisc.nr-nota-fis = it-nota-fisc.nr-nota-fis and
                tt-it-nota-fisc.nr-seq-fat  = it-nota-fisc.nr-seq-fat and
                tt-it-nota-fisc.it-codigo   = c-it-codigo
                query-tuning(no-lookahead): end.
            if not avail tt-it-nota-fisc then do:
                create tt-it-nota-fisc.
                buffer-copy it-nota-fisc to tt-it-nota-fisc
                    assign tt-it-nota-fisc.qt-saldo = it-nota-fisc.qt-faturada[1].
            end.
            assign c-nat-origem = it-nota-fisc.nat-operacao.
    
            /*
            DISPLAY tt-it-nota-fisc.cod-estabel
                    tt-it-nota-fisc.serie      
                    tt-it-nota-fisc.nr-nota-fis
                    tt-it-nota-fisc.nr-seq-fat 
                    tt-it-nota-fisc.it-codigo  
                    tt-it-nota-fisc.qt-saldo.
            */
        end.
    
        if not can-find(first tt-it-nota-fisc no-lock where
                        tt-it-nota-fisc.cod-estabel = c-cod-estab-comp and
                        tt-it-nota-fisc.nr-nota-fis = trim(string(int(c-num-cup), "9999999")) and
                        tt-it-nota-fisc.it-codigo   = c-it-codigo) then do:
            run pi-gera-log (input "Item da nota origem n∆o encontrado. Filial: " + c-cod-estab-comp + 
                             " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                             " Cupom: "         + c-num-cup  +
                             " Item: "          + c-it-codigo +
                             " Seq: "           + string(int_dp_nota_devolucao_item.ndp_sequenciaorigem_n * 10),
                             input 1).
            next.
        end.

    END.

    for last  tt-it-nota-fisc use-index id-ult-nota no-lock 
        where tt-it-nota-fisc.cod-estabel = c-cod-estab-comp 
          and tt-it-nota-fisc.nr-nota-fis = TRIM(string(int(c-num-cup), "9999999"))
          and tt-it-nota-fisc.it-codigo   = c-it-codigo 
          and tt-it-nota-fisc.qt-saldo   >= int_dp_nota_devolucao_item.ndp_quantidade_n
        query-tuning(no-lookahead):

        create tt-movto.
        assign tt-movto.nr-nota-fis     = c-num-nota
               tt-movto.dt-emissao      = int_dp_nota_devolucao.ndv_dataemissao_d
               tt-movto.cnpj_filial_dev = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s
               tt-movto.numero_dev      = int_dp_nota_devolucao.ndv_notafiscal_n
               tt-movto.cnpj_filial_cup = int_dp_nota_devolucao.ndv_cnpjfilialorigem_s
               tt-movto.numero_cup      = int_dp_nota_devolucao.ndv_notaorigem_n
               tt-movto.it-codigo       = c-it-codigo
               tt-movto.cod-estab-comp  = c-cod-estab-comp.
        assign tt-movto.qt-recebida     = int_dp_nota_devolucao_item.ndp_quantidade_n
               tt-movto.base-pis        = int_dp_nota_devolucao_item.ndp_basepis_n
               tt-movto.valor-pis       = int_dp_nota_devolucao_item.ndp_valorpis_n
               tt-movto.aliquota-pis    = int_dp_nota_devolucao_item.ndp_percentualpis_n
               tt-movto.base-cofins     = int_dp_nota_devolucao_item.ndp_basecofins_n
               tt-movto.valor-cofins    = int_dp_nota_devolucao_item.ndp_valorcofins_n
               tt-movto.aliquota-cofins = int_dp_nota_devolucao_item.ndp_percentualcofins_n

               tt-movto.serie-comp      = tt-it-nota-fisc.serie
               tt-movto.nro-comp        = tt-it-nota-fisc.nr-nota-fis
               tt-movto.nat-comp        = tt-it-nota-fisc.nat-operacao
               tt-movto.seq-comp        = tt-it-nota-fisc.nr-seq-fat
               tt-movto.data-comp       = tt-it-nota-fisc.dt-emis-nota
               tt-it-nota-fisc.qt-saldo = tt-it-nota-fisc.qt-saldo - tt-movto.qt-recebida.

        assign tt-movto.cod-estabel     = c-cod-estab-dev
               tt-movto.uf              = c-estado-dev
               tt-movto.nr-sequencia    = int_dp_nota_devolucao_item.ndp_sequencia_n.
        assign tt-movto.cd-trib-pis     = if int_dp_nota_devolucao_item.ndp_valorpis_n > 0 then 1 else 2
               tt-movto.cd-trib-cofins  = if int_dp_nota_devolucao_item.ndp_valorcofins_n > 0 then 1 else 2
               tt-movto.chave-acesso    = TrataNuloChar(int_dp_nota_devolucao.ndv_chaveacesso_s)
               tt-movto.idi-sit-nf-eletro = if int_dp_nota_devolucao.tipo_movto = 3 then 6 else 3
               tt-movto.observacao      = "Devoluá∆o Cupom: " + c-num-cup + " SÇrie: " + c-serie-cup + " Filial: " + c-cod-estab-comp.

        /* n∆o movimenta lote no totvs
        for first fat-ser-lote no-lock 
            WHERE fat-ser-lote.cod-estabel = tt-it-nota-fisc.cod-estabel
              AND fat-ser-lote.serie       = tt-it-nota-fisc.serie
              AND fat-ser-lote.nr-nota-fis = tt-it-nota-fisc.nr-nota-fis
              AND fat-ser-lote.nr-seq-fat  = tt-it-nota-fisc.nr-seq-fat
              AND fat-ser-lote.it-codigo   = tt-it-nota-fisc.it-codigo
              query-tuning(no-lookahead):
            assign tt-movto.lote            = fat-ser-lote.nr-serlote
                   tt-movto.dt-vali-lote    = fat-ser-lote.dt-vali-lote.
        end.
        assign tt-movto.lote            = int_dp_nota_devolucao_item.ndp-lote-s
               tt-movto.dt-vali-lote    = int_dp_nota_devolucao_item.ndp-datavalidade-d.
        */

    end. /* tt-it-nota-fisc */

    if not avail tt-it-nota-fisc then do:
        run pi-gera-log (input "Produto n∆o encontrado na nota origem com saldo para devoluá∆o. Filial: " + c-cod-estab-comp + 
                         " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                         " Cupom: " + c-num-cup          + 
                         " Item: "  + c-it-codigo     +
                         " Qtde: "  + string(int_dp_nota_devolucao_item.ndp_quantidade_n),
                         input 1).
        next.
    end.

    if item.tipo-contr = 4 /* debito direto */ then do:
        assign tt-movto.conta-aplicacao = c-conta
               tt-movto.sc-codigo = c-subconta.
    end.


    assign tt-movto.cod-depos = /*if avail item-uni-estab 
                                then item-uni-estab.deposito-pad
                                else item-estab.deposito-pad.*/ "LOJ".

    for first nota-fiscal no-lock of tt-it-nota-fisc 
       query-tuning(no-lookahead): 
       assign d-dt-nf-orig = nota-fiscal.dt-emis-nota.
       
       if not can-find(first mgdis.cidade no-lock where 
           cidade.pais   = c-pais and
           cidade.estado = c-estado-dev and
           cidade.cidade = c-cidade) then do:
           run pi-gera-log (input "Cidade do cliente n∆o encontrada. Pa°s: " + c-pais + " UF: " + c-estado-dev + " Cidade: " + c-cidade + " Cliente: " + string(i-cod-emitente),
                            input 1).
           next.
       end.
       
       assign tt-movto.cod-emitente = i-cod-emitente.
       
       c-nat-of = "".
       /* determina natureza de operacao */
       run intprg/int115a.p ( input c-tp-pedido    ,
                              input c-estado-dev   ,
                              input c-estado-dev   ,
                              input c-nat-origem   ,
                              input i-cod-emitente ,
                              input c-class-fiscal ,
			                  input c-it-codigo    , /* item */
                              INPUT "", // estabel
                              output c-aux         ,
                              output c-nat-of      ,
                              output r-rowid).

       
       /*
       display c-it-codigo
               c-tp-pedido    
               c-estado-dev   
               c-estado-dev   
               c-nat-origem   
               i-cod-emitente 
               c-class-fiscal 
               c-aux         
               c-nat-of      
               ndv_notaorigem_n
               ndv-serieorigem
           with frame f-log width 550 stream-io.
       */

       if  c-nat-of = "" or c-nat-of = ? then do:
           assign c-nat-of = "".
           run pi-gera-log (input "N∆o encontrada natureza de operaá∆o para entrada. Filial: " + c-cod-estab-dev + 
                            " Nr. Devoluá∆o: " + c-num-nota      + " Serie: " + c-serie-nota +
                            " Cupom: "         + c-num-cup       + 
                            " Natur. Oper.: "  + c-nat-of        +
                            " UF: "            + c-estado-dev    +
                            " Estab.: "        + c-cod-estab-dev +
                            " NCM: "           + c-class-fiscal  +
                            " Tp Pedido: "     + c-tp-pedido,
                            input 1).
           next.
       end.

       assign  c-cod-esp-princ = ""
               i-esp-docto     = 0.
       for first natur-oper no-lock where 
           natur-oper.nat-operacao = c-nat-of: 
           if i-cod-mensagem = 0 then 
                assign i-cod-mensagem = natur-oper.cod-mensagem.
           assign  c-cod-esp-princ = natur-oper.cod-esp
                   i-esp-docto     = if natur-oper.especie-doc = "NFS" then 22 else 
                                       if natur-oper.especie-doc = "NFD" then 20 else 
                                         if natur-oper.especie-doc = "NFT" then 23 else 21 /* NFE */.
       end.
       if not avail natur-oper then do:
           run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada: " + c-nat-of,
                            input 1).
           next.
       end.
       if c-nat-operacao = "" then c-nat-operacao = c-nat-of.
       assign tt-movto.nat-operacao    = c-nat-operacao
              tt-movto.nat-of          = c-nat-of
              tt-movto.serie           = c-serie-nota.

       if natur-oper.tipo-compra <> 3 then do:
           run pi-gera-log (input "Natureza de operaá∆o deve ter tipo de compra Devoluá∆o de Cliente. Filial: " + c-cod-estab-dev + 
                                  " Nr. Devoluá∆o: " + c-num-nota + " Serie: " + c-serie-nota +
                                  " Cupom: "         + c-num-cup  + 
                                  " Natur. Oper.: "  + c-nat-of,
                            input 1).
           next.
       end.
       assign tt-movto.tipo-compra     = natur-oper.tipo-compra.

    end. /* nota-fiscal */
end.

procedure pi-importa-nota.
    
    run pi-acompanhar in h-acomp (input "Gerando Nota").

    for first tt-docto query-tuning(no-lookahead):     end.
    for first tt-it-docto query-tuning(no-lookahead):  end.
    for first tt-movto query-tuning(no-lookahead):     end.
    if  avail  tt-docto     and
        avail  tt-it-docto  and
        avail  tt-movto
    then do-nota: do transaction:

        run pi-gera-tt-fat-devol.
        if return-value = "NOK" then do:
            run pi-gera-log (input ("Parcelas de devoluá∆o n∆o enviadas: " + 
                                    " Emitente: " + string(tt-movto.cod-emitente) + 
                                    " SÇrie: " + tt-movto.serie +
                                    " Docto.: " + tt-movto.nr-nota-fis +
                                    " Natur. Oper.: " + tt-movto.nat-operacao + 
                                    " Cupom: " + tt-movto.nro-comp),
                             input 1).
            return.
        end.
    
        
/*         PUT tt-docto.cod-estabel " - " LENGTH(tt-docto.cod-estabel) */
/*             tt-docto.serie       " - " LENGTH(tt-docto.serie)       */
/*             tt-docto.nr-nota     " - " LENGTH(tt-docto.nr-nota)     */
/*             SKIP.                                                   */
        
        run ftp/ft2010.p (input  no,
                          output l-erro,
                          input  table tt-docto,
                          input  table tt-it-docto,
                          input  table tt-it-imposto,
                          input  table tt-nota-trans,
                          input  table tt-saldo-estoq,
                          input  table tt-fat-duplic,
                          input  table tt-fat-repre,
                          input  table tt-nota-embal,
                          input  table tt-item-embal,
                          input  table tt-it-docto-imp,
                          &IF DEFINED(bf_dis_desc_bonif) &THEN
                          input  table tt-docto-bn,
                          input  table tt-it-docto-bn,
                          &ENDIF
                          &IF DEFINED(bf_dis_unid_neg) &THEN
                          input table tt-rateio-it-duplic ,
                          &ENDIF
                          input-output table tt-notas-geradas
                          &IF DEFINED(bf_dis_ciap) &THEN ,
                          input table tt-it-nota-doc
                          &ENDIF ,
                          input table tt-desp-nota-fisc).                         

        for each tt-notas-geradas query-tuning(no-lookahead):
            for each nota-fiscal NO-LOCK where 
                rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal
                query-tuning(no-lookahead):
                run pi-acompanhar in h-acomp (input "Verifica Nota: " + nota-fiscal.nr-nota-fis).

                /* acerta tipo da nota para nota pr¢pria */
                FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                    WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.
                IF AVAIL b-nota-fiscal THEN
                    assign b-nota-fiscal.ind-tip-nota = 8.
                RELEASE b-nota-fiscal.

                /* adicionais substituiá∆o de cupom e devoluá∆o */
                for each tt-nota-fiscal-adc of nota-fiscal
                    query-tuning(no-lookahead):
                    for first nota-fisc-adc where 
                              nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel         and 
                              nota-fisc-adc.cod-serie      = nota-fiscal.serie               and 
                              nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis         and 
                              nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente        and 
                              nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao        and 
                              nota-fisc-adc.idi-tip-dado   = tt-nota-fiscal-adc.idi-tip-dado and 
                              nota-fisc-adc.num-seq        = 1 query-tuning(no-lookahead):   end.
                    if not avail nota-fisc-adc then do :
                       create nota-fisc-adc.
                       assign nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  
                              nota-fisc-adc.cod-serie      = nota-fiscal.serie        
                              nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  
                              nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente 
                              nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao
                              nota-fisc-adc.idi-tip-dado   = tt-nota-fiscal-adc.idi-tip-dado
                              nota-fisc-adc.num-seq        = 1.
                       buffer-copy tt-nota-fiscal-adc to nota-fisc-adc.
                    end. 
                end.    

                run pi-gera-docum-est.
                if  RETURN-VALUE <> "OK" or l-erro = yes or
                    not can-find (first docum-est no-lock where 
                                  docum-est.cod-emitente = nota-fiscal.cod-emitente and
                                  docum-est.serie-docto  = nota-fiscal.serie        and
                                  docum-est.nro-docto    = nota-fiscal.nr-nota-fis  and
                                  docum-est.nat-operacao = nota-fiscal.nat-operacao)
                    then undo do-nota, return.

                /* campos adicionais */
                for each bint_dp_nota_devolucao exclusive-lock where
                    bint_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s and
                    bint_dp_nota_devolucao.ndv_serie_s       = int_dp_nota_devolucao.ndv_serie_s       and
                    bint_dp_nota_devolucao.ndv_notafiscal_n  = int_dp_nota_devolucao.ndv_notafiscal_n
                    query-tuning(no-lookahead):

                    for each it-nota-fisc of nota-fiscal exclusive-lock
                        query-tuning(no-lookahead):
                        assign it-nota-fisc.nr-pedcli = nota-fiscal.nr-pedcli.

                        /* acertando campos n∆o suportados na ft2010 */
                        for each int_dp_nota_devolucao_item no-lock of bint_dp_nota_devolucao where
                            /*int_dp_nota_devolucao_item.ndp-sequencia-n = it-nota-fisc.nr-seq-fat and*/
                            int_dp_nota_devolucao_item.ndp_produto_n = int64(it-nota-fisc.it-codigo)
                            query-tuning(no-lookahead):

                            for first tt-it-nota-fisc no-lock of nota-fiscal where
                                tt-it-nota-fisc.it-codigo = it-nota-fisc.it-codigo
                                query-tuning(no-lookahead): end.

                            /* CSTÔs e Modalidades de base de c†lculo */
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                assign  it-nota-fisc.cod-sit-tributar-ipi     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbipi_n,"99"))
                                        it-nota-fisc.cod-sit-tributar-pis     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbpis_s,"99"))
                                        it-nota-fisc.cod-sit-tributar-cofins  = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbcofins_s,"99")).

                                assign  it-nota-fisc.idi-modalid-base-icms    = if int_dp_nota_devolucao_item.ndp_modbcicms_n <> ? /* se preenchido, usa este */
                                                                                then TrataNuloDec(int_dp_nota_devolucao_item.ndp_modbcicms_n)
                                                                                else int(substring(it-nota-fisc.char-1,81,2)) /* se n∆o, usa da origem */
                                        it-nota-fisc.idi-modalid-base-icms-st = if int_dp_nota_devolucao_item.ndp_modbcst_n <> ? /* se preenchido, usa este */
                                                                                then TrataNuloDec(int_dp_nota_devolucao_item.ndp_modbcst_n)  
                                                                                else int(substring(it-nota-fisc.char-1,85,2)) /* se n∆o, usa da origem */
                                        it-nota-fisc.idi-modalid-base-ipi     = if int_dp_nota_devolucao_item.ndp_modbipi_n <> ?  /* se n∆o, usa da origem */
                                                                                then TrataNuloDec(int_dp_nota_devolucao_item.ndp_modbipi_n)
                                                                                else int(substring(it-nota-fisc.char-1,83,2)). /* se n∆o, usa da origem */
                            &else
                                assign  overlay(it-nota-fisc.char-1,75,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbipi_n,"99"))
                                        overlay(it-nota-fisc.char-1,77,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbpis_s,"99"))
                                        overlay(it-nota-fisc.char-1,79,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbcofins_s,"99")).

                                assign  overlay(it-nota-fisc.char-1,81,2)     = if int_dp_nota_devolucao_item.ndp_modbcicms_n <> ?
                                                                                then TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbcicms_n))
                                                                                else substring(it-nota-fisc.char-1,81,2)
                                        overlay(it-nota-fisc.char-1,85,2)     = if int_dp_nota_devolucao_item.ndp_modbcst_n <> ?
                                                                                then TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbcst_n))
                                                                                else substring(it-nota-fisc.char-1,85,2)
                                        overlay(it-nota-fisc.char-1,83,2)     = if int_dp_nota_devolucao_item.ndp_modbipi_n <> ?
                                                                                then TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbipi_n))
                                                                                else substring(it-nota-fisc.char-1,83,2).
                            &endif
                            
                            /* PIS/COFINS */
                            assign overlay(it-nota-fisc.char-2,96,1)          = if int_dp_nota_devolucao_item.ndp_percentualpis_n > 0 then "1" else "2" /* Tributaá∆o PIS    */ 
                                   overlay(it-nota-fisc.char-2,76,5)          = string (int_dp_nota_devolucao_item.ndp_percentualpis_n,"99.99") /* Aliquota PIS */.
                        
                            assign overlay(it-nota-fisc.char-2,97,1)          = if int_dp_nota_devolucao_item.ndp_percentualcofins_n > 0 then "1" else "2" /* Tributaá∆o COFINS */
                                   overlay(it-nota-fisc.char-2,81,5)          = string(int_dp_nota_devolucao_item.ndp_percentualcofins_n,"99.99").
                        
                            assign overlay(it-nota-fisc.char-2,86,5)  /* Reduá∆o PIS    */ = "00,00".
                                   overlay(it-nota-fisc.char-2,91,5)  /* Reduá∆o COFINS */ = "00,00".
                        end.
                    end.
                    RELEASE it-nota-fisc.

                    /* Marcando integraá∆o processada nos pedidos e na nota */
                    assign bint_dp_nota_devolucao.situacao = 2.
                    
                    run pi-gera-log (input "Nota fiscal importada com sucesso: " 
                                     + "Est: "       + c-cod-estab-dev
                                     + " SÇrie: "    + c-serie-nota
                                     + " Numero: "   + c-num-nota,
                                     input 2).
                    release bint_dp_nota_devolucao.
                 end.
            end.
        end.

        /* verificando notas n∆o importadas */
        for each tt-docto
            query-tuning(no-lookahead):
            if not can-find (first nota-fiscal no-lock where
                                   nota-fiscal.cod-estabel = tt-docto.cod-estabel and
                                   nota-fiscal.serie       = tt-docto.serie       and
                                   nota-fiscal.nr-nota-fis = tt-docto.nr-nota) then do:
                run pi-gera-log (input "Nota fiscal NAO importada: " 
                                 + "Est: "       + c-cod-estab-dev
                                 + " SÇrie: "    + c-serie-nota 
                                 + " Numero: "   + c-num-nota,
                                 input 1).
                undo, leave.
            end.
            else do:

                /* atualizar documento estoque */
                empty temp-table tt-digita-re1005.
                empty temp-table tt-param-re1005.

                create tt-param-re1005.
                assign 
                    tt-param-re1005.destino            = 3
                    tt-param-re1005.arquivo            = "int227-re1005.txt"
                    tt-param-re1005.usuario            = c-seg-usuario
                    tt-param-re1005.data-exec          = today
                    tt-param-re1005.hora-exec          = time
                    tt-param-re1005.classifica         = 1
                    tt-param-re1005.c-cod-estabel-ini  = tt-docto.cod-estabel
                    tt-param-re1005.c-cod-estabel-fim  = tt-docto.cod-estabel
                    tt-param-re1005.i-cod-emitente-ini = tt-docto.cod-emitente
                    tt-param-re1005.i-cod-emitente-fim = tt-docto.cod-emitente
                    tt-param-re1005.c-nro-docto-ini    = tt-docto.nr-nota
                    tt-param-re1005.c-nro-docto-fim    = tt-docto.nr-nota
                    tt-param-re1005.c-serie-docto-ini  = tt-docto.serie
                    tt-param-re1005.c-serie-docto-fim  = tt-docto.serie
                    tt-param-re1005.c-nat-operacao-ini = tt-docto.nat-operacao
                    tt-param-re1005.c-nat-operacao-fim = tt-docto.nat-operacao
                    tt-param-re1005.da-dt-trans-ini    = tt-docto.dt-emis-nota
                    tt-param-re1005.da-dt-trans-fim    = tt-docto.dt-emis-nota.

                empty temp-table tt-digita-re1005.

                create tt-digita-re1005.
                assign tt-digita-re1005.r-docum-est  = rowid(docum-est).
                release docum-est.

                raw-transfer tt-param-re1005 to raw-param.
                run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                empty temp-table tt-digita-re1005.
                empty temp-table tt-param-re1005.

            end.
        end.

    end. /* do transaction */
end procedure.

procedure pi-gera-duplicatas:

    def var de-vl-tot-dup       as decimal no-undo.
    def var i-seq-fat-duplic    as integer no-undo.

    i-seq-fat-duplic = 0.

    if int_dp_nota_devolucao.tipo_movto <> 3 /* cancelado */ then do:

        for each int_dp_nota_devolucao_cond no-lock of int_dp_nota_devolucao
            by int_dp_nota_devolucao_cond.ndc_sequencia_n
            query-tuning(no-lookahead):
            if int_dp_nota_devolucao_cond.ndc_valor_n <= 0 then next.
            
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = 1
                   tt-fat-duplic.cod-vencto        = 1 /* dias da data */
                   tt-fat-duplic.dt-venciment      = int_dp_nota_devolucao.ndv_dataemissao_d
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = string(i-seq-fat-duplic,"99")
                   tt-fat-duplic.vl-parcela        = TrataNuloDec(int_dp_nota_devolucao_cond.ndc_valor_n)
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = c-cod-esp-princ.
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela.
        end.

        if can-find(first tt-fat-duplic where
                    tt-fat-duplic.seq-tt-docto = 1) then do:
    
            create tt-fat-repre.
            assign tt-fat-repre.seq-tt-docto = 1
                   tt-fat-repre.sequencia    = 1
                   tt-fat-repre.cod-rep      = i-cod-rep
                   tt-fat-repre.nome-ab-rep  = c-nome-repres
                   tt-fat-repre.perc-comis   = 0
                   tt-fat-repre.comis-emis   = 0
                   tt-fat-repre.vl-comis     = 0
                   tt-fat-repre.vl-emis      = 0.
        end.
    end.
end.

procedure pi-gera-docum-est:

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
    if not avail tt-movto then return "NOK".

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

    for each tt-movto
        break by tt-movto.serie
              by tt-movto.nr-nota-fis
              by tt-movto.nat-operacao
              by tt-movto.nr-sequencia
              by tt-movto.it-codigo
        query-tuning(no-lookahead):
        for first tt-docum-est-nova where
            tt-docum-est-nova.serie-docto       = tt-movto.serie         and
            tt-docum-est-nova.nro-docto         = tt-movto.nr-nota-fis   and
            tt-docum-est-nova.cod-emitente      = tt-movto.cod-emitente
            query-tuning(no-lookahead): end.
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
                   tt-docum-est-nova.observacao        = tt-movto.observacao
                   tt-docum-est-nova.ct-transit        = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                         estab-mat.conta-dev-cli
                                                         &else
                                                         estab-mat.cod-cta-devol-c-unif
                                                         &endif
                   tt-docum-est-nova.sc-transit        = ""
                   tt-docum-est-nova.dt-emissao        = tt-movto.dt-emissao
                   tt-docum-est-nova.dt-trans          = int_dp_nota_devolucao.ndv_dataemissao_d
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
                   tt-docum-est-nova.efetua-calculo    = 2 /*1 - efetua os c†lculos - <> 1 valor informado*/
                   tt-docum-est-nova.sequencia         = 1
                   tt-docum-est-nova.esp-docto         = 20 /* NFD */
                   tt-docum-est-nova.rec-fisico        = no
                   tt-docum-est-nova.origem            = "" /* verificar*/
                   tt-docum-est-nova.pais-origem       = "Brasil"
                   tt-docum-est-nova.cotacao-dia       = 0
                   tt-docum-est-nova.embarque          = ""
                   tt-docum-est-nova.gera-unid-neg     = 0.
               &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                    overlay(tt-docum-est-nova.char-1,93,60)  = tt-movto.chave-acesso.
                    overlay(tt-docum-est-nova.char-1,154,2)  = string(tt-movto.idi-sit-nf-eletro,">9").
               &else
                    tt-docum-est-nova.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                    tt-docum-est-nova.cdn-sit-nfe              = tt-movto.idi-sit-nf-eletro.
               &endif
        end.

        run pi-acompanhar in h-acomp (input string(tt-movto.nr-nota-fis + "/" + tt-movto.it-codigo)).
        for each tt-it-docto no-lock where 
            tt-it-docto.cod-estabel  = tt-movto.cod-estabel  and
            tt-it-docto.serie        = tt-movto.serie        and
            tt-it-docto.nr-nota      = tt-movto.nr-nota-fis  and
            tt-it-docto.it-codigo    = tt-movto.it-codigo    and
            tt-it-docto.nr-sequencia = tt-movto.nr-sequencia,
            first tt-it-imposto no-lock where 
            tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
            query-tuning(no-lookahead):

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
                   tt-item-doc-est-nova.preco-total        = tt-it-docto.vl-merc-liq
                   tt-item-doc-est-nova.desconto           = 0
                   tt-item-doc-est-nova.vl-frete-cons      = 0
                   tt-item-doc-est-nova.despesas           = 0
                   tt-item-doc-est-nova.peso-liquido       = tt-it-docto.peso-liq-it
                   tt-item-doc-est-nova.cod-depos          = tt-movto.cod-depos
                   tt-item-doc-est-nova.cod-localiz        = ""
                   tt-item-doc-est-nova.lote               = tt-movto.lote
                   tt-item-doc-est-nova.dt-vali-lote       = tt-movto.dt-vali-lote
                   tt-item-doc-est-nova.class-fiscal       = tt-it-docto.class-fiscal
                   tt-item-doc-est-nova.aliquota-ipi       = tt-it-imposto.aliquota-ipi
                   tt-item-doc-est-nova.cd-trib-ipi        = tt-it-imposto.cd-trib-ipi 
                   tt-item-doc-est-nova.base-ipi           = tt-it-imposto.vl-bipi-it
                   tt-item-doc-est-nova.valor-ipi          = tt-it-imposto.vl-ipi-it
                   tt-item-doc-est-nova.cd-trib-iss        = tt-it-imposto.cd-trib-iss
                   tt-item-doc-est-nova.aliquota-icm       = tt-it-imposto.aliquota-icm
                   tt-item-doc-est-nova.cd-trib-icm        = tt-it-imposto.cd-trib-icm 
                   tt-item-doc-est-nova.base-icm           = tt-it-imposto.vl-bicms-it
                   tt-item-doc-est-nova.valor-icm          = tt-it-imposto.vl-icms-it
                   tt-item-doc-est-nova.base-subs          = tt-it-imposto.vl-bsubs-it  
                   tt-item-doc-est-nova.valor-subs         = tt-it-imposto.vl-icmsub-it 
                   tt-item-doc-est-nova.icm-complem        = 0
                   tt-item-doc-est-nova.ind-icm-ret        = if tt-it-imposto.vl-icmsub-it <> 0 then yes else no
                   tt-item-doc-est-nova.narrativa          = ""
                   tt-item-doc-est-nova.icm-outras         = tt-it-imposto.vl-icmsou-it
                   tt-item-doc-est-nova.ipi-outras         = tt-it-imposto.vl-ipi-outras
                   tt-item-doc-est-nova.iss-outras         = tt-it-imposto.vl-issou-it 
                   tt-item-doc-est-nova.icm-ntrib          = tt-it-imposto.vl-icmsnt-it
                   tt-item-doc-est-nova.ipi-ntrib          = tt-it-imposto.vl-ipint-it
                   tt-item-doc-est-nova.iss-ntrib          = tt-it-imposto.vl-issnt-it
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
                   tt-item-doc-est-nova.ct-codigo          = tt-movto.conta-aplicacao
                   tt-item-doc-est-nova.sc-codigo          = tt-movto.sc-codigo
                   tt-item-doc-est-nova.base-pis           = tt-movto.base-pis       
                   tt-item-doc-est-nova.valor-pis          = tt-movto.valor-pis      
                   tt-item-doc-est-nova.aliquota-pis       = tt-movto.aliquota-pis   
                   tt-item-doc-est-nova.base-cofins        = tt-movto.base-cofins    
                   tt-item-doc-est-nova.valor-cofins       = tt-movto.valor-cofins   
                   tt-item-doc-est-nova.aliquota-cofins    = tt-movto.aliquota-cofins
                   tt-item-doc-est-nova.aliquota-iss       = tt-it-imposto.aliquota-iss
                   tt-item-doc-est-nova.base-iss           = tt-it-imposto.vl-biss-it
                   tt-item-doc-est-nova.valor-iss          = tt-it-imposto.vl-iss-it  
                   tt-item-doc-est-nova.val-perc-red-icm   = tt-it-imposto.perc-red-icm
                   tt-item-doc-est-nova.val-perc-red-ipi   = tt-it-imposto.perc-red-ipi.
            
            /* origem 
            assign tt-item-doc-est-nova.data-comp          = tt-movto.data-comp
                   tt-item-doc-est-nova.serie-comp         = tt-movto.serie-comp
                   tt-item-doc-est-nova.nro-comp           = tt-movto.nro-comp
                   tt-item-doc-est-nova.nat-comp           = tt-movto.nat-comp
                   tt-item-doc-est-nova.seq-comp           = tt-movto.seq-comp.
            */
             /*
             /*  CSTÔs */
             assign  overlay(tt-it-docto.char-1,75,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-cstbipi-n,"99"))
                     overlay(tt-it-docto.char-1,77,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-cstbpis-s,"99"))
                     overlay(tt-it-docto.char-1,79,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-cstbcofins-s,"99")).
        
             /* Modalidades de base */
             assign  overlay(tt-it-docto.char-1,81,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-modbcicms-n))
                     overlay(tt-it-docto.char-1,85,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-modbcst-n))
                     overlay(tt-it-docto.char-1,83,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp-modbipi-n)).
            */
        
        end.
        assign tt-docum-est-nova.valor-mercad = tt-docum-est-nova.valor-mercad + tt-item-doc-est-nova.preco-total.

        if last-of (tt-movto.nr-nota-fis) then 
        do-trans:
        do on error undo, leave:
            l-erro = yes.
            for each tt-cst_fat_devol where 
                tt-cst_fat_devol.cod_emitente = tt-docum-est-nova.cod-emitente  and  
                tt-cst_fat_devol.serie_docto  = tt-docum-est-nova.serie-docto   and  
                tt-cst_fat_devol.nro_docto    = tt-docum-est-nova.nro-docto     and  
                tt-cst_fat_devol.nat_operacao = tt-docum-est-nova.nat-operacao
                on error undo do-trans, leave do-trans:

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
               put skip(1).
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

            for first docum-est exclusive-lock of tt-docum-est-nova
                query-tuning(no-lookahead):

                /* Nota de faturamento - evitar geracao da nota novamente quando atualizar o documento */
                assign docum-est.log-1 = yes
                       &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                          overlay(docum-est.char-1,93,60)  = tt-movto.chave-acesso.
                          overlay(docum-est.char-1,154,2)  = string(tt-movto.idi-sit-nf-eletro,">9").
                       &else
                          docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
                          docum-est.idi-sit-nf-eletro = tt-movto.idi-sit-nf-eletro.
                       &endif
                       
                /* para evitar reatualizaá∆o de documento eliminados por correá∆o de integraá‰es 
                if can-find(first movto-estoq where
                                  movto-estoq.cod-estabel  = docum-est.cod-estabel and 
                                  movto-estoq.serie-docto  = docum-est.serie-docto and 
                                  movto-estoq.nro-docto    = docum-est.nro-docto and
                                  movto-estoq.nat-operacao = docum-est.nat-operacao and
                                  movto-estoq.cod-emitente = docum-est.cod-emitente) then do:
                    assign docum-est.ce-atual = yes.
                end.
                */

                for each item-doc-est of docum-est,
                    each btt-movto no-lock where 
                    btt-movto.nr-nota-fis  = item-doc-est.nro-docto     and
                    btt-movto.serie        = item-doc-est.serie-docto   and
                    btt-movto.cod-estabel  = docum-est.cod-estabel      and
                    btt-movto.it-codigo    = item-doc-est.it-codigo     and
                    btt-movto.nr-sequencia = item-doc-est.sequencia
                    query-tuning(no-lookahead):

                    /* compatibilidade dados anteriores PRS */
                    assign item-doc-est.nr-pedcli = tt-movto.nr-nota-fis.

                    /* acerto pis/cofins alterados na API */
                    for first tt-item-doc-est-nova of item-doc-est:
                        assign  item-doc-est.idi-tributac-pis     = if tt-item-doc-est-nova.valor-pis > 0 then 1 else 2
                                item-doc-est.val-aliq-pis         = tt-item-doc-est-nova.aliquota-pis
                                item-doc-est.base-pis             = tt-item-doc-est-nova.base-pis
                                item-doc-est.valor-pis            = tt-item-doc-est-nova.valor-pis
                                item-doc-est.idi-tributac-cof     = if tt-item-doc-est-nova.valor-cofins > 0 then 1 else 2
                                item-doc-est.val-aliq-cof         = tt-item-doc-est-nova.aliquota-cofins
                                item-doc-est.val-cofins           = tt-item-doc-est-nova.valor-cofins  
                                item-doc-est.val-base-calc-cofins = tt-item-doc-est-nova.base-cofins.
                         assign item-doc-est.data-comp            = btt-movto.data-comp    
                                item-doc-est.serie-comp           = btt-movto.serie-comp   
                                item-doc-est.nro-comp             = btt-movto.nro-comp     
                                item-doc-est.nat-comp             = btt-movto.nat-comp     
                                item-doc-est.seq-comp             = btt-movto.seq-comp.

    
                    /* KML - 16/12/2022 - Colocar dados de CST no documento */ 
    
                        FIND FIRST emitente NO-LOCK
                            WHERE emitente.cod-emitente = docum-est.cod-emitente NO-ERROR.
        
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
                    END.

                END.
                return "OK".
            end.
            if not avail docum-est then do:
                run pi-gera-log("Emitente: " + trim(string(tt-movto.cod-emitente)) +
                                " SÇrie: " + tt-movto.serie  +
                                " NF: "  + tt-movto.nr-nota  +
                                " Natur. Oper.: " + tt-movto.nat-operacao + " - " + 
                                "Documento N∂O importado RE1001",
                                1).
                return "NOK".
            end.
        end. /* trans */
    end. /* tt-movto */
end procedure. /* pi-gera-docum-est */

procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    if tt-param.arquivo <> "" then do:    
        put unformatted
            int_dp_nota_devolucao.ndv_cnpjfilialorigem_s + "/" + 
            c-num-nota + "/" + 
            c-num-cup + "/" +
            string(int_dp_nota_devolucao.ndv_dataemissao_d,"99/99/9999") + " - " +
            c-informacao
            skip.
    end.
    if i-situacao = 1 then l-erro = yes.

    RUN intprg/int999.p ("DEV PROC", 
                         int_dp_nota_devolucao.ndv_cnpjfilialorigem_s + "/" + 
                         c-num-nota + "/" + 
                         c-num-cup + "/" + 
                         string(int_dp_nota_devolucao.ndv_dataemissao_d,"99/99/9999"),
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario,
                         "int227rp.p").
end.

procedure pi-gera-tt-fat-devol:

    i-parcela = 0.
    for each int_dp_nota_devolucao_cond no-lock of int_dp_nota_devolucao
        on error undo, return error:

        assign  i-cod-port-ori   = 0 
                i-modalid-ori    = 0 
                c-modo-devolucao = ""
                c-cod-esp-dev    = "".


        for each int_ds_loja_cond_pag no-lock where 
            int_ds_loja_cond_pag.CONDIPAG = trim(string(int(int_dp_nota_devolucao_cond.ndc_condipag_s),">>99")):
            assign c-cod-esp-dev  = int_ds_loja_cond_pag.COD_ESP
                   i-cod-port-ori = int_ds_loja_cond_pag.COD_PORTADOR
                   i-modalid-ori  = int_ds_loja_cond_pag.MODALIDADE.

            for first cst_cond_pagto no-lock where 
                cst_cond_pagto.cod_cond_pag = int_ds_loja_cond_pag.COD_COND_PAG:

                c-modo-devolucao = cst_cond_pagto.modo_devolucao.
            end.
        end.

        if c-cod-esp-dev = "" then do:

            RUN pi-gera-log("N∆o encontrado portador para condiá∆o de pagamento: " + trim(int_dp_nota_devolucao_cond.ndc_condipag_s) +
                            " SÇrie: " + tt-movto.serie        +
                            " NF: "  + tt-movto.nr-nota-fis    +
                            " Natur. Oper.: " + tt-movto.nat-operacao + 
                            " Estab.: " + tt-movto.cod-estabel,
                            1).
            return.

        end.
        
        /* converter espÇcie para dinhairo quando cÔredito ou dÇbito e n∆o for PBMs */
        if (c-cod-esp-dev = "CC" or 
            c-cod-esp-dev = "CD") and 
            i-cod-port-ori <> 91101 and /* vidalink */
            i-cod-port-ori <> 91201 and /* epharma */
            i-cod-port-ori <> 91401     /* funcional card */
        then do:
            assign c-cod-esp-dev    = "DI"
                   i-cod-port-ori   = 99901
                   i-modalid-ori    = 6
                   c-modo-devolucao = "Dinheiro"
                   l-aux            = yes.
        end.
        else do:
            /* verifica se existe duplicata com a espÇcie devolvida */
            l-aux = no.
            for each fat-duplic no-lock where
                     fat-duplic.cod-estabel  = tt-movto.cod-estab-comp and
                     fat-duplic.serie        = tt-movto.serie-comp    and
                     fat-duplic.nr-fatura    = tt-movto.nro-comp      and
                     fat-duplic.cod-esp      = c-cod-esp-dev,
               first cst_fat_duplic no-lock
               WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
                 AND cst_fat_duplic.serie       = fat-duplic.serie
                 AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
                 AND cst_fat_duplic.parcela     = fat-duplic.parcela:

                i-cod-port-ori = cst_fat_duplic.cod_portador.
                i-modalid-ori  = cst_fat_duplic.modalidade.

                for first cst_cond_pagto no-lock where 
                    cst_cond_pagto.cod_cond_pag = cst_fat_duplic.cod_cond_pag:

                    c-modo-devolucao = cst_cond_pagto.modo_devolucao.
                end.
                l-aux = yes.
                leave.
            end.
        end.
        
        /* Tratativa feito para devoluá∆o de convenio ap¢s fechamento da fatura */ 
        IF c-cod-esp-dev    = "DI"   AND     
           i-cod-port-ori   = 99901  AND       
           i-modalid-ori    = 6      AND      
           c-modo-devolucao = "Dinheiro" 
            THEN ASSIGN l-aux = YES.

        if not l-aux then do:

            RUN pi-gera-log("N∆o encontrada duplicata cupom origem p/ cond. de pagamento: " + trim(int_dp_nota_devolucao_cond.ndc_condipag_s) +
                            " Estab.: " + tt-movto.cod-estabel +
                            " SÇrie: "  + tt-movto.serie       +
                            " NF: "     + tt-movto.nr-nota-fis +
                            " Esp.: "   + c-cod-esp-dev,
                            1).
            return.
        end.

        i-parcela = i-parcela + 1.
        create  tt-cst_fat_devol.
        assign  tt-cst_fat_devol.cod_estabel    = tt-movto.cod-estabel
                tt-cst_fat_devol.serie_docto    = tt-movto.serie
                tt-cst_fat_devol.nro_docto      = tt-movto.nr-nota-fis
                tt-cst_fat_devol.cod_emitente   = tt-movto.cod-emitente
                tt-cst_fat_devol.nat_operacao   = tt-movto.nat-operacao
                tt-cst_fat_devol.cod_esp        = c-cod-esp-dev
                tt-cst_fat_devol.parcela        = trim(string(i-parcela))
                tt-cst_fat_devol.vl_devolucao   = int_dp_nota_devolucao_cond.ndc_valor_n
                tt-cst_fat_devol.dt_vencto      = tt-movto.dt-emissao
                tt-cst_fat_devol.cod_portador   = i-cod-port-ori
                tt-cst_fat_devol.modalidade     = i-modalid-ori
                tt-cst_fat_devol.modo_devolucao = c-modo-devolucao
                tt-cst_fat_devol.serie_comp     = tt-movto.serie-comp
                tt-cst_fat_devol.nro_comp       = tt-movto.nro-comp
                tt-cst_fat_devol.numero_dev     = trim(string(int(tt-movto.nr-nota-fis),">>999999"))
                tt-cst_fat_devol.cod_estab_comp = tt-movto.cod-estab-comp.


    end. /* int_dp_nota_devolucao_condpagto */

    if i-parcela = 0 then return "NOK".
    return "OK".
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

procedure pi-cria-tt-docto.

    run pi-acompanhar in h-acomp (input "Criando Docto:" +
                                  c-cod-estab-dev + "/" + 
                                  c-serie-nota + "/" + 
                                  c-num-nota).
    
    create tt-docto.
    assign tt-docto.fat-nota         = if int_dp_nota_devolucao.tipo_movto <> 3
                                       then 1 /* NFF */ else 2 /* nota */
           tt-docto.ind-tip-nota     = 11    /* Importada */
           tt-docto.nr-prog          = 2015
           tt-docto.seq-tt-docto     = 1
           tt-docto.cod-des-merc     = 2 /* consumo */
           tt-docto.cod-estabel      = c-cod-estab-dev
           tt-docto.dt-nf-ent-fut    = ?
           tt-docto.nat-operacao     = c-nat-operacao
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.nr-nota          = c-num-nota
           tt-docto.serie            = c-serie-nota
           tt-docto.cgc              = c-cpf
           tt-docto.ins-estadual     = c-ins-estadual
           tt-docto.nome-abrev       = c-nome-abrev
           tt-docto.tip-cob-desp     = i-tip-cob-desp.

    assign tt-docto.estado           = c-estado-dev
           tt-docto.cep              = c-cep
           tt-docto.pais             = c-pais
           tt-docto.endereco         = c-endereco
           tt-docto.bairro           = c-bairro
           tt-docto.cidade           = c-cidade.
           
    assign tt-docto.perc-embalagem   = 0
           tt-docto.perc-frete       = 0
           tt-docto.perc-desco1      = 0
           tt-docto.perc-desco2      = 0
           tt-docto.perc-seguro      = 0

           tt-docto.cod-canal-venda  = 0
           tt-docto.cidade-cif       = ""
           tt-docto.cod-cond-pag     = 0
           tt-docto.cod-entrega      = "Padr∆o"
           tt-docto.dt-emis-nota     = int_dp_nota_devolucao.ndv_dataemissao_d
           tt-docto.dt-base-dup      = tt-docto.dt-emis-nota
           tt-docto.dt-prvenc        = tt-docto.dt-emis-nota
           tt-docto.dt-cancela       = if int_dp_nota_devolucao.tipo_movto = 3 
                                       then int_dp_nota_devolucao.ndv_datacancelamento_d else ?
           tt-docto.marca-volume     = ""
           tt-docto.mo-codigo        = 0
           tt-docto.no-ab-reppri     = c-nome-repres
           tt-docto.nome-tr-red      = ""
           tt-docto.nome-transp      = ""
           tt-docto.nr-fatura        = tt-docto.nr-nota
           tt-docto.nr-tabpre        = ""
           tt-docto.nr-volumes       = ""
           tt-docto.placa            = ""
           tt-docto.serie-ent-fut    = ""
           tt-docto.nr-nota-ent-fut  = ""
           tt-docto.ind-lib-nota     = yes
           tt-docto.cod-rota         = ""
           tt-docto.cod-msg          = i-cod-mensagem
           tt-docto.vl-taxa-exp      = 0
           tt-docto.nr-proc-exp      = ""
           tt-docto.nr-tab-finan     = i-tab-finan
           tt-docto.nr-ind-finan     = i-indice
           tt-docto.cod-portador     = i-cod-portador
           tt-docto.modalidade       = i-modalidade
           tt-docto.nr-nota-base     = ""
           tt-docto.serie-base       = ""
           tt-docto.dt-embarque      = ?
           tt-docto.serie-dif        = ""
           tt-docto.nr-nota-dif      = ""
           tt-docto.perc-acres-dif   = 0
           tt-docto.vl-acres-dif     = 0
           tt-docto.vl-taxa-exp-dif  = 0
           tt-docto.cond-redespa     = ""
           tt-docto.obs              = TrataNuloChar(int_dp_nota_devolucao.ndv_observacao_s)
           tt-docto.esp-docto        = i-esp-docto
           tt-docto.motvo-cance      = if int_dp_nota_devolucao.tipo_movto = 3 then "Cancelada Procfit" else ""
           tt-docto.nr-pedcli        = "".

    assign tt-docto.vl-mercad        = TrataNuloDec(int_dp_nota_devolucao.ndv_valortotalprodutos_n).

    if int_dp_nota_devolucao.ndv_chaveacesso_s  /* chave acesso */ <> ? then do:
        assign overlay(tt-docto.char-1,112,60) = TrataNuloChar(OnlyNumbers(int_dp_nota_devolucao.ndv_chaveacesso_s))  /* chave acesso */
               overlay(tt-docto.char-1,172,2)  = if int_dp_nota_devolucao.tipo_movto <> 3 then "3" else "6" /* situacao */.
    end.               

    if int_dp_nota_devolucao.ndv_tipoambientenfe_n /* tipo transmissao*/  <> ? then 
        assign overlay(tt-docto.char-1,174,1)  = TrataNuloChar(string(int_dp_nota_devolucao.ndv_tipoambientenfe_n)) /* tipo transmissao*/.

    if int_dp_nota_devolucao.ndv_protocolonfe_s /* protocolo */ <> ? then
           assign overlay(tt-docto.char-1,175,15) = int_dp_nota_devolucao.ndv_protocolonfe_s. /* protocolo */.

    /*Modalidade de Frete */
    assign overlay(tt-docto.char-1,190,8) = "9".
    /*Fim Modalidade de Frete*/			     

    create  tt-nota-fiscal-adc.
    assign  tt-nota-fiscal-adc.cod-estabel              = c-cod-estab-dev
            tt-nota-fiscal-adc.serie                    = c-serie-nota
            tt-nota-fiscal-adc.nr-nota-fis              = c-num-nota
            tt-nota-fiscal-adc.cod-model-ecf            = ""
            tt-nota-fiscal-adc.cod-fabricc-ecf          = ""
            tt-nota-fiscal-adc.cod-cx-ecf               = ""
            tt-nota-fiscal-adc.cod-docto-referado       = c-num-cup
            tt-nota-fiscal-adc.cdn-emit-docto-referado  = i-cod-emitente
            tt-nota-fiscal-adc.cod-ser-docto-referado   = c-serie-cup
            tt-nota-fiscal-adc.idi-tip-dado             = 3
            tt-nota-fiscal-adc.cod-model-docto-referado = "1"
            tt-nota-fiscal-adc.idi-tip-docto-referado   = 1
            tt-nota-fiscal-adc.idi-tip-emit-referado    = 1
            tt-nota-fiscal-adc.dat-docto-referado       = d-dt-nf-orig.

    if  tt-nota-fiscal-adc.cod-ser-docto-referado = ""  or
        tt-nota-fiscal-adc.cod-docto-referado-ecf = "" then do:
        run pi-gera-log (input "Nota origem devolucao nao informada: " 
                         + "Est: "       + c-cod-estab-dev
                         + " SÇrie: "    + c-serie-nota
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.
end.

procedure pi-cria-tt-it-docto.

   define var i-cd-trib-ipi as integer no-undo.
   define var i-cd-trib-icm as integer no-undo.

   run pi-acompanhar in h-acomp (input "Criando Itens: " + c-it-codigo).

   if not avail natur-oper then
       find natur-oper no-lock where natur-oper.nat-operacao = c-nat-operacao no-error.

   if not avail item then
       find item no-lock where item.it-codigo = c-it-codigo no-error.


   /*assign i-cd-trib-icm = natur-oper.cd-trib-icm.*/
   case int_dp_nota_devolucao_item.ndp_cstb_icms_n:
       when 00 then i-cd-trib-icm = 1 /* tributado */.
       when 10 then i-cd-trib-icm = 1 /* tributado */.
       when 20 then i-cd-trib-icm = 4 /* reduzido */ .
       when 30 then i-cd-trib-icm = 2 /* isento */   .
       when 40 then i-cd-trib-icm = 2 /* isento */   .
       when 41 then i-cd-trib-icm = 2 /* isento */   .
       when 50 then i-cd-trib-icm = 3 /* outros */   .
       when 60 then i-cd-trib-icm = 1 /* tributado */.
       when 70 then i-cd-trib-icm = 4 /* reduzido */ .
       when 90 then i-cd-trib-icm = 3 /* outros */   .
       otherwise i-cd-trib-icm = 3 /* outros */ .
   end.
   case int_dp_nota_devolucao_item.ndp_cstbIPI_n:
       when 00 then i-cd-trib-ipi = 3 /*1*/ /* Entrada com Recuperaá∆o de CrÇdito */.
       when 01 then i-cd-trib-ipi = 3 /*1*/ /* Entrada com Recuperaá∆o de CrÇdito */.
       when 02 then i-cd-trib-ipi = 2 /* Entrada Isenta */   .
       when 03 then i-cd-trib-ipi = 2 /* Entrada Isenta */ .
       when 04 then i-cd-trib-ipi = 2 /* Entrada Isenta */   .
       when 05 then i-cd-trib-ipi = 3 /* Entrada com Suspens∆o */   .
       when 49 then i-cd-trib-ipi = 3 /* outros */   .
       otherwise i-cd-trib-ipi = 3 /* outros */ .
   end.
   /*assign i-cd-trib-ipi = 3 /* outros */.*/

   create tt-it-docto.
   assign tt-it-docto.calcula             = yes
          tt-it-docto.tipo-atend          = 1   /* Total */
          tt-it-docto.seq-tt-it-docto     = int_dp_nota_devolucao_item.ndp_sequencia_n
          tt-it-docto.baixa-estoq         = /*if int_dp_nota_devolucao.tipo-movto <> 3 then item.tipo-contr <> 4 else no*/ NO
          tt-it-docto.class-fiscal        = c-class-fiscal
          tt-it-docto.cod-estabel         = c-cod-estab-dev
          tt-it-docto.cod-refer           = ""
          tt-it-docto.it-codigo           = c-it-codigo
          /*
          tt-it-docto.data-comp           = d-dt-nf-orig
          tt-it-docto.nat-comp            = c-nat-origem
          tt-it-docto.nro-comp            = c-num-cup
          tt-it-docto.serie-comp          = c-serie-cup
          tt-it-docto.seq-comp            = int(TrataNuloDec(int_dp_nota_devolucao_item.ndp_sequenciaorigem_n))
          */
          tt-it-docto.nat-operacao        = c-nat-of
          tt-it-docto.nr-nota             = c-num-nota
          tt-it-docto.nr-sequencia        = int_dp_nota_devolucao_item.ndp_sequencia_n
          tt-it-docto.per-des-item        = 0
          tt-it-docto.peso-liq-it-inf     = 0
          tt-it-docto.peso-bru-it-inf     = 0
          tt-it-docto.peso-bru-it         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_peso_n)
          tt-it-docto.peso-liq-it         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_peso_n)
          tt-it-docto.peso-embal-it       = 0
          tt-it-docto.quantidade[1]       = TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n)
          tt-it-docto.quantidade[2]       = tt-it-docto.quantidade[1]
          tt-it-docto.serie               = c-serie-nota
          tt-it-docto.un[1]               = item.un
          tt-it-docto.un[2]               = tt-it-docto.un[1]
          tt-it-docto.vl-despes-it        = 0
          tt-it-docto.vl-embalagem        = 0
          tt-it-docto.vl-frete            = 0
          tt-it-docto.vl-seguro           = 0
          tt-it-docto.vl-merc-liq         = truncate(TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n) * TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n),2)
          tt-it-docto.vl-merc-ori         = truncate(TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n) * TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n),2)
          tt-it-docto.vl-merc-tab         = truncate(TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n) * TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n),2)
          tt-it-docto.vl-preori           = TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n)
          tt-it-docto.vl-pretab           = TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n)
          tt-it-docto.vl-preuni           = TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n)
          tt-it-docto.vl-tot-item         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_valortotalproduto_n)
          tt-it-docto.ind-imprenda        = no
          tt-it-docto.mercliq-moeda-forte = 0
          tt-it-docto.mercori-moeda-forte = 0
          tt-it-docto.merctab-moeda-forte = 0
          tt-it-docto.vl-taxa-exp         = 0
          tt-it-docto.vl-desconto         = 0
          tt-it-docto.desconto            = 0
          tt-it-docto.vl-desconto-perc    = 0
          tt-it-docto.nr-pedcli           = "".
   
   create tt-it-imposto.
   assign tt-it-imposto.seq-tt-it-docto   = int_dp_nota_devolucao_item.ndp_sequencia_n
          tt-it-imposto.aliquota-icm      = TrataNuloDec(int_dp_nota_devolucao_item.ndp_percentualicms_n)
          tt-it-imposto.aliquota-ipi      = TrataNuloDec(int_dp_nota_devolucao_item.ndp_percentualipi_n)
          tt-it-imposto.cd-trib-icm       = i-cd-trib-icm
          tt-it-imposto.cd-trib-iss       = 2 /* isento */
          tt-it-imposto.cod-servico       = 0
          tt-it-imposto.ind-icm-ret       = no
          tt-it-imposto.per-des-icms      = 0
          tt-it-imposto.perc-red-icm      = TrataNuloDec(int_dp_nota_devolucao_item.ndp_redutorbaseicms_n)
          tt-it-imposto.perc-red-iss      = 0
          tt-it-imposto.vl-bicms-ent-fut  = 0
          tt-it-imposto.vl-bicms-it       = if i-cd-trib-icm = 1 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseicms_n) else 0
          tt-it-imposto.vl-icms-it        = if i-cd-trib-icm = 1 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_valoricms_n) else 0
          tt-it-imposto.vl-icms-outras    = if i-cd-trib-icm = 3 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseicms_n) else
                                            if TrataNuloDec(int_dp_nota_devolucao_item.ndp_redutorbaseicms_n) <> 0 
                                            then TrataNuloDec(int_dp_nota_devolucao_item.ndp_valorliquido_n - int_dp_nota_devolucao_item.ndp_baseicms_n)
                                            else 0                                                                 
          tt-it-imposto.vl-icmsou-it      = tt-it-imposto.vl-icms-outras
          tt-it-imposto.vl-icmsnt-it      = if i-cd-trib-icm = 2 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseicms_n) else 0
          tt-it-imposto.cd-trib-ipi       = i-cd-trib-ipi
          tt-it-imposto.perc-red-ipi      = 0
          tt-it-imposto.vl-bipi-ent-fut   = 0
          tt-it-imposto.vl-ipi-ent-fut    = 0
          tt-it-imposto.vl-bipi-it        = if i-cd-trib-ipi = 1 or i-cd-trib-ipi = 4 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseipi_n) else 0
          tt-it-imposto.vl-ipi-it         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_valoripi_n)
          tt-it-imposto.vl-ipi-outras     = if i-cd-trib-ipi = 3 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseipi_n) else 0
          tt-it-imposto.vl-ipiou-it       = tt-it-imposto.vl-ipi-outras
          tt-it-imposto.vl-ipint-it       = if i-cd-trib-ipi = 2 then TrataNuloDec(int_dp_nota_devolucao_item.ndp_baseipi_n) else 0.

   assign tt-it-imposto.vl-biss-it        = 0
          tt-it-imposto.vl-bsubs-ent-fut  = 0
          tt-it-imposto.vl-bsubs-it       = TrataNuloDec(int_dp_nota_devolucao_item.ndp_basest_n)
          tt-it-imposto.icm-complem       = 0
          tt-it-imposto.vl-icms-ent-fut   = 0
          tt-it-imposto.vl-icmsub-ent-fut = 0
          tt-it-imposto.vl-icmsub-it      = TrataNuloDec(int_dp_nota_devolucao_item.ndp_icmsst_n)
          tt-it-imposto.aliq-icm-comp     = 0
          tt-it-imposto.aliquota-iss      = 0
          tt-it-imposto.vl-irf-it         = 0
          tt-it-imposto.vl-iss-it         = 0
          tt-it-imposto.vl-issnt-it       = 0
          tt-it-imposto.vl-issou-it       = 0
          tt-it-docto.desconto-zf         = 0
          tt-it-docto.narrativa           = TrataNuloChar(int_dp_nota_devolucao_item.ndp_lote_s).

   /*  CSTÔs */
   assign  overlay(tt-it-docto.char-1,75,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbipi_n,"99"))
           overlay(tt-it-docto.char-1,77,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbpis_s,"99"))
           overlay(tt-it-docto.char-1,79,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_cstbcofins_s,"99")).

   /* Modalidades de base */
   assign  overlay(tt-it-docto.char-1,81,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbcicms_n))
           overlay(tt-it-docto.char-1,85,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbcst_n))
           overlay(tt-it-docto.char-1,83,2)     = TrataNuloChar(string(int_dp_nota_devolucao_item.ndp_modbipi_n)).

   /* Tributaá∆o PIS    */ 
   overlay(tt-it-docto.char-2,96,1) = if int_dp_nota_devolucao_item.ndp_valorpis_n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,76,5) = string(TrataNuloDec(int_dp_nota_devolucao_item.ndp_percentualpis_n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,76,5)) = 0 then
       overlay(tt-it-docto.char-2,96,1) = "2".

   /* Tributaá∆o COFINS */
   overlay(tt-it-docto.char-2,97,1) = if int_dp_nota_devolucao_item.ndp_valorcofins_n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,81,5) = string(TrataNuloDec(int_dp_nota_devolucao_item.ndp_percentualcofins_n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,81,5)) = 0 then 
       overlay(tt-it-docto.char-2,97,1) = "2" .

   overlay(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
   overlay(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".

   /* Unidade de Negocio */
   assign overlay(tt-it-docto.char-2,172,03) = "000"
          tt-it-imposto.vl-pauta             = 0.


   /* somar o peso dos itens ....*/
   for each tt-docto where
       tt-docto.cod-estabel = tt-it-docto.cod-estabel and
       tt-docto.serie       = tt-it-docto.serie and
       tt-docto.nr-nota     = tt-it-docto.nr-nota
       query-tuning(no-lookahead):
       assign   tt-docto.peso-bru-tot     = tt-docto.peso-bru-tot + int_dp_nota_devolucao_item.ndp_peso_n
                tt-docto.peso-liq-tot     = tt-docto.peso-bru-tot
                tt-docto.vl-embalagem     = 0
                tt-docto.vl-frete         = 0
                tt-docto.vl-seguro        = 0.
   end.

   if  item.tipo-contr <> 4 /* debito direto */ and int_dp_nota_devolucao.tipo_movto <> 3 /* cancelamento */ and
       tt-it-docto.baixa-estoq then do:
       if item.tipo-con-est = 3 /* lote */ then
       for first saldo-estoq fields (dt-vali-lote) no-lock where 
           saldo-estoq.cod-estabel = c-cod-estab-dev and
           saldo-estoq.cod-depos   = "LOJ" and
           saldo-estoq.cod-localiz = "" and
           saldo-estoq.cod-refer   = "" and
           saldo-estoq.it-codigo   = c-it-codigo and
           saldo-estoq.lote        = int_dp_nota_devolucao_item.ndp_lote_s
           query-tuning(no-lookahead):
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = int_dp_nota_devolucao_item.ndp_sequencia_n
                  tt-saldo-estoq.seq-tt-it-docto    = int_dp_nota_devolucao_item.ndp_sequencia_n
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = TrataNuloChar(int_dp_nota_devolucao_item.ndp_lote_s)
                  tt-saldo-estoq.dt-vali-lote       = saldo-estoq.dt-vali-lote
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n).
       end.
       if not avail saldo-estoq /*and l-saldo-neg avb 18/09/2017 */ then do:
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = int_dp_nota_devolucao_item.ndp_sequencia_n
                  tt-saldo-estoq.seq-tt-it-docto    = int_dp_nota_devolucao_item.ndp_sequencia_n
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = if item.tipo-con-est = 3 /* lote */ then int_dp_nota_devolucao_item.ndp_lote_s else ""
                  tt-saldo-estoq.dt-vali-lote       = if item.tipo-con-est = 3 /* lote */ then today else ?
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int_dp_nota_devolucao_item.ndp_quantidade_n).
       end.
       /*************** Baixa do Estoque *************************************/
       if  tt-it-docto.baixa-estoq then do:
           for first tt-saldo-estoq no-lock where
               tt-saldo-estoq.seq-tt-saldo-estoq = int_dp_nota_devolucao_item.ndp_sequencia_n and
               tt-saldo-estoq.seq-tt-it-docto    = int_dp_nota_devolucao_item.ndp_sequencia_n and
               tt-saldo-estoq.it-codigo          = c-it-codigo  and
               tt-saldo-estoq.cod-depos          = "LOJ"        and
               tt-saldo-estoq.cod-localiz        = ""
               query-tuning(no-lookahead):            end.
           if not avail tt-saldo-estoq then do:
               return.
           end.
       end.
   end.
end.

