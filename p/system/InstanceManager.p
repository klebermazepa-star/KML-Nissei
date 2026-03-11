&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* PROGRAMA:
*   system/InstanceManager.p
*
* FINALIDADE:
*   "Classe" gerenciadora de instancias de objetos. Veja exemplos de utilizacao
*   em ../vc/dtpr/prof/src/system/tests.
*
* NOTAS:
*   Modelo para uso de instanciacao e heranca:
*   - nenhum codigo de instanciacao e heranca deve ficar no 'definitions' ou no 'main-block' de
*     um programa. Essa logica necessariamente deve ser movida para um metodo 'startup' que o
*     createInstance se encarrega de chamar. Por exemplo, uma instanciacao que nao era originalmente
*     feita na construcao do programa (no 'definitions' ou 'main-block') nao precisam ficar na 'startup';
*   - eh preciso ter {system/InstanceManagerDef.i} no 'definitions' de classes que instanciem ou 
*     herdam outras classes;
*   - eh preciso ter {system/InstanceManager.i} no 'startup' de classes que instanciem ou herdam
*     outras classes;
*   - o metodo 'startup' deve ser chamado explicitamente nas interfaces (ver main-block do esbc003)
*     e outros casos de programas nao executados via createInstance;
*   - apenas classes que nao herdam de ninguem eh que poderiam (em tese) nao ter o metodo 'startup'
*     (ver revisao 3487 de Etiqueta.p para exemplo).
*
*   - o metodo 'dispose' das classes instanciadas eh executado antes delas serem deletadas
*/

{system/Error.i}

define temp-table ttHandles no-undo
    field parentHandle as handle
    field childHandle  as handle.

/* PAY ATTENTION: nao use InstanceManager.i aqui, pois acabaria gerando
   um loop infinito */
define new global shared variable ghInstanceManager as handle no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-newInstance) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD newInstance Procedure 
FUNCTION newInstance returns handle(input path as char) FORWARD.

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
         HEIGHT             = 11.29
         WIDTH              = 38.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

if valid-handle(ghInstanceManager) then
    return error "Instance Manager already instantiated, and is a singleton".

if not this-procedure:persistent then 
    return error "The Instance Manager can only be ran as a persistent procedure".

assign ghInstanceManager = this-procedure:handle.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addSuperProcedure) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addSuperProcedure Procedure 
PROCEDURE addSuperProcedure PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     Implementa logica para adicionar super-procedures em um 
               determinado programa, verificando se a super a ser adicionada ja
               eh super do pai. Se for, nao instancia novamente a super, mas usa
               a do pai.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cSuperProcedure as character  no-undo.
    define input  parameter hParentHandle   as handle     no-undo.
    define input  parameter hProgram        as handle     no-undo.

    define variable hCurrentSuper   as handle     no-undo.
    define variable hProcedureToAdd as handle     no-undo.
    define variable iLoopIndex      as integer    no-undo.

    do iLoopIndex = num-entries(hParentHandle:super-procedures) to 1 by -1:
        assign hCurrentSuper = widget-handle(entry(iLoopIndex, hParentHandle:super-procedures)).

        if hCurrentSuper:file-name matches cSuperProcedure then do:
            assign hProcedureToAdd = hCurrentSuper.
            leave.
        end.
    end.

    if not valid-handle(hProcedureToAdd) then do:
        run createInstanceInternal
            (input  hParentHandle,
             input  cSuperProcedure,
             output hProcedureToAdd).

        hParentHandle:add-super-procedure(hProcedureToAdd).
    end.

    /* Apenas para nao adicionar 2 vezes a super procedure quando addSuperProcedures
       for invocado por registerInstance */
    if hParentHandle <> hProgram then
        hProgram:add-super-procedure(hProcedureToAdd).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addSuperProcedures) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addSuperProcedures Procedure 
PROCEDURE addSuperProcedures PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     Adiciona as classes Error.p e Child.p no pai da procedure e na
               propria procedure.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hParentHandle as handle     no-undo.
    define input  parameter hProgram      as handle     no-undo.

    run addSuperProcedure('system/Object.p':u, hParentHandle, hProgram).
    run addSuperProcedure('system/Error.p':u,  hParentHandle, hProgram).
    run addSuperProcedure('system/Child.p':u,  hParentHandle, hProgram).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createInstance) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createInstance Procedure 
