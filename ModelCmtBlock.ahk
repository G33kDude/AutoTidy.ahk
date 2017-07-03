class ModelCmtBlock extends Model
{
	static OnOwnLine := True
	
	Value[]
	{
		Get
		{
			; TODO: Use indent for close brace
			return "/*" this.Comment "*/"
		}
	}
	
	Parse()
	{
		Loop
		{
			if this.Context.Code.AtEOF()
				return
			
			ClosePtr := this.Context.Code.Pos
			Line := new ModelLine(this.Context, False)
			
			if Line.StartsWith("*/")
				break
			
			this.Comment .= Line.Raw "`n"
		}
		this.Context.Code.Pos := ClosePtr
		this.Context.Code.Read(InStr(Line.Raw, "*/")+1)
	}
}