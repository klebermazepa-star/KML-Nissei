&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
        ---------------------------------------------------------
            ######  ######  ######  ##  ##  ###### ######  ######
           ##  ##    ##    ##      ### ##  ##     ##  ##  ##  ##
          ######    ##    ####    ## ###  ##     ######  ##  ##
         ##  ##    ##    ##      ##  ##  ##     ##  ##  ##  ##
        ##  ##    ##    ######  ##   #  ###### ##  ##  ######
        ---------------------------------------------------------
                ESTE FONTE DEVE SER EDITADO NO APPBUILDER
        ---------------------------------------------------------
        
   File        : classeGenerator
   Purpose     : Criar um modelo de classe j† com os sets e gets necess†rios
   Author(s)   : Richard Edgar - Datasul paranaense
   Created     : 29/04/2008
   Notes       : Usado como base e inspiraá∆o o accessorGenerator de Luiz Polli
   ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{system/Error.i}
{system/InstanceManagerDef.i}

{utils/class/classGeneratorDefine.i}

&scoped-define classCommentBegin '--gen_comment_begin--'
&scoped-define classCommentEnd '--gen_comment_end--'
&scoped-define classDefinitionsBegin '--gen_definitions_begin--'
&scoped-define classDefinitionsEnd '--gen_definitions_end--'
&scoped-define classFindDeclarationBegin '--gen_find_declaration_begin--'
&scoped-define classFindDeclarationEnd '--gen_find_declaration_end--'
&scoped-define classFindBegin '--gen_find_begin--'
&scoped-define classFindEnd '--gen_find_end--'
&scoped-define classCanFindDeclarationBegin '--gen_canFind_declaration_begin--'
&scoped-define classCanFindDeclarationEnd '--gen_canFind_declaration_end--'
&scoped-define classCanFindBegin '--gen_canFind_begin--'
&scoped-define classCanFindEnd '--gen_canFind_end--'
&scoped-define classSetBegin '--gen_set_begin--'
&scoped-define classSetEnd '--gen_set_end--'
&scoped-define classGetBegin '--gen_get_begin--'
&scoped-define classGetEnd '--gen_get_end--'
&scoped-define classStartUpBegin '--gen_startup_begin--'
&scoped-define classStartUpEnd '--gen_startup_end--'
&scoped-define classValidateInsertBegin '--gen_validateInsert_begin--'
&scoped-define classValidateInsertEnd '--gen_validateInsert_end--'

&scoped-define adapterPreProcessorsBegin '--gen_preprocessors_begin--'
&scoped-define adapterPreProcessorsEnd '--gen_preprocessors_end--'
&scoped-define adapterPopulateDeclarationBegin '--gen_populate_declaration_begin--'
&scoped-define adapterPopulateDeclarationEnd '--gen_populate_declaration_end--'
&scoped-define adapterPopulateBegin '--gen_populate_begin--'
&scoped-define adapterPopulateEnd '--gen_populate_end--'
&scoped-define adapterProcessingDeclarationBegin '--gen_processing_declaration_begin--'
&scoped-define adapterProcessingDeclarationEnd '--gen_processing_declaration_end--'
&scoped-define adapterProcessingBegin '--gen_processing_begin--'
&scoped-define adapterProcessingEnd '--gen_processing_end--'
&scoped-define adapterProcessingGetKeyValuesBegin '--gen_processing_getkeyvalues_begin--'
&scoped-define adapterProcessingGetKeyValuesEnd '--gen_processing_getkeyvalues_end--'
&scoped-define adapterProcessingAddBegin '--gen_processing_add_begin--'
&scoped-define adapterProcessingAddEnd '--gen_processing_add_end--'
&scoped-define adapterProcessingUpdateBegin '--gen_processing_update_begin--'
&scoped-define adapterProcessingUpdateEnd '--gen_processing_update_end--'
&scoped-define adapterGetKeyValuesDeclarationBegin '--gen_keyvalues_declaration_begin--'
&scoped-define adapterGetKeyValuesDeclarationEnd '--gen_keyvalues_declaration_end--'
&scoped-define adapterGetKeyValuesXMLBegin '--gen_keyvalues_XML_begin--'
&scoped-define adapterGetKeyValuesXMLEnd '----gen_keyvalues_XML_end----'

define temp-table ttTemplate no-undo
    field idSession   as character
    field lineContent as character.

define temp-table ttTypes no-undo
    field typeName as character.

define variable productName        as character no-undo.
define variable productVersion     as character no-undo.
define variable productType        as character no-undo.
define variable transactionName    as character no-undo.
define variable transactionVersion as character no-undo.
define variable moduleName         as character no-undo.
define variable DBO                as logical   no-undo initial false.
define variable DBOFile            as character no-undo.
define variable generateAdapter    as logical   no-undo initial false.

