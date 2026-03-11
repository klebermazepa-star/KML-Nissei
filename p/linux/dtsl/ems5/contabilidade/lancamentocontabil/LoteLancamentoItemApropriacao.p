&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   LancamentoContabilApropriacao
*
* FINALIDADE:
*   ..
*
* NOTAS:
*   Classe gerada automaticamente pelo class generator
*   da Datasul Paranaense.
*/
&scoped-define tableName   aprop_lancto_ctbl
&scoped-define Apropriacao _integr_aprop_lancto_ctbl_1

{system/Error.i}
{system/InstanceManagerDef.i}

{dtsl/ems5/contabilidade/lancamentocontabil/LancamentoContabil.i}

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
         HEIGHT             = 23.83
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-afterNew) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterNew Procedure 
PROCEDURE afterNew :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        run setIndicaErro('NÆo').
        run setOrigemValor('Informado').
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clear) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear Procedure 
PROCEDURE clear PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        empty temp-table tt{&Apropriacao}.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-findByRowid) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE findByRowid Procedure 
PROCEDURE findByRowid :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter rTable_ as rowid      no-undo.

    do {&throws}:
        find {&tableName}
             where rowid({&tableName}) = rTable_
             no-lock no-error.

        if not avail {&tableName} then do:
            run createError(17006,
                substitute('Apropria‡Æo Item Lancamento Contabil inexistente.~~' 
                + 'NÆo encontrado registro na tabela Apropria‡Æo Item Lancamento Contabil com id &2',
                string(rtable_))).
            return error.
        end.

        run load.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCentroCusto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCentroCusto Procedure 
PROCEDURE getCentroCusto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_ccusto_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_ccusto_ = tt{&Apropriacao}.tta_cod_ccusto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataCotacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataCotacao Procedure 
PROCEDURE getDataCotacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter tta_dat_cotac_indic_econ_ as date       no-undo.

    do {&throws}:
        assign
            tta_dat_cotac_indic_econ_ = tt{&Apropriacao}.tta_dat_cotac_indic_econ.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getIndicaErro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getIndicaErro Procedure 
PROCEDURE getIndicaErro :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ttv_ind_erro_valid_ as character no-undo.

    do {&throws}:
        assign
            ttv_ind_erro_valid_ = tt{&Apropriacao}.ttv_ind_erro_valid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMoeda) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMoeda Procedure 
PROCEDURE getMoeda :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_finalid_econ_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_finalid_econ_ = tt{&Apropriacao}.tta_cod_finalid_econ.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getOrigemValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getOrigemValor Procedure 
PROCEDURE getOrigemValor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_ind_orig_val_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_ind_orig_val_lancto_ctbl_ = tt{&Apropriacao}.tta_ind_orig_val_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPlanoCCusto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPlanoCCusto Procedure 
PROCEDURE getPlanoCCusto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_plano_ccusto_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_plano_ccusto_ = tt{&Apropriacao}.tta_cod_plano_ccusto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getQuantidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getQuantidade Procedure 
PROCEDURE getQuantidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_qtd_unid_lancto_ctbl_ as decimal no-undo.

    do {&throws}:
        assign
            tta_qtd_unid_lancto_ctbl_ = tt{&Apropriacao}.tta_qtd_unid_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUnidadeNegocio) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUnidadeNegocio Procedure 
PROCEDURE getUnidadeNegocio :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_unid_negoc_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_unid_negoc_ = tt{&Apropriacao}.tta_cod_unid_negoc.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getValor Procedure 
PROCEDURE getValor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_val_lancto_ctbl_ as decimal no-undo.

    do {&throws}:
        assign
            tta_val_lancto_ctbl_ = tt{&Apropriacao}.tta_val_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getValorCotacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getValorCotacao Procedure 
PROCEDURE getValorCotacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter tta_val_cotac_indic_econ_ as decimal    no-undo.

    do {&throws}:
        assign
            tta_val_cotac_indic_econ_ = tt{&Apropriacao}.tta_val_cotac_indic_econ.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-load) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load Procedure 
PROCEDURE load :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear.
    
        create tt{&Apropriacao}.
        assign
            tt{&Apropriacao}.ttv_rec_integr_aprop_lancto_ctbl = recid(tt{&Apropriacao})
            tt{&Apropriacao}.tta_cod_finalid_econ             = {&tableName}.cod_finalid_econ
            tt{&Apropriacao}.tta_qtd_unid_lancto_ctbl         = {&tableName}.qtd_unid_lancto_ctbl
            tt{&Apropriacao}.tta_val_lancto_ctbl              = {&tableName}.val_lancto_ctbl
            tt{&Apropriacao}.tta_num_id_aprop_lancto_ctbl     = {&tableName}.num_id_aprop_lancto_ctbl
            tt{&Apropriacao}.tta_dat_cotac_indic_econ         = {&tableName}.dat_cotac_indic_econ
            tt{&Apropriacao}.tta_val_cotac_indic_econ         = {&tableName}.val_cotac_indic_econ
            tt{&Apropriacao}.tta_ind_orig_val_lancto_ctbl     = {&tableName}.ind_orig_val_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-new) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE new Procedure 
PROCEDURE new :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        run clear.

        create tt{&Apropriacao}.

        run afterNew in child().
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
    define input  parameter tta_cod_ccusto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_cod_ccusto = tta_cod_ccusto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataCotacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataCotacao Procedure 
PROCEDURE setDataCotacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter tta_dat_cotac_indic_econ_ as date       no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_dat_cotac_indic_econ = tta_dat_cotac_indic_econ_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setIndicaErro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setIndicaErro Procedure 
PROCEDURE setIndicaErro :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ttv_ind_erro_valid_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.ttv_ind_erro_valid = ttv_ind_erro_valid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setMoeda) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMoeda Procedure 
PROCEDURE setMoeda :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_finalid_econ_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_cod_finalid_econ = tta_cod_finalid_econ_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setOrigemValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setOrigemValor Procedure 
PROCEDURE setOrigemValor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_ind_orig_val_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_ind_orig_val_lancto_ctbl = tta_ind_orig_val_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPlanoCCusto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPlanoCCusto Procedure 
PROCEDURE setPlanoCCusto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_plano_ccusto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_cod_plano_ccusto = tta_cod_plano_ccusto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setQuantidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setQuantidade Procedure 
PROCEDURE setQuantidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_qtd_unid_lancto_ctbl_ as decimal no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_qtd_unid_lancto_ctbl = tta_qtd_unid_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeNegocio) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeNegocio Procedure 
PROCEDURE setUnidadeNegocio :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_unid_negoc_ as character no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_cod_unid_negoc = tta_cod_unid_negoc_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValor Procedure 
PROCEDURE setValor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_val_lancto_ctbl_ as decimal no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_val_lancto_ctbl = tta_val_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setValorCotacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValorCotacao Procedure 
PROCEDURE setValorCotacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter tta_val_cotac_indic_econ_ as decimal    no-undo.

    do {&throws}:
        assign
            tt{&Apropriacao}.tta_val_cotac_indic_econ = tta_val_cotac_indic_econ_.
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

