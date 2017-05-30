#include <GUIConstantsEx.au3>
#include <Process.au3>
#include <Constants.au3>

GUICreate("Simple Service", 450, 180)

;Edit the "FileInstall" function before compiling

$gSvcDisplayNameGroup = GUICtrlCreateGroup("Service Display Name",10,5,130,40)
$gSvcDisplayName = GUICtrlCreateInput("CustomService",15,20,120,20)
$gAutostartCheckbox = GUICtrlCreateCheckbox("Autostart Service On Boot", 10, 50)
$gStartNowCheckbox = GUICtrlCreateCheckbox("Start Service After Install", 10, 75)
$gBrowseButton = GUICtrlCreateButton("Browse", 370,110,60)
$gExePathGroup = GUICtrlCreateGroup("Path to Executable",10,100,350,40)
$gExePath = GUICtrlCreateInput("",15,115,340,20)
$gInstallButton = GUICtrlCreateButton("Install", 10, 150, 60)
$gCancelButton = GUICtrlCreateButton("Cancel", 80, 150, 60)

$sExePath = ""

GuiCtrlSetState($gAutostartCheckbox,$GUI_CHECKED)
GuiCtrlSetState($gStartNowCheckbox,$GUI_CHECKED)
GUISetState(@SW_SHOW)

While 1
  $msg = GUIGetMsg()

  Select
    Case $msg = $GUI_EVENT_CLOSE
      	ExitLoop
		
	Case $msg = $gCancelButton
		ExitLoop

	Case $msg = $gBrowseButton
		_BrowseToExe()
	
	Case $msg = $gInstallButton
		If Not FileExists(GuiCtrlRead($gExePath)) Then 
			MsgBox(4096,"Invalid EXE","Please select an existing/valid executable file")
		Else
			$sSvcDisplayName = GuiCtrlRead($gSvcDisplayName)
			_InstallService()
			MsgBox(0, "Congratulations", $sSvcDisplayName & " Service Installed Successfully!")
			
		ExitLoop
		EndIf
	EndSelect
WEnd 

Func _BrowseToExe()
	If Not IsDeclared('sExePath') Then Dim $sExePath
	If GuiCtrlRead($gExePath) = "" Then $sDefaultPath = @ProgramFilesDir
	If GuiCtrlRead($gExePath) <> "" Then $sDefaultPath = GuiCtrlRead($gExePathGroup)
	
		$sExePath = FileOpenDialog ( 'Find Your EXE', $sDefaultPath,'All (*.*)')
			If Not @error Then
			$sExePathArray = StringSplit($sExePath,'\',1)
			$sExeName = StringTrimRight($sExePathArray[$sExePathArray[0]],4)
			GuiCtrlSetData($gExePath,$sExePath)
			If GuiCtrlRead($gSvcDisplayName) = 'CustomService' Then GuiCtrlSetData($gSvcDisplayName,$sExeName)
			EndIf
EndFunc
	
;Write the info to the Registry
Func _InstallService()
If GuiCtrlRead($gAutostartCheckbox) = 1 Then $sStartupOption = "Automatic"
If GuiCtrlRead($gAutostartCheckbox) = 0 Then $sStartupOption = "Manual"
If Not FileExists('c:\windows\srvany.exe') Then  FileInstall("Z:\Storage\scripts\JerryScripts\targetfiles\srvany.exe",'c:\windows\srvany.exe',1)

$objWMIService = ObjGet('winmgmts:' & '{impersonationLevel=impersonate}!\\.\root\cimv2')
	$objService = $objWMIService.Get('Win32_BaseService')
	$errReturn = $objService.Create($sSvcDisplayName,$sSvcDisplayName,'c:\windows\srvany.exe',16,1, _
	$sStartupOption,false,'LocalSystem','')

RegWrite('HKLM\SYSTEM\CurrentControlSet\Services\' & $sSvcDisplayName & '\Parameters')
RegWrite('HKLM\SYSTEM\CurrentControlSet\Services\' & $sSvcDisplayName & '\Parameters', 'AppDirectory', 'REG_SZ', @WorkingDir)
RegWrite('HKLM\SYSTEM\CurrentControlSet\Services\' & $sSvcDisplayName & '\Parameters', 'Application', 'REG_SZ', $sExePath)

If GuiCtrlRead($gStartNowCheckbox) = 1 Then _RunDos('Net start ' & '"' & $sSvcDisplayName & '"')
EndFunc
