/***********************************************************************************
** Programa: INT227 - Importaá∆o de NF Devoluá‰es Cupom do PROCFIT
**
** Versao : 12 - 19/03/2018 - Alessandro V Baccin
**
************************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i INT227RP 2.12.06.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* definiá∆o das temp-tables para recebimento de parÉmetros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

/* temp-tables das API's e BO's */
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

{method/dbotterr.i}

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

/* recebimento de parÉmetros */
def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT227.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
def var h-aux               as handle no-undo.
def var h-acomp             as handle no-undo.
def var l-erro              as logical no-undo.
def var l-servico           as logical no-undo.
def var r-rowid             as rowid no-undo.
def var c-nat-operacao      as char no-undo.
def var c-nat-entrada       as char no-undo.
def var c-nat-origem        as char no-undo.
def var c-nat-comp          as char no-undo.
def var c-cod-estabel       as char no-undo.
def var c-cod-esp-princ     as char no-undo.
def var c-nome-abrev        as char no-undo.
def var c-ins-estadual      as char no-undo.
def var c-bairro            like estabelec.bairro no-undo.
def var c-cidade            like estabelec.cidade no-undo.
def var c-pais              like estabelec.pais no-undo.
def var c-endereco          like estabelec.endereco no-undo.
def var i-ep-codigo         like estabelec.ep-codigo no-undo.
def var c-cep               as char no-undo.
def var c-uf-origem         as char no-undo.
def var c-uf-destino        as char no-undo.
def var c-nome-repres       as char no-undo.
def var c-aux               as char no-undo.
def var c-nome-transp       as char no-undo.
def var c-num-nota          as char no-undo.
def var i-cod-emitente      as integer no-undo.
def var i-cod-mensagem      as integer no-undo.
def var i-tab-finan         as integer no-undo.
def var i-indice            as integer no-undo.
def var i-cod-portador      as integer no-undo.
def var i-modalidade        as integer no-undo.
def var de-red-base-ipi     as decimal no-undo.
def var de-base-ipi         as decimal no-undo.
def var i-nr-sequencia      as integer no-undo.
def var i-cod-rep           as integer no-undo.
def var i-cfop              as integer no-undo.
def var i-cst               as integer no-undo.
def var i-tip-cob-desp      as integer no-undo.
def var i-esp-docto         as integer no-undo.
def var d-dt-comp           as date    no-undo.
def var d-dt-procfit        as date    no-undo.

def buffer bint-dp-nota-devolucao for int-dp-nota-devolucao.

def var de-tot-despesas as decimal decimals 4 no-undo.

/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i /*&stream = "stream str-rp"*/}
END.

assign c-programa     = "INT227"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Importacao Devoluá∆o Cupom Procfit".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.


/******* LE NOTA E GERA TEMP TABLES  *************/
for-nota:
for each int-dp-nota-devolucao no-lock where 
    int-dp-nota-devolucao.situacao = 1
    query-tuning(no-lookahead):

    assign c-num-nota = trim(string(int-dp-nota-devolucao.ndv-notafiscal-n,">>>9999999")).
    assign l-erro = no.
    run pi-elimina-tabelas.

    run pi-acompanhar in h-acomp (input "Validando Nota:" + 
                                  int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s + "/" + 
                                  int-dp-nota-devolucao.ndv-serie-s + "/" + 
                                  string(int-dp-nota-devolucao.ndv-notafiscal-n)).

    RUN pi-valida-cabecalho.
    if l-erro then next for-nota.
    run pi-acompanhar in h-acomp (input "Validando Nota:" + 
                                  c-cod-estabel + "/" + 
                                  int-dp-nota-devolucao.ndv-serie-s + "/" + 
                                  c-num-nota).

    i-nr-sequencia = 0.
    for each int-dp-nota-devolucao-item no-lock where
        int-dp-nota-devolucao-item.ndv-cnpjfilialdevolucao-s = int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s and
        int-dp-nota-devolucao-item.ndv-serie-s               = int-dp-nota-devolucao.ndv-serie-s       and
        int-dp-nota-devolucao-item.ndv-notafiscal-n          = int-dp-nota-devolucao.ndv-notafiscal-n
        query-tuning(no-lookahead):
        
        run pi-valida-item.
        if l-erro then next for-nota.
        RUN pi-cria-tt-it-docto.

    end. /* int-dp-nota-devolucao-item */

    if not l-erro then do:
        RUN pi-cria-tt-docto.
        if not l-erro then do:
            RUN pi-importa-nota.
            run pi-elimina-tabelas.
        end.
    end.
  /*  run pi-elimina-tabelas.*/
end. /* for-nota */

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.

RUN intprg/int888.p (INPUT "NFS",
                     INPUT "INT227RP.P").

run pi-finalizar in h-acomp.
return "OK":U.

