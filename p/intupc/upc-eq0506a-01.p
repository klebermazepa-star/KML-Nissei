/******************************************************************************************
**  Programa: upc-eq0506a.p
**  Versao..:  
**  Data....: Desabilitar campo numero de embarque e incrementar automaticamente 
******************************************************************************************/
DEF INPUT PARAM p-opcao          AS   CHAR              NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-nr-embarque-eq0506a   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR l-add-cq0506a            AS LOGICAL       NO-UNDO. 

DEF VAR i-nr-embarque LIKE embarque.cdd-embarq  NO-UNDO. 
     
IF p-opcao = "entry" 
THEN DO:          
    
    IF VALID-HANDLE(wh-nr-embarque-eq0506a) THEN DO:

       ASSIGN wh-nr-embarque-eq0506a:SENSITIVE =  no.
       
       IF l-add-cq0506a = NO THEN DO:

           RUN pi-nr-embarque (OUTPUT i-nr-embarque). 

           ASSIGN wh-nr-embarque-eq0506a:SCREEN-VALUE =  STRING(i-nr-embarque).
       END.

    END.                         
    
END.

PROCEDURE pi-nr-embarque :

DEF OUTPUT PARAM p-nr-embarque LIKE embarque.cdd-embarq.
           
 /* Code placed here will execute AFTER standard behavior.    */  
  find last embarque no-lock no-error.
  IF  AVAIL embarque AND embarque.cdd-embarq < 999999 THEN
      ASSIGN p-nr-embarque = embarque.cdd-embarq + 1.
  ELSE DO:

      /************************************************************************************ 
      * Se passou de 999.999 volta para 1, e tenta achar a primeira numera‡Æo disponivel. *
      * A numera‡Æo ‚ gravada na ped-curva, para que na pr¢xima vez a contagem continue   *
      * do mesmo ponto                                                                    *
      ************************************************************************************/

      FOR FIRST ems2dis.ped-curva
          WHERE ped-curva.vl-aberto = 36227783
          AND   ped-curva.codigo    = 36227783 NO-LOCK:
      END.
      IF  NOT AVAIL ped-curva THEN DO:
          CREATE ped-curva.
          ASSIGN ped-curva.vl-aberto = 36227783
                 ped-curva.codigo    = 36227783
                 ped-curva.int-1     = 0.
          FIND CURRENT ped-curva NO-LOCK.
      END.
          
      ASSIGN p-nr-embarque = ped-curva.int-1 + 1.

  END.

  REPEAT:
      /*find last embarque WHERE embarque.nr-embarque = p-nr-embarque no-lock no-error.*/
      IF CAN-FIND(FIRST embarque WHERE 
                        embarque.cdd-embar = p-nr-embarque) THEN
          ASSIGN p-nr-embarque = p-nr-embarque + 1.
      ELSE
          LEAVE.
  END.

END PROCEDURE.



 

