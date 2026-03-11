/***********************************************************************************
** Programa: INT217 - Importaá∆o de Notas de Saida Simples do PROCFIT S/ Duplicatas
**
** Versao : 12 - 22/02/2018 - Alessandro V Baccin
**
************************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i int217rp 2.12.06.AVB}
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
def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int217.txt"
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
def var c-class-fiscal      as char    no-undo.
def var c-it-codigo         as char    no-undo.
def var c-nota-origem       as char    no-undo.
def var i-cont-item-ped     as integer no-undo.
def var i-cont-item-nf      as integer no-undo.
DEF VAR l-int_ds_pedido     AS LOGICAL NO-UNDO.

def buffer bint_dp_nota_saida for int_dp_nota_saida.
def buffer bestabelec for estabelec.

def var de-tot-despesas as decimal decimals 4 no-undo.

/* definiá∆o de frames do relat¢rio */

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i}
/* bloco principal do programa */

FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i}
END.

assign c-programa     = "int217"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Faturamento"
       c-titulo-relat = "Importacao NF Sa°da Procfit".

IF tt-param.arquivo <> "" THEN DO:
    view frame f-cabec.
    view frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock query-tuning(no-lookahead): end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin query-tuning(no-lookahead): end.
assign c-empresa = mgadm.empresa.razao-social.


/******* LE NOTA E GERA TEMP TABLES  *************/
for-nota:
for each int_dp_nota_saida no-lock where 
    int_dp_nota_saida.situacao = 1
    query-tuning(no-lookahead):

    assign c-num-nota = trim(string(int_dp_nota_saida.nsa_notafiscal_n,">>>9999999")).
    assign c-nota-origem = TrataNuloChar(string(int_dp_nota_saida.nen_notafiscalorigem_n,">>>9999999")).
    assign l-erro = no.
    if int_dp_nota_saida.ped_tipopedido_n = ? OR int_dp_nota_saida.ped_tipopedido_n = 0 then do: 
        run pi-gera-log (input "Tipo de pedido inv†lido: " 
                         + "CNPJ: "      + int_dp_nota_saida.nsa_cnpj_origem_s
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Tipo: "     + (if int_dp_nota_saida.ped_tipopedido_n = 0 
                                            then string(int_dp_nota_saida.ped_tipopedido_n) else "?"),
                         input 1).
        next.
    end.

    run pi-elimina-tabelas.
    for each int_ds_tipo_pedido no-lock where 
        int_ds_tipo_pedido.tp_pedido = trim(string(int_dp_nota_saida.ped_tipopedido_n))
        query-tuning(no-lookahead):

        for each int_ds_mod_pedido no-lock where 
            int_ds_mod_pedido.cod_mod_pedido = int_ds_tipo_pedido.cod_mod_pedido and
           (int_ds_mod_pedido.cod_prog_dtsul = "int147" or /* faturamentos pedidos */
            int_ds_mod_pedido.cod_prog_dtsul = "int137" or /* faturamentos pedidos */
            int_ds_mod_pedido.cod_prog_dtsul = "int127" or /* faturamentos pedidos */
            int_ds_mod_pedido.cod_prog_dtsul = "int048" or /* substituiá∆o de cupom */
            int_ds_mod_pedido.cod_prog_dtsul = "int217" /* importaá∆o de notas */)
            query-tuning(no-lookahead):

            run pi-acompanhar in h-acomp (input "Validando Nota:" + 
                                          int_dp_nota_saida.nsa_cnpj_origem_s + "/" + 
                                          int_dp_nota_saida.nsa_serie_s + "/" + 
                                          string(int_dp_nota_saida.nsa_notafiscal_n)).

            RUN pi-valida-cabecalho.
            if l-erro then next for-nota.
            run pi-acompanhar in h-acomp (input "Validando Nota:" + 
                                          c-cod-estabel + "/" + 
                                          int_dp_nota_saida.nsa_serie_s + "/" + 
                                          c-num-nota).

            i-nr-sequencia = 0.
            for each int_dp_nota_saida_item no-lock where
                int_dp_nota_saida_item.nsa_cnpj_origem_s = int_dp_nota_saida.nsa_cnpj_origem_s and
                int_dp_nota_saida_item.nsa_serie_s       = int_dp_nota_saida.nsa_serie_s       and
                int_dp_nota_saida_item.nsa_notafiscal_n  = int_dp_nota_saida.nsa_notafiscal_n
                query-tuning(no-lookahead):
                
                run pi-valida-item.
                if l-erro then next for-nota.
                RUN pi-cria-tt-it-docto.
            end. /* int_dp_nota_saida_item */
            for first tt-it-docto. end.
            if not l-erro and not avail tt-it-docto then do:
                run pi-gera-log (input "Documento sem itens:" 
                                        + " CNPJ: "     + int_dp_nota_saida.nsa_cnpj_origem_s
                                        + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                                        + " Numero: "   + c-num-nota
                                        + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                                 input 1).
                next.
            end.

            if not l-erro then do:
                RUN pi-cria-tt-docto.
                if not l-erro then do:
                    RUN pi-importa-nota.
                    run pi-elimina-tabelas.
                end.
            end.
        end. /* int_ds_mod_pedido */
    end. /* int_ds_tipo_pedido */
    run pi-elimina-tabelas.
end. /* for-nota */

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpclo.i}
END.

RUN intprg/int888.p (INPUT "NF PROC",
                     INPUT "int217rp.p").

run pi-finalizar in h-acomp.
return "OK":U.