define variable adapterFile     as character no-undo.
define variable classFile       as character no-undo.
define variable methodSintaxe   as character no-undo.
define variable outputFolder    as character no-undo.
define variable classModel      as character no-undo.
define variable adapterModel    as character no-undo.
define variable folderTarget    as character no-undo.
define variable extentAttribute as character no-undo.
define variable extentField     as character no-undo.
define variable tempLinha       as character no-undo.
define variable countExtent     as integer   no-undo.
define variable maxExtent       as integer   no-undo.

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
         HEIGHT             = 29.92
         WIDTH              = 47.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-clear) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear Procedure 
PROCEDURE clear PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        empty temp-table ttTemplate.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createTemplate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createTemplate Procedure 
PROCEDURE createTemplate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter idSession_   as character no-undo.
  define input parameter lineContent_ as character no-undo.

  do {&throws}:
      create ttTemplate.
      assign ttTemplate.idSession   = idSession_
             ttTemplate.lineContent = lineContent_.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterKeyValuesDeclaration) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterKeyValuesDeclaration Procedure 
PROCEDURE generateAdapterKeyValuesDeclaration :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "AdapterKeyValuesDeclaration" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','<keyValue>').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','character').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock {&throws}:
                for each ttTemplate no-lock where
                         ttTemplate.idSession = "AdapterKeyValuesDeclaration" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',ttIndex.fieldName).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',ttIndex.fieldType).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterKeyValuesXML) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterKeyValuesXML Procedure 
PROCEDURE generateAdapterKeyValuesXML :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable extName as character no-undo.

    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "AdapterKeyValuesXML" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','Val').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','<keyValue>').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock {&throws}:
                case ttIndex.fieldType:
                    when 'integer' then extName = "Dec".
                    when 'decimal' then extName = "Dec".
                    when 'date'    then extName = "Date".
                    when 'logical' then extName = "Log".
                    otherwise extName = "Val".
                end case.

                for each ttTemplate no-lock where
                         ttTemplate.idSession = "AdapterKeyValuesXML" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',extName).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',ttIndex.fieldName).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterPopulate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterPopulate Procedure 
PROCEDURE generateAdapterPopulate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable extName as character no-undo.

    do {&throws}:
        for each ttAttributes no-lock {&throws}:
            case ttAttributes.typeField:
                when 'integer' then extName = "Dec".
                when 'decimal' then extName = "Dec".
                when 'date'    then extName = "Date".
                when 'logical' then extName = "Log".
                otherwise extName = "Val".
            end case.

            maxExtent = ttAttributes.numExtent.
            if maxExtent <= 0 then
                maxExtent = 1.

            do countExtent = 1 to maxExtent {&throws}:
                if ttAttributes.numExtent = 0 then
                    assign extentAttribute = ""
                           extentField     = "".
                else
                    assign extentAttribute = "_" + string(countExtent)
                           extentField     = "[" + string(countExtent) + "]".

                for each ttTemplate no-lock where
                         ttTemplate.idSession = "adapterPopulate" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',extName).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',trim(ttAttributes.fieldName) + extentAttribute).

                    if index(tempLinha,'&3') <> 0 then
                        tempLinha = replace(tempLinha,'&3',caps(substring(ttAttributes.attributeName,1,1)) + 
                                                           substring(ttAttributes.attributeName,2) +
                                                           extentAttribute).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterPopulateDeclaration) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterPopulateDeclaration Procedure 
PROCEDURE generateAdapterPopulateDeclaration PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable extName as character no-undo.

    do {&throws}:
        for each ttAttributes no-lock {&throws}:
            case ttAttributes.typeField:
                when 'integer' then extName = "decimal".
                when 'decimal' then extName = "decimal".
                when 'date'    then extName = "date".
                when 'logical' then extName = "logical".
                otherwise extName = "character".
            end case.

            if not can-find(first ttTypes no-lock where
                                  ttTypes.typeName = extName) then do:
                create ttTypes.
                assign ttTypes.typeName = extName.
            end.
        end.

        for each ttTypes no-lock:
            case ttTypes.typeName:
                when 'integer' then extName = "Dec".
                when 'decimal' then extName = "Dec".
                when 'date'    then extName = "Date".
                when 'logical' then extName = "Log".
                otherwise extName = "Val".
            end case.

            for each ttTemplate no-lock where
                     ttTemplate.idSession = "adapterPopulateDeclaration" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',extName).

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2',ttTypes.typeName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterPreProcessors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterPreProcessors Procedure 
PROCEDURE generateAdapterPreProcessors PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for each ttTemplate no-lock where
                 ttTemplate.idSession = "AdapterPreProcessors" {&throws}:
            tempLinha = ttTemplate.lineContent.

            if index(tempLinha,'&1') <> 0 then
                tempLinha = replace(tempLinha,'&1',"Aplicacao").
            if index(tempLinha,'&2') <> 0 then
                tempLinha = replace(tempLinha,'&2',productType).
            if index(tempLinha,'&3') <> 0 then
                tempLinha = replace(tempLinha,'&3',productVersion).
            if index(tempLinha,'&4') <> 0 then
                tempLinha = replace(tempLinha,'&4',caps(substring(transactionName,1,1)) + 
                                                   substring(transactionName,2)).

            run putString(tempLinha).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterProcessing) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterProcessing Procedure 
