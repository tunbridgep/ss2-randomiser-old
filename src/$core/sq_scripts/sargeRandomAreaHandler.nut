// ================================================================================
// Anything linked as a target will, if it's a marker, become an output.
// If it's a container, it will become an output and it's contents will become inputs
// If it's just an item, it will become an input
class sargeRandomiserAreaHandler extends sargeBase
{
	inputs = null;
	outputs = null;
	used = null;
	
	//useful when moving things like bodies or crates around, or making specific lists for weapons etc
	unsafe = false;
	
	//useful when ???
	readonly = false;
	
	//useful when you want to add various specific linked items to certain inventories, such as power cells, without having any items taken
	writeonly = false;
	
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
		
		unsafe = getParam("allowUnsafe",false);
		readonly = getParam("containerReadOnly",false);
		writeonly = getParam("containerWriteOnly",false);
	
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
				outputs.append([processing,true]);
			}
			else if (isContainer || isCorpse)
			{
				if (!Object.HasMetaProperty(processing, "Object Randomiser Output Container"))
					Object.AddMetaProperty(processing, "Object Randomiser Output Container");
					
				if (!writeonly)
					ProcessInventory(processing);
				if (!readonly)
					outputs.append([processing,false]);
			}
			else if (isInventoryItem || unsafe) //Not a container or a marker, it must be some other item.
			{
				inputs.append(processing);
			}
			else
			{
				print ("Trying to do something with non-inventory item " + processing + "! Stopped, so that you don't acidentally move the walls around etc.");
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
			
			if (unsafe || canModify(item))
			{
				inputs.append(item);
				print ("Adding " + item + " to input list");
			}
		}
	}
}