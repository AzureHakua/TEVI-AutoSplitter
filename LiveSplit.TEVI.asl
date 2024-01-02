state("TEVI") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");

    dynamic[,] _settings =
    {
        { "bosses", true, "Bosses", null },
            { "e120", true, "Ribauld", "bosses" },
            { "e292", true, "Vena", "bosses" },
            { "e125", true, "Caprice", "bosses" },
            { "e121", true, "Lily", "bosses" },
            { "e124", true, "Katu", "bosses" },
            { "e127", true, "Roleo", "bosses" },
            { "e128", true, "Malphage", "bosses" },
            { "e129", true, "Thetis", "bosses" },
            { "e126", true, "Frankie", "bosses" },
            { "e123", true, "Barados", "bosses" },
            { "e153", true, "Tybrious", "bosses" },
            { "e155", true, "Fray", "bosses" },
            { "e135", true, "Eidolon", "bosses" },
            { "e138", true, "Memloch", "bosses" },
            { "e174", true, "Vassago", "bosses" },
            { "e177", true, "Amaryllis", "bosses" },
            { "e217", true, "Jezbelle", "bosses" },
            { "e239", true, "Jethro", "bosses" },
            { "e242", true, "Illusion Alius", "bosses" },
            { "e247", true, "Charon", "bosses" },
            { "e271", true, "Cyril", "bosses" },
            { "e290", true, "Tahlia", "bosses" },
            { "e294", true, "Revenance", "bosses" },
        { "items", true, "Items", null },
            { "i24", false, "Cross Bomb", "items" },
            { "i25", false, "Cluster Bomb", "items" },
            { "i26", true, "Bomb Fuel", "items" },
            { "i41", false, "Combustible", "items" },
            { "i27", false, "Rabi Boots", "items" },
            { "i30", false, "Wall Jump", "items" },
            { "i31", false, "Double Jump", "items" },
            { "i32", true, "Jetpack", "items" },
            { "i29", true, "Slide", "items" },
            { "i64", false, "Airy Powder", "items" },
            { "i42", true, "Air Dash", "items" },
            { "i35", false, "Decay Mask", "items" },
            { "i40", false, "Decay Potion", "items" },
            { "i33", false, "Hydrodynamo", "items" },
            { "i48", false, "Equilibrium Ring", "items" },
            { "i63", false, "Vortex Gloves", "items" },
        { "sigils", true, "Sigils", null },
            { "i266", true, "Blood Lust", "sigils" },
            { "i237", true, "Hero Call", "sigils" },
        { "gears", true, "Gears", null },
            { "g0", true, "Desert Base", "gears" },
            { "g4", true, "Magma Depths", "gears" },
            { "g5", true, "Gallery of Mirrors", "gears" },
            { "g6", true, "Blushwood", "gears" }
    };

    vars.Helper.Settings.Create(_settings);

    vars.Music = new ExpandoObject();
        vars.Music.OFF = 0;
        vars.Music.MAINTHEME = 3;

    vars.timer = 0;
    vars.triggeredEvents = new bool[400];
    vars.triggeredItems = new bool[500];
    vars.triggeredGears = new bool[100];
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["Runtime"] = mono.Make<float>("SaveManager", "Instance", "savedata", "truntime");
        vars.Helper["Events"] = mono.MakeArray<bool>("SaveManager", "Instance", "savedata", "eventflag");
        vars.Helper["Items"] = mono.MakeArray<bool>("SaveManager", "Instance", "savedata", "itemflag");
        vars.Helper["Gears"] = mono.MakeArray<bool>("SaveManager", "Instance", "savedata", "stackableItemList");
        vars.Helper["Music"] = mono.Make<byte>("MusicManager", "Instance", "lastMusic");
        return true;
    });
}

start
{
    /*
        Starts the timer when game time starts.
        If the game time jump is more than 1s,
        then do not start the timer yet.
    */
    if (0f < current.Runtime && current.Runtime < 1f && old.Runtime == 0f)
    {
        print (">>> Start LiveSplit");
        return true;
    }
    return false;
}

onStart
{
    // Resets all the variables on start.
    print (">>> Variables Reset");
    vars.timer = 0;
    vars.triggeredEvents = new bool[400];
    vars.triggeredItems = new bool[500];
    vars.triggeredGears = new bool[100];
}

split
{
    /*
        Splits the game when you beat a particular boss.
        See https://rentry.co/TEVI_IDs#event-ids for event IDs
    */
    bool[] oEvents = old.Events, cEvents = current.Events;
    for (int i = 0; i < cEvents.Length; i++)
    {
        string id = "e" + i;
        if (settings.ContainsKey(id) && settings[id]
            && !oEvents[i] && cEvents[i]
            && !vars.triggeredEvents[i])
        {
            print(">>> Split at Event: " + id);
            vars.triggeredEvents[i] = true;
            return true;
        }
    }

    /*
        Splits the game when you obtain a particular item.
        See https://rentry.co/TEVI_IDs#item-ids for item IDs
    */
    bool[] oItems = old.Items, cItems = current.Items;
    for (int i = 0; i < cItems.Length; i++)
    {
        string id = "i" + i;
        if (settings.ContainsKey(id) && settings[id]
            && !oItems[i] && cItems[i]
            && !vars.triggeredItems[i])
        {
            print(">>> Split at Item: " + id);
            vars.triggeredItems[i] = true;
            return true;
        }
    }

    /*
        Splits the game when you obtain a particular stackable.
        Index 0-63 are Gears
    */
    bool[] oGears = old.Gears, cGears = current.Gears;
    for (int i = 0; i < cGears.Length; i++)
    {
        string id = "g" + i;
        if (settings.ContainsKey(id) && settings[id]
            && !oGears[i] && cGears[i]
            && !vars.triggeredGears[i])
        {
            print(">>> Split at Gear: " + id);
            vars.triggeredGears[i] = true;
            return true;
        }
    }
}

reset
{
    /*
        Resets when the title music plays.
        Disable this feature if you're running
        a category where save & quit is involved.
    */
    if (old.Music == vars.Music.OFF && current.Music == vars.Music.MAINTHEME)
    {
        print(">>> Reset LiveSplit");
        return true;
    }
    return false;
}

gameTime
{
    /*
        Tracks the timer using TEVI's T. Runtime variable.
        Only displays the max to keep LiveSplit looking nice.
    */
    vars.timer = Math.Max(current.Runtime, vars.timer);
    return TimeSpan.FromSeconds(vars.timer);
}

isLoading
{
    return true;
}