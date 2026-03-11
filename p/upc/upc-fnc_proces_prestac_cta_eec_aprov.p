define input param p-ind-event  as character     no-undo.
define input param p-ind-object as character     no-undo.
define input param p-wgh-object as handle        no-undo.
define input param p-wgh-frame  as widget-handle no-undo.
define input param p-cod-table  as character     no-undo.
define input param p-row-table  as recid         no-undo.

def var v_nom_pessoa
    as character
    format "x(40)":U
    label "Nome"
    column-label "Nome"
    no-undo.


def buffer b_func_financ_mod
    for func_financ.
def buffer b_func_unid_aprovac_eec
    for func_unid_aprovac_eec.
def buffer b_hosped_eec_bgc
    for hosped_eec.
def buffer b_func_financ_add
    for func_financ.
def buffer b_pessoa_fisic
    for pessoa_fisic.

/* define variable codPortador     as widget-handle no-undo.         */
/* define variable fcod_portador   as widget-handle no-undo.         */
/* define variable btZoomPortador  as widget-handle no-undo.         */
/* define variable fbtZoomPortador as widget-handle no-undo.         */
/*                                                                   */
/* DEFINE VARIABLE h_log_bord_ap_escrit    AS WIDGET-HANDLE NO-UNDO. */
/* DEFINE VARIABLE h_log_bord_ap_desc_dist AS WIDGET-HANDLE NO-UNDO. */
/*                                                                   */
DEFINE BUFFER b_proces_prestac_cta_eec FOR proces_prestac_cta_eec.                              

def temp-table tt_proces_prestac_cta_eec no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_func_financ              as Integer format ">>>>>>>9" initial 0 label "Funcionÿrio" column-label "Funcionÿrio"
    field tta_cdn_prestac_cta              as Integer format ">>>,>>9" initial 0 label "Processo" column-label "Processo"
    field tta_ind_sit_proces               as character format "X(25)" initial "Digita»’o Adto" label "Situa»’o Processo" column-label "Situa»’o Processo"
    field ttv_rec_proces_prestac_cta_eec   as recid format ">>>>>>9" initial ?
    field ttv_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_cdn_func_financ              ascending
          tta_cdn_prestac_cta              ascending
    index tt_ind                           is unique
          tta_cod_estab                    ascending
          tta_cdn_func_financ              ascending
          tta_cdn_prestac_cta              ascending
          tta_ind_sit_proces               ascending
    .

/* message ' p-ind-event   '  p-ind-event     skip */
/*         ' p-ind-object  '  p-ind-object    skip */
/*         ' p-wgh-object  '  p-wgh-object    skip */
/*         ' p-wgh-frame   '  p-wgh-frame     skip */
/*         ' p-cod-table   '  p-cod-table     skip */
/*         ' p-row-table   '  p-row-table     skip */
/*         ' transaction() '  transaction .        */        


IF  p-ind-event =  "reprov_proces"  THEN DO:

    RUN utp/ut-msgs.p (INPUT "show",
                       INPUT 27100,
                       INPUT "Deseja eliminar o processo definitivamente?~~ Caso deseje que o processo nÆo retorne para Digita‡Æo," +
                             " clique no botÆo SIM. Essa elimina‡Æo nÆo ter  como ser estornada. Deseja mesmo eliminar o processo definitivamente?").
    IF RETURN-VALUE = "YES" THEN DO:

        EMPTY TEMP-TABLE tt_proces_prestac_cta_eec.

        FIND FIRST b_proces_prestac_cta_eec EXCLUSIVE-LOCK
             WHERE RECID(b_proces_prestac_cta_eec) = p-row-table NO-ERROR.
        IF AVAIL b_proces_prestac_cta_eec THEN DO:
            DISABLE TRIGGERS FOR LOAD OF b_proces_prestac_cta_eec.
            DELETE b_proces_prestac_cta_eec.