/* procedures internas */
procedure pi-cria-tt-docto.

    run pi-acompanhar in h-acomp (input "Criando Docto:" +
                                  c-cod-estabel + "/" + 
                                  int_dp_nota_saida.nsa_serie_s + "/" + 
                                  c-num-nota).
    
    create tt-docto.
    assign tt-docto.fat-nota         = if int_dp_nota_saida.tipo_movto <> 3
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
           tt-docto.serie            = int_dp_nota_saida.nsa_serie_s
           tt-docto.cgc              = int_dp_nota_saida.nsa_cnpj_destino_s
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
           tt-docto.peso-bru-tot     = TrataNuloDec(int_dp_nota_saida.nsa_pesobruto_n)
           tt-docto.peso-liq-tot     = TrataNuloDec(int_dp_nota_saida.nsa_pesoliquido_n)
           tt-docto.vl-embalagem     = TrataNuloDec(int_dp_nota_saida.nsa_valorembalagem_n)
           tt-docto.vl-frete         = TrataNuloDec(int_dp_nota_saida.nsa_valorfrete_n)
           tt-docto.vl-seguro        = TrataNuloDec(int_dp_nota_saida.nsa_valorseguro_n)
           tt-docto.cod-canal-venda  = 0
           tt-docto.cidade-cif       = ""
           tt-docto.cod-cond-pag     = 0
           tt-docto.cod-entrega      = "Padr∆o"
           tt-docto.dt-base-dup      = int_dp_nota_saida.nsa_dataemissao_d
           tt-docto.dt-emis-nota     = tt-docto.dt-base-dup
           tt-docto.dt-prvenc        = tt-docto.dt-base-dup
           tt-docto.dt-cancela       = if int_dp_nota_saida.tipo_movto = 3 then tt-docto.dt-base-dup else ?
           tt-docto.marca-volume     = TrataNuloChar(int_dp_nota_saida.nsa_marcavolumes_s)
           tt-docto.mo-codigo        = 0
           tt-docto.no-ab-reppri     = c-nome-repres
           tt-docto.nome-tr-red      = ""
           tt-docto.nome-transp      = c-nome-transp
           tt-docto.nr-fatura        = tt-docto.nr-nota
           tt-docto.nr-tabpre        = ""
           tt-docto.nr-volumes       = TrataNuloChar(string(int_dp_nota_saida.nsa_quantvolumes_n))
           tt-docto.placa            = TrataNuloChar(int_dp_nota_saida.nsa_placaveiculo_s)
           tt-docto.serie-ent-fut    = ""
           tt-docto.nr-nota-ent-fut  = ""
           tt-docto.ind-lib-nota     = yes
           tt-docto.cod-rota         = ""
           tt-docto.cod-msg          = i-cod-mensagem
           tt-docto.vl-taxa-exp      = 1 /* cotaªío Real -> Real */
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
           tt-docto.obs              = TrataNuloChar(int_dp_nota_saida.nsa_observacao_s)
           tt-docto.esp-docto        = i-esp-docto
           tt-docto.motvo-cance      = if int_dp_nota_saida.tipo_movto = 3 then "Cancelada Procfit" else ""
           tt-docto.nr-pedcli        = /*TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))*/ "".

    assign tt-docto.vl-mercad        = TrataNuloDec(int_dp_nota_saida.nsa_valortotalprodutos_n).

    if int_dp_nota_saida.nsa_chaveacesso_s  /* chave acesso */ <> ? then do:
        assign overlay(tt-docto.char-1,112,60) = TrataNuloChar(OnlyNumbers(int_dp_nota_saida.nsa_chaveacesso_s))  /* chave acesso */
               overlay(tt-docto.char-1,172,2)  = if int_dp_nota_saida.tipo_movto <> 3 then "3" else "6" /* situacao */.
    end.               
    if int_dp_nota_saida.nsa_tipoambientenfe_n /* tipo transmissao*/  <> ? then 
        assign overlay(tt-docto.char-1,174,1)  = TrataNuloChar(string(int_dp_nota_saida.nsa_tipoambientenfe_n)) /* tipo transmissao*/.
    if int_dp_nota_saida.nsa_protocolonfe_s /* protocolo */ <> ? then
           assign overlay(tt-docto.char-1,175,15) = int_dp_nota_saida.nsa_protocolonfe_s. /* protocolo */.
           
    /*Modalidade de Frete */
    assign overlay(tt-docto.char-1,190,8) = TrataNuloChar(string(int_dp_nota_saida.nsa_modalidadefrete_n)) no-error.
    if substring(tt-docto.char-1,190,8) = "" then overlay(tt-docto.char-1,190,8) = "9".
    /*Fim Modalidade de Frete*/			     

    /* dados adicionais da nota - substituicao de cupom */
    if  TrataNuloChar(int_dp_nota_saida.nsa_cupomorigem_s) <> "" or
        int_dp_nota_saida.ped_tipopedido_n = 48 then do:
        create  tt-nota-fiscal-adc.
        assign  tt-nota-fiscal-adc.cod-estabel              = c-cod-estabel
                tt-nota-fiscal-adc.serie                    = int_dp_nota_saida.nsa_serie_s
                tt-nota-fiscal-adc.nr-nota-fis              = c-num-nota
                tt-nota-fiscal-adc.cod-model-ecf            = TrataNuloChar(int_dp_nota_saida.nsa_modelocupom_s)
                tt-nota-fiscal-adc.cod-fabricc-ecf          = if TrataNuloChar(int_dp_nota_saida.nsa_numeroserieecf_s) = "NFCE" then "0"
                                                              else TrataNuloChar(int_dp_nota_saida.nsa_numeroserieecf_s)
                tt-nota-fiscal-adc.cod-cx-ecf               = TrataNuloChar(int_dp_nota_saida.nsa_caixaecf_s)
                tt-nota-fiscal-adc.cod-docto-referado-ecf   = TrataNuloChar(string(int64(int_dp_nota_saida.nsa_cupomorigem_s),">>>9999999"))
                tt-nota-fiscal-adc.dat-docto-referado-ecf   = int_dp_nota_saida.nsa_datacupomorigem_ecf
                tt-nota-fiscal-adc.idi-tip-dado             = 4
                tt-nota-fiscal-adc.cdn-emit-docto-referado  = 0
                tt-nota-fiscal-adc.cod-ser-docto-referado   = TrataNuloChar(int_dp_nota_saida.nen_serieorigem_s).

        if  tt-nota-fiscal-adc.cod-ser-docto-referado = ""  or
            tt-nota-fiscal-adc.cod-docto-referado-ecf = "" then do:
            run pi-gera-log (input "Cupom substituido nao informado: " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                             + " Numero: "   + c-num-nota
                             + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                             input 1).
            return.
        end.
    end.
    /* dados adicionais da nota - devolucao Lj->Fornecedor */
    if int_dp_nota_saida.ped_tipopedido_n = 15 then do:
        create  tt-nota-fiscal-adc.
        assign  tt-nota-fiscal-adc.cod-estabel              = c-cod-estabel
                tt-nota-fiscal-adc.serie                    = int_dp_nota_saida.nsa_serie_s
                tt-nota-fiscal-adc.nr-nota-fis              = c-num-nota
                tt-nota-fiscal-adc.cod-model-ecf            = ""
                tt-nota-fiscal-adc.cod-fabricc-ecf          = ""
                tt-nota-fiscal-adc.cod-cx-ecf               = ""
                tt-nota-fiscal-adc.cod-docto-referado       = c-nota-origem
                tt-nota-fiscal-adc.cdn-emit-docto-referado  = i-cod-emitente
                tt-nota-fiscal-adc.cod-ser-docto-referado   = trim(int_dp_nota_saida.nen_serieorigem_s)
                tt-nota-fiscal-adc.idi-tip-dado             = 3
                tt-nota-fiscal-adc.cod-model-docto-referado = "1"
                tt-nota-fiscal-adc.idi-tip-docto-referado   = 1
                tt-nota-fiscal-adc.idi-tip-emit-referado    = 1
                tt-nota-fiscal-adc.dat-docto-referado       = d-dt-comp.

        if  tt-nota-fiscal-adc.cod-ser-docto-referado = ""  or
            tt-nota-fiscal-adc.cod-docto-referado-ecf = "" then do:
            run pi-gera-log (input "Nota origem devolucao nao informada: " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                             + " Numero: "   + c-num-nota
                             + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                             input 1).
            return.
        end.
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
   case int_dp_nota_saida_item.nsi_cstb_n:
       when 00 then i-cd-trib-icm = 1 /* tributado */.
       when 10 then i-cd-trib-icm = 1 /* tributado e ST */.
       when 20 then i-cd-trib-icm = 4 /* reduzido */ .
       when 30 then i-cd-trib-icm = 2 /* isento */   .
       when 40 then i-cd-trib-icm = 2 /* isento */   .
       when 41 then i-cd-trib-icm = 2 /* isento */   .
       when 50 then i-cd-trib-icm = 3 /* outros */   .
       when 60 then i-cd-trib-icm = 3 /* ST - outros */.
       when 70 then i-cd-trib-icm = 4 /* reduzido */ .
       when 90 then i-cd-trib-icm = 3 /* outros */   .
       otherwise i-cd-trib-icm = 3 /* outros */ .
   end.

   /*assign i-cd-trib-ipi = natur-oper.cd-trib-ipi.*/
   case int_dp_nota_saida_item.nsi_cstbIPI_n:
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

   i-nr-sequencia = i-nr-sequencia + 1.

   create tt-it-docto.
   assign tt-it-docto.calcula             = yes
          tt-it-docto.tipo-atend          = 1   /* Total */
          tt-it-docto.seq-tt-it-docto     = i-nr-sequencia
          tt-it-docto.baixa-estoq         = if int_dp_nota_saida.tipo_movto <> 3 then item.tipo-contr <> 4 else no
          tt-it-docto.class-fiscal        = c-class-fiscal
          tt-it-docto.cod-estabel         = c-cod-estabel
          tt-it-docto.cod-refer           = ""
          tt-it-docto.data-comp           = d-dt-comp
          tt-it-docto.it-codigo           = c-it-codigo
          tt-it-docto.nat-comp            = c-nat-comp
          tt-it-docto.nro-comp            = c-nota-origem
          tt-it-docto.serie-comp          = if c-nota-origem <> "" then TrataNuloChar(int_dp_nota_saida.nen_serieorigem_s) else ""
          tt-it-docto.seq-comp            = if c-nota-origem <> "" then TrataNuloDec(int_dp_nota_saida_item.nep_sequenciaorigem_n) else 0
          tt-it-docto.nat-operacao        = c-nat-operacao
          tt-it-docto.nr-nota             = c-num-nota
          tt-it-docto.nr-sequencia        = if int_dp_nota_saida_item.nsi_sequencia_n <> ? 
                                            then int_dp_nota_saida_item.nsi_sequencia_n else i-nr-sequencia
          tt-it-docto.per-des-item        = 0
          tt-it-docto.peso-liq-it-inf     = 0
          tt-it-docto.peso-bru-it-inf     = 0
          tt-it-docto.peso-bru-it         = TrataNuloDec(int_dp_nota_saida_item.nsi_pesobruto_n)
          tt-it-docto.peso-liq-it         = TrataNuloDec(int_dp_nota_saida_item.nsi_pesoliquido_n)
          tt-it-docto.peso-embal-it       = 0
          tt-it-docto.quantidade[1]       = TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
          tt-it-docto.quantidade[2]       = tt-it-docto.quantidade[1]
          tt-it-docto.serie               = int_dp_nota_saida_item.nsa_serie_s
          tt-it-docto.un[1]               = item.un
          tt-it-docto.un[2]               = tt-it-docto.un[1]
          tt-it-docto.vl-despes-it        = TrataNuloDec(int_dp_nota_saida_item.nsi_valordespesa_n) 
                                          + (if i-esp-docto = 20 /* devolucao */ 
                                             then TrataNuloDec(int_dp_nota_saida_item.nsi_icmsst_n) else 0)
          tt-it-docto.vl-embalagem        = TrataNuloDec(int_dp_nota_saida_item.nsi_valorembalagem_n)
          tt-it-docto.vl-frete            = TrataNuloDec(int_dp_nota_saida_item.nsi_valorfrete_n)
          tt-it-docto.vl-seguro           = TrataNuloDec(int_dp_nota_saida_item.nsi_valorseguro_n)
          tt-it-docto.vl-merc-liq         = truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valorliquido_n),2)
          tt-it-docto.vl-merc-ori         = truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valorbruto_n),2)
          tt-it-docto.vl-merc-tab         = truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valorbruto_n),2)
          tt-it-docto.vl-preori           = TrataNuloDec(int_dp_nota_saida_item.nsi_valorbruto_n) / TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
          tt-it-docto.vl-pretab           = TrataNuloDec(int_dp_nota_saida_item.nsi_valorbruto_n) / TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
          tt-it-docto.vl-preuni           = TrataNuloDec(int_dp_nota_saida_item.nsi_valorliquido_n) / TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
          tt-it-docto.vl-tot-item         = tt-it-docto.vl-merc-liq + (if i-esp-docto = 20 /* devolucao */ then TrataNuloDec(int_dp_nota_saida_item.nsi_icmsst_n) else 0)
          tt-it-docto.ind-imprenda        = no
          tt-it-docto.mercliq-moeda-forte = 0
          tt-it-docto.mercori-moeda-forte = 0
          tt-it-docto.merctab-moeda-forte = 0
          tt-it-docto.vl-taxa-exp         = 0
          tt-it-docto.vl-desconto         = TrataNuloDec(int_dp_nota_saida_item.nsi_desconto_n)
          tt-it-docto.desconto            = TrataNuloDec(int_dp_nota_saida_item.nsi_desconto_n)
          tt-it-docto.vl-desconto-perc    = 0
          tt-it-docto.nr-pedcli           = "".

   create tt-it-imposto.
   assign tt-it-imposto.seq-tt-it-docto   = i-nr-sequencia
          tt-it-imposto.aliquota-icm      = TrataNuloDec(int_dp_nota_saida_item.nsi_percentualicms_n)
          tt-it-imposto.aliquota-ipi      = TrataNuloDec(int_dp_nota_saida_item.nsi_percentualipi_n)
          tt-it-imposto.cd-trib-icm       = i-cd-trib-icm
          tt-it-imposto.cd-trib-iss       = 2 /* isento */
          tt-it-imposto.cod-servico       = 0
          tt-it-imposto.ind-icm-ret       = no /* ---------------------------------------------------------------verificar na devolucao a fornecedor e trnasferencias */
          tt-it-imposto.per-des-icms      = 0
          tt-it-imposto.perc-red-icm      = TrataNuloDec(int_dp_nota_saida_item.nsi_redutorbaseicms_n)
          tt-it-imposto.perc-red-iss      = 0
          tt-it-imposto.vl-bicms-ent-fut  = 0
          tt-it-imposto.vl-bicms-it       = if i-cd-trib-icm = 1 or i-cd-trib-icm = 4 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseicms_n) else 0
          tt-it-imposto.vl-icms-it        = if i-cd-trib-icm = 1 or i-cd-trib-icm = 4 then TrataNuloDec(int_dp_nota_saida_item.nsi_valoricms_n) else 0
          tt-it-imposto.vl-icms-outras    = if i-cd-trib-icm = 3 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseicms_n) else
                                            if TrataNuloDec(int_dp_nota_saida_item.nsi_redutorbaseicms_n) <> 0 
                                            then TrataNuloDec(int_dp_nota_saida_item.nsi_valorliquido_n - int_dp_nota_saida_item.nsi_baseicms_n)
                                            else 0                                                                 
          tt-it-imposto.vl-icmsou-it      = tt-it-imposto.vl-icms-outras
          tt-it-imposto.vl-icmsnt-it      = if i-cd-trib-icm = 2 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseicms_n) else 0
          tt-it-imposto.cd-trib-ipi       = i-cd-trib-ipi
          tt-it-imposto.perc-red-ipi      = 0
          tt-it-imposto.vl-bipi-ent-fut   = 0
          tt-it-imposto.vl-ipi-ent-fut    = 0
          tt-it-imposto.vl-bipi-it        = if i-cd-trib-ipi = 1 or i-cd-trib-ipi = 4 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseipi_n) else 0
          tt-it-imposto.vl-ipi-it         = TrataNuloDec(int_dp_nota_saida_item.nsi_valoripi_n)
          tt-it-imposto.vl-ipi-outras     = if i-cd-trib-ipi = 3 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseipi_n) else 0
          tt-it-imposto.vl-ipiou-it       = tt-it-imposto.vl-ipi-outras
          tt-it-imposto.vl-ipint-it       = if i-cd-trib-ipi = 2 then TrataNuloDec(int_dp_nota_saida_item.nsi_baseipi_n) else 0.

   assign tt-it-imposto.vl-biss-it        = 0
          tt-it-imposto.vl-bsubs-ent-fut  = 0
          tt-it-imposto.vl-bsubs-it       = if i-esp-docto <> 20 /* devolucao */ then TrataNuloDec(int_dp_nota_saida_item.nsi_basest_n) else 0
          tt-it-imposto.icm-complem       = 0
          tt-it-imposto.vl-icms-ent-fut   = 0
          tt-it-imposto.vl-icmsub-ent-fut = 0
          tt-it-imposto.vl-icmsub-it      = if i-esp-docto <> 20 /* devolucao */ then TrataNuloDec(int_dp_nota_saida_item.nsi_icmsst_n) else 0
          tt-it-imposto.aliq-icm-comp     = 0
          tt-it-imposto.aliquota-iss      = 0
          tt-it-imposto.vl-irf-it         = 0
          tt-it-imposto.vl-iss-it         = 0
          tt-it-imposto.vl-issnt-it       = 0
          tt-it-imposto.vl-issou-it       = 0
          tt-it-docto.desconto-zf         = 0
          tt-it-docto.narrativa           = TrataNuloChar(int_dp_nota_saida_item.nsi_lote_s).

   /*  CSTÔs */
   assign  overlay(tt-it-docto.char-1,75,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbipi_n,"99"))
           overlay(tt-it-docto.char-1,77,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbpis_s,"99"))
           overlay(tt-it-docto.char-1,79,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbcofins_s,"99")).

   /* Modalidades de base */
   assign  overlay(tt-it-docto.char-1,81,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbcicms_n))
           overlay(tt-it-docto.char-1,85,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbcst_n))
           overlay(tt-it-docto.char-1,83,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbipi_n)).

   /* Tributaá∆o PIS    */ 
   overlay(tt-it-docto.char-2,96,1) = if int_dp_nota_saida_item.nsi_valorpis_n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,76,5) = string(TrataNuloDec(int_dp_nota_saida_item.nsi_percentualpis_n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,76,5)) = 0 then
       overlay(tt-it-docto.char-2,96,1) = "2".

   /* Tributaá∆o COFINS */
   overlay(tt-it-docto.char-2,97,1) = if int_dp_nota_saida_item.nsi_valorcofins_n > 0 then "1" else "2".
   overlay(tt-it-docto.char-2,81,5) = string(TrataNuloDec(int_dp_nota_saida_item.nsi_percentualcofins_n),"99.99").

   /* sem aliquota deve ficar como isento */
   if dec(substring(tt-it-docto.char-2,81,5)) = 0 then 
       overlay(tt-it-docto.char-2,97,1) = "2" .

   overlay(tt-it-docto.char-2,86,5)  /* Reduá∆o PIS       */ = "00,00".
   overlay(tt-it-docto.char-2,91,5)  /* Reduá∆o COFINS    */ = "00,00".

   /* Unidade de Negocio */
   assign overlay(tt-it-docto.char-2,172,03) = "000"
          tt-it-imposto.vl-pauta             = 0.

   if  item.tipo-contr <> 4 /* debito direto */ and int_dp_nota_saida.tipo_movto <> 3 /* cancelamento */ and
       int_dp_nota_saida.ped_tipopedido_n <> 48 /* substituicao de cupom */ and
       tt-it-docto.baixa-estoq then do:
       if item.tipo-con-est = 3 /* lote */ then
       for first saldo-estoq fields (dt-vali-lote) no-lock where 
           saldo-estoq.cod-estabel = c-cod-estabel and
           saldo-estoq.cod-depos   = "LOJ" and
           saldo-estoq.cod-localiz = "" and
           saldo-estoq.cod-refer   = "" and
           saldo-estoq.it-codigo   = c-it-codigo and
           saldo-estoq.lote        = int_dp_nota_saida_item.nsi_lote_s
           query-tuning(no-lookahead):
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = TrataNuloChar(int_dp_nota_saida_item.nsi_lote_s)
                  tt-saldo-estoq.dt-vali-lote       = saldo-estoq.dt-vali-lote
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n).
       end.
       if not avail saldo-estoq /*and l-saldo-neg avb 18/09/2017 */ then do:
           create tt-saldo-estoq.
           assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
                  tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
                  tt-saldo-estoq.it-codigo          = c-it-codigo
                  tt-saldo-estoq.cod-depos          = "LOJ"
                  tt-saldo-estoq.cod-localiz        = ""
                  tt-saldo-estoq.lote               = if item.tipo-con-est = 3 /* lote */ then int_dp_nota_saida_item.nsi_lote_s else ""
                  tt-saldo-estoq.dt-vali-lote       = if item.tipo-con-est = 3 /* lote */ then today else ?
                  tt-saldo-estoq.quantidade         = TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)
                  tt-saldo-estoq.qtd-contada        = TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n).
       end.
       /*************** Baixa do Estoque *************************************/
       if  tt-it-docto.baixa-estoq then do:

           for first tt-saldo-estoq no-lock where
               tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia and
               tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia and
               tt-saldo-estoq.it-codigo          = c-it-codigo    and
               tt-saldo-estoq.cod-depos          = "LOJ"          and
               tt-saldo-estoq.cod-localiz        = ""
               query-tuning(no-lookahead):                        end.
           if not avail tt-saldo-estoq then do:
               return.
           end.
       end.
   end.

