&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* PROGRAMA:
*   system/Error.p
*
* FINALIDADE:
*   "Classe" que implementa tratamento de erros para infra-estrutura OO
*   em Progress 9.
*
*/

{system/Error.i}                
{method/dbotterr.i} /* rowErrors */

define temp-table rowErrorsInput no-undo
    like RowErrors.

define temp-table rowOnlyErrors no-undo
    like rowErrors.

{utils/ttErro.i}
{utils/ttErros.i}
{utils/ttBoErro.i}

/* &global-define debug_proof yes */

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
         HEIGHT             = 18.63
         WIDTH              = 34.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addErrors Procedure 
PROCEDURE addErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter table for RowErrorsInput.
    define variable iErrorSequence as integer no-undo.

    run getNextSequence (output iErrorSequence).

    for each RowErrorsInput:
        create RowErrors.
        buffer-copy RowErrorsInput to RowErrors
            assign RowErrors.ErrorSequence = iErrorSequence
                   iErrorSequence          = iErrorSequence + 1.

    end.

    &if defined(debug_proof) &then
        run logErrors.
    &endif

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addErrorsFromTtBoErro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addErrorsFromTtBoErro Procedure 
PROCEDURE addErrorsFromTtBoErro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter table for tt-bo-erro.

    for each tt-bo-erro:
        run insertError(tt-bo-erro.cd-erro, tt-bo-erro.mensagem, tt-bo-erro.errorHelp).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addErrorsFromTtErro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addErrorsFromTtErro Procedure 
PROCEDURE addErrorsFromTtErro :
/*------------------------------------------------------------------------------
  Purpose: copiar os erros da tt-erros, retornada por alguns processos,
           para a rowErrors
  Parameters: tt-errors
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter table for tt-erro.

    empty temp-table RowErrorsInput.

    run utils/ttErroToRowErrors.p(input table tt-erro,
                                  input-output table RowErrorsInput).
    run addErrors (input table RowErrorsInput).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addErrorsFromTtErros) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addErrorsFromTtErros Procedure 
PROCEDURE addErrorsFromTtErros :
/*------------------------------------------------------------------------------
  Purpose: copiar os erros da tt-erros, retornada por alguns processos,
           para a rowErrors
  Parameters: tt-errors
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter table for tt-erros.

    empty temp-table RowErrorsInput.

    run utils/ttErrosToRowErrors.p(input table tt-erros,
                                   input-output table RowErrorsInput).
    run addErrors (input table RowErrorsInput).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addErrorsInBO) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addErrorsInBO Procedure 
PROCEDURE addErrorsInBO :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter DBO as handle     no-undo.

    for each rowErrors
        {&throws}:

        run _insertErrorManual in DBO
            (rowErrors.ErrorNumber,
             rowErrors.ErrorType,
             if rowErrors.ErrorSubType begins 'Erro' then
                 'ERROR':u
             else
                 rowErrors.ErrorSubType,
             rowErrors.ErrorDescription,
             rowErrors.ErrorHelp,
             rowErrors.ErrorParameters).
    end.

    &if defined(debug_proof) &then
        run logErrors.
    &endif

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearOnlyErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearOnlyErrors Procedure 
PROCEDURE clearOnlyErrors PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    empty temp-table rowOnlyErrors no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createError) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createError Procedure 
PROCEDURE createError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iCodError   as integer no-undo.
    define input parameter cParameters as char no-undo.

    run utils/createRowError.p(input iCodError,
                               input cParameters,
                               input-output table RowErrors).

    &if defined(debug_proof) &then
        run logErrors.
    &endif

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createLockError) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createLockError Procedure 
PROCEDURE createLockError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cDatabase as character  no-undo.
    define input  parameter cTable    as character  no-undo.
    define input  parameter rRecid    as recid      no-undo.
    define input  parameter cHelp     as character  no-undo.

    define variable hQuery      as handle     no-undo.
    define variable hBufferFile as handle     no-undo.
    define variable hBufferLock as handle     no-undo.
    define variable cQueryExp   as character  no-undo.
    define variable cUser       as character  no-undo.

    do {&throws}:
        create query hQuery.
        create buffer hBufferFile for table cDatabase + '.':u + '_file':u.
        create buffer hBufferLock for table cDatabase + '.':u + '_lock':u.

        assign cQueryExp =
            substitute('for each &1._file ':u +
                       'where &1._file._file-name = "&2" ':u +
                       'no-lock':u +
                       ', ':u +
                       'first &1._lock ':u +
                       'where &1._lock._lock-table = &1._file._file-number ':u +
                         'and &1._lock._lock-recid = &3 ':u +
                       'no-lock':u,
                       cDatabase,
                       cTable,
                       rRecid).

        hQuery:set-buffers(hBufferFile, hBufferLock).
        hQuery:query-prepare(cQueryExp).
        hQuery:query-open.

        hQuery:get-first(no-lock).

        if not hQuery:query-off-end then
            assign cUser = hBufferLock:buffer-field('_lock-name':u):buffer-value.

        if cUser = '':u then
            assign cUser = '*desconhecido*'.

        /* fechada aqui para nao correr risco de ficar aberta se der erro,
           e porque o buffer eh mantido mesmo fechando a query */
        hQuery:query-close.

        run createError
            (input 17006,
             input substitute('Tabela "&1" travada pelo usu rio "&2"~~&3',
                              hBufferFile:buffer-field('_desc':u):buffer-value,
                              cUser,
                              cHelp)).

        &if defined(debug_proof) &then
            run logErrors.
        &endif
    end.

    return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-emptyErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE emptyErrors Procedure 
