DEFINE BUFFER portador FOR ems5.portador.

define temp-table ttPortador no-undo 
    field cod-portador          like portador.cod_portador    column-label 'Portador'
    field cod-cart-bcia         like cart_bcia.cod_cart_bcia  column-label 'Modal'
    field vl-maximo             like tit_ap.val_sdo_tit_ap    column-label 'Vl Maximo'
    field cod-forma-pagto-mesmo as character                  column-label 'Pag Mesmo'
    field cod-forma-pagto-outro as character                  column-label 'Pag Outro'
    field classificacao         as integer                    column-label 'Classifica'
    field qt-titulo             as integer                    column-label 'Qtde'
    field vl-destinado          like tit_ap.val_sdo_tit_ap    column-label "Vl Dest".  

define temp-table ttTitulo no-undo 
    field cod-portador    like portador.cod_portador
    field cod-cart-bcia   like cart_bcia.cod_cart_bcia
    field cod_estab       like tit_ap.cod_estab      
    field cdn_fornecedor  like tit_ap.cdn_fornecedor 
    field cod_espec_docto like tit_ap.cod_espec_docto
    field cod_ser_docto   like tit_ap.cod_ser_docto  
    field cod_tit_ap      like tit_ap.cod_tit_ap     
    field cod_parcela     like tit_ap.cod_parcela 
    field cod_portador    like tit_ap.cod_portador 
    field dat_vencto_tit_ap like tit_ap.dat_vencto_tit_ap
    field dat_transacao   like tit_ap.dat_transacao
    field valorPagamento  like tit_ap.val_sdo_tit_ap
    field re-tit-ap       as recid
    index pk_portador cod-portador
                      cod-cart-bcia
    index ie_titulo   cod_estab          
                      cdn_fornecedor 
                      cod_espec_docto
                      cod_ser_docto  
                      cod_tit_ap     
                      cod_parcela    
    index ie_recid    re-tit-ap.

define temp-table ttExcecao no-undo
    like ttTitulo
    index ie_fornecedor cdn_fornecedor.

/******** variaveis para impressao ********/
DEFINE VARIABLE v_num_ped_exec_rpw as integer no-undo. /* nÆo deve ser alterada */
DEFINE VARIABLE c-impressora       as char    no-undo. /* deve ser atualizada com o nome da impressora selecionada */
DEFINE VARIABLE c-layout           as char    no-undo. /* deve ser atualizada com o layout da impressao selecionada */ 
DEFINE VARIABLE v_cod_programa     AS CHARACTER  NO-UNDO. /* deve ser atualizada com o nome do programa corrente */
DEFINE VARIABLE v_cod_parameters   AS CHARACTER  NO-UNDO. /* ‚ carragada com os parametros separados com chr(10) */
DEFINE VARIABLE v_log_dwb_param    AS LOGICAL  NO-UNDO.  /* imprime ou nao parametros */
DEFINE VARIABLE v_cod_dwb_file     AS CHARACTER  NO-UNDO. /* nome do arquivo de impressao */
DEFINE VARIABLE v_cod_dwb_output   AS CHARACTER  NO-UNDO. /* destino da impressao */

/******** variaveis globais ********/
DEF new global shared var v_cod_estab_usuar  as char  format "x(03)" no-undo.
def new global shared var v_cod_usuar_corren as char  no-undo.
def new global shared var v_num_ped_exec_corren as integer format ">>>>>9" no-undo.
def new global shared var v_cod_dwb_user     as char no-undo. /* usuario corrente */
def new global shared VAR v_cod_empres_usuar AS CHAR NO-UNDO.

def new shared var v_rpt_s_1_lines as integer initial 66.
def new shared var v_rpt_s_1_columns as integer initial 132.
def new shared var v_rpt_s_1_bottom as integer initial 66.
