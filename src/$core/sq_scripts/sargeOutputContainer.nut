// ================================================================================
// Moves the received items to it's relevant container
// ================================================================================
class sargeOutputContainer extends sargeOutput
{
	function RemoveContainsLinks(item)
	{
		foreach (outLink in Link.GetAll(linkkind("~Contains"),item))
			Link.Destroy(outLink);
	}

	function ProcessItem(item)
	{
		RemoveContainsLinks(item);
		Link.Create(linkkind("Contains"),self,item);
		print ("moving item " + item + " to container " + self);
	}
}