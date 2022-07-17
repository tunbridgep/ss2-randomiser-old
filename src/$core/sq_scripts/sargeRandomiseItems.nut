// ================================================================================
// Base class for randomisers
class sargeRandomiserBase extends SqRootScript
{
	// fetch a parameter or return default value
	// blatantly stolen from RSD
	function getParam(key, defVal)
	{
		return key in userparams() ? userparams()[key] : defVal;
	}
	
	function OnSim()
	{
		if (!GetData("Setup"))
		{
			local timer = Data.RandFlt0to1() * 0.1;
			print ("timer set for " + timer);
			SetOneShotTimer("RandomiseTimer", timer);
			SetData("Setup",TRUE);
		}
	}
	
	function OnTimer()
	{
		if (message().name == "RandomiseTimer")
		{
			print ("timer finished, rolling");
			Randomise();
		}
	}
	
	function Randomise()
	{
		local item = getParam("sargeRandomiseObject",0);
		OnRollSuccess(item);
	}
	
	/*
	function Randomise()
	{	
		local item = getParam("sargeRandomiseObject",0);
		
		//if (Link.AnyExist(linkkind("Teleport"), 0, item)) //We are using a "link" to signal to our other randomisers not to roll
		//{
		//	print ("Already Rolled successfully");
		//	return;
		//}
	
		local chance = getParam("sargeRandomiseChance",0);				
		local roll = Data.RandInt(1, 100);
			
		if (roll <= chance)
		{
			print ("Roll success! (" + roll + "/" + chance + ")");
			OnRollSuccess(item);
			//Link.Create(linkkind("Teleport"), self, item);
		}
		else
		{
			print ("Roll failed! (" + roll + "/" + chance + ")");
		}
	}
	*/
	
	//extend this
	function OnRollSuccess(item)
	{
	}
}


// ================================================================================
// Handles randomising the position of items based on various marker positions
class sargeRandomisePosition extends sargeRandomiserBase
{
	function OnRollSuccess(item)
	{
		//Remove links in case it was added to a container
		foreach (outLink in Link.GetAll(linkkind("~Contains"),item))
		{
			local realLink = sLink(outLink);
			print ("Link found: " + outLink);
			Link.Destroy(outLink);
		}
	
		local disablePhysics = getParam("sargeDisablePhysics",0);
	
		if (disablePhysics)
			Physics.SetGravity(item,0);
		Object.Teleport(item, Object.Position(self), Object.Facing(self));
		print ("item " + item + " was moved to " + Object.Position(self) + " " + Object.Facing(self));
	}
}

// ================================================================================
// Handles randomising whether or not an item should be linked to a container
class sargeRandomiseContainer extends sargeRandomiserBase
{
	function OnRollSuccess(item)
	{
		local container = getParam("sargeContainer",0);
	
		Link.Create(linkkind("Contains"), container, item);
	
		print ("item " + item + " was moved to container " + container);
	}
}