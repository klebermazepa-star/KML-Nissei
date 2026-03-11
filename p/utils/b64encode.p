/*-----------------------------------------------------------------------*
File........: b64engine6b.p
Version.....: 1.0 - 6 July 2001
Description : Really, Really Fast Base64 Conversion Engine
Input Param : 
                cInputFile  - char - Input filename to convert
                cOutputFile - char - Output filename to convert

Output Param: <none>
Author......: Peter J. Graybash III (pjg3@luther-rose.com)
Copyright...: FreeFramework 2001 - http://www.freeframework.org
Created.....: 6 July 2001
Notes.......: Written in response to a PEG-wide programming contest in Late June
                / Early July of 2001.  This was the fastest (and winning) entry.
                FFW owes a free sizzling steak dinner to Peter Graybash!!!
Modified:
            20010709: add no-* to input from (just being tidy...)
                change email address in header
            20010710: borrowed the read-1/write-6 trick and tweaked it!
                changed EOL to '~r~n' (CR/LF)
                added :U to string constants

*-----------------------------------------------------------------------*/

/** Parameter Definitions **/
def input param cInputFile  as char no-undo.
def input param cOutputFile as char no-undo.

/** Working Variables **/
def var rrr as raw  no-undo.
def var ccc as char no-undo.
def var iii as int  no-undo.

/** Open Input & Output File Streams **/
input  from value(cInputFile) binary no-echo no-map no-convert.
output to   value(cOutputFile).

/** Magic File Encoder : Thanks to Andrew Maizels, et.al. **/
length(rrr) = 342.
repeat:
  import unformatted rrr.
  assign
      ccc = string(rrr)
      iii = length(ccc).
  put control
      (if iii gt   7 then substring(ccc,   7, 76, 'RAW':U) + '~r~n':U else '':U) +
      (if iii gt  83 then substring(ccc,  83, 76, 'RAW':U) + '~r~n':U else '':U) +
      (if iii gt 159 then substring(ccc, 159, 76, 'RAW':U) + '~r~n':U else '':U) +
      (if iii gt 235 then substring(ccc, 235, 76, 'RAW':U) + '~r~n':U else '':U) +
      (if iii gt 311 then substring(ccc, 311, 76, 'RAW':U) + '~r~n':U else '':U) +
      (if iii gt 387 then substring(ccc, 387, 76, 'RAW':U) + '~r~n':U else '':U).
end.
length(rrr) = 0.

/** Close Input & Output File Streams **/
input  close.
output close.


/* That's all, folks! -SES */
