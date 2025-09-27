const string g_mapsfile = "scripts/plugins/cfg/maps.txt";

array<string> g_maps;

//  Global initiation of the pop-up menu
array<CTextMenu@> g_menus(g_Engine.maxClients+1, null);

void PluginInit()
{
  //  Information for as_listplugin command
  g_Module.ScriptInfo.SetAuthor("JustJ4y, Megaraptor38");
  g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

  //  Register what the player writes in chat
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

  //  Load the maps listed in maps.txt
  ReadMaps();
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
  CBasePlayer@ plr = pParams.GetPlayer();
  //  The written text will be loaded into args
  const CCommand@ args = pParams.GetArguments();

  if(g_PlayerFuncs.AdminLevel(plr)>=ADMIN_YES)
  {
    //  Compares the text with keyword
    if (args.Arg(0).ToLowercase() == "menumap" || args.Arg(0).ToLowercase() == "mapmenu")
    {
      openMapMenu(plr, 0);
      //  Stops keyword from showing up in global chat
      pParams.ShouldHide = true;
    }
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
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER, "Map changed to " + mapName + "!\n");
    g_Scheduler.SetTimeout("Mapchange", 2.0f, mapName);
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

void Mapchange(const string & in mapname){
  g_EngineFuncs.ServerCommand("changelevel " + mapname + "\n");
}