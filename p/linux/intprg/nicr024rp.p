
/* include de controle de versao */
{include/i-prgvrs.i NICR024RP.P 1.00.00.001}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    field cod-estabel-ini       like nota-fiscal.cod-estabel
    field cod-estabel-fim       like nota-fiscal.cod-estabel
    field nr-nota-fis-ini       like nota-fiscal.nr-nota-fis
    field nr-nota-fis-fim       like nota-fiscal.nr-nota-fis
    field serie-ini             like nota-fiscal.serie
    field serie-fim             like nota-fiscal.serie
    field cod-emitente-ini      like nota-fiscal.cod-emitente
    field cod-emitente-fim      like nota-fiscal.cod-emitente
    field dt-emis-nota-ini      like nota-fiscal.dt-emis-nota
    field dt-emis-nota-fim      like nota-fiscal.dt-emis-nota
    FIELD cod-gr-forn-ini       LIKE emitente.cod-gr-forn
    FIELD cod-gr-forn-fim       LIKE emitente.cod-gr-forn
    FIELD tgConsideraMatriz     AS LOG
    .

DEFINE VARIABLE c-nota-origem   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-serie-origem  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-tit-ap    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-parcela   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE d-val-origin    AS DECIMAL     NO-UNDO.
DEFINE VARIABLE d-val-saldo     AS DECIMAL     NO-UNDO.
                                
DEFINE BUFFER b-emitente FOR emitente.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

define variable v-integ-finan as char no-undo.
                                     
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
assign c-programa 	  = 'NICR024RP'
       c-versao	      = '1.01'
       c-revisao      = '.00.001'
       c-empresa      = param-global.grupo
       c-sistema      = 'Notas Fiscais'
       c-titulo-relat = 'Relat¢rio de devolu‡äes de nota Fiscal'. 

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

    DEFINE VARIABLE i-linha     AS      INTEGER INIT 3                 NO-UNDO.    
    DEFINE VARIABLE c-planilha  AS      CHARACTER                      NO-UNDO.
    DEFINE VARIABLE chExcelAppl AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE chWorkBook  AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE chWorkSheet AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE c-data      AS      CHARACTER FORMAT "x(16)"       NO-UNDO.

    ASSIGN c-data = STRING(TIME) 
           c-data = REPLACE(c-data,"/","-").



    ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "nicr024-" + string(TIME) + ".xlsx" .
    
    OS-COPY VALUE(SEARCH("intprg\nicr024.xlsx")) VALUE(c-planilha).
    CREATE 'Excel.Application':U chExcelAppl CONNECT NO-ERROR.
    IF  ERROR-STATUS:ERROR THEN
        CREATE 'Excel.Application':U chExcelAppl.

    
    chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).
    chWorkBook:Activate().
    
    chExcelAppl:VISIBLE        = NO.
    chExcelAppl:ScreenUpdating = FALSE.    
    chWorkSheet = chExcelAppl:Sheets:Item(1). 

    /*************** FIM INCIIALICAO DO EXCEL ************************/

/* ************************* LOGICA RELATORIO *********************/

