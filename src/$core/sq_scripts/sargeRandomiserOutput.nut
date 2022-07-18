// ================================================================================
// Base class for randomisers
class sargeRandomiserOutput extends sargeBase
{
	item = null;

	function Init()
	{
		item = getParam("sargeRandomiseObject",0);
		if (item)
		{
			local link = Link.Create(linkkind("Target"), self, item);
		}
		else
		{
			print ("sargeRandomiseObject not set - output will not function!");
		}
		//LinkTools.LinkSetData(link, "sargeRandomiseChance", getParam("sargeRandomiseChance",50));
	}
	
	//Remove any contains links, so that items can actually exist in the world
	function RemoveContainsLinks()
	{
		//If item is contained, we need to clone it and delete the old one
		if (Link.AnyExist(linkkind("~Contains"),item))
		{
			Object.Destroy(item);
			item = Object.Create(item);
		}
		//foreach (outLink in Link.GetAll(linkkind("~Contains"),item))
			//Link.Destroy(outLink);
	}
	
	function DisablePhysics()
	{
		//item.SetProperty("PhysType","None");
		//Property.Set(item,"PhysType","Type",0);
		//Physics.SetGravity(item,0.0);
		//Physics.SetVelocity(item,vector(0,0,0));
		Property.Remove(item,"PhysType");
		Property.Remove(item,"PhysAttr");
	}
	
	//Override this
	function OnOutputSelected()
	{
		RemoveContainsLinks();
		//print ("OnOutputSelected called!");
	}
}

// ================================================================================
// Various classes for handling what a randomiser should do when chosen - move the object to it's position, put it in a linked container, etc.


//When chosen, move the target object to this objects current position - used for positional randomness
class sargeRandomiserOutputPosition extends sargeRandomiserOutput
{
	function OnOutputSelected()
	{
		base.OnOutputSelected();
		local disablePhysics = getParam("sargeDisablePhysics",FALSE);
		
		print ("moving item " + item + " to position " + Object.Position(self));
		
		if (disablePhysics)
		{
			DisablePhysics();
			print ("disabling physics for " + item);
		}
		
		Object.Teleport(item, Object.Position(self), Object.Facing(self));
	}
}

//When chosen, move the target object to this objects linked container - used for positional randomness to allow moving objects into crates etc
class sargeRandomiserOutputContainer extends sargeRandomiserOutput
{
	function OnOutputSelected()
	{
		base.OnOutputSelected();
		local container = getParam("sargeContainer",0);
		
		if (container)
		{
			print ("moving item " + item + " to container " + container);
			Link.Create(linkkind("Contains"),container,item);
		}
		else
			print ("sargeContainer not set - output will not function!");
	}
}

//When chosen, swap the target and the swapobject - used for things like moving sim units and replacing them with generic computer terminals
class sargeRandomiserOutputSwap extends sargeRandomiserOutput
{
	function OnOutputSelected()
	{
		base.OnOutputSelected();
		local swap = getParam("sargeSwapObject",0);
		
		if (swap)
		{
			print ("swapping item " + item + " with swap object " + swap);
			
			local item_position = Object.Position(item);
			local item_facing = Object.Facing(item);
			
			local swap_position = Object.Position(swap);
			local swap_facing = Object.Facing(swap);
			
			Object.Teleport(item, swap_position, swap_facing);
			Object.Teleport(swap, item_position, item_facing);
			
		}
		else
			print ("sargeSwapObject not set - output will not function!");
	}
}