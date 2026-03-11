/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT094RP 1.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i int094rp cdp }
&ENDIF

{cdp/cdcfgdis.i}
  
define temp-table TT-PARAM NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD cod-estabel-ini    AS CHAR FORMAT "x(5)"
       FIELD cod-estabel-fim    AS CHAR FORMAT "x(5)"
       FIELD planilha           AS CHAR.

define temp-table tt-msg
    FIELD linha         AS INT
    FIELD cod-estabel   AS CHAR
    FIELD periodo       AS CHAR
    field cod-ajuste    AS CHAR
    field cod-lanc      AS CHAR
    field valor         AS DEC 
    FIELD descricao     AS CHAR.

DEFINE TEMP-TABLE tt-imp
    FIELD col-a       AS CHAR    /* Estab */
    field col-b       as CHAR    /* UF */
    field col-c       as CHAR    /* Periodo */
    field col-d       as CHAR    /* C¢digo Ajuste */
    field col-e       as CHAR    /* C¢digo Lan‡amento */
    field col-f       as CHAR    /* Descri‡Æo */
    field col-g       as DEC     /* Valor */
    .

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

DEF VAR h-excel       AS HANDLE      NO-UNDO.
DEF VAR chExcel       AS office.iface.excel.ExcelWrapper NO-UNDO.
DEF VAR c-arq-csv     AS CHAR        NO-UNDO.
DEF VAR i-atualizados AS INT         NO-UNDO.     

DEFINE STREAM s-import.

def var h-acomp         as handle       no-undo.
def var c-selecao       as char no-undo format "x(20)" init "SELE€ÇO".
def var c-impressao     as char no-undo format "x(20)" init "IMPRESSÇO". 
def var c-msg           as char no-undo format "X(10)".
def var l-atualizou     as logical INIT NO no-undo.
DEF VAR l-alterou       AS LOGICAL NO-UNDO.
DEF VAR i-seq-int_ds_item AS INT NO-UNDO.
DEF VAR i-zeros         AS INT NO-UNDO.
DEF VAR c-class         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR c-zeros         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR i-cont          AS INT NO-UNDO.


DEFINE BUFFER b-item FOR ITEM.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Aguarde !").

{include/i-rpvar.i}

{utp/ut-liter.i SELE€ÇO *}
assign c-selecao = return-value.

{utp/ut-liter.i IMPRESSÇO *}
assign c-impressao = return-value.

create tt-param.
raw-transfer raw-param to tt-param.                    
find first param-global no-lock no-error.



form
    tt-msg.linha            column-label "Linha"                at 1 
    tt-msg.cod-estabel      column-label "Filial"               at 13 
    tt-msg.periodo          column-label "Periodo"              at 23 
    tt-msg.cod-ajuste       column-label "C¢digo Ajuste"        at 35 
    tt-msg.cod-lanc         column-label "C¢digo Lan‡amento"    at 52  
    tt-msg.valor            column-label "Valor"                AT 75  
    tt-msg.descricao        column-label "Descri‡Æo"            AT 90  
    with DOWN STREAM-IO width 132 frame f-impressao.
    

assign c-empresa  = param-global.grupo
       c-programa = "INT094"
       c-versao   = "1.00"
       c-revisao  = "000KML".

assign c-titulo-relat = "IMPORTACAO EXCEL".
assign c-sistema      = "CADASTROS".

{utp/ut-glob.i}

RUN pi-importa-excel.


{include/i-rpcab.i}
{include/i-rpout.i}

RUN pi-processa.

RUN pi-finalizar IN h-acomp.

{include/i-rpclo.i}

return "OK":U.

/*******************************************************************************************************************************************************************************************/

