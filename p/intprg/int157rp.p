
/* include de controle de versao */
{include/i-prgvrs.i INT156RP.P 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    FIELD dt-emissao-ini        AS DATE 
    FIELD dt-emissao-fim        AS DATE 
    FIELD tp-transf             AS INT
    .

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.
                                     
/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Recebimentro de Parametros */   
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

def var h-acomp          as handle    no-undo.
def var i-aux            as int       no-undo.
def var c-linha          as char      no-undo.
def var c-fator          as char      no-undo.

find first param-global no-lock no-error.
assign c-programa 	  = 'INT156RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-empresa      = param-global.grupo
       c-sistema      = 'Pedidos'
       c-titulo-relat = 'Atualização preços'. 

{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).

/***************   INICIANDO GERACAO DO EXCEL ******************/

DEFINE VARIABLE i-linha     AS      INTEGER INIT 2                 NO-UNDO.    
DEFINE VARIABLE c-planilha  AS      CHARACTER                      NO-UNDO.
DEFINE VARIABLE chExcelAppl AS      COM-HANDLE                     NO-UNDO.
DEFINE VARIABLE chWorkBook  AS      COM-HANDLE                     NO-UNDO.
DEFINE VARIABLE chWorkSheet AS      COM-HANDLE                     NO-UNDO.
DEFINE VARIABLE c-data      AS      CHARACTER FORMAT "x(16)"       NO-UNDO.


DEFINE VARIABLE c-situacao  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-data-conf AS DATE        NO-UNDO.
DEFINE VARIABLE i-sit-conf AS INTEGER     NO-UNDO.


ASSIGN c-data = STRING(TIME) 
       c-data = REPLACE(c-data,"/","-").



ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "int157.xlsx" .

OS-COPY VALUE(SEARCH("intprg\int157.xlsx")) VALUE(c-planilha).
CREATE 'Excel.Application':U chExcelAppl CONNECT NO-ERROR.
IF  ERROR-STATUS:ERROR THEN
    CREATE 'Excel.Application':U chExcelAppl.


chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).
chWorkBook:Activate().

chExcelAppl:VISIBLE        = NO.
chExcelAppl:ScreenUpdating = FALSE.    
chWorkSheet = chExcelAppl:Sheets:Item(1). 

/*************** FIM INICIALICAO DO EXCEL ************************/

IF TT-PARAM.tp-transf = 1 THEN DO:  // Notas fiscais Lojas

    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-emitente <> 9356
          AND nota-fiscal.dt-emis-nota >= dt-emissao-ini
          AND nota-fiscal.dt-emis-nota <= dt-emissao-fim
          AND nota-fiscal.dt-cancel     = ?
          , FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao 
              AND natur-oper.especie-doc = "NFT" :
    
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.
    
        FIND FIRST docum-est NO-LOCK
            WHERE nota-fiscal.cod-estabel   = docum-est.estab-de-or
              AND nota-fiscal.nr-nota-fis   = docum-est.nro-docto
              AND nota-fiscal.serie         = docum-est.serie-docto NO-ERROR.
    
        IF NOT AVAIL docum-est THEN DO:
    
            RUN pi-acompanhar IN h-acomp (INPUT "Processando nota fiscal: " + STRING(nota-fiscal.nr-nota-fis) /* + " EmissÆo: " string(nota-fiscal.dt-emis-nota) */ ).
        
        
            ASSIGN c-situacao  = "NÆo existe tabela de integra‡Æo"
                   c-data-conf = ?.
    
            FIND FIRST emitente NO-LOCK
                WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.
    
            FIND FIRST int_ds_nota_entrada NO-LOCK 
                WHERE int_ds_nota_entrada.nen_serie_s       = nota-fiscal.serie
                  AND int_ds_nota_entrada.nen_notafiscal_n  = int(nota-fiscal.nr-nota-fis)
                  AND int_ds_nota_entrada.nen_cnpj_origem_s = estabelec.cgc NO-ERROR.
    
            IF AVAIL int_ds_nota_entrada THEN DO:
     
                ASSIGN c-situacao = string(int_ds_nota_entrada.situacao).
    
                FIND FIRST int_dp_nota_entrada_ret NO-LOCK
                    WHERE int_dp_nota_entrada_ret.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND int_dp_nota_entrada_ret.nen_notafiscal_n  = int_ds_nota_entrada.nen_notafiscal_n   
                      AND int_dp_nota_entrada_ret.nen_serie_s       = int_ds_nota_entrada.nen_serie_s NO-ERROR.
    
                IF AVAIL int_dp_nota_entrada_ret THEN DO:
    
                    ASSIGN c-data-conf = int_dp_nota_entrada_ret.nen_datamovimentacao_d.
    
                END.
    
            END.
        
            ASSIGN chWorkSheet:Range("A" + STRING (i-linha)) = nota-fiscal.dt-emis-nota
                   chWorkSheet:Range("B" + STRING (i-linha)) = nota-fiscal.nr-nota-fis 
                   chWorkSheet:Range("C" + STRING (i-linha)) = nota-fiscal.serie       
                   chWorkSheet:Range("D" + STRING (i-linha)) = nota-fiscal.cod-estabel 
                   chWorkSheet:Range("E" + STRING (i-linha)) = nota-fiscal.nat-operacao
                   chWorkSheet:Range("F" + STRING (i-linha)) = nota-fiscal.nome-ab-cli 
                   chWorkSheet:Range("G" + STRING (i-linha)) = nota-fiscal.vl-tot-nota 
                   chWorkSheet:Range("H" + STRING (i-linha)) = c-situacao 
                   chWorkSheet:Range("I" + STRING (i-linha)) = c-data-conf.   
            
            ASSIGN i-linha = i-linha + 1. 
    
        END.
        
    
    END.