PROCEDURE generateAdapterProcessing PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for each ttTemplate no-lock where
                 ttTemplate.idSession = "adapterProcessing" {&throws}:
            tempLinha = ttTemplate.lineContent.

            if index(tempLinha,'&1') <> 0 then
                tempLinha = replace(tempLinha,'&1',lower(productType)).

            if index(tempLinha,'&2') <> 0 then
                tempLinha = replace(tempLinha,'&2',lower(moduleName)).

            if index(tempLinha,'&3') <> 0 then
                tempLinha = replace(tempLinha,'&3',caps(substring(transactionName,1,1)) + 
                                                   substring(transactionName,2)).

            run putString(tempLinha).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterProcessingAdd) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterProcessingAdd Procedure 
PROCEDURE generateAdapterProcessingAdd :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "AdapterProcessingAdd" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','<keyValueAttribute>').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','<keyValue>').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock,
                first ttAttributes no-lock where
                      ttAttributes.tableName = ttIndex.tableName and
                      ttAttributes.fieldName = ttIndex.fieldName {&throws}:
                for each ttTemplate no-lock where
                         ttTemplate.idSession = "AdapterProcessingAdd" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.attributeName,1,1)) +
                                                           substring(ttAttributes.attributeName,2)).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',ttIndex.fieldName).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterProcessingDeclaration) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterProcessingDeclaration Procedure 
PROCEDURE generateAdapterProcessingDeclaration :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "AdapterProcessingDeclaration" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','<keyValue>').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','character').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock {&throws}:
                for each ttTemplate no-lock where
                         ttTemplate.idSession = "AdapterProcessingDeclaration" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',ttIndex.fieldName).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',ttIndex.fieldType).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterProcessingGetKeyValues) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterProcessingGetKeyValues Procedure 
PROCEDURE generateAdapterProcessingGetKeyValues :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable output_ as character no-undo initial "".

    do {&throws}:
        if not can-find(first ttIndex) then 
            output_ = '<keyValue>'.
        else do:
            for each ttIndex no-lock {&throws}:
                if output_ <> "" then
                    output_ = output_ + ", ".
                output_ = output_ + "output " + trim(ttIndex.fieldName) + "_".
            end.
        end.

        for each ttTemplate no-lock where
                 ttTemplate.idSession = "AdapterProcessingGetKeyValues" {&throws}:
            tempLinha = ttTemplate.lineContent.

            if index(tempLinha,'&1') <> 0 then
                tempLinha = replace(tempLinha,'&1',output_).

            run putString(tempLinha).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateAdapterProcessingUpdate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateAdapterProcessingUpdate Procedure 
PROCEDURE generateAdapterProcessingUpdate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable input_ as character no-undo initial "".

    do {&throws}:
        if not can-find(first ttIndex) then 
            input_ = '<keyValue>'.
        else do:
            for each ttIndex no-lock {&throws}:
                if input_ <> "" then
                    input_ = input_ + ", ".
                input_ = input_ + trim(ttIndex.fieldName) + "_".
            end.
        end.

        for each ttTemplate no-lock where
                 ttTemplate.idSession = "AdapterProcessingUpdate" {&throws}:
            tempLinha = ttTemplate.lineContent.

            if index(tempLinha,'&1') <> 0 then
                tempLinha = replace(tempLinha,'&1',input_).

            run putString(tempLinha).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassCanFind) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassCanFind Procedure 
PROCEDURE generateClassCanFind PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable where_ as character no-undo initial ''.

    do {&throws}:
        if not can-find(first ttIndex) then
            where_ = 'where ~{&tableName}.<atributo> = <keyValue>'.
        else do:
            for each ttIndex
                no-lock
                break by ttIndex.tableName
                {&throws}:

                if first-of(ttIndex.tableName) then
                  where_ = where_ + 'where '.
                else
                  where_ = where_ + chr(10) + fill(" ",32) + 'and '.

                  assign
                      where_ = where_ + '~{&tableName}.' + trim(ttIndex.fieldName)
                             + ' = ' + trim(ttIndex.fieldName) + '_'.
            end.
        end.

        for first ttAttributes no-lock {&throws}:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassCanFind" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',where_).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassCanFindDeclaration) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassCanFindDeclaration Procedure 
