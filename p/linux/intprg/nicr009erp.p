/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR007RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR007RP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Importaá∆o das Liquidaá‰es de Cheque e Dinheiro atravÇs do
                   arquivo enviado pela empresa de transportes de valores.
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
define buffer portador for emscad.portador.

{include/i-rpvar.i}
{include/i-rpcab.i}
{intprg/nicr007rp.i}
{intprg/intpdf001.i01}
/* {utp/ut-glob.i} */ 
    
 def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.
def new global shared var gr-vale-manual as rowid no-undo.

DEFINE NEW SHARED TEMP-TABLE tt_val_extenso
    FIELD ttv_des_val_extenso              AS CHARACTER FORMAT "x(8)".

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

DEFINE BUFFER bf-vale-manual FOR vale-manual.

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
.

def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usuˇrio Corrente"
    column-label "Usuˇrio Corrente"
    no-undo.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.             

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.

DEF VAR v_hdl_program     AS HANDLE  FORMAT ">>>>>>9":U NO-UNDO.
DEF var v_log_integr_cmg  AS LOGICAL FORMAT "Sim/N∆o":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

def var c_cod_table               as character         format "x(8)"                no-undo.
def var w_estabel                 as character         format "x(3)"                no-undo.
def var c-cod-refer               as character         format "x(10)"               no-undo.
def var v_log_refer_uni           as log                                            no-undo.

DEFINE TEMP-TABLE tt-int-ds-furo-caixa LIKE int-ds-furo-caixa
    FIELD r-rowid AS ROWID.

DEFINE STREAM               s-pedido. 

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR009"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Impressao_Vale_Manual * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Impress∆o Vale Manual").

RUN pi-imprime-excel.

