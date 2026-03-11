/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i INT061RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: INT061RP
**
**       DATA....: 10/2016
**
**       OBJETIVO: Relat¢rio de Apura‡Æo de ICMS
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
{include/i-rpvar.i}
{include/i-rpcab.i}
/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char    format "x(12)"   no-undo.

{method/dbotterr.i} 
{cdp/cd0666.i}  /*     Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    field estab-ini        like doc-fiscal.cod-estab 
    field estab-fim        like doc-fiscal.cod-estab 
    field data-ini         like doc-fiscal.dt-docto
    field data-fim         like doc-fiscal.dt-docto
    field estado-ini       like estabelec.estado
    field estado-fim       like estabelec.estado
    FIELD l-atualiza-of0313  AS LOG.

define temp-table tt-digita no-undo
    field nat-operacao    as CHARACTER   format "x(6)"
    field denominacao     as CHARACTER format "x(100)"
    index id nat-operacao.

def temp-table tt-raw-digita
    field raw-digita as raw.
    
define temp-table tt-estab-icms no-undo
    field cod-estab            LIKE it-doc-fisc.class-fiscal
    field vl-saldo-credor-ant  LIKE it-doc-fisc.vl-tot-item
    field vl-deb-saidas        LIKE it-doc-fisc.vl-tot-item
    field vl-outros-deb        LIKE it-doc-fisc.vl-tot-item
    field vl-cred-entradas     LIKE it-doc-fisc.vl-tot-item
    field vl-outros-cred       LIKE it-doc-fisc.vl-tot-item
    INDEX id cod-estab 
            .


DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEFINE TEMP-TABLE tt-erro-aux NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.   


define temp-table tt-param-ni0320 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field estab-ini        as char 
    field estab-fim        as char 
    field uf-ini           as CHAR 
    field uf-fim           as CHAR
    FIELD dt-apur-ini      AS DATE
    FIELD dt-apur-fim      AS DATE
    FIELD tp-imposto       AS CHAR
    FIELD acao             AS INT.

def var raw-param-ni0320        as raw no-undo.

def temp-table tt-raw-digita-ni0320
   field raw-digita      as raw.


def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER raw-digita TO tt-digita.
END.

DEFINE VARIABLE h-acomp        AS HANDLE      NO-UNDO.
DEFINE VARIABLE c-acompanha    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-sped-credito AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-sped-debito  AS CHARACTER   NO-UNDO.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "INT061RP"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.

{include/i-rpout.i}
assign c-titulo-relat = "Relat¢rio Apura‡Æo de ICMS"
       c-sistema      = "Obriga‡äes Fiscais".

VIEW frame f-cabec.
VIEW frame f-rodape.

                   
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Geracao_Titulo_Convenio.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                                */
     
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Leitura dos Documentos").

RUN pi-monta-tt-relat.

IF  tt-param.l-atualiza-of0313
THEN
    RUN pi-executa-ni0320.

RUN pi-imprime-tt-relat.

IF  tt-param.l-atualiza-of0313
THEN DO:
    {include/i-rpclo.i}  
    {include/i-rpout.i}

    VIEW frame f-cabec.
    VIEW frame f-rodape.

    EMPTY TEMP-TABLE tt-estab-icms.

    RUN pi-monta-tt-relat.
    RUN pi-imprime-tt-relat.

END.


RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log(). */

{include/i-rpclo.i}   
return "OK":U.

