/*****************************************************************************
**
** Include padrao com vari veis padroes do sistema
**
*****************************************************************************/


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