/*     OUTPUT STREAM s-pedido TO VALUE (SESSION:TEMP-DIRECTORY + 'Pedido.txt').                                               */
/*     PUT    STREAM s-pedido ' ' SKIP.                                                                                       */
/*     OUTPUT STREAM s-pedido CLOSE.                                                                                          */
/*                                                                                                                            */
/*                                                                                                                            */
/*     RUN pdf_new ('Pedido','c:\temp\VALE.pdf').                                                                             */
/*                                                                                                                            */
/*     RUN pdf_load_font('Pedido', 'Times', SEARCH ('intprg\intpdf-arial.ttf':U), SEARCH ('intprg\intpdf-arial.afm':U), '').  */
/*                                                                                                                            */
/*     RUN pdf_load_image ('Pedido', 'Logotipo', SEARCH ('image/marca-nissei.jpg':U)).                                        */
/*     RUN pdf_new_page2  ('Pedido',"PORTRAIT").                                                                              */
/*                                                                                                                            */
/*     /* Impress∆o da PRIMEIRA VIA */                                                                                        */
/*     RUN pdf_place_image('Pedido', 'Logotipo', 005.00, 50.00, 180.00, 050.00).                                              */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times-Bold', 8).                                                                        */
/*     RUN pdf_text_align ('Pedido', 'Farm†cias e Drogarias Nissei S.A', 'LEFT'   , 175.00, 780.00).                          */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times', 8).                                                                             */
/*     RUN pdf_text_align ('Pedido', 'Rodovia do Contorno Norte, 305 - Colombo - PR', 'LEFT'   , 175.00, 770.00).             */
/*     RUN pdf_text_align ('Pedido', 'CNPJ: 79.483.682/0255-40', 'LEFT'   , 175.00, 760.00).                                  */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times-Bold', 11).                                                                       */
/*     RUN pdf_text_align ('Pedido', '1¶ VIA', 'LEFT'   , 575.00, 780.00).                                                    */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times', 10).                                                                            */
/*     RUN pdf_text_align ('Pedido', 'Emissor:', 'LEFT'   , 20.00, 730.00).                                                   */
/*     RUN pdf_text_align ('Pedido', 'super', 'LEFT'   , 100.00, 730.00).                                                     */
/*     RUN pdf_text_align ('Pedido', 'Data Emiss∆o:', 'LEFT'   , 20.00, 718.00).                                              */
/*     RUN pdf_text_align ('Pedido', STRING(TODAY,"99/99/9999"), 'LEFT'   , 100.00, 718.00).                                  */
/*     RUN pdf_text_align ('Pedido', 'Hora Emiss∆o:', 'LEFT'   , 20.00, 706.00).                                              */
/*     RUN pdf_text_align ('Pedido', STRING(TIME,"HH:MM:SS"), 'LEFT'   , 100.00, 706.00).                                     */
/*                                                                                                                            */
/*                                                                                                                            */
/*                                                                                                                            */
/*     /* Impress∆o da SEGUNDA VIA */                                                                                         */
/*     RUN pdf_place_image ('Pedido', 'Logotipo', 005.00, 450.00, 180.00, 050.00).                                            */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times-Bold', 8).                                                                        */
/*     RUN pdf_text_align ('Pedido', 'Farm†cias e Drogarias Nissei S.A', 'LEFT'   , 175.00, 380.00).                          */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times', 8).                                                                             */
/*     RUN pdf_text_align ('Pedido', 'Rodovia do Contorno Norte, 305 - Colombo - PR', 'LEFT'   , 175.00, 370.00).             */
/*     RUN pdf_text_align ('Pedido', 'CNPJ: 79.483.682/0255-40', 'LEFT'   , 175.00, 360.00).                                  */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times-Bold', 11).                                                                       */
/*     RUN pdf_text_align ('Pedido', '2¶ VIA', 'LEFT'   , 575.00, 380.00).                                                    */
/*                                                                                                                            */
/*     RUN pdf_set_font   ('Pedido', 'Times', 10).                                                                            */
/*     RUN pdf_text_align ('Pedido', 'Emissor:', 'LEFT'   , 20.00, 280.00).                                                   */
/*     RUN pdf_text_align ('Pedido', 'super', 'LEFT'   , 100.00, 280.00).                                                     */
/*     RUN pdf_text_align ('Pedido', 'Data Emiss∆o:', 'LEFT'   , 20.00, 270.00).                                              */
/*     RUN pdf_text_align ('Pedido', STRING(TODAY,"99/99/9999"), 'LEFT'   , 100.00, 270.00).                                  */
/*     RUN pdf_text_align ('Pedido', 'Hora Emiss∆o:', 'LEFT'   , 20.00, 260.00).                                              */
/*     RUN pdf_text_align ('Pedido', STRING(TIME,"HH:MM:SS"), 'LEFT'   , 100.00, 260.00).                                     */
/*                                                                                                                            */
/*                                                                                                                            */
/*     /** FECHAR DOCUMENTO **/                                                                                               */
/*    RUN pdf_close  ("Pedido").                                                                                              */

RUN pi-finalizar IN h-acomp.                       


