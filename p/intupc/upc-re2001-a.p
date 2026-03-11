/******************************************************************************************
**  Programa....: esp/upc-re2001-a.p
**  Objetivo....: Listar notas integradas pelo XML e criar notas no recebimento f°sico 
**            
**            
******************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-object-re2001         AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re2001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re2001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re2001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-query-re2001          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR r-row-table-wms-re2001      AS ROWID    NO-UNDO.

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{cdp/cd0666.i} 
{cdp/cdcfgmat.i}
{intprg/int002.i}

DEF VAR l-erro             AS LOGICAL NO-UNDO.
def var l-erro-co          as logical no-undo.

FIND FIRST param-global NO-LOCK NO-ERROR.

find first param-re NO-LOCK where
           param-re.usuario = c-seg-usuario NO-ERROR.

FIND FIRST int_ds_param_re WHERE
           int_ds_param_re.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.  
              
IF AVAIL int_ds_param_re AND 
         int_ds_param_re.usu_manut = YES 
THEN DO: 
   ASSIGN l-erro = NO.
END.
ELSE DO:
   
  ASSIGN l-erro = YES.

  RUN utp/ut-msgs.p (input "show":U, 
                     input 17006, 
                     input "Usuario " + c-seg-usuario + " sem permiss∆o para gerar documentos." + "~~" + 
                           "Parametrizar o usuario no proprama Re0101").

  RETURN "NOK".
      
END.          

/* FIND FIRST doc-fisico WHERE 
          ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR. 
IF AVAIL doc-fisico THEN DO:

  FIND FIRST int-ds-docto-wms WHERE
             int-ds-docto-wms.doc_numero_n = INT(doc-fisico.nro-docto) AND
             int-ds-docto-wms.doc_serie_s  = doc-fisico.serie-docto    AND
             int-ds-docto-wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
  IF AVAIL int-ds-docto-wms THEN DO:

     IF int-ds-docto-wms.situacao = 1 OR 
        int-ds-docto-wms.situacao = 3 
     THEN DO:
     
         ASSIGN l-erro = YES.
     
         RUN utp/ut-msgs.p (input "show":U, 
                            input 17006, 
                            input "Nota em conferància com WMS!" + "~~" + 
                                  "Esperar retorno de conferància do WMS.").

         RETURN "NOK".

     END.

  END.  
END. */


IF l-erro = NO 
THEN DO:
    
    EMPTY TEMP-TABLE tt-param-nissei.

    CREATE tt-param-nissei.
    ASSIGN tt-param-nissei.h-tela     = wh-query-re2001
           tt-param-nissei.tipo-docto = 1. /* Doc-fisico */

    RUN intprg/int002c.w (INPUT TABLE tt-param-nissei).

END.
/* fim do include */


