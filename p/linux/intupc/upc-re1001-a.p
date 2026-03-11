/******************************************************************************************
**  Programa: upc-re1001-a.p
**  Data....: 
**  Objetivo: Listar notas integradas pelo XML e criar notas no recebimento fiscal
******************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re1001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re1001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re1001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nat-oper-re1001       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btconf-orig-re1001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bconf-fake-re1001     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-object-re1001         AS WIDGET-HANDLE NO-UNDO.

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{cdp/cd0666.i} 
{intprg/int002.i}

def var l-pede-qtd       as logical  no-undo.
def var h-boin176        as handle   no-undo.
DEF VAR de-tot-variacao  AS DEC      NO-UNDO.
DEF VAR de-var-permitida AS DEC      NO-UNDO.

FIND FIRST param-global NO-LOCK NO-ERROR.

find first param-re NO-LOCK where
           param-re.usuario = c-seg-usuario NO-ERROR.

FIND FIRST int_ds_param_re WHERE
           int_ds_param_re.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.  
       
IF AVAIL int_ds_param_re AND 
         int_ds_param_re.usu_manut = YES 
THEN DO: 

    EMPTY TEMP-TABLE tt-param-nissei.

    CREATE tt-param-nissei.
    ASSIGN tt-param-nissei.h-tela     = wh-object-re1001
           tt-param-nissei.tipo-docto = 2. /* Doc-fiscal */

    RUN intprg/int002c.w (INPUT TABLE tt-param-nissei).

  

END.
ELSE DO:

   RUN utp/ut-msgs.p (input "show":U, 
                      input 17006, 
                      input "Usuario " + c-seg-usuario + " sem permiss∆o para gerar documentos." + "~~" + 
                            "Parametrizar o usuario no proprama Re0101").
END.