PROCEDURE emptyErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    empty temp-table RowErrors.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateOnlyErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateOnlyErrors Procedure 
PROCEDURE generateOnlyErrors PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run clearOnlyErrors.

    for each rowErrors
        where rowErrors.errorSubType begins 'Erro':

        create rowOnlyErrors.
        buffer-copy rowErrors to rowOnlyErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getErrorMessage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getErrorMessage Procedure 
PROCEDURE getErrorMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter errorMessage as character  no-undo.

    for each rowErrors:
        assign errorMessage = errorMessage + rowErrors.errorDescription + "~n".
    end.

    if errorMessage = '':u then
        assign errorMessage = 'Erro desconhecido (solicite mais detalhes ao administrador de sistemas)'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getErrors Procedure 
PROCEDURE getErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter table for RowErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFullErrorMessage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFullErrorMessage Procedure 
PROCEDURE getFullErrorMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter errorMessage as character  no-undo.

    for each rowErrors:
        assign errorMessage = errorMessage
            + rowErrors.errorDescription
            + ' (' + trim(string(rowErrors.errorNumber))
            + (if rowErrors.errorHelp <> '' then ', ' else '')
            + trim(rowErrors.errorHelp)
            + ')'
            + '~n'.
    end.

    if errorMessage = '':u then
        assign errorMessage = 'Erro desconhecido (solicite mais detalhes ao administrador de sistemas)'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNextSequence) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNextSequence Procedure 
PROCEDURE getNextSequence PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output param iNextSequence as integer init 1 no-undo.

    for last RowErrors:
        assign iNextSequence = RowErrors.ErrorSequence + 1.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-hasError) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hasError Procedure 
PROCEDURE hasError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter hasError as logical   no-undo. 

    assign
        hasError = can-find(first rowErrors
                            where rowErrors.errorSubType begins 'Erro').

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-insertError) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE insertError Procedure 
PROCEDURE insertError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iCodigo  as integer   no-undo. 
    define input parameter cMsg     as character no-undo. 
    define input parameter cHelp    as character no-undo. 

    run insertMessage(input iCodigo,
                      input 'ERRO':u,
                      input cMsg,
                      input cHelp).

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-insertMessage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE insertMessage Procedure 
PROCEDURE insertMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter iError   as integer   no-undo. 
    define input parameter cSubType as character no-undo. 
    define input parameter cMsg     as character no-undo. 
    define input parameter cHelp    as character no-undo. 

    define variable iSequencia as integer   no-undo.

    for last rowErrors:
        assign iSequencia = rowErrors.ErrorSequence.
    end.

    create rowErrors.
    assign
        rowErrors.ErrorSequence    = iSequencia + 1
        rowErrors.ErrorNumber      = iError
        rowErrors.ErrorParameters  = '':u
        rowErrors.ErrorType        = 'EMS':u
        rowErrors.ErrorSubType     = cSubType
        rowErrors.ErrorDescription = cMsg
        rowErrors.ErrorHelp        = cHelp.

    &if defined(debug_proof) &then
        run logErrors.
    &endif

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-logErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE logErrors Procedure 
PROCEDURE logErrors PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Provisoriamente nao esta jogando para arquivo os erros se nao for sessao
       batch. TODO: gerar log em arquivo para sessoes NAO batch */
    &IF integer(entry(1, proversion, '.':u)) <= 9 &THEN
        if not session:batch-mode then
            output to value(session:temp-dir + "error.log") append.
    &ENDIF.

    for each RowErrors:
        &IF integer(entry(1, proversion, '.':u)) > 9 &THEN
            log-manager:write-message(substitute('Erro: &1, &2~nAjuda: &3',
                                                 rowErrors.ErrorNumber,
                                                 rowErrors.ErrorDescription,
                                                 rowErrors.ErrorHelp),
                                      'PROOF').
        &ELSE
            message substitute('Erro: &1, &2~nAjuda: &3',
                           rowErrors.ErrorNumber,
                           rowErrors.ErrorDescription,
                           rowErrors.ErrorHelp).
        &ENDIF.
    end.

    run printStackTrace.

    &IF integer(entry(1, proversion, '.':u)) <= 9 &THEN
        output close.
    &ENDIF.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-printStackTrace) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printStackTrace Procedure 
PROCEDURE printStackTrace PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable i as integer no-undo initial 4.

    &IF integer(entry(1, proversion, '.':u)) > 9 &THEN
        log-manager:write-message('Stack Trace:', 'PROOF').
    &ELSE
        message 'Stack Trace:' + '~n':u.
    &ENDIF.

    do while program-name(i) <> ?:
        &IF integer(entry(1, proversion, '.':u)) > 9 &THEN
            log-manager:write-message('  ' + program-name(i), 'PROOF').
        &ELSE
            message program-name(i).
        &ENDIF.
        
        assign i = i + 1.            
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-putErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putErrors Procedure 
PROCEDURE putErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        run utils/putErrors.p(table rowErrors).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showErrors Procedure 
PROCEDURE showErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run generateOnlyErrors.

    if session:window-system = 'TTY':u then
        run utils/showBOErrorsTTY.p(input table rowErrors).
    else
        run utils/showMessages.w(input table rowOnlyErrors).

    run clearOnlyErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showMessages) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showMessages Procedure 
PROCEDURE showMessages :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    if can-find(first rowErrors) then
        if session:window-system = 'TTY':u then
            run utils/showBOErrorsTTY.p(table rowErrors).
        else
            run utils/showMessages.w(table rowErrors).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

