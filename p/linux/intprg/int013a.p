define input  parameter p-nen_cfop_n     like int_ds_cfop_natur_oper.nen_cfop_n no-undo.
define input  parameter p-nep_cstb_icm_n like int_ds_cfop_natur_oper.nep_cstb_icm_n no-undo.
define input  parameter p-nep_cstb_ipi_n like int_ds_cfop_natur_oper.nep_cstb_ipi_n no-undo.
define input  parameter p-cod-estabel    like int_ds_cfop_natur_oper.cod_estabel no-undo.
define input  parameter p-cod-emitente   like int_ds_cfop_natur_oper.cod_emitente no-undo.
define input  parameter p-dt-validade    like int_ds_cfop_natur_oper.dt_inicio_validade no-undo.
define output parameter p-nat-operacao   like int_ds_cfop_natur_oper.nat_operacao no-undo.

p-nat-operacao = "".
RUN pi-busca-natureza(input p-nen_cfop_n    ,
                      input p-nep_cstb_icm_n,
                      input p-nep_cstb_ipi_n,
                      input p-cod-estabel   ,
                      input p-cod-emitente  ,
                      input p-dt-validade 
                      ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,   
                          input ?               ,
                          input p-nep_cstb_ipi_n,
                          input p-cod-estabel   ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input ?               ,
                          input p-cod-estabel   ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input p-nep_cstb_ipi_n,
                          input ?               ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input p-nep_cstb_ipi_n,
                          input p-cod-estabel   ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?               ,
                          input ?               ,
                          input p-cod-estabel   ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?,
                          input p-nep_cstb_ipi_n,
                          input ?               ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input ?               ,
                          input ?               ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?,
                          input p-nep_cstb_ipi_n,
                          input p-cod-estabel   ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input ?               ,
                          input p-cod-estabel   ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input p-nep_cstb_ipi_n,
                          input ?               ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input p-cod-emitente  ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?               ,
                          input ?               ,
                          input p-cod-estabel   ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?               ,
                          input p-nep_cstb_ipi_n,
                          input ?               ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input p-nep_cstb_icm_n,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input p-dt-validade   
                          ).

if p-nat-operacao = "" then
    RUN pi-busca-natureza(input p-nen_cfop_n    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input p-dt-validade
                          ).

procedure pi-busca-natureza:
    define input  parameter p-nen_cfop_n     like int_ds_cfop_natur_oper.nen_cfop_n no-undo.
    define input  parameter p-nep_cstb_icm_n like int_ds_cfop_natur_oper.nep_cstb_icm_n no-undo.
    define input  parameter p-nep_cstb_ipi_n like int_ds_cfop_natur_oper.nep_cstb_ipi_n no-undo.
    define input  parameter p-cod-estabel    like int_ds_cfop_natur_oper.cod_estabel no-undo.   /* Kleber Mazepa 07-07-2018 - Estava invertido os parametros de cod-estabel e cod-emitente */
	define input  parameter p-cod-emitente   like int_ds_cfop_natur_oper.cod_emitente no-undo.    
    define input  parameter p-dt-validade    like int_ds_cfop_natur_oper.dt_inicio_validade no-undo.
    for last int_ds_cfop_natur_oper no-lock where 
        int_ds_cfop_natur_oper.nen_cfop_n          = p-nen_cfop_n     and
        int_ds_cfop_natur_oper.nep_cstb_icm_n      = p-nep_cstb_icm_n and
        int_ds_cfop_natur_oper.nep_cstb_ipi_n      = p-nep_cstb_ipi_n and
        int_ds_cfop_natur_oper.cod_emitente        = p-cod-emitente   and
        int_ds_cfop_natur_oper.cod_estabel         = p-cod-estabel    and
        int_ds_cfop_natur_oper.dt_inicio_validade <= p-dt-validade:
        p-nat-operacao = int_ds_cfop_natur_oper.nat_operacao.
    end.
end.
