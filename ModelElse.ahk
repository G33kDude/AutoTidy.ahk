class ModelElse extends Model
{
	Value[]
	{
		Get
		{
			return "else`n" this.Code.Value
		}
	}
	
	Parse()
	{
		LinePtr := this.Context.Code.Pos
		Line := new ModelLine(this.Context.Clone())
		this.Context.Code.Pos := LinePtr
		
		if (!RegExMatch(Line.Line, "i)^else\b(\s*{)?", Match))
			throw Exception("Couldn't parse else block")
		
		Context := this.Context.Clone()
		Context.IndentLevel++
		
		if Match1 ; Has brace
		{
			Context.UseBraces := True
			Context.Code.Read(InStr(Line.Raw, "{"))
		}
		else
		{
			Context.SingleLine := True
			Context.UseBraces := Context.BracesForSingleLine
			Context.Code.Read(InStr(Line.Raw, "else")+3)
		}
		
		this.Code := new ModelCode(Context)
	}
}