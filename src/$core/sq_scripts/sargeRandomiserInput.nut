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
	
	function Roll(links)
	{
		local max = links.len();
		local roll = Data.RandInt(0, max);
		
		local object_name = ShockGame.GetArchetypeName(self);
		if (roll == 0)
		{
			print ("Rolled a 0/" + max + " - " + object_name + " (" + self + ") will remain in original location.");
		}
		else
		{
			print ("Rolled a " + roll + "/" + max + " - " + object_name + " (" + self + ") sent to output " + (roll-1) + ".");
			SendMessage(links[roll-1].dest, "OutputSelected",self);
		}	
	
		//LinkTools.LinkSetData
		
		//cMultiParm SendMessage(object to, string sMessage, cMultiParm data, cMultiParm data2, cMultiParm data3);
	}
	
	function OnTimer()
	{
		local links = [];
		if (message().name == "RandomiseTimer")
		{
			//There's no linkset.len() or linkset[0] equivalent functionality...
			//So we'll do our own array, with hookers, and blackjack!
			foreach (index,outLink in Link.GetAll(linkkind("~Target"),self))
				links.append(sLink(outLink));
			
			Roll(links);
		}
	}
}