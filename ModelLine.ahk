class ModelLine extends Model
{
	HasContinuation := False
	Continuation := ""
	HasComment := False
	Comment := ""
	Raw := ""
	Line := ""
	
	Value[]
	{
		; TODO: Intelligent whitespace
		Get
		{
			Out := this.Line
			if (this.HasComment && !this.Context.Minify)
				Out .= (this.Line == "" ? "" : " ") "; " Trim(this.Comment, " `t`r`n")
			if this.HasContinuation
				Out .= "`n" this.Continuation
			return Out "`n"
		}
	}
	
	__New(Context, CheckContinuation:=True)
	{
		this.Context := Context
		this.CheckContinuation := CheckContinuation
		this.Parse()
	}
	
	Parse()
	{
		this.Raw := RTrim(this.Context.Code.ReadLine(), "`r`n")
		this.StripLine()
		
		if this.CheckContinuation
			this.GetContinuation()
	}
	
	GetContinuation()
	{
		OriginalLinePos := this.Context.Code.Pos
		
		; Look for the next non-blank line
		while (NextLine.Line == "" && !this.Context.Code.AtEOF())
			NextLine := new ModelLine(this.Context, False)
		
		; Check if it's the start of a continuation section
		if (NextLine.StartsWith("(") && !IsFakeCSOpening(NextLine.Line))
		{
			this.HasContinuation := True
			
			; Look for the end of the continuation section
			Loop
			{
				this.Continuation .= NextLine.Raw "`n"
				
				if this.Context.Code.AtEOF()
					throw Exception("Closing ) not found")
				
				ClosePtr := this.Context.Code.Pos
				NextLine := new ModelLine(this.Context, False)
				
				if NextLine.StartsWith(")")
					break
			}
			
			this.Continuation .= NextLine.Raw
			return
		}
		
		this.Context.Code.Pos := OriginalLinePos
	}
	
	StripLine()
	{
		if (RegExMatch(this.Raw, "^(.*?\s)?;(.*)$", Match))
		{
			this.HasComment := True
			this.Comment := Match2
			this.Line := Trim(Match1, " `t`r`n")
		}
		else
			this.Line := Trim(this.Raw, " `t`r`n")
		
	}
	
	StartsWith(Needle)
	{
		return SubStr(this.Line, 1, StrLen(Needle)) == Needle
	}
	
	EndsWith(Needle)
	{
		return SubStr(this.Line, 1-StrLen(Needle)) == Needle
	}
}

; From ahk2exe
IsFakeCSOpening(tline)
{
	Loop, Parse, tline, %A_Space%%A_Tab%
		if !StrStartsWith(A_LoopField, "Join") && InStr(A_LoopField, ")")
			return true
	return false
}
StrStartsWith(ByRef v, ByRef w)
{
	return SubStr(v, 1, StrLen(w)) = w
}