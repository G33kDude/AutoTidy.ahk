class ModelInclude extends Model
{
	Model := {Value: ""}
	
	Value[]
	{
		Get
		{
			return this.Model.Value "`n"
		}
	}
	
	Parse()
	{
		Line := new ModelLine(this.Context.Clone())
		
		if !RegExMatch(Line.Line, "i)^#Include(Again)?[ \t]*[, \t]?\s+(.*)$", Match)
			throw Exception("Weird #Include")
		
		IsIncludeAgain := (Match1 = "Again")
		IgnoreErrors := false
		IncludeFile := Match2
		if RegExMatch(IncludeFile, "\*[iI]\s+?(.*)", Match)
			IgnoreErrors := true, IncludeFile := Trim(Match1)
		
		if RegExMatch(IncludeFile, "^<(.+)>$", Match)
			&& (IncFile2 := FindLibraryFile(Match1, this.Context.FirstScriptDir))
		{
			IncludeFile := IncFile2
		}
		else
		{
			StringReplace, IncludeFile, IncludeFile, `%A_ScriptDir`%, % this.Context.FirstScriptDir, All
			StringReplace, IncludeFile, IncludeFile, `%A_AppData`%, %A_AppData%, All
			StringReplace, IncludeFile, IncludeFile, `%A_AppDataCommon`%, %A_AppDataCommon%, All
			StringReplace, IncludeFile, IncludeFile, `%A_LineFile`%, % this.Context.ScriptPath, All
			
			if InStr(FileExist(IncludeFile), "D")
			{
				SetWorkingDir, %IncludeFile%
				return False
			}
		}
		
		IncludeFile := Util_GetFullPath(IncludeFile)
		
		AlreadyIncluded := ahk2exe_InArray(this.Context.Includes, IncludeFile)
		
		if(IsIncludeAgain || !AlreadyIncluded)
		{
			if !AlreadyIncluded
			{
				FileObj := FileOpen(IncludeFile, "r")
				if !FileObj
				{
					if IgnoreErrors
						return False
					else
						throw Exception("Couldn't open file", "#Include", IncludeFile)
				}
				
				this.Context.Includes.Push(IncludeFile)
				
				Context := this.Context.Clone()
				Context.UseBraces := False
				Context.Code := FileObj
				SplitPath, IncludeFile, ScriptName, ScriptDir
				Context.ScriptName := ScriptName
				Context.ScriptDir := ScriptDir
				Context.ScriptPath := IncludeFile
				
				this.Model := new ModelCode(Context)
			}
		}
	}
}

; ahk2exe
FindLibraryFile(name, ScriptDir)
{
	libs := [ScriptDir "\Lib", A_MyDocuments "\AutoHotkey\Lib", A_ScriptDir "\..\Lib"]
	p := InStr(name, "_")
	if p
		name_lib := SubStr(name, 1, p-1)
	
	for each,lib in libs
	{
		file := lib "\" name ".ahk"
		IfExist, %file%
		return file
		
		if !p
			continue
		
		file := lib "\" name_lib ".ahk"
		IfExist, %file%
		return file
	}
}

ahk2exe_InArray(Array, Value)
{
	for k, v in Array
		if (v = Value)
			return true
	return false
}

Util_GetFullPath(path)
{
	VarSetCapacity(fullpath, 260 * (!!A_IsUnicode + 1))
	if DllCall("GetFullPathName", "str", path, "uint", 260, "str", fullpath, "ptr", 0, "uint")
		return fullpath
	else
		return ""
}