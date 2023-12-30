state("TEVI", "TEVI")
{
	float truntime: "mono-2.0-bdwgc.dll", 0x007280F8, 0xC0, 0xE4C;
	float runtime: "mono-2.0-bdwgc.dll", 0x007280F8, 0xC0, 0xE64;
	byte1664 eventArray: "UnityPlayer.dll", 0x01B29AD8, 0x10, 0x10, 0x28, 0x28, 0x68, 0x50, 0x20;
	byte1664 itemArray: "UnityPlayer.dll", 0x01B29AD8, 0x10, 0x10, 0x28, 0x28, 0x68, 0x58, 0x20;
	// TODO: Find Music Address, Title Music == 3
}

startup
{
	settings.Add("bosses", true, "Bosses");
	settings.Add("items", true, "Items");
	settings.Add("sigils", true, "Sigils");
	settings.CurrentDefaultParent = "bosses";         // Boss End ID
		settings.Add("ribauld", true, "Ribauld");              // 120
		settings.Add("vena", true, "Vena");                    // 292
		settings.Add("caprice", true, "Caprice");              // 125
		settings.Add("lily", true, "Lily");                    // 121
		settings.Add("katu", true, "Katu");                    // 124
		settings.Add("roleo", true, "Roleo");                  // 127
		settings.Add("malphage", true, "Malphage");            // 128
		settings.Add("thetis", true, "Thetis");                // 129
		settings.Add("frankie", true, "Frankie");              // 126
		settings.Add("barados", true, "Barados");              // 123
		settings.Add("tybrious", true, "Tybrious");            // 153
		settings.Add("fray", true, "Fray");                    // 155
		settings.Add("eidolon", true, "Eidolon");              // 135
		settings.Add("memloch", true, "Memloch");              // 138
		settings.Add("vassago", true, "Vassago");              // 174
		settings.Add("amaryllis", true, "Amaryllis");          // 177
		settings.Add("jezbelle", true, "Jezbelle");            // 217 
		settings.Add("jethro", true, "Jethro");                // 239
		settings.Add("alius", true, "Illusion Alius");         // 242
		settings.Add("charon", true, "Charon");                // 247
		settings.Add("cyril", true, "Cyril");                  // 271
		settings.Add("tahlia", true, "Tahlia");                // 290
		settings.Add("revenance", true, "Revenance");          // 294
	settings.CurrentDefaultParent = "items";               // Item ID
		settings.Add("lineBomb", false, "Cross Bomb");          // 24
		settings.Add("areaBomb", false, "Cluster Bomb");        // 25
		settings.Add("bombFuel", false, "Bomb Fuel");           // 26
		settings.Add("bombLengthExtend", false, "Combustible"); // 41
		settings.Add("hiJump", false, "Rabi Boots");            // 27
		settings.Add("wallJump", false, "Wall Jump");           // 30
		settings.Add("doubleJump", false, "Double Jump");       // 31
		settings.Add("jetpack", true, "Jetpack");              // 32
		settings.Add("slide", true, "Slide");                   // 29
		settings.Add("airSlide", false, "Airy Powder");         // 64
		settings.Add("airDash", true, "Air Dash");              // 42
		settings.Add("mask", false, "Decay Mask");              // 35
		settings.Add("antiDecay", false, "Decay Potion");       // 40
		settings.Add("waterMovement", false, "Hydrodynamo");    // 33
		settings.Add("tempRing", false, "Equilibrium Ring");    // 48
		settings.Add("rotater", false, "Vortex Gloves");        // 63
	settings.CurrentDefaultParent = "sigils";             // Sigil ID
		settings.Add("bloodLust", true, "Blood Lust");         // 266
		settings.Add("heroCall", true, "Hero Call");           // 237
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

	// Timer Variables
	vars.reloading = false;
	vars.timer = 0;
	vars.timerIncrease = 0;
	vars.TIMERFAILSAFE = 5;  // Set the failsafe for timer jumps
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
		return true;
	}
}

reset
{
	/*
		Resets the timer when the title music plays.
		Disable this feature if you're running
		a category where save & quit is involved.
	*//*
	if (current.songID == 3) {
		vars.timer = 0;
		vars.timerIncrease = 0;
		return true;
	} */
	return false;
}

