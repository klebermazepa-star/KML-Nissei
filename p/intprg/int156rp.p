
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
    FIELD it-codigo-ini         AS INT
    FIELD it-codigo-fim         AS INT 
    FIELD cod-estabel-ini       AS CHAR 
    FIELD cod-estabel-fim       AS CHAR 
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

IF tt-param.it-codigo-fim   = 0 THEN 
    ASSIGN tt-param.it-codigo-ini = 0
           tt-param.it-codigo-fim = 9999999.

IF tt-param.cod-estabel-fim = "" THEN 
    ASSIGN tt-param.cod-estabel-ini = ""
           tt-param.cod-estabel-fim = "ZZZZZZZZZ".

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

ASSIGN c-data = STRING(TIME) 
       c-data = REPLACE(c-data,"/","-").



ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "int156.xlsx" .

OS-COPY VALUE(SEARCH("intprg\int156.xlsx")) VALUE(c-planilha).
CREATE 'Excel.Application':U chExcelAppl CONNECT NO-ERROR.
IF  ERROR-STATUS:ERROR THEN
    CREATE 'Excel.Application':U chExcelAppl.


chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).
chWorkBook:Activate().

chExcelAppl:VISIBLE        = NO.
chExcelAppl:ScreenUpdating = FALSE.    
chWorkSheet = chExcelAppl:Sheets:Item(1). 

/*************** FIM INICIALICAO DO EXCEL ************************/

FOR EACH int_dp_preco_item NO-LOCK
    WHERE int_dp_preco_item.pri_produto_n       >= tt-param.it-codigo-ini
      AND int_dp_preco_item.pri_produto_n       <= tt-param.it-codigo-fim
      AND int_dp_preco_item.pri_cod_estabel_s   >= tt-param.cod-estabel-ini
      AND int_dp_preco_item.pri_cod_estabel_s   <= tt-param.cod-estabel-fim
    :

    RUN pi-acompanhar IN h-acomp (INPUT "Processando item: " + STRING(int_dp_preco_item.pri_produto_n)).

    FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = STRING(int_dp_preco_item.pri_produto_n) NO-ERROR.

    IF AVAIL ITEM THEN DO:
   

       // chWorkSheet:Range("A" + STRING (i-linha)) = int_dp_preco_item.tipo_movto. 
        chWorkSheet:Range("A" + STRING (i-linha)) = int_dp_preco_item.dt_geracao.   
        chWorkSheet:Range("B" + STRING (i-linha)) = "~'" + int_dp_preco_item.hr_geracao.   
        chWorkSheet:Range("C" + STRING (i-linha)) = "~'" + int_dp_preco_item.pri_cod_estabel_s. 
        chWorkSheet:Range("D" + STRING (i-linha)) = "~'" + int_dp_preco_item.pri_cnpj_origem_s. 
        chWorkSheet:Range("E" + STRING (i-linha)) = "~'" + ITEM.it-codigo. 
        chWorkSheet:Range("F" + STRING (i-linha)) = "~'" + ITEM.descricao-1. 
        chWorkSheet:Range("G" + STRING (i-linha)) = int_dp_preco_item.pri_precomedio_n.     
        chWorkSheet:Range("H" + STRING (i-linha)) = int_dp_preco_item.pri_precobase_n.
        chWorkSheet:Range("I" + STRING (i-linha)) = int_dp_preco_item.pri_precoentrada_n.
        chWorkSheet:Range("J" + STRING (i-linha)) = int_dp_preco_item.pri_datamedio_d .
        chWorkSheet:Range("K" + STRING (i-linha)) = int_dp_preco_item.pri_database_d.
        chWorkSheet:Range("L" + STRING (i-linha)) = int_dp_preco_item.pri_dataentrada_d.
     //   chWorkSheet:Range("N" + STRING (i-linha)) = "~'" + string(int_dp_preco_item.ENVIO_DATA_HORA) .
        
    END.

    assign  i-linha = i-linha + 1. 

    

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


