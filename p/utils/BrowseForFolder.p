/***
*
* FINALIDADE:
*   Mostra a caixa de di logo padrÆo do Windows para sele‡Æo de
*   diret¢rios.
*
* NOTAS:
*   a) Essa rotina ainda nÆo valida se o usu rio selecionou um dos
*      diret¢rios especiais do Windows, como "Impressoras", "Painel
*      de Controle" e afins;
*   b) Implementado a partir do documento 18823, da Knowledge Base da
*      Progress;
*   c) A SHELL32.DLL deve ser, no m¡nimo, a 4.71.
*
* VERSOES:
*   02/09/2002, ljohann, criacao
*
*/

/* parametros de entrada/saida */
DEFINE INPUT  PARAMETER c-titulo    AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER c-diretorio AS CHARACTER NO-UNDO.

/* variaveis utilizadas */
DEFINE VARIABLE oServer AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE oFolder AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE oParent AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE cFolder AS CHARACTER  NO-UNDO.
DEFINE VARIABLE iCount  AS INTEGER    NO-UNDO.

/* Retorna apenas diret¢rios do sistema de arquivos. Se o usu rio
   selecionar diret¢rios que nÆo sÆo parte do sistema de arquivos,
   o botÆo OK ‚ desabilitado (texto extra¡do do site da MSDN). */
&SCOPED BIF_RETURNONLYFSDIRS  1 

IF c-titulo = '' THEN
    ASSIGN c-titulo = 'Selecione um diret¢rio.'.

CREATE 'Shell.Application' oServer.

oFolder = oServer:BrowseForFolder(CURRENT-WINDOW:HWND,
                                  c-titulo,
                                  {&BIF_RETURNONLYFSDIRS}).

IF VALID-HANDLE(oFolder) THEN DO:
    ASSIGN cFolder = oFolder:Title
           oParent = oFolder:ParentFolder
           iCount  = 0.

    REPEAT:
        IF iCount >= oParent:Items:Count THEN DO:
            /* nenhum diret¢rio selecionado */
            LEAVE.
        END.
        ELSE
            IF oParent:Items:Item(iCount):Name = cFolder THEN DO:
                ASSIGN c-diretorio = oParent:Items:Item(iCount):Path.
                LEAVE.
            END.

        ASSIGN iCount = iCount + 1.
    END.
END.
ELSE DO:
/*     message 'Nenhum diret¢rio selecionado.' skip              */
/*             'problemas ao utilizar a API do Windows.' skip(1) */
/*             'Informe o problema ao seu fornecedor' skip       */
/*             'do software.'                                    */
/*          view-as alert-box warning.                           */

    ASSIGN c-diretorio = "".
END.

/* desaloca a mem¢ria utilizada pelos objetos */
RELEASE OBJECT oFolder NO-ERROR.
RELEASE OBJECT oServer NO-ERROR.
