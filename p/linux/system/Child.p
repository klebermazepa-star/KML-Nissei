&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* CLASSE:
*   system/Child.p
*
* FINALIDADE:
*   Implementa a funcao child(), cuja finalidade eh ser uma substituta
*   de target-procedure no framework OO para Progress da DTSL PR.
*
*/

{system/InstanceManagerDef.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-child) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD child Procedure 
FUNCTION child RETURNS HANDLE
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-deepestChild) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD deepestChild Procedure 
FUNCTION deepestChild RETURNS HANDLE PRIVATE
    ( input hCurrentObject as handle )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-handleSuper) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD handleSuper Procedure 
FUNCTION handleSuper RETURNS HANDLE
    (input cProcedureToFind as character ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isA) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isA Procedure 
FUNCTION isA RETURNS LOGICAL
  ( input objectToCompare as handle,
    input classInstance   as handle )  FORWARD.

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
         HEIGHT             = 8.04
         WIDTH              = 25.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-child) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION child Procedure 
FUNCTION child RETURNS HANDLE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    return deepestChild(target-procedure).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-deepestChild) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION deepestChild Procedure 
FUNCTION deepestChild RETURNS HANDLE PRIVATE
    ( input hCurrentObject as handle ) :

    define variable hChild as handle     no-undo.

    run getParent in ghInstanceManager (input hCurrentObject, output hChild).

    if lookup(string(hCurrentObject), hChild:super-procedures) = 0 then
        return hCurrentObject.

    return deepestChild(hChild).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-handleSuper) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION handleSuper Procedure 
FUNCTION handleSuper RETURNS HANDLE
    (input cProcedureToFind as character ):
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    define variable hSuper      as handle     no-undo.
    define variable iSuperCount as integer    no-undo.

    do iSuperCount = num-entries(target-procedure:super-procedures) to 1 by -1:
        assign hSuper = widget-handle(entry(iSuperCount, target-procedure:super-procedures)).
        if lookup(cProcedureToFind, hSuper:internal-entries) <> 0 then
            return hSuper.
    end.

    run createError
        (input 17006,
         input substitute('Imposs¡vel encontrar m‚todo "&1" nas SUPER-PROCEDURES de "&2"',
                          cProcedureToFind, target-procedure:file-name)).

    return error.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isA) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isA Procedure 
FUNCTION isA RETURNS LOGICAL
  ( input objectToCompare as handle,
    input classInstance   as handle ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    define variable i      as integer    no-undo.
    define variable hSuper as handle     no-undo.

    if objectToCompare:file-name = classInstance:file-name then
        return true.

    do i = 1 to num-entries(objectToCompare:super-procedures):
        assign hSuper = widget-handle(entry(i,objectToCompare:super-procedures)).
        if hSuper:file-name = classInstance:file-name then
            return true.
    end.
    
    RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

