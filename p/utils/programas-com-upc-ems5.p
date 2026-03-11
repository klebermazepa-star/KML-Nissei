
/* upcs de programas */
/* output to 'c:\temp\upcs-p.txt' convert target 'iso8859-1'. */

for each emsbas.prog_dtsul
    where emsbas.prog_dtsul.nom_prog_upc <> ''
    no-lock:

    disp emsbas.prog_dtsul.cod_prog_dtsul
         emsbas.prog_dtsul.des_prog_dtsul
         emsbas.prog_dtsul.cod_proced
         emsbas.prog_dtsul.nom_prog_ext
         emsbas.prog_dtsul.log_reg_padr
         emsbas.prog_dtsul.nom_prog_upc
         with stream-io width 300 no-box down frame f-relp.
end.

/* output close. */


/* upcs de triggers */
/* output to 'c:\temp\upcs-t.txt' convert target 'iso8859-1'. */

for each emsbas.tab_dic_dtsul
    no-lock:

    disp emsbas.tab_dic_dtsul.cod_tab_dic_dtsul
         emsbas.tab_dic_dtsul.des_tab_dic_dtsul
         emsbas.tab_dic_dtsul.nom_prog_upc_gat_delete
         emsbas.tab_dic_dtsul.nom_prog_upc_gat_write
         with stream-io width 300 no-box down frame f-relt.
end.

/* output close. */
