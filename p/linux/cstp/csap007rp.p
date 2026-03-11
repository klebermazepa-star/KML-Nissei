{cstp/csap007tt.i}

DEFINE INPUT PARAMETER f-dt-trans AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE INPUT PARAMETER Ativar-ACR AS LOGICAL.
DEFINE INPUT PARAMETER Ativar-APB AS LOGICAL.
DEFINE INPUT PARAMETER acr-empresa AS CHAR FORMAT 'X(3)'.
DEFINE INPUT PARAMETER apb-empresa AS CHAR FORMAT 'X(3)'.
DEFINE INPUT PARAMETER Portador-acr AS CHAR FORMAT 'X(5)'.
DEFINE INPUT PARAMETER Carteira-ACR AS CHAR FORMAT 'X(3)'.
DEFINE INPUT PARAMETER Portador-apb AS CHAR FORMAT 'X(5)'.
DEFINE INPUT PARAMETER TABLE FOR tt-tit_ap .

DEF VAR cCodReferAPB AS CHAR NO-UNDO.

DEF VAR acr901zf AS HANDLE NO-UNDO. 
DEF VAR apb902ze AS HANDLE NO-UNDO.

def var i-seq-ref    as integer no-undo.

/* C¢digo para o relatorio de sa¡da do programa */

{utp/ut-glob.i}

&SCOPED-DEFINE pagesize             60
&SCOPED-DEFINE program_name         CSAP007
&SCOPED-DEFINE program_definition   "Relat¢rio de T¡tulos Liquidados"
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name}RP {&program_version} }

CREATE tt-param .
ASSIGN tt-param.destino = 3
    tt-param.arquivo = "csap007.tmp"
    tt-param.usuario = c-seg-usuario
    tt-param.data-exec = TODAY
    tt-param.hora-exec = TIME
    .


FIND mguni.empresa NO-LOCK WHERE empresa.ep-codigo = i-ep-codigo-usuario .

{include/i-rpvar.i}

{include/i-rpout.i &STREAM="stream str-rp"}
{include/i-rpcab.i &STREAM="str-rp"}

ASSIGN c-programa = "{&program_name}RP"
c-versao = "{&program_version}"
c-empresa = STRING(empresa.ep-codigo) + " - " + empresa.razao-social
c-sistema = ""
c-titulo-relat = {&program_definition}
.

VIEW STREAM str-rp FRAME f-cabec.
VIEW STREAM str-rp FRAME f-rodape.

/* at‚ aqui, relat¢rio */

run utils/geraReferenciaEMS5.p(output cCodReferAPB).
    
    
    /* Relatorio, continua‡Æo ACR */

FORM "------------------------------------------------------------------------------------------------------------------------------------":U
    skip     " Titulos ACR Liquidados com Sucesso! ":U
    WITH FRAME f-sucesso WIDTH 300 STREAM-IO
    .
VIEW STREAM str-rp FRAME f-sucesso.



FORM SKIP(3) 
    "------------------------------------------------------------------------------------------------------------------------------------":U 
    SKIP "------------------------------------------------------------------------------------------------------------------------------------":U
    SKIP " Titulos ACR nÆo Liquidados por Falha! ":U
    WITH FRAME f-falha WIDTH 300 STREAM-IO
    .

VIEW STREAM str-rp FRAME f-falha.

FORM 
    WITH FRAME f-corpo-fail-acr WIDTH 300 DOWN STREAM-IO    
    .                                                   
                                                        

    /* Relat¢rio, fim da continua‡Æo ACR */



/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
/*{include/i-rpexc.i}*/
{include/i-rptrm.i}

procedure WinExec external "kernel32.dll":
  def input param prg_name                          as character.
  def input param prg_style                         as short.
end procedure.

/* fim relatorio */