END.
ELSE IF tt-param.tp-transf = 2 THEN DO:  // Notas fiscais do CD

    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-emitente = 9356
          AND nota-fiscal.dt-emis-nota >= dt-emissao-ini
          AND nota-fiscal.dt-emis-nota <= dt-emissao-fim
          AND nota-fiscal.dt-cancel     = ?:

        ASSIGN c-data-conf = ?
               i-sit-conf  = ?.
    
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.
    
        FIND FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao 
              AND natur-oper.especie-doc = "NFT" NO-ERROR.
     
        IF AVAIL natur-oper THEN DO:
    
            FIND FIRST docum-est NO-LOCK
                WHERE nota-fiscal.cod-estabel   = docum-est.estab-de-or
                  AND nota-fiscal.nr-nota-fis   = docum-est.nro-docto
                  AND nota-fiscal.serie         = docum-est.serie-docto NO-ERROR.
    
            IF NOT AVAIL docum-est THEN DO:
    
                ASSIGN c-situacao  = "NÆo existe tabela de integra‡Æo"
                       c-data-conf = ?.
    
                FIND FIRST emitente NO-LOCK
                    WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.
        
                FIND FIRST int_ds_docto_xml NO-LOCK 
                    WHERE int_ds_docto_xml.serie    = nota-fiscal.serie
                      AND int_ds_docto_xml.nNF      = nota-fiscal.nr-nota-fis
                      AND int_ds_docto_xml.CNPJ     = estabelec.cgc NO-ERROR.
        
                IF AVAIL int_ds_docto_xml THEN DO:
        
                    ASSIGN c-situacao = string(int_ds_docto_xml.situacao).
    
                    FOR LAST int_ds_docto_wms no-lock /* use-index sequencial */ where 
                         int_ds_docto_wms.doc_numero_n = string(int(int_ds_docto_xml.nNF))   and
                         int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
                         int_ds_docto_wms.doc_origem_n = int_ds_docto_xml.cod_emitente
                         BY int_ds_docto_wms.situacao :
                        ASSIGN c-data-conf = int_ds_docto_wms.datamovimentacao_d
                               i-sit-conf = int_ds_docto_wms.situacao.
                    END.
                END.
    
                ASSIGN chWorkSheet:Range("A" + STRING (i-linha)) = nota-fiscal.dt-emis-nota
                       chWorkSheet:Range("B" + STRING (i-linha)) = nota-fiscal.nr-nota-fis 
                       chWorkSheet:Range("C" + STRING (i-linha)) = nota-fiscal.serie       
                       chWorkSheet:Range("D" + STRING (i-linha)) = nota-fiscal.cod-estabel 
                       chWorkSheet:Range("E" + STRING (i-linha)) = nota-fiscal.nat-operacao
                       chWorkSheet:Range("F" + STRING (i-linha)) = nota-fiscal.nome-ab-cli 
                       chWorkSheet:Range("G" + STRING (i-linha)) = nota-fiscal.vl-tot-nota 
                       chWorkSheet:Range("H" + STRING (i-linha)) = c-situacao 
                       chWorkSheet:Range("I" + STRING (i-linha)) = c-data-conf
                       chWorkSheet:Range("J" + STRING (i-linha)) = i-sit-conf.   
                
                ASSIGN i-linha = i-linha + 1. 
    
    
            END.
    
        END.
    
    END.
END.
 /************** FECHAMENTO EXCEL ***************/

   NO-RETURN-VALUE chExcelAppl:SAVE  NO-ERROR.

    chExcelAppl:VISIBLE        = YES.
    chExcelAppl:ScreenUpdating = TRUE. 

    RELEASE OBJECT chExcelAppl NO-ERROR.
    RELEASE OBJECT chWorksheet NO-ERROR.
    RELEASE OBJECT chWorkbook  NO-ERROR.
    
 /************** FIM FECHAMENTO EXCEL ***********/    

    
/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.