{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-imprime-excel:

    FIND FIRST vale-manual NO-LOCK
         WHERE ROWID(vale-manual) = gr-vale-manual NO-ERROR.

    RUN pi-seta-titulo IN h-acomp (INPUT "Gerando o Excel").

    DEFINE VARIABLE chExcel       AS COM-HANDLE NO-UNDO. /* Documento Excel */
    DEFINE VARIABLE chWorksheet   AS COM-HANDLE NO-UNDO. /* Abas da Planilha */
    DEFINE VARIABLE chWorkbook    AS COM-HANDLE NO-UNDO. /* Planilha */
    
    DEF VAR xsheet AS INTEGER INIT 1 NO-UNDO.
    DEF VAR xlinha AS INTEGER INIT 1 NO-UNDO.

    DEFINE VARIABLE hora                AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE fi-nome-funcionario AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE fi-nome-filial      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-cont-tit          AS INTEGER     NO-UNDO.



    DEFINE VARIABLE v_cod_return AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE extenso_     AS CHARACTER   NO-UNDO.
    
    CREATE "Excel.Application" chExcel.        /*criar planilha*/
    chExcel:DisplayAlerts = FALSE. 
    chExcel:VISIBLE = FALSE.                    /*visualiza o relat¢rio no excel automaticamente*/
    chWorkBook      = chExcel:WorkBooks:ADD(search("layout\ModeloValeDesconto.xlsx")). /*Adiciona a primeira aba*/
    
    /* Seleciona Aba da Planilha */
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet).
    
    FIND FIRST usuar_mestre NO-LOCK
         WHERE usuar_mestre.cod_usuario = v_cod_usuar_corren NO-ERROR.

    ASSIGN hora = STRING(TIME,"HH:MM:SS").

    FIND FIRST VR034FUN NO-LOCK
         WHERE VR034FUN.NUMCAD = vale-manual.mat-funcionario 
           AND VR034FUN.SITAFA <> 7
           AND VR034FUN.SITAFA <> 22
           AND emsesp.VR034FUN.TIPCOL = YES
           AND emsesp.VR034FUN.ESTCAR = 10  NO-ERROR.
    IF AVAIL VR034FUN THEN DO:
        ASSIGN fi-nome-funcionario = VR034FUN.nomfun.

        FIND FIRST estabelec
             WHERE estabelec.cod-estabel = STRING(VR034FUN.CODFIL,"999") NO-LOCK NO-ERROR.
        IF AVAIL estabelec THEN DO:
            ASSIGN fi-nome-filial = STRING(VR034FUN.CODFIL) + " - " + CAPS(estabelec.nome).
        END.
    END.

    EMPTY TEMP-TABLE tt_val_extenso.
    RUN prgint/utb/utb900za.py (Input vale-manual.val-vale,
                                Input 5,
                                Input 50,
                                Input 'POR',
                                Input 'Real',
                                output v_cod_return).

    assign extenso_ = ''.
    for each tt_val_extenso no-lock:
        assign extenso_ = extenso_ + tt_val_extenso.ttv_des_val_extenso.
    end.

        /* Seleciona Aba da Planilha */
    assign xsheet = 1.
    chWorkbook:Worksheets(xsheet):Activate.
    chWorksheet = chWorkbook:Worksheets(xsheet). 
    
    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo 1¶ Via...").

    ASSIGN chWorksheet:Range("C6") = usuar_mestre.cod_usuario + " - " + usuar_mestre.nom_usuario.
    ASSIGN chWorksheet:Range("C7") = TODAY. 
    ASSIGN chWorksheet:Range("C8") = hora.

    ASSIGN chWorksheet:Range("C10") = vale-manual.num-vale.
    ASSIGN chWorksheet:Range("C11") = STRING(vale-manual.val-vale) + " - " + extenso_ .
    ASSIGN chWorksheet:Range("C12") = vale-manual.obs-historico.

    ASSIGN chWorksheet:Range("F24") = CAPS(fi-nome-funcionario).
    ASSIGN chWorksheet:Range("F25") = vale-manual.mat-funcionario. 
    ASSIGN chWorksheet:Range("F26") = fi-nome-filial.

    ASSIGN i-cont-tit = 0.
    FOR EACH movto-vale-manual OF vale-manual NO-LOCK,
        EACH tit_acr WHERE tit_acr.num_id_tit_acr = movto-vale-manual.num-id-tit-acr NO-LOCK:
        
        ASSIGN i-cont-tit = i-cont-tit + 1.

        CASE i-cont-tit:
            /* Coluna 1 */
            WHEN 1 THEN DO:
                ASSIGN chWorksheet:Range("C16") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 2 THEN DO:
                ASSIGN chWorksheet:Range("C17") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 3 THEN DO:
                ASSIGN chWorksheet:Range("C18") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            /* Coluna 2 */
            WHEN 4 THEN DO:
                ASSIGN chWorksheet:Range("F16") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 5 THEN DO:
                ASSIGN chWorksheet:Range("F17") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 6 THEN DO:
                ASSIGN chWorksheet:Range("F18") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            /* Coluna 3 */
            WHEN 7 THEN DO:
                ASSIGN chWorksheet:Range("I16") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 8 THEN DO:
                ASSIGN chWorksheet:Range("I17") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 9 THEN DO:
                ASSIGN chWorksheet:Range("I18") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
        END CASE.
    END.

    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo 2¶ Via...").

    ASSIGN chWorksheet:Range("C36") = usuar_mestre.cod_usuario + " - " + usuar_mestre.nom_usuario.
    ASSIGN chWorksheet:Range("C37") = TODAY. 
    ASSIGN chWorksheet:Range("C38") = hora.

    ASSIGN chWorksheet:Range("C40") = vale-manual.num-vale.
    ASSIGN chWorksheet:Range("C41") = STRING(vale-manual.val-vale) + " - " + extenso_.
    ASSIGN chWorksheet:Range("C42") = vale-manual.obs-historico.

    ASSIGN chWorksheet:Range("F54") = CAPS(fi-nome-funcionario).
    ASSIGN chWorksheet:Range("F55") = vale-manual.mat-funcionario. 
    ASSIGN chWorksheet:Range("F56") = fi-nome-filial.

    ASSIGN i-cont-tit = 0.
    FOR EACH movto-vale-manual OF vale-manual NO-LOCK,
        EACH tit_acr WHERE tit_acr.num_id_tit_acr = movto-vale-manual.num-id-tit-acr NO-LOCK:
        
        ASSIGN i-cont-tit = i-cont-tit + 1.

        CASE i-cont-tit:
            /* Coluna 1 */
            WHEN 1 THEN DO:
                ASSIGN chWorksheet:Range("C46") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 2 THEN DO:
                ASSIGN chWorksheet:Range("C47") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 3 THEN DO:
                ASSIGN chWorksheet:Range("C48") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            /* Coluna 2 */
            WHEN 4 THEN DO:
                ASSIGN chWorksheet:Range("F46") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 5 THEN DO:
                ASSIGN chWorksheet:Range("F47") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 6 THEN DO:
                ASSIGN chWorksheet:Range("F48") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            /* Coluna 3 */
            WHEN 7 THEN DO:
                ASSIGN chWorksheet:Range("I46") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 8 THEN DO:
                ASSIGN chWorksheet:Range("I47") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
            WHEN 9 THEN DO:
                ASSIGN chWorksheet:Range("I48") = tit_acr.cod_estab + "/" + tit_acr.cod_espec_docto + "/" + tit_acr.cod_ser_docto + "/" + tit_acr.cod_tit_acr + "/" + tit_acr.cod_parcela.
            END.
        END CASE.
    END.
