                   &if {&bf_libera_15_posicoes} = yes &then
                        assign c-formato = ">>>>>>>>9999999". /* Formato de 15 posi»„es */
                   &else
                        assign c-formato = ">>>9999999". /* Formato de 10 posi»„es */
                   &endif
                   
                   &IF '{&bf_mat_versao_ems}' >= '2.062' &THEN
                        if substring(tt-docum-est-nova.nro-docto,LENGTH(c-formato) + 1, 16 - LENGTH(c-formato)) <> "" then /*Alterado em 04/01/2010*/
                    
                        RUN pi-gera-erro (INPUT 36151, 
                                          INPUT "", 
                                          INPUT length(c-formato)).
                   ELSE DO:
                       ASSIGN l-erro-numero = NO.
                       /* Para o Brasil o nœmero do documento deve ser num²rico */
                       do i-x = 1 to LENGTH(left-trim(tt-docum-est-nova.nro-docto)): /*Alterado em 04/01/2010*/
                       
                           if lookup(substri(left-trim(tt-docum-est-nova.nro-docto),i-x,1), "1,2,3,4,5,6,7,8,9,0") = 0 then do:
                               ASSIGN l-erro-numero = yes. 
                               next.
                           end.
                       end.

                       IF l-erro-numero THEN
                           RUN pi-gera-erro (INPUT 
                                             36151, 
                                             INPUT "", 
                                             INPUT length(c-formato)).
                   end.
                   
                   &else
                        if substring(tt-docum-est.nro-docto,LENGTH(c-formato) + 1, 16 - LENGTH(c-formato)) <> "" then do: /*Alterado em 04/01/2010*/
                                
                            assign i-msg  = 36151          
                                   c-msg  = ""
                                   c-char = string(length(c-formato)).                     
                            run pi-gera-erro.
                            if l-voltar then next.
                        end.
                        else do:

                        
                            assign l-erro-numero = no.
                            
                            /* Para o Brasil o n£mero do documento deve ser num‚rico */
                            do i-x = 1 to LENGTH(left-trim(tt-docum-est.nro-docto)): /*Alterado em 04/01/2010*/
                            
                                if lookup(substri(left-trim(tt-docum-est.nro-docto),i-x,1), "1,2,3,4,5,6,7,8,9,0") = 0 then do:
                                    assign l-erro-numero = yes. 
                                    next.    
                                end.
                            end. 
                            
                            if l-erro-numero then do:
                                assign i-msg  = 36151
                                c-msg  = "" 
                                c-char = string(length(c-formato)).
                                
                                run pi-gera-erro.
                                if l-voltar then next.
                            end.
                        end.        
                        
                        if LENGTH(tt-docum-est.nro-docto) > LENGTH(c-formato) then do:
                            
                            assign i-msg  = 18247 
                                   c-msg  = "" 
                                   c-char = string(length(c-formato)).
                            run pi-gera-erro.
                            if l-voltar then next.           
                        end.
                   &endif 


