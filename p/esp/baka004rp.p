

  
def temp-table tt-raw-digita
    field raw-digita as raw.
    
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.     
          
//def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.   
//def var raw-param          as raw no-undo. 

define temp-table tt-param-int142 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.
    
    
DEFINE VARIABLE cont AS INT NO-UNDO.

FOR EACH int_ds_nota_entrada NO-LOCK
    WHERE int_ds_nota_entrada.nen_datamovimentacao_d    >= 12/22/2025 
      AND int_ds_nota_entrada.nen_datamovimentacao_d    <= 12/29/2025 
      AND int_ds_nota_entrada.tipo_nota                 = 3
      AND int_Ds_nota_entrada.nen_conferida_n           = 0:
      
    EMPTY TEMP-TABLE tt-param-int142.
      
    FIND FIRST int_dp_nota_entrada_ret NO-LOCK
    WHERE int_dp_nota_entrada_ret.nen_cnpj_origem_s    = int_ds_nota_entrada.nen_cnpj_origem_s  
      AND int_dp_nota_entrada_ret.nen_notafiscal_n     = int_ds_nota_entrada.nen_notafiscal_n
      AND int_dp_nota_entrada_ret.nen_serie_s          = int_ds_nota_entrada.nen_serie_s NO-ERROR.
      
    IF NOT AVAIL int_dp_nota_entrada_ret THEN
    DO:
           
        CREATE int_dp_nota_entrada_ret.
        ASSIGN int_dp_nota_entrada_ret.tipo_movto           = 3
               int_dp_nota_entrada_ret.dt_geracao           = int_ds_nota_entrada.nen_datamovimentacao_d
               int_dp_nota_entrada_ret.situacao             = 1
               int_dp_nota_entrada_ret.nen_cnpj_origem_s    = int_ds_nota_entrada.nen_cnpj_origem_s  
               int_dp_nota_entrada_ret.nen_notafiscal_n     = int_ds_nota_entrada.nen_notafiscal_n
               int_dp_nota_entrada_ret.nen_serie_s          = int_ds_nota_entrada.nen_serie_s
               int_dp_nota_entrada_ret.nen_conferida_n      = 0
               int_dp_nota_entrada_ret.ID_SEQUENCIAL        = NEXT-VALUE(seq-int_dp_nota_entrada_ret).
               
    END.  
    
    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s  NO-ERROR.
        
        
    FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-emitente = emitente.cod-emitente
          AND docum-est.nro-docto   = STRING(int_ds_nota_entrada.nen_notafiscal_n, "9999999")
          AND docum-est.serie-docto = int_ds_nota_entrada.nen_serie_s NO-ERROR.
          
    IF NOT AVAIL docum-est THEN
    DO:
    
    
    //    IF cont >= 150 THEN NEXT.
    
        CREATE tt-param-int142.
        ASSIGN tt-param-int142.destino             = 2    
               tt-param-int142.arquivo             = "notas_16-12.txt"
               tt-param-int142.usuario             = "rpw"
               tt-param-int142.data-exec           = TODAY
               tt-param-int142.hora-exec           = TIME
               tt-param-int142.classifica          = 0
               tt-param-int142.desc-classifica     = ""
               tt-param-int142.cod-emitente-fim    = emitente.cod-emitente
               tt-param-int142.cod-emitente-ini    = emitente.cod-emitente
               tt-param-int142.cod-estabel-fim     = "ZZZ"
               tt-param-int142.cod-estabel-ini     = ""
               tt-param-int142.dt-emis-nota-fim    = 12/31/2025
               tt-param-int142.dt-emis-nota-ini    = 01/01/2025
               tt-param-int142.nro-docto-fim       = int_ds_nota_entrada.nen_notafiscal_n
               tt-param-int142.nro-docto-ini       = int_ds_nota_entrada.nen_notafiscal_n
               tt-param-int142.serie-docto-fim     = int_ds_nota_entrada.nen_serie_s
               tt-param-int142.serie-docto-ini     = int_ds_nota_entrada.nen_serie_s.
               
        raw-transfer tt-param-int142 to raw-param.       
               
               
        RUN intprg/int142rp-dezembro.r(INPUT raw-param, INPUT TABLE tt-raw-digita).
        
        ASSIGN cont = cont + 1.
    END.
END.


DISP cont.


/*



Table: int_ds_nota_entrada

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
tipo_movto                  inte       i   9
dt_geracao                  date           99/99/9999
hr_geracao                  char           x(8)
situacao                    inte       i   9
nen_cnpj_origem_s           char       i   x(14)
nen_cnpj_destino_s          char       i   x(14)
nen_notafiscal_n            inte       i   >>>,>>>,>>9
nen_serie_s                 char       i   x(3)
nen_dataemissao_d           date           99/99/9999
nen_cfop_n                  inte           >>>9
nen_quantidade_n            deci-2         >,>>>,>>9.99
nen_desconto_n              deci-5         >>>,>>>,>>>,>>9.99999
nen_baseicms_n              deci-5         >>>,>>>,>>>,>>9.99999
nen_valoricms_n             deci-5         >>>,>>>,>>>,>>9.99999
nen_basediferido_n          deci-5         >>>,>>>,>>>,>>9.99999
nen_baseisenta_n            deci-5         >>>,>>>,>>>,>>9.99999
nen_baseipi_n               deci-5         >>>,>>>,>>>,>>9.99999
nen_valoripi_n              deci-5         >>>,>>>,>>>,>>9.99999
nen_basest_n                deci-5         >>>,>>>,>>>,>>9.99999
nen_icmsst_n                deci-5         >>>,>>>,>>>,>>9.99999
nen_valortotalprodutos_n    deci-5         >>>,>>>,>>>,>>9.99999
nen_observacao_s            char           x(4000)
nen_chaveacesso_s           char           x(44)
nen_frete_n                 deci-5         >>>,>>>,>>9.99999
nen_seguro_n                deci-5         >>>,>>>,>>9.99999
nen_despesas_n              deci-5         >>>,>>>,>>9.99999
nen_modalidade_frete_n      inte           9
nen_conferida_n             inte       i   >9
ped_codigo_n                inte           >>>>>>>>9
nen_datamovimentacao_d      date       i   99/99/9999
nen_horamovimentacao_s      char           x(8)
tipo_nota                   inte       im  >9
ID_SEQUENCIAL               inte       i   >>>>>>>>>>>>>>9
ENVIO_STATUS                inte       i   99
ENVIO_DATA_HORA             datetm         99/99/9999 HH:MM:SS.SSS
ENVIO_ERRO                  char       i   x(1000)
ped_procfit                 inte       i   >>>>>>>>9
valor_fcp                   deci-5         >>,>>>,>>>,>>9.99999
valor_fcp_st                deci-5         >>,>>>,>>>,>>9.99999
valor_fcp_st_ret            deci-5         >>,>>>,>>>,>>9.99999
valor_ipi_devol             deci-5         >>,>>>,>>>,>>9.99999
tpag                        char           x(8)
vpag                        deci-5         >>,>>>,>>>,>>9.99999
vbc_cst_fcp                 deci-5         >>>>>,>>>,>>9.99999


*/
