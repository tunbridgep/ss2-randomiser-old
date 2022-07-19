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
		
		unsafe = getParam("allowUnsafe",false);
		
		ProcessTargets();
		
		if (outputs.len() > 0 && inputs.len() > 0)
		{
			RandomiseItems();
		}
		else
		{
			print("Randomiser Error: No inputs or outputs defined");
		}		
	}
	
	//Adds each item from the input array to a corresponding output.
	function RandomiseItems()
	{
		inputs = Array_Shuffle(inputs);
		outputs = Array_Shuffle(outputs);
			
		local output_pointer = 0;
		
		//Get each item, keep looping through outputs until you find a valid one, or you get back to where you were
		foreach(input in inputs)
		{
			
			local lastPointer = output_pointer;
			local output;
			
			//print ("new object processing: " + input[OBJECT]);
		
			//keep finding outputs until we have a valid one, or we run out
			do
			{		
				output = outputs[output_pointer];
			
				output_pointer++;
				if (output_pointer >= outputs.len())
					output_pointer = 0;
			}
			while (!IsOutputValidForInput(output,input) && lastPointer != output_pointer);

			HandleOutput(input,output);
			
		}
	}
	
	//Actually perform the item placement
	function HandleOutput(input,output)
	{
		local item = input[OBJECT];
	
		//Add to output we selected
		if (output[OBJECT_TYPE] == IS_MARKER)
		{
			MoveObjectToPos(item,output[OBJECT],false,IsContained(item));
		}
		else if (output[OBJECT_TYPE] == IS_CONTAINER || output[OBJECT_TYPE] == IS_CORPSE)
		{
			AddItemToContainer(item,output[OBJECT]);
		}
	}
	
	//Determines if an output is valid for a given input
	function IsOutputValidForInput(output,input)
	{
		//return true;
		//prevent duplicate items if a container doesn't want them
		if (Object.HasMetaProperty(output[OBJECT],"Object Randomiser  - No Duplicates"))
		{
			if (HasItemOfType(input[OBJECT],output[OBJECT]))
			{
				print ("Has duplicate items!");
				return false;
			}
		}
		
		//Enforce container type checks
		if (Object.HasMetaProperty(output[OBJECT],"Object Randomiser  - Only Hypos") && Object.Archetype(input[OBJECT]) != -51)
		{
			print ("Trying to add a non-hypo to a hypo-only container!");
			return false;
		}
		return true;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	function RollEachItem()
	{
		while (inputs.len() > 0)
		{
			Roll();
		}
	}
	
	function Roll()
	{
		if (outputs.len() == 0)
			outputs = used;
			
		local retries = -1;
		local item = null;
		local output = null;
		local roll_o = 0;
		local roll_i = 0;
		
		local outputs_max = outputs.len() - 1;
		local inputs_max = inputs.len() - 1;
		
		local valid;
		
		do
		{
		
			retries++;
			
			print ("------------------");
			
			
			roll_i = Data.RandInt(0, inputs_max);
			roll_o = Data.RandInt(0, outputs_max);
			
			item = inputs[roll_i];
			
			print ("Roll #" + retries + " - Rolled an input of " + roll_i + "/" + inputs_max + " - output of " + roll_o + "/" + outputs_max + ": " + item + " sent to output.");
			
			output = outputs[roll_o][0];
			
			valid = IsRollValid(output,item);
		
		}
		while (!valid && retries <= 10 && inputs_max > 1);
		
		//if (valid)
		{
		
			SendMessage(output, "OutputSelected",item);
		
			if (!outputs[roll_o][1])
				used.append(outputs[roll_o]);
			outputs.remove(roll_o);
			inputs.remove(roll_i);
		}
	}
	
	//Determines if a roll is valid
	function IsRollValid(output,item)
	{
		//prevent duplicate items if a container doesn't want them
		if (Object.HasMetaProperty(output,"Object Randomiser  - No Duplicates"))
		{
			foreach (outLink in Link.GetAll(linkkind("Contains"),output))
			{
				local invitem = sLink(outLink).dest;
				
				if (Object.Archetype(invitem) == Object.Archetype(item))
				{
					print ("	Duplicate item found!");
					return false;
				}
			}
		}
		if (Object.HasMetaProperty(output,"Object Randomiser  - Only Hypos") && Object.Archetype(item) != -51)
		{
			return false;
		}
		return true;
	}
	
	*/
	
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
		local isInventoryItem = Property.Get(processing, "InvDims","Width");
				
		if (isMarker)
		{
			outputs.append([processing,IS_MARKER]);
		}
		else if (isContainer)
		{		
			ProcessInventory(processing);
			outputs.append([processing,IS_CONTAINER]);
		}
		else if (isCorpse)
		{
			ProcessInventory(processing);
			outputs.append([processing,IS_CORPSE]);
		}
		else if (isInventoryItem) //Not a container or a marker, it must be some other item.
		{
			inputs.append([processing,IS_INVENTORY_ITEM]);
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
		
	function canModify(item)
	{
		foreach (type in dontModify)
		{
			if (Object.InheritsFrom(item, type) || item == type)
				return false;
		}
		return true;
	}
	
	
	//Process all items in an inventory, adding them to input array
	function ProcessInventory(source)
	{
		foreach (outLink in Link.GetAll(linkkind("Contains"),source))
		{
			local item = sLink(outLink).dest;
			
			if (unsafe || canModify(item))
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