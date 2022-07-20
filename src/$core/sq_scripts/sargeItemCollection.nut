// ================================================================================
// Handles item selection, will send messages to linked outputs containing items, until none are left
class sargeItemCollection extends sargeBase
{
	inputs = null;
	outputs = null;

	function OnSim()
	{
		//This has to be done here, squirrel doesn't handle class members properly
		//see note under section 2.9.2
		//http://www.squirrel-lang.org/squirreldoc/reference/language/classes.html
		inputs = [];
		outputs = [];
		
		print ("OnSim called");
		ProcessTargets();
		
		Array_Shuffle(inputs);
		
		SignalReady();
	}
	
	//Gets ALL inputs - directly linked objects, plus objects in linked containers
	function ProcessTargets()
	{
		//Get every link and every item each linked item contains
		foreach (outLink in Link.GetAll(linkkind("~Target"),self))
		{
			local target = sLink(outLink).dest;
			
			if (isArchetype(target,-379) || isArchetype(target,-118)) //crate or corpse
			{
				Link.Create("Target", self, target);
				if (!Object.HasMetaProperty(target,"Object Randomiser - Container"))
					Object.AddMetaProperty(target,"Object Randomiser - Container");
				
				outputs.append(target);
				print ("Added " + target + " as output link");
			}
			
			print ("target found: " + target);
			
			foreach (collectionLink in Link.GetAll(linkkind("Contains"),target))
			{
				local contained = sLink(collectionLink).dest;	
				print ("processing: " + contained);
				inputs.append(contained);
			}
			
			print ("processing: " + target);
			inputs.append(target);
		}
	}
	
	//Sends the "ready" signal to targets, they will respond by asking for items.
	function SignalReady()
	{
		foreach (output in outputs)
		{
			SendMessage(output, "ItemCollectionReady", self);
		}
	}
	
	function OnItemRequested()
	{
		print (message().data + " requested an item of type " + message().data2);
		
		//Get first available item of type, or return null if there aren't any
		local selected = null;
		foreach(input in inputs)
		{
			if (isArchetype(input,message().data2))
			{
				selected = input;
				break;
			}
		}
		
		SendMessage(message().data, "ItemChosen", self, selected);
	}
}