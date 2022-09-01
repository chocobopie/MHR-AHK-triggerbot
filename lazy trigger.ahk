#NoEnv                        ;https://www.autohotkey.com/docs/commands/_NoEnv.htm
#SingleInstance, Force        ;https://www.autohotkey.com/docs/commands/_SingleInstance.htm
#Persistent                   ;https://www.autohotkey.com/docs/commands/_Persistent.htm
#InstallMouseHook             ;https://www.autohotkey.com/docs/commands/_InstallMouseHook.htm
#include CGDipSnapshot.ahk    ;https://www.autohotkey.com/docs/commands/_Include.htm
#KeyHistory, 0                ;https://www.autohotkey.com/docs/commands/_KeyHistory.htm
SetBatchLines, -1             ;https://www.autohotkey.com/docs/commands/SetBatchLines.htm
ListLines, Off                ;https://www.autohotkey.com/docs/commands/ListLines.htm
SendMode, Input               ;https://www.autohotkey.com/docs/commands/SendMode.htm
SetTitleMatchMode Fast        ;https://www.autohotkey.com/docs/commands/SetTitleMatchMode.htm
Process, Priority, , High     ;https://www.autohotkey.com/docs/commands/Process.htm
SetWorkingDir %A_ScriptDir%   ;https://www.autohotkey.com/docs/commands/SetWorkingDir.htm
OnExit DoBeforeExit           ;https://www.autohotkey.com/docs/commands/OnExit.htm
 
 
;Check if script is running as administrator, if not, run it as such
if (A_IsAdmin = 0)
{
	try
	{
		if (A_IsCompiled)
		{
			;https://www.autohotkey.com/docs/commands/Run.htm
			Run *RunAs "%A_ScriptFullPath%" /restart
		}
		else
		{
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
	}
	ExitApp
}
 
 
;GUI variables
;https://www.autohotkey.com/docs/commands/SetExpression.htm (:=)
recoil_offset  := 8
counter_a	   := 0
counter_b	   := 0
recoil_status  := "Disabled"
trigger_status := "Disabled"
GuiVisible     := True
 
;Snapshot 1
SNAPSHOT_WIDTH_A  := 1
SNAPSHOT_HEIGHT_A := 1
SNAPSHOT_X_A 	  := 960
SNAPSHOT_Y_A 	  := 540
;Snapshot 2
SNAPSHOT_WIDTH_B  := 1
SNAPSHOT_HEIGHT_B := 1
SNAPSHOT_X_B 	  := 165
SNAPSHOT_Y_B 	  := 147



 
;https://www.autohotkey.com/docs/Variables.htm#new
snap1 			:= new CGdipSnapshot(SNAPSHOT_X_A,SNAPSHOT_Y_A,SNAPSHOT_WIDTH_A,SNAPSHOT_HEIGHT_A)
snap2 			:= new CGdipSnapshot(SNAPSHOT_X_B,SNAPSHOT_Y_B,SNAPSHOT_WIDTH_B,SNAPSHOT_HEIGHT_B)
snapshot_colour := new CColor(0xB0AA60)  
snapshot_colour2 := new CColor(0x969731)
snapshot_colour4 := new CColor(0xBF6D19)
snapshot_colour5 := new CColor(0xD98B38)
snapshot_colour3 := new CColor(0x746F2B)
 
if (FileExist("TD.txt"))
{
	;https://www.autohotkey.com/docs/commands/FileRead.htm
	FileRead, readfile, TD.txt
 
	if ((readfile < 100) AND (readfile > -100))
	{
		recoil_offset := readfile
	}
	else if (ErrorLevel)
	{
		recoil_offset := 8
	}
}
else
{
	recoil_offset := 8
}
 
 
Gui, +AlwaysOnTop +ToolWindow -Caption +Owner +LastFound +E0x20
;+AlwaysOnTop  - https://www.autohotkey.com/docs/commands/Gui.htm#Options
;+ToolWindow   - +ToolWindow avoids a taskbar button and an alt-tab menu item.
;-Caption      - https://www.autohotkey.com/docs/commands/Gui.htm#Color
;+Owner        - https://www.autohotkey.com/docs/commands/Gui.htm#Options
;+LastFound    - Make the GUI window the last found window for use by the line below.
;+E0x20        - (WS_EX_TRANSPARENT) https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles

 
;Recoil-Reduce line of GUI
;https://www.autohotkey.com/docs/commands/Gui.htm#Font
;c<colour> - Text colour
;s<size>   - Font size
;bold      - Changes font style to bold
;q<number> - Text rendering quality
;  0 = DEFAULT_QUALITY	      Appearance of the font does not matter.
;  1 = DRAFT_QUALITY	      Appearance of the font is less important than when the PROOF_QUALITY value is used.
;  2 = PROOF_QUALITY	      Character quality of the font is more important than exact matching of the logical-font attributes.
;  3 = NONANTIALIASED_QUALITY Font is never antialiased, that is, font smoothing is not done.
;  4 = ANTIALIASED_QUALITY	  Font is antialiased, or smoothed, if the font supports it and the size of the font is not too small or too large.
;  5 = CLEARTYPE_QUALITY	  Windows XP and later: If set, text is rendered (when possible) using ClearType antialiasing method.
 
;Triggerbot line of GUI
 
;debug gui
;Gui, Font, cWhite s20 bold q4, Arial
;timervalue := 0
;global timervalue
;Gui, Add, Text, x10 w10 h40 vtimer, 0
;change gui height to 140 to see
 
;Set +LastFound with 200/255 transparency
;NoActivate - Unminimizes or unmaximizes the window, if necessary. The window is also shown without activating it.
 
 
Hotkey, IfWinActive, AHK_EXE MonsterHunterRise.exe
Hotkey, *~LButton, Off	;Toggle hotkey off - starting state
 
 
#UseHook  							   ;https://www.autohotkey.com/docs/commands/_UseHook.htm
#IfWinActive, AHK_EXE MonsterHunterRise.exe  ;https://www.autohotkey.com/docs/commands/_IfWinActive.htm
 
;Triggerbot Hotkey
5::
{
	returned := Toggler(counter_b, 2)
	tex := returned[1]
	col := returned[2]
	GuiControl, +%col%, trigger_status		   ;set colour
	GuiControl, 	  , trigger_status, %tex%  ;set text
	counter_b += 1
}
return
 
 
;Recoil-Reduce Hotkey
;https://www.autohotkey.com/docs/Hotkeys.htm#Symbols
;* - Fire the hotkey even if extra modifiers are being held down
;~ - When the hotkey fires, its key's native function will not be blocked (hidden from the system) '
*~LButton::
{
	while GetKeyState("LButton")
	{
		DllCall("mouse_event", uint, 1, int, 0, int, recoil_offset, uint, 0, int, 0)
		Sleep, 25
	}
}
return
 
 
;Triggerbot Procedure
Trigger:
{
	Loop
	{
		if (Mod(counter_b, 2) = 0)
		{
			return
		}
		if WinActive("AHK_EXE MonsterHunterRise.exe")
		{
			while (GetKeyState("RButton", "P") = 1)
			{
				snap1.TakeSnapshot()
				if (snap1.PixelSnap[0,0].Compare(snapshot_colour, 15))
				{
					DllCall("mouse_event", "UInt", 0x02) ; left mouse button down
					Sleep, 1  							 ; enough time to register click in-game
					DllCall("mouse_event", "UInt", 0x04) ; left mouse button up
					;timervalue += 1
					;GuiControl,, timer, %timervalue%
					continue
				}
				if (snap1.PixelSnap[0,0].Compare(snapshot_colour2, 15))
				{
					DllCall("mouse_event", "UInt", 0x02) ; left mouse button down
					Sleep, 1  							 ; enough time to register click in-game
					DllCall("mouse_event", "UInt", 0x04) ; left mouse button up
					;timervalue += 1
					;GuiControl,, timer, %timervalue%
					continue
				}
				if (snap1.PixelSnap[0,0].Compare(snapshot_colour4, 15))
				{
					DllCall("mouse_event", "UInt", 0x02) ; left mouse button down
					Sleep, 1  							 ; enough time to register click in-game
					DllCall("mouse_event", "UInt", 0x04) ; left mouse button up
					;timervalue += 1
					;GuiControl,, timer, %timervalue%
					continue
				}
				if (snap1.PixelSnap[0,0].Compare(snapshot_colour5, 15))
				{
					DllCall("mouse_event", "UInt", 0x02) ; left mouse button down
					Sleep, 1  							 ; enough time to register click in-game
					DllCall("mouse_event", "UInt", 0x04) ; left mouse button up
					;timervalue += 1
					;GuiControl,, timer, %timervalue%
					continue
				}
				snap2.TakeSnapshot()
				if (snap2.PixelSnap[0,0].Compare(snapshot_colour3, 15))
				{
					DllCall("mouse_event", "UInt", 0x02) ; left mouse button down
					Sleep, 1  							 ; enough time to register click in-game
					DllCall("mouse_event", "UInt", 0x04) ; left mouse button up
					;timervalue += 1
					;GuiControl,, timer, %timervalue%
					continue
				}
				;re := snap.PixelSnap[0,0].RGB
			}
		}
		else
		{
			Sleep, 800
		}
	}
}
return
 
 
Toggler(counter, option)
{
	if (Mod(counter, 2) = 0)
	{
		fstatus := "Enabled"
		colour := "clime"
		SoundBeepToggle(8000,2000)
		if (option = 2)
		{
			SetTimer, Trigger, -0
		}
	}
	else
	{	
		fstatus := "Disabled"
		colour := "cred"
		SoundBeepToggle(200,200)
	}
	return [fstatus, colour]
}
#IfWinActive  ;https://www.autohotkey.com/docs/commands/_IfWinActive.htm#Basic_Operation
 
 
DoBeforeExit:
{
	FileDelete, TD.txt
	FileAppend, %recoil_offset%, TD.txt
	FileSetAttrib, +H, TD.txt
	ExitApp
}
 
 
;Function to play SoundBeep with passed variables
SoundBeepToggle(freq,qur)
{
	;https://www.autohotkey.com/docs/commands/SoundBeep.htm
	SoundBeep, %freq%, %dur%
}
return
 
 
;Control shift h
;Toggle Hide GUI
;https://www.autohotkey.com/docs/Hotkeys.htm#Symbols
;^ - Ctrl
;+ - Shift
^+h::
{
	if (GuiVisible = True)
	{
		GuiVisible := False
		Gui, Hide
	}
	else
	{
		Gui, Show, NoActivate
		Reload  ;Allows GUI to be re-displayed over a window that took priority
	}
}
return