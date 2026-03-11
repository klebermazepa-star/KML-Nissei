/*******************************************************************
**
**  CD0666.I - Definicao temp-table de erros
**
*******************************************************************/
def new global shared var l-multi as logical initial yes.

def var l-del-erros as logical init YES NO-UNDO.
def var v-nom-arquivo-cb as char format "x(50)" no-undo.
def var c-mensagem-cb    as char format "x(132)" no-undo.

def {1} temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".

/*Tratamento criado para que, em rotinas criticas nas quais esta include s¢ Ç chamada para definir a tt-erro, seja possivel
  fazer com que n∆o seja definida a frame nem seja chamado o tratamento de traduá∆o, pois isto degrada performance.*/
&if '{&excludeFrameDefinition}' = 'yes' &then 
&else
                                              
    form
        space(04)
        tt-erro.cd-erro 
        space (02)
        c-mensagem-cb
        with width 132 no-box down stream-io frame f-consiste.
    
    run utp/ut-trfrrp.p (input frame f-consiste:handle).
    
    {utp/ut-liter.i Mensagem}
    assign tt-erro.cd-erro:label in frame f-consiste = trim(return-value).
    
    {utp/ut-liter.i Descriá∆o}
    assign c-mensagem-cb:label in frame f-consiste = trim(return-value).

&endif
