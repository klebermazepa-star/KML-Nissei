DEFINE VARIABLE h_q01di134 AS HANDLE NO-UNDO.
DEFINE VARIABLE h_v01di134 AS HANDLE NO-UNDO.
DEFINE VARIABLE h_ft2073   AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b01di096 AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b16di088 AS HANDLE NO-UNDO.


PROCEDURE pi-recebe-parametros.
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input param table for tt-docto.
def input param table for tt-it-docto.
def input param table for tt-nota-embal.
def input param seq-tt-nota-embal as integer .

DEF input param p-h_q01di134 AS HANDLE NO-UNDO.
DEF input param p-h_v01di134 AS HANDLE NO-UNDO.
DEF input param p-h_ft2073   AS HANDLE NO-UNDO.
DEF input param p-h_b01di096 AS HANDLE NO-UNDO.
DEF input param p-h_b16di088 AS HANDLE NO-UNDO.

assign h_q01di134 = p-h_q01di134 
       h_v01di134 = p-h_v01di134 
       h_ft2073   = p-h_ft2073
       h_b01di096 = p-h_b01di096
       h_b16di088 = p-h_b16di088 .


END procedure.


