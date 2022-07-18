// ================================================================================
// Can be used to set a number of inputs for objects which will be randomised
// Also handled rolling and other stuff
// Actually handles the "choosing an item" aspect
// And then tells a specific output to act.
class sargeRandomiserInput extends sargeBase
{
	function Init()
	{
		//We need to delay a bit to give our link generation some time to kick in
		SetOneShotTimer("RandomiseTimer", 0.2);
	}
	
	function Roll(outputs,item)
	{	
		local max = outputs.len();
			
		local roll = Data.RandInt(0, max);
		
		local object_name = ShockGame.GetArchetypeName(item);
		if (roll == 0)
		{
			print ("Rolled a 0/" + max + " - " + object_name + " (" + item + ") will remain in original location.");
		}
		else
		{
			print ("Rolled a " + roll + "/" + max + " - " + object_name + " (" + item + ") sent to output " + (roll-1) + ".");
			SendMessage(outputs[roll-1].dest, "OutputSelected",item);
			outputs.remove(roll-1);
		}
	}
	
	function RollForAllInputs(outputs)
	{
		foreach (value in getParamArray("sargeInputItem",self))
		{
			value = value == "[me]" ? self : value;
			Roll(outputs,value);
		}
	}
	
	function OnTimer()
	{
		local outputs = [];
		if (message().name == "RandomiseTimer")
		{
			//There's no outputset.len() or outputset[0] equivalent functionality...
			//So we'll do our own array, with hookers, and blackjack!
			foreach (outLink in Link.GetAll(linkkind("~Target"),self))
				outputs.append(sLink(outLink));
			
			RollForAllInputs(outputs);
		}
	}
}