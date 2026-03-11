&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   LancamentoContabil
*
* FINALIDADE:
*   ..
*
* NOTAS:
*   Classe gerada automaticamente pelo class generator
*   da Datasul Paranaense.
*/
&scoped-define tableName   lote_ctbl
&scoped-define Lote        _integr_lote_ctbl_1
&scoped-define Lancamento  _integr_lancto_ctbl_1
&scoped-define Item        _integr_item_lancto_ctbl_1
&scoped-define Apropriacao _integr_aprop_lancto_ctbl_1
&scoped-define ErroInsert  _integr_ctbl_valid_1
&scoped-define ErroCancel  _log_erro

{system/Error.i}
{system/InstanceManagerDef.i}

{dtsl/ems5/contabilidade/lancamentocontabil/LancamentoContabil.i}

define new global shared variable v_cod_empres_usuar as character no-undo.

define variable lancamentos as handle    no-undo.
define variable itens as handle    no-undo.
define variable apropriacoes as handle    no-undo.
define new shared stream s_1.

define variable atualizaLote as logical   no-undo.
define variable outputFile as character no-undo.

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
         HEIGHT             = 30.13
         WIDTH              = 38.86.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addLancamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addLancamento Procedure 
PROCEDURE addLancamento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter lancamento as handle     no-undo.

    do {&throws}:
        run add in lancamentos(lancamento).
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
        run setDataLote(today).
        run setIndicaErro('N∆o').
        run setIntegracaoOnline(false).
        run setAtualizaLote(false).
        run setLoteContabil(recid(tt{&Lote})).
        run setOutputFile('LancamentoContabil.txt').
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-beforeInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInsert Procedure 
PROCEDURE beforeInsert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        /*<Execute os set's das colunas de valores default. Se nao precisar, exclua esse metodo>*/
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-cancel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cancel Procedure 
PROCEDURE cancel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable codigoEmpresa as character no-undo.
    define variable numeroLote as integer   no-undo.

    do {&throws}:
        run getNumeroLote(output numeroLote).

        for each tt{&Lancamento}
            no-lock
            {&throws}:
            find first lancto_ctbl
                where lancto_ctbl.num_lote_ctbl = numeroLote
                  and lancto_ctbl.num_lancto_ctbl = tt{&Lancamento}.tta_num_lancto_ctbl
                no-lock no-error.

            if avail lancto_ctbl and
                lancto_ctbl.ind_sit_lancto_ctbl = 'Ctbz' then do:

                run prgfin/fgl/fgl201za.py (1,  numeroLote, tt{&Lancamento}.tta_num_lancto_ctbl,
                    'Descontabilizar', output table tt{&ErroCancel}).
        
                run verifyErrors.
            end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-canFind) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE canFind Procedure 
PROCEDURE canFind :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input parameter num_lote_ctbl_ as integer no-undo.
    define output parameter found_ as logical    no-undo.

    do {&throws}:
        assign
            found_ = can-find({&tableName}
                              where {&tableName}.num_lote_ctbl = num_lote_ctbl_).
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
        empty temp-table tt{&Lote}.
        empty temp-table tt{&Lancamento}.
        empty temp-table tt{&Item}.
        empty temp-table tt{&Apropriacao}.
        empty temp-table tt{&ErroInsert}.
        empty temp-table tt{&ErroCancel}.

        assign
            atualizaLote = false
            outputFile = ''.

        run clearLancamentos.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearLancamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearLancamentos Procedure 
PROCEDURE clearLancamentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in lancamentos.
        run clear in itens.
        run clear in apropriacoes.
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
    define input parameter num_lote_ctbl_ as integer no-undo.

    do {&throws}:
        find first {&tableName}
             where {&tableName}.num_lote_ctbl = num_lote_ctbl_
             no-lock no-error.

        if not avail {&tableName} then do:
            run createError(17006, substitute('Lote cont†bil %1 n∆o encontrado',
                num_lote_ctbl_)).
            return error.
        end.

        run findByRowId(rowid({&tableName})).
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
                substitute('Lote Contabil inexistente.~~' 
                + 'N∆o encontrado registro na tabela Lote Contabil com id &2',
                string(rtable_))).
            return error.
        end.

        run load.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataLote Procedure 
PROCEDURE getDataLote :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_dat_lote_ctbl_ as date no-undo.

    do {&throws}:
        assign
            tta_dat_lote_ctbl_ = tt{&Lote}.tta_dat_lote_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDescricaoLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDescricaoLote Procedure 
