/*

utils/i-rpout5.i

Define o output de saida para ems5

Utiliza a tt-param

tt-param.destino = 1, 2 ou 3
tt-param.arquivo = arquivo ou Impressora:Layout
tt-param.usuario

*/

case tt-param.destino:
    when 3 /* terminal */  then do:
        output to value(tt-param.arquivo)
            paged page-size 64 convert target 'iso8859-1'.
    end.

    when 2 /*l_file*/  then do:
        output to value(tt-param.arquivo)
               paged page-size 64 convert target 'iso8859-1'.
    end.

    when 1 /*l_printer*/  then do:
        def var c-temp-layout-impr as char no-undo.
        assign
            c-temp-layout-impr = entry(2, tt-param.arquivo, ':')
            tt-param.arquivo = entry(1, tt-param.arquivo, ':').

        find emsbas.imprsor_usuar no-lock
            where emsbas.imprsor_usuar.nom_impressora = tt-param.arquivo
            and  emsbas.imprsor_usuar.cod_usuario     = tt-param.usuario
            use-index imprsrsr_id no-error.
            
        find first emsbas.layout_impres no-lock
            where emsbas.layout_impres.nom_impressora    = tt-param.arquivo
            and   emsbas.layout_impres.cod_layout_impres = c-temp-layout-impr
            no-error.

        if opsys = "UNIX" then do:
            output through value(imprsor_usuar.nom_disposit_so)
                paged page-size value(emsbas.layout_impres.num_lin_pag)
                convert target 'iso8859-1'.
        end.
        else
            output to value(imprsor_usuar.nom_disposit_so)
                paged page-size value(emsbas.layout_impres.num_lin_pag)
                convert target 'iso8859-1'.

        for each emsbas.configur_layout_impres no-lock
            where emsbas.configur_layout_impres.num_id_layout_impres = emsbas.layout_impres.num_id_layout_impres
            by emsbas.configur_layout_impres.num_ord_funcao_imprsor:
        
            find emsbas.configur_tip_imprsor no-lock
                where emsbas.configur_tip_imprsor.cod_tip_imprsor        = layout_impres.cod_tip_imprsor
                and   emsbas.configur_tip_imprsor.cod_funcao_imprsor     = configur_layout_impres.cod_funcao_imprsor
                and   emsbas.configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
                no-error.

            put control configur_tip_imprsor.cod_comando_configur.

        end.

    end.
end.
