const string g_mapsfile = "scripts/plugins/cfg/maps.txt";
const string voteNow = "as_scripts/votenow.wav";

array<string> g_maps;

//  Global initiation of the pop-up menu
array<CTextMenu@> g_menus(g_Engine.maxClients+1, null);

Vote@ g_SampleVote;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

    ReadMaps();
}

void MapInit(){
	g_Game.PrecacheGeneric( "sound/" + voteNow );
	g_SoundSystem.PrecacheSound( voteNow );
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
    CBasePlayer@ plr = pParams.GetPlayer();
    //  The written text will be loaded into args
    const CCommand@ args = pParams.GetArguments();

    //  Compares the text with keyword
    if (args.Arg(0).ToLowercase() == "votemap" || args.Arg(0).ToLowercase() == "mapvote")
    {
        openMapMenu(plr, 0);
        //  Stops keyword from showing up in global chat
        pParams.ShouldHide = true;
    }
    
    //  Keeps the Hook running after someone used the chat
    return HOOK_CONTINUE;
}

void ReadMaps()
{
    g_maps.resize(0);

    //  Opens the file located in the directory g_mapsfile
    File@ file = g_FileSystem.OpenFile(g_mapsfile, OpenFile::READ);
    //  
    if (file !is null && file.IsOpen())
    {
        while(!file.EOFReached())
        {
            string lineContent;
            //  Saves the content of the line in lineContent
            file.ReadLine(lineContent);
            //  Removes blanks
            lineContent.Trim();

            if (lineContent.IsEmpty())
            continue;

            //  Inserts the content of lineContent at the end of g_maps
            g_maps.insertLast(lineContent);
        }
        file.Close();
    }
    // Sorts the maps alphabetical (ascending)
    g_maps.sortAsc();
}

void mapMenuCallback(CTextMenu@ menu, CBasePlayer@ plr, int itemNumber, const CTextMenuItem@ item)
{
    if (item is null or plr is null or !plr.IsConnected())
    {
        return;
    }

    string mapName = StripEdgeColorCodes(item.m_szName);

    if (mapName == "")
    {
        g_Scheduler.SetTimeout("openMapMenu", 0.0f, EHandle(plr), 0); // wait a frame or else game crashes
    } else
    {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, "Mapvote incoming!\n");
        g_Scheduler.SetTimeout("startMapVote", 3.0f, mapName);
    }
}

void openMapMenu(EHandle h_plr, int pageNum)
{
    CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
    if (plr is null)
        return;

    const int eidx = plr.entindex();

    //  Initiates the mapMenuCallback as handle for the input you pick 
    @g_menus[eidx] = CTextMenu(@mapMenuCallback);

    g_menus[eidx].SetTitle("\\gMap Menu\\g   ");

    for (uint i = 0; i < g_maps.length(); i++)
    {
        g_menus[eidx].AddItem("\\w" + g_maps[i] + "\\g");
    }

    g_menus[eidx].Register();
    g_menus[eidx].Open(0, pageNum, plr);
}

string StripEdgeColorCodes(const string &in s)
{
    uint L = s.Length();

    if (L >= 4 && s[0] == '\\' && s[L-2] == '\\')
        return s.SubString(2, L - 4);

    return s;
}

void startMapVote(const string & in mapName)
{

    if (g_SampleVote !is null)
        return;

    @g_SampleVote = Vote("Mapvote", "Change map to " + mapName + "?\n", 20.0f, 51.0f);

    g_SampleVote.SetYesText("Yee");
    g_SampleVote.SetNoText("Nee");

    any@ ud = any();        // Add any-Container
    ud.store(mapName);      // Store string in any-Container
    g_SampleVote.SetUserData(ud);

    g_SampleVote.SetVoteEndCallback(@OnVoteEnd);
    g_SampleVote.SetVoteBlockedCallback(@OnVoteBlocked);

    g_SampleVote.Start();
    g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, voteNow, 1.0f, 0.0f);

    countDown(20);
}

void countDown(int n)
{
    if (n <= 0) {
        return;
    }

    g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, "Vote ends in " + n + " Seconds\n");

    g_Scheduler.SetTimeout("countDown", 1.0f, n - 1);
}

void OnVoteEnd(Vote@ pVote, bool fResult, int iVoters)
{
    string mapName = "";
    any@ ud = pVote.GetUserData();
    ud.retrieve(mapName);

    const string verdict = fResult ? " Accepted" : " Denied";
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER,
        "Vote " + pVote.GetVoteText() +  verdict +
        " (Votes: " + iVoters + ")\n");

    if (fResult) {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, "Map changed to " + mapName + "!\n");
        g_Scheduler.SetTimeout("Mapchange", 2.0f, mapName);
    }

    pVote.ClearUserData();
    @g_SampleVote = null;
}

void Mapchange(const string & in mapName){
    g_EngineFuncs.ServerCommand("changelevel " + mapName + "\n");
}

void OnVoteBlocked(Vote@ pVote, float flTime)
{
    const float rest = Math.max(0.0f, flTime - g_Engine.time);
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY,
        "[Vote] Blocked: Another Vote is running!"
        "(~" + int(Math.Ceil(rest)) + "s).\n");
}
