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
	
	//Shuffles an array
	//https://en.wikipedia.org/wiki/Knuth_shuffle
	function Array_Shuffle(shuffle = [])
	{
		for (local position = shuffle.len() - 1;position >= 0;position--)
		{
			local val = Data.RandInt(0, position);
			local temp = shuffle[position];
			shuffle[position] = shuffle[val];
			shuffle[val] = temp;
		}		
				
		return shuffle;
	}
	
	//Check if an object has an item of a type in it's inventory
	function HasItemOfType(type,container)
	{
		//handle concretes
		type = (type > 0) ? Object.Archetype(type) : type;
	
		foreach (outLink in Link.GetAll(linkkind("Contains"),container))
		{
			local invitem = sLink(outLink).dest;
			
			if (Object.Archetype(invitem) == type)
				return true;
		}
		return false;
	}
	
	function IsContained(item)
	{
		return Link.AnyExist(linkkind("~Contains"),item);
	}
	
	function AddItemToContainer(item,container)
	{
		foreach (outLink in Link.GetAll(linkkind("~Contains"),item))
			Link.Destroy(outLink);
		Link.Create(linkkind("Contains"),container,item);
		
		print ("object " + item + " moved to container " + container);
	}
	
	function MoveObjectToPos(item,position,facingoffset,disablePhysics,shouldClone)
	{
		local debugString = "object " + item + " ";
	
		if (shouldClone)
		{
			local item2 = Object.Create(item);
			Object.Destroy(item);
			item = item2;
			debugString += "cloned to new object " + item + " and ";
		}
		
		local pos = Object.Position(position);
		local facing = Object.Facing(position) + facingoffset;
		
		Object.Teleport(item, pos, facing);
		
		debugString += "moved to " + pos + ", " + facing;
		
		if (disablePhysics)
		{
			Property.Remove(item,"PhysType");
			Property.Remove(item,"PhysAttr");
			debugString += " (physics disabled)";
		}
		
		print (debugString);
	}
	
	//Creates a marker at a specified position
	function CreateMarker(position,heading)
	{
		local marker = Object.Create(-327);
		Object.Teleport(marker, position, heading);
		return marker;
	}
	
	//overwrite this
	function Init()
	{
	}
}