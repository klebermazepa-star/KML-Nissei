/****************************************************************************************************
**   Programa: trg-w-item-uni-estab.p - Trigger de write para a tabela item-uni-estab
*****************************************************************************************************/
 
DEF PARAM BUFFER b-item-uni-estab     FOR item-uni-estab.
DEF PARAM BUFFER b-old-item-uni-estab FOR item-uni-estab.

DEF BUFFER bf-item-uni-estab FOR item-uni-estab.
DEF BUFFER b-item FOR ITEM.

DEF VAR i-it-codigo AS INT64 NO-UNDO.

DEFINE VARIABLE l-not-alterado AS LOGICAL     NO-UNDO.
def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.


DEFINE VARIABLE i-cont AS INTEGER     NO-UNDO.

/* KML - Kleber Mazepa - 28/08/2025 - Avaliando se teve altera‡…o no pre‡o base e qual programa alterou */
IF b-item-uni-estab.preco-base <> b-old-item-uni-estab.preco-base THEN
DO:

    OUTPUT TO VALUE (SESSION:TEMP-DIRECTORY + "alteracao_item_uni_estab" + string(time) + ".txt").
    DO i-cont = 1 TO 10:                                                                                             
        IF  PROGRAM-NAME(i-cont) <> ? THEN                                                                                                         
            EXPORT DELIMITER ";"
                b-item-uni-estab.it-codigo
                b-item-uni-estab.cod-estabel
                b-old-item-uni-estab.preco-base
                b-item-uni-estab.preco-base
                PROGRAM-NAME(i-cont).                 
    END.       
    OUTPUT CLOSE.
END.


/* S¢ gera pendˆncia se os campos abaixo forem alterados. */
buffer-compare b-item-uni-estab to b-old-item-uni-estab 
    save l-not-alterado. 