/*                                                                                                                          */
/*             RUN pi_proces_prestac_cta_eec_aprovador (INPUT "1",                                                          */
/*                                                      INPUT b_proces_prestac_cta_eec.cod_estab,                           */
/*                                                      INPUT b_proces_prestac_cta_eec.cdn_func_financ,                     */
/*                                                      OUTPUT v_nom_pessoa) /*pi_proces_prestac_cta_eec_aprovador*/.       */
/*                                                                                                                          */
/*             CREATE tt_proces_prestac_cta_eec.                                                                            */
/*             ASSIGN tt_proces_prestac_cta_eec.tta_cod_estab                  = b_proces_prestac_cta_eec.cod_estab         */
/*                    tt_proces_prestac_cta_eec.tta_cdn_func_financ            = b_proces_prestac_cta_eec.cdn_func_financ   */
/*                    tt_proces_prestac_cta_eec.tta_cdn_prestac_cta            = b_proces_prestac_cta_eec.cdn_prestac_cta   */
/*                    tt_proces_prestac_cta_eec.tta_ind_sit_proces             = b_proces_prestac_cta_eec.ind_sit_proces    */
/*                    tt_proces_prestac_cta_eec.ttv_rec_proces_prestac_cta_eec = recid(b_proces_prestac_cta_eec)            */
/*                    tt_proces_prestac_cta_eec.ttv_nom_pessoa                 = v_nom_pessoa.                              */
/*                                                                                                                          */
/*                                                                                                                          */
/*             RUN prgfin/eec/eec700ga.p (INPUT-OUTPUT TABLE tt_proces_prestac_cta_eec) /*prg_era_proces_prestac_cta_eec*/. */
        END.
        RELEASE b_proces_prestac_cta_eec.
    END.
END.

/*****************************************************************************
** Procedure Interna.....: pi_proces_prestac_cta_eec_aprovador
** Descricao.............: pi_proces_prestac_cta_eec_aprovador
** Criado por............: Souza
** Criado em.............: 20/11/1998 11:42:51
** Alterado por..........: Souza
** Alterado em...........: 06/07/1999 15:42:54
*****************************************************************************/
PROCEDURE pi_proces_prestac_cta_eec_aprovador:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cdn_func_financ
        as Integer
        format ">>>>>>>9"
        no-undo.
    def output param p_nom_pessoa
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find b_func_financ_mod no-lock
        where b_func_financ_mod.cod_estab = p_cod_estab
        and   b_func_financ_mod.cdn_func_financ = p_cdn_func_financ no-error.
    estrut_block:
    for each func_unid_aprovac_eec no-lock
        where func_unid_aprovac_eec.cod_empresa = p_cod_empresa
        and   func_unid_aprovac_eec.cod_estab_func_financ = p_cod_estab
        and   func_unid_aprovac_eec.cdn_func_financ = p_cdn_func_financ:
        find unid_aprovac_eec no-lock use-index undprvcc_id
            where unid_aprovac_eec.cod_empresa = func_unid_aprovac_eec.cod_empresa
            and   unid_aprovac_eec.cod_estab = func_unid_aprovac_eec.cod_estab
            and   unid_aprovac_eec.cod_plano_aprovac_eec = func_unid_aprovac_eec.cod_plano_aprovac_eec
            and   unid_aprovac_eec.cod_unid_aprovac = func_unid_aprovac_eec.cod_unid_aprovac no-error.
        if avail unid_aprovac_eec then do:
            if  unid_aprovac_eec.cod_estab_func_financ = b_func_financ_mod.cod_estab
            and unid_aprovac_eec.cdn_func_respons_eec  = b_func_financ_mod.cdn_func_financ then do:
                find first estrut_unid_aprov no-lock
                    where estrut_unid_aprov.cod_empresa = unid_aprovac_eec.cod_empresa
                    and   estrut_unid_aprov.cod_estab = unid_aprovac_eec.cod_estab
                    and   estrut_unid_aprov.cod_plano_aprovac_eec = unid_aprovac_eec.cod_plano_aprovac_eec
                    and   estrut_unid_aprov.cod_unid_aprovac_filho = unid_aprovac_eec.cod_unid_aprovac no-error.
                if avail estrut_unid_aprov
                and estrut_unid_aprov.cod_unid_aprovac_pai <> "" then do:
                    find unid_aprovac_eec no-lock
                        where unid_aprovac_eec.cod_empresa = estrut_unid_aprov.cod_empresa
                        and   unid_aprovac_eec.cod_estab = estrut_unid_aprov.cod_estab
                        and   unid_aprovac_eec.cod_plano_aprovac_eec = estrut_unid_aprov.cod_plano_aprovac_eec
                        and   unid_aprovac_eec.cod_unid_aprovac = estrut_unid_aprov.cod_unid_aprovac_pai no-error.
                    if avail unid_aprovac_eec then do:
                        find b_func_financ_add no-lock
                            where b_func_financ_add.cod_estab = unid_aprovac_eec.cod_estab_func_financ
                            and   b_func_financ_add.cdn_func_financ = unid_aprovac_eec.cdn_func_respons_eec no-error.
                        if avail b_func_financ_add then do:
                            find b_pessoa_fisic no-lock
                                where b_pessoa_fisic.num_pessoa_fisic = b_func_financ_add.num_pessoa_fisic no-error.
                            if avail b_pessoa_fisic then
                                assign p_nom_pessoa = b_pessoa_fisic.nom_pessoa.
                        end.
                    end.
                    leave estrut_block.
                end.
                else do:
                    find b_pessoa_fisic no-lock
                        where b_pessoa_fisic.num_pessoa_fisic = b_func_financ_mod.num_pessoa_fisic no-error.
                    if avail b_pessoa_fisic then
                        assign p_nom_pessoa = b_pessoa_fisic.nom_pessoa.
                    leave estrut_block.
                end.
            end.
            else do:
                find b_func_financ_add no-lock
                    where b_func_financ_add.cod_estab = unid_aprovac_eec.cod_estab_func_financ
                    and   b_func_financ_add.cdn_func_financ = unid_aprovac_eec.cdn_func_respons_eec no-error.
                if avail b_func_financ_add then do:
                    find b_pessoa_fisic no-lock
                        where b_pessoa_fisic.num_pessoa_fisic = b_func_financ_add.num_pessoa_fisic no-error.
                    if avail b_pessoa_fisic then
                        assign p_nom_pessoa = b_pessoa_fisic.nom_pessoa.
                end.
                leave estrut_block.
            end.
        end.
    end.
