// ================================================================================
// Anything linked as a target will, if it's a marker, become an output.
// If it's a container, it will become an output and it's contents will become inputs
// If it's just an item, it will become an input
class sargeRandomiserAreaHandler extends sargeBase
{
	inputs = null;
	outputs = null;
	
	static OBJECT = 0;
	static OBJECT_TYPE = 1;
	
	static IS_MARKER = 0;
	static IS_CONTAINER = 1;
	static IS_CORPSE = 2;
	static IS_INVENTORY_ITEM = 3;
	static IS_OTHER = 4;
	
	//useful when moving things like bodies or crates around
	unsafe = null;
	
	//For each object that is linked to the input, add their original location as a possible output
	//(Objects in the world only)
	//This is mainly used when randomising specific items when the goal is for them to be able to also spawn at their original location
	useLocations = null;
	
	//Make sure every possible output is processed before processing any a second time
	//This stops the "clumping up" of some items onto outputs, which leads to a decent number of empty outputs as well
	//This is mainly used for things like hackable crates to ensure that every crate always gets at least some loot, and it's less clumped
	//For high value loot this is important as we don't want RNG to play as much of a factor, or punish people for opening a crate just to get nothing
	fairDistribution = null;
	
	//useful when ???
	//readonly = false;
	
	//useful when you want to add various specific linked items to certain inventories, such as power cells, without having any items taken
	writeonly = false;
	
	//These won't be automatically picked up from inventories
	//Unless unsafe is set.
	//But we can still manually link them
	static dontModify = [
		
		-1461,	//Plot Item
		-156,	//key
		-76,	//audio logs
		//-928,	//Wrench
		-12,	//Weapon
		-78,	//Armor
		-99,	//Implants
		-218,	//Organs
		-436,	//Cheeseborger
		-71,	//Recycler
		//-70,	//Device			
	];
	
	function Init()
	{
		//Have to do this here because squirrel is shit
		inputs = [];
		outputs = [];
		
		unsafe = getParam("allowUnsafe",false);
		fairDistribution = getParam("fairDistribution",false);
		useLocations = getParam("useCurrentPositions",false);
		writeonly = getParam("noAutoAddInventory",false);
		
		print ("writeonly:" + writeonly);
			
		ProcessTargets();
				
		if (outputs.len() > 0 && inputs.len() > 0)
		{
			RandomiseItems();
		}
		else if (outputs.len() == 0)
		{
			print("Randomiser Error: No outputs defined ("+ ShockGame.GetArchetypeName(self) + ")");
		}
		else
		{
			print("Randomiser Error: No inputs defined ("+ ShockGame.GetArchetypeName(self) + ")");
		}
	}
	
	//Adds each item from the input array to a corresponding output.
	function RandomiseItems()
	{
		inputs = Array_Shuffle(inputs);
		outputs = Array_Shuffle(outputs);
			
		local currentInputInd = 0;
		
		//Iterate through each input, finding the first valid position to put it intp. If there are none, do nothing (which will usually leave it where it started)
		foreach (input in inputs)
		{
			local index = GetFirstValidOutput(input);
			if (index >= 0)
			{
				local output = outputs[index];
				HandleOutput(input,output);
			
				outputs.remove(index);
				
				//Don't want physical objects to overlap.
				if (output[OBJECT_TYPE] == IS_MARKER)
					continue;
					
				//Randomise it's position in the array. Adds some more randomness and allow objects to "clump up",
				//but also leaves more empty outputs
				if (index < outputs.len() - 5 && !fairDistribution)
				{
					local newIndex = Data.RandInt(index + 3, outputs.len());
					outputs.insert(newIndex,output);
				}
				else
					outputs.append(output);
			}
		}
	}
	
	function GetFirstValidOutput(input)
	{
		foreach (index,output in outputs)
		{
			if (IsOutputValidForInput(output,input))
				return index;
		}
		return -1;
	}
		
	//Actually perform the item placement
	function HandleOutput(input,output)
	{
		local item = input[OBJECT];
	
		//Add to output we selected
		if (output[OBJECT_TYPE] == IS_MARKER)
		{
			local disablePhysics = Object.HasMetaProperty(output[OBJECT],"Object Randomiser - Disable Physics");
			MoveObjectToPos(item,output[OBJECT],0,disablePhysics,IsContained(item));
		}
		else if (output[OBJECT_TYPE] == IS_CONTAINER || output[OBJECT_TYPE] == IS_CORPSE)
		{
			AddItemToContainer(item,output[OBJECT]);
		}
	}
	