/* procedures internas */
procedure pi-cria-tt-docto.

    run pi-acompanhar in h-acomp (input "Criando Docto:" +
                                  c-cod-estabel + "/" + 
                                  int-dp-nota-devolucao.ndv-serie-s + "/" + 
                                  c-num-nota).
    
    create tt-docto.
    assign tt-docto.fat-nota         = if int-dp-nota-devolucao.tipo-movto <> 3
                                       then 1 /* NFF */ else 2 /* nota */
           tt-docto.ind-tip-nota     = 11     /* Importada */
           tt-docto.nr-prog          = 2015
           tt-docto.seq-tt-docto     = 1
           tt-docto.cod-des-merc     = 2 /* consumo */
           tt-docto.cod-estabel      = c-cod-estabel
           tt-docto.dt-nf-ent-fut    = ?
           tt-docto.nat-operacao     = c-nat-operacao
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.nr-nota          = c-num-nota
           tt-docto.serie            = int-dp-nota-devolucao.ndv-serie-s
           tt-docto.cgc              = int-dp-nota-devolucao.ndv-cpf-cliente
           tt-docto.ins-estadual     = c-ins-estadual
           tt-docto.nome-abrev       = c-nome-abrev
           tt-docto.tip-cob-desp     = i-tip-cob-desp.

    assign tt-docto.estado           = c-uf-destino
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
           tt-docto.dt-base-dup      = int-dp-nota-devolucao.ndv-dataemissao-d
           tt-docto.dt-emis-nota     = tt-docto.dt-base-dup
           tt-docto.dt-prvenc        = tt-docto.dt-base-dup
           tt-docto.dt-cancela       = if int-dp-nota-devolucao.tipo-movto = 3 then tt-docto.dt-base-dup else ?
           tt-docto.marca-volume     = ""
           tt-docto.mo-codigo        = 0
           tt-docto.no-ab-reppri     = c-nome-repres
           tt-docto.nome-tr-red      = ""
           tt-docto.nome-transp      = c-nome-transp
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
           tt-docto.obs              = TrataNuloChar(int-dp-nota-devolucao.ndv-observacao-s)
           tt-docto.esp-docto        = i-esp-docto
           tt-docto.motvo-cance      = if int-dp-nota-devolucao.tipo-movto = 3 then "Cancelada Procfit" else ""
           tt-docto.nr-pedcli        = /*TrataNuloChar(string(int-dp-nota-devolucao.ped-codigo-n))*/ "".

    assign tt-docto.vl-mercad        = TrataNuloDec(int-dp-nota-devolucao.ndv-valortotalprodutos-n).

    if int-dp-nota-devolucao.ndv-chaveacesso-s  /* chave acesso */ <> ? then do:
        assign overlay(tt-docto.char-1,112,60) = TrataNuloChar(replace(replace(int-dp-nota-devolucao.ndv-chaveacesso-s,'NFe',''),'CFe',''))  /* chave acesso */
               overlay(tt-docto.char-1,172,2)  = if int-dp-nota-devolucao.tipo-movto <> 3 then "3" else "6" /* situacao */.
    end.               


    /* criar........
    if int-dp-nota-devolucao.ndv-transmissao-s /* tipo transmissao*/  <> ? then 
        assign overlay(tt-docto.char-1,174,1)  = TrataNuloChar(string(int-dp-nota-devolucao.ndv-tipoambientenfe-n)) /* tipo transmissao*/.

    if int-dp-nota-devolucao.ndv-protocolonfe-s /* protocolo */ <> ? then
           assign overlay(tt-docto.char-1,175,15) = int-dp-nota-devolucao.ndv-protocolonfe-s. /* protocolo */.
     */


    /*Modalidade de Frete */
    assign overlay(tt-docto.char-1,190,8) = "9".
    /*Fim Modalidade de Frete*/			     

    create  tt-nota-fiscal-adc.
    assign  tt-nota-fiscal-adc.cod-estabel              = c-cod-estabel
            tt-nota-fiscal-adc.serie                    = int-dp-nota-devolucao.ndv-serie-s
            tt-nota-fiscal-adc.nr-nota-fis              = c-num-nota
            tt-nota-fiscal-adc.cod-model-ecf            = ""
            tt-nota-fiscal-adc.cod-fabricc-ecf          = ""
            tt-nota-fiscal-adc.cod-cx-ecf               = ""
            tt-nota-fiscal-adc.cod-docto-referado       = TrataNuloChar(string(int-dp-nota-devolucao.ndv-notaorigem-n,">>>9999999"))
            tt-nota-fiscal-adc.cdn-emit-docto-referado  = i-cod-emitente
            tt-nota-fiscal-adc.dat-docto-referado       = 01/01/2016
            tt-nota-fiscal-adc.cod-ser-docto-referado   = string(int-dp-nota-devolucao.ndv-serieorigem-s)
            tt-nota-fiscal-adc.idi-tip-dado             = 3
            tt-nota-fiscal-adc.cod-model-docto-referado = "1"
            tt-nota-fiscal-adc.idi-tip-docto-referado   = 1
            tt-nota-fiscal-adc.idi-tip-emit-referado    = 1
            tt-nota-fiscal-adc.dat-docto-referado       = d-dt-comp.

    if  tt-nota-fiscal-adc.cod-ser-docto-referado = ""  or
        tt-nota-fiscal-adc.cod-docto-referado-ecf = "" then do:
        run pi-gera-log (input "Nota origem devolucao nao informada: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.
end.

procedure pi-cria-tt-it-docto.

   define var i-cd-trib-ipi as integer no-undo.
   define var i-cd-trib-icm as integer no-undo.

   run pi-acompanhar in h-acomp (input "Criando Itens: " + trim(string(int-dp-nota-devolucao-item.ndp-produto-n))).

   if not avail natur-oper then
       find natur-oper no-lock where natur-oper.nat-operacao = c-nat-operacao no-error.

   if not avail item then
       find item no-lock where item.it-codigo = trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) no-error.


   /*assign i-cd-trib-icm = natur-oper.cd-trib-icm.*/
   case int-dp-nota-devolucao-item.ndp-cstb-icms-n:
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

   assign i-cd-trib-ipi = natur-oper.cd-trib-ipi.
   /*
   case int-dp-nota-devolucao-item....
       when 00 then i-cd-trib-ipi = 3 /*1*/ /* Entrada com Recuperaá∆o de CrÇdito */.
       when 01 then i-cd-trib-ipi = 3 /*1*/ /* Entrada com Recuperaá∆o de CrÇdito */.
       when 02 then i-cd-trib-ipi = 2 /* Entrada Isenta */   .
       when 03 then i-cd-trib-ipi = 2 /* Entrada Isenta */ .
       when 04 then i-cd-trib-ipi = 2 /* Entrada Isenta */   .
       when 05 then i-cd-trib-ipi = 3 /* Entrada com Suspens∆o */   .
       when 49 then i-cd-trib-ipi = 3 /* outros */   .
       otherwise i-cd-trib-ipi = 3 /* outros */ .
   end.
   */
   assign i-cd-trib-ipi = 3 /* outros */.

   /*
   if i-cd-trib-icm <> 2 /* Isento */ and 
      i-cd-trib-icm <> 3 /* Outros */ then
        if item.cd-trib-icm = 1 /* tributado */ or  
           item.cd-trib-icm = 4 /* reduzido */ then
            assign i-cd-trib-icm = item.cd-trib-icm.*/

   i-nr-sequencia = i-nr-sequencia + 1.

   create tt-it-docto.
   assign tt-it-docto.calcula             = yes
          tt-it-docto.tipo-atend          = 1   /* Total */
          tt-it-docto.seq-tt-it-docto     = i-nr-sequencia
          tt-it-docto.baixa-estoq         = if int-dp-nota-devolucao.tipo-movto <> 3 then item.tipo-contr <> 4 else no
          tt-it-docto.class-fiscal        = TrataNuloChar(replace(int-dp-nota-devolucao-item.ndp-ncm-s,".",""))
          tt-it-docto.cod-estabel         = c-cod-estabel
          tt-it-docto.cod-refer           = ""
          tt-it-docto.data-comp           = d-dt-comp
          tt-it-docto.it-codigo           = trim(string(int-dp-nota-devolucao-item.ndp-produto-n))
          tt-it-docto.nat-comp            = c-nat-comp
          tt-it-docto.nro-comp            = if int-dp-nota-devolucao.ndv-notaorigem-n <> ?
                                            then TrataNuloChar(string(int-dp-nota-devolucao.ndv-notaorigem-n,">>>9999999")) else ""
          tt-it-docto.serie-comp          = if TrataNuloChar(int-dp-nota-devolucao.ndv-serieorigem-s) = "" 
                                            then TrataNuloChar(int-dp-nota-devolucao.ndv-serieorigem-s) else ""
          tt-it-docto.seq-comp            = if int-dp-nota-devolucao-item.ndp-sequenciaorigem-n <> ?
                                            then TrataNuloDec(int-dp-nota-devolucao-item.ndp-sequenciaorigem-n) else 0
          tt-it-docto.nat-operacao        = c-nat-operacao
          tt-it-docto.nr-nota             = c-num-nota
          tt-it-docto.nr-sequencia        = if int-dp-nota-devolucao-item.ndp-sequencia-n <> ? 
                                            then int-dp-nota-devolucao-item.ndp-sequencia-n else i-nr-sequencia
          tt-it-docto.per-des-item        = 0
          tt-it-docto.peso-liq-it-inf     = 0
          tt-it-docto.peso-bru-it-inf     = 0
          tt-it-docto.peso-bru-it         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-peso-n)
          tt-it-docto.peso-liq-it         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-peso-n)
          tt-it-docto.peso-embal-it       = 0
          tt-it-docto.quantidade[1]       = TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n)
          tt-it-docto.quantidade[2]       = tt-it-docto.quantidade[1]
          tt-it-docto.serie               = int-dp-nota-devolucao-item.ndv-serie-s
          tt-it-docto.un[1]               = item.un
          tt-it-docto.un[2]               = tt-it-docto.un[1]
          tt-it-docto.vl-despes-it        = 0
          tt-it-docto.vl-embalagem        = 0
          tt-it-docto.vl-frete            = 0
          tt-it-docto.vl-seguro           = 0
          tt-it-docto.vl-merc-liq         = truncate(TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n) * TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n),2)
          tt-it-docto.vl-merc-ori         = truncate(TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n) * TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n),2)
          tt-it-docto.vl-merc-tab         = truncate(TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n) * TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n),2)
          tt-it-docto.vl-preori           = TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n)
          tt-it-docto.vl-pretab           = TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n)
          tt-it-docto.vl-preuni           = TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n)
          tt-it-docto.vl-tot-item         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-valortotalproduto-n)
          tt-it-docto.ind-imprenda        = no
          tt-it-docto.mercliq-moeda-forte = 0
          tt-it-docto.mercori-moeda-forte = 0
          tt-it-docto.merctab-moeda-forte = 0
          tt-it-docto.vl-taxa-exp         = 0
          tt-it-docto.vl-desconto         = 0
          tt-it-docto.desconto            = 0
          tt-it-docto.vl-desconto-perc    = 0
          tt-it-docto.nr-pedcli           = /*TrataNuloChar(string(int-dp-nota-devolucao.ped-codigo-n))*/ "".
   
   create tt-it-imposto.
   assign tt-it-imposto.seq-tt-it-docto   = i-nr-sequencia
          tt-it-imposto.aliquota-icm      = TrataNuloDec(int-dp-nota-devolucao-item.ndp-percentualicms-n)
          tt-it-imposto.aliquota-ipi      = TrataNuloDec(int-dp-nota-devolucao-item.ndp-percentualipi-n)
          tt-it-imposto.cd-trib-icm       = i-cd-trib-icm
          tt-it-imposto.cd-trib-iss       = 2 /* isento */
          tt-it-imposto.cod-servico       = 0
          tt-it-imposto.ind-icm-ret       = no
          tt-it-imposto.per-des-icms      = 0
          tt-it-imposto.perc-red-icm      = TrataNuloDec(int-dp-nota-devolucao-item.ndp-redutorbaseicms-n)
          tt-it-imposto.perc-red-iss      = 0
          tt-it-imposto.vl-bicms-ent-fut  = 0
          tt-it-imposto.vl-bicms-it       = if i-cd-trib-icm = 1 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseicms-n) else 0
          tt-it-imposto.vl-icms-it        = if i-cd-trib-icm = 1 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-valoricms-n) else 0
          tt-it-imposto.vl-icms-outras    = if i-cd-trib-icm = 3 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseicms-n) else
                                            if TrataNuloDec(int-dp-nota-devolucao-item.ndp-redutorbaseicms-n) <> 0 
                                            then TrataNuloDec(int-dp-nota-devolucao-item.ndp-valorliquido-n - int-dp-nota-devolucao-item.ndp-baseicms-n)
                                            else 0                                                                 
          tt-it-imposto.vl-icmsou-it      = tt-it-imposto.vl-icms-outras
          tt-it-imposto.vl-icmsnt-it      = if i-cd-trib-icm = 2 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseicms-n) else 0
          tt-it-imposto.cd-trib-ipi       = i-cd-trib-ipi
          tt-it-imposto.perc-red-ipi      = 0
          tt-it-imposto.vl-bipi-ent-fut   = 0
          tt-it-imposto.vl-ipi-ent-fut    = 0
          tt-it-imposto.vl-bipi-it        = if i-cd-trib-ipi = 1 or i-cd-trib-ipi = 4 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseipi-n) else 0
          tt-it-imposto.vl-ipi-it         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-valoripi-n)
          tt-it-imposto.vl-ipi-outras     = if i-cd-trib-ipi = 3 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseipi-n) else 0
          tt-it-imposto.vl-ipiou-it       = tt-it-imposto.vl-ipi-outras
          tt-it-imposto.vl-ipint-it       = if i-cd-trib-ipi = 2 then TrataNuloDec(int-dp-nota-devolucao-item.ndp-baseipi-n) else 0.

   assign tt-it-imposto.vl-biss-it        = 0
          tt-it-imposto.vl-bsubs-ent-fut  = 0
          tt-it-imposto.vl-bsubs-it       = TrataNuloDec(int-dp-nota-devolucao-item.ndp-basest-n)
          tt-it-imposto.icm-complem       = 0
          tt-it-imposto.vl-icms-ent-fut   = 0
          tt-it-imposto.vl-icmsub-ent-fut = 0
          tt-it-imposto.vl-icmsub-it      = TrataNuloDec(int-dp-nota-devolucao-item.ndp-icmsst-n)
          tt-it-imposto.aliq-icm-comp     = 0
          tt-it-imposto.aliquota-iss      = 0
          tt-it-imposto.vl-irf-it         = 0
          tt-it-imposto.vl-iss-it         = 0
          tt-it-imposto.vl-issnt-it       = 0
          tt-it-imposto.vl-issou-it       = 0
          tt-it-docto.desconto-zf         = 0
          tt-it-docto.narrativa           = TrataNuloChar(int-dp-nota-devolucao-item.ndp-lote-s).

   /*  CSTÔs */
   assign  overlay(tt-it-docto.char-1,75,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbipi-n,"99"))
           overlay(tt-it-docto.char-1,77,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbpis-s,"99"))
           overlay(tt-it-docto.char-1,79,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbcofins-s,"99")).

   /* Modalidades de base */
   assign  overlay(tt-it-docto.char-1,81,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbcicms-n))
           overlay(tt-it-docto.char-1,85,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbcst-n))
           overlay(tt-it-docto.char-1,83,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbipi-n)).

   /* Tributaá∆o PIS    */ 
   overlay(tt-it-docto.char-2,96,1) = if int-dp-nota-devolucao-item.ndp-valorpis-n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,76,5) = string(TrataNuloDec(int-dp-nota-devolucao-item.ndp-percentualpis-n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,76,5)) = 0 then
       overlay(tt-it-docto.char-2,96,1) = "2".

   /* Tributaá∆o COFINS */
   overlay(tt-it-docto.char-2,97,1) = if int-dp-nota-devolucao-item.ndp-valorcofins-n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,81,5) = string(TrataNuloDec(int-dp-nota-devolucao-item.ndp-percentualcofins-n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,81,5)) = 0 then 
       overlay(tt-it-docto.char-2,97,1) = "2" .

   overlay(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
   overlay(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".

   /* Unidade de Negocio */
   assign overlay(tt-it-docto.char-2,172,03) = "000"
          tt-it-imposto.vl-pauta             = 0.


   /* somar o dos itens ....*/
   for each tt-docto where
       tt-docto.cod-estabel = tt-it-docto.cod-estabel and
       tt-docto.serie       = tt-it-docto.serie and
       tt-docto.nr-nota     = tt-it-docto.nr-nota:
       assign   tt-docto.peso-bru-tot     = tt-docto.peso-bru-tot + int-dp-nota-devolucao-item.ndp-peso-n
                tt-docto.peso-liq-tot     = tt-docto.peso-bru-tot
                tt-docto.vl-embalagem     = 0
                tt-docto.vl-frete         = 0
                tt-docto.vl-seguro        = 0.
   end.

   if  item.tipo-contr <> 4 /* debito direto */ and int-dp-nota-devolucao.tipo-movto <> 3 /* cancelamento */ and
       tt-it-docto.baixa-estoq then do:
       if item.tipo-con-est = 3 /* lote */ then
       for first saldo-estoq fields (dt-vali-lote) no-lock where 
           saldo-estoq.cod-estabel = c-cod-estabel and
           saldo-estoq.cod-depos   = "LOJ" and
           saldo-estoq.cod-localiz = "" and
           saldo-estoq.cod-refer   = "" and
           saldo-estoq.it-codigo   = trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) and
           saldo-estoq.lote        = int-dp-nota-devolucao-item.ndp-lote-s:
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = trim(string(int-dp-nota-devolucao-item.ndp-produto-n))
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = TrataNuloChar(int-dp-nota-devolucao-item.ndp-lote-s)
                  tt-saldo-estoq.dt-vali-lote       = saldo-estoq.dt-vali-lote
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n).
       end.
       if not avail saldo-estoq /*and l-saldo-neg avb 18/09/2017 */ then do:
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = trim(string(int-dp-nota-devolucao-item.ndp-produto-n))
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = if item.tipo-con-est = 3 /* lote */ then int-dp-nota-devolucao-item.ndp-lote-s else ""
                  tt-saldo-estoq.dt-vali-lote       = if item.tipo-con-est = 3 /* lote */ then today else ?
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n).
       end.
       /*************** Baixa do Estoque *************************************/
       if  tt-it-docto.baixa-estoq then do:

           for first tt-saldo-estoq no-lock where
               tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia and
               tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia and
               tt-saldo-estoq.it-codigo          = trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) and
               tt-saldo-estoq.cod-depos          = "LOJ"          and
               tt-saldo-estoq.cod-localiz        = "":            end.
           if not avail tt-saldo-estoq then do:
               return.
           end.
       end.
   end.
