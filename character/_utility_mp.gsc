attachFromArray(a)
{
	self.empire_headmodel = character\_utility::randomElement(a);
	self attach(self.empire_headmodel, "", true);
}
