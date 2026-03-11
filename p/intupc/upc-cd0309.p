/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i UPC-CD0309 2.12.00.001} /*** 010002 ***/
/****************************************************************************
** Programa: upc-cd0309.p
*****************************************************************************/

/************ definicao de parametros ***********************/
def input param p-ind-event           as char          no-undo.
def input param p-ind-object          as char          no-undo.
def input param p-wgh-object          as handle        no-undo.
def input param p-wgh-frame           as widget-handle no-undo.
def input param p-cod-table           as char          no-undo.
def input param p-row-table           as rowid         no-undo.

/*************** definicao variaveis globais *************************/
DEF NEW GLOBAL SHARED VAR wh-ct-desconto-ced0309   AS WIDGET-HANDLE NO-UNDO.
def new global shared var wh-ct-desc-cartao        as widget-handle no-undo.
def new global shared var wh-ct-desc-cartao-label  as widget-handle no-undo.
def new global shared var wh-frame                 as widget-handle no-undo.
                                                                       
def new global shared var i-ep-codigo-usuario  like ems2mult.empresa.ep-codigo no-undo.

/************* definicao variaveis locais *****************/

def var wh-fill    as widget-handle               no-undo.
          
def var c-objeto    as char                        no-undo.

if valid-handle(p-wgh-object) then
    assign c-objeto  = entry(num-entries(p-wgh-object:file-name, "~/"), p-wgh-object:file-name, "~/").

IF VALID-HANDLE(wh-ct-desc-cartao-label)THEN
   ASSIGN wh-ct-desc-cartao-label:SCREEN-VALUE  = "Desconto Cart∆o:".

if p-ind-event  = "ENABLE" and
   p-ind-object = "VIEWER" and
   c-objeto = "v04di022.w" then do:

   ASSIGN wh-ct-desc-cartao:sensitive          = YES
         wh-ct-desc-cartao-label:SCREEN-VALUE  = "Desconto Cart∆o:".

end.

if p-ind-event = "DISABLE" and
   p-ind-object = "VIEWER" and
   c-objeto = "v04di022.w" then 
   assign wh-ct-desc-cartao:SENSITIVE  = no. 

if  p-ind-event  = "BEFORE-DISPLAY"
    and p-ind-object = "VIEWER"
    and c-objeto     = "v04di022.w" 
then do:
    
    IF VALID-HANDLE(wh-ct-desc-cartao) THEN
      APPLY "leave" TO  wh-ct-desc-cartao.

    FOR FIRST conta-ft WHERE 
        rowid(conta-ft) = p-row-table NO-LOCK:

        FIND FIRST int_ds_conta_ft 
             where int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel  
             and   int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
             and   int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
             and   int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
             and   int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
             and   int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
             and   int_ds_conta_ft.serie            = conta-ft.serie        
             and   int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
             and   int_ds_conta_ft.it_codigo        = conta-ft.it-codigo    no-lock no-error.
        if avail int_ds_conta_ft then do:
            if valid-handle(wh-ct-desc-cartao) then
               assign wh-ct-desc-cartao:screen-value = string(int_ds_conta_ft.ct_desc_cartao).
        end.
        ELSE DO:
            if valid-handle(wh-ct-desc-cartao) then
               assign wh-ct-desc-cartao:screen-value = "".
        END. 

    end.    
end.

