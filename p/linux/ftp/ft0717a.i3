/*************************************************************************
**
** FT0717.i3 - PI-EPC
**
*************************************************************************/

DEF INPUT PARAM pdeValor AS DEC NO-UNDO.

/*--------- INICIO UPC ---------*/
IF  c-nom-prog-upc-mg97  <> '':U THEN DO:

for each tt-epc:
    delete tt-epc.
end.
create tt-epc.
assign tt-epc.cod-event     = "AfterAssignSumarFt"
       tt-epc.cod-parameter = "sumar-ft rowid"
       tt-epc.val-parameter = string(rowid(sumar-ft)).
create tt-epc.
assign tt-epc.cod-event     = "AfterAssignSumarFt"
       tt-epc.cod-parameter = "ValueToConvert"
       tt-epc.val-parameter = string(pdeValor).

{include/i-epc201.i "AfterAssignSumarFt"}
/*--------- FINAL UPC ---------*/
END.
