/************************************************************************************
**   Programa: trg-d-ped-venda.p - Trigger de delete para a tabela ped-venda
**             Eliminar a tabela int-ds-ped-venda
**   Data....: Dezembro/2015
************************************************************************************/

DEF PARAM BUFFER b-ped-venda FOR ped-venda.

FOR EACH cst_ped_venda where cst_ped_venda.nr_pedido = b-ped-venda.nr-pedido:
    for each cst_ped_item exclusive-lock of cst_ped_venda:
        delete cst_ped_item.
    end.
    delete cst_ped_venda.
END.
for first int_ds_pedido where
    int_ds_pedido.ped_codigo_n = int(b-ped-venda.nr-pedcli):
    assign int_ds_pedido.situacao = 1.
end.
RETURN "OK".
