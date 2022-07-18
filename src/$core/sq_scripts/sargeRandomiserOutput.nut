// ================================================================================
// Base class for randomisers
class sargeRandomiserOutput extends sargeBase
{
	item = null;

	function Init()
	{
		item = getParam("sargeRandomiseObject",0);
		local link = Link.Create(linkkind("Target"), self, item);
		//LinkTools.LinkSetData(link, "sargeRandomiseChance", getParam("sargeRandomiseChance",50));
	}
	
	//Override this
	function OnRandomiserSelected()
	{
		print ("OnRandomiserSelected called!");
	}
}

// ================================================================================
// Various classes for handling what a randomiser should do when chosen - move the object to it's position, put it in a linked container, etc.

class sargeRandomiserOutputPosition extends sargeRandomiserOutput
{
	function OnRandomiserSelected()
	{
		local disablePhysics = getParam("sargeDisablePhysics",FALSE);
		
		print ("moving item " + item + " to position " + Object.Position(self));
		
		Object.Teleport(item, Object.Position(self), Object.Facing(self));
		
		if (disablePhysics)
		{
			print ("disabling physics for " + item);
			Physics.SetGravity(item,0.0);
			Physics.SetVelocity(item,vector(0,0,0));
		}
	}
}

class sargeRandomiserOutputContainer extends sargeRandomiserOutput
{
	function OnRandomiserSelected()
	{
		local container = getParam("sargeContainer",0);
		
		if (container)
		{
			print ("moving item " + item + " to container " + container);
			Link.Create(linkkind("Contains"),container,item);
		}
		else
			print ("sargeContainer not set - not transferring item to container!");
	}
}