PROCEDURE pi-monta-tt-relat:

    RUN pi-seta-titulo IN h-acomp (INPUT "Lendo Estabelecimentos").

    FOR EACH estabelec
       WHERE estabelec.cod-estab >= tt-param.estab-ini
         AND estabelec.cod-estab <= tt-param.estab-fim
         AND estabelec.estado    >= tt-param.estado-ini
         AND estabelec.estado    <= tt-param.estado-fim NO-LOCK:

         RUN pi-seta-titulo IN h-acomp (INPUT "Estabelecimento - " + STRING(estabelec.cod-estab,"999")).

         FIND FIRST tt-estab-icms
              WHERE tt-estab-icms.cod-estab = estabelec.cod-estab NO-ERROR.
         IF NOT AVAIL tt-estab-icms THEN DO:
             CREATE tt-estab-icms.
             ASSIGN tt-estab-icms.cod-estab = estabelec.cod-estab.
         END.

         FOR EACH   imp-valor NO-LOCK
              WHERE imp-valor.cod-estab   = estabelec.cod-estab
                AND imp-valor.tp-imposto  = 1 /* ICMS */  
                AND imp-valor.dt-apur-ini = DATE(tt-param.data-ini)
                AND imp-valor.dt-apur-fim = DATE(tt-param.data-fim)
                AND imp-valor.cod-lanc    = 9:
         
             ASSIGN tt-estab-icms.vl-saldo-credor-ant = tt-estab-icms.vl-saldo-credor-ant + imp-valor.vl-lancamento.
         END.

         FOR EACH   imp-valor NO-LOCK
              WHERE imp-valor.cod-estab   = estabelec.cod-estab
                AND imp-valor.tp-imposto  = 1 /* ICMS */
                AND imp-valor.dt-apur-ini = DATE(tt-param.data-ini)
                AND imp-valor.dt-apur-fim = DATE(tt-param.data-fim)
                AND imp-valor.cod-lanc    = 2:
             ASSIGN tt-estab-icms.vl-outros-deb = tt-estab-icms.vl-outros-deb + imp-valor.vl-lancamento.
         END.

         FOR EACH   imp-valor NO-LOCK
              WHERE imp-valor.cod-estab   = estabelec.cod-estab
                AND imp-valor.tp-imposto  = 1 /* ICMS */
                AND imp-valor.dt-apur-ini = DATE(tt-param.data-ini)
                AND imp-valor.dt-apur-fim = DATE(tt-param.data-fim)
                AND imp-valor.cod-lanc    = 6:
             ASSIGN tt-estab-icms.vl-outros-cred = tt-estab-icms.vl-outros-cred + imp-valor.vl-lancamento.
         END.

         RUN pi-seta-titulo IN h-acomp (INPUT "Estab - " + STRING(estabelec.cod-estab,"999") + " - Sa¡das").

         FOR EACH doc-fiscal 
            WHERE doc-fiscal.cod-estab = estabelec.cod-estab
              AND doc-fiscal.dt-docto >= tt-param.data-ini
              AND doc-fiscal.dt-docto <= tt-param.data-fim
              AND doc-fiscal.tipo-nat  = 2
              and doc-fiscal.ind-sit-doc <> 2 NO-LOCK,
             EACH it-doc-fisc OF doc-fiscal NO-LOCK:

             RUN pi-acompanhar IN h-acomp (INPUT "Docto/Data - " + STRING(doc-fiscal.nr-doc-fis) + "/" + STRING(doc-fiscal.dt-docto)).

             ASSIGN tt-estab-icms.vl-deb-saidas = tt-estab-icms.vl-deb-saidas + It-doc-fisc.vl-icms-it.                                 
         END.

         RUN pi-seta-titulo IN h-acomp (INPUT "Estab - " + STRING(estabelec.cod-estab,"999") + " - Entradas").

         FOR EACH doc-fiscal
            WHERE doc-fiscal.cod-estab = estabelec.cod-estab
              AND doc-fiscal.dt-docto >= tt-param.data-ini
              AND doc-fiscal.dt-docto <= tt-param.data-fim
              AND doc-fiscal.tipo-nat  = 1
              AND doc-fiscal.ind-sit-doc <> 2 NO-LOCK,
             EACH it-doc-fisc OF doc-fiscal NO-LOCK:

             RUN pi-acompanhar IN h-acomp (INPUT "Docto/Data - " + STRING(doc-fiscal.nr-doc-fis) + "/" + STRING(doc-fiscal.dt-docto)).

             ASSIGN tt-estab-icms.vl-cred-entradas = tt-estab-icms.vl-cred-entradas + It-doc-fisc.vl-icms-it.                                 
         END.

    END.
END.

PROCEDURE pi-imprime-tt-relat:
    DEFINE VARIABLE d-val-saldo-estab     LIKE tt-estab-icms.vl-saldo-credor-ant.
    DEFINE VARIABLE d-val-saldo-estab-aux LIKE tt-estab-icms.vl-saldo-credor-ant.
    DEFINE VARIABLE d-val-saldo-estab-tot LIKE tt-estab-icms.vl-saldo-credor-ant.

    PUT UNFORMATTED
        "Estab" AT 3
        "Saldo Credor Anterior" AT 10
        "D‚bitos por Saidas" AT 33
        "Outros D‚bitos" AT 53 
        "Cr‚dito por Entrada"  AT 69
        "Outros Cr‚ditos"  AT 91 
        "Saldo"  TO 132  SKIP
        "-----" AT 3
        "---------------------" AT 10
        "------------------" AT 33
        "--------------" AT 53 
        "--------------------"  AT 69
        "----------------"  AT 91 
        "------------------------"  TO 132
         SKIP.

    FOR EACH tt-estab-icms
          BY tt-estab-icms.cod-estab:

/*         MESSAGE "LINE-COUNTER - " LINE-COUNTER */
/*             VIEW-AS ALERT-BOX INFO BUTTONS OK. */

        IF LINE-COUNTER = 64 THEN DO:
            PUT UNFORMATTED
                "Estab" AT 3
                "Saldo Credor Anterior" AT 10
                "D‚bitos por Saidas" AT 33
                "Outros D‚bitos" AT 53 
                "Cr‚dito por Entrada"  AT 69
                "Outros Cr‚ditos"  AT 91 
                "Saldo"  TO 132  SKIP
                "-----" AT 3
                "---------------------" AT 10
                "------------------" AT 33
                "--------------" AT 53 
                "--------------------"  AT 69
                "----------------"  AT 91 
                "------------------------"  TO 132
                 SKIP
                .
        END.

        ASSIGN d-val-saldo-estab = 0
               d-val-saldo-estab = (tt-estab-icms.vl-saldo-credor-ant  + (tt-estab-icms.vl-cred-entradas + tt-estab-icms.vl-outros-cred )) - (tt-estab-icms.vl-deb-saidas + tt-estab-icms.vl-outros-deb).
        
        IF d-val-saldo-estab < 0 
        THEN
             ASSIGN d-val-saldo-estab-aux = (d-val-saldo-estab * (-1)).
        ELSE 
             ASSIGN d-val-saldo-estab-aux = d-val-saldo-estab.

        ASSIGN d-val-saldo-estab-tot = d-val-saldo-estab-tot + d-val-saldo-estab.

        PUT UNFORMATTED 
            tt-estab-icms.cod-estab               TO 7 
            tt-estab-icms.vl-saldo-credor-ant     TO 30  FORMAT "->>>,>>>,>>9.99"
            tt-estab-icms.vl-deb-saidas           TO 50  FORMAT "->>>,>>>,>>9.99"
            tt-estab-icms.vl-outros-deb           TO 66  FORMAT "->>>,>>>,>>9.99"
            tt-estab-icms.vl-cred-entradas        TO 88  FORMAT "->>>,>>>,>>9.99"
            tt-estab-icms.vl-outros-cred          TO 106 FORMAT "->>>,>>>,>>9.99"
            d-val-saldo-estab-aux                 TO 132 FORMAT "->>>,>>>,>>9.99" 
            SKIP.
            
        IF  tt-param.l-atualiza-of0313  = YES AND
            d-val-saldo-estab          <> 0
        THEN
            RUN pi-cria-lancto-of0313 (INPUT d-val-saldo-estab).
    END.

    PUT UNFORMATTED
        SKIP(2)
        "Saldo Devedor:" TO 106 
        IF d-val-saldo-estab-tot < 0 THEN (d-val-saldo-estab-tot * (-1)) ELSE 0 TO 132 FORMAT "->>>,>>>,>>9.99" SKIP
        "Saldo Credor:"  TO 106 
        IF d-val-saldo-estab-tot > 0 THEN d-val-saldo-estab-tot ELSE 0 TO 132 FORMAT "->>>,>>>,>>9.99" SKIP.




    PUT UNFORMATTED
        SKIP(4)
        "--------------------------------- SELE€¶O ---------------------------------" SKIP
        "Estabelecimento : " STRING(tt-param.estab-ini) + " at‚ " + STRING(tt-param.estab-fim) SKIP
        "Data Apura‡Æo   : " STRING(tt-param.data-ini) + " at‚ " + STRING(tt-param.data-fim) SKIP
        "Estado          : " STRING(tt-param.estado-ini) + " at‚ " + STRING(tt-param.estado-fim) SKIP.

END PROCEDURE.


