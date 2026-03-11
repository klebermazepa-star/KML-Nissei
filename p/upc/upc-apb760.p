/*****************************************************************************
** Nome Externo..........: upc\upc-apb760.p
** UPC do programa.......: api_enviar_msg_pagto_edi_mpf (apb760za)
** Alteraá∆o por ........: Eduardo Marcel Barth (47) 99903-1968
** Vers∆o ...............: 000 - Tratamento tributos sem c¢digo de barras
** Alterado em...........: 10/2022
*****************************************************************************/

define temp-table tt_epc no-undo
    field cod_event        as character
    field cod_parameter    as character
    field val_parameter    as character
    index id is primary cod_parameter cod_event ascending.

DEF INPUT PARAMETER p-evento AS CHAR.
DEF INPUT-OUTPUT PARAMETER TABLE FOR tt_epc.

DEF VAR v_rec_item_bord_ap AS RECID NO-UNDO.
DEF VAR c_retorno          AS CHAR NO-UNDO INIT "".

/**********************************************************************/

IF  p-evento <> 'Atualiza Forma Pagto' THEN
    RETURN "".

FIND FIRST tt_epc
    WHERE tt_epc.cod_parameter = 'recid_item_bord'
    NO-ERROR.
IF  NOT AVAIL tt_epc THEN
    RETURN "".

FIND item_bord_ap WHERE recid(item_bord_ap) = int64( TT_epc.val_parameter ) NO-LOCK NO-ERROR.
IF  NOT AVAIL ITEM_bord_ap THEN
    RETURN "".

IF  item_bord_ap.cod_banco <> "237" // Bradesco
    THEN RETURN "".


FIND tit_ap
    where tit_ap.cod_estab       = item_bord_ap.cod_estab
      and tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
      and tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
      and tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
      and tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
      and tit_ap.cod_parcela     = item_bord_ap.cod_parcela
      NO-LOCK NO-ERROR.
IF  NOT AVAIL tit_ap THEN
    RETURN "".

IF  tit_ap.cb4_tit_ap_bco_cobdor = ""                      // Tributos sem codigo de barras
OR  LENGTH(tit_ap.cb4_tit_ap_bco_cobdor) = 48 THEN DO:     // 48 posiá‰es - Pode ser FGTS ou IPTU

    FIND cst_tit_ap_tributo OF ITEM_bord_ap NO-LOCK NO-ERROR.
    IF  AVAIL cst_tit_ap_tributo THEN
        FIND cst_espec_tributo OF cst_tit_ap_tributo NO-LOCK NO-ERROR.
    IF  AVAIL cst_espec_tributo THEN DO:
        IF  tit_ap.cb4_tit_ap_bco_cobdor = "" THEN DO:         // Tributos sem codigo de barras
            IF  cst_espec_tributo.tip_tributo = "DARF" THEN    ASSIGN c_retorno = "PagtoDARF" + CHR(10) + "16".    // Forma lancto 16 = DARF
            IF  cst_espec_tributo.tip_tributo = "GPS" THEN     ASSIGN c_retorno = "PagtoGPS" + CHR(10) + "17".     // Forma lancto 17 = GPS (guia da previdencia social)
            IF  cst_espec_tributo.tip_tributo = "GARE-SP" THEN ASSIGN c_retorno = "PagtoGARE-SP" + CHR(10) + "22". // Forma lancto 22 = GARE-SP ICMS
        END.
        ELSE IF LENGTH(tit_ap.cb4_tit_ap_bco_cobdor) = 48 THEN DO:  // 48 posiá‰es - Pode ser FGTS ou IPTU        IF  cst_espec_tributo.tip_tributo = "DARF" THEN    ASSIGN c_retorno = "PagtoDARF" + CHR(10) + "16".    // Forma lancto 16 = DARF
            IF  cst_espec_tributo.tip_tributo = "IPTU" THEN    ASSIGN c_retorno = "PagtoIPTU" + CHR(10) + "19".    // Forma lancto 19 = IPTU
            IF  cst_espec_tributo.tip_tributo = "FGTS" THEN    ASSIGN c_retorno = "PagtoFGTS" + CHR(10) + "11".    // Forma lancto 11=Pagamento de Contas e Tributos com c¢digo de barras
            // OBS: os nomes acima servem para gerar lotes separados no arquivo de envio.
            //      o c¢digo Ö direita Ç o campo Forma de Lanáamento do registro Header de Lote do layout Bradesco.
        END.
    END.
    ELSE IF LENGTH(tit_ap.cb4_tit_ap_bco_cobdor) = 48 THEN  // 48 posiá‰es - conta de †gua, luz, etc.
        ASSIGN c_retorno = "PagtoContas" + CHR(10) + "11".  // Forma lancto 11=Pagamento de Contas e Tributos com c¢digo de barras
END.


IF  c_retorno <> "" THEN DO:
    CREATE tt_epc.
    ASSIGN tt_epc.cod_event     = 'Atualiza Forma Pagto'
           tt_epc.cod_parameter = 'Retorno Forma Pagto'
           tt_epc.val_parameter = c_retorno.
    RETURN "OK".
END.

RETURN "".
