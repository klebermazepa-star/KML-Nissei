&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
    * CLASSE:
    *   dtsl/ems5/contabilidade/ContaContabil.p
    *
    * FINALIDADE:
    *   Wrapper de contas contabeis do EMS 5.
    */
    
    {system/Error.i}
    {system/InstanceManagerDef.i}
    
    define variable planoContas   as character   no-undo.
    define variable contaContabil as character   no-undo.
    
    define new shared variable v_rec_cta_ctbl_integr as recid   no-undo.

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

&IF DEFINED(EXCLUDE-findByPlanoConta) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE findByPlanoConta Procedure 
PROCEDURE findByPlanoConta :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        find first cta_ctbl_integr
            where cta_ctbl_integr.cod_plano_cta_ctbl = planoContas
              and cta_ctbl_integr.cod_cta_ctbl       = contaContabil
            no-lock no-error.

        if not avail cta_ctbl_integr then do:
            run createError(17006, 'Conta cont†bil de integraá∆o n∆o encontrada'
                + '~~':u
                + substitute('Plano contas "&1", conta "&2"',
                             planoContas, contaContabil)).
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
    define output parameter descricaoConta_ as character   no-undo.

    do {&throws}:
        run findByPlanoConta.

        find first cta_ctbl
            where cta_ctbl.cod_plano_cta_ctbl = planoContas
              and cta_ctbl.cod_cta_ctbl = contaContabil
            no-lock no-error.

        if not avail cta_ctbl then do:
            run createError(17006, 'Conta cont†bil n∆o encontrada'
                + '~~':u
                + substitute('Plano contas "&1", conta "&2"',
                             planoContas, contaContabil)).
            return error.
        end.

        assign descricaoConta_ = cta_ctbl.des_tit_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEspecieConta) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEspecieConta Procedure 
PROCEDURE getEspecieConta :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter especieConta_ as character   no-undo.

    do {&throws}:
        run findByPlanoContas.

        find first cta_ctbl
            where cta_ctbl.cod_plano_cta_ctbl = planoContas
              and cta_ctbl.cod_cta_ctbl = contaContabil
            no-lock no-error.

        if not avail cta_ctbl then do:
            run createError(17006, 'Conta cont†bil n∆o encontrada'
                + '~~':u
                + substitute('Plano contas "&1", conta "&2"',
                             planoContas, contaContabil)).
            return error.
        end.

        assign especieConta_ = ind_espec_cta_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isValid) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isValid Procedure 
PROCEDURE isValid :
/*------------------------------------------------------------------------------
  Purpose:     Verifica no EMS 5 se a conta passada como parametro eh valida.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter isValid as logical     no-undo.

    assign isValid =
        can-find(first cta_ctbl_integr
                 where cta_ctbl_integr.cod_plano_cta_ctbl = planoContas
                   and cta_ctbl_integr.cod_cta_ctbl       = contaContabil).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setContaContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setContaContabil Procedure 
PROCEDURE setContaContabil :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter contaContabil_ as character   no-undo.

    assign contaContabil = contaContabil_.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPlanoContas) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPlanoContas Procedure 
PROCEDURE setPlanoContas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter planoContas_ as character   no-undo.

    assign planoContas = planoContas_.

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

&IF DEFINED(EXCLUDE-zoom) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zoom Procedure 
PROCEDURE zoom :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter contaContabil_ as character no-undo.

    do {&throws}:
        run prgint/utb/utb033ka.w.

        for first cta_ctbl_integr fields (cod_cta_ctbl) no-lock
            where recid(cta_ctbl_integr) = v_rec_cta_ctbl_integr:

            run setPlanoContas(cta_ctbl_integr.cod_plano_cta_ctbl).
            run setContaContabil(cta_ctbl_integr.cod_cta_ctbl).

            assign contaContabil_ = contaContabil.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

