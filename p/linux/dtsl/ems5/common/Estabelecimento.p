&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------                                                          
   File        : dtsl/ems5/common/Estabelecimento.p
   Purpose     : classe para estabelecimentos
   Notes       :                                                                                                                    
   ----------------------------------------------------------------------*/                                                         
                                                                                                                                    
/* ***************************  Definitions  ************************** */                                                          
{system/Error.i}                                                                                                                    
{system/InstanceManagerDef.i}

define variable hMessage as handle    no-undo.

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
         HEIGHT             = 11.54
         WIDTH              = 34.86.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-canFind) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE canFind Procedure 
PROCEDURE canFind :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_estab_ as character  no-undo.
    define output parameter found_ as logical    no-undo.

    do {&throws}:
        assign
            found_ = can-find(estabelecimento
                                where estabelecimento.cod_estab = cod_estab_).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-find) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find Procedure 
PROCEDURE find :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_estab_ as character no-undo. 

    do {&throws}:
        find first estabelecimento
            where estabelecimento.cod_estab = cod_estab_
            no-lock no-error.

        if not avail estabelecimento then do:
            run createError in hMessage(11075, cod_estab_).
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEmpresa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEmpresa Procedure 
PROCEDURE getEmpresa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter cod_empresa_ as character  no-undo.

    do {&throws}:
        assign
            cod_empresa_ = estabelecimento.cod_empresa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEstabelecimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEstabelecimento Procedure 
PROCEDURE getEstabelecimento :
/*------------------------------------------------------------------------------                                                    
  Purpose:                                                                                                                          
  Parameters:  <none>                                                                                                               
  Notes:                                                                                                                            
------------------------------------------------------------------------------*/                                                    
    def output param cod_estab_ as character no-undo.

    do {&throws}:
        assign
            cod_estab_ = estabelecimento.cod_estab.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNomeAbreviado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNomeAbreviado Procedure 
PROCEDURE getNomeAbreviado :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter nom_abrev_ as character  no-undo.

    do {&throws}:
        assign
            nom_abrev_ = estabelecimento.nom_abrev.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNomePessoa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNomePessoa Procedure 
PROCEDURE getNomePessoa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter nom_pessoa_ as character  no-undo.

    do {&throws}:
        assign
            nom_pessoa_ = estabelecimento.nom_pessoa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPais Procedure 
PROCEDURE getPais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter cod_pais_ as character  no-undo.

    do {&throws}:
        assign
            cod_pais_ = estabelecimento.cod_pais.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose: m‚todo construtor.
  Parameters:  <none>
  Notes: executado automaticamente quando instanciado
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}

    run createInstance in ghInstanceManager
        (input this-procedure,
         input 'dtsl/ems5/common/Message.p':u,
         output hMessage).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

