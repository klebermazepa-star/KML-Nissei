/**
*
* PROGRAMA:
*   utils/showReport.p
*
* FINALIDADE:
*   Obtem no .ini da sessao o programa para mostrar relatorios e depois executa
*   esse programa via utils/WinExec.p.
*
* VERSOES:
*   25/01/2005, Leandro Johann, Datasul Paranaense,
*     Criacao
*
*/
define input  parameter cReportFile as character  no-undo.

run utils/getIniKey.p (input 'EMS', input 'Show-Report-Program').

run utils/WinExec.p
    (input return-value + ' ' + cReportFile,
     input 1).
