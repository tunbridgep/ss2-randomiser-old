// ================================================================================
// Base class for everything, contains mainly utility functions
class sargeBase extends SqRootScript
{
	// fetch a parameter or return default value
	// blatantly stolen from RSD
	function getParam(key, defVal)
	{
		return key in userparams() ? userparams()[key] : defVal;
	}
	
	// fetch an array of parameters
	// This is not complete - it will find values that aren't in the actual array
	// for instance, if you have myValue0, myValue1 they will be added correctly,
	// but myValueWhichIsReallyLong will also be added.
	// This needs to be updated to check that the only remaining parts after the name are numbers.
	function getParamArray(name,defVal = null)
	{
		local array = [];
		foreach(key,value in userparams())
		{			
			if (key.find(name) == 0)
				array.append(value);
		}
		
		if (array.len() == 0 && defVal != null)
			array.append(defVal);
		
		return array;
	}
	
	//Add an "init" function which is only ever called once
	function OnSim()
	{
		if (!GetData("Setup"))
		{
			Init();
			SetData("Setup",TRUE);
		}
	}
	
	//overwrite this
	function Init()
	{
	}
}