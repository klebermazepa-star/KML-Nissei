/*******************************************************************************
**  Programa.: upc-mla0171.p	- UPC fixar parametros para MLA
**  
**  Descri‡Æo: deixar campos fixos para evitar erros operacionais
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.


DEFINE VARIABLE wh-selec-todos-1                     AS widget-handle NO-UNDO.
DEFINE VARIABLE wh-tg-chave-documento                AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-codigo-rejeicao                AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-programa-consulta              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-usuario-aprovacao              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-aprovacao                 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-aprovador-alternativo          AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-conf-visuais                   AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-layouts                        AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-seleciona-todos-com-emp        AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lotacao-aprovacao              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lotacao-usuario                AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-referencia                     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-limite-aprovacao-familia       AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-aprovacao-documento       AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-aprovacao-familia         AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-aprovacao-item            AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-aprovacao-referencia      AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-seleciona-todos-com-emp-estab  AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-parametro-aprovacao            AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-tipo-documento                 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-permissao-usuario              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-aprovador-padrao               AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-aprovador-faixa                AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-email-alternativo              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-faixa-aprovacao                AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-hierarquia-aprovador           AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lista-aprovador-documento      AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lista-aprovador-familia        AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lista-aprovador-item           AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-lista-aprovador-referencia     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-tg-simula                         AS WIDGET-HANDLE NO-UNDO.


/* MESSAGE p-ind-event              "p-ind-event  " skip  */
/*          p-ind-object             "p-ind-object " skip */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip */
/*          p-cod-table              "p-cod-table  " skip */
/*         string(p-row-table)      "p-row-table  " skip  */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                    */