END PROCEDURE. /* pi_proces_prestac_cta_eec_aprovador */

/* IF p-ind-event  = "INITIALIZE" THEN DO:                                                                         */
/*                                                                                                                 */
/*     run utils\findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).                      */
/*     if valid-handle(fcod_portador) then return.                                                                 */
/*                                                                                                                 */
/*     run utils\findWidget.p('cod_portador', 'fill-in', p-wgh-frame, output codPortador).                         */
/*     if valid-handle(codPortador) then do:                                                                       */
/*         create fill-in fcod_portador                                                                            */
/*             assign                                                                                              */
/*                 frame       = codPortador:frame                                                                 */
/*                 width       = codPortador:width                                                                 */
/*                 height      = codPortador:height                                                                */
/*                 row         = codPortador:row                                                                   */
/*                 col         = codPortador:col                                                                   */
/*                 bgcolor     = codPortador:bgcolor                                                               */
/*                 sensitive   = true                                                                              */
/*                 visible     = true                                                                              */
/*                 name        = 'fcod_portador'                                                                   */
/*                 tooltip     = codPortador:tooltip                                                               */
/*                 help        = codPortador:help                                                                  */
/*                 triggers:                                                                                       */
/*                   on leave persistent run upc/upc-add_bord_ap-evt.p(p-wgh-frame).                               */
/*                   on entry persistent run upc/upc-add_bord_ap-evt2.p(p-wgh-frame).                              */
/*                 end triggers.                                                                                   */
/*                                                                                                                 */
/*             fcod_portador:move-after-tab-item (codPortador).                                                    */
/*             codPortador:tab-stop = no.                                                                          */
/*             codPortador:visible = no.                                                                           */
/*             codPortador:sensitive = no.                                                                         */
/*                                                                                                                 */
/*                                                                                                                 */
/*     end.                                                                                                        */
/*                                                                                                                 */
/*     run utils\findWidget.p('bt_zoo_64301', 'button', p-wgh-frame, output btZoomPortador).                       */
/*     if valid-handle(btZoomPortador) then do:                                                                    */
/*         create button fbtZoomPortador                                                                           */
/*             assign                                                                                              */
/*                 frame       = btZoomPortador:frame                                                              */
/*                 width       = btZoomPortador:width                                                              */
/*                 height      = btZoomPortador:height                                                             */
/*                 row         = btZoomPortador:row                                                                */
/*                 col         = btZoomPortador:col                                                                */
/*                 sensitive   = true                                                                              */
/*                 visible     = true                                                                              */
/*                 name        = 'fbt_zoo_64301'                                                                   */
/*                 tooltip     = btZoomPortador:tooltip                                                            */
/*                 help        = btZoomPortador:help                                                               */
/*                 triggers:                                                                                       */
/*                   on choose persistent run upc/upc-add_bord_ap-evt3.p(p-wgh-frame).                             */
/*                 end triggers.                                                                                   */
/*                                                                                                                 */
/*             fbtZoomPortador:move-after-tab-item (btZoomPortador).                                               */
/*             btZoomPortador:tab-stop = no.                                                                       */
/*             fbtZoomPortador:load-image(btZoomPortador:image).                                                   */
/*             btZoomPortador:sensitive = no.                                                                      */
/*             btZoomPortador:visible = no.                                                                        */
/*                                                                                                                 */
/*     end.                                                                                                        */
/*                                                                                                                 */
/*     /* INICIO - SM de Parametro para Desconto Distribuidora */                                                  */
/*     run utils\findWidget.p('log_bord_ap_escrit', 'TOGGLE-BOX', p-wgh-frame, output h_log_bord_ap_escrit).       */
/*     IF     VALID-HANDLE(h_log_bord_ap_escrit)    AND                                                            */
/*        NOT VALID-HANDLE(h_log_bord_ap_desc_dist) THEN DO:                                                       */
/*                                                                                                                 */
/*         CREATE TOGGLE-BOX h_log_bord_ap_desc_dist                                                               */
/*             assign                                                                                              */
/*                 frame       = h_log_bord_ap_escrit:FRAME                                                        */
/*                 width       = h_log_bord_ap_escrit:WIDTH + 10                                                   */
/*                 height      = h_log_bord_ap_escrit:HEIGHT                                                       */
/*                 row         = h_log_bord_ap_escrit:ROW                                                          */
/*                 col         = h_log_bord_ap_escrit:COL + 20                                                     */
/* /*                 bgcolor     = h_log_bord_ap_escrit:bgcolor */                                                */
/*                 sensitive   = true                                                                              */
/*                 visible     = true                                                                              */
/*                 name        = 'log_bord_ap_desc_dist'                                                           */
/*                 LABEL       = "Desconto Financ. Distribuidora"                                                  */
/*                 tooltip     = ""                                                                                */
/*                 help        = "Desconto Financ. Distribuidora"                                                  */
/*                 .                                                                                               */
/*                                                                                                                 */
/*             h_log_bord_ap_desc_dist:move-after-tab-item (h_log_bord_ap_escrit).                                 */
/*     END.                                                                                                        */
/*     /* FIM    - SM de Parametro para Desconto Distribuidora */                                                  */
/*                                                                                                                 */
/* end.                                                                                                            */
/*                                                                                                                 */
/* if p-ind-event = 'ENABLE' then do:                                                                              */
/*     run utils/findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).                      */
/*     if valid-handle(fcod_portador) then                                                                         */
/*         assign fcod_portador:screen-value = ''.                                                                 */
/* end.                                                                                                            */
/*                                                                                                                 */
/* IF p-ind-event = 'ASSIGN' THEN DO:                                                                              */
/*                                                                                                                 */
/*     RUN utils/findWidget.p('log_bord_ap_desc_dist', 'TOGGLE-BOX', p-wgh-frame, OUTPUT h_log_bord_ap_desc_dist). */
/*     IF VALID-HANDLE(h_log_bord_ap_desc_dist) THEN DO:                                                           */
/*                                                                                                                 */
/*         FIND FIRST b_bord_ap NO-LOCK                                                                            */
/*              WHERE RECID(b_bord_ap) = p-row-table NO-ERROR.                                                     */
/*         IF AVAIL b_bord_ap THEN DO:                                                                             */
/*             ASSIGN b_bord_ap.log_livre_2 = h_log_bord_ap_desc_dist:CHECKED.                                     */
/*         END.                                                                                                    */
/*     END.                                                                                                        */
/* END.                                                                                                            */
/*                                                                                                                 */
/*                                                                                                                 */
/**/
RETURN "OK":U .
