class Model
{
	; Define a value property
	; This property should return valid AHK code
	;Value[]
	;{
		;Get
		;{
			;return this.text
		;}
	;}
	
	__New(Context)
	{
		this.Context := Context
		RetVal := this.Parse()
		if (RetVal != "")
			return RetVal
	}
	
	; Define a Parse method
	; This method should handle parsing of the context
	;Parse()
	;{
		;return
	;}
}