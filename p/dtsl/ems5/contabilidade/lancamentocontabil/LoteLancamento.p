&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   LancamentoContabilLancamento
*
* FINALIDADE:
*   ..
*
* NOTAS:
*   Classe gerada automaticamente pelo class generator
*   da Datasul Paranaense.
*/
&scoped-define tableName   lancto_ctbl
&scoped-define Lancamento  _integr_lancto_ctbl_1

{system/Error.i}
{system/InstanceManagerDef.i}

{dtsl/ems5/contabilidade/lancamentocontabil/LancamentoContabil.i}

define variable itens as handle    no-undo.

define variable numeroLote as integer   no-undo.

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
         HEIGHT             = 22
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addItem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addItem Procedure 
PROCEDURE addItem :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    do {&throws}:
        run add in itens(item).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-afterNew) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterNew Procedure 
PROCEDURE afterNew :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        run setLancamentoApuracao(false).
        run setLancamentoConversao(false).
        run setDataLancamento(today).
        run setIndicaErro('NÆo').
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
        empty temp-table tt{&Lancamento}.
        assign
            numeroLote = 0.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearItens Procedure 
PROCEDURE clearItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in itens.
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
                substitute('Lancamento Contabil inexistente.~~' 
                + 'NÆo encontrado registro na tabela Lancamento Contabil com id &2',
                string(rtable_))).
            return error.
        end.

        run load.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCenarioContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCenarioContabil Procedure 
PROCEDURE getCenarioContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_cenar_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_cenar_ctbl_ = tt{&Lancamento}.tta_cod_cenar_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataLancamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataLancamento Procedure 
PROCEDURE getDataLancamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_dat_lancto_ctbl_ as date no-undo.

    do {&throws}:
        assign
            tta_dat_lancto_ctbl_ = tt{&Lancamento}.tta_dat_lancto_ctbl.
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
            ttv_ind_erro_valid_ = tt{&Lancamento}.ttv_ind_erro_valid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getItens Procedure 
PROCEDURE getItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter itens_ as handle     no-undo.

    do {&throws}:
        assign
            itens_ = itens.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNumeroLancamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNumeroLancamento Procedure 
PROCEDURE getNumeroLancamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_num_lancto_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tta_num_lancto_ctbl_ = tt{&Lancamento}.tta_num_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRateioContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRateioContabil Procedure 
PROCEDURE getRateioContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_rat_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_rat_ctbl_ = tt{&Lancamento}.tta_cod_rat_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isLancamentoApuracao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isLancamentoApuracao Procedure 
PROCEDURE isLancamentoApuracao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_log_lancto_apurac_restdo_ as logical no-undo.

    do {&throws}:
        assign
            tta_log_lancto_apurac_restdo_ = tt{&Lancamento}.tta_log_lancto_apurac_restdo.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isLancamentoConversao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isLancamentoConversao Procedure 
PROCEDURE isLancamentoConversao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_log_lancto_conver_ as logical no-undo.

    do {&throws}:
        assign
            tta_log_lancto_conver_ = tt{&Lancamento}.tta_log_lancto_conver.
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
    
        create tt{&Lancamento}.
        assign
            tt{&Lancamento}.ttv_rec_integr_lancto_ctbl   = recid(tt{&Lancamento})
            numeroLote                                   = {&tableName}.num_lote_ctbl
            tt{&Lancamento}.tta_cod_cenar_ctbl           = {&tableName}.cod_cenar_ctbl
            tt{&Lancamento}.tta_log_lancto_conver        = {&tableName}.log_lancto_conver
            tt{&Lancamento}.tta_log_lancto_apurac_restdo = {&tableName}.log_lancto_apurac_restdo
            tt{&Lancamento}.tta_cod_rat_ctbl             = {&tableName}.cod_rat_ctbl
            tt{&Lancamento}.tta_num_lancto_ctbl          = {&tableName}.num_lancto_ctbl
            tt{&Lancamento}.tta_dat_lancto_ctbl          = {&tableName}.dat_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-loadItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadItens Procedure 
PROCEDURE loadItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable item as handle    no-undo.

    define variable numeroLancamento as integer   no-undo.

    do {&throws}:
        run clearItens.

        run getNumeroLancamento(output numeroLancamento).

        for each item_lancto_ctbl
            where item_lancto_ctbl.num_lote_ctbl = numeroLote
              and item_lancto_ctbl.num_lancto_ctbl = numeroLancamento
            no-lock
            {&throws}:
            run createInstance in ghInstanceManager (this-procedure,
                'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamentoItem.p':u, 
                output item).

            run findByRowid in item(rowid(item_lancto_ctbl)).
            run loadApropriacoes in item.

            run addItem(item).
        end.
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

        create tt{&Lancamento}.

        run afterNew in child().
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCenarioContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCenarioContabil Procedure 
PROCEDURE setCenarioContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_cenar_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_cod_cenar_ctbl = tta_cod_cenar_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataLancamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataLancamento Procedure 
PROCEDURE setDataLancamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_dat_lancto_ctbl_ as date no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_dat_lancto_ctbl = tta_dat_lancto_ctbl_.
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
            tt{&Lancamento}.ttv_ind_erro_valid = ttv_ind_erro_valid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLancamentoApuracao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLancamentoApuracao Procedure 
PROCEDURE setLancamentoApuracao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_log_lancto_apurac_restdo_ as logical no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_log_lancto_apurac_restdo = tta_log_lancto_apurac_restdo_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLancamentoConversao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLancamentoConversao Procedure 
PROCEDURE setLancamentoConversao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_log_lancto_conver_ as logical no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_log_lancto_conver = tta_log_lancto_conver_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNumeroLancamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNumeroLancamento Procedure 
PROCEDURE setNumeroLancamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_num_lancto_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_num_lancto_ctbl = tta_num_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRateioContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRateioContabil Procedure 
PROCEDURE setRateioContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_rat_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lancamento}.tta_cod_rat_ctbl = tta_cod_rat_ctbl_.
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

    do {&throws}:
        run createInstance in ghInstanceManager (this-procedure,
            'system/TempTableCollection.p':u, output itens).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

