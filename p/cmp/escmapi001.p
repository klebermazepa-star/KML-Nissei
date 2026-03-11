//----------------------------------------------------------------------------------------------------
//      DEFINTIONS
//----------------------------------------------------------------------------------------------------

// Variÿveis Globais ---
{utp/ut-glob.i}

// Includes ---
{method/dbotterr.i}
{include/i-epc200.i setDefaultEmitente}
{lib/utilidades.i}
{lib/mensagens2.i}

// Include de controle de vers’o ---
{include/i-prgvrs.i setDefaultEmitente 12.1.2301.002}


// Defini»’o de Buffer usados nas includes ---
DEFINE BUFFER b2-emitente FOR ems2mult.emitente.
DEFINE BUFFER empresa     FOR mguni.empresa.
DEFINE BUFFER cheque      FOR mguni.cheque.

DEFINE BUFFER cotacao                                   FOR ems2mult.cotacao.
DEFINE BUFFER emitente                                  FOR ems2mult.emitente.
DEFINE BUFFER funcao                                    FOR ems2mult.funcao.
DEFINE BUFFER estabelec                                 FOR ems2mult.estabelec.
DEFINE BUFFER dist-emitente                             FOR ems2mult.dist-emitente.
DEFINE BUFFER titulo                                    FOR ems2mult.titulo.
DEFINE BUFFER esp-doc                                   FOR ems2mult.esp-doc.
DEFINE BUFFER relacto-titulo-cheque                     FOR ems2mult.relacto-titulo-cheque.
DEFINE BUFFER estatist                                  FOR ems2mult.estatist.
DEFINE BUFFER gr-cli                                    FOR ems2mult.gr-cli.
DEFINE BUFFER emit-estat                                FOR ems2mult.emit-estat.
DEFINE BUFFER tit-ap                                    FOR ems2mult.tit-ap.

// Defini»’o de Variaveis usadas nas includes ---
DEFINE VARIABLE c-cm-cod-estabel               AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-cm-num-dia-atraso            AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-cm-num-dia-aviso             AS INTEGER   NO-UNDO.
DEFINE VARIABLE d-cm-val-atraso-max            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE d-cm-val-aviso-db              AS DECIMAL   NO-UNDO.
DEFINE VARIABLE d-lim-credito                  AS DECIMAL   NO-UNDO.
DEFINE VARIABLE i-cm-num-horiz-fix             AS INTEGER   NO-UNDO. 
DEFINE VARIABLE l-cm-reabre-aval               AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-cm-log-consid-cr-cr          AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-cm-log-consid-cotas-credito  AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-cm-log-consid-desco-credito  AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-cm-log-consid-precos-credito AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-considera-replica-pd         AS LOGICAL   NO-UNDO.  // usado na cdapi013.i ---
DEFINE VARIABLE i-empresa                      LIKE param-global.empresa-prin    NO-UNDO.

// Includes de saldo de cr²dito ---
{cdp/cdapi013.i}  // definic’o de TTs para cr²dito ---
{cdp/cdapi013.i1} // verifica»’o de cr²dito do cliente ---


// Deifni»’o de Variÿveis Locais ---
DEFINE VARIABLE d-saldo-credito AS DECIMAL     NO-UNDO.
DEFINE VARIABLE d-valor-aux     AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-ipi       AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-icms      AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-iss       AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-pis       AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-cofins    AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-tot-imp   AS DECIMAL     NO-UNDO.
DEFINE VARIABLE d-prop          AS DECIMAL     NO-UNDO.

//----------------------------------------------------------------------------------------------------
//      MAIN BLOCK
//----------------------------------------------------------------------------------------------------

 // RUN tester.

//----------------------------------------------------------------------------------------------------
//      FUNCTIONS
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
FUNCTION retornarSaldoCredito RETURNS DECIMAL
    (INPUT p-cod-emitente           AS INTEGER):
