/******************************************************************************************
**  Programa....: intprg/upc-re2001-a.p
**  Objetivo....: Listar notas integradas pelo XML e criar notas no recebimento f°sico 
**            
**            
******************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-object-re2001         AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re2001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re2001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re2001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-query-re2001          AS WIDGET-HANDLE NO-UNDO.

{utp/ut-glob.i} 
{cdp/cd0666.i} 
{cdp/cdcfgmat.i}
{intprg/int002.i}

DEF VAR l-erro             AS LOGICAL NO-UNDO.
def var l-erro-co          as logical no-undo.

FIND FIRST param-global NO-LOCK NO-ERROR.

find first param-re NO-LOCK where
           param-re.usuario = c-seg-usuario NO-ERROR.

FIND FIRST int-ds-param-re WHERE
           int-ds-param-re.cod-usuario = c-seg-usuario NO-LOCK NO-ERROR.  
       
IF AVAIL int-ds-param-re AND 
         int-ds-param-re.usu-manut = YES 
THEN DO: 
   
    EMPTY TEMP-TABLE tt-param-nissei.

    CREATE tt-param-nissei.
    ASSIGN tt-param-nissei.h-tela     = wh-query-re2001
           tt-param-nissei.tipo-docto = 1. /* Doc-fisico */

    RUN intprg/int002c.w (INPUT TABLE tt-param-nissei).

END.
ELSE DO:
   
  RUN utp/ut-msgs.p (input "show":U, 
                     input 17006, 
                     input "Usuario " + c-seg-usuario + " sem permiss∆o para gerar documentos." + "~~" + 
                           "Parametrizar o usuario no proprama Re0101").
      
END.

/* fim do include */


