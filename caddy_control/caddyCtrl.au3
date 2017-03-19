#NoTrayIcon ; Hide Tray Icon
#include <Constants.au3>
#include <File.au3>

Global $caddyPID

; Script Filename without extension
$ScriptName = StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0 ,-1)-1)

logger('App: started')

logger('WorkingDir: ' & @WorkingDir)

; Commandline Usage: (start|stop|restart|browser)
if $CmdLine[0] > 0 Then
   logger('CmdArg: > 0')

   If $CmdLine[1] == "start" Then
	  logger('CmdArg: start')
	  StartCaddy()
   EndIf

   If $CmdLine[1] == "stop" Then
	  logger('CmdArg: stop')
	  StopCaddy()
   EndIf

   If $CmdLine[1] == "restart" Then
	  logger('CmdArg: restart')
	  StopCaddy()
	  Sleep(500)
	  StartCaddy()
   EndIf

   If $CmdLine[1] == "browser" Then
	  logger('CmdArg: browser')
	  StartBrowser()
   EndIf

   Exit 0
Else
   logger('no CmdArg: start')
   StartCaddy()
   Exit 0
EndIf


; Open Browser with URL+Port
Func StartBrowser()
   $caddyPort = EnvGet("CADDY_PORT")
   ;$caddyHostStart = @IPAddress1
   $caddyHostStart = @ComputerName & ".local"

   logger('StartBrowser: http://' & $caddyHostStart & ':' & $caddyPort & '/')
   ShellExecute('http://' & $caddyHostStart & ':' & $caddyPort & '/')
EndFunc

; Caddy functions
Func StartCaddy()
   $caddyPID = ProcessExists('caddy.exe')
   if $caddyPID Then
	  logger('an existing caddy.exe was fund (PID: ' & $caddyPID & ')')
   Else
	  $caddyPID = Run(@ScriptDir & '\caddy.exe -conf ' & @ScriptDir & '\Caddyfile', @WorkingDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  logger('StartCaddy: PID ' & $caddyPID & ' started')
   EndIf

EndFunc

Func StopCaddy()
   ; INFO: ProcessClose beendet caddy nicht sauber sodass caddy php nicht selbst beendet
   if RunWait("taskkill /IM caddy.exe", @ScriptDir, @SW_HIDE) Then
	  logger('StopCaddy: PID ' & $caddyPID & ' stopped')
   Else
	  logger('StopCaddy: PID ' & $caddyPID & ' not stopped @error: ' & @error)
   EndIf
   ProcessClose('php-cgi.exe')
EndFunc

Func logger($str)
   _FileWriteLog(@ScriptDir & '\logs\' & $ScriptName & '.log', $str)
EndFunc

Func ExitApp($exitcode = 0)
   logger('ExitApp: ' & $exitcode)
   Exit $exitcode
EndFunc