PROCEDURE createInstance :
/*------------------------------------------------------------------------------
  Purpose:     Substitui "RUN xxx.p PERSISTENT SET hHandle".
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hParentHandle as handle no-undo.
    define input  parameter cProgramName as char    no-undo.
    define output parameter hProgram     as handle  no-undo.
    
    run createInstanceInternal
        (input  hParentHandle,
         input  cProgramName,
         output hProgram).

    run addSuperProcedures(hParentHandle, hProgram).

    do {&throws}:
        if lookup('startup':u, hProgram:internal-entries) > 0 then
            run startup in hProgram.
    end.

    return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createInstanceInternal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createInstanceInternal Procedure 
PROCEDURE createInstanceInternal PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     Usada pela createInstance (e pela addSuperProcedures) para 
               efetivamente executar o programa desejado.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hParentHandle as handle     no-undo.
    define input  parameter cProgramName  as character  no-undo.
    define output parameter hProgram      as handle     no-undo.

    run value(cProgramName) persistent set hProgram.

    create ttHandles.
    assign ttHandles.parentHandle = hParentHandle
           ttHandles.childHandle  = hProgram.

    return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-deleteInstance) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deleteInstance Procedure 
PROCEDURE deleteInstance :
/*------------------------------------------------------------------------------
  Purpose:     Deleta a procedure passada como parametro e todos os seus filhos.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter hProcedure as handle no-undo.

    define buffer ttHandles for ttHandles.

    for each ttHandles
        where ttHandles.parentHandle = hProcedure:

        run deleteInstance(ttHandles.childHandle).

        /* run 'on close' at child. Please se more details on header comments, in
           version from 19/06/2006 */
        if valid-handle(ttHandles.childHandle) then do:
            apply 'close':u to ttHandles.childHandle.

            if lookup('dispose':u, ttHandles.childHandle:internal-entries) > 0 then
                run dispose in ttHandles.childHandle.
        end.

        /* If the handle remains valid, force delete */
        if valid-handle(ttHandles.childHandle) then
            delete procedure ttHandles.childHandle.

        delete ttHandles.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getHandles) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getHandles Procedure 
PROCEDURE getHandles :
/*------------------------------------------------------------------------------
  Purpose:     Retorna temp-table de todos os handles.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter table for ttHandles.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getParent) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getParent Procedure 
PROCEDURE getParent :
/*------------------------------------------------------------------------------
  Purpose:     Encontra o pai de uma procedure.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hChildHandle  as handle     no-undo.
    define output parameter hParentHandle as handle     no-undo.

    find first ttHandles
        where ttHandles.childHandle = hChildHandle
        no-lock no-error.

    if avail ttHandles then
        assign hParentHandle = ttHandles.parentHandle.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTopParent) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTopParent Procedure 
PROCEDURE getTopParent :
/*------------------------------------------------------------------------------
  Purpose:     Encontra o pai de mais alto nivel do programa passado.
               Normalmente esse "pai" de mais alto nivel eh a interface.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hProcedure as handle     no-undo.
    define output parameter hTopParent as handle     no-undo.

    find first ttHandles
        where ttHandles.childHandle = hProcedure
        no-lock no-error.

    if not avail ttHandles then do:
        assign hTopParent = hProcedure.
        return.
    end.

    run getTopParent
        (input  ttHandles.parentHandle,
         output hTopParent).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-inherit) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inherit Procedure 
PROCEDURE inherit :
/*------------------------------------------------------------------------------
  Purpose:     Metodo que permite implementar heranca entre programas Progress.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hProgramRunning     as handle     no-undo.
    define input  parameter cClassToInheritFrom as character  no-undo.   
    
    define variable hClassInherited as handle     no-undo.
    define variable hHandleSuper    as handle     no-undo.
    define variable iLoopIndex      as integer    no-undo.
    define variable cSupersInChild  as character  no-undo.
    define variable hasError        as logical     no-undo.
    
    do iLoopIndex = 1 to num-entries(hProgramRunning:super-procedures):
        assign hHandleSuper   = widget-handle(entry(iLoopIndex, hProgramRunning:super-procedures))
               cSupersInChild = cSupersInChild +
                                ( if cSupersInChild = '':u
                                  then '':u
                                  else ',':u ) +
                                hHandleSuper:file-name.
    end.
    
    assign cClassToInheritFrom = replace( cClassToInheritFrom, "~\", "/").
    
    if index(cSupersInChild, cClassToInheritFrom) > 0 then
        return.
    
    /* run value(cClassToInheritFrom) persistent set hClassInherited no-error. */
    assign hasError = true.

    do {&try}:
        run createInstance in this-procedure
            (input  hProgramRunning,
             input  cClassToInheritFrom,
             output hClassInherited).

        assign hasError = false.
    end.

    if hasError or ( error-status:error = true ) then
        return error substitute("Could not add &1 as a super-procedure.",
                                cClassToInheritFrom).
    
    /* if the procedure has super procedures then add them to the current 
       procedures */        
    do iLoopIndex = num-entries( hClassInherited:super-procedures ) to 1 by -1:
        assign hHandleSuper = widget-handle(entry(iLoopIndex, hClassInherited:super-procedures)).
    
        if index(cSupersInChild, hHandleSuper:file-name) = 0 then
            hProgramRunning:add-super-procedure(hHandleSuper).
    end.
    
    /* add procedure as a super-procedure */
    if index(cSupersInChild, hClassInherited:file-name) = 0 then
        hProgramRunning:add-super-procedure(hClassInherited).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-registerInstance) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE registerInstance Procedure 
PROCEDURE registerInstance :
/*------------------------------------------------------------------------------
  Purpose:     Registra uma procedure ja executada (do menu, por exemplo, e nao
               via createInstance). O "registro" eh apenas a associacao da
               classe Error.p como super-procedure do programa passado como
               parametro.
  Parameters:  ...
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter hRunningProgram as handle     no-undo.

    define variable hParentHandle as handle     no-undo.

    run getParent
        (input  hRunningProgram,
         output hParentHandle).

    if not valid-handle(hParentHandle) then
        assign hParentHandle = hRunningProgram.

    run addSuperProcedures(hParentHandle, hRunningProgram).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-newInstance) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION newInstance Procedure 
FUNCTION newInstance returns handle(input path as char):
    def var hand as handle no-undo.
    run createInstance in ghInstanceManager(target-procedure, path, output hand).
    return hand.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

