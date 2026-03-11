{cdp/cdcfgmat.i}
    
{esp/roboteasy/robotapi032.i}
{esp/roboteasy/robot_db032.i}

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}

{include/i-license-manager.i robotapi032 roboteasy}

FUNCTION fn_situacao RETURNS CHARACTER (INPUT c_ind_sit_ped_exec AS CHARACTER).

    IF  NOT CAN-DO("1,2,3",c_ind_sit_ped_exec) THEN 
    DO:
        /* n’o deve traduzir o conteœdo do browser 
        Run utp/ut-liter.p (input c_ind_sit_ped_exec,"*","").
        return Return-value.*/
        RETURN c_ind_sit_ped_exec.
    END.

    ELSE 
    DO:
        /* n’o deve traduzir o conteœdo do browser 
        Run utp/ut-liter.p (input {fninc/i01fn103.i 04 integer(c_ind_sit_ped_exec)},"*","").
        return Return-value.*/
        RETURN {fninc/i01fn103.i 04 integer(c_ind_sit_ped_exec)}.
    END.


END FUNCTION.

FUNCTION fn_motivo RETURNS CHARACTER (INPUT c_ind_motiv_sit_ped_exec AS CHARACTER).

    IF  NOT CAN-DO("11,12,13,14,21,22,31,32,33,34,35",c_ind_motiv_sit_ped_exec) THEN 
    DO:
        /* n’o deve traduzir o conteœdo do browser 
        Run utp/ut-liter.p (input c_ind_motiv_sit_ped_exec,"*","").
        return Return-value. */
        RETURN c_ind_motiv_sit_ped_exec.
    END.
    ELSE 
    DO:
        /* n’o deve traduzir o conteœdo do browser 
        Run utp/ut-liter.p (input {fninc/i02fn103.i 04 integer(c_ind_motiv_sit_ped_exec)},"*","").
        return Return-value. */
        RETURN {fninc/i02fn103.i 04 integer(c_ind_motiv_sit_ped_exec)}.
    END.


END FUNCTION.

