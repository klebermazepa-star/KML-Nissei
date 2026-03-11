&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   dtsl/ems5/contabilidade/CentroCusto.p
*
* FINALIDADE:
*   Wrapper de centros de custo do EMS 5.
*/

{system/Error.i}
{system/InstanceManagerDef.i}

define variable empresa              as character   no-undo.
define variable planoCentroCusto     as character   no-undo.
define variable centroCusto          as character   no-undo.

define new shared variable v_rec_ccusto as recid   no-undo.

define variable messageEms5 as handle      no-undo.

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
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        find first emsuni.ccusto
            where emsuni.ccusto.cod_empresa      = empresa
              and emsuni.ccusto.cod_plano_ccusto = planoCentroCusto
              and emsuni.ccusto.cod_ccusto       = centroCusto
            no-lock no-error.

        if not avail emsuni.ccusto then do:
            run createError(17006, 'Centro de custo n∆o encontrado'
                + '~~':u
                + substitute('Empresa "&1", plano c. custo "&2", c. custo "&3"',
                             empresa, planoCentroCusto, centroCusto)).
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
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter descricaoCentroCusto_ as character   no-undo.

    do {&throws}:
        run findById.
        assign descricaoCentroCusto_ = emsuni.ccusto.des_tit_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isValid) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isValid Procedure 
PROCEDURE isValid :
/*------------------------------------------------------------------------------
  Purpose:     Verifica no EMS 5 se o centro de custo eh valido.
  Parameters:  <none>
  Notes:       Necessario chamar antes setEmpresa, setPlanoCentroCusto e
               setCentroCusto.
------------------------------------------------------------------------------*/
    define output parameter isValid as logical     no-undo.

    assign isValid =
        can-find(first emsuni.ccusto
                 where emsuni.ccusto.cod_empresa      = empresa
                   and emsuni.ccusto.cod_plano_ccusto = planoCentroCusto
                   and emsuni.ccusto.cod_ccusto       = centroCusto).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-lookupPlano) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lookupPlano Procedure 
PROCEDURE lookupPlano :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first emsuni.plano_ccusto
            where emsuni.plano_ccusto.cod_empresa     = empresa
              and emsuni.plano_ccusto.dat_inic_valid <= today
              and emsuni.plano_ccusto.dat_fim_valid  >= today
            no-lock no-error.

        if not avail emsuni.plano_ccusto then do:
            run createError in messageEms5(524
                , substitute('N∆o encontrado plano de centro de custo '
                             + 'v†lido em &1 na empresa &2'
                             , today
                             , empresa)).

            return error.
        end.

        run setPlanoCentroCusto(emsuni.plano_ccusto.cod_plano_ccusto).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCentroCusto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCentroCusto Procedure 
PROCEDURE setCentroCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter centroCusto_ as character   no-undo.

    assign centroCusto = centroCusto_.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEmpresa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEmpresa Procedure 
PROCEDURE setEmpresa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter empresa_ as character   no-undo.

    assign empresa = empresa_.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPlanoCentroCusto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPlanoCentroCusto Procedure 
PROCEDURE setPlanoCentroCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter planoCentroCusto_ as character   no-undo.

    assign planoCentroCusto = planoCentroCusto_.

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

    run createInstance in ghInstanceManager(this-procedure,
        'dtsl/ems5/common/Message.p':u, output messageEms5).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-zoom) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zoom Procedure 
PROCEDURE zoom :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter centroCusto_ as character no-undo.

    do {&throws}:       
        run prgint/utb/utb066ka.w.
        
        for first emsuni.ccusto
            where recid(emsuni.ccusto) = v_rec_ccusto
            no-lock:

            run setEmpresa(emsuni.ccusto.cod_empresa).
            run setPlanoCentroCusto(emsuni.ccusto.cod_plano_ccusto).
            run setCentroCusto(emsuni.ccusto.cod_ccusto).

            assign centroCusto_ = centroCusto.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

