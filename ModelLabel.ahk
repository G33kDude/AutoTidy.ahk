class ModelLabel extends Model
{
	static OnOwnLine := True
	
	Value[]
	{
		Get
		{
			return this.Name ":`n"
		}
	}
	
	Parse()
	{
		Line := new ModelLine(this.Context.Clone())
		if !RegExMatch(Line.Line, "^(" ModelCode.RECustomName "):$", Match)
			throw Exception("Couldn't parse label " Line.Raw)
		this.Name := Match1
	}
}