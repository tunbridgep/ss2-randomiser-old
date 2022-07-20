// ================================================================================
//Receives Messages from an item collection, acts as an output for the randomiser,
//creating or manipulating items as instructed
// ================================================================================
class sargeOutput extends sargeBase
{
	//Default allowed inputs.
	//We can replace this
	static allowedInputs = [
		-49, //Goodies
		-12, //Weapons
		-156, //Keys
	];

	itemList = null;
	allowedListIndex = null;
	rolls = null;

	function Setup()
	{
		if (!GetData("SetUp"))
		{
			SetData("SetUp",TRUE);
			allowedListIndex = 0;
			rolls = Data.RandInt(1,3); //request up to 3 items
			print ("allowedListIndex is " + allowedListIndex);
		}
	}

	//Message to let us know when it's ready to start asking for items
	function OnItemCollectionReady()
	{
		Setup();
		print (self + " received ItemCollectionReady Message");
		itemList = message().data;
				
		RequestItem();
	}
	
	//Request a new item of a given type
	function RequestItem()
	{
		//stop the process if we have run out of item types to request;
		if (allowedListIndex >= allowedInputs.len())
			return;
	
		//Get a random type from our allowed types
		print ("itemList is " + itemList + ", index is " + allowedListIndex);
		SendMessage(itemList, "ItemRequested", self, allowedInputs[allowedListIndex]);
	}
	
	function OnItemChosen()
	{
		local source = message().data;
		local item = message().data2;
		
		//no items of type available,
		//move onto the next type
		if (item == null)
		{
			allowedListIndex++;				
		}
		else
		{
			ProcessItem(item);
			rolls--;
			if (rolls > 0)
			{
				RequestItem();
			}
		}
	}
	
	//Process our last selected item
	function ProcessItem(item)
	{
		print ("Processing item " + item);
	}
}