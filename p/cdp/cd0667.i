/************************************************************/
/***                                                      ***/
/*** DEFINI€ÇO DA TEMP-TABLE DE ERROS                     ***/
/***                                                      ***/
/************************************************************/

def temp-table tt-erro{1} no-undo
    field i-sequen  as int             
    field cd-erro   as int
    field mensagem  as char
    field parametro as char
    index ch-seq is primary
        i-sequen.
