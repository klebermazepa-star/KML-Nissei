/********************************************************************************
**
**  Programa: int046.p - Atualizar a tabela int_ds_ean_item com os EANs gerados
**                       pelo Procfit para permitir a consulta no cd0204
**
********************************************************************************/                                                                

{intprg/int-rpw.i}  

define buffer bint_ds_ean_item for int_ds_ean_item.
        
FOR EACH int_ds_item_compl WHERE 
         int_ds_item_compl.envio_status = 1 USE-INDEX SEQUENCIAL
    /*BREAK BY int_ds_item_compl.cba-produto-n
          BY int_ds_item_compl.cba-ean-n 
          BY int_ds_item_compl.dt-geracao 
          BY int_ds_item_compl.hr-geracao 
          BY int_ds_item_compl.tipo_movto DESC*/ 
    BY int_ds_item_compl.id_sequencial QUERY-TUNING(NO-LOOKAHEAD):

    IF int_ds_item_compl.tipo_movto = 1
    OR int_ds_item_compl.tipo_movto = 2 THEN DO:
       FOR FIRST int_ds_ean_item WHERE
                 int_ds_ean_item.codigo_ean = int_ds_item_compl.cba_ean_n QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF NOT AVAIL int_ds_ean_item THEN DO:
          CREATE int_ds_ean_item.
          ASSIGN int_ds_ean_item.it_codigo  = STRING(int_ds_item_compl.cba_produto_n)         
                 int_ds_ean_item.codigo_ean = int_ds_item_compl.cba_ean_n.
       END.
       ASSIGN int_ds_ean_item.lote_multiplo  = int_ds_item_compl.cba_lotemultiplo_n   
              int_ds_ean_item.altura         = int_ds_item_compl.cba_altura_n         
              int_ds_ean_item.largura        = int_ds_item_compl.cba_largura_n        
              int_ds_ean_item.profundidade   = int_ds_item_compl.cba_profundidade_n   
              int_ds_ean_item.peso           = int_ds_item_compl.cba_peso_n           
              int_ds_ean_item.data_cadastro  = int_ds_item_compl.cba_data_cadastro_d  
              int_ds_ean_item.principal      = IF int_ds_item_compl.cba_principal_s = "S" THEN YES ELSE NO
              int_ds_item_compl.envio_status = 2.

       /* Se este for o EAN principal, desmarcar os demais EANïs do item - AVB 24/07/2018 */
       if int_ds_ean_item.principal then do:
           for each bint_ds_ean_item exclusive where
               bint_ds_ean_item.it_codigo   = int_ds_ean_item.it_codigo and
               bint_ds_ean_item.codigo_ean <> int_ds_ean_item.codigo_ean:
               assign bint_ds_ean_item.principal = no.
           end.
       end.

       IF int_ds_item_compl.cba_principal_s = "S" THEN DO:
          FOR FIRST ITEM WHERE
                    ITEM.it-codigo = trim(STRING(int_ds_item_compl.cba_produto_n)):
          END.
          IF AVAIL ITEM THEN DO:
             IF ITEM.fm-codigo < "500" THEN DO:
                ASSIGN OVERLAY(ITEM.char-1,133,16) = STRING(int_ds_item_compl.cba_ean_n,"9999999999999").
                RELEASE ITEM.
                FOR FIRST item-mat WHERE
                          item-mat.it-codigo = trim(STRING(int_ds_item_compl.cba_produto_n)):
                END.
                IF AVAIL item-mat THEN DO:
                   ASSIGN item-mat.cod-ean = STRING(int_ds_item_compl.cba_ean_n,"9999999999999").
                   RELEASE item-mat.
                END.
             END.
          END.
       END.

    END.

    IF int_ds_item_compl.tipo_movto = 3 THEN DO:
       FOR FIRST int_ds_ean_item WHERE
                 int_ds_ean_item.codigo_ean = int_ds_item_compl.cba_ean_n QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF AVAIL int_ds_ean_item THEN DO:
          DELETE int_ds_ean_item.
       END.
       FOR FIRST ITEM WHERE
                 ITEM.it-codigo = trim(STRING(int_ds_item_compl.cba_produto_n)):
       END.
       IF AVAIL ITEM THEN DO:
          IF ITEM.fm-codigo < "500" THEN DO:
             ASSIGN OVERLAY(ITEM.char-1,133,16) = "".
             RELEASE ITEM.
             FOR FIRST item-mat WHERE
                       item-mat.it-codigo = trim(STRING(int_ds_item_compl.cba_produto_n)):
             END.
             IF AVAIL item-mat THEN DO:
                ASSIGN item-mat.cod-ean = "".
                RELEASE item-mat.
             END.
          END.
       END.
       ASSIGN int_ds_item_compl.envio_status = 2.
    END.
    RELEASE int_ds_ean_item.
END.

RETURN "OK".