PROCEDURE pi-importa-excel:

    DEFINE VARIABLE i-linha AS INTEGER    NO-UNDO.

    DEFINE VARIABLE l-erro-linha AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE l-erro       AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE ch-arquivo        AS office.iface.excel.Workbook  NO-UNDO. 
    DEFINE VARIABLE ch-planilha       AS office.iface.excel.WorkSheet NO-UNDO.
    DEFINE VARIABLE c-arquivo         AS CHARACTER   NO-UNDO.

    IF VALID-HANDLE(h-acomp) THEN DO:
        {utp/ut-liter.i Importando * l}
        RUN pi-acompanhar IN h-acomp (INPUT TRIM(RETURN-VALUE) + "...":U).
    END.

    EMPTY TEMP-TABLE tt-imp.

    ASSIGN i-linha = 1
           l-erro  = NO.

    //CREATE 'excel.application' chExcel NO-ERROR.
    ASSIGN chExcel     = NEW office.libre.excel.ExcelWrapper().
    ASSIGN chExcel     =  chExcel:APPLICATION.
           ch-arquivo  =  chExcel:workBooks:OPEN(tt-param.planilha).          
           ch-planilha =  ChExcel:Sheets:ITEM(1).          
            

     REPEAT ON ENDKEY UNDO, LEAVE:

        ASSIGN i-linha      = i-linha + 1
               l-erro-linha = NO.

        IF i-linha <= 1 THEN NEXT.

        IF chExcel:Range("A"  + STRING(i-linha)):TEXT = "" THEN LEAVE. /* Estab branco nao importa */

        RUN pi-acompanhar IN h-acomp (INPUT "Registros Lidos : " + STRING(i-linha) ).

        ASSIGN i-atualizados = 0.


        IF chExcel:Range("A"  + STRING(i-linha)):TEXT  >= tt-param.cod-estabel-ini   AND  /* estab */
           chExcel:Range("A"  + STRING(i-linha)):TEXT  <= tt-param.cod-estabel-fim     THEN DO:   
           
            CREATE tt-imp.
            ASSIGN tt-imp.col-a                       = string(int(chExcel:Range("A"  + STRING(i-linha)):TEXT), "999") // Cod estab  
                   tt-imp.col-b                       = chExcel:Range("B"  + STRING(i-linha)):TEXT                     // UF
                   tt-imp.col-c                       = chExcel:Range("C"  + STRING(i-linha)):TEXT                     // Periodo
                   tt-imp.col-d                       = chExcel:Range("D"  + STRING(i-linha)):TEXT                     // C¢digo Ajuste
                   tt-imp.col-e                       = chExcel:Range("E"  + STRING(i-linha)):TEXT                     // C¢digo Lan‡amento
                   tt-imp.col-f                       = chExcel:Range("F"  + STRING(i-linha)):TEXT                     // Descri‡Æo
                   tt-imp.col-g                       = dec(chExcel:Range("G"  + STRING(i-linha)):TEXT).               // Valor

                                                                                                                                                                                                                   
            ASSIGN i-atualizados = i-atualizados + 1.  

        END.                                                                                                                                                                                                                                                                                              
    END.   

 END PROCEDURE.                                                                                                                                                                                                                                                                                           


PROCEDURE pi-processa:

    DEFINE VARIABLE i-linha     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE da-data-ini AS DATE     NO-UNDO.
    DEFINE VARIABLE da-data-fim AS DATE     NO-UNDO.
    DEFINE VARIABLE c-cod-lanc  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-seq-lanc AS INTEGER     NO-UNDO.
    DEFINE VARIABLE h-bofi281 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE c-desc AS CHARACTER FORMAT "x(256)"  NO-UNDO. 

    ASSIGN i-linha = 1   .

    RUN fibo\bofi281.p PERSISTENT SET h-bofi281.

    blk-imp:
    FOR EACH tt-imp:

        ASSIGN i-linha = i-linha + 1.

        ASSIGN da-data-ini = date(tt-imp.col-c)
               da-data-fim = DATE(STRING(DAY(da-data-ini), "99") + "/" + string(MONTH(da-data-ini) + 1, "99") + "/" + string(YEAR(da-data-ini), "9999")) - 1.

        
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = tt-imp.col-a NO-ERROR.

        IF NOT AVAIL estabelec THEN DO:

            CREATE tt-msg.
            ASSIGN tt-msg.linha         = i-linha
                   tt-msg.cod-estabel   = tt-imp.col-a
                   tt-msg.periodo       = tt-imp.col-c
                   tt-msg.cod-ajuste    = tt-imp.col-d
                   tt-msg.cod-lanc      = tt-imp.col-e
                   tt-msg.valor         = tt-imp.col-g
                   tt-msg.descricao     = "Estabelecimento nÆo cadastrado".
            NEXT blk-imp.

        END.

        FIND FIRST apur-imposto NO-LOCK
            WHERE apur-imposto.cod-estabel = tt-imp.col-a 
              AND apur-imposto.dt-apur-ini = da-data-ini
              AND apur-imposto.dt-apur-fim = da-data-fim 
              AND apur-imposto.tp-imposto  = 1 /* ICMS */ NO-ERROR.

        IF NOT AVAIL apur-imposto THEN DO:

            CREATE apur-imposto.
            ASSIGN apur-imposto.cod-estabel = tt-imp.col-a 
                   apur-imposto.dt-apur-ini = da-data-ini  
                   apur-imposto.dt-apur-fim = da-data-fim  
                   apur-imposto.tp-imposto  = 1 /* ICMS */ .

        END.

        RUN validateCodAjust2 IN h-bofi281("1016",TRIM(tt-imp.col-d),OUTPUT c-desc).
        
        IF c-desc = "" THEN DO:

            CREATE tt-msg.
            ASSIGN tt-msg.linha         = i-linha
                   tt-msg.cod-estabel   = tt-imp.col-a
                   tt-msg.periodo       = tt-imp.col-c
                   tt-msg.cod-ajuste    = tt-imp.col-d
                   tt-msg.cod-lanc      = tt-imp.col-e
                   tt-msg.valor         = tt-imp.col-g
                   tt-msg.descricao     = "C¢digo Ajuste nÆo cadastrado".
            NEXT blk-imp.

        END.

        CASE tt-imp.col-e:
        
           when "Outros D‚bitos" then 
               assign c-cod-lanc = "002".
           when "Estorno de Cr‚ditos" then
               assign c-cod-lanc = "003".
           when "Outros Cr‚ditos" then
               assign c-cod-lanc = "006".
           when "Estorno de D‚bitos" then
               assign c-cod-lanc = "007".
           when "Saldo Credor do per¡odo anterior" then
               assign c-cod-lanc = "009".
           when "Dedu‡äes" then
               assign c-cod-lanc = "012".
           otherwise do:

                CREATE tt-msg.
                ASSIGN tt-msg.linha         = i-linha
                       tt-msg.cod-estabel   = tt-imp.col-a
                       tt-msg.periodo       = tt-imp.col-c
                       tt-msg.cod-ajuste    = tt-imp.col-d
                       tt-msg.cod-lanc      = tt-imp.col-e
                       tt-msg.valor         = tt-imp.col-g
                       tt-msg.descricao     = "C¢digo Lan‡amento nÆo existe".
                NEXT blk-imp.

           END.

        END CASE.

        // Se os dados estiverem corretos cria-se a importa‡Æo


        ASSIGN i-seq-lanc = i-seq-lanc + 1.

        CREATE imp-valor.
        ASSIGN imp-valor.cod-estabel            = apur-imposto.cod-estabel
               imp-valor.tp-imposto             = apur-imposto.tp-imposto 
               imp-valor.dt-apur-ini            = apur-imposto.dt-apur-ini 
               imp-valor.dt-apur-fim            = apur-imposto.dt-apur-fim 
               imp-valor.cod-lanc               = int(c-cod-lanc)
               OVERLAY(imp-valor.char-1,11,20)  = TRIM(tt-imp.col-d)
               imp-valor.nr-sequencia           = i-seq-lanc
               imp-valor.descricao              = tt-imp.col-f
               imp-valor.vl-lancamento          = tt-imp.col-g.


        CREATE tt-msg.
        ASSIGN tt-msg.linha         = i-linha
               tt-msg.cod-estabel   = tt-imp.col-a
               tt-msg.periodo       = tt-imp.col-c
               tt-msg.cod-ajuste    = tt-imp.col-d
               tt-msg.cod-lanc      = tt-imp.col-e
               tt-msg.valor         = tt-imp.col-g
               tt-msg.descricao     = "Impostado com Sucesso".



    END.

    DELETE PROCEDURE h-bofi281.

    FOR EACH tt-msg:

        DISP tt-msg.linha      
             tt-msg.linha     
             tt-msg.cod-estabel
             tt-msg.periodo      FORMAT "X(10)"
             tt-msg.cod-ajuste   FORMAT "X(15)"  
             tt-msg.cod-lanc     FORMAT "X(20)" 
             tt-msg.valor     
             tt-msg.descricao FORMAT "X(40)" 
             WITH FRAME f-impressao. 
         down with frame f-impressao.

    END.                             

END PROCEDURE.

