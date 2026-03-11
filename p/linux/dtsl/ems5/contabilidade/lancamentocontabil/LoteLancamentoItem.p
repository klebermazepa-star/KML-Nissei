&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   LancamentoContabilItem
*
* FINALIDADE:
*   ..
*
* NOTAS:
*   Classe gerada automaticamente pelo class generator
*   da Datasul Paranaense.
*/
&scoped-define tableName   item_lancto_ctbl
&scoped-define Item        _integr_item_lancto_ctbl_1

{system/Error.i}
{system/InstanceManagerDef.i}

{dtsl/ems5/contabilidade/lancamentocontabil/LancamentoContabil.i}

define variable apropriacoes as handle    no-undo.

define variable numeroLote as integer   no-undo.
define variable numeroLancamento as integer   no-undo.

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
         WIDTH              = 41.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addApropriacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addApropriacao Procedure 
PROCEDURE addApropriacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter apropriacao_ as handle     no-undo.

    do {&throws}:
        run add in apropriacoes(apropriacao_).
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
        run setIndicaErro(false).
        run setDataLancamento(today).
        run setNatureza('DB').
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
        empty temp-table tt{&Item}.
        assign
            numeroLote = 0
            numeroLancamento = 0.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearApropriacoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearApropriacoes Procedure 
PROCEDURE clearApropriacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in apropriacoes.
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
                substitute('Item lancamento Contabil inexistente.~~' 
                + 'NÆo encontrado registro na tabela Item lancamento Contabil com id &2',
                string(rtable_))).
            return error.
        end.

        run load.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getApropriacoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getApropriacoes Procedure 
PROCEDURE getApropriacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter apropriacoes_ as handle     no-undo.

    do {&throws}:
        assign
            apropriacoes_ = apropriacoes.
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
            tta_cod_ccusto_ = tt{&Item}.tta_cod_ccusto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getContaContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getContaContabil Procedure 
PROCEDURE getContaContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_cta_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_cta_ctbl_ = tt{&Item}.tta_cod_cta_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataDocumento Procedure 
PROCEDURE getDataDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_dat_docto_ as date no-undo.

    do {&throws}:
        assign
            tta_dat_docto_ = tt{&Item}.tta_dat_docto.
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
            tta_dat_lancto_ctbl_ = tt{&Item}.tta_dat_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDescricaoDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDescricaoDocumento Procedure 
PROCEDURE getDescricaoDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_des_docto_ as character no-undo.

    do {&throws}:
        assign
            tta_des_docto_ = tt{&Item}.tta_des_docto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDescricaoHistorico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDescricaoHistorico Procedure 
PROCEDURE getDescricaoHistorico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_des_histor_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_des_histor_lancto_ctbl_ = tt{&Item}.tta_des_histor_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEspecie Procedure 
PROCEDURE getEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_espec_docto_ = tt{&Item}.tta_cod_espec_docto.
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
    define output parameter tta_cod_estab_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_estab_ = tt{&Item}.tta_cod_estab.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getHistoricoPadrao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getHistoricoPadrao Procedure 
PROCEDURE getHistoricoPadrao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_histor_padr_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_histor_padr_ = tt{&Item}.tta_cod_histor_padr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getImagem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getImagem Procedure 
PROCEDURE getImagem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_imagem_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_imagem_ = tt{&Item}.tta_cod_imagem.
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
            ttv_ind_erro_valid_ = tt{&Item}.ttv_ind_erro_valid.
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
    define output parameter tta_cod_indic_econ_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_indic_econ_ = tt{&Item}.tta_cod_indic_econ.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNatureza) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNatureza Procedure 
PROCEDURE getNatureza :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_ind_natur_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_ind_natur_lancto_ctbl_ = tt{&Item}.tta_ind_natur_lancto_ctbl.
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
            tta_cod_plano_ccusto_ = tt{&Item}.tta_cod_plano_ccusto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPlanoContas) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPlanoContas Procedure 
PROCEDURE getPlanoContas :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_plano_cta_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_plano_cta_ctbl_ = tt{&Item}.tta_cod_plano_cta_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getProjeto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getProjeto Procedure 
PROCEDURE getProjeto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_proj_financ_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_proj_financ_ = tt{&Item}.tta_cod_proj_financ.
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
            tta_qtd_unid_lancto_ctbl_ = tt{&Item}.tta_qtd_unid_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSequencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getSequencia Procedure 