end.

procedure pi-valida-cabecalho:

    if int-dp-nota-devolucao.ndv-dataemissao-d = ? then do: 
        run pi-gera-log (input "Data de emiss∆o em branco: " 
                         + "CNPJ: "      + int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s
                         + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.

    c-uf-origem = "".
    for first emitente fields (cod-emitente nome-abrev estado identific) no-lock where 
        emitente.cgc = int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s,
        first dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1: 
        c-uf-origem  = emitente.estado.
    end.
    if not avail emitente then do:
        run pi-gera-log (input "Fornecedor n∆o cadastrado ou inativo. CNPJ: " + string(int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s),
                         input 1).
    end.
    if emitente.identific = 1 then do:     /* Cliente */
        run pi-gera-log (input "Emitente do estabelecimento origem Ç cliente: " 
                         + "Est: "      + c-cod-estabel
                         + " SÇrie: "   + int-dp-nota-devolucao.ndv-serie-s 
                         + " Numero: "  + c-num-nota
                         + " Emit: "    + string(emitente.cod-emitente),
                         input 1).
        return.                                 
    end.


    c-cod-estabel = "".
    d-dt-procfit  = ?.
    i-ep-codigo   = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                    0 &else "" &endif. 
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= int-dp-nota-devolucao.ndv-dataemissao-d:
        c-cod-estabel  = estabelec.cod-estabel.
        i-ep-codigo    = estabelec.ep-codigo.
        d-dt-procfit   = cst-estabelec.dt-inicio-oper.
        leave.
    end.

    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento Devoluá∆o n∆o cadastrado ou fora de operaá∆o. CNPJ: " + int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s,
                         input 1).
        return.
    end.

    /*
    if d-dt-procfit > int-dp-nota-devolucao.ndv-dataemissao-d then do:
        run pi-gera-log (input "Estabelecimento Origem n∆o Ç Procfit na data de emiss∆o. CNPJ: " + int-dp-nota-devolucao.ndv-cnpj-destino-s + 
                               " Data: " + string(int-dp-nota-devolucao.ndv-dataemissao-d,"99/99/9999"),
                         input 1).
    end.
    */

    for each nota-fiscal no-lock where 
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = int-dp-nota-devolucao.ndv-serie-s and
        nota-fiscal.nr-nota-fis = c-num-nota:
        run pi-gera-log (input "Documento j† cadastrado: " 
                         + "Est: "      + nota-fiscal.cod-estabel
                         + " SÇrie: "   + nota-fiscal.serie 
                         + " Numero: "  + nota-fiscal.nr-nota-fis,
                         input 2).
        for each bint-dp-nota-devolucao where
            bint-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s  = int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s and
            bint-dp-nota-devolucao.ndv-serie-s        = int-dp-nota-devolucao.ndv-serie-s       and
            bint-dp-nota-devolucao.ndv-notafiscal-n   = int-dp-nota-devolucao.ndv-notafiscal-n:
            assign  bint-dp-nota-devolucao.situacao = 2 /* processada */.
            release bint-dp-nota-devolucao.
        end.
        assign l-erro = yes.
        return.
    end.

    c-uf-destino   = "".
    c-cidade       = "".
    c-bairro       = "".
    c-endereco     = "".
    c-pais         = "".
    c-cep          = "".
    i-cod-emitente = 0.
    c-ins-estadual = "".
    i-tip-cob-desp = 0.
    for first emitente 
        fields (estado       cidade       
                bairro       endereco     
                pais         cep          
                cod-emitente nome-abrev   
                cod-rep      tip-cob-desp 
                ins-estadual)
        no-lock where 
        emitente.cgc = int-dp-nota-devolucao.ndv-cpf-cliente:
        /*
        first dist-emitente no-lock of emitente where 
        dist-emitente.idi-sit-fornec = 1:*/  
        assign  c-uf-destino   = emitente.estado
                c-cidade       = emitente.cidade
                c-bairro       = emitente.bairro
                c-endereco     = emitente.endereco
                c-pais         = emitente.pais
                c-cep          = emitente.cep
                i-cod-emitente = emitente.cod-emitente
                c-nome-abrev   = emitente.nome-abrev
                i-cod-rep      = emitente.cod-rep
                i-tip-cob-desp = emitente.tip-cob-desp
                c-ins-estadual = emitente.ins-estadual.
    end.
    if not avail emitente then do:
        run pi-gera-log (input "Cliente n∆o cadastrado ou inativo. CPF: " + string(int-dp-nota-devolucao.ndv-cpf-cliente),
                         input 1).
        return.
    end.

    for first param-estoq no-lock: 
        if month (param-estoq.ult-fech-dia) = 12 then 
            assign c-aux = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
        else
            assign c-aux = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").

        if param-estoq.ult-fech-dia >= int-dp-nota-devolucao.ndv-dataemissao-d or
           param-estoq.mensal-ate >= int-dp-nota-devolucao.ndv-dataemissao-d or
          (c-aux = string(year(int-dp-nota-devolucao.ndv-dataemissao-d),"9999") + string(month(int-dp-nota-devolucao.ndv-dataemissao-d),"99") and
          (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes))
        then do:

            run pi-gera-log (input "Documento em per°odo fechado ou em fechamento. " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                             + " Numero: "   + c-num-nota
                             + " Data: "     + string(int-dp-nota-devolucao.ndv-dataemissao-d,"99/99/9999"),
                             input 1).
            return.
        end.
    end.

    for first ser-estab no-lock where
        ser-estab.serie = trim(int-dp-nota-devolucao.ndv-serie-s) and
        ser-estab.cod-estabel = c-cod-estabel: 
    end.
   if not avail ser-estab then do:
       run pi-gera-log (input "SÇrie n∆o cadastrada para estabelecimento: " 
                        + "Est: "       + c-cod-estabel
                        + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                        + " Numero: "   + c-num-nota,
                        input 1).
       return.
   end.  

    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres fields (cod-rep nome-abrev) no-lock where 
            repres.cod-rep = i-cod-rep:
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    if int-dp-nota-devolucao.ndv-chaveacesso-s  /* chave acesso */ = ? and 
        int-dp-nota-devolucao.tipo-movto <> 3 then do:
        l-servico = no.
        for each int-dp-nota-devolucao-item no-lock of int-dp-nota-devolucao.
            for first item no-lock where
                item.it-codigo = trim(string(int(int-dp-nota-devolucao-item.ndp-produto-n))): end.
            if avail item and item.tipo-contr <> 4 then do:
                l-servico = no.
                leave.
            end.
            l-servico = yes.
        end.
        if l-servico then next.
        run pi-gera-log (input "Nota fiscal sem chave de acesso: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                         + " Numero: "   + c-num-nota,
                         input 1).
        return.
    end.               

    assign c-nome-transp = "PADRAO".
    /*
    assign  d-dt-comp    = ?
            c-nat-origem = "".
    if  int-dp-nota-devolucao.nen-notafiscalorigem-n <> 0 and
       (int-dp-nota-devolucao.ndv-cupomorigem-s = "" or int-dp-nota-devolucao.ndv-cupomorigem-s = ?) 
    then do:
        for each docum-est fields (dt-emissao nat-operacao) no-lock where 
            docum-est.serie-docto  = int-dp-nota-devolucao.nen-serieorigem-s and
            docum-est.nro-docto    = trim(string(int-dp-nota-devolucao.nen-notafiscalorigem-n,">>>9999999")) and
            docum-est.cod-emitente = i-cod-emitente: 
            assign  d-dt-comp      = docum-est.dt-emissao
                    c-nat-origem   = docum-est.nat-operacao.
        end.
        if c-nat-origem = "" then do:
            run pi-gera-log (input "Documento origem n∆o encontrado: " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                             + " Numero: "   + c-num-nota
                             + " Nota: "     +  trim(string(int-dp-nota-devolucao.nen-notafiscalorigem-n,">>>9999999")),
                             input 1).
            next.
        end.
    end.
    */