IF p-ind-event  = "AFTER-INITIALIZE" AND  
   p-ind-object = "CONTAINER"          THEN DO:  


    RUN utils/findWidget.p (INPUT  'tg-seleciona-todos-sem-emp ',   
                        INPUT  'TOGGLE-BOX',       
                        INPUT  p-wgh-frame,    
                        OUTPUT wh-selec-todos-1).

    if valid-handle (wh-selec-todos-1) then
        ASSIGN wh-selec-todos-1:CHECKED = YES. 

    RUN utils/findWidget.p (INPUT  'tg-chave-documento',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-chave-documento).

    if valid-handle (wh-tg-chave-documento) then
        ASSIGN wh-tg-chave-documento:CHECKED = YES. 

    RUN utils/findWidget.p (INPUT  'tg-codigo-rejeicao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-codigo-rejeicao).

    if valid-handle (wh-tg-codigo-rejeicao) then
        ASSIGN wh-tg-codigo-rejeicao:CHECKED = YES. 

    RUN utils/findWidget.p (INPUT  'tg-programa-consulta',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-programa-consulta).
    
    if valid-handle (wh-tg-programa-consulta) then
        ASSIGN wh-tg-programa-consulta:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-usuario-aprovacao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-usuario-aprovacao).
    
    if valid-handle (wh-tg-usuario-aprovacao) then
        ASSIGN wh-tg-usuario-aprovacao:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-tipo-aprovacao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-aprovacao).
    
    if valid-handle (wh-tg-tipo-aprovacao) then
        ASSIGN wh-tg-tipo-aprovacao:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-aprovador-alternativo',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-aprovador-alternativo).
    
    if valid-handle (wh-tg-aprovador-alternativo) then
        ASSIGN wh-tg-aprovador-alternativo:CHECKED = YES. 

    RUN utils/findWidget.p (INPUT  'tg-conf-visuais',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-conf-visuais).
    
    if valid-handle (wh-tg-aprovador-alternativo) then
        ASSIGN wh-tg-conf-visuais:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-layouts',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-layouts).
    
    if valid-handle (wh-tg-layouts) then
        ASSIGN wh-tg-layouts:CHECKED = YES. 

    RUN utils/findWidget.p (INPUT  'tg-seleciona-todos-com-emp',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-seleciona-todos-com-emp).
    
    if valid-handle (wh-tg-seleciona-todos-com-emp) then
        ASSIGN wh-tg-seleciona-todos-com-emp:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-lotacao-aprovacao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lotacao-aprovacao).
    
    if valid-handle (wh-tg-lotacao-aprovacao) then
        ASSIGN wh-tg-lotacao-aprovacao:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-lotacao-usuario',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lotacao-usuario).
    
    if valid-handle (wh-tg-lotacao-usuario) then
        ASSIGN wh-tg-lotacao-usuario:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-referencia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-referencia).
    
    if valid-handle (wh-tg-referencia) then
        ASSIGN wh-tg-referencia:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-limite-aprovacao-familia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-limite-aprovacao-familia).
    
    if valid-handle (wh-tg-limite-aprovacao-familia) then
        ASSIGN wh-tg-limite-aprovacao-familia:CHECKED = YES.
    RUN utils/findWidget.p (INPUT  'tg-limite-aprovacao-familia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-limite-aprovacao-familia).
    
    if valid-handle (wh-tg-limite-aprovacao-familia) then
        ASSIGN wh-tg-limite-aprovacao-familia:CHECKED = YES.
    
    RUN utils/findWidget.p (INPUT  'tg-tipo-aprovacao-documento',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-aprovacao-documento).
    
    if valid-handle (wh-tg-tipo-aprovacao-documento) then
        ASSIGN wh-tg-tipo-aprovacao-documento:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-tipo-aprovacao-familia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-aprovacao-familia).
    
    if valid-handle (wh-tg-tipo-aprovacao-familia) then
        ASSIGN wh-tg-tipo-aprovacao-familia:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-tipo-aprovacao-item',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-aprovacao-item).
    
    if valid-handle (wh-tg-tipo-aprovacao-item) then
        ASSIGN wh-tg-tipo-aprovacao-item:CHECKED = YES.


    RUN utils/findWidget.p (INPUT  'tg-tipo-aprovacao-referencia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-aprovacao-referencia).
    
    if valid-handle (wh-tg-tipo-aprovacao-referencia) then
        ASSIGN wh-tg-tipo-aprovacao-referencia:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-seleciona-todos-com-emp-estab',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-seleciona-todos-com-emp-estab).
    
    if valid-handle (wh-tg-seleciona-todos-com-emp-estab) then
        ASSIGN wh-tg-seleciona-todos-com-emp-estab:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-parametro-aprovacao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-parametro-aprovacao).
    
    if valid-handle (wh-tg-parametro-aprovacao) then
        ASSIGN wh-tg-parametro-aprovacao:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-tipo-documento',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-tipo-documento).
    
    if valid-handle (wh-tg-tipo-documento) then
        ASSIGN wh-tg-tipo-documento:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-permissao-usuario',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-permissao-usuario).
    
    if valid-handle (wh-tg-permissao-usuario) then
        ASSIGN wh-tg-permissao-usuario:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-aprovador-padrao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-aprovador-padrao).
    
    if valid-handle (wh-tg-aprovador-padrao) then
        ASSIGN wh-tg-aprovador-padrao:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-aprovador-faixa',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-aprovador-faixa).
    
    if valid-handle (wh-tg-aprovador-faixa) then
        ASSIGN wh-tg-aprovador-faixa:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-email-alternativo',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-email-alternativo).
    
    if valid-handle (wh-tg-email-alternativo) then
        ASSIGN wh-tg-email-alternativo:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-faixa-aprovacao',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-faixa-aprovacao).
    
    if valid-handle (wh-tg-faixa-aprovacao) then
        ASSIGN wh-tg-faixa-aprovacao:CHECKED = YES.

     RUN utils/findWidget.p (INPUT  'tg-hierarquia-aprovador',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-hierarquia-aprovador).
    
    if valid-handle (wh-tg-hierarquia-aprovador) then
        ASSIGN wh-tg-hierarquia-aprovador:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-lista-aprovador-documento',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lista-aprovador-documento).
    
    if valid-handle (wh-tg-lista-aprovador-documento) then
        ASSIGN wh-tg-lista-aprovador-documento:CHECKED = YES.

     RUN utils/findWidget.p (INPUT  'tg-lista-aprovador-familia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lista-aprovador-familia).
    
    if valid-handle (wh-tg-lista-aprovador-familia) then
        ASSIGN wh-tg-lista-aprovador-familia:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-lista-aprovador-item',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lista-aprovador-item).
    
    if valid-handle (wh-tg-lista-aprovador-item) then
        ASSIGN wh-tg-lista-aprovador-item:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-lista-aprovador-referencia',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-lista-aprovador-referencia).
    
    if valid-handle (wh-tg-lista-aprovador-referencia) then
        ASSIGN wh-tg-lista-aprovador-referencia:CHECKED = YES.

    RUN utils/findWidget.p (INPUT  'tg-simula',   
                    INPUT  'TOGGLE-BOX',       
                    INPUT  p-wgh-frame,    
                    OUTPUT wh-tg-simula).
    
    if valid-handle (wh-tg-simula) then
        ASSIGN wh-tg-simula:CHECKED = NO.




END.


/*

---------------------------
Informacao
---------------------------
AFTER-INITIALIZE p-ind-event   
CONTAINER p-ind-object  
lap/mla0171.w p-wgh-object  
fpage0 p-wgh-frame   
'?' p-cod-table   
? p-row-table   
---------------------------
OK   
---------------------------


*/
