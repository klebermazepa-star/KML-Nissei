&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* PROGRAMA:
*   system/Session.p
*
* FINALIDADE:
*   Rotinas de apoio para controle da sessao Progress.
*
*/

{system/Error.i}
{system/InstanceManagerDef.i}

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
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addFile Procedure 
PROCEDURE addFile PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     Adiciona a lista o programa passado.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input        parameter cFileName as character no-undo.
    define input-output parameter cFileList as character  no-undo.

    if cFileName = ? or
       length(cFileName) < 0 then
        return.

    assign cFileList =
        cFileList +
        ( if length(cFileList) > 0
          then ',':u
          else '':u ) +
        cFileName.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-buildRCodeName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buildRCodeName Procedure 
PROCEDURE buildRCodeName PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     Verifica se existe .r para o programa passado.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cFileName  as character no-undo.
    define output parameter cRCodeName as character no-undo initial ?.

    if num-entries(cFileName, '.':u) > 1 then
        assign cFileName = substring(cFileName, 1, r-index(cFileName, '.':u) - 1) + '.r':u.
    else
        assign cFileName = cFileName + '.r':u. 

    file-info:file-name = cFileName.

    if file-info:pathname <> ? and
       file-info:pathname = cFileName then
        assign cRCodeName = cFileName.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-fullSearch) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fullSearch Procedure 
PROCEDURE fullSearch :
/*------------------------------------------------------------------------------
  Purpose:     Procedimento equivalente a funcao SEARCH do Progress, mas que
               retorna a lista completa de entradas no PROPATH para o programa,
               da mesma forma que o botao "search" na tela de manutencao do
               PROPATH no PRO*Tools.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cFileToFind as character  no-undo.
    define output parameter cPathList   as character  no-undo.

    define variable lCurrentDir   as logical   no-undo.
    define variable iPropathCount as integer   no-undo.
    define variable cFullFilename as character no-undo.
    define variable cFileRCode    as character no-undo.
    define variable cFileExt      as character no-undo.
        
    if length(cFileToFind) > 1 then do:
       
        /* Full path name, don't use propath */        
        if index(':':u, cFileToFind) > 0 then
            run addFile(search(cFileToFind), input-output cPathList).
        else do:
            do iPropathCount = 1 to num-entries(propath):

                /* Nao eh necessaria uma barra se for o diretorio corrente */
                if entry(iPropathCount, propath) = '':u then
                    assign
                        cFullFilename = cFileToFind
                        lCurrentDir   = yes.
                else
                    assign
                        cFullFilename = entry(iPropathCount, propath) + '~/':u + cFileToFind
                        lCurrentDir   = no.
                
                if opsys begins 'win':u then
                    assign cFullFilename = replace(cFullFilename, "~/", "~\").
                else
                    assign cFullFilename = replace(cFullFilename, "~\", "~/").               
                
                /* Busca pelo .r se for um .p ou .w */
                assign cFileExt = substring(cFullFilename, length(cFullFilename, 'CHARACTER':u) - 1, -1, 'CHARACTER':u).
                if cFileExt = '.p':u or cFileExt = '.w':u then do:
                    run buildRCodeName(cFullFilename, output cFileRCode).
                    if cFileRCode <> ? then
                        run addFile(cFileRCode, input-output cPathList).
                end.
                                                                           
                file-info:file-name = cFullFilename.
                
                /* If we're working with a relative file then check if is different */
                if lCurrentDir then do:
                    if search(cFullFilename) = cFullFilename then
                           run addFile(cFullFilename, input-output cPathList).
                end.
                else do: 
                    if file-info:pathname <> ? and
                       file-info:pathname = cFullFilename then
                        run addFile(cFullFilename, input-output cPathList).    
                end.
            end.
        end.

        /* Verifica tambem se o programa esta em alguma .pl */
        if library(search(cFileToFind)) <> ? then
            run addFile(library(search(cFileToFind)), input-output cPathList).
        
        /* Se nao achou nada... */
        if num-entries(cPathList) = 0 then
            assign cPathList = '':u.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-searchNext) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE searchNext Procedure 
PROCEDURE searchNext :
/*------------------------------------------------------------------------------
  Purpose:     Equivalente ao SEARCH do Progress, mas retorna a proxima entrada
               no PROPATH.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cFileToFind as character  no-undo.
    define output parameter cNextEntry  as character  no-undo.

    define variable iCount      as integer    no-undo.
    define variable cPathList   as character  no-undo.
    define variable cFirstEntry as character  no-undo.

    run fullSearch (input cFileToFind, output cPathList).

    do iCount = 1 to num-entries(cPathList):
        case iCount:
            when 1 then
                assign cFirstEntry = entry(iCount, cPathList).

            otherwise do:
                assign cNextEntry = entry(iCount, cPathList).
                if substring(cNextEntry,  1, r-index(cNextEntry, '.':u) - 1) <>
                   substring(cFirstEntry, 1, r-index(cFirstEntry, '.':u) - 1) then
                    return.
            end.
        end case.
    end.

    assign cNextEntry = '':u.

    run createError(17006, substitute('Programa "&1" n∆o encontrado', cFileToFind)).
    return error.

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

