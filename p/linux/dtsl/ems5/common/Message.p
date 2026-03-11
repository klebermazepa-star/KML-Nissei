&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* PROGRAMA:
*   ems5/common/Message.p
*
* FINALIDADE:
*   Classe para tratamento de mensagens do EMS5.
* 
*/

{system/InstanceManagerDef.i}
{system/Error.i}
{method/dbotterr.i} /* rowErrors */

/* propriedades */
define variable cMessageReturn as character no-undo.

/* instancias */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-localSubstitute) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD localSubstitute Procedure 
FUNCTION localSubstitute returns character
    (cText as character, cParam as character) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.96
         WIDTH              = 31.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-createError) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createError Procedure 
PROCEDURE createError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iMensagem as integer   no-undo. 
    define input parameter cParameters as character no-undo. 

    define variable cProgramName as character no-undo.
    define variable cMsg     as character no-undo.
    define variable cHelp    as character no-undo.
    define variable cType    as character no-undo.

    do {&try}:

        run getProgramName(input iMensagem, output cProgramName).

        run value(cProgramName) (input 'Msg':u, input '':u).
        assign cMsg = localSubstitute(return-value, cParameters).

        run value(cProgramName) (input 'Help':u, input '':u).
        assign cHelp = localSubstitute(return-value, cParameters).

        run value(cProgramName) (input 'Type':u, input '':u).
        assign cType = return-value.

        run insertMessage(input iMensagem,
                          input cType,
                          input cMsg,
                          input cHelp).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMessageReturn) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMessageReturn Procedure 
PROCEDURE getMessageReturn :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pcMessageReturn as character no-undo.

    assign pcMessageReturn = cMessageReturn.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getProgramName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getProgramName Procedure 
PROCEDURE getProgramName PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iMensagem as integer   no-undo. 
    define output parameter cProgramName as character no-undo. 

    assign
        cProgramName = 'messages/':u
                     + string(trunc(iMensagem / 1000, 0), '99':u)
                     + "/msg"
                     + string(iMensagem, '99999':u).

    if search(cProgramName + '.r':u) = ? and search(cProgramName + '.p':u) = ? then do:
        run insertError(input 524,
                        input substitute('Programa para a mensagem &1 n∆o encontrado',
                                         iMensagem),
                        input substitute('O programa "&2" que trata a mensagem &1 n∆o ' +
                                         'foi encontrado',
                                         iMensagem,
                                         cProgramName)).
        return error.
    end.

    assign cProgramName = cProgramName + '.p':u.

    return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-show) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show Procedure 
PROCEDURE show :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iMensagem as integer   no-undo. 
    define input parameter cParameters as character no-undo. 

    define variable cProgramName as character no-undo.

    run emptyErrors.

    do {&throws}:

        run getProgramName(input iMensagem, output cProgramName).

        run value(cProgramName) (input 'show':u, input cParameters).

        assign cMessageReturn = return-value.

        return.
    end.

    run showErrors.

    return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-localSubstitute) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION localSubstitute Procedure 
FUNCTION localSubstitute returns character
    (cText as character, cParam as character):
/*------------------------------------------------------------------------------
Purpose: 
  Notes:  
------------------------------------------------------------------------------*/

    assign
        cParam = cParam + fill('~~':u, 8)
        cText  = substitute(cText,
                            entry(01, cParam, '~~':u),
                            entry(02, cParam, '~~':u),
                            entry(03, cParam, '~~':u),
                            entry(04, cParam, '~~':u),
                            entry(05, cParam, '~~':u),
                            entry(06, cParam, '~~':u),
                            entry(07, cParam, '~~':u),
                            entry(08, cParam, '~~':u),
                            entry(09, cParam, '~~':u)).
    return cText.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

