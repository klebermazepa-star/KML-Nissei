/**
*
* Declara o 'forward' da funcao 'child'. Note que nao eh
* exatamente um forward, mas o equivalente dessa clausula
* para invocar a funcao de uma super-procedure. Para mais
* detalhes de 'child', veja system/Child.p.
*
*/
function child returns handle in super.
function handleSuper returns handle (input cProcedureToFind as character) in super.
function isa returns logical (input objectToCompare as handle, input classInstance as handle ) in super.
