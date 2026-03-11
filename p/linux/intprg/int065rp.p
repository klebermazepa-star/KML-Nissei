/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int065RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int065RP
**
**       DATA....: 09/2016
**
**       OBJETIVO: Relat¢rio de PIS/COFINS por NCM
**
**       VERSAO..: 2.06.002
** 
******************************************************************************/
{include/i-rpvar.i}
{include/i-rpcab.i}
{intprg/nicr003arp.i}
/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char    format "x(12)"   no-undo.

{method/dbotterr.i} 
{cdp/cd0666.i}  /*     Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    field data-ini         like mgcad.doc-fiscal.dt-docto
    field data-fim         like mgcad.doc-fiscal.dt-docto
    field l-compras        AS LOGICAL
    field l-devol-cliente AS LOGICAL
    field l-devol-forn AS LOGICAL
    field l-perdas AS LOGICAL
    field l-reducaoz AS LOGICAL
    field l-nfce AS LOGICAL
    field c-cod-estabel-ini as char
    field c-cod-estabel-fim as char    .

define temp-table tt-digita no-undo
    field nat-operacao    as CHARACTER   format "x(6)"
    field denominacao     as CHARACTER format "x(100)"
    index id nat-operacao.

def temp-table tt-raw-digita
    field raw-digita as raw.
    
define temp-table tt-ncm-pis-cofins no-undo
    field aba                  as char format "x(25)"
    field class-fiscal         like it-doc-fisc.class-fiscal
    field vl-tot-item          like it-doc-fisc.vl-tot-item
    field val-base-calc-pis    like it-doc-fisc.val-base-calc-pis
    field val-pis              like it-doc-fisc.val-pis
    field val-base-calc-cofins like it-doc-fisc.val-base-calc-cofins
    field val-cofins           like it-doc-fisc.val-cofins
    field tp-trib-pis          as char format "x(12)" 
    field tp-trib-cofins       as char format "x(12)"
    FIELD nat-operacao         LIKE it-doc-fisc.nat-operacao   
    FIELD cod-cfop             LIKE natur-oper.cod-cfop
    
    
    INDEX id aba 
             class-fiscal
             tp-trib-pis 
             tp-trib-cofins nat-operacao cod-cfop.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEFINE TEMP-TABLE tt-erro-aux NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.   

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER raw-digita TO tt-digita.
END.

def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.

DEF VAR dTot-vl-tot-item          LIKE tt-ncm-pis-cofins.vl-tot-item NO-UNDO. 
DEF VAR dTot-val-base-calc-pis     LIKE tt-ncm-pis-cofins.val-base-calc-pis NO-UNDO.
DEF VAR dTot-val-pis              LIKE tt-ncm-pis-cofins.val-pis NO-UNDO.
DEF VAR dTot-val-base-calc-cofins LIKE tt-ncm-pis-cofins.val-base-calc-cofins NO-UNDO.
DEF VAR dTot-val-cofins           LIKE tt-ncm-pis-cofins.val-cofins NO-UNDO.


DEF VAR  vl-aliquotaPIS    like it-doc-fisc.aliq-pis NO-UNDO.
DEF VAR  vl-BasePIS        like tt-ncm-pis-cofins.val-base-calc-pis NO-UNDO.
DEF VAR  vl-PIS            like tt-ncm-pis-cofins.val-pis NO-UNDO.
DEF VAR  TribPIS           AS INTEGER INIT 1 NO-UNDO.
DEF VAR  vl-aliquotaCOFINS like it-doc-fisc.aliq-cofins NO-UNDO.
DEF VAR  vl-BaseCOFINS     like tt-ncm-pis-cofins.val-base-calc-cofins NO-UNDO.
DEF VAR  vl-COFINS         like tt-ncm-pis-cofins.val-cofins NO-UNDO.
DEF VAR  TribCOFINS        AS INTEGER INIT 1 NO-UNDO.

DEF VAR i-ind              AS INTEGER NO-UNDO.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "int065RP"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i PIS/COFINS_por_NCM * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i PIS/COFINS_por_NCM * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

                   
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Geracao_Titulo_Convenio.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                                */
     
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Leitura dos Documentos").
EMPTY TEMP-TABLE tt-ncm-pis-cofins.
IF tt-param.l-compras or 
   tt-param.l-devol-cliente THEN
   RUN pi-ncm-compras.

