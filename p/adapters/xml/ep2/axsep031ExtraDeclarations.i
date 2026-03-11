DEFINE BUFFER b-unid-feder-est FOR unid-feder.
DEFINE BUFFER b-cidade-est     FOR ems2dis.cidade.
DEFINE BUFFER b-emitente       FOR emitente.

DEFINE VARIABLE c-dia                AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE c-mes                AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE c-ano                AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE c-hora               AS CHARACTER   FORMAT "x(15)"            NO-UNDO.
DEFINE VARIABLE c-indice             AS CHARACTER                             NO-UNDO. 

DEFINE VARIABLE lcXMLMDFe            AS LONGCHAR                              NO-UNDO.

DEFINE VARIABLE i-cont-nfe           AS INTEGER                               NO-UNDO.

DEFINE VARIABLE lObtemXMLMDFe        AS LOGICAL                               NO-UNDO.
DEFINE VARIABLE l-integr-totvs-colab AS LOGICAL                               NO-UNDO.

DEFINE VARIABLE de-valor-carga       AS DECIMAL     FORMAT ">>>>>>>>>>>>9.99" NO-UNDO.
DEFINE VARIABLE de-peso-carga        AS DECIMAL     FORMAT ">>>>>>>>>>9.9999" NO-UNDO.

DEFINE VARIABLE da-tz                AS DATETIME-TZ                           NO-UNDO.

DEFINE VARIABLE h-bodi538            AS HANDLE                                NO-UNDO.

DEFINE VARIABLE l-NTMDFE2021002      AS LOGICAL     INITIAL NO                NO-UNDO.
ASSIGN l-NTMDFE2021002 = CAN-FIND(FIRST funcao NO-LOCK
                              WHERE funcao.cd-funcao = "spp-mdfe-nt2021002":U
                                AND funcao.ativo ).
                                 
{ftp/ft4704.i2} /* Defini‡Æo das temp-tables tt-mdfe-ciot e tt-mdfe-seguro */
