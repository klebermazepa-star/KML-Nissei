{utp/ut-glob.i}
def var raw-param as raw no-undo.
define temp-table tt-param-re1005
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.
define temp-table tt-digita-re1005
    field r-docum-est        as rowid.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

/******* LE NOTA E GERA TEMP TABLES  *************/
for each estabelec no-lock where estabelec.estado = "SC":
    for each docum-est no-lock WHERE docum-est.dt-atualiza = ? and
        docum-est.cod-estabel = estabelec.cod-estabel:

        empty temp-table tt-digita-re1005.
        empty temp-table tt-param-re1005.

        create tt-param-re1005.
        assign 
            tt-param-re1005.destino            = 3
            tt-param-re1005.arquivo            = "int012-re1005_SC.txt"
            tt-param-re1005.usuario            = c-seg-usuario
            tt-param-re1005.data-exec          = today
            tt-param-re1005.hora-exec          = time
            tt-param-re1005.classifica         = 1
            tt-param-re1005.c-cod-estabel-ini  = docum-est.cod-estabel
            tt-param-re1005.c-cod-estabel-fim  = docum-est.cod-estabel
            tt-param-re1005.i-cod-emitente-ini = docum-est.cod-emitente
            tt-param-re1005.i-cod-emitente-fim = docum-est.cod-emitente
            tt-param-re1005.c-nro-docto-ini    = docum-est.nro-docto
            tt-param-re1005.c-nro-docto-fim    = docum-est.nro-docto
            tt-param-re1005.c-serie-docto-ini  = docum-est.serie-docto
            tt-param-re1005.c-serie-docto-fim  = docum-est.serie-docto
            tt-param-re1005.c-nat-operacao-ini = docum-est.nat-operacao
            tt-param-re1005.c-nat-operacao-fim = docum-est.nat-operacao
            tt-param-re1005.da-dt-trans-ini    = docum-est.dt-trans
            tt-param-re1005.da-dt-trans-fim    = docum-est.dt-trans.


        create tt-digita-re1005.
        assign tt-digita-re1005.r-docum-est  = rowid(docum-est).
        release docum-est.
        
       /*
        create tt-raw-digita.
        raw-transfer tt-digita-re1005 to tt-raw-digita.raw-param.
        */
        raw-transfer tt-param-re1005 to raw-param.
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita).
    
        empty temp-table tt-digita-re1005.
        empty temp-table tt-param-re1005.


    end.
     
end.