IF tt-param.l-devol-forn or 
   tt-param.l-reducaoz or 
   tt-param.l-nfce THEN
   RUN pi-ncm-devol-fornecedor.

IF tt-param.l-perdas THEN
   RUN pi-ncm-perdas.

RUN pi-gera-relatorio.

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log(). */

{include/i-rpclo.i}   

/* IF CAN-FIND(FIRST tt-digita) THEN DO: */
/*     RUN winexec (INPUT "notepad.exe" + CHR(32) + tt-param.arquivo, INPUT 1). */
/* END. */

return "OK":U.

PROCEDURE pi-gera-relatorio:

    RUN pi-seta-titulo IN h-acomp (INPUT "Gerando o Excel").

    DEFINE VARIABLE chExcel       AS COM-HANDLE NO-UNDO. /* Documento Excel */
    DEFINE VARIABLE chWorksheet   AS COM-HANDLE NO-UNDO. /* Abas da Planilha */
    DEFINE VARIABLE chWorkbook    AS COM-HANDLE NO-UNDO. /* Planilha */
    
    DEF VAR xsheet AS INTEGER INIT 1 NO-UNDO.
    DEF VAR xlinha AS INTEGER INIT 1 NO-UNDO.
    
    CREATE "Excel.Application" chExcel.        /*criar planilha*/
    chExcel:DisplayAlerts = FALSE. 
    chExcel:VISIBLE = FALSE.                    /*visualiza o relat¢rio no excel automaticamente*/
    chWorkBook      = chExcel:WorkBooks:ADD(search("layout\Modelo_int999.xls")). /*Adiciona a primeira aba*/
    
    /* Seleciona Aba da Planilha */
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Aba Completa...").

    ASSIGN xlinha = 1.
        
    /* INICIO - IMPRESSÇO ABA COMPLETA */ 
    FOR EACH tt-ncm-pis-cofins NO-lOCK
    BREAK BY tt-ncm-pis-cofins.aba :
    
        IF FIRST-OF(tt-ncm-pis-cofins.aba) THEN DO:
            ASSIGN chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("A" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.aba         
                   xlinha                                         = xlinha + 1
                   chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE 
                   chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "NCM"
                   chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("B" + STRING(xlinha)):VALUE  = "Valor Cont bil":U 
                   chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("C" + STRING(xlinha)):VALUE  = "Base PIS"
                   chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("D" + STRING(xlinha)):VALUE  = "Valor PIS"
                   chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("E" + STRING(xlinha)):VALUE  = "Base COFINS"
                   chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("F" + STRING(xlinha)):VALUE  = "Valor COFINS"
                   chWorkSheet:range("G" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("G" + STRING(xlinha)):VALUE  = "Trib. PIS"
                   chWorkSheet:range("H" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("H" + STRING(xlinha)):VALUE  = "Trib. COFINS"  
                   chWorkSheet:range("I" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("I" + STRING(xlinha)):VALUE  = "CFOP"   
                   chWorkSheet:range("J" + STRING(xlinha)):Font:Bold = TRUE
                   chWorksheet:Range("J" + STRING(xlinha)):VALUE  = "Natureza"
                   xlinha                                         = xlinha + 1 .

            ASSIGN dTot-vl-tot-item          = 0
                   dTot-val-base-calc-pis    = 0
                   dTot-val-pis              = 0
                   dTot-val-base-calc-cofins = 0
                   dTot-val-cofins           = 0.
        END.
        
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .



        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  

        IF LAST-OF(tt-ncm-pis-cofins.aba) THEN DO:
             ASSIGN xlinha = xlinha + 1.

             ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
                    chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
             ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
                    chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
             ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
                    chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
             ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
                    chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
             ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
                    chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
             ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
                    chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .
        END.
           
        ASSIGN xlinha = xlinha + 1 .  
        
        IF LAST-OF(tt-ncm-pis-cofins.aba) THEN DO:
            ASSIGN xlinha = xlinha + 1 .        
        END.
    END.
    /* FIM - IMPRESSÇO ABA COMPLETA */            
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Aba Compras...").
    
    /* INICIO - IMPRESSÇO ABA COMPRAS */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 2.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).
    
    ASSIGN xlinha = 3 . 

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.
    
    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Compras" :       
        /*MESSAGE tt-ncm-pis-cofins.COD-CFOP SKIP tt-ncm-pis-cofins.nat-operacao
            VIEW-AS ALERT-BOX INFO BUTTONS OK.*/
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .  
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .   
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA COMPRAS */ 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Aba Dev. Clientes...").    
    
    /* INICIO - IMPRESSÇO ABA DEVOLU€ÇO CLIENTES */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 3.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 .

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.

    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Devolu‡Æo de Cliente" :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") . 
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .   
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA DEVOLU€ÇO CLIENTES */ 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Aba Dev. Fornecedores...").        
    
    /* INICIO - IMPRESSÇO ABA DEVOLU€ÇO FORNECEDORES */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 4.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 .  

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.
    
    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Devolu‡Æo Fornecedor" :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) . 
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis    + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA DEVOLU€ÇO FORNECEDORES */ 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Aba Perdas...").            
    
    /* INICIO - IMPRESSÇO ABA PERDAS */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 5.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 . 

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.

    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Perdas" :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) . 
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA PERDAS*/ 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Redu‡Æo Z...").                
    
    /* INICIO - IMPRESSÇO ABA REDU€ÇO Z */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 6.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 .       
    
    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.

    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Redu‡Æo Z":U :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .  
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA REDU€ÇO Z */ 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo NCF-e...").                    
    
    /* INICIO - IMPRESSÇO ABA NFC-E */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 7.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 .  

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.
    
    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "NFC-e":U :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .  
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA NFC-E */     
   

    /* INICIO - IMPRESSÇO ABA Outras Saidas */            
    /* Seleciona Aba da Planilha */
    assign xsheet = 8.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).  

    ASSIGN xlinha = 3 .  

    ASSIGN dTot-vl-tot-item          = 0
           dTot-val-base-calc-pis    = 0
           dTot-val-pis              = 0
           dTot-val-base-calc-cofins = 0
           dTot-val-cofins           = 0.
    
    FOR EACH tt-ncm-pis-cofins NO-lOCK
       WHERE tt-ncm-pis-cofins.aba = "Outras Saidas":U :
            
        ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.class-fisc,"9999.99.99") .
        ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.vl-tot-item .
        ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-pi .
        ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-pis .
        ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-base-calc-cofins .
        ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = tt-ncm-pis-cofins.val-cofins .
        ASSIGN chWorksheet:Range("G" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-pis) .
        ASSIGN chWorksheet:Range("H" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.tp-trib-cofins) .  
        ASSIGN chWorksheet:Range("I" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.COD-CFOP) .
        ASSIGN chWorksheet:Range("J" + STRING(xlinha)):VALUE  = STRING(tt-ncm-pis-cofins.nat-operacao) .

        ASSIGN dTot-vl-tot-item          = dTot-vl-tot-item          + tt-ncm-pis-cofins.vl-tot-item            
               dTot-val-base-calc-pis    = dTot-val-base-calc-pis     + tt-ncm-pis-cofins.val-base-calc-pi 
               dTot-val-pis              = dTot-val-pis              + tt-ncm-pis-cofins.val-pis       
               dTot-val-base-calc-cofins = dTot-val-base-calc-cofins + tt-ncm-pis-cofins.val-base-calc-cofins 
               dTot-val-cofins           = dTot-val-cofins           + tt-ncm-pis-cofins.val-cofins .                  
           
        ASSIGN xlinha = xlinha + 1 .  
    END.

    ASSIGN chWorksheet:Range("A" + STRING(xlinha)):VALUE  = "Totais:"
           chWorkSheet:range("A" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("B" + STRING(xlinha)):VALUE  = dTot-vl-tot-item 
           chWorkSheet:range("B" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("C" + STRING(xlinha)):VALUE  = dTot-val-base-calc-pis
           chWorkSheet:range("C" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("D" + STRING(xlinha)):VALUE  = dTot-val-pis 
           chWorkSheet:range("D" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("E" + STRING(xlinha)):VALUE  = dTot-val-base-calc-cofins 
           chWorkSheet:range("E" + STRING(xlinha)):Font:Bold = TRUE.
    ASSIGN chWorksheet:Range("F" + STRING(xlinha)):VALUE  = dTot-val-cofins
           chWorkSheet:range("F" + STRING(xlinha)):Font:Bold = TRUE .

    /* FIM - IMPRESSÇO ABA Outras Saidas */     

    /* Seleciona Aba da Planilha */
    assign xsheet = 1.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet). 
    
    chExcel:VISIBLE = TRUE.
    
    /*para fechar a planilha */
    RELEASE OBJECT chExcel.
    RELEASE OBJECT chWorkbook.
    RELEASE OBJECT chWorksheet.

END PROCEDURE.

PROCEDURE pi-ncm-compras:

    RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - Compras").

    for EACH doc-fiscal FIELDS (ind-sit-doc cod-estabel cod-emitente nat-operacao serie nr-doc-fis dt-docto tipo-nat cod-cfop esp-docto)
        no-lock USE-INDEX ch-apuracao
       where doc-fiscal.dt-docto    >= tt-param.data-ini
         and doc-fiscal.dt-docto    <= tt-param.data-fim   
         AND doc-fiscal.tipo-nat     = 1
         and doc-fiscal.cod-estabel >= tt-param.c-cod-estabel-ini
         and doc-fiscal.cod-estabel <= tt-param.c-cod-estabel-fim:

        IF doc-fiscal.ind-sit-doc = 2 THEN NEXT.
        for each it-doc-fisc fields (vl-tot-item nat-operacao it-codigo class-fiscal
                                     aliq-pis val-base-calc-pis val-pis cd-trib-pis
                                     aliq-cofins val-base-calc-cofins val-cofins cd-trib-cofins) 
            of doc-fiscal no-lock:
            
            IF it-doc-fisc.vl-tot-item <= 0 THEN NEXT.
            /* compras */
            if tt-param.l-compras then 
            FOR first natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1)
                NO-LOCK where 
                  natur-oper.nat-operacao = it-doc-fisc.nat-operacao 
              and natur-oper.tipo-compra = 1
              AND natur-oper.especie-doc = 'NFE':

                FOR first item FIELD (char-2 it-codigo)
                    NO-LOCK where item.it-codigo = it-doc-fisc.it-codigo: END.
        
                i-ind = i-ind + 1.
                IF i-ind MOD 50000 = 0 THEN
                    RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                        STRING(doc-fiscal.cod-estabel) + " - " +
                                                        STRING(doc-fiscal.serie)     + " - " + 
                                                        STRING(doc-fiscal.nr-doc-fis) ).  
                RUN calculapiscofins.
                RUN GravaDados("Compras").
            END.
            /* devolucao */
            if tt-param.l-devol-cliente then
            FOR first natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1)
                where natur-oper.nat-operacao = it-doc-fisc.nat-operacao 
                  and natur-oper.tipo-compra = 3 
                  AND natur-oper.especie-doc = 'NFD' NO-LOCK:

                FOR first item FIELD (char-2 it-codigo)
                    NO-LOCK where item.it-codigo = it-doc-fisc.it-codigo: END.

                i-ind = i-ind + 1.
                IF i-ind MOD 50000 = 0 THEN
                    RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                        STRING(doc-fiscal.cod-estabel) + " - " +
                                                        STRING(doc-fiscal.serie)     + " - " + 
                                                        STRING(doc-fiscal.nr-doc-fis) ).  
                RUN calculapiscofins.
                RUN GravaDados("Devolu‡Æo de Cliente":U).
            END.
        END.
    end.