PROCEDURE generateClassCanFindDeclaration :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassCanFindDeclaration" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','<keyValue>').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','character').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock {&throws}:
                for each ttTemplate no-lock where
                         ttTemplate.idSession = "ClassCanFindDeclaration" {&throws}:

                    assign
                        tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',trim(ttIndex.fieldName)).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',trim(ttIndex.fieldType)).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassClear) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassClear Procedure 
PROCEDURE generateClassClear PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassClear" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassComments) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassComments Procedure 
PROCEDURE generateClassComments PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassComments" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',transactionName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassDefinitions) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassDefinitions Procedure 
PROCEDURE generateClassDefinitions PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassDefinitions" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha, '&1', ttAttributes.tableName).

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2',ttAttributes.dbaseName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassDelete) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassDelete Procedure 
PROCEDURE generateClassDelete PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassDelete" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then do:
                    if DBO then
                      tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                         substring(ttAttributes.tableName,2)).
                    else
                        tempLinha = replace(tempLinha,'&1',ttAttributes.tableName).
                end.

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassFind) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassFind Procedure 
PROCEDURE generateClassFind PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable where_ as character no-undo initial ''.

    do {&throws}:
        if not can-find(first ttIndex) then
            where_ = 'where ~{&tableName}.<atributo> = <keyValue>' + chr(10).
        else do:
            for each ttIndex
                no-lock
                break by ttIndex.tableName
                {&throws}:

                if first-of(ttIndex.tableName) then
                  where_ = where_ + 'where '.
                else
                  where_ = where_ + fill(" ",15) + 'and '.

                where_ = where_ + '~{&tableName}.' + trim(ttIndex.fieldName) + ' = ' + 
                                  trim(ttIndex.fieldName) + '_' + chr(10).
            end.
        end.

        for first ttAttributes no-lock {&throws}:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassFind" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',where_).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassFindDeclaration) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassFindDeclaration Procedure 
PROCEDURE generateClassFindDeclaration :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        if not can-find(first ttIndex) then do:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassFindDeclaration" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1','<keyValue>').

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2','character').

                run putString(tempLinha).
            end.
        end.
        else do:
            for each ttIndex no-lock {&throws}:
                for each ttTemplate no-lock where
                         ttTemplate.idSession = "ClassFindDeclaration" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',trim(ttIndex.fieldName)).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',trim(ttIndex.fieldType)).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassGet) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassGet Procedure 
PROCEDURE generateClassGet PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable methodSintaxe as character no-undo.

    do {&throws}:
        for each ttAttributes no-lock {&throws}:
            maxExtent = ttAttributes.numExtent.
            if maxExtent <= 0 then
                maxExtent = 1.

            if ttAttributes.typeField = 'logical':U then
                methodSintaxe = 'is':U.
            else
                methodSintaxe = 'get':U.

            do countExtent = 1 to maxExtent {&throws}:
                if ttAttributes.numExtent = 0 then
                    assign extentAttribute = ""
                           extentField     = "".
                else
                    assign extentAttribute = "_" + string(countExtent)
                           extentField     = "[" + string(countExtent) + "]".

                for each ttTemplate no-lock where
                         ttTemplate.idSession = "ClassGet" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1',methodSintaxe + 
                                                           caps(substring(ttAttributes.attributeName,1,1)) +
                                                           substring(ttAttributes.attributeName,2) +
                                                           extentAttribute).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',trim(ttAttributes.fieldName) + extentField).

                    if index(tempLinha,'&3') <> 0 then
                        tempLinha = replace(tempLinha,'&3',ttAttributes.typeField).

                    if index(tempLinha,'&4') <> 0 then
                        tempLinha = replace(tempLinha,'&4',trim(ttAttributes.fieldName) + extentAttribute).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassInsert Procedure 
PROCEDURE generateClassInsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassInsert" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                if index(tempLinha,'&2') <> 0 and
                   not DBO then
                    tempLinha = replace(tempLinha,'&2',ttAttributes.tableName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassLoad) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassLoad Procedure 
PROCEDURE generateClassLoad PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassLoad" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2',ttAttributes.tableName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassLock) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassLock Procedure 
PROCEDURE generateClassLock PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassLock" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',ttAttributes.tableName).

                if index(tempLinha,'&2') <> 0 then
                    tempLinha = replace(tempLinha,'&2',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassNew) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassNew Procedure 
