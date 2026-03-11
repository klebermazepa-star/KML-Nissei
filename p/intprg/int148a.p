/******************************************************************************
**
**  Programa: INT148A.P
**
**  Objetivo: Carregar informaá‰es das tabelas tempor†rias para impress∆o
**            da NF-e simulada baseado em wt-docto/wtit-docto
**
******************************************************************************/



{include/i-prgvrs.i INT148A 2.00.00.011 } /*** 010011 ***/
{cdp/cdcfgdis.i}

def temp-table tt-documentos no-undo
    field seq-wt-docto as int
    index codigo
          seq-wt-docto. 

def input param table for tt-documentos.

DEF TEMP-TABLE ttArquivo NO-UNDO
      FIELD sequencia   AS INT
      FIELD nomeArquivo AS CHAR
      INDEX idx1 sequencia.

/**** Variaveis ****/
def var iTpAmbSEFAZ                  AS INTEGER     NO-UNDO.
def var c-cod-uf-ibge                AS CHARACTER   NO-UNDO.
def var i-mult-nfe                   AS INTEGER     NO-UNDO.
def var i-count-nfe                  AS INTEGER     NO-UNDO.
def var i-soma-mod-nfe               AS INTEGER     NO-UNDO.
def var i-dig-ver-nfe                AS INTEGER     NO-UNDO.
def var i-cont-itens                 AS INTEGER     NO-UNDO.
def var c-modelo-DANFE               AS CHARACTER   NO-UNDO.
def var c-chave-acesso-adicional-nfe AS CHARACTER   NO-UNDO.
def var i-cont                       AS INTEGER     NO-UNDO.
def var l-sem-Word                   AS LOGICAL     NO-UNDO.
def var c-desc-mod-frete             AS CHARACTER   NO-UNDO.
def var de-vl-merc-liq      like wt-it-docto.vl-merc-liq     no-undo.
def var de-vl-despes-it     like wt-it-docto.vl-despes-it    no-undo.
def var de-vl-tot-item      like wt-it-docto.vl-tot-item     no-undo.
def var de-vl-base-icms     like wt-it-imposto.vl-bicms-it   no-undo.
def var de-vl-icms-it       like wt-it-imposto.vl-icms-it    no-undo.
def var de-vl-icmsnt-it     like wt-it-imposto.vl-icmsnt-it  no-undo.
def var de-vl-icmsou-it     like wt-it-imposto.vl-icmsou-it  no-undo.
def var de-vl-base-ipi      like wt-it-imposto.vl-bipi-it    no-undo.
def var de-vl-ipi-it        like wt-it-imposto.vl-ipi-it     no-undo.
def var de-vl-ipint-it      like wt-it-imposto.vl-ipint-it   no-undo.
def var de-vl-ipiou-it      like wt-it-imposto.vl-ipiou-it   no-undo.
def var de-vl-base-iss      like wt-it-imposto.vl-biss-it    no-undo.
def var de-vl-iss-it        like wt-it-imposto.vl-iss-it     no-undo.
def var de-vl-issnt-it      like wt-it-imposto.vl-issnt-it   no-undo.
def var de-vl-issou-it      like wt-it-imposto.vl-issou-it   no-undo.
def var de-vl-base-subs     like wt-it-imposto.vl-bsubs-it   no-undo.
def var de-vl-icmsub-it     like wt-it-imposto.vl-icmsub-it  no-undo.
def var de-vl-base-imp      like wt-it-docto-imp.vl-base-imp no-undo.
def var de-vl-imposto       like wt-it-docto-imp.vl-imposto  no-undo.
def var de-vl-parcela       like wt-fat-duplic.vl-parcela    no-undo.
def var de-vl-comis         like wt-fat-duplic.vl-comis      no-undo.
def var de-vl-desconto      like wt-fat-duplic.vl-desconto   no-undo.
def var de-vl-tot-frete     like wt-docto.vl-frete           no-undo.
def var de-vl-tot-seguro    like wt-docto.vl-seguro          no-undo.
def var de-vl-tot-embalagem like wt-docto.vl-embalagem       no-undo.
def var de-tot-peso-liq     like wt-docto.peso-liq-tot-inf   no-undo.
def var de-tot-peso-bru     like wt-docto.peso-bru-tot-inf   no-undo.
def var h-acomp             as handle no-undo.

