/* include de controle de versao */
{include/i-prgvrs.i NICR012RP.P 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)" 
    FIELD cod-estabel-ini       AS CHAR 
    FIELD cod-estabel-fim       AS CHAR
    FIELD nota-ini              AS CHAR 
    FIELD nota-fim              AS CHAR 
    FIELD espec-ini             AS CHAR 
    FIELD espec-fim             AS CHAR 
    field serie-ini             AS CHAR
    field serie-fim             AS CHAR
    field dt-emis-ini           as date
    field dt-emis-fim           as date
    field dt-vencto-ini         as date
    field dt-vencto-fim         as date
    field portador-ini          as integer 
    field portador-fim          as integer 
    field cliente-ini           as integer           
    field cliente-fim           as INTEGER
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
assign c-programa 	  = 'NICR030RP'
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

DEFINE VARIABLE i-linha     AS      INTEGER INIT 2                  NO-UNDO.    
DEFINE VARIABLE c-planilha  AS      CHARACTER                       NO-UNDO.
DEFINE VARIABLE chExcelAppl AS      office.iface.excel.ExcelWrapper NO-UNDO.
DEFINE VARIABLE chWorkBook  AS      office.iface.excel.Workbook     NO-UNDO.
DEFINE VARIABLE chWorkSheet AS      office.iface.excel.WorkSheet    NO-UNDO.
DEFINE VARIABLE c-data      AS      CHARACTER FORMAT "x(16)"        NO-UNDO.
DEFINE VARIABLE cont        AS DEC                                  NO-UNDO.

ASSIGN c-data = STRING(TIME) 
       c-data = REPLACE(c-data,"/","-").



ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "nicr030.xlsx" .

ASSIGN chExcelAppl = NEW office.libre.excel.ExcelWrapper(). /*criar planilha*/
        ChWorkBook  = ChExcelAppl:WorkBooks:ADD(search("intprg\nicr030.xlsx")).
ASSIGN chWorksheet = chExcelAppl:ActiveSheet.   


//chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).

chExcelAppl:VISIBLE        = NO.
chExcelAppl:ScreenUpdating = FALSE.    
chWorkSheet = chExcelAppl:Sheets:Item(1).
chWorkSheet:COLUMNS:autofit().

ASSIGN i-linha = 1.

      
            chWorkSheet:Range("A1:T1"):FONT:Bold = TRUE.
            chWorkSheet:Range("A" + STRING (i-linha)):SetValue("EmissÆo").
            chWorkSheet:Range("B" + STRING (i-linha)):SetValue("Titulo").
            chWorkSheet:Range("C" + STRING (i-linha)):SetValue("Parcela").
            chWorkSheet:Range("D" + STRING (i-linha)):SetValue("Estabelecimento").
            chWorkSheet:Range("E" + STRING (i-linha)):SetValue("Esp‚cie").
            chWorkSheet:Range("F" + STRING (i-linha)):SetValue("S‚rie").
            chWorkSheet:Range("G" + STRING (i-linha)):SetValue("Data de Vencimento").
            chWorkSheet:Range("H" + STRING (i-linha)):SetValue("Portador").
            chWorkSheet:Range("I" + STRING (i-linha)):SetValue("Descri‡Æo").
            chWorkSheet:Range("J" + STRING (i-linha)):SetValue("C¢digo Cliente").
            chWorkSheet:Range("K" + STRING (i-linha)):SetValue("Nome Cliente").
            chWorkSheet:Range("L" + STRING (i-linha)):SetValue("Valor Bruto Parcela").
            //chWorkSheet:Range("M" + STRING (i-linha)):SetValue("Valor Bruto").
            chWorkSheet:Range("M" + STRING (i-linha)):SetValue("Valor Liquido").
            chWorkSheet:Range("N" + STRING (i-linha)):SetValue("Valor Taxa").

            /*Fim do cabe‡ario*/
/*************** FIM INICIALICAO DO EXCEL ************************/

ASSIGN i-linha = 2.

