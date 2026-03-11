
/* upcs de programas */
output to 'c:\datasul\temp\upcs-p.txt' convert target 'iso8859-1'.

for each prog_dtsul
    where prog_dtsul.nom_prog_upc <> ''
    no-lock:

    disp prog_dtsul.cod_prog_dtsul
         prog_dtsul.des_prog_dtsul
         prog_dtsul.cod_proced
         prog_dtsul.nom_prog_ext
         prog_dtsul.log_reg_padr
         prog_dtsul.nom_prog_upc
         with stream-io width 300 no-box down frame f-relp.
end.

output close.


/* upcs de triggers */
output to 'c:\datasul\temp\upcs-t.txt' convert target 'iso8859-1'.

for each tab_dic_dtsul
    no-lock:

    disp tab_dic_dtsul.cod_tab_dic_dtsul
         tab_dic_dtsul.des_tab_dic_dtsul
         tab_dic_dtsul.nom_prog_upc_gat_delete
         tab_dic_dtsul.nom_prog_upc_gat_write
         with stream-io width 300 no-box down frame f-relt.
end.

output close.
