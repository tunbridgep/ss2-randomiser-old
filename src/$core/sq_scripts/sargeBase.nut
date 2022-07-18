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