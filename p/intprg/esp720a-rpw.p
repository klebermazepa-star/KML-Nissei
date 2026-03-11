DEFINE VARIABLE h-boin090 AS HANDLE      NO-UNDO.


DEFINE TEMP-TABLE RowErrors NO-UNDO
    FIELD ErrorSequence    AS INTEGER
    FIELD ErrorNumber      AS INTEGER
    FIELD ErrorDescription AS CHARACTER
    FIELD ErrorParameters  AS CHARACTER
    FIELD ErrorType        AS CHARACTER
    FIELD ErrorHelp        AS CHARACTER
    FIELD ErrorSubType     AS CHARACTER.

define temp-table tt-param
    field destino            as integer
    field arquivo            as char
    field usuario            as char format "x(12)"
    field data-exec          as date
    field hora-exec          as integer
    field da-data-ini        as date format "99/99/9999"
    field da-data-fim        as date format "99/99/9999"
    field c-esp-ini          as char
    field c-esp-fim          as char
    field c-ser-ini          as char
    field c-ser-fim          as char
    field c-num-ini          as char
    field c-num-fim          as char
    field i-emit-ini         as integer
    field i-emit-fim         as integer
    field c-nat-ini          as char
    field c-nat-fim          as char
    field c-estab-ini        as char
    field c-estab-fim        as char
    field da-atual-ini       as date format "99/99/9999"
    field da-atual-fim       as date format "99/99/9999"
    field c-usuario-ini      as char 
    field c-usuario-fim      as char
    field i-tipo-ini         as integer
    field i-tipo-fim         as integer
    field l-of               as logical
    field l-saldo            as logical
    field l-desatual         as logical
    field l-custo-padrao     as logical
    field l-desatualiza-ap   as logical
    field l-desatualiza-aca  as logical    
    field i-prc-custo        as integer
    field c-custo            as char
    field c-destino          as char
    field l-desatualiza-wms  as logical
    field l-desatualiza-draw as logical
    field l-desatualiza-cr   as logical
    field l-cons-wms-externo as logical 
    field l-imp-param        as logical
    field mot-canc           as char.
    
define temp-table tt-digita
    field i-seq                    AS   INT
    field tipo-digita              AS   INT INIT 1
    field serie-docto              like docum-est.serie-docto
    field nro-docto                like docum-est.nro-docto
    field cod-emitente             like docum-est.cod-emitente
    field nat-operacao             like docum-est.nat-operacao
    field cod-chave-aces-nf-eletro like docum-est.cod-chave-aces-nf-eletro.    

 
//DEF var raw-param as raw no-undo.
def var raw-digita as raw no-undo.

def temp-table tt-raw-digita     
    field raw-digita      as raw.
    
DEFINE TEMP-TABLE tt-notas 
    FIELD cgc       AS CHAR
    FIELD nr-nota   AS CHAR
    FIELD serie     AS CHAR
    .
    
def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 
    
INPUT FROM VALUE ("\mnt\shares\rpw\prod\rpw-fila2\svc_datasul\recebimento\docto_wms.csv").


REPEAT:

    CREATE tt-notas.
    IMPORT DELIMITER ";" tt-notas.
    
END.
 
 
 OUTPUT TO VALUE ("\mnt\shares\rpw\prod\rpw-fila2\svc_datasul\recebimento\processamento_3.csv").
/*
ASSIGN tt-notas.cgc     = "61940292000218"
       tt-notas.serie   = "60"
       tt-notas.nr-nota = "0476705".   */
       
