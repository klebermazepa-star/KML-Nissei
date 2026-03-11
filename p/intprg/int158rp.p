
/* include de controle de versao */
{include/i-prgvrs.i INT158RP.P 1.00.00.002KML}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             AS integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    FIELD it-codigo-ini         AS CHAR
    FIELD it-codigo-fim         AS CHAR 
    FIELD tab-preco-ini         AS CHAR 
    FIELD tab-preco-fim         AS CHAR 
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
assign c-programa 	  = 'INT158RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.002KML'
       c-empresa      = param-global.grupo
       c-sistema      = 'Pedidos'
       c-titulo-relat = 'Tabela de pre‡os'. 

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

DEFINE VARIABLE i-linha     AS      INTEGER INIT 2                  NO-UNDO.    
DEFINE VARIABLE c-planilha  AS      CHARACTER                       NO-UNDO.
DEFINE VARIABLE chExcelAppl AS      office.iface.excel.ExcelWrapper NO-UNDO.
DEFINE VARIABLE chWorkBook  AS      office.iface.excel.Workbook     NO-UNDO.
DEFINE VARIABLE chWorkSheet AS      office.iface.excel.WorkSheet    NO-UNDO.
DEFINE VARIABLE c-data      AS      CHARACTER FORMAT "x(16)"        NO-UNDO.

ASSIGN c-data = STRING(TIME) 
       c-data = REPLACE(c-data,"/","-").



ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "int158.xlsx" .

//OS-COPY VALUE(SEARCH("intprg\int158.xlsx")) VALUE(c-planilha).
/* CREATE 'Excel.Application':U chExcelAppl CONNECT NO-ERROR.     */
/* IF  ERROR-STATUS:ERROR THEN                                    */
/*     CREATE 'Excel.Application':U chExcelAppl.                  */
 ASSIGN chExcelAppl = NEW office.libre.excel.ExcelWrapper(). /*criar planilha*/
        ChWorkBook  = ChExcelAppl:WorkBooks:ADD(search("intprg\int158.xlsx")).  //search("intprg\int158.xlsx")
 ASSIGN chWorksheet = chExcelAppl:ActiveSheet.    

//chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).
chExcelAppl:VISIBLE        = NO.
chExcelAppl:ScreenUpdating = FALSE.    
chWorkSheet = chExcelAppl:Sheets:Item(1). 

/*************** FIM INICIALICAO DO EXCEL ************************/

FOR EACH ems2dis.preco-item NO-LOCK
    WHERE preco-item.nr-tabpre >= tt-param.tab-preco-ini
      AND preco-item.nr-tabpre <= tt-param.tab-preco-fim
      AND preco-item.it-codigo >= tt-param.it-codigo-ini
      AND preco-item.it-codigo <= tt-param.it-codigo-fim
      AND preco-item.situacao   = 1 :


    RUN pi-acompanhar IN h-acomp (INPUT "Processando item: " + STRING(preco-item.it-codigo)).

 
        chWorkSheet:Range("A" + STRING (i-linha)):SetValue(preco-item.nr-tabpre).    
        chWorkSheet:Range("B" + STRING (i-linha)):SetValue(preco-item.it-codigo).      
        chWorkSheet:Range("C" + STRING (i-linha)):SetValue(preco-item.preco-venda).  
        chWorkSheet:Range("D" + STRING (i-linha)):SetValue(IF preco-item.situacao = 1 THEN "Ativo" ELSE "Inativo").
        chWorkSheet:Range("E" + STRING (i-linha)):SetValue(preco-item.user-alter).
        chWorkSheet:Range("F" + STRING (i-linha)):SetValue(preco-item.dt-useralt).
        chWorkSheet:Range("G" + STRING (i-linha)):SetValue(preco-item.dt-inival).

    assign  i-linha = i-linha + 1. 


END.

 /************** FECHAMENTO EXCEL ***************/

   //NO-RETURN-VALUE chExcelAppl:SAVE  NO-ERROR.

    chExcelAppl:VISIBLE        = YES.
    chExcelAppl:ScreenUpdating = TRUE.

      ASSIGN chExcelAppl = ? NO-ERROR.
      ASSIGN chWorksheet = ? NO-ERROR.
      ASSIGN chWorkbook  = ? NO-ERROR.

    /* RELEASE OBJECT chExcelAppl NO-ERROR.  */
    /* RELEASE OBJECT chWorksheet NO-ERROR.  */
    /* RELEASE OBJECT chWorkbook  NO-ERROR.  */
    
 /************** FIM FECHAMENTO EXCEL ***********/    

    
/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.


