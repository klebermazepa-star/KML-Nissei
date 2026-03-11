/******************************************************************************************
**  Programa: upc-boin157q01.p
**  Data....: Janeiro de 2016
**  Funcao..: Validar registros importados
**  Autor...: ResultPro
**  Versao..: 2.06.00.001 - Versao Inicial.
******************************************************************************************/
/*** DEFINICAO DE TEMP-TABLES -----------------------------------------------------------*/
{utp/ut-glob.i}   
{include/i-epc200.i} /*Definicao tt-epc*/

DEFINE TEMP-TABLE tt-inventario NO-UNDO LIKE inventario
    FIELD r-Rowid   AS ROWID.

/*** DEFINICAO DE PARAMETROS ------------------------------------------------------------*/
DEF INPUT        PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc.

/*** DEFINICAO DE VARIAVEIS LOCAIS ------------------------------------------------------*/
DEF VAR h-bo                  AS HANDLE                        NO-UNDO.

{include/boerrtab.i}
{method/dbotterr.i} /** Definicao temp-table rowErrors **/

IF p-ind-event = "beforeupdaterecord" 
THEN DO:

   FIND FIRST tt-epc 
         WHERE tt-epc.cod-event     = p-ind-event 
           AND tt-epc.cod-parameter = "OBJECT-HANDLE" NO-LOCK NO-ERROR.
   IF AVAIL tt-epc THEN DO:

       ASSIGN h-bo = WIDGET-HANDLE(tt-epc.val-parameter).
        
       RUN getRecord IN h-bo(OUTPUT TABLE tt-inventario).

       FIND FIRST tt-inventario NO-ERROR.
       IF AVAIL tt-inventario THEN DO:

             IF tt-inventario.char-1 = "Importada" THEN DO: /* validar se registro Ç importado */ 
             

                 RUN _insertErrorManual IN h-bo (INPUT 17006,
                                                 INPUT "EMS",
                                                 INPUT "ERROR", 
                                                 INPUT "Registro Importado,n∆o pode ser alterado",
                                                 INPUT "Registro Importado,n∆o pode ser alterado",
                                                 INPUT "":U).  
             END.


       END.

   END.

END.


