define variable cDir as character  no-undo.

ASSIGN cDir = 'c:\datasul\temp\':u.

define temp-table ttProgDtsul no-undo
    like prog_dtsul.

define temp-table ttTabDicDtsul no-undo
    like tab_dic_dtsul.

do transaction on error undo, leave:

    /* sub-rotinas */
    if search(cDir + 'sub-rotinas-espec.txt') <> ? then do:
        input from value(cDir + 'sub-rotinas-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create sub_rot_dtsul.
            import sub_rot_dtsul.
        end.
        
        input close.
    END.


    /* programas */
    
    if search(cDir + 'programas-espec.txt') <> ? then do:
        input from value(cDir + 'programas-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create ttProgDtsul.
            import ttProgDtsul.
        end.

        input close.

        for each ttProgDtsul
            where ttProgDtsul.cod_prog_dtsul <> '':

            find prog_dtsul
                where prog_dtsul.cod_prog_dtsul = ttProgDtsul.cod_prog_dtsul
                exclusive-lock no-error.

            if not avail prog_dtsul then do:
                create prog_dtsul.
                buffer-copy ttProgDtsul to prog_dtsul.
            end.
            else
                assign
                    prog_dtsul.nom_prog_upc = ttProgDtsul.nom_prog_upc
                    prog_dtsul.log_reg_padr = false.
        end.
    end.
    
    /* seguranca programas */
    if search(cDir + 'prog-segur-espec.txt') <> ? then do:
        input from value(cDir + 'prog-segur-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create prog_dtsul_segur.
            import prog_dtsul_segur.
        end.
        
        input close.
    END.
    
    
    /* procedimetos */
    if search(cDir + 'procedimentos-espec.txt') <> ? then do:
        input from value(cDir + 'procedimentos-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create procedimento.
            import procedimento.
        end.
        
        input close.
    END.
    
    /* seguranca procedimentos */
    if search(cDir + 'proced-segur-espec.txt') <> ? then do:
        input from value(cDir + 'proced-segur-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create proced_segur.
            import proced_segur.
        end.
        
        input close.
    END.
    
    
    /* estrutura */
    if search(cDir + 'estrutura-espec.txt') <> ? then do:
        input from value(cDir + 'estrutura-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create modul_rot_proced.
            import modul_rot_proced.
        end.
        
        input close.
    END.
    
    
    /* estrutura - sub-rotinas */
    if search(cDir + 'estrutura-sub-espec.txt') <> ? then do:
        input from value(cDir + 'estrutura-sub-espec.txt') convert source 'iso8859-1'.
        
        repeat:
            create sub_rot_dtsul_proced.
            import sub_rot_dtsul_proced.
        end.
        
        input close.
    END.


    if search(cDir + 'tabelas-dic.txt') <> ? then do:
        /* tabelas dicionario */
        input from value(cDir + 'tabelas-dic.txt') convert source 'iso8859-1'.

        repeat:
            create ttTabDicDtsul.
            import ttTabDicDtsul.
        end.

        input close.

        for each ttTabDicDtsul
            where ttTabDicDtsul.cod_tab_dic_dtsul <> '':

            find tab_dic_dtsul of ttTabDicDtsul
                exclusive-lock no-error.

            if not avail tab_dic_dtsul then do:
                create tab_dic_dtsul.
                buffer-copy ttTabDicDtsul to tab_dic_dtsul.
            end.
            else
                assign
                    tab_dic_dtsul.nom_prog_upc_gat_delete = ttTabDicDtsul.nom_prog_upc_gat_delete
                    tab_dic_dtsul.nom_prog_upc_gat_write  = ttTabDicDtsul.nom_prog_upc_gat_write.
        end.

    end.
end.