end.

procedure pi-valida-cabecalho:

    if int_dp_nota_saida.nsa_dataemissao_d = ? then do: 
        run pi-gera-log (input "Data de emiss∆o em branco: " 
                         + "CNPJ: "      + int_dp_nota_saida.nsa_cnpj_origem_s
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                         input 1).
        return.
    end.

    if int_dp_nota_saida.ped_codigo <> ? and
       int_dp_nota_saida.ped_codigo <> 0  then do:
        ASSIGN l-int_ds_pedido = NO.
        for first int_ds_pedido no-lock where 
                  int_ds_pedido.ped_codigo_n = int_dp_nota_saida.ped_codigo_n: 
        end.
        if not avail int_ds_pedido then do:
           for first int_ds_pedido_subs no-lock where 
                     int_ds_pedido_subs.ped_codigo_n = int_dp_nota_saida.ped_codigo_n: 
           end.
           IF NOT AVAIL int_ds_pedido_subs THEN DO:
              run pi-gera-log (input "Pedido ainda n∆o est† na base de integraá∆o: " 
                               + "CNPJ: "      + int_dp_nota_saida.nsa_cnpj_origem_s
                               + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                               + " Numero: "   + c-num-nota
                               + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                               input 1).
              return.
           END.
        end.
        ELSE 
           ASSIGN l-int_ds_pedido = YES.
        i-cont-item-ped = 0.
        i-cont-item-nf  = 0.
        IF l-int_ds_pedido = YES THEN DO:
           for each int_ds_pedido_produto no-lock of int_ds_pedido,
               each int_ds_pedido_retorno no-lock of int_ds_pedido_produto:
               i-cont-item-ped = i-cont-item-ped + int_ds_pedido_retorno.rpp_quantidade.
           end.
           for each int_dp_nota_saida_item no-lock of int_dp_nota_saida:
               i-cont-item-nf  = i-cont-item-nf  + int_dp_nota_saida_item.nsi_quantidade_n.
           end.
           if i-cont-item-ped <> i-cont-item-nf then do:
               run pi-gera-log (input "Quantidades diferentes entre Pedido e Nota Fiscal: " 
                                + "CNPJ: "      + int_dp_nota_saida.nsa_cnpj_origem_s
                                + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                                + " Numero: "   + c-num-nota
                                + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                                + " Qtd Nf: "   + string(i-cont-item-nf)
                                + " Qtd Pd: "   + string(i-cont-item-ped),
                                input 1).
               return.
           end.
        END.
    end.

    c-cod-estabel = "".
    d-dt-procfit  = ?.
    i-ep-codigo   = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                    0 &else "" &endif. 
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_dp_nota_saida.nsa_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_dp_nota_saida.nsa_dataemissao_d
        query-tuning(no-lookahead):
        c-cod-estabel  = estabelec.cod-estabel.
        i-ep-codigo    = estabelec.ep-codigo.
        d-dt-procfit   = cst_estabelec.dt_inicio_oper.
        leave.
    end.

    if c-cod-estabel = "" then do:
        run pi-gera-log (input "Estabelecimento Origem n∆o cadastrado ou fora de operaá∆o." 
                                + " CNPJ: "     + int_dp_nota_saida.nsa_cnpj_origem_s
                                + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                                + " Numero: "   + c-num-nota
                                + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                         input 1).
        return.
    end.

    
    if d-dt-procfit = ? or d-dt-procfit > int_dp_nota_saida.nsa_dataemissao_d then do:
        run pi-gera-log (input "Estabelecimento Origem n∆o Ç Procfit na data de emiss∆o." 
                               + " Est: "      + c-cod-estabel 
                               + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                               + " Numero: "   + c-num-nota
                               + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                               + " Data: "     + string(int_dp_nota_saida.nsa_dataemissao_d,"99/99/9999"),
                         input 1).
        return.
    end.

    c-uf-origem = "".
    for first emitente fields (cod-emitente nome-abrev estado identific) no-lock where 
        emitente.cgc = int_dp_nota_saida.nsa_cnpj_origem_s,
        first dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1
        query-tuning(no-lookahead): 
        c-uf-origem  = emitente.estado.
    end.
    if not avail emitente then do:
        run pi-gera-log (input "Fornecedor n∆o cadastrado ou inativo." 
                               + " Est: "      + c-cod-estabel 
                               + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s
                               + " Numero: "   + c-num-nota
                               + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                               + " Fornec: "   + string(int_dp_nota_saida.nsa_cnpj_origem_s),
                         input 1).
    end.
    if emitente.identific = 1 then do:     /* Cliente */
        run pi-gera-log (input "Emitente do estabelecimento origem Ç cliente: " 
                         + "Est: "      + c-cod-estabel
                         + " SÇrie: "   + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "  + c-num-nota
                         + " Pedido: "  + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Emit: "    + string(emitente.cod-emitente),
                         input 1).
        return.                                 
    end.

    for each nota-fiscal no-lock where 
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = int_dp_nota_saida.nsa_serie_s and
        nota-fiscal.nr-nota-fis = c-num-nota
        query-tuning(no-lookahead):
        run pi-gera-log (input "Documento j† cadastrado: " 
                         + "Est: "      + nota-fiscal.cod-estabel
                         + " SÇrie: "   + nota-fiscal.serie 
                         + " Numero: "  + nota-fiscal.nr-nota-fis
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                         input 2).
        for each bint_dp_nota_saida where
            bint_dp_nota_saida.nsa_cnpj_origem_s  = int_dp_nota_saida.nsa_cnpj_origem_s and
            bint_dp_nota_saida.nsa_serie_s        = int_dp_nota_saida.nsa_serie_s       and
            bint_dp_nota_saida.nsa_notafiscal_n   = int_dp_nota_saida.nsa_notafiscal_n
            query-tuning(no-lookahead):
            assign  bint_dp_nota_saida.situacao = 2 /* processada */.
            for each int_ds_pedido_subs exclusive-lock where 
                int_ds_pedido_subs.ped_codigo_n = bint_dp_nota_saida.ped_codigo_n
                query-tuning(no-lookahead):
                assign int_ds_pedido_subs.situacao = 2.
            end.
            for each int_ds_pedido exclusive-lock where 
                int_ds_pedido.ped_codigo_n = bint_dp_nota_saida.ped_codigo_n
                query-tuning(no-lookahead):
                assign int_ds_pedido.situacao = 2.
            end.
            release bint_dp_nota_saida.
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
        emitente.cgc = int_dp_nota_saida.nsa_cnpj_destino_s
        query-tuning(no-lookahead):
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
        run pi-gera-log (input "Cliente n∆o cadastrado ou inativo." 
                         + "Est: "      + c-cod-estabel
                         + " SÇrie: "   + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "  + c-num-nota
                         + " Pedido: "  + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Cliente: " + string(int_dp_nota_saida.nsa_cnpj_destino_s),
                         input 1).
        return.
    end.

    for first param-estoq no-lock query-tuning(no-lookahead): 
        if month (param-estoq.ult-fech-dia) = 12 then 
            assign c-aux = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
        else
            assign c-aux = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").

        if param-estoq.ult-fech-dia >= int_dp_nota_saida.nsa_dataemissao_d or
           param-estoq.mensal-ate >= int_dp_nota_saida.nsa_dataemissao_d or
          (c-aux = string(year(int_dp_nota_saida.nsa_dataemissao_d),"9999") + string(month(int_dp_nota_saida.nsa_dataemissao_d),"99") and
          (param-estoq.fase-medio <> 1 or param-estoq.pm-j†-ini = yes))
        then do:

            run pi-gera-log (input "Documento em per°odo fechado ou em fechamento. " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                             + " Numero: "   + c-num-nota
                             + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                             + " Data: "     + string(int_dp_nota_saida.nsa_dataemissao_d,"99/99/9999"),
                             input 1).
            return.
        end.
    end.

    for first ser-estab no-lock where
        ser-estab.serie = trim(int_dp_nota_saida.nsa_serie_s) and
        ser-estab.cod-estabel = c-cod-estabel
        query-tuning(no-lookahead): 
    end.
   if not avail ser-estab then do:
       run pi-gera-log (input "SÇrie n∆o cadastrada para estabelecimento: " 
                        + "Est: "       + c-cod-estabel
                        + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                        + " Numero: "   + c-num-nota
                        + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                        input 1).
       return.
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
            
    if int_dp_nota_saida.nsa_chaveacesso_s  /* chave acesso */ = ? and 
        int_dp_nota_saida.tipo_movto <> 3 then do:
        l-servico = no.
        for each int_dp_nota_saida_item no-lock of int_dp_nota_saida
            query-tuning(no-lookahead).
            for first item no-lock where
                item.it-codigo = c-it-codigo query-tuning(no-lookahead): end.
            if avail item and item.tipo-contr <> 4 then do:
                l-servico = no.
                leave.
            end.
            l-servico = yes.
        end.
        if l-servico then next.
        if int_dp_nota_saida.ped_tipopedido_n = 70 /* inutilizaao */ then next.
        run pi-gera-log (input "Nota fiscal sem chave de acesso: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                         input 1).
        return.
    end.               

    assign c-nome-transp = "PADRAO".
    if int_dp_nota_saida.nsa_cnpj_transportadora_s <> ? then
    for first emitente fields (nome-abrev) no-lock where
        emitente.cgc = trim(int_dp_nota_saida.nsa_cnpj_transportadora_s)
        query-tuning(no-lookahead):
        assign c-nome-transp = emitente.nome-abrev.    
    end.
    if not avail emitente then do:
        run pi-gera-log (input "Transportador NAO cadastrado: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Transp: "   + int_dp_nota_saida.nsa_cnpj_transportadora_s,
                         input 1).
        return.
    end.

    /*
    assign  d-dt-comp    = ?
            c-nat-origem = "".
    if  int_dp_nota_saida.nen_notafiscalorigem_n <> 0 and
       (int_dp_nota_saida.nsa_cupomorigem_s = "" or int_dp_nota_saida.nsa_cupomorigem_s = ?) 
    then do:
        for each docum-est fields (dt-emissao nat-operacao) no-lock where 
            docum-est.serie-docto  = int_dp_nota_saida.nen_serieorigem_s and
            docum-est.nro-docto    = trim(string(int_dp_nota_saida.nen_notafiscalorigem_n,">>>9999999")) and
            docum-est.cod-emitente = i-cod-emitente
            query-tuning(no-lookahead): 
            assign  d-dt-comp      = docum-est.dt-emissao
                    c-nat-origem   = docum-est.nat-operacao.
        end.
        if c-nat-origem = "" then do:
            run pi-gera-log (input "Documento origem n∆o encontrado: " 
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                             + " Numero: "   + c-num-nota
                             + " Nota: "     +  trim(string(int_dp_nota_saida.nen_notafiscalorigem_n,">>>9999999")),
                             input 1).
            next.
        end.
    end.
    */

end procedure.

procedure pi-valida-item.

    c-it-codigo = trim(string(int_dp_nota_saida_item.nsi_produto_n)).
    run pi-acompanhar in h-acomp (input "Validando Itens:" + 
                                        c-cod-estabel + "/" + 
                                        int_dp_nota_saida.nsa_serie_s + "/" + 
                                        c-num-nota + "/" + c-it-codigo).
    
    if c-it-codigo <> ""    and
       c-it-codigo <> ?     and 
       c-it-codigo <> "0"   then do:
        for first item 
            no-lock where 
            item.it-codigo = c-it-codigo query-tuning(no-lookahead): end.
        if not avail item then do:
            run pi-gera-log (input "Item n∆o cadastrado: " 
                            + "Est: "       + c-cod-estabel
                            + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                            + " Numero: "   + c-num-nota
                            + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                            + " Item: "     + c-it-codigo,
                             input 1).
            next.
        end.
    end.
    else do:
        run pi-gera-log (input "Item Nissei n∆o informado: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + if c-it-codigo <> ? then c-it-codigo else "?",
                         input 1).
        next.
    end.

    /*
    if avail item and item.cod-obsoleto = 4 then do:
        run pi-gera-log (input "Item est† obsoleto: " + trim(item.it-codigo),
                         input 1).
        next.
    end.     
    */

    if int_dp_nota_saida_item.nsi_ncm_s = "" then do:
        run pi-gera-log (input "NCM do Item n∆o informada: "
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo,
                         input 1).
        next.
    end.

    c-class-fiscal = TrataNuloChar(int_dp_nota_saida_item.nsi_ncm_s).
    if not can-find(classif-fisc where 
                    classif-fisc.class-fiscal = c-class-fiscal) then do:
        run pi-gera-log (input "NCM do Item n∆o cadasrrada: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo 
                         + " NCM: "      + int_dp_nota_saida_item.nsi_ncm_s,
                         input 1).
        next.
    end.

    if int_dp_nota_saida_item.nsi_valorbruto_n < int_dp_nota_saida_item.nsi_desconto_n then do:
        run pi-gera-log (input "Valor desconto maior que o valor bruto: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo 
                         + " Vl Bruto: " + string(int_dp_nota_saida_item.nsi_valorbruto_n,"->>>,>>>,>>9.99")
                         + " Desconto: " + string(int_dp_nota_saida_item.nsi_desconto_n,"->>>,>>>,>>9.99"),
                         input 1).
        next.
    end.
    
    for first item-uni-estab no-lock where 
              item-uni-estab.cod-estabel = c-cod-estabel and
              item-uni-estab.it-codigo = c-it-codigo query-tuning(no-lookahead): end.
    if not avail item-uni-estab THEN DO:
       for first item-estab NO-LOCK where 
                 item-estab.cod-estabel = c-cod-estabel and
                 item-estab.it-codigo = c-it-codigo query-tuning(no-lookahead): end.
    end.
    if not avail item-estab and not avail item-uni-estab then do:
       run pi-gera-log (input "Item n∆o cadastrado no estabelecimento." 
                        + "Est: "       + c-cod-estabel
                        + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                        + " Numero: "   + c-num-nota
                        + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                        + " Item: "     + c-it-codigo,
                        input 1).
       next.
    end.
    if item-uni-estab.ind-item-fat = no then do:
        run pi-gera-log (input "Item n∆o fatur†vel no estabelecimento."
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo,
                         input 1).
        next.
    end.

    i-cfop = int_dp_nota_saida_item.nsi_cfop_n.
    if i-cfop = ? then do:
        run pi-gera-log (input "CFOP do Item n∆o informada."
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo,
                         input 1).
        next.
    end.

    assign  c-nat-comp   = ""
            d-dt-comp    = ?
            c-nat-origem = "".
    if  int_ds_mod_pedido.log_nat_origem or
       (int_dp_nota_saida.nen_notafiscalorigem_n <> 0 and int_dp_nota_saida.nen_notafiscalorigem_n <> ? and
        (int_dp_nota_saida.nsa_cupomorigem_s = "" or int_dp_nota_saida.nsa_cupomorigem_s = ?)
        ) 
    then do:
        for first item-doc-est no-lock where 
            item-doc-est.cod-emitente = i-cod-emitente  and
            item-doc-est.nro-docto    = c-nota-origem and
            item-doc-est.serie-docto  = TrataNuloChar(int_dp_nota_saida.nen_serieorigem_s) and
            item-doc-est.it-codigo    = TrataNuloChar(c-it-codigo) query-tuning(no-lookahead):
            assign  c-nat-comp   = item-doc-est.nat-operacao.
                    c-nat-origem = item-doc-est.nat-of.
            for each docum-est no-lock of item-doc-est query-tuning(no-lookahead):
                assign d-dt-comp = docum-est.dt-emissao.
            end.
        end.
        if not avail item-doc-est then do:
            run pi-gera-log (input "Documento origem a devolver n∆o localizado: " 
                             + " Ser: " + TrataNuloChar(int_dp_nota_saida.nen_serieorigem_s)
                             + " Docto: " + c-nota-origem
                             + " Emitente: " + string(i-cod-emitente)
                             + " Item: " + TrataNuloChar(c-it-codigo)
                             + " Pedido: " + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                             input 1).
            next.
        end.
    end.


    if  truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valorliquido_n),2) < 0 or
        truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valorbruto_n),2) < 0 or
        truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_valoricms_n),2) < 0 or
        truncate(TrataNuloDec(int_dp_nota_saida_item.nsi_baseicms_n),2) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_valordespesa_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_valorembalagem_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_valorfrete_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_valorseguro_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_baseipi_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_basest_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_valoripi_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_icmsst_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_desconto_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_desconto_n) < 0 or      
        TrataNuloDec(int_dp_nota_saida_item.nsi_percentualicms_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_percentualipi_n)  < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_redutorbaseicms_n) < 0 or
        TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n) < 0 then do:
        run pi-gera-log (input "Valores negativos informados no item: " 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Seq: "      + string(int_dp_nota_saida_item.nsi_sequencia_n)
                         + " Item: "     + c-it-codigo,
                         input 1).

        next.
    end.


    /* determina natureza de operacao */
    run intprg/int115a.p ( input int_ds_tipo_pedido.tp_pedido ,
                           input c-uf-destino   ,
                           input c-uf-origem    ,
                           input c-nat-origem   ,  
                           input i-cod-emitente ,
                           input c-class-fiscal,
                           output c-nat-operacao,
                           output c-nat-entrada ,
                           output r-rowid).
    
    assign  c-cod-esp-princ = ""
            i-esp-docto     = 0.
    for first natur-oper no-lock where 
        natur-oper.nat-operacao = c-nat-operacao query-tuning(no-lookahead): 
        if i-cod-mensagem = 0 then 
            i-cod-mensagem = natur-oper.cod-mensagem.
        assign  c-cod-esp-princ = natur-oper.cod-esp
                i-esp-docto     = if natur-oper.especie-doc = "NFS" then 22 else 
                                    if natur-oper.especie-doc = "NFD" then 20 else 
                                      if natur-oper.especie-doc = "NFT" then 23 else 21 /* NFE */.
    end.
    if not avail natur-oper then do:
        run pi-gera-log (input "Natureza de operaá∆o n∆o cadastrada." 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Nat Oper: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    if avail natur-oper and 
       not natur-oper.nat-ativa then do:
        run pi-gera-log (input "Natureza de operaá∆o inativa."
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Nat Oper: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    /**************** Natureza nío pode ser de entrada ****************/
    if natur-oper.tipo = 1 then do:     /* Entrada */
        run pi-gera-log (input "Natureza de operaá∆o de entrada n∆o permitida."
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Nat Oper: " + c-nat-operacao,
                         input 1).
        next.
    end.
    
    if natur-oper.especie-doc = "NFD" then do:
        if int_dp_nota_saida.nen_notafiscalorigem_n = ? or
           int_dp_nota_saida.nen_notafiscalorigem_n = 0 then do:
            run pi-gera-log (input "Natureza de devolucao sem documento origem."
                             + "Est: "       + c-cod-estabel
                             + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                             + " Numero: "   + c-num-nota
                             + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                             + " Nat Oper: " + c-nat-operacao,
                             input 1).
            next.
        end.
    end.

    
    if can-find (first int_dp_nota_saida_dup of int_dp_nota_saida) and
       not natur-oper.emite-duplic then do:
        run pi-gera-log (input "Duplicatas informadas e Natureza de operaá∆o n∆o emite duplicatas."
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Nat Oper: " + c-nat-operacao,
                         input 1).
        next.
    end.

    /******************************************/
    if TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n) <= 0 then do:
        run pi-gera-log (input "Quantidade do item incorreta." 
                         + "Est: "       + c-cod-estabel
                         + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                         + " Numero: "   + c-num-nota
                         + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n))
                         + " Item: "     + c-it-codigo 
                         + " Qtde: "     + string(TrataNuloDec(int_dp_nota_saida_item.nsi_quantidade_n)),
                         input 1).
       next.
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
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
   empty temp-table tt-nota-fiscal-adc.
