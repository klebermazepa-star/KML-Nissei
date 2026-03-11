define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente     as integer
    field cod-estabel      as CHAR
    field dt-emis-nota     as DATE
    field nro-docto        as INTEGER
    field serie-docto      as CHAR.

def temp-table tt-raw-digita
    field raw-digita as raw. 
    
    


//def input parameter raw-param as raw no-undo.
//def input parameter table for tt-raw-digita.

DEFINE BUFFER b2estabelec FOR estabelec.

DEFINE TEMP-TABLE tt-notas NO-UNDO
    FIELD serie     AS CHAR
    FIELD nota      AS CHAR
    FIELD estab     AS CHAR.
    
//INPUT FROM VALUE ("/mnt/shares/p/cjem8f/KML/KLEBER/Correcao_hub_transferencias/notas_todas.csv").    
//INPUT FROM VALUE ("\\10.0.1.3\cjem8f\KML\KLEBER\Correcao_hub_transferencias/notas_v2-2.csv").  
//INPUT FROM VALUE ("V:\downloads\notas_filiais.csv"). 


  /*
REPEAT :

    CREATE tt-notas.
    IMPORT DELIMITER ";"  tt-notas.
    
END.
   */

//OUTPUT TO VALUE ("/mnt/shares/p/cjem8f/KML/KLEBER/Correcao_hub_transferencias/log_notas_v2-3.txt").
//OUTPUT TO VALUE ("\\10.0.1.3\cjem8f\KML\KLEBER\Correcao_hub_transferencias/log_notas_v2-filiais.txt").

 CURRENT-LANGUAGE = CURRENT-LANGUAGE.

    FIND FIRST b2estabelec NO-LOCK
        WHERE b2estabelec.cod-estabel = "425" NO-ERROR.

    IF AVAIL b2estabelec THEN DO:
        
    
        FIND LAST int_ds_nota_entrada
            WHERE int_ds_nota_entrada.nen_notafiscal_n  = 5076           
              AND int_ds_nota_entrada.nen_serie_s       = "15"
              AND int_ds_nota_entrada.nen_cnpj_origem_s = b2estabelec.cgc NO-ERROR.
        IF AVAIL  int_ds_nota_entrada THEN
        DO:    
        
            RUN x:\kml\kleber\correcao_hub_transferencias/esp/baka002logica.p (INPUT ROWID(INT_DS_NOTA_ENTRADA)).
              
        END.          
    END.