PROCEDURE generateClassNew PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassNew" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassSet) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassSet Procedure 
PROCEDURE generateClassSet PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for each ttAttributes no-lock {&throws}:
            maxExtent = ttAttributes.numExtent.
            if maxExtent <= 0 then
                maxExtent = 1.

            do countExtent = 1 to maxExtent {&throws}:
                if ttAttributes.numExtent = 0 then
                    assign extentAttribute = ""
                           extentField     = "".
                else
                    assign extentAttribute = "_" + string(countExtent)
                           extentField     = "[" + string(countExtent) + "]".

                for each ttTemplate no-lock where
                         ttTemplate.idSession = "ClassSet" {&throws}:
                    tempLinha = ttTemplate.lineContent.

                    if index(tempLinha,'&1') <> 0 then
                        tempLinha = replace(tempLinha,'&1','set' + 
                                                           caps(substring(ttAttributes.attributeName,1,1)) +
                                                           substring(ttAttributes.attributeName,2) +
                                                           extentAttribute).

                    if index(tempLinha,'&2') <> 0 then
                        tempLinha = replace(tempLinha,'&2',trim(ttAttributes.fieldName) + extentField).

                    if index(tempLinha,'&3') <> 0 then
                        tempLinha = replace(tempLinha,'&3',ttAttributes.typeField).

                    if index(tempLinha,'&4') <> 0 then
                        tempLinha = replace(tempLinha,'&4',trim(ttAttributes.fieldName) + extentAttribute).

                    run putString(tempLinha).
                end.
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassStartUp) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassStartUp Procedure 
PROCEDURE generateClassStartUp PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassStartUp" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',DBOFile).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassUnlock) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassUnlock Procedure 
PROCEDURE generateClassUnlock PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassUnlock" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',ttAttributes.tableName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassUpdate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassUpdate Procedure 
PROCEDURE generateClassUpdate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes no-lock:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassUpdate" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',caps(substring(ttAttributes.tableName,1,1)) +
                                                       substring(ttAttributes.tableName,2)).

                if index(tempLinha,'&2') <> 0 and
                   not DBO then
                    tempLinha = replace(tempLinha,'&2',ttAttributes.tableName).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateClassValidateInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateClassValidateInsert Procedure 
PROCEDURE generateClassValidateInsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable where_ as character no-undo.

    do {&throws}:
        if not can-find(first ttIndex) then
            assign
                where_ = 'tt~{&tableName}.<atributo>' + chr(10).
        else do:
            for each ttIndex
                no-lock
                break by ttIndex.tableName
                {&throws}:

                assign
                    where_ = where_ + 'tt~{&tableName}.' + trim(ttIndex.fieldName).

                if not last-of(ttIndex.tableName) then
                    assign
                        where_ = where_ + ',' + chr(10) + fill(' ', 20).
            end.
        end.

        for first ttAttributes no-lock {&throws}:
            for each ttTemplate no-lock where
                     ttTemplate.idSession = "ClassValidateInsert" {&throws}:
                tempLinha = ttTemplate.lineContent.

                if index(tempLinha,'&1') <> 0 then
                    tempLinha = replace(tempLinha,'&1',where_).

                run putString(tempLinha).
            end.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-generateFixPart) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generateFixPart Procedure 
PROCEDURE generateFixPart PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter idSession_ as character no-undo.

    do {&throws}:
        for each ttTemplate no-lock where
                 tttemplate.idSession = idSession_:
            tempLinha = ttTemplate.lineContent.
            run putString(tempLinha).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getClassFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getClassFile Procedure 
PROCEDURE getClassFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: usado na UI (criar = false) 
         e para mostrar o caminho nessa classe para validar/criar as pastas
------------------------------------------------------------------------------*/
    define input  parameter criar as logical    no-undo.
    define output parameter classFile as character  no-undo.

    do {&throws}:
        assign
            folderTarget = replace(trim(outputFolder),"\":U,"/":U).
        if substring(folderTarget,length(folderTarget),1) <> '/':U then
            assign
                folderTarget = folderTarget + '/':U.

        assign
            classFile = folderTarget.

        if criar then
            run validatePasta(false, classFile).

        if productName <> '':u then do:
            assign
                classFile = classFile + productName + '/':u.
            if criar then
                run validatePasta(true, classFile).
        end.

        if productType <> '':u then do:
            assign
                classFile = classFile + lower(productType) + '/'.
            if criar then
                run validatePasta(true, classFile).
        end.

        if moduleName <> '' then do:
            assign
                classFile = classFile + lower(moduleName) + '/'.
            if criar then
                run validatePasta(true, classFile).
        end.

        assign
            classFile = classFile
                      + caps(substring(transactionName,1,1))
                      + substring(transactionName,2) + '.p'.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-outputFiles) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputFiles Procedure 