PROCEDURE pi-executa-ni0320:

    DEFINE VARIABLE i-tp-imposto AS INTEGER     NO-UNDO.

    create tt-param-ni0320.
    assign tt-param-ni0320.usuario         = tt-param.usuario  
           tt-param-ni0320.destino         = tt-param.destino  
           tt-param-ni0320.data-exec       = tt-param.data-exec
           tt-param-ni0320.hora-exec       = tt-param.hora-exec
           tt-param-ni0320.destino         = tt-param.destino
           tt-param-ni0320.estab-ini       = tt-param.estab-ini 
           tt-param-ni0320.estab-fim       = tt-param.estab-fim 
           tt-param-ni0320.uf-ini          = tt-param.estado-ini
           tt-param-ni0320.uf-fim          = tt-param.estado-fim
           tt-param-ni0320.dt-apur-ini     = DATE("01/" + STRING(MONTH(tt-param.data-ini)) + "/" + STRING(YEAR(tt-param.data-ini)))
           tt-param-ni0320.dt-apur-fim     = ADD-INTERVAL(tt-param.data-ini,1 ,"MONTH") - DAY(tt-param.data-ini)
           tt-param-ni0320.acao            = 1.

    DO i-tp-imposto = 1 TO 4:

        CASE i-tp-imposto:
            WHEN(1) THEN ASSIGN tt-param-ni0320.tp-imposto = "ICMS".
            WHEN(2) THEN ASSIGN tt-param-ni0320.tp-imposto = "IPI".
            WHEN(3) THEN ASSIGN tt-param-ni0320.tp-imposto = "ICMS Incentivado (PE)".
            WHEN(4) THEN ASSIGN tt-param-ni0320.tp-imposto = "ICMS Substituto Interno".
        END CASE.

        if tt-param-ni0320.destino = 1 
        then 
            assign tt-param-ni0320.arquivo = "".
        else 
            assign tt-param-ni0320.arquivo = session:TEMP-DIRECTORY  + "int061-ni0320-" + STRING(i-tp-imposto) + ".txt".
        
        SESSION:SET-WAIT-STATE("general").

        RAW-TRANSFER tt-param-ni0320 TO raw-param-ni0320.
        
        RUN intprg/ni0320rp.p (INPUT raw-param-ni0320,
                               INPUT TABLE tt-raw-digita-ni0320).
        
        SESSION:SET-WAIT-STATE("").
    END.

END PROCEDURE.


