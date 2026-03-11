DEF VAR i-tipo-imposto      AS INTEGER INITIAL 0                   NO-UNDO.

/*** Projeto 1006  Atualiza‡Æo Devolu‡Æo de Cliente no Contas a Receber ***/
&IF "{&bf_mat_versao_ems}" >= "2.04" &THEN

   DO i-tipo-imposto = 1 TO 4:
       
       CREATE tt-impto-retid-fat.
       ASSIGN tt-impto-retid-fat.cod-estabel     =  fat-duplic.cod-estabel
              tt-impto-retid-fat.cod-esp         =  fat-duplic.cod-esp
              tt-impto-retid-fat.serie           =  fat-duplic.serie
              tt-impto-retid-fat.nr-docto        =  fat-duplic.nr-fatura
              tt-impto-retid-fat.parcela         =  fat-duplic.parcela
              tt-impto-retid-fat.cod-emitente    =  docum-est.cod-emitente
              tt-impto-retid-fat.idi-tip-impto   =  i-tipo-imposto.

       &IF "{&bf_mat_versao_ems}" <  "2.06" &THEN
            CASE i-tipo-imposto:
                WHEN 1 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((dec(substring(it-nota-fisc.char-2,112,14)) / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*PIS   */
                WHEN 2 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((dec(substring(it-nota-fisc.char-2,126,14)) / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*COFINS*/
                WHEN 3 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((dec(substring(it-nota-fisc.char-2,98,14))  / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*CSLL  */
                WHEN 4 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((it-nota-fisc.vl-irf-it                     / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*IR    */
            END CASE.
       &ENDIF
       
       &IF "{&bf_mat_versao_ems}" >= "2.06" &THEN
            CASE i-tipo-imposto:
                WHEN 1 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((it-nota-fisc.val-retenc-pis    / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*PIS   */
                WHEN 2 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((it-nota-fisc.val-retenc-cofins / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*COFINS*/
                WHEN 3 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((it-nota-fisc.val-retenc-csll   / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*CSLL  */
                WHEN 4 THEN
                    ASSIGN tt-impto-retid-fat.vl-impto = fn_ajust_dec( ((it-nota-fisc.vl-irf-it         / it-nota-fisc.qt-faturada[1]) * item-doc-est.quantidade) , 0). /*IR    */
            END CASE.
       &ENDIF
       
   END.
&ENDIF

/*** Projeto 1006  Atualiza‡Æo Devolu‡Æo de Cliente no Contas a Receber ***/