	//Determines if an input item is valid
	//This is NOT checked for items linked manually,
	//as it is assumed these were intentional. Instead, it
	//only runs when auto-randomising containers and inventories,
	function IsInputValid(item,owner)
	{
		//Prevent stripping of various items
		if (Object.HasMetaProperty(item,"Object Randomiser - Dont Strip"))
		{
			return false;
		}	
	
		//Ensure we don't randomise certain problematic item types
		foreach (type in dontModify)
		{
			if (Object.InheritsFrom(item, type) || item == type)
				return false;
		}
		
		return true;
	}
	
	//Determines if an output is valid for a given input
	function IsOutputValidForInput(output,input)
	{			
		//prevent duplicate items if a container doesn't want them
		if (Object.HasMetaProperty(output[OBJECT],"Object Randomiser - No Duplicates"))
		{
			if (HasItemOfType(input[OBJECT],output[OBJECT]))
			{
				//print ("Has duplicate items!");
				return false;
			}
		}
		
		//Enforce container type checks
		
		//Hypo only
		if (Object.HasMetaProperty(output[OBJECT],"Object Randomiser - Only Hypos") && !Object.InheritsFrom(input[OBJECT],-51))
		{
			//print ("Trying to add a non-hypo item " + ShockGame.GetArchetypeName(input[OBJECT]) + "(" + Object.Archetype(input[OBJECT]) + ") to a hypo-only output!");
			return false;
		}
		
		//Hypo or Ammo only
		else if (Object.HasMetaProperty(output[OBJECT],"Object Randomiser - Only Hypos And Ammo"))
		{
			if (!Object.InheritsFrom(input[OBJECT],-51) && !Object.InheritsFrom(input[OBJECT],-30))
			//print ("Trying to add a non-hypo or ammo item " + ShockGame.GetArchetypeName(input[OBJECT]) + "(" + Object.Archetype(input[OBJECT]) + ") to a hypo and ammo only output!");
			return false;
		}
		return true;
	}
	
	//Get data for an object and classify it into an input or an output
	//OUTPUT ARRAY FORMAT:
	//[Item, Type]
	//INPUT ARRAY FORMAT:
	//[Item, Type]
	function ProcessObject(processing)
	{
		local isMarker = Object.InheritsFrom(processing, "Marker");
		local isContainer = Object.InheritsFrom(processing, -118);
		local isCorpse = Object.InheritsFrom(processing, -379);
		local isInventoryItem = Property.Get(processing, "InvDims","Width") || Object.InheritsFrom(processing, -157);
				
		if (isMarker)
		{
			outputs.append([processing,IS_MARKER]);
		}
		else if (isContainer)
		{
			if (!writeonly)
				ProcessInventory(processing);
			outputs.append([processing,IS_CONTAINER]);
		}
		else if (isCorpse)
		{
			if (!writeonly)
				ProcessInventory(processing);
			outputs.append([processing,IS_CORPSE]);
		}
		else if (isInventoryItem) //Not a container or a marker, it must be some other item.
		{
			inputs.append([processing,IS_INVENTORY_ITEM]);
			if (useLocations && !IsContained(processing))
			{
				print ("Using local locations... Adding marker");
				local marker = CreateMarker(Object.Position(processing),Object.Facing(processing));
				ProcessObject(marker);
			}
		}
		else if (unsafe)
		{
			inputs.append([processing,IS_OTHER]);
		}
		else
		{
			print ("Trying to do something with non-inventory item " + processing + "! Stopped, so that you don't acidentally move the walls around etc.");
			return;
		}
		//print ("Processed item " + processing);
	}
			
	//Process all items in an inventory, adding them to input array
	function ProcessInventory(source)
	{
		foreach (outLink in Link.GetAll(linkkind("Contains"),source))
		{
			local item = sLink(outLink).dest;
			
			if (unsafe || IsInputValid(item,source))
				ProcessObject(item);
		}
	}
	
	//Take target links and add them to input and output arrays
	function ProcessTargets()
	{
		foreach (outLink in Link.GetAll(linkkind("~Target"),self))
		{
			local processing = sLink(outLink).dest;	
			ProcessObject(processing);
		}
	}
}