#NoTrayIcon ; Hide Tray Icon
#include <Constants.au3>
#include <File.au3>

Opt("TrayMenuMode", 3) ; don't show default tray menu items
TraySetClick(16) ; tray meno only on secondary mouse

; Script Filename without extension
$ScriptName = StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0 ,-1)-1)

logger('App: started')

logger('WorkingDir: ' & @WorkingDir)

; prevent multiple instances
$startPID = ProcessExists(@ScriptName)

If $startPID AND $startPID <> @AutoItPID Then
   logger('App: i am already running')
   Exit 1
EndIf

logger('App: tray')

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
		 logger('Tray: Start Browser')
		 Run(@scriptDir & "\caddyCtrl.exe browser", @workingDir)
	  Case $TRAY_EVENT_SECONDARYDOWN
		 ; right click
	  Case $trayStartBrowser
		 logger('Tray: Start Browser')
		 Run(@scriptDir & "\caddyCtrl.exe browser", @workingDir)
	  Case $trayStart
		 logger('Tray: Start')
		 Run(@scriptDir & "\caddyCtrl.exe start", @workingDir)
	  Case $trayStop
		 logger('Tray: Stop')
		 Run(@scriptDir & "\caddyCtrl.exe stop", @workingDir)
	  Case $trayRestart
		 logger('Tray: Restart')
		 Run(@scriptDir & "\caddyCtrl.exe stop", @workingDir)
		 Sleep(500)
		 Run(@scriptDir & "\caddyCtrl.exe start", @workingDir)
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

Func logger($str)
   _FileWriteLog(@ScriptDir & '\logs\' & $ScriptName & '.log', $str)
EndFunc

Func ExitApp($exitcode = 0)
   logger('ExitApp: ' & $exitcode)
   Exit $exitcode
EndFunc