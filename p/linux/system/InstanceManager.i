/**
* INCLUDE:
*   system/InstanceManager.i
*
* FINALIDADE:
*   Executa o gerenciador de instancias de objetos se o mesmo ainda nao esta
*   em execucao para a sessao e registra o programa invocador (atencao com o
*   uso de THIS-PROCEDURE) para que o mesmo receba a Error.p como super procedure.
*
* NOTA:
*   Voce pode usar o pre-processor REGISTER com os valores TRUE ou FALSE para
*   indicar se o programa onde essa include foi colocada deve (TRUE) ou
*   nao (FALSE) receber as instancias de Error.p e outras classes de
*   infra-estrutura. Nao declarar o pre-processor eh o mesmo que declara-lo com
*   TRUE. Veja as 3 possibilidades disponiveis:
*     {system/InstanceManager.i}
*        Executa o "singleton" de gerenciamento de classes e adiciona a
*        this-procedure algumas super-procedures de infra-estrutura, como
*        tratamento de erros e afins.
*     
*     {system/InstanceManager.i &register=true}
*        Idem ao anterior.
*     
*     {system/InstanceManager.i &register=false}
*        Apenas executa o "singleton", mas sem adicionar nenhuma classe de
*        infra-estrutura como super-procedure do programa corrente (aquele em
*        que essa include foi colocada).
*
* IMPORTANTE:
*   O uso mais comum de {system/InstanceManager.i &register=false} eh em UPCs.
*/

if not valid-handle(ghInstanceManager) then
    run system/InstanceManager.p persistent.

&if defined(register) &then
    if {&register} then do:
        run registerInstance in ghInstanceManager(this-procedure).
    end.
&elseif defined(register) = 0 &then
    run registerInstance in ghInstanceManager(this-procedure).
&endif
