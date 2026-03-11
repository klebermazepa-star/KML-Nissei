

  
def temp-table tt-raw-digita
    field raw-digita as raw.
    
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.     



define temp-table tt-param-ft2100
    field destino           as integer 
    field arquivo           as char
    field usuario           as char
    field data-exec         as date
    field hora-exec         as integer
    field tipo-atual        as integer   /* 1 - Atualiza, 2 - Desatualiza */
    field c-desc-tipo-atual as char format "x(15)"
    field da-emissao-ini    as date format "99/99/9999"
    field da-emissao-fim    as date format "99/99/9999"
    field da-saida          as date format "99/99/9999"
    field da-vencto-ipi     as date format "99/99/9999"
    field da-vencto-icms    as date format "99/99/9999"
    field da-vencto-iss     as date format "99/99/9999"
    field c-estabel-ini     as char
    field c-estabel-fim     as char
    field c-serie-ini       as char
    field c-serie-fim       as char
    field c-nr-nota-ini     as char
    field c-nr-nota-fim     as char
    field de-embarque-ini   as dec
    field de-embarque-fim   as dec
    field c-preparador      as char
    field l-disp-men        as log
    field l-b2b             as log
    field log-1             as log.
    
    
    
    
    
DEFINE TEMP-TABLE tt-notas NO-UNDO
    FIELD estab     AS CHAR
    FIELD nota      AS INT
    FIELD serie     AS CHAR.
    
              
INPUT FROM VALUE ("/mnt/shares/p/cjem8f/KML/KLEBER/itens_excluir.csv").
    
REPEAT:

    CREATE tt-notas.
    IMPORT DELIMITER ";" tt-notas.
END.
    
    
    
DEFINE BUFFER b-estabelec FOR ems2mult.estabelec.    

DEF VAR cont-total AS INT.
DEF VAR cont-processadas AS INT.
DEF VAR cont-deucerto AS INT.

DEF VAR cont2 AS INT.



OUTPUT TO VALUE ("/mnt/shares/p/cjem8f/KML/KLEBER/itens_ft2100_desatualizado.csv").

FOR EACH tt-notas:


    EXPORT DELIMITER ";" tt-notas.

   // ASSIGN cont-total = cont-total + 1.
    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = "977"  NO-ERROR.
        
        
    FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-emitente    = estabelec.cod-emitente
          AND docum-est.nro-docto       = STRING(tt-notas.nota, "9999999")
          AND docum-est.serie-docto     = tt-notas.serie NO-ERROR.
          
    IF AVAIL docum-est THEN DO:

              
        ASSIGN cont-processadas = cont-processadas + 1.  
        
        IF docum-est.CE-atual = YES
            then do:
            ASSIGN cont-deucerto = cont-deucerto + 1.
        END.
    //  DISP dt-trans.
      
    END.   
    ELSE DO:
    
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.cod-estabel   = "977"
              AND nota-fiscal.serie         = tt-notas.serie
              AND nota-fiscal.nr-nota-fis   = STRING(tt-notas.nota, "9999999") NO-ERROR.
        IF AVAIL nota-fiscal THEN
        DO:
        
            EXPORT DELIMITER ";" "excluido".
            empty temp-table tt-param-ft2100.

            create  tt-param-FT2100.
            assign  tt-param-FT2100.usuario           = "rpw"
                    tt-param-FT2100.destino           = 2
                    tt-param-FT2100.tipo-atual        = 2  /* 1 - Atualiza | 2 - Desatualiza*/
                    tt-param-FT2100.c-desc-tipo-atual = ""
                    tt-param-FT2100.da-emissao-ini    = nota-fiscal.dt-emis-nota
                    tt-param-FT2100.da-emissao-fim    = nota-fiscal.dt-emis-nota
                    tt-param-FT2100.da-saida          = nota-fiscal.dt-emis-nota
                    tt-param-FT2100.da-vencto-ipi     = today 
                    tt-param-FT2100.da-vencto-icms    = today 
                    tt-param-FT2100.c-estabel-ini     = nota-fiscal.cod-estabel
                    tt-param-FT2100.c-estabel-fim     = nota-fiscal.cod-estabel
                    tt-param-FT2100.c-serie-ini       = nota-fiscal.serie
                    tt-param-FT2100.c-serie-fim       = nota-fiscal.serie
                    tt-param-FT2100.c-nr-nota-ini     = nota-fiscal.nr-nota-fis
                    tt-param-FT2100.c-nr-nota-fim     = nota-fiscal.nr-nota-fis
                    tt-param-FT2100.de-embarque-ini   = 0
                    tt-param-FT2100.de-embarque-fim   = 99999999
                    tt-param-FT2100.c-preparador      = ""
                    tt-param-FT2100.arquivo           = nota-fiscal.cod-estabel +   
                                                        nota-fiscal.serie       +   
                                                        nota-fiscal.nr-nota-fis + "-ft2100-1.tmp"
                    tt-param-FT2100.l-disp-men        = no.

            raw-transfer tt-param-FT2100 to raw-param.
            run ftp/ft2100rp.p (input raw-param,
                                input table tt-raw-digita).
                                
          
            
        END.
    
    END.
    
END.  

OUTPUT CLOSE.