PROCEDURE outputFiles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter table for ttAttributes.

    do {&throws}:
        run verifyOutput.

        if search(adapterFile) <> ? or
           search(classFile) <> ? then do:
            run utp/ut-msgs.p (input "show",
                               input 27100,
                               input "Arquivos adapter/classe j† existem!~~" +
                                     "Deseja regravar arquivos?").
            if return-value <> "yes":U then
                return error.
        end.

        run verifyModel.
        run verifyFields.
        run readModel.

        output to value(classFile).
        run generateFixPart("classFixPart1").
        run generateClassComments.
        run generateFixPart("classFixPart2").
        run generateClassDefinitions.
        run generateFixPart("classFixPart3").
        run generateClassCanFindDeclaration.
        run generateFixPart("classFixPart4").
        run generateClassCanFind.
        run generateFixPart("classFixPart5").        
        run generateClassFindDeclaration.
        run generateFixPart("classFixPart6").
        run generateClassFind.
        run generateFixPart("classFixPart7").
        run generateClassSet.
        run generateFixPart("classFixPart8").
        run generateClassGet.
        run generateFixPart("classFixPart9").
        run generateClassStartUp.
        run generateFixPart("classFixPart10").
        run generateClassValidateInsert.
        run generateFixPart("classFixPart11").
        output close.

        if generateAdapter then do:
            output to value(adapterFile).
            run generateFixPart("adapterFixPart1").
            run generateAdapterPreProcessors.
            run generateFixPart("adapterFixPart2").
            run generateAdapterPopulateDeclaration.
            run generateFixPart("adapterFixPart3").
            run generateAdapterPopulate.
            run generateFixPart("adapterFixPart4").
            run generateAdapterProcessingDeclaration.
            run generateFixPart("adapterFixPart5").
            run generateAdapterProcessing.
            run generateFixPart("adapterFixPart6").
            run generateAdapterProcessingGetKeyValues.
            run generateFixPart("adapterFixPart7").
            run generateAdapterProcessingAdd.
            run generateFixPart("adapterFixPart8").
            run generateAdapterProcessingUpdate.
            run generateFixPart("adapterFixPart9").
            run generateAdapterKeyValuesDeclaration.
            run generateFixPart("adapterFixPart10").
            run generateAdapterKeyValuesXML.
            run generateFixPart("adapterFixPart11").

            output close.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-putString) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putString Procedure 
PROCEDURE putString PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter lineContents as character no-undo.

    do {&throws}:
        if lineContents = "" then
            put unformatted skip(1).
        else
            put unformatted 
                right-trim(lineContents)
                skip.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-readModel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE readModel Procedure 
