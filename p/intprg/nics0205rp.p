/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICS0205RP 2.00.00.000}  /*** 020016 ***/

/* ---------------------[ VERSAO ]-------------------- */
/******************************************************************************
**
**   Programa: NICS0205RP.P
**
**   Objetivo: Listagem dos Custos dos Itens.
**
******************************************************************************/

define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field i-ge-codigo-ini      like item.ge-codigo
    field i-ge-codigo-fim      like item.ge-codigo  
    field c-fm-codigo-ini      like item.fm-codigo     
    field c-fm-codigo-fim      like item.fm-codigo    
    field c-it-codigo-ini      like item.it-codigo   
    field c-it-codigo-fim      like item.it-codigo     
    field c-descricao-1-ini    like item.desc-item   
    field c-descricao-1-fim    like item.desc-item
    field c-inform-compl-ini   like item.inform-compl  
    field c-inform-compl-fim   like item.inform-compl    
    field da-implant-ini       like item.data-implant       
    field da-implant-fim       like item.data-implant 
    field rs-item              as integer format ">9"
    field cod-estabel          like estabelec.cod-estabel
    field rs-preco             as integer format ">9"
    field descricao            like estabelec.nome.   

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-excel 
    FIELD cod-estabel  LIKE estabelec.cod-estabel
    FIELD it-codigo    LIKE item.it-codigo
    FIELD desc-item    LIKE item.desc-item
    FIELD un           LIKE item.un
    FIELD preco-base   LIKE item-uni-estab.preco-base
    FIELD preco-ul-ent LIKE item-uni-estab.preco-ul-ent
    FIELD data-base    LIKE item-uni-estab.data-base
    FIELD data-ult-ent LIKE item-uni-estab.data-ult-ent
    FIELD medio-ant    AS DEC FORMAT "->>>,>>9.9999"
    FIELD medio-atu    AS DEC FORMAT "->>>,>>9.9999"
    FIELD tp-controle  AS CHAR FORMAT "x(14)"
    FIELD obsoleto     AS CHAR FORMAT "x(28)"
    FIELD ge-codigo    LIKE ITEM.ge-codigo
    FIELD desc-ge      AS CHAR FORMAT "x(30)"
    FIELD fm-codigo    LIKE ITEM.fm-codigo
    FIELD desc-fm      AS CHAR FORMAT "x(30)"
    INDEX ITEM it-codigo.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

{cdp/cdcfgman.i}

create tt-param.
raw-transfer raw-param to tt-param.

def buffer b-item for item.
def buffer b-item-estab for item-estab.
&IF DEFINED (bf_man_custeio_item) &THEN
    def buffer b-item-uni-estab for item-uni-estab.
&ENDIF

def var i-grupo-ini as integer format "99" init 0 no-undo.
def var i-grupo-fim as integer format "99" init 99 no-undo.
def var c-familia-aux like item.fm-codigo no-undo.
def var c-familia-ini as character format "x(8)" init "" no-undo.
def var c-familia-fim as character format "x(8)" init "ZZZZZZZZ" no-undo.
def var c-item-ini as character format "x(16)" init "" no-undo.
def var c-item-fim as character format "x(16)" init "ZZZZZZZZZZZZZZZZ" no-undo.
def var c-descr-ini as character format "x(18)" init "" no-undo.
def var c-descr-fim as character format "x(18)" init "ZZZZZZZZZZZZZZZZZZ" no-undo.
def var c-inf-ini as character format "x(16)" init "" no-undo.
def var c-inf-fim as character format "x(16)" init "ZZZZZZZZZZZZZZZZ" no-undo.
def var d-data-ini as date format "99/99/9999" init &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF no-undo.
def var d-data-fim as date format "99/99/9999" init 12/31/9999 no-undo.
DEF VAR da-medio-ant AS DATE FORMAT "99/99/9999" NO-UNDO.

def var c-opcao-obs as character init "1" no-undo.
def var c-obs as char format "x(01)".
def var c-cha as char format "x(01)".
def var c-gr-estoq as char format "x(22)". 
def var c-fam as char format "x(13)".
def var c-desc as char format "x(23)".
def var h-acomp as handle no-undo. 
def var c-destino       as char format "x(10)" no-undo.
def var c-arquivo       as char format "x(40)" no-undo.