end.        

procedure pi-importa-nota.
    
    run pi-acompanhar in h-acomp (input "Gerando Nota").

    for first tt-docto query-tuning(no-lookahead): end.
    for first tt-it-docto query-tuning(no-lookahead): end.
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

        for each tt-notas-geradas query-tuning(no-lookahead):
            for each nota-fiscal exclusive-lock where 
                rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal 
                query-tuning(no-lookahead):
                run pi-acompanhar in h-acomp (input "Verifica Nota: " + nota-fiscal.nr-nota-fis).

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

                /* Acerto n£mero do pedido e campos adicionais */
                for each bint_dp_nota_saida exclusive-lock where
                    bint_dp_nota_saida.nsa_cnpj_origem_s = int_dp_nota_saida.nsa_cnpj_origem_s and
                    bint_dp_nota_saida.nsa_serie_s       = int_dp_nota_saida.nsa_serie_s       and
                    bint_dp_nota_saida.nsa_notafiscal_n  = int_dp_nota_saida.nsa_notafiscal_n
                    query-tuning(no-lookahead):

                    /* acertando numero do pedido */
                    if nota-fiscal.nr-pedcli = "" then do:
                        assign nota-fiscal.nr-pedcli = trim(string(int_dp_nota_saida.ped_codigo_n)).
                    end.

                    for each it-nota-fisc of nota-fiscal exclusive-lock
                        query-tuning(no-lookahead):
                        assign it-nota-fisc.nr-pedcli = nota-fiscal.nr-pedcli.

                        /* acertando campos n∆o suportados na ft2010 */
                        for each int_dp_nota_saida_item no-lock of bint_dp_nota_saida where
                            int_dp_nota_saida_item.nsi_sequencia_n = it-nota-fisc.nr-seq-fat and
                            int_dp_nota_saida_item.nsi_produto_n = int64(it-nota-fisc.it-codigo)
                            query-tuning(no-lookahead):

                            /* CSTÔs e Modalidades de base de c†lculo */
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                assign  it-nota-fisc.cod-sit-tributar-ipi     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbipi_n,"99"))
                                        it-nota-fisc.cod-sit-tributar-pis     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbpis_s,"99"))
                                        it-nota-fisc.cod-sit-tributar-cofins  = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbcofins_s,"99")).

                                assign  it-nota-fisc.idi-modalid-base-icms    = TrataNuloDec(int_dp_nota_saida_item.nsi_modbcicms_n)
                                        it-nota-fisc.idi-modalid-base-icms-st = TrataNuloDec(int_dp_nota_saida_item.nsi_modbcst_n)  
                                        it-nota-fisc.idi-modalid-base-ipi     = TrataNuloDec(int_dp_nota_saida_item.nsi_modbipi_n).  
                            &else
                                assign  overlay(it-nota-fisc.char-1,75,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbipi_n,"99"))
                                        overlay(it-nota-fisc.char-1,77,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbpis_s,"99"))
                                        overlay(it-nota-fisc.char-1,79,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_cstbcofins_s,"99")).

                                assign  overlay(it-nota-fisc.char-1,81,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbcicms_n))
                                        overlay(it-nota-fisc.char-1,85,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbcst_n))
                                        overlay(it-nota-fisc.char-1,83,2)     = TrataNuloChar(string(int_dp_nota_saida_item.nsi_modbipi_n)).
                            &endif
                            
                            /* PIS/COFINS */
                            assign overlay(it-nota-fisc.char-2,96,1)          = if int_dp_nota_saida_item.nsi_percentualpis_n > 0 then "1" else "2" /* Tributaá∆o PIS    */ 
                                   overlay(it-nota-fisc.char-2,76,5)          = string (int_dp_nota_saida_item.nsi_percentualpis_n,"99.99") /* Aliquota PIS */.
                        
                            assign overlay(it-nota-fisc.char-2,97,1)          = if int_dp_nota_saida_item.nsi_percentualcofins_n > 0 then "1" else "2" /* Tributaá∆o COFINS */
                                   overlay(it-nota-fisc.char-2,81,5)          = string(int_dp_nota_saida_item.nsi_percentualcofins_n,"99.99").
                        
                            assign overlay(it-nota-fisc.char-2,86,5)  /* Reduá∆o PIS    */ = "00,00".
                                   overlay(it-nota-fisc.char-2,91,5)  /* Reduá∆o COFINS */ = "00,00".
                        end.
                    end.

                    /* Marcando integraá∆o processada nos pedidos e na nota */
                    for each int_ds_pedido where 
                        int_ds_pedido.ped_codigo_n = int_dp_nota_saida.ped_codigo_n and
                        int_ds_pedido.situacao <> 2 
                        query-tuning(no-lookahead):
                        assign int_ds_pedido.situacao = 2.
                    end.
                    for each int_ds_pedido_subs where 
                        int_ds_pedido_subs.ped_codigo_n = int_dp_nota_saida.ped_codigo_n and
                        int_ds_pedido_subs.situacao <> 2
                        query-tuning(no-lookahead):
                        assign int_ds_pedido_subs.situacao = 2.
                    end.
                    assign bint_dp_nota_saida.situacao = 2.
                    
                    /* integraá‰es Oblak e CD */
                    if nota-fiscal.esp-docto = 23 /* NFT */ then do:
                        for first estabelec no-lock where estabelec.cod-estabel = nota-fiscal.cod-estabel: end.
                        for each bestabelec no-lock where bestabelec.cgc = nota-fiscal.cgc
                            query-tuning(no-lookahead):
                            /* Destino CD */
                            if bestabelec.cod-estabel = "973" then RUN pi-entrada-cd(2 /* Sit Docto */, 2 /* Sit Envio_status integrado - somente para retorno posterior da conferencia */).
                            else do: /* Destino Lojas */
                                for each cst_estabelec no-lock WHERE 
                                         cst_estabelec.cod_estabel      = bestabelec.cod-estabel AND
                                         cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota query-tuning(no-lookahead):
                                    /* Destino Loja Oblak */
                                    if cst_estabelec.dt_inicio_oper = ? or 
                                       cst_estabelec.dt_inicio_oper > nota-fiscal.dt-emis-nota then
                                        RUN pi-saidas("PROCFIT", /* origem */
                                                      1, /* situacao saida Oblak - Deixar ativo pois eles usam saida e entrada para dar entrada */
                                                      2, /* situacao saida Procfit - N∆o integrar pois eles mesmo emitiram a nota */
                                                      1, /* situacao entrada Oblak */
                                                      2  /* situacao entrada Procfit - N∆o integrar pois eles mesmo emitiram a nota  */).
                                    /* Destino Loja Procfit */
                                    if cst_estabelec.dt_inicio_oper <= nota-fiscal.dt-emis-nota then
                                        RUN pi-saidas("PROCFIT", /* origem */
                                                      2, /* situacao saida Oblak - evita integrar nota na Oblak */
                                                      2, /* situacao saida Procfit - evita integrar nota na Procfit - eles emitiram a nota*/
                                                      2, /* situacao entrada Oblak - evita integrar nota na Oblak */                                
                                                      2  /* situacao entrada Procfit */). 
                                end.
                            end.
                        end.
                    end.

                    run pi-gera-log (input "Nota fiscal importada com sucesso: " 
                                     + "Est: "       + c-cod-estabel
                                     + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                                     + " Numero: "   + c-num-nota
                                     + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
                                     input 2).
                    release bint_dp_nota_saida.
                 end.
            end.
        end.

        /* verificando notas n∆o importadas */
        for each tt-docto query-tuning(no-lookahead):
            if not can-find (first nota-fiscal no-lock where
                                   nota-fiscal.cod-estabel = tt-docto.cod-estabel and
                                   nota-fiscal.serie       = tt-docto.serie       and
                                   nota-fiscal.nr-nota-fis = tt-docto.nr-nota) then do:
                run pi-gera-log (input "Nota fiscal NAO importada: " 
                                 + "Est: "       + c-cod-estabel
                                 + " SÇrie: "    + int_dp_nota_saida.nsa_serie_s 
                                 + " Numero: "   + c-num-nota
                                 + " Pedido: "   + TrataNuloChar(string(int_dp_nota_saida.ped_codigo_n)),
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

    if int_dp_nota_saida.tipo_movto <> 3 /* cancelado */ then do:

        for each int_dp_nota_saida_dup no-lock of int_dp_nota_saida
            by int_dp_nota_saida_dup.nsa_vencimento_d
            query-tuning(no-lookahead):
            if int_dp_nota_saida_dup.nsa_valorduplicata_n <= 0 then next.
            
            if int_dp_nota_saida_dup.nsa_vencimento_d < int_dp_nota_saida.nsa_dataemissao_d then do:
                assign int_dp_nota_saida_dup.nsa_vencimento_d = int_dp_nota_saida.nsa_dataemissao_d.
            end.
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = 1
                   tt-fat-duplic.cod-vencto        = 1 /* dias da data */
                   tt-fat-duplic.dt-venciment      = int_dp_nota_saida_dup.nsa_vencimento_d
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = string(i-seq-fat-duplic,"99")
                   tt-fat-duplic.vl-parcela        = TrataNuloDec(int_dp_nota_saida_dup.nsa_valorduplicata_n)
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
        put unformatted
            int_dp_nota_saida.nsa_cnpj_origem_s + "/" + 
            trim(int_dp_nota_saida.nsa_serie_s) + "/" + 
            trim(string(int_dp_nota_saida.nsa_notafiscal_n)) + "/" + 
            int_dp_nota_saida.nsa_cnpj_destino_s + " - " + 
            c-informacao
            skip.
    END.

    RUN intprg/int999.p ("NF PROC", 
                         int_dp_nota_saida.nsa_cnpj_origem_s + "/" + 
                         trim(int_dp_nota_saida.nsa_serie_s) + "/" + 
                         trim(string(int_dp_nota_saida.nsa_notafiscal_n)) + "/" + 
                         int_dp_nota_saida.nsa_cnpj_destino_s,
                         c-informacao,
                         i-situacao, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario,
                         "int217rp.p").
    if i-situacao = 1 then l-erro = yes.
end.

{intprg/int011rp-proc.i} /* pi-saidas */