end procedure.

procedure pi-valida-item.

    run pi-acompanhar in h-acomp (input "Validando Itens:" + 
                                        c-cod-estabel + "/" + 
                                        int-dp-nota-devolucao.ndv-serie-s + "/" + 
                                        c-num-nota + "/" + string(int-dp-nota-devolucao-item.ndp-produto-n)).
    
    if trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) <> ""    and
       trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) <> ?     and 
       trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) <> "0"   then do:
        for first item 
            no-lock where 
            item.it-codigo = string(int-dp-nota-devolucao-item.ndp-produto-n): end.
        if not avail item then do:
            run pi-gera-log (input "Item n∆o cadastrado: " + string(int-dp-nota-devolucao-item.ndp-produto-n),
                             input 1).
        end.
    end.
    else do:
        run pi-gera-log (input "Item Nissei n∆o informado: " + trim(string(int-dp-nota-devolucao-item.ndp-produto-n)),
                         input 1).
    end.
    if avail item and item.cod-obsoleto = 4 then do:
        run pi-gera-log (input "Item est† obsoleto: " + trim(item.it-codigo),
                         input 1).
        next.
    end.     

    if int-dp-nota-devolucao-item.ndp-ncm-s = "" then do:
        run pi-gera-log (input "NCM do Item n∆o informada: " + trim(item.it-codigo),
                         input 1).
    end.

    if not can-find(classif-fisc where 
                    classif-fisc.class-fiscal = int-dp-nota-devolucao-item.ndp-ncm-s) then do:
        run pi-gera-log (input "NCM do Item n∆o cadasrrada: " + trim(item.it-codigo) + " NCM: " + int-dp-nota-devolucao-item.ndp-ncm-s,
                         input 1).
        next.
    end.

    for first item-uni-estab no-lock where 
              item-uni-estab.cod-estabel = c-cod-estabel and
              item-uni-estab.it-codigo = string(int-dp-nota-devolucao-item.ndp-produto-n): 
    end.
    if not avail item-uni-estab THEN DO:
       for first item-estab NO-LOCK where 
                 item-estab.cod-estabel = c-cod-estabel and
                 item-estab.it-codigo = string(int-dp-nota-devolucao-item.ndp-produto-n): 
       end.
    end.
    if not avail item-estab and not avail item-uni-estab then do:
       run pi-gera-log (input "Item n∆o cadastrado no estabelecimento. Item: " + string(int-dp-nota-devolucao-item.ndp-produto-n) + " Estab.: " + c-cod-estabel,
                        input 1).
       next.
    end.
    if item-uni-estab.ind-item-fat = no then do:
        run pi-gera-log (input "Item n∆o fatur†vel no estabelecimento. Item: " + string(int-dp-nota-devolucao-item.ndp-produto-n) + " Estab.: " + c-cod-estabel,
                         input 1).
        next.
    end.

    i-cfop = int-dp-nota-devolucao-item.ndp-cfop-n.
    if i-cfop = ? then do:
        run pi-gera-log (input "CFOP do Item n∆o informada. Item: " + string(int-dp-nota-devolucao-item.ndp-produto-n),
                         input 1).
        next.
    end.

    assign  c-nat-comp   = ""
            d-dt-comp    = ?
            c-nat-origem = "".
    if  int-ds-mod-pedido.log-nat-origem or
       (int-dp-nota-devolucao.nen-notafiscalorigem-n <> 0 and int-dp-nota-devolucao.nen-notafiscalorigem-n <> ? and
        (int-dp-nota-devolucao.ndv-cupomorigem-s = "" or int-dp-nota-devolucao.ndv-cupomorigem-s = ?)
        ) 
    then do:
        for first item-doc-est no-lock where 
            item-doc-est.cod-emitente = i-cod-emitente  and
            item-doc-est.nro-docto    = TrataNuloChar(string(int-dp-nota-devolucao.nen-notafiscalorigem-n,">>>9999999")) and
            item-doc-est.serie-docto  = TrataNuloChar(int-dp-nota-devolucao.nen-serieorigem-s) and
            item-doc-est.it-codigo    = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-produto-n)):
            assign  c-nat-comp   = item-doc-est.nat-operacao.
                    c-nat-origem = item-doc-est.nat-of.
            for each docum-est no-lock of item-doc-est:
                assign d-dt-comp = docum-est.dt-emissao.
            end.
        end.
        if not avail item-doc-est then do:
            run pi-gera-log (input "Documento origem a devolver n∆o localizado: " 
                             + " Ser: " + TrataNuloChar(int-dp-nota-devolucao.nen-serieorigem-s)
                             + " Docto: " + TrataNuloChar(string(int-dp-nota-devolucao.nen-notafiscalorigem-n,">>>9999999"))
                             + " Emitente: " + string(i-cod-emitente)
                             + " Item: " + TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-produto-n)),
                             input 1).
            next.
        end.
    end.
    /* determina natureza de operacao */
    
    run intprg/int115a.p ( input int-ds-tipo-pedido.tp-pedido ,
                           input c-uf-destino   ,
                           input c-uf-origem    ,
                           input c-nat-origem   ,  
                           input i-cod-emitente ,
                           input int-dp-nota-devolucao-item.ndp-ncm-s ,
                           output c-nat-operacao,
                           output c-nat-entrada ,
                           output r-rowid).
    
    assign  c-cod-esp-princ = ""
            i-esp-docto     = 0.
    for first natur-oper no-lock where 
        natur-oper.nat-operacao = c-nat-operacao: 
        if i-cod-mensagem = 0 then 
            i-cod-mensagem = natur-oper.cod-mensagem.
        assign  c-cod-esp-princ = natur-oper.cod-esp
                i-esp-docto     = if natur-oper.especie-doc = "NFS" then 22 else 
                                    if natur-oper.especie-doc = "NFD" then 20 else 
                                      if natur-oper.especie-doc = "NFT" then 23 else 21 /* NFE */.
    end.
    if not avail natur-oper then do:
        run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada. Natur. Oper.: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    if avail natur-oper and 
       not natur-oper.nat-ativa then do:
        run pi-gera-log (input "Natureza de operaá∆o inativa. Natur. Oper.: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    /**************** Natureza nío pode ser de entrada ****************/
    if natur-oper.tipo = 1 then do:     /* Entrada */
        run pi-gera-log (input "Natureza de operaá∆o de entrada n∆o permitida. Natur. Oper.: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    if natur-oper.especie-doc = "NFD" then do:
        if int-dp-nota-devolucao.nen-notafiscalorigem-n = ? or
           int-dp-nota-devolucao.nen-notafiscalorigem-n = 0 then do:
            run pi-gera-log (input "Natureza de devolucao sem documento origem. Natur. Oper.: " + c-nat-operacao,
                             input 1).
            next.
        end.
    end.

    /*
    if can-find (first int-dp-nota-devolucao-dup of int-dp-nota-devolucao) and
       not natur-oper.emite-duplic) then do:
        run pi-gera-log (input "Duplicatas informadas e Natureza de operaá∆o n∆o emite duplicatas. Natur. Oper.: " + c-nat-operacao,
                         input 1).
        next.
    end.
    */

    /******************************************/
    if TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n) <= 0 then do:
        run pi-gera-log (input "Quantidade do item incorreta: " + string(int-dp-nota-devolucao-item.ndp-produto-n) + " Qtde: " + string(TrataNuloDec(int-dp-nota-devolucao-item.ndp-quantidade-n)),
                         input 1).
       next.
    end. 
    
    
     /*************** CΩdigo da Mensagem ***********************************/
     /*
     if  natur-oper.cod-mensagem <> 0 
     and not can-find(mensagem where 
                      mensagem.cod-mensagem = natur-oper.cod-mensagem) then do:
         {utp/ut-table.i mgadm mensagem 1}    
         run pi-erros-nota (input 56, input trim(return-value) + " Cod. Mensagem: " + string(natur-oper.cod-mensagem)).
         return.
     end.
     */
    
     /* Venda tributada ICMS e natureza NAO tributa 
     if natur-oper.cd-trib-icm <> 1 and
       (trim(c-trib-icms) = "1" or 
        trim(c-trib-icms) = "3") and
        de-valor-icms > 0 then do:
         assign i-erro = 49
                c-informacao = "Nr. Nota: " + c-num-nota + " - " + "Item: " + trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) + " - " +
                               "NCM: " + int-dp-nota-devolucao-item.ndp-ncm-s + " - " + "Cd Pgto: " + c-condipag + " - " +
                               "Natur. Oper.: " + c-natur +
                               " - " + "ICMS: " + trim(string(de-valor-icms,"->>>,>>>,>>9.99"))
             l-cupom-com-erro = yes.
         run gera-log. 
         return.
     end.
     */
     /* Natureza c/ ICMS e cupom sem valor de ICMS 
     if natur-oper.cd-trib-icm = 1 and
        trim(c-trib-icms) <> "1" and
        trim(c-trib-icms) <> "3" and
        de-valor-icms = 0 then do:
         assign i-erro = 50
                c-informacao = "Nr. Nota: " + c-num-nota + " - " + "Item: " + trim(string(int-dp-nota-devolucao-item.ndp-produto-n)) + " - " +
                               "NCM: " + int-dp-nota-devolucao-item.ndp-ncm-s + " - " + "Cd Pgto: " + c-condipag + " - " +
                               "Natur. Oper.: " + c-natur +
                               " - " + "ICMS: " + trim(string(de-valor-icms,"->>>,>>>,>>9.99"))
             l-cupom-com-erro = yes.
         run gera-log. 
         return.
     end.
     */

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
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
   empty temp-table tt-nota-fiscal-adc.
end.        

procedure pi-importa-nota.
    
    run pi-acompanhar in h-acomp (input "Gerando Nota").

    for first tt-docto: end.
    for first tt-it-docto: end.
    if  avail  tt-docto and
        avail  tt-it-docto
    then do transaction:

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

        for each tt-notas-geradas:
            for each nota-fiscal exclusive-lock where 
                rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
                run pi-acompanhar in h-acomp (input "Verifica Nota: " + nota-fiscal.nr-nota-fis).

                /* adicionais substituiá∆o de cupom e devoluá∆o */
                for each tt-nota-fiscal-adc of nota-fiscal:
                    for first nota-fisc-adc where 
                              nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel         and 
                              nota-fisc-adc.cod-serie      = nota-fiscal.serie               and 
                              nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis         and 
                              nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente        and 
                              nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao        and 
                              nota-fisc-adc.idi-tip-dado   = tt-nota-fiscal-adc.idi-tip-dado and 
                              nota-fisc-adc.num-seq        = 1:
                    end.
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

                /* integraá‰es Oblak e CD */
                if nota-fiscal.esp-docto = 23 /* NFT */ then do:
                    for each estabelec no-lock where estabelec.cgc = nota-fiscal.cgc:
                        /* Destino CD */
                        if estabelec.cod-estabel = "973" then RUN pi-entrada-cd(2 /* Sit Docto */, 2 /* Sit Envio_status integrado - somente para retorno posterior da conferencia */).
                        else do: /* Destino Lojas */
                            for each cst-estabelec no-lock of estabelec where
                                cst-estabelec.dt-fim-operacao >= nota-fiscal.dt-emis-nota:
                                /* Destino Loja Oblak */
                                if cst-estabelec.dt-inicio-oper = ? or 
                                   cst-estabelec.dt-inicio-oper > nota-fiscal.dt-emis-nota then
                                    RUN pi-saidas(1, /* situacao saida Oblak - Deixar ativo pois eles usam saida e entrada para dar entrada */
                                                  2, /* situacao saida Procfit - N∆o integrar pois eles mesmo emitiram a nota */
                                                  1, /* situacao entrada Oblak */
                                                  2  /* situacao entrada Procfit - N∆o integrar pois eles mesmo emitiram a nota  */).
                                /* Destino Loja Procfit */
                                if cst-estabelec.dt-inicio-oper <= nota-fiscal.dt-emis-nota then
                                    RUN pi-saidas(2, /* situacao saida Oblak - evita integrar nota na Oblak */
                                                  2, /* situacao saida Procfit - evita integrar nota na Procfit - eles emitiram a nota*/
                                                  2, /* situacao entrada Oblak - evita integrar nota na Oblak */                                
                                                  2 /* situacao entrada Procfit */). 
                            end.
                        end.
                    end.
                end.

                /* Acerto n£mero do pedido e campos adicionais */
                for each bint-dp-nota-devolucao exclusive-lock where
                    bint-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s = int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s and
                    bint-dp-nota-devolucao.ndv-serie-s       = int-dp-nota-devolucao.ndv-serie-s       and
                    bint-dp-nota-devolucao.ndv-notafiscal-n  = int-dp-nota-devolucao.ndv-notafiscal-n:

                    /* acertando numero do pedido */
                    if nota-fiscal.nr-pedcli = "" then do:
                        assign nota-fiscal.nr-pedcli = trim(string(int-dp-nota-devolucao.ped-codigo-n)).
                    end.

                    for each it-nota-fisc of nota-fiscal exclusive-lock
                        query-tuning(no-lookahead):
                        assign it-nota-fisc.nr-pedcli = nota-fiscal.nr-pedcli.

                        /* acertando campos n∆o suportados na ft2010 */
                        for each int-dp-nota-devolucao-item no-lock of bint-dp-nota-devolucao where
                            int-dp-nota-devolucao-item.ndp-sequencia-n = it-nota-fisc.nr-seq-fat and
                            int-dp-nota-devolucao-item.ndp-produto-n = int64(it-nota-fisc.it-codigo):

                            /* CSTÔs e Modalidades de base de c†lculo */
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                assign  it-nota-fisc.cod-sit-tributar-ipi     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbipi-n,"99"))
                                        it-nota-fisc.cod-sit-tributar-pis     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbpis-s,"99"))
                                        it-nota-fisc.cod-sit-tributar-cofins  = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbcofins-s,"99")).

                                assign  it-nota-fisc.idi-modalid-base-icms    = TrataNuloDec(int-dp-nota-devolucao-item.ndp-modbcicms-n)
                                        it-nota-fisc.idi-modalid-base-icms-st = TrataNuloDec(int-dp-nota-devolucao-item.ndp-modbcst-n)  
                                        it-nota-fisc.idi-modalid-base-ipi     = TrataNuloDec(int-dp-nota-devolucao-item.ndp-modbipi-n).  
                            &else
                                assign  overlay(it-nota-fisc.char-1,75,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbipi-n,"99"))
                                        overlay(it-nota-fisc.char-1,77,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbpis-s,"99"))
                                        overlay(it-nota-fisc.char-1,79,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-cstbcofins-s,"99")).

                                assign  overlay(it-nota-fisc.char-1,81,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbcicms-n))
                                        overlay(it-nota-fisc.char-1,85,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbcst-n))
                                        overlay(it-nota-fisc.char-1,83,2)     = TrataNuloChar(string(int-dp-nota-devolucao-item.ndp-modbipi-n)).
                            &endif
                            
                            /* PIS/COFINS */
                            assign overlay(it-nota-fisc.char-2,96,1)          = if int-dp-nota-devolucao-item.ndp-percentualpis-n > 0 then "1" else "2" /* Tributaá∆o PIS    */ 
                                   overlay(it-nota-fisc.char-2,76,5)          = string (int-dp-nota-devolucao-item.ndp-percentualpis-n,"99.99") /* Aliquota PIS */.
                        
                            assign overlay(it-nota-fisc.char-2,97,1)          = if int-dp-nota-devolucao-item.ndp-percentualpis-n > 0 then "1" else "2" /* Tributaá∆o COFINS */
                                   overlay(it-nota-fisc.char-2,81,5)          = string(int-dp-nota-devolucao-item.ndp-percentualpis-n,"99.99").
                        
                            assign overlay(it-nota-fisc.char-2,86,5)  /* Reduá∆o PIS    */ = "00,00".
                                   overlay(it-nota-fisc.char-2,91,5)  /* Reduá∆o COFINS */ = "00,00".
                        end.
                    end.

                    /* Marcando integraá∆o processada nos pedidos e na nota */
                    for each int-ds-pedido where int-ds-pedido.ped-codigo-n = int-dp-nota-devolucao.ped-codigo-n and
                        int-ds-pedido.situacao <> 2:
                        assign int-ds-pedido.situacao = 2.
                    end.
                    for each int-ds-pedido-subs where int-ds-pedido-subs.ped-codigo-n = int-dp-nota-devolucao.ped-codigo-n and
                        int-ds-pedido-subs.situacao <> 2:
                        assign int-ds-pedido-subs.situacao = 2.
                    end.
                    assign bint-dp-nota-devolucao.situacao = 2.
                    
                    run pi-gera-log (input "Nota fiscal importada com sucesso: " 
                                     + "Est: "       + c-cod-estabel
                                     + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                                     + " Numero: "   + c-num-nota,
                                     input 2).
                    release bint-dp-nota-devolucao.
                 end.
            end.
        end.

        /* verificando notas n∆o importadas */
        for each tt-docto:
            if not can-find (first nota-fiscal no-lock where
                                   nota-fiscal.cod-estabel = tt-docto.cod-estabel and
                                   nota-fiscal.serie       = tt-docto.serie       and
                                   nota-fiscal.nr-nota-fis = tt-docto.nr-nota) then do:
                run pi-gera-log (input "Nota fiscal NAO importada: " 
                                 + "Est: "       + c-cod-estabel
                                 + " SÇrie: "    + int-dp-nota-devolucao.ndv-serie-s 
                                 + " Numero: "   + c-num-nota,
                                 input 1).
                undo, leave.
            end.
        end.

    end.
