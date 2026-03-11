&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*
Author: JRA
Template Name: DBO
Template Library: CSTDDK
Template Version: 1.01
*/
/* Template Definitions ---                                                 */
&SCOPED-DEFINE DBOName          bocst001
&SCOPED-DEFINE DBOVersion       1.00.00.000

&SCOPED-DEFINE DBOTable         cst_prefeitura
&SCOPED-DEFINE DBOTempTable     tt_cst_prefeitura
&SCOPED-DEFINE DBOQuery         DBOQry

&SCOPED-DEFINE keyField1        cod_prefeitura

DEF QUERY {&DBOQuery} FOR {&DBOTable} SCROLLING .
DEF TEMP-TABLE {&DBOTempTable} NO-UNDO LIKE {&DBOTable}
    FIELD r-rowid AS ROWID
    .
DEF TEMP-TABLE tt-constraint NO-UNDO
    FIELD cod_prefeitura       LIKE {&DBOTable}.cod_prefeitura EXTENT 2 INIT [0 , 999999999]
    .
CREATE tt-constraint .

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&DBOName} {&DBOVersion}}

/* Template Includes                                                        */
{cstddk/include/dbocstDefinitions.i}

/* ***************************  Definitions  ***************************    */

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */

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
         HEIGHT             = 14.54
         WIDTH              = 34.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */
{cstddk/include/dbocstMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-openQueryMain) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueryMain Procedure 
PROCEDURE openQueryMain :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
OPEN QUERY {&DBOQuery} FOR EACH {&DBOTable} NO-LOCK INDEXED-REPOSITION .
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateRecord) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateRecord Procedure 
PROCEDURE validateRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAMETER p-type  AS CHAR NO-UNDO .

/*Chave Duplicada*/
IF p-type = "Create":U THEN DO:
    IF CAN-FIND(FIRST {&DBOTable} OF {&DBOTempTable}) 
    THEN DO:
        RUN insertErrorManual IN THIS-PROCEDURE
            (INPUT 8 , INPUT "EMS":U , INPUT "ERROR":U , INPUT "":U ,
             INPUT "J  existe um registro com a chave informada":U , 
             INPUT "":U ) 
            .
    END.
END.

/*Relacionamentos com chave externa*/

/*Relacionamentos com filhos*/
/*IF p-type = "Delete":U THEN DO:
    IF CAN-FIND(FIRST pdcst_fam_comerc WHERE
                pdcst_fam_comerc.fm-cod-com-base = {&DBOTempTable}.fm-cod-com-base ) 
    THEN DO:
        RUN insertErrorManual IN THIS-PROCEDURE
            (INPUT 5 , INPUT "EMS":U , INPUT "ERROR":U , INPUT "":U ,
             INPUT "Possui relacionamentos ativos com Familia Comercial":U , 
             INPUT "":U ) 
            .
    END.
END.*/

/**/
IF CAN-FIND(FIRST RowErrors) THEN RETURN "NOK":U .
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