if  p-ind-event  = "INITIALIZE" and 
    p-ind-object = "VIEWER"     and 
    c-objeto     = "v04di022.w" then do:

   ASSIGN wh-fill  = p-wgh-frame:FIRST-CHILD
          wh-fill  = wh-fill:FIRST-CHILD.

   DO WHILE VALID-HANDLE(wh-fill):

        IF wh-fill:NAME = "cod-cta-desc" THEN /* trocar para  na nissei  ct-despesa*/
           ASSIGN wh-ct-desconto-ced0309 = wh-fill.

        ASSIGN wh-fill = wh-fill:NEXT-SIBLING.
   END.

    if p-wgh-frame:name = "f-main" then do:
       assign wh-frame = p-wgh-frame.

       create text wh-ct-desc-cartao-label
       assign frame              = p-wgh-frame
              format             = "x(19)"
              width              = 19.00
              height             = 0.88
              screen-value       = "Desconto Cart∆o: "
              row                =  wh-ct-desconto-ced0309:ROW + 1
              col                =  wh-ct-desconto-ced0309:COL - 13
              visible            = yes
              sensitive          = no.

       create fill-in wh-ct-desc-cartao
       assign frame              = p-wgh-frame
              Side-label-handle  = wh-ct-desc-cartao-label
              Data-type          = "CHARACTER"
              width              =  wh-ct-desconto-ced0309:WIDTH
              format             = "x(20)"
              height             = wh-ct-desconto-ced0309:HEIGHT
              row                = wh-ct-desconto-ced0309:ROW + 1
              col                = wh-ct-desconto-ced0309:COL
              visible            = yes
              sensitive          = no.

       wh-ct-desc-cartao:MOVE-AFTER-TAB-ITEM(wh-ct-desconto-ced0309).
       wh-ct-desc-cartao:LOAD-MOUSE-POINTER ("IMAGE~\lupa.cur").

       ON LEAVE OF wh-ct-desc-cartao PERSISTENT RUN intupc/upc-cd0309-a.p(INPUT "LEAVE").
       ON ENTRY OF wh-ct-desc-cartao PERSISTENT RUN intupc/upc-cd0309-a.p(INPUT "ENTRY").
       ON F5    OF wh-ct-desc-cartao PERSISTENT RUN intupc/upc-cd0309-a.p(INPUT "F5").
       ON MOUSE-SELECT-DBLCLICK OF wh-ct-desc-cartao PERSISTENT RUN intupc/upc-cd0309-a.p(INPUT "F5"). 

    end.

    FOR FIRST conta-ft
        WHERE rowid(conta-ft) = p-row-table NO-LOCK:
        /*
        find int_ds_conta_ft 
             where int_ds_conta_ft.cod-estabel        = conta-ft.cod-estabel  
             and   int_ds_conta_ft.cod-gr-cli         = conta-ft.cod-gr-cli  
             and   int_ds_conta_ft.cod-canal-venda    = conta-ft.cod-canal-venda
             and   int_ds_conta_ft.ge-codigo          = conta-ft.ge-codigo    
             and   int_ds_conta_ft.fm-codigo          = conta-ft.fm-codigo    
             and   int_ds_conta_ft.nat-operacao       = conta-ft.nat-operacao 
             and   int_ds_conta_ft.serie              = conta-ft.serie        
             and   int_ds_conta_ft.cod-depos          = conta-ft.cod-depos    
             and   int_ds_conta_ft.it-codigo          = conta-ft.it-codigo        no-lock no-error.
        if avail int_ds_conta_ft then do:
           if valid-handle(wh-ct-desc-cartao) then
              assign wh-ct-desc-cartao:screen-value = string(int_ds_conta_ft.ct-desc-cartao).
        end. */
    end.    
end.
if  p-ind-object = "VIEWER"     AND  
    p-ind-event  = "VALIDATE"   AND  
    c-objeto     = "v04di022.w" THEN  
DO:
    /*CD150300.01050*/
    IF VALID-HANDLE(wh-ct-desc-cartao) THEN 
    DO:
        ASSIGN wh-ct-desc-cartao:FORMAT = "x(17)".

        FIND FIRST cta_ctbl NO-LOCK 
             WHERE cta_ctbl.cod_plano_cta_ctbl  = "PADRAO" AND  
                   cta_ctbl.cod_cta_ctbl = wh-ct-desc-cartao:SCREEN-VALUE NO-ERROR.
        IF NOT AVAIL cta_ctbl THEN 
        DO:
            RUN utp/ut-msgs.p (INPUT "show",
                               INPUT 17006,
                               INPUT "Conta Cont†bil Deb Desconto Cart∆o n∆o existe: " + wh-ct-desc-cartao:SCREEN-VALUE + "~~" +
                                     "Conta Cont†bil Deb Desconto Cart∆o n∆o existe: " + wh-ct-desc-cartao:SCREEN-VALUE).

            APPLY "ENTRY" TO wh-ct-desc-cartao.
            
            RETURN "NOK".
        END.
       
    END.
