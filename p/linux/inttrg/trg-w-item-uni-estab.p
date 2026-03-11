/****************************************************************************************************
**   Programa: trg-w-item-uni-estab.p - Trigger de write para a tabela item-uni-estab
*****************************************************************************************************/
 
DEF PARAM BUFFER b-item-uni-estab     FOR item-uni-estab.
DEF PARAM BUFFER b-old-item-uni-estab FOR item-uni-estab.

DEF BUFFER bf-item-uni-estab FOR item-uni-estab.

DEF VAR i-it-codigo AS INT64 NO-UNDO.

FOR EACH bf-item-uni-estab WHERE
         bf-item-uni-estab.it-codigo   = b-item-uni-estab.it-codigo AND      
         bf-item-uni-estab.cod-estabel = "973" NO-LOCK:
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

IF  b-item-uni-estab.cod-estabel  <> "973" AND
    b-item-uni-estab.deposito-pad <> "LOJ"
THEN
    ASSIGN b-item-uni-estab.deposito-pad = "LOJ".
/* Fim SM 159 - Dep¢sito unico para Matriz/CD e Filial 23/01/2018 */

if  b-item-uni-estab.ind-item-fat and (
   (b-item-uni-estab.preco-base     <> b-old-item-uni-estab.preco-base   or
    b-item-uni-estab.preco-ul-ent   <> b-old-item-uni-estab.preco-ul-ent or
    b-item-uni-estab.vl-mat-ant     <> b-old-item-uni-estab.vl-mat-ant)  or
    b-old-item-uni-estab.ind-item-fat = no)
then do:
    assign i-it-codigo = ?.
    assign i-it-codigo = int64(b-item-uni-estab.it-codigo) no-error.
    if i-it-codigo <> ? then do:
        for first estabelec fields (cod-estabel cgc) no-lock where 
            estabelec.cod-estabel = b-item-uni-estab.cod-estabel,
            first cst_estabelec no-lock where 
                  cst_estabelec.cod_estabel = estabelec.cod-estabel AND 
                  cst_estabelec.dt_fim_operacao >= today:
            find int_dp_preco_item exclusive-lock where 
                int_dp_preco_item.pri_cnpj_origem_s = estabelec.cgc and
                int_dp_preco_item.pri_produto_n = i-it-codigo no-error.    
            if not avail int_dp_preco_item then do:
                create  int_dp_preco_item.
                assign  int_dp_preco_item.pri_cnpj_origem_s = estabelec.cgc
                        int_dp_preco_item.pri_produto_n     = i-it-codigo
                        int_dp_preco_item.ID_SEQUENCIAL     = ?.
            end.
        end.
		
		find int_dp_preco_item exclusive-lock where 
			int_dp_preco_item.pri_cnpj_origem_s = estabelec.cgc and
			int_dp_preco_item.pri_produto_n = i-it-codigo no-error.   
			
		if avail int_dp_preco_item then do:	
		
			assign  int_dp_preco_item.pri_cod_estabel_s  = estabelec.cod-estabel.
			assign  int_dp_preco_item.pri_precobase_n    = b-item-uni-estab.preco-base
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


RETURN "OK".

