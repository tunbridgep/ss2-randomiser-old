// ================================================================================
// Base class for everything, contains mainly utility functions
class sargeBase extends SqRootScript
{
	// fetch a parameter or return default value
	// blatantly stolen from RSD
	function getParam(key, defVal)
	{
		return key in userparams() ? userparams()[key] : defVal;
	}
	
	//Add an "init" function which is only ever called once
	function OnSim()
	{
		if (!GetData("Setup"))
		{
			Init();
			SetData("Setup",TRUE);
		}
	}
	
	//overwrite this
	function Init()
	{
	}
}

// ================================================================================
// Base class for randomisers
class sargeRandomiserBase extends sargeBase
{
	item = null;

	function Init()
	{
		item = getParam("sargeRandomiseObject",0);
		//local chance = getParam("sargeRandomiseChance",50);
		//SetData("Chance",chance);
		Link.Create(linkkind("Target"), self, item);
	}
	
	//Override this
	function OnRandomiserSelected()
	{
		print ("OnRandomiserSelected called!");
	}
}

// ================================================================================
// Various classes for handling what a randomiser should do when chosen - move the object to it's position, put it in a linked container, etc.

class sargeRandomisePosition extends sargeRandomiserBase
{
	function OnRandomiserSelected()
	{
		local disablePhysics = getParam("sargeDisablePhysics",FALSE);
		
		print ("moving item " + item + " to position " + Object.Position(self));
		
		Object.Teleport(item, Object.Position(self), Object.Facing(self));
		
		if (disablePhysics)
		{
			print ("disabling physics for " + item);
			Physics.SetGravity(item,0.0);
			Physics.SetVelocity(item,vector(0,0,0));
		}
	}
}

class sargeRandomiseContainer extends sargeRandomiserBase
{
	function OnRandomiserSelected()
	{
		local container = getParam("sargeContainer",0);
		
		if (container)
		{
			print ("moving item " + item + " to container " + container);
			Link.Create(linkkind("Contains"),container,item);
		}
		else
			print ("sargeContainer not set - not transferring item to container!");
	}
}

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



// ================================================================================
// Deletes the associated object based on a random chance
class sargeRandomRemoveObject extends sargeBase
{
	function Init()
	{
		local chance = getParam("sargeDestroyChance",50);
		local roll = Data.RandInt(1, 100);
		
		if (roll <= chance)
		{
			print ("Rolled under needed chance value - object not destroyed");
			Object.Destroy(self);
		}
		else
			print ("Rolled over needed chance value - object not destroyed");
	}
}