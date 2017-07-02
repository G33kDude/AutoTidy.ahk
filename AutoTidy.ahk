
x =
(
a
b
c
)xyz

/*

y =
(
a
b
c
)

*/

;ModelInclude := ModelLine

Token := Tidy(A_LineFile)
MsgBox, % clipboard := Token.Value
ExitApp

Tidy(FilePath)
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
		"BracesForSingleLine": True,
		"Minify": True
	}
	)
	
	; Set the working dir for #Include path resolution
	OldWorkingDir := A_WorkingDir
	SetWorkingDir, % FilePath
	Code := new ModelCode(Context)
	SetWorkingDir, % OldWorkingDir
	
	return Code
}

#Include ModelLine.ahk
#Include ModelCode.ahk
#Include Util.ahk
#Include ModelCmtBlock.ahk
#Include ModelInclude.ahk
#Include Model.ahk
;#Include ModelIndentable.ahk