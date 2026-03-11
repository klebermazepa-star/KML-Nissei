/***************************************************************************************
**   Programa: trg-w-int_dp_abc_farma.p - 
***************************************************************************************/
TRIGGER PROCEDURE FOR CREATE OF int_dp_abc_farma.
ASSIGN int_dp_abc_farma.sequenci = NEXT-VALUE(seq_int_dp_abc_farma).
RETURN "OK".
