#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%

TraySetupAndShortCut()
If (A_Args[1] == "")
	CheakUpdateScripts()

#include *i Internal\Include_Scripts_auto-execute.ahk ;Load script with _A.ahk endings

Return

#Include *i Internal\Include_Scripts.ahk

TraySetupAndShortCut() {
	If (Not A_IsCompiled) {
		If FileExist("icon.ico") {
			Menu, Tray, Icon, icon.ico
			If Not FileExist("ScriptLoader.lnk")
				FileCreateShortcut, %A_AhkPath%, ScriptLoader.lnk, %A_ScriptDir%,	%A_ScriptFullPath%, copy to Startup folder to start on boot, %A_ScriptDir%\icon.ico
		}
		Else {
			If Not FileExist("ScriptLoader.lnk")
				FileCreateShortcut, %A_AhkPath%, ScriptLoader.lnk, %A_ScriptDir%,	%A_ScriptFullPath%, copy to Startup folder to start on boot
		}
	}
	Menu, Tray, add, Force Update Scripts, UpdateScripts,
	Menu, Tray, add, Cheak Update Scripts, CheakUpdateScripts,
	Menu, Tray, add, Open Scripts Folder, OpenScriptsFolder,
}

CheakUpdateScripts() {
	RestoresOrCreateFiles()
	If FindScriptChanges()
		UpdateScripts()
}

RestoresOrCreateFiles() {
	If Not FileExist("Scripts") {
		FileCreateDir, Scripts
		If A_IsCompiled {
			#Include *i Internal\Install_Scripts.ahk
		}
	}
	FileCreateDir, Internal
	If (A_IsCompiled) {
		#include *i Internal\built-in_Compiler.ahk
	}
	If (Not FileExist("Internal\DISABLE built-in_Compiler.ahk") && Not FileExist("Internal\built-in_Compiler.ahk"))
		FileAppend, FileInstall`, Internal\built-in_Compiler.ahk`, Internal\built-in_Compiler.ahk`r`nFileCreateDir`, Compiler`r`nFileInstall`, Compiler\Ahk2Exe.exe`, Compiler\Ahk2Exe.exe, Internal\DISABLE built-in_Compiler.ahk
}

FindScriptChanges() {
	If A_IsCompiled
		FileGetTime, ScriptIncludeTime, ScriptLoader.exe
	Else
		FileGetTime, ScriptIncludeTime, Internal\Include_Scripts.ahk
	If ErrorLevel
		Return True
	FileGetTime, ScriptChangeTime, Scripts
	If (ScriptIncludeTime > ScriptChangeTime) {
		Loop, Files, Scripts\*, DFR
		{
			FileGetTime, ScriptChangeTime, %A_LoopFilePath%
			If (ScriptChangeTime > ScriptIncludeTime)
				Return True
		}
		Return False
	}
	Return True
}

UpdateScripts() {
	If A_IsCompiled {
		File_Install := FileOpen("Internal\Install_Scripts.ahk", "w")
		If FileExist("icon.ico")
			File_Install.Write("FileInstall, icon.ico, icon.ico`r`n")
		Loop Files, Scripts\*, RD
			File_Install.Write("FileCreateDir, " A_LoopFilePath "`r`n")
	}
	File_Include := FileOpen("Internal\Include_Scripts.ahk", "w")
	Loop Files, Scripts\*.ahk, R
	{
		File_Install.Write("FileInstall, "A_LoopFilePath ", " A_LoopFilePath "`r`n")
		File_Include.Write("#include *i "A_LoopFileFullPath "`r`n")
	}
	File_Install.close()
	File_Include.close()
	File_Include_AE := FileOpen("Internal\Include_Scripts_auto-execute.ahk", "w")
	Loop Files, Scripts\*_A.ahk, R
		File_Include_AE.Write("#include *i "A_LoopFileFullPath "`r`n")
	File_Include_AE.close()
	ReloadScriptLoader()
}

ReloadScriptLoader() {
	If A_IsCompiled {
		FileInstall, ScriptLoader.ahk, ScriptLoader.ahk
		If FileExist("Compiler\Ahk2Exe.exe")
			Ahk2Exe =Compiler\Ahk2Exe.exe
		Else
			Ahk2Exe := RegExReplace(A_AhkPath, "^(.+\\)[^\\]+$", "$1Compiler\Ahk2Exe.exe")
		If FileExist("icon.ico")
			Run, "%comspec%" /c ""%Ahk2Exe%" /in "ScriptLoader.ahk" /icon "icon.ico" & start """" "ScriptLoader.exe" 0", , Hide
		Else
			Run, "%comspec%" /c ""%Ahk2Exe%" /in "ScriptLoader.ahk" & start """" "ScriptLoader.exe" 0", , Hide
		ExitApp
	}
	Else
		Run, "%A_AhkPath%" /r "%A_ScriptName%" 0, , Hide
}

OpenScriptsFolder(){
	Run, "Scripts"
}
