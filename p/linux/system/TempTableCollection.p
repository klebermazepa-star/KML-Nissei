&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
    File        : system/TempTableCollection.p
    Purpose     : Implementaá∆o da interface Collection de Java em progress para
                  utilizar como holder de handles.
                  
    Syntax      : ver http://java.sun.com/j2se/1.3/docs/api/java/util/Collection.html

    Description : 

    Author(s)   : Alexandre Reis
    Created     : 28/09/2006
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{system/Error.i}
{system/InstanceManagerDef.i}

define temp-table ttCollection no-undo
    field objectHandle as handle
    index pk is primary unique
        objectHandle.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



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
         HEIGHT             = 14.17
         WIDTH              = 32.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-add) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add Procedure 
PROCEDURE add :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter phObject as handle no-undo.

    do {&throws}:

        run validateObject(phObject).
   
        find first ttCollection
            where ttCollection.objectHandle = phObject no-error.
        if avail ttCollection then do:
            run createError(17006,
                            substitute("Objeto &1:&2 j† adicionado Ö lista"
                                       ,phObject
                                       ,phObject:file-name)).
            return error.
        end.
    
        create ttCollection.
        assign ttCollection.objectHandle = phObject.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addAll) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addAll Procedure 
PROCEDURE addAll :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter phCollection as handle no-undo.

    define variable hIterator as handle  no-undo.
    define variable lHasNext  as logical no-undo.
    define variable hObject   as handle  no-undo.

    do {&throws}:

        run iterator in phCollection(output hIterator).
        run hasNext in hIterator(output lHasNext).
    
        do while(lHasNext):
            run next in hIterator(output hObject).
            run add(hObject).
            run hasNext in hIterator(output lHasNext).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clear) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear Procedure 
PROCEDURE clear :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*  Se fizermos o cleanup aqui, pode quebrar link com outras procedures        */
/*-----------------------------------------------------------------------------*/    
/*     for each ttCollection:                                                  */
/*         run deleteInstance in ghInstanceManager(ttCollection.objectHandle). */
/*     end.                                                                    */
    empty temp-table ttCollection.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-contains) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE contains Procedure 
PROCEDURE contains :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter phObject   as handle  no-undo.
    define output parameter plContains as logical no-undo.

    define variable numEntries as integer    no-undo.

    do {&throws}:
        run numEntries(phObject, output numEntries).
        assign plContains =  numEntries > 0.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-containsAll) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE containsAll Procedure 
PROCEDURE containsAll :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter phCollection   as handle  no-undo.
    define output parameter plContainsAll as logical no-undo.

    define variable hIterator as handle  no-undo.
    define variable lHasNext  as logical no-undo.
    define variable hObject   as handle  no-undo.
    define variable lContains as logical no-undo.

    do {&throws}:
        run iterator in phCollection(output hIterator).
        run hasNext in hIterator(output lHasNext).
    
        do while(lHasNext):
            run next in hIterator(output hObject).
            run contains(hObject, output lContains).
            if not lContains then do:
                assign plContainsAll = no.
                return.
            end.
            run hasNext in hIterator(output lHasNext).
        end.
        assign plContainsAll = yes.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-count) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE count Procedure 
PROCEDURE count :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter recordCount as integer    no-undo.

    for each ttCollection:
        assign recordCount = recordCount + 1.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isEmpty) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isEmpty Procedure 
PROCEDURE isEmpty :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter plEmpty as logical no-undo.

    assign plEmpty = not can-find(first ttCollection).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-iterator) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE iterator Procedure 
PROCEDURE iterator :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter phIterator as handle no-undo.
            
    do {&throws}:
        run createInstance in ghInstanceManager(this-procedure,
                                                "system/TempTableCollectionIterator.p",
                                                output phIterator).
        run setCollection in phIterator(input table ttCollection).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-numEntries) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE numEntries Procedure 
PROCEDURE numEntries :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter phObject   as handle  no-undo.
    define output parameter numEntries as integer no-undo.

    define variable iterator as handle     no-undo.
    define variable element  as handle     no-undo.
    define variable hasNext  as logical    no-undo.
    define variable contains as logical    no-undo.


    do {&throws}:
        run validateObject(phObject).

        run iterator (output iterator).
        run hasNext in iterator (output hasNext).
        do while hasNext:
            run next in iterator (output element).
            run equals in element (phObject, output contains).
            if contains then
                assign numEntries = numEntries + 1.
            run hasNext in iterator (output hasNext).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-remove) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE remove Procedure 
PROCEDURE remove :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/    
    define input parameter phObject as handle no-undo.

    define variable lContains as logical no-undo.
    do {&throws}:
        run validateObject(phObject).              

        find first ttCollection 
            where ttCollection.objectHandle = phObject no-error.
        if not avail ttCollection then do:
            run createError(17006,
                            substitute("Objeto &1 n∆o existe nesta coleá∆o",
                                       phObject)).
            return error.
        end.
        delete ttCollection.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-removeAll) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE removeAll Procedure 
PROCEDURE removeAll :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter phCollection as handle no-undo.

    define variable hIterator as handle  no-undo.
    define variable lHasNext  as logical no-undo.
    define variable hObject   as handle  no-undo.

    do {&throws}:
        run iterator in phCollection(output hIterator).
        run hasNext in hIterator(output lHasNext).
    
        do while(lHasNext):
            run next in hIterator(output hObject).
            run remove(hObject).
            run hasNext in hIterator(output lHasNext).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-retainAll) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE retainAll Procedure 
PROCEDURE retainAll :
/*------------------------------------------------------------------------------
  Purpose:  Retains only the elements in this collection that are contained in 
            the specified collection    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter phCollection as handle no-undo.

    define variable hIterator as handle  no-undo.
    define variable lHasNext  as logical no-undo.
    define variable hObject   as handle  no-undo.
    define variable lContains as logical no-undo.

    do {&throws}:
        run iterator(output hIterator).
        run hasNext (output lHasNext).
    
        do while(lHasNext):
            run next in hIterator(output hObject).
            run contains in phCollection(hObject, output lContains).
            if not lContains then
                run remove(hObject).
            run hasNext (output lHasNext).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-size) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE size Procedure 
PROCEDURE size :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter piSize as integer no-undo.

    for each ttCollection:
        assign piSize = piSize + 1.
    end.


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

&IF DEFINED(EXCLUDE-validateObject) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateObject Procedure 
PROCEDURE validateObject PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter phObject as handle  no-undo.

    if not valid-handle(phObject) then do:
        run createError(17006,
                        substitute("Objeto &1 n∆o Ç v†lido"
                                   ,phObject)).
        return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