split
{
	// Checks if the game is reloading.
	vars.reloading = current.runtime == 0 || (current.runtime < old.runtime);

	// TEVI tends to reassign its arrays, so this will avoid null object errors.
	if (current.eventArray == null || old.eventArray == null || current.itemArray == null || old.itemArray == null)
		return false;

	/*
		Splits the game when you beat a particular boss.
		See https://rentry.co/TEVI_IDs#event-ids for event IDs
	*/
	if(settings["ribauld"]
		&& current.eventArray[120] == 1
		&& old.eventArray[120] == 0
	){ print("Ribauld Split"); return true; }

	if(settings["vena"]
		&& current.eventArray[292] == 1
		&& old.eventArray[292] == 0
	){ print("Vena Split"); return true; }

	if(settings["caprice"]
		&& current.eventArray[125] == 1
		&& old.eventArray[125] == 0
	){ print("Caprice Split"); return true; }

	if(settings["lily"]
		&& current.eventArray[121] == 1
		&& old.eventArray[121] == 0
	){ print("Lily Split"); return true; }

	if(settings["katu"]
		&& current.eventArray[124] == 1
		&& old.eventArray[124] == 0
	){ print("Katu Split"); return true; }

	if(settings["roleo"]
		&& current.eventArray[127] == 1
		&& old.eventArray[127] == 0
	){ print("Roleo Split"); return true; }

	if(settings["malphage"]
		&& current.eventArray[128] == 1
		&& old.eventArray[128] == 0
	){ print("Malphage Split"); return true; }

	if(settings["thetis"]
		&& current.eventArray[129] == 1
		&& old.eventArray[129] == 0
	){ print("Thetis Split"); return true; }

	if(settings["frankie"]
		&& current.eventArray[126] == 1
		&& old.eventArray[126] == 0
	){ print("Frankie Split"); return true; }

	if(settings["barados"]
		&& current.eventArray[123] == 1
		&& old.eventArray[123] == 0
	){ print("Barados Split"); return true; }

	if(settings["tybrious"]
		&& current.eventArray[153] == 1
		&& old.eventArray[153] == 0
	){ print("Tybrious Split"); return true; }

	if(settings["fray"]
		&& current.eventArray[155] == 1
		&& old.eventArray[155] == 0
	){ print("Fray Split"); return true; }

	if(settings["eidolon"]
		&& current.eventArray[135] == 1
		&& old.eventArray[135] == 0
	){ print("Eidolon Split"); return true; }

	if(settings["memloch"]
		&& current.eventArray[138] == 1
		&& old.eventArray[138] == 0
	){ print("Memloch Split"); return true; }

	if(settings["vassago"]
		&& current.eventArray[174] == 1
		&& old.eventArray[174] == 0
	){ print("Vassago Split"); return true; }

	if(settings["amaryllis"]
		&& current.eventArray[177] == 1
		&& old.eventArray[177] == 0
	){ print("Amaryllis Split"); return true; }

	if(settings["jezbelle"]
		&& current.eventArray[217] == 1
		&& old.eventArray[217] == 0
	){ print("Jezbelle Split"); return true; }

	if(settings["jethro"]
		&& current.eventArray[239] == 1
		&& old.eventArray[239] == 0
	){ print("Jethro Split"); return true; }

	if(settings["alius"]
		&& current.eventArray[242] == 1
		&& old.eventArray[242] == 0
	){ print("Alius Split"); return true; }

	if(settings["charon"]
		&& current.eventArray[247] == 1
		&& old.eventArray[247] == 0
	){ print("Charon Split"); return true; }

	if(settings["cyril"]
		&& current.eventArray[271] == 1
		&& old.eventArray[271] == 0
	){ print("Cyril Split"); return true; }

	if(settings["tahlia"]
		&& current.eventArray[290] == 1
		&& old.eventArray[290] == 0
	){ print("Tahlia Split"); return true; }

	if(settings["revenance"]
		&& current.eventArray[294] == 1
		&& old.eventArray[294] == 0
	){ print("Revenance Split"); return true; }

	/*
		Splits the game when you obtain a particular item.
		See https://rentry.co/TEVI_IDs#item-ids for item IDs
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

	/*
		Splits the game when you obtain a particular sigil.
		See https://rentry.co/TEVI_IDs#item-ids for item IDs
	*/
	if(settings["bloodLust"]
		&& current.itemArray[266] == 1
		&& old.itemArray[266] == 0
	){ print("Blood Lust Split"); return true; }

	if(settings["heroCall"]
		&& current.itemArray[237] == 1
		&& old.itemArray[237] == 0
	){ print("Hero Call Split"); return true; }

	return false;
}