END PROCEDURE.  

PROCEDURE pi-ncm-devol-cliente:

    RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - Dev. Clientes").

END PROCEDURE.

PROCEDURE pi-ncm-devol-fornecedor:

     RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - Dev. Fornecedores").

     for each doc-fiscal FIELDS (ind-sit-doc cod-estabel cod-emitente nat-operacao serie nr-doc-fis dt-docto tipo-nat cod-cfop esp-docto) 
         no-lock USE-INDEX ch-apuracao
        where doc-fiscal.dt-docto  >= tt-param.data-ini
          and doc-fiscal.dt-docto  <= tt-param.data-fim
          and doc-fiscal.tipo-nat = 2 /* {diinc/i01di025.i 04 doc-fiscal.tipo-nat} = "Sa¡da" */
          and doc-fiscal.cod-estabel >= tt-param.c-cod-estabel-ini
          and doc-fiscal.cod-estabel <= tt-param.c-cod-estabel-fim:

         IF doc-fiscal.ind-sit-doc = 2 THEN NEXT.
         for each it-doc-fisc fields (vl-tot-item nat-operacao it-codigo class-fiscal
                                      aliq-pis val-base-calc-pis val-pis cd-trib-pis
                                      aliq-cofins val-base-calc-cofins val-cofins cd-trib-cofins) 
             of doc-fiscal no-lock:

             IF it-doc-fisc.vl-tot-item <= 0 THEN NEXT.
             if tt-param.l-devol-forn then 
             FOR first natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1)
                where natur-oper.nat-operacao = it-doc-fisc.nat-operacao
                  and natur-oper.especie-doc  = "NFD" 
                  and natur-oper.tipo-compra  <> 3 NO-LOCK:

                 FOR first item FIELD (char-2 it-codigo)
                     NO-LOCK where item.it-codigo = it-doc-fisc.it-codigo: END.
          
                 i-ind = i-ind + 1.
                 IF i-ind MOD 50000 = 0 THEN
                     RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                         STRING(doc-fiscal.cod-estabel) + " - " +
                                                         STRING(doc-fiscal.serie)     + " - " + 
                                                         STRING(doc-fiscal.nr-doc-fis) ).  
            
                 RUN calculapiscofins.
                 RUN GravaDados("Devolu‡Æo Fornecedor":U).
             END. /* natur-oper */

             IF doc-fiscal.esp-docto = "NFS" THEN DO:
                 FOR FIRST estabelec NO-LOCK WHERE estabelec.cod-estabel = doc-fiscal.cod-estabel: END.

                 /* Redu‡Æo Z */
                 if tt-param.l-reducaoz and 
                    estabelec.estado <> 'PR' THEN DO:
                     FOR first natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1 cod-model-nf-eletro) no-lock
                         where natur-oper.nat-operacao = it-doc-fisc.nat-operacao
                           AND (natur-oper.cod-model-nf-eletro   = "65" or natur-oper.cod-model-nf-eletro = "59" or natur-oper.cod-model-nf-eletro = "55")
                           /*and natur-oper.cd-situacao  = 18 */
                           and natur-oper.tipo-compra  <> 3 /*NÆo considerar devolu‡äes**/:

                         FOR first item FIELD (char-2 it-codigo)
                             NO-LOCK where item.it-codigo = it-doc-fisc.it-codigo: END.

                         i-ind = i-ind + 1.
                         IF i-ind MOD 50000 = 0 THEN
                             RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                                 STRING(doc-fiscal.cod-estab) + " - " +
                                                                 STRING(doc-fiscal.serie)     + " - " + 
                                                                 STRING(doc-fiscal.nr-doc-fis) ). 
    
                         RUN calculapiscofins.
                         IF NOT natur-oper.nat-operacao BEGINS "5102" AND
                            NOT natur-oper.nat-operacao BEGINS "5405" THEN
                             RUN GravaDados("Outras Saidas":U).
                         ELSE 
                             RUN GravaDados("Redu‡Æo Z":U).
                     END. /* natur-oper */
    
                 END. /* if PR */
                 /* NFC-e */                 
                 if tt-param.l-nfce and 
                    estabelec.estado = 'PR' THEN DO:
                    FOR first natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1 cod-model-nf-eletro) no-lock
                        where natur-oper.nat-operacao = it-doc-fisc.nat-operacao
                           AND (natur-oper.cod-model-nf-eletro   = "65" or natur-oper.cod-model-nf-eletro = "59" or natur-oper.cod-model-nf-eletro = "55")
                          /*and natur-oper.cd-situacao  = 18 */
                          and natur-oper.tipo-compra  <> 3 /*NÆo considerar devolu‡äes**/:
                        i-ind = i-ind + 1.
                        IF i-ind MOD 50000 = 0 THEN
                            RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                                STRING(doc-fiscal.cod-estab) + " - " +
                                                                STRING(doc-fiscal.serie)     + " - " + 
                                                                STRING(doc-fiscal.nr-doc-fis) ).  
    
                        RUN calculapiscofins.
                        IF NOT natur-oper.nat-operacao BEGINS "5102" AND
                           NOT natur-oper.nat-operacao BEGINS "5405" THEN
                            RUN GravaDados("Outras Saidas":U).
                        ELSE 
                            RUN GravaDados("NFC-e":U).
                    END. /* natur-oper */
                 END. /* if PR */
             END. /* NFS */
         END. /* it-doc-fisc */
    END. /* doc-fiscal */
