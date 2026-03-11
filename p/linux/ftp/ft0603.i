/******************************************************************************
**
**  Include.: FT0603.I
**
**  Objetivo: Rotina para impressao dos representantes da duplicata
**
******************************************************************************/

disp rep-i-cr.cod-rep
     repres.nome-abrev
     rep-i-cr.comissao
     rep-i-cr.comis-emis
     with frame f-linha-reg.
down with frame f-linha-reg.

assign de-vl-comisnota =
       de-vl-comisnota + (fat-duplic.vl-comis * (rep-i-cr.comissao / 100)).

 /* FT0603.I */