/* Função interna para corrigir caminho e retornar formato válido */
FUNCTION fGetCaminhoValido RETURNS CHARACTER (INPUT pCaminho AS CHARACTER):
	DEF VAR cUNC   AS CHARACTER NO-UNDO.
	DEF VAR cDrive AS CHARACTER NO-UNDO.
	DEF VAR cLinha AS CHARACTER NO-UNDO.
	DEF VAR cTest  AS CHARACTER NO-UNDO.
	DEF VAR cLista AS CHARACTER EXTENT 5 NO-UNDO.
	DEF VAR i      AS INTEGER   NO-UNDO.

	/* Detecta se é unidade mapeada (X:, V:, etc.) */
	IF LENGTH(pCaminho) > 2 AND SUBSTRING(pCaminho, 2, 1) = ":" THEN DO:
		cDrive = SUBSTRING(pCaminho, 1, 2).

		/* Descobre UNC real com net use */
		INPUT THROUGH VALUE("cmd /c net use " + cDrive).
		REPEAT:
			IMPORT UNFORMATTED cLinha.
			IF INDEX(cLinha, "\\") > 0 THEN DO:
				cUNC = TRIM(SUBSTRING(cLinha, INDEX(cLinha, "\\"))).
				LEAVE.
			END.
		END.
		INPUT CLOSE.

		IF cUNC <> "" THEN
			pCaminho = cUNC + SUBSTRING(pCaminho, 3).
	END.

	/* Lista de formatos para testar */
	ASSIGN cLista[1] = pCaminho
		   cLista[2] = REPLACE(pCaminho, "\", "/")
		   cLista[3] = REPLACE(pCaminho, "/", "\")
		   cLista[4] = REPLACE(pCaminho, "/", "\\")
		   cLista[5] = REPLACE(pCaminho, "\", "\\").

	/* Testa e retorna o primeiro válido */
	DO i = 1 TO EXTENT(cLista):
		IF cLista[i] = "" THEN NEXT.
		FILE-INFO:FILE-NAME = cLista[i].
		IF FILE-INFO:FULL-PATHNAME <> ? THEN
			RETURN cLista[i].
	END.

	/* Se nenhum funcionou, retorna original */
	RETURN pCaminho.
END FUNCTION.

/******* PROCEDURES *******/

PROCEDURE pi-cria-pedido-rpw:
    DEF INPUT  PARAM TABLE FOR tt-cria-pedido.
    DEF INPUT  PARAM TABLE FOR tt-param-ce0403.
    DEF INPUT  PARAM TABLE FOR tt-param-ft0708.
    DEF INPUT  PARAM TABLE FOR tt-param-ft0709.
    DEF INPUT  PARAM TABLE FOR tt-param-of0410.
    DEF INPUT  PARAM TABLE FOR tt-param-of0520.
    DEF INPUT  PARAM TABLE FOR tt-param-of0620.
    DEF INPUT  PARAM TABLE FOR tt-param-of0770.
    DEF INPUT  PARAM TABLE FOR tt-param-re0530.
    DEF OUTPUT PARAM TABLE FOR tt-resultado-criacao.

    DEFINE VARIABLE v_num_aux LIKE ped_exec.num_ped_exec.
    DEFINE VARIABLE bRaw AS RAW NO-UNDO.

    DEFINE VARIABLE campo-hora   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-hora       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-minuto     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-segundo    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE tempo-futuro AS INTEGER   NO-UNDO.

    FOR EACH tt-cria-pedido:
        
        DO ON ERROR UNDO, LEAVE:

            /* Calcula hora, minuto e segundo a partir dos segundos desde meia-noite */
            ASSIGN v-hora     = INTEGER(TIME / 3600)
                   v-minuto   = INTEGER((TIME MOD 3600) / 60)
                   v-segundo  = TIME MOD 60
                   campo-hora = STRING(v-hora, "99") + STRING(v-minuto, "99") + STRING(v-segundo, "99").

            CREATE ped_exec.
    
            ASSIGN v_num_aux = NEXT-VALUE(seq_ped_exec). 
            REPEAT: 
                ASSIGN ped_exec.num_ped_exec = v_num_aux NO-ERROR. 
                IF (ped_exec.num_ped_exec = 0) THEN
                    ASSIGN v_num_aux = NEXT-VALUE(seq_ped_exec).
                ELSE  
                    LEAVE.
            END.

            ASSIGN ped_exec.cod_usuario            = tt-cria-pedido.cod_usuario
                   ped_exec.cod_empresa            = tt-cria-pedido.cod_empresa
                   ped_exec.cod_prog_dtsul         = tt-cria-pedido.cod_prog_dtsul
                   ped_exec.dat_criac_ped_exec     = tt-cria-pedido.dat_criac_ped_exec
                   ped_exec.hra_criac_ped_exec     = campo-hora
                   ped_exec.hra_exec_ped_exec      = tt-cria-pedido.hra_criac_ped_exec
                   ped_exec.dat_exec_ped_exec      = tt-cria-pedido.dat_criac_ped_exec
                   ped_exec.cod_servid_exec        = tt-cria-pedido.cod_servid_exec
                   ped_exec.cod_agrpdor            = tt-cria-pedido.cod_agrpdor
                   ped_exec.nom_prog_ext           = tt-cria-pedido.nom_prog_ext 
                   ped_exec.cdn_estil_dwb          = tt-cria-pedido.cdn_estil_dwb
                   ped_exec.ind_sit_ped_exec       = "1"  // nao executado 
                   ped_exec.ind_motiv_sit_ped_exec = "14" // enfileirado 
                   ped_exec.num_ped_exec_pai       = 0.
    
            IF TEMP-TABLE tt-param-ce0403:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-ce0403 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-ce0403 THEN
                    RAW-TRANSFER tt-param-ce0403 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-ft0708:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-ft0708 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-ft0708 THEN
                    RAW-TRANSFER tt-param-ft0708 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-ft0709:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-ft0709 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-ft0709 THEN
                    RAW-TRANSFER tt-param-ft0709 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-of0410:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-of0410 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-of0410 THEN
                    RAW-TRANSFER tt-param-of0410 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-of0520:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-of0520 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-of0520 THEN
                    RAW-TRANSFER tt-param-of0520 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-of0620:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-of0620 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-of0620 THEN
                    RAW-TRANSFER tt-param-of0620 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-of0770:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-of0770 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-of0770 THEN
                    RAW-TRANSFER tt-param-of0770 TO bRaw.
            END.
            ELSE IF TEMP-TABLE tt-param-re0530:HAS-RECORDS THEN DO:
                FIND FIRST tt-param-re0530 NO-LOCK NO-ERROR.
                IF AVAIL tt-param-re0530 THEN
                    RAW-TRANSFER tt-param-re0530 TO bRaw.
            END.

            CREATE ped_exec_param.
            ASSIGN ped_exec_param.num_ped_exec             = v_num_aux
                   ped_exec_param.cod_dwb_file             = tt-cria-pedido.nom_prog_ext
                   ped_exec_param.cod_dwb_output           = tt-cria-pedido.cod_dwb_output
                   ped_exec_param.nom_dwb_printer          = tt-cria-pedido.nom_dwb_printer         
                   ped_exec_param.log_dwb_print_parameters = tt-cria-pedido.log_dwb_print_parameters
                   ped_exec_param.cod_empresa              = FILL(tt-cria-pedido.cod_empresa + CHR(10), 3) //tt-cria-pedido.cod_empresa + chr(10) + tt-cria-pedido.cod_empresa + chr(10) + tt-cria-pedido.cod_empresa
                   ped_exec_param.cod_estab                = tt-cria-pedido.cod_estab               
                   ped_exec_param.cod_idiom_trad           = "POR"
                   ped_exec_param.cod_pais                 = "BRA"
                   ped_exec_param.cod_usuar_criptog        = ENCODE(tt-cria-pedido.cod_usuario)
                   ped_exec_param.cdn_pais_impto_usuar     = 1
                   ped_exec_param.cod_unid_negoc           = tt-cria-pedido.cod_unid_negoc         
                   ped_exec_param.cod_funcao_negoc_empres  = tt-cria-pedido.cod_funcao_negoc_empres
                   ped_exec_param.cod_plano_ccusto         = tt-cria-pedido.cod_plano_ccusto       
                   ped_exec_param.cod_ccusto               = tt-cria-pedido.cod_ccusto             
                   ped_exec_param.raw_param_ped_exec       = bRaw.
        END.

        CREATE tt-resultado-criacao.

        IF ERROR-STATUS:ERROR THEN
            ASSIGN tt-resultado-criacao.cod-status   = 101
                   tt-resultado-criacao.desc-retorno = ERROR-STATUS:GET-MESSAGE(1)
                   tt-resultado-criacao.num-pedido   = 0.
        ELSE
            ASSIGN tt-resultado-criacao.cod-status   = 200
                   tt-resultado-criacao.desc-retorno = "Pedido RPW criado com sucesso"
                   tt-resultado-criacao.num-pedido   = v_num_aux.
    END.

END PROCEDURE.

PROCEDURE pi-busca-pedido-rpw:
    DEF INPUT  PARAM TABLE FOR tt-consulta-pedido.
    DEF OUTPUT PARAM TABLE FOR tt-resultado-consulta.

    DEF VAR v_nom_dwb_file_printer_rpw AS CHARACTER NO-UNDO.
    DEF VAR c-dir-usuario AS CHAR NO-UNDO.

    FOR EACH tt-consulta-pedido:

        FIND FIRST ped_exec
             WHERE ped_exec.num_ped_exec = tt-consulta-pedido.num-ped-exec NO-LOCK NO-ERROR.

        IF AVAIL ped_exec THEN DO:
            CREATE tt-resultado-consulta.
            ASSIGN tt-resultado-consulta.cod-status         = 200
                   tt-resultado-consulta.desc-retorno       = "Sucesso"
                   tt-resultado-consulta.cod_usuario        = ped_exec.cod_usuario
                   tt-resultado-consulta.cod_prog_dtsul     = ped_exec.cod_prog_dtsul
                   tt-resultado-consulta.dat_criac_ped_exec = ped_exec.dat_criac_ped_exec
                   tt-resultado-consulta.hra_criac_ped_exec = ped_exec.hra_criac_ped_exec
                   tt-resultado-consulta.dat_exec_ped_exec  = ped_exec.dat_exec_ped_exec
                   tt-resultado-consulta.hra_exec_ped_exec  = ped_exec.hra_exec_ped_exec
                   tt-resultado-consulta.situacao           = fn_situacao(ped_exec.ind_sit_ped_exec)
                   tt-resultado-consulta.motivo-situacao    = fn_motivo(ped_exec.ind_motiv_sit_ped_exec)
	           tt-resultado-consulta.descricao-erro     = ped_exec.des_text_erro
                   tt-resultado-consulta.num_ped_exec       = ped_exec.num_ped_exec
                   tt-resultado-consulta.cod_servid_exec    = ped_exec.cod_servid_exec
                   tt-resultado-consulta.nom_prog_ext       = ped_exec.nom_prog_ext.

            FOR FIRST ped_exec_param NO-LOCK OF ped_exec:

                FIND usuar_mestre NO-LOCK WHERE usuar_mestre.cod_usuario = ped_exec.cod_usuario NO-ERROR.

                FIND servid_exec NO-LOCK WHERE servid_exec.cod_servid_exec = ped_exec.cod_servid_exec NO-ERROR.

                ASSIGN v_nom_dwb_file_printer_rpw = ped_exec_param.cod_dwb_file.
                        
                IF ped_exec.cdn_estil_dwb = 97 THEN DO:
                    IF TRIM(ENTRY(1,usuar_mestre.nom_subdir_spool_rpw)) <> "" THEN
                        ASSIGN v_nom_dwb_file_printer_rpw = servid_exec.nom_dir_spool + (IF SUBSTRING(servid_exec.nom_dir_spool,LENGTH(servid_exec.nom_dir_spool),1) <> "\" THEN "\" ELSE "") + usuar_mestre.nom_subdir_spool_rpw + '\' + ped_exec_param.nom_dwb_printer.
                    ELSE
                        ASSIGN v_nom_dwb_file_printer_rpw = servid_exec.nom_dir_spool + (IF SUBSTRING(servid_exec.nom_dir_spool,LENGTH(servid_exec.nom_dir_spool),1) <> "\" THEN "\" ELSE "") + ped_exec_param.nom_dwb_printer.
                END.

                ASSIGN tt-resultado-consulta.diretorio = v_nom_dwb_file_printer_rpw.
            END.

        END.
        ELSE DO:
            CREATE tt-resultado-consulta.
            ASSIGN tt-resultado-consulta.num_ped_exec       = tt-consulta-pedido.num-ped-exec
                   tt-resultado-consulta.cod-status         = 101
                   tt-resultado-consulta.desc-retorno       = "Pedido RPW nao encontrado".
        END.
    END.

END PROCEDURE.

PROCEDURE pi-move-relatorios-rpw:
    DEF INPUT  PARAM TABLE FOR tt-move-arquivo.
    DEF OUTPUT PARAM TABLE FOR tt-resultado-arquivo.

    DEF VAR lOK            AS LOGI NO-UNDO.
    DEF VAR arquivoOrigem  AS CHAR NO-UNDO.
    DEF VAR arquivoDestino AS CHAR NO-UNDO.

    /* Loop para mover todos */
    FOR EACH tt-move-arquivo:

        /* Corrige e normaliza caminhos antes de usar */
        ASSIGN arquivoOrigem  = fGetCaminhoValido(tt-move-arquivo.origem)
               arquivoDestino = fGetCaminhoValido(tt-move-arquivo.destino).

        /* Verifica se arquivo origem existe */
        FILE-INFO:FILE-NAME = arquivoOrigem.
        IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 102
                   tt-resultado-arquivo.desc-retorno = "Arquivo origem nao encontrado"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
            NEXT. /* próximo registro */
        END.

        /* Copia */
        COPY-LOB FROM FILE arquivoOrigem TO FILE arquivoDestino.

        /* Verifica se destino existe */
        FILE-INFO:FILE-NAME = arquivoDestino.
        lOK = FILE-INFO:FULL-PATHNAME <> ?.

        /* Se copiou, apaga origem */
        IF lOK THEN DO:
            OS-DELETE VALUE(arquivoOrigem).

            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 200
                   tt-resultado-arquivo.desc-retorno = "Arquivo movido com sucesso"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
        END.
        ELSE DO:
            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 101
                   tt-resultado-arquivo.desc-retorno = "Diretorio destino nao encontrado"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
        END.
    END.

END PROCEDURE.


/*PROCEDURE pi-move-relatorios-rpw:
    DEF INPUT  PARAM TABLE FOR tt-move-arquivo.
    DEF OUTPUT PARAM TABLE FOR tt-resultado-arquivo.

    DEF VAR lOK            AS LOGI NO-UNDO.
	DEF VAR arquivoOrigem  AS CHAR NO-UNDO.
	DEF VAR arquivoDestino AS CHAR NO-UNDO.
    
    /* Loop para mover todos */
    FOR EACH tt-move-arquivo:

		/* Normaliza caminhos antes de usar */
		ASSIGN arquivoOrigem  = REPLACE(tt-move-arquivo.origem,  "\", "/")
			   arquivoDestino = REPLACE(tt-move-arquivo.destino, "\", "/").

        /* Verifica se arquivo origem existe */
        FILE-INFO:FILE-NAME = arquivoOrigem.
        IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 102
                   tt-resultado-arquivo.desc-retorno = "Arquivo origem nao encontrado"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
            NEXT. /* pula para o pr¢ximo registro */
        END.

        /* Copia */
        COPY-LOB FROM FILE arquivoOrigem TO FILE arquivoDestino.
    
        /* Verifica se destino existe */

        FILE-INFO:FILE-NAME = arquivoDestino.
        lOK = FILE-INFO:FULL-PATHNAME <> ?.
    
        /* Se copiou, apaga */
        IF lOK THEN DO:
            OS-DELETE VALUE(arquivoOrigem).

            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 200
                   tt-resultado-arquivo.desc-retorno = "Arquivo movido com sucesso"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
        END.
        ELSE DO:
            CREATE tt-resultado-arquivo.
            ASSIGN tt-resultado-arquivo.cod-status   = 101
                   tt-resultado-arquivo.desc-retorno = "Diretorio destino nao encontrado"
                   tt-resultado-arquivo.num-ped-exec = tt-move-arquivo.num-ped-exec
                   tt-resultado-arquivo.origem       = arquivoOrigem
                   tt-resultado-arquivo.destino      = arquivoDestino.
        END.
    END.

END PROCEDURE.
*/