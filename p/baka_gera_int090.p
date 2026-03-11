

 define temp-table TT-PARAM-int090 NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD cod-estab-ini      as character FORMAT "x(3)"
       FIELD cod-estab-fim      as character FORMAT "x(3)"
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD tg-pr              AS LOG       
       FIELD tg-sp              AS LOG
       FIELD tg-sc              AS LOG
       FIELD tg-go              AS LOG
       FIELD tg-df              AS LOG
       FIELD tg-pr-dest         AS LOG       
       FIELD tg-sp-dest         AS LOG
       FIELD tg-sc-dest         AS LOG
       FIELD tg-go-dest         AS LOG
       FIELD tg-df-dest         AS LOG
       FIELD ge-codigo-ini      AS INTEGER   FORMAT ">9"
       FIELD ge-codigo-fim      AS INTEGER   FORMAT ">9"
       FIELD fm-codigo-ini      AS CHARACTER FORMAT "x(8)"
       FIELD fm-codigo-fim      AS CHARACTER FORMAT "x(8)"
       FIELD clas-fiscal-ini    AS CHARACTER FORMAT "9999.99.99" /* ncm */
       FIELD clas-fiscal-fim    AS CHARACTER FORMAT "9999.99.99"
       FIELD cst-ini            AS INTEGER   FORMAT ">9"
       FIELD cst-fim            AS INTEGER   FORMAT ">9"
       FIELD com-subst-tribut   AS LOG         
       FIELD sem-subst-tribut   AS LOG
       FIELD forc-integ         AS LOG.
       
def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.       

def var raw-param          as raw no-undo.
DEFINE VARIABLE i-num-ped-exec-rpw AS INTEGER     NO-UNDO.

    create  tt-param-int090.
    assign  tt-param-int090.DESTINO             = 2
            tt-param-int090.ARQUIVO             = "int090.LST"
            tt-param-int090.USUARIO             = "rpw"
            tt-param-int090.DATA-EXEC           = today
            tt-param-int090.HORA-EXEC           = time
            tt-param-int090.L-IMP-PARAM         = NO  
            tt-param-int090.L-EXCEL             = NO
            tt-param-int090.cod-estab-ini       = ""
            tt-param-int090.cod-estab-fim       = "ZZZZZZZZZ"
            tt-param-int090.it-codigo-ini       = "2009"
            tt-param-int090.it-codigo-fim       = "2009"
            tt-param-int090.tg-pr               = YES     
            tt-param-int090.tg-sp               = YES
            tt-param-int090.tg-sc               = YES
            tt-param-int090.tg-go               = YES
            tt-param-int090.tg-df               = YES
            tt-param-int090.tg-pr-dest          = YES   
            tt-param-int090.tg-sp-dest          = YES   
            tt-param-int090.tg-sc-dest          = YES
            tt-param-int090.tg-go-dest          = YES
            tt-param-int090.tg-df-dest          = YES
            tt-param-int090.ge-codigo-ini       = 0 
            tt-param-int090.ge-codigo-fim       = 99999999
            tt-param-int090.fm-codigo-ini       = ""
            tt-param-int090.fm-codigo-fim       = "ZZZZZZZZZ" 
            tt-param-int090.clas-fiscal-ini     = ""
            tt-param-int090.clas-fiscal-fim     = "ZZZZZZZZZ"
            tt-param-int090.cst-ini             = 0  
            tt-param-int090.cst-fim             = 9999 
            tt-param-int090.com-subst-tribut    = YES   
            tt-param-int090.sem-subst-tribut    = YES
            tt-param-int090.forc-integ          = NO
            .

    raw-transfer tt-param-int090 to raw-param.
 
 
run btb/btb911zb.p (input "int090",
                    input "intprg/int090rp.p",
                    input "2.00.00.000",
                    input 97,
                    INPUT "int090.LST",
                    input 2,
                    input raw-param,
                    input TABLE tt-raw-digita,
                    OUTPUT i-num-ped-exec-rpw).   
                    
                    
MESSAGE i-num-ped-exec-rpw
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
