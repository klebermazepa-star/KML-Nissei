/******************************************************************************
 * Programa:  upc-cc0301a.p
 * Diretorio: upc
 * Objetivo:  UPC para tirar o zero do campo item fornecedor
 *
 * Autor: KML - Lohan
 * Data de Cria»’o: 11/2024
 *
 ******************************************************************************/

define input  param p-ind-event             as char             no-undo.
define input  param p-ind-object            as char             no-undo.
define input  param p-wgh-object            as handle           no-undo.
define input  param p-wgh-frame             as widget-handle    no-undo.
define input  param p-cod-table             as character        no-undo.
define input  param p-row-table             as ROWID            no-undo.

define new global shared var h-item-despesa   as handle no-undo.
define new global shared var h-cod-icm   as handle no-undo.


/* .MESSAGE 'EVENTO' p-ind-event SKIP                          */
/*         'OBJETO' p-ind-object SKIP                          */
/*         'FRAME' p-wgh-frame SKIP                            */
/*         'TABELA' p-cod-table SKIP                           */
/*         'ROWID' STRING(p-row-table) SKIP VIEW-AS ALERT-BOX. */
                               
IF p-ind-event = "BEFORE-INITIALIZE" 
    AND p-ind-object = "VIEWER" THEN DO:
           
    RUN utils/findWidget.p (INPUT  'codigo-icm',   
                            INPUT  'RADIO-SET',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-cod-icm).
                            
END.

                               
IF p-ind-event = "BEFORE-DISPLAY" 
    AND p-ind-object = "VIEWER" THEN DO:
   
    IF VALID-HANDLE(h-cod-icm) THEN DO:
    
        CREATE TOGGLE-BOX h-item-despesa
        ASSIGN NAME      = "h-item-despesa"
               FRAME     = h-cod-icm:FRAME
               ROW       = h-cod-icm:ROW + 1
               COL       = h-cod-icm:COL
               VISIBLE   = YES
               SENSITIVE = YES
               LABEL     = "Item de Despesa".
    
    
    
     END.
      
END.

IF p-ind-event = "DISPLAY" 
    AND p-ind-object = "VIEWER" THEN DO:
    
    IF VALID-HANDLE(h-item-despesa) THEN DO:
        
        FIND FIRST ordem-compra NO-LOCK
            WHERE rowid(ordem-compra) = p-row-table NO-ERROR.
            
        IF AVAIL ordem-compra THEN
        DO:
            
            ASSIGN h-item-despesa:CHECKED = IF SUBSTRING(ordem-compra.char-2, 120,1) = "S" THEN YES ELSE NO.
        
            
        END.
        
    END.    
    
END.

IF p-ind-event = "ASSIGN" 
    AND p-ind-object = "VIEWER" THEN DO:
    
    
    IF VALID-HANDLE(h-item-despesa) THEN DO:
        
        FIND FIRST ordem-compra NO-LOCK
            WHERE rowid(ordem-compra) = p-row-table NO-ERROR.
            
        IF AVAIL ordem-compra THEN DO:
  
            IF h-item-despesa:CHECKED = YES THEN
                OVERLAY(ordem-compra.char-2, 120,1) = "S".
            
            ELSE 
                OVERLAY(ordem-compra.char-2, 120,1) = "N".
        
            
        END.
        
    END.    
    
END.

IF p-ind-event = "DESTROY" 
    AND p-ind-object = "VIEWER" THEN DO:
   
   DELETE PROCEDURE h-item-despesa.
   DELETE PROCEDURE h-cod-icm.
   
END.

RETURN "OK".

/* ---------------------------
Mensagem
---------------------------
EVENTO DESTROY 
OBJETO CONTAINER 
FRAME 75454 
TABELA  
ROWID ? 
---------------------------
OK   
---------------------------
 */

/* 
Salvar no Banco de Dados
---------------------------
Mensagem
---------------------------
EVENTO ASSIGN 
OBJETO VIEWER 
FRAME 74726 
TABELA ordem-compra 
ROWID 0x00000000e7178e0a 
---------------------------
OK   
---------------------------
 */

/*
Fazer o find para salvar no campo em tela
---------------------------
Mensagem
---------------------------
EVENTO DISPLAY 
OBJETO VIEWER 
FRAME 74726 
TABELA ordem-compra 
ROWID 0x0000000001d98201 
---------------------------
OK   
---------------------------
 */

/* ---------------------------
Mensagem
---------------------------
EVENTO BEFORE-DISPLAY 
OBJETO VIEWER 
FRAME 74138 
TABELA ordem-compra 
ROWID 0x0000000001d98201 
---------------------------
OK   
---------------------------
 */

/* ---------------------------
Mensagem
---------------------------
EVENTO BEFORE-INITIALIZE 
OBJETO VIEWER 
FRAME 72295 
TABELA ordem-compra 
ROWID ? 
---------------------------
OK   
---------------------------
 */

/* ---------------------------
Informacao
---------------------------
DBName: ems2log 
Table: ordem-compra 
Name: codigo-icm 
Type: INTEGER 
Format: ? 
Transaction: no 
Program: ccp/cc0301a-v02.w 
Path: \\192.168.200.78\Totvs12\_quarentena\ems2\ccp\cc0301a-v02.r
---------------------------
OK   
---------------------------
 */
