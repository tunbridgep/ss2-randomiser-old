// ================================================================================
// Script used by objects to roll a random randomiser
class sargeRandomisedObject extends sargeBase
{
	function Init()
	{
		//We need to delay a bit to give our link generation some time to kick in
		SetOneShotTimer("RandomiseTimer", 0.1);
	}
	
	function Roll(links)
	{
		local max = links.len();
		local roll = Data.RandInt(0, max);
		print ("Rolled " + roll + "/" + max);
		
		local object_name = ShockGame.GetArchetypeName(self);
		
		//If we roll a 0, do nothing - stay in our current place
		//Otherwise, send us off to whichever link we triggered.
		if (roll > 0)
			SendMessage(links[roll-1].dest, "RandomiserSelected");
		else
			print ("Rolled a 0 - " + object_name + " not randomised");
		
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