PROCEDURE getDescricaoLote :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_des_lote_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tta_des_lote_ctbl_ = tt{&Lote}.tta_des_lote_ctbl.
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
    define output parameter tta_cod_empresa_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_empresa_ = tt{&Lote}.tta_cod_empresa.
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
            ttv_ind_erro_valid_ = tt{&Lote}.ttv_ind_erro_valid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLoteContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLoteContabil Procedure 
PROCEDURE getLoteContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ttv_rec_integr_lote_ctbl_ as recid no-undo.

    do {&throws}:
        assign
            ttv_rec_integr_lote_ctbl_ = tt{&Lote}.ttv_rec_integr_lote_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getModuloDatasul) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getModuloDatasul Procedure 
PROCEDURE getModuloDatasul :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_modul_dtsul_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_modul_dtsul_ = tt{&Lote}.tta_cod_modul_dtsul.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNumeroLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNumeroLote Procedure 
PROCEDURE getNumeroLote :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter tta_num_lote_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tta_num_lote_ctbl_ = tt{&Lote}.tta_num_lote_ctbl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getOutputFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getOutputFile Procedure 
PROCEDURE getOutputFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter outputFile_ as character  no-undo.

    do {&throws}:
        assign
            outputFile_ = outputFile.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-insert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE insert Procedure 
PROCEDURE insert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    
    define variable outputFile as character no-undo.

    do {&throws}:
        run getOutputFile(output outputFile).

        run beforeInsert in child().

        run populateLancamentos.

        run validate('insert':u).

        os-delete value(session:temp-directory + outputFile).
       
        output stream s_1 to value(session:temp-directory + outputFile).

        run prgfin/fgl/fgl900zl.py (
            3, 
            'Aborta Lotes Errados',
            true,
            300,
            'Apropriaá∆o',
            'Todos',
            true,
            true,
            input-output table tt{&Lote},
            input-output table tt{&Lancamento},
            input-output table tt{&Item},
            input-output table tt{&Apropriacao},
            input-output table tt{&ErroInsert}).

        output stream s_1 close.

        find first tt{&Lote} no-lock no-error.

        run verifyErrors.

        if not atualizaLote then
            run cancel.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isIntegracaoOnline) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isIntegracaoOnline Procedure 
PROCEDURE isIntegracaoOnline :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_log_integr_ctbl_online_ as logical no-undo.

    do {&throws}:
        assign
            tta_log_integr_ctbl_online_ = tt{&Lote}.tta_log_integr_ctbl_online.
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

        create tt{&Lote}.
        assign
            tt{&Lote}.ttv_rec_integr_lote_ctbl   = recid(tt{&Lote})
            tt{&Lote}.tta_cod_modul_dtsul        = {&tableName}.cod_modul_dtsul       
            tt{&Lote}.tta_num_lote_ctbl          = {&tableName}.num_lote_ctbl         
            tt{&Lote}.tta_des_lote_ctbl          = {&tableName}.des_lote_ctbl         
            tt{&Lote}.tta_cod_empresa            = {&tableName}.cod_empresa           
            tt{&Lote}.tta_dat_lote_ctbl          = {&tableName}.dat_lote_ctbl       
            tt{&Lote}.tta_log_integr_ctbl_online = {&tableName}.log_integr_ctbl_online.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-loadLancamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadLancamentos Procedure 
PROCEDURE loadLancamentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable lancamento as handle    no-undo.

    define variable numeroLote as integer   no-undo.

    do {&throws}:
        run clearLancamentos.

        run getNumeroLote(output numeroLote).

        for each lancto_ctbl
            where lancto_ctbl.num_lote_ctbl = numeroLote
            no-lock
            {&throws}:
            run createInstance in ghInstanceManager (this-procedure,
                'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamento.p':u, 
                output lancamento).

            run findByRowid in lancamento(rowid(lancto_ctbl)).
            run loadItens in lancamento.

            run addLancamento(lancamento).
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

        create tt{&Lote}.

        run afterNew in child().
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateApropriacoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateApropriacoes Procedure 
PROCEDURE populateApropriacoes PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        {system/foreach.i apropriacao apropriacoes}

            create tt{&Apropriacao}.
            assign
                tt{&Apropriacao}.ttv_rec_integr_aprop_lancto_ctbl = recid(tt{&Apropriacao})
                tt{&Apropriacao}.tta_num_id_aprop_lancto_ctbl = recid(tt{&Apropriacao})
                tt{&Apropriacao}.ttv_rec_integr_item_lancto_ctbl = recid(tt{&Item}).

            run getMoeda                    in apropriacao(output tt{&Apropriacao}.tta_cod_finalid_econ).
            run getUnidadeNegocio           in apropriacao(output tt{&Apropriacao}.tta_cod_unid_negoc).
            run getPlanoCCusto              in apropriacao(output tt{&Apropriacao}.tta_cod_plano_ccusto).
            run getQuantidade               in apropriacao(output tt{&Apropriacao}.tta_qtd_unid_lancto_ctbl).
            run getValor                    in apropriacao(output tt{&Apropriacao}.tta_val_lancto_ctbl).
            run getDataCotacao              in apropriacao(output tt{&Apropriacao}.tta_dat_cotac_indic_econ).
            run getValorCotacao             in apropriacao(output tt{&Apropriacao}.tta_val_cotac_indic_econ).
            run getIndicaErro               in apropriacao(output tt{&Apropriacao}.ttv_ind_erro_valid).
            run getOrigemValor              in apropriacao(output tt{&Apropriacao}.tta_ind_orig_val_lancto_ctbl).
            run getCentroCusto              in apropriacao(output tt{&Apropriacao}.tta_cod_ccusto).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateItens Procedure 
