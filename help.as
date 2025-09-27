void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
    const CCommand@ args = pParams.GetArguments();
	CBasePlayer@ player = pParams.GetPlayer();

    if (args.ArgC() > 0){
        if (args.Arg(0).ToLowercase() == "help"){
			if(g_PlayerFuncs.AdminLevel(player)>=ADMIN_YES){
                g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"map = forced mapvote (admin only)\n");
			    g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"mapvote = mapvote menu (admin only)\n");
            }
			g_PlayerFuncs.ClientPrint(player,HUD_PRINTTALK,"player = lists living and connected players\n");


			pParams.ShouldHide = true;
			return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}	