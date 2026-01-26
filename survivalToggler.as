void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

HookReturnCode ClientSay(SayParameters@ pParams){
    const CCommand@ args = pParams.GetArguments();
	CBasePlayer@ player = pParams.GetPlayer();

    if (args.ArgC() > 0){
        if (args.Arg(0).ToLowercase() == "survival"){
			if(g_PlayerFuncs.AdminLevel(player)>=ADMIN_YES){
				g_PlayerFuncs.ClientPrintAll(HUD_PRINTCENTER,"Survival Mode toggled!\n");
				g_Scheduler.SetTimeout("survivalToggle",1.0f);
			}	
			else{
				g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"Admins only!\n");}	
		
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}

void survivalToggle(){
    g_EngineFuncs.ServerCommand("toggle_survival_mode\n");
}