DEF VAR de-medio-ant       AS DEC FORMAT "->>>,>>9.9999"   NO-UNDO.
DEF VAR de-medio-atu       AS DEC FORMAT "->>>,>>9.9999"   NO-UNDO.
DEF VAR c-tp-controle      AS CHAR FORMAT "x(14)" NO-UNDO.
DEF VAR c-obsoleto         AS CHAR FORMAT "x(28)" NO-UNDO.
DEF VAR i-linha            AS INT NO-UNDO.



create tt-param.
raw-transfer raw-param to tt-param.    

assign i-grupo-ini   = i-ge-codigo-ini     
       i-grupo-fim   = i-ge-codigo-fim      
       c-familia-ini = c-fm-codigo-ini      
       c-familia-fim = c-fm-codigo-fim      
       c-item-ini    = c-it-codigo-ini      
       c-item-fim    = c-it-codigo-fim      
       c-descr-ini   = c-descricao-1-ini    
       c-descr-fim   = c-descricao-1-fim    
       c-inf-ini     = c-inform-compl-ini   
       c-inf-fim     = c-inform-compl-fim   
       d-data-ini    = da-implant-ini       
       d-data-fim    = da-implant-fim.   

assign c-obs       = string(rs-item)
       c-opcao-obs = substring(c-obs,1,1). 

{utp/ut-liter.i Custos_dos_Itens mcs}

run utp/ut-acomp.p persistent set h-acomp. 


DEF VAR ChExcel      AS office.iface.excel.ExcelWrapper.
DEF VAR ChBook       AS office.iface.excel.WorkBook    .
DEF VAR ChSheet      AS office.iface.excel.WorkSheet   .



 ASSIGN ChExcel     = NEW office.libre.excel.ExcelWrapper().      
 ASSIGN  ChBook     = ChExcel:WorkBooks:ADD()                                                                                     
         ChSheet    = ChExcel:ActiveSheet .                                                                                        
      //   ChSheet    = ChBook:Worksheets("Plan1").


ASSIGN ChSheet:Name                                 = "Custos dos Itens"
       ChSheet:range("A1:P1"):MergeCells            = TRUE
       ChSheet:range("A1"):VALUE                    = "Custos dos Itens - EmissÆo: " + STRING(TODAY,"99/99/9999")
       ChSheet:range("A1:P1"):FONT:bold             = TRUE
       ChSheet:range("A1:P1"):FONT:SIZE             = 22
       ChSheet:range("A1:P1"):Interior:ColorIndex   = 15
       ChSheet:range("A1:P1"):HorizontalAlignment   = 3
       ChSheet:range("A1:P1"):Borders(7):LineStyle  = 1
       ChSheet:range("A1:P1"):Borders(7):Weight     = 3
       ChSheet:range("A1:P1"):Borders(8):LineStyle  = 1
       ChSheet:range("A1:P1"):Borders(8):Weight     = 3
       ChSheet:range("A1:P1"):Borders(9):LineStyle  = 1
       ChSheet:range("A1:P1"):Borders(9):Weight     = 3
       ChSheet:range("A1:P1"):Borders(10):LineStyle = 1
       ChSheet:range("A1:P1"):Borders(10):Weight    = 3.

{utp/ut-liter.i Listagem_dos_Custos_dos_Itens mcs}
run pi-inicializar in h-acomp (return-value).

EMPTY TEMP-TABLE tt-excel.

FIND FIRST param-estoq NO-LOCK NO-ERROR.

ASSIGN da-medio-ant = date(month(param-estoq.mensal-ate),01,YEAR(param-estoq.mensal-ate)) - 1.

