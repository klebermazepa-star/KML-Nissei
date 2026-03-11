/*
 *------------------------------------------------------------------------------
 *  PROGRAMA        escm0001
 *  OBJETIVO        Grava‡Æo do Saldo de Cr‚dito do cliente
 *  AUTOR           TOTVS - LASF
 *  DATA            05/2025
 *------------------------------------------------------------------------------
 */

/*
 *------------------------------------------------------------------------------
 *
 *                                DEFINI€åES
 *
 *------------------------------------------------------------------------------
 */
{cmp/escm0001.i}

DEFINE BUFFER emitente FOR ems2mult.emitente.

DEF temp-table tt-raw-digita
    field raw-digita        as raw.

{include/i-rpvar.i} 
DEF VAR h-acomp AS HANDLE NO-UNDO.

&IF DEFINED(debug) = 0 &THEN
    DEFINE INPUT PARAMETER  raw-param AS RAW NO-UNDO.
    DEFINE INPUT PARAMETER  TABLE FOR tt-raw-digita.
&ENDIF

DEFINE STREAM sArq.

{METHOD/dbotterr.i}
{lib/utilidades.i}                                                                                        
{lib/mensagens2.i}      
{lib/log2.i}


DEFINE VARIABLE h-escmapi001 AS HANDLE      NO-UNDO.
DEFINE VARIABLE iLidos  AS INTEGER     NO-UNDO.
DEFINE VARIABLE iOK     AS INTEGER     NO-UNDO.
DEFINE VARIABLE iNOK    AS INTEGER     NO-UNDO.



//---------------------------------------------------------------------------------------------------------------------------------------    
//      FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------------------------    

/*
 *------------------------------------------------------------------------------
 *
 *                                MAIN BLOCK
 *
 *------------------------------------------------------------------------------
 */


&IF DEFINED(debug) = 0 &THEN
    CREATE tt-param.
    RAW-TRANSFER raw-param TO tt-param.    
&ENDIF

    RUN abrirlog(tt-param.arquivo).
    RUN gerarLog("Grava‡Æo do Saldo de Cr‚dito do Cliente").  
    RUN gerarLog("Iniciando processamento...").             

    FOR FIRST tt-param:
    END.

    RUN utp/ut-acomp.p persistent set h-acomp.

    RUN pi-inicializar in h-acomp(input "Aguarde").
    
    RUN instanciarProcedures.
    
    RUN atualizarSaldoCliente.
    
    RUN gerarLog("Registros Lidos : " + STRING(iLidos)). 
    RUN gerarLog("Registros OK    : " + STRING(iOK)).
    RUN gerarLog("Registros NOK   : " + STRING(iNOK)). 
    
    
    RUN gerarLog("Processamento conclu¡do").             
    
    RUN excluirProcedures.       

    RUN pi-finalizar IN h-acomp.
    

//---------------------------------------------------------------------------------------------------------------------------------------    
//      PROCEDURE
//---------------------------------------------------------------------------------------------------------------------------------------    

//---------------------------------------------------------------------------------------------------------------------------------------    
PROCEDURE atualizarSaldoCliente:

    FOR FIRST tt-param:
    END.
    
    
    ASSIGN  iLidos  = 0
            iOK     = 0
            iNOK    = 0.
    
    
    FOR EACH emitente NO-LOCK WHERE
             emitente.cod-emitente      >= tt-param.cod-emitente-ini
         AND emitente.cod-emitente      <= tt-param.cod-emitente-fim
         AND emitente.nome-abrev        >= tt-param.nome-abrev-ini
         AND emitente.nome-abrev        <= tt-param.nome-abrev-fim:
         
         IF NOT CAN-FIND(FIRST integra-emitente NO-LOCK WHERE integra-emitente.cod-emitente   = emitente.cod-emitente) THEN
            NEXT. 
         
         IF emitente.identif = 2 THEN
            NEXT.
            
        ASSIGN  iLidos      = iLidos + 1.

        RUN gerarLog("Atualizando Cliente " + STRING(emitente.cod-emitente)).
        RUN gerarLog("Processando..." + STRING(emitente.cod-emitente) ).             
            
        RUN limparErros IN h-escmapi001.
        RUN atualizarSaldoCreditoEmitente IN h-escmapi001 (emitente.cod-emitente).
        IF RETURN-VALUE = "OK" THEN
        DO:
            ASSIGN  iOK     = iOK + 1.
            RUN gerarLog("Atualizado com sucesso").             
                        
        END.
        ELSE
        DO:
            ASSIGN  iNOK     = iNOK + 1.
            RUN gerarLog("Houve Erro").             
            RUN retornarErros IN h-escmapi001 (OUTPUT TABLE rowErrors).
            FOR EACH rowErrors:
                RUN gerarLog("Erro retornado pela API: " + rowErrors.errorDesc).             
                
            END.
        
        END.
        
    END.
    
    
    RETURN "OK".
    

END PROCEDURE.

        
//---------------------------------------------------------------------------------------------------------------------------------------    
PROCEDURE instanciarProcedures:


    IF NOT VALID-HANDLE(h-escmapi001) THEN
        RUN cmp/escmapi001.p PERSISTENT SET h-escmapi001.        
        
END PROCEDURE.

//---------------------------------------------------------------------------------------------------------------------------------------    
PROCEDURE excluirProcedures:

    IF VALID-HANDLE(h-escmapi001) THEN DO:
        DELETE PROCEDURE h-escmapi001.
        ASSIGN h-escmapi001 = ?.
    END.
    
END PROCEDURE.