/****  Variaveis Compartilhadas  ****/
DEFINE SHARED VAR r-nota       AS ROWID.
DEFINE SHARED VAR c-hr-saida   AS CHAR    FORMAT "xx:xx:xx" INIT "000000".
DEFINE SHARED VAR l-dt         AS LOGICAL FORMAT "Sim/Nao"  INIT NO.


/*{ftp/INT148A.i5} /* ttDanfe, ttDanfeItem */*/
{ftp/ft0518f.i5} /* ttDanfe, ttDanfeItem */

{ftp/ft0518rp.i1 "NEW"} /* Definiá∆o temp-table ttCaracteres como NEW SHARED */
{ftp/ft0518rp.i2}       /* Criaá∆o registros temp-table ttCaracteres e ttColunasDANFE */

{adapters/xml/ep2/axsep017.i} /*Temp-Tables da NF-e, ttNFe, ttIde, ttDet, etc.*/

/*Temp-Table com todos os campos que s∆o impressos no DANFE, referente ao ICMS*/
DEFINE TEMP-TABLE ttICMSDanfe NO-UNDO  
    FIELD orig           AS CHARACTER INITIAL ?                                         /*origem da mercadoria: 0 - Nacional 1 - Estrangeira - Importaá∆o direta 2 - Estrangeira - Adquirida no mercado interno */
    FIELD CST            AS CHARACTER INITIAL ?                                         /*Tributá∆o pelo ICMS 00 - Tributada integralmente*/
    FIELD vBC            AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>>>>>>9.99" DECIMALS 2   /*Valor da BC do ICMS*/ 
    FIELD vICMS          AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>>>>>>9.99" DECIMALS 2   /*Valor do ICMS*/       
    FIELD pICMS          AS DECIMAL   INITIAL ?  FORMAT ">>9.99"           DECIMALS 2   /*Al°quota do ICMS*/    
    FIELD vBCST          AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>>>>>>9.99" DECIMALS 2   /*Valor da BC do ICMS ST*/ 
    FIELD vICMSST        AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>>>>>>9.99" DECIMALS 2   /*Valor do ICMS ST*/ 
    /*Chave EMS*/
    FIELD CodEstabelNF   AS CHARACTER INITIAL ?
    FIELD SerieNF        AS CHARACTER INITIAL ?
    FIELD NrNotaFisNF    AS CHARACTER INITIAL ?
    FIELD ItCodigoNF     AS CHARACTER INITIAL ?
    FIELD NrSeqFatNF     AS INTEGER   INITIAL ?
    INDEX ch-ttICMSDanfe CodEstabelNF SerieNF NrNotaFisNF NrSeqFatNF ItCodigoNF.

EMPTY TEMP-TABLE ttDanfe.
EMPTY TEMP-TABLE ttDanfeItem.

define buffer bdestino for emitente.
define buffer wt-it-docto for wt-it-docto.


for first param-global no-lock: end.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp(input "Acompanhamento").
run pi-acompanhar in h-acomp("Gerando ESPELHO DANFE").

IF  NOT (iTpAmbSEFAZ > 0) THEN
    ASSIGN iTpAmbSEFAZ = INT(1).
/* Fim - Ambiente (SEFAZ) do envio da Nota */

ASSIGN c-modelo-DANFE = "3".
/* Fim - MODELO DO DANFE*/

for first tt-documentos no-lock: end.
for first wt-docto no-lock where 
    wt-docto.seq-wt-docto = tt-documentos.seq-wt-docto: end.
for first transporte where transporte.nome-abrev = wt-docto.nome-transp: end.
for first estabelec no-lock where estabelec.cod-estabel = wt-docto.cod-estabel: end.
for first emitente no-lock where emitente.cod-emitente = estabelec.cod-emitente: end.
for first bdestino no-lock where bdestino.cod-emitente = wt-docto.cod-emitente: end.

/* Utiliza ou N∆o Word da impress∆o do DANFE */
ASSIGN l-sem-Word     = no.
/* Fim - Utiliza ou N∆o Word da impress∆o do DANFE */

