/*OUTPUT TO F:\TOTVS\Vanilda\SPED-SC-SP\nfs-modelo-59-janeiro-dwf-v004.txt.*/
    DEF VAR chave AS CHAR FORMAT "X(80)".
    DEF VAR chave2 AS CHAR FORMAT "X(60)".

    /*MESSAGE c-cod-estabel-ini SKIP c-cod-estabel-fim SKIP dt-ini SKIP dt-fim
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/
FOR EACH estabelec NO-LOCK WHERE estabelec.estado = 'SP' AND estabelec.cod-estabel >= c-cod-estabel-ini AND estabelec.cod-estabel <= c-cod-estabel-fim:
   FOR EACH dwf-docto EXCLUSIVE-LOCK WHERE dwf-docto.dat-entr-saida >= dt-ini
                                        AND dwf-docto.dat-entr-saida <= dt-fim
                                        AND dwf-docto.cod-estab = estabelec.cod-estabel
                                       /* AND dwf-docto.cod-estab = '064' */
                                        /*AND dwf-docto.cod-docto = '0601211'
                                        AND dwf-docto.cod-serie = '004'*/
                                        AND dwf-docto.idi-tip-docto = 2 :

       

       ASSIGN chave =  dwf-docto.cod-chave-aces-nf-eletro.
       /*PUT dwf-docto.cod-chave-aces-nf-eletro SKIP.*/
       IF SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,1,3) = 'CFE' THEN DO:
           ASSIGN dwf-docto.cod-chave-aces-nf-eletro = TRIM(SUBSTRING(dwf-docto.cod-chave-aces-nf-eletro,4,60)).
           /*ASSIGN dwf-docto.cod-model-docto = '59'.*/
       END.
       
       /*IF dwf-docto.cod-model-docto <> '59' THEN*/
      /* ASSIGN dwf-docto.cod-model-docto = TRIM(SUBSTRING(dwf-docto.cod-chave-aces-nf-eletro,21,2)).*/
       IF TRIM(dwf-docto.cod-model-docto) = '' THEN DO:
         /* PUT 'sem modelo' SKIP .*/
          ASSIGN dwf-docto.cod-model-docto = '1B' .
       END.

       

       IF TRIM(SUBSTRING(dwf-docto.cod-chave-aces-nf-eletro,21,2)) = '59' THEN DO:
          /*PUT 'Trocou o modelo ' dwf-docto.cod-model-docto " " .*/
          ASSIGN dwf-docto.cod-model-docto = '03'.
          /*PUT dwf-docto.cod-model-docto SKIP.*/
       END.

      /* IF dwf-docto.cod-docto = '0682075' THEN DO:
           MESSAGE 11111 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/
          IF TRIM(SUBSTRING(dwf-docto.cod-chave-aces-nf-eletro,21,2)) = '65' THEN DO:
             /*PUT 'Trocou o modelo ' dwf-docto.cod-model-docto " " .*/
             ASSIGN dwf-docto.cod-model-docto = '65'.
             /*PUT dwf-docto.cod-model-docto SKIP.*/
          END.
      /* END.*/

       
 

      /*PUT TRIM(SUBSTRING(dwf-docto.cod-chave-aces-nf-eletro,21,2))  dwf-docto.cod-model-docto " " dwf-docto.cod-estab " " dwf-docto.cod-serie " " dwf-docto.cod-docto " " dwf-docto.cod-natur-operac " " 
                  dwf-docto.cod-chave-aces-nf-eletro " " estabelec.estado " " dwf-docto.dat-entr-saida " "  SKIP.*/
      /* MESSAGE dwf-docto.char-2          
           VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

   END.

END.




        
/*OUTPUT CLOSE.*/