PROCEDURE readModel PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable lineImport as character no-undo.
    define variable idSession_ as integer   no-undo.

    do {&throws}:
        run clear.

        idSession_ = 1.
        input from value(search(classModel)).
        repeat:
            import unformatted lineImport.

            if index(lineImport,{&classCommentBegin}) <> 0 or
               index(lineImport,{&classCommentEnd}) <> 0 or
               index(lineImport,{&classDefinitionsBegin}) <> 0 or
               index(lineImport,{&classDefinitionsEnd}) <> 0 or
               index(lineImport,{&classCanFindDeclarationBegin}) <> 0 or
               index(lineImport,{&classCanFindDeclarationEnd}) <> 0 or
               index(lineImport,{&classCanFindBegin}) <> 0 or
               index(lineImport,{&classCanFindEnd}) <> 0 or               
               index(lineImport,{&classFindDeclarationBegin}) <> 0 or
               index(lineImport,{&classFindDeclarationEnd}) <> 0 or
               index(lineImport,{&classFindBegin}) <> 0 or
               index(lineImport,{&classFindEnd}) <> 0 or
               index(lineImport,{&classSetBegin}) <> 0 or
               index(lineImport,{&classSetEnd}) <> 0 or
               index(lineImport,{&classGetBegin}) <> 0 or
               index(lineImport,{&classGetEnd}) <> 0 or
               index(lineImport,{&classStartUpBegin}) <> 0 or
               index(lineImport,{&classStartUpEnd}) <> 0 or
               index(lineImport,{&classValidateInsertBegin}) <> 0 or
               index(lineImport,{&classValidateInsertEnd}) <> 0 then do:

                assign
                    idSession_ = idSession_ + 1.

                next.
            end.

            case idSession_:
                when  1 then run createTemplate("ClassFixPart1",lineImport).
                when  2 then run createTemplate("ClassComments",lineImport).
                when  3 then run createTemplate("ClassFixPart2",lineImport).
                when  4 then run createTemplate("ClassDefinitions",lineImport).
                when  5 then run createTemplate("ClassFixPart3",lineImport).
                
                when  6 then run createTemplate("ClassCanFindDeclaration",lineImport).
                when  7 then run createTemplate("ClassFixPart4",lineImport).
                when  8 then run createTemplate("ClassCanFind",lineImport).
                when  9 then run createTemplate("ClassFixPart5",lineImport).
                
                when 10 then run createTemplate("ClassFindDeclaration",lineImport).
                when 11 then run createTemplate("ClassFixPart6",lineImport).
                when 12 then run createTemplate("ClassFind",lineImport).
                when 13 then run createTemplate("ClassFixPart7",lineImport).
                when 14 then run createTemplate("ClassSet",lineImport).
                when 15 then run createTemplate("ClassFixPart8",lineImport).
                when 16 then run createTemplate("ClassGet",lineImport).
                when 17 then run createTemplate("ClassFixPart9",lineImport).
                when 18 then run createTemplate("ClassStartUp",lineImport).
                when 19 then run createTemplate("ClassFixPart10",lineImport).
                
                when 20 then run createTemplate("ClassValidateInsert",lineImport).
                when 21 then run createTemplate("ClassFixPart11",lineImport).
                
            end case.
        end.
        input close.

        idSession_ = 1.
        input from value(search(adapterModel)).
        repeat:
            import unformatted lineImport.

            if index(lineImport,{&adapterPreProcessorsBegin}) <> 0 or
               index(lineImport,{&adapterPreProcessorsEnd}) <> 0 or
               index(lineImport,{&adapterPopulateDeclarationBegin}) <> 0 or
               index(lineImport,{&adapterPopulateDeclarationEnd}) <> 0 or
               index(lineImport,{&adapterPopulateBegin}) <> 0 or
               index(lineImport,{&adapterPopulateEnd}) <> 0 or
               index(lineImport,{&adapterProcessingDeclarationBegin}) <> 0 or
               index(lineImport,{&adapterProcessingDeclarationEnd}) <> 0 or
               index(lineImport,{&adapterProcessingBegin}) <> 0 or
               index(lineImport,{&adapterProcessingEnd}) <> 0 or
               index(lineImport,{&adapterProcessingGetKeyValuesBegin}) <> 0 or
               index(lineImport,{&adapterProcessingGetKeyValuesEnd}) <> 0 or
               index(lineImport,{&adapterProcessingAddBegin}) <> 0 or
               index(lineImport,{&adapterProcessingAddEnd}) <> 0 or
               index(lineImport,{&adapterProcessingUpdateBegin}) <> 0 or
               index(lineImport,{&adapterProcessingUpdateEnd}) <> 0 or
               index(lineImport,{&adapterGetKeyValuesDeclarationBegin}) <> 0 or
               index(lineImport,{&adapterGetKeyValuesDeclarationEnd}) <> 0 or
               index(lineImport,{&adapterGetKeyValuesXMLBegin}) <> 0 or
               index(lineImport,{&adapterGetKeyValuesXMLEnd}) <> 0 then do:
                idSession_ = idSession_ + 1.
                next.
            end.

            case idSession_:
                when  1 then run createTemplate("AdapterFixPart1",lineImport).
                when  2 then run createTemplate("AdapterPreProcessors",lineImport).
                when  3 then run createTemplate("AdapterFixPart2",lineImport).
                when  4 then run createTemplate("AdapterPopulateDeclaration",lineImport).
                when  5 then run createTemplate("AdapterFixPart3",lineImport).
                when  6 then run createTemplate("AdapterPopulate",lineImport).
                when  7 then run createTemplate("AdapterFixPart4",lineImport).
                when  8 then run createTemplate("AdapterProcessingDeclaration",lineImport).
                when  9 then run createTemplate("AdapterFixPart5",lineImport).
                when 10 then run createTemplate("AdapterProcessing",lineImport).
                when 11 then run createTemplate("AdapterFixPart6",lineImport).
                when 12 then run createTemplate("AdapterProcessingGetKeyValues",lineImport).
                when 13 then run createTemplate("AdapterFixPart7",lineImport).
                when 14 then run createTemplate("AdapterProcessingAdd",lineImport).
                when 15 then run createTemplate("AdapterFixPart8",lineImport).
                when 16 then run createTemplate("AdapterProcessingUpdate",lineImport).
                when 17 then run createTemplate("AdapterFixPart9",lineImport).
                when 18 then run createTemplate("AdapterKeyValuesDeclaration",lineImport).
                when 19 then run createTemplate("AdapterFixPart10",lineImport).
                when 20 then run createTemplate("AdapterKeyValuesXML",lineImport).
                when 21 then run createTemplate("AdapterFixPart11",lineImport).
            end case.
        end.
        input close.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-readPrimaryKey) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE readPrimaryKey Procedure 
PROCEDURE readPrimaryKey PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        for first ttAttributes {&throws}:
            delete alias dictdb.
            create alias dictdb for database value(ttAttributes.dbaseName).

            run utils/class/ClassGeneratorPrimaryKey.p
                (input table ttAttributes, output table ttIndex).
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDBO) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDBO Procedure 
PROCEDURE setDBO :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter DBO_     as logical   no-undo initial false.
    define input parameter DBOFile_ as character no-undo.

    do {&throws}:
        DBO     = DBO_.
        DBOFile = DBOFile_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setGenerateAdapter) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setGenerateAdapter Procedure 
