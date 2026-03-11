/*--gen_preprocessors_begin--*/
&GLOBAL-DEFINE XmlApp            &1
&GLOBAL-DEFINE XmlMod            ESP
&GLOBAL-DEFINE XmlProdName       &2    /*INFORMAR AQUI O PRODUTO -EMS2, EMS5 OU HR*/ 
&GLOBAL-DEFINE XmlProdVersion    &3
&GLOBAL-DEFINE XmlTranName       &4    /*INFORMAR AQUI A TRANSACAO*/
&GLOBAL-DEFINE XmlMinTranVersion 200.000
&GLOBAL-DEFINE XmlMaxTranVersion 999.999
&GLOBAL-DEFINE XmlListOfAction   upd,add,del
/*--gen_preprocessors_end--*/

{system/Error.i}
{system/InstanceManagerDef.i}
{system/InstanceManager.i &register=false}

define variable objectHandle as handle    no-undo.

DEFINE VAR cReturnValue     AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VAR cTranAction      AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VAR cTranEvent       AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VAR cTranVersion     AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VAR hBusinessContent AS HANDLE NO-UNDO.
DEFINE VAR hGenXml          AS HANDLE NO-UNDO.
DEFINE VAR hMessageHandler  AS HANDLE NO-UNDO.
DEFINE VAR lSuccessProcess  AS LOGICAL INITIAL ? NO-UNDO.

{xmlinc/xmlLoadMessageHandlerRecDef.i}
{xmlinc/xmlLoadGenXmlRecDef.i}
{xmlinc/xmlgettranssubsinfo.i}
 
DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID  AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.

DEFINE TEMP-TABLE ttErros NO-UNDO
    FIELD descricao  AS CHARACTER
    FIELD ajuda      AS CHARACTER.
 
{method/dbotterr.i}
                                                                                                
FUNCTION addStack RETURN INTEGER (INPUT val AS INTEGER).
     DEFINE VARIABLE id AS INTEGER INITIAL 1 NO-UNDO.
     FIND LAST ttStack NO-ERROR.
     IF AVAILABLE(ttStack) THEN 
         ASSIGN id = ttStack.ttID + 1.
 
     CREATE ttStack.
     ASSIGN ttStack.ttID  = id.
     ASSIGN ttStack.ttPos = val.
END FUNCTION.
 
 
FUNCTION delStack RETURN INTEGER.
     FIND LAST ttStack NO-ERROR.
     IF AVAILABLE(ttStack) THEN
         DELETE ttStack.
 
     FIND LAST ttStack NO-ERROR.
END FUNCTION.
 
 
FUNCTION getStack RETURN INTEGER.
     IF AVAILABLE(ttStack) THEN
         RETURN ttStack.ttPos.
     ELSE
          RETURN 0.
END FUNCTION.
 
 
FUNCTION nullDec RETURN decimal
    (input inputValue as decimal).
    if inputValue = ? then
        return 0.0.
    else
        return inputValue.
END FUNCTION.
 
 
FUNCTION nullVal RETURN character
    (input inputValue as character).
    if inputValue = ? then
        return "".
    else
        return inputValue.
END FUNCTION.
 
 
FUNCTION nullDate RETURN date
    (input inputValue as date).
    if inputValue = ? then
        return ?.
    else
        return inputValue.
END FUNCTION.
 
 
FUNCTION nullLog RETURN logical
    (input inputValue as logical).
    if inputValue = ? then
        return false.
    else
        return inputValue.
END FUNCTION.


procedure loadXml private:
    /* OBTEM A PARTE DA MENSAGEM QUE ESTÊ ABAIXO DO ELEMENTO BusinessContent */
    RUN getBusinessContent IN hMessageHandler (OUTPUT hBusinessContent).

    /* LIMPA AS TEMP-TABLES INTERNAS DA API XML */
    RUN RESET IN hGenXml.

    /* CARREGA A ESTRUTURA FILHA DE BusinessContent */
    RUN loadXml IN hGenXml (hBusinessContent).

    /* ELIMINA A MENSAGEM OBTIDA NO MêTODO getBusinessContent */
    DELETE OBJECT hBusinessContent NO-ERROR.
end procedure.
 
procedure populateNonKeyValues private:
/*--gen_populate_declaration_begin--*/
    define variable return&1 as &2 no-undo.
/*--gen_populate_declaration_end--*/

    addStack(1).

/*--gen_populate_begin--*/
    run getSon&1 in hGenXml(getStack(), '&2', output return&1).
    run set&3 in objectHandle(null&1(return&1)).
                        
/*--gen_populate_end--*/
    delStack().