for each ITEM where
    item.it-codigo    >= c-item-ini    and item.it-codigo    <= c-item-fim and
    item.ge-codigo    >= i-grupo-ini   and item.ge-codigo    <= i-grupo-fim and
    item.fm-codigo    >= c-familia-ini and item.fm-codigo    <= c-familia-fim and
    item.desc-item    >= c-descr-ini   and item.desc-item    <= c-descr-fim and
    item.inform-compl >= c-inf-ini     and item.inform-compl <= c-inf-fim and
    item.data-implant >= d-data-ini    and item.data-implant <= d-data-fim no-lock 
    &IF DEFINED (bf_man_custeio_item) &THEN 
        ,first item-uni-estab where
               item-uni-estab.it-codigo   = item.it-codigo and
               item-uni-estab.cod-estabel = tt-param.cod-estabel no-lock
    &ENDIF
    on stop undo, LEAVE QUERY-TUNING(NO-LOOKAHEAD):
           
    if c-opcao-obs = "2" and item.cod-obsoleto > 1 then
       next.
    if c-opcao-obs = "3" and item.cod-obsoleto = 1 then
       next.
    
    find FIRST grup-estoque of item no-lock NO-ERROR.
    FIND FIRST familia      OF ITEM NO-LOCK NO-ERROR.

    if item.tipo-contr = 1 then        
       assign c-tp-controle = "F¡sico".
    if item.tipo-contr = 2 then        
       assign c-tp-controle = "Total".
    if item.tipo-contr = 3 then        
       assign c-tp-controle = "Consignado".
    if item.tipo-contr = 4 then        
       assign c-tp-controle = "D‚bito Direto".
    if item.tipo-contr = 5 then        
       assign c-tp-controle = "NÆo Definido".

    if item.cod-obsoleto = 1 then
       assign c-obsoleto = "Ativo".
    if item.cod-obsoleto = 2 then
       assign c-obsoleto = "Obsoleto Ordens Autom ticas".
    if item.cod-obsoleto = 3 then
       assign c-obsoleto = "Obsoleto Todas as Ordens".
    if item.cod-obsoleto = 4 then
       assign c-obsoleto = "Totalmente Obsoleto".

    assign de-medio-ant = 0
           de-medio-atu = 0.

    for each pr-it-per where 
             pr-it-per.it-codigo   = item.it-codigo and
             pr-it-per.cod-estabel = tt-param.cod-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
         
        IF pr-it-per.periodo = da-medio-ant THEN
           ASSIGN de-medio-ant = pr-it-per.val-unit-mat-m[1] + pr-it-per.val-unit-mob-m[1] + pr-it-per.val-unit-ggf-m[1].
        
        IF pr-it-per.periodo = param-estoq.mensal-ate THEN
           ASSIGN de-medio-atu = pr-it-per.val-unit-mat-m[1] + pr-it-per.val-unit-mob-m[1] + pr-it-per.val-unit-ggf-m[1].
    end.

    CREATE tt-excel.
    ASSIGN tt-excel.cod-estabel = tt-param.cod-estabel
           tt-excel.it-codigo   = item.it-codigo
           tt-excel.desc-item   = ITEM.desc-item
           tt-excel.un          = ITEM.un.

   /*&IF DEFINED (bf_man_custeio_item) &THEN*/
       ASSIGN tt-excel.preco-base   = item-uni-estab.preco-base 
              tt-excel.preco-ul-ent = item-uni-estab.preco-ul-ent 
              tt-excel.data-base    = item-uni-estab.data-base   
              tt-excel.data-ult-ent = item-uni-estab.data-ult-ent.
   /*&ELSE        
       ASSIGN tt-excel.preco-base   = item.preco-base
              tt-excel.preco-ul-ent = item.preco-ul-ent
              tt-excel.data-base    = item.data-base
              tt-excel.data-ult-ent = item.data-ult-ent.
   &ENDIF*/
   
   ASSIGN tt-excel.medio-ant   = de-medio-ant
          tt-excel.medio-atu   = de-medio-atu
          tt-excel.tp-controle = c-tp-controle
          tt-excel.obsoleto    = c-obsoleto
          tt-excel.ge-codigo   = ITEM.ge-codigo
          tt-excel.desc-ge     = IF AVAIL grup-estoque THEN grup-estoque.descricao ELSE ""
          tt-excel.fm-codigo   = ITEM.fm-codigo
          tt-excel.desc-fm     = IF AVAIL familia THEN familia.descricao ELSE "".

    run pi-acompanhar in h-acomp (input "Item: " + item.it-codigo).
end.

ASSIGN i-linha = 2.