end procedure.

procedure pi-gera-duplicatas:

    def var de-vl-tot-dup       as decimal no-undo.
    def var i-seq-fat-duplic    as integer no-undo.

    i-seq-fat-duplic = 0.

    if int-dp-nota-devolucao.tipo-movto <> 3 /* cancelado */ then do:

        for each int-dp-nota-devolucao-dup no-lock of int-dp-nota-devolucao
            by int-dp-nota-devolucao-dup.ndv-vencimento-d
            query-tuning(no-lookahead):
            if int-dp-nota-devolucao-dup.ndv-valorduplicata-n <= 0 then next.
            
            if int-dp-nota-devolucao-dup.ndv-vencimento-d < int-dp-nota-devolucao.ndv-dataemissao-d then do:
                assign int-dp-nota-devolucao-dup.ndv-vencimento-d = int-dp-nota-devolucao.ndv-dataemissao-d.
            end.
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = 1
                   tt-fat-duplic.cod-vencto        = 1 /* dias da data */
                   tt-fat-duplic.dt-venciment      = int-dp-nota-devolucao-dup.ndv-vencimento-d
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = string(i-seq-fat-duplic,"99")
                   tt-fat-duplic.vl-parcela        = TrataNuloDec(int-dp-nota-devolucao-dup.ndv-valorduplicata-n)
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
 
procedure pi-gera-log:
    define input parameter c-informacao as char no-undo.
    define input parameter i-situacao as integer no-undo.

    IF tt-param.arquivo <> "" THEN DO:
        put /*stream str-rp*/ unformatted
            int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s + "/" + 
            trim(int-dp-nota-devolucao.ndv-serie-s) + "/" + 
            trim(string(int-dp-nota-devolucao.ndv-notafiscal-n)) + " - " + 
            c-informacao
            skip.
    END.

    RUN intprg/int999.p ("NFS", 
                         int-dp-nota-devolucao.ndv-cnpjfilialdevolucao-s + "/" + 
                         trim(int-dp-nota-devolucao.ndv-serie-s) + "/" + 
                         trim(string(int-dp-nota-devolucao.ndv-notafiscal-n)),
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario,
                         "INT227RP.P").
    if i-situacao = 1 then l-erro = yes.
end.

{intprg/int011rp.i} /* pi-saidas */