end procedure.
 
 
PROCEDURE receiveMessage:
    DEFINE INPUT  PARAM hInputXML  AS HANDLE NO-UNDO.
    DEFINE OUTPUT PARAM hOutputXML AS HANDLE NO-UNDO.
    
    /* VERIFICA SE MessageHandler.p ESTA NA MEMORIA */
    {xmlinc/xmlLoadMessageHandlerRec.i &MessageHandler="hMessageHandler" &MHReturnValue="cReturnValue" &MHReturnError="hOutputXML"}

    IF cReturnValue <> "OK" THEN DO:
        RETURN cReturnValue.
    END.

    /* INTERPRETA, ARMAZENA E VALIDA A MENSAGEM QUE RECEBE */
    RUN parseMessage IN hMessageHandler (
         INPUT  hInputXml, 
         INPUT "{&XmlTranName}", 
         INPUT "{&XmlMaxTranVersion}", 
         INPUT "{&XmlMinTranVersion}", 
         INPUT "{&XmlListOfEvents}",
         OUTPUT lSuccessProcess,
         OUTPUT cTranAction, 
         OUTPUT cTranEvent,
         OUTPUT cTranVersion,
         OUTPUT hOutputXML ).
 
    /* SE N«O PROCESSOU CORRETAMENTE RETORNA ERRO */
    IF NOT lSuccessProcess OR RETURN-VALUE <> "OK" THEN 
    /* DAR TRATAMENTO CONVENIENTE ANTES DE RETORNAR */
         RETURN RETURN-VALUE.
 
    /* VERIFICA SE APIXML ESTA NA MEMORIA */
    {xmlinc/xmlloadgenxmlrec.i &GenXml="hGenXml" &GXReturnValue="cReturnValue" &GXReturnError="hOutputXML"}
 
    /* VERIFICA SE O ut-genxml FOI INICIADO CORRETAMENTE */
    IF cReturnValue <> "OK"
    THEN DO:
         /* ELIMINA A MENSAGEM OBTIDA NO M»TODO getBusinessContent */
         DELETE OBJECT hBusinessContent NO-ERROR.
 
         RETURN cReturnValue.
    END.
 
    /* Chamada para o programa que ir† tratar o conteudo da mensagem */
    RUN processaMensagem IN THIS-PROCEDURE.
    
    /* OBTEM UMA MENSAGEM DE RETORNO - SENDO ELA DE ERRO OU DE CONFIRMAÄ«O */
    RUN getReturnMessage IN hMessageHandler (OUTPUT hOutputXML).
END PROCEDURE.
 
PROCEDURE processaMensagem:
/*--gen_processing_declaration_begin--*/
    define variable &1_ as &2 no-undo.
/*--gen_processing_declaration_end--*/

    if index('{&XmlListOfAction}', cTranAction) = 0 then do:
        run setError in hMessageHandler(17006, 'Erro',
            substitute('Aá∆o "&1" inv†lida. Aá‰es permitidas: &2', cTranAction, '{&XmlListOfAction}')).
        return 'NOK':u.                                                                                                        
    end.

    if not valid-handle(ghInstanceManager) then do:                                                                                 
        run setError in hMessageHandler(17006, 'Erro', 'Classe InstanceManager n∆o foi inicializada').
        return "NOK":U.                                                                                                        
    end.                       

/*--gen_processing_begin--*/
    run createInstance in ghInstanceManager(this-procedure,
        'integracao/&1/&2/&3.p', output objectHandle).
/*--gen_processing_end--*/

    if not valid-handle(objectHandle) then do:
        run setError in hMessageHandler(17006, 'Erro', 'Classe de neg¢cio n∆o foi instanciada').
        return "NOK":U.
    end.

    processing-block:
    do {system/Try.i processing-block}:
        run loadXml.
/*--gen_processing_getkeyvalues_begin--*/
        run getKeyValues(&1).
/*--gen_processing_getkeyvalues_end--*/
    
        case cTranAction:
            when 'add' then do:
                run new in objectHandle.
/*--gen_processing_add_begin--*/
                run set&1 in objectHandle(&2_).
/*--gen_processing_add_end--*/
            end.
    
            when 'upd' or when 'del' then do:
/*--gen_processing_update_begin--*/
                run find in objectHandle(&1).
/*--gen_processing_update_end--*/
            end.
        end case.
    
        run populateNonKeyValues.

        do transaction {system/Try.i processing-block}:
            case cTranAction:
                when 'add' then
                    run insert in objectHandle.
    
                when 'upd' then
                    run update in objectHandle.
    
                when 'del' then
                    run delete in objectHandle.
            end case.
        end. /* transaction */
    end. 
    
    run getErrors in objectHandle(output table RowErrors).
      
    run deleteInstance in ghInstanceManager(objectHandle).
    
    for each rowErrors:
        run setError in hMessageHandler (rowErrors.errorNumber,
            rowErrors.errorSubType, rowErrors.errorDescription
                + ', Ajuda: ':u + rowErrors.errorHelp).
    end.
    
    if can-find(first rowErrors) then
        return "NOK":U.
END PROCEDURE.

procedure getKeyValues private:
/*--gen_keyvalues_declaration_begin--*/
    define output parameter &1_ as &2 no-undo.
/*--gen_keyvalues_declaration_end--*/

    addStack(1).
    
/*--gen_keyvalues_xml_begin--*/
    run getSon&1 in hGenXml(getStack(), '&2', output &2_).
/*--gen_keyvalues_xml_begin--*/

    delStack().
end procedure.

