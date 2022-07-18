// ================================================================================
// Base class for randomisers
class sargeRandomiserOutput extends sargeBase
{
	//If an item has a contains link, it should be cloned so that it actually works when placed in the world
	function CloneContainedItem(item)
	{
		//If item is contained, we need to clone it and delete the old one
		if (Link.AnyExist(linkkind("~Contains"),item))
		{
			local item2 = Object.Create(item);
			Object.Destroy(item);
			print (item + " cloned to new item " + item2);
			item = item2;
		}
		return item;
	}
	
	function DisablePhysics(item)
	{
		Property.Remove(item,"PhysType");
		Property.Remove(item,"PhysAttr");
		print ("disabling physics for " + item);
	}
	
	function RemoveContainsLinks(item)
	{
		foreach (outLink in Link.GetAll(linkkind("~Contains"),item))
			Link.Destroy(outLink);
	}
	
	function OnOutputSelected()
	{
		local item = message().data;
	
		local container = getParam("sargeContainer",false);
		local swap = getParam("sargeSwapObject",0);
		local create = getParam("sargeCreateObject",false);
		
		if (container) //Specify that an object should be moved to a container
		{
			print ("moving item " + item + " to container " + self);
			RemoveContainsLinks(item);
			Link.Create(linkkind("Contains"),self,item);
		}
		else if (swap) //Swap the positions of 2 objects
		{
			print ("swapping item " + item + " with swap object " + swap);
			
			local item_position = Object.Position(item);
			local item_facing = Object.Facing(item);
			
			local swap_position = Object.Position(swap);
			local swap_facing = Object.Facing(swap);
			
			Object.Teleport(item, swap_position, swap_facing);
			Object.Teleport(swap, item_position, item_facing);
			
		}
		else if (create)
		{
			print ("creating item from " + item + " at position " + Object.Position(self));
			item = Object.Create(item);
			Object.Teleport(item, Object.Position(self), Object.Facing(self));
		}
		else
		{
			item = CloneContainedItem(item);
			print ("moving item " + item + " to position " + Object.Position(self));
			Object.Teleport(item, Object.Position(self), Object.Facing(self));
		}
	
		if (getParam("sargeDisablePhysics",FALSE))
			DisablePhysics(item);
		
		print ("OnOutputSelected called!");
	}
}