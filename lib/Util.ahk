InArray(Array, Value)
{
	for k, v in Array
		if (Array == Value)
			return True
	return False
}

Repeat(Val, Times)
{
	return StrReplace(Format("{:0" Round(Times) "}", ""), "0", Val)
}