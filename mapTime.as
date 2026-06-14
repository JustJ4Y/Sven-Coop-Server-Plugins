//  File where the best completion times are stored (mapname time)
const string g_timesFile = "scripts/plugins/store/maptimes.txt";

//  Shared flag file: forcing plugins write "1" here so a forced change is not logged
const string g_forcedFlagFile = "scripts/plugins/store/maptime_forced.txt";

//  Time (in seconds) the current map was started at
float g_mapStartTime = 0.0f;

//  Holds the best known completion time for every map (mapname -> seconds)
dictionary g_records;

void PluginInit()
{
    //  Information for as_listplugin command
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    //  Fires when the level is about to change (e.g. map completed)
    g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
    //  Register what the player writes in chat
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

    //  Load the previously saved records
    ReadRecords();
}

void MapInit()
{
    //  Remember when this map started so we can measure how long it took
    g_mapStartTime = g_Engine.time;

    //  Fresh map: clear any leftover forced-change flag from the previous change
    ClearForcedChange();
    g_Scheduler.SetTimeout("MapStart",15.0f);
}

void MapStart()
{
    string currentMap = string(g_Engine.mapname);

    if (g_records.exists(currentMap))
    {
        float best;
        g_records.get(currentMap, best);
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,
            "Best time for " + currentMap + ": " + FormatTime(best) + "\n");
    }
    else
    {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,
            "No time saved for " + currentMap + " yet. Be the first to complete it!\n");
    }
}

HookReturnCode MapChange(const string& in szNextMap)
{
    //  Empty next map means the server is shutting down, not a completion
    if (szNextMap.IsEmpty())
        return HOOK_CONTINUE;

    //  Admin map changes and passed mapvotes leave a flag, ignore those
    if (WasForcedChange())
        return HOOK_CONTINUE;

    //  A real completion needs at least one survivor, otherwise it was a failed attempt
    if (CountAlivePlayers() < 1)
        return HOOK_CONTINUE;

    //  How long the players took on this map
    float elapsed = g_Engine.time - g_mapStartTime;
    string currentMap = string(g_Engine.mapname);

    SaveTime(currentMap, elapsed);

    return HOOK_CONTINUE;
}

//  True if the level change was forced by another plugin (admin map / mapvote)
bool WasForcedChange()
{
    bool forced = false;

    File@ file = g_FileSystem.OpenFile(g_forcedFlagFile, OpenFile::READ);
    if (file !is null && file.IsOpen())
    {
        string line;
        file.ReadLine(line);
        line.Trim();
        forced = (line == "1");
        file.Close();
    }

    return forced;
}

//  Resets the shared forced-change flag back to "0"
void ClearForcedChange()
{
    File@ file = g_FileSystem.OpenFile(g_forcedFlagFile, OpenFile::WRITE);
    if (file !is null && file.IsOpen())
    {
        file.Write("0\n");
        file.Close();
    }
}

//  Counts how many connected players are still alive
uint CountAlivePlayers()
{
    uint aliveCount = 0;

    for (int i = 1; i <= g_Engine.maxClients; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsAlive())
            aliveCount++;
    }

    return aliveCount;
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
    const CCommand@ args = pParams.GetArguments();
    CBasePlayer@ player = pParams.GetPlayer();
    string askedMap = "";

    if (args.ArgC() > 0)
    {
        //  Shows the player the best time for the current map
        if (args.Arg(0).ToLowercase() == "maptime" || args.Arg(0).ToLowercase() == "besttime")
        {

            if (args.ArgC() == 2)
            {
                askedMap = args.Arg(1).ToLowercase();
            }
            else
            {
                askedMap = string(g_Engine.mapname);
            }

            if (g_records.exists(askedMap))
            {
                float best;
                g_records.get(askedMap, best);
                g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK,
                    "Best time for " + askedMap + ": " + FormatTime(best) + "\n");
            }
            else
            {
                g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK,
                    "No time saved for " + askedMap + " yet. Be the first to complete it!\n");
            }

            pParams.ShouldHide = true;
            return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}

void SaveTime(const string &in mapName, float elapsed)
{
    //  Ignore nonsense values (e.g. the map barely ran)
    if (elapsed <= 0.0f)
        return;

    bool isRecord = false;

    if (g_records.exists(mapName))
    {
        float best;
        g_records.get(mapName, best);
        //  Only keep the fastest completion
        if (elapsed < best)
        {
            g_records.set(mapName, elapsed);
            isRecord = true;
        }
    }
    else
    {
        //  First time this map was ever completed
        g_records.set(mapName, elapsed);
        isRecord = true;
    }

    if (isRecord)
    {
        WriteRecords();
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,
            "New record for " + mapName + ": " + FormatTime(elapsed) + "!\n");
    }
    else
    {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,
            "Map " + mapName + " completed in " + FormatTime(elapsed) + ".\n");
    }
}

void ReadRecords()
{
    g_records.deleteAll();

    //  Opens the file located in the directory g_timesFile
    File@ file = g_FileSystem.OpenFile(g_timesFile, OpenFile::READ);
    if (file !is null && file.IsOpen())
    {
        while (!file.EOFReached())
        {
            string lineContent;
            //  Saves the content of the line in lineContent
            file.ReadLine(lineContent);
            //  Removes blanks
            lineContent.Trim();

            if (lineContent.IsEmpty())
                continue;

            //  Each line is "mapname time", split at the space (map names have none)
            int sep = lineContent.Find(" ");
            if (sep < 0)
                continue;

            string mapName = lineContent.SubString(0, sep);
            string timeStr = lineContent.SubString(sep + 1);
            mapName.Trim();

            g_records.set(mapName, atof(timeStr));
        }
        file.Close();
    }
}

void WriteRecords()
{
    //  Opens (or creates) the file for writing
    File@ file = g_FileSystem.OpenFile(g_timesFile, OpenFile::WRITE);
    if (file !is null && file.IsOpen())
    {
        array<string> keys = g_records.getKeys();
        keys.sortAsc();

        for (uint i = 0; i < keys.length(); i++)
        {
            float best;
            g_records.get(keys[i], best);
            file.Write(keys[i] + " " + best + "\n");
        }
        file.Close();
    }
}

//  Turns seconds into a readable "H:MM:SS" string
string FormatTime(float seconds)
{
    int total = int(seconds);
    int hours = total / 3600;
    int minutes = (total / 60) % 60;
    int secs = total % 60;

    string secStr = secs < 10 ? "0" + secs : "" + secs;
    string minutesStr = minutes < 10 ? "0" + minutes : "" + minutes;

    if (total < 3600)
    {
        return "" + minutes + ":" + secStr;
    } 
    else
    {
        return "" + hours + ":" + minutesStr + ":" + secStr;
    }
}