// ================================================================================
// Handles randomising the position of items based on various marker positions
class sargeRandomiser extends SqRootScript
{
	// fetch a parameter or return default value
	// blatantly stolen from RSD
	function getParam(key, defVal)
	{
		return key in userparams() ? userparams()[key] : defVal;
	}
	
	function OnSim()
	{
		if (!GetData("Setup"))
		{
			Randomise();
			SetData("Setup",TRUE);
		}
	}

	function Randomise()
	{
			print ("Randomising position...");
			
			local item = getParam("sargeRandomiseObject",0);
			local chance = getParam("sargeRandomiseChance",0);
			
			print (Object.GetName(item) + " with number " + item);
			
			local roll = Data.RandInt(1, 100);
			
			print ("Rolled " + roll);
			
			if (roll <= chance)
			{
				Object.Teleport(item, Object.Position(self), Object.Facing(self));
				print ("item " + item + " was moved to " + Object.Position(self) + " " + Object.Facing(self));
			}
			
			//Object.Destroy(item);
	}
}