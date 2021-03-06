#NoEnv
SetBatchLines, -1

FileSelectFile, FilePath
if !FilePath
	ExitApp

MsgBox, 4,, Minify? (Click "No" to un-minify)
IfMsgBox, Yes
	Minify := True

Script := Tidy(FilePath, Minify)

MsgBox, 4,, Done! Save to clipboard?
IfMsgBox, Yes
	Clipboard := Script.Value

ExitApp
return

Tidy(FilePath, Minify)
{
	FilePath := Util_GetFullPath(FilePath)
	SplitPath, FilePath, ScriptName, ScriptDir	
	Context :=
	( LTrim Join
	{
		"Code": FileOpen(FilePath, "r"),
		"UseBraces": False,
		"SingleLine": False,
		"IndentLevel": 0,
		"Includes": [FilePath],
		"FirstScriptName": ScriptName,
		"FirstScriptDir": ScriptDir,
		"FirstScriptPath": FilePath,
		"ScriptName": ScriptName,
		"ScriptDir": ScriptDir,
		"ScriptPath": FilePath,
		"IsFirstScript": True,
		"BracesForSingleLine": False,
		"Minify": Minify
	}
	)
	
	; Set the working dir for #Include path resolution
	OldWorkingDir := A_WorkingDir
	SetWorkingDir, % ScriptDir
	Code := new ModelCode(Context)
	SetWorkingDir, % OldWorkingDir
	
	return Code
}

#Include Lib\Model.ahk
#Include Lib\ModelCmtBlock.ahk
#Include Lib\ModelCode.ahk
#Include Lib\ModelElse.ahk
#Include Lib\ModelInclude.ahk
#Include Lib\ModelLabel.ahk
#Include Lib\ModelLine.ahk
#Include Lib\Util.ahk