PROCEDURE setGenerateAdapter :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter generateAdapter_ as logical no-undo initial false.

    do {&throws}:
        generateAdapter = generateAdapter_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setOutputFiles) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setOutputFiles Procedure 
PROCEDURE setOutputFiles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter outputFolder_ as character no-undo.

    do {&throws}:
        outputFolder = outputFolder_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setProduct) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setProduct Procedure 
PROCEDURE setProduct :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter productName_    as character no-undo.
    define input parameter productVersion_ as character no-undo.
    define input parameter productType_    as integer   no-undo.

    do {&throws}:
        assign
            productName    = productName_
            productVersion = productVersion_
            productType    = if productType_ < 3 then
                                 entry(productType_, "EMS2,EMS5")
                             else
                                 '':u.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTransaction) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTransaction Procedure 
PROCEDURE setTransaction :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter moduleName_         as character no-undo.
    define input parameter transactionName_    as character no-undo.
    define input parameter transactionVersion_ as character no-undo.

    do {&throws}:
        moduleName         = moduleName_.
        transactionName    = transactionName_.
        transactionVersion = transactionVersion_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose: mÇtodo construtor.
  Parameters:  <none>
  Notes: executado automaticamente quando instanciado
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validatePasta) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validatePasta Procedure 
PROCEDURE validatePasta PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter criar as logical    no-undo.
    define input  parameter pasta as character  no-undo.

    do {&throws}:

        if search(pasta + "nul":U) = ? and criar then
            os-create-dir value(substring(pasta, 1, length(pasta) - 1)).

        if search(pasta + "nul":U) = ? then do:
            run createError(17006,'Geraá∆o cancelada!~~' +
                            substitute('Pasta &1 n∆o existe &2',
                                       pasta,
                                       string(criar, 'e n∆o pode ser criada/'))).
            return error.
        end.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyFields Procedure 
PROCEDURE verifyFields PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  do {&throws}:
      if not can-find(first ttAttributes) then do:
          run createError(17006,'Geraá∆o cancelada!~~Coleá∆o de atributos vazia').
          return error.
      end.

      for first ttAttributes:
          delete alias dictdb.
          create alias dictdb for database value(ttAttributes.dbaseName).

          run readPrimaryKey.
      end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyModel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyModel Procedure 
PROCEDURE verifyModel PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    adapterModel = 'utils/class/ClassGeneratorTemplateAdapter.i'.

    if DBO then
        classModel = 'utils/class/ClassGeneratorTemplateClasseDBO.i'.
    else
        classModel = 'utils/class/ClassGeneratorTemplateClasse.i'.

    if search(classModel) = ? then do:
        run createError(17006,'Geraá∆o cancelada!~~Modelo de classe n∆o existe').
        return error.
    end.

    if search(adapterModel) = ? then do:
        run createError(17006,'Geraá∆o cancelada!~~Modelo de adapter n∆o existe').
        return error.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyOutput) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyOutput Procedure 
PROCEDURE verifyOutput PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  do {&throws}:

      run getClassFile(true, output classFile).

      if generateAdapter then do:
          file-infor:file-name = folderTarget + "integracao/" + lower(productType) + "/adapters".
          if search(folderTarget + "integracao/" + lower(productType) + "/adapters/nul":U) = ? then 
              os-create-dir value(folderTarget + "integracao/" + lower(productType) + "/adapters").
          if search(folderTarget + "integracao/" + lower(productType) + "/adapters/nul":U) = ? then do:
              run createError(17006,'Geraá∆o cancelada!~~Pasta integracao/' + lower(productType) + '/adapters n∆o existe e n∆o pode ser criada').
              return error.
          end.

          file-infor:file-name = folderTarget + "integracao/" + lower(productType) + "/adapters/" + lower(moduleName).
          if search(folderTarget + "integracao/" + lower(productType) + "/adapters/" + lower(moduleName) + "/nul":U) = ? then 
              os-create-dir value(folderTarget + "integracao/" + lower(productType) + "/adapters/" + lower(moduleName)).
          if search(folderTarget + "integracao/" + lower(productType) + "/adapters/" + lower(moduleName) + "/nul":U) = ? then do:
              run createError(17006,'Geraá∆o cancelada!~~Pasta integracao/' + lower(productType) + '/adapters/' + lower(moduleName) + ' n∆o existe e n∆o pode ser criada').
              return error.
          end.

          adapterFile = folderTarget + "integracao/" + lower(productType) + "/adapters/" + lower(moduleName) + "/" + 
                        caps(substring(transactionName,1,1)) + substring(transactionName,2) + ".p".
      end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

