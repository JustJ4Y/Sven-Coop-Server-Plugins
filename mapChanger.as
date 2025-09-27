void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

HookReturnCode ClientSay(SayParameters@ pParams){
    const CCommand@ args = pParams.GetArguments();
	CBasePlayer@ player = pParams.GetPlayer();

    if (args.ArgC() > 0){
        if (args.Arg(0).ToLowercase() == "map"){
			if(g_PlayerFuncs.AdminLevel(player)>=ADMIN_YES){
				if (args.ArgC() > 1){
					string mapname=args.Arg(1);
					
					if (g_EngineFuncs.IsMapValid(mapname)){
						g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER,"Map changed to " + mapname + "!\n");
						g_Scheduler.SetTimeout("Mapchange",2.0f,mapname);
					}
					else{
						g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"Map " + mapname + " does not exist!\n");}
				}	
				else{
					g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"Don't forget your map names!\n");}
			}	
			else{
				g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"Admins only!\n");}	
		
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}

void Mapchange(const string & in mapname){
g_EngineFuncs.ServerCommand("changelevel " + mapname + "\n");
}