FOR EACH nota-fiscal NO-LOCK
    WHERE nota-fiscal.dt-emis-nota >= tt-param.dt-emis-ini
    AND   nota-fiscal.dt-emis-nota <= tt-param.dt-emis-fim
    AND   nota-fiscal.cod-estabel  >= tt-param.cod-estabel-ini
    AND   nota-fiscal.cod-estabel  <= tt-param.cod-estabel-fim
    AND   nota-fiscal.serie        <= tt-param.serie-fim 
    AND   nota-fiscal.serie        >= tt-param.serie-ini 
    AND   nota-fiscal.cod-emitente >= tt-param.cliente-ini
    AND   nota-fiscal.cod-emitente <= tt-param.cliente-fim
    :

    FOR EACH fat-duplic NO-LOCK
        WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel 
        and fat-duplic.serie         = nota-fiscal.serie      
        and fat-duplic.nr-fatura     = nota-fiscal.nr-nota-fis
        AND fat-duplic.cod-esp       >= tt-param.espec-ini
        AND fat-duplic.cod-esp       <= tt-param.espec-fim
        AND fat-duplic.int-1         >= tt-param.portador-ini
        AND fat-duplic.int-1         <= tt-param.portador-fim
        AND fat-duplic.dt-venciment  >= tt-param.dt-vencto-ini
        AND fat-duplic.dt-venciment  <= tt-param.dt-vencto-fim
        :

        FIND FIRST cst_fat_duplic NO-LOCK
            WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
            AND   cst_fat_duplic.serie       = fat-duplic.serie      
            AND   cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
            AND   cst_fat_duplic.parcela     = fat-duplic.parcela NO-ERROR.

        IF AVAIL cst_fat_duplic 
            AND (cst_fat_duplic.num_id_tit_acr <> ? AND  cst_fat_duplic.num_id_tit_acr <> 0) THEN DO:

            RUN pi-acompanhar IN h-acomp (INPUT "Processando Titulos: " + STRING(nota-fiscal.nr-nota-fis)).

            FIND FIRST ems2mult.portador NO-LOCK
                WHERE portador.cod-portador = fat-duplic.INT-1 NO-ERROR.    
           
            FIND FIRST emitente NO-LOCK
                   WHERE emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-ERROR.

            ASSIGN cont =  fat-duplic.vl-parcela - cst_fat_duplic.taxa_admin.

            chWorkSheet:Range("A:Z"):EntireColumn:autofit().
            chWorkSheet:Range("A" + STRING (i-linha)):SetValue(fat-duplic.dt-emissao).
            chWorkSheet:Range("B" + STRING (i-linha)):SetValue(fat-duplic.nr-fatura).
            chWorkSheet:Range("C" + STRING (i-linha)):SetValue(fat-duplic.parcela).
            chWorkSheet:Range("C" + STRING (i-linha)):NumberFormat = "0#".
            chWorkSheet:Range("D" + STRING (i-linha)):SetValue(fat-duplic.cod-estabel).
            chWorkSheet:Range("E" + STRING (i-linha)):SetValue(fat-duplic.cod-esp).
            chWorkSheet:Range("F" + STRING (i-linha)):SetValue(fat-duplic.serie).
            chWorkSheet:Range("G" + STRING (i-linha)):SetValue(fat-duplic.dt-venciment).
            chWorkSheet:Range("H" + STRING (i-linha)):SetValue(fat-duplic.int-1).
            chWorkSheet:Range("I" + STRING (i-linha)):SetValue(portador.nome-abrev).
            chWorkSheet:Range("J" + STRING (i-linha)):SetValue(emitente.cod-emitente).
            chWorkSheet:Range("K" + STRING (i-linha)):SetValue(emitente.nome-emit).
            chWorkSheet:Range("L" + STRING (i-linha)):SetValue(fat-duplic.vl-parcela).
            //chWorkSheet:Range("M" + STRING (i-linha)):SetValue(nota-fiscal.vl-tot-nota).    
            chWorkSheet:Range("M" + STRING (i-linha)):SetValue(cont).
            chWorkSheet:Range("N" + STRING (i-linha)):SetValue(cst_fat_duplic.taxa_admin).

            assign  i-linha = i-linha + 1. 
               
                                                       
        END.  //end if avail
    END. // end for each fat-duplic
END. //end for each nota-fiscal

/************** FECHAMENTO EXCEL ***************/

    chExcelAppl:VISIBLE        = YES.
    chExcelAppl:ScreenUpdating = TRUE.

      ASSIGN chExcelAppl = ? NO-ERROR.
      ASSIGN chWorksheet = ? NO-ERROR.
      ASSIGN chWorkbook  = ? NO-ERROR.
    
 /************** FIM FECHAMENTO EXCEL ***********/    

    
/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.