PROCEDURE getSequencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_num_seq_lancto_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tta_num_seq_lancto_ctbl_ = tt{&Item}.tta_num_seq_lancto_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSequenciaContraPartida) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getSequenciaContraPartida Procedure 
PROCEDURE getSequenciaContraPartida :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_num_seq_lancto_ctbl_cpart_ as integer no-undo.

    do {&throws}:
        assign
            tta_num_seq_lancto_ctbl_cpart_ = tt{&Item}.tta_num_seq_lancto_ctbl_cpart.
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
            tta_cod_unid_negoc_ = tt{&Item}.tta_cod_unid_negoc.
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
            tta_val_lancto_ctbl_ = tt{&Item}.tta_val_lancto_ctbl.
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
    
        create tt{&Item}.
        assign
            tt{&Item}.ttv_rec_integr_item_lancto_ctbl       = recid(tt{&Item})
            numeroLote                                      = {&tableName}.num_lote_ctbl
            numeroLancamento                                = {&tableName}.num_lancto_ctbl
            tt{&Item}.tta_num_seq_lancto_ctbl               = {&tableName}.num_seq_lancto_ctbl      
            tt{&Item}.tta_ind_natur_lancto_ctbl             = {&tableName}.ind_natur_lancto_ctbl    
            tt{&Item}.tta_cod_plano_cta_ctbl                = {&tableName}.cod_plano_cta_ctbl       
            tt{&Item}.tta_cod_cta_ctbl                      = {&tableName}.cod_cta_ctbl             
            tt{&Item}.tta_cod_plano_ccusto                  = {&tableName}.cod_plano_ccusto         
            tt{&Item}.tta_cod_estab                         = {&tableName}.cod_estab                
            tt{&Item}.tta_cod_unid_negoc                    = {&tableName}.cod_unid_negoc           
            tt{&Item}.tta_cod_histor_padr                   = {&tableName}.cod_histor_padr          
            tt{&Item}.tta_des_histor_lancto_ctbl            = {&tableName}.des_histor_lancto_ctbl   
            tt{&Item}.tta_cod_espec_docto                   = {&tableName}.cod_espec_docto          
            tt{&Item}.tta_dat_docto                         = {&tableName}.dat_docto                
            tt{&Item}.tta_des_docto                         = {&tableName}.des_docto                
            tt{&Item}.tta_cod_imagem                        = {&tableName}.cod_imagem               
            tt{&Item}.tta_cod_indic_econ                    = {&tableName}.cod_indic_econ           
            tt{&Item}.tta_dat_lancto_ctbl                   = {&tableName}.dat_lancto_ctbl          
            tt{&Item}.tta_qtd_unid_lancto_ctbl              = {&tableName}.qtd_unid_lancto_ctbl     
            tt{&Item}.tta_val_lancto_ctbl                   = {&tableName}.val_lancto_ctbl          
            tt{&Item}.tta_num_seq_lancto_ctbl_cpart         = {&tableName}.num_seq_lancto_ctbl_cpart       
            tt{&Item}.tta_cod_ccusto                        = {&tableName}.cod_ccusto               
            tt{&Item}.tta_cod_proj_financ                   = {&tableName}.cod_proj_financ.        
    end.
                                                            
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-loadApropriacoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadApropriacoes Procedure 
PROCEDURE loadApropriacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable apropriacao as handle    no-undo.

    define variable sequencia as integer   no-undo.

    do {&throws}:
        run clearItens.

        run getSequencia(output sequencia).

        for each aprop_lancto_ctbl
            where aprop_lancto_ctbl.num_lote_ctbl = numeroLote
              and aprop_lancto_ctbl.num_lancto_ctbl = numeroLancamento
              and aprop_lancto_ctbl.num_seq_lancto_ctbl = sequencia
            no-lock
            {&throws}:
            run createInstance in ghInstanceManager (this-procedure,
                'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamentoItemApropriacao.p':u, 
                output apropriacao).

            run findByRowid in apropriacao(rowid(aprop_lancto_ctbl)).

            run addApropriacao(apropriacao).
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

        create tt{&Item}.

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
            tt{&Item}.tta_cod_ccusto = tta_cod_ccusto_.
    end.

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
    define input  parameter tta_cod_cta_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_cta_ctbl = tta_cod_cta_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataDocumento Procedure 
PROCEDURE setDataDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_dat_docto_ as date no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_dat_docto = tta_dat_docto_.
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
            tt{&Item}.tta_dat_lancto_ctbl = tta_dat_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDescricaoDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDescricaoDocumento Procedure 
PROCEDURE setDescricaoDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_des_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_des_docto = tta_des_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDescricaoHistorico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDescricaoHistorico Procedure 
PROCEDURE setDescricaoHistorico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_des_histor_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_des_histor_lancto_ctbl = tta_des_histor_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEspecie Procedure 
PROCEDURE setEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_espec_docto = tta_cod_espec_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEstabelecimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEstabelecimento Procedure 
PROCEDURE setEstabelecimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_estab_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_estab = tta_cod_estab_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setHistoricoPadrao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setHistoricoPadrao Procedure 
PROCEDURE setHistoricoPadrao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_histor_padr_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_histor_padr = tta_cod_histor_padr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setImagem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setImagem Procedure 
PROCEDURE setImagem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_imagem_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_imagem = tta_cod_imagem_.
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
            tt{&Item}.ttv_ind_erro_valid = ttv_ind_erro_valid_.
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
    define input  parameter tta_cod_indic_econ_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_indic_econ = tta_cod_indic_econ_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNatureza) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNatureza Procedure 
PROCEDURE setNatureza :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_ind_natur_lancto_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_ind_natur_lancto_ctbl = tta_ind_natur_lancto_ctbl_.
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
            tt{&Item}.tta_cod_plano_ccusto = tta_cod_plano_ccusto_.
    end.

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
    define input  parameter tta_cod_plano_cta_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_plano_cta_ctbl = tta_cod_plano_cta_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setProjeto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setProjeto Procedure 
PROCEDURE setProjeto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_proj_financ_ as character no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_cod_proj_financ = tta_cod_proj_financ_.
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
            tt{&Item}.tta_qtd_unid_lancto_ctbl = tta_qtd_unid_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setSequencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSequencia Procedure 
PROCEDURE setSequencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_num_seq_lancto_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_num_seq_lancto_ctbl = tta_num_seq_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setSequenciaContraPartida) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSequenciaContraPartida Procedure 
PROCEDURE setSequenciaContraPartida :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_num_seq_lancto_ctbl_cpart_ as integer no-undo.

    do {&throws}:
        assign
            tt{&Item}.tta_num_seq_lancto_ctbl_cpart = tta_num_seq_lancto_ctbl_cpart_.
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
            tt{&Item}.tta_cod_unid_negoc = tta_cod_unid_negoc_.
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
            tt{&Item}.tta_val_lancto_ctbl = tta_val_lancto_ctbl_.
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
            'system/TempTableCollection.p':u, output apropriacoes).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