if v_cdn_empres_usuar = "1" then do:
	if l-not-alterado = no then do:

		FOR FIRST ext-item-uni-estab EXCLUSIVE-LOCK
			WHERE ext-item-uni-estab.it-codigo   = b-item-uni-estab.it-codigo  
			AND   ext-item-uni-estab.cod-estabel = b-item-uni-estab.cod-estabel: END.
		IF NOT AVAIL ext-item-uni-estab THEN DO:
			CREATE ext-item-uni-estab.
			ASSIGN ext-item-uni-estab.it-codigo   = b-item-uni-estab.it-codigo  
				   ext-item-uni-estab.cod-estabel = b-item-uni-estab.cod-estabel.
		END.

		ASSIGN ext-item-uni-estab.log-atualizado = YES.


		FOR FIRST b-item NO-LOCK
			WHERE b-item.it-codigo = b-item-uni-estab.it-codigo:
		  //  RUN intprg/int090a.p (BUFFER b-item).
		END.
	end.

	FOR EACH bf-item-uni-estab WHERE
			 bf-item-uni-estab.it-codigo   = b-item-uni-estab.it-codigo AND      
			 bf-item-uni-estab.cod-estabel = b-item-uni-estab.cod-estabel NO-LOCK:
		IF b-item-uni-estab.preco-base = 0 THEN
		   ASSIGN b-item-uni-estab.preco-base = bf-item-uni-estab.preco-base.
		IF b-item-uni-estab.preco-ul-ent = 0 THEN
		   ASSIGN b-item-uni-estab.preco-ul-ent = bf-item-uni-estab.preco-ul-ent.
	END.


	/* Inicio SM 159 - Dep¢sito unico para Matriz/CD e Filial 23/01/2018 */
	IF  b-item-uni-estab.cod-estabel   = "973" AND
		b-item-uni-estab.deposito-pad <> "973"
	THEN
		ASSIGN b-item-uni-estab.deposito-pad = "973".
        
    IF  b-item-uni-estab.cod-estabel   = "977" AND
		b-item-uni-estab.deposito-pad <> "977"
	THEN
		ASSIGN b-item-uni-estab.deposito-pad = "977". 
       
	IF v_cdn_empres_usuar <> "10" THEN DO:
   
		IF  b-item-uni-estab.cod-estabel  <> "973" 
        AND b-item-uni-estab.cod-estabel  <> "977"
        AND	b-item-uni-estab.deposito-pad <> "LOJ" 
		
		THEN
			
			ASSIGN b-item-uni-estab.deposito-pad = "LOJ".

	/* Fim SM 159 - Dep¢sito unico para Matriz/CD e Filial 23/01/2018 */
		
	END.

	if  b-item-uni-estab.ind-item-fat and (
	   (b-item-uni-estab.preco-base     <> b-old-item-uni-estab.preco-base   or
		b-item-uni-estab.preco-ul-ent   <> b-old-item-uni-estab.preco-ul-ent or
		b-item-uni-estab.vl-mat-ant     <> b-old-item-uni-estab.vl-mat-ant)  or
		b-old-item-uni-estab.ind-item-fat = no)
	then do:
		assign i-it-codigo = ?.
		assign i-it-codigo = int64(b-item-uni-estab.it-codigo) no-error.
		if i-it-codigo <> ? then do:
			for first ems2mult.estabelec fields (cod-estabel cgc) no-lock where 
				estabelec.cod-estabel = b-item-uni-estab.cod-estabel,
				first cst_estabelec no-lock where 
					  cst_estabelec.cod_estabel = estabelec.cod-estabel AND 
					  cst_estabelec.dt_fim_operacao >= today:
				find FIRST int_dp_preco_item exclusive-lock where 
						   int_dp_preco_item.pri_cnpj_origem_s = estabelec.cgc and
						   int_dp_preco_item.pri_produto_n = i-it-codigo no-error.    
				if not avail int_dp_preco_item then do:
				   create int_dp_preco_item.
				   assign int_dp_preco_item.pri_cnpj_origem_s = estabelec.cgc
						  int_dp_preco_item.pri_produto_n     = i-it-codigo
						  int_dp_preco_item.ID_SEQUENCIAL     = NEXT-VALUE(seq-int-dp-preco-item)
						  int_dp_preco_item.ENVIO_STATUS      = 0.
				end.
			end.
			
			find FIRST int_dp_preco_item exclusive-lock where 
					   int_dp_preco_item.pri_cnpj_origem_s = ems2mult.estabelec.cgc and
					   int_dp_preco_item.pri_produto_n = i-it-codigo no-error.   			
			if avail int_dp_preco_item then do:			
			   assign int_dp_preco_item.ENVIO_STATUS       = 0
					  int_dp_preco_item.pri_cod_estabel_s  = estabelec.cod-estabel
					  int_dp_preco_item.pri_precobase_n    = b-item-uni-estab.preco-base
					  int_dp_preco_item.pri_precoentrada_n = b-item-uni-estab.preco-ul-ent
					  int_dp_preco_item.pri_database_d     = b-item-uni-estab.data-base
					  int_dp_preco_item.pri_dataentrada_d  = b-item-uni-estab.data-ult-ent.
			   
				for first item-estab fields (val-unit-mat-m[1] mensal-ate) no-lock where 
					item-estab.cod-estabel = b-item-uni-estab.cod-estabel and
					item-estab.it-codigo   = b-item-uni-estab.it-codigo:
					assign  int_dp_preco_item.pri_precomedio_n = item-estab.val-unit-mat-m[1]
							int_dp_preco_item.pri_datamedio_d  = item-estab.mensal-ate.
				end.
			
				assign  int_dp_preco_item.tipo_movto    = 1                       
						int_dp_preco_item.dt_geracao    = today                   
						int_dp_preco_item.hr_geracao    = string(time,"HH:MM:SS")
						int_dp_preco_item.ENVIO_STATUS  = 1.
			end.       
			release int_dp_preco_item.
		end.
	end.
end.

RETURN "OK".