PROCEDURE populateItens PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable counter as integer initial 1 no-undo.

    do {&throws}:
        {system/foreach.i item itens}
            run setSequencia in item(counter).
            assign
                counter = counter + 1.

            create tt{&Item}.
            assign
                tt{&Item}.ttv_rec_integr_item_lancto_ctbl = recid(tt{&Item})
                tt{&Item}.ttv_rec_integr_lancto_ctbl = recid(tt{&Lancamento}).

            run getSequencia                in item(output tt{&Item}.tta_num_seq_lancto_ctbl).        
            run getNatureza                 in item(output tt{&Item}.tta_ind_natur_lancto_ctbl).      
            run getPlanoContas              in item(output tt{&Item}.tta_cod_plano_cta_ctbl).         
            run getContaContabil            in item(output tt{&Item}.tta_cod_cta_ctbl).               
            run getPlanoCCusto              in item(output tt{&Item}.tta_cod_plano_ccusto).           
            run getEstabelecimento          in item(output tt{&Item}.tta_cod_estab).                  
            run getUnidadeNegocio           in item(output tt{&Item}.tta_cod_unid_negoc).             
            run getHistoricoPadrao          in item(output tt{&Item}.tta_cod_histor_padr).
            run getDescricaoHistorico       in item(output tt{&Item}.tta_des_histor_lancto_ctbl).     
            run getEspecie                  in item(output tt{&Item}.tta_cod_espec_docto).            
            run getDataDocumento            in item(output tt{&Item}.tta_dat_docto).                  
            run getDescricaoDocumento       in item(output tt{&Item}.tta_des_docto).                  
            run getImagem                   in item(output tt{&Item}.tta_cod_imagem).                 
            run getMoeda                    in item(output tt{&Item}.tta_cod_indic_econ).             
            run getDataLancamento           in item(output tt{&Item}.tta_dat_lancto_ctbl).            
            run getQuantidade               in item(output tt{&Item}.tta_qtd_unid_lancto_ctbl).       
            run getValor                    in item(output tt{&Item}.tta_val_lancto_ctbl).            
            run getSequenciaContraPartida   in item(output tt{&Item}.tta_num_seq_lancto_ctbl_cpart).  
            run getIndicaErro               in item(output tt{&Item}.ttv_ind_erro_valid).             
            run getCentroCusto              in item(output tt{&Item}.tta_cod_ccusto).                 
            run getProjeto                  in item(output tt{&Item}.tta_cod_proj_financ).

            run getApropriacoes in item(output apropriacoes).
            run populateApropriacoes.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateLancamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateLancamentos Procedure 
PROCEDURE populateLancamentos PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable counter as integer no-undo.
    
    do {&throws}:
        find last lancto_ctbl
            where lancto_ctbl.num_lote_ctbl = tt{&Lote}.tta_num_lote_ctbl
            no-lock no-error.
            
        if avail lancto_ctbl then
            assign
                counter = lancto_ctbl.num_lancto_ctbl.

        {system/foreach.i lancamento lancamentos}
            assign
                counter = counter + 1.

            create tt{&Lancamento}.
            assign
                tt{&Lancamento}.ttv_rec_integr_lancto_ctbl = recid(tt{&Lancamento})
                tt{&Lancamento}.ttv_rec_integr_lote_ctbl = recid(tt{&Lote})
                tt{&Lancamento}.tta_num_lancto_ctbl = counter.

            run getCenarioContabil      in lancamento(output tt{&Lancamento}.tta_cod_cenar_ctbl).
            run isLancamentoApuracao    in lancamento(output tt{&Lancamento}.tta_log_lancto_conver).
            run isLAncamentoConversao   in lancamento(output tt{&Lancamento}.tta_log_lancto_apurac_restdo).
            run getDataLancamento       in lancamento(output tt{&Lancamento}.tta_dat_lancto_ctbl).
            run getIndicaErro           in lancamento(output tt{&Lancamento}.ttv_ind_erro_valid).
            run getRateioContabil       in lancamento(output tt{&Lancamento}.tta_cod_rat_ctbl).

            run getItens in lancamento(output itens).
            run populateItens.
        end.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAtualizaLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAtualizaLote Procedure 
