/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ni0302A 2.00.00.061 } /*** 010061 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ni0302a MFP}
&ENDIF
 
/******************************************************************************
**
**  Programa: ni0302A.P 
**
*******************************************************************************/
 
    def input parameter l-incentivado as logical no-undo.
    def input parameter i-tp-emissao  as integer no-undo.

    def var c-descricao as char no-undo.

    {intprg/ni0302.i4 SHARED}
    {cdp/cdcfgdis.i}  /* pre-processadores */

    /** EPC ****************************/
    {include/i-epc200.i ni0302A}
    /** EPC ****************************/

    /*
    def shared var c-linha-branco as character no-undo format "x(132)".
    def shared var l-separadores  as logical format "Sim/Nao"               no-undo.
    def shared var i-aux          as int                                    no-undo. 

    def shared var c-tit          as char format "x(11)"                    no-undo.
    def shared var c-titimposto   as char format "x(7)"                     no-undo.
    def shared var c-cod-est      like estabelec.cod-estabel                no-undo.
    def shared var da-iniper      like doc-fiscal.dt-docto                  no-undo.
    def shared var da-fimper      like doc-fiscal.dt-docto                  no-undo.
    def shared var de-imp-deb     as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.
    def shared var de-imp-cre     as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo. 
    def shared var h-acomp        as handle                                 no-undo.
    def shared var i-moeda        like moeda.mo-codigo.                      
    def shared var c-moeda        as character format "x(12)".
    def shared var de-conv        as decimal  init 1                        no-undo.
    def shared var i-num-pag      as int                                    no-undo.
    def shared var i-terab        like termo.te-codigo                      no-undo.
    def shared var i-teren        like termo.te-codigo                      no-undo.

    def var de-imposto            as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.
    def var i-cont                as int                                    no-undo.
    def var c-arrecada            as char format "x(20)" extent 5           no-undo.
    def var da-entrega            as date                                   no-undo.
    def var c-local               as char format "x(30)"                    no-undo.
    def var l-achou               as logical                                no-undo.
    def shared var c-sep          as character no-undo format "x" init "|". 
    def var c-sepa                like c-sep                                no-undo.

    def frame f-cabec with stream-io.
    */

    def shared var h-acomp        as handle                                 no-undo.
    def var c-sepa                like c-sep                                no-undo.


    {include/tt-edit.i}  /** defini»’o da tabela p/ impress’o do campo editor */

    def var l-tem-funcao         as log     no-undo.

    assign l-tem-funcao = can-find(funcao where funcao.cd-funcao = "considera-termo" and funcao.ativo).

    def var i-tp-imposto as integer no-undo.

    /* 3. tratamento icms incentivado - 1.ICMS normal */
    assign i-tp-imposto = if  l-incentivado then 3 else 1. 

    {utp/ut-liter.i Saldo_credor_a_transportar_para_o_per¡odo_seguinte * r}
    assign c-descricao = return-value.

    for first estabelec fields ( estado )
        where estabelec.cod-estabel = c-cod-est no-lock.
    end.

    /** EPC ****************************/
    FOR EACH tt-epc 
       WHERE tt-epc.cod-event = "pi-executar-ponto-1":U:
        DELETE tt-epc.
    END.
    CREATE tt-epc.
    ASSIGN tt-epc.cod-event     = "pi-executar-ponto-1":U
           tt-epc.cod-parameter = "tp-imposto":U
           tt-epc.val-parameter = "0":U.
    {include/i-epc201.i "pi-executar-ponto-1"}
    FIND FIRST tt-epc
         WHERE tt-epc.cod-event     = "pi-executar-ponto-1":U
           AND tt-epc.cod-parameter = "return-tp-imposto":U NO-ERROR.
    IF AVAIL tt-epc THEN DO:
       ASSIGN i-tp-imposto = INT(tt-epc.val-parameter) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN
          ASSIGN i-tp-imposto = ?.
    END.
    /** EPC ****************************/

    for first apur-imposto fields ( cod-estabel tp-imposto dt-apur-ini
                                    dt-apur-fim dt-entrega loc-entrega observacao )
        where apur-imposto.cod-estabel = c-estab-param
        and   apur-imposto.dt-apur-ini = da-iniper 
        and   apur-imposto.dt-apur-fim = da-fimper 
        and   apur-imposto.tp-imposto  = i-tp-imposto no-lock.
    end.

    if  avail apur-imposto then do:

        run pi-acompanhar in h-acomp (input apur-imposto.cod-estabel ).
        assign c-tit = "  RESUMO DA".

        if estabelec.estado = "MG"
        then assign c-titimposto = "IMPOSTO".
        else assign c-titimposto = "ICMS".

        {intprg/ni0302.i2}         

        /**  Gera‡Æo autom tica do C¢digo 014
        **/
        if  i-tp-emissao = 2 
        and credito-1 >= 0 then do:

            for first imp-valor fields()
                where imp-valor.cod-estabel = c-estab-param
                  and imp-valor.tp-imposto  = i-tp-imposto 
                  and imp-valor.cod-lanc    = 014 
                  and imp-valor.dt-apur-ini = da-iniper 
                  and imp-valor.dt-apur-fim = da-fimper exclusive-lock.
            end.

            if  not available imp-valor then do:
                create imp-valor.
                assign imp-valor.cod-estabel   = c-estab-param
                       imp-valor.cod-lanc      = 014
                       imp-valor.vl-lancamento = credito-1
                       imp-valor.descricao     = c-descricao
                       imp-valor.dt-apur-fim   = da-fimper
                       imp-valor.dt-apur-ini   = da-iniper
                       imp-valor.nr-sequencia  = 1
                       imp-valor.tp-imposto    = i-tp-imposto.
            end.
            else do:
                assign imp-valor.vl-lancamento = credito-1.
                release imp-valor.
            end.                   
        end.

    end.

    {include/pi-edit.i}

    {intprg/ni0302.i8} /* procedure pi-imprime-termo */
