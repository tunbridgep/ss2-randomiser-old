// ================================================================================
// Anything linked as a target will, if it's a marker, become an output.
// If it's a container, it will become an output and it's contents will become inputs
// If it's just an item, it will become an input
class sargeRandomiserAreaHandler extends sargeBase
{
	inputs = null;
	outputs = null;
	used = null;
	
	//These won't be automatically picked up from inventories
	//But we can still manually link them
	static dontModify = [
		
		-1461,	//Plot Item
		-156,	//key
		-76,	//log
		//-928,	//Wrench
		-12,	//Weapon
		-78,	//Armor
		-128,	//Chemical
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
		used = [];
	
		local targets = [];
		foreach (outLink in Link.GetAll(linkkind("~Target"),self))
		{
			targets.append(sLink(outLink));
		}
		
		ProcessTargets(targets);
		RollEachItem();
	}
	
	function RollEachItem()
	{
		foreach(item in inputs)
		{
			Roll(item,outputs);
		}
	}
	
	function Roll(item, outputs)
	{
		if (outputs.len() == 0)
			outputs = used;
	
		print ("------------------");
		
		local max = outputs.len();
				
		local roll = Data.RandInt(0, max - 1);
		
		print (roll + "/" + max);
		
		print ("Rolled a " + roll + "/" + max + " - " + item + " sent to output " + (roll) + ".");
		
		SendMessage(outputs[roll][0], "OutputSelected",item);
		
		if (!outputs[roll][1])
			used.append(outputs[roll]);
		outputs.remove(roll);
	}
	
	//Apply the necessary metaprops to the right targets
	function ProcessTargets(targets)
	{
		foreach (target in targets)
		{
			local processing = target.dest;
		
			local isMarker = Object.InheritsFrom(processing, "Marker");
			local isContainer = Object.InheritsFrom(processing, -118);
			local isCorpse = Object.InheritsFrom(processing, -379);
			local isInventoryItem = Property.Get(processing, "InvDims","Width");
			
			if (isMarker)
			{
				//if (!Object.HasMetaProperty(processing, "Object Randomiser Output"))
				//	Object.AddMetaProperty(processing, "Object Randomiser Output");
				outputs.append([processing,true]);
			}
			else if (isContainer || isCorpse)
			{
				if (!Object.HasMetaProperty(processing, "Object Randomiser Output Container"))
					Object.AddMetaProperty(processing, "Object Randomiser Output Container");
				ProcessInventory(processing);
				outputs.append([processing,false]);
			}
			else if (isInventoryItem) //Not a container or a marker, it must be some other item.
			{
				inputs.append(processing);
			}
			else
			{
				print ("Trying to do something with a non-inventory item! Stopped, so that you don't acidentally move the walls around etc.");
			}
			
		}
	}
	
	function canModify(item)
	{
		foreach (type in dontModify)
		{
			if (Object.InheritsFrom(item, type) || item == type)
				return false;
		}
		return true;
	}
	
	function ProcessInventory(source)
	{
		foreach (outLink in Link.GetAll(linkkind("Contains"),source))
		{
			local item = sLink(outLink).dest;
			
			if (canModify(item))
			{
				inputs.append(item);
				print ("Adding " + item + " to input list");
			}
		}
	}
}