//DEFINE OUTPUT PARAMETER p-saldo-credito AS DECIMAL     NO-UNDO.
DEFINE VARIABLE saldo-credito AS DECIMAL     NO-UNDO.

    IF NOT AVAIL emitente THEN
        RETURN ?.

    EMPTY TEMP-TABLE tt-emitente.
    EMPTY TEMP-TABLE tt-emitente-safra.
    EMPTY TEMP-TABLE tt-empresa-estab.
    EMPTY TEMP-TABLE tt-epc.

    ASSIGN saldo-credito   = 0
           d-lim-credito   = 0
           de-saldo-ap     = 0
           mp-vl-ap-abe    = 0
           de-saldo-cr     = 0
           mp-vl-cr-abe    = 0
           de-vl-nota      = 0
           de-totvlap      = 0.

    CREATE tt-emitente.
    ASSIGN tt-emitente.cod-emitente      = emitente.cod-emitente
           tt-emitente.nome-abrev        = emitente.nome-abrev
           tt-emitente.nr-mesina         = emitente.nr-mesina
           tt-emitente.cod-gr-cli        = emitente.cod-gr-cli
           tt-emitente.nr-peratr         = emitente.nr-peratr
           tt-emitente.nr-cheque-devol   = emitente.nr-cheque-devol
           tt-emitente.vl-max-devol      = emitente.vl-max-devol
           tt-emitente.qtd-dias          = emitente.periodo-devol
           tt-emitente.moeda-credito     = 0
           tt-emitente.de_saldo_cr       = 0
           tt-emitente.de_saldo_ap       = 0
           tt-emitente.de_tot_tit_atr_cr = 0
           tt-emitente.de_tot_ad_cr      = 0
           tt-emitente.de_cr_ant_aberto  = 0
           tt-emitente.de_ap_ant_aberto  = 0
           tt-emitente.identif           = emitente.identif.

     RUN pi-determina-limite (OUTPUT d-lim-credito).
     RUN pi-verifica-pd.
     RUN pi-verifica-ft.

     /* L½gica abaixo evita erro progress na procedure pi-saldo-cr */
     IF emitente.ind-abrange-aval = 1 THEN 
         FOR FIRST b2-emitente FIELDS ()
             WHERE ROWID(b2-emitente) = ROWID(emitente) NO-LOCK:
         END.
     ELSE 
         FOR FIRST b2-emitente FIELDS ()
             WHERE b2-emitente.nome-abrev = emitente.nome-matriz NO-LOCK:
         END.

     IF NOT AVAIL b2-emitente THEN NEXT.
     /**/
    
    EMPTY TEMP-TABLE tt_tit_acr_analise_credito.
    EMPTY TEMP-TABLE tt_tit_ap_analise_credito.
    EMPTY TEMP-TABLE tt-emitente-safra.
    EMPTY TEMP-TABLE tt-erros-analise-credito.
    
    RUN pi-saldo-cr (INPUT IF emitente.ind-aval = 2 THEN 1 ELSE 3).
    RUN pi-saldo-ap.

    ASSIGN saldo-credito = d-lim-credito + (de-saldo-ap + mp-vl-ap-abe) - (de-saldo-cr + mp-vl-cr-abe + de-vl-nota + de-totvlap).
    
    RETURN saldo-credito.

END FUNCTION.


//----------------------------------------------------------------------------------------------------
//      PROCEDURE
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
PROCEDURE pi-executa-upc:
    // ***** N’o remover essa procedure *****
    // "Usada" pela rotina de cÿlculo de saldo de cr²dito
END PROCEDURE.

//----------------------------------------------------------------------------------------------------
PROCEDURE atualizarSaldoCreditoEmitente:
DEFINE INPUT  PARAMETER p-cod-emitente AS INTEGER     NO-UNDO.    

    EMPTY TEMP-TABLE rowErrors.

    FIND FIRST emitente NO-LOCK
         WHERE emitente.cod-emitente = p-cod-emitente NO-ERROR.
    IF NOT AVAIL emitente THEN DO:
        RUN gerarRowErrors(SUBSTITUTE("Emitente nÆo encontado (c¢digo &1)", STRING(p-cod-emitente))).
        RETURN "NOK".
    END.
    
    FOR FIRST es-emitente-credito EXCLUSIVE-LOCK WHERE
              es-emitente-credito.cod-emitente      = emitente.cod-emitente:
    END.
    IF NOT AVAIL es-emitente-credito THEN
    DO:
        CREATE  es-emitente-credito.
        ASSIGN  es-emitente-credito.cod-emitente    = emitente.cod-emitente.
        
    END.
    
    ASSIGN  es-emitente-credito.val-saldo-credito           = retornarSaldoCredito(emitente.cod-emitente)
            es-emitente-credito.dat-ultima-atualizacao      = NOW.
    
    RELEASE  es-emitente-credito.
    
    RETURN "OK".    
    
END PROCEDURE.



//----------------------------------------------------------------------------------------------------
PROCEDURE tester:

    //FOR FIRST emitente NO-LOCK WHERE emitente.nome-abrev = "2 benites el" : END.

    // Busca Saldo de Cr²dito do Cliente ---
      /// emitente.cod-emitente,  // INPUT  127303,
                            

    RUN atualizarSaldoCreditoEmitente (INPUT  17901).
    //MESSAGE retornarSaldoCredito (INPUT  17901)        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    
END PROCEDURE.    

