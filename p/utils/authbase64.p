/* ---------------------------------------------------------------------------
   PLSYS 
   authbase64.p - Programa que converte as informacoes de usuário e senha para 
                  base64 para ser utilizado na autenticação em servidores SMTP
                  A string resultado so poderá ser utilizada para autenticações
                  do tipo PLAIN (Ver especificações de autenticação na RFC 2554)
                
   Autor: Marcio Fuckner - 02/04/2003
   --------------------------------------------------------------------------- */
   
def input  parameter c-user as char no-undo.
def input  parameter c-pass as char no-undo.
def output parameter c-string-base64 as char no-undo.
                                                     
def var c-temp-file as char no-undo.
def var c-temp-file-64 as char no-undo.

def stream st-temp-file.
def stream binary-s.
def stream base64-s.

assign c-temp-file    = session:temp-dir + "/encode64a" + string(TIME,"99999") + ".tmp".
assign c-temp-file-64 = session:temp-dir + "/encode64b" + string(TIME,"99999") + ".tmp".

output stream st-temp-file to value(c-temp-file).
   
put stream st-temp-file unformatted c-user.
put stream st-temp-file control null(1).
put stream st-temp-file unformatted c-user.
put stream st-temp-file control null(1).
put stream st-temp-file unformatted c-pass.

output stream st-temp-file close.

run pi-tobase64(c-temp-file,c-temp-file-64).

input stream st-temp-file from value(c-temp-file-64).

repeat:
    import stream st-temp-file unformatted c-string-base64.
end.

output stream st-temp-file close.

os-delete value(c-temp-file).
os-delete value(c-temp-file-64).

procedure pi-tobase64:

   def input param pc-infile as char no-undo.
   def input param pc-outfile as char no-undo.

   def var lr-in as raw no-undo.

   input stream binary-s from value(pc-infile).
   output stream base64-s to value(pc-outfile).

   length(lr-in) = 57.

   repeat:
      import stream binary-s unformatted lr-in.
      if length(lr-in) = 0 then leave.
      put stream base64-s unformatted substr(string(lr-in),7,76) skip.
   end.

   input stream binary-s close.
   output stream base64-s close.
end.
