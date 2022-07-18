// ================================================================================
// Attach to an object, link it to some RandomiserOutputs through their target fields, and it will pick one at random
class sargeRandomiserInput extends sargeBase
{
	function Init()
	{	
		local outputs = [];
		//There's no outputset.len() or outputset[0] equivalent functionality...
		//So we'll do our own array, with hookers, and blackjack!
		foreach (outLink in Link.GetAll(linkkind("~Target"),self))
		{
			outputs.append(sLink(outLink));
		}
		
		Roll(outputs,self);
	}
	
	function Roll(outputs,item)
	{
		print ("------------------");
		
		local max = outputs.len();
			
		local roll = Data.RandInt(0, max);
		
		local object_name = ShockGame.GetArchetypeName(item);
		if (roll == 0)
		{
			print ("Rolled a 0/" + max + " - " + object_name + " (" + item + ") will remain in original location.");
		}
		else
		{
			print ("Rolled a " + roll + "/" + max + " - " + object_name + " (" + item + ") sent to output " + (roll) + ".");
			SendMessage(outputs[roll-1].dest, "OutputSelected",item);
			//outputs.remove(roll-1);
		}
	}
}