END PROCEDURE.

PROCEDURE pi-ncm-reducaoZ: 

     RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - Redu‡Æo Z").
    
END PROCEDURE.

PROCEDURE pi-ncm-NFC-e: 

     RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - NFC-e").

END PROCEDURE.

PROCEDURE pi-ncm-perdas:

    FOR EACH tt-digita:
    
        RUN pi-seta-titulo IN h-acomp (INPUT "Documentos - Perdas").
    
        FOR  FIRST natur-oper FIELDS (nat-operacao tipo-compra especie-doc char-1 cod-model-nf-eletro) NO-LOCK
             WHERE natur-oper.nat-operacao = tt-digita.nat-operacao: END.
        IF AVAIL natur-oper THEN DO:
        
            for each doc-fiscal no-lock USE-INDEX ch-registro
               where doc-fiscal.dt-docto  >= tt-param.data-ini
                 and doc-fiscal.dt-docto  <= tt-param.data-fim
                 and doc-fiscal.cod-estabel >= tt-param.c-cod-estabel-ini
                 and doc-fiscal.cod-estabel <= tt-param.c-cod-estabel-fim
                 AND doc-fiscal.ind-sit-doc <> 2
                 and doc-fiscal.tipo-nat <= 2 /* "Entrada ou Saida" */
                 and doc-fiscal.esp-docto = "NFS",
                each it-doc-fisc of doc-fiscal no-lock
               where it-doc-fisc.nat-operacao  = natur-oper.nat-operacao AND it-doc-fisc.vl-tot-item > 0, 
               first item no-lock
                  where item.it-codigo = it-doc-fisc.it-codigo         
                  BY doc-fiscal.cod-estab
                  BY doc-fiscal.dt-docto
                 :
                 
                i-ind = i-ind + 1.
                IF i-ind MOD 50000 = 0 THEN
                   RUN pi-acompanhar IN h-acomp (INPUT STRING(doc-fiscal.dt-docto,"99/99/9999") + " - " +
                                                       STRING(doc-fiscal.cod-estab) + " - " +
                                                       STRING(doc-fiscal.serie)     + " - " + 
                                                       STRING(doc-fiscal.nr-doc-fis) ).  
                 
               /*FIND FIRST tt-ncm-pis-cofins
                    WHERE tt-ncm-pis-cofins.aba             = "Perdas":U
                      AND tt-ncm-pis-cofins.class-fiscal    = it-doc-fisc.class-fiscal
                      AND tt-ncm-pis-cofins.tp-trib-pis     = {ininc/i11in172.i 04 it-doc-fisc.cd-trib-pis} 
                      AND tt-ncm-pis-cofins.tp-trib-cofins  = {ininc/i11in172.i 04 it-doc-fisc.cd-trib-cofins} NO-ERROR.
               IF NOT AVAIL tt-ncm-pis-cofins THEN DO:
                   CREATE tt-ncm-pis-cofins.
                   ASSIGN tt-ncm-pis-cofins.aba                   = "Perdas":U
                          tt-ncm-pis-cofins.class-fiscal          = it-doc-fisc.class-fiscal
                          tt-ncm-pis-cofins.tp-trib-pis           = {ininc/i11in172.i 04 it-doc-fisc.cd-trib-pis}
                          tt-ncm-pis-cofins.tp-trib-cofins        = {ininc/i11in172.i 04 it-doc-fisc.cd-trib-cofins}
                          tt-ncm-pis-cofins.vl-tot-item           = it-doc-fisc.vl-tot-item
                          tt-ncm-pis-cofins.val-base-calc-pis    = it-doc-fisc.val-base-calc-pis 
                          tt-ncm-pis-cofins.val-pis               = it-doc-fisc.val-pis 
                          tt-ncm-pis-cofins.val-base-calc-cofins  = it-doc-fisc.val-base-calc-cofins 
                          tt-ncm-pis-cofins.val-cofins            = it-doc-fisc.val-cofins
                          .
               
               END.
               ELSE DO:
                   ASSIGN tt-ncm-pis-cofins.vl-tot-item           = tt-ncm-pis-cofins.vl-tot-item          + it-doc-fisc.vl-tot-item
                          tt-ncm-pis-cofins.val-base-calc-pis    = tt-ncm-pis-cofins.val-base-calc-pis    + it-doc-fisc.val-base-calc-pis 
                          tt-ncm-pis-cofins.val-pis               = tt-ncm-pis-cofins.val-pis              + it-doc-fisc.val-pis 
                          tt-ncm-pis-cofins.val-base-calc-cofins  = tt-ncm-pis-cofins.val-base-calc-cofins + it-doc-fisc.val-base-calc-cofins 
                          tt-ncm-pis-cofins.val-cofins            = tt-ncm-pis-cofins.val-cofins           + it-doc-fisc.val-cofins
                          .        
               END.            */
           END.     
        END.     
     
    END.