CREATE ttDanfe.
for each wt-it-docto USE-INDEX calcula
    where wt-it-docto.seq-wt-docto = wt-docto.seq-wt-docto 
    and   wt-it-docto.calcula      = yes no-lock,
    each  wt-it-imposto
    where wt-it-imposto.seq-wt-docto    = wt-it-docto.seq-wt-docto
    and   wt-it-imposto.seq-wt-it-docto = wt-it-docto.seq-wt-it-docto no-lock
    break by wt-it-docto.nr-seq-nota
          by wt-it-docto.nr-sequencia
          by wt-it-docto.seq-wt-it-docto: 

    run pi-acompanhar in h-acomp("Gerando ESPELHO DANFE " + wt-it-docto.it-codigo).
    if  first-of(wt-it-docto.nr-seq-nota) then 
        assign de-vl-tot-frete     = 0
               de-vl-tot-seguro    = 0
               de-vl-tot-embalagem = 0
               de-tot-peso-liq     = 0
               de-tot-peso-bru     = 0
               i-cont-itens        = 0
               de-vl-base-icms = 0
               de-vl-icms-it   = 0
               de-vl-icmsnt-it = 0
               de-vl-icmsou-it = 0
               de-vl-base-ipi  = 0
               de-vl-ipi-it    = 0
               de-vl-ipint-it  = 0
               de-vl-ipiou-it  = 0
               de-vl-base-iss  = 0
               de-vl-iss-it    = 0
               de-vl-issnt-it  = 0
               de-vl-issou-it  = 0
               de-vl-base-subs = 0
               de-vl-icmsub-it = 0.

    assign de-vl-tot-frete     = de-vl-tot-frete     + wt-it-docto.vl-frete 
           de-vl-tot-seguro    = de-vl-tot-seguro    + wt-it-docto.vl-seguro
           de-vl-tot-embalagem = de-vl-tot-embalagem + wt-it-docto.vl-embalagem
           de-tot-peso-liq     = de-tot-peso-liq     + wt-it-docto.peso-liq-it-inf 
           de-tot-peso-bru     = de-tot-peso-bru     + wt-it-docto.peso-bru-it-inf.

    assign de-vl-base-icms = de-vl-base-icms + wt-it-imposto.vl-bicms-it
           de-vl-icms-it   = de-vl-icms-it   + wt-it-imposto.vl-icms-it
           de-vl-icmsnt-it = de-vl-icmsnt-it + wt-it-imposto.vl-icmsnt-it
           de-vl-icmsou-it = de-vl-icmsou-it + wt-it-imposto.vl-icmsou-it
           de-vl-base-ipi  = de-vl-base-ipi  + wt-it-imposto.vl-bipi-it
           de-vl-ipi-it    = de-vl-ipi-it    + wt-it-imposto.vl-ipi-it
           de-vl-ipint-it  = de-vl-ipint-it  + wt-it-imposto.vl-ipint-it
           de-vl-ipiou-it  = de-vl-ipiou-it  + wt-it-imposto.vl-ipiou-it
           de-vl-base-iss  = de-vl-base-iss  + wt-it-imposto.vl-biss-it
           de-vl-iss-it    = de-vl-iss-it    + wt-it-imposto.vl-iss-it
           de-vl-issnt-it  = de-vl-issnt-it  + wt-it-imposto.vl-issnt-it
           de-vl-issou-it  = de-vl-issou-it  + wt-it-imposto.vl-issou-it
           de-vl-base-subs = de-vl-base-subs + wt-it-imposto.vl-bsubs-it
           de-vl-icmsub-it = de-vl-icmsub-it + wt-it-imposto.vl-icmsub-it.
    assign de-vl-merc-liq  = de-vl-merc-liq  + wt-it-docto.vl-merc-liq
           de-vl-despes-it = de-vl-despes-it + wt-it-docto.vl-despes-it
           de-vl-tot-item  = de-vl-tot-item  + wt-it-docto.vl-tot-item.

    for first item no-lock where item.it-codigo = wt-it-docto.it-codigo: end.
    CREATE ttDanfeItem.
    ASSIGN ttDanfeItem.iSeq           = i-cont-itens
           ttDanfeItem.cprod          = wt-it-docto.it-codigo
           ttDanfeItem.descitem       = item.desc-item
           ttDanfeItem.ncm            = item.class-fiscal
           ttDanfeItem.cfop           = substring(wt-it-docto.nat-operacao,1,4)
           ttDanfeItem.u              = wt-it-docto.un[1]
           ttDanfeItem.quantitem      = STRING(wt-it-docto.quantidade[1], "->>>,>>>,>>>,>>9.99<<":U).
    ASSIGN ttDanfeItem.vlunit         = STRING(ROUND(DEC(wt-it-docto.vl-preuni),4),">>>>>>>>>>>>>>9.99<<<<<<<<").
    ASSIGN ttDanfeItem.vltotitem      = STRING(wt-it-docto.vl-tot-item, "->>>,>>>,>>>,>>>,>>9.99":U).
    
    ASSIGN /*Tribut†vel*/
           ttDanfeItem.u-trib         = substring(wt-it-docto.char-1,419,2)
           ttDanfeItem.quantitem-trib = STRING(dec(substring(wt-it-docto.char-1,421,20)), "->>>,>>>,>>>,>>9.99<<":U).
    ASSIGN ttDanfeItem.vlunit-trib    = STRING(ROUND(DEC(substring(wt-it-docto.char-1,441,26)),fn-retorna-nro-decimais-nfe-FT0301()),">>>>>>>>>>>>>>9.99<<<<<<<<":U).

    /*--- Valores e Informaá‰es conforme tributaá∆o do ICMS --*/
    ASSIGN ttDanfeItem.vlbcicmit    = STRING(wt-it-imposto.vl-bicms-it  , "->>>,>>>,>>>,>>9.99":U)
           ttDanfeItem.vlicmit      = STRING(wt-it-imposto.vl-icms-it   , "->>>,>>>,>>>,>>9.99":U)
           ttDanfeItem.icm          = if wt-it-imposto.vl-icms-it > 0 then STRING(wt-it-imposto.aliquota-icm , "->>9.99":U) else ""
           ttDanfeItem.vlbcicmit-st = STRING(wt-it-imposto.vl-bsubs-it  , "->>>,>>>,>>>,>>9.99":U)
           ttDanfeItem.vlicmit-st   = STRING(wt-it-imposto.vl-icmsub-it , "->>>,>>>,>>>,>>9.99":U).
    /*--- Fim - Valores e Informaá‰es conforme tributaá∆o do ICMS --*/
    
    /*--- Valores e Informaá‰es de IPI --*/
    ASSIGN ttDanfeItem.vlipiit = STRING(wt-it-imposto.vl-ipi-it         , "->>>,>>>,>>>,>>9.99":U)
           ttDanfeItem.ipi     = if wt-it-imposto.vl-ipi-it > 0 then STRING(wt-it-imposto.aliquota-ipi      , "->>9.99":U) else "".

    for first item fields (codigo-orig cd-trib-icm) no-lock where 
        item.it-codigo = wt-it-docto.it-codigo: end.
    for first natur-oper fields (cd-trib-icm) no-lock where
        natur-oper.nat-operacao = wt-it-docto.nat-operacao: 
        assign ttDanfeItem.s = string(item.codigo-orig).
        case natur-oper.cd-trib-icm:
            when 1 then do:
                if item.cd-trib-icm = 1 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "10".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "00".
                if item.cd-trib-icm = 2 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "30".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "40".
                if item.cd-trib-icm = 3 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "90".
                if item.cd-trib-icm = 4 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "70".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "20".
                if item.cd-trib-icm = 5 then
                    assign ttDanfeItem.s = ttDanfeItem.s + "51".
            end.
            when 2 then do:
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "30".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "40".
            end.
            when 3 then do:
                assign ttDanfeItem.s = ttDanfeItem.s + "90".
            end.
            when 4 then do:
                if item.cd-trib-icm = 2 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "30".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "40".
                if item.cd-trib-icm = 3 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "90".
                if item.cd-trib-icm = 4 or item.cd-trib-icm = 1 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "70".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "20".
                if item.cd-trib-icm = 5 then
                    assign ttDanfeItem.s = ttDanfeItem.s + "51".
            end.
            when 5 then do:
                if item.cd-trib-icm = 2 then
                    if wt-it-imposto.vl-icmsub-it > 0 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "30".
                    else
                        assign ttDanfeItem.s = ttDanfeItem.s + "40".
                if item.cd-trib-icm = 3 then
                        assign ttDanfeItem.s = ttDanfeItem.s + "90".
                if item.cd-trib-icm = 5 or item.cd-trib-icm = 4 or item.cd-trib-icm = 1 then
                    assign ttDanfeItem.s = ttDanfeItem.s + "51".
            end.
        end case.
    end.

    ASSIGN i-cont-itens = i-cont-itens + 1.

    if  last-of(wt-it-docto.nr-seq-nota) then do:

        assign de-vl-parcela  = 0
               de-vl-comis    = 0
               de-vl-desconto = 0
               i-cont         = 1.
        for each  wt-fat-duplic
            where wt-fat-duplic.seq-wt-docto = wt-docto.seq-wt-docto
            and   wt-fat-duplic.nr-seq-nota  = wt-it-docto.nr-seq-nota no-lock
            break by wt-fat-duplic.seq-wt-docto:

            assign de-vl-parcela  = de-vl-parcela  + wt-fat-duplic.vl-parcela
                   de-vl-comis    = de-vl-comis    + wt-fat-duplic.vl-comis
                   de-vl-desconto = de-vl-desconto + wt-fat-duplic.vl-desconto.    

            IF  i-cont = 8 THEN LEAVE. /*Danfe Padr∆o somente com 8 duplicatas. Se houverem mais, sair e nao imprimir. No XML ir∆o todas as fat-duplic existentes*/

            IF  i-cont = 1 THEN                  
                ASSIGN ttDanfe.fatura1  = wt-fat-duplic.parcela 
                       ttDanfe.vencfat1 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")
                       ttDanfe.vlfat1   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).
            IF  i-cont = 2 THEN
                ASSIGN ttDanfe.fatura2  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat2 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat2   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 3 THEN
                ASSIGN ttDanfe.fatura3  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat3 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat3   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 4 THEN
                ASSIGN ttDanfe.fatura4  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat4 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat4   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 5 THEN
                ASSIGN ttDanfe.fatura5  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat5 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat5   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 6 THEN
                ASSIGN ttDanfe.fatura6  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat6 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat6   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 7 THEN
                ASSIGN ttDanfe.fatura7  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat7 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat7   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            IF  i-cont = 8 THEN
                ASSIGN ttDanfe.fatura8  = wt-fat-duplic.parcela                                                 
                       ttDanfe.vencfat8 = STRING(wt-fat-duplic.dt-venciment,"99/99/9999")                           
                       ttDanfe.vlfat8   = TRIM(STRING(wt-fat-duplic.vl-parcela,"->>>>,>>>,>>>,>>9.99")).

            ASSIGN i-cont = i-cont + 1.
        end.
    end.
