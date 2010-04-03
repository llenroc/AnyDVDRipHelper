;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         James Manning <james.manning@gmail.com>
; Author:         Adam Pash <adam@lifehacker.com> 
;       ===> Adam did the original DVD Rip that this is just a stripped-down version of
;
; Script Function:
;	Automate DVD ripping process (eject, start ripping on insert) when 
;   used in conjunction with a running instance of AnyDVD Ripper from SlySoft
;
#SingleInstance, force
SetTitleMatchMode, 3
;SendMode, Input

APPName = AnyDVD Rip Helper
Version = 0.1
AnyDVDRipperMainWindow = AnyDVD Ripper
DVDDrive = X: ; TODO: get this from the running AnyDVD Ripper window

GoSub, EnsureAdmin
GoSub, CreateGuiWindow

; infinite loop - the main worker
Loop
{
	GoSub, WaitForAnyDVDWindow
	GoSub, WaitForDiscReady
	GoSub, PerformRip
	GoSub, EjectDisc
}

; from thread at http://www.autohotkey.com/forum/topic19184.html
; first try was from thread at http://www.autohotkey.com/forum/topic45110.html
CreateGuiWindow:
    ; need a GUI window on top in order to make sure Windows sends us the QueryCancelAutoPlay message
	#Persistent
	Gui +AlwaysOnTop -MinimizeBox -MaximizeBox
	SetFormat, Integer, Hex

	MsgNo := DllCall("RegisterWindowMessage", Str, "QueryCancelAutoPlay")
	OnMessage( MsgNo, "QueryCancelAutoPlayHandler" )

	Gui, Add, Text, w400 h25 +0x201 +Border  vMsg

	ShowMessage("Starting up Any DVD Rip Helper")
	
	Gui, Show, x0 y0 , %APPName%
return

GuiClose:
	ExitApp

QueryCancelAutoPlayHandler(wParam, lParam, msg, hwnd)
{
	Return True
}

WaitForDiscReady:
	DriveGet, status, status, %DVDDrive%
	if status = ready
	{
		return
	}
	ShowMessage("DVD Drive " . DVDDrive . " is not yet ready for ripping - status is " . status)

	; loop until something has been inserted
	Loop
	{
		DriveGet, status, status, %DVDDrive%
		if status <> notready
		{
			break
		}
	}
	
	; now something is inserted (status is probably unknown as AnyDVD analyzes it), so we need to both 
	; keep querying and make sure our window is foremost to get the AutoPlay message
	ShowMessage("[Blocked Input] Waiting on DVD Drive " . DVDDrive . " to be ready")
	BlockInput On
	Gui, Show
	Loop
	{

		DriveGet, status, status, %DVDDrive%
		if status = ready
		{
			break
		}
		ShowMessage("[Blocked Input] DVD Drive " . DVDDrive . " is not yet ready for ripping - status is " . status)
		Sleep 500
	}

	; wait a couple more seconds after the drive is ready just to make sure we got (or get) and process the AutoPlay message
	ShowMessage("[Blocked Input] DVD Drive " . DVDDrive . " is now ready for ripping")
	Sleep 2000
	BlockInput Off
return

ShowMessage(message)
{
;	SplashTextOn,,, %message%
;	Progress, x0 y0, %message%, , , Courier New
	GuiControl,, Msg, %message%
}

EjectDisc:
	ShowMessage("Ejecting the DVD")
	Sleep 1000
	Drive, Eject, %DVDDrive%
return

EnsureAdmin:
	if not A_IsAdmin
	{
		DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_AhkPath
				, str, """" . A_ScriptFullPath . """", str, A_WorkingDir, int, 1) ; Last parameter: SW_SHOWNORMAL = 1
		ExitApp
	}
return

Die(message)
{
	Gui, Destroy
	MsgBox, %message%
	ExitApp
}

WaitForAnyDVDWindow:
	ShowMessage("Waiting for window " . AnyDVDRipperMainWindow)
	WinWait, %AnyDVDRipperMainWindow%
	if ErrorLevel
	{
		Die("WinWait timed out waiting for " . APPName . " window " . AnyDVDRipperMainWindow . " - exiting")
	}
return

PerformRip:
	ShowMessage("Telling AnyDVD to start rip")
	; block the user so they do not mess us up as we control the window
	; BlockInput On
	WinActivate, %AnyDVDRipperMainWindow%
	Sleep 500

	; Select Alt-D to invoke the "Copy DVD" button
	; Send, !d

	; above does not work (the D shortcut is not working even thought it is marked as 
	; such in the text of the button) so, instead we will click the button based on its text
	ControlClick, Copy &DVD, %AnyDVDRipperMainWindow%
	; ok, we are done with our actions, the user can do things again
	; BlockInput Off

	; give it 2 seconds to start ripping and change the title
	Sleep 2000
	IfWinExist, %AnyDVDRipperMainWindow%
	{
		Die("Unable to start the ripping process with AnyDVD (old window title still around), exiting")
	}
	
	ShowMessage("Ripping is in progress")

	SetTitleMatchMode, RegEx
	Loop
	{
		IfWinNotExist, AnyDVD \d+`%
		{
			; title no longer has the percentage complete, so we are done
			break
		}

		;ShowMessage("Ripping is still in progress")
		Sleep 1000
	}
	SetTitleMatchMode, 3

	ShowMessage("Ripping is done")
return
