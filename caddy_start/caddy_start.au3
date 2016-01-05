#NoTrayIcon ; Hide Tray Icon
#include <Constants.au3>
#include <File.au3>

Global $caddyPID, $phpPID, $caddyStdout, $caddyHost, $caddyPort

Opt("TrayMenuMode", 3) ; don't show default tray menu items
TraySetClick(16) ; tray meno only on secondary mouse

; Script Filename without extension
$ScriptName = StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0 ,-1)-1)

; prevent multiple instances
$startPID = ProcessExists(@ScriptName)

If $startPID AND $startPID <> @AutoItPID Then
   logger('App: i am already running')
   Exit 1
EndIf

logger('App: started')

logger('WorkingDir: ' & @WorkingDir)

; Commandline Usage: (start|stop|restart)
if $CmdLine[0] > 0 Then
   logger('CmdArg: > 0')

   If $CmdLine[1] == "browser" Then
	  logger('CmdArg: browser')
	  StartBrowser()
   EndIf

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

   Exit 0
EndIf

; Code below runs if app is started as gui app
logger('App: is tray app')


;~ Tray Menu Definition
Local $trayStartBrowser = TrayCreateItem("Start Browser")
TrayCreateItem("") ; --------------------------------------
Local $trayStatus = TrayCreateItem("Caddy (Stopped)")
TrayCreateItem("") ; --------------------------------------
Local $trayStart = TrayCreateItem("Start")
Local $trayStop = TrayCreateItem("Stop")
Local $trayRestart = TrayCreateItem("Restart")
TrayCreateItem("") ; --------------------------------------
Local $trayExit = TrayCreateItem("Exit")

; Show TrayIcon
TraySetIcon(@ScriptDir & "\lib\caddy_icon.ico")
TraySetState($TRAY_ICONSTATE_SHOW)

; check if processes already running
processCheck()

$hTimer = TimerInit()

While 1
   Switch TrayGetMsg()
	  Case $TRAY_EVENT_PRIMARYDOWN
		 ; left click
		 StartBrowser()
	  Case $TRAY_EVENT_SECONDARYDOWN
		 ; right click
	  Case $trayStartBrowser
		 logger('Tray: Start Browser')
		 StartBrowser()
	  Case $trayStart
		 logger('Tray: Start')
		 StartCaddy()
	  Case $trayStop
		 logger('Tray: Stop')
		 StopCaddy()
	  Case $trayRestart
		 logger('Tray: Restart')
		 StopCaddy()
		 Sleep(500)
		 StartCaddy()
	  Case $trayExit
		 logger('Tray: Exit App')
		 ExitApp()
   EndSwitch

   $hTimerDiff = TimerDiff($hTimer)
   if $hTimerDiff > 500 Then
	  $hTimer = TimerInit()

	  ; Status Update
	  ; Caddy
	  processCheck()

   EndIf

WEnd

; Open Browser with URL+Port
Func StartBrowser()
   $caddyPort = EnvGet("CADDY_PORT")
   $caddyHostStart = @IPAddress1
   logger('StartBrowser: http://' & $caddyHostStart & ':' & $caddyPort & '/')
   ShellExecute('http://' & $caddyHostStart & ':' & $caddyPort & '/')
EndFunc

Func processCheck()
   $caddyPID = ProcessExists('caddy.exe')

   if $caddyPID <> 0 Then
	  TrayItemSetText($trayStatus, "Caddy (Running)")
	  TrayItemSetState($trayStart, $TRAY_DISABLE)
	  TrayItemSetState($trayStop, $TRAY_ENABLE)
	  TraySetIcon(@ScriptDir & "\lib\caddy_icon_up.ico")
   Else
	  TrayItemSetText($trayStatus, "Caddy (Stopped)")
	  TrayItemSetState($trayStart, $TRAY_ENABLE)
	  TrayItemSetState($trayStop, $TRAY_DISABLE)
	  TraySetIcon(@ScriptDir & "\lib\caddy_icon_down.ico")
   EndIf
EndFunc

; Caddy functions
Func StartCaddy()
   $caddyPID = ProcessExists('caddy.exe')
   if $caddyPID Then
	  logger('an existing caddy.exe was fund (PID: ' & $caddyPID & ')')
   Else
	  $caddyPID = Run(@ScriptDir & '\caddy.exe', @WorkingDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  logger('StartCaddy: PID ' & $caddyPID & ' started')
   EndIf
   ; PHP wird von caddy über startup in CaddyFile gestartet
   ; $phpPID = Run(@ScriptDir & '\caddy.exe', @WorkingDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
EndFunc

Func StopCaddy()
   ;if ProcessClose('caddy.exe') Then ; beendet programm nicht sauber sodass caddy php nicht selbst beendet
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
