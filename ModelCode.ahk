class ModelCode extends Model
{
	static REContinuedExpression := "i)^\s*(&&|OR|AND|\.|\,|\|\||:|\?)"
	static RECustomName := "[a-zA-Z_][a-zA-Z0-9_]*" ; Not really true
	static REIndentable := "
	( LTrim Join
	i)^\b(
		Catch|else|for|Finally|if|IfEqual|IfExist|
		IfGreater|IfGreaterOrEqual|IfInString|
		IfLess|IfLessOrEqual|IfMsgBox|IfNotEqual|
		IfNotExist|IfNotInString|IfWinActive|IfWinExist|
		IfWinNotActive|IfWinNotExist|Loop|Try|while|
		Get|Set
	`)\b
	)"
	
	Literals := []
	LinePtr := -1
	LineNumber := 0
	IndentLevel := 0
	
	Value[]
	{
		Get
		{
			; TODO: Better SingleLine handling. This is broken
			;if this.SingleLine
			;{
				;if this.Context.UseBraces
				;{
					;return "{`n"
					;. Repeat("`t", this.Context.IndentLevel) . this[1].Value
					;. Repeat("`t", this.Context.IndentLevel-1) "}`n"
				;}
				;return "`t" this[1].Value
			;}
			
			Out := ""
			if this.Context.UseBraces
				Out .= "{"
			Loop, % this.Length()
			{
				TmpVal := this[A_Index].Value
				if (Trim(TmpVal, " `t`r`n") && !this.Context.Minify) ; Don't show whitespace for blank lines
					Out .= Repeat("`t", this.Context.IndentLevel)
				Out .= TmpVal
			}
			if this.Context.UseBraces
				Out .= (this.Context.Minify ? "" : Repeat("`t", this.Context.IndentLevel-1)) "}"
			return Out
		}
	}
	
	Parse()
	{
		this.SingleLine := this.Context.SingleLine
		this.Context.SingleLine := False
		
		; Set the WorkingDir. Important for includes.
		; TODO: move into init function?
		if this.Context.IsFirstScript
		{
			OldWorkingDir := A_WorkingDir
			SetWorkingDir, % this.Context.ScriptDir
		}
		
		while this.GetNextLine()
			if this.ProcessLine()
				break
		
		; Restore old WorkingDir if necessary
		if OldWorkingDir
			SetWorkingDir, %OldWorkingDir%
	}
	
	; Returns end of block flag
	ProcessLine()
	{
		; Blank line
		if (this.Line.Line == "")
		{
			if !this.Context.Minify
				this.Push(this.Line)
			return
		}
		
		; Is a comment block
		if this.Line.StartsWith("/*")
		{
			this.Context.Code.Pos := this.LinePtr
			this.Context.Code.Read(InStr(this.Line.Raw, "/*")+1)
			
			if (this.Context.Minify)
				new ModelCmtBlock(this.Context.Clone()) ; Read it but don't save it
			else
				this.Push(new ModelCmtBlock(this.Context.Clone()))
			return
		}
		
		; Known block (Takes shortcuts with continued expressions)
		if (this.Line.Line ~= this.REIndentable)
		{
			; OTB
			if this.Line.EndsWith("{") {
				; TODO: Better idea
				this.Line.Line := Trim(SubStr(this.Line.Line, 1, -1), " `t`r`n")
				this.Push(this.Line)
				
				Context := this.Context.Clone()
				Context.IndentLevel++
				Context.UseBraces := True
				this.Push(new ModelCode(Context))
				return this.SingleLine
			}
			
			this.Push(this.Line)
			
			; Next line brace
			loop
			{
				this.GetNextLine()
				
				if this.Line.StartsWith("{")
				{
					this.Context.Code.Pos := this.LinePtr
					this.Context.Code.Read(InStr(this.Line.Raw, "{"))
					
					Context := this.Context.Clone()
					Context.IndentLevel++
					Context.UseBraces := True
					this.Push(new ModelCode(Context))
					return this.SingleLine
				}
				
				if (this.Line.Line ~= this.REContinuedExpression)
					continue
				
				break
			}
			
			; Single line no brace
			this.Context.Code.Pos := this.LinePtr
			Context := this.Context.Clone()
			Context.SingleLine := True
			Context.IndentLevel++
			Context.UseBraces := this.Context.BracesForSingleLine
			this.Push(new ModelCode(Context))
			return this.SingleLine
		}
		
		; Other blocks
		if (this.Line.StartsWith("{"))
		{
			; Put the cursor after the open brace
			this.Context.Code.Pos := this.LinePtr
			this.Context.Code.Read(InStr(this.Line.Raw, "{"))
			
			Context := this.Context.Clone()
			Context.IndentLevel++
			Context.UseBraces := True
			this.Push(new ModelCode(Context))
			return this.SingleLine
		}
		
		; End of block
		if (this.Line.StartsWith("}"))
		{
			this.Context.Code.Pos := this.LinePtr
			this.Context.Code.Read(InStr(this.Line.Raw, "}"))
			return True
		}
		
		; #Includes
		if (this.Line.Line ~= "i)^#Include(Again)?\s")
		{
			this.Context.Code.Pos := this.LinePtr
			
			; Will be false if it's just changing include dir
			; Will be false if *i and doesn't exist
			if (Include := new ModelInclude(this.Context.Clone()))
				this.Push(Include)
			return this.SingleLine
		}
		
		; Some other kind of line
		this.Push(this.Line)
		
		return this.SingleLine
	}
	
	GetNextLine()
	{
		if this.Context.Code.AtEOF()
			return False
		
		this.LinePtr := this.Context.Code.Pos
		this.Line := new ModelLine(this.Context.Clone())
		
		return True
	}
	
	PeekLine()
	{
		LinePtr := this.Context.Code.Pos
		Line := new ModelLine(this.Context.Code)
		this.Context.Code.Pos := LinePtr
		return Line
	}
}