FOR EACH tt-notas:
    
    EMPTY TEMP-TABLE tt-param.
    EMPTY TEMP-TABLE tt-digita.
    EMPTY TEMP-TABLE tt-raw-digita .
    
    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = tt-notas.cgc NO-ERROR.
        
    EXPORT DELIMITER ";" tt-notas.
    
    create tt-param.  
    ASSIGN tt-param.destino             = 2
           tt-param.arquivo             = "testearquivo.txt"
           tt-param.usuario             = "rpw"
           tt-param.data-exec           = TODAY
           tt-param.hora-exec           = 0
           tt-param.da-data-ini         = 02/27/2025
           tt-param.da-data-fim         = 02/28/2025
           tt-param.c-esp-ini           = ""
           tt-param.c-esp-fim           = "99"
           tt-param.c-ser-ini           = tt-notas.serie
           tt-param.c-ser-fim           = tt-notas.serie
           tt-param.c-num-ini           = string(int(tt-notas.nr-nota), "9999999")
           tt-param.c-num-fim           = string(int(tt-notas.nr-nota), "9999999")
           tt-param.i-emit-ini          = emitente.cod-emitente
           tt-param.i-emit-fim          = emitente.cod-emitente
           tt-param.c-nat-ini           = ""
           tt-param.c-nat-fim           = "ZZZZZZ"
           tt-param.c-estab-ini         = ""   
           tt-param.c-estab-fim         = "ZZZ" 
           tt-param.da-atual-ini        = 02/27/2025
           tt-param.da-atual-fim        = 02/28/2025
           tt-param.c-usuario-ini       = "" 
           tt-param.c-usuario-fim       = "ZZZZZZZZZZ"
           tt-param.i-tipo-ini          = 0
           tt-param.i-tipo-fim          = 999999999 
           tt-param.l-of                = NO
           tt-param.l-saldo             = NO
           tt-param.l-desatual          = YES
           tt-param.l-custo-padrao      = YES
           tt-param.l-desatualiza-ap    = YES
           tt-param.l-desatualiza-aca   = NO
           tt-param.i-prc-custo         = 2
           tt-param.c-custo             = ""
           tt-param.c-destino           = "teste2.txt"
           tt-param.l-desatualiza-wms   = NO
           tt-param.l-desatualiza-draw  = NO.

        raw-transfer tt-param  to raw-param.

        

        
    FIND FIRST DOCUM-EST NO-LOCK
        WHERE docum-est.cod-emitente    = tt-param.i-emit-ini
          AND docum-est.nro-docto       = tt-param.c-num-ini 
          AND docum-est.serie-docto     = tt-param.c-ser-ini NO-ERROR.
          
    IF AVAIL docum-est THEN
    DO:
        
        create tt-digita.
        assign tt-digita.i-seq          = 1
               tt-digita.serie-docto    = docum-est.serie-docto
               tt-digita.nro-docto      = docum-est.nro-docto
               tt-digita.cod-emitente   = docum-est.cod-emitente
               tt-digita.nat-operacao   = docum-est.nat-operacao
               tt-digita.cod-chave-aces-nf-eletro = docum-est.cod-chave-aces-nf-eletro .
               
        
        raw-transfer tt-digita  to raw-digita. 
        CREATE tt-raw-digita.
        ASSIGN tt-raw-digita.raw-digita = raw-digita .    
    
        run rep/re0402rp.r (input raw-param, input table tt-raw-digita). 

        EXPORT DELIMITER ";" tt-param.i-emit-ini
                             tt-param.c-num-ini 
                             tt-param.c-ser-ini
                             "return-re0202 - " 
                             RETURN-VALUE.
            
        RUN inbo/boin090.p  PERSISTENT SET h-boin090.
        
        .MESSAGE VALID-HANDLE(h-boin090)
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       
        RUN setConstraintChave IN h-boin090 (INPUT docum-est.serie-docto,
                                             INPUT docum-est.nro-docto,
                                             INPUT docum-est.cod-emitente,
                                             INPUT docum-est.nat-operacao).
        RUN OpenQueryStatic IN h-boin090 ("Chave").       
        run goToKey in h-boin090 ( input docum-est.serie-docto,
                                   input docum-est.nro-docto,
                                   input docum-est.cod-emitente,
                                   input docum-est.nat-operacao ).  
                          
        .MESSAGE RETURN-VALUE
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       
        run emptyRowErrors in h-boin090.
        run deleteRecord in h-boin090.
        
        run getRowErrors in h-boin090 (output table RowErrors).
        
        FOR EACH RowErrors:
            .MESSAGE ErrorDescription
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        END.
        
        DELETE PROCEDURE h-boin090.
        
    END.
    RELEASE docum-est.
    
   /* FIND FIRST DOCUM-EST NO-LOCK
        WHERE docum-est.cod-emitente    = tt-param.i-emit-ini
          AND docum-est.nro-docto       = tt-param.c-num-ini 
          AND docum-est.serie-docto     = tt-param.c-ser-ini NO-ERROR.
          
    IF NOT AVAIL docum-est THEN
    DO:
    
        
        
    END.  */
    
    
END.

OUTPUT CLOSE.







