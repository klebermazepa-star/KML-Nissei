/******************************************************************************/
{include/i-prgvrs.i int520d 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int520d
**
**       DATA....: 10/2016
**
**       OBJETIVO: Integra‡Æo NDD - XML Recebimento p/ Reprocessamento p¢s conferˆncia
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}
{utp/ut-glob.i}

{intprg/int002b.i}
{intprg/int500.i}

CREATE WIDGET-POOL.
    
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    field r-rowid          as rowid.

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

for each tt-raw-digita:
    create tt-digita.
    raw-transfer tt-raw-digita.raw-digita to tt-digita NO-ERROR.
end.

DEF VAR h-acomp         AS HANDLE  NO-UNDO.
DEF VAR c-data          AS CHAR    NO-UNDO.
DEF VAR i-seq-item      AS INTEGER NO-UNDO.
DEF VAR c-lista         AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR i-cont          AS INTEGER.
DEF VAR i-linha         AS INTEGER.
DEF VAR de-vl-bruto-int AS DECIMAL NO-UNDO.
DEF VAR de-vprod       AS DECIMAL no-undo.
DEF VAR c-item-do-forn AS CHAR    NO-UNDO.

DEF VAR i-orig_icms    like  int_ds_it_docto_xml.orig_icms. 
DEF VAR i-cst_icms     like  int_ds_it_docto_xml.cst_icms. 
DEF VAR i-modBC        like  int_ds_it_docto_xml.modBC.     
DEF VAR i-modbcst      like  int_ds_it_docto_xml.modbcst.   
DEF VAR de-vbc_icms    like  int_ds_it_docto_xml.vbc_icms.  
DEF VAR de-picms       like  int_ds_it_docto_xml.picms.     
DEF VAR de-vicms       like  int_ds_it_docto_xml.vicms.     
DEF VAR de-pmvast      like  int_ds_it_docto_xml.pmvast.    
DEF VAR de-vbcst       like  int_ds_it_docto_xml.vbcst.     
DEF VAR de-picmsst     like  int_ds_it_docto_xml.picmsst.   
DEF VAR de-vicmsst     like  int_ds_it_docto_xml.vicmsst.   
DEF VAR de-vbcstret    like  int_ds_it_docto_xml.vbcstret.  
DEF VAR de-vicmsstret  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-vicmsDeson  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-aliq-pis    LIKE  int_ds_it_docto_xml.ppis.
DEF VAR de-aliq-cofins LIKE int_ds_it_docto_xml.pcofins.
DEF VAR de-tot-bicms   LIKE it-nota-fisc.vl-bicms-it.
DEF VAR de-tot-icms    LIKE it-nota-fisc.vl-icms-it.
DEF VAR de-tot-bsubs   LIKE it-nota-fisc.vl-bsubs-it.
DEF VAR de-tot-icmst   LIKE it-nota-fisc.vl-icmsub-it.
DEF VAR de-predbc-icms LIKE it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-pRedBCST    like it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-tot-pis     LIKE  int_ds_docto_xml.valor_pis no-undo.       
DEF VAR de-tot-cofins  LIKE  int_ds_docto_xml.valor_cofins no-undo.

DEF VAR i-num-pedido  AS     INTEGER.
DEF VAR c-doc         AS     LONGCHAR NO-UNDO.


DEF BUFFER b-int_ds_docto_xml      FOR int_ds_docto_xml. 
DEF BUFFER b-NDD_ENTRYINTEGRATION  FOR NDD_ENTRYINTEGRATION. 

find first param-global no-lock no-error.
find first mgadm.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "INT520d"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Integra‡Æo_Notas_Danf-e * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Recebimento * L}
assign c-sistema = trim(return-value).

view frame f-cabec.
view frame f-rodape.

/* FIND FIRST int-ds-param-xml NO-LOCK where
           int-ds-param-xml.ep-codigo = int(i-ep-codigo-usuario) NO-ERROR.
IF NOT AVAIL int-ds-param-xml THEN NEXT.
*/

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integra‡Æo_Notas_Danf-e * L}
run pi-inicializar in h-acomp (input return-value).

RUN pi-IntegracaoNDD.

empty temp-table tt-docto-xml.
empty temp-table tt-xml-dup.
empty temp-table tt-it-docto-xml.
 
DELETE WIDGET-POOL.

{include/i-rpclo.i}   

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.
 
PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-xml       AS CHAR     NO-UNDO.
    DEF VAR c-arquivo   AS CHAR     NO-UNDO.
    DEF VAR h-documento AS HANDLE   NO-UNDO.
    DEF VAR h-raiz      AS HANDLE   NO-UNDO.
    DEF VAR c-arq-log   AS CHAR     NO-UNDO. 


    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 
    FOR EACH int_ds_nota_entrada WHERE 
        rowid(int_ds_nota_entrada) = tt-param.r-rowid and
        int_ds_nota_entrada.tipo_nota <> 3 and
        int_ds_nota_entrada.nen_conferida <> 2,
        last NDD_ENTRYINTEGRATION NO-LOCK  WHERE  
             NDD_ENTRYINTEGRATION.kind    = 0 /* Envio */       /*AND   
             NDD_ENTRYINTEGRATION.status_ = 0  campo status pendente */
        AND DOCUMENTNUMBER = INTEGER(int_ds_nota_entrada.nen_notafiscal_n) 
        AND NDD_ENTRYINTEGRATION.CNPJEMIT = DECIMAL(int_ds_nota_entrada.nen_cnpj_origem)
        /*AND NDD_ENTRYINTEGRATION.CNPJdest = 79430682025540 */
        AND NDD_ENTRYINTEGRATION.SERIE    = INTEGER(int_ds_nota_entrada.nen_serie)
        BY NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID DESC
        query-tuning(no-lookahead)
        ON ERROR UNDO, NEXT:

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Processando: " + string(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
     
        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        empty temp-table tt-xml-dup.
        EMPTY TEMP-TABLE tt-digita.

        COPY-LOB FROM NDD_ENTRYINTEGRATION.documentdata TO pXMLResult.
        IF pXMLResult = "" OR
           pXMLResult = ?  THEN DO:
            for first b-NDD_ENTRYINTEGRATION where 
                    rowid(b-NDD_ENTRYINTEGRATION) = rowid(NDD_ENTRYINTEGRATION) 
                query-tuning(no-lookahead):
                assign b-NDD_ENTRYINTEGRATION.status_ = 1.     
                release b-NDD_ENTRYINTEGRATION.
            end.
            put "Erro na leitura do XML" skip.
            next.
        END.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
        
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
             
        /* trata xml - gera tt-docto-xml */
        run pi-abre-xml(INPUT STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID),
                         INPUT c-xml).

        FOR FIRST tt-docto-xml NO-LOCK: END.
        de-vicmsstret = 0.
        de-vProd = 0.
        ASSIGN i-linha = 0.
        FOR EACH tt-it-docto-xml WHERE
            tt-it-docto-xml.arquivo       = tt-docto-xml.arquivo AND
            tt-it-docto-xml.serie         = tt-docto-xml.serie   AND
            tt-it-docto-xml.nNF           = tt-docto-xml.nNF     AND
            tt-it-docto-xml.CNPJ          = tt-docto-xml.CNPJ
            by tt-it-docto-xml.sequencia:
            de-vicmsstret = de-vicmsstret + tt-it-docto-xml.vicmsst.
            de-vProd = de-VProd + tt-it-docto-xml.vProd.
        END.

        assign int_ds_nota_entrada.nen_valortotalprodutos_n = de-vProd.

        de-vicmsst = 0.
        de-vl-bruto-int = 0.
        FOR EACH int_ds_nota_entrada_produt NO-LOCK OF int_ds_nota_entrada by int_ds_nota_entrada_produt.nep_sequencia_n:
            if i-linha = 0 then i-linha = int_ds_nota_entrada_produt.nep_sequencia_n.
            de-vicmsst = de-vicmsst + int_ds_nota_entrada_produt.nep_icmsst_n.
            de-vl-bruto-int = de-vl-bruto-int + int_ds_nota_entrada_produt.nep_valorbruto_n.
        END.

        IF  AVAIL tt-docto-xml then do:
           
            for first emitente fields (cod-emitente nome-abrev)
                no-lock where emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s: end.

            display emitente.cod-emitente   when avail emitente
                    emitente.nome-abrev     when avail emitente
                    int_ds_nota_entrada.nen_serie_s
                    int_ds_nota_entrada.nen_notafiscal_n
                    int_ds_nota_entrada.nen_cnpj_origem_s
                    int_ds_nota_entrada.nen_cfop_n
                    int_ds_nota_entrada.nen_datamovimentacao_d
                    int_ds_nota_entrada.situacao                 COLUMN-LABEL "Sit"
                    int_ds_nota_entrada.nen_conferida_n          COLUMN-LABEL "Conferida"
                    de-vl-bruto-int                              COLUMN-LABEL "Tot Merc Itens"
                    de-vprod                                     COLUMN-LABEL "Tot Merc It XML"
                    de-vicmsst                                   COLUMN-LABEL "ST It"
                    de-vicmsstret                                COLUMN-LABEL "ST It XML"
                with width 300 stream-io down frame f-rel.

            
            for each tt-it-docto-xml where 
                tt-it-docto-xml.arquivo       = tt-docto-xml.arquivo and
                tt-it-docto-xml.serie         = tt-docto-xml.serie   and 
                tt-it-docto-xml.nNF           = tt-docto-xml.nNF     and 
                tt-it-docto-xml.CNPJ          = tt-docto-xml.CNPJ
                by tt-it-docto-xml.sequencia:
                display tt-it-docto-xml.sequencia 
                        tt-it-docto-xml.xProd       format "X(60)" column-label "Descricao"
                        /*tt-it-docto-xml.vUnCom      format "->>>,>>9.99"*/
                        tt-it-docto-xml.vProd       format "->,>>>,>>9.99" column-label "Valor Bruto"   (total)
                        tt-it-docto-xml.vDesc       format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vprod - 
                        tt-it-docto-xml.vDesc       format "->,>>>,>>9.99" column-label "Liquido"       (total)
                        tt-it-docto-xml.vbc_icms    format "->>>,>>>,>>9.99"                            (total)
                        tt-it-docto-xml.vicms       format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vbc_ipi     format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vipi        format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vbcst       format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vicmsst     format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vOutro      format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vbc_pis     format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vpis        format "->,>>>,>>9.99"                              (total)
                        tt-it-docto-xml.vcofins     format "->,>>>,>>9.99"                              (total)
                    with width 300 stream-io.

                if i-linha = 10 then 
                    for first int_ds_nota_entrada_produt of int_ds_nota_entrada where 
                              /*
                              int_ds_nota_entrada_produt.nen_cnpj_origem_s = tt-it-docto-xml.CNPJ          and 
                              int_ds_nota_entrada_produt.nen_serie_s       = tt-docto-xml.serie            and 
                              int_ds_nota_entrada_produt.nen_notafiscal_n  = int(tt-it-docto-xml.nNF)      and 
                              */
                              int_ds_nota_entrada_produt.nep_sequencia_n   = tt-it-docto-xml.sequencia: end.
                else if i-linha = 1 then do:
                    for first int_ds_nota_entrada_produt of int_ds_nota_entrada where 
                              /*
                              int_ds_nota_entrada_produt.nen_cnpj_origem_s = tt-it-docto-xml.CNPJ          and 
                              int_ds_nota_entrada_produt.nen_serie_s       = tt-docto-xml.serie            and 
                              int_ds_nota_entrada_produt.nen_notafiscal_n  = int(tt-it-docto-xml.nNF)      and 
                              */
                              int_ds_nota_entrada_produt.nep_sequencia_n        = int(tt-it-docto-xml.sequencia / 10) and
                              int_ds_nota_entrada_produt.alternativo_fornecedor = tt-it-docto-xml.item_do_forn   and
                              int_ds_nota_entrada_produt.nep_lote_s             = tt-it-docto-xml.lote:          end.
                    if not avail int_ds_nota_entrada_produt then 
                        for first int_ds_nota_entrada_produt of int_ds_nota_entrada where 
                                  /*
                                  int_ds_nota_entrada_produt.nen_cnpj_origem_s = tt-it-docto-xml.CNPJ          and 
                                  int_ds_nota_entrada_produt.nen_serie_s       = tt-docto-xml.serie            and 
                                  int_ds_nota_entrada_produt.nen_notafiscal_n  = int(tt-it-docto-xml.nNF)      and 
                                  */
                                  int_ds_nota_entrada_produt.nep_sequencia_n        = int(tt-it-docto-xml.sequencia / 10) and
                                  int_ds_nota_entrada_produt.alternativo_fornecedor = tt-it-docto-xml.item_do_forn:  end.
                    if not avail int_ds_nota_entrada_produt then 
                        for first int_ds_nota_entrada_produt of int_ds_nota_entrada where 
                                  /*
                                  int_ds_nota_entrada_produt.nen_cnpj_origem_s = tt-it-docto-xml.CNPJ          and 
                                  int_ds_nota_entrada_produt.nen_serie_s       = tt-docto-xml.serie            and 
                                  int_ds_nota_entrada_produt.nen_notafiscal_n  = int(tt-it-docto-xml.nNF)      and 
                                  */
                                  /*int_ds_nota_entrada_produt.nep_sequencia_n        = tt-it-docto-xml.sequencia / 10 and*/
                                  int_ds_nota_entrada_produt.alternativo_fornecedor = tt-it-docto-xml.item_do_forn   and
                                  int_ds_nota_entrada_produt.nep_lote_s             = tt-it-docto-xml.lote:          end.
                end.
                if avail int_ds_nota_entrada_produt then do:
                    display "OK".

                    if tt-it-docto-xml.cst_icms = 40 then
                       assign int_ds_nota_entrada_produt.nep_baseisenta_n = tt-it-docto-xml.vbc_icms.
    
                    if tt-it-docto-xml.cst_icms = 51 then 
                       assign int_ds_nota_entrada_produt.nep_basediferido_n = tt-it-docto-xml.vbc_icms.

                    assign int_ds_nota_entrada_produt.nep_cstb_icm = tt-it-docto-xml.cst_icms.
                    assign int_ds_nota_entrada_produt.nen_cfop_n = tt-it-docto-xml.CFOP.
    
                    assign int_ds_nota_entrada_produt.nep_valorliquido_n     = tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc.
                    assign int_ds_nota_entrada_produt.nep_valorbruto_n       = tt-it-docto-xml.vProd   
                           int_ds_nota_entrada_produt.nep_valordesconto_n    = tt-it-docto-xml.vDesc         
                           int_ds_nota_entrada_produt.nep_baseicms_n         = tt-it-docto-xml.vbc_icms
                           int_ds_nota_entrada_produt.nep_valoricms_n        = tt-it-docto-xml.vicms 
                           int_ds_nota_entrada_produt.nep_baseipi_n          = tt-it-docto-xml.vbc_ipi
                           int_ds_nota_entrada_produt.nep_valoripi_n         = tt-it-docto-xml.vipi
                           int_ds_nota_entrada_produt.nep_icmsst_n           = tt-it-docto-xml.vicmsst
                           int_ds_nota_entrada_produt.nep_basest_n           = tt-it-docto-xml.vbcst
                           int_ds_nota_entrada_produt.nep_valordespesa_n     = tt-it-docto-xml.vOutro
                           int_ds_nota_entrada_produt.nep_basepis_n          = tt-it-docto-xml.vbc_pis
                           int_ds_nota_entrada_produt.nep_valorpis_n         = tt-it-docto-xml.vpis  
                           int_ds_nota_entrada_produt.nep_basecofins_n       = tt-it-docto-xml.vbc_cofins       
                           int_ds_nota_entrada_produt.nep_valorcofins_n      = tt-it-docto-xml.vcofins
                           int_ds_nota_entrada_produt.nep_valor_icms_des_n   = tt-it-docto-xml.vicmsdeson.
                    /*
                    display int_ds_nota_entrada_produt.nep_sequencia_n
                            int_ds_nota_entrada_produt.nep-produto
                            int_ds_nota_entrada_produt.nep_valorbruto_n 
                            int_ds_nota_entrada_produt.nep_valorliquido_n
                            int_ds_nota_entrada_produt.nep_valordesconto_n
                        with width 300 stream-io.
                      */
                end.
                else do:
                    display "NAO ENCONTRADO".
                    assign int_ds_nota_entrada.situacao = 5.
                end.
            end.
            
        end.
        
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.
           
        IF VALID-HANDLE(h-documento) THEN
            DELETE OBJECT h-documento.

        IF VALID-HANDLE(h-raiz) THEN
            DELETE OBJECT h-raiz.


    END. 
    
    /* log-manager:close-log(). */

