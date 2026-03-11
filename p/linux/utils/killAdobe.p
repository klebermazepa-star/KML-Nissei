&GLOB PROCESS_QUERY_INFORMATION 1024
&GLOB PROCESS_VM_READ 16
&GLOB MAX_PATH 260
&GLOB TH32CS_SNAPPROCESS 2
&GLOB PROCESS_TERMINATE 1
&GlOB BOOL long 

define variable lpId          as memptr  no-undo.
define variable cbNeeded      as integer no-undo.
define variable ReturnValue   as integer no-undo.
define variable PID           as integer no-undo.
define variable i             as integer no-undo.
define variable viPID         as integer no-undo.
define variable ProcessHandle as integer no-undo.
 
procedure EnumProcesses external "psapi.dll" :
    define input  parameter lpIdProcess as long.
    define input  parameter cb          as long.
    define output parameter cbNeeded    as long.
    define return parameter ReturnValue as long.
end procedure.
 
procedure EnumProcessModules external "psapi.dll" :
    define input  parameter hProcess    as long.
    define input  parameter lphModule   as long.  /* lp to array of module handles */
    define input  parameter cb          as long.
    define output parameter cbNeeded    as long.
    define return parameter ReturnValue as long.
end procedure.
 
procedure GetModuleBaseNameA external "psapi.dll" :
    define input  parameter hProcess      as long.
    define input  parameter hModule       as long.
    define output parameter lpBaseName    AS CHAR.
    define input  parameter nSize         as long.
    define return parameter nReturnedSize as long.
end procedure.

procedure OpenProcess external "kernel32.dll" :
    define input  parameter dwDesiredAccess as long.
    define input  parameter bInheritHandle  as long.
    define input  parameter dwProcessId     as long.
    define return parameter hProcess        as long.
end procedure.
 
procedure CloseHandle external "kernel32.dll" :
    define input  parameter hObject     as long.
    define return parameter ReturnValue as long.
end procedure.

procedure TerminateProcess external "kernel32.dll" :
    define input  parameter hProcess  as long.
    define input  parameter uExitCode as long.
    define return parameter retval    as long.
end procedure.

function GetProcessName returns character(input PID as integer) :
    define variable hProcess      as integer   no-undo.
    define variable cbNeeded      as integer   no-undo.
    define variable lphMod        as memptr    no-undo.
    define variable szProcessName as character no-undo.
    define variable ReturnValue   as integer   no-undo.

    run OpenProcess({&PROCESS_QUERY_INFORMATION} + {&PROCESS_VM_READ},
                    0,
                    PID,
                    output hProcess).

    szProcessName = "[unknown]" + fill(" ", {&MAX_PATH}).

    if hProcess ne 0 then do:
        set-size (lphMod) = 4. /* need only one hMod  */

        run EnumProcessModules(hProcess,
                               get-pointer-value(lphMod),
                               get-size(lphMod),
                               output cbNeeded,
                               output ReturnValue).

        if ReturnValue ne 0 then do:
            run GetModuleBaseNameA(hProcess,
                                   get-long(lphMod,1),
                                   output szProcessName,
                                   length(szProcessName),
                                   output ReturnValue).
            szProcessName = substring(szProcessName,1,ReturnValue).
            set-size (lphMod) = 0.
        end.

        run CloseHandle(hProcess, output ReturnValue).
    end.
    return trim(szProcessName).
end function.

set-size(lpId) = 1000.
 
run EnumProcesses(get-pointer-value(lpId),
                  get-size(lpID),
                  output cbNeeded,
                  output ReturnValue).
 
do i = 1 to cbNeeded / 4 :
    PID = get-long(lpID, 4 * (i - 1) + 1).
    if GetProcessName(PID) = 'Acrobat.exe' or 
       GetProcessName(PID) = 'Acrord32.exe' then
        viPID = integer(PID).
end.
 
set-size(lpId) = 0.

if viPID <> 0 then do:
    run OpenProcess({&PROCESS_TERMINATE}, 
                    0, 
                    viPID, 
                    output ProcessHandle).
    
    if ProcessHandle ne 0 then do:
        run TerminateProcess(ProcessHandle, 
                             0, 
                             output ReturnValue).

        run CloseHandle(ProcessHandle, 
                        output ReturnValue).
    end.
end.
