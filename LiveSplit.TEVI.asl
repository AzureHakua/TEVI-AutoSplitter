state("TEVI", "TEVI")
{
	// variables
	float truntime: "mono-2.0-bdwgc.dll", 0x007280F8, 0xC0, 0xE4C;
	float runtime: "mono-2.0-bdwgc.dll", 0x007280F8, 0xC0, 0xE64;
	byte1664 itemArray: "UnityPlayer.dll", 0x01B29AD8, 0x10, 0x10, 0x28, 0x28, 0x68, 0x58, 0x20;
}

startup
{
	settings.Add("bosses", true, "Bosses")
	settings.Add("items", true, "Items");
	settings.CurrentDefaultParent = "bosses";
		settings.Add("all", true "All Bosses");
	settings.CurrentDefaultParent = "items";               // Item ID
		settings.Add("lineBomb", false, "Cross Bomb");          // 24
		settings.Add("areaBomb", false, "Cluster Bomb");        // 25
		settings.Add("bombFuel", false, "Bomb Fuel");           // 26
		settings.Add("hiJump", false, "Rabi Boots");            // 27
		settings.Add("slide", true, "Slide");                   // 29
		settings.Add("wallJump", false, "Wall Jump");           // 30
		settings.Add("doubleJump", false, "Double Jump");       // 31
		settings.Add("jetpack", false, "Jetpack");              // 32
		settings.Add("waterMovement", false, "Hydrodynamo");    // 33
		settings.Add("mask", false, "Decay Mask");              // 35
		settings.Add("antiDecay", false, "Decay Potion");       // 40
		settings.Add("bombLengthExtend", false, "Combustible"); // 41
		settings.Add("airDash", true, "Air Dash");              // 42
		settings.Add("tempRing", false, "Equilibrium Ring");    // 48
		settings.Add("rotater", false, "Vortex Gloves");        // 63
		settings.Add("airSlide", false, "Airy Powder");         // 64
}

init
{
	// TODO: this does not properly check version
	if(modules.First().ModuleMemorySize == 0xD8000)
		version = "TEVI";
	else
		version = "undefined";

	refreshRate = 60;

	// vars.xtile = (int)(current.xpos/1280) + current.mapid * 25;
	// vars.ytile = (int)(current.ypos/720);
	// vars.hasSplit = new bool[100];

	// timer variables
	vars.reloading = false;
	vars.timer = 0;
	vars.timerIncrease = 0;
	vars.TIMERFAILSAFE = 5;  // set the failsafe for timer jumps
}

update
{
	return true;
}

gameTime
{
	/*
		Tracks the timer increase separately to account for reloads / timer resets.
		If the difference is negative or greater than the failsafe, throw it out.
		Otherwise, add the increase to the overall timer and output it.
	*/ 
	vars.timerIncrease = current.truntime - old.truntime;
	
	if(vars.timerIncrease < 0 || vars.timerIncrease > vars.TIMERFAILSAFE)
		vars.timerIncrease = 0;

	vars.timer += vars.timerIncrease;
	
	// Convert to milliseconds 
	vars.igt = (int) Math.Round(vars.timer * 1000);
	return new TimeSpan(0, 0, 0, 0, vars.igt);
}

start
{
	// TODO: add another check so it doesn't randomly start
	if (current.truntime > 0 && old.truntime == 0) {
		vars.timer = 0;
		vars.timerIncrease = 0;
		// vars.hasSplit = new bool[100];
		return true;
	}
}

reset
{
	// TODO: maybe reset when title music plays?
	/*
	if (TODO) {
		vars.timer = 0;
		vars.timerIncrease = 0;
		// vars.hasSplit = new bool[100];
		return true;
	} */
	return false;
}

split
{
	// checks if the game is reloading
	vars.reloading = current.runtime == 0 || (current.runtime < old.runtime);

	/*
		splits the game when you obtain a particular item
		see ItemList.Type in the IDs sheet for item IDs
	*/
	if(settings["lineBomb"]
		&& current.itemArray[24] == 1
		&& old.itemArray[24] == 0
	){ print("Cross Bomb Split"); return true; }

	if(settings["areaBomb"]
		&& current.itemArray[25] == 1
		&& old.itemArray[25] == 0
	){ print("Cluster Bomb Split"); return true; }

	if(settings["bombFuel"]
		&& current.itemArray[26] == 1
		&& old.itemArray[26] == 0
	){ print("Bomb Fuel Split"); return true; }

	if(settings["hiJump"]
		&& current.itemArray[27] == 1
		&& old.itemArray[27] == 0
	){ print("Rabi Boots Split"); return true; }

	if(settings["slide"]
		&& current.itemArray[29] == 1
		&& old.itemArray[29] == 0
	){ print("Slide Split"); return true; }

	if(settings["wallJump"]
		&& current.itemArray[30] == 1
		&& old.itemArray[30] == 0
	){ print("Wall Jump Split"); return true; }

	if(settings["doubleJump"]
		&& current.itemArray[31] == 1
		&& old.itemArray[31] == 0
	){ print("Double Jump Split"); return true; }

	if(settings["jetpack"]
		&& current.itemArray[32] == 1
		&& old.itemArray[32] == 0
	){ print("Jetpack Split"); return true; }

	if(settings["waterMovement"]
		&& current.itemArray[33] == 1
		&& old.itemArray[33] == 0
	){ print("Hydrodynamo Split"); return true; }

	if(settings["mask"]
		&& current.itemArray[35] == 1
		&& old.itemArray[35] == 0
	){ print("Decay Mask Split"); return true; }

	if(settings["antiDecay"]
		&& current.itemArray[40] == 1
		&& old.itemArray[40] == 0
	){ print("Decay Potion Split"); return true; }

	if(settings["bombLengthExtend"]
		&& current.itemArray[41] == 1
		&& old.itemArray[41] == 0
	){ print("Combustible Split"); return true; }

	if(settings["airDash"]
		&& current.itemArray[42] == 1
		&& old.itemArray[42] == 0
	){ print("Air Dash Split"); return true; }

	if(settings["tempRing"]
		&& current.itemArray[48] == 1
		&& old.itemArray[48] == 0
	){ print("Equilibrium Ring Split"); return true; }

	if(settings["rotater"]
		&& current.itemArray[63] == 1
		&& old.itemArray[63] == 0
	){ print("Vortex Gloves Split"); return true; }

	if(settings["airSlide"]
		&& current.itemArray[64] == 1
		&& old.itemArray[64] == 0
	){ print("Airy Powder Split"); return true; }

	return false;
}