/*     chExcel:VISIBLE = TRUE. */

    chExcel:ActiveSheet:ExportAsFixedFormat(0,SESSION:TEMP-DIRECTORY + "ValeManual_" + STRING(vale-manual.num-vale) + ".PDF",0,true,,,,,).
    RUN winexec (input "explorer " +  SESSION:TEMP-DIRECTORY + "ValeManual_" + STRING(vale-manual.num-vale) + ".PDF", input 1 ). 

    FIND FIRST bf-vale-manual EXCLUSIVE-LOCK
         WHERE ROWID(bf-vale-manual) = ROWID(vale-manual) NO-ERROR.
    IF AVAIL bf-vale-manual AND bf-vale-manual.situacao = 1 THEN DO:
        ASSIGN bf-vale-manual.situacao      = 2
               bf-vale-manual.dat-impressao = TODAY.
    END.
    
    /*para fechar a planilha */
    RELEASE OBJECT chExcel.
    RELEASE OBJECT chWorkbook.
    RELEASE OBJECT chWorksheet.
    
END PROCEDURE.

PROCEDURE WinExec EXTERNAL "kernel32.dll":u: 
    DEF INPUT PARAMETER pProgName as char. 
    DEF INPUT PARAMETER pStyle as long. 
END PROCEDURE.



