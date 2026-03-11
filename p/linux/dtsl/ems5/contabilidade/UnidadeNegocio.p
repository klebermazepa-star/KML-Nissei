&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   dtsl/ems5/contabilidade/UnidadeNegocio.p
*
* FINALIDADE:
*   Wrapper de unidades de negocio do EMS 5.
*/

{system/Error.i}
{system/InstanceManagerDef.i}

define variable unidadeNegocio as character   no-undo.
define new shared variable v_rec_unid_negoc as recid no-undo.

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
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 10.17
         WIDTH              = 34.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-findById) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE findById Procedure 
PROCEDURE findById :
/*  */
    do {&throws}:
        find first emsuni.unid_negoc
            where emsuni.unid_negoc.cod_unid_negoc = unidadeNegocio
            no-lock no-error.

        if not avail emsuni.unid_negoc then do:
            run createError(17006, 
                            substitute('Unidade de neg¢cio "&1" n∆o encontrada',
                                       unidadeNegocio)).
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDescricao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDescricao Procedure 
PROCEDURE getDescricao :
/*  */
    define output parameter descricao_ as character   no-undo.

    do {&throws}:
        run findById.

        assign
            descricao_ = emsuni.unid_negoc.des_unid_negoc.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isValid) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isValid Procedure 
PROCEDURE isValid :
/*------------------------------------------------------------------------------
  Purpose:     Verifica no EMS 5 se a Unidade de Negocio Ç valida .
  Parameters:  <none>
  Notes:       Necessario chamar antes setUnidadeNegocio
------------------------------------------------------------------------------*/
    define output parameter isValid as logical     no-undo.

    assign isValid =
        can-find(first emsuni.unid_negoc
                 where emsuni.unid_negoc.cod_unid_negoc = unidadeNegocio).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeNegocio) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeNegocio Procedure 
PROCEDURE setUnidadeNegocio :
/*  */
    define input  parameter unidadeNegocio_ as character   no-undo.

    assign unidadeNegocio = unidadeNegocio_.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*  */
    {system/InstanceManager.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-zoom) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zoom Procedure 
PROCEDURE zoom :
/*  */
    define output parameter unidadeNegocio_ as character no-undo.

    do {&throws}:
        run prgint/utb/utb011ka.p.
        
        for first emsuni.unid_negoc
            where recid(emsuni.unid_negoc) = v_rec_unid_negoc
            no-lock:

            run setUnidadeNegocio(emsuni.unid_negoc.cod_unid_negoc).

            assign unidadeNegocio_ = unidadeNegocio.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