END.

IF  p-ind-event = "ADD"     and 
    p-ind-object = "VIEWER" and 
    c-objeto     = "v04di022.w" THEN 
DO:
    ASSIGN wh-ct-desc-cartao-label:SCREEN-VALUE  = "Desconto Cart∆o:".
 
    FOR FIRST conta-ft
        WHERE rowid(conta-ft) = p-row-table NO-LOCK:
        FIND FIRST int_ds_conta_ft 
             where int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel  
             and   int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
             and   int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
             and   int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
             and   int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
             and   int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
             and   int_ds_conta_ft.serie            = conta-ft.serie        
             and   int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
             and   int_ds_conta_ft.it_codigo        = conta-ft.it-codigo   exclusive-lock no-error.
        IF   not avail int_ds_conta_ft then 
        DO:
             create int_ds_conta_ft.
             assign int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel      
                    int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
                    int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
                    int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
                    int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
                    int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
                    int_ds_conta_ft.serie            = conta-ft.serie        
                    int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
                    int_ds_conta_ft.it_codigo        = conta-ft.it-codigo
                    int_ds_conta_ft.ct_desc_cartao   = string(wh-ct-desc-cartao:SCREEN-VALUE,"x(17)").
        END. 
    END. /* FOR FIRST conta-ft */
END. /* IF  p-ind-event = "ADD"     and  */

if  p-ind-event = "end-update"  and 
    p-ind-object = "VIEWER"     and 
    c-objeto     = "v04di022.w" then do:
    
    FOR FIRST conta-ft NO-LOCK  
        WHERE rowid(conta-ft) = p-row-table:
        FIND FIRST int_ds_conta_ft 
             where int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel  
             and   int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
             and   int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
             and   int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
             and   int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
             and   int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
             and   int_ds_conta_ft.serie            = conta-ft.serie        
             and   int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
             and   int_ds_conta_ft.it_codigo        = conta-ft.it-codigo   exclusive-lock no-error.
        
        ASSIGN wh-ct-desc-cartao:FORMAT = "x(17)".

        if not avail int_ds_conta_ft then do:
             create int_ds_conta_ft.
             assign int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel      
                    int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
                    int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
                    int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
                    int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
                    int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
                    int_ds_conta_ft.serie            = conta-ft.serie        
                    int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
                    int_ds_conta_ft.it_codigo        = conta-ft.it-codigo
                    int_ds_conta_ft.ct_desc_cartao   = wh-ct-desc-cartao:SCREEN-VALUE.
        end. 
        ELSE 
            ASSIGN int_ds_conta_ft.ct_desc_cartao    = wh-ct-desc-cartao:SCREEN-VALUE.
          
    END.
END.

IF  p-ind-event = "delete"  and 
    p-ind-object = "VIEWER" and 
    c-objeto     = "v01di022.w" then 
DO:
    
    FOR FIRST conta-ft
        WHERE rowid(conta-ft) = p-row-table NO-LOCK:
         
        FOR FIRST int_ds_conta_ft EXCLUSIVE-LOCK   
            where int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel  
            and   int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli  
            and   int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda
            and   int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo    
            and   int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo    
            and   int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao 
            and   int_ds_conta_ft.serie            = conta-ft.serie        
            and   int_ds_conta_ft.cod_depos        = conta-ft.cod-depos    
            and   int_ds_conta_ft.it_codigo        = conta-ft.it-codigo:
             delete int_ds_conta_ft.
        END.  /* FOR FIRST int_ds_conta_ft EXCLUSIVE-LOCK    */         

    END. /* FOR FIRST conta-ft */
END. /* if  p-ind-event = "delete"  and  */