end.
for first natur-oper fields (denominacao) no-lock where
    natur-oper.nat-operacao = wt-docto.nat-operacao: end.

ASSIGN ttDanfe.chavedeacessonfe          = STRING(0,"99999999999999999999999999999999999999999999")
       ttDanfe.sn                        = ""
       ttDanfe.razaosocialempresa        = estabelec.nome
       ttDanfe.enderecoemp               = estabelec.endereco
       ttDanfe.bairroemp                 = estabelec.bairro
       ttDanfe.cidadeemp                 = estabelec.cidade
       ttDanfe.ufemp                     = estabelec.estado
       ttDanfe.cepemp                    = string(estabelec.cep,"99999999")
       ttDanfe.foneemp                   = emitente.telefone[1]
       ttDanfe.nrnota                    = "0000000"
       ttDanfe.ser                       = "TST"
       ttDanfe.naturezaoperacao          = substring(wt-docto.nat-operacao,1,4) + "-" + 
                                           natur-oper.denominacao
       ttDanfe.inscrestadempresa         = estabelec.ins-estadual
       ttDanfe.inscrestadsubstituto      = "".

assign ttDanfe.cnpjempresa               = (IF param-global.formato-id-federal <> ""
                                            THEN STRING(estabelec.cgc, param-global.formato-id-federal)
                                            ELSE estabelec.cgc)
       ttDanfe.cnpjdestinatario          = if param-global.formato-id-federal <> ""
                                           THEN STRING(bdestino.cgc, param-global.formato-id-federal)
                                           ELSE bdestino.cgc
       ttDanfe.razaosocialdestinatario   = bdestino.nome-emit
       ttDanfe.dataemissao               = STRING(today,"99/99/9999")
       ttDanfe.dataentrega               = STRING(today,"99/99/9999")
       ttDanfe.horasaida                 = "00:00:00"
       ttDanfe.enderecodestinatario      = bdestino.endereco
       ttDanfe.cidadedestinatario        = bdestino.cidade
       ttDanfe.bairrodestinatario        = bdestino.bairro       
       ttDanfe.cepdestinatario           = STRING(bdestino.cep,"99999999")
       ttDanfe.fonedestinatario          = bdestino.telefone[1]
       ttDanfe.ufdest                    = bdestino.estado
       ttDanfe.inscrestaddestinatario    = bdestino.ins-estadual
       ttDanfe.vlbcicmsnota              = TRIM(STRING(de-vl-base-icms ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlicmsnota                = TRIM(STRING(de-vl-icms-it   ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlbcicmsstnota            = TRIM(STRING(de-vl-base-subs ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlicmsstnota              = TRIM(STRING(de-vl-icmsub-it ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vltotprod                 = TRIM(STRING(de-vl-merc-liq  ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlfretenota               = TRIM(STRING(de-vl-tot-frete ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlseguronota              = TRIM(STRING(de-vl-tot-seguro,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vldescontonota            = TRIM(STRING(de-vl-desconto  ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vldespesasnota            = TRIM(STRING(de-vl-despes-it ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vlipinota                 = TRIM(STRING(de-vl-ipi-it    ,"->>>,>>>,>>>,>>9.99"))
       ttDanfe.vltotnota                 = TRIM(STRING(de-vl-tot-item  ,"->>>,>>>,>>>,>>9.99"))

       ttDanfe.nometransp                = if avail transporte then transporte.nome else ""
       ttDanfe.placa1                    = wt-docto.placa
       ttDanfe.ufpl1                     = wt-docto.uf-placa.
       
assign ttDanfe.vltotalsevicos            = TRIM(STRING(0 ,"->>>,>>>,>>>,>>9.99")) 
       ttDanfe.vlbciss                   = TRIM(STRING(0 ,"->>>,>>>,>>>,>>9.99")) 
       ttDanfe.vlisstotal                = TRIM(STRING(0 ,"->>>,>>>,>>>,>>9.99")) 
       ttDanfe.informacoescomplementares = wt-docto.observ-nota
       ttDanfe.homologacao1              = "SEM VALOR FISCAL":U
       ttDanfe.homologacao2              = "Nota Fiscal Eletrìnica de SIMULAÄ«O.":U.

IF (AVAIL transporte AND 
   transporte.nome-abrev <> "Remetente"    AND 
   transporte.nome-abrev <> "Destinat†rio" AND 
   transporte.nome-abrev <> "Destinatario") THEN DO:

   ASSIGN ttDanfe.cnpjtransp                = IF   param-global.formato-id-federal <> ""
                                               THEN STRING(transporte.cgc, param-global.formato-id-federal)
                                               ELSE transporte.cgc
          ttDanfe.enderecotransp            = transporte.endereco
          ttDanfe.cidadetransp              = transporte.cidade
          ttDanfe.uftran                    = transporte.estado
          ttDanfe.inscrestadtransp          = transporte.ins-estadual.
END.
ELSE 
    ASSIGN ttDanfe.cnpjtransp               = ""
           ttDanfe.enderecotransp           = ""
           ttDanfe.cidadetransp             = ""
           ttDanfe.uftran                   = ""
           ttDanfe.inscrestadtransp         = "".


/*=====================================================================================================================================================
  LOCAL DE ENTREGA (quando for diferente do endereáo padr∆o do destinat†rio da nota fiscal) 
=====================================================================================================================================================

FOR FIRST ttEntrega NO-LOCK: /*S¢ haver† registro na ttEntrega na condiá∆o de o local de entrega ser diferente do endereáo do destinatario/cliente da nota*/

    ASSIGN ttDanfe.informacoescomplementares = ttDanfe.informacoescomplementares +
                                               "  LOCAL DE ENTREGA: "    + (ttEntrega.xLgr + " " + ttEntrega.nro + " " + ttEntrega.xCpl) +
                                               " Bairro/Distrito: "      + ttEntrega.xBairro +
                                               " Municipio: "            + ttEntrega.xMun    + 
                                               " UF: "                   + ttEntrega.UF      +
                                               " Pais: "                 + wt-docto.pais.
END.
===================================================================================================================================================*/



/*=====================================================================================================================================================
  MODALIDADE DE FRETE (No XML da NF-e envia-se apenas os C¢digos. No DANFE, imprime-se Codigo + Descricao) 
  
  0 ? Emitente
  1 ? Destinat†rio/Remetente
  2 ? Terceiros
  9 ? Sem Frete
=====================================================================================================================================================*/

CASE string(wt-docto.ind-tp-frete):
    WHEN "0":U THEN
        ASSIGN c-desc-mod-frete = "0 ? Emitente":U.
    WHEN "1":U THEN
        ASSIGN c-desc-mod-frete = "1 ? Destinat†rio/Remetente":U.
    WHEN "2":U THEN
        ASSIGN c-desc-mod-frete = "2 ? Terceiros":U.
    WHEN "9":U THEN
        ASSIGN c-desc-mod-frete = "9 ? Sem Frete":U.
END CASE.

ASSIGN ttDanfe.idfr = c-desc-mod-frete.

/*===================================================================================================================================================*/



/*=====================================================================================================================================================
  VOLUMES E EMBALAGENS
=====================================================================================================================================================*/
assign ttDanfe.especievolume = "".
if ttDanfe.informacoescomplementares matches "*Embalagens:*"
then assign ttDanfe.especievolume = "Vide Observaá‰es".
i-cont = 0.
for each wt-it-docto no-lock of wt-docto:
    for each wt-item-embal no-lock of wt-it-docto:
        assign i-cont = i-cont + 1.
    end.
end.
for each wt-nota-embal no-lock of wt-docto:
    assign i-cont = i-cont + wt-nota-embal.qt-volumes.
    if ttDanfe.especievolume <> "Vide Observaá‰es" then do:
        if wt-nota-embal.desc-vol <> "" then do:
            if ttDanfe.especievolume = "" then
                assign ttDanfe.especievolume = wt-nota-embal.desc-vol.
            else 
                assign ttDanfe.especievolume = ttDanfe.especievolume + "/" + wt-nota-embal.desc-vol.
        end.
        else 
            for first embalag no-lock where 
                embalag.sigla-emb = wt-nota-embal.sigla-emb:
            if ttDanfe.especievolume = "" then
                assign ttDanfe.especievolume = embalag.descricao.
            else                     
                assign ttDanfe.especievolume = ttDanfe.especievolume + "/" + embalag.descricao.
            end.                
    end.
end.
ASSIGN ttDanfe.qtvolume              = if i-cont <> 0 then string(i-cont) else ""
       ttDanfe.marcavolume           = wt-docto.marca-volume
       ttDanfe.numeracaovolume       = wt-docto.nr-volumes
       ttDanfe.pesobrutototal        = TRIM(STRING(
           if wt-docto.peso-bru-tot-inf <> 0 
           then wt-docto.peso-bru-tot-inf
           else de-tot-peso-bru,"->>>,>>>,>>>,>>9.999"))
       ttDanfe.pesoliquidototal      = TRIM(STRING(
           if wt-docto.peso-liq-tot-inf <> 0 
           then wt-docto.peso-liq-tot-inf
           else de-tot-peso-liq,"->>>,>>>,>>>,>>9.999")).

/*
FOR EACH ttVol NO-LOCK
   WHERE ( (ttVol.esp   <> "" AND ttVol.esp   <> ?) /* Valida se existe ao menos uma informacao valida */
     OR    (ttVol.pesoB <> 0  AND ttVol.pesoB <> ?)
     OR    (ttVol.pesoL <> 0  AND ttVol.pesoL <> ?)
     /*OR    (ttVol.qVol  <> "" AND ttVol.qVol  <> ?)*/ )  /*NT2012.003 - tag qVol obrigatoria*/
    BREAK BY ttVol.siglaEmb:

    ACCUMULATE INT(ttVol.qVol) (TOTAL).
    ACCUMULATE     ttVol.pesoB (TOTAL).
    ACCUMULATE     ttVol.pesoL (TOTAL).

    IF  LAST (ttVol.siglaEmb) THEN
        ASSIGN ttDanfe.qtvolume              = TRIM(STRING(ACCUM TOTAL INT(ttVol.qVol),"->>>,>>>,>>>,>>9.99"))
               ttDanfe.marcavolume           = ttVol.marca
               ttDanfe.numeracaovolume       = ttVol.nVol
               ttDanfe.pesobrutototal        = TRIM(STRING(ACCUM TOTAL ttVol.pesoB,"->>>,>>>,>>>,>>9.999"))
               ttDanfe.pesoliquidototal      = TRIM(STRING(ACCUM TOTAL ttVol.pesoL,"->>>,>>>,>>>,>>9.999")).

    IF  ttVol.esp <> ?  AND 
        ttVol.esp <> "" THEN DO:
        IF  ttDanfe.especievolume <> "" THEN
            ttDanfe.especievolume = ttDanfe.especievolume + "/".

        ASSIGN ttDanfe.especievolume = ttDanfe.especievolume + ttVol.esp.
    END.
        
    
END.
/*===================================================================================================================================================*/
*/

/*=====================================================================================================================================================
  PROTOCOLO DE AUTORIZACAO + Data e Hora
=====================================================================================================================================================*/

ASSIGN ttDanfe.protocoloautorizacao = "000000000000000".

/*=====================================================================================================================================================
  INFORMAÄÂES ESPECIAIS PARA EMISS«O EM CONTING“NCIA (VARIAVEIS DOS ARQUIVOS .RTF -> conteudovariavel1 E conteudovariavel2)
=====================================================================================================================================================*/
ASSIGN ttDanfe.conteudovariavel1 = "www.nfe.fazenda.gov.br/portal ou no site da Sefaz Autorizadora":U
       ttDanfe.conteudovariavel2 = "PROTOCOLO DE AUTORIZAÄ«O DE USO":U.
/*===================================================================================================================================================*/
                      

DEFINE BUFFER bf-ttArquivo FOR ttArquivo.

FOR LAST bf-ttArquivo: END.
CREATE ttArquivo.
ASSIGN ttArquivo.sequencia   = IF AVAIL bf-ttArquivo THEN bf-ttArquivo.sequencia + 1 ELSE 1
       ttArquivo.nomeArquivo = TRIM(wt-docto.cod-estabel) + "-" + TRIM(wt-docto.serie) + "-" + TRIM(wt-docto.nr-nota) + "-" + ".doc".


RUN ftp/FT0518F1.p(INPUT TABLE ttDanfe,
                   INPUT TABLE ttDanfeItem,
                   INPUT ttArquivo.nomeArquivo,
                   INPUT c-modelo-Danfe,
                   INPUT l-sem-Word).

run pi-finalizar in h-acomp.
RUN OpenDocument(session:temp-directory + ttArquivo.nomeArquivo).
RETURN "OK":U.
/*fim*/

PROCEDURE OpenDocument:

    def input param c-doc as char  no-undo.
    def var c-exec as char  no-undo.
    def var h-Inst as int  no-undo.

    assign c-exec = fill("x",255).
    run FindExecutableA (input c-doc,
                         input "",
                         input-output c-exec,
                         output h-inst).

    if h-inst >= 0 and h-inst <=32 then
      run ShellExecuteA (input 0,
                         input "open",
                         input "rundll32.exe",
                         input "shell32.dll,OpenAs_RunDLL " + c-doc,
                         input "",
                         input 1,
                         output h-inst).

    run ShellExecuteA (input 0,
                       input "open",
                       input c-doc,
                       input "",
                       input "",
                       input 1,
                       output h-inst).
    if h-inst < 0 or h-inst > 32 then return "OK".
    else return "NOK".

END PROCEDURE.

PROCEDURE FindExecutableA EXTERNAL "Shell32.dll" persistent:

    define input parameter lpFile as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input-output parameter lpResult as char  no-undo.
    define return parameter hInstance as long.

END.

PROCEDURE ShellExecuteA EXTERNAL "Shell32.dll" persistent:

    define input parameter hwnd as long.
    define input parameter lpOperation as char  no-undo.
    define input parameter lpFile as char  no-undo.
    define input parameter lpParameters as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input parameter nShowCmd as long.
    define return parameter hInstance as long.

END PROCEDURE.

