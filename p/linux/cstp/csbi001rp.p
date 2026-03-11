/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         CSBI001
&SCOPED-DEFINE program_definition   ""
&SCOPED-DEFINE program_version      1.00.00.001

{include/i-prgvrs.i {&program_name}RP {&program_version} }

{cstp/{&program_name}tt.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/*Stream Definitions*/
{include/i-rpvar.i}
{include/i-rpout.i &STREAM="stream str-rp"}

/*Cabecario e Rodape Padrao*/
{include/i-rpcab.i &STREAM="str-rp"}

FIND mguni.empresa NO-LOCK WHERE empresa.ep-codigo = tt-param.empresa .
ASSIGN c-programa = "{&program_name}RP"
    c-versao = "{&program_version}"
    c-empresa = STRING(empresa.ep-codigo) + " - " + empresa.razao-social
    c-sistema = ""
    c-titulo-relat = {&program_definition}
    .

VIEW STREAM str-rp FRAME f-cabec.
VIEW STREAM str-rp FRAME f-rodape.

/* ***************************  MAIN BLOCK  ************************** */

IF tt-param.modul_fgl THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpa.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_acr THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpb.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_apb THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpc.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_cmg THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpd.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_pat THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpe.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_apl THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpf.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_cep THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rpg.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.
IF tt-param.modul_fat THEN 
DO ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:
    RUN cstp/csbi001rph.p(INPUT raw-param , INPUT TABLE tt-raw-digita) .
END.

PUT STREAM str-rp UNFORMATTED
    "Execu‡Æo finalizada."
    SKIP .

/*FIM*/
{include/i-rpclo.i &STREAM="stream str-rp"}
RETURN "OK":U .