PROCEDURE pi-cria-lancto-of0313:

    DEF INPUT PARAM p-de-valor-lancto AS DEC NO-UNDO.

    DEFINE VARIABLE i-cod-lanc AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-seq-lanc AS INTEGER     NO-UNDO.

    ASSIGN c-sped-credito = "PR020061"  
           c-sped-debito  = "PR000062". 

    IF  p-de-valor-lancto < 0
    THEN
        ASSIGN i-cod-lanc = 6. /* Cr‚dito */ 
    ELSE
        ASSIGN i-cod-lanc = 2. /* D‚bito */

    FOR FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = tt-estab-icms.cod-estab:

        CASE estabelec.estado:
            WHEN("PR") 
                THEN ASSIGN c-sped-credito = "PR020061" 
                            c-sped-debito  = "PR000062".

            WHEN("SP") 
                THEN ASSIGN c-sped-credito = "SP020729" 
                            c-sped-debito  = "SP000218".

            WHEN("SC") 
                THEN ASSIGN c-sped-credito = "SC020054" 
                            c-sped-debito  = "SC000001".
        END CASE.
    END.

    ASSIGN i-seq-lanc = 1.

    FIND LAST imp-valor NO-LOCK
        WHERE imp-valor.cod-estabel  = tt-estab-icms.cod-estab    
          AND imp-valor.tp-imposto   = 1 /* ICMS */               
          AND imp-valor.dt-apur-ini  = tt-param-ni0320.dt-apur-ini
          AND imp-valor.dt-apur-fim  = tt-param-ni0320.dt-apur-fim
          AND imp-valor.cod-lanc     = i-cod-lanc NO-ERROR.
          
    IF AVAIL imp-valor  THEN
    DO:
        ASSIGN i-seq-lanc = imp-valor.nr-sequencia + 1.
        
    END.

    ELSE DO:
        
        CREATE imp-valor.
        ASSIGN imp-valor.cod-estabel  = tt-estab-icms.cod-estab
               imp-valor.tp-imposto   = 1 /* ICMS */
               imp-valor.dt-apur-ini  = tt-param-ni0320.dt-apur-ini
               imp-valor.dt-apur-fim  = tt-param-ni0320.dt-apur-fim
               imp-valor.cod-lanc     = i-cod-lanc
               imp-valor.nr-sequencia = i-seq-lanc.

        IF  p-de-valor-lancto < 0
        THEN
            ASSIGN  imp-valor.vl-lancamento = p-de-valor-lancto * -1
                    imp-valor.descricao     = "TRANSFERENCIA DE SALDO DEVEDOR PARA CENTRALIZADORA"
            OVERLAY(imp-valor.char-1,11,20) = c-sped-credito.
        ELSE
            ASSIGN  imp-valor.vl-lancamento = p-de-valor-lancto
                    imp-valor.descricao     = "TRANSFERENCIA DE SALDO CREDOR PARA CENTRALIZADORA"
            OVERLAY(imp-valor.char-1,11,20) = c-sped-debito.
            
    END.
    
        
    FOR FIRST  dwf-apurac-impto EXCLUSIVE-LOCK
        WHERE  dwf-apurac-impto.cod-estab                  = imp-valor.cod-estabel
          AND  dwf-apurac-impto.dat-apurac-final-impto     = imp-valor.dt-apur-fim
          AND  dwf-apurac-impto.dat-apurac-inicial-impto   = imp-valor.dt-apur-ini
          AND  dwf-apurac-impto.cod-impto                  = {diinc/i01di220.i 04 imp-valor.tp-imposto}
          AND  dwf-apurac-impto.dat-inic-valid             = TODAY
          AND  dwf-apurac-impto.dat-fim-valid              = ?:

        DELETE dwf-apurac-impto.
    END.

    CREATE dwf-apurac-impto.
    ASSIGN dwf-apurac-impto.cod-estab                = imp-valor.cod-estabel
           dwf-apurac-impto.dat-apurac-final-impto   = imp-valor.dt-apur-fim
           dwf-apurac-impto.dat-apurac-inicial-impto = imp-valor.dt-apur-ini
           dwf-apurac-impto.cod-impto                = {diinc/i01di220.i 04 imp-valor.tp-imposto} 
           dwf-apurac-impto.dat-inic-valid           = TODAY
           dwf-apurac-impto.dat-fim-valid            = ?.
           
     
    FOR FIRST  dwf-apurac-impto-ajust EXCLUSIVE-LOCK
        WHERE  dwf-apurac-impto-ajust.cod-estab                 = imp-valor.cod-estabel
          AND  dwf-apurac-impto-ajust.dat-apurac-inicial-impto  = imp-valor.dt-apur-ini
          AND  dwf-apurac-impto-ajust.dat-apurac-final-impto    = imp-valor.dt-apur-fim
          AND  dwf-apurac-impto-ajust.cod-ajust                 = SUBSTRING(imp-valor.char-1,11,8)
          AND  dwf-apurac-impto-ajust.cod-impto                 = {diinc/i01di220.i 04 imp-valor.tp-imposto}
          AND  dwf-apurac-impto-ajust.cod-lancto                = STRING(imp-valor.cod-lanc,"999")
          AND  dwf-apurac-impto-ajust.num-seq-ajust             = imp-valor.nr-sequencia:

        DELETE dwf-apurac-impto-ajust.
    END.

    CREATE dwf-apurac-impto-ajust.
    ASSIGN dwf-apurac-impto-ajust.cod-estab                = imp-valor.cod-estabel
           dwf-apurac-impto-ajust.dat-apurac-final-impto   = imp-valor.dt-apur-fim
           dwf-apurac-impto-ajust.dat-apurac-inicial-impto = imp-valor.dt-apur-ini
           dwf-apurac-impto-ajust.cod-ajust                = SUBSTRING(imp-valor.char-1,11,8)
           dwf-apurac-impto-ajust.cod-ajust-sped           = SUBSTRING(imp-valor.char-1,11,20)
           dwf-apurac-impto-ajust.cod-impto                = {diinc/i01di220.i 04 imp-valor.tp-imposto}
           dwf-apurac-impto-ajust.num-seq-ajust            = imp-valor.nr-sequencia
           dwf-apurac-impto-ajust.dsl-ajust-apurac         = imp-valor.descricao
           dwf-apurac-impto-ajust.cod-lancto               = STRING(imp-valor.cod-lanc,"999")
           dwf-apurac-impto-ajust.val-ajust-apurac         = imp-valor.vl-lancamento
           dwf-apurac-impto-ajust.dat-inic-valid           = TODAY
           dwf-apurac-impto-ajust.dat-fim-valid            = ?.
           

    RELEASE imp-valor.
    RELEASE dwf-apurac-impto.
    RELEASE dwf-apurac-impto-ajust.

END PROCEDURE.