END PROCEDURE.

PROCEDURE calculapiscofins:

        ASSIGN vl-aliquotaPIS = it-doc-fisc.aliq-pis
               vl-BasePIS     = it-doc-fisc.val-base-calc-pis
               vl-PIS         = it-doc-fisc.val-pis
               TribPIS        = it-doc-fisc.cd-trib-pis. 

        ASSIGN vl-aliquotaCOFINS = it-doc-fisc.aliq-cofins
               vl-BaseCOFINS     = it-doc-fisc.val-base-calc-cofins
               vl-COFINS         = it-doc-fisc.val-cofins
               TribCOFINS        = it-doc-fisc.cd-trib-cofins.

        IF TribPIS = 0 THEN DO:
           if vl-PIS > 0 then 
              ASSIGN TribPIS = 1. 
           else 
              ASSIGN TribPIS = 2.
        END.

        IF TribCOFINS = 0 THEN DO:
           if vl-COFINS > 0 then 
              ASSIGN TribCOFINS = 1. 
           else 
              ASSIGN TribCOFINS = 2.
        END.

END PROCEDURE.

PROCEDURE gravaDados:
    DEF INPUT PARAMETER aba LIKE tt-ncm-pis-cofins.aba NO-UNDO.
    FIND FIRST tt-ncm-pis-cofins
             WHERE tt-ncm-pis-cofins.aba             = aba
               AND tt-ncm-pis-cofins.class-fiscal    = it-doc-fisc.class-fiscal
               AND tt-ncm-pis-cofins.tp-trib-pis     = {ininc/i11in172.i 04 TribPIS /*it-doc-fisc.cd-trib-pis*/ } 
               AND tt-ncm-pis-cofins.tp-trib-cofins  = {ininc/i11in172.i 04 TribCOFINS /*it-doc-fisc.cd-trib-cofins*/ } 
               AND tt-ncm-pis-cofins.nat-operacao    = it-doc-fisc.nat-operacao   
               AND tt-ncm-pis-cofins.cod-cfop        = doc-fiscal.cod-cfop NO-ERROR.
             
                  
        IF NOT AVAIL tt-ncm-pis-cofins THEN DO:            
            CREATE tt-ncm-pis-cofins.
            ASSIGN tt-ncm-pis-cofins.aba                   = aba
                   tt-ncm-pis-cofins.class-fiscal          = it-doc-fisc.class-fiscal
                   tt-ncm-pis-cofins.tp-trib-pis           = {ininc/i11in172.i 04 TribPIS}
                   tt-ncm-pis-cofins.tp-trib-cofins        = {ininc/i11in172.i 04 TribCOFINS}
                   tt-ncm-pis-cofins.nat-operacao          = it-doc-fisc.nat-operacao 
                   tt-ncm-pis-cofins.cod-cfop              = doc-fiscal.cod-cfop
                   .        
        END.
        ASSIGN tt-ncm-pis-cofins.vl-tot-item           = tt-ncm-pis-cofins.vl-tot-item          +  it-doc-fisc.vl-tot-item
               tt-ncm-pis-cofins.val-base-calc-pis     = tt-ncm-pis-cofins.val-base-calc-pis    +  vl-BasePIS
               tt-ncm-pis-cofins.val-pis               = tt-ncm-pis-cofins.val-pis              +  vl-PIS
               tt-ncm-pis-cofins.val-base-calc-cofins  = tt-ncm-pis-cofins.val-base-calc-cofins +  vl-BaseCOFINS
               tt-ncm-pis-cofins.val-cofins            = tt-ncm-pis-cofins.val-cofins           +  vl-COFINS
               .        
END PROCEDURE.
