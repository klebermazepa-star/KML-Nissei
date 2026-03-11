
/* include de controle de versao */
{include/i-prgvrs.i INT155RP.P 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    FIELD it-codigo-ini         AS CHAR 
    FIELD it-codigo-fim         AS CHAR 
    FIELD cod-estabel-ini       AS CHAR 
    FIELD cod-estabel-fim       AS CHAR 
    .

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.
                                     
/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Recebimentro de Parametros */   
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

IF tt-param.it-codigo-fim   = "" THEN 
    ASSIGN tt-param.it-codigo-ini = ""
           tt-param.it-codigo-fim = "ZZZZZZZZZ".

IF tt-param.cod-estabel-fim = "" THEN 
    ASSIGN tt-param.cod-estabel-ini = ""
           tt-param.cod-estabel-fim = "ZZZZZZZZZ".

{include/i-rpvar.i}

def var h-acomp          as handle    no-undo.
def var i-aux            as int       no-undo.
def var c-linha          as char      no-undo.
def var c-fator          as char      no-undo.

find first param-global no-lock no-error.
assign c-programa 	  = 'INT155RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-empresa      = param-global.grupo
       c-sistema      = 'Pedidos'
       c-titulo-relat = 'Atualização preços'. 

{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).

DEF BUFFER bf-ext-item-uni-estab FOR ext-item-uni-estab.

FOR EACH ext-item-uni-estab NO-LOCK
    WHERE ext-item-uni-estab.log-atualizado = YES
    AND   ext-item-uni-estab.cod-estabel >= tt-param.cod-estabel-ini
    AND   ext-item-uni-estab.cod-estabel <= tt-param.cod-estabel-fim
    AND   ext-item-uni-estab.it-codigo   >= tt-param.it-codigo-ini
    AND   ext-item-uni-estab.it-codigo   <= tt-param.it-codigo-fim,
    EACH item-uni-estab NO-LOCK
    WHERE item-uni-estab.it-codigo   = ext-item-uni-estab.it-codigo  
    AND   item-uni-estab.cod-estabel = ext-item-uni-estab.cod-estabel:

    DO TRANS: 
        run pi-acompanhar in h-acomp (input "Atualizando Item: " + item-uni-estab.it-codigo + " Estab: " + item-uni-estab.cod-estabel ).
    
        FIND FIRST estabelec NO-LOCK
            WHERE  estabelec.cod-estabel = item-uni-estab.cod-estabel NO-ERROR.
    
        find FIRST int_dp_preco_item exclusive-lock where 
                   int_dp_preco_item.pri_cnpj_origem_s  = estabelec.cgc and
                   int_dp_preco_item.pri_produto_n      = int(item-uni-estab.it-codigo) no-error.   	  
    
        if avail int_dp_preco_item then do:	   
    
           assign int_dp_preco_item.ENVIO_STATUS       = 0
                  int_dp_preco_item.pri_cod_estabel_s  = estabelec.cod-estabel
                  int_dp_preco_item.pri_precobase_n    = item-uni-estab.preco-base
                  int_dp_preco_item.pri_precoentrada_n = item-uni-estab.preco-ul-ent
                  int_dp_preco_item.pri_database_d     = item-uni-estab.data-base
                  int_dp_preco_item.pri_dataentrada_d  = item-uni-estab.data-ult-ent.
           
            for first item-estab fields (val-unit-mat-m[1] mensal-ate) no-lock where 
                item-estab.cod-estabel = item-uni-estab.cod-estabel and
                item-estab.it-codigo   = item-uni-estab.it-codigo:
    
                assign  int_dp_preco_item.pri_precomedio_n = item-estab.val-unit-mat-m[1]
                        int_dp_preco_item.pri_datamedio_d  = item-estab.mensal-ate.
            end.
        
            assign  int_dp_preco_item.tipo_movto    = 1                       
                    int_dp_preco_item.dt_geracao    = today                   
                    int_dp_preco_item.hr_geracao    = string(time,"HH:MM:SS")
                    int_dp_preco_item.ENVIO_STATUS  = 1.
    
            RELEASE int_dp_preco_item.
    
            DISP "Atualizado Item: " + item-uni-estab.it-codigo + " Estab: " + item-uni-estab.cod-estabel.
    
        END.

        FOR FIRST bf-ext-item-uni-estab EXCLUSIVE-LOCK
            WHERE ROWID(bf-ext-item-uni-estab) = ROWID(ext-item-uni-estab):
            ASSIGN bf-ext-item-uni-estab.log-atualizado = NO.
        END.
    END.
END.

/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.