PROCEDURE setAtualizaLote :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter atualizaLote_ as logical    no-undo.

    do {&throws}:
        assign
            atualizaLote = atualizaLote_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataLote Procedure 
PROCEDURE setDataLote :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_dat_lote_ctbl_ as date no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_dat_lote_ctbl = tta_dat_lote_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDescricaoLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDescricaoLote Procedure 
PROCEDURE setDescricaoLote :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_des_lote_ctbl_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_des_lote_ctbl = tta_des_lote_ctbl_.
    end.

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
    define input  parameter tta_cod_empresa_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_empresa = tta_cod_empresa_.
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
            tt{&Lote}.ttv_ind_erro_valid = ttv_ind_erro_valid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setIntegracaoOnline) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setIntegracaoOnline Procedure 
PROCEDURE setIntegracaoOnline :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_log_integr_ctbl_online_ as logical no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_log_integr_ctbl_online = tta_log_integr_ctbl_online_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLoteContabil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLoteContabil Procedure 
PROCEDURE setLoteContabil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ttv_rec_integr_lote_ctbl_ as recid no-undo.

    do {&throws}:
        assign
            tt{&Lote}.ttv_rec_integr_lote_ctbl = ttv_rec_integr_lote_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setModuloDatasul) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setModuloDatasul Procedure 
PROCEDURE setModuloDatasul :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_modul_dtsul_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_modul_dtsul = tta_cod_modul_dtsul_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNumeroLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNumeroLote Procedure 
PROCEDURE setNumeroLote :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter tta_num_lote_ctbl_ as integer no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_num_lote_ctbl = tta_num_lote_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setOutputFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setOutputFile Procedure 
PROCEDURE setOutputFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter outputFile_ as character  no-undo.

    do {&throws}:
        assign
            outputFile = outputFile_.
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
            'system/TempTableCollection.p':u, output lancamentos).

        run createInstance in ghInstanceManager (this-procedure,
            'system/TempTableCollection.p':u, output itens).

        run createInstance in ghInstanceManager (this-procedure,
            'system/TempTableCollection.p':u, output apropriacoes).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate Procedure 
PROCEDURE validate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter validationType as character no-undo.

    define variable hasErrors as logical     no-undo.

    do {&throws}:

        /* fazer validacoes genericas aqui */

        case validationType:
            when 'insert' then
                run validateInsert.

            when 'update' then
                run validateUpdate.

            when 'delete' then
                run validateDelete.

            otherwise do:
                run createError(17006, substitute('validate.validationType inv†lido (&1)',
                    validationType)).
                return error.
            end.
        end case.

        run hasError(output hasErrors).
        if hasErrors then
            return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateInsert Procedure 
PROCEDURE validateInsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable found as logical   no-undo.

    do {&throws}:
        /* Faca aqui as validacoes para inclusao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        if can-find(first familia where familia.fm-codigo = ttFamilia.fm-codigo) then
            run createError(17006, substitute('Fam°lia de Materiais &1 j† cadastrada',
                ttFamilia.fm-codigo)).
        */

/*         run canFind(tt{&tableName}.<atributo>               */
/* ,                                                           */
/*                     output found).                          */
/*                                                             */
/*         if found then do:                                   */
/*             {utp/ut-table.i {&databaseName} {&tableName} 1} */
/*             run createError(1, return-value).               */
/*             return error.                                   */
/*         end.                                                */

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyErrors Procedure 
PROCEDURE verifyErrors :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable outputFile as character no-undo.
    define variable hasError as logical   no-undo.

    do {&throws}:
        run getOutputFile(output outputFile).

        for each tt{&ErroInsert}
            no-lock
            {&throws}:
            run insertError(tt{&ErroInsert}.ttv_num_mensagem, 
                substitute("Erro no &1", tt{&ErroInsert}.ttv_ind_pos_erro),
                'Verifique os erros no arquivo ' + session:temp-directory + outputFile).
        end.

        for each tt{&ErroCancel}
            no-lock
            {&throws}:
            run insertError(tt{&ErroCancel}.ttv_num_cod_erro, 
                tt{&ErroCancel}.ttv_des_msg_erro, tt{&ErroCancel}.ttv_des_msg_ajuda).
        end.

        run hasError(output hasError).
        if hasError then
            return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