END PROCEDURE.

PROCEDURE SaveXML:
    DEFINE INPUT PARAMETER pXML  AS LONGCHAR NO-UNDO.
    DEFINE INPUT PARAMETER pFile AS CHAR NO-UNDO.

    DEF VAR hDoc AS HANDLE NO-UNDO.

    CREATE X-DOCUMENT hDoc.
    hDoc:LOAD("LONGCHAR", pXML, FALSE).
    hDoc:SAVE("FILE", pFile).
    DELETE OBJECT hDoc.


END PROCEDURE.

   
PROCEDURE pi-abre-xml:

    DEF INPUT PARAMETER p-arquivo AS CHAR.
    DEF INPUT PARAMETER p-xml     AS CHAR.

    EMPTY TEMP-TABLE ttIde.
    EMPTY temp-table ttInfNFe. 
    EMPTY temp-table ttIde.
    EMPTY temp-table ttNFref .
    EMPTY temp-table ttRefNF .
    EMPTY temp-table ttEmit .
    EMPTY temp-table ttEnderEmit .
    EMPTY temp-table ttDest .
    EMPTY temp-table ttEnderDest .
    EMPTY temp-table ttDet .
    EMPTY temp-table ttProd .
    EMPTY temp-table ttDI .
    EMPTY temp-table ttAdi .
    EMPTY temp-table ttVeicProd .
    EMPTY temp-table ttImposto .
    EMPTY temp-table ttIcms .
    EMPTY temp-table ttICMS00. 
    EMPTY temp-table ttICMS10 .
    EMPTY temp-table ttICMS20 .
    EMPTY temp-table ttICMS30 .
    EMPTY temp-table ttICMS40.
    EMPTY temp-table ttICMS51 .
    EMPTY temp-table ttICMS60.
    EMPTY temp-table ttICMS70 .
    EMPTY temp-table ttICMS90.
    EMPTY temp-table ttICMSSN101.
    EMPTY temp-table ttICMSSN102. 
    EMPTY temp-table ttICMSSN201.
    EMPTY temp-table ttICMSSN202.
    EMPTY temp-table ttICMSSN500.
    EMPTY temp-table ttICMSSN900.
    EMPTY temp-table ttIPI.
    EMPTY temp-table ttIPITrib.
    EMPTY temp-table ttIPINT.
    EMPTY temp-table ttII.
    EMPTY temp-table ttPIS.
    EMPTY temp-table ttPISAliq.
    EMPTY temp-table ttPISNT.
    EMPTY temp-table ttPISOutr.
    EMPTY temp-table ttCOFINS.
    EMPTY temp-table ttCOFINSAliq.
    EMPTY temp-table ttCOFINSNT.
    EMPTY temp-table ttCOFINSOutr.
    EMPTY temp-table ttISSQN.
    EMPTY temp-table ttTotal.
    EMPTY temp-table ttICMSTot.
    EMPTY temp-table ttISSQNtot.
    EMPTY temp-table ttRetTrib.
    EMPTY temp-table ttTransp.
    EMPTY temp-table ttTransporta.
    EMPTY temp-table ttVeicTransp.
    EMPTY temp-table ttReboque.
    EMPTY temp-table ttVol.
    EMPTY temp-table ttCobr. 
    EMPTY temp-table ttFat.
    EMPTY temp-table ttDup.
    EMPTY TEMP-TABLE ttInfAdic.
    EMPTY  temp-table ttExporta.
    EMPTY TEMP-TABLE ttmed.
    EMPTY TEMP-TABLE ttinfprot.
    EMPTY TEMP-TABLE ttcompra.

     /*------------------------------------------------------------------------------
     Notes: Ler XML e carregar Dataset
    ------------------------------------------------------------------------------*/
    DEF var cSourceType as char no-undo.
    def var cReadMode as char no-undo.
    def var lOverrideDefaultMapping as log no-undo.
    def var cFile as char no-undo.
    def var cEncoding as char no-undo.
    def var cSchemaLocation as char no-undo.
    def var cFieldTypeMapping as char no-undo.
    def var cVerifySchemaMode as char no-undo.
    def var retOK as log no-undo.
    
    /* inicio processamento XML */
    dataset dsNfe:empty-dataset no-error.
    dataset dsChave:empty-dataset no-error.

    assign cSourceType = "FILE"
    cFile = p-xml /* arquivo da nfe - Realiza a leitura do procNFe */
    cReadMode = "empty"
    cSchemaLocation = ?
    lOverrideDefaultMapping = ?
    cFieldTypeMapping = ?
    cVerifySchemaMode = "IGNORE"
    no-error.
    
    assign retOK = dataset dsNfe:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    
    assign retOK = dataset dsChave:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    /* inicio processamento XML */

    /* inicio tratamento tmp-tables geradas pelo XML */
    ASSIGN i-seq-item = 0.
    for first ttIde ON ERROR UNDO, RETURN ERROR:

        CREATE tt-docto-xml.
        ASSIGN tt-docto-xml.arquivo   = p-arquivo
               tt-docto-xml.ep_codigo = int(i-ep-codigo-usuario)
               tt-docto-xml.serie     = string(ttIde.serie).

        IF tt-docto-xml.serie = "" THEN 
           ASSIGN tt-docto-xml.serie = "1". 

        ASSIGN tt-docto-xml.serie = STRING(INT(ttIde.serie)) NO-ERROR.

        IF ERROR-STATUS:ERROR = YES 
        THEN DO:
           DO i-cont = 1 TO LENGTH(string(ttIde.serie)):
              IF LOOKUP(SUBSTRING(string(ttIde.serie),i-cont,1),c-lista) = 0 THEN
                 ASSIGN tt-docto-xml.serie = tt-docto-xml.serie + SUBSTRING(string(ttIde.serie),i-cont,1).  
           END.
        END.

        IF LENGTH(tt-docto-xml.serie) > 3
        THEN DO:
           ASSIGN tt-docto-xml.serie = SUBSTRING(tt-docto-xml.serie,1,3).
        END.
      
        IF LENGTH(TRIM(string(ttIde.nnf))) < 8 THEN
           ASSIGN tt-docto-xml.nNF = STRING(ttIde.nnf,"9999999").
        ELSE 
           ASSIGN tt-docto-xml.nNF = string(ttIde.nnf,"99999999").
      
        ASSIGN c-data = SUBSTRING(ttIde.dhEmi,1,10)
               c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
               tt-docto-xml.dEmi       = DATE(c-data)
               tt-docto-xml.dt_trans   = TODAY
               tt-docto-xml.tipo_docto = 1.
                
        /* emitente do documento */
        for first ttEmit:

           ASSIGN tt-docto-xml.CNPJ   = STRING(ttEmit.CNPJ). 

           FIND FIRST estabelec NO-LOCK WHERE
                      estabelec.cgc = tt-docto-xml.CNPJ NO-ERROR.
           IF AVAIL estabelec THEN 
              ASSIGN tt-docto-xml.tipo_nota = 3. /* NFT */
              
           FIND FIRST emitente NO-LOCK WHERE 
                      emitente.cgc = trim(tt-docto-xml.cnpj) AND 
                      emitente.cod-emitente > 0  NO-ERROR.
           IF AVAIL emitente THEN 
              ASSIGN tt-docto-xml.cod_emitente = emitente.cod-emitente.

           ASSIGN tt-docto-xml.xNome  = STRING(ttEmit.xNome).
              
        end. /* ttEmit */

        /* destinatario */
        for first ttDest:

             ASSIGN tt-docto-xml.CNPJ_dest   = STRING(ttDest.CNPJ)
                    tt-docto-xml.tipo_estab  = 2.
    
             FIND FIRST estabelec NO-LOCK WHERE 
                        estabelec.cgc = trim(tt-docto-xml.CNPJ_dest) AND 
                        estabelec.cgc <> ""  NO-ERROR.
             IF AVAIL estabelec THEN DO:
                 
                 IF estabelec.cod-estabel = "973" THEN
                    ASSIGN tt-docto-xml.tipo_estab = 1. /* Principal/CD */
                 ELSE 
                    ASSIGN tt-docto-xml.tipo_estab = 2. /* Frente de Loja */
       
                 ASSIGN tt-docto-xml.cod_estab = estabelec.cod-estab
                        tt-docto-xml.ep_codigo = int(estabelec.ep-codigo).
             END.  
             
             IF tt-docto-xml.CNPJ_dest = tt-docto-xml.cnpj  THEN
                ASSIGN tt-docto-xml.tipo_estab = 0. /* Desconsiderar essas notas */  
                        
             FOR FIRST b-int_ds_docto_xml NO-LOCK WHERE
                       b-int_ds_docto_xml.tipo_nota    = tt-docto-xml.tipo_nota    AND 
                       b-int_ds_docto_xml.CNPJ         = tt-docto-xml.CNPJ         AND                             
                       int(b-int_ds_docto_xml.nNF)     = int(tt-docto-xml.nNF)     AND
                       b-int_ds_docto_xml.serie        = tt-docto-xml.serie
                 query-tuning(no-lookahead):
    
             END.    
             IF AVAIL b-int_ds_docto_xml THEN
                ASSIGN tt-docto-xml.tipo_estab = 3. /* Documento j  cadastrado na base */

             /*
             IF tt-docto-xml.tipo-estab = 2 /* Lj */
             THEN DO:
                   FOR FIRST int_ds_nota_entrada NO-LOCK WHERE
                             int_ds_nota_entrada.nen_cnpj_origem_s = tt-docto-xml.CNPJ     AND 
                             int_ds_nota_entrada.nen_serie_s       = tt-docto-xml.serie    AND 
                             int_ds_nota_entrada.nen_notafiscal_n  = int(tt-docto-xml.nnf) AND 
                             int_ds_nota_entrada.nen_cfop_n        = tt-docto-xml.cfop
                       query-tuning(no-lookahead): END.

                   IF AVAIL int_ds_nota_entrada THEN
                      ASSIGN tt-docto-xml.tipo-estab = 3 /* transferencia j  gerada em loja */.
             END. 
             */
        end. /* ttDest */
    
        /* chave da NFe */
        FOR FIRST ttinfprot : 
            ASSIGN tt-docto-xml.chNfe = ttinfprot.chNfe.
        END.
        /* totais de icms */
        for first ttICMSTot :
       
            ASSIGN tt-docto-xml.VNF            = dec(STRING(ttICMSTot.VNF       )).   
            ASSIGN tt-docto-xml.vbc            = dec(STRING(ttICMSTot.vBC       )).
            ASSIGN tt-docto-xml.tot_desconto   = dec(STRING(ttICMSTot.vDesc     )).
            ASSIGN tt-docto-xml.valor_frete    = dec(STRING(ttICMSTot.vFrete    )).
            ASSIGN tt-docto-xml.valor_mercad   = dec(STRING(ttICMSTot.vProd     )).
            ASSIGN tt-docto-xml.valor_outras   = dec(STRING(ttICMSTot.vOutro    )).
            ASSIGN tt-docto-xml.valor_seguro   = dec(STRING(ttICMSTot.vSeg      )).
            ASSIGN tt-docto-xml.valor_icms     = dec(STRING(ttICMSTot.vICMS     )).
            ASSIGN tt-docto-xml.vbc_cst        = dec(STRING(ttICMSTot.vBCST     )).
            ASSIGN tt-docto-xml.valor_st       = dec(STRING(ttICMSTot.vST       )).
            ASSIGN tt-docto-xml.valor_ii       = dec(STRING(ttICMSTot.vII       )).
            ASSIGN tt-docto-xml.valor_ipi      = dec(STRING(ttICMSTot.vIPI      )).
            ASSIGN tt-docto-xml.valor_pis      = dec(STRING(ttICMSTot.vPIS      )).
            ASSIGN tt-docto-xml.valor_cofins   = dec(STRING(ttICMSTot.vCOFINS   )).
           
        end. /* ttICMSTot */

        for first ttTransp:
            ASSIGN tt-docto-xml.modFrete = ttTransp.modFrete.
        end.

        for first ttCompra:
          ASSIGN i-num-pedido = int(ttCompra.xped) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
              ASSIGN i-num-pedido = 0.      
        end.
        ASSIGN de-tot-pis     = 0 
               de-tot-cofins  = 0.

        /* itens da nota */
        FOR EACH ttprod 
            BY ttprod.nitem:

           ASSIGN i-seq-item = i-seq-item + 10.
           IF i-num-pedido = 0 THEN DO:
               ASSIGN i-num-pedido = int(ttprod.xped) NO-ERROR.
               IF ERROR-STATUS:ERROR THEN
                  ASSIGN i-num-pedido = 0.
           END.

           CREATE tt-it-docto-xml.                                              
           ASSIGN tt-it-docto-xml.arquivo       = tt-docto-xml.arquivo           
                  tt-it-docto-xml.serie         = tt-docto-xml.serie             
                  tt-it-docto-xml.nNF           = tt-docto-xml.nNF               
                  tt-it-docto-xml.CNPJ          = tt-docto-xml.CNPJ              
                  tt-it-docto-xml.tipo_nota     = tt-docto-xml.tipo_nota         
                  tt-it-docto-xml.item_do_forn  = trim(STRING(ttprod.cProd))  
                  tt-it-docto-xml.sequencia     = i-seq-item
                  tt-it-docto-xml.xProd         = SUBstring(STRING(ttprod.xProd),1,60)                     
                  tt-it-docto-xml.ncm           = INT(STRING(ttprod.ncm))             
                  tt-it-docto-xml.cfop          = INT(STRING(ttprod.cfop))                 
                  tt-it-docto-xml.uCom          = SUBstring(STRING(ttprod.uCom),1,2)                        
                  tt-it-docto-xml.uCom_forn     = SUBstring(STRING(ttprod.uCom),1,2)                    
                  tt-it-docto-xml.qCom          = dec(ttprod.qCom)                    
                  tt-it-docto-xml.qCom_forn     = dec(ttprod.qCom)                 
                  tt-it-docto-xml.vUnCom        = dec(ttprod.vUnCom) /* / 10000000000 */  
                  tt-it-docto-xml.vProd         = dec(ttprod.vProd)                 
                  tt-it-docto-xml.vDesc         = dec(ttprod.vDesc)                 
                  tt-it-docto-xml.num_pedido    = INT(i-num-pedido).    
           for first ttmed WHERE
               ttmed.nItem = ttprod.nitem:
               ASSIGN tt-it-docto-xml.lote = if ttmed.nlote <> ? then ttmed.nlote else ""
                      c-data = SUBSTRING(ttmed.dfab,1,10).
                    IF c-data <> "" AND c-data <> ? THEN
                        ASSIGN      c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                              tt-it-docto-xml.dFab  =  DATE(c-data).
               ASSIGN c-data = SUBSTRING(ttmed.dval,1,10).

               IF c-data <> ? AND c-data <> "" THEN
                    ASSIGN  c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                            tt-it-docto-xml.dVal  =  DATE(c-data).

           END.

           ASSIGN i-orig_icms   = 0
                  i-modBC       = 0
                  de-vbc_icms    = 0
                  de-picms       = 0
                  de-vicms       = 0
                  de-pmvast      = 0
                  de-vbcst       = 0
                  de-picmsst     = 0
                  de-vicmsst     = 0
                  de-vbcstret    = 0
                  de-vicmsstret  = 0
                  de-vicmsDeson  = 0
                  de-predbc-icms = 0 .
    
           for first ttICMS00 WHERE
               ttICMS00.nItem = ttprod.nitem:
               ASSIGN  i-orig_icms   = ttICMS00.orig
                       i-cst_icms    = ttICMS00.cst  
                       i-modBC       = ttICMS00.modBC     
                       de-vbc_icms    = ttICMS00.vbc  
                       de-picms       = ttICMS00.picms     
                       de-vicms       = ttICMS00.vicms
                       de-pmvast      = ttICMS00.pmvast  
                       de-vbcst       = ttICMS00.vbcst
                       de-picmsst     = ttICMS00.picmsst
                       de-vicmsst     = ttICMS00.vicmsst     
                       de-vbcstret    = ttICMS00.vbcstret   
                       de-vicmsstret  = ttICMS00.vicmsstret.
           END. /* ttICMS00*/
    
           for FIRST ttICMS10 WHERE 
               ttICMS10.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS10.orig
                       i-cst_icms    = ttICMS10.cst  
                       i-modBC       = ttICMS10.modBC     
                       de-vbc_icms    = ttICMS10.vbc  
                       de-picms       = ttICMS10.picms     
                       de-vicms       = ttICMS10.vicms
                       de-pmvast      = ttICMS10.pmvast  
                       de-vbcst       = ttICMS10.vbcst
                       de-picmsst     = ttICMS10.picmsst
                       de-vicmsst     = ttICMS10.vicmsst     
                       de-vbcstret    = ttICMS10.vbcstret   
                       de-vicmsstret  = ttICMS10.vicmsstret.
           end. /* ttICMS10 */
           for FIRST ttICMS20 where
               ttICMS20.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS20.orig
                       i-cst_icms    = ttICMS20.cst  
                       i-modBC       = ttICMS20.modBC     
                       de-vbc_icms    = ttICMS20.vbc  
                       de-picms       = ttICMS20.picms     
                       de-vicms       = ttICMS20.vicms
                       de-pmvast      = ttICMS20.pmvast  
                       de-vbcst       = ttICMS20.vbcst
                       de-picmsst     = ttICMS20.picmsst
                       de-vicmsst     = ttICMS20.vicmsst     
                       de-vbcstret    = ttICMS20.vbcstret   
                       de-vicmsstret  = ttICMS20.vicmsstret
                       de-predbc-icms = ttICMS20.pRedBC.
           end. /*ttICMS20 */
           
           for first ttICMS30  where
               ttICMS30.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS30.orig
                       i-cst_icms    = ttICMS30.cst  
                       i-modBC       = ttICMS30.modBC     
                       de-vbc_icms    = ttICMS30.vbc  
                       de-picms       = ttICMS30.picms     
                       de-vicms       = ttICMS30.vicms
                       de-pmvast      = ttICMS30.pmvast  
                       de-vbcst       = ttICMS30.vbcst
                       de-picmsst     = ttICMS30.picmsst
                       de-vicmsst     = ttICMS30.vicmsst     
                       de-vbcstret    = ttICMS30.vbcstret   
                       de-vicmsstret  = ttICMS30.vicmsstret
                       de-predbc-icms = ttICMS30.pRedBC.
           end. /* ttICMS30 */
    
           for first ttICMS40  WHERE
               ttICMS40.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS40.orig
                       i-cst_icms    = ttICMS40.cst  
                       i-modBC       = ttICMS40.modBC     
                       de-vbc_icms    = ttICMS40.vbc  
                       de-picms       = ttICMS40.picms     
                       de-vicms       = ttICMS40.vicms
                       de-pmvast      = ttICMS40.pmvast  
                       de-vbcst       = ttICMS40.vbcst
                       de-picmsst     = ttICMS40.picmsst
                       de-vicmsst     = ttICMS40.vicmsst     
                       de-vbcstret    = ttICMS40.vbcstret   
                       de-vicmsstret  = ttICMS40.vicmsstret
                       de-vicmsDeson  = ttICMS40.vicmsDeson
                       de-predbc-icms = ttICMS40.pRedBC.
           end. /* ttICMS40*/
             
           for first ttICMS51 WHERE 
               ttICMS51.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS51.orig
                       i-cst_icms    = ttICMS51.cst  
                       i-modBC       = ttICMS51.modBC     
                       de-vbc_icms    = ttICMS51.vbc  
                       de-picms       = ttICMS51.picms     
                       de-vicms       = ttICMS51.vicms
                       de-pmvast      = ttICMS51.pmvast  
                       de-vbcst       = ttICMS51.vbcst
                       de-picmsst     = ttICMS51.picmsst
                       de-vicmsst     = ttICMS51.vicmsst     
                       de-vbcstret    = ttICMS51.vbcstret   
                       de-vicmsstret  = ttICMS51.vicmsstret
                       de-vicmsDeson  = ttICMS51.vicmsDeson
                       de-predbc-icms = ttICMS51.pRedBC.
           end. /* ttICMS51 */
          
           /* nÆo estava trandao - AVB 31/08/2016 */
           for first ttICMS60 WHERE 
               ttICMS60.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS60.orig
                       i-cst_icms    = ttICMS60.cst  
                       i-modBC       = ttICMS60.modBC     
                       de-vbc_icms    = ttICMS60.vbc  
                       de-picms       = ttICMS60.picms     
                       de-vicms       = ttICMS60.vicms
                       de-pmvast      = ttICMS60.pmvast  
                       de-vbcst       = ttICMS60.vbcst
                       de-picmsst     = ttICMS60.picmsst
                       de-vicmsst     = ttICMS60.vicmsst     
                       de-vbcstret    = ttICMS60.vbcstret   
                       de-vicmsstret  = ttICMS60.vicmsstret
                       de-predbc-icms = ttICMS60.pRedBC.
           end. /* ttICMS60 */

           for first ttICMS70 WHERE 
               ttICMS70.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS70.orig
                       i-cst_icms    = ttICMS70.cst  
                       i-modBC       = ttICMS70.modBC     
                       de-vbc_icms    = ttICMS70.vbc  
                       de-picms       = ttICMS70.picms     
                       de-vicms       = ttICMS70.vicms
                       de-pmvast      = ttICMS70.pmvast  
                       de-vbcst       = ttICMS70.vbcst
                       de-picmsst     = ttICMS70.picmsst
                       de-vicmsst     = ttICMS70.vicmsst     
                       de-vbcstret    = ttICMS70.vbcstret   
                       de-vicmsstret  = ttICMS70.vicmsstret
                       de-predbc-icms = ttICMS70.pRedBC.
           end. /* ttICMS70 */
    
           for first ttICMS90 WHERE 
               ttICMS90.nItem = ttprod.nitem :
               ASSIGN  i-orig_icms   = ttICMS90.orig
                       i-cst_icms    = ttICMS90.cst  
                       i-modBC       = ttICMS90.modBC     
                       de-vbc_icms    = ttICMS90.vbc  
                       de-picms       = ttICMS90.picms     
                       de-vicms       = ttICMS90.vicms
                       de-pmvast      = ttICMS90.pmvast  
                       de-vbcst       = ttICMS90.vbcst
                       de-picmsst     = ttICMS90.picmsst
                       de-vicmsst     = ttICMS90.vicmsst     
                       de-vbcstret    = ttICMS90.vbcstret   
                       de-vicmsstret  = ttICMS90.vicmsstret
                       de-predbc-icms = ttICMS90.pRedBC.
           end. /* ttICMS90*/
    
           for first ttICMSSN101 WHERE 
               ttICMSSN101.nItem = ttprod.nitem :
               ASSIGN i-orig_icms   = ttICMSSN101.orig.
           end.
    
           for first ttICMSSN102 WHERE 
               ttICMSSN102.nItem = ttprod.nitem :
               ASSIGN i-orig_icms   = ttICMSSN102.orig.
           END.
           
           for first ttICMSSN201 WHERE 
               ttICMSSN201.nItem = ttprod.nitem :
               ASSIGN i-orig_icms   = ttICMSSN201.orig
                      i-modBC       = ttICMSSN201.modBC     
                      de-vbc_icms    = ttICMSSN201.vbc  
                      de-picms       = ttICMSSN201.picms     
                      de-vicms       = ttICMSSN201.vicms
                      de-pmvast      = ttICMSSN201.pmvast  
                      de-vbcst       = ttICMSSN201.vbcst
                      de-picmsst     = ttICMSSN201.picmsst
                      de-vicmsst     = ttICMSSN201.vicmsst.
           end. /* ttICMSSN201 */
          
           for FIRST ttICMSSN202 WHERE 
               ttICMSSN202.nItem = ttprod.nitem :
               ASSIGN i-orig_icms   = ttICMSSN202.orig
                      i-modBC       = ttICMSSN202.modBC     
                      de-vbc_icms    = ttICMSSN202.vbc  
                      de-picms       = ttICMSSN202.picms     
                      de-vicms       = ttICMSSN202.vicms
                      de-pmvast      = ttICMSSN202.pmvast  
                      de-vbcst       = ttICMSSN202.vbcst
                      de-picmsst     = ttICMSSN202.picmsst
                      de-vicmsst     = ttICMSSN202.vicmsst.
           end. /* ttICMSSN202 */
    
           for FIRST ttICMSSN500 WHERE 
               ttICMSSN500.nItem = ttprod.nitem :
               ASSIGN i-orig_icms   = ttICMSSN500.orig
                      de-vbcstret    = ttICMSSN500.vbcstret   
                      de-vicmsstret  = ttICMSSN500.vicmsstret.
                      /*de-predbc-icms = ttICMSSN500.pRedBC.*/
           end.
    
           for FIRST ttICMSSN900 WHERE 
               ttICMSSN900.nItem = ttprod.nitem:
               ASSIGN i-orig_icms   = ttICMSSN900.orig
                      i-cst_icms    = ttICMSSN900.cst  
                      i-modBC       = ttICMSSN900.modBC     
                      de-vbc_icms    = ttICMSSN900.vbc  
                      de-picms       = ttICMSSN900.picms     
                      de-vicms       = ttICMSSN900.vicms
                      de-pmvast      = ttICMSSN900.pmvast  
                      de-vbcst       = ttICMSSN900.vbcst
                      de-picmsst     = ttICMSSN900.picmsst
                      de-vicmsst     = ttICMSSN900.vicmsst.
           end.

           ASSIGN tt-it-docto-xml.orig_icms     = i-orig_icms 
                  tt-it-docto-xml.cst_icms      = i-cst_icms  
                  tt-it-docto-xml.modBC         = i-modBC
                  tt-it-docto-xml.vbc_icms      = de-vbc_icms  
                  tt-it-docto-xml.picms         = de-picms     
                  tt-it-docto-xml.vicms         = de-vicms     
                  tt-it-docto-xml.pmvast        = de-pmvast    
                  tt-it-docto-xml.vbcst         = de-vbcst     
                  tt-it-docto-xml.picmsst       = de-picmsst   
                  tt-it-docto-xml.vicmsst       = de-vicmsst   
                  tt-it-docto-xml.vbcstret      = de-vbcstret  
                  tt-it-docto-xml.vicmsstret    = de-vicmsstret.
    
           assign tt-it-docto-xml.vicmsDeson    = de-vicmsDeson
                  tt-it-docto-xml.predBc        = de-predbc-icms
                  tt-it-docto-xml.vOutro        = ttProd.vOutro.
    
           for FIRST ttIPITrib WHERE
               ttIPITrib.nItem = ttprod.nitem :
               assign tt-it-docto-xml.cst_ipi = ttIPITrib.CST
                      tt-it-docto-xml.vbc_ipi = ttIPITrib.vBC
                      tt-it-docto-xml.pipi    = ttIPITrib.pIPI
                      tt-it-docto-xml.vipi    = ttIPITrib.vIPI.
           end.
    
           ASSIGN tt-it-docto-xml.cst_pis    = 0
                  tt-it-docto-xml.vbc_pis    = 0
                  tt-it-docto-xml.ppis       = 0
                  tt-it-docto-xml.vpis       = 0
                  tt-it-docto-xml.cst_cofins = 0 
                  tt-it-docto-xml.vbc_cofins = 0 
                  tt-it-docto-xml.pcofins    = 0 
                  tt-it-docto-xml.vcofins    = 0.

    
           ASSIGN c-item-do-forn = ""
                  de-aliq-pis    = 0
                  de-aliq-cofins = 0.
    
           ASSIGN c-item-do-forn = tt-it-docto-xml.item_do_forn.
    
           for first item-fornec no-lock where
               item-fornec.cod-emitente = tt-docto-xml.cod_emitente AND 
               ITEM-fornec.item-do-forn = c-item-do-forn AND 
               ITEM-fornec.ativo = YES query-tuning(no-lookahead): end.

           if not avail ITEM-fornec 
           then do:
                ASSIGN c-item-do-forn = TRIM(tt-it-docto-xml.item_do_forn) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN
                   ASSIGN c-item-do-forn = STRING (tt-it-docto-xml.item_do_forn).
                for first item-fornec no-lock where 
                    item-fornec.cod-emitente = tt-docto-xml.cod_emitente AND 
                    ITEM-fornec.item-do-forn = c-item-do-forn AND 
                    ITEM-fornec.ativo = YES query-tuning(no-lookahead):
                end.
           end.
           IF AVAIL item-fornec 
           THEN DO:

              for first ITEM no-lock where 
                  ITEM.it-codigo  = item-fornec.it-codigo query-tuning(no-lookahead):

                  ASSIGN de-aliq-pis = dec(substr(item.char-2,31,5)).
                  ASSIGN de-aliq-cofins = dec(substr(item.char-2,36,5)).
    
                  IF de-aliq-pis > 0 THEN DO:
                     FIND FIRST ttPISAliq WHERE
                                ttPISAliq.nItem = ttprod.nitem NO-ERROR.
                     IF AVAIL ttPISAliq THEN DO:
                        ASSIGN tt-it-docto-xml.cst_pis = ttPISAliq.CST
                               tt-it-docto-xml.vbc_pis = ttPISAliq.vBC
                               tt-it-docto-xml.ppis    = de-aliq-pis
                               tt-it-docto-xml.vpis    = ttPISAliq.vBC / de-aliq-pis.
                        ASSIGN de-tot-pis = de-tot-pis + tt-it-docto-xml.vpis.
                     END.   
                  END.

                  IF de-aliq-cofins > 0 THEN DO:
                     FIND FIRST ttCOFINSAliq WHERE
                                ttCOFINSAliq.nItem = ttprod.nitem NO-ERROR.
                     IF AVAIL ttCOFINSAliq 
                     THEN DO:
                        ASSIGN tt-it-docto-xml.cst_cofins =  ttCOFINSAliq.CST  
                               tt-it-docto-xml.vbc_cofins =  ttCOFINSAliq.vBC    
                               tt-it-docto-xml.pcofins    =  de-aliq-cofins
                               tt-it-docto-xml.vcofins    =  ttCOFINSAliq.vBC / de-aliq-cofins.
                        ASSIGN de-tot-cofins = de-tot-cofins + tt-it-docto-xml.vcofins.
                     END. 
                  END.
              END. /* item */
           END. /* item-fornec */
        END. /* each ttprod */
        ASSIGN tt-docto-xml.valor_pis     = de-tot-pis. 
               tt-docto-xml.valor_cofins  = de-tot-cofins.
    
        ASSIGN tt-docto-xml.observacao = ".".
        for first ttInfAdic:
            ASSIGN tt-docto-xml.observacao = if trim(substring(ttInfAdic.infCpl,1,2000)) <> ? 
                                             then trim(substring(ttInfAdic.infCpl,1,2000))
                                             else ".".
        end.
        /* duplicatas da nota */
        for each ttDup:
            for first tt-xml-dup where 
                tt-xml-dup.serie        = tt-docto-xml.serie        and
                tt-xml-dup.nNF          = tt-docto-xml.nNF          and
                tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente and
                tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota    and
                tt-xml-dup.nDup         = ttDup.nDup                and
                tt-xml-dup.dVenc        = ttDup.dVenc:              end.
            if not avail tt-xml-dup then do:
                create  tt-xml-dup.
                assign  tt-xml-dup.serie        = tt-docto-xml.serie        
                        tt-xml-dup.nNF          = tt-docto-xml.nNF          
                        tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente 
                        tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota    
                        tt-xml-dup.nDup         = ttDup.nDup                
                        tt-xml-dup.dVenc        = ttDup.dVenc.
            end.
            assign  tt-xml-dup.InfNFe = ttDup.ttInfNFe
                    tt-xml-dup.Cobr   = ttDup.ttCobr  
                    tt-xml-dup.vDup   = ttDup.vDup.
        end. /* ttDup */

    END. /* ttIde */
    
END PROCEDURE.