ChSheet:range("A" + STRING(i-linha)):VALUE                 = "Estab".                                 
ChSheet:range("A" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("A" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("B" + STRING(i-linha)):VALUE                 = "Item".                                 
ChSheet:range("B" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("B" + STRING(i-linha)):Borders(7):Weight     = 3.
                                                                                                         
ChSheet:range("C" + STRING(i-linha)):VALUE                 = "Descri‡Æo".                            
ChSheet:range("C" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ChSheet:range("C" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ChSheet:range("D" + STRING(i-linha)):VALUE                 = "Un".                                   
ChSheet:range("D" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ChSheet:range("D" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ChSheet:range("E" + STRING(i-linha)):VALUE                 = "Pre‡o Ult Entrada".                               
ChSheet:range("E" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                       
ChSheet:range("E" + STRING(i-linha)):Borders(7):Weight     = 3.                                    
                                                                                                         
ChSheet:range("F" + STRING(i-linha)):VALUE                 = "Dt Ult Entrada".                             
ChSheet:range("F" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ChSheet:range("F" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ChSheet:range("G" + STRING(i-linha)):VALUE                 = "Pre‡o Base".                                
ChSheet:range("G" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ChSheet:range("G" + STRING(i-linha)):Borders(7):Weight     = 3.                                      

ChSheet:range("H" + STRING(i-linha)):VALUE                 = "Data Base".
ChSheet:range("H" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("H" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("I" + STRING(i-linha)):VALUE                 = "M‚dio " + STRING(da-medio-ant,"99/99/9999").
ChSheet:range("I" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("I" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("J" + STRING(i-linha)):VALUE                 = "M‚dio " + STRING(param-estoq.mensal-ate,"99/99/9999").
ChSheet:range("J" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("J" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("K" + STRING(i-linha)):VALUE                 = "Tipo Controle".
ChSheet:range("K" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("K" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("L" + STRING(i-linha)):VALUE                 = "Cod. Obsoleto".
ChSheet:range("L" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("L" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("M" + STRING(i-linha)):VALUE                 = "Gr Est".
ChSheet:range("M" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("M" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("N" + STRING(i-linha)):VALUE                 = "Descri‡Æo".
ChSheet:range("N" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("N" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("O" + STRING(i-linha)):VALUE                 = "Fam¡lia".
ChSheet:range("O" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("O" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("P" + STRING(i-linha)):VALUE                 = "Descri‡Æo".
ChSheet:range("P" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("P" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("Q" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("Q" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Interior:ColorIndex  = 15.
ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(8):LineStyle = 1.
ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(8):Weight    = 3.
ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(9):LineStyle = 1.
ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(9):Weight    = 3.

FOR EACH tt-excel USE-INDEX ITEM: 

    run pi-acompanhar in h-acomp (input "Gerando Planilha - Item: " + tt-excel.it-codigo).

    ASSIGN i-linha = i-linha + 1.
    
    ChSheet:range("A" + STRING(i-linha)):VALUE = tt-excel.cod-estabel.
    /*ChSheet:range("B" + STRING(i-linha)):NumberFormat = "@".*/
    ChSheet:range("B" + STRING(i-linha)):VALUE = tt-excel.it-codigo.
    ChSheet:range("C" + STRING(i-linha)):VALUE = tt-excel.desc-item.                          
    ChSheet:range("D" + STRING(i-linha)):VALUE = tt-excel.un.         
    ChSheet:range("E" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ChSheet:range("E" + STRING(i-linha)):VALUE = string(tt-excel.preco-ul-ent).
    ChSheet:range("F" + STRING(i-linha)):VALUE = string(tt-excel.data-ult-ent).                             
    ChSheet:range("G" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".                               
    ChSheet:range("G" + STRING(i-linha)):VALUE = string(tt-excel.preco-base). 
    ChSheet:range("H" + STRING(i-linha)):VALUE = string(tt-excel.data-base).
    ChSheet:range("I" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".                               
    ChSheet:range("I" + STRING(i-linha)):VALUE = string(tt-excel.medio-ant). 
    ChSheet:range("J" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".                               
    ChSheet:range("J" + STRING(i-linha)):VALUE = string(tt-excel.medio-atu).  
    ChSheet:range("K" + STRING(i-linha)):VALUE = tt-excel.tp-controle.                
    ChSheet:range("L" + STRING(i-linha)):VALUE = tt-excel.obsoleto.                 
    ChSheet:range("M" + STRING(i-linha)):VALUE = string(tt-excel.ge-codigo).                        
    ChSheet:range("N" + STRING(i-linha)):VALUE = tt-excel.desc-ge.                  
    ChSheet:range("O" + STRING(i-linha)):VALUE = tt-excel.fm-codigo.                         
    ChSheet:range("P" + STRING(i-linha)):VALUE = tt-excel.desc-fm.   
END.                                                                                                                
                                                                                                                          
ChSheet:range("A2:A" + STRING(i-linha)):HorizontalAlignment   = 3.                                                     
ChSheet:range("A2:A" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                                       
ChSheet:range("A2:A" + STRING(i-linha)):Borders(7):Weight     = 3.                                                    
                                                                                                                
ChSheet:range("B2:B" + STRING(i-linha)):HorizontalAlignment   = 3.                                      
ChSheet:range("B2:B" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                          
ChSheet:range("B2:B" + STRING(i-linha)):Borders(7):Weight     = 3.                                          
                                                                                                                
ChSheet:range("C2:C" + STRING(i-linha)):HorizontalAlignment   = 3.                                          
ChSheet:range("C2:C" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                          
ChSheet:range("C2:C" + STRING(i-linha)):Borders(7):Weight     = 3.                                          
                                                                                                                
ChSheet:range("D2:D" + STRING(i-linha)):HorizontalAlignment   = 3.                                      
ChSheet:range("D2:D" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("D2:D" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("E2:E" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("E2:E" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("E2:E" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("F2:F" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("F2:F" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("F2:F" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("G2:G" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("G2:G" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("G2:G" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("H2:H" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("H2:H" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("H2:H" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("I2:I" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("I2:I" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("I2:I" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("J2:J" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("J2:J" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("J2:J" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("K2:K" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("K2:K" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("K2:K" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("L2:L" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("L2:L" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("L2:L" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("M2:M" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("M2:M" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("M2:M" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("N2:N" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("N2:N" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("N2:N" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("O2:O" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("O2:O" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("O2:O" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("P2:P" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("P2:P" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("P2:P" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("Q2:Q" + STRING(i-linha)):HorizontalAlignment   = 3.
ChSheet:range("Q2:Q" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ChSheet:range("Q2:Q" + STRING(i-linha)):Borders(7):Weight     = 3.

ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(9):LineStyle = 1.
ChSheet:range("A" + STRING(i-linha) + ":" + "P" + STRING(i-linha)):Borders(9):Weight    = 3.

ChSheet:SELECT().
// ChExcel:COLUMNS("A:AD"):AutoFit.

DEFINE VARIABLE cUser     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDateTime AS CHARACTER NO-UNDO.

cUser = OS-GETENV("USERNAME").

/* Monta data e hora: YYYYMMDD_HHMMSS */
cDateTime = STRING(YEAR(TODAY),"9999") + "-" +
            STRING(MONTH(TODAY),"99") + "-" +
            STRING(DAY(TODAY),"99") + "_" +
            STRING(TIME).


if tt-param.destino = 2 then do:

   ChExcel:VISIBLE = no.
    //colocar comando para salvar em diretorio excel.
   //ChExcel:Workbooks:Item(1):SaveAs("D:\Shares\Nissei\RPW\prod\rpw-fila3\" + "NICS0205 - " + tt-param.cod-estabel + ".xlsx").
   ChExcel:Workbooks:Item(1):SaveAs("\\10.0.1.3\cjem8f\rpw\prod\rpw-fila3\" + "NICS0205 - " + tt-param.cod-estabel + "_" + cDateTime + ".xlsx").
   //ChExcel:Workbooks:Item(1):SaveAs(session:temp-directory + "NICS0205_" + tt-param.cod-estabel + "_" + cDateTime + ".xlsx").
end.
else do:
   ChExcel:VISIBLE = YES.
end.


/*IF VALID-HANDLE(ChExcel) THEN
   RELEASE OBJECT ChExcel.*/
/*IF VALID-HANDLE(chWorkbook) THEN
   RELEASE OBJECT chWorkbook.*/
/*IF VALID-HANDLE(ChSheet) THEN
   RELEASE OBJECT ChSheet.*/

run pi-finalizar in h-acomp.   

return "OK".