blk-nota-fiscal:
FOR EACH nota-fiscal NO-LOCK
    WHERE nota-fiscal.cod-estabel   >= tt-param.cod-estabel-ini
      AND nota-fiscal.cod-estabel   <= tt-param.cod-estabel-fim
      AND nota-fiscal.nr-nota-fis   >= tt-param.nr-nota-fis-ini
      AND nota-fiscal.nr-nota-fis   <= tt-param.nr-nota-fis-fim
      AND nota-fiscal.serie         >= tt-param.serie-ini
      AND nota-fiscal.serie         <= tt-param.serie-fim
      AND nota-fiscal.dt-emis-nota  >= tt-param.dt-emis-nota-ini
      AND nota-fiscal.dt-emis-nota  <= tt-param.dt-emis-nota-fim
    , FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao
              AND natur-oper.tipo = 2
              AND natur-oper.especie = "NFD"
       QUERY-TUNING(NO-LOOKAHEAD) :

    RUN pi-acompanhar IN h-acomp (INPUT STRING("Nota Fiscal: ") + 
                                        STRING(nota-fiscal.dt-emis-nota) + " | " +
                                        STRING(nota-fiscal.cod-estabel) + " | " +
                                        STRING(nota-fiscal.nr-nota-fis) ).


    ASSIGN c-cod-tit-ap   = ""
           c-cod-parcela  = ""
           d-val-origin   = 0
           d-val-saldo    = 0
           c-nota-origem  = ""
           c-serie-origem = "".

    IF tgConsideraMatriz THEN DO:

        FOR FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente   = nota-fiscal.cod-emitente
              AND emitente.identific >= 2
              AND emitente.cod-emitente  >= tt-param.cod-emitente-ini
              AND emitente.cod-emitente  <= tt-param.cod-emitente-fim  
              AND emitente.cod-gr-forn   >= tt-param.cod-gr-forn-ini  
              AND emitente.cod-gr-forn   <= tt-param.cod-gr-forn-fim :

            FIND FIRST b-emitente NO-LOCK
                WHERE b-emitente.nome-matriz = emitente.nome-abrev NO-ERROR.

            IF NOT AVAIL b-emitente THEN NEXT blk-nota-fiscal.

        END.
         
    END.
    ELSE DO:

        FIND FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente   = nota-fiscal.cod-emitente
              AND emitente.identific >= 2
              AND emitente.cod-emitente  >= tt-param.cod-emitente-ini
              AND emitente.cod-emitente  <= tt-param.cod-emitente-fim 
              AND emitente.cod-gr-forn   >= tt-param.cod-gr-forn-ini  
              AND emitente.cod-gr-forn   <= tt-param.cod-gr-forn-fim  NO-ERROR.

         IF NOT AVAIL emitente THEN NEXT blk-nota-fiscal.

    END.

    FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK
        WHERE it-nota-fisc.nr-docum <> ""
         QUERY-TUNING(NO-LOOKAHEAD) :

            ASSIGN c-nota-origem = it-nota-fisc.nr-docum
                   c-serie-origem = it-nota-fisc.serie-docum.
    END.

    FOR EACH tit_ap
        WHERE tit_ap.cod_tit_Ap = c-nota-origem
          AND tit_ap.cod_ser_docto = c-serie-origem
          AND tit_ap.cdn_fornecedor = nota-fiscal.cod-emitente
          AND tit_ap.cod_estab = nota-fiscal.cod-estabel
          AND tit_ap.dat_emis_docto = nota-fiscal.dt-emis-nota
          AND round(tit_ap.val_origin_tit_ap,2) = round(nota-fiscal.vl-tot-nota,2)
          AND tit_ap.cod_espec_docto = "AE"
          QUERY-TUNING(NO-LOOKAHEAD) :
            ASSIGN c-cod-tit-ap     = tit_ap.cod_tit_ap
                   c-cod-parcela    = tit_ap.cod_parcela
                   d-val-origin     = tit_ap.val_origin_tit_ap
                   d-val-saldo      = tit_ap.val_sdo_tit_ap.

    END. 

    chWorkSheet:Range("A" + STRING (i-linha)) = nota-fiscal.cod-estabel. 
    chWorkSheet:Range("B" + STRING (i-linha)) = nota-fiscal.nr-nota-fis.   
    chWorkSheet:Range("C" + STRING (i-linha)) = nota-fiscal.serie.   
    chWorkSheet:Range("D" + STRING (i-linha)) = STRING(nota-fiscal.cod-emitente). 
    chWorkSheet:Range("E" + STRING (i-linha)) = emitente.nome-emit.
    chWorkSheet:Range("F" + STRING (i-linha)) = nota-fiscal.dt-emis-nota. 
    chWorkSheet:Range("G" + STRING (i-linha)) = nota-fiscal.vl-tot-nota. 
    chWorkSheet:Range("H" + STRING (i-linha)) = c-nota-origem.     
    chWorkSheet:Range("I" + STRING (i-linha)) = c-serie-origem. 
    chWorkSheet:Range("J" + STRING (i-linha)) = c-cod-tit-ap. 
    chWorkSheet:Range("K" + STRING (i-linha)) = c-cod-parcela.
    chWorkSheet:Range("L" + STRING (i-linha)) = d-val-origin. 
    chWorkSheet:Range("M" + STRING (i-linha)) = d-val-saldo.  

    assign  i-linha = i-linha + 1. 


END.



/*
    
for each item-uni-estab no-lock
    where item-uni-estab.it-codigo      >= tt-param.it-codigo-ini
      and item-uni-estab.it-codigo      <= tt-param.it-codigo-fim  
      and item-uni-estab.cod-unid-negoc >= tt-param.cod-unid-negoc-ini
      and item-uni-estab.cod-unid-negoc <= tt-param.cod-unid-negoc-fim
      and item-uni-estab.cod-estabel    >= tt-param.cod-estabel-ini
      and item-uni-estab.cod-estabel    <= tt-param.cod-estabel-fim:
  
    find first item 
        where item-uni-estab.it-codigo   = item.it-codigo
          and item.ge-codigo            >= tt-param.ge-codigo-ini
          and item.ge-codigo            <= tt-param.ge-codigo-fim 
          and item.deposito-pad         >= tt-param.cod-depos-ini
          and item.deposito-pad         <= tt-param.cod-depos-fim
    no-lock no-error.

    if not avail item then next.
    
    find first grup-estoque no-lock
        where grup-estoque.ge-codigo = item.ge-codigo no-error.
    
    if not avail grup-estoque then next.
  
    chWorkSheet:Range("A" + STRING (i-linha)) = "~'" + item-uni-estab.it-codigo. 
    chWorkSheet:Range("B" + STRING (i-linha)) = "~'" + item.desc-item.   
    chWorkSheet:Range("C" + STRING (i-linha)) = "~'" + string(item.ge-codigo).   
    chWorkSheet:Range("D" + STRING (i-linha)) = "~'" + grup-estoque.descricao. 
    chWorkSheet:Range("E" + STRING (i-linha)) = "~'" + item.deposito-pad. 
    chWorkSheet:Range("F" + STRING (i-linha)) = "~'" + item-uni-estab.cod-estabel. 
    chWorkSheet:Range("G" + STRING (i-linha)) = "~'" + item-uni-estab.cod-unid-negoc. 
    chWorkSheet:Range("H" + STRING (i-linha)) = "~'" + string({ininc/i17in172.i 04 item-uni-estab.cod-obsol} ).     

    assign  i-linha = i-linha + 1. 
end.